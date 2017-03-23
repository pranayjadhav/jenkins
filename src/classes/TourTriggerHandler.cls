/*
 * @ Created By : Anant Kumar
 * @ Created Date : 23 Feb 2016
 */
public class TourTriggerHandler {
    public static Boolean bOnceExTrigger = false;
 
    public static void updateMostRecentTourDate(Set<Id> conIdSet){
        if(bOnceExTrigger == false){
            Map<Id, Opportunity> conOppMap = new Map<Id, Opportunity>([SELECT Id, Primary_Member__c, Primary_Member__r.Most_recent_tour_date__c, StageName, (SELECT Id, Tour_Date__c, Start_Time__c, Tour_Date_Time__c FROM Tour_Outcome__r) FROM Opportunity WHERE Primary_Member__c IN :conIdSet]);
            Debug.log('conOppMap::::'+conOppMap);
            Map<Id, Contact> contactToUpdateMap = new Map<Id, Contact>();
            DateTime currentTimeStamp = system.now();
            for(Opportunity opp : conOppMap.values()){
                if(opp.Primary_Member__c != null && opp.Tour_Outcome__r.size() > 0){
                    Date mostRecentDate = null;
                    Datetime mostRecentDateTime = null;
                    for( Tour_Outcome__c tour : opp.Tour_Outcome__r){
                        if(tour.Tour_Date_Time__c != null && tour.Tour_Date_Time__c < currentTimeStamp){
                            if(mostRecentDateTime == null) mostRecentDateTime = tour.Tour_Date_Time__c;
                            if(mostRecentDateTime < tour.Tour_Date_Time__c)
                                mostRecentDateTime = tour.Tour_Date_Time__c; 
                        }
                        else if(tour.Tour_Date__c != null && tour.Tour_Date__c < currentTimeStamp){
                            Datetime tourDatetime = datetime.newInstance(tour.Tour_Date__c.year(), tour.Tour_Date__c.month(),tour.Tour_Date__c.day());
                            if(mostRecentDateTime == null) mostRecentDateTime = tourDatetime;
                            if(mostRecentDateTime < tourDatetime)
                                mostRecentDateTime = tourDatetime;
                        }
                    }
                    Contact con = new Contact();
                    con.Id = opp.Primary_Member__c;
                    con.Most_recent_tour_date__c = mostRecentDateTime;
                    if(contactToUpdateMap.containsKey(con.Id)){
                        if(con.Most_recent_tour_date__c > contactToUpdateMap.get(con.Id).Most_recent_tour_date__c)
                           contactToUpdateMap.get(con.Id).Most_recent_tour_date__c = con.Most_recent_tour_date__c;
                    }
                    else{
                        contactToUpdateMap.put(con.Id, con);
                    }
                        
                }
            }
            if(contactToUpdateMap.size() > 0){
                try{
        			update contactToUpdateMap.values();
                }
                catch(DMLException ex){
                    Debug.log(ex.getMessage());
                }
                bOnceExTrigger = true;
            }
        }
    }

    //ST-444 : Tour_Outcome__c: Stage Update for Journey Records
    //Changes made by : Pranay Jadhav
    //Date : 28/June/2016
    public static void updateJourneyStage(){
    	Set<Id> setJourneyIds = new Set<Id>();
        List<Journey__c> lstUpdateJourneys = new List<Journey__c>();
    	for(Tour_Outcome__c tour : (List<Tour_Outcome__c>)trigger.new){
            setJourneyIds.add(tour.Journey__c);
        }
        List<Journey__c> listJourneys = [Select Id,Name,Stage__c,(Select Id,Name,Status__c From Tours__r) From Journey__c Where Id in : setJourneyIds];
        for (Journey__c Journey : listJourneys) {
        	Boolean boolChangeStage = false;
        	if(Journey.Tours__r.size() > 0){
			    for (Tour_Outcome__c Tour : Journey.Tours__r) {
                    if(Journey.Stage__c == 'Started' && Tour.Status__c != 'Completed' ){
                    	boolChangeStage = false;
                    }   
                    if(Journey.Stage__c =='Booked Tour' && Tour.Status__c == 'Completed'){
                    	boolChangeStage = true;
                    	break;
                    }
			    }   
			    if(Journey.Tours__r.size() > 0 && boolChangeStage){
			    	Journey.Stage__c = 'Tour Completed';
			    }else if(Journey.Tours__r.size() > 0 && (boolChangeStage == false)){
			    	Journey.Stage__c = 'Booked Tour';
			    }else{
			    	Journey.Stage__c = 'Started';
			    }      
                lstUpdateJourneys.add(Journey);
            }
		}
        update lstUpdateJourneys;
    } 
        
