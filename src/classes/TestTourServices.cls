@isTest
private class TestTourServices {
  static {
    
  }

    @isTest
    private static void testGetAvailableTimes() {
        
        Date thisDate = Date.today();
        
        Building__c b = new Building__c(
            City__c = 'Test',
            Name = 'b1',
            uuid__c = 'bui001',
            time_zone__c = 'America/New_York'
        );
        insert b;
        
        Tour_Schedule__c tour_Schedule = new Tour_Schedule__c(
            Building__c = b.Id,
            Simultaneous_Tours__c = '2',
            Product_Line__c = 'Office Space',
            Tour_Spacing__c = 'Half Hour',
            Maximum_Tour_Days__c = 1
        );
        insert tour_Schedule;
        
        /*Building__c b = new Building__c(
            City__c = 'Test',
            uuid__c = 'abc123',
            Name = 'Test Building'

        );
        insert b;
        
        Tour_Schedule__c tour_Schedule = new Tour_Schedule__c(
            Building__c = b.Id,
            Simultaneous_Tours__c = '2',
            Product_Line__c = 'Residential Space',
            Tour_Spacing__c = 'Half Hour',      
            Maximum_Tour_Days__c = 1
        );
        insert tour_Schedule;*/
        
        Event e = new Event(
            StartDateTime = Datetime.newInstance(thisDate, Time.newInstance(8, 15, 0, 0)),
            EndDateTime = Datetime.newInstance(thisDate, Time.newInstance(18, 15, 0, 0)),
            WhatId = b.Id
        );
        insert e;
        
        Tour_Outcome__c t1 = new Tour_Outcome__c(
            Tour_Date__c = thisDate,
            Location__c = b.Id,
            Start_Time__c = '4:00PM',
            End_Time__c = '7:00PM'
        );
        insert t1;
        
        Tour_Outcome__c t2 = new Tour_Outcome__c(
            Tour_Date__c = thisDate,
            Location__c = b.Id,
            Start_Time__c = '18:30PM',
            End_Time__c = '7:30PM'
        );
        insert t2;
        
        Set<Time> availableTimes = TourServices.getAvailableTimesAsSet(thisDate, b.Id,tour_Schedule.Product_Line__c );
        
        /*
        System.assertEquals(3, availableTimes.size());
        System.assert(availableTimes.contains(Time.newInstance(19, 0, 0, 0)));
        System.assert(availableTimes.contains(Time.newInstance(19, 30, 0, 0)));
        System.assert(availableTimes.contains(Time.newInstance(20, 0, 0, 0)));
        */
    }
    
