/*
 * @ Created By : Anant Kumar
 * @ Created Date : 1 Mar 2016
 */
trigger ReservableTriggers on Reservable__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    
    //Triggers__c triggerSettings = Triggers__c.getInstance();
    TriggerSettings.TriggersMappedField triggerSetting = TriggerSettings.get();
     
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        ReservableTriggerHandler reservableHandler = new ReservableTriggerHandler();
        if(triggerSetting.Reservable_UpdateSpaceBasedOnSpaceUUID == true){
        	reservableHandler.updateSpaceBasedOnSpaceUUID(Trigger.New);
        }
    }
}