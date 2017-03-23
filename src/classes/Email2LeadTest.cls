@isTest
private class Email2LeadTest {
    static{
        Triggers__c triggersSettings = Settings.getTriggerSettings();
        triggersSettings.Lead_ConvertLeadsToJourneys__c = false;
        upsert triggersSettings;
        
        Setting__c testSettings = new Setting__c();
        testSettings.Name = 'LeadJourneyTrigger';
        testSettings.Data__c = '[{"LeadStatus":"Unqualified","JourneyStage":"Completed-Lost"}]';
        TestingUtility.insertWithAssert(testSettings);
    }
    @isTest static void test_1_no_previous_lead() {
        //pre-context
            
            //create pre-existing
            Lead[] Ks = new Lead[]{
                new Lead(
                    firstname   = 'Troy',
                    lastname    = 'McClure',
                    email       = 'not_the_one@gmail.com',
                    company     = 'Springfield Inc'
                )
            };
            insert Ks;

            // create a new email and envelope object
      Messaging.InboundEmail email  = new Messaging.InboundEmail() ;
      Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

      // setup the data for the email
      email.subject       = 'Looking for a space';
      email.fromname      = 'John Doe';
      email.plainTextBody = 'Love pizza for breakfast!';
      email.htmlBody      = email.plainTextBody;
      email.fromAddress   = 'john@doe.com';
      email.toAddresses   = new String[]{'testservice@salesforce.com'};
      env.toAddress       = 'testservice@salesforce.com';
      env.fromAddress     = 'john@doe.com';

        //test
        Test.startTest();

        // call the email service class and test it with the data in the testMethod
      EMail2Lead emailProcess = new EMail2Lead();
      emailProcess.handleInboundEmail(email, env);

      Lead[] Ls = [ SELECT id 
                                FROM Lead 
                                WHERE email = :email.fromAddress
                            ];

      //check lead creation
      system.assertEquals(
        1,
        Ls.size(),
        'A new lead should exist after processing a new email'
      );

      //select tasks associated to lead
      Task[] Ts = [ SELECT id, subject, type 
                                FROM Task 
                                WHERE WhoId = :Ls[0].id
                                ORDER BY createddate
                               ];

            //check task created
            system.assertEquals(
                1,
                Ts.size(),
                'A new Task Email should be created'
            );

            //check task type was email
            system.assertEquals(
                'Email',
                Ts[0].type,
                'A new Email should be created and associated to the Lead'
            );

    
        Test.stopTest();
    }

    @isTest static void test_2_existing_lead() {
        //pre-context
        
            //create pre-existing
                Lead[] Ks = new Lead[]{
                    new Lead(
                        firstname = 'Troy',
                        lastname    = 'McClure',
                        email       = 'not_the_one@gmail.com',
                        company     = 'Springfield Inc'
                    ),
                    new Lead(
                        firstname = 'John',
                        lastname    = 'Doe',
                        email       = 'john@doe.com',
                        company     = 'Springfield Inc'
                    )
                };
                insert Ks;

            // create a new email and envelope object
      Messaging.InboundEmail email  = new Messaging.InboundEmail() ;
      Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

      // setup the data for the email
      email.subject       = 'Looking for a space';
      email.fromname      = 'John Doe';
      email.plainTextBody = 'Love pizza for breakfast!';
      email.htmlBody      = email.plainTextBody;
      email.fromAddress   = 'john@doe.com';
      email.toAddresses   = new String[]{'testservice@salesforce.com'};
      env.toAddress       = 'testservice@salesforce.com';
      env.fromAddress     = 'john@doe.com';

        //test
        Test.startTest();

        // call the email service class and test it with the data in the testMethod
      EMail2Lead emailProcess = new EMail2Lead();
      emailProcess.handleInboundEmail(email, env);

      Lead[] Ls = [ SELECT id 
                                    FROM Lead 
                                    WHERE email = :email.fromAddress
                                ];

      //check lead creation
      system.assertEquals(
        1,
        Ls.size(),
        'A new lead should not exist after processing a new email'
      );

      //select tasks associated to lead
      Task[] Ts = [ SELECT id, subject, type 
                                FROM Task 
                                WHERE WhoId = :Ls[0].id
                                ORDER BY createddate
                               ];

            //check task created
            system.assertEquals(
                1,
                Ts.size(),
                'A new Task Email should be created'
            );

            //check task type was email
            system.assertEquals(
                'Email',
                Ts[0].type,
                'A new Email should be created and associated to the Lead'
            );
    
        Test.stopTest();
    }

