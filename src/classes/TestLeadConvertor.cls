@isTest
public class TestLeadConvertor {
    static Boolean settingsInitialized = false;
    static LeadConvertor.JourneySettings settingJourney;

    static void initFieldMappings() {
        if( settingsInitialized )
            return;
        
        TriggerSettings.TriggersMappedField triggerSetting = TriggerSettings.get();
        
        Setting__c testSettings = new Setting__c();
        testSettings.Name = 'LeadJourneyTrigger';
        testSettings.Data__c = '[{"LeadStatus":"Unqualified","JourneyStage":"Completed-Lost"}]';
        TestingUtility.insertWithAssert(testSettings);
        
        testSettings = new Setting__c();
        testSettings.Name = 'Lead:Lead and Lead Source Details';
        testSettings.Data__c = '{"LeadSource":["Broker"], "LeadSourceDetails":["Broker1","Broker2" ]}';
        TestingUtility.insertWithAssert(testSettings);
        
        Profile weworkSystemAdmin = [SELECT Id FROM Profile WHERE Name='WeWork Standard User'];
        Map<String,Object> userRecordMap = new Map<String,Object>();
        userRecordMap.put('LastName','Last Name 1');
        userRecordMap.put('Username','testweworkuser1@example.com');
        userRecordMap.put('Email','testweworkuser1@example.com');
        User testUser = TestingUtility.insertUserWithAssert(weworkSystemAdmin.Id, userRecordMap, true); 

        //Create a queue
        Group testGroup = new Group ();
        testGroup.Name = 'Test Lead Queue';
        testGroup.Type = 'Queue';
        insert testGroup;
        
        Group testGroup1 = new Group ();
        testGroup1.Name = 'Test Lead Queue1';
        testGroup1.Type = 'Queue';
        insert testGroup1;
        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            QueueSObject testQueue = new QueueSObject();
            testQueue.QueueId = testGroup.Id;
            testQueue.SObjectType = 'Lead';
            insert testQueue;
       
            testQueue = new QueueSObject();
            testQueue.QueueId = testGroup.Id;
            testQueue.SObjectType = 'Journey__c';
            insert testQueue;
           
            testQueue = new QueueSObject();
            testQueue.QueueId = testGroup1.Id;
            testQueue.SObjectType = 'Lead';
            insert testQueue;
       
            testQueue = new QueueSObject();
            testQueue.QueueId = testGroup1.Id;
            testQueue.SObjectType = 'Journey__c';
            insert testQueue;
            
            GroupMember member = new GroupMember();
            member.UserOrGroupId = UserInfo.getUserId();
            member.GroupId = testGroup.Id; 
            insert member;
    }
        
        testSettings = new Setting__c();
        testSettings.Name = 'User/Queue Journey Creation';
        testSettings.Data__c = '{"allowedUsers":[{"userName":"'+ testUser.Username +'","Id":"'+testUser.Id +'"}],"allowedQueues":[{"Id":"'+ testGroup.Id +'","queueName":"'+ testGroup.Name +'"}]}';//{"Id":"'+ testGroup1.Id +'","queueName":"'+ testGroup1.Name +'"}
        TestingUtility.insertWithAssert(testSettings);
        
