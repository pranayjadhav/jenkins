/*
 * @ Created By : Anant Kumar
 * @ Created Date : 23 Feb 2016
 * @ Modified By : Amol Darekar
 * @ Modified Date : 13 June 2016
 */
@isTest
private class OpportunityTriggerHandlerTest {
    static testMethod void testOpportunityTriggerHandler(){
		
        Account accRec = TestingUtility.createAccount('strAccountName', true);
         Contact conRec = new Contact(
         		firstname	= 'John',
                lastname 	= 'Rambo',
                email 		= 'test@example.com',
                accountID	= accRec.Id,
                Status__c	= 'active'
            );
            insert conRec;
        Map<String, Id> oppRecordType = TestingUtility.getRecordTypeMapByName(Opportunity.sObjectType);
        
        Opportunity oppRec = TestingUtility.createOpportunity(accRec.Id, false);
        oppRec.Primary_Member__c = conRec.Id;
        oppRec.StageName = 'Tour Scheduled';
        oppRec.CloseDate = system.today().addDays(5);
        oppRec.RecordTypeId = oppRecordType.get('Office Space');
        TestingUtility.insertWithAssert(oppRec);
        
        Opportunity oppRec1 = TestingUtility.createOpportunity(accRec.Id, false);
        oppRec1.Primary_Member__c = conRec.Id;
        oppRec1.StageName = 'Tour Scheduled';
        oppRec1.CloseDate = system.today().addDays(5);
        oppRec1.RecordTypeId = oppRecordType.get('Enterprise Solutions');
        TestingUtility.insertWithAssert(oppRec1);
        
        Opportunity oppRec2 = TestingUtility.createOpportunity(accRec.Id, false);
        oppRec2.Primary_Member__c = conRec.Id;
        oppRec2.StageName = 'Tour Scheduled';
        oppRec2.CloseDate = system.today().addDays(5);
        oppRec2.RecordTypeId = oppRecordType.get('Enterprise Solutions');
        TestingUtility.insertWithAssert(oppRec2);
        
        Test.startTest();
        
        Building__c building1 = new Building__c(Name='building1',uuid__c = 'abc123');
		TestingUtility.insertWithAssert(building1);
		Reservable__c reservable = new Reservable__c(Name='reservable',Building__c=building1.Id);
		TestingUtility.insertWithAssert(reservable);
		Opportunity_Reservable__c oppReservable = new Opportunity_Reservable__c(Reservable__c=reservable.Id, Opportunity__c=oppRec1.Id);
		TestingUtility.insertWithAssert(oppReservable);
        
        Test.stopTest();
        
        oppRec1.Opportunity_Reservable__c = oppReservable.Id ;
        oppRec1.Building__c = building1.Id;
        oppRec1.Primary_Member__c = conRec.Id;
        oppRec1.Encoded_ID__c = '123';
        oppRec1.Actual_Start_Date__c = system.today().addDays(5);
        oppRec1.StageName = 'Closed Won';
        TestingUtility.updateWithAssert(oppRec1);
        
        Opportunity oppRec3 = TestingUtility.createOpportunity(accRec.Id, false);
        oppRec3.Primary_Member__c = conRec.Id;
        oppRec3.StageName = 'Tour Scheduled';
        oppRec3.LeadSource = 'WeLive.com';
        oppRec3.CloseDate = system.today().addDays(5);
        oppRec3.RecordTypeId = oppRecordType.get('Enterprise Solutions');
        TestingUtility.insertWithAssert(oppRec3);
    }
    