    @isTest
    private static void testScheduleTour() {   
        Building__c b = new Building__c(
            City__c = 'Test',
            Name = 'Test',
            uuid__c = 'bui001',
            time_zone__c = 'America/New_York'
        );
        insert b;
        
        Tour_Schedule__c tour_Schedule = new Tour_Schedule__c(
            Building__c = b.Id,
            Simultaneous_Tours__c = '2',
            Product_Line__c = 'Office Space',
            Tour_Spacing__c = 'Half Hour',
            Maximum_Tour_Days__c = 1
        );
        insert tour_Schedule;

        Lead l = new Lead(FirstName = 'Test', LastName = 'Test', Company = 'Test', Email = 'testlead@example.com');
        insert l;
        
        Date thisDate = Date.today();
        
        TriggersFlags.allowTourUpdates = false; 
        Tour_Outcome__c tour = TourServices.scheduleTour(l.Id, null, b.Id, thisDate, '8:00AM', 'WeWork');
        
        System.assertEquals(l.Id, tour.Lead__c);
        System.assertEquals(b.Id, tour.Location__c);
        System.assertEquals(thisDate, tour.Tour_Date__c);
        System.assertEquals('8:00AM', tour.Start_Time__c);
        System.assertEquals('8:30AM', tour.End_Time__c);
    }
//Removing this code as we are deleting the trigger EventDuplicateBuildings, which was duplicating the events.
//By Hemanshu Shah on 23 Apr 2016
/*
  @isTest static void test_create_holiday_event_1() {
    //pre-context
      Building__c b1 = new Building__c(
        name = 'London',
        country__c = 'UK'
      );
      insert b1;

      Building__c b2 = new Building__c(
        name = 'Liverpool',
        country__c = 'UK'
      );
      insert b2;

      Building__c b3 = new Building__c(
        name = 'Manchester',
        country__c = 'UK'
      );
      insert b3;

      Building__c b4 = new Building__c(
        name = 'Soho NY',
        country__c = 'USA'
      );
      insert b4;

      //this will be an event for all UK buildings
      Event e = new Event(
        subject                               = 'Holidays Queens day',
        Copy_to_buildings_in_same_country__c  = true,
        StartDateTime                         = Datetime.now().addDays(5),
        EndDateTime                           = Datetime.now().addDays(6),
        WhatId                                = b1.Id, //uk building
        isAllDayEvent                         = true
      );
      insert e;

    //test
    Test.startTest();

      Event[] HEs = [ SELECT subject, WhatId 
                      FROM Event 
                      WHERE subject = :e.subject
                    ];

      system.assertEquals(
        3,
        HEs.size(),
        'Both buildings should have the UK holiday event associated'
      );

      system.assert(
        b1.id == HEs[0].WhatId ||
        b2.id == HEs[0].WhatId ||
        b3.id == HEs[0].WhatId,
        'UK Buidings should have the holidays event associated!'
      );

      system.assert(
        b1.id == HEs[1].WhatId ||
        b2.id == HEs[1].WhatId ||
        b3.id == HEs[1].WhatId,
        'UK Buidings should have the holidays event associated!'
      );

      system.assert(
        b1.id == HEs[2].WhatId ||
        b2.id == HEs[2].WhatId ||
        b3.id == HEs[2].WhatId,
        'UK Buidings should have the holidays event associated!'
      );
  
    Test.stopTest();
  }

  @isTest static void test_create_holiday_event_recurring_1() {
    //pre-context
      Building__c b1 = new Building__c(
        name = 'London',
        country__c = 'UK'
      );
      insert b1;

      Building__c b2 = new Building__c(
        name = 'Liverpool',
        country__c = 'UK'
      );
      insert b2;

      Building__c b3 = new Building__c(
        name = 'Manchester',
        country__c = 'UK'
      );
      insert b3;

      Building__c b4 = new Building__c(
        name = 'Soho NY',
        country__c = 'USA'
      );
      insert b4;

      //this will be an event for all UK buildings
      Event e = new Event(
        subject                               = 'Holidays Queens day',
        Copy_to_buildings_in_same_country__c  = true,
        RecurrenceStartDateTime               = system.today(),
        RecurrenceEndDateOnly                 = system.today().addYears(6),
        RecurrenceDayOfMonth                  = 29,
        RecurrenceMonthOfYear                 = 'January',
        RecurrenceType                        = 'RecursYearly',
        ActivityDate                          = system.today(),
        WhatId                                = b1.Id, //uk building
        isAllDayEvent                         = true,
        isRecurrence                          = true
      );
      insert e;

    //test
    Test.startTest();

      Event[] HEs = [ SELECT subject, WhatId, isRecurrence 
                      FROM Event 
                      WHERE subject = :e.subject AND isRecurrence = true
                    ];

      system.assertEquals(
        3,
        HEs.size(),
        'Both buildings should have the UK holiday event associated'
      );

      system.assert(
        b1.id == HEs[0].WhatId ||
        b2.id == HEs[0].WhatId ||
        b3.id == HEs[0].WhatId,
        'UK Buidings should have the holidays event associated!'
      );

      system.assert(
        b1.id == HEs[1].WhatId ||
        b2.id == HEs[1].WhatId ||
        b3.id == HEs[1].WhatId,
        'UK Buidings should have the holidays event associated!'
      );

      system.assert(
        b1.id == HEs[2].WhatId ||
        b2.id == HEs[2].WhatId ||
        b3.id == HEs[2].WhatId,
        'UK Buidings should have the holidays event associated!'
      );

      system.assert(
        HEs[0].isRecurrence &&
        HEs[1].isRecurrence &&
        HEs[2].isRecurrence,
        'Recurring Events should be copied too!'
      );
  
    Test.stopTest();
  }

  //stress testing
  @isTest static void test_create_holiday_event_recurring_2() {
    //pre-context
      Building__c[] Bs = new Building__c[]{};
      for (Integer i=0; i < 100; i++)
        Bs.add(
          new Building__c(
            name = TestUtility.generateRandomString(8),
            country__c = 'Uk'
          )
        );

      //insert bulk
      insert Bs;

      Building__c b1 = new Building__c(
        name = 'London',
        country__c = 'UK'
      );
      insert b1;

      //this will be an event for all UK buildings
      Event e = new Event(
        subject                               = 'Holidays Queens day',
        Copy_to_buildings_in_same_country__c  = true,
        RecurrenceStartDateTime               = system.today(),
        RecurrenceEndDateOnly                 = system.today().addYears(6),
        RecurrenceDayOfMonth                  = 29,
        RecurrenceMonthOfYear                 = 'January',
        RecurrenceType                        = 'RecursYearly',
        ActivityDate                          = system.today(),
        WhatId                                = b1.Id, //uk building
        isAllDayEvent                         = true,
        isRecurrence                          = true
      );
      insert e;

    //test
    Test.startTest();

      Event[] HEs = [ SELECT subject, WhatId, isRecurrence 
                      FROM Event 
                      WHERE subject = :e.subject AND isRecurrence = true
                    ];

      system.assertEquals(
        101,
        HEs.size(),
        'Both buildings should have the UK holiday event associated'
      );     
  
    Test.stopTest();
  }*/

