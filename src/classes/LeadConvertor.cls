/* Created by @hemanshu.shah@enzigma.com on 24 Apr 2016
* This class should contain all the triggers related to Leads
* 
* 
*/

public class LeadConvertor {
  
    //Fields mapping to map Lead fields to Contacts fields
    //static Map<String,String> mapLeadToContact;
    static Settings.FieldMappings mapLeadToContact;
    //Fields mapping to map Lead fields to Journey fields
    static Settings.FieldMappings mapLeadToJourney;
    //Fields mapping to map Lead fields to Activity fields
    static Settings.FieldMappings mapLeadToActivity;
    //Fields mapping to map Lead fields to Account fields
    static Settings.FieldMappings mapLeadToAccount;
    
    static JourneySettings settingsJourney;

    public static Settings.FieldMappings Lead2Contact() {
        Settings.FieldMappings leadToContactMappings = new Settings.FieldMappings();
        leadToContactMappings.version = 1;
        leadToContactMappings.mappings = new Map<String, Settings.MappedField>();
        //leadToContactMappings.mappings.put('Name', new Settings.MappedField('Name'));
        leadToContactMappings.mappings.put('LastName', new Settings.MappedField('LastName'));
        leadToContactMappings.mappings.put('Email', new Settings.MappedField('Email'));
        leadToContactMappings.mappings.put('OwnerId', new Settings.MappedField('OwnerId'));
        return leadToContactMappings;
    }

    public static Settings.FieldMappings Lead2Journey() {
        Settings.FieldMappings leadToJourneyMappings = new Settings.FieldMappings();
        leadToJourneyMappings.version = 1;
        leadToJourneyMappings.mappings = new Map<String, Settings.MappedField>();
        leadToJourneyMappings.mappings.put('Name', new Settings.MappedField('Name'));
        leadToJourneyMappings.mappings.put('Lead_Source__c', new Settings.MappedField('LeadSource'));
        leadToJourneyMappings.mappings.put('Lead_Source_Detail__c', new Settings.MappedField('Lead_Source_Detail__c'));
        return leadToJourneyMappings;
    }

    public static Settings.FieldMappings Lead2Activity() {
        Settings.FieldMappings leadToActivityMappings = new Settings.FieldMappings();
        leadToActivityMappings.version = 1;
        leadToActivityMappings.mappings = new Map<String, Settings.MappedField>();
        leadToActivityMappings.mappings.put('Lead_Source__c', new Settings.MappedField('LeadSource'));
        return leadToActivityMappings;
    }
    
    public static Settings.FieldMappings Lead2Account() {
        Settings.FieldMappings leadToAccountMappings = new Settings.FieldMappings();
        leadToAccountMappings.version = 1;
        leadToAccountMappings.mappings = new Map<String, Settings.MappedField>();
        leadToAccountMappings.mappings.put('Name', new Settings.MappedField('Company'));
        leadToAccountMappings.mappings.put('CurrencyIsoCode', new Settings.MappedField('CurrencyIsoCode'));
        return leadToAccountMappings;
    }

    public static JourneySettings DefaultJourneySettings() {
        String strDummyAccountName = 'Dummy Lead Conversion Account';
        Account account;
        Account[] accounts = [Select Id From Account Where Name = :strDummyAccountName];
        if( accounts.size() > 0 )
            account = accounts[0];
        else{
            account = new Account(Name = strDummyAccountName);
            insert account;
        }

        LeadConvertor.JourneySettings settingJourney;

        settingJourney = new LeadConvertor.JourneySettings();
        settingJourney.NextCallInDaysFromLeadCreation = 1;
        settingJourney.NewLeadActivityFields = null;
        settingJourney.NewJourneyFields = null;
        settingJourney.NoCompanyAccountId = account.Id;
        return settingJourney;
    }

    static {
        Settings.LoadSettings(new String[]{'FieldMappings:LeadToContact', 'FieldMappings:LeadToJourney', 'FieldMappings:LeadToActivity', 'Journey'});
        //mapLeadToContact = Settings.getFieldMappings('LeadToContact');
        mapLeadToContact = Settings.getFieldMappings('LeadToContact');
        if( mapLeadToContact == null ) mapLeadToContact = Lead2Contact();
        
        mapLeadToJourney = Settings.getFieldMappings('LeadToJourney');
        if( mapLeadToJourney == null ) mapLeadToJourney = Lead2Journey();
        
        mapLeadToActivity = Settings.getFieldMappings('LeadToActivity');
        if( mapLeadToActivity == null ) mapLeadToActivity = Lead2Activity();
        
        mapLeadToAccount = Settings.getFieldMappings('LeadToAccount');
        if( mapLeadToAccount == null ) mapLeadToAccount = Lead2Account();
        
        settingsJourney = (JourneySettings)Settings.get('Journey', JourneySettings.class);
        if( settingsJourney == null ){
            settingsJourney = DefaultJourneySettings();
        } 
        
        settingsJourney.initDefaults();
    }
    
