/**
 * Test methods for different Task triggers
 * 
 * @author  RamseySolutions
 * @date    18/01/2016
 */
@isTest
private class TaskTriggersTest {
  
    /*static void initFieldMappings() {
        List<Setting__c> settings = new List<Setting__c>();
        settings.add(new Setting__c(Name = 'FieldMappings:LeadToContact', Data__c = '{"LastName": {"name": "LastName", "overwrite": true}, "Email" : {"name":"Email", "overwrite": true}}'));
        settings.add(new Setting__c(Name = 'FieldMappings:LeadToJourney', Data__c = '{"LastName": {"name":"Name", "overwrite": true}, "LeadSource": {"name":"Lead_Source__c", "overwrite": true}}'));
        settings.add(new Setting__c(Name = 'FieldMappings:LeadToActivity', Data__c = '{"LeadSource": {"name":"Lead_Source__c", "overwrite": true}}'));
        LeadTriggers.JourneySettings settingJourney = new LeadTriggers.JourneySettings();
        settingJourney.NextCallInDaysFromLeadCreation = 2;
        settingJourney.NewLeadActivityFields = null;
        settingJourney.NewJourneyFields = null;
        
        settings.add(new Setting__c(Name = 'Journey', Data__c = JSON.serialize(settingJourney)));
        insert settings;
    }
    */
    
    static Boolean settingsInitialized = false;
    static LeadConvertor.JourneySettings settingJourney;

    static void initFieldMappings() {
    	Debug.turnDebugOn();

        if( settingsInitialized )
            return;
        
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
        Debug.log('leadToJourneyMappings:'+leadToJourneyMappings); 
         
    	Settings.FieldMappings leadToActivityMappings = new Settings.FieldMappings();
        leadToActivityMappings.version = 1;
        leadToActivityMappings.mappings = new Map<String, Settings.MappedField>();
        leadToJourneyMappings.mappings.put('Lead_Source__c', new Settings.MappedField('LeadSource'));
    	Settings.saveFieldMappings( 'LeadToActivity', leadToActivityMappings);

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
       
        settingsInitialized = true;
    }
    
 		static testMethod void testUpdateLeadEngagementFields() {
        //initFieldMappings();
        Lead l = new Lead(FirstName = 'Test', LastName = 'Test', Company = 'Test',Phone = '1236547890',Email = 'samsung@example.com' );
        insert l;
        
        Task t = new Task(WhoId = l.Id, Subject = 'Engage Campaign:');
        insert t;
       
        l = [select Engage_Emails_Sent__c, Last_Engage_Email_Sent__c from Lead where Id = :l.Id];
        t = [select CreatedDate from Task where Id = :t.Id];
        
        System.assertEquals(1, l.Engage_Emails_Sent__c);
        System.assertEquals(t.CreatedDate, l.Last_Engage_Email_Sent__c);
    }
     /**
     * Test method for update stage field trigger
     * 
     * @author  Samadhan Kadam
     * @date    17/05/2016
     */
    static testMethod void testupdateJourneyStageField() {
      	/*Triggers__c triggers = new Triggers__c(Name= 'Triggers');
      	triggers.Update_Journey_Stage_To_CompletedLost__c = true;
      	upsert triggers;*/
      
     	Account accRec = new Account();
    	accRec.Name='Test Account' ;
    	insert accRec;
    
       	Contact conRec1 = new Contact();
       	conRec1.AccountId = accRec.Id;
       	conRec1.firstname = 'TestFirstName';
       	conRec1.lastname = 'TestLastName';
        conRec1.Email = 'Test111@example.com';
        conRec1.Status__c = 'active';
      
        insert conRec1;
      
      	Setting__c testSettings = new Setting__c();
        testSettings.Name = 'JourneySettings';
        testSettings.Data__c = '[{"CallResult":"Left VM","NextDate":"3"},{"CallResult":"No Answer/Busy","NextDate":"1"}]';
        TestingUtility.insertWithAssert(testSettings);
        
        testSettings = new Setting__c();
        testSettings.Name = 'LeadJourneyTrigger';
        testSettings.Data__c = '[{"LeadStatus":"Unqualified","JourneyStage":"Completed-Lost"}]';
        TestingUtility.insertWithAssert(testSettings);
        
        Setting__c testSettings2 = new Setting__c();
        testSettings2.Name = 'QueueManagementSettings';
        testSettings2.Data__c = '{"excludeprofiles":"","status":["Completed"],"types":["Call","Phone","Email"],"excludesubjects":["Inbound Lead submission"]}';
        TestingUtility.insertWithAssert(testSettings2);
        
        Lead l = new Lead(FirstName = 'Test', LastName = 'Test', Company = 'Test',Phone ='7894562359',Email='herohonda@example.com');
        insert l;
      
     	Journey__c newTestJourney = new Journey__c();
      	newTestJourney.Name = 'Test Samadhan';
      	newTestJourney.Stage__c = 'Started';
      	newTestJourney.Primary_Contact__c = conRec1.Id;
      	newTestJourney.NMD_Next_Contact_Date__c = Date.today();
      	insert newTestJourney;
      	
      
      	Task testTask = new Task(Status = 'Not Started',Priority = 'Normal',Subject = 'Call',whatId  = newTestJourney.Id);
      	insert testTask; 
      
      	testTask.CallDisposition = 'Do Not Call'; 
      	update testTask;
      
      	journey__c journey = [SELECT Id, Stage__c FROM Journey__c WHERE Id=:newTestJourney.Id];
        system.assertEquals('Completed-Lost',journey.Stage__c);
      
      }
      