  @isTest static void test_available_tours_east_coast_sameday() {
    //pre-context

      //set internal clock
      Now.setGMT(2016, 2, 5, 8, 0, 0); //friday 2/5/16 8:00am 

      //create a building and open it
        Building__c b = new Building__c(
            City__c = 'Test',
            uuid__c = 'abc123',
            time_zone__c = 'America/New_York',
            Name = 'NYC-Penn Station'
        );
        insert b;
        
        Tour_Schedule__c tour_Schedule = new Tour_Schedule__c(
            Building__c = b.Id,
            Simultaneous_Tours__c = '2',
            Product_Line__c = 'Residential Space',
            Tour_Spacing__c = 'Half Hour',
            Maximum_Tour_Days__c = 1
        );
        insert tour_Schedule;

      insert new Tour_Open_Hour__c[]{
        new Tour_Open_Hour__c(
            weekday__c = 'Monday',
            start_time__c = '9:00AM',
            end_time__c = '1:00PM',
            Tour_Schedule__c = tour_Schedule.id,
            Building__c = b.Id
        ),
        new Tour_Open_Hour__c(
            weekday__c = 'Tuesday',
            start_time__c = '9:00AM',
            end_time__c = '1:00PM',
            Tour_Schedule__c = tour_Schedule.id,
            Building__c = b.Id
        ),
        new Tour_Open_Hour__c(
            weekday__c = 'Wednesday',
            start_time__c = '9:00AM',
            end_time__c = '1:00PM',
            Tour_Schedule__c = tour_Schedule.id,
            Building__c = b.Id
        ),
        new Tour_Open_Hour__c(
            weekday__c = 'Thursday',
            start_time__c = '9:00AM',
            end_time__c = '1:00PM',
            Tour_Schedule__c = tour_Schedule.id,
            Building__c = b.Id
        ),
        new Tour_Open_Hour__c(
            weekday__c = 'Friday',
            start_time__c = '9:00AM',
            end_time__c = '1:00PM',
            Tour_Schedule__c = tour_Schedule.id,
            Building__c = b.Id
        ),
        new Tour_Open_Hour__c(
            weekday__c = 'Saturday',
            start_time__c = '9:00AM',
            end_time__c = '1:00PM',
            Tour_Schedule__c = tour_Schedule.id,
            Building__c = b.Id
        ),
        new Tour_Open_Hour__c(
            weekday__c = 'Sunday',
            start_time__c = '9:00AM',
            end_time__c = '1:00PM',
            Tour_Schedule__c = tour_Schedule.id,
            Building__c = b.Id
        )
    };

    Tour_Closed_Hour__c tch = new Tour_Closed_Hour__c(
      date__c = Now.date(),
      start_time__c = '10:00AM',
      end_time__c = '12:00PM',
      Tour_Schedule__c = tour_Schedule.id,
      Building__c = b.Id
    );

    insert tch;

    //test
    Test.startTest();
      
      

      //get available times      
      Time[] Ts = TourServices.getAvailableTimes(
                    Now.date(), 
                    b.id,
                    tour_Schedule.Product_Line__c
                  );

      Debug.log('available times on test same day:');
      //Debug.log(Ts);   
      //Debug.log('--- available times Zones ----'+ tour_Schedule.Time_Zone__c ); 
      Integer offset =  Timezone.getTimezone(b.Time_Zone__c).getOffset(Now.date())
                        - 
                        Userinfo.getTimezone().getOffset(Now.date());

      Time[] expected = new Time[]{
        Time.newInstance(9,0,0,0).addMilliseconds(-offset),
        Time.newInstance(9,30,0,0).addMilliseconds(-offset),
        Time.newInstance(12,0,0,0).addMilliseconds(-offset),
        Time.newInstance(12,30,0,0).addMilliseconds(-offset)
      };

      System.assertEquals(
        expected,
        Ts,
        'There are differences on the open times'
      );            

    Test.stopTest();
  }