    static testMethod void testUpdateOppName(){
        Account accRec = TestingUtility.createAccount('strAccountName', true);
        //Contact conRec = TestingUtility.createContact(accRec.Id, 'strLastName', true);
         Contact conRec = new Contact(
         		firstname = 'John',
                lastname = 'Rambo',
                email = 'primarycontact@example.com',
                accountID = accRec.Id,
                Status__c = 'active'
            );
            insert conRec;
            
         Contact referrer1 = new Contact(
         		firstname = 'John',
                lastname = 'Rambo',
                email = 'referrer1@example.com',
                accountID = accRec.Id,
                Status__c = 'active'
            );
            insert referrer1;
        
        Reference__c reference1 = new Reference__c();
        reference1.Referenced_Email__c = 'primarycontact@example.com';
        reference1.IsActive__c = true;
        reference1.Referrer__c = referrer1.Id;
        reference1.Expires_On__c = Date.today().addDays(10);
        TestingUtility.insertWithAssert(reference1);
        
        Map<String, Id> oppRecordType = TestingUtility.getRecordTypeMapByName(Opportunity.sObjectType);
        
        Opportunity oppRec = TestingUtility.createOpportunity(accRec.Id, false);
        oppRec.Primary_Member__c = conRec.Id;
        oppRec.AccountId = accRec.Id;
        oppRec.StageName = 'Tour Scheduled';
        oppRec.CloseDate = system.today().addDays(5);
        oppRec.RecordTypeId = oppRecordType.get('Office Space');
        TestingUtility.insertWithAssert(oppRec);
        
        System.assertEquals(referrer1.Id, [SELECT Referrer__c FROM Opportunity WHERE Id=:oppRec.Id].Referrer__c);
        
        Opportunity oppRec1 = new Opportunity();
        oppRec1.StageName = 'Tour Scheduled';
        oppRec1.CloseDate = system.today().addDays(5);
        oppRec1.RecordTypeId = oppRecordType.get('Office Space');
        TestingUtility.insertWithAssert(oppRec1);
        
        Opportunity oppRec2 = TestingUtility.createOpportunity(accRec.Id, false);
        oppRec2.Primary_Member__c = conRec.Id;
        oppRec2.AccountId = accRec.Id;
        oppRec2.StageName = 'Tour Scheduled';
        oppRec2.CloseDate = system.today().addDays(5);
        oppRec2.RecordTypeId = oppRecordType.get('Enterprise Solutions');
        TestingUtility.insertWithAssert(oppRec2);
        
        List<Opportunity> oppList = new List<Opportunity>();
        Opportunity oppRec3 = TestingUtility.createOpportunity(accRec.Id, false);
        oppRec3.Primary_Member__c = conRec.Id;
        oppRec3.AccountId = accRec.Id;
        oppRec3.StageName = 'Tour Scheduled';
        oppRec3.CloseDate = system.today().addDays(5);
        oppRec3.RecordTypeId = oppRecordType.get('Enterprise Solutions');
        oppList.add(oppRec3);
        
        Opportunity oppRec4 = TestingUtility.createOpportunity(accRec.Id, false);
        oppRec4.Primary_Member__c = conRec.Id;
        oppRec4.AccountId = accRec.Id;
        oppRec4.StageName = 'Tour Scheduled';
        oppRec4.CloseDate = system.today().addDays(5);
        oppRec4.RecordTypeId = oppRecordType.get('Enterprise Solutions');
        oppList.add(oppRec4);
        
        TestingUtility.insertListWithAssert(oppList);
        
        Opportunity updatedOpp2 = [Select Id, Name From Opportunity Where Id=:oppRec2.Id];
        System.assertEquals('strAccountName - 1 - Enterprise', updatedOpp2.Name);
        System.assertEquals('strAccountName - 2 - Enterprise', [Select Id, Name From Opportunity Where Id=:oppList[0].Id].Name);
        
        Test.startTest();
        
        Building__c b = new Building__c(
				Name='b1',
				uuid__c = 'abc123'
		);
		insert b;
		
        Opportunity oppRec5 = TestingUtility.createOpportunity(accRec.Id, false);
        oppRec5.Primary_Member__c = conRec.Id;
        oppRec5.AccountId = accRec.Id;
        oppRec5.StageName = 'Tour Scheduled';
        oppRec5.CloseDate = system.today().addDays(5);
        oppRec5.Building__c	= b.Id;
        oppRec5.Actual_Start_Date__c = system.today();
        oppRec5.Encoded_ID__c = '10';
        TestingUtility.insertWithAssert(oppRec5);
        
	    Reservable__c r = new Reservable__c(Name='r1',Building__c=b.Id);
		insert r;
        Opportunity_Reservable__c opres = new Opportunity_Reservable__c(Reservable__c=r.Id, Opportunity__c=oppRec5.Id);
		insert opres;
        
        oppRec5.StageName = 'Contract Sent';
        TestingUtility.updateWithAssert(oppRec5);
        
        Test.stopTest();
    } 
    
