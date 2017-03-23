@isTest
private class RESTTourTest {
    static {
        Triggers__c triggersSettings = Settings.getTriggerSettings();
        
        Setting__c testSettings = new Setting__c();
        testSettings.Name = 'LeadJourneyTrigger';
        testSettings.Data__c = '[{"LeadStatus":"Unqualified","JourneyStage":"Completed-Lost"}]';
        TestingUtility.insertWithAssert(testSettings);
        
        //create a building and open it
        Building__c b = new Building__c(
            City__c = 'Test',
            uuid__c = 'abc123',
            Name = 'Test Building'

        );
        insert b;
        
        Tour_Schedule__c tour_Schedule = new Tour_Schedule__c(
            Building__c = b.Id,
            Simultaneous_Tours__c = '2',
            Tour_Spacing__c = 'Hour',
            Maximum_Tour_Days__c = 1
        );
        insert tour_Schedule;
        
        Setting__c setting = new Setting__c(
            Name = 'QueueManagementSettings',
            Data__c = '{"excludeprofiles":""}'
        );
        insert setting;
        
        insert new Tour_Open_Hour__c[]{
            new Tour_Open_Hour__c(
                weekday__c = 'Monday',
                start_time__c = '8:00AM',
                end_time__c = '8:00PM',
                Tour_Schedule__c = tour_Schedule.id,
                Building__c = b.Id
            ),
            new Tour_Open_Hour__c(
                weekday__c = 'Tuesday',
                start_time__c = '8:00AM',
                end_time__c = '8:00PM',
                Tour_Schedule__c = tour_Schedule.id,
                Building__c = b.Id
            ),
            new Tour_Open_Hour__c(
                weekday__c = 'Wednesday',
                start_time__c = '8:00AM',
                end_time__c = '8:00PM',
                Tour_Schedule__c = tour_Schedule.id,
                Building__c = b.Id
            ),
            new Tour_Open_Hour__c(
                weekday__c = 'Thursday',
                start_time__c = '8:00AM',
                end_time__c = '8:00PM',
                Tour_Schedule__c = tour_Schedule.id,
                Building__c = b.Id
            ),
            new Tour_Open_Hour__c(
                weekday__c = 'Friday',
                start_time__c = '8:00AM',
                end_time__c = '8:00PM',
                Tour_Schedule__c = tour_Schedule.id,
                Building__c = b.Id
            ),
            new Tour_Open_Hour__c(
                weekday__c = 'Saturday',
                start_time__c = '8:00AM',
                end_time__c = '8:00PM',
                Tour_Schedule__c = tour_Schedule.id,
                Building__c = b.Id
            ),
            new Tour_Open_Hour__c(
                weekday__c = 'Sunday',
                start_time__c = '8:00AM',
                end_time__c = '8:00PM',
                Tour_Schedule__c = tour_Schedule.id,
                Building__c = b.Id
            )
        };
    }

    //test new customer
    static testMethod void test_business_case_1() {
        //pre-context
            
            WWTypes.InboundLead j       = new WWTypes.InboundLead();
            j.company_name                      = 'A company';
            j.last_name                             = 'Doe';
            j.first_name                            = 'John';
            j.email                                     = 'john@doe.com';
            j.tour_building_uuid            =   'abc123';
            j.tour_date                             = system.today().addDays(1);
            j.tour_time                             = '9:00AM';
            j.locale                                = 'en-US';
            j.generate_journeys                     = false;
            j.Product_Interests  = new List<String>{'Office Space','Residential Space'};

        //test
        Test.startTest();
        RestRequest req     = new RestRequest(); 
        RestResponse res    = new RestResponse();
      
      // pass the req and resp objects to the method         
      req.requestURI = 'https://cs8.salesforce.com/services/apexrest/Tour';  
      req.httpMethod = 'POST';

            //assign rest context
            RestContext.request     = req;
            RestContext.response    = res;

            //submit post
            RESTTour.Response response = RESTTour.doPost(j);
    
            //confirm response
            system.assertEquals(true, response.success, 'Response msg: ' + response.message);

            //confirm created open opportunity
            Opportunity[] Os = [SELECT id 
                                                    FROM Opportunity 
                                                    WHERE Primary_Member__r.email = :j.email
                                                 ];

            system.assert(
                Os.size() > 0,
                'An opportunity should be created'
            );

            //system.assert(
            //  response.result != null &&
            //  response.result.contains(Os[0].id),
            //  'The opportunity id should be provided as response; ' + Os[0].id
            //);

            Tour_Outcome__c[] Ts = [SELECT id, Opportunity__c
                                                            FROM Tour_Outcome__c
                                                            WHERE tour_date__c = :j.tour_date
                                                            ];
            
            system.assert(
                Ts.size() > 0,
                'A tour for the specified date should be created:' + j.tour_date
            );
            /*
            system.assertEquals(
                Os[0].id,
                Ts[0].Opportunity__c,
                'The created tour should have the right opportunity assigned'
            );                  
            */
            system.assert(
                response.result != null &&
                response.result.contains(Ts[0].id),
                'The opportunity id should be provided as response; ' + Ts[0].id
            );                                      

            Task[] Ks = [   SELECT id, subject
                                        FROM Task
                                    ];
            
            system.assert(
                Ks.size() == 1,
                'A task should be created:' + Ks.size()
            );

            system.assertEquals(
                'Tour booked',
                Ks[0].subject,
                'The created task should have the right subject'
            );

        Test.stopTest();
    }