    //ST-372 : Close all open InboundLead Leads activities
    //Author : Anant Kumar
    //Date : 15-June-2015
    public static void closeAllOpenInboundLead(){
		Setting__c objectData = Settings.get('CloseOpenActivities');
		Debug.Log( 'Subjects To Close : Settings : ' + objectData);
		if( objectData == null )
			return;

		Map<String, Object> mapData = (Map<String,Object>)JSON.deserializeUntyped(objectData.Data__c);
        Set<String> subjectSet = new Set<String>();
		for(String strSubject : String.valueOf(mapData.get('subject')).split(',') ){
			subjectSet.add(strSubject.trim().toLowerCase());
		}
		if( subjectSet.size() <= 0 )
			return;

		Debug.log('Subjects To Close : ' + subjectSet);
    	Set<Id> scheduledByIdSet = new Set<Id>();
        Set<Id> opportunityIdSet = new Set<Id>();
        Set<Id> contactIdSet = new Set<Id>();
        for(Tour_Outcome__c tour : (List<Tour_Outcome__c>)trigger.new){
            if(tour.Scheduled_By__c != null)
                scheduledByIdSet.add(tour.Scheduled_By__c);
            if(tour.Opportunity__c != null)
                opportunityIdSet.add(tour.Opportunity__c);
        }
        
        if(opportunityIdSet.size() > 0){
            for(Opportunity opp : [Select Id, Primary_Member__c From Opportunity Where Id in :opportunityIdSet]){
                if(opp.Primary_Member__c != null)
                    contactIdSet.add(opp.Primary_Member__c);
            }
        }
        
        if(contactIdSet.size() > 0){
        	
        	List<Contact> contactWithActivityList = new List<Contact>([Select Id, (Select Id, Subject From Tasks Where Subject in:subjectSet and Status != 'Completed') From Contact Where Id in :contactIdSet]);
			List<Task> openInboundLeadTask = new List<Task>();
			for(Contact con : contactWithActivityList){
				for(Task task : con.tasks){
					if(subjectSet.contains(task.Subject.toLowerCase())){
						task.Status = 'Completed';
						openInboundLeadTask.add(task);
					}
				}
			}
			update openInboundLeadTask;
        }
    }
    