    static List<String> listLeadFields = null;
    public static List<String> getLeadFields(){
        if( listLeadFields == null ){
            Set<String> setLeadFields = new Set<String>();
            setLeadFields.add('Building_Interested_In__r.City__c');
            setLeadFields.add('Generate_Journey__c');
            for(Settings.MappedField field : mapLeadToContact.mappings.values()){
                setLeadFields.add(field.fieldname.toLowerCase());
            }
           
            for(Settings.MappedField field : mapLeadToJourney.mappings.values()){
                setLeadFields.add(field.fieldname.toLowerCase());
            }
            
            for(Settings.MappedField field : mapLeadToActivity.mappings.values()){
                setLeadFields.add(field.fieldname.toLowerCase());
            }
            
            for(Settings.MappedField field : mapLeadToAccount.mappings.values()){
                setLeadFields.add(field.fieldname.toLowerCase());
            }
            
            listLeadFields = new List<String>();
            listLeadFields.addAll(setLeadFields);
        }
        return listLeadFields;
        
    }
    
    //Need this method to create new account from lead
    public static Account accountFromLead(Lead lead){
        Account objAccount = new Account();
        //objAccount.Email = lead.Email;
         for(String field : mapLeadToAccount.mappings.keySet()){
            //contact.put(mapLeadToContact.get(field), lead.get(field));
            Settings.MappedField mappedField = mapLeadToAccount.mappings.get(field);
            if(mappedField.isvalue == true)
                objAccount.put(field, mappedField.value);
            else
                objAccount.put(field, lead.get(mappedField.fieldname));
        }
        
        if(!String.isBlank(lead.company))
        {
        	objAccount.Name = lead.company;
        }
        else
        {
        	objAccount.Name = (string.isBlank(lead.FirstName) ? '' :lead.FirstName+' ') +''+ lead.LastName;
        }
        
        return objAccount;
    }
    
    //Need this method to create Journey from lead
    public static Journey__c journeyFromLead(Lead lead){
        Journey__c journey = new Journey__c();
        journey.OwnerId = lead.OwnerId;
        
        for(String strKey : settingsJourney.NewJourneyFields.keySet()) {
            journey.put(strKey, settingsJourney.NewJourneyFields.get(strKey));
        }

        //journey.NMD_Next_Contact_Date__c= Date.today().addDays(settingsJourney.NextCallInDaysFromLeadCreation);
        journey.NMD_Next_Contact_Date__c = DateUtilities.addBusinessDays(Date.today(), settingsJourney.NextCallInDaysFromLeadCreation);
        for(String field : mapLeadToJourney.mappings.keySet()){
            Settings.MappedField mappedField = mapLeadToJourney.mappings.get(field);
            if(mappedField.isvalue == true)
                journey.put(field, mappedField.value);
            else
                journey.put(field, lead.get(mappedField.fieldname));

        }
        //journey.Name = lead.Lastname + '-' + (string.isBlank(lead.Market__c) ? '' :lead.Market__c+'-') + '' + (Date.today()).year()+'-'+(Date.today()).month()+'-'+(Date.today()).day();
        journey.Name = lead.Name + '-' +(string.isBlank(lead.Building_Interested_In__r.City__c) ? '' :lead.Building_Interested_In__r.City__c+'-')+''+ lead.LeadSource; //(Date.today()).year() +'-'+ (Date.today()).month() +'-'+ (Date.today()).day();
        if(journey.Name != null && journey.Name.length() > 80)
     	{
        	journey.Name =  journey.Name.substring(0, 80);
     	}
        return journey;
    }
    
    //Need this method to create Activity from lead
    public static Task activityFromLead(Lead lead, Contact contact, Journey__c journey){
        Task activity = new Task();
        //activity.OwnerId = lead.OwnerId;
        for(String strKey : settingsJourney.NewLeadActivityFields.keySet()) {
            activity.put(strKey, settingsJourney.NewLeadActivityFields.get(strKey));
        }

        if( contact != null ){
            activity.WhoId = contact.Id;
            
            //Journey can be associated with Task only if Task is assigned to the contact,
            //Salesforce does not allow to assolciate ask to any other object if the task
            //is associated with a Lead.
           if(journey != null) 
               activity.WhatId = journey.Id;
        }
        else
            activity.WhoId = lead.Id;

        for(String field : mapLeadToActivity.mappings.keySet()){
            Settings.MappedField mappedField = mapLeadToActivity.mappings.get(field);
            if(mappedField.isvalue == true)
                activity.put(field, mappedField.value);
            else
                activity.put(field, lead.get(mappedField.fieldname));
        }
        return activity;
    }
    
     //Need this method to create Activity on exising lead
    public static Task activityFromExistingLead(Lead lead, Lead existingLead, Contact contact, Journey__c journey){
        Task activity = new Task();
        //activity.OwnerId = lead.OwnerId;
        for(String strKey : settingsJourney.NewLeadActivityFields.keySet()) {
            activity.put(strKey, settingsJourney.NewLeadActivityFields.get(strKey));
        }

        if( contact != null ){
            activity.WhoId = contact.Id;
            
            //Journey can be associated with Task only if Task is assigned to the contact,
            //Salesforce does not allow to assolciate ask to any other object if the task
            //is associated with a Lead.
          if(journey != null) 
            activity.WhatId = journey.Id;
        }
        else
            activity.WhoId = existingLead.Id;

        for(String field : mapLeadToActivity.mappings.keySet()){
            Settings.MappedField mappedField = mapLeadToActivity.mappings.get(field);
            if(mappedField.isvalue == true)
                activity.put(field, mappedField.value);
            else
                activity.put(field, lead.get(mappedField.fieldname));
        }
        return activity;
    }
    