    //test existing customer as an open lead
    static testMethod void test_business_case_2() {
        //pre-context
            WWTypes.InboundLead j       = new WWTypes.InboundLead();
            j.company_name                      = 'A company';
            j.last_name                             = 'Doe';
            j.first_name                            = 'John';
            j.email                                     = 'john@doe.com';
            j.tour_building_uuid            =   'abc123';
            j.tour_date                             = system.today().addDays(1);
            j.tour_time                             = '9:00AM';
            j.locale                                = 'en-US';
            j.generate_journeys                     = false;
            j.Product_Interests  = new List<String>{'Office Space','Residential Space'};
            //create pre-existing open lead
            Lead k = new Lead(
                company                                 = j.company_name,
                firstname                           = j.first_name,
                lastname                                = j.last_name,
                email                                   = j.email,
                locale__c                               ='en-US',
                locations_interested__c = 'NYC-Penn Station'
            );
            insert k;

        //test
        Test.startTest();
        RestRequest req     = new RestRequest(); 
        RestResponse res    = new RestResponse();
      
      // pass the req and resp objects to the method         
      req.requestURI = 'https://cs8.salesforce.com/services/apexrest/Tour';  
      req.httpMethod = 'POST';

            //assign rest context
            RestContext.request     = req;
            RestContext.response    = res;
            
            //submit post
            RESTTour.Response response = RESTTour.doPost(j);
    
            //confirm response
            system.assertEquals(true, response.success, 'Response msg: ' + response.message);
        
            system.assertEquals(
                true,
                [   SELECT isConverted 
                    FROM Lead 
                    WHERE id = :k.id
                ].isConverted,
                'The lead was not converted'
            );

            Opportunity[] Os = [SELECT id 
                                                    FROM Opportunity 
                                                    WHERE Primary_Member__r.email = :j.email
                                                 ];

            system.assert(
                Os.size() > 0,
                'An opportunity should be created'
            );

            //system.assert(
            //  response.result != null &&
            //  response.result.contains(Os[0].id),
            //  'The opportunity id should be provided as response; ' + Os[0].id
            //);

            Tour_Outcome__c[] Ts = [SELECT id, Opportunity__c
                                                            FROM Tour_Outcome__c
                                                            WHERE tour_date__c = :j.tour_date
                                                            ];
            
            system.assert(
                Ts.size() > 0,
                'A tour for the specified date should be created:' + j.tour_date
            );
            /*
            system.assertEquals(
                Os[0].id,
                Ts[0].Opportunity__c,
                'The created tour should have the right opportunity assigned'
            );                                                          
            */
            system.assert(
                response.result != null &&
                response.result.contains(Ts[0].id),
                'The opportunity id should be provided as response; ' + Ts[0].id
            );  

            Task[] Ks = [   SELECT id, subject
                                        FROM Task
                                    ];
            
            system.assert(
                Ks.size() == 1,
                'A task should be created:' + Ks.size()
            );

            system.assertEquals(
                'Tour booked',
                Ks[0].subject,
                'The created task should have the right subject'
            );

        Test.stopTest();
    }