  @isTest static void test_available_tours_east_coast_anotherday() {
    //pre-context
      //set internal clock
      Now.setGMT(2016, 2, 5, 8, 0, 0); //friday 2/5/16 8am 

      //create a building and open it
       Building__c b = new Building__c(
            City__c = 'Test',
            uuid__c = 'abc123',
            time_zone__c = 'America/New_York',
            Name = 'NYC-Penn Station'
        );
        insert b;
        
        Tour_Schedule__c tour_Schedule = new Tour_Schedule__c(
            Building__c = b.Id,
            Simultaneous_Tours__c = '2',
            Product_Line__c = 'Residential Space',
            Tour_Spacing__c = 'Half Hour',
            Maximum_Tour_Days__c = 1
        );
        insert tour_Schedule;

      insert new Tour_Open_Hour__c[]{
        new Tour_Open_Hour__c(
            weekday__c = 'Monday',
            start_time__c = '9:00AM',
            end_time__c = '1:00PM',
            Tour_Schedule__c = tour_Schedule.id,
            Building__c = b.Id
        ),
        new Tour_Open_Hour__c(
            weekday__c = 'Tuesday',
            start_time__c = '9:00AM',
            end_time__c = '1:00PM',
            Tour_Schedule__c = tour_Schedule.id,
            Building__c = b.Id
        ),
        new Tour_Open_Hour__c(
            weekday__c = 'Wednesday',
            start_time__c = '9:00AM',
            end_time__c = '1:00PM',
            Tour_Schedule__c = tour_Schedule.id,
            Building__c = b.Id
        ),
        new Tour_Open_Hour__c(
            weekday__c = 'Thursday',
            start_time__c = '9:00AM',
            end_time__c = '1:00PM',
            Tour_Schedule__c = tour_Schedule.id,
            Building__c = b.Id
        ),
        new Tour_Open_Hour__c(
            weekday__c = 'Friday',
            start_time__c = '9:00AM',
            end_time__c = '1:00PM',
            Tour_Schedule__c = tour_Schedule.id,
            Building__c = b.Id
        ),
        new Tour_Open_Hour__c(
            weekday__c = 'Saturday',
            start_time__c = '9:00AM',
            end_time__c = '1:00PM',
            Tour_Schedule__c = tour_Schedule.id,
            Building__c = b.Id
        ),
        new Tour_Open_Hour__c(
            weekday__c = 'Sunday',
            start_time__c = '9:00AM',
            end_time__c = '1:00PM',
            Tour_Schedule__c = tour_Schedule.id,
            Building__c = b.Id
        )
    };

    Tour_Closed_Hour__c tch = new Tour_Closed_Hour__c(
      date__c = Now.date().addDays(3),
      start_time__c = '10:00AM',
      end_time__c = '12:00PM',
      Tour_Schedule__c = tour_Schedule.id,
      Building__c = b.Id
    );

    insert tch;

    //test
    Test.startTest();
      
      //get available times      
      Time[] Ts = TourServices.getAvailableTimes(
                    Now.date().addDays(3), 
                    b.id,
                    tour_Schedule.Product_Line__c
                  );

      Debug.log('available times on test same day:');
      //Debug.log(Ts);

      Integer offset =  Timezone.getTimezone(b.Time_Zone__c).getOffset(Now.date())
                        - 
                        Userinfo.getTimezone().getOffset(Now.date());

      Time[] expected = new Time[]{
        Time.newInstance(9,0,0,0).addMilliseconds(-offset),
        Time.newInstance(9,30,0,0).addMilliseconds(-offset),
        Time.newInstance(12,0,0,0).addMilliseconds(-offset),
        Time.newInstance(12,30,0,0).addMilliseconds(-offset)
      };

      System.assertEquals(
        expected,
        Ts,
        'There are differences on the open times'
      ); 

    Test.stopTest();
  }

