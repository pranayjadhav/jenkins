/*
* @ Created By : Anant Kumar
* @ Created Date : 15 Mar 2016
*/
@isTest
private class WeworkEngineTest {
    static testMethod void testWeworkEngine(){
        Account accRec = TestingUtility.createAccount('strAccountName', true);
        String strQuery = 'SELECT Id FROM Account WhERE Id= \'' + accRec.Id + '\'';
        WeworkEngine engineObj = new WeworkEngine();
        System.assertEquals(accRec.Id, WeWorkEngine.Query(strQuery)[0].Id);
        System.assertEquals(UserInfo.getUserId(), WeWorkEngine.GetLoggedInUserInfo().Id);
        System.assertEquals(true, WeWorkEngine.fetchObjectFields('Account', 'AccountSource').size() > 0);
        
    }
    static testMethod void verifySaveRecords(){
        List<Account> lstAccount = new List<Account>();
        lstAccount.add(new Account(Name = 'Test'));
        List<SaveResult> saveResult = WeworkEngine.SaveRecords(lstAccount);
        System.assert(saveResult[0].IsSuccess); 
        
        List<SObject> lstSObject = new List<SObject>();
        lstSObject.add(new Account());
        List<SaveResult> nullSaveResult = WeworkEngine.SaveRecords(lstSObject);
        System.assertEquals(true,saveResult[0].IsSuccess);
    }
    static testMethod void verifyDeleteRecords(){
        List<Account> lstAccount = new List<Account>();
        lstAccount.add(new Account(Name = 'Test'));
        List<SaveResult> saveResult = WeworkEngine.SaveRecords(lstAccount);
        System.assert(saveResult[0].IsSuccess);
        saveResult = WeworkEngine.SaveRecords(lstAccount);
        System.assert(saveResult[0].IsSuccess);
        List<Database.DeleteResult>  deleteResult = WeworkEngine.DeleteRecords(new List<Id>{saveResult[0].Id});
        System.assert(deleteResult[0].isSuccess());
        List<Database.DeleteResult>  deleteResultNull = WeworkEngine.DeleteRecords(new List<Id>());
    }
    static testMethod void verifyGetAllFields(){
        WeworkEngine.GetAllFields('Lead');
        //System.assertEquals(false, fieldResults.isEmpty());
    }
    static testMethod void verifyGetUserName(){
        String strUserName = WeworkEngine.getUserName();
        System.assertEquals(strUserName, UserInfo.getName());
    }

    static testMethod void verifyGetSettings(){
        Setting__c settings = new Setting__c(Name = 'Test Settings');
        insert Settings;
        Setting__c objSettings = WeworkEngine.getSettings(Settings.Id);
    }

    static testMethod void verifyLoadAvailableTimes(){
        Building__c b = new Building__c(
            City__c = 'Test City',
            Name = 'Test Building',
            CurrencyIsoCode = 'USD',
            Time_Zone__c = 'America/New_York'
        );
        insert b;
        
        Tour_Schedule__c tour_Schedule = new Tour_Schedule__c(
            Building__c = b.Id,
            Simultaneous_Tours__c = '2',
            Tour_Spacing__c = 'Hour',
            Product_Line__c = 'WeWork',
            Maximum_Tour_Days__c = 1
        );
        insert tour_Schedule;
        
        insert new Tour_Open_Hour__c[]{
            new Tour_Open_Hour__c(
                weekday__c = 'Monday',
                start_time__c = '8:00AM',
                end_time__c = '8:00PM',
                Building__c = b.Id,
                Tour_Schedule__c = tour_Schedule.id
            ),
                new Tour_Open_Hour__c(
                    weekday__c = 'Tuesday',
                    start_time__c = '8:00AM',
                    end_time__c = '8:00PM',
                    Building__c = b.Id,
                    Tour_Schedule__c = tour_Schedule.id
                ),
                new Tour_Open_Hour__c(
                    weekday__c = 'Wednesday',
                    start_time__c = '8:00AM',
                    end_time__c = '8:00PM',
                    Building__c = b.Id,
                    Tour_Schedule__c = tour_Schedule.id
                ),
                new Tour_Open_Hour__c(
                    weekday__c = 'Thursday',
                    start_time__c = '8:00AM',
                    end_time__c = '8:00PM',
                    Building__c = b.Id,
                    Tour_Schedule__c = tour_Schedule.id
                ),
                new Tour_Open_Hour__c(
                    weekday__c = 'Friday',
                    start_time__c = '8:00AM',
                    end_time__c = '8:00PM',
                    Building__c = b.Id,
                    Tour_Schedule__c = tour_Schedule.id
                ),
                new Tour_Open_Hour__c(
                    weekday__c = 'Saturday',
                    start_time__c = '8:00AM',
                    end_time__c = '8:00PM',
                    Building__c = b.Id,
                    Tour_Schedule__c = tour_Schedule.id
                ),
                new Tour_Open_Hour__c(
                    weekday__c = 'Sunday',
                    start_time__c = '8:00AM',
                    end_time__c = '8:00PM',
                    Building__c = b.Id,
                    Tour_Schedule__c = tour_Schedule.id
                )      
                };
           WeworkEngine.loadAvailableTimes(Date.today().addDays(1),b.Id,'WeWork','America/New_York');              
     }
     