    public static void ConvertLead(Lead lead,contact contact,string convertedLeadStatus)
    {
        Database.LeadConvert leadConvert = new database.LeadConvert();
        leadConvert.setLeadId(lead.Id);
        //leadConvert.setAccountId(mapAccountsByName.get(lead.Company).Id);
        leadConvert.setAccountId(contact.AccountId);
        leadConvert.setContactId(contact.Id);
        leadConvert.setConvertedStatus(settingsJourney.ConvertedLeadStatus);
        leadConvert.doNotCreateOpportunity = true;
        leadConvert.overwriteLeadSource  = false;
        Database.LeadConvertResult lcr = Database.convertLead(leadConvert);   
    }
     //This method should be called whenever one or more leads are created
    /*
      Devoloped By: Hemanshu Shah
      Modified By: Amol Darekar
      Comment: This method is used to Generate Journey And Activity from lead if contact is not present and if contact present the it converts the lead 
               and transfer all journeys of lead to contact.
    */ 
    public static LeadResult[] ConvertLeadsToJourneys(Set<Id> setLeadIds){
    //try{
    	
        Debug.log('In Convert Lead to Joureny::');
        List<LeadResult> resultRet = new List<LeadResult>();
        set<string> setContactNotHavingAccount = new set<string>();
        integer iIndex = 0;
        //Prepare list of Leads and Leads Map
        Map<String, List<Lead>> mapLeadsByEmail = new Map<String,List<Lead>>();
        Map<Id,Lead> mapLeadsById = new Map<Id,Lead>();
        Lead[] leadsToBeProcessed = Database.Query('Select ' + String.join(getLeadFields(), ',') + ' From Lead Where Id in :setLeadIds and IsConverted = False');
        Debug.Log('Leads being Processed : ' + leadsToBeProcessed);
        
        for(Lead lead : leadsToBeProcessed){
            mapLeadsById.put(lead.Id, lead);
            if( !String.isBlank(lead.Email) ){
                String strEmail = lead.Email.toLowerCase();
                if( mapLeadsByEmail.containsKey(strEmail)){
                    mapLeadsByEmail.get(strEmail).add(lead);
                }
                else {
                    mapLeadsByEmail.put(strEmail, new List<Lead>{lead});
                }
            }
        }
        
        //Find existing contacts matching the emails sorted by CreatedDate desc so we will use latest contact.
        Set<String> leadEmails = mapLeadsByEmail.keySet();
        Contact[] contactsExisting = [Select Id, Email, AccountId, OwnerId From Contact Where Email in :leadEmails order by createdDate desc];
        
        Map<String,Contact> mapContactsExistingByEmail = new Map<String,Contact>();
        Debug.log('Existing Contacts : ' + contactsExisting);
        List<Contact> contactsNew = new List<Contact>();
        Map<String,Contact> mapContactsByEmail = new Map<String,Contact>();
        Set<Id> setExistingLeadIds = new Set<Id>();
        Set<Id> setExistingContactIds = new Set<Id>();
        
        for(Contact contact : contactsExisting){
            if( !mapContactsByEmail.containsKey(contact.Email.toLowerCase())) {
                mapContactsExistingByEmail.put(contact.Email.toLowerCase(), contact);
                mapContactsByEmail.put(contact.Email.toLowerCase(), contact);
                setExistingContactIds.add(contact.Id);
              }
             //Changes for lead conversion
             Debug.log('contact.AccountId:'+contact.AccountId);
             if(contact.AccountId == null){
             setContactNotHavingAccount.add(contact.Email.toLowerCase());
        	} 
        }
       
       Boolean leadUpdateFlag = false ,contactUpdateFlag = false;
       
       //If lead owner is queue then update lead owner with current loggedin user id before conversion
       Database.DMLOptions dmo = new Database.DMLOptions();
	   dmo.assignmentRuleHeader.useDefaultRule= false;
       
       	for(Lead lead : leadsToBeProcessed) {
          	 String strLeadEmail = lead.Email.toLowerCase();
		      if(mapContactsByEmail.containsKey(strLeadEmail) ) {
		    	if(((String)lead.OwnerId).startsWith('00G'))
		    	{
		    		lead.OwnerId = UserInfo.getUserId();
		    		//lead.Is_Active_Assignment__c = false;
		    		lead.setOptions(dmo);
		    		leadUpdateFlag = true;
		    	}
		     }
         }
         
	     if(leadUpdateFlag)
	     {
	     	update leadsToBeProcessed;
	     	Debug.log('leas after update'+leadsToBeProcessed);
	     }

       	Map<String,Account> mapAccountsByName = new Map<String,Account>(); 
       //Create account for contact not having account and account Id to contact AccountId field. 
       	List<Account> accountsNew = new List<Account>();
       
       	for(String strEmail : setContactNotHavingAccount) 
      	{ 
         	accountsNew.add(accountFromLead(mapLeadsByEmail.get(strEmail)[0]));
       	}
                
       	insert accountsNew;
        
       
        for(Account account : accountsNew){
            mapAccountsByName.put(account.Name, account);
        }
        
       //Assign account Id to contact accountId and update contact required for conversion
       for(contact currentContact : contactsExisting)
       {    
       	 if(currentContact.AccountId == null && mapLeadsByEmail.get(currentContact.Email.toLowerCase())[0].company != null)
       	 {
	         currentContact.AccountId = mapAccountsByName.get(mapLeadsByEmail.get(currentContact.Email.toLowerCase())[0].company).Id;
	         contactUpdateFlag = true;
       	 }  
	     else if(currentContact.AccountId == null)
	      {
              string companyName = (string.isBlank((mapLeadsByEmail.get(currentContact.Email.toLowerCase())[0]).FirstName+ ' ')?'':(mapLeadsByEmail.get(currentContact.Email.toLowerCase())[0]).FirstName+' ') +''+(mapLeadsByEmail.get(currentContact.Email.toLowerCase())[0]).LastName;
         	  currentContact.AccountId = mapAccountsByName.get(companyName).Id;
         	  contactUpdateFlag = true;
	      }
       }
  
       if(contactUpdateFlag == true)
        	update contactsExisting;
 
        //Check for existing lead
        set<string> setContactEmail = mapContactsByEmail.keySet();
        Lead[] leadsExisting =  Database.Query('Select ' + String.join(getLeadFields(), ',') + ' From Lead Where Email in :leadEmails And Email not in: setContactEmail And Id not in :setLeadIds');
        Debug.Log('Existing Leads : ' + leadsExisting);
        Map<String,Lead> mapExistingLeadsByEmail = new Map<STring,Lead>();
        
        for(Lead currentLead : leadsExisting) {
            mapExistingLeadsByEmail.put(currentLead.Email.toLowerCase(), currentLead);
            setExistingLeadIds.add(currentLead.Id);
        }

        List<Lead> leadsToBeDeleted = new List<Lead>();
       
        //Find if there are any open Journeys for given contacts
        Map<String,List<Journey__c>> mapJourneysByEmail = new Map<String,List<Journey__c>>();
        List<Journey__c> journeysToCreate = new List<Journey__c>();
        Journey__c[] journeysExisting = [Select Id, OwnerId, Stage__c, Primary_Contact__c,Primary_Contact__r.Email, Primary_Lead__c, Primary_Lead__r.Email From Journey__c Where Stage__c not in :settingsJourney.ClosedJourneyStages And (Primary_Contact__c IN :setExistingContactIds OR Primary_Lead__c IN : setExistingLeadIds) order by createdDate desc];
        Debug.log('Existing Journeys : ' + journeysExisting);
        for(Journey__c journey : journeysExisting){
            String strEmail = null;
            if(journey.Primary_Contact__r != null)
                strEmail = journey.Primary_Contact__r.Email.toLowerCase();
            else if(journey.Primary_Lead__r != null && !String.isBlank(journey.Primary_Lead__r.Email))//String.isBlank(journey.Primary_Lead__r.Email)
                strEmail = journey.Primary_Lead__r.Email.toLowerCase();
            
            if( mapJourneysByEmail.containsKey(strEmail) ){
                mapJourneysByEmail.get(strEmail).add(journey);
            }
            else {
                mapJourneysByEmail.put(strEmail, new List<Journey__c>{journey});
            }
        }
        
        //Query all Group Members available for Queue available for Journey object
        //We are assuming the same queue will support the Lead and Journey both, if there are queue which support only one of these object the code will fail.
        //Hence always make sure the queues created always support both Lead and Journey
        Map<Id,Set<Id>> mapUsersToQueues = new Map<Id, Set<Id>>();
        GroupMember[] queueMembers = [Select GroupId, UserOrGroupId From GroupMember Where GroupId in (Select QueueId From QueueSobject Where SObjectType = 'Journey__c')];
         Set<Id> setMemberQueues;
        for(GroupMember member : queueMembers) {
            setMemberQueues = mapUsersToQueues.get(member.UserOrGroupId);
            if( setMemberQueues == null ) {
                setMemberQueues = new Set<Id>();
                mapUsersToQueues.put(member.UserOrGroupId, setMemberQueues);
            }
            if( !setMemberQueues.contains(member.GroupId) ) {
                setMemberQueues.add(member.GroupId);
            }
        }
        Debug.log('mapUsersToQueues : ' + mapUsersToQueues);
        Debug.log('setMemberQueues : ' + setMemberQueues);
        //Find list of Journeys which needs to be created, if there is no open Journey for given Contact
        List<Journey__c> journeysToUpsert = new List<Journey__c>();
        map<Integer,Journey__c> mapNullJourneys = new map<Integer,Journey__c>();
        map<Integer,Journey__c> mapJourneysBeforeUpsert = new map<Integer,Journey__c>();
        Integer mapIndex= 0;
        List<Task> activities = new List<Task>();
       
        set<string> setAllowedUsers = new set<string>();
        set<string> setAllowedQueues = new set<string>();
        
        //Get User and queue details for Journey Creation if owner Id record is in json & Lead Source and Lead Source Details Match then it will create Journey record.
    	Setting__c settingsQueue = Settings.get('User/Queue Journey Creation');
    	if(settingsQueue != null)
		{
		    UserQueueJourneySettings objJourneyCreationsetting = (UserQueueJourneySettings)JSON.deserialize(settingsQueue.Data__c, UserQueueJourneySettings.class);
		    set<Id> setUserId = new set<Id>();
		    
		    if(objJourneyCreationsetting != null)
		    {
		    	string Ids;
			    for(AllowedUsersSettings currentUser:objJourneyCreationsetting.allowedUsers)
			    {
			    	Ids = string.valueOf(currentUser.Id);
			        setAllowedUsers.add(Ids.subString(0,15));
			    }
			        
			    for(AllowedQueueSettings currentQueue:objJourneyCreationsetting.allowedQueues)
			    {
			    	Ids = string.valueOf(currentQueue.Id);
			        setAllowedQueues.add(Ids.subString(0,15));
			    }
		       //throw new Exception();
		       //Get Lead source and lead source details from JSON setting
			   settingsQueue = Settings.get('Lead:Lead and Lead Source Details');
			   if(settingsQueue != null)
			   {
				    map<String,set<String>> mapLeadSourceAndDetails = new map<String,set<String>>();
				    set<string> setLeadSource = new set<string>();
				    set<string> setLeadSourceDetails = new set<string>();
				    LeadSoruceSettings setting = (LeadSoruceSettings)JSON.deserialize(settingsQueue.Data__c, LeadSoruceSettings.class);
				    
				    for(string currentLeadSource : setting.LeadSource)
				    {
				    	setLeadSource.add(currentLeadSource.toLowerCase());	
				    }
				    
				    for(string currentLeadSourceDetails : setting.LeadSourceDetails)
				    {
				    	setLeadSourceDetails.add(currentLeadSourceDetails.toLowerCase());	
				    }
			    
			        for(Lead lead : leadsToBeProcessed) {
			            Journey__c journeyNew = null;
			            String strLeadEmail = '';
			            if( !String.isBlank(lead.Email) ) {
			                strLeadEmail = lead.Email.toLowerCase();		                
			                List<Journey__c> journeys = mapJourneysByEmail.get(strLeadEmail);
			                 Debug.log('lead :: ' + lead.ownerId);
			                if( journeys != null ){
			                    for(Journey__c journey : journeys ) {
			                    	
				                    if(mapContactsByEmail.containsKey(strLeadEmail) ) {
							    			journey.ownerId = mapContactsByEmail.get(strLeadEmail).ownerId;
		      					 	 }
			                        Debug.log('journey :: ' + journey.ownerId);
			                        //If there is alredy Open Journey which has same OwnerId as Lead we need to reuse that journey
			                        if( journey.OwnerId == lead.OwnerId || setMemberQueues.contains(lead.OwnerId))
			                            journeyNew = journey;
			                        else if( ((String)lead.OwnerId).startsWith('00G')
			                            && !((String)journey.OwnerId).startsWith('00G') 
			                            && mapUsersToQueues.containsKey(journey.OwnerId) 
			                            &&  mapUsersToQueues.get(journey.OwnerId).contains(lead.OwnerId) ) {
			                            //Else If the Lead.OwnerId is a Queue, we should check if there is any open journey assigned to the queue member of the Lead.Owner Queue and if found use that
			                            journeyNew = journey;
			                        }
			                        if( journeyNew != null ) {
			                            journeyNew.NMD_Next_Contact_Date__c = DateUtilities.addBusinessDays(Date.today(), 1);
			                            break;
			                        }
			                    }
			                }
			            }
			            Debug.log('contact for journeyNew:'+journeyNew);
			            Contact contact = mapContactsByEmail.get(strLeadEmail);
			            Lead leadExisting = mapExistingLeadsByEmail.get(strLeadEmail);
			                
			            if( journeyNew == null) {
			            	string leadOwnerId = string.valueOf(lead.OwnerId);
                            Debug.log('leadOwnerId:'+lead);
			            	Debug.log('leadOwnerId:'+leadOwnerId);
			            	leadOwnerId = leadOwnerId.subString(0,15);
			                if((setAllowedUsers.contains(leadOwnerId) || setAllowedQueues.contains(leadOwnerId)) && lead.LeadSource != null && lead.Lead_Source_Detail__c!= null && setLeadSource.contains(lead.LeadSource.toLowerCase()) && setLeadSourceDetails.contains(lead.Lead_Source_Detail__c.toLowerCase()))
			                {
			                     journeyNew = journeyFromLead(lead);
			                     if(mapContactsByEmail.containsKey(lead.Email.toLowerCase()) ) {
							    	journeyNew.ownerId = mapContactsByEmail.get(strLeadEmail).ownerId;
		      					 }
			                }
			                
			                if(contact != null){
			                   if(journeyNew != null)
			                    journeyNew.Primary_Contact__c = contact.Id;
			                    //New Requirement if contact exist with same email use existing contact and convert the lead
			                  if(mapContactsByEmail.containsKey(lead.Email.toLowerCase()) ) {
			                        ConvertLead(lead,contact,settingsJourney.ConvertedLeadStatus);
			                }
			                //leadsToBeDeleted.add(lead);
			                }
			                else if(leadExisting != null) {
			                  if(journeyNew!=null)
			                      journeyNew.Primary_Lead__c = leadExisting.Id;
			                    //If Lead with same Email already exists delete lead being processed
			                    leadsToBeDeleted.add(lead);
			                }
			                else if(journeyNew != null)
			                    journeyNew.Primary_Lead__c = lead.Id;
			            }
			            else
			            {    if(contact != null)
			                     ConvertLead(lead,contact,settingsJourney.ConvertedLeadStatus);
			                 else
			                    leadsToBeDeleted.add(lead);
			            }
			            
			            if(journeyNew != null)
			            {
			                journeysToUpsert.add(journeyNew);
			                mapJourneysBeforeUpsert.put(mapIndex,journeyNew);
			            }
			            else
			            {
			              mapNullJourneys.put(mapIndex,journeyNew);
			            }
			            mapIndex++;
			        }
		        
			        Debug.log('Journeys To Upsert: ' + journeysToUpsert);
			        if(journeysToUpsert.size() >0)
			          upsert journeysToUpsert;
			          
			       for(Integer currentIndex : mapJourneysBeforeUpsert.keySet())
			       {
			           mapNullJourneys.put(currentIndex,journeysToUpsert[iIndex]);
			           iIndex++;
			       }
		        
			       journeysToUpsert = mapNullJourneys.values();
			       iIndex = 0;
			       
			       for(Lead lead : leadsToBeProcessed) {
			            Contact contact = null;
			            Lead leadExisting;
			            Task task;
			            if( !String.isBlank(lead.Email)) {
			                String strEmail = lead.Email.toLowerCase();
			                contact = mapContactsByEmail.get(strEmail);
			                leadExisting = mapExistingLeadsByEmail.get(lead.Email.toLowerCase());
			            }
			
			            if(leadExisting == null)
			              task = activityFromLead(lead, contact, journeysToUpsert[iIndex]);
			            else
			              task = activityFromExistingLead(lead, leadExisting, contact, journeysToUpsert[iIndex]);
			            
			            activities.add(task);
			            ++iIndex;
		        	}
		            
			        Debug.log('Activities To Insert: ' + activities);
			        //Insert activities
			        upsert activities;
			        
			        iIndex = 0;
			        for(Lead lead : leadsToBeProcessed) {
			            LeadResult result = new LeadResult();
			
			            if( !String.isBlank(lead.Email)) {
			                String strEmail = lead.Email.toLowerCase();
			                Contact contact = mapContactsByEmail.get(strEmail);
			                if(contact != null)
			                    result.ContactId = contact.Id;
			                Lead leadExisting = mapExistingLeadsByEmail.get(strEmail);
			                if(leadExisting != null) {
			                    result.LeadId = leadExisting.Id;
			                }
			            }
			
			            result.ActivityId = activities[iIndex].Id;
			            if(journeysToUpsert[iIndex] != null)
			              result.JourneyId = journeysToUpsert[iIndex].Id;
			            resultRet.add(result);
			            ++iIndex;
		        }
		        delete leadsToBeDeleted;
		       }//Lead:Lead and Lead Source Details end
		      }
		     }
		     return resultRet;
        /*}
        catch(Exception ex)
        {	
         Debug.log('ex::'+ex);
		 if(RESTInboundLead.sp!=null)	
			Database.rollback(RESTInboundLead.sp);	
        }
        return null;*/
    }
    
