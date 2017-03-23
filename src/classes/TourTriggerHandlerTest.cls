/*
 * @ Created By : Anant Kumar
 * @ Created Date : 23 Feb 2016
 */
@isTest
private class TourTriggerHandlerTest {
    static testMethod void testUpdateMostRecentTourDate(){
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
                Status__c = 'active',
                Most_recent_tour_date__c = system.today()
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
                AccountID                       = a.Id,
                CloseDate                       = system.today(),
                Actual_Start_Date__c            = system.today(),
                StageName                       = 'Prospect',
                Name                            = 'test Opoortunity',
                Building__c                     = b.Id,
                Primary_Member__c               = paul.Id,
                Encoded_ID__c                   = '10'
            );
            insert o;
            
            Opportunity o2 = new Opportunity(
                AccountID                       = a.Id,
                CloseDate                       = system.today(),
                Actual_Start_Date__c            = system.today(),
                StageName                       = 'Prospect',
                Name                            = 'test Opoortunity 2',
                Building__c                     = b2.Id,
                Primary_Member__c               = paul.Id
            );
            insert o2;
        
        Lead l = new Lead(FirstName = 'Test', LastName = 'Test', Company = 'Test', Email = 'TestTourLeadConversionTrigger@TestTourLeadConversionTrigger.com');
        insert l;
        
        Tour_Outcome__c t = new Tour_Outcome__c(
            Lead__c = l.Id,
            Status__c = 'Scheduled',
            Opportunity__c = o.Id
        );
        
        
     