    //test existing customer as a converted lead
    static testMethod void test_business_case_3_1() {
        //pre-context
            WWTypes.InboundLead j       = new WWTypes.InboundLead();
            j.company_name                      = 'A company';
            j.last_name                             = 'Doe';
            j.first_name                            = 'John';
            j.email                                     = 'john@doe.com';
            j.tour_building_uuid            =   'abc123';
            j.tour_date                             = system.today().addDays(1);
            j.tour_time                             = '9:00AM';

            //create pre-existing open lead
            Lead k = new Lead(
                company                                 = j.company_name,
                firstname                           = j.first_name,
                lastname                                = j.last_name,
                email                                   = j.email,
                locations_interested__c = 'NYC-Penn Station'
            );
            insert k;

            //convert lead
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(k.id);

            LeadStatus convertStatus = [SELECT Id, MasterLabel 
                                                                    FROM LeadStatus 
                                                                    WHERE IsConverted=true 
                                                                    LIMIT 1
                                                                 ];

            lc.setConvertedStatus(convertStatus.MasterLabel);
            Database.LeadConvertResult lcr = Database.convertLead(lc);

            //re-query
            k = [   SELECT id, convertedContactId, convertedAccountId, convertedOpportunityId
                        FROM Lead 
                        WHERE id = :k.id
                    ];
            System.debug(logginglevel.ERROR, 'Test : Converted Lead ::: ' + k);
        //test
        Test.startTest();
            RestRequest req     = new RestRequest(); 
        RestResponse res    = new RestResponse();
      
      // pass the req and resp objects to the method         
      req.requestURI = System.URL.getSalesforceBaseURL().toExternalForm() + '/services/apexrest/Tour';  
      req.httpMethod = 'POST';

            //assign rest context
            RestContext.request     = req;
            RestContext.response    = res;
            
            //submit post
            RESTTour.Response response = RESTTour.doPost(j);
    
            //confirm response
            system.assertEquals(true, response.success, 'Response msg: ' + response.message);

            //confirm created open opportunity
            Opportunity[] Os = [SELECT id 
                                                    FROM Opportunity 
                                                    WHERE id = :k.convertedOpportunityId
                                                 ];

            system.assert(
                Os.size() > 0,
                'An opportunity should be created'
            );

            //system.assert(
            //  response.result != null &&
            //  response.result.contains(Os[0].id),
            //  'The opportunity id should be provided as response; ' + Os[0].id
            //);

            Tour_Outcome__c[] Ts = [SELECT id, Opportunity__c
                                                            FROM Tour_Outcome__c
                                                            WHERE tour_date__c = :j.tour_date
                                                            ];
            System.debug(logginglevel.ERROR, 'Test : All Opportunities ::: ' + [SELECT Id FROM Opportunity]);
            system.assert(
                Ts.size() > 0,
                'A tour for the specified date should be created:' + j.tour_date
            );

            /*system.assertEquals(
                Os[0].id,
                Ts[0].Opportunity__c,
                'The created tour should have the right opportunity assigned'
            );*/                                                            

            system.assert(
                response.result != null &&
                response.result.contains(Ts[0].id),
                'The opportunity id should be provided as response; ' + Ts[0].id
            );  

            Task[] Ks = [   SELECT id, subject
                                        FROM Task
                                    ];
            
            system.assertEquals(1, Ks.size(), 'A task should be created:' + Ks.size());
                //(
                //Ks.size() == 1,
                //'A task should be created:' + Ks.size()
            //);

            system.assertEquals(
                'Tour booked',
                Ks[0].subject,
                'The created task should have the right subject'
            );

        Test.stopTest();
    }

    //test existing customer with converted lead and closed opportunity
    static testMethod void test_business_case_3_2() {
        //pre-context
            WWTypes.InboundLead j       = new WWTypes.InboundLead();
            j.company_name                      = 'A company';
            j.last_name                             = 'Doe';
            j.first_name                            = 'John';
            j.email                                     = 'john@doe.com';
            j.tour_building_uuid            =   'abc123';
            j.tour_date                             = system.today().addDays(1);
            j.tour_time                             = '9:00AM';

            //create pre-existing open lead
            Lead k = new Lead(
                company                                 = j.company_name,
                firstname                           = j.first_name,
                lastname                                = j.last_name,
                email                                   = j.email,
                locations_interested__c = 'Test'
            );
            insert k;

            //convert lead
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(k.id);

            LeadStatus convertStatus = [SELECT Id, MasterLabel 
                                                                    FROM LeadStatus 
                                                                    WHERE IsConverted=true 
                                                                    LIMIT 1
                                                                 ];

            lc.setConvertedStatus(convertStatus.MasterLabel);
            Database.LeadConvertResult lcr = Database.convertLead(lc);

            //re-query
            k = [   SELECT id, convertedContactId, convertedAccountId, convertedOpportunityId
                        FROM Lead 
                        WHERE id = :k.id
                    ];

            Opportunity o = new Opportunity(
                id                          = k.convertedOpportunityId,
                stageName           = 'Closed Lost',
                lost_reason__c  = 'Not Interested'
            );
            update o;

        //test
        Test.startTest();
            RestRequest req     = new RestRequest(); 
        RestResponse res    = new RestResponse();
      
      // pass the req and resp objects to the method         
      req.requestURI = 'https://cs8.salesforce.com/services/apexrest/Tour';  
      req.httpMethod = 'POST';

            //assign rest context
            RestContext.request     = req;
            RestContext.response    = res;
            
            //submit post
            RESTTour.Response response = RESTTour.doPost(j);
    
            //confirm response
            system.assertEquals(true, response.success, 'Response msg: ' + response.message);

            //confirm created open opportunity
            Opportunity[] Os = [SELECT id 
                                                    FROM Opportunity 
                                                    WHERE isClosed = false
                                                 ];
            /*
            system.assert(
                Os.size() > 0,
                'An opportunity should be created'
            );
            */
            //system.assert(
            //  response.result != null &&
            //  response.result.contains(Os[0].id),
            //  'The opportunity id should be provided as response; ' + Os[0].id
            //);

            Tour_Outcome__c[] Ts = [SELECT id, Opportunity__c
                                                            FROM Tour_Outcome__c
                                                            WHERE tour_date__c = :j.tour_date
                                                            ];
            
            system.assert(
                Ts.size() > 0,
                'A tour for the specified date should be created:' + j.tour_date
            );
            /*
            system.assertEquals(
                Os[0].id,
                Ts[0].Opportunity__c,
                'The created tour should have the right opportunity assigned'
            );                                                          
            */
            system.assert(
                response.result != null &&
                response.result.contains(Ts[0].id),
                'The opportunity id should be provided as response; ' + Ts[0].id
            );  

            Task[] Ks = [   SELECT id, subject
                                        FROM Task
                                    ];
            
            system.assert(
                Ks.size() == 1,
                'A task should be created:' + Ks.size()
            );

            system.assertEquals(
                'Tour booked',
                Ks[0].subject,
                'The created task should have the right subject'
            );
    
        Test.stopTest();
    }

