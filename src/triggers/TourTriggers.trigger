trigger TourTriggers on Tour_Outcome__c (before insert, before update, after insert, after update) {
	//Changes : ST-372 : Tour : Close all open Inbound Lead.
    //Changes made by : Anant Kumar
    //Date : 15-Jun-2016
   // Triggers__c triggerSetting = Settings.getTriggerSettings();
    TriggerSettings.TriggersMappedField triggerSetting1 = TriggerSettings.get();

    if(Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
    	
        if(triggerSetting1.Tour_CloseAllOpenInboundLeadActivities){
            TourTriggerHandler.closeAllOpenInboundLead();
        }
        
        //ST-464 : Tour_Outcome__c: Move TourEndTime to TourTriggerHandler
	    //Changes made by : Anant Kumar
	    //Date : 22/June/2016
	    if(triggerSetting1.Tour_UpdateTourEnditme){
	    	TourTriggerHandler.updateTourEndTime();
	    }

	    //ST-469 : Tour_Outcome__c: Move TourScheduledConvertLead to TourTriggerHandler
	    //Changes made by : Anant Kumar
	    //Date : 22/June/2016
	    if(triggerSetting1.Tour_ScheduledConvertLead)
	    {
	    	TourTriggerHandler.tourScheduledConvertLead();
	    }
	    
	    //ST-531 : Tour_Outcome__c: get active Referrence record and set Referrer__c field value of Tour based on Primary_Member__c
	    //Changes made by : Dipak Pawar
	    //Date : 20/July/2016
	    if(triggerSetting1.Tour_UpdateActiveReferrerOnTour)
	    {
	    	TourTriggerHandler.updateActiveReferrerOnTour();
	    }
	    
	    //ST-470 : Endpoint : Opportunity Records must not be created on Tour Endpoint
		//Changes made by : Pranay Jadhav
		//Date : 01-07-2016
		//Comment : (before insert) While creating new Tour if convert_opportunity is set as 'true' then we create Opportunity.
  		if(Trigger.isInsert){
  				//TourTriggerHandler.tourConvertOpportunity();
  		}
    }    
    
	//ST-444 : Tour_Outcome__c: Stage Update for Journey Records
	//Changes made by : Pranay Jadhav
	//Date : 28/June/2016
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)){
    	if(triggerSetting1.Tour_StageUpdateforJourneyRecords){
			TourTriggerHandler.updateJourneyStage();
    	}
    //ST-473 : Tour_Outcome__c : Extend Validity Of Reference 
    //Chanages made by : Samadhan Kadam
    //Date:22/June/2016
    	if(triggerSetting1.Tour_ExtendValidityOfReference){
    		TourTriggerHandler.extendValidityOfReference();
    	}
    }
   
}