    static testMethod void verifyGetBuildingList(){
        List<Building__c> lstBuilding = new List<Building__c>();
        lstBuilding.add(new Building__c(City__c = 'Amsterdam', Country__c = 'Netherlands',Name = 'AMS-Metropool', CurrencyIsoCode = 'USD',Time_Zone__c = 'Europe/Amsterdam'));
        lstBuilding.add(new Building__c(City__c = 'Brooklyn',Country__c = 'USA',Name = 'BKN-Brooklyn Heights',CurrencyIsoCode = 'USD',Time_Zone__c = 'America/New_York'));
        lstBuilding.add(new Building__c(City__c = 'Berlin Mitte',Country__c = 'Germany',Name = 'BL-Sony Center',CurrencyIsoCode = 'USD',Time_Zone__c = 'America/New_York'));
        lstBuilding.add(new Building__c(City__c = 'Amsterdam',Country__c = 'USA',Name = 'AMS-Labs',CurrencyIsoCode = 'USD',Time_Zone__c = 'America/New_York'));
        lstBuilding.add(new Building__c(City__c = 'Chicago',Country__c = 'USA',Name = 'CHI-River North',CurrencyIsoCode = 'USD',Time_Zone__c = 'America/Chicago'));
        List<SaveResult> saveResult = WeworkEngine.SaveRecords(lstBuilding);
 
        Tour_Schedule__c tour_Schedule = new Tour_Schedule__c(
            Building__c = saveResult[0].Id,
            Simultaneous_Tours__c = '2',
            Tour_Spacing__c = 'Hour',
            Product_Line__c = 'WeWork',
            Maximum_Tour_Days__c = 1
        );
        insert tour_Schedule;
        WeworkEngine.getBuildingList('WeWork');              
     }
    