        Set<Id> conIdSet = new Set<Id>();
        conIdSet.add(john.Id);
        conIdSet.add(paul.Id);
        TourTriggerHandler.updateMostRecentTourDate(conIdSet);
    }
    
    static testMethod void testTourTriggerHandler(){
        Setting__c testSettings = new Setting__c();
        testSettings.Name = 'OpportunityFromLatestOpportunity';
        testSettings.Data__c = '{"LeadSource":{"name":"LeadSource","overwrite":false},"Lead_Source_Detail__c":{"name":"Lead_Source_Detail__c","overwrite":true},"utm_campaign__c":{"name":"utm_campaign__c","overwrite":true},"utm_campaign_id__c":{"name":"utm_campaign_id__c","overwrite":false},"utm_content__c":{"name":"utm_content__c","overwrite":false},"utm_medium__c":{"name":"utm_medium__c","overwrite":true},"utm_source__c":{"name":"utm_source__c","overwrite":false},"utm_term__c":{"name":"utm_term__c","overwrite":false}}';
        TestingUtility.insertWithAssert(testSettings);
        
        Setting__c testSettings2 = new Setting__c();
        testSettings2.Name = 'CloseAllOpenInboundLead';
        testSettings2.Data__c = '{"subject":"Inbound Lead Submission, Follow-Up"}';
        insert testSettings2;
        
        Account accRec = TestingUtility.createAccount('strAccountName', true);
            Contact conRec = new Contact(
                firstname = 'Paul',
                lastname = 'Rambo',
                email = 'paul123@rambo.com',
                accountID = accRec.Id,
                Status__c = 'active'
            );
            insert conRec;
        
        Map<String, Id> oppRecordType = TestingUtility.getRecordTypeMapByName(Opportunity.sObjectType);
        
        Opportunity oppRec = TestingUtility.createOpportunity(accRec.Id, false);
        oppRec.Primary_Member__c = conRec.Id;
        oppRec.StageName = 'Tour Scheduled';
        oppRec.CloseDate = system.today().addDays(5);
        oppRec.RecordTypeId = oppRecordType.get('Office Space');
        TestingUtility.insertWithAssert(oppRec);
        
        Opportunity oppRec2 = TestingUtility.createOpportunity(accRec.Id, false);
        oppRec2.Primary_Member__c = conRec.Id;
        oppRec2.StageName = 'Tour Scheduled';
        oppRec2.CloseDate = system.today().addDays(5);
        oppRec2.RecordTypeId = oppRecordType.get('Office Space');
        TestingUtility.insertWithAssert(oppRec2);
        
        Map<String,Object> tourDataMap = new Map<String,Object>();
        tourDataMap.put('Opportunity__c', oppRec.Id);
        tourDataMap.put('Status__c', 'Scheduled');
        tourDataMap.put('Tour_Date__c', system.today().addDays(-1));
        tourDataMap.put('Start_Time__c', '9:00AM');
        Tour_Outcome__c contactRecord = (Tour_Outcome__c)TestingUtility.createTestRecords(Tour_Outcome__c.SObjectType, tourDataMap, true);
        
        Test.startTest();
        
        tourDataMap = new Map<String,Object>();
        tourDataMap.put('Opportunity__c', oppRec.Id);
        tourDataMap.put('Status__c', 'Scheduled');
        tourDataMap.put('Tour_Date__c', system.today().addDays(-1));
        TestingUtility.createTestRecords(Tour_Outcome__c.SObjectType, tourDataMap, true);
        
        tourDataMap = new Map<String,Object>();
        tourDataMap.put('Opportunity__c', oppRec2.Id);
        tourDataMap.put('Status__c', 'Scheduled');
        tourDataMap.put('Tour_Date__c', system.today().addDays(-1));
        TestingUtility.createTestRecords(Tour_Outcome__c.SObjectType, tourDataMap, true);
        
        Test.stopTest();
    }
    
    static testMethod void testUpdateJourneyStage(){
        Setting__c testSettings = new Setting__c();
        testSettings.Name = 'LeadJourneyTrigger';
        testSettings.Data__c = '[{"LeadStatus":"Unqualified","JourneyStage":"Completed-Lost"}]';
        TestingUtility.upsertWithAssert(testSettings);
        
        Account accRec = TestingUtility.createAccount('strAccountName', true);
         Contact conRec = new Contact(
                firstname = 'Paul',
                lastname = 'Rambo',
                email = 'paul12345@rambo.com',
                accountID = accRec.Id,
                Status__c = 'active'
            );
            insert conRec;
        System.assertNotEquals(conRec.Id, null);
        Map<String, Id> oppRecordType = TestingUtility.getRecordTypeMapByName(Opportunity.sObjectType);
        
        Opportunity oppRec = TestingUtility.createOpportunity(accRec.Id, false);
        oppRec.Primary_Member__c = conRec.Id;
        oppRec.StageName = 'Tour Scheduled';
        oppRec.CloseDate = system.today().addDays(5);
        oppRec.RecordTypeId = oppRecordType.get('Office Space');
        TestingUtility.insertWithAssert(oppRec);        
        
        Journey__c newTestJourney = new Journey__c();
        newTestJourney.Name = 'Test Samadhan';
        newTestJourney.Stage__c = 'Started';
        newTestJourney.Primary_Contact__c = conRec.Id;
        newTestJourney.NMD_Next_Contact_Date__c = Date.today();
        insert newTestJourney;
        
        List<Tour_Outcome__c> lstTours = new List<Tour_Outcome__c>();
        Tour_Outcome__c tour1 = new Tour_Outcome__c();
        tour1.Scheduled_By__c = conRec.Id;
        tour1.Opportunity__c = oppRec.Id;
        tour1.Journey__c = newTestJourney.Id;
        tour1.Status__c = 'Scheduled';
        tour1.Tour_Date__c = system.today().addDays(3);
        lstTours.add(tour1);
        Tour_Outcome__c tour2 = new Tour_Outcome__c();
        tour2.Scheduled_By__c = conRec.Id;
        tour2.Opportunity__c = oppRec.Id;
        tour2.Journey__c = newTestJourney.Id;
        tour2.Status__c = 'Completed';
        tour2.Tour_Date__c = system.today().addDays(3);
        lstTours.add(tour2);
        TestingUtility.insertListWithAssert(lstTours);
        
        System.assertEquals('Tour Completed', [Select Id,Name,Stage__c From Journey__c Where Id =: newTestJourney.Id ].Stage__c);
    }
    
    static testMethod void testCloseOpenActivities(){
        Setting__c testSettings = new Setting__c();
        testSettings.Name = 'OpportunityFromLatestOpportunity';
        testSettings.Data__c = '{"LeadSource":{"name":"LeadSource","overwrite":false},"Lead_Source_Detail__c":{"name":"Lead_Source_Detail__c","overwrite":true},"utm_campaign__c":{"name":"utm_campaign__c","overwrite":true},"utm_campaign_id__c":{"name":"utm_campaign_id__c","overwrite":false},"utm_content__c":{"name":"utm_content__c","overwrite":false},"utm_medium__c":{"name":"utm_medium__c","overwrite":true},"utm_source__c":{"name":"utm_source__c","overwrite":false},"utm_term__c":{"name":"utm_term__c","overwrite":false}}';
        TestingUtility.insertWithAssert(testSettings);
        
        Account accRec = TestingUtility.createAccount('strAccountName', true);
        //Contact conRec = TestingUtility.createContact(accRec.Id, 'contact Last Name', true);
         Contact conRec = new Contact(
                firstname = 'Paul',
                lastname = 'Rambo',
                email = 'paul111@rambo.com',
                accountID = accRec.Id,
                Status__c = 'active'
            );
            insert conRec;
        
        System.assertNotEquals(conRec.Id, null);
        Map<String, Id> oppRecordType = TestingUtility.getRecordTypeMapByName(Opportunity.sObjectType);
        
        Opportunity oppRec = TestingUtility.createOpportunity(accRec.Id, false);
        oppRec.Primary_Member__c = conRec.Id;
        oppRec.StageName = 'Tour Scheduled';
        oppRec.CloseDate = system.today().addDays(5);
        oppRec.RecordTypeId = oppRecordType.get('Office Space');
        TestingUtility.insertWithAssert(oppRec);
        
        Setting__c testSettings1 = new Setting__c();
        testSettings1.Name = 'QueueManagementSettings';
        testSettings1.Data__c = '{"excludeprofiles":""}';
        insert testSettings1;
        
        Setting__c testSettings2 = new Setting__c();
        testSettings2.Name = 'CloseOpenActivities';
        testSettings2.Data__c = '{"subject":"Inbound Lead submission, Follow-Up"}';
        insert testSettings2;
        
        Task openInboundLeadActivity1 = new Task();
        openInboundLeadActivity1.Subject = 'Inbound Lead Submission';
        openInboundLeadActivity1.Type = 'Website';
        openInboundLeadActivity1.WhoId = conRec.Id;
        openInboundLeadActivity1.Description = 'Inbound Lead';
        openInboundLeadActivity1.CallDisposition = 'Test';
        TestingUtility.insertWithAssert(openInboundLeadActivity1);
        
        Debug.log('Test : openInboundLeadActivity1 ::: ' + openInboundLeadActivity1);
        
        Tour_Outcome__c tour1 = new Tour_Outcome__c();
        tour1.Scheduled_By__c = conRec.Id;
        tour1.Opportunity__c = oppRec.Id;
        tour1.Status__c = 'Scheduled';
        tour1.Tour_Date__c = system.today().addDays(3);
        TestingUtility.insertWithAssert(tour1);
        
        System.assertEquals('Completed', [SELECT Id, Subject, Status FROM Task WHERE Id=:openInboundLeadActivity1.Id].Status);
        
        Task openInboundLeadActivity2 = new Task();
        openInboundLeadActivity2.Subject = 'Phone Call';
        openInboundLeadActivity2.Type = 'Website';
        openInboundLeadActivity2.WhoId = conRec.Id;
        openInboundLeadActivity2.Description = 'Inbound Lead';
        openInboundLeadActivity2.CallDisposition = 'Test';
        TestingUtility.insertWithAssert(openInboundLeadActivity2);
        
        Task openInboundLeadActivity3 = new Task();
        openInboundLeadActivity3.Subject = 'Inbound Lead Submission';
        openInboundLeadActivity3.Type = 'Website';
        openInboundLeadActivity3.WhoId = conRec.Id;
        openInboundLeadActivity3.Description = 'Inbound Lead';
        openInboundLeadActivity3.CallDisposition = 'Test';
        TestingUtility.insertWithAssert(openInboundLeadActivity3);
        
        Task openInboundLeadActivity4 = new Task();
        openInboundLeadActivity4.Subject = 'Inbound Lead Submission';
        openInboundLeadActivity4.Type = 'Website';
        openInboundLeadActivity4.WhoId = conRec.Id;
        openInboundLeadActivity4.Description = 'Inbound Lead';
        openInboundLeadActivity4.CallDisposition = 'Test';
        TestingUtility.insertWithAssert(openInboundLeadActivity4);
        
        Task openInboundLeadActivity5 = new Task();
        openInboundLeadActivity5.Subject = 'Follow-Up';
        openInboundLeadActivity5.Type = 'Website';
        openInboundLeadActivity5.WhoId = conRec.Id;
        openInboundLeadActivity5.Description = 'Inbound Lead';
        openInboundLeadActivity5.CallDisposition = 'Test';
        TestingUtility.insertWithAssert(openInboundLeadActivity5);
        
        Task openInboundLeadActivity6 = new Task();
        openInboundLeadActivity6.Subject = 'Inbound Lead Submission';
        openInboundLeadActivity6.Type = 'Website';
        openInboundLeadActivity6.WhoId = conRec.Id;
        openInboundLeadActivity6.Description = 'Inbound Lead';
        openInboundLeadActivity6.CallDisposition = 'Test';
        //TestingUtility.insertWithAssert(openInboundLeadActivity5);
                
        Tour_Outcome__c tour2 = new Tour_Outcome__c();
        tour2.Scheduled_By__c = conRec.Id;
        tour2.Opportunity__c = oppRec.Id;
        tour2.Status__c = 'Scheduled';
        tour2.Tour_Date__c = system.today().addDays(4);
        TestingUtility.insertWithAssert(tour2);
        
        System.assertEquals('Completed', [SELECT Id, Subject, Status FROM Task WHERE Id=:openInboundLeadActivity4.Id].Status);
    }
    
    static testMethod void testTourScheduledConvertLead(){
      
        Setting__c testSettings = new Setting__c();
        testSettings.Name = 'OpportunityFromLatestOpportunity';
        testSettings.Data__c = '{"LeadSource":{"name":"LeadSource","overwrite":false},"Lead_Source_Detail__c":{"name":"Lead_Source_Detail__c","overwrite":true},"utm_campaign__c":{"name":"utm_campaign__c","overwrite":true},"utm_campaign_id__c":{"name":"utm_campaign_id__c","overwrite":false},"utm_content__c":{"name":"utm_content__c","overwrite":false},"utm_medium__c":{"name":"utm_medium__c","overwrite":true},"utm_source__c":{"name":"utm_source__c","overwrite":false},"utm_term__c":{"name":"utm_term__c","overwrite":false}}';
        TestingUtility.insertWithAssert(testSettings);
        
         
        Account accRec = TestingUtility.createAccount('strAccountName', true);
        //Contact conRec = TestingUtility.createContact(accRec.Id, 'contact Last Name', true);
         Contact conRec = new Contact(
                firstname = 'Paul',
                lastname = 'Rambo',
                email = 'paul111@rambo.com',
                accountID = accRec.Id,
                Status__c = 'active'
            );
            insert conRec;
            
        Opportunity oppRec = TestingUtility.createOpportunity(accRec.Id, false);
        oppRec.Primary_Member__c = conRec.Id;
        oppRec.StageName = 'Tour Scheduled';
        oppRec.CloseDate = system.today().addDays(5);
       // oppRec.RecordTypeId = oppRecordType.get('Office Space');
        TestingUtility.insertWithAssert(oppRec); 
        
        Lead l = new Lead(FirstName = 'Test', LastName = 'Test', Company = 'Test', Email = 'TestTourLeadConversionTrigger@TestTourLeadConversionTrigger.com');
        insert l;
        
        Tour_Outcome__c tour1 = new Tour_Outcome__c();
        tour1.Scheduled_By__c = conRec.Id;
        tour1.Opportunity__c = oppRec.Id;
        tour1.Status__c = 'Scheduled';
        tour1.Lead__c = l.Id;
        tour1.Tour_Date__c = system.today().addDays(3);
        TestingUtility.insertWithAssert(tour1);          
    }
    
    static testMethod void testUpdateReffereOnTour(){
    	
      	Account accRec = new Account();
    	accRec.Name='Test Account' ;
    	insert accRec;
    	
    	Contact testContact = new Contact(
    	   AccountId =  accRec.Id,	
           firstname = 'TestFirstName',
           lastname = 'TestLastName',
           email = 'primary@example.com',
           Status__c = 'active',
		   Referrer__c  = null	          
        );
        insert testContact;  
        
        Contact referrer1 = new Contact(
    	   AccountId =  accRec.Id,	
           firstname = 'TestFirstName',
           lastname = 'TestLastName',
           email = 'TesT777@example.com',
           Status__c = 'active',
		   Referrer__c  = null	          
        );
        insert referrer1;
        
        Reference__c testReference = new Reference__c(Referenced_Email__c = 'primary@example.com', IsActive__c = true,Expires_On__c = (Date.today()).addDays(2),Referrer__c = referrer1.Id);
        insert testReference;
        
       	Tour_Outcome__c tour1 = new Tour_Outcome__c();
        tour1.Scheduled_By__c = testContact.Id;
        tour1.Primary_Member__c = testContact.Id;
        tour1.Status__c = 'Scheduled';
        tour1.CurrencyIsoCode = 'USD';
        tour1.Tour_Date__c = system.today().addDays(4);
        tour1.Referrer__c = null;
        
   		insert tour1;
   		
   		Tour_Outcome__c testTour = [Select Id, Referrer__c from Tour_Outcome__c where Id =: tour1.Id];
        Debug.Log('testTour : '+testTour);
        
        system.assertEquals( referrer1.Id,testTour.Referrer__c);
        
        Account accRec1 = new Account();
    	accRec1.Name='Test Account' ;
    	insert accRec1;
    	
       	Contact testContact1 = new Contact(
       		AccountId =  accRec1.Id,	
            firstname = 'TestFirstName',
            lastname = 'TestLastName',
            email = 'primary2@example.com',
            Status__c = 'active',
            Referrer__c  = null
        );
        insert testContact1;
        
       	Reference__c testReference1 = new Reference__c(Referenced_Email__c = 'primary2@example.com', IsActive__c = true,Expires_On__c = (Date.today()).addDays(-1),Referrer__c = referrer1.Id);
        insert testReference1;
        
        Tour_Outcome__c tour2 = new Tour_Outcome__c();
        tour2.Scheduled_By__c = testContact1.Id;
        tour2.Primary_Member__c = testContact1.Id;
        tour2.Status__c = 'Started';
        tour2.Tour_Date__c = system.today().addDays(2);
        tour2.Referrer__c = null;
        tour2.CurrencyIsoCode = 'MXN';
        insert tour2;
        
       	Tour_Outcome__c testTour1 = [Select Id, Referrer__c from Tour_Outcome__c where Id =: tour2.Id];
       	system.assertEquals(referrer1.Id,testTour1.Referrer__c);
        
    }
    
    static testMethod void testExtendValidityOfReference(){
    	
    	Account accRec = new Account();
    	accRec.Name='Test Account' ;
    	insert accRec;
    	
    	Contact testContact = new Contact(
    	   AccountId =  accRec.Id,	
           firstname = 'TestFirstName',
           lastname = 'TestLastName',
           email = 'test888@example.com',
           Status__c = 'active',
		   Referrer__c  = null	          
        );
        
        insert testContact; 
        
        Contact referrer1 = new Contact(
    	   AccountId =  accRec.Id,	
           firstname = 'TestFirstName',
           lastname = 'TestLastName',
           email = 'TesT777@example.com',
           Status__c = 'active',
		   Referrer__c  = null	          
        );
        insert referrer1;
         
       	Reference__c testReference = new Reference__c(Referenced_Email__c = 'test888@example.com', IsActive__c = true,Expires_On__c = (Date.today()).addDays(0),Referrer__c = referrer1.Id);
        insert testReference;
                
        Tour_Outcome__c tour = new Tour_Outcome__c();
        tour.Scheduled_By__c = testContact.Id;
        tour.Primary_Member__c = testContact.Id;
        tour.Status__c = 'Completed';
        tour.Tour_Date__c = system.today().addDays(-4);
        tour.Referrer__c = null;
        tour.CurrencyIsoCode = 'MXN';
        insert tour;
        
        Reference__c testReference1 = [SELECT Id,Expires_On__c FROM Reference__c WHERE Id=:testReference.Id];
        system.assertEquals(Date.today().addDays(60),testReference1.Expires_On__c);
       
       	Tour_Outcome__c tour1 = new Tour_Outcome__c();
        tour1.Scheduled_By__c = testContact.Id;
        tour1.Primary_Member__c = testContact.Id;
        tour1.Status__c = 'Scheduled';
        tour1.Tour_Date__c = system.today().addDays(-4);
        tour1.Referrer__c = null;
        tour1.CurrencyIsoCode = 'MXN';
        insert tour1;
        
        Reference__c testReference2 = [SELECT Id,Expires_On__c FROM Reference__c WHERE Id =: testReference.Id];
        system.assertEquals(Date.today().addDays(60),testReference2.Expires_On__c);
            
       	Reference__c testReference4 = new Reference__c(Referenced_Email__c = 'test888@example.com', IsActive__c = true,Expires_On__c = (Date.today()).addDays(0),Referrer__c = referrer1.Id);
        insert testReference4;
         
       	Tour_Outcome__c tour2 = new Tour_Outcome__c();
        tour2.Scheduled_By__c = testContact.Id;
        tour2.Primary_Member__c = testContact.Id;
        tour2.Status__c = 'Started';
        tour2.Tour_Date__c = system.today().addDays(-4);
        tour2.Referrer__c = null;
        tour2.CurrencyIsoCode = 'MXN';
        insert tour2;
          
        Reference__c testReference3 = [SELECT Id,Expires_On__c FROM Reference__c WHERE Id =: testReference4.Id];
        system.assertEquals(Date.today(),testReference3.Expires_On__c);
    }
    
}