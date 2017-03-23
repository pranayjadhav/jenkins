trigger LeadTriggers on Lead (before insert, after insert, before update, after update, before delete) {
    TriggerSettings.TriggersMappedField triggerSetting = TriggerSettings.get();
    if( trigger.isAfter && trigger.isInsert ) {
        if(triggerSetting.Lead_ConvertLeadsToJourneys)
        {
            Set<Id> setLeadIds = new Set<Id>();
            
            for(Lead currentLead : trigger.New)
            {
                if(currentLead.Generate_Journey__c)
                    setLeadIds.add(currentLead.Id);
            }
            if(setLeadIds.size() > 0){
                //In case trigger is running under test method context processing should happen right away and not in future
                if( Test.isRunningTest() )
                    LeadConvertor.ConvertLeadsToJourneys(setLeadIds);
                else
                    LeadConvertor.FutureConvertLeadsToJourneys(setLeadIds);
            }
        }
    }
    
    if(trigger.isAfter && trigger.isUpdate)
    {
        if(triggerSetting.Lead_SetOpprtunityStageDependsOnTour)
        {
         LeadTriggerHandler.SetNewOpprtunityStageDependsOnTourStatus();
        }
        
        if(triggerSetting.Lead_ChangeRelatedJourneyStatus)
        {
           LeadTriggerHandler.ChangeRelatedJourneyStatus();
        }
        LeadTriggerHandler.updateJourneyPrimaryContact();
    }
    
    if(trigger.isBefore && trigger.isInsert)
    {
    	if(triggerSetting.Lead_UpdateActiveReferrerOnLead)
    	{
    		LeadTriggerHandler.UpdateActiveReferrerOnLead();
    	}
    }
    // Code written By : Anant
    // Date : 19/Apr/2016
    //Start
    if(trigger.isBefore && (trigger.isInsert || trigger.isUpdate)){
        if(triggerSetting.Lead_UpdateBuildingInterestOnLead)
            LeadTriggerHandler.updateBuildingInterestOnLead();
        if(triggerSetting.Lead_BlankEmailOrPhoneOnLead)
            LeadTriggerHandler.blankEmailOrPhoneOnLead();
    }
    //End
    
    if(trigger.isAfter && (trigger.isInsert || trigger.isUpdate))
    {
        if(triggerSetting.Lead_CreateDeleteBuildingInterest)
          LeadTriggerHandler.CreateDeleteBuildingInterest();
          
        if(triggerSetting.Lead_CopyOfficeTypeFromLeadToBuildingInterest)
            LeadTriggerHandler.CopyOfficeTypeFromLeadToBuildingInterest();
    }
    
    if(trigger.isBefore && trigger.isDelete)
    {
        if(triggerSetting.Lead_DeleteBuildingInterestOnLeadDelete)
           LeadTriggerHandler.DeleteBuildingInterestOnLeadDelete();
    }
}