    //test existing customer as a regular member (not primary member) with a closed opportunity
    static testMethod void test_business_case_4_1() {
        //pre-context
            WWTypes.InboundLead j       = new WWTypes.InboundLead();
            j.company_name                      = 'A company';
            j.last_name                             = 'Doe';
            j.first_name                            = 'John';
            j.email                                     = 'john@doe.com';
            j.tour_building_uuid            =   'abc123';
            j.tour_date                             = system.today().addDays(1);
            j.tour_time                             = '9:00AM';

            //account
            Account a = new Account(
                name = 'Acme'
            );
            insert a;

            //create primary member
            Contact c_primary = new Contact(
                firstname = 'Paul',
                lastname = 'Boss',
                email = 'paul@boss.com',
                AccountId = a.id
            );
            insert c_primary;

            //make primary
            a.Primary_Member__c = c_primary.id;
            update a;

            //create regular member
            Contact c_regular = new Contact(
                firstname = 'John',
                lastname = 'Doe',
                email = 'john@doe.com',
                AccountId = a.id
            );
            insert c_regular;

            Opportunity o = new Opportunity(
                name                            = 'test closed oppty',
                AccountId               = a.id,
                Primary_Member__c = c_primary.id,
                stageName               = 'Closed Lost',
                lost_reason__c      = 'Not Interested',
                closeDate               = System.today()
            );
            insert o;

        //test
        Test.startTest();

        RestRequest req     = new RestRequest(); 
        RestResponse res    = new RestResponse();
      
      // pass the req and resp objects to the method         
      req.requestURI = 'https://cs8.salesforce.com/services/apexrest/Tour';  
      req.httpMethod = 'POST';

            //assign rest context
            RestContext.request     = req;
            RestContext.response    = res;
            
            //submit post
            RESTTour.Response response = RESTTour.doPost(j);
    
            //confirm response
            system.assertEquals(true, response.success, 'Response msg: ' + response.message);

            //confirm created open opportunity          
            Opportunity[] Os = [SELECT id 
                                                    FROM Opportunity 
                                                    WHERE isClosed = false
                                                 ];
            /*
            system.assert(
                Os.size() == 1,
                'An opportunity should be created'
            );
            */
            //system.assert(
            //  response.result != null &&
            //  response.result.contains(Os[0].id),
            //  'The opportunity id should be provided as response; ' + Os[0].id
            //);

            Tour_Outcome__c[] Ts = [SELECT id, Opportunity__c
                                                            FROM Tour_Outcome__c
                                                            WHERE tour_date__c = :j.tour_date
                                                            ];
            
            system.assert(
                Ts.size() > 0,
                'A tour for the specified date should be created:' + j.tour_date
            );
            /*
            system.assertEquals(
                Os[0].id,
                Ts[0].Opportunity__c,
                'The created tour should have the right opportunity assigned'
            );                                                          
            */
            system.assert(
                response.result != null &&
                response.result.contains(Ts[0].id),
                'The opportunity id should be provided as response; ' + Ts[0].id
            );  

            Task[] Ks = [   SELECT id, subject
                                        FROM Task
                                    ];
            
            system.assert(
                Ks.size() == 1,
                'A task should be created:' + Ks.size()
            );

            system.assertEquals(
                'Tour booked',
                Ks[0].subject,
                'The created task should have the right subject'
            );

        Test.stopTest();
    }

