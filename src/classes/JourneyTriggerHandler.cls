/*
*	Created By   	: Dipak Pawar
*	Created Date 	: 06-07-2016
*	Summary       	: This class will contain the business logic of JourneyTriggers.
* 	Issue No.		: 
*/
public class JourneyTriggerHandler {
    public static void setPrimaryLeadToUnqualified() {
    	map<String,String> mapJourenyStatus = new map<String,String>();
        list<LeadJourneyStatusController> lstLeadJourneyStatus = new list<LeadJourneyStatusController>();
        Setting__c JSONLeadJourneyStatus = Settings.get('LeadJourneyTrigger');
    	if(JSONLeadJourneyStatus != null){
	    	lstLeadJourneyStatus = (List<LeadJourneyStatusController>)JSON.deserialize(JSONLeadJourneyStatus.Data__c, List<LeadJourneyStatusController>.class);
	       	if(lstLeadJourneyStatus != null && lstLeadJourneyStatus.size() > 0)
	    	{
	    		for(LeadJourneyStatusController currentStatus : lstLeadJourneyStatus)
	    		{
	    			mapJourenyStatus.put(currentStatus.JourneyStage,currentStatus.LeadStatus);
	    		}	    		
	    	}
	    	String leadStatus = mapJourenyStatus.values()[0];
	    	set<string> journeyStage = mapJourenyStatus.keySet();
	        List<Journey__c> lstJourneys = new List<Journey__c>();
	    	Map<Id, String> mapLeadIds = new Map<Id, String>();
	    	
	        for(Journey__c currentJourney : (List<Journey__c>)Trigger.New){
	            Journey__c oldJourney = (Journey__c)Trigger.oldMap.get(currentJourney.Id);
	            if(oldJourney.Stage__c != currentJourney.Stage__c && oldJourney.Stage__c == 'Started' && journeyStage.contains(currentJourney.Stage__c)){
	                         mapLeadIds.put(currentJourney.Primary_Lead__c, currentJourney.Lost_Reason__c);
	            }	            
	        }
	        set<Id> setLeadIds = new set<Id>(mapLeadIds.keySet());
	        if(setLeadIds.size() > 0) {
	         	List<Lead> lstLeads = [select Id, Email, Status, Unqualified_Reason__c from Lead where Id in :setLeadIds and Status !=: leadStatus];
	         	if(lstLeads!= null && lstLeads.size() > 0)
	         	{
		         	for(Lead currentLead : lstLeads){
		                currentLead.Status = leadStatus;
		                currentLead.Unqualified_Reason__c = mapLeadIds.get(currentLead.Id);
		            }
		            update lstLeads;
	         	}
         	}
    	}
	}
	
	public class LeadJourneyStatusController 
    {
    	public string LeadStatus{get;set;}
    	public string JourneyStage{get;set;}
    }
    
    /*
*	Created By   	: Samadhan Kadam
*	Created Date 	: 19-07-2016
*	Summary       	: This method get active Referrence record and set Referrer__c field value of lead or contact based on email Id.
* 	Issue No.		: 533
*/
    public static void updateActiveReferrerOnJourney(){
    	Set<String> setLeadEmails = new Set<String>();
    	Set<String> setContactEmails = new Set<String>();
    	Set<Id> setContact = new Set<Id>();
    	Set<Id> setLead = new Set<Id>();
    	Map<Id,String> mapOfLead = new Map<Id,String>();
    	Map<Id,String> mapOfContact = new Map<Id,String>();
    	
    	for(Journey__c journey :  (List<Journey__c>)Trigger.New){
    		if(journey.Primary_Contact__c != null){
 				setContact.add(journey.Primary_Contact__c);
			}  			
    		if(journey.Primary_Lead__c != null){
				setLead.add(journey.Primary_Lead__c);
    		}
    	}		  	
    	for(Contact contact :  [select Id,Email,Referrer__c from Contact WHERE Id IN:setContact]){
  				setContactEmails.add(contact.Email.toLowerCase());
  				mapOfContact.put(contact.Id,contact.Email.toLowerCase());
    	}
		if(setContactEmails.size() > 0){
    		Map<String,Id> mapOfContactActiveReference = ReferenceHandler.getActiveReference(setContactEmails);
    		if(mapOfContactActiveReference != null && mapOfContactActiveReference.size() > 0){
    			for(Journey__c journey : (List<Journey__c>)Trigger.New){
            		journey.Referrer__c = mapOfContactActiveReference.get(mapOfContact.get(journey.Primary_Contact__c));
    			 }
    		}
    	}
    	for(Lead lead :  [select Id,Email,Referrer__c from Lead WHERE Id IN:setLead]){
  				setLeadEmails.add(lead.Email.toLowerCase());
  				mapOfLead.put(lead.Id,lead.Email.toLowerCase());		
    	}
    	if(setLeadEmails.size() > 0){
    	  Map<String,Id> mapOfLeadActiveReference = ReferenceHandler.getActiveReference(setLeadEmails);
    		if(mapOfLeadActiveReference != null && mapOfLeadActiveReference.size() > 0){
  				for(Journey__c journey : (List<Journey__c>)Trigger.New){
            		journey.Referrer__c = mapOfLeadActiveReference.get(mapOfLead.get(journey.Primary_Lead__c));
    			 }
    		}
    	}
   	} 
   	
   	/*
	* Created By   	: Mayuresh Ghodke
	* Created Date 	: 29-07-2016
	* Comment		: Generate UUID for new Journey.
	*/
   	public static void generateUUID() {
		for (Journey__c journeyRec : (List<Journey__c>)Trigger.new) {
				journeyRec.UUID__c = UUIDHandler.generateVersion4();
		}
    }
}