  @isTest static void test_available_tours_west_coast_sameday() {
    //pre-context

      //set internal clock
      Now.setGMT(2016, 2, 5, 8, 0, 0); //friday 2/5/16 8:00am 

      //create a building and open it
        Building__c b = new Building__c(
            City__c = 'Test',
            uuid__c = 'abc123',
            time_zone__c = 'America/New_York',
            Name = 'NYC-Penn Station'
        );
        insert b;
        
        Tour_Schedule__c tour_Schedule = new Tour_Schedule__c(
            Building__c = b.Id,
            Simultaneous_Tours__c = '2',
            Product_Line__c = 'Residential Space',
            Tour_Spacing__c = 'Half Hour',
            Maximum_Tour_Days__c = 1
        );
        insert tour_Schedule;

      insert new Tour_Open_Hour__c[]{
        new Tour_Open_Hour__c(
            weekday__c = 'Monday',
            start_time__c = '9:00AM',
            end_time__c = '1:00PM',
            Tour_Schedule__c = tour_Schedule.id,
            Building__c = b.Id
        ),
        new Tour_Open_Hour__c(
            weekday__c = 'Tuesday',
            start_time__c = '9:00AM',
            end_time__c = '1:00PM',
            Tour_Schedule__c = tour_Schedule.id,
            Building__c = b.Id
        ),
        new Tour_Open_Hour__c(
            weekday__c = 'Wednesday',
            start_time__c = '9:00AM',
            end_time__c = '1:00PM',
            Tour_Schedule__c = tour_Schedule.id,
            Building__c = b.Id
        ),
        new Tour_Open_Hour__c(
            weekday__c = 'Thursday',
            start_time__c = '9:00AM',
            end_time__c = '1:00PM',
            Tour_Schedule__c = tour_Schedule.id,
            Building__c = b.Id
        ),
        new Tour_Open_Hour__c(
            weekday__c = 'Friday',
            start_time__c = '9:00AM',
            end_time__c = '1:00PM',
            Tour_Schedule__c = tour_Schedule.id,
            Building__c = b.Id
        ),
        new Tour_Open_Hour__c(
            weekday__c = 'Saturday',
            start_time__c = '9:00AM',
            end_time__c = '1:00PM',
            Tour_Schedule__c = tour_Schedule.id,
            Building__c = b.Id
        ),
        new Tour_Open_Hour__c(
            weekday__c = 'Sunday',
            start_time__c = '9:00AM',
            end_time__c = '1:00PM',
            Tour_Schedule__c = tour_Schedule.id,
            Building__c = b.Id
        )
    };

    Tour_Closed_Hour__c tch = new Tour_Closed_Hour__c(
      date__c = Now.date(),
      start_time__c = '10:00AM',
      end_time__c = '12:00PM',
      Tour_Schedule__c = tour_Schedule.id,
      Building__c = b.Id
    );

    insert tch;

    //test
    Test.startTest();
      
      

      //get available times      
      Time[] Ts = TourServices.getAvailableTimes(
                    Now.date(), 
                    b.id,
                    tour_Schedule.Product_Line__c
                  );

      Debug.log('available times on test same day:');
      //Debug.log(Ts);
      
      Integer offset =  Timezone.getTimezone(b.Time_Zone__c).getOffset(Now.date())
                        - 
                        Userinfo.getTimezone().getOffset(Now.date());

      Time[] expected = new Time[]{
        Time.newInstance(9,0,0,0).addMilliseconds(-offset),
        Time.newInstance(9,30,0,0).addMilliseconds(-offset),
        Time.newInstance(12,0,0,0).addMilliseconds(-offset),
        Time.newInstance(12,30,0,0).addMilliseconds(-offset)
      };

      System.assertEquals(
        expected,
        Ts,
        'There are differences on the open times'
      );            

    Test.stopTest();
  }