    //ST-464 : Tour_Outcome__c: Move TourEndTime to TourTriggerHandler
    //Changes made by : Anant Kumar
    //Date : 22/June/2016
    public static void updateTourEndTime(){
    	for (Tour_Outcome__c t : (List<Tour_Outcome__c>)Trigger.new) {
			//if no end time, add a default one
			if (t.End_Time__c == null && t.Start_Time__c != null) {			
				//start time is required so always exists
				Time parsed_time = TourServices.parsePicklistTime(t.Start_Time__c);
	
				t.End_Time__c = Datetime.newInstance(
					Date.today(), //just used as reference we only need the time
					parsed_time.addMinutes(30)	
				).format('h:mma');			
			}
	
			//remove leading 0
			if (t.End_Time__c != null && t.Start_Time__c != null) {			
				t.End_Time__c = t.End_Time__c.removeStart('0');			
			}
		}
    }
    
    
    //ST-469 : Tour_Outcome__c: Move TourScheduledConvertLead to TourTriggerHandler
    //Changes made by : Anant Kumar
    //Date : 22/June/2016
    public static void tourScheduledConvertLead()
    {
    	if (!TriggersFlags.allowTourUpdates) {
	    	return;
	    }
	    
	    Set<Id> leadIds = new Set<Id>{};
	    Set<Tour_Outcome__c> toursToProcess = new Set<Tour_Outcome__c>{};
	    Map<Id, Tour_Outcome__c> mapTriggerOldMap = (Map<Id, Tour_Outcome__c>)Trigger.oldMap;
	    // Check which Tours should have its Lead converted
	    for (Tour_Outcome__c t:(List<Tour_Outcome__c>)Trigger.new) {
	    	
	    	if (t.Status__c == 'Scheduled' && (Trigger.isInsert || mapTriggerOldMap.get(t.Id).Status__c != t.Status__c) && t.Lead__c != null) {
	            toursToProcess.add(t);
	            leadIds.add(t.Lead__c);
	    	}
	    }
	    Debug.log('leadIds'+leadIds.size());
	    if (!leadIds.isEmpty()) {
	    	
	    	// Find Contacts with an e-mail matching Lead email
	    	Set<String> leadEmails = new Set<String>{};
	    	
	    	Lead[] leads = [select Id, Email from Lead where Id in :leadIds];
	    	
	    	for (Lead l:leads) {
	    		if (!String.isBlank(l.Email)) {
	                leadEmails.add(l.Email);
	    		}
	    	}
	
	    	Map<String, Contact> emailToContactMap = new Map<String, Contact>{};
	    	
	    	if (!leadEmails.isEmpty()) {
	    		
	    		Contact[] contactCandidates = [select Id, Email, AccountId from Contact where Email in :leadEmails];
	    		Set<Id> accountIds = new Set<Id>{};
	    		
	    		for (Contact c:contactCandidates) {
	    			accountIds.add(c.AccountId);
	    		}
	
	            Map<Id, Date> accountLastActivityDate = new Map<Id, Date>{};
	            
	            for (Account a:[select Id,
	                                   (
	                                    select ActivityDate
	                                    from ActivityHistories
	                                    order by ActivityDate desc
	                                    limit 1
	                                   )
	                            from Account
	                            where Id in :accountIds]) {
	
	                accountLastActivityDate.put(a.Id, !a.ActivityHistories.isEmpty() ? a.ActivityHistories[0].ActivityDate : null);
	            } 
	
	            for (Contact c:contactCandidates) {
	            	
	            	if (!emailToContactMap.containsKey(c.Email) ||
	            	    (accountLastActivityDate.get(c.AccountId) != null &&
	            	     (accountLastActivityDate.get(emailToContactMap.get(c.Email).AccountId) == null ||
	            	      accountLastActivityDate.get(emailToContactMap.get(c.Email).AccountId) < accountLastActivityDate.get(c.AccountId)))) {
	
	                    emailToContactMap.put(c.Email, c);
	            	}
	            }
	    	}
	    	
	        
	        // We are all set, convert Leads
	    	Map<Id, Id> leadToContactMap = new Map<Id, Id>{};
	    	LeadStatus convertedStatus = [select Id, MasterLabel from LeadStatus where IsConverted = true limit 1];
	
	    	Database.LeadConvert[] leadConversions = new Database.LeadConvert[]{};
	    	
	    	for (Lead l:leads) {
	    		
	            Database.LeadConvert lc = new Database.LeadConvert();
	            lc.setLeadId(l.Id);
	            lc.setConvertedStatus(convertedStatus.MasterLabel);
	
	            // If Contact with matching email exists, use that Contact & Opportunity
	    		if (!String.isBlank(l.Email) && emailToContactMap.containsKey(l.Email)) {
	
	    			lc.setContactId(emailToContactMap.get(l.Email).Id);
	    			lc.setAccountId(emailToContactMap.get(l.Email).AccountId);
	    		}
	
	            leadConversions.add(lc);
	    	}
	    	
	    	Map<Id, Id> leadToConvertedContact = new Map<Id, Id>{};
	    	Map<Id, Id> leadToConvertedOpportunity = new Map<Id, Id>{};
	    	
	    	TriggersFlags.allowTourUpdates = false;
	    	
	    	for (Database.LeadConvertResult res:Database.convertLead(leadConversions, true)) {
	    		
	    		if (res.isSuccess()) {
	    			leadToConvertedContact.put(res.getLeadId(), res.getContactId());
	    			leadToConvertedOpportunity.put(res.getLeadId(), res.getOpportunityId());
	    		}
	    		else if (!res.errors.isEmpty()) {
	    			System.debug(LoggingLevel.ERROR, res.errors[0]);
	    		}
	    	}
	    	
	    	TriggersFlags.allowTourUpdates = true;
	    	
	    	// Update Tours: relate to Contact (Scheduled By) and Opportunity, and remove Lead
	    	for (Tour_Outcome__c t:toursToProcess) {
	    		if (leadToConvertedContact.containsKey(t.Lead__c)) {
	    			t.Scheduled_By__c = leadToConvertedContact.get(t.Lead__c);
	    			t.Opportunity__c = leadToConvertedOpportunity.get(t.Lead__c);
	    			t.Primary_Member__c = leadToConvertedContact.get(t.Lead__c);
	    			t.Lead__c = null;
	    		}
	    	}
	    }
    }
	
