/*
 * @ Created By : Anant Kumar
 * @ Created Date : 20 June 2016
 */
@isTest
private class ReferenceHandlerTest {
	static{
		ReferenceSettings settingsMy = new ReferenceSettings();
        settingsMy.expireafter = 10;

        Setting__c setting = new Setting__c( Name = 'ReferenceSettings', Data__c = JSON.serialize(settingsMy));
        insert setting;
	}

    public static testMethod void checkSettings(){
	 ReferenceSettings settingsNew;
		settingsNew = (ReferenceSettings) Settings.get('ReferenceSettings',ReferenceSettings.class);
        System.assert(settingsNew.expireafter == 10);
    }

    static testMethod void testReferenceHandler()
    {
        Account accRec = TestingUtility.createAccount('strAccountName', true);
        Contact referrer1 = new Contact();
        referrer1.LastName = 'referrer1';
        referrer1.Email = 'referrer1@example.com';
        TestingUtility.insertWithAssert(referrer1);
        
        Contact referrer2 = new Contact();
        referrer2.LastName = 'referrer1';
        referrer2.Email = 'referrer2@example.com';
        TestingUtility.insertWithAssert(referrer2);
        
        Reference__c reference1 = new Reference__c();
        reference1.Referenced_Email__c = 'reference1@example.com';
        reference1.IsActive__c = true;
        reference1.Referrer__c = referrer1.Id;
        reference1.Expires_On__c = Date.today().addDays(10);
        TestingUtility.insertWithAssert(reference1);
        
        Reference__c reference2 = new Reference__c();
        reference2.Referenced_Email__c = 'reference2@example.com';
        reference2.IsActive__c = false;
        reference2.Referrer__c = referrer1.Id;
        reference2.Expires_On__c = Date.today().addDays(10);
        TestingUtility.insertWithAssert(reference2);
        
        Set<String> setEmails = new Set<String>();
        setEmails.add(reference1.Referenced_Email__c);
        
        ReferenceHandler.ExtendReference(setEmails);

        Reference__c existingReference = [SELECT Id, Name, Expires_On__c FROM Reference__c WHERE Id=:reference1.Id];
        Debug.Log('Test : reference1 ::: ' + existingReference);
        Time tNow = Time.newInstance(0, 0, 0, 0);
        DateTime todayTime = DateTime.newInstance(Date.today(), tNow);
        //System.assertEquals(todayTime.addDays(60), existingReference.Expires_On__c);

        ReferenceHandler.ExtendReference(reference1.Id,Date.today());

        Map <string,Id> mapReferrer = ReferenceHandler.getActiveReference(setEmails);
        System.assertEquals(referrer1.Id, mapReferrer.get(reference1.Referenced_Email__c));
        
        System.assertEquals(referrer1.Id, ReferenceHandler.getActiveReference(reference1.Referenced_Email__c));
        System.assertEquals(null, ReferenceHandler.getActiveReference(reference2.Referenced_Email__c));
    }

	public class ReferenceSettings {
		public Integer expireafter{get;Set;}
	}
}