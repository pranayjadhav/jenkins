public with sharing class LeadServices {
    public Lead k {get;set;}
    public Contact c {get;set;}
    public Campaign objCampaign {get;set;}
    public Boolean is_first_touch {get; set;}
    
    public LeadServices() {		
    }
    
    // Load init from Email
    public LeadServices(Messaging.inboundEmail email,
                        Messaging.InboundEnvelope env) {
                            //load lead
                            this.k = this.get_recent_lead_by_email(email.fromAddress);
                            
                            //load contact
                            this.c = this.get_contact_by_email(email.fromAddress);
                            
                            //if new create a new lead
                            if (this.set_first_touch()) insert_lead_by_email(email, env);
                        }
    
    // Load init from Web Handler
    public LeadServices(WWTypes.InboundLead pInboundLead) {
        /*
        //load lead
        this.k = this.get_recent_lead_by_email(pInboundLead.email);
        
        //load contact
        this.c = this.get_contact_by_email(pInboundLead.email);
        //Anant Kumar on 6th May 2016
        //ST-289
        if(this.c != null){
            if(pInboundLead.referrer_sfid != null){
                if(this.c.Account.Type == 'Member' || this.c.Account.Type == 'Previous Member')
                    throw new applicationException('A member with given email exists');
                //if(this.k.Opportunities__r != null)
                for(Opportunity opp : this.c.Opportunities__r){
                    Integer contractSentDateDiff, contractSignedDateDiff;
                    if(opp.Contract_Sent_Date__c != null)
                        contractSentDateDiff = opp.Contract_Sent_Date__c.daysBetween(System.today());
                    if(opp.StageName == 'Closed Won')
                        contractSignedDateDiff = opp.CloseDate.daysBetween(System.today());
                    
                    if(contractSentDateDiff < 60 || contractSignedDateDiff < 60){
                        throw new applicationException('Person has a contract sent/signed in last 60 days');
                    }
                }
                for(Tour_Outcome__c tour : this.c.Tours__r){
                    DateTime createdDateTime = tour.CreatedDate;
                    Date createdDate = date.newinstance(createdDateTime.year(), createdDateTime.month(), createdDateTime.day());
                    Integer dayesBetweenCreatedAndToday = createdDate.daysBetween(System.today());
                    if(dayesBetweenCreatedAndToday <= 60){
                        throw new applicationException('Person has booked a tour with us in last 60 days');
                    }
                }
            }
            
            if(pInboundLead.campaign_sfid != null){
            	if(pInboundLead.campaign_sfid !=''){
		        	try{
		        		this.objCampaign = [SELECT ID From Campaign Where Id = : pInboundLead.campaign_sfid];
		        	}catch(Exception pEx){
		        		throw new applicationException('Campaign with specified campaign_sfid does not exists');
		        	}
            	}
       		}

            RESTInboundLead.contactId = this.c.Id;
        }*/
        
        validationInbloundRecord(pInboundLead);
        
        if(this.c != null)
        	RESTInboundLead.contactId = this.c.Id;
        
        //if the lead exists and is not converted, we should update it
        if (this.k != null && !this.k.isConverted) {
            this.update_lead_by_web(pInboundLead);
        }
        
        
        //if the contact exists and not sent from a tour endpoint, send a notification
        /* As Rachell requested to turn it off on Staging and Production.
         * 10 May 2016 
        if (this.c != null && pInboundLead.tour_date == null && pInboundLead.tour_building_uuid == null) {
            this.send_notification_for_manual_process(pInboundLead);
        }
		*/
        
        //if new, create new lead
        if (this.set_first_touch()) this.insert_lead_by_web(pInboundLead);
        
    }
    
    public void convert_lead() {
        //convert lead
        Database.LeadConvert lc = new Database.LeadConvert();
        lc.setLeadId(this.k.id);
        
        LeadStatus convertStatus = [SELECT Id, MasterLabel 
                                    FROM LeadStatus 
                                    WHERE IsConverted=true 
                                    LIMIT 1
                                   ];
        
        lc.setConvertedStatus(convertStatus.MasterLabel);
        
        Database.LeadConvertResult lcr = Database.convertLead(lc);
        
        //re-query
		this.k = [	SELECT id, ownerId, Locale__c, Product_Interests__c, Country_Code__c, Product_Line__c, isConverted, convertedContactId, convertedAccountId, 
                  convertedOpportunityId, CreatedDate, LastModifiedDate
                  FROM Lead 
                  WHERE id = :k.id 
                  LIMIT 1
                 ];
        //update account's primary member
        Account a = new Account(
            id = this.k.convertedAccountId,
            Primary_Member__c = this.k.convertedContactId
        );
        update a;
        
        //update contact's locale
        Contact contactToUpdateLocale = new Contact(
            id = this.k.convertedContactId,
            Locale__c = this.k.Locale__c,
            Product_Interests__c = this.k.Product_Interests__c,
            Product_Line__c = this.k.Product_Line__c,
            Country_Code__c = this.k.Country_Code__c
        );
        update contactToUpdateLocale;
                
        //update opportunity's primary member
        Opportunity o = new Opportunity(
            id = this.k.convertedOpportunityId,
            Primary_Member__c = this.k.convertedContactId
        );
        update o;
        
    }
    
    public void validationInbloundRecord(WWTypes.InboundLead pInboundLead)
    {
    	//load lead
        this.k = this.get_recent_lead_by_email(pInboundLead.email);
        //load contact
        this.c = this.get_contact_by_email(pInboundLead.email);
		
        // Anant Kumar on 6th May 2016(ST-289)
        // Changes made by : Anant Kumar(ST-472)
        // Date : 19/July/2016
        Id referrerId = null;
        if(pInboundLead.referrer_sfid != null)
        {
            if(this.k != null){
                DateTime createdLeadDateTime = this.k.CreatedDate;
                Date createdDate = date.newinstance(createdLeadDateTime.year(), createdLeadDateTime.month(), createdLeadDateTime.day());
                Integer dayesBetweenCreatedAndToday = createdDate.daysBetween(System.today());
                if(dayesBetweenCreatedAndToday <= 60)
                    throw new applicationException('A lead with given email was already submitted in last 60 days');
            }
            
            if(this.c != null)
            {
                if(this.c.Account.Type == 'Member' || this.c.Account.Type == 'Previous Member')
                    throw new applicationException('A member with given email exists');

                //if(this.k.Opportunities__r != null)
                for(Opportunity opp : this.c.Opportunities__r){
                    Integer contractSentDateDiff, contractSignedDateDiff;
                    if(opp.Contract_Sent_Date__c != null)
                        contractSentDateDiff = opp.Contract_Sent_Date__c.daysBetween(System.today());
                    if(opp.StageName == 'Closed Won')
                        contractSignedDateDiff = opp.CloseDate.daysBetween(System.today());
                    
                    if(contractSentDateDiff < 60 || contractSignedDateDiff < 60){
                        throw new applicationException('Person has a contract sent/signed in last 60 days');
                    }
                }
                for(Tour_Outcome__c tour : this.c.Tours__r){
                    DateTime createdTourDateTime = tour.CreatedDate;
                    Date createdTourDate = date.newinstance(createdTourDateTime.year(), createdTourDateTime.month(), createdTourDateTime.day());
                    Integer dayesBetweenTourCreatedAndToday = createdTourDate.daysBetween(System.today());
                    if(dayesBetweenTourCreatedAndToday <= 60){
                        throw new applicationException('Person has booked a tour with us in last 60 days');
                    }
                }
        	}
        	Contact referral = [SELECT Email FROM Contact WHERE Id=:pInboundLead.referrer_sfid];
        	referrerId = ReferenceHandler.getActiveReference(referral.email);
        	if(referrerId == null)
	        {
	        	Reference__c reference = new Reference__c();
	        	reference.Referenced_Email__c = pInboundLead.email;
	        	reference.Expires_On__c = System.today().addDays(60);
	        	reference.Referrer__c = pInboundLead.referrer_sfid;
	        	reference.Start_Date__c = System.today();
	        	insert reference;
	        }
        }
        
        if(this.c != null && pInboundLead.campaign_sfid != null){
        	if(pInboundLead.campaign_sfid !=''){
	        	try{
	        		this.objCampaign = [SELECT ID From Campaign Where Id = : pInboundLead.campaign_sfid];
	        	}catch(Exception pEx){
	        		throw new applicationException('Campaign with specified campaign_sfid does not exists');
	        	}
        	}
   		}
    }
    
    private void update_lead_by_web(WWTypes.InboundLead pInboundLead) {
        //bindings
        this.lead_bind('firstname', 					pInboundLead.first_name);
        this.lead_bind('lastname', 						pInboundLead.last_name);
        this.lead_bind('company', 						pInboundLead.company_name);
        this.lead_bind('industry', 						pInboundLead.company_industry);		
        this.lead_bind('phone', 						pInboundLead.phone);		
        this.lead_bind('broker_company_name__c', 		pInboundLead.broker_name);
        this.lead_bind('broker_email__c', 				pInboundLead.broker_email);
        this.lead_bind('broker_phone__c', 				pInboundLead.broker_phone);
        this.lead_bind('promo_code__c', 				pInboundLead.promo_code);
        this.lead_bind('referral_id__c', 				pInboundLead.referral_id);
        this.lead_bind('referral_code__c', 				pInboundLead.referral_code);
        this.lead_bind('locations_interested__c', 		BuildingHandler.getMultipicklistValuesFromUUID(pInboundLead.buildings_interested_uuids));
        this.lead_bind('last_inbound_lead_received_at__c', 	Datetime.now());
        this.lead_bind('description', 					pInboundLead.notes);
        this.lead_bind('quick_quote_location__c', 		pInboundLead.quick_quote_location);
        //this.lead_bind('Type__c', 		pInboundLead.lead_type);
        //this.lead_bind('Market__c', 		pInboundLead.market);
        
        //this.lead_bind('Product_Interests__c', 				getProduct_Interests(pInboundLead.product_interests));
        //this.lead_bind('Product_Line__c', 				pInboundLead.product_line);
        //dml
        
        //Hemanshu Shah on 8th Apr 2016
        //If a lead is assigned to a queue, salesforce throws error on conversion, hence following code was added to assign the lead to current user
        if(k.OwnerId == null || ((String)k.OwnerId).startswith('00G'))
            k.OwnerId = UserInfo.getUserId();
        
        if(pInboundLead.campaign_sfid != null){
        	if(pInboundLead.campaign_sfid !=''){
	        	if(this.k.Id != null){
		        	try{
		        		this.objCampaign = [SELECT ID From Campaign Where Id = : pInboundLead.campaign_sfid];	
		        	}catch(Exception pEx){
		        		throw new applicationException('Campaign with specified campaign_sfid does not exists');
		        	}
	        	}
        	}
        }
        
        //Anant Kumar on 6th May 2016
        //ST-289
        if(pInboundLead.referrer_sfid != null){
            DateTime createdDateTime = this.k.CreatedDate;
			Date createdDate = date.newinstance(createdDateTime.year(), createdDateTime.month(), createdDateTime.day());
            Integer dayesBetweenCreatedAndToday = createdDate.daysBetween(System.today());
            if(dayesBetweenCreatedAndToday <= 60){
                throw new applicationException('A lead with given email was already submitted in last 60 days');
            }
            else{
                this.k.Referrer__c = pInboundLead.referrer_sfid;
                this.k.Contact_Broker__c = pInboundLead.contact_referrer_only;
                
                /*TaskServices taskServiceObj = new TaskServices();
                Task task = taskServiceObj.create_task_from_web(pInboundLead);
                task.WhoId = (Id)pInboundLead.referrer_sfid;
                insert task;*/
            }
        }
        
        //Anant Kumar on 6th May 2016
        //Functionality to return salesforce id of the lead
        update this.k;
        RESTInboundLead.leadId = this.k.Id;

    }
    
    private void lead_bind(String pField, Object pValue) {
        if (pValue != null)
            this.k.put(pField, pValue);
    }
    /*
    private void send_notification_for_manual_process(WWTypes.InboundLead pInboundLead) {
        ApexNotificationServices.generic_notify(
            'rachell.bordoy@wework.com', 
            'New InboundLead',
            String.format(
                'Hi there, new inquiry has been submitted for existing Lead or Contact ' + 
                'click <a href="{0}/{1}">here</a> to access and follow-up',
                new String[]{
                    URL.getSalesforceBaseURL().toExternalForm(),
                        this.c.id
                        }
            )
        );
    }*/
    
    private void insert_lead_by_web(WWTypes.InboundLead pInboundLead) {
        //use default assignment rule
        Savepoint sp = Database.setSavepoint();
        Database.DMLOptions dmo 								= new Database.DMLOptions();
        
        //Hemanshu Shah on 28 Apr 2016
        //If Lead is being created while not booking the tour, Lead assignment rules should be used,
        //If Lead is being created while booking a tour, Lead Owner should remain current user
        //We have to fix this because while creating lead for tour, if it was assigned to a queue, while converting salesforce was throwing error.
        dmo.assignmentRuleHeader.useDefaultRule = ( pInboundLead.tour_date == null && pInboundLead.tour_building_uuid == null);
        //dmo.assignmentRuleHeader.useDefaultRule = true;
        Debug.Log('LeadServices:insert_lead_by_web:assignmentRuleHeader.useDefaultRule:' + dmo.assignmentRuleHeader.useDefaultRule);
        
        //create new lead
        this.k = new Lead(
            firstname 							= pInboundLead.first_name,
            lastname 							= pInboundLead.last_name,
            company 							= pInboundLead.company_name,
            industry							= pInboundLead.company_industry,
            email 								= pInboundLead.email,
            phone								= pInboundLead.phone,
            leadsource 							= pInboundLead.lead_source,
            lead_source_detail__c				= pInboundLead.lead_source_detail,
            utm_campaign__c						= pInboundLead.utm_campaign,
            utm_content__c						= pInboundLead.utm_content,
            utm_medium__c						= pInboundLead.utm_medium,
            utm_source__c						= pInboundLead.utm_source,
            utm_term__c							= pInboundLead.utm_term,
            utm_campaign_id__c					= pInboundLead.utm_campaign_id,
            broker_company_name__c				= pInboundLead.broker_name,
            broker_email__c 					= pInboundLead.broker_email,
            broker_phone__c						= pInboundLead.broker_phone,
            Company_Size__c						= pInboundLead.company_size,
            promo_code__c						= pInboundLead.promo_code,
            referral_id__c 						= pInboundLead.referral_id,
            referral_code__c					= pInboundLead.referral_code,
            locations_interested__c   			= BuildingHandler.getMultipicklistValuesFromUUID(pInboundLead.buildings_interested_uuids),
            last_inbound_lead_received_at__c 	= Datetime.now(),
            description 						= pInboundLead.notes,
            Locale__c 					        = pInboundLead.locale,
            quick_quote_location__c 			= pInboundLead.quick_quote_location,
            Country_Code__c                     = pInboundLead.country_code,
            Product_Line__c                     = pInboundLead.product_line,
            Product_Interests__c			   	= getProduct_Interests(pInboundLead.product_interests),
           // Market__c							= pInboundLead.market,
            Generate_Journey__c                 = pInboundLead.generate_journeys
            //... more to come...
        );
        
        //Anant Kumar on 6th May 2016
        //ST-289 : update lead "Referrer" and "Contact_Broker"
        if(pInboundLead.referrer_sfid != null){
            this.k.Referrer__c = pInboundLead.referrer_sfid;
            this.k.Contact_Broker__c = pInboundLead.contact_referrer_only;
        }
        
        //End ST-289
        //use lead assignment rules
        this.k.setOptions(dmo);
        
        //dml
        insert this.k;
        
        if(pInboundLead.campaign_sfid != null){
        	if(pInboundLead.campaign_sfid !=''){
	        	if(this.k.Id != null){
		        	try{
		        		this.objCampaign = [SELECT ID From Campaign Where Id = : pInboundLead.campaign_sfid];
		        		CampaignMember cm = new CampaignMember(CampaignId=this.objCampaign.Id ,LeadId=this.k.Id, Status='Sent');
						insert cm;
		        	}catch(Exception pEx){
		        		Database.rollback(sp);
		        		throw new applicationException('Campaign with specified campaign_sfid does not exists');
		        	}
	        	}
        	}
        }
        //Anant Kumar on 6th May 2016
        //Functionality to return salesforce id of the lead created
        RESTInboundLead.leadId = this.k.Id;
        
        //re-query
        this.k = [	SELECT id, ownerId, isConverted, convertedContactId, convertedAccountId, 
                  convertedOpportunityId 
                  FROM Lead 
                  WHERE id = :k.id 
                  LIMIT 1
                 ];
    }
    
    private Boolean set_first_touch() {
        this.is_first_touch = (this.k == null) & (this.c == null);
        return this.is_first_touch;
    }
    
    private Lead get_recent_lead_by_email(String pEmail) {		
        Lead[] Ks = [	SELECT id, createddate, email, isConverted, convertedContactId, convertedContact.ownerId, 
                     ownerId, convertedAccountId, convertedOpportunityId
                     FROM Lead 
                     WHERE email = :pEmail 
                     ORDER BY createddate DESC
                     LIMIT 1
                    ];
        
        return Ks.size() > 0 ? Ks[0] : null;
    }
    
    private Contact get_contact_by_email(String pEmail) {		
        Contact[] Ks = [	SELECT id, AccountId, ownerId, id_kind__c, Account.Type, is_primary_member__c,
                        	 (Select Id, StageName, CloseDate, Contract_Sent_Date__c From Opportunities__r),
                        	 (Select CreatedDate From Tours__r)
                        FROM Contact 
                        WHERE email = :pEmail 
                        ORDER BY createddate DESC
                        LIMIT 1
                       ];
        
        return Ks.size() > 0 ? Ks[0] : null;
    }
    
    private void insert_lead_by_email(Messaging.inboundEmail email,
                                      Messaging.InboundEnvelope env) {
                                          //use default assignment rule
                                          Database.DMLOptions dmo 								= new Database.DMLOptions();
                                          dmo.assignmentRuleHeader.useDefaultRule = true;
                                          
                                          //create new lead
                                          this.k = new Lead(
                                              firstname 						= this.getContactFirstname(email.fromName),
                                              lastname 							= this.getContactLastname(email.fromName),
                                              company 							= this.getContactCompany(email.fromAddress),
                                              email 								= email.fromAddress,
                                              email_origin__c 			= env.fromAddress,
                                              leadsource 						= 'Inbound Email',
                                              lead_source_detail__c = 'joinus@wework.com'
                                          );
                                          
                                          //use lead assignment rules
                                          this.k.setOptions(dmo);
                                          
                                          //dml
                                          insert this.k;
                                          
                                          //re-query
                                          this.k = [	SELECT id, ownerId, isConverted, convertedContactId, convertedAccountId, 
                                                    convertedOpportunityId 
                                                    FROM Lead 
                                                    WHERE id = :k.id 
                                                    LIMIT 1
                                                   ];
                                      }
    
    private String getContactFirstname(String pFrom) {		
        String result;
        try {
            result = pFrom.substring(0,pFrom.indexOf(' '));  
        }
        catch(Exception pEx) {
            result = ''; //default value
        }
        
        return result;
    }
    
    private String getContactLastname(String pFrom) {
        String result;
        try {
            result = pFrom.indexOf(' ') > 0 ? 
                pFrom.substring(pFrom.indexOf(' ')) :
            pFrom;
        }
        catch(Exception pEx) {
            result = ''; //default value
        }
        
        return result;
    }
    
    private String getContactCompany(String pEmail) {
        String result;
        try {
            result = pEmail.indexOf('@') > 0 ? 
                pEmail.substring(pEmail.indexOf('@') + 1) :
            pEmail;
        }
        catch(Exception pEx) {
            result = ''; //default value
        }
        
        return result;
    }
    public static String getProduct_Interests(String [] Product_Interests) {
        String result;
        try {
            result = String.join(Product_Interests, ';');
        }
        catch(Exception pEx) {
            result = ''; //default value
        }
        return result;
    }
    
    public string call_insert_lead_by_web(WWTypes.InboundLead body)
    {
    	validationInbloundRecord(body);
    	insert_lead_by_web(body);
        return this.k.Id;
    }
    //Custom Exception Class
    public class applicationException extends Exception {}
    
}