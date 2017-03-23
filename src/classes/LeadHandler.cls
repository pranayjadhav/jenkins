public with sharing class LeadHandler {
	//used by Inbound Lead API
	public static void upsert_inbound_lead(WWTypes.InboundLead pInboundLead) {
		LeadServices ls = new LeadServices(pInboundLead);

		TaskServices ts = new TaskServices(ls);

		//create task
		Task t = ts.create_task_from_web(pInboundLead);

		//modify task
		//...

		//insert task
		insert t;
	}

    /*public static Id book_a_tour(WWTypes.InboundLead pInboundLead) {
        Id journeyId = null;
        if( String.isBlank(str) pInboundLead.)
        
        return journeyId;
    }*/
    
	//used by Tour API
	public static Id book_a_tour(WWTypes.InboundLead pInboundLead) {
		//container
		Id result = null; //the affected Opportunity
		Debug.Log('Rest Tour Advanced Test : ==>'+pInboundLead);
		//business scenario 5: pre-existing account or contact
		if (pInboundLead.account_uuid != null || pInboundLead.contact_uuid != null) {

		  //set account services
	      AccountServices aServices = new AccountServices(pInboundLead);
		  /*
		  * Commented By : Mayuresh Ghodke
		  * Date		 : 28-06-16
		  * Comment		 : While creating new Tour new Opportunity should not get created.
		  * Issue No.	 : ST-470
		  */
	      //locate the latest open opportunity id
	      //Id latest_open_opportunity_id = null;
	      //Id latest_open_opportunity_id = LeadHandler.get_or_create_opportunity(aServices.a.Id,	'Tour Scheduled', pInboundLead);
	      
	      
		  Account acc = [SELECT Primary_member__c FROM Account WHERE id = :aServices.a.Id LIMIT 1];
	      //create tour (primaryMember.id, pInboundLead)
	      Id tour_id = TourServices.insert_tour_from_external_app(acc.Primary_member__c , pInboundLead).id;
	
	      //create task services
	      TaskServices ts = new TaskServices(null, aServices.c, false);
	
	      //create task and assign to regular member
	      LeadHandler.insert_task(ts, pInboundLead, 'Book a Tour', UserInfo.getUserId());
	
	      result = tour_id;
	    }

		//business scenarios 1-4:
		else {
			//locate a customer
			
			LeadServices ls = new LeadServices(pInboundLead);
			
			//business scenario 1: new customer on system ///////////////////////////////////////////
			if (ls.is_first_touch) {
				//convert lead + associate primary member 
				ls.convert_lead();

				//create task services
				TaskServices ts = new TaskServices(ls);

				//create task (isFirstTouch, pInboundLead, contactId, subject)
				LeadHandler.insert_task(ts, pInboundLead, 'Tour booked', null);				

				//create tour (primaryMember.id, pInboundLead)
				Account acc = [SELECT Primary_member__c FROM Account WHERE id = :ls.k.convertedAccountId LIMIT 1];
				Id tour_id = TourServices.insert_tour_from_external_app(acc.Primary_member__c, pInboundLead).id;

				//result
				result = tour_id;
			}
			//business scenario 2: existing customer with open lead ////////////////////////////////
			else if (	!ls.is_first_touch && 
								ls.k != null && 
								!ls.k.isConverted
							) {
				//convert lead + associate primary member
				ls.convert_lead();

				//create task services
				TaskServices ts = new TaskServices(ls);

				//create task (isFirstTouch, pInboundLead, contactId, subject)
				LeadHandler.insert_task(ts, pInboundLead, 'Tour booked', null);	

				//create tour (convertedOpportunityId, pInboundLead)
				Account acc = [SELECT Primary_member__c FROM Account WHERE id = :ls.k.convertedAccountId LIMIT 1];
				Id tour_id = TourServices.insert_tour_from_external_app(acc.Primary_member__c, pInboundLead).id;

				//result
				result = tour_id;
			}
			//business scenario 3: existing customer with converted lead ///////////////////////////
			else if (	!ls.is_first_touch && 
								ls.k != null && 
								ls.k.isConverted && 
								ls.c.is_primary_member__c == true
							) {

				/*
				* Commented By 	: Mayuresh Ghodke
				* Date		 	: 28-06-16
				* Comment		: While creating new Tour new Opportunity should not get created.
				* Issue No.	 	: ST-470
				*/
				//locate the latest open opportunity id
				//Id latest_open_opportunity_id = null;
				//Id latest_open_opportunity_id = LeadHandler.get_or_create_opportunity(ls.k.convertedAccountId,	'Tour Scheduled', pInboundLead);
				//create task services
				
				TaskServices ts = new TaskServices(ls);

				//create task (isFirstTouch, pInboundLead, contactId, subject)
				LeadHandler.insert_task(ts, pInboundLead, 'Tour booked', null);
				
				Account acc = [SELECT Primary_member__c FROM Account WHERE id = :ls.k.convertedAccountId LIMIT 1];
				//create tour (primaryMember.id, pInboundLead)
				Id tour_id = TourServices.insert_tour_from_external_app(acc.Primary_member__c, pInboundLead).id;

				//result
				result = tour_id;
			}
			//business scenario 4: existing customer as regular member (not primary) ///////////////
			else if (	ls.k == null &&
								ls.c != null &&
								ls.c.is_primary_member__c == false
							) { 
				//locate account
				Id account_id = ls.c.AccountId;

				/*
			    * Commented By  : Mayuresh Ghodke
			    * Date		 	: 28-06-16
			    * Comment		: While creating new Tour new Opportunity should not get created.
			    * Issue No.	 	: ST-470
			    */
		        //locate the latest open opportunity id
		        //Id latest_open_opportunity_id = null;
		        //Id latest_open_opportunity_id = LeadHandler.get_or_create_opportunity(account_id,	'Tour Scheduled', pInboundLead);
		      		      
			    Account acc = [SELECT Primary_member__c FROM Account WHERE id = :account_id LIMIT 1];
		        //create tour (primaryMember.id, pInboundLead)
		        Id tour_id = TourServices.insert_tour_from_external_app(acc.Primary_member__c , pInboundLead).id;

				//create task services
				TaskServices ts = new TaskServices(ls);

				//create task and assign to regular member
				LeadHandler.insert_task(ts, pInboundLead, 'Tour booked', null); 	

				result = tour_id;
			}	
		}

		return result;
	}

  private static void insert_task(TaskServices ts,
                                  WWTypes.InboundLead pInboundLead,
                                  String subject,
                                  Id ownerId) {
		//create generic task
		Task t = ts.create_task_from_web(pInboundLead);

		//custom bindings
		t.Description = 'Created by Tour API';    
		t.Subject 		= subject;
	      
	 //set task owner                               
		if (ownerId != null) t.OwnerId = UserInfo.getUserId(); // Review this    
    
    //dml
    insert t;
  }

/*
* Commented By  : Mayuresh Ghodke
* Date		 	: 28-06-16
* Comment		: While creating new Tour new Opportunity should not get created.
* Issue No.	 	: ST-470
*/
/*
  private static Id get_or_create_opportunity(Id pAccountId,
                                              String pStageName,
                                              WWTypes.InboundLead pInboundLead) {
                                              	
      
    //collect building name
    String buildingName = BuildingHandler.getMultipicklistValuesFromUUID(
														new String[] {
															pInboundLead.tour_building_uuid
														}
        									); 
    
    Opportunity o = OpportunityServices.get_latest_open_opportunity(pAccountId, buildingName);
    
    if (o == null) {
      o = OpportunityServices.create_opportunity(pAccountId, buildingName, pStageName);

      o.LeadSource				= pInboundLead.lead_source;
      o.Lead_Source_Detail__c	= pInboundLead.lead_source_detail;
      o.utm_campaign__c			= pInboundLead.utm_campaign;
      o.utm_campaign_id__c		= pInboundLead.utm_campaign_id;
      o.utm_content__c			= pInboundLead.utm_content;
      o.utm_medium__c			= pInboundLead.utm_medium;
      o.utm_source__c			= pInboundLead.utm_source;
      o.utm_term__c				= pInboundLead.utm_term;
	  //o.Type__c				= pInboundLead.lead_type;
        
      insert o;
    }
    
    return o.Id;
  }
*/
}