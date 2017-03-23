/**
 * Placeholder for different Task triggers
 * 
 * @author  RamseySolutions
 * @date    18/01/2016
 */
trigger TaskTriggers on Task (before insert,after insert,before update,after update)  {
    //Triggers__c triggerSetting = Settings.getTriggerSettings();
    //Triggers__c triggerSettings = Triggers__c.getInstance();
    TriggerSettings.TriggersMappedField triggerSetting = TriggerSettings.get();
    
    if (Trigger.isAfter && Trigger.isInsert) {
    	if(triggerSetting.Task_UpdateLeadEngagementFields){
        	TaskTriggers.updateLeadEngagementFields(Trigger.new);
    	}
    }
    
    if(triggerSetting.Task_ChangeOwnerToFirstUserWhoRespond){
        if(Trigger.isUpdate){
            TaskTriggers.changeTaskOwner();
        }
    }
  
    if (Trigger.isAfter && Trigger.isUpdate) {
        if(triggerSetting.Task_UpdateJourneyStageToCompletedLost)
        {
            TaskTriggers.updateJourneyStageField();
        }
    }
        
    if (Trigger.isBefore && Trigger.isUpdate) 
    {
        if(triggerSetting.Task_CallResultUpdateJourneyNMDDate)
        {
            TaskTriggers.updateJourneyNMDNextContactDate();
        }
    }
   
}