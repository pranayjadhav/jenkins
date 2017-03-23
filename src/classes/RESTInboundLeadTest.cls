@isTest
private class RESTInboundLeadTest {
    static Boolean settingsInitialized = false;
    static LeadConvertor.JourneySettings settingJourney;
    
    static void initFieldMappings() {
        Debug.turnDebugOn();

        if( settingsInitialized )
            return;
        
        /*
        Settings.FieldMappings leadToContactMappings = new Settings.FieldMappings();
        leadToContactMappings.version = 1;
        leadToContactMappings.mappings = new Map<String, Settings.MappedField>();
        leadToContactMappings.mappings.put('Name', new Settings.MappedField('Name'));
        leadToContactMappings.mappings.put('Email', new Settings.MappedField('Email'));
        Settings.saveFieldMappings( 'LeadToContact', leadToContactMappings);
        
        Settings.FieldMappings leadToJourneyMappings = new Settings.FieldMappings();
        leadToJourneyMappings.version = 1;
        leadToJourneyMappings.mappings = new Map<String, Settings.MappedField>();
        leadToJourneyMappings.mappings.put('Name', new Settings.MappedField('Name'));
        leadToJourneyMappings.mappings.put('Lead_Source__c', new Settings.MappedField('LeadSource'));
        Settings.saveFieldMappings( 'LeadToJourney', leadToJourneyMappings);

        Settings.FieldMappings leadToActivityMappings = new Settings.FieldMappings();
        leadToActivityMappings.version = 1;
        leadToActivityMappings.mappings = new Map<String, Settings.MappedField>();
        leadToJourneyMappings.mappings.put('Lead_Source__c', new Settings.MappedField('LeadSource'));
        Settings.saveFieldMappings( 'LeadToActivity', leadToActivityMappings);
		*/
        
        Account account = new Account(Name = 'Dummy Lead Conversion Account');
        insert account;

        //Initiralize Trigger settings
        /*Triggers__c triggers = Triggers__c.getOrgDefaults();
        Debug.Log('Triggers Existing : ' + triggers);
        triggers.Lead_ConvertLeadsToJourneys__c = true;
        upsert triggers;
        Debug.Log('Triggers Saved : ' + triggers);*/

        Setting__c[] settingsToInsert = new List<Setting__c>();
        settingJourney = new LeadConvertor.JourneySettings();
        settingJourney.NextCallInDaysFromLeadCreation = 2;
        settingJourney.NewLeadActivityFields = null;
        settingJourney.NewJourneyFields = null;
        settingJourney.NoCompanyAccountId = account.Id;
        settingsToInsert.add(new Setting__c(Name = 'Journey', Data__c = JSON.serialize(settingJourney)));
        insert settingsToInsert;
        
        /*Setting__c testSettings = new Setting__c();
        testSettings.Name = 'LeadJourneyTrigger';
        testSettings.Data__c = '[{"LeadStatus":"Unqualified","JourneyStage":"Completed-Lost"}]';
        TestingUtility.insertWithAssert(testSettings);*/
        
        Profile weworkSystemAdmin = [SELECT Id FROM Profile WHERE Name='WeWork Standard User'];
        Map<String,Object> userRecordMap = new Map<String,Object>();
        userRecordMap.put('LastName','Last Name 1');
        userRecordMap.put('Username','testweworkuser1@example.com');
        userRecordMap.put('Email','testweworkuser1@example.com');
        User testUser = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, userRecordMap, true); 
        
        Setting__c testSettings = new Setting__c();
        testSettings.Name = 'Lead:Lead and Lead Source Details';
        testSettings.Data__c = '{"LeadSource":["Broker"], "LeadSourceDetails":["Broker1","Broker2" ]}]';
        TestingUtility.insertWithAssert(testSettings);
        
        testSettings = new Setting__c();
        testSettings.Name = 'User/Queue Journey Creation';
        testSettings.Data__c = '{"allowedUsers":[{"userName":"'+ testUser.Username +'","Id":"'+testUser.Id +'"}],"allowedQueues":[]}';
        TestingUtility.insertWithAssert(testSettings);
        