    @isTest static void test_3_existing_lead() {
        //pre-context

            //create pre-existing           
            List<sObject> Ks = Test.loadData(Lead.sObjectType, 'email2lead_test_csv');
            

            Lead last_lead = new Lead(
                firstname = 'John',
                lastname    = 'Doe',
                email       = 'john@doe.com',
                company     = 'Springfield Inc'
            );
            insert last_lead;

            // create a new email and envelope object
      Messaging.InboundEmail email  = new Messaging.InboundEmail() ;
      Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

      // setup the data for the email
      email.subject       = 'Looking for a space';
      email.fromname      = 'John Doe';
      email.plainTextBody = 'Love pizza for breakfast!';
      email.htmlBody      = email.plainTextBody;
      email.fromAddress   = 'john@doe.com';
      email.toAddresses   = new String[]{'testservice@salesforce.com'};
      env.toAddress       = 'testservice@salesforce.com';
      env.fromAddress     = 'john@doe.com';

        //test
        Test.startTest();

        // call the email service class and test it with the data in the testMethod
      EMail2Lead emailProcess = new EMail2Lead();
      emailProcess.handleInboundEmail(email, env);
    
            Lead[] Ls = [   SELECT id 
                                    FROM Lead 
                                    WHERE email = :email.fromAddress
                                    ORDER BY createddate DESC                               
                                ];

      //check lead creation
      system.assertEquals(
        2,
        Ls.size(),
        'A new lead should not exist after processing a new email'
      );

      //select tasks associated to newest lead
      Task[] Ts = [ SELECT id, subject, type 
                                FROM Task 
                                WHERE WhoId = :last_lead.id
                                ORDER BY createddate
                               ];

            //check task created
            system.assertEquals(
                1,
                Ts.size(),
                'A new Task Email should be created'
            );

            //check task type was email
            system.assertEquals(
                'Email',
                Ts[0].type,
                'A new Email should be created and associated to the Lead'
            );
    

        Test.stopTest();
    }

    @isTest static void test_4_existing_converted_lead() {
        //pre-context

            //create pre-existing
            List<sObject> Ks = Test.loadData(Lead.sObjectType, 'email2lead_test_csv');
            
            Lead last_lead = new Lead(
                firstname = 'John',
                lastname    = 'Doe',
                email       = 'john@doe.com',
                company     = 'Springfield Inc'
            );
            insert last_lead;

            //convert last lead
            Database.LeadConvert lc = new Database.LeadConvert();
            lc.setLeadId(last_lead.id);

            LeadStatus convertStatus = [    SELECT Id, MasterLabel 
                                                                        FROM LeadStatus 
                                                                        WHERE IsConverted=true 
                                                                        LIMIT 1
                                                                    ];

            lc.setConvertedStatus(convertStatus.MasterLabel);

            Database.LeadConvertResult lcr = Database.convertLead(lc);
            System.assert(lcr.isSuccess());

            // create a new email and envelope object
      Messaging.InboundEmail email  = new Messaging.InboundEmail() ;
      Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

      // setup the data for the email
      email.subject       = 'Looking for a space';
      email.fromname      = 'John Doe';
      email.plainTextBody = 'Love pizza for breakfast!';
      email.htmlBody      = email.plainTextBody;
      email.fromAddress   = 'john@doe.com';
      email.toAddresses   = new String[]{'testservice@salesforce.com'};
      env.toAddress       = 'testservice@salesforce.com';
      env.fromAddress     = 'john@doe.com';

        //test
        Test.startTest();

        // call the email service class and test it with the data in the testMethod
      EMail2Lead emailProcess = new EMail2Lead();
      emailProcess.handleInboundEmail(email, env);
    
            Lead[] Ls = [   SELECT id, isConverted, convertedContactId, convertedContact.ownerId 
                                    FROM Lead 
                                    WHERE id = :last_lead.id                                    
                                ];

      //check lead creation
      system.assertEquals(
        1,
        Ls.size(),
        'A new lead should not exist after processing a new email'
      );

      //check lead conversion
      system.assertEquals(
        true,
        Ls[0].isConverted,
        'The last lead sould be converted'
      );

      //check lead conversion/contact
      system.assertNotEquals(
        null,
        Ls[0].convertedContactId,
        'The last lead sould be converted into a contact'
      );

      //select tasks associated to newest lead
      Task[] Ts = [ SELECT id, subject, type, ownerId 
                                FROM Task 
                                WHERE WhoId = :Ls[0].convertedContactId
                                ORDER BY createddate
                               ];

            //check task created
            system.assertEquals(
                1,
                Ts.size(),
                'A new Task Email should be created'
            );

            //check task type was email
            system.assertEquals(
                'Email',
                Ts[0].type,
                'A new Email should be created and associated to the Lead\'s converted Contact'
            );

            //check task assigned to
            system.assertEquals(
                Ls[0].convertedContact.ownerId,
                Ts[0].ownerId,
                'Task should be assigned to Lead/Contact owner'
            );

        Test.stopTest();
    }

