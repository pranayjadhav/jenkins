@isTest
private class TestScheduleTour {
    @isTest
    private static void testSuccesfulSchedule() {
        Building__c b = new Building__c(
            City__c = 'Test',
            Name = 'Test',
            Simultaneous_Tours__c = '2',
            Tour_Spacing__c = 'Half Hour',
            Maximum_Tour_Days__c = 1
        );
        insert b;
		
		Tour_Schedule__c tour_Schedule = new Tour_Schedule__c(
            Building__c = b.Id,
            Simultaneous_Tours__c = '2',
            Tour_Spacing__c = 'Hour',
            Maximum_Tour_Days__c = 1,
            Product_Line__c = 'WeWork'
        );
        insert tour_Schedule;
		
        insert new Tour_Open_Hour__c[]{
            new Tour_Open_Hour__c(
                weekday__c = 'Monday',
                start_time__c = '8:00AM',
                end_time__c = '8:00PM',
                Tour_Schedule__c = tour_Schedule.id,
                Building__c = b.id
            ),
            new Tour_Open_Hour__c(
                weekday__c = 'Tuesday',
                start_time__c = '8:00AM',
                end_time__c = '8:00PM',
                Tour_Schedule__c = tour_Schedule.id,
                Building__c = b.id
            ),
            new Tour_Open_Hour__c(
                weekday__c = 'Wednesday',
                start_time__c = '8:00AM',
                end_time__c = '8:00PM',
                Tour_Schedule__c = tour_Schedule.id,
                Building__c = b.id
            ),
            new Tour_Open_Hour__c(
                weekday__c = 'Thursday',
                start_time__c = '8:00AM',
                end_time__c = '8:00PM',
                Tour_Schedule__c = tour_Schedule.id,
                Building__c = b.id
            ),
            new Tour_Open_Hour__c(
                weekday__c = 'Friday',
                start_time__c = '8:00AM',
                end_time__c = '8:00PM',
                Tour_Schedule__c = tour_Schedule.id,
                Building__c = b.id
            ),
            new Tour_Open_Hour__c(
                weekday__c = 'Saturday',
                start_time__c = '8:00AM',
                end_time__c = '8:00PM',
                Tour_Schedule__c = tour_Schedule.id,
                Building__c = b.id
            ),
            new Tour_Open_Hour__c(
                weekday__c = 'Sunday',
                start_time__c = '8:00AM',
                end_time__c = '8:00PM',
                Tour_Schedule__c = tour_Schedule.id,
                Building__c = b.id
            )
        };
        
        Lead l = new Lead(FirstName = 'Test', LastName = 'Test', Company = 'Test', Email = 'test@test.com');
        insert l;

        PageReference pr = new PageReference('/apex/ScheduleTour');
        pr.getParameters().put('leadId', l.Id);
        pr.getParameters().put('product_line', l.Product_Line__c);
        Test.setCurrentPageReference(pr);
        
        ScheduleTour sc = new ScheduleTour();
        
        SelectOption[] cities = sc.getCityList();
        System.assertEquals(1, cities.size());
        System.assertEquals('Test', cities[0].getValue());
        
        sc.selectedCity = 'Test';
        sc.citySelected();
        
        SelectOption[] buildings = sc.getBuildingListForSelectedLocation();
        System.assertEquals(1, buildings.size());
        System.assertEquals(b.Id, buildings[0].getValue());
        
        sc.selectedBuilding = b.Id;
        sc.buildingSelected();
        
        Date thisDate = Date.today().addDays(1);
        
        // Date out of range
        sc.newTour.Tour_Date__c = thisDate.addDays(2);
        sc.dateSelected();
        System.assertEquals(null, sc.newTour.Tour_Date__c);
        
        // Correct date
        sc.newTour.Tour_Date__c = thisDate;
        sc.dateSelected();
        
        // Time out of range
        sc.selectedTime = '4:00AM';
        sc.timeSelected();
        System.assertEquals(null, sc.selectedTime);
        
        // Correct time
        sc.selectedTime = '8:00AM';
        sc.timeSelected();
        
        // Incorrect time again
        sc.selectedTime = '4:00AM';
        sc.confirmTour();
        System.assertEquals(null, sc.selectedTime);

        // Correct time, schedule tour
        sc.selectedTime = '8:00AM';
        
        TriggersFlags.allowTourUpdates = false;
        sc.confirmTour();
        
        Tour_Outcome__c[] tours = [select Id, Status__c, Lead__c, Location__c, Tour_Date__c, Start_Time__c, End_Time__c from Tour_Outcome__c];
        system.assertNotEquals(
            0,
            tours.size(),
            'a tour record should be created'
        );

        Tour_Outcome__c tour = tours[0];

        System.assertEquals(l.Id, tour.Lead__c);
        System.assertEquals(b.Id, tour.Location__c);
        System.assertEquals(thisDate, tour.Tour_Date__c);
        System.assertEquals('8:00AM', tour.Start_Time__c);
        System.assertEquals('9:00AM', tour.End_Time__c);
        
    }
    
