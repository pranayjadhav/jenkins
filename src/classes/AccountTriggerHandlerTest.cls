/*
*	Created By   	: Mayuresh Ghodke
*	Created Date 	: 05-07-2016
*	Summary       	: Test class of AccountTriggerHandler.
*/
@isTest
private class AccountTriggerHandlerTest {
	private static testMethod void testSetAccountPrimaryMember() {
		//pre-context
		Account acc = new Account(
			name = 'Test Account'
		);
		insert acc;
        
        system.assertNotEquals(null,acc.Id);
        
		Contact con = new Contact(
			firstname = 'John',
			lastname = 'Rambo',
			email = 'john@example.com'
		);
		insert con;
        
		con.AccountId = acc.Id;
        update con;
        
		acc.phone = '1236548790';        
		update acc;
        Debug.log('conId :: '+con.Id);
        Debug.log('accId :: '+acc.Id);
        Debug.log('Primary_Member__c :: '+acc.Primary_Member__c);
        Account updatedAcc = [SELECT Id,Primary_Member__c FROM Account WHERE Id = : acc.Id];
		system.assertEquals(updatedAcc.Primary_Member__c, con.Id, 'Contact should be primary member of account.');
	}
}