public with sharing class DocuSignStatusTriggerHandler {
    /*
 	* Notes: Code moved from DocusignStatusOpportunityWon trigger.
 	* Date : 07/July/2016
 	* Moved By : Anant Kumar
 	*/
 	public static void closeOpportunities()
 	{
 		Set<Id> opportunityIds = new Set<Id>();
		Map<Id, dsfs__DocuSign_Status__c> oldDocuSignMap = (Map<Id, dsfs__DocuSign_Status__c>)Trigger.oldMap;
	    for (dsfs__DocuSign_Status__c docuSignStatus:(List<dsfs__DocuSign_Status__c>)Trigger.new) {
	    	
	    	if (docuSignStatus.dsfs__Opportunity__c != null &&
	    	    docuSignStatus.dsfs__Envelope_Status__c == 'Completed' &&
	    	    (Trigger.isInsert || oldDocuSignMap.get(docuSignStatus.Id).dsfs__Envelope_Status__c != 'Completed')) {
	
	            opportunityIds.add(docuSignStatus.dsfs__Opportunity__c);
	        }
	    }
	    
	    if (!opportunityIds.isEmpty()) {
	    	OpportunityServices.closeOpportunities(opportunityIds);
	    }
 	}
}