@isTest
private class RESTOpportunitiesTest {
	@isTest static void test_GET_success() {
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
				lastname = 'Rambo',
				email = 'john@rambo.com',
				accountID = a.Id,
				Status__c = 'active'
			);
			insert john;

			//add contact as primary member
			a.Primary_Member__c = john.Id;
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
				uuid__c = 'abc123'
			);
			insert b;
			
			Building__c b2 = new Building__c(
				Name='b2',
				uuid__c = 'abc124'
			);
			insert b2;

			Opportunity o = new Opportunity(
				AccountID 						= a.Id,
				CloseDate 						= system.today(),
				Actual_Start_Date__c 	        = system.today(),
				StageName 						= 'Prospect',
				Name 							= 'test Opoortunity',
				Building__c						= b.Id,
                Primary_Member__c 				= paul.Id,
                Encoded_ID__c					= '10'
			);
			insert o;
			
			Opportunity o2 = new Opportunity(
				AccountID 						= a.Id,
				CloseDate 						= system.today(),
				Actual_Start_Date__c 	        = system.today(),
				StageName 						= 'Prospect',
				Name 							= 'test Opoortunity 2',
				Building__c						= b2.Id,
                Primary_Member__c 				= paul.Id
			);
			insert o2;

			// to avoid validation error
			Reservable__c r = new Reservable__c(Name='r1',Building__c=b.Id);
			Reservable__c r2 = new Reservable__c(Name='r2',Building__c=b2.Id);
			insert r;
			insert r2;
			
			Opportunity_Reservable__c opres = new Opportunity_Reservable__c(Reservable__c=r.Id, Opportunity__c=o.Id);
			Opportunity_Reservable__c opres2 = new Opportunity_Reservable__c(Reservable__c=r2.Id, Opportunity__c=o2.Id);
			insert opres;
			insert opres2;

			//update stage
			o.StageName = 'Contract Sent';
			o2.StageName = 'Contract Sent';
			update o;
		//test
		Test.startTest();

		RestRequest req 	= new RestRequest(); 
	    RestResponse res 	= new RestResponse();

	    // pass the req and resp objects to the method		 
	    req.requestURI = System.URL.getSalesforceBaseURL().getHost() + '/' + a.UUID__c;
        req.httpMethod = 'GET';
	 
	 		//assign rest context
	 		RestContext.request 	=	req;
	 		RestContext.response 	= res;
	 		
			//submit get
			RESTOpportunities.Response response = RESTOpportunities.doGet();
	
			//confirm response
			system.assertEquals(true, response.success);
		Test.stopTest();
	}
    
    @isTest static void test_GET_Failure() {
		//pre-context
		//test
		Test.startTest();

		RestRequest req 	= new RestRequest(); 
	    RestResponse res 	= new RestResponse();

	    // pass the req and resp objects to the method		 
	    req.requestURI = System.URL.getSalesforceBaseURL().getHost();
        req.httpMethod = 'GET';
	 
	 		//assign rest context
	 		RestContext.request 	=	req;
	 		RestContext.response 	= res;
	 		
			//submit get
			RESTOpportunities.Response response = RESTOpportunities.doGet();
	
			//confirm response
			system.assertEquals(false, response.success);
		Test.stopTest();
	}
}