     /*
    Comment   : This method is use to convert leads to contact and account if contact is not exist.   
    Author    : Amol Darekar 
    Date      : 28 June 2016 */
    public static ContactResult[] ConvertLeadsToContact(list<string> lstEmails){
     Set<Id> contactIds = new Set<Id>();
     Map<Id,Lead> mapLeadsById = new Map<Id,Lead>();
     Map<String,Contact> mapContactsByEmail = new Map<String,Contact>();
     Map<String, List<Lead>> mapLeadsByEmail = new Map<String,List<Lead>>();
     set<string> setContactNotHavingAccount = new set<string>();
     //list<contact> lstContactNotHavingAccount = new list<contact>();
     List<ContactResult> resultRet = new List<ContactResult>();
     
     Contact[] contactsExisting = [Select Id, Email, OwnerId, AccountId From Contact Where Email in :lstEmails Order by CreatedDate desc];
	   if(contactsExisting !=null && contactsExisting.size()>0)
	   {
	     for(Contact contact : contactsExisting){
	           contactIds.add(contact.Id);
	           Debug.log('contact.AccountId::'+contact.AccountId);
	            if( !mapContactsByEmail.containsKey(contact.Email.toLowerCase())) {
	                    mapContactsByEmail.put(contact.Email.toLowerCase(), contact);
	             }
	             
	             if(contact.AccountId == null){
	               setContactNotHavingAccount.add(contact.Email.toLowerCase());
	               //lstContactNotHavingAccount.add(contact);
	             }  
	     }
	   }
        
      Lead[] leadsToBeProcessed = Database.Query('Select ' + String.join(getLeadFields(), ',') + ' From Lead Where Email in :lstEmails and isConverted = false');  
      Debug.log('leadsToBeProcessed::'+leadsToBeProcessed);
     
      if(leadsToBeProcessed!=null && leadsToBeProcessed.size()>0)
      {
       for(Lead lead : leadsToBeProcessed){
              mapLeadsById.put(lead.Id, lead);
              if( mapLeadsByEmail.containsKey(lead.Email)){
                  mapLeadsByEmail.get(lead.Email.toLowerCase()).add(lead);
              }
              else {
                  mapLeadsByEmail.put( lead.Email.toLowerCase(), new List<Lead>{lead});
              }
       }
       
       
	     //Set of company name of lead
	      Set<String> leadEmails = mapLeadsByEmail.keySet();
	      set<string> setLeadsCompany = new set<string>();
	      
      for(String strEmail : leadEmails) {
          strEmail = strEmail.toLowerCase();
          setLeadsCompany.add((mapLeadsByEmail.get(strEmail.toLowerCase())[0]).company);
          
      }
        
       //Create account which do not already exist 
       List<Account> accountsNew = new List<Account>();
       for(String strEmail : setContactNotHavingAccount) 
       { 
            accountsNew.add(accountFromLead(mapLeadsByEmail.get(strEmail)[0]));
       }
                
       insert accountsNew;
        
        //Add newly created accounts to map
        Map<String,Account> mapAccountsByName = new Map<String,Account>();
        for(Account account : accountsNew){
            mapAccountsByName.put(account.Name, account);
        }
        
       //Assign account Id to contact and update the contact
       for(contact currentContact : contactsExisting)
       {
       	 Debug.log('currentContact::'+currentContact);
	   	 if(currentContact.AccountId == null && mapLeadsByEmail.get(currentContact.Email.toLowerCase())[0].company != null)
	         currentContact.AccountId = mapAccountsByName.get(mapLeadsByEmail.get(currentContact.Email.toLowerCase())[0].company).Id;  
	     else if(currentContact.AccountId == null)
	      {
              string companyName = (string.isBlank((mapLeadsByEmail.get(currentContact.Email.toLowerCase())[0]).FirstName+ ' ')?'':(mapLeadsByEmail.get(currentContact.Email.toLowerCase())[0]).FirstName+' ') +''+(mapLeadsByEmail.get(currentContact.Email.toLowerCase())[0]).LastName;
         	  currentContact.AccountId = mapAccountsByName.get(companyName).Id; 
	      }   
        }

       update contactsExisting;
       Debug.log('Contact Update:'+contactsExisting[0].AccountId);
       //Put contact with account Id
      for(Contact contact : contactsExisting){
       mapContactsByEmail.put(contact.Email.toLowerCase(), contact);
      }
       
       
       List<Journey__c> newJourneys = new List<Journey__c>();
       
       Map<String,Journey__c> mapEmailsToJourney = new Map<String,Journey__c>(); 
       
       //Find if there are any Journeys for given contacts or lead
       
       Map<String,List<Journey__c>> mapJourneysByEmail = new Map<String,List<Journey__c>>();
       
       Journey__c[] journeys = [Select Id, Primary_Lead__c, Primary_Contact__c,Primary_Contact__r.Email, Primary_Lead__r.Email, Stage__c, OwnerId From Journey__c Where Primary_Lead__c in :mapLeadsById.keySet()];
       
        for(Journey__c journey : journeys) {
         String strEmail = null;
            if(journey.Primary_Contact__r != null)
                strEmail = journey.Primary_Contact__r.Email.toLowerCase();
            else if(journey.Primary_Lead__r != null && !String.isBlank(journey.Primary_Lead__r.Email))//String.isBlank(journey.Primary_Lead__r.Email)
                strEmail = journey.Primary_Lead__r.Email.toLowerCase();
            
            if( mapJourneysByEmail.containsKey(strEmail) ){
                mapJourneysByEmail.get(strEmail).add(journey);
            }
            else {
                mapJourneysByEmail.put(strEmail, new List<Journey__c>{journey});
            }
          }
          
          
        map<string,Journey__c> mapContactWithOpenJourneys = new map<string,Journey__c>();
        
        //assign all journeys of lead to contact
        for(string strLeadEmail : mapLeadsByEmail.keySet())
        {
            list<Journey__c> lstAllJourneys = mapJourneysByEmail.get(strLeadEmail);
            string contactId = mapContactsByEmail.get(strLeadEmail).Id;
            string ownerId = mapContactsByEmail.get(strLeadEmail).ownerId;
            if(lstAllJourneys != null)
            {
              for(Journey__c currnetJourney : lstAllJourneys)
               {
                    if(currnetJourney.Primary_Lead__c != null)
                     {
                         currnetJourney.Primary_Lead__c = null;
                         currnetJourney.Primary_Contact__c = contactId;
                         currnetJourney.OwnerId = ownerId;
                         newJourneys.add(currnetJourney); 
                     }
               }
            }
        }
        
        upsert newJourneys;
        
       //If lead owner is queue then update lead owner with current loggedin user id before conversion
       for(Lead lead : leadsToBeProcessed) {
          String strLeadEmail = lead.Email.toLowerCase();
	      if( mapLeadsByEmail.containsKey(strLeadEmail) || mapContactsByEmail.containsKey(strLeadEmail) ) {
	    	if(((String)lead.OwnerId).startsWith('00G'))
	    	{
	    		lead.OwnerId = UserInfo.getUserId();
	    	}
	      }
         }
         
        update leadsToBeProcessed;
        
        integer iIndex = 0;
        for(Lead lead : leadsToBeProcessed) {
            String strLeadEmail = lead.Email.toLowerCase();
            ContactResult result = new ContactResult(); 
            String companyName = mapLeadsByEmail.get(strLeadEmail)[0].company;
            result.ContactId = mapContactsByEmail.get(strLeadEmail).Id;
            result.AccountId = mapContactsByEmail.get(strLeadEmail).AccountId;
            if( mapLeadsByEmail.containsKey(strLeadEmail) || mapContactsByEmail.containsKey(strLeadEmail) ) {
            	if(((String)lead.OwnerId).startsWith('00G'))
            	{
            		lead.OwnerId = UserInfo.getUserId();
            		update lead;
            	}
            	
                Database.LeadConvert leadConvert = new database.LeadConvert();
                leadConvert.setLeadId(lead.Id);
                //leadConvert.setAccountId(mapAccountsByName.get(companyName).Id);
                leadConvert.setAccountId(mapContactsByEmail.get(strLeadEmail).AccountId);
                leadConvert.setContactId(result.ContactId);
                leadConvert.setConvertedStatus(settingsJourney.ConvertedLeadStatus);
                leadConvert.doNotCreateOpportunity = true;
                leadConvert.overwriteLeadSource  = false;
                Debug.log('Lead Being Converted : ' + leadConvert);
                Database.LeadConvertResult lcr = Database.convertLead(leadConvert);
            }
            Debug.log('result : ' + result);
            resultRet.add(result); 
        }
        }
        else{
            ContactResult result = new ContactResult();
            for(Contact contact : contactsExisting){
             result.ContactId = contact.Id;
             result.AccountId = contact.AccountId;
             resultRet.add(result);
            }
        }
        //delete leadsToBeDeleted;
        Debug.log('resultRet : ' + resultRet);
        return resultRet; 
    }
    