    static testMethod void verifyReScheduleTours(){
        Date thisDate = Date.today();
        Building__c b = new Building__c(City__c = 'Amsterdam', Country__c = 'Netherlands',Name = 'AMS-Metropool', CurrencyIsoCode = 'USD',Time_Zone__c = 'Europe/Amsterdam');
        insert b;
        Tour_Schedule__c tour_Schedule = new Tour_Schedule__c(
            Building__c = b.Id,
            Simultaneous_Tours__c = '2',
            Tour_Spacing__c = 'Hour',
            Product_Line__c = 'WeWork',
            Maximum_Tour_Days__c = 1
        );
        insert tour_Schedule;
        
        insert new Tour_Open_Hour__c[]{
            new Tour_Open_Hour__c(
                weekday__c = 'Monday',
                start_time__c = '8:00AM',
                end_time__c = '8:00PM',
                Building__c = b.Id,
                Tour_Schedule__c = tour_Schedule.id
            ),
                new Tour_Open_Hour__c(
                    weekday__c = 'Tuesday',
                    start_time__c = '8:00AM',
                    end_time__c = '8:00PM',
                    Building__c = b.Id,
                    Tour_Schedule__c = tour_Schedule.id
                ),
                new Tour_Open_Hour__c(
                    weekday__c = 'Wednesday',
                    start_time__c = '8:00AM',
                    end_time__c = '8:00PM',
                    Building__c = b.Id,
                    Tour_Schedule__c = tour_Schedule.id
                ),
                new Tour_Open_Hour__c(
                    weekday__c = 'Thursday',
                    start_time__c = '8:00AM',
                    end_time__c = '8:00PM',
                    Building__c = b.Id,
                    Tour_Schedule__c = tour_Schedule.id
                ),
                new Tour_Open_Hour__c(
                    weekday__c = 'Friday',
                    start_time__c = '8:00AM',
                    end_time__c = '8:00PM',
                    Building__c = b.Id,
                    Tour_Schedule__c = tour_Schedule.id
                ),
                new Tour_Open_Hour__c(
                    weekday__c = 'Saturday',
                    start_time__c = '8:00AM',
                    end_time__c = '8:00PM',
                    Building__c = b.Id,
                    Tour_Schedule__c = tour_Schedule.id
                ),
                new Tour_Open_Hour__c(
                    weekday__c = 'Sunday',
                    start_time__c = '8:00AM',
                    end_time__c = '8:00PM',
                    Building__c = b.Id,
                    Tour_Schedule__c = tour_Schedule.id
                )      
                };
   
        list<Tour_Outcome__c> listTourOutcome1 = new list<Tour_Outcome__c>();
        	listTourOutcome1.add(new Tour_Outcome__c(Tour_Date__c = thisDate,Location__c = b.Id,Start_Time__c = '4:00PM',End_Time__c = '7:00PM'));
        list<Tour_Outcome__c> listTourOutcome2 = new list<Tour_Outcome__c>();
        	listTourOutcome2.add(new Tour_Outcome__c(Tour_Date__c = thisDate,Location__c = b.Id,Start_Time__c = '18:30PM',End_Time__c = '7:30PM'));  
        list<Tour_Outcome__c> listTourOutcome3 = new list<Tour_Outcome__c>();
        	listTourOutcome3.add(new Tour_Outcome__c(Start_Time__c = '18:30PM',End_Time__c = '7:30PM'));    
        WeworkEngine.reScheduleTours(listTourOutcome1,listTourOutcome2);  
        WeworkEngine.reScheduleTours(listTourOutcome1,null); 
        WeworkEngine.reScheduleTours(listTourOutcome3,listTourOutcome3); 
     }
    
    static testMethod void verifyCreateJourneryAndJourneyContact_1(){
		//Insert Account
		Account acc = new Account(Name = 'Test Account');
		insert acc;
        
		//Insert two contacts
		Contact c1 = new Contact(FirstName = 'Test',
								LastName = 'Contact1',
                                Email = 'testContact1@example.com',
								AccountId = acc.Id,
								Phone = '3256987425');
		insert c1;
		Contact c2 = new Contact(FirstName = 'Test',
								LastName = 'Contact2',
								AccountId = acc.Id,
                                Email = 'testContact2@example.com',
								Phone = '3256987455',
								LeadSource = 'Inbound Call');
		insert c2;
		
		Building__c tesBuilding = new Building__c(Name = 'NYC-Wall Street',
								CurrencyIsoCode = 'USD');
		insert tesBuilding;
		
      
		WeworkEngine.createJourneryAndJourneyContact(c2.Id, c2.LeadSource, tesBuilding.Id, false);
    } 
    
    static testMethod void verifyCreateJourneryAndJourneyContact_2(){
		//Insert Account
		Account acc = new Account(Name = 'Test Account');
		insert acc;
        
		//Insert two contacts
		Contact c1 = new Contact(FirstName = 'Test',
								LastName = 'Contact1',
								AccountId = acc.Id,
                                Email = 'testContact3@example.com',
								Phone = '3256987425');
		insert c1;
		Contact c2 = new Contact(FirstName = 'Test',
								LastName = 'Contact2',
								AccountId = acc.Id,
                                Email = 'testContact4@example.com',
								Phone = '3256987455',
								LeadSource = 'Inbound Call');
		insert c2;
		
		Building__c tesBuilding = new Building__c(Name = 'NYC-Wall Street',
								CurrencyIsoCode = 'USD');
		insert tesBuilding;
      
		WeworkEngine.createJourneryAndJourneyContact(c2.Id, c2.LeadSource, tesBuilding.Id, true);
    } 

    static testMethod void verifyAddBusinessDays(){
    	Date resultDate = WeworkEngine.addBusinessDays('10/05/2016', 1);
    	
    }
    
    static testMethod void verifyGetNextBussinessDays(){
    	Date resultDate = WeworkEngine.getNextBusinessDay('02/10/2016');
    	
    }

