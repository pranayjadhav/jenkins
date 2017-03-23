@isTest
private class TriggerSettingsTest {
    static testmethod void testGetTriggersSetting(){
    	Debug.turnDebugOn();
        
        TriggerSettings.TriggersMappedField mappedField = TriggerSettings.get();
 		System.assertEquals(true, mappedField.Lead_ChangeRelatedJourneyStatus);
        
        Setting__c triggersSetting = new Setting__c();
        triggersSetting.Name = 'TriggerSettings';
        triggersSetting.Data__c = '{"Account_SetAccountPrimaryMember":true, "Lead_ChangeRelatedJourneyStatus":true}';
        TestingUtility.insertWithAssert(triggersSetting);
        
        mappedField = TriggerSettings.get();
        System.assertEquals(true, mappedField.Account_SetAccountPrimaryMember);
        
        mappedField = TriggerSettings.get();
 		System.assertEquals(true, mappedField.Lead_ChangeRelatedJourneyStatus);       
    }
}