    static testMethod void testcopyFieldFromLastOpportunity(){
     	Setting__c testSettings = new Setting__c();
       	testSettings.Name = 'OpportunityFromLatestOpportunity';
       	testSettings.Data__c = '{"LeadSource":{"name":"LeadSource","overwrite":false},"Lead_Source_Detail__c":{"name":"Lead_Source_Detail__c","overwrite":true},"utm_campaign__c":{"name":"utm_campaign__c","overwrite":true},"utm_campaign_id__c":{"name":"utm_campaign_id__c","overwrite":false},"utm_content__c":{"name":"utm_content__c","overwrite":false},"utm_medium__c":{"name":"utm_medium__c","overwrite":true},"utm_source__c":{"name":"utm_source__c","overwrite":false},"utm_term__c":{"name":"utm_term__c","overwrite":false}}';
       	TestingUtility.insertWithAssert(testSettings);
       	
     	Account accRec = TestingUtility.createAccount('strAccountName', true);
        Contact conRec = new Contact(
         		firstname = 'John',
                lastname = 'Rambo',
                email = 'test@example.com',
                accountID = accRec.Id,
                Status__c = 'active'
            );
            insert conRec;
        
        Map<String, Id> oppRecordType = TestingUtility.getRecordTypeMapByName(Opportunity.sObjectType);
    
     	Opportunity oppRec = new Opportunity();
     	oppRec.AccountId = accRec.Id;
     	oppRec.Primary_Member__c = conRec.Id;
     	oppRec.StageName = 'Inquirey';
     	oppRec.CloseDate = system.today();
     	oppRec.RecordTypeId = oppRecordType.get('Office Space');
        oppRec.Lead_Source_Detail__c = 'Test Lead Details'; 
     	oppRec.LeadSource = '44 Source';
     	oppRec.utm_campaign__c = 'Test Campaign';
     	oppRec.utm_campaign_id__c = '123';
     	oppRec.utm_content__c = 'Test Content';
     	oppRec.utm_medium__c = 'Test Medium';
     	oppRec.utm_source__c = 'Test Source';
     	oppRec.utm_term__c = 'Test Term';
     	insert oppRec;
     	
     	Opportunity oppnew = [select CreatedDate,LeadSource,Lead_Source_Detail__c,utm_campaign__c,utm_campaign_id__c,utm_content__c,utm_medium__c,utm_source__c,utm_term__c,Contract_Email__c from Opportunity where Id =: oppRec.Id];
     	Opportunity opportunity2 = new Opportunity();
     	opportunity2.AccountId = accRec.Id;
     	opportunity2.Primary_Member__c = conRec.Id;
     	opportunity2.StageName = 'Tour Scheduled';
     	opportunity2.CloseDate = system.today().addDays(5);
     	opportunity2.RecordTypeId = oppRecordType.get('Office Space');
     	oppRec.RecordTypeId = oppRecordType.get('Office Space');
        insert opportunity2;
     	
     	Opportunity newOpp = [select CreatedDate,LeadSource,Lead_Source_Detail__c,utm_campaign__c,utm_campaign_id__c,utm_content__c,utm_medium__c,utm_source__c,utm_term__c,Contract_Email__c from Opportunity where Id =: opportunity2.Id];
     	system.assertEquals('44 Source',newOpp.LeadSource);
     }
    
    static testMethod void testEncodedOpportunityID() {
		//pre-context
			Building__c b = new Building__c(
				Name='b1',
				uuid__c = 'abc123'
			);
			insert b;

			Opportunity o = new Opportunity(				
				CloseDate 	= system.today(),
				StageName 	= 'Inquire',
				Name 		= 'test Opoortunity',
				Building__c	= b.Id
			);
			insert o;		//test

		Test.startTest();
			o = [SELECT Encoded_Id__c FROM Opportunity WHERE id = :o.Id LIMIT 1];
			system.assertEquals(
				EncodingHandler.encode(o.Id),
				o.Encoded_Id__c,
				'The Opportunity was not correctly encoded.'
			);
			
		Test.stopTest();
	}
	
