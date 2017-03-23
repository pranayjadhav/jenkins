/*
 * Created By   : Amol Darekar
 * Created Date : 13-05-2016
 *
*/
trigger DealTriggers on Deal__c (before update) {
	
   //Triggers__c triggerSettings = Triggers__c.getInstance();
	TriggerSettings.TriggersMappedField triggerSetting = TriggerSettings.get();
	
   if(Trigger.isBefore && Trigger.isUpdate)
   {
      if(triggerSetting.Deal_SetClosedDealStatusToBlank)
      {
          DealsTriggerHandler.updateClosedDealStatusToBlank();
      }
   }
}