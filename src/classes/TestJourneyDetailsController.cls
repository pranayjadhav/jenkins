/**
 * This class should contain all the test methods related JourneyDetailsController 
 * 
 * @author  Dipak Pawar
 * @date    25/06/2016
 */

@isTest
public class TestJourneyDetailsController {
    /**
	 * ST-300 : Test method for JourneyDetailController Constructor
	 * @author  Dipak Pawar
	 * @date    21/June/2016
	 */
    static testMethod void TestJourneyDetailsController() {
		//Test Account created for testContact.
        Account testAccount = new Account();
        testAccount.Name = 'Test Account';
		insert testAccount;
		//Test Contact created for testJourney.
        Contact testContact = new Contact();
    	 	testContact.AccountId = testAccount.Id;
    	 	testContact.firstname = 'TestFirstName';
    	 	testContact.lastname = 'TestLastName';
         	testContact.Email = 'Test111@example.com';
         	testContact.Status__c = 'active';
        insert testContact;
	    System.assertNotEquals(testContact.Id, null);
		
		//Test Journey for JourneyDetailController.        
	    Journey__c testJourney = new Journey__c();
	    testJourney.Name = 'testJourneyName';
	    testJourney.CurrencyIsoCode = 'USD';
	    testJourney.Primary_Contact__c = testContact.Id;
        testJourney.NMD_Next_Contact_Date__c = Date.today();
	    TestingUtility.insertWithAssert(testJourney);
        System.debug(LoggingLevel.ERROR,'testJourney1 ::'+testJourney);
	    ApexPages.StandardController testStandardController = new ApexPages.StandardController(testJourney);
	    JourneyDetailController testObject = new JourneyDetailController(testStandardController);
        
        //JourneyDetails Page with journeyId as a parameter.
        PageReference testPageReference = new PageReference('/apex/JourneyDetails');
        testPageReference.getParameters().put('journeyId', testJourney.Id);
        Test.setCurrentPageReference(testPageReference);
    }
    
    static testMethod void TestJourneyDetailsController_ForLead() {
		//Test Account created for testContact.
        Lead leadNew = new Lead(LastName = 'Test Lead Last Name', Company = 'Test Company', Email = 'test@example.com', Phone = '1212121125', Generate_Journey__c = false);
        insert leadNew;
		//Test Journey for JourneyDetailController.        
	    Journey__c testJourney = new Journey__c();
	    testJourney.Name = 'testJourney';
	    testJourney.CurrencyIsoCode = 'USD';
	    testJourney.Primary_Lead__c = leadNew.Id;
        testJourney.NMD_Next_Contact_Date__c = Date.today();
	    TestingUtility.insertWithAssert(testJourney);
	    ApexPages.StandardController testStandardController = new ApexPages.StandardController(testJourney);
	    JourneyDetailController testObject = new JourneyDetailController(testStandardController);
        
        //JourneyDetails Page with journeyId as a parameter.
        PageReference testPageReference = new PageReference('/apex/JourneyDetails');
        testPageReference.getParameters().put('journeyId', testJourney.Id);
        Test.setCurrentPageReference(testPageReference);
    }
}