    @isTest static void test_5_existing_contact() {
        //pre-context

            //create pre-existing
            List<sObject> Ks = Test.loadData(Lead.sObjectType, 'email2lead_test_csv');
            
            Lead last_lead = new Lead(
                firstname = 'John',
                lastname    = 'Doe',
                email       = 'john@doe.com',
                company     = 'Springfield Inc'
            );
            insert last_lead;

            Account a = new Account(
                name = 'Test Account'
            );
            insert a;

            Contact c = new Contact(
                firstname = 'Peter',
                lastname = 'Parker',
                email = 'peter@parker.com',
                AccountId = a.id
            );
            insert c;

            //re-query
            c = [   SELECT id, ownerId, firstname, lastname, email
                        FROM Contact
                        WHERE id = :c.id
                        LIMIT 1
                    ];

            // create a new email and envelope object
      Messaging.InboundEmail email  = new Messaging.InboundEmail() ;
      Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

      // setup the data for the email
      email.subject       = 'Alligators in NY?';
      email.fromname      = 'Peter Parker';
      email.plainTextBody = 'Dr Octopus might be around!';
      email.htmlBody      = email.plainTextBody;
      email.fromAddress   = 'peter@parker.com';
      email.toAddresses   = new String[]{'testservice@salesforce.com'};
      env.toAddress       = 'testservice@salesforce.com';
      env.fromAddress     = 'peter@parker.com';

        //test
        Test.startTest();

        // call the email service class and test it with the data in the testMethod
      EMail2Lead emailProcess = new EMail2Lead();
      emailProcess.handleInboundEmail(email, env);
                
      //select tasks associated to contact
      Task[] Ts = [ SELECT id, subject, type, ownerId 
                                FROM Task 
                                WHERE WhoId = :c.id
                                ORDER BY createddate
                               ];

            //check task created
            system.assertEquals(
                1,
                Ts.size(),
                'A new Task Email should be created and associated to the contact'
            );

            //check task type was email
            system.assertEquals(
                'Email',
                Ts[0].type,
                'A new Email should be created and associated to the Lead\'s converted Contact'
            );

            //check task assigned to
            system.assertEquals(
                c.OwnerId,
                Ts[0].OwnerId,
                'Task should be assigned to Contact owner'
            );

        Test.stopTest();
    }

    @isTest static void test_6_existing_contact() {
        //pre-context

            //create pre-existing
            List<sObject> Ks = Test.loadData(Lead.sObjectType, 'email2lead_test_csv');
            
            Lead last_lead = new Lead(
                firstname = 'John',
                lastname    = 'Doe',
                email       = 'john@doe.com',
                company     = 'Springfield Inc'
            );
            insert last_lead;

            Account a = new Account(
                name = 'Test Account'
            );
            insert a;

            Contact c = new Contact(
                firstname = 'John',
                lastname = 'Doe',
                email = 'john@doe.com',
                AccountId = a.id
            );
            insert c;

            //re-query
            c = [   SELECT id, ownerId, firstname, lastname, email
                        FROM Contact
                        WHERE id = :c.id
                        LIMIT 1
                    ];

            // create a new email and envelope object
      Messaging.InboundEmail email  = new Messaging.InboundEmail() ;
      Messaging.InboundEnvelope env = new Messaging.InboundEnvelope();

      // setup the data for the email
      email.subject       = 'Alligators in NY?';
      email.fromname      = 'John Doe';
      email.plainTextBody = 'Dr Octopus might be around!';
      email.htmlBody      = email.plainTextBody;
      email.fromAddress   = 'john@doe.com';
      email.toAddresses   = new String[]{'testservice@salesforce.com'};
      env.toAddress       = 'testservice@salesforce.com';
      env.fromAddress     = 'john@doe.com';

        //test
        Test.startTest();

        // call the email service class and test it with the data in the testMethod
      EMail2Lead emailProcess = new EMail2Lead();
      emailProcess.handleInboundEmail(email, env);
                
      //select tasks associated to contact
      Task[] Ts = [ SELECT id, subject, type, ownerId 
                                FROM Task 
                                WHERE WhoId = :c.id
                                ORDER BY createddate
                               ];

            //check task created
            system.assertEquals(
                1,
                Ts.size(),
                'A new Task Email should be created and associated to the contact'
            );

            //check task type was email
            system.assertEquals(
                'Email',
                Ts[0].type,
                'A new Email should be created and associated to the Lead\'s converted Contact'
            );

            //check task assigned to
            system.assertEquals(
                c.OwnerId,
                Ts[0].OwnerId,
                'Task should be assigned to Contact owner'
            );

        Test.stopTest();
    }
    
}