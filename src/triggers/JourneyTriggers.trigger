/*
* Created By   : Amol Darekar
* Created Date : 17/05/2016
*/
trigger JourneyTriggers on Journey__c (before insert,after update) {
    TriggerSettings.TriggersMappedField triggerSetting = TriggerSettings.get();
    
     
    	/*
		*	Created By   	: Samadhan Kadam
		*	Created Date 	: 19-07-2016
		* 	Issue No.		: 533
		*/
    
    if(Trigger.isBefore && Trigger.isInsert){
    	if(triggerSetting.Journey_UpdateActiveReferrerOnJourney){
    		JourneyTriggerHandler.updateActiveReferrerOnJourney();
    	}
    	/*
		* Created By   	: Mayuresh Ghodke
		* Created Date 	: 29-07-2016
		* Comment		: Generate UUID for new Journey.
		*/
    	if(triggerSetting.Journey_GenerateUUID){
    		JourneyTriggerHandler.generateUUID();
    	}
    }
    
    if(Trigger.isAfter && Trigger.isUpdate)
    {
      if(triggerSetting.Journey_CreateJourneyContactOnMemberChange){
            //JourneyTriggerHelper.CreateNewJournyContactOnMemberChange();
      }
      
      	/*
		*	Created By   	: Dipak Pawar
		*	Created Date 	: 06-07-2016
		*	Summary       	: Sets Primary Lead to Unqualified if Journet Stage is Completed-Lost.
		* 	Issue No.		: 
		*/
      if(triggerSetting.Journey_SetPrimaryLeadToUnqualified){
        JourneyTriggerHandler.setPrimaryLeadToUnqualified();
      }
    }
}