        settingsInitialized = true;
    }
    @isTest static void test_post_success_1() {
        //pre-context
        Debug.turnDebugOn();
        initFieldMappings();
        
        //test
        Test.startTest();
        RestRequest req     = new RestRequest(); 
        RestResponse res    = new RestResponse();
      
      // pass the req and resp objects to the method         
      req.requestURI = 'https://cs8.salesforce.com/services/apexrest/InboundLead';  
      req.httpMethod = 'POST';

            //assign rest context
            RestContext.request     = req;
            RestContext.response    = res;
            Campaign c = new Campaign(Name='Test Campaign');
            insert c;
            //define container and set request Company and Reservable UUIDs
            WWTypes.InboundLead j = new WWTypes.InboundLead();
            j.company_name = 'A company';
            j.last_name = 'Doe';
            j.first_name = 'John';
            j.email = 'john@doe.com';
            j.campaign_sfid = c.Id;
            j.locale ='en-US';
            j.generate_journeys = false;
            j.phone = '9874563210';
            j.lead_source = 'test';
            j.lead_source_detail = 'test';
            j.lead_type = 'Office Space';
            j.Product_Interests = new List<String>{'Office Space','Residential Space'};
            
            //submit post
            RESTInboundLead.Response response = RESTInboundLead.doPost(j);
    
            //confirm response
            system.assertEquals(true, response.success);

            Lead[] Ks = [   SELECT id
                                        FROM Lead 
                                        WHERE email = :j.email 
                                        LIMIT 1
                                    ];
            system.assertEquals(
                1,
                Ks.size(),
                'A lead should be created'
            );

            Task[] Ts = [ SELECT id
                                    FROM Task
                                    WHERE WhoId = :Ks[0].id
                                    LIMIT 1
                                ];

            system.assertEquals(
                1,
                Ts.size(),
                'A task associated to the lead should be created'
            ); 
        
            List<Lead> leads = [ SELECT Id FROM Lead WHERE Id IN (SELECT LeadId FROM CampaignMember WHERE CampaignId =: c.Id AND LeadId != null) ];
            system.assertEquals(
                1,
                leads.size(),
                'A Lead associated to the Campaign should be created'
            );
        Test.stopTest();
    }
       
    @isTest static void test_post_success_2() {
        //pre-context
        
        //test
        Test.startTest();
        RestRequest req     = new RestRequest(); 
        RestResponse res    = new RestResponse();
      
      // pass the req and resp objects to the method         
      req.requestURI = 'https://cs8.salesforce.com/services/apexrest/InboundLead';  
      req.httpMethod = 'POST';

            //assign rest context
            RestContext.request     = req;
            RestContext.response    = res;
            Campaign c = new Campaign(Name='Test Campaign');
            insert c;
            //define container and set request Company and Reservable UUIDs
            WWTypes.InboundLead j       = new WWTypes.InboundLead();
            
            //submit post
            RESTInboundLead.Response response = RESTInboundLead.doPost(j);

        Test.stopTest();
    }
    
    //Anant Kumar on 9th May 2016
    //UseCase : If lead is exists with given email id;
    @isTest static void test_post_success_3() {
        //pre-context

        //test
        Test.startTest();
            RestRequest req     = new RestRequest(); 
        	RestResponse res    = new RestResponse();
      
        	// pass the req and resp objects to the method         
        	req.requestURI = System.URL.getSalesforceBaseURL().toExternalForm() + '/services/apexrest/InboundLead';  
        	req.httpMethod = 'POST';

            //assign rest context
            RestContext.request     = req;
            RestContext.response    = res;
            Campaign c = new Campaign(Name='Test Campaign');
            insert c;
            Account accRec = TestingUtility.createAccount('strAccountName', true);
            Contact referrerContact = TestingUtility.createContact(accRec.Id, 'strLastName', false);
        	referrerContact.Email = 'testreferrer@example.com';
        	TestingUtility.insertWithAssert(referrerContact);

            Lead leadRec1 = new Lead();
            leadRec1.LastName = 'Test Lead';
            leadRec1.Company = 'test123';
            leadRec1.Status = 'Open';
            leadRec1.LeadSource = 'wework.com';
            leadRec1.Email = 'test.lead@test123.com';
            Database.SaveResult result = TestingUtility.insertWithAssert(leadRec1);
        
            CampaignMember cm = new CampaignMember(CampaignId=c.Id ,LeadId=result.Id, Status='Sent');
            insert cm;
            //define container and set request Company and Reservable UUIDs
            WWTypes.InboundLead j       = new WWTypes.InboundLead();
            j.company_name                      = 'A company';
            j.last_name                             = 'Doe';
            j.first_name                            = 'John';
            j.email                                     = 'test.lead@test123.com';
            j.locale                                    ='en-US';
            j.campaign_sfid                             = c.Id;
            j.referrer_sfid                                  = referrerContact.Id;  
            j.Product_Interests  = new List<String>{'Office Space','Residential Space'}; 
            
            //submit post
            RESTInboundLead.Response response = RESTInboundLead.doPost(j);
    
            //confirm response
            //If a lead with given email id is exists.
            system.assertEquals(false, response.success);
    }
    
    @isTest static void test_post_success_5() {
        //pre-context

        //test
        Test.startTest();
            RestRequest req     = new RestRequest(); 
        RestResponse res    = new RestResponse();
      
      // pass the req and resp objects to the method         
      req.requestURI = System.URL.getSalesforceBaseURL().toExternalForm() + '/services/apexrest/InboundLead';  
      req.httpMethod = 'POST';

            //assign rest context
            RestContext.request     = req;
            RestContext.response    = res;
            Campaign c = new Campaign(Name='Test Campaign');
            insert c;
            Account accRec = TestingUtility.createAccount('strAccountName', true);
            Contact referrerContact = TestingUtility.createContact(accRec.Id, 'strLastName', false);
        	referrerContact.Email = 'testreferrer@example.com';
        	TestingUtility.insertWithAssert(referrerContact);

            Lead leadRec1 = new Lead();
            leadRec1.LastName = 'Test Lead';
            leadRec1.Company = 'test123';
            leadRec1.Status = 'Open';
            leadRec1.LeadSource = 'wework.com';
            leadRec1.Email = 'test.lead1@test123.com';
            Database.SaveResult result = TestingUtility.insertWithAssert(leadRec1);
        
            CampaignMember cm = new CampaignMember(CampaignId=c.Id ,LeadId=result.Id, Status='Sent');
            insert cm;
            //define container and set request Company and Reservable UUIDs
            WWTypes.InboundLead j       = new WWTypes.InboundLead();
            j.company_name                      = 'A company';
            j.last_name                             = 'Doe';
            j.first_name                            = 'John';
            j.email                                     = 'test.lead1@test123.com';
            j.locale                                    ='en-US';
            j.campaign_sfid                             = c.Id;
            j.referrer_sfid                                  = referrerContact.Id;  
            j.Product_Interests  = new List<String>{'Office Space','Residential Space'};
            
            //submit post
            RESTInboundLead.Response response = RESTInboundLead.doPost(j);
    
            //confirm response
            //If a lead with given email id is exists.
            system.assertEquals(false, response.success);
            Test.stopTest();
    }
    
    //Anant Kumar on 9th May 2016
    //UseCase : If contact is exists with given email id;
    @isTest static void test_post_success_4() {
        //pre-context

        //test
        Test.startTest();
            RestRequest req     = new RestRequest(); 
        RestResponse res    = new RestResponse();
      
      // pass the req and resp objects to the method         
      req.requestURI = System.URL.getSalesforceBaseURL().toExternalForm() + '/services/apexrest/InboundLead';  
      req.httpMethod = 'POST';

            //assign rest context
            RestContext.request     = req;
            RestContext.response    = res;
            Campaign c = new Campaign(Name='Test Campaign');
            insert c;
            Account accRec = TestingUtility.createAccount('strAccountName', true);
            Contact referrerContact = TestingUtility.createContact(accRec.Id, 'strLastName', false);
        	referrerContact.Email = 'testreferrer@example.com';
        	TestingUtility.insertWithAssert(referrerContact);
                
            Contact existingContact = TestingUtility.createContact(accRec.Id, 'existing Contact', false);
            existingContact.Email = 'test.lead@test123.com';
            TestingUtility.insertWithAssert(existingContact);
            
            Opportunity oppRec1 = TestingUtility.createOpportunity(accRec.Id, false);
            oppRec1.Primary_Member__c = existingContact.Id;
            TestingUtility.insertWithAssert(oppRec1);
            
            Map<String,Object> tourDataMap = new Map<String,Object>();
            tourDataMap.put('Scheduled_By__c', existingContact.Id);
            tourDataMap.put('Status__c', 'Scheduled');
            tourDataMap.put('Tour_Date__c', system.today().addDays(-1));
            tourDataMap.put('Start_Time__c', '9:00AM');
            Tour_Outcome__c contactRecord = (Tour_Outcome__c)TestingUtility.createTestRecords(Tour_Outcome__c.SObjectType, tourDataMap, true);
            
            //define container and set request Company and Reservable UUIDs
            WWTypes.InboundLead j       = new WWTypes.InboundLead();
            j.company_name                      = 'A company';
            j.last_name                             = 'Doe';
            j.first_name                            = 'John';
            j.email                                     = 'test.lead@test123.com';
            j.locale                                    ='en-US';
            j.campaign_sfid                             = c.Id;
            j.referrer_sfid                             = referrerContact.Id;  
            j.Product_Interests  = new List<String>{'Office Space','Residential Space'};
            
            //submit post
            RESTInboundLead.Response response = RESTInboundLead.doPost(j);
    
            //confirm response
            //If a lead with given email id is exists.
            system.assertEquals(false, response.success);
            Test.stopTest();
    }
    
    //UseCase : Test Inbound Lead for referral app.
    @isTest static void test_post_success_6() {
        //pre-context

        //test
        Test.startTest();
            RestRequest req     = new RestRequest(); 
        	RestResponse res    = new RestResponse();
      
        	// pass the req and resp objects to the method         
        	req.requestURI = System.URL.getSalesforceBaseURL().toExternalForm() + '/services/apexrest/InboundLead';  
        	req.httpMethod = 'POST';

            //assign rest context
            RestContext.request     = req;
            RestContext.response    = res;
            Campaign c = new Campaign(Name='Test Campaign');
            insert c;
            Account accRec = TestingUtility.createAccount('strAccountName', false);
        	accRec.Type = 'Prospect';
        	TestingUtility.insertWithAssert(accRec);
        
            Contact referrerContact = TestingUtility.createContact(accRec.Id, 'strLastName', false);
        	referrerContact.Email = 'testreferrer@example.com';
        	TestingUtility.insertWithAssert(referrerContact);
        	
            //define container and set request Company and Reservable UUIDs
            WWTypes.InboundLead j       = new WWTypes.InboundLead();
            j.company_name                      = 'A company';
            j.last_name                             = 'Doe';
            j.first_name                            = 'John';
            j.email                                     = 'test.lead@example.com';
            j.locale                                    ='en-US';
        	j.referrer_sfid                                  = referrerContact.Id;  
            j.Product_Interests  = new List<String>{'Office Space','Residential Space'}; 
            
            //submit post
            RESTInboundLead.Response response = RESTInboundLead.doPost(j);
    
            //confirm response
            //If a lead with given email id is exists.
            system.assertEquals(false, response.success);
        	system.assertEquals(1, [SELECT Id, Expires_On__c, Referrer__c FROM Reference__c].size());
        Test.stopTest();
    }
}