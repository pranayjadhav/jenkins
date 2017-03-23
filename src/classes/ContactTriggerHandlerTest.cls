/*
*	Created By   : Dipak Pawar
*	Created Date : 04-07-2016
*	Summary      : This class should contain all test methods related to ContactTriggerHandler class.
*/
@isTest
public class ContactTriggerHandlerTest{
    
    @isTest static void testCheckForDuplicateEmail() {
        Boolean result = false;
        Contact newContact1 = new Contact(
            firstname = 'TestFirstName',
            lastname = 'TestLastName',
            email = 'test@example.com',
            Status__c = 'active'
        );
        insert newContact1;
        
        Contact newContact2 = new Contact(
            firstname = 'TestFirstName1',
            lastname = 'TestLastName1',
            email = 'test@example.com',
            Status__c = 'active'
        );
        
        try{
        	insert newContact2;
        }
        catch(DmlException ex){ 
        	result = true;
        }
      	System.assert(result);
		
    }
    
	  
    @isTest 
    static void convertMatchingLead()
    {
		Account accRec = TestingUtility.createAccount('strAccountName', true);
		accRec.Name = 'Test';
    	update accRec;
    
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
    	
    	Lead newLead = [SELECT Id,Name,Email,IsConverted FROM Lead WHERE Id=:lead.Id];
    	
    	system.assertEquals(false,newLead.IsConverted);
	
	 	Contact newContact1 = new Contact();
	 	newContact1.AccountId = accRec.Id;
	 	newContact1.firstname = 'TestFirstName';
	 	newContact1.lastname = 'TestLastName';
     	newContact1.Email = 'Test111@example.com';
     	newContact1.Status__c = 'active';
     	newContact1.Convert_Lead__c = true;
     	Test.startTest();
        insert newContact1;
       	Test.stopTest();
       	
  		Lead lead1 = [SELECT Id,Name,Email,IsConverted FROM Lead WHERE Id=:lead.Id];
  		
       	system.assertEquals(true,lead1.IsConverted);
    
	}
		
	@isTest 
    static void testSetPrimaryContactOnAccount(){
    	Account testAccount = new Account();
        testAccount.Name = 'Test Account';
		insert testAccount;
        
        Opportunity testOpportunity = new Opportunity(
          AccountID   = testAccount.Id,
          CloseDate   = system.today(),
          StageName   = 'Prospect',
          Name = 'test Opoortunity',
          Actual_Start_Date__c = system.today()
      	);
      	insert testOpportunity;
        
        
		
		Contact testContact = new Contact();
    	testContact.AccountId = testAccount.Id;
    	testContact.firstname = 'TestFirstName';
    	testContact.lastname = 'TestLastName';
        testContact.Email = 'TestEmail@example.com';
        testContact.Status__c = 'active';
        testContact.Convert_Lead__c = true;
        insert testContact;
    }
		
	@isTest 
    static void testUpdateAccounts(){
    	Account testAccount = new Account();
        testAccount.Name = 'Test Account';
		insert testAccount;
        
		
		Contact testContact = new Contact();
    	testContact.AccountId = testAccount.Id;
    	testContact.firstname = 'TestFirstName';
    	testContact.lastname = 'TestLastName';
        testContact.Email = 'TestEmail@example.com';
        testContact.Status__c = 'active';
        testContact.Convert_Lead__c = true;
        insert testContact;
        
        delete testContact;
    }
    
    @isTest 
    static void testtGenerateUUID(){
    	Account testAccount = new Account();
        testAccount.Name = 'Test Account';
		insert testAccount;
        
		Contact testContact = new Contact();
    	testContact.AccountId = testAccount.Id;
    	testContact.firstname = 'TestFirstName';
    	testContact.lastname = 'TestLastName';
        testContact.Email = 'TestEmail@example.com';
        testContact.Status__c = 'active';
        testContact.Convert_Lead__c = true;
        insert testContact;
        
    }
}