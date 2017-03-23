@isTest
public class TestInboundCallController
{
  
		static testMethod void testContactAndRelated(){
		//Insert Account
		Account acc = new Account(Name = 'Test Account');
		insert acc;
        
		//Insert two contacts
		Contact c1 = new Contact(FirstName = 'Test',
								LastName = 'Contact1',
								AccountId = acc.Id,
								Email = 'Test111@example.com',
								Phone = '3256987425');
		insert c1;
		Contact c2 = new Contact(FirstName = 'Test',
								LastName = 'Contact2',
								AccountId = acc.Id,
								Phone = '3256987455',
								Email = 'Test112@example.com',
								LeadSource = 'Inbound Call');
		insert c2;
		
		Lead lead = new Lead(
    	 	FirstName = 'Test', 
    	 	LastName = 'Test',
    	 	Company = 'Test',
    	 	Email = 'Test111@example.com',
    	 	LeadSource = 'other',
    	    Status = 'TestStatus',
    	    CurrencyIsoCode = 'USD'
    	);
    	 	  
        insert lead;
        
        
		Journey__c objTestJourny1 = new Journey__c();
		objTestJourny1.Name = 'Test Customer1';
		objTestJourny1.Stage__c = 'Started';
		objTestJourny1.Primary_Contact__c = c1.Id;
		objTestJourny1.NMD_Next_Contact_Date__c=Date.today().addDays(4);
		TestingUtility.insertWithAssert(objTestJourny1);
		
		objTestJourny1 = new Journey__c();
		objTestJourny1.Name = 'Test Customer1';
		objTestJourny1.Stage__c = 'Started';
		objTestJourny1.Primary_Lead__c = lead.Id;
		objTestJourny1.NMD_Next_Contact_Date__c=Date.today().addDays(4);
		TestingUtility.insertWithAssert(objTestJourny1);
       
		// WeworkEngine.createJourneryAndJourneyContact(c2.Id,c2.LeadSource);
       
		InboundCallController.getContactAndRelatedJoureny('3256987425','','', (String)c1.Id);
		InboundCallController.getContactAndRelatedJoureny('Test111@example.com','','','');
	}
}