    @isTest static void test_available_tours_west_coast_anotherday() {
    //pre-context
      //set internal clock
      Now.setGMT(2016, 2, 5, 8, 0, 0); //friday 2/5/16 8am 

      //create a building and open it
       Building__c b = new Building__c(
            City__c = 'Test',
            uuid__c = 'abc123',
            time_zone__c = 'America/New_York',
            Name = 'NYC-Penn Station'
        );
        insert b;
        
        Tour_Schedule__c tour_Schedule = new Tour_Schedule__c(
            Building__c = b.Id,
            Simultaneous_Tours__c = '2',
            Product_Line__c = 'Residential Space',
            Tour_Spacing__c = 'Half Hour',
            Maximum_Tour_Days__c = 1
        );
        insert tour_Schedule;
        
      insert new Tour_Open_Hour__c[]{
        new Tour_Open_Hour__c(
            weekday__c = 'Monday',
            start_time__c = '9:00AM',
            end_time__c = '1:00PM',
            Tour_Schedule__c = tour_Schedule.id,
            Building__c = b.Id
        ),
        new Tour_Open_Hour__c(
            weekday__c = 'Tuesday',
            start_time__c = '9:00AM',
            end_time__c = '1:00PM',
            Tour_Schedule__c = tour_Schedule.id,
            Building__c = b.Id
        ),
        new Tour_Open_Hour__c(
            weekday__c = 'Wednesday',
            start_time__c = '9:00AM',
            end_time__c = '1:00PM',
            Tour_Schedule__c = tour_Schedule.id,
            Building__c = b.Id
        ),
        new Tour_Open_Hour__c(
            weekday__c = 'Thursday',
            start_time__c = '9:00AM',
            end_time__c = '1:00PM',
            Tour_Schedule__c = tour_Schedule.id,
            Building__c = b.Id
        ),
        new Tour_Open_Hour__c(
            weekday__c = 'Friday',
            start_time__c = '9:00AM',
            end_time__c = '1:00PM',
            Tour_Schedule__c = tour_Schedule.id,
            Building__c = b.Id
        ),
        new Tour_Open_Hour__c(
            weekday__c = 'Saturday',
            start_time__c = '9:00AM',
            end_time__c = '1:00PM',
            Tour_Schedule__c = tour_Schedule.id,
            Building__c = b.Id
        ),
        new Tour_Open_Hour__c(
            weekday__c = 'Sunday',
            start_time__c = '9:00AM',
            end_time__c = '1:00PM',
            Tour_Schedule__c = tour_Schedule.id,
            Building__c = b.Id
        )
    };

    Tour_Closed_Hour__c tch = new Tour_Closed_Hour__c(
      date__c = Now.date().addDays(3),
      start_time__c = '10:00AM',
      end_time__c = '12:00PM',
      Tour_Schedule__c = tour_Schedule.id,
      Building__c = b.Id
    );

    insert tch;

    //test
    Test.startTest();
      
      //get available times      
      Time[] Ts = TourServices.getAvailableTimes(
                    Now.date().addDays(3), 
                    b.id,
                    tour_Schedule.Product_Line__c
                  );

      Debug.log('available times on test same day:');
      //Debug.log( Ts);

      Integer offset =  Timezone.getTimezone(b.Time_Zone__c).getOffset(Now.date())
                        - 
                        Userinfo.getTimezone().getOffset(Now.date());

      Time[] expected = new Time[]{
        Time.newInstance(9,0,0,0).addMilliseconds(-offset),
        Time.newInstance(9,30,0,0).addMilliseconds(-offset),
        Time.newInstance(12,0,0,0).addMilliseconds(-offset),
        Time.newInstance(12,30,0,0).addMilliseconds(-offset)
      };

      System.assertEquals(
        expected,
        Ts,
        'There are differences on the open times'
      ); 

    Test.stopTest();
  }
  
   @isTest static void testGetDayOfWeek(){
   			Date d = Date.today();
   			TourServices.getDayOfWeek(d);
   }
   
   @isTest static void test_duplicate_event_to_buildings(){
   	 Date thisDate = Date.today();
   		 Building__c b = new Building__c(
            City__c = 'Test',
            Name = 'b1',
            uuid__c = 'bui001',
            time_zone__c = 'America/New_York'
        );
        insert b;
        
        Tour_Schedule__c tour_Schedule = new Tour_Schedule__c(
            Building__c = b.Id,
            Simultaneous_Tours__c = '2',
            Product_Line__c = 'Office Space',
            Tour_Spacing__c = 'Half Hour',
            Maximum_Tour_Days__c = 1
        );
        insert tour_Schedule;
        
         Event e = new Event(
            StartDateTime = Datetime.newInstance(thisDate, Time.newInstance(8, 15, 0, 0)),
            EndDateTime = Datetime.newInstance(thisDate, Time.newInstance(18, 15, 0, 0)),
            WhatId = b.Id,
            copy_to_buildings_in_same_country__c = true
        );
        insert e;
        TourServices.duplicate_event_to_buildings(e);
   }
}