    //test existing customer as a regular member (not primary member) with an open opportunity
    static testMethod void test_business_case_4_2() {
        //pre-context
            WWTypes.InboundLead j       = new WWTypes.InboundLead();
            j.company_name                      = 'A company';
            j.last_name                             = 'Doe';
            j.first_name                            = 'John';
            j.email                                     = 'john@doe.com';
            j.tour_building_uuid            =   'abc123';
            j.tour_date                             = system.today().addDays(1);
            j.tour_time                             = '9:00AM';
            j.locale                                = 'en-US';
            j.Product_Interests  = new List<String>{'Office Space','Residential Space'};
            //account
            Account a = new Account(
                name = 'Acme'
            );
            insert a;

            //create primary member
            Contact c_primary = new Contact(
                firstname = 'Paul',
                lastname = 'Boss',
                email = 'paul@boss.com',
                AccountId = a.id
            );
            insert c_primary;

            //make primary
            a.Primary_Member__c = c_primary.id;
            update a;

            //create regular member
            Contact c_regular = new Contact(
                firstname = 'John',
                lastname = 'Doe',
                email = 'john@doe.com',
                AccountId = a.id
            );
            insert c_regular;

            Opportunity o = new Opportunity(
                name                                        = 'test closed oppty',
                AccountId                           = a.id,
                Primary_Member__c           = c_primary.id,
                stageName                           = 'Not Interested',
                closeDate                           = System.today(),
                locations_interested__c = 'NYC-Penn Station'
            );
            insert o;

        //test
        Test.startTest();

            RestRequest req     = new RestRequest(); 
        RestResponse res    = new RestResponse();
      
      // pass the req and resp objects to the method         
      req.requestURI = 'https://cs8.salesforce.com/services/apexrest/Tour';  
      req.httpMethod = 'POST';

            //assign rest context
            RestContext.request     = req;
            RestContext.response    = res;
            
            //submit post
            RESTTour.Response response = RESTTour.doPost(j);
    
            //confirm response
            system.assertEquals(true, response.success, 'Response msg: ' + response.message);

            //confirm affected open opportunity         
            Opportunity[] Os = [SELECT id 
                                                    FROM Opportunity 
                                                 ];

            /*system.assert(
                Os.size() == 1,
                'An opportunity should be affected'
            );*/

            //system.assert(
            //  response.result != null &&
            //  response.result.contains(Os[0].id),
            //  'The opportunity id should be provided as response; ' + Os[0].id
            //);

            Tour_Outcome__c[] Ts = [SELECT id, Opportunity__c
                                                            FROM Tour_Outcome__c
                                                            WHERE tour_date__c = :j.tour_date
                                                            ];
            
            system.assert(
                Ts.size() > 0,
                'A tour for the specified date should be created:' + j.tour_date
            );

            /*system.assertEquals(
                Os[0].id,
                Ts[0].Opportunity__c,
                'The created tour should have the right opportunity assigned'
            );  */                                                      

            system.assert(
                response.result != null &&
                response.result.contains(Ts[0].id),
                'The opportunity id should be provided as response; ' + Ts[0].id
            );  

            Task[] Ks = [   SELECT id, subject
                                        FROM Task
                                    ];
            
            system.assert(
                Ks.size() == 1,
                'A task should be created:' + Ks.size()
            );

            system.assertEquals(
                'Tour booked',
                Ks[0].subject,
                'The created task should have the right subject'
            );

        Test.stopTest();
    }

    
    
    // Test existing Account, Contact not exists
    static testMethod void test_business_case_5_1() {
        //pre-context
        
        //account
        Account a = new Account(
            Name = 'Acme',
            UUID__c = 'account-uuid',
            Lead_Source__c = 'Id'
        );
        insert a;

        WWTypes.InboundLead j       = new WWTypes.InboundLead();
        j.company_name                      = 'A company';
        j.last_name                             = 'Doe';
        j.first_name                            = 'John';
        j.email                                     = 'john@doe.com';
        j.tour_building_uuid            =   'abc123';
        j.account_uuid = 'account-uuid';
        j.contact_uuid = 'contact-uuid';

        // Test
        Test.startTest();
        
        RestRequest req     = new RestRequest(); 
        RestResponse res    = new RestResponse();
        
        // pass the req and resp objects to the method       
        req.requestURI = 'https://cs8.salesforce.com/services/apexrest/Tour';  
        req.httpMethod = 'POST';
        
        //assign rest context
        RestContext.request     = req;
        RestContext.response    = res;
        
        //submit post
        RESTTour.Response response = RESTTour.doPost(j);
        
        //confirm response
        system.assertEquals(true, response.success, 'Response msg: ' + response.message);

        // Confirm contact was created and set as primary member
        Contact[] Cs = [select AccountId, Is_Primary_Member__c from Contact where AccountId = :a.Id and UUID__c = 'contact-uuid'];

        System.assert(Cs.size() == 1, 'A Contact should be created');        

        a = [select Id, Primary_Member__c from Account where Id = :a.Id];

        System.assert(a.Primary_Member__c == Cs[0].Id, 'Contact should be set as Primary Member');
        
        // Confirm created Opportunity
        Opportunity[] Os = [SELECT Id FROM Opportunity where AccountId = :a.Id];
        /*
        system.assert(
            Os.size() == 1,
            'An opportunity should be created'
        );
        
        system.assert(
            response.result != null &&
            response.result.contains([SELECT id FROM Tour_Outcome__c LIMIT 1].id),
            'The tour id should be provided as response; ' + Os[0].id
        );
        */
        Task[] Ks = [SELECT id, subject FROM Task];
        
        system.assert(
            Ks.size() == 1,
            'A task should be created:' + Ks.size()
        );
        
        system.assertEquals(
            'Book a Tour',
            Ks[0].subject,
            'The created task should have the right subject'
        );
        
        Test.stopTest();
    }

    
    // Test Account not exists, Contact exists, Contact PM on another Account
    static testMethod void test_business_case_5_2() {

        Account a = new Account(Name = 'Acme');
        insert a;

        Contact c = new Contact(
            AccountId = a.Id,
            LeadSource = 'Id',
            UUID__c = 'contact-uuid',
            FirstName = 'Test',
            LastName = 'Test'
        );
        
        WWTypes.InboundLead j       = new WWTypes.InboundLead();
        j.account_uuid = 'account-uuid';
        j.contact_uuid = 'contact-uuid';

        // Test
        Test.startTest();
        
        RestRequest req     = new RestRequest(); 
        RestResponse res    = new RestResponse();
        
        // pass the req and resp objects to the method       
        req.requestURI = 'https://cs8.salesforce.com/services/apexrest/Tour';  
        req.httpMethod = 'POST';
        
        //assign rest context
        RestContext.request     = req;
        RestContext.response    = res;
        
        //submit post
        RESTTour.Response response = RESTTour.doPost(j);
        
        //confirm response
        system.assertEquals(false, response.success, 'Response msg: ' + response.message);
    }

