@isTest
private class RESTOpportunityInsertTest {
	@isTest static void test_POST_success() {
		//pre-context
			Setting__c testSettings = new Setting__c();
	       	testSettings.Name = 'OpportunityFromLatestOpportunity';
	       	testSettings.Data__c = '{"LeadSource":{"name":"LeadSource","overwrite":false},"Lead_Source_Detail__c":{"name":"Lead_Source_Detail__c","overwrite":true},"utm_campaign__c":{"name":"utm_campaign__c","overwrite":true},"utm_campaign_id__c":{"name":"utm_campaign_id__c","overwrite":false},"utm_content__c":{"name":"utm_content__c","overwrite":false},"utm_medium__c":{"name":"utm_medium__c","overwrite":true},"utm_source__c":{"name":"utm_source__c","overwrite":false},"utm_term__c":{"name":"utm_term__c","overwrite":false}}';
	       	TestingUtility.insertWithAssert(testSettings);
       		
       		Triggers__c triggers = new Triggers__c(Name= 'Triggers');
         	triggers.Opportunity_Upate_Encoded_ID__c= true;
       		TestingUtility.insertWithAssert(triggers);
        
        	Account a = new Account(
				name = 'Test Account',
				WW_Synced__c = true,
				WW_Sync_Request__c = false,
				ID_Creation_Status_Code__c = '200'
			);
			insert a;

			Contact john = new Contact(
				firstname = 'John',
				lastname = 'Rambo',
				email = 'john@rambo.com',
				accountID = a.Id,
				Status__c = 'active'
			);
			insert john;

			//add contact as primary member
			a.Primary_Member__c = john.Id;
			a.UUID__c = 'com001';
			update a;

			Contact paul = new Contact(
				firstname = 'Paul',
				lastname = 'Rambo',
				email = 'paul@rambo.com',
				accountID = a.Id,
				Status__c = 'active'
			);
			insert paul;

			Building__c b = new Building__c(
				Name='b1',
				uuid__c = 'bui001'
			);
			insert b;

			// fixed
			Reservable__c r1 = new Reservable__c(Name='r1',Building__c=b.Id, uuid__c='res001', Status__c = 'Available', Open_Date__c = date.today());
			insert r1;
        
        	// fixed
			Reservable__c r2 = new Reservable__c(Name='r2',Building__c=b.Id, uuid__c='res002', Status__c = 'Available', Open_Date__c = date.today());
			insert r2;
        
        	// fixed
			Reservable__c r3 = new Reservable__c(Name='r3',Building__c=b.Id, uuid__c='res003', Status__c = 'Available', Open_Date__c = date.today());
			insert r3;

		//test
		Test.startTest();

			RestRequest req 	= new RestRequest(); 
	    RestResponse res 	= new RestResponse();
      
      // pass the req and resp objects to the method		 
      req.requestURI = System.URL.getSalesforceBaseURL().getHost() + '/services/apexrest/OpportunityInsert';  
      req.httpMethod = 'POST';

	 		//assign rest context
	 		RestContext.request 	= req;
	 		RestContext.response 	= res;
	 		
	 		//define container and set request Company and Reservable UUIDs
	 		WWTypes.OpportunityInsert oi = new WWTypes.OpportunityInsert();
	 		oi.company_uuid 					= a.UUID__c;
	 		oi.building_uuid 					= b.uuid__c;
	 		oi.opportunity_type 			= 'Office Space';
	 		oi.community_manager_uuid = 'xxx';
	 		oi.desk_number 						= 2;
	 		oi.actual_start_date 			= system.today();
			oi.reservable_uuids 			= new String[]{
				 																r1.uuid__c, 
				 																r3.uuid__c
				 															};

			WWTypes.Discount discount1 = new WWTypes.Discount();
			discount1.amount 				= 100;
			discount1.start_date 		= system.today();
			discount1.end_date 			= system.today();
			discount1.discount_type = 'Regular Discount';

			WWTypes.Discount discount2 = new WWTypes.Discount();
			discount2.amount 				= 200;
			discount2.start_date 		= system.today();
			discount2.end_date 			= system.today();
			discount2.discount_type = 'Regular Discount';
			
			//collect discounts
			oi.discounts.add(discount1);
			oi.discounts.add(discount2);

			//submit post
			RESTOpportunityInsert.Response response = RESTOpportunityInsert.doPost(oi);
	
			//confirm response
			system.assertEquals(true, response.success);

			//check if a new opportunity was created
			Opportunity[] Os = [SELECT id, AccountID FROM Opportunity];
			system.assertEquals(
				1,
				Os.size(),
				'A new opportunity should be created'
			);

			//check if the opportunity is associated to the given account
			system.assertEquals(
				a.Id,
				Os[0].AccountID,
				'The new opportunity should be associated with the right Company(Account)'
			);

			//check if the opportunity has the right opportunity-reservables records.
			Opportunity_Reservable__c[] ORs = [	SELECT Opportunity__c, Reservable__c 
																					FROM Opportunity_Reservable__c
																				];
			system.assertEquals(
				2,
				ORs.size(),
				'Given 2 reservables on an Opportunity should result in 2 Opportunity Reservable records'
			);

			system.assertEquals(
				Os[0].id,
				ORs[0].Opportunity__c,
				'The Opportunity Reservable must be associated to the right Opportunity'
			);

			system.assertEquals(
				Os[0].id,
				ORs[1].Opportunity__c,
				'The Opportunity Reservable must be associated to the right Opportunity'
			);

			system.assert(
				r1.Id == ORs[0].Reservable__c ||
				r1.Id == ORs[1].Reservable__c,
				'The Opportunity Reservable must be associated to the right Reservable'
			);

			system.assert(
				r3.Id == ORs[0].Reservable__c ||
				r3.Id == ORs[1].Reservable__c,
				'The Opportunity Reservable must be associated to the right Reservable'
			);
	
		Test.stopTest();
	}
}