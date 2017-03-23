global class WWTypes {
	
	global class Company {
		global String name;
		global String legal_name;
		global String printer_login;
		global String uuid;
		global Date start_date;
		global String building_uuid;
		global String status;
		global String industry;
		global String size;
		global String funding;
		global String salesforce_id;
		global Boolean has_non_wework_space;
	}

	global class Members {
		global Member[] users = new Member[]{};
	}

	global class Member {
		global String company_uuid;
		global Date date_of_birth;
		global String email;
		global String gender;
		global String key_card_number;
		global String key_card_batch;
		global String additional_phone;
		global String member_type;
		global String name;
		global String first_name;
		global String last_name;
		global String phone;
		global String status;
		global String kind;
		global String uuid;
		global Address address = new Address();
		global String salesforce_id;
		global Datetime created_at;
	}
    
    global class Person {
        global String contact_sfid;
		global String company_name;
		global String email;
		global String first_name;
		global String last_name;
		global String phone;
		global String type;
        global String contact_uuid;
        global String account_uuid;
        global String lead_source;
        global String lead_source_detail;
        global String utm_campaign_id; 
        global String utm_campaign;
        global String utm_content;
        global String utm_medium;
        global String utm_source;
        global String utm_term;
        global String locale;
        global String country_code;
	}
    
    global class PrimaryMember {
        global String contact_sfid;
		global String company_name;
		global String email;
		global String first_name;
		global String last_name;
		global String phone;
		global String type;
        global String contact_uuid;
	}

	global class Address {
		global String street;
		global String city;
		global String state;
		global String zip;
		global String country;
	}

	global class Payment {
		global Invitation invitation = new Invitation();
	}

	global class Invitation {
		global String user_uuid;
		global String location_uuid;
		global String company_name;
		global String primary_member_name;
		global String opportunity_id;
	}

	global class PaymentResult {
		global Meta meta;
		global Result result;
	}

	global class CompanyResult {
		global Meta meta;
		global Result result;
	}

	global class Meta {
		global Boolean success;
		global String version;
		global Integer httpStatus;
	}

	global class Result {
		global Datetime created_at;
		global Datetime deleted_at;
		global Integer id;
		global String name;
		global String notes;
		global Integer printer_login;
		global Integer printer_pin;
		global Date start_date;
		global String status;
		global Datetime updated_at;
		global String uuid;
		global Integer weconnect_id;
		global String error;
		global String stack;
		global Params params;
		global Boolean success;
		global String url;
	}

	global class MemberResult {
		global Meta meta;
		global Result[] result;
	}

	global class Params {
		global String name;
	}

	global class Network_Membership_Details {
		global Decimal fee;
		global Decimal setup_fee;
		global Decimal conference_room_credits;
		global Boolean mail_and_package_handling;
	}

  global class OpportunityInsert {
  	global String company_uuid;
    global String building_uuid;
    global String opportunity_type; 
   	global String community_manager_uuid;
    global Integer desk_number;
    global Date actual_start_date;
    global String[] reservable_uuids;
    global Discount[] discounts = new Discount[]{};
    global Decimal parking_fee;
    global Decimal number_of_phones;
    global Decimal phone_setup_fee;
    global Decimal setup_fee;
    global String international_calling;
    global String membership_agreement_notes;
    global String internal_transfer_encoded_id;
    global String lead_source;
	global String lead_source_details;
	global String[] locations_interested_uuids = new String[]{};
  }

  global class OpportunityUpdate {
  	global String encoded_opportunity_id;
  	global String company_uuid;
    global String building_uuid;
    global String opportunity_type; 
   	global String community_manager_uuid;
    global Integer desk_number;
    global Date actual_start_date;
    global String[] reservable_uuids;
    global Discount[] discounts = new Discount[]{};
    global Decimal parking_fee;
    global Decimal number_of_phones;
    global Decimal phone_setup_fee;
    global Decimal setup_fee;
    global String international_calling;
    global String membership_agreement_notes;
    global String internal_transfer_encoded_id;
    global String lead_source;
	global String lead_source_details;
	global String[] locations_interested_uuids = new String[]{};
  }
    
	global class OpportunityDetails {
		global Member primary_member;
		global Member authorized_signatory;
		global Company company;		
		global Reservable[] reservables = new Reservable[]{};
		global Member[] members = new Member[]{};
		global Network_Membership_Details network_membership_details;
		global String opportunity_stage;
		global String opportunity_type;
		global String encoded_opportunity_id;
		global String salesforce_id;
		global String location_uuid;
		global Date actual_start_date;
		global Decimal setup_fee;
		global Decimal number_of_phones;
		global Decimal number_of_desks;
		global Decimal total_desks_reserved;
		global Decimal office_conference_room_credits;
		global Decimal prints_color;
		global Decimal prints_black_white;
		global Decimal parking_fee;
		global Decimal phone_setup_fee;
		global Decimal additional_members;
		global String international_calling;
		global String notes;
		global String payment_method;
		global Discount[] discounts = new Discount[]{};
		global String responsible_community_manager;
		global String building_email;
		global String lead_source;
		global String lead_source_details;
		global String[] locations_interested_uuids = new String[]{};		
		global String[] office_types_interested = new String[]{};
	}

	global class Reservable {
		global String name;
		global String type;
		global String reservable_uuid;
		global Decimal prints_black_white;
		global Decimal prints_color;
		global Decimal monthly_price;
		global Decimal capacity;
		global Decimal conference_room_credits;
		global String station_number;
	}

	global class Discount {
		global Decimal amount;
		global String discount_type;
		global Date start_date;
		global Date end_date;
		global String promotion_code;
		global Boolean promotion_override;
	}

	global class Stage {
		global String name;
		global String reason;
	}

	global class BuildingAvailability {
		global String building_uuid;
		global TourDate[] dates = new TourDate[]{};
	}

	global class TourDate {
		global Date tour_date;
		global String[] times = new String[]{};
	}

	global class InboundLead {
		global String last_name; //required
		global String first_name;
		global String email; //required
		global String phone;
		global String lead_source;
		global String utm_campaign_id;
		global String utm_campaign;
		global String utm_content;
		global String utm_medium;
		global String utm_source;
		global String utm_term;
		global String referral_id;
		global String lead_source_detail;
		global String company_name; //required
		global String company_size;
		global String company_industry;
		global String lead_type;
		global String broker_name;
		global String broker_email;
		global String broker_phone;
		global String quick_quote_location;
		global String notes;
		global String referral_code;
		global String promo_code;
		global String[] buildings_interested_uuids = new String[]{};
		global Date tour_date;
		global String tour_time;
		global String tour_building_uuid;
		global String tour_notes;
		global String tour_uuid;
		global String account_uuid;
		global String contact_uuid;
		global String primary_member; // Contact SF Id
		global String original_tour; // Tour_Outcome__c SF Id
		global String[] product_interests = new String[]{};
		global String product_line;
		global String locale;
		global String country_code;
        global String referrer;
        global String referrer_sfid;
        global Boolean contact_referrer_only;
        global Boolean generate_journeys;
        global String market;
        global String campaign_sfid;
        global Boolean convert_opportunity;
	}

	global class TourDetail {
		global String last_name; 
		global String first_name;
		global String contact_name;
		global String contact_uuid;
		global String email; 
		global String phone;

		global String company_name;
		global String company_uuid;
		global String company_size;
		global String company_industry;
		global String number_of_desks;
	
		global String tour_status;
		global Date tour_date;      
		global String tour_time;
		global String tour_building_uuid;
		global String tour_notes;
		global String tour_outcome_notes;
		global String tour_referred_by_code;
		global String tour_referral_code;
		global String tour_id;
		global String tour_uuid;
		global String opportunity_id;

		global String lead_source;
		global String lead_source_detail;
        
        global String product_line;
	}

	global class Waitlist {
	global Date actual_start_date;
    global String[] buildings_interested_uuids = new String[]{};
    global String email;
    global String notes;
	}

}