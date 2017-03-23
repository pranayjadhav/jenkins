/**
 * Some logic around Tours that is used from different entry points.
 *
 * @author  - Antonio Grassi
 * @date    - 02/11/2014
 */
public with sharing class TourServices {

    /*
    Introduce new method for Product line
    */
    public static Time[] getAvailableTimes(Date tourDate, Id tourBuildingId, String product_line) {
    	system.debug(loggingLevel.error,'Date =>'+tourDate);
    	return getAvailableTimes(tourDate, tourBuildingId, false, product_line);
    }
    
    public static Time[] getAvailableTimes(Date tourDate, Id tourBuildingId, Boolean showPastTimes, String product_line) {
      TourHandler h = new TourHandler(
        tourDate, 
        tourBuildingId,
        showPastTimes,
        product_line
      );

      return h.open_times;
    }
    
    /*
    public static Time[] getAvailableTimes(Date tourDate, Id tourBuildingId, Boolean showPastTimes) {
      TourHandler h = new TourHandler(
        tourDate, 
        tourBuildingId,
        showPastTimes
      );

      return h.open_times;
    }
	*/
	
    public static Set<Time> getAvailableTimesAsSet(Date tourDate, Id tourBuildingId, String product_line) {
    	return new Set<Time>(getAvailableTimes(tourDate, tourBuildingId, product_line));
    }
    
    public static Tour_Outcome__c scheduleTour(Id leadId, Id oppId, Id buildingId, Date tourDate, String startTime, String productLine) {
    	Tour_Schedule__c tour_schedule = [select Tour_Spacing__c from Tour_Schedule__c where Building__c = :buildingId Limit 1];
    	
    	Time startTimeParsed = parsePicklistTime(startTime);
    	
    	return scheduleTour(leadId,
    	                    oppId,
    	                    buildingId,
    	                    tourDate,
    	                    startTime,
    	                    DateTime.newInstance(Date.today(), startTimeParsed.addMinutes(tour_schedule.Tour_Spacing__c == 'Half Hour' ? 30 : 60)).format('h:mma'),
                            productLine);
    	
    }
    
    public static Tour_Outcome__c scheduleTour(Id leadId, Id oppId, Id buildingId, Date tourDate, String startTime, String endTime, String productLine) {    	
    	Tour_Outcome__c t = new Tour_Outcome__c(
    	    Status__c = 'Scheduled',
            Lead__c = leadId,
            Opportunity__c = oppId,
            Tour_Date__c = tourDate,
            Location__c = buildingId,
            Start_Time__c = startTime,
            End_Time__c = endTime,
            Entry_Type__c = 'New Tour Wizard',
            Product_Line__c = productLine
        );
            
    	insert t;
    	return t;
    }
    
    private static Boolean eventsOverlap(Datetime aStartTime, Datetime aEndTime, Datetime bStartTime, Datetime bEndTime) {

        return (aStartTime < bEndTime && aEndTime >= bEndTime) ||
               (aStartTime <= bStartTime && aEndTime > bStartTime) ||
               (aStartTime >= bStartTime && aEndTime <= bEndTime) ||
               (aStartTime <= bStartTime && aEndTime >= bEndTime);
    }
    
    public static Time parsePicklistTime(String timeString) {
    	
    	String[] parts = timeString.split(':');
    	
    	return Time.newInstance(Integer.valueOf(parts[0]) + (parts[1].subString(2, 4).equalsIgnoreCase('pm') && parts[0] != '12' ? 12 : 0),
    	                        Integer.valueOf(parts[1].subString(0, 2)),
    	                        0,
    	                        0);
    }

    public static Datetime adjustToTimeZone(Date d, Time t, TimeZone tz) {
    	return Datetime.newInstanceGMT(d, t).addSeconds(-(tz.getOffset(Datetime.newInstanceGMT(d, t)) / 1000));
    }
    
    public static String getDayOfWeek(Date d) {
    	return Datetime.newInstance(d, Time.newInstance(0, 0, 0, 0)).format('EEEE');
    }

    //executes under a trigger context
    public static void duplicate_event_to_buildings(Event pEvent) {
      //containers
      Event[] EEs = new Event[]{};

      //variables
      String BUILDING_PREFIX  = 'a00';
      String related_to       = pEvent.WhatId;

      //check if business logic applies to duplicate event
      if (pEvent.copy_to_buildings_in_same_country__c &&
          related_to != null &&
          related_to.startsWith(BUILDING_PREFIX)) {

        //get original building
        Building__c b_original = [SELECT country__c 
                                  FROM Building__c 
                                  WHERE id = :related_to 
                                  LIMIT 1
                                 ];

        //select buildings from same country
        Building__c[] BBs = [ SELECT id 
                              FROM Building__c 
                              WHERE country__c = :b_original.country__c AND 
                                    id <> :b_original.id
                            ];

        //collect events
        for (Building__c b : BBs) {
          Event e = pEvent.clone(false, false, false, false);
          e.WhatId = b.id;
          e.copy_to_buildings_in_same_country__c = false;
          insert e;
          //EEs.add(e);
        }            

        //insert EEs;             

      }
    }

    public static Tour_Outcome__c insert_tour_from_external_app(Id primaryMemberId, WWTypes.InboundLead pInboundLead) {      
      Tour_Outcome__c t = new Tour_Outcome__c(
        Status__c           = 'Scheduled',
        Primary_Member__c	= primaryMemberId,
        Tour_Date__c        = pInboundLead.tour_date,
        Location__c         = BuildingHandler.getBuildingIdByUUID(pInboundLead.tour_building_uuid),
        Start_Time__c       = pInboundLead.tour_time,
        End_Time__c         = null, //it will be catched by TourEndTime trigger
        Entry_Type__c       = 'Website',
        New_Tour_Notes__c   = pInboundLead.tour_notes,
        uuid__c             = pInboundLead.tour_uuid,
        Tour_Participant__c = TourServices.get_tour_participant(pInboundLead.contact_uuid),
        Promo_Code__c       = pInboundLead.promo_code,
        Product_Line__c     = pInboundLead.product_line
      );
	  
	  //Opportunity__c      = pOpportunityId,
	  //Convert_Opportunity__c = pInboundLead.convert_opportunity
      //dml
      insert t;
      
      return t;
    }

    private static Id get_tour_participant(String uuid) {
      Id result;      
      try {
        //sanity check
        if (uuid == null || uuid == '') throw new TourServicesException('No contact_uuid detected');

        Contact c = [SELECT id FROM Contact WHERE uuid__c = :uuid LIMIT 1];
        result = c.id;
      }
      catch(Exception pEx) {
        result = null; //default value
      }
      
      return result;
    }

    public static WWTypes.TourDetail get_tour_by_id(Id pTour_id) {
      //select tour
      Tour_Outcome__c t = [ SELECT  status__c, id, uuid__c,
                                    
                                    start_time__c, end_time__c, tour_date__c,
                                    tour_notes__c, tour_outcome_notes__c,product_line__c,
                                    referred_by_code__c, referral_code__c,
                                    
                                    Location__r.uuid__c, 
                                    
                                    Opportunity__c, Opportunity__r.Account.name, Opportunity__r.Account.uuid__c,
                                    Opportunity__r.Account.company_size__c, Opportunity__r.Account.industry,
                                    
                                    Opportunity__r.number_of_desks__c, Opportunity__r.lead_source_detail__c,
                                    Opportunity__r.leadsource,

                                    Opportunity__r.Primary_Member__r.firstname, Opportunity__r.Primary_Member__r.lastname,
                                    Opportunity__r.Primary_Member__r.name, Opportunity__r.Primary_Member__r.uuid__c, 
                                    Opportunity__r.Primary_Member__r.email, Opportunity__r.Primary_Member__r.phone, 

                                    Tour_Participant__r.firstname, Tour_Participant__r.lastname, Tour_Participant__r.name,
                                    Tour_Participant__r.email, Tour_Participant__r.phone, Tour_Participant__r.uuid__c,
                                    Tour_Participant__c, 
                                    
                                    Lead__r.name, Lead__r.firstname, Lead__r.lastname, Lead__r.email, Lead__r.phone                                    

                            FROM Tour_Outcome__c
                            WHERE id = :pTour_id
                            LIMIT 1
                          ];

      //container
      WWTypes.TourDetail result = new WWTypes.TourDetail();

      //contact is from Lead
      if (t.Lead__c != null) {
        result.last_name    = t.Lead__r.firstname; 
        result.first_name   = t.Lead__r.lastname;
        result.contact_name = t.Lead__r.name;
        result.contact_uuid = null;
        result.email        = t.Lead__r.email; 
        result.phone        = t.Lead__r.phone;
      }

      //contact is from Opportunity Primary
      if (t.Opportunity__c != null && t.Opportunity__r.Primary_Member__r != null) {
        result.last_name    = t.Opportunity__r.Primary_Member__r.firstname; 
        result.first_name   = t.Opportunity__r.Primary_Member__r.lastname;
        result.contact_name = t.Opportunity__r.Primary_Member__r.name;
        result.contact_uuid = t.Opportunity__r.Primary_Member__r.uuid__c;
        result.email        = t.Opportunity__r.Primary_Member__r.email; 
        result.phone        = t.Opportunity__r.Primary_Member__r.phone;
      }

      //contact is from Tour Participant
      if (t.Tour_Participant__c != null) {
        result.last_name    = t.Tour_Participant__r.firstname; 
        result.first_name   = t.Tour_Participant__r.lastname;
        result.contact_name = t.Tour_Participant__r.name;
        result.contact_uuid = t.Tour_Participant__r.uuid__c;
        result.email        = t.Tour_Participant__r.email; 
        result.phone        = t.Tour_Participant__r.phone;
      }

      //company
      if (t.Opportunity__c != null) {
        result.company_name     = t.Opportunity__r.Account.name;
        result.company_uuid     = t.Opportunity__r.Account.uuid__c;
        result.company_size     = t.Opportunity__r.Account.company_size__c;
        result.company_industry = t.Opportunity__r.Account.industry;
        result.number_of_desks  = t.Opportunity__r.number_of_desks__c != null ? 
                                    String.valueOf(t.Opportunity__r.number_of_desks__c) :
                                    '0';        
      }

      //lead source
      if (t.Opportunity__c != null) {
        result.lead_source        = t.Opportunity__r.leadsource;
        result.lead_source_detail = t.Opportunity__r.lead_source_detail__c;        
      }
      
      //tour details
      result.tour_status            = t.status__c;
      result.tour_date              = t.tour_date__c;      
      result.tour_time              = t.start_time__c;
      result.tour_building_uuid     = t.Location__r.uuid__c;
      result.tour_notes             = t.tour_notes__c;
      result.tour_outcome_notes     = t.tour_outcome_notes__c;
      result.tour_referred_by_code  = null;
      result.tour_referral_code     = null;
      result.tour_id                = t.id;
      result.tour_uuid              = t.uuid__c;
      result.product_line			= t.Product_Line__c;
      //associated oppty
      result.opportunity_id = t.Opportunity__c;

      return result;
    }

    public class TourServicesException extends Exception{}
}