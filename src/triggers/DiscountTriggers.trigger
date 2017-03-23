trigger DiscountTriggers on Discount__c (before insert) {
    TriggerSettings.TriggersMappedField triggerSetting = TriggerSettings.get();
    if(Trigger.IsBefore && Trigger.IsInsert){
        if(triggerSetting.Discount_VerifyStartDate){
            DiscountTriggerHandler.verifyStartDate();
        }
    }
}