	static testMethod void testUpdatePrimaryMemberOnOpportunity(){
	       	
         	Account accRec     = TestingUtility.createAccount('strAccountName', true);
         		Contact conRec = new Contact(
              	firstname 	   = 'John',
               	lastname       = 'Rambo',
               	email          = 'test@example.com',
                accountID  	   = accRec.Id,
                Status__c      = 'active'
            );
            insert conRec;
            
       		Opportunity oppRec = new Opportunity();
       		//oppRec.Primary_Member__c = conRec.Id;
        	oppRec.AccountId = accRec.Id;
        	oppRec.StageName = 'Tour Scheduled';
        	oppRec.CloseDate = system.today().addDays(5);
        	//oppRec.RecordTypeId = oppRecordType.get('Office Space');
        	insert oppRec;
        	
        	//Test : ST-508 : Map opportunity with latest booked tour on its primary member with same location interested
        	
        	Account accountRec = TestingUtility.createAccount('strAccountName', true);
        	Contact primaryMember1 = TestingUtility.createContact(accountRec.Id, 'strLastName', false);
        	primaryMember1.Email = 'primarymember1@example.com';
        	TestingUtility.insertWithAssert(primaryMember1);
        
        	Building__c building1 = new Building__c(
                Name='NYC-Penn Station',
                uuid__c = 'abc123'
            );
            insert building1;
        
        	Building__c building2 = new Building__c(
                Name='building2',
                uuid__c = 'abc1232'
            );
            insert building2;
        
        	Tour_Outcome__c tour1 = new Tour_Outcome__c();
            tour1.Primary_Member__c = primaryMember1.Id;
            tour1.Status__c = 'Scheduled';
            tour1.Tour_Date__c = system.today().addDays(3);
        	tour1.Location__c = building1.Id;
            TestingUtility.insertWithAssert(tour1);
        	
        	Tour_Outcome__c tour2 = new Tour_Outcome__c();
            tour2.Primary_Member__c = primaryMember1.Id;
            tour2.Status__c = 'Scheduled';
            tour2.Tour_Date__c = system.today().addDays(3);
        	tour2.Location__c = building2.Id;
            TestingUtility.insertWithAssert(tour2);
        	
        	Tour_Outcome__c tour3 = new Tour_Outcome__c();
            tour3.Primary_Member__c = primaryMember1.Id;
            tour3.Status__c = 'Scheduled';
            tour3.Tour_Date__c = system.today().addDays(3);
        	tour3.Location__c = building1.Id;
            TestingUtility.insertWithAssert(tour3);
        
        	Opportunity opportunity1 = new Opportunity(
                AccountID                       = accountRec.Id,
                CloseDate                       = system.today(),
                Actual_Start_Date__c            = system.today(),
                StageName                       = 'Prospect',
                Name                            = 'test Opoortunity',
                Locations_Interested__c         = 'NYC-Penn Station',
                Primary_Member__c               = primaryMember1.Id
            );
            insert opportunity1;
        	System.assertEquals(tour3.Id, [SELECT Id, Name, Tour_Outcome__c FROM Opportunity WHERE Id=:opportunity1.Id].Tour_Outcome__c);
	}
	
	static testMethod void testDeleteBuildingInterests(){		
	       	Account accRec     = TestingUtility.createAccount('strAccountName', true);
         	Contact conRec = new Contact(
              	firstname 	   = 'John',
               	lastname       = 'Rambo',
               	email          = 'test@example.com',
                accountID  	   = accRec.Id,
                Status__c      = 'active'
            );
            insert conRec;
                      
       		Opportunity oppRec = new Opportunity();
       		//oppRec.Primary_Member__c = conRec.Id;
        	oppRec.AccountId = accRec.Id;
        	oppRec.StageName = 'Tour Scheduled';
        	oppRec.CloseDate = system.today().addDays(5);
        	//oppRec.RecordTypeId = oppRecordType.get('Office Space');
        	insert oppRec;
        	
			Building__c b = new Building__c(
				Name='b1',
				uuid__c = 'abc123'
			);
			insert b;
        	
        	Building_Interest__c b1 = new Building_Interest__c(
				Building__c = b.Id,
				//CurrencyIsoCode ='GBP-British Pound',
				Opportunity__c = oppRec.Id
			);
			
			insert b1;
        	delete oppRec;
        	
        	List<Building_Interest__c> bi = [SELECT Id FROM Building_Interest__c];
    		System.assertEquals(bi.size(),0);
    		Debug.log('Size of Building Interest ::'+bi);
	}

	static testMethod void testupdateContractEmail(){
		Debug.log(':: updateContractEmail ::');
	}


}