    //Created By : Amol Darekar
    //Created Date : 19-05-2016
    //Purpose : Written to cover senarios for ST:297 and ST:298
    static testMethod void testUpdateNextNMDContactDateOnJourney() 
    {
        Account accRec = new Account();
      	accRec.Name='Test Account' ;
      	insert accRec;
        
        Contact conRec1 = new Contact();
        conRec1.AccountId = accRec.Id;
        conRec1.firstname = 'TestFirstName';
        conRec1.lastname = 'TestLastName';
        conRec1.Email = 'Test111@example.com';
        conRec1.Status__c = 'active';
        
        insert conRec1;
        
        /*Triggers__c triggers = new Triggers__c(Name= 'Triggers');
        triggers.Task_Call_Result_Update_Journey_NMD_Date__c = true;
        triggers.Update_Task_Due_Date_From_Journey_NMD__c = true;
        upsert triggers;*/
        
        Setting__c testSettings = new Setting__c();
        testSettings.Name = 'JourneySettings';
        testSettings.Data__c = '[{"CallResult":"Left VM","NextDate":"3"},{"CallResult":"No Answer/Busy","NextDate":"1"}]';
        TestingUtility.insertWithAssert(testSettings);
          
        testSettings = new Setting__c();
        testSettings.Name = 'LeadJourneyTrigger';
        testSettings.Data__c = '[{"LeadStatus":"Unqualified","JourneyStage":"Completed-Lost"}]';
        TestingUtility.insertWithAssert(testSettings);
          
        Setting__c testSettings2 = new Setting__c();
        testSettings2.Name = 'QueueManagementSettings';
        testSettings2.Data__c = '{"excludeprofiles":"","status":["Completed"],"types":["Call","Phone","Email"],"excludesubjects":["Inbound Lead submission"]}';
        TestingUtility.insertWithAssert(testSettings2);
            
        list<Journey__c> lstTestJourny = new list<Journey__c>();
         set<Id> setJourneyWhatIds = new set<Id>(); 
         
        Journey__c objTestJourny1 = new Journey__c();
        objTestJourny1.Name = 'Test Customer1';
        objTestJourny1.Stage__c = 'Started';
        objTestJourny1.Primary_Contact__c = conRec1.Id;
        objTestJourny1.NMD_Next_Contact_Date__c =Date.today();
      	TestingUtility.insertWithAssert(objTestJourny1);
      
      	Task testTask = new Task();
      	testTask.Type = 'Call';
      	testTask.Subject = 'Follow-Up';
      	testTask.TaskSubtype = 'Task';
      	testTask.Status = 'In Progress';
      	testTask.Priority = 'Normal';
      	testTask.whatId = objTestJourny1.Id;
      	testTask.CallDisposition = 'Left VM';
      	Date before_60_days = Date.Today().addDays(-14);
      	testTask.ActivityDate = before_60_days;
      	TestingUtility.insertWithAssert(testTask);
      	testTask.Status = 'Not Started';
      	TestingUtility.updateWithAssert(testTask);
      
      	setJourneyWhatIds.add(testTask.whatId);
      	Debug.log('SetofWhatIds*******************'+setJourneyWhatIds.size());

      	Task testTask1 = new Task();
      	testTask1.Type = 'Call';
      	testTask1.TaskSubtype = 'Task';
      	testTask1.whatId = objTestJourny1.Id;
      	testTask1.Priority = 'Normal';
      	testTask1.CallDisposition = 'Call in one week';
      	testTask1.Status = 'In Progress';
      	TestingUtility.insertWithAssert(testTask1);
      	testTask1.Status = 'In Progress';
     	TestingUtility.updateWithAssert(testTask1);
      
      	Task testTask3 = new Task();
      	//testTask3.Type = 'Call';
      	testTask3.TaskSubtype = 'Task';
      	testTask3.whatId = objTestJourny1.Id;
      	testTask3.Status = 'Deferred';
      	testTask3.Priority = 'Normal';
      	testTask3.CallDisposition = 'Call in one week';
      	testTask3.Status = 'In Progress';
      	TestingUtility.insertWithAssert(testTask3);
      	TestingUtility.updateWithAssert(testTask3);
      
      	Journey__c objTestJourny2 = new Journey__c();
        objTestJourny2.Name = 'Test Customer1';
        objTestJourny2.Stage__c = 'Started';
        objTestJourny2.Primary_Contact__c = conRec1.Id;
        objTestJourny2.NMD_Next_Contact_Date__c = Date.today().addDays(-2);
      	TestingUtility.insertWithAssert(objTestJourny2);
      
      	Task testTask4 = new Task();
      	testTask4.Type = 'Call';
      	testTask4.TaskSubtype = 'Task';
      	testTask4.whatId = objTestJourny2.Id;
      	testTask4.Status = 'Not Started';
      	testTask4.Priority = 'Normal';
      	testTask4.CallDisposition = 'Call in one week';
      	TestingUtility.insertWithAssert(testTask4);
      	testTask4.Status = 'In Progress';
      	TestingUtility.updateWithAssert(testTask4);
      
      	Task testTask5 = new Task();
      	testTask5.Type = 'Call';
      	testTask5.TaskSubtype = 'Task';
      	testTask5.whatId = objTestJourny2.Id;
      	testTask5.Status = 'Not Started';
     	testTask5.Priority = 'Normal';
      	testTask5.CallDisposition = 'No Answer/Busy';
      	TestingUtility.insertWithAssert(testTask5);
      	testTask5.Status = 'Completed';
      	TestingUtility.updateWithAssert(testTask5);
      }
    
