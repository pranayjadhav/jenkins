public class LeadTriggerHandler {
	public static Savepoint sp{get;set;}
	
    public static void updateBuildingInterestOnLead(){

            Set<String> allBuildings = new Set<String>();
            for(Lead leadRec : (List<Lead>)trigger.new){
                if(leadRec.Locations_Interested__c != null){
                    String strBuildingName = leadRec.Locations_Interested__c.split(';')[0];
                    allBuildings.add(strBuildingName);
                }
            }
            List<Building__c> buildingsList = [SELECT Id, Name FROM Building__c WHERE Name in:allBuildings];
            Debug.log('buildingsList:');
            Map<String, Id> allBuildingsMap = new Map<String, Id>();
            for(Building__c building : buildingsList){
                allBuildingsMap.put(building.Name,building.Id);
            }
            for(Lead leadRec : (List<Lead>)trigger.new){
                if(leadRec.Locations_Interested__c != null){
                    String strBuildingName = leadRec.Locations_Interested__c.split(';')[0];
                    if(allBuildingsMap.containsKey(strBuildingName))
                    	leadRec.Building_Interested_In__c = allBuildingsMap.get(strBuildingName);
                }
            }
    }
    
    /*
	* When Lead gets converted, we need to set the Contact person on the Journey as a "Primary Contact".
	* @Created by	: Mayuresh Ghodke
	* @Date			: 28/07/2016
	* @Issue No.	: ST-574
	*/
    public static void updateJourneyPrimaryContact(){
    	Debug.log(':: updateJourneyPrimaryContact ::');
    	Set<Id> setConvertedLeadId = new Set<Id>();
    	List<Journey__c> lstJourneyToUpdate = new List<Journey__c>();
        for(Lead leadRec : (List<Lead>)trigger.new){
            if(leadRec.IsConverted){
                setConvertedLeadId.add(leadRec.Id);
            }
        }
        Debug.log('setConvertedLeadId ::'+setConvertedLeadId);
        List<Journey__c> lstJourney = new List<Journey__c>([Select Id, Primary_contact__c,Primary_Lead__c From Journey__c Where Primary_Lead__c IN : setConvertedLeadId]);
        Debug.log('lstJourney ::'+lstJourney);
        if(lstJourney!=null && !lstJourney.isEmpty()){
	        for(Journey__c journeyRec : lstJourney){
	        	for(Lead leadRec : (List<Lead>)trigger.new){
		            if(journeyRec.Primary_Lead__c == leadRec.Id){
		                journeyRec.Primary_contact__c = leadRec.ConvertedContactId;
		                journeyRec.Primary_Lead__c = null;
		                lstJourneyToUpdate.add(journeyRec);
		            }
	        	}
	        }
	        Debug.log('lstJourneyToUpdate ::'+lstJourneyToUpdate);
        	if(lstJourneyToUpdate!=null && !lstJourneyToUpdate.isEmpty())
        		update lstJourneyToUpdate;
        }
    }

    /**
		 * REMOVED - Moves the Id of a converted Lead onto the Lead_Id__c field of the created Opportunity
		 *
		 * @author  Antonio Grassi
		 * @date    02/07/2014
		 *
		 * Updates Created opportunity once again to get Primary Member
		 *
		 * @author  Ivan Tadic
		 * @date    03/12/2014
		 *
		 * Sets new Opportunity Stage depending on Tour Status
		 *
		 * @author  Antonio Grassi
		 * @date    04/02/2014
		 * 
		 * This metohd is moved from LeadConversion.trigger
		 */
		 
		  /**
		* Sets new Opportunity Stage depending on Tour Status
		* @Merge	Amol Darekar
		* @Old Trigger LeadConversion.trigger
		* @Date	05/07/2016
	*/
  public static void SetNewOpprtunityStageDependsOnTourStatus()
   {
     	Set<Id> oppIds = new Set<Id>();
     	
  		for (Lead l:(List<Lead>)Trigger.new) {
	        if (l.IsConverted && !((Lead)Trigger.oldMap.get(l.Id)).IsConverted && l.ConvertedOpportunityId != null) {
	            oppIds.add(l.ConvertedOpportunityId);
	        }
	    }
	    
	    if (!oppIds.isEmpty()) {
	        Map<Id, Opportunity> ops = new Map<Id, Opportunity>([select Id,
	                                                                    Lead_Id__c,
	                                                                    StageName,
	                                                                    Tour_Date__c
	                                                             from Opportunity
	                                                             where Id in :oppIds]);
	        
	        if (!ops.isEmpty()) {
	        	
	            Set<Opportunity> opsToUpdate = new Set<Opportunity>{};
	            
		        for (Tour_Outcome__c t:[select Status__c,
		                                       Opportunity__c,
		                                       CreatedDate
		                                from Tour_Outcome__c
		                                where Opportunity__c in :ops.keySet()
		                                and (Status__c = 'Scheduled' or Status__c = 'Cancelled')
		                                order by CreatedDate asc]) {
	
		            if (t.Status__c == 'Cancelled') {
		            	ops.get(t.Opportunity__c).StageName = 'Inquiry';
		            	opsToUpdate.add(ops.get(t.Opportunity__c));
		            }
		            else if (t.Status__c == 'Scheduled' && ops.get(t.Opportunity__c).StageName == 'Inquiry') {
		            	ops.get(t.Opportunity__c).StageName = 'Tour Scheduled';
		            	ops.get(t.Opportunity__c).Tour_Scheduled__c = t.CreatedDate.date();
		            	opsToUpdate.add(ops.get(t.Opportunity__c));
		            }
		        }
	
	            if (!opsToUpdate.isEmpty()) {
	            	update new List<Opportunity>(opsToUpdate);
	            }
	        }
	    } 
    
    }
    
    
      /**
		* Create Delete Building Interest on lead insert or update
		* @Merge	Amol Darekar
		* @Old Trigger BuildingInterestTrigger.trigger
		* @Date	05/07/2016
	*/
    public static void CreateDeleteBuildingInterest()
    {
    	String NONE_BUILDING_NAME = 'None';
    	//End
		//Keep related list in sync
		//Map of Leads to process(Only non-converted)
		Map<Id,Lead> leadsToProcess = new Map<Id,Lead>();
		for(Lead l :(List<Lead>) trigger.new){
			if(!l.IsConverted){
				leadsToProcess.put(l.Id,l);
			}
		}
		
		//Get all existing Building Interest records
		List<Building_Interest__c> existingInts = [SELECT
														Id, Building__c, Building__r.Name, Lead__c, Lead__r.Locations_Interested__c
												   FROM
												   		Building_Interest__c
												   WHERE
												   		Lead__c IN :leadsToProcess.keySet()
												   ORDER BY
												   		Lead__c];
		//Lists for creation and deletion
		List<Building_Interest__c> intsForCreate = new List<Building_Interest__c>();
		List<Building_Interest__c> intsForDelete = new List<Building_Interest__c>();
	
		//Check if Building Interest is removed from Locations_Interested__c list
		Id lastLead = null;
		Set<string> leadLocationsSet = new Set<string>();
		for(Building_Interest__c bi : existingInts){
			if(lastLead != bi.Lead__c){
				lastLead = bi.Lead__c;
				if(String.isBlank(bi.Lead__r.Locations_Interested__c)) {
					leadLocationsSet = new Set<String>{NONE_BUILDING_NAME};
				} else {
					leadLocationsSet = Common.splitStringToSet(bi.Lead__r.Locations_Interested__c , ';');	
				}
			}
			if(!leadLocationsSet.contains(bi.Building__r.Name)){
				intsForDelete.add(bi);
			}
		}
	
		//Check which have to be added
		Map<Id, Set<string>> leadExistingIns = new Map<Id, Set<string>>();
		for(Building_Interest__c bi : existingInts){
			if(!leadExistingIns.containsKey(bi.Lead__c)){
				leadExistingIns.put(bi.Lead__c, new Set<string>());
			}
			Set<string> biSet = leadExistingIns.get(bi.Lead__c);
			biSet.add(bi.Building__r.Name);
		}
	
		List<Building__c> buildings = [SELECT Id, Name FROM Building__c];
		Map<string, Building__c> buildingsMap = new Map<string, Building__c>();
		for(Building__c b : buildings){
			buildingsMap.put(b.Name, b);
		}
	
		for(Lead l : leadsToProcess.values()){
			List<String> selectedLocations = new List<string>();
			if(string.isBlank(l.Locations_Interested__c)){
				selectedLocations.add(NONE_BUILDING_NAME);
			} else {
				selectedLocations = Common.splitStringToList(l.Locations_Interested__c, ';');
			}
			for(string selectedLocation : selectedLocations){
				Set<string> existingLocations = leadExistingIns.get(l.Id);
				if(existingLocations == null || !existingLocations.contains(selectedLocation)){
					if(buildingsMap.containsKey(selectedLocation)){
						Building_Interest__c bi = new Building_Interest__c(Lead__c  	= l.Id,
																		   Building__c	= buildingsMap.get(selectedLocation).Id);
						intsForCreate.add(bi);
					}
				}
			}
		}
	
		insert intsForCreate;
		delete intsForDelete;
		
		//Map<Id, Id> leadToOppMap = new Map<Id, Id>();
    }
    
    /**
		* Delete Building Interest on lead delete
		* @Merge	Amol Darekar
		* @Old Trigger BuildingInterestTrigger.trigger
		* @Date	05/07/2016
	*/
    //Moved from BuildingInterestTrigger.trigger
    public static void DeleteBuildingInterestOnLeadDelete()
    {
    	//Delete if Lead is deleted

		//Get all existing Building Interest records
		List<Building_Interest__c> existingInts = [SELECT
														Id
												   FROM
												   		Building_Interest__c
												   WHERE
												   		Lead__c IN :trigger.oldMap.keySet()
												   ORDER BY
												   		Lead__c];
		if (existingInts.size() > 0)
			delete existingInts;
    }
    
    /**
		*Copy OfficeType From Lead To Building Interest
		* @Merge	Amol Darekar
		* @Old Trigger BuildingInterestTrigger.trigger
		* @Date	05/07/2016
	*/
    public static void CopyOfficeTypeFromLeadToBuildingInterest()
    {
    	//Copy Office Type from Lead to related Building Interests
       List<Building_Interest__c> bints = [SELECT Id, Lead__c, Office_Type__c FROM Building_Interest__c
                                            WHERE Lead__c IN :trigger.newMap.keySet()];
        List<Building_Interest__c> bintsForUpdate = new List<Building_Interest__c>();                                                    
        for(Building_Interest__c bint : bints){
            Lead parentLead = (Lead)Trigger.newMap.get(bint.Lead__c);
            //Update if it is different
            if(bint.Office_Type__c != parentLead.Office_Type__c){
                bint.Office_Type__c = parentLead.Office_Type__c;
                bintsForUpdate.add(bint);    
            }
        }

        if(bintsForUpdate.size() > 0){
            update bintsForUpdate;
        }
    }
    
    /**
		* Created By : Mayuresh Ghodke.
		* Modified By : Amol Darekar.
		* Date of Modified: 07/07/2016.
	*/
    public static void ChangeRelatedJourneyStatus()
    {
    	Set<Id> setLeadId  = new set<Id>(); //Set of Lead Ids.
    	map<String,String> mapJourenyStatus = new map<String,String>();

    	for(Lead lead : (List<Lead>)Trigger.new){
    		if(((Lead)Trigger.oldMap.get(lead.Id)).Status != lead.Status  && lead.Status == 'Unqualified'){
    		   setLeadId.add(lead.Id);
    		}
    	}
    	
    	if(setLeadId !=null && setLeadId.size() > 0)
    	{
	    	Setting__c JSONLeadJourneyStatus = Settings.get('LeadJourneyTrigger');
	    	if(JSONLeadJourneyStatus != null)
	    	{
		    	list<LeadJourneyStatusController> lstLeadJourneyStatus = new list<LeadJourneyStatusController>();
		    	
		    	lstLeadJourneyStatus = (List<LeadJourneyStatusController>)JSON.deserialize(JSONLeadJourneyStatus.Data__c, List<LeadJourneyStatusController>.class);
		    	
		    	if(lstLeadJourneyStatus != null && lstLeadJourneyStatus.size() > 0)
		    	{
		    		for(LeadJourneyStatusController currentStatus : lstLeadJourneyStatus)
		    		{
		    			mapJourenyStatus.put(currentStatus.LeadStatus,currentStatus.JourneyStage);
		    		}
		    		
		    	}
		    	
		    	Debug.Log('In Lead Trigger setLeadId :'+setLeadId);
		    	List<Journey__c> lstJourneyToUpdate = new List<Journey__c>();
		    	List<Journey__c> lstJourney = new List<Journey__c>([Select Id,Stage__c,Primary_Lead__c From Journey__c Where Primary_Lead__c IN : setLeadId and Stage__c != 'Completed-Lost']);
		    	Debug.Log('In Lead Trigger lstJourney :'+lstJourney);
		    	
			    if(lstJourney != null && lstJourney.size() > 0)	
			    {
			    	for(Lead lead : (List<Lead>)Trigger.new){
			    		if(((Lead)Trigger.oldMap.get(lead.Id)).Status != lead.Status  && lead.Status == 'Unqualified'){ //Trigger.oldMap.get(lead.Id).Status != lead.Status && 
			    			Debug.Log('In Lead Trigger lead.Id :'+lead.Id);
			    			for(Journey__c journey : lstJourney){
			    				if(journey.Primary_Lead__c == lead.Id){
			    					Debug.Log('In Lead Trigger journey.Id  :'+journey.Id);
			    					if(mapJourenyStatus.containsKey(lead.Status))
			    					{
							    		journey.Stage__c = mapJourenyStatus.get(lead.Status);
							    		lstJourneyToUpdate.add(journey);
			    					}
			    				}
					    	}
			    		}
			    	}
			    	
			    	update lstJourneyToUpdate;
			    }
	    	}
    	}
    }
    
    /**
		* Created By : Dipak.
		* Delete Lead if Email or Phone is blank.
		* Created Date : 14 July 2016.
	*/
    public static void blankEmailOrPhoneOnLead() {
    	for(Lead currentLead : (List<Lead>)trigger.new){
    		if((currentLead.Email == null || currentLead.Email == '') && (currentLead.Phone == null || currentLead.Phone == '')){
    			currentLead.addError('Email and Phone cannot be blank on Lead.');
    		}
    	}
    }
    
   /**
		* Created By : Amol Darekar.
		* Comment : This method get active Referrence record and set Referrer__c field value of lead based on lead email Id.
		* Created Date : 19 July 2016.
		* Issue : ST-352
	*/
    public static void UpdateActiveReferrerOnLead()
    {
    	sp = Database.setSavepoint();
        set<string> setLeadEmails = new set<string>();
        
        for(Lead currentLead : (List<Lead>)trigger.new)
        {
            if(!string.isBlank(currentLead.Email))
            {
                setLeadEmails.add(currentLead.Email);
            }
        }
        
        map<string,Id> mapActiveReference = ReferenceHandler.getActiveReference(setLeadEmails);
        
       if(mapActiveReference != null && mapActiveReference.size() > 0)
       {
          for(Lead currentLead : (List<Lead>)trigger.new)
          {
            if(!string.isBlank(currentLead.Email) && mapActiveReference.containsKey(currentLead.Email.toLowerCase()))
            {
                currentLead.Referrer__c = mapActiveReference.get(currentLead.Email.toLowerCase());
            }
         }   
       }
    }
    
    /**
		* Created By : Amol Darekar.
		* Comment : This method get change the lead owner id if the owner is inactive user.
		* Created Date : 21 July 2016.
		* Issue :ST-542
	*/
    public static void ChangeLeadOwnerToActiveUser()
    {
    	list<lead> lstLeads = [select Id, Name,OwnerId from Lead where OwnerId in (select Id from User where IsActive = false) and isConverted = false];
		map<Id,Id> mapLeadOwner =  new map<Id,Id>(); 
		list<lead> leadsToUpdate = new list<lead>();
		
		for(lead lead : lstLeads)
		{
		    Database.DMLOptions dmo = new Database.DMLOptions();
			dmo.assignmentRuleHeader.useDefaultRule = true;
			lead.setOptions(dmo);
		    mapLeadOwner.put(lead.Id,lead.ownerId);
		}
		update lstLeads;

		for(lead lead : lstLeads)
		{
		   if(mapLeadOwner.get(lead.Id) == lead.ownerId)
		   {
		       lead.ownerId = UserInfo.getUserId();
		       leadsToUpdate.add(lead);
		  }
		}
		update leadsToUpdate;
    }
    
    public class LeadJourneyStatusController 
    {
    	public string LeadStatus{get;set;}
    	public string JourneyStage{get;set;}
    }
}