/*
* Test class moved by DocusignStatusOpportunityWon trigger
* Moved By : Aanat Kumar
* Date : 07-July-2016
*/
trigger DocuSignStatusTriggers on dsfs__DocuSign_Status__c (after insert, after update) {
    TriggerSettings.TriggersMappedField triggerSetting = TriggerSettings.get();
    if(Trigger.IsAfter && (Trigger.IsInsert || Trigger.IsUpdate)){
        if(triggerSetting.DocuSign_CloseOpportunity){
            DocuSignStatusTriggerHandler.closeOpportunities();
        }
    }
}