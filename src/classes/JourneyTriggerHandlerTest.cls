@isTest
public class JourneyTriggerHandlerTest {
    private static testMethod void testSetPrimaryLeadToUnqualified() {
        
        Triggers__c triggerSettings = Triggers__c.getInstance();
		triggerSettings.Journey_setPrimaryLeadToUnqualified__c = true;
		upsert triggerSettings;
		
		Setting__c testSettings = new Setting__c();
        testSettings.Name = 'LeadJourneyTrigger';
        testSettings.Data__c = '[{"LeadStatus":"Unqualified","JourneyStage":"Completed-Lost"}]';
        TestingUtility.upsertWithAssert(testSettings);
		
    	//Test Account created for testContact.
        Lead testLead = new Lead(LastName = 'Test Lead Last Name', Company = 'Test Company', Email = 'test@example.com', Phone = '1212121125', Generate_Journey__c = false);
        TestingUtility.insertWithAssert(testLead);
		//Test Journey for JourneyDetailController.        
	    Journey__c testJourney = new Journey__c();
	    testJourney.Name = 'testJourney';
	    testJourney.CurrencyIsoCode = 'USD';
	    testJourney.Primary_Lead__c = testLead.Id;
        testJourney.NMD_Next_Contact_Date__c = Date.today();
        testJourney.Lost_Reason__c = 'Not Interested';
	    TestingUtility.insertWithAssert(testJourney);
	    
        testJourney.Stage__c = 'Completed-Lost';
        update testJourney;
        List<Lead> lead = new List<Lead>([select Id, Name, Status, Unqualified_Reason__c from Lead where Id =: testLead.Id]);
        System.assertEquals('Unqualified', lead[0].Status);
        System.assertEquals('Not interested', lead[0].Unqualified_Reason__c);
    }
    
    static testMethod void testUpdateActiveReferrerOnJourney(){
    	Account accRec = new Account();
    	accRec.Name='Test Account' ;
    	insert accRec;
    	
    	Contact testContact = new Contact(
    	   AccountId =  accRec.Id,	
           firstname = 'TestFirstName',
           lastname = 'TestLastName',
           email = 'primary123@example.com',
           Status__c = 'active',
		   Referrer__c  = null	          
        );
        insert testContact;
                
        Contact referrer1 = new Contact(
    	   AccountId =  accRec.Id,	
           firstname = 'TestFirstName',
           lastname = 'TestLastName',
           email = 'TesT888@example.com',
           Status__c = 'active',
		   Referrer__c  = null	          
        );
        insert referrer1;
    	 
        Reference__c testReference = new Reference__c(Referenced_Email__c = 'primary123@example.com', IsActive__c = true,Expires_On__c = (Date.today()).addDays(2),Referrer__c = referrer1.Id);
        insert testReference;
        
        Journey__c testJourney = new Journey__c();
        testJourney.Name = 'testJourney';
        testJourney.NMD_Next_Contact_Date__c = Date.today();
        testJourney.Primary_Contact__c = testContact.Id;
        insert testJourney;
       
        Journey__c journey = [select Id,Referrer__c from Journey__c where Id=: testJourney.Id];
        system.assertEquals(referrer1.Id,journey.Referrer__c);
   
   		  Contact referrer2 = new Contact(
    	   AccountId =  accRec.Id,	
           firstname = 'TestFirstName',
           lastname = 'TestLastName',
           email = 'TesT456@example.com',
           Status__c = 'active',
		   Referrer__c  = null	          
        );
        insert referrer2;
        
        Lead testLead = new Lead(FirstName = 'Test',
             LastName = 'Lead',
             Company = 'TestCompany',
             Status = 'Open',
             Locations_Interested__c = 'B1; B2;',
             Office_Type__c = 'Shared Desk; DailyDesk;',
             Email = 'TEST1994@example.com'
            );
        insert testLead;
        
       	Reference__c testReference1 = new Reference__c(Referenced_Email__c = 'TEST1994@example.com', IsActive__c = true,Expires_On__c = (Date.today()).addDays(2),Referrer__c = referrer2.Id);
        insert testReference1;
        
        Journey__c testJourney2 = new Journey__c();
        testJourney2.Name = 'testJourney';
        testJourney2.NMD_Next_Contact_Date__c = Date.today();
        testJourney2.Primary_Lead__c = testLead.Id;
        insert testJourney2;
               
        Journey__c journey1 = [select Id,Referrer__c from Journey__c where Id =:testJourney2.Id];
        system.assertEquals(referrer2.Id,journey1.Referrer__c);
       
    }
}