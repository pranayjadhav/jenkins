@isTest
private class TestWWSyncRequestTriggers {
	

	/*
	*	When an opportunity changes to closed won, all the Contacts (members) of the 
	*	associated Account (company) should have status=active and id_kind=member
	*/
	@isTest static void test_Opportunity_1() {
		//pre-context
			Account a = new Account(
				name = 'Test Account',
				WW_Synced__c = true,
				WW_Sync_Request__c = false,
				ID_Creation_Status_Code__c = '200'
			);
			insert a;

			Contact c = new Contact(
				firstname = 'John',
				lastname = 'Rambo',
				email = 'john@rambo.com',
				accountID = a.Id,
				Status__c = 'inactive'
			);
			insert c;

			//assign primary member
			a.Primary_Member__c = c.Id;
			update a;

			//hack to use the same uuid as on mock services
			c.UUID__c = '89d850f0-4bdd-0131-6a4b-10ddb1c23555';
			update c;

			Building__c b = new Building__c(
				Name='b1',
				uuid__c = 'abc123'
			);
			insert b;

			
			Opportunity o = new Opportunity(
				AccountID 						= a.Id,
				CloseDate 						= system.today(),
				StageName 						= 'Prospect',
				Name 									= 'test Opoortunity',
				Actual_Start_Date__c 	= system.today(),
				Building__c						= b.Id
			);
			insert o;

			// to avoid validation error
			Reservable__c r = new Reservable__c(Name='r1',Building__c=b.Id);
			insert r;
			Opportunity_Reservable__c res = new Opportunity_Reservable__c(Reservable__c=r.Id, Opportunity__c=o.Id);
			insert res;

			//update contract sent
			o.StageName = 'Contract Sent';
			update o;

			//update opportunity to closed won
			o.StageName = 'Closed Won';
			o.Payment_Details_Status__c = 'Details Received';
			update o;

		//test
		Test.startTest();
			
			
		Test.stopTest();

		//asserts
			c = [SELECT WW_Sync_Request__c, Status__c, ID_Kind__c FROM Contact WHERE Id = :c.Id LIMIT 1];

			system.assert('active'.equalsIgnoreCase(c.Status__c), 'This contact should have status=active after a closed won opportunity. Found: ' + c.Status__c);
			system.assert('member'.equalsIgnoreCase(c.ID_Kind__c), 'This contact should have ID_kind=member after a closed won opportunity. Found: ' + c.ID_Kind__c);

	}
	
}