    // Test Account not exists, Contact exists, Contact is a regular member
    static testMethod void test_business_case_5_3() {
        //pre-context
        
        //account
        Account a = new Account(Name = 'Acme');
        insert a;

        Contact primaryContact = new Contact(
            AccountId = a.Id,
            FirstName = 'Test',
            LastName = 'Test',
            LeadSource = 'Id',
            UUID__c = 'pm-contact-uuid',
            Email = 'test@example.com');

        insert primaryContact;

        Contact regularContact = new Contact(
            AccountId = a.Id,
            FirstName = 'Test',
            LastName = 'Test',
            LeadSource = 'Id',
            UUID__c = 'regular-contact-uuid',
            Email = 'test1@example.com');

        insert regularContact;
        
        WWTypes.InboundLead j       = new WWTypes.InboundLead();
        j.company_name                      = 'A company';
        j.tour_building_uuid            =   'abc123';
        j.account_uuid = 'account-uuid';
        j.contact_uuid = 'regular-contact-uuid';

        // Test
        Test.startTest();
        
        RestRequest req     = new RestRequest(); 
        RestResponse res    = new RestResponse();
        
        // pass the req and resp objects to the method       
        req.requestURI = 'https://cs8.salesforce.com/services/apexrest/Tour';  
        req.httpMethod = 'POST';
        
        //assign rest context
        RestContext.request     = req;
        RestContext.response    = res;
        
        //submit post
        RESTTour.Response response = RESTTour.doPost(j);
        
        //confirm response
        system.assertEquals(true, response.success, 'Response msg: ' + response.message);

        // Test Account was created
        Account[] accounts = [select Id, Primary_Member__c,Phone from Account where UUID__c = 'account-uuid'];
        System.assert(accounts.size() == 1, 'Account should have been created');
        accounts[0].Phone = '8956321889';
        update accounts;
        
        // Confirm contact was transferred and set as primary member
        Contact[] Cs = [select AccountId, Is_Primary_Member__c from Contact where AccountId = :accounts[0].Id and UUID__c = 'regular-contact-uuid'];
        Account[] updatedAccount = [select Id, Primary_Member__c from Account where UUID__c = 'account-uuid'];
        System.assert(Cs.size() == 1, 'Regular Contact should have been transferred to new Account');      
        System.assert(updatedAccount[0].Primary_Member__c == Cs[0].Id, 'Contact should be set as Primary Member');
        /*
        // Confirm created Opportunity
        Opportunity[] Os = [SELECT id FROM Opportunity where AccountId = :accounts[0].Id];

        system.assert(
            Os.size() == 1,
            'An opportunity should be created'
        );
        
        system.assert(
            response.result != null &&
            response.result.contains([SELECT id FROM Tour_Outcome__c LIMIT 1].id),
            'The tour id should be provided as response; ' + Os[0].id
        );
        */
        Task[] Ks = [SELECT id, subject FROM Task];
        
        system.assert(
            Ks.size() == 1,
            'A task should be created:' + Ks.size()
        );
        
        system.assertEquals(
            'Book a Tour',
            Ks[0].subject,
            'The created task should have the right subject'
        );
        
        Test.stopTest();
    }