    static testMethod void verifyGetLeadsToJourneys(){
    		
			Lead lead = new Lead(
                FirstName = 'Test', 
                LastName = 'Test',
                Company = 'Test',
                Email = 'Test111@example.com',
                LeadSource = 'other',
                Status = 'TestStatus',
                CurrencyIsoCode = 'USD'
    		);
    		
    		insert lead;
    		
    		list<ID> lstIds = new list<ID>();
    		Lead lead1 = [SELECT Id FROM Lead WHERE Id=:lead.Id];
    		Id id1 = lead1.Id;
    		lstIds.add(id1);
        	//Before convert lead
    		WeworkEngine.getLeadsToJourneys(lstIds);
        
        	//After Convert lead other condition
        	WeworkEngine.getLeadsToJourneys(lstIds);
    }
    
    static testMethod void verifyFetchObjectFields(){
    	Account accRec = TestingUtility.createAccount('strAccountName', true);
			accRec.Name = 'Test';
	    	update accRec;
	    	
	    	Contact newContact1 = new Contact();
    	 	newContact1.AccountId = accRec.Id;
    	 	newContact1.firstname = 'TestFirstName';
    	 	newContact1.lastname = 'TestLastName';
         	newContact1.Email = 'Test11@example.com';
         	newContact1.Status__c = 'active';
         	newContact1.Convert_Lead__c = true;
         	
            insert newContact1;
    		
    	WeworkEngine.fetchObjectFields('Contact','Email');
    
    }
    
    static testMethod void verifyConstructSobject(){
    	
		String jsonStr = '{"Name":"John", "lastName":"Doe"}';
		//String jsonstring = Json.serialize(jsonStr); 
 		WeworkEngine.ConstructSobject('Name',jsonStr);
    } 
    
    static testMethod void testDeleteRecord(){
    	String jsonStr = '{"Name":"John", "lastName":"Doe"}';
    	WeworkEngine.DeleteRecord('Name',jsonStr);
    }

    static testMethod void testGetTypedSetings(){
		Test.startTest();
        MySettings settingsMy = new MySettings();
        settingsMy.count = 10;
        settingsMy.timestamp = Date.today();
        settingsMy.name = 'Test';
        
        Setting__c setting = new Setting__c( Name = 'Test', Data__c = JSON.serialize(settingsMy));
        insert setting;
        
        Setting__c settingsNew = WeworkEngine.getSettingsRecord('Test');
        System.assert(settingsNew.Data__c != null);
        System.assert(settingsMy.Name == 'Test');
		Test.stopTest();
    }
    
	public class MySettings {
        Integer count;
        Date timestamp;
        String name;
    }

	static testMethod void testExtendReference(){
		Test.startTest();
    	Account accRec = TestingUtility.createAccount('strAccountName', true);
        Contact referrer1 = new Contact();
        referrer1.LastName = 'referrer1';
        referrer1.Email = 'referrer1@example.com';
        TestingUtility.insertWithAssert(referrer1);
        
        Contact referrer2 = new Contact();
        referrer2.LastName = 'referrer1';
        referrer2.Email = 'referrer2@example.com';
        TestingUtility.insertWithAssert(referrer2);
        
        Reference__c reference1 = new Reference__c();
        reference1.Referenced_Email__c = 'reference1@example.com';
        reference1.IsActive__c = true;
        reference1.Referrer__c = referrer1.Id;
        reference1.Expires_On__c = Date.today().addDays(10);
        TestingUtility.insertWithAssert(reference1);
        
        Reference__c reference2 = new Reference__c();
        reference2.Referenced_Email__c = 'reference2@example.com';
        reference2.IsActive__c = false;
        reference2.Referrer__c = referrer1.Id;
        reference2.Expires_On__c = Date.today().addDays(10);
        TestingUtility.insertWithAssert(reference2);

    	WeworkEngine.extendReference(reference1.Id,Date.today());
		Reference__c assertReference = [Select Id,Name,Referenced_Email__c,Expires_On__c,Referrer__r.Name,Referrer_Email__c From Reference__c where Id =:reference1.Id ];

		System.assertEquals(assertReference.Expires_On__c , Date.today().addDays(60));
		Test.stopTest();
    }