    @isTest
    private static void testScheduleTourFromOpportunity() {
        Building__c b = new Building__c(
            City__c = 'Test',
            Name = 'Test',
            Simultaneous_Tours__c = '2',
            Tour_Spacing__c = 'Half Hour',
            Maximum_Tour_Days__c = 1
        );
        insert b;
		
		Tour_Schedule__c tour_Schedule = new Tour_Schedule__c(
            Building__c = b.Id,
            Simultaneous_Tours__c = '2',
            Tour_Spacing__c = 'Hour',
            Maximum_Tour_Days__c = 1,
            Product_Line__c = 'WeWork'
        );
        insert tour_Schedule;
        
        insert new Tour_Open_Hour__c[]{
            new Tour_Open_Hour__c(
                weekday__c = 'Monday',
                start_time__c = '8:00AM',
                end_time__c = '8:00PM',
                Tour_Schedule__c = tour_Schedule.id,
                Building__c = b.id
            ),
            new Tour_Open_Hour__c(
                weekday__c = 'Tuesday',
                start_time__c = '8:00AM',
                end_time__c = '8:00PM',
                Tour_Schedule__c = tour_Schedule.id,
                Building__c = b.id
            ),
            new Tour_Open_Hour__c(
                weekday__c = 'Wednesday',
                start_time__c = '8:00AM',
                end_time__c = '8:00PM',
                Tour_Schedule__c = tour_Schedule.id,
                Building__c = b.id
            ),
            new Tour_Open_Hour__c(
                weekday__c = 'Thursday',
                start_time__c = '8:00AM',
                end_time__c = '8:00PM',
                Tour_Schedule__c = tour_Schedule.id,
                Building__c = b.id
            ),
            new Tour_Open_Hour__c(
                weekday__c = 'Friday',
                start_time__c = '8:00AM',
                end_time__c = '8:00PM',
                Tour_Schedule__c = tour_Schedule.id,
                Building__c = b.id
            ),
            new Tour_Open_Hour__c(
                weekday__c = 'Saturday',
                start_time__c = '8:00AM',
                end_time__c = '8:00PM',
                Tour_Schedule__c = tour_Schedule.id,
                Building__c = b.id
            ),
            new Tour_Open_Hour__c(
                weekday__c = 'Sunday',
                start_time__c = '8:00AM',
                end_time__c = '8:00PM',
                Tour_Schedule__c = tour_Schedule.id,
                Building__c = b.id
            )
        };
        Account accountRec = TestingUtility.createAccount('strAccountName', true);
        Opportunity opp = TestingUtility.createOpportunity(accountRec.Id, true);
        
        PageReference pr = new PageReference('/apex/ScheduleTour');
        pr.getParameters().put('oppId', opp.Id);
        Test.setCurrentPageReference(pr);
        
        ScheduleTour sc = new ScheduleTour();
        
        SelectOption[] cities = sc.getCityList();
        System.assertEquals(1, cities.size());
        System.assertEquals('Test', cities[0].getValue());
        
        sc.selectedCity = 'Test';
        sc.citySelected();
        
        SelectOption[] buildings = sc.getBuildingListForSelectedLocation();
        System.assertEquals(1, buildings.size());
        System.assertEquals(b.Id, buildings[0].getValue());
        
        sc.selectedBuilding = b.Id;
        sc.buildingSelected();
        
        Date thisDate = Date.today().addDays(1);
        
        // Date out of range
        sc.newTour.Tour_Date__c = thisDate.addDays(2);
        sc.dateSelected();
        System.assertEquals(null, sc.newTour.Tour_Date__c);
        
        // Correct date
        sc.newTour.Tour_Date__c = thisDate;
        sc.dateSelected();
        
        // Time out of range
        sc.selectedTime = '4:00AM';
        sc.timeSelected();
        System.assertEquals(null, sc.selectedTime);
        
        // Correct time
        sc.selectedTime = '8:00AM';
        sc.timeSelected();
        
        // Incorrect time again
        sc.selectedTime = '4:00AM';
        sc.confirmTour();
        System.assertEquals(null, sc.selectedTime);

        // Correct time, schedule tour
        sc.selectedTime = '8:00AM';
        
        TriggersFlags.allowTourUpdates = false;
        sc.confirmTour();
        
        Tour_Outcome__c[] tours = [select Id, Status__c, Opportunity__c, Lead__c, Journey__c, Location__c, Tour_Date__c, Start_Time__c, End_Time__c from Tour_Outcome__c];
        system.assertNotEquals(
            0,
            tours.size(),
            'a tour record should be created'
        );

        Tour_Outcome__c tour = tours[0];

        System.assertEquals(opp.Id, tour.Opportunity__c);
        System.assertEquals(b.Id, tour.Location__c);
        System.assertEquals(thisDate, tour.Tour_Date__c);
        System.assertEquals('8:00AM', tour.Start_Time__c);
        System.assertEquals('9:00AM', tour.End_Time__c);
        
    }
    /*
    @isTest
    private static void testScheduleTourFromJourney() {
        Building__c b = new Building__c(
            City__c = 'Test',
            Name = 'Test',
            Simultaneous_Tours__c = '2',
            Tour_Spacing__c = 'Half Hour',
            Maximum_Tour_Days__c = 1
        );
        insert b;
		
		Tour_Schedule__c tour_Schedule = new Tour_Schedule__c(
            Building__c = b.Id,
            Simultaneous_Tours__c = '2',
            Tour_Spacing__c = 'Hour',
            Maximum_Tour_Days__c = 1,
            Product_Line__c = 'WeWork'
        );
        insert tour_Schedule;
        
        insert new Tour_Open_Hour__c[]{
            new Tour_Open_Hour__c(
                weekday__c = 'Monday',
                start_time__c = '8:00AM',
                end_time__c = '8:00PM',
                Tour_Schedule__c = tour_Schedule.id,
                Building__c = b.id
            ),
            new Tour_Open_Hour__c(
                weekday__c = 'Tuesday',
                start_time__c = '8:00AM',
                end_time__c = '8:00PM',
                Tour_Schedule__c = tour_Schedule.id,
                Building__c = b.id
            ),
            new Tour_Open_Hour__c(
                weekday__c = 'Wednesday',
                start_time__c = '8:00AM',
                end_time__c = '8:00PM',
                Tour_Schedule__c = tour_Schedule.id,
                Building__c = b.id
            ),
            new Tour_Open_Hour__c(
                weekday__c = 'Thursday',
                start_time__c = '8:00AM',
                end_time__c = '8:00PM',
                Tour_Schedule__c = tour_Schedule.id,
                Building__c = b.id
            ),
            new Tour_Open_Hour__c(
                weekday__c = 'Friday',
                start_time__c = '8:00AM',
                end_time__c = '8:00PM',
                Tour_Schedule__c = tour_Schedule.id,
                Building__c = b.id
            ),
            new Tour_Open_Hour__c(
                weekday__c = 'Saturday',
                start_time__c = '8:00AM',
                end_time__c = '8:00PM',
                Tour_Schedule__c = tour_Schedule.id,
                Building__c = b.id
            ),
            new Tour_Open_Hour__c(
                weekday__c = 'Sunday',
                start_time__c = '8:00AM',
                end_time__c = '8:00PM',
                Tour_Schedule__c = tour_Schedule.id,
                Building__c = b.id
            )
        };
        Journey__c journey = new Journey__c();
        journey.Name = 'Test Journey';
        journey.Stage__c = 'Started';
        journey.NMD_Next_Contact_Date__c= System.today();
        TestingUtility.insertWithAssert(journey);
        
        PageReference pr = new PageReference('/apex/ScheduleTour');
        pr.getParameters().put('journeyId', journey.Id);
        Test.setCurrentPageReference(pr);
        
        ScheduleTour sc = new ScheduleTour();
        
        SelectOption[] cities = sc.getCityList();
        System.assertEquals(1, cities.size());
        System.assertEquals('Test', cities[0].getValue());
        
        sc.selectedCity = 'Test';
        sc.citySelected();
        
        SelectOption[] buildings = sc.getBuildingListForSelectedLocation();
        System.assertEquals(1, buildings.size());
        System.assertEquals(b.Id, buildings[0].getValue());
        
        sc.selectedBuilding = b.Id;
        sc.buildingSelected();
        
        Date thisDate = Date.today().addDays(1);
        
        // Date out of range
        sc.newTour.Tour_Date__c = thisDate.addDays(2);
        sc.dateSelected();
        System.assertEquals(null, sc.newTour.Tour_Date__c);
        
        // Correct date
        sc.newTour.Tour_Date__c = thisDate;
        sc.dateSelected();
        
        // Time out of range
        sc.selectedTime = '4:00AM';
        sc.timeSelected();
        System.assertEquals(null, sc.selectedTime);
        
        // Correct time
        sc.selectedTime = '8:00AM';
        sc.timeSelected();
        
        // Incorrect time again
        sc.selectedTime = '4:00AM';
        sc.confirmTour();
        System.assertEquals(null, sc.selectedTime);

        // Correct time, schedule tour
        sc.selectedTime = '8:00AM';
        
        TriggersFlags.allowTourUpdates = false;
        sc.confirmTour();
        
        Tour_Outcome__c[] tours = [select Id, Status__c, Lead__c, Journey__c, Location__c, Tour_Date__c, Start_Time__c, End_Time__c from Tour_Outcome__c];
        system.assertNotEquals(
            0,
            tours.size(),
            'a tour record should be created'
        );

        Tour_Outcome__c tour = tours[0];

        System.assertEquals(journey.Id, tour.Journey__c);
        System.assertEquals(b.Id, tour.Location__c);
        System.assertEquals(thisDate, tour.Tour_Date__c);
        System.assertEquals('8:00AM', tour.Start_Time__c);
        System.assertEquals('8:30AM', tour.End_Time__c);
        
    }
    */
}