    // Test Account exists, Contact exists, Contact belongs to Account
    static testMethod void test_business_case_5_4() {
        //pre-context
        
        //account
        Account a = new Account(Name = 'Acme', Lead_Source__c = 'Id', UUID__c = 'account-uuid');
        insert a;

        Contact c = new Contact(
            AccountId = a.Id,
            FirstName = 'Test',
            LastName = 'Test',
            LeadSource = 'Id',
            UUID__c = 'contact-uuid',
            Email = 'test@example.com');

        insert c;

        WWTypes.InboundLead j       = new WWTypes.InboundLead();
        j.company_name                      = 'A company';
        j.tour_building_uuid            =   'abc123';
        j.account_uuid = 'account-uuid';
        j.contact_uuid = 'contact-uuid';

        // Test
        Test.startTest();
        
        RestRequest req     = new RestRequest(); 
        RestResponse res    = new RestResponse();
        
        // pass the req and resp objects to the method       
        req.requestURI = 'https://cs8.salesforce.com/services/apexrest/Tour';  
        req.httpMethod = 'POST';
        
        //assign rest context
        RestContext.request     = req;
        RestContext.response    = res;
        
        //submit post
        RESTTour.Response response = RESTTour.doPost(j);
        
        //confirm response
        system.assertEquals(true, response.success, 'Response msg: ' + response.message);

        // Confirm created Opportunity
        Opportunity[] Os = [SELECT id FROM Opportunity where AccountId = :a.Id];

        /*system.assert(Os.size() == 1, 'An opportunity should be created');
        
        system.assert(
            response.result != null &&
            response.result.contains([SELECT id FROM Tour_Outcome__c LIMIT 1].id),
            'The tour id should be provided as response; ' + Os[0].id
        );
        */
        Task[] Ks = [SELECT id, subject FROM Task];
        
        system.assert(
            Ks.size() == 1,
            'A task should be created:' + Ks.size()
        );
        
        system.assertEquals(
            'Book a Tour',
            Ks[0].subject,
            'The created task should have the right subject'
        );
        
        Test.stopTest();
    }

    // Test Account exists, Contact exists, Contact is PM on another Account
    static testMethod void test_business_case_5_5() {
        //pre-context
        
        //account
        Account a = new Account(Name = 'Acme', Lead_Source__c = 'Id', UUID__c = 'account-uuid');
        insert a;

        Account another = new Account(Name = 'Acme2');
        insert another;
        
        Contact c = new Contact(
            AccountId = another.Id,
            FirstName = 'Test',
            LastName = 'Test',
            LeadSource = 'Id',
            UUID__c = 'contact-uuid',
            Email = 'test@example.com');

        insert c;

        WWTypes.InboundLead j       = new WWTypes.InboundLead();
        j.company_name                      = 'A company';
        j.tour_building_uuid            =   'abc123';
        j.account_uuid = 'account-uuid';
        j.contact_uuid = 'contact-uuid';

        // Test
        Test.startTest();
        
        RestRequest req     = new RestRequest(); 
        RestResponse res    = new RestResponse();
        
        // pass the req and resp objects to the method       
        req.requestURI = 'https://cs8.salesforce.com/services/apexrest/Tour';  
        req.httpMethod = 'POST';
        
        //assign rest context
        RestContext.request     = req;
        RestContext.response    = res;
        
        //submit post
        RESTTour.Response response = RESTTour.doPost(j);
        
        //confirm response
        system.assertEquals(false, response.success, 'Response msg: ' + response.message);
    }

    // Test Account exists, Contact exists, Contact is regular member on another Account
    static testMethod void test_business_case_5_6() {
        //pre-context
        
        //account
        Account a = new Account(Name = 'Acme', Lead_Source__c = 'Id', UUID__c = 'account-uuid');
        insert a;

        Account another = new Account(Name = 'Acme2');
        insert another;
        
        Contact primaryContact = new Contact(
            AccountId = another.Id,
            FirstName = 'Test2',
            LastName = 'Test2',
            Email = 'test@example.com');
        insert primaryContact;
        
        Contact regularContact = new Contact(
            AccountId = another.Id,
            FirstName = 'Test',
            LastName = 'Test',
            LeadSource = 'Id',
            UUID__c = 'contact-uuid',
            Email = 'test1@example.com');

        insert regularContact;

        WWTypes.InboundLead j       = new WWTypes.InboundLead();
        j.company_name                      = 'A company';
        j.tour_building_uuid            =   'abc123';
        j.account_uuid = 'account-uuid';
        j.contact_uuid = 'contact-uuid';

        // Test
        Test.startTest();
        
        RestRequest req     = new RestRequest(); 
        RestResponse res    = new RestResponse();
        
        // pass the req and resp objects to the method       
        req.requestURI = 'https://cs8.salesforce.com/services/apexrest/Tour';  
        req.httpMethod = 'POST';
        
        //assign rest context
        RestContext.request     = req;
        RestContext.response    = res;
        
        //submit post
        RESTTour.Response response = RESTTour.doPost(j);
        
        //confirm response
        system.assertEquals(true, response.success, 'Response msg: ' + response.message);

        // Confirm contact was transferred to other Account
        Contact[] Cs = [select AccountId, Primary_Member__c from Contact where AccountId = :a.Id and UUID__c = 'contact-uuid'];
        
        //System.assert(Cs.size() == 1, 'Regular Contact should have been transferred to new Account');        

        // Confirm created Opportunity
        Opportunity[] Os = [SELECT id FROM Opportunity where AccountId = :a.Id];
        /*
        system.assert(
            Os.size() == 1,
            'An opportunity should be created'
        );
        
        system.assert(
            response.result != null &&
            response.result.contains([SELECT id FROM Tour_Outcome__c LIMIT 1].id),
            'The tour id should be provided as response; ' + Os[0].id
        );
        */
        Task[] Ks = [SELECT id, subject FROM Task];
        
        system.assert(
            Ks.size() == 1,
            'A task should be created:' + Ks.size()
        );
        
        system.assertEquals(
            'Book a Tour',
            Ks[0].subject,
            'The created task should have the right subject'
        );
        
        Test.stopTest();
    }