    /**
		* Created By : Samadhan Kadam.
		* Comment : This method get active Referrence record and set Referrer__c field value of Tour based on Primary_Member__c email Id.
		* Created Date : 20 July 2016.
		* Issue : ST-531
	*/
    public static void updateActiveReferrerOnTour(){
    	
        Set<Id> setContact = new Set<Id>();
        Set<String> setOfContactEmail = new Set<String>();
		Map<Id,String> mapOfContact = new Map<Id,String>();
		      
        for(Tour_Outcome__c currentTour : (List<Tour_Outcome__c>)trigger.new){
            if(currentTour.Primary_Member__c != null){
               setContact.add(currentTour.Primary_Member__c);
            }
        }
        for(Contact contact : [SELECT Id,Email FROM Contact WHERE Id IN:setContact]){
        	if(contact.Email != null){
       		setOfContactEmail.add(contact.Email.toLowerCase());
        	mapOfContact.put(contact.Id,contact.Email.toLowerCase());
        	}
        }
        map<string,Id> mapActiveReference = ReferenceHandler.getActiveReference(setOfContactEmail);
        
       if(mapActiveReference != null && mapActiveReference.size() > 0){
          for(Tour_Outcome__c currentTour : (List<Tour_Outcome__c>)trigger.new){
         	 currentTour.Referrer__c = mapActiveReference.get(mapOfContact.get(currentTour.Primary_Member__c));
          }   
       }
   } 
   	
    /**
		* Created By : Samadhan Kadam.
		* Comment : This method extend validity(Expires On) of Reference__c for 60 days if Tour Status__c is Completed or Scheduled.
		* Created Date : 22 July 2016.
		* Issue : ST-473
	*/

    public static void extendValidityOfReference(){
    	
    	Set<Id> setOfContact = new Set<Id>();
    	Set<String> setOfContactEmail = new Set<String>();
    	
    	if(Trigger.isInsert){
    		for(Tour_Outcome__c tour : (List<Tour_Outcome__c>)trigger.new){
    			if(tour.Status__c == 'Scheduled' || tour.Status__c == 'Completed'){
    				if(tour.Primary_Member__c != null){
    					setOfContact.add(tour.Primary_Member__c);
    				}
    			}else return;
    		}
    	}
    	else{
    		Map<Id,Tour_Outcome__c> oldMap = (Map<Id,Tour_Outcome__c>)Trigger.oldMap;
    		for(Tour_Outcome__c newTour : (List<Tour_Outcome__c>)trigger.new){
   				if(newTour.Status__c != oldMap.get(newTour.Id).Status__c && (newTour.Status__c == 'Completed' || newTour.Status__c == 'Scheduled')){
   					if(newTour.Primary_Member__c != null){
   						setOfContact.add(newTour.Primary_Member__c);
   					}
   				} 			
    		}
    	}
    	for(Contact contact : [SELECT Id,Email FROM Contact WHERE Id IN:setOfContact]){
    		setOfContactEmail.add(contact.Email.toLowerCase());
    	}
    	if(setOfContactEmail.size() > 0){
    	 	ReferenceHandler.ExtendReference(setOfContactEmail);
    	}
   }
    