    //For method createActivityForTour 
    static testMethod void verifyCreateActivityForTour(){
        Account accRec = TestingUtility.createAccount('strAccountName', true);
			accRec.Name = 'TestAccount';
	    	update accRec;
        
        Contact newContact2 = new Contact();
    	 	newContact2.AccountId = accRec.Id;
    	 	newContact2.firstname = 'TestFirstName';
    	 	newContact2.lastname = 'TestLastName';
         	newContact2.Email = 'Test111@example.com';
        	newContact2.Phone = '9874563210';
         	newContact2.Status__c = 'active';
         	newContact2.Convert_Lead__c = true;
         	insert newContact2;
        
        Task newTask = new Task();
            Date activityDate = Date.newInstance(2016, 10, 13);
            newTask.ActivityDate = activityDate;
            newTask.Product_Line__c = 'WeWork';
        
        List<Task> lstTask = new List<Task>();
        lstTask.add(newTask);
        
        WeworkEngine.createActivityForTour(newContact2.Id,'',lstTask);
            
    }

    /*
    * @ Created By : 	Mayuresh Ghodke
    * @ Created Date : 	27-07-2016
    */
    static testMethod void testChangeLeadRecordType(){
    	TriggerSettings.TriggersMappedField triggerSetting = TriggerSettings.get();
    	triggerSetting.Lead_CreateDeleteBuildingInterest = false;
       	  	        
        Lead lead1 = new Lead(
            FirstName = 'Test', 
            LastName = 'Test',
            Company = 'Test',
            Email = 'Test1@example.com',
            LeadSource = 'other',
            Status = 'TestStatus',
            CurrencyIsoCode = 'USD'
        );
        insert lead1;
        
        String resultNeg1 = WeworkEngine.changeLeadRecordType(lead1.Id);
        System.assertEquals(resultNeg1, 'Please update Company Size to submit to Enterprise Solution Team');
        
        Lead lead2 = new Lead(
            FirstName = 'Test', 
            LastName = 'Test',
            Company = 'Test',
            Email = 'Test2@example.com',
            LeadSource = 'other',
            Status = 'TestStatus',
            CurrencyIsoCode = 'USD',
            Company_Size__c = '5-10'
            
        );
        insert lead2;
        
        String resultNeg2 = WeworkEngine.changeLeadRecordType(lead2.Id);
        System.assertEquals(resultNeg2, 'Company Size is less than 15 desk. Unable to submit to Enterprise Solution Team');
        
        Lead lead3 = new Lead(
            FirstName = 'Test', 
            LastName = 'Test',
            Company = 'Test',
            Email = 'Test3@example.com',
            LeadSource = 'other',
            Status = 'TestStatus',
            CurrencyIsoCode = 'USD',
            Company_Size__c = '5-20'
        );
        insert lead3;
        
        Test.startTest();     
        String resultNeg3 = WeworkEngine.changeLeadRecordType(lead3.Id);
        System.assertEquals(resultNeg3, 'Lead is submitted to Enterprise Solution Team successfully');
        
        List<Group> lstOwnerInfo = new List<Group>();
        lstOwnerInfo = [select Id From Group where Name = 'Enterprise Queue'];
        
        Lead lead4 = new Lead(
            FirstName = 'Test', 
            LastName = 'Test',
            Company = 'Test',
            Email = 'Test4@example.com',
            LeadSource = 'other',
            Status = 'TestStatus',
            CurrencyIsoCode = 'USD',
            Company_Size__c = '6-20',
            OwnerId = lstOwnerInfo[0].Id
        );
        insert lead4;
        
        String result4 = WeworkEngine.changeLeadRecordType(lead4.Id);
        System.assertEquals(result4, 'Lead is submitted to Enterprise Solution Team successfully');
               
        List<RecordType> lstRecordType = new List<RecordType>();
        lstRecordType = [select Id from RecordType where Name = 'Default' and sObjectType = 'Lead'];
        
        Lead lead5 = new Lead(
            FirstName = 'Test', 
            LastName = 'Test',
            Company = 'Test',
            Email = 'Test5@example.com',
            LeadSource = 'other',
            Status = 'TestStatus',
            CurrencyIsoCode = 'USD',
            Company_Size__c = '6-20',
            RecordTypeId = lstRecordType[0].Id            
        );
        insert lead5;
        
        String result5 = WeworkEngine.changeLeadRecordType(lead5.Id);
        System.assertEquals(result5, 'Lead is submitted to Enterprise Solution Team successfully');        
        String resultNeg5 = WeworkEngine.changeLeadRecordType(lead5.Id);
        System.assertEquals(resultNeg5, 'Lead is already submitted to Enterprise Solution Team');               
       Test.stopTest();
       triggerSetting.Lead_CreateDeleteBuildingInterest = true;
    }
}