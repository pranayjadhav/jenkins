@isTest
private class DiscountTriggerHandlerTest {
    
    @isTest static void test_1() {
		//pre-context
			
			Account a = new Account(
				name = 'Test Account',
				UUID__c = 'abcd1234',
				WW_Synced__c = true,
				WW_Sync_Request__c = false,
				ID_Creation_Status_Code__c = '200'
			);
			insert a;

			Contact john = new Contact(
				firstname = 'John',
				lastname 	= 'Rambo',
				email 		= 'john@rambo.com',
				accountID = a.Id,
				Status__c = 'active'
			);
			insert john;

			//add contact as primary member
			a.Primary_Member__c = john.Id;
			update a;

			Contact paul = new Contact(
				firstname = 'Paul',
				lastname 	= 'Rambo',
				email 		= 'paul@rambo.com',
				accountID = a.Id,
				Status__c = 'active'
			);
			insert paul;

			Building__c b = new Building__c(
				Name 		= 'b1',
				uuid__c = 'abc123'
			);
			insert b;
			
			Opportunity o = new Opportunity(
				AccountID 						= a.Id,
				CloseDate 						= system.today(),
				Actual_Start_Date__c  = system.today(),
				StageName 						= 'Prospect',
				Name 									= 'test Opoortunity',
				Building__c						= b.Id
			);
			insert o;

			Discount__c d1 = new Discount__c(
				Opportunity__c = o.Id,
				Amount__c = 10,
				Discount_Type__c = 'Regular Discount',
				Start_Date__c = system.today(),
				End_Date__c = system.today().addDays(7)
			);
			insert d1;

		//test
		Test.startTest();
		
			Discount__c d2 = new Discount__c(
				Opportunity__c = o.Id,
				Amount__c = 20,
				Discount_Type__c = 'Regular Discount',
				Start_Date__c = system.today(),
				End_Date__c = system.today().addDays(7)
			);

			Boolean errorFlag = false;
			try {
				insert d2;	
			}
			catch (System.DmlException pEx) {
				errorFlag = true;
			}

			system.assertEquals(
				true,
				errorFlag,
				'There is an existing discount for the given start date'
			);
			
		Test.stopTest();
	}
	
}