    //ST-470 : Endpoint : Opportunity Records must not be created on Tour Endpoint
	//Changes made by : Pranay Jadhav
	//Date : 01-07-2016
	//Comment : (before insert) While creating new Tour if convert_opportunity is set as 'true' then we create Opportunity.
	 /*public static void tourConvertOpportunity(){
	 	Set<Tour_Outcome__c> setToursToProcess = new Set<Tour_Outcome__c>();
	 	Set<Id> setBuildingIds = new Set<Id>();
	 	Set<Id> setPrimaryMemberIds = new Set<Id>();
	 	List<Opportunity> listOpportunities = new List<Opportunity>();
	 	for(Tour_Outcome__c tour : (List<Tour_Outcome__c>)trigger.new){
            if(tour.Convert_Opportunity__c == true){
            	setToursToProcess.add(tour);
            	setBuildingIds.add(tour.Location__c);
            	setPrimaryMemberIds.add(tour.Primary_Member__c);
            }                
        }
        if (!setToursToProcess.isEmpty()) {
        	Map<Id,String> mapBuildingIdName = new Map<Id,String>();
			for(Building__c b : [SELECT Id, Name FROM Building__c Where Id In:setBuildingIds]) {
				mapBuildingIdName.put(b.Id,b.name);
			}
			
			Map<Id,Id> mapContactIdAccountId = new Map<Id,Id>();
			for(Contact c : [select Id, Name, AccountId  From Contact Where Id In:setPrimaryMemberIds]) {
				mapContactIdAccountId.put(c.Id,c.AccountId);
			}

			for(Tour_Outcome__c tour : setToursToProcess){
                Opportunity newOpportunity = new Opportunity(
			        stageName               = 'Scheduled Tour',
			        AccountId               = (mapContactIdAccountId.containsKey(tour.Primary_Member__c))? mapContactIdAccountId.get(tour.Primary_Member__c):'',
			        closeDate               = system.today(),
			        Name                    = 'New Opportunity',
			        Primary_Member__c       = tour.Primary_Member__c,
			        locations_interested__c = (mapBuildingIdName.containsKey(tour.Location__c))? mapBuildingIdName.get(tour.Location__c):''
				);  
			   	listOpportunities.add(newOpportunity);
       		}
       		
       		set<Id> setAccountIds = new map<Id>();
       		map<Id,String> mapOpportunity = new map<Id,String>();
		   	for(Opportunity o : listOpportunities){
		   		setAccountIds.add(o.AccountId);
		   	}

		   	Opportunity[] Opportunities = [ SELECT id,locations_interested__c,AccountId FROM Opportunity WHERE 
                        AccountId In : setAccountIds AND
                        stageName IN ('Inquiry', 
                                      'Wait List', 
                                      'Internal Wait List', 
                                      'Tour Scheduled', 
                                      'Tour Completed', 
                                      'Not Interested' 
                                      )
                      ORDER BY createddate DESC
                      LIMIT 1
            ];     
            /*
            for(Opportunity o : Opportunities){
            	if(o.locations_interested__c ==  )
            	
            }                        
                 
		       Debug.Log('@@@@@In listOpportunities Existed ==>@@'+Opportunities);
		           
			   Debug.Log('In listOpportunities to Insert ==>'+listOpportunities);
	    	// insert listOpportunities;
    	  
        }  
	 } */

}