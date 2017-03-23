/*
 * @ Created By : Anant Kumar
 * @ Created Date : 1 Mar 2016
 */
trigger ReservableTrigger on Reservable__c (after delete, after insert, after undelete, after update, before delete, before insert, before update) {
    
    if(Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        ReservableTriggerHandler reservableHandler = new ReservableTriggerHandler();
        reservableHandler.updateSpaceBasedOnSpaceUUID(Trigger.New);
    }
}