        settingsInitialized = true;
    }
    
    public static Lead prepareLead(String lastName, String company, String email, String phone) {
        return prepareLeads(lastName, company, email, phone, 1)[0];
    }
    
    public static List<Lead> prepareLeads(String lastName, String company, String email, String phone, integer count){
        List<Lead> listLeads = new List<Lead>();
        if( count == 1 ){
            Lead leadNew = new Lead(LastName = lastName, Company = company, Email = email, Phone = phone, Generate_Journey__c = false);
            listLeads.add(leadNew);
        }
        else if( count > 1 ) {
            String emailName = null, emailDomain = null;
            if( !String.IsBlank(email) ){
            integer iFound = email.indexOf('@');
            if( iFound >= 0 ){
            emailName = email.left(iFound);
            emailDomain = email.Mid(iFound, email.length());
            }
        }

        for(integer iIndex = 0; iIndex < count; ++iIndex) {
            Lead leadNew = new Lead(LastName = lastName + '-' + iIndex, Company = company, Generate_Journey__c = false);
            leadNew.Email = (emailName == null) ? null : emailName + '-' + iIndex + emailDomain;
            leadNew.Phone = (String.IsBlank(phone)) ? null : phone + iIndex;
            listLeads.add(leadNew);
            }
        }
        
        return listLeads;
    }
    
  static testMethod void testConvertLeadAssinedToUser(){
        initFieldMappings();
        Lead lead;
    	Contact contact;
        Set<Id> idsLead;
        Journey__c[] journeys;
        LeadConvertor.LeadResult[] results;
        string leadId;
        Lead[] leads;
        Lead leadOriginal;
        Task[] tasks;
        User u = [Select Id from user where username =:'testweworkuser1@example.com']; 
        system.assertNotEquals(null, u);
        //System.assert(journeys[0].Primary_Lead__c == leads[0].Id);
        Debug.log('New User:'+u);
    
       //If Journey is owned by the user given in settings also match the lead source and lead source details create new journey and activity
       system.runAs(u)
       {
           leads = prepareLeads('Smith', 'WeWork Test Company', 'john.smith@example.com', '+13698564125',4);
           for(Lead currentLead : leads)
           {
              currentLead.LeadSource= 'Broker';
              currentLead.Lead_Source_Detail__c = 'Broker1';
              currentLead.Generate_Journey__c = true;
           }
           
           insert leads;

           journeys = [Select Id,Name from Journey__c where Primary_Lead__c IN : leads];
           system.assertEquals(4, journeys.size());
           
           leads = [select Id,Name from Lead];
           system.assertEquals(4, leads.size());
           
           tasks = [select Id from task];
           system.assertEquals(4, tasks.size());
           
        //Check if contact exist and use the same contact and convert the lead get created with same email id and create journey and assign it to primary contact
        /*contact = new Contact(LastName = 'test', Email = 'test@example.com');
        insert contact;
        System.assert(contact.Id != null);*/
        
        contact = [Select Id from contact where Email = 'test@example.com'];
        
        Debug.Log('# of Queries 1: ' + Limits.getQueries());
        //Creates New Lead And Use existing Journey
        lead = prepareLead('Smith', 'WeWork Test Company', 'test@example.com', null);
        lead.Company = 'Test Company';
        lead.Generate_Journey__c = true;
    	lead.LeadSource= 'Broker';
        lead.Lead_Source_Detail__c = 'Broker1';
        insert lead;

        journeys = [Select Id, Primary_Contact__c From Journey__c where Primary_Contact__c =: contact.Id];
        leads = [Select Id,OwnerId,Email From Lead where isConverted = true];   
        System.assertEquals(1,leads.size());
    	System.assertEquals(1,journeys.size());
       }
       Test.startTest();
        //Lead Created with different owner Id which is not in allowed user settings creates activity and not journey
        lead = prepareLead('Smith', 'WeWork Test Company', 'john.smith@example.com', null);
        lead.Company = 'Test Company';
        lead.LeadSource = 'Broker';
        lead.Lead_Source_Detail__c = 'Broker1';
        //lead.ownerId = testGroup.Id;
        lead.Generate_Journey__c = true;
        insert lead;
        leads = [select Id,Name from Lead];
       	system.assertEquals(6, leads.size());
           
        tasks = [select Id from task];
        system.assertEquals(6, tasks.size());

        journeys = [Select Id,Name from Journey__c];
        system.assertEquals(5, journeys.size());
        

        //Check if contact exist and use the same contact and convert the lead get created with same email id
       /* Contact contact = new Contact(LastName = 'test', Email = 'test@example.com');
        insert contact;
        System.assert(contact.Id != null);*/
        //Creates New Lead & convert it becasue contact is alredy present and do not create journey.
        lead = prepareLead('Smith', 'WeWork Test Company', 'test@example.com', null);
        lead.Company = 'Test Company';
        lead.Generate_Journey__c = true;
    	lead.LeadSource= 'Broker';
        lead.Lead_Source_Detail__c = 'Broker1';
        insert lead;

        journeys = [Select Id, Primary_Contact__c From Journey__c where Primary_Contact__c =: contact.Id];
        leads = [Select Id,OwnerId,Email From Lead where isConverted = true];   
        System.assertEquals(2,leads.size());
    	System.assertEquals(1,journeys.size());

        //Check if lead owner is queue if yes and Lead source and lead source details condition satisfy create journey and activity.
        Group testGroup = [Select Id,Name from Group where Name = 'Test Lead Queue' and Type = 'Queue'];
        lead = prepareLead('Smith', 'WeWork Test Company', 'test1@example.com', null);
        lead.Company = 'Test Company';
        lead.LeadSource = 'Broker';
      	lead.Lead_Source_Detail__c = 'Broker1';
     	lead.Generate_Journey__c = true;
        lead.OwnerId = testGroup.Id;
        insert lead;
        //Test.startTest(); 
        journeys = [Select Id, Primary_Contact__c From Journey__c];
        System.assertEquals(5,journeys.size());
    
        //Check if contact exist and use the same contact and convert the lead get created with same email id
        contact = [Select Id from Contact where Email = 'test1@example.com'];
        Debug.Log('# of Queries 1: ' + Limits.getQueries());
 
        lead = prepareLead('Smith', 'WeWork Test Company', 'test1@example.com', null);
        lead.Company = 'Test Company';
        lead.LeadSource = 'Broker';
      	lead.Lead_Source_Detail__c = 'Broker1';
        lead.OwnerId = testGroup.Id;
      	lead.Generate_Journey__c = true;
        insert lead;
     	journeys = [Select Id, Primary_Contact__c From Journey__c];
        System.assertEquals(5,journeys.size());
        Test.stopTest();
    }
    
    //Test mehtod for leads assined to  queue
    static testMethod void testConvertLeadAssignedToQueue(){
    	initFieldMappings();
        Lead lead;
    	Contact contact;
        Journey__c[] journeys;
        Lead[] leads;
        Task[] tasks;
        //Check if lead owner is queue if yes and Lead source and lead source details condition satisfy create journey and activity.
        Group testGroup = [Select Id,Name from Group where Name = 'Test Lead Queue' and Type = 'Queue'];
        lead = prepareLead('Smith', 'WeWork Test Company', 'testLead1@example.com', null);
        lead.Company = 'Test Company';
        lead.LeadSource = 'Broker';
      	lead.Lead_Source_Detail__c = 'Broker1';
     	lead.Generate_Journey__c = true;
        lead.OwnerId = testGroup.Id;
        insert lead;
        journeys = [Select Id, Primary_Contact__c From Journey__c];
        System.assertEquals(1,journeys.size());
        tasks = [Select Id from Task where whoId =:lead.Id];
        System.assertEquals(1,tasks.size());
        Test.startTest();
        //Check if contact exist and use the same contact and convert the lead get created with same email id and should not create joureny because before contact creation 
        //OwnerId get changed and it is no user from json settings and convert the lead because contact with same email is alredy exist
        contact = [Select Id from Contact where Email = 'test1@example.com'];
        Debug.Log('# of Queries 1: ' + Limits.getQueries());
        lead = prepareLead('Smith', 'WeWork Test Company', 'test1@example.com', null);
        lead.Company = 'Test Company';
        lead.LeadSource = 'Broker';
      	lead.Lead_Source_Detail__c = 'Broker1';
      	lead.Generate_Journey__c = true;
        lead.OwnerId = testGroup.Id;
        insert lead;
     	journeys = [Select Id, Primary_Contact__c From Journey__c];
        System.assertEquals(1,journeys.size());
        tasks = [Select Id from Task where whoId =: contact.Id];
        System.assertEquals(1,tasks.size());
        leads = [select Id from lead where IsConverted = true];
		System.assertEquals(1,leads.size());
       
        //User is a queue but not added in json object only activity get created and not journey.
        testGroup = [Select Id,Name from Group where Name = 'Test Lead Queue1' and Type = 'Queue'];
        lead = prepareLead('Smith', 'WeWork Test Company', 'test1@example.com', null);
        lead.Company = 'Test Company';
        lead.LeadSource = 'Broker';
      	lead.Lead_Source_Detail__c = 'Broker1';
      	lead.Generate_Journey__c = true;
        lead.OwnerId = testGroup.Id;
        insert lead;
        journeys = [Select Id, Primary_Contact__c From Journey__c];
        System.assertEquals(1,journeys.size());
        tasks = [Select Id from Task];
        System.assertEquals(3,tasks.size());
        leads = [select Id from lead where IsConverted = true];
		System.assertEquals(2,leads.size());
		Test.stopTest();
    }
    
    
    
    @testSetup static void testContactCreation() {
	   //Check if contact exist and use the same contact and convert the lead get created with same email id and create journey and assign it to primary contact
        Contact contact = new Contact(LastName = 'test', Email = 'test@example.com');
        insert contact;
        System.assert(contact.Id != null);
        
        contact = new Contact(LastName = 'test', Email = 'test1@example.com');
        insert contact;
        System.assert(contact.Id != null);
	}

    
    
    static testMethod void testActivityForExistingLead(){
        initFieldMappings();
 		Lead lead;
        Set<Id> idsLead;
        Task[] tasks;
        
        lead = prepareLead('Smith', 'WeWork Test Company', 'john.smith@example.com', null);
        lead.Company = 'Test Company';
        lead.LeadSource = 'Broker';
        lead.Lead_Source_Detail__c = 'Broker1';
        lead.Generate_Journey__c = true;
        //lead.ownerId = testGroup.Id;
        insert lead;
        
        tasks = [select Id from task];
        system.assertEquals(1, tasks.size());
        lead = prepareLead('Smith', 'WeWork Test Company', 'john.smith@example.com', null);
        lead.Company = 'Test Company';
        lead.LeadSource = 'Broker';
        lead.Lead_Source_Detail__c = 'Broker1';
        lead.Generate_Journey__c = true;
        //lead.ownerId = testGroup.Id;
        insert lead;
        tasks = [Select Id from Task];
        system.assertEquals(2,tasks.size());
    }
    
    //This method is use to create account and contact from leads information if contact not exist
    
    static testmethod void testConvertLeadToContact(){
        initFieldMappings();
        list<Account> lstTestAccount = new list<Account>();
        list<Contact> lstTestContact = new list<Contact>();
        list<Journey__c> lstTestJourney = new list<Journey__c>();
        list<Lead> lstTestlead = new list<Lead>();
        LeadConvertor.DefaultJourneySettings();
        LeadConvertor.ContactResult[]  testContactResult;

        //Insert single lead
        list<string> lstTestEmails = new list<string>();
        Lead lead = prepareLead('Smith', 'WeWork Test Company', 'john.smith@example.com', null);
        lead.Generate_Journey__c = true;
        lead.Company = 'Test Company';
        insert lead;
        
        lead = prepareLead('Smith', 'WeWork Test Company', 'john.smith@example.com', null);
        lead.Company = 'Test Company';
        lead.Generate_Journey__c = true;
        insert lead;
        
        //Insert contact and convert existing lead to contact
        Contact c1 = new Contact(FirstName = 'Test',
                                LastName = 'Contact1',
                                //AccountId = acc.Id,
                                Email = 'john.smith@example.com',
                                Phone = '3256987425');
        insert c1;
        
        list<contact> testLstContact = [select Id,Name from contact];
        System.assert(testLstContact.size() == 3);
        System.assert(lead.Id != null);
        lstTestEmails.add(lead.Email);
        testContactResult = LeadConvertor.ConvertLeadsToContact(lstTestEmails);
        list<Lead> lstTestLeads = [Select Id, Name, isConverted from Lead where isConverted = true];
        system.assertEquals(lstTestLeads.size(),1);
        lstTestAccount = [Select Id, Name from Account];
        system.assertEquals(lstTestAccount.size(),2);
        Test.startTest();
        lead = prepareLead('Smith', 'WeWork Test Company', 'john.smith1@example.com', null);
        lead.Generate_Journey__c = true;
        lead.Company = 'Test Company';
        insert lead;
        
        Journey__c testObjJourney = new Journey__c();
        testObjJourney.Name = Lead.LastName;
        testObjJourney.Primary_Lead__c = Lead.Id;
        testObjJourney.NMD_Next_Contact_Date__c = Date.today();
        insert testObjJourney;
        lstTestJourney = [select Id,Name from Journey__c where Primary_Lead__c =: lead.Id];
        System.assert(lstTestJourney.size() == 1);
        
        lstTestEmails = new list<string>();
        lstTestEmails.add(lead.Email);
                //Lead With Journey
        c1 = new Contact(FirstName = 'Test',
                                LastName = 'Contact1',
                                //AccountId = acc.Id,
                                Email = 'john.smith1@example.com',
                                Phone = '3256987425');
        insert c1;
        
        testContactResult = LeadConvertor.ConvertLeadsToContact(lstTestEmails);
        
        lstTestJourney = [select Id,Name from Journey__c where Primary_Contact__c =: c1.Id];
        System.assert(lstTestJourney.size() == 1);
        Test.stopTest();
    }

}