     @future
    public static void FutureConvertLeadsToJourneys(Set<Id> setLeadIds)
    {
        ConvertLeadsToJourneys(setLeadIds); 
    }
    
    @future
   public static void FutureConvertLeadsToContact(List<String> listEmails)
   {
       ConvertLeadsToContact(listEmails); 
   }
    
    public class LeadResult {
        public String LeadId {get;set;}
        public String ContactId {get; set;}
        public String JourneyId {get; set;}
        public String ActivityId {get; set;}
    }
    
    public class ContactResult {
        public String ContactId {get; set;}
        public String JourneyId {get; set;}
        public String AccountId {get; set;}   
    }
    
    public class JourneySettings {
        public JourneySettings (){
            initDefaults();
        }
        
        public void initDefaults(){
            if( NextCallInDaysFromLeadCreation == null )
                NextCallInDaysFromLeadCreation = 1;
            if( CloseInDaysFromJourneyCreation == null )
                CloseInDaysFromJourneyCreation = 30;
            if( NewLeadActivityFields == null )
                NewLeadActivityFields = new Map<String,String>{'Subject' => 'Inbound Lead submission', 'Status' => 'Open'};
                    if( NewJourneyFields == null )
                    NewJourneyFields = new Map<String,String>{'Stage__c' => 'Inquiry'};
                        if( ClosedJourneyStages == null )
                        ClosedJourneyStages = new String[]{'Completed-Won', 'Completed-Lost'};
                            if(ConvertedLeadStatus == null)
                            ConvertedLeadStatus = 'Qualified';
        }
        
        
        
        public String NoCompanyAccountId {get;set;}
        public String ConvertedLeadStatus {get;set;}
        public Integer NextCallInDaysFromLeadCreation {get;set;}
        public Integer CloseInDaysFromJourneyCreation {get;set;}
        public Map<String,String> NewLeadActivityFields{get;set;}
        public Map<String,String> NewJourneyFields {get;set;}
        public String[] ClosedJourneyStages {get;set;}
    }
    
  public class AllowedUsersSettings {
      public String userName;  
      public String Id;  
  }
  
  public class AllowedQueueSettings {
      public String queueName;  
      public String Id;  
  }
  
  public class UserQueueJourneySettings{
      public AllowedUsersSettings[] allowedUsers;
      public AllowedQueueSettings[] allowedQueues;
  }
  
  public class LeadSoruceSettings {
        public String[] LeadSource;
        public String[] LeadSourceDetails;
  }
}