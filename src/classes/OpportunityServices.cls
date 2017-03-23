/**
 * Different logic related to Opportunities
 *
 * @author  Antonio Grassi
 * @date    09/25/2013
 */
public with sharing class OpportunityServices {

  public static void closeOpportunities(Set<Id> opportunityIds) {
  	
  	Opportunity[] ops = [select Id, StageName from Opportunity where Id in :opportunityIds];
  	
  	for (Opportunity o:ops) {
  		o.StageName = 'Contract Signed';
  	}
  	
  	if (!ops.isEmpty()) {
  		update ops;
  	}
  }
  
  @future
  public static void update_closedwon_accounts(Id[] pOpportunityIDs) {

    Id[] container = new Id[]{};

    //validation because method was called in the past
    for (Opportunity o : [SELECT AccountId 
                          FROM Opportunity 
                          WHERE 
                            isClosed = true AND 
                            isWon = true AND
                            id IN :pOpportunityIDs
                          ])
      container.add(o.AccountId);
    
    
    ////////////////////////// CLOSED WON STUFF /////////////////////////////////
    //select closed won Accounts
    Account[] ClosedWonAAs = [  SELECT WW_Sync_Request__c, Type 
                                FROM Account 
                                WHERE 
                                  Id IN :container 
                                LIMIT 1000
                              ];

    //set sync request for each account
    for (Account a : ClosedWonAAs) {
      //a.WW_Sync_Request__c = true;
      a.Type = 'Member';
      a.ID_Status2__c = 'active';
    }

    //dml
    update ClosedWonAAs; 
    

    //select tagged closed won contacts and re send them to ID api (the opportunity was won)
    Contact[] ClosedWonCs = [ SELECT WW_Sync_Request__c, Status__c, Account.Primary_Member__c, Id
                              FROM Contact
                              WHERE
                                AccountID IN :container 
                              LIMIT 1000
                            ];

    //set sync request for each contact
    for (Contact c : ClosedWonCs) {
      //c.WW_Sync_Request__c = true;

      //if primary member set as active
      if (c.Account.Primary_Member__c == c.Id)
        c.Status__c = 'active';
    }

    //dml
    update ClosedWonCs;
  }

  public static Opportunity get_latest_open_opportunity(Id pAccountId, String pBuildingName) {

    //select latest open opportunity
    Opportunity[] Os = [  SELECT id
                          FROM Opportunity
                          WHERE 
                            AccountId = :pAccountId AND
                            locations_interested__c INCLUDES (:pBuildingName) AND
                            stageName IN ('Inquiry', 
                                          'Wait List', 
                                          'Internal Wait List', 
                                          'Tour Scheduled', 
                                          'Tour Completed', 
                                          'Not Interested' 
                                          )
                          ORDER BY createddate DESC
                          LIMIT 1
                       ];
    
    return Os.isEmpty() ? null : Os[0];
  }
  
  public static Opportunity create_opportunity(Id pAccountId, String pBuildingName, String pStageName) {
      //get primary member
      Account a = [SELECT Primary_member__c FROM Account WHERE id = :pAccountId LIMIT 1];

      //create opportunity
      Opportunity o = new Opportunity(
        stageName               = pStageName, //Scheduled Tour
        AccountId               = pAccountId,
        closeDate               = system.today(),
        name                    = 'New Opportunity',
        Primary_Member__c       = a.Primary_Member__c,
        locations_interested__c = pBuildingName
      );

      return o;
  }

  /*
  // locate an open opportunity by account id
  // if exists and Oppty and payload builing are the same use this opp
  // else create a new oppty and link with the account
  //
  // review this - So far this is only used from LeadHandler. But would be smart to refactor in order to avoid
  // dependency on WWTypes.InboundLead (would need to separate query and creation steps, so that custom
  // bindings could be applied on the opportunity before insertion)
  public static Id get_latest_open_opportunity_id(
      Id pAccountId,
      String pStageName,
      String pBuildingUUID,
      WWTypes.InboundLead pInboundLead) {

    //container
    Id result = null;

    //get building
    String building_name = BuildingHandler.getMultipicklistValuesFromUUID(new String[]{
                                                                            pBuildingUUID
                                                                          }); 
    //select latest open opportunity
    Opportunity[] Os = [  SELECT id
                          FROM Opportunity
                          WHERE 
                            AccountId = :pAccountId AND
                            locations_interested__c INCLUDES (:building_name) AND
                            stageName IN ('Inquiry', 
                                          'Wait List', 
                                          'Internal Wait List', 
                                          'Tour Scheduled', 
                                          'Tour Completed', 
                                          'Not Interested' 
                                          )
                          ORDER BY createddate DESC
                          LIMIT 1
                       ];
    
    //check if already on system
    if (Os.size() == 1) {
      result = Os[0].id;
    }
    //or a new Opportunity is needed
    else {
      //get primary member
      Account a = [SELECT Primary_member__c FROM Account WHERE id = :pAccountId LIMIT 1];

      //create opportunity
      Opportunity o = new Opportunity(
        stageName               = pStageName, //Scheduled Tour
        AccountId               = pAccountId,
        closeDate               = system.today(),
        name                    = 'New Opportunity',
        Primary_Member__c       = a.Primary_Member__c,
        locations_interested__c = building_name
      );
        
      if (pInboundLead != null) {
        o.LeadSource			= pInboundLead.lead_source;
        o.Lead_Source_Detail__c	= pInboundLead.lead_source_details;
        o.utm_campaign__c		= pInboundLead.utm_campaign;
        o.utm_campaign_id__c	= pInboundLead.utm_campaign_id;
        o.utm_content__c		= pInboundLead.utm_content;
        o.utm_medium__c			= pInboundLead.utm_medium;
        o.utm_source__c			= pInboundLead.utm_source;
        o.utm_term__c			= pInboundLead.utm_term;
      }
        
      insert o;
      result = o.id;
    }

    return result;
  }
  */

  public static Id getMostRecentOpportunityId(Id pAccountId) {
    Id result;
    try {
      Account[] AAs = [ SELECT id, name, 
                          (SELECT id FROM Opportunities ORDER BY createddate DESC LIMIT 1)
                        FROM Account
                        WHERE id = :pAccountId                              
                        LIMIT 1
                      ];
      
      result = AAs[0].Opportunities[0].id;
    }
    catch (Exception pEx) {
      result = null;
    }

    return result;
  }

  public static void updateOpportunity(WWTypes.OpportunityUpdate pOpportunityUpdate) {
    //get encoded id
    Id opportunity_id = EncodingHandler.decode(pOpportunityUpdate.encoded_opportunity_id);

    //get opportunity
    Opportunity[] Os = [  SELECT id
                          FROM Opportunity
                          WHERE id = :opportunity_id
                          LIMIT 1
                        ];
    if (Os.size() == 0) throw new OpportunityServicesException('Can\'t locate opportunity with provided encoded_id.');

    //get opportunity
    Opportunity o = Os[0];

    //opportunity binding
    o.Type__c                         = pOpportunityUpdate.opportunity_type;
    //o.Community_Manager__c            = pOpportunityUpdate.community_manager_uuid;
    o.Number_of_Desks__c              = pOpportunityUpdate.desk_number;
    o.Actual_Start_Date__c            = pOpportunityUpdate.actual_start_date;
    o.Parking_Fees__c                 = pOpportunityUpdate.parking_fee;
    o.Number_of_phones__c             = pOpportunityUpdate.number_of_phones;
    o.Phone_Setup_Fee__c              = pOpportunityUpdate.phone_setup_fee;
    o.Setup_Fee__c                    = pOpportunityUpdate.setup_fee;
    o.International_Calling__c        = pOpportunityUpdate.international_calling;
    o.Membership_Agreement_Notes__c   = pOpportunityUpdate.membership_agreement_notes;
    o.Internal_Transfer_Encoded_ID__c = pOpportunityUpdate.internal_transfer_encoded_id;
    o.LeadSource                      = pOpportunityUpdate.lead_source;
    o.Lead_Source_Detail__c           = pOpportunityUpdate.lead_source_details;
    o.Building__c                     = BuildingHandler.getBuildingIdByUUID(pOpportunityUpdate.building_uuid);
    o.Locations_Interested__c         = BuildingHandler.getMultipicklistValuesFromUUID(pOpportunityUpdate.locations_interested_uuids);
    
    //dml
    update o;

    //Discounts: Let's remove all existing discounts and replace with 
    //the ones (if any) that are given. Even if there's a discount in
    //Salesforce and we send paperwork from Spacestation with no discount, 
    //this should overwrite the discount that was previously indicated. 
    //create discounts records        
    if (pOpportunityUpdate.discounts != null) {
      //create discounts
      Discount__c[] Ds = new Discount__c[]{};

      //delete existing discounts
      delete [SELECT id FROM Discount__c WHERE Opportunity__c = :o.id];

      //collect discounts
      for (WWTypes.Discount d : pOpportunityUpdate.discounts) {
        Ds.add(
          new Discount__c(
            Opportunity__c    = o.id,
            Amount__c         = d.amount,
            Start_date__c     = d.start_date,
            End_Date__c       = d.end_date,
            Discount_Type__c  = d.discount_type,
            Promotion_Code__c = d.promotion_code,
            Promotion_Override__c = d.promotion_override
          )
        );
      }
      insert Ds;
    }
    
    //Reservables: All reservables on the Opportunity whose uuid is not present 
    //in the reservable_uuids provided should be removed from the Opportunity.
    if (pOpportunityUpdate.reservable_uuids != null) {
      //get reservables
      Reservable__c[] Rs = [SELECT id
                            FROM Reservable__c
                            WHERE uuid__c IN :pOpportunityUpdate.reservable_uuids
                           ];
      if (Rs.size() == 0) throw new OpportunityServicesException('Can\'t locate reservables');

      //delete existing reservables
      delete [SELECT id FROM Opportunity_Reservable__c WHERE Opportunity__c = :o.id];
      
      //create opportunity reservables
      Opportunity_Reservable__c[] ORs = new Opportunity_Reservable__c[]{};
      for (Reservable__c r : Rs) {
        ORs.add(
          new Opportunity_Reservable__c(
            Opportunity__c  = o.id,
            Reservable__c   = r.id
          )
        );    
      }      
      insert ORs;
    }
    

  }

  public static void insertOpportunity(WWTypes.OpportunityInsert pOpportunityInsert) {
    //get account
    Account[] a = [ SELECT id, primary_member__c 
                    FROM Account 
                    WHERE uuid__c = :pOpportunityInsert.company_uuid 
                    LIMIT 1
                  ];
    if (a.size() == 0) throw new OpportunityServicesException('Can\'t locate account with provided uuid.');
    if (a[0].primary_member__c == null) throw new OpportunityServicesException('The account has no primary member');

    //get reservables
    Reservable__c[] Rs = [SELECT id
                          FROM Reservable__c
                          WHERE uuid__c IN :pOpportunityInsert.reservable_uuids
                         ];
    if (Rs.size() == 0) throw new OpportunityServicesException('Can\'t locate reservables');

    //get building
    Building__c[] b = [ SELECT id
                        FROM Building__c
                        WHERE uuid__c = :pOpportunityInsert.building_uuid
                        LIMIT 1
                      ];
    if (b.size() == 0) throw new OpportunityServicesException('Can\'t locate building');

    //create opportunity
    Opportunity o = new Opportunity(
      CloseDate                         = system.today(),
      Name                              = 'Inbound cloned opportunity',
      AccountID                         = a[0].id,
      Primary_member__c                 = a[0].primary_member__c,
      Number_of_Desks__c                = pOpportunityInsert.desk_number,
      Type__c                           = pOpportunityInsert.opportunity_type,
      Actual_Start_Date__c              = pOpportunityInsert.actual_start_date,
      Building__c                       = b[0].id,
      StageName                         = 'Wait List',
      Parking_Fees__c                   = pOpportunityInsert.parking_fee,
      Number_of_Phones__c               = pOpportunityInsert.number_of_phones,
      International_Calling__c          = pOpportunityInsert.international_calling,
      Membership_Agreement_Notes__c     = pOpportunityInsert.membership_agreement_notes,
      Phone_Setup_Fee__c                = pOpportunityInsert.phone_setup_fee,
      Setup_Fee__c                      = pOpportunityInsert.setup_fee,
      LeadSource                        = pOpportunityInsert.lead_source,
      Lead_Source_Detail__c             = pOpportunityInsert.lead_source_details,
      Internal_Transfer_Encoded_Id__c   = pOpportunityInsert.internal_transfer_encoded_id,
      Locations_Interested__c           = BuildingHandler.getMultipicklistValuesFromUUID(pOpportunityInsert.locations_interested_uuids)
    );
    insert o;

    //create opportunity reservables
    Opportunity_Reservable__c[] ORs = new Opportunity_Reservable__c[]{};
    for (Reservable__c r : Rs) {
      ORs.add(
        new Opportunity_Reservable__c(
          Opportunity__c  = o.id,
          Reservable__c   = r.id
        )
      );    
    }      
    insert ORs;

    //create discounts records
    Discount__c[] Ds = new Discount__c[]{};
    if (pOpportunityInsert.discounts != null)
      for (WWTypes.Discount d : pOpportunityInsert.discounts) {
        Ds.add(
          new Discount__c(
            Opportunity__c    = o.Id,
            Amount__c         = d.amount,
            Start_date__c     = d.start_date,
            End_Date__c       = d.end_date,
            Discount_Type__c  = d.discount_type,
            Promotion_Code__c = d.promotion_code,
            Promotion_Override__c = d.promotion_override
          )
        );
      }
    insert Ds;

    //update stage to Contract Sent
    try {
    	OpportunityServices.sendContract(o.Id);
    } catch (Exception e) {
    	delete o;
    	throw e;
    }
  }

  /**
  * updates an opportunity stage to contract sent with all the custom validation logic
  */
  public static void sendContract(Id pOpportunityID) {
    
    if (pOpportunityID == null) throw new OpportunityServicesException('The Opportunity ID is undefined');

    Opportunity o = [ SELECT StageName 
                      FROM Opportunity 
                      WHERE Id = :pOpportunityID 
                      LIMIT 1 
                    ];

    //check if the opportunity was already sent
    if (o.StageName == 'Contract Sent') throw new OpportunityServicesException('The contact was already sent');

    //check all reservables available or not Archived on
    if (!OpportunityServices.areAllReservablesAvailable(pOpportunityID)) 
      throw new OpportunityServicesException('One of the selected reservables is not available or was archived. Please correct and resend the contract again.');

    //check if reservable is used for other Opportunity
    if (OpportunityServices.areReservablesUsedInOtherOpportunity(pOpportunityID)) 
      throw new OpportunityServicesException('This reservable is used in another contract. Please verify and resend again.');
    
    //check if all reservables are with open date at opportunity's actual start date
    if (!OpportunityServices.areAllReservablesOpenAtActualStartDate(pOpportunityID)) 
      throw new OpportunityServicesException('Opportunity Actual Start Date is before Reservable Open Date. Please correct and resend the contract again.');
    
    //check if all reservables has last move out date = null OR BEFORE Opportunity's actual start date
    if (!OpportunityServices.areAllReservablesMoveOutDateBeforeStartDate(pOpportunityID)) 
      throw new OpportunityServicesException('Actual Start Date selected is before Reservable Last Move Out date. Please correct and resend again.');

    //check if any of Opportunity Reservables.Reservable.Budilding is not equal Opportunity.Building, then don't allow to send the contract.
    if (!OpportunityServices.areAllReservablesBuildingMatching(pOpportunityID))
      throw new OpportunityServicesException('Opportunity Building and Reservable Building do not match. You have to select the reservables from the Building indicated on Opportunity.');
    
    //set send contract button used
    o.Send_Contract_Button_Used__c = true;

    //set stage
    o.StageName = 'Contract Sent';

    //dml
    update o;
  }

  private static Boolean areAllReservablesMoveOutDateBeforeStartDate(Id pOpportunityID) {
    Boolean result = true; //pass
    try {
      //select reservables from all opportunity reservables
      for (Opportunity_Reservable__c r : [  SELECT Reservable__r.Status__c, 
                                                   Reservable__r.Status_Right_Now__c, 
                                                   Reservable__r.Last_Move_Out__c,
                                                   Reservable__r.Open_Date__c,
                                                   Opportunity__r.Actual_Start_Date__c 
                                            FROM Opportunity_Reservable__c
                                            WHERE Opportunity__c = :pOpportunityID
                                          ]) {

        String right_now = r.Reservable__r.Status_Right_Now__c != null ? 
                            r.Reservable__r.Status_Right_Now__c : 
                            '';

        Date move_out_date      = r.Reservable__r.Last_Move_Out__c;
        Date open_date          = r.Reservable__r.Open_Date__c;
        Date actual_start_date  = r.Opportunity__r.Actual_Start_Date__c;

        //available
        if ( r.Reservable__r.Status__c == 'Available') {
          if ( right_now.equalsIgnoreCase('Occupied') || right_now.equalsIgnoreCase('Unoccupied') ) {
            if ( move_out_date != null) {
              result = result &&
                        move_out_date < actual_start_date;                        
            }
            else { // move_out_date = null
              result = result &&
                        open_date <= actual_start_date;
            }            
          }          
        }

        //status = unavailable
        if (r.Reservable__r.Status__c == 'Unavailable') result = result && false;

      }
    }
    catch(Exception pEx) {
      result = false; //default value
    }
    
    return result;
  }

  private static Boolean areReservablesUsedInOtherOpportunity(Id pOpportunityID) {
    //container
    Set<Id> SReservablesID = new Set<Id>();
    Boolean result = false;

    try {
      //collect reservables from opportunity reservables
      for (Opportunity_Reservable__c r : [  SELECT Reservable__c
                                            FROM Opportunity_Reservable__c
                                            WHERE Opportunity__c = :pOpportunityID
                                          ]) 
        SReservablesID.add(r.Reservable__c);

      //select target reservables with contract sent
      Opportunity_Reservable__c[] ORs = [ SELECT id 
                                          FROM Opportunity_Reservable__c
                                          WHERE 
                                            Opportunity__r.StageName = 'Contract Sent' AND
                                            Reservable__r.Office_Work_Station_Type__c <> 'HotDeskArea' AND
                                            Reservable__c IN :SReservablesID
                                        ];

      //check if there are reservables in a Contract sent opportunity
      result = ORs.size() > 0;
    }
    catch(Exception pEx) {
      result = false; //default value
    }
    return result;
  }

  private static Boolean areAllReservablesAvailable(Id pOpportunityID) {
    Boolean result = true;
    try {
      //select reservables from all opportunity reservables
      for (Opportunity_Reservable__c r : [  SELECT Reservable__r.Status__c, 
                                                   Reservable__r.Archived_On__c 
                                            FROM Opportunity_Reservable__c
                                            WHERE Opportunity__c = :pOpportunityID
                                          ]) {
        //check availability
        result =  result && 
                  r.Reservable__r.Status__c == 'Available' && 
                  r.Reservable__r.Archived_On__c == null;
      }
    }
    catch(Exception pEx) {
      result = false; //default value
    }
    
    return result;
  }


  private static Boolean areAllReservablesOpenAtActualStartDate(Id pOpportunityID) {
    Boolean result = true;
    try {
      //select reservables from all opportunity reservables
      for (Opportunity_Reservable__c r : [  SELECT Reservable__r.Open_Date__c,
                                                   Opportunity__r.Actual_Start_Date__c 
                                            FROM Opportunity_Reservable__c
                                            WHERE Opportunity__c = :pOpportunityID
                                          ]) {
        //check availability
        result =  result && 
                  r.Opportunity__r.Actual_Start_Date__c != null &&
                  r.Reservable__r.Open_Date__c != null &&
                  r.Reservable__r.Open_Date__c <= r.Opportunity__r.Actual_Start_Date__c;
      }
    }
    catch(Exception pEx) {
      result = false; //default value
    }
    
    return result;
  }

  private static Boolean areAllReservablesBuildingMatching(Id pOpportunityID) {
    Boolean result = true;
    try {
      //select reservables from all opportunity reservables
      for (Opportunity_Reservable__c r : [  SELECT Reservable__r.Building__c,
                                                   Opportunity__r.Building__c
                                            FROM Opportunity_Reservable__c
                                            WHERE Opportunity__c = :pOpportunityID
                                          ]) {
        //check availability
        result =  result && 
                  r.Opportunity__r.Building__c == r.Reservable__r.Building__c;
      }
    }
    catch(Exception pEx) {
      result = false; //default value
    }
    
    return result;
  }
      
  public static WWTypes.OpportunityDetails getOpportunityDetails(Id pOpportunityID) {
    WWTypes.OpportunityDetails result = new WWTypes.OpportunityDetails();

    //select the opportunity
    Opportunity o = [ SELECT id, name, accountID, StageName, Type__c,
                        Building__r.UUID__c, Building__r.Responsible_CM__r.Name, Building__r.email__c, Building__r.Community_Manager__r.Name,
                        actual_start_date__c, 
                        office_type__c,
                        Encoded_ID__c, 
                        Setup_Fee__c, 
                        Total_Desks_Reserved__c, Office_Conference_Room_Credits__c,
                        Monthly_Prints_Color_Total__c, Parking_Fees__c, International_calling__c,
                        Monthly_Payment_Method__c, Membership_Agreement_Notes__c, Monthly_Prints_B_W_Total__c, 
                        Number_of_Phones__c, Number_of_Desks__c,
                        Network_Set_Up_Fee__c, 
                        Network_Monthly_Membership_Fee__c,
                        Network_Monthly_Conference_Room_Credits__c,
                        Mail_and_Package_Handling__c,
                        Phone_Setup_Fee__c,
                        LeadSource,
                        Lead_Source_Detail__c,
                        Locations_Interested__c
                      FROM Opportunity 
                      WHERE id = :pOpportunityID 
                      LIMIT 1
                    ];

    //company
      Account a = [ SELECT id, name, legal_name__c, industry, company_size__c, funding_status__c, 
                            primary_member__c, uuid__c, has_non_wework_space__c, authorized_signatory__c
                    FROM Account
                    WHERE id = :o.accountID
                    LIMIT 1
                  ];
      //binding           
      result.company                      = new WWTypes.Company();
      result.company.name                 = a.name;
      result.company.legal_name           = a.legal_name__c;
      result.company.industry             = a.industry;
      result.company.size                 = a.company_size__c;
      result.company.funding              = a.funding_status__c;
      result.company.salesforce_id        = a.id;
      result.company.uuid                 = a.UUID__c;
      result.company.has_non_wework_space = a.has_non_wework_space__c;

    //primary member
      Contact pm = [  SELECT id, uuid__c, name, firstname, lastname, createddate,
                            email, phone, birthdate, gender__c, status__c,
                            mailingstreet, mailingcity, mailingstate, mailingpostalcode, mailingcountry
                      FROM Contact
                      WHERE id = :a.primary_member__c
                      LIMIT 1
                   ];
      //binding
      result.primary_member                 = new WWTypes.Member();
      result.primary_member.name            = pm.name;
      result.primary_member.first_name      = pm.firstname;
      result.primary_member.last_name       = pm.lastname;
      result.primary_member.uuid            = pm.uuid__c;
      result.primary_member.email           = pm.email;
      result.primary_member.gender          = pm.gender__c;
      result.primary_member.phone           = pm.phone;
      result.primary_member.salesforce_id   = pm.id;
      result.primary_member.date_of_birth   = pm.birthdate;
      result.primary_member.status          = pm.status__c;
      result.primary_member.address         = new WWTypes.Address();
      result.primary_member.address.street  = pm.mailingstreet;
      result.primary_member.address.city    = pm.mailingcity;
      result.primary_member.address.state   = pm.mailingstate;
      result.primary_member.address.zip     = pm.mailingpostalcode;
      result.primary_member.address.country = pm.mailingcountry;
      result.primary_member.created_at      = pm.createddate;
    
    //authorized signatory
      if (a.Authorized_Signatory__c != null) {
        Contact aus = [ SELECT name, email, createddate, uuid__c 
                        FROM Contact 
                        WHERE id = :a.Authorized_Signatory__c 
                        LIMIT 1
                      ];  
        //binding
        result.authorized_signatory             = new WWTypes.Member();
        result.authorized_signatory.name        = aus.name;
        result.authorized_signatory.email       = aus.email;
        result.authorized_signatory.uuid        = aus.uuid__c;
        result.authorized_signatory.created_at  = aus.createddate;
      }
      
    //reservables
      //collect
      for (Opportunity_Reservable__c opr : [ SELECT Reservable__r.name, 
                                                Reservable__r.office_work_station_type__c,
                                                Reservable__r.office_work_station_number__c,
                                                Reservable__r.uuid__c,
                                                Reservable__r.office_capacity__c,
                                                conference_room_credits__c,
                                                monthly_Prints_Copies_B_W__c, 
                                                monthly_Prints_Copies_Color__c,
                                                monthly_Price__c
                                              FROM Opportunity_Reservable__c
                                              WHERE Opportunity__c = :pOpportunityID                                    
                                          ]) {
        //binding
        WWTypes.Reservable r      = new WWTypes.Reservable();
        r.name                    = opr.Reservable__r.name;
        r.type                    = opr.Reservable__r.office_work_station_type__c;
        r.station_number          = opr.Reservable__r.office_work_station_number__c;
        r.reservable_uuid         = opr.Reservable__r.uuid__c;
        r.prints_black_white      = opr.Monthly_Prints_Copies_B_W__c;
        r.prints_color            = opr.Monthly_Prints_Copies_Color__c;
        r.monthly_price           = opr.Monthly_Price__c;
        r.capacity                = opr.Reservable__r.office_capacity__c;
        r.conference_room_credits = opr.Conference_Room_Credits__c;
        result.reservables.add(r);
      }

    //members
      //collect
      for (Contact c : [  SELECT name, firstname, lastname, email, phone, createddate, 
                                 birthdate, gender__c, status__c, id, uuid__c
                          FROM Contact
                          WHERE 
                            AccountID = :a.id AND
                            Id <> :a.primary_member__c
                        ]) {
        WWTypes.Member m  = new WWTypes.Member();
        m.name            = c.name;
        m.first_name      = c.firstname;
        m.last_name       = c.lastname;
        m.email           = c.email;
        m.phone           = c.phone;
        m.uuid            = c.UUID__c;
        m.date_of_birth   = c.birthdate;
        m.gender          = c.Gender__c;
        m.status          = c.Status__c;
        m.salesforce_id   = c.id;
        m.created_at      = c.createddate;
        result.members.add(m);
      }

    //discounts
      //collect
      for (Discount__c s : [  SELECT amount__c, discount_type__c, start_date__c, end_date__c,promotion_code__c,promotion_override__c
                              FROM Discount__c
                              WHERE Opportunity__c = :o.Id
                            ]) {
        WWTypes.Discount d = new WWTypes.Discount();
        d.amount        = s.amount__c;
        d.discount_type = s.discount_type__c;
        d.start_date    = s.start_date__c;
        d.end_date      = s.end_date__c;
        d.promotion_code = s.promotion_code__c;
        d.promotion_override = s.promotion_override__c;
        result.discounts.add(d);
      }
      
    //root level fields
    result.salesforce_id                  = o.Id;
    result.opportunity_stage              = o.StageName;
    result.opportunity_type               = o.Type__c;
    result.encoded_opportunity_id         = o.Encoded_ID__c;
    result.location_uuid                  = o.Building__r.UUID__c;
    result.actual_start_date              = o.Actual_Start_Date__c;
    result.setup_fee                      = o.Setup_Fee__c;
    result.total_desks_reserved           = o.Total_Desks_Reserved__c;
    result.office_conference_room_credits = o.Office_Conference_Room_Credits__c;
    result.prints_color                   = o.Monthly_Prints_Color_Total__c;
    result.prints_black_white             = o.Monthly_Prints_B_W_Total__c;
    result.parking_fee                    = o.Parking_Fees__c;
    result.international_calling          = o.International_Calling__c;
    result.payment_method                 = o.Monthly_Payment_Method__c;
    result.notes                          = o.Membership_Agreement_Notes__c;
    result.number_of_phones               = o.Number_of_Phones__c;
    result.number_of_desks                = o.Number_of_Desks__c;
    if(o.Building__r != null && o.Building__r.Community_Manager__r != null)
    	result.responsible_community_manager  = o.Building__r.Community_Manager__r.Name;
    else
    	result.responsible_community_manager = o.Building__r.Responsible_CM__r.Name;
    result.building_email                 = o.Building__r.email__c;
    result.phone_setup_fee                = o.Phone_Setup_Fee__c;
    result.lead_source                    = o.LeadSource;
    result.lead_source_details            = o.Lead_Source_Detail__c;
    result.locations_interested_uuids     = BuildingHandler.getUUIDsFromMultipicklistValues(o.Locations_Interested__c);
    result.office_types_interested        = Common.splitStringToList(o.Office_Type__c, ';');

    //Network Membership Details
    result.network_membership_details                           = new WWTypes.Network_Membership_Details();
    result.network_membership_details.setup_fee                 = o.Network_Set_Up_Fee__c;
    result.network_membership_details.fee                       = o.Network_Monthly_Membership_Fee__c;
    result.network_membership_details.conference_room_credits   = o.Network_Monthly_Conference_Room_Credits__c;
    result.network_membership_details.mail_and_package_handling = o.Mail_and_Package_Handling__c;

    return result;
  }

  //optimistic coding: if error detected, the caller will catch the exceptions
  public static void serializeOpportunityDetails(WWTypes.OpportunityDetails pOpportunityDetails) {
    //parse opportunityID
      Id opportunityID = Id.valueOf(pOpportunityDetails.salesforce_id);

    //opportunity
      Opportunity o = [ SELECT id, name, Monthly_Payment_Method__c
                        FROM Opportunity
                        WHERE id = :opportunityID
                        LIMIT 1
                      ];
      //root binding
      o.Monthly_Payment_Method__c = pOpportunityDetails.payment_method;
      o.Phone_Setup_Fee__c        = pOpportunityDetails.phone_setup_fee;

      //dml
      update o;
     
    //company
      Account a = [ SELECT id, name, legal_name__c, industry, company_size__c, funding_status__c, has_non_wework_space__c
                    FROM Account
                    WHERE id = :pOpportunityDetails.company.salesforce_id
                    LIMIT 1
                  ];
      
      //bindings
      a.name                    = pOpportunityDetails.company.name;
      a.legal_name__c           = pOpportunityDetails.company.legal_name;
      a.industry                = pOpportunityDetails.company.industry;
      a.company_size__c         = pOpportunityDetails.company.size;
      a.funding_status__c       = pOpportunityDetails.company.funding;
      a.has_non_wework_space__c = pOpportunityDetails.company.has_non_wework_space;
      //dml
      update a;
      

    //primary member
    
      Contact pm = [  SELECT id, accountId, uuid__c, name, firstname, lastname, email, phone, birthdate, gender__c, 
                            mailingstreet, mailingcity, mailingstate, mailingpostalcode, Account_UUID__c
                      FROM Contact
                      WHERE id = :pOpportunityDetails.primary_member.salesforce_id
                      LIMIT 1 ];
                      
      Contact[] pmByemail = [  SELECT id, accountId, uuid__c, name, firstname, lastname, email, phone, birthdate, gender__c, Status__c,
                            mailingstreet, mailingcity, mailingstate, mailingpostalcode, Account_UUID__c, Primary_Member__c
                      FROM Contact
                      WHERE email = :pOpportunityDetails.primary_member.email AND id != :pOpportunityDetails.primary_member.salesforce_id ];
                      
      if (pmByEmail.size() > 0) {
      	Contact existing = pmByEmail[0];
      	
      	// If the found duplicate is an active licensee of a different account, raise an error
      	if (existing.Primary_Member__c == 'Yes' && existing.Status__c == 'active' && existing.Account_UUID__c != pm.Account_UUID__c) {
      		throw new OpportunityServicesException('Attempted to change primary member to ' + existing.email + ', who is an active primary member for an existing company');
      	}
      	
      	pm.email = pOpportunityDetails.primary_member.email;
      	reconcileDuplicate(pm, existing, o, true);
      	pm = existing;
      }

	    pm.status__c          = 'active';
      pm.firstname          = pOpportunityDetails.primary_member.first_name;
      pm.lastname           = pOpportunityDetails.primary_member.last_name;
      pm.phone              = pOpportunityDetails.primary_member.phone;
      pm.birthdate          = pOpportunityDetails.primary_member.date_of_birth;
      pm.Gender__c          = pOpportunityDetails.primary_member.gender;
      pm.mailingstreet      = pOpportunityDetails.primary_member.address.street;
      pm.mailingcity        = pOpportunityDetails.primary_member.address.city;
      pm.mailingstate       = pOpportunityDetails.primary_member.address.state;
      pm.mailingpostalcode  = pOpportunityDetails.primary_member.address.zip;
      pm.mailingcountry     = pOpportunityDetails.primary_member.address.country;

      //dml
      update pm;

    //contact - members (we might have new contacts!)
      //containers
      Set<String> SContactEmails = new Set<String>();
      Set<Id> SContactIds = new Set<Id>();
      
      Contact[] upsertable_contacts = new Contact[]{}; 
      
      Map<String, Contact> existingContactsByEmail = new Map<String, Contact>();
      Map<Id, Contact> existingContactsById = new Map<Id, Contact>();

      //first pass collect existing Contact Emails or create new ones
      for(WWTypes.Member m : pOpportunityDetails.members) {
        if (m.email != null) 
          SContactEmails.add(m.email);
          
        if (m.salesforce_id != null && m.salesforce_id.length() > 0)
          SContactIds.add(m.salesforce_id);
      }

      //load existing contacts
      for ( Contact existing : [SELECT id, email, UUID__c FROM Contact WHERE email IN :SContactEmails and id NOT IN :SContactIds] ) {
      	if (existing != null && existing.email != null && existing.email.length() > 0)
      		existingContactsByEmail.put(existing.email, existing);
      }
      
      existingContactsById = new Map<Id, Contact>([  SELECT id, email, UUID__c, Status__c, accountId
                                                  FROM Contact 
                                                  WHERE id IN :SContactIds
                                              ]);
              
      
      //second pass to bind sObjects
      for(WWTypes.Member m : pOpportunityDetails.members) {        
        if (existingContactsById.containsKey(m.salesforce_id) ) {
          Contact c = existingContactsById.get(m.salesforce_id);
          
          // Resolve duplicate by email
          if (existingContactsByEmail.containsKey(m.email)) {
          	Contact existing = existingContactsByEmail.get(m.email);
          	reconcileDuplicate(c, existing, o, false);
          	c = existing;
          }
          
          c.firstname = m.first_name;
          c.lastname  = m.last_name;
          c.email     = m.email;
          c.phone     = m.phone;
          c.birthdate = m.date_of_birth;
          c.gender__c = m.gender;
          c.status__c = m.status;
          upsertable_contacts.add(c);
        } else if (existingContactsByEmail.containsKey(m.email)) {
          Contact existing = existingContactsByEmail.get(m.email);
          if (existing != null) {
            existing.AccountID = a.Id;
            existing.status__c = 'active';
            update existing;
          }
        }
        else { //create new contact
          upsertable_contacts.add(
            new Contact(
              firstname = m.first_name,
              lastname  = m.last_name,
              email     = m.email,
              phone     = m.phone,
              birthdate = m.date_of_birth,
              gender__c = m.gender,
              status__c = 'active',
              AccountID = a.Id
            )
          );
        }                
      }

      //dml
      upsert upsertable_contacts;
  }
  
  public static void reconcileDuplicate(Contact newContact, Contact existingContact, Opportunity opportunity, Boolean isPrimary) {
  	if (newContact.id == existingContact.id || newContact.email != existingContact.email) return;
   	newContact.UUID__c = null;
  	newContact.status__c = 'inactive';
  	newContact.email = newContact.email + '.dup' + datetime.now().format('yyMMdd');
  	
  	// Move existing record to account and make them the PM
  	existingContact.accountId = newContact.accountId;

	update newContact;
  	update existingContact;
  	
  	if (isPrimary) {
  		opportunity.primary_member__c = existingContact.id;	
  		update opportunity;
  	}
  }

  public static List<String> getEncodedOpportunityIdsForAccount(Id accountId) {
    //container
    List<String> results = new List<String>();

    //collect opportunities
    for (Opportunity o : [SELECT Encoded_ID__c FROM Opportunity WHERE accountId = :accountId])
      results.add(o.Encoded_ID__c);

    return results;
  }

  public class OpportunityServicesException extends Exception{}
  


}