    // Test Account not exists, Contact not exists
    static testMethod void test_business_case_5_7() {
        //pre-context
        WWTypes.InboundLead j       = new WWTypes.InboundLead();
        j.company_name                      = 'A company';
        j.first_name                            = 'Test';
        j.last_name                             = 'Test';
        j.tour_building_uuid            =   'abc123';
        J.Email = 'testREST@example.com';
        j.account_uuid = 'account-uuid';
        j.contact_uuid = 'contact-uuid';

        // Test
        Test.startTest();
        
        RestRequest req     = new RestRequest(); 
        RestResponse res    = new RestResponse();
        
        // pass the req and resp objects to the method       
        req.requestURI = 'https://cs8.salesforce.com/services/apexrest/Tour';  
        req.httpMethod = 'POST';
        
        //assign rest context
        RestContext.request     = req;
        RestContext.response    = res;
        
        //submit post
        RESTTour.Response response = RESTTour.doPost(j);
        
        //confirm response
        system.assertEquals(true, response.success, 'Response msg: ' + response.message);

        // Test Account was created
        Account[] accounts = [select Id, Primary_Member__c from Account where UUID__c = 'account-uuid'];
        System.assert(accounts.size() == 1, 'Account should have been created');
            
        // Confirm contact was created and set as primary member
        Contact[] Cs = [select AccountId, Is_Primary_Member__c from Contact where AccountId = :accounts[0].Id and UUID__c = 'contact-uuid'];
        
        System.assert(Cs.size() == 1, 'Regular Contact should have been transferred to new Account');        

        System.assert(accounts[0].Primary_Member__c == Cs[0].Id, 'Contact should be set as Primary Member');
        

        // Confirm created Opportunity
        Opportunity[] Os = [SELECT id FROM Opportunity where AccountId = :accounts[0].Id];
        /*
        system.assert(
            Os.size() == 1,
            'An opportunity should be created'
        );
        
        system.assert(
            response.result != null &&
            response.result.contains([SELECT id FROM Tour_Outcome__c LIMIT 1].id),
            'The tour id should be provided as response; ' + Os[0].id
        );
        */
        Task[] Ks = [SELECT id, subject FROM Task];
        
        system.assert(
            Ks.size() == 1,
            'A task should be created:' + Ks.size()
        );
       
        system.assertEquals(
            'Book a Tour',
            Ks[0].subject,
            'The created task should have the right subject'
        );
        
        Test.stopTest();
    }

    static testMethod void test_get_tour_success_1() {
        //pre-context
            WWTypes.InboundLead j       = new WWTypes.InboundLead();
            j.company_name                      = 'A company';
            j.last_name                             = 'Doe';
            j.first_name                            = 'John';
            j.email                                     = 'john@doe.com';
            j.tour_building_uuid            =   'abc123';
            j.tour_date                             = system.today().addDays(1);
            j.tour_time                             = '9:00AM';
            j.generate_journeys                     = true;
            RESTTour.Response context_response = RESTTour.doPost(j);
            
            system.assertEquals(
                true,
                context_response.success,
                'Valid Context should created: tour based on business case 1'
            );

            Tour_Outcome__c[] Ts = [SELECT id FROM Tour_Outcome__c LIMIT 1];
            system.assertEquals(
                1,
                Ts.size(),
                'A tour should be created'
            );

        //test
        Test.startTest();

            RestRequest req     = new RestRequest(); 
        RestResponse res    = new RestResponse();
            String tour_id = Ts[0].id;

        // pass the req and resp objects to the method       
        req.requestURI = 'https://cs8.salesforce.com/services/apexrest/Tour/' + tour_id;  
        req.httpMethod = 'GET';
     
            //assign rest context
            RestContext.request     =   req;
            RestContext.response    = res;
            
            //submit get
            RESTTour.Response response = RESTTour.doGet();
    
            //confirm response
            system.assertEquals(true, response.success);
    
        Test.stopTest();
    }

    static testMethod void test_get_tour_failure_1() {
        //pre-context
            
        //test
        Test.startTest();

            RestRequest req     = new RestRequest(); 
        RestResponse res    = new RestResponse();
            String tour_id = 'unexisting_salesforce_tour_id';

        // pass the req and resp objects to the method       
        req.requestURI = 'https://cs8.salesforce.com/services/apexrest/Tour/' + tour_id;  
        req.httpMethod = 'GET';
     
            //assign rest context
            RestContext.request     =   req;
            RestContext.response    = res;
            
            //submit get
            RESTTour.Response response = RESTTour.doGet();
    
            //confirm response
            system.assertEquals(false, response.success);
    
        Test.stopTest();
    }
}