    //Created By : Anant Kumar
    //Created Date : 13-06-2016
    //Purpose : ST-421
    static testMethod void testChangeTaskOwner(){
        set<Id> setWhatIds = new set<Id>();
        System.runAs(new User(Id=UserInfo.getUserId()))
        {
            Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
            User u2 = new User(Alias = 'newUser1', Email='newuser123@testorg.com', 
            		EmailEncodingKey='UTF-8', LastName='Testing123', LanguageLocaleKey='en_US', 
                 	LocaleSidKey='en_US', ProfileId = p.Id, 
                 	TimeZoneSidKey='America/Los_Angeles', UserName='newuser123@testorg.com');
        
            
            User testUser = TestUtility.createTestUser();
            Group group1 = new Group(Name='group name', type='Queue');
            insert group1;
            
            QueuesObject q1 = new QueueSObject(QueueID = group1.id, SobjectType = 'Lead');
            insert q1;
            
            QueuesObject q2 = new QueueSObject(QueueID = group1.id, SobjectType = 'Journey__c');
            insert q2;
            
            GroupMember member = new GroupMember();
            member.UserOrGroupId = testUser.Id;
            member.GroupId = group1.Id;
            insert member;
            
            System.runAs(testUser) {
                Lead lead1 = new Lead(OwnerId=q1.QueueID,FirstName = 'Test', LastName = 'Test', Company = 'Test',Phone = '9874563210',Email='honda@example.com');
                insert lead1;
               
                Account accRec = TestingUtility.createAccount('strAccountName', true);
                
                //Contact conRec1 = TestingUtility.createContact(accRec.Id, 'Contact1', true);
                
                Contact conRec1 = new Contact();
                conRec1.AccountId = accRec.Id;
                conRec1.firstname = 'TestFirstName';
                conRec1.lastname = 'TestLastName';
                conRec1.Email = 'Test120@example.com';
                conRec1.Status__c = 'active';
                
                insert conRec1; 
             
                Journey__c journey = new Journey__c();
                journey.Name = 'TestJourney';
                journey.NMD_Next_Contact_Date__c = Date.today();
                journey.Primary_Lead__c = lead1.Id;
        
                insert journey;
                
                Contact con =[select Id from Contact where Id=:conRec1.Id];
                debug.log('Contact Id ::'+con.Id);
                //Contact conRec2 = TestingUtility.createContact(accRec.Id, 'Contact2', true);
                
                Lead lead111 = [select Id,OwnerId,LastName from Lead where Id=:lead1.Id];
                debug.log('Lead ownerId and Id from Test Method '+lead111.OwnerId+' '+lead111.Id);
            
                Setting__c testSettings = new Setting__c();
                testSettings.Name = 'JourneySettings';
                testSettings.Data__c = '[{"CallResult":"Left VM","NextDate":"3"},{"CallResult":"No Answer/Busy","NextDate":"1"}]';
                TestingUtility.insertWithAssert(testSettings);
                
                testSettings = new Setting__c();
                testSettings.Name = 'LeadJourneyTrigger';
                testSettings.Data__c = '[{"LeadStatus":"Unqualified","JourneyStage":"Completed-Lost"}]';
                TestingUtility.insertWithAssert(testSettings);
                
                Setting__c testSettings2 = new Setting__c();
                testSettings2.Name = 'QueueManagementSettings';
                testSettings2.Data__c = '{"excludeprofiles":"","status":["Completed"],"types":["Call","Phone","Email"],"excludesubjects":["Inbound Lead submission"]}';
                insert testSettings2;
                
                list<Journey__c> lstTestJourny = new list<Journey__c>();
                set<Id> setWhoId = new Set<Id>();
                
                Journey__c objTestJourny1 = new Journey__c();
                objTestJourny1.Name = 'Test Customer1';
                objTestJourny1.Stage__c = 'Completed';
                objTestJourny1.Primary_Lead__c = lead111.Id;
                objTestJourny1.NMD_Next_Contact_Date__c = Date.today();
                objTestJourny1.OwnerId = q1.QueueID;
                TestingUtility.insertWithAssert(objTestJourny1);
                
                Journey__c objTestJourny2 = new Journey__c();
                objTestJourny2.Name = 'Test Customer1';
                objTestJourny2.Stage__c = 'Completed';
                objTestJourny2.Primary_Contact__c = conRec1.Id;
                objTestJourny2.NMD_Next_Contact_Date__c =Date.today();
                objTestJourny1.OwnerId = q1.QueueID;
                TestingUtility.insertWithAssert(objTestJourny2);
                
                Task testTask = new Task();
                testTask.whoId = conRec1.Id;
                testTask.Type = 'Call';
                testTask.Status = 'Started';
                testTask.Priority = 'Normal';
                testTask.whatId = objTestJourny1.Id;
                testTask.CallDisposition = 'Left VM';
                testTask.Subject = 'other';
                //TestingUtility.insertWithAssert(testTask);
                insert testTask;
                
                testTask.Status = 'Call';
                testTask.Subject = 'other';
                
                update testTask;
                
                Task testTask2 = new Task();
                testTask2.whoId = lead111.Id;
                testTask2.Type = 'Call';
                testTask2.Status = 'Started';
                testTask2.Priority = 'Normal';
                testTask2.CallDisposition = 'Left VM';
                testTask2.Subject = 'other';
                insert testTask2;
                                
                testTask2.Status = 'Completed';
                testTask2.Subject = 'Call';
                update testTask2;
                
                Task testTask3 = new Task();
                testTask3.whoId = conRec1.Id;
                testTask3.Type = 'Call';
                testTask3.Status = 'Started';
                testTask3.Priority = 'Normal';
                testTask3.whatId = objTestJourny2.Id;
                testTask3.CallDisposition = 'Left VM';
                testTask3.Subject = 'other';
                insert testTask3;
                
                testTask3.Status = 'Call';
                testTask3.Subject = 'other';
                
                update testTask3;
                
                Id currentUserId = testUser.Id;
                
                List<Lead> updatedLead = new List<Lead>([Select Id,OwnerId From Lead Where Id =: lead111.Id]);
                System.assertEquals(updatedLead[0].OwnerId, testUser.Id);
                
                List<Journey__c> updatedJourney = new List<Journey__c>([Select Id,OwnerId From Journey__c Where Id =: objTestJourny1.Id]);
                System.assertEquals(updatedJourney[0].OwnerId, testUser.Id);
            }
    	}
     }
    }