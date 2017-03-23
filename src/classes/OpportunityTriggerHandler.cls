/*
* @ Created By : Anant Kumar
* @ Created Date : 23 Feb 2016 * 
* @ modified By : Amol Darekar
* @ modified By : 12 May 2016
*/
public class OpportunityTriggerHandler {
/*
Comment   : This method used for create Deal record before opprtunity get created and assigne that Deal record to Deal lookup field on Opprtunity object.
Issue     : ST-317
Author    : Amol Darekar 
Date      : 12/05/2016 
*/
    public static void createDealOnOpportunityCreate()
    {
        try
        {
            List<Deal__c> lstDeal = new List<Deal__c>();
            Deal__c objDeal;
            Integer index = 0;
            List<Opportunity> lstOpportunity = Trigger.New;
            Opportunity objOpprtunity = new Opportunity();
            Id EntSolutionId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise Solutions').getRecordTypeId();
            
            if(lstOpportunity != null && lstOpportunity.size() > 0)
            {
                map<Id,String> relatedAccounts = new map<Id,String>();
                set<Id> setRelatedAccountId = new set<Id>();
                
                for(Opportunity currentOpprotunity:lstOpportunity)
                {
                    setRelatedAccountId.add(currentOpprotunity.AccountId);
                    //relatedAccounts.put(currentOpprotunity.AccountId,currentOpprotunity.AccountId);
                }
                
                
                List<Account> lstAccount = [SELECT Id,Name FROM Account WHERE Id IN :setRelatedAccountId];
                for(Account currentAccount : lstAccount)
                {
                    relatedAccounts.put(currentAccount.Id,currentAccount.Name);
                }
                
                
                for(Opportunity currentOpprotunity:lstOpportunity)
                {     
                    if(EntSolutionId != null && currentOpprotunity.RecordTypeId == EntSolutionId)
                    {
                        objDeal = new Deal__c();
                        objDeal.Name = currentOpprotunity.Name;
                        //objDeal.Approver_1__c = UseriNFO.getUserId();
                        objDeal.Status__c = 'Active';
                        objDeal.Counter_Party__c = relatedAccounts.get(currentOpprotunity.AccountId);
                        objDeal.Priority__c = 'I/NU';
                        objDeal.Group__c = 'Enterprise Solution';//ST-331
                        objDeal.Phase__c = 'E';
                        objDeal.Category__c = 'Membership';
                        lstDeal.add(objDeal);
                    }
                }
                
                insert lstDeal;
                
                for(Opportunity currentOpprotunity:lstOpportunity)
                { 
                    Integer dealIndex = 0;
                    for(Deal__c currentDeal:lstDeal)
                    {   
                        if(currentOpprotunity.Deal__c == null)
                        {
                            currentOpprotunity.Deal__c = currentDeal.Id;
                            lstDeal.remove(dealIndex);
                            break;
                        }
                        dealIndex++;
                    }
                }
            }
        }
        catch(Exception ex)
        {
            Debug.log(ex.getMessage());
        }  
    }
    
/*
Comment   : This method used for update Deal record Gate and Status when Opportunity phase change.
Issue     : ST-318
Author    : Amol Darekar 
Date      : 12/05/2016
*/
    public static void updateDealWhenOpprtunityStageChange()
    {
        try
        {
            List<Opportunity> lstNewOpportunites = Trigger.New;
            List<Opportunity> lstUpdatedOpportunites = new List<Opportunity>();
            Map <String,String> mapDealStatus = new Map <String,String>();
            Map <String,String> mapDealGate = new Map <String,String>();
            List<Deal__c> lstDealToUpdate = new List<Deal__c>();
            Set <Id> setDealIds = new Set<Id>();
            
            mapDealStatus.put('Closed Won','Closed');
            mapDealStatus.put('Closed Lost','Dead');
            
            mapDealGate.put('D','D');
            mapDealGate.put('C','C');
            mapDealGate.put('B','B');
            mapDealGate.put('A','A');
          // mapDealGate.put('Internal Sign Off','B');
            mapDealGate.put('Closed Won','A');
            
            Id EntSolutionId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Enterprise Solutions').getRecordTypeId();
            
            for(Opportunity currentOpprotunity : lstNewOpportunites)
            {
                if(EntSolutionId != null && currentOpprotunity.RecordTypeId == EntSolutionId)
                {
                    Opportunity objOldOpp = (Opportunity)Trigger.oldMap.get(currentOpprotunity.ID);
                    if(objOldOpp != null && (objOldOpp.StageName != currentOpprotunity.StageName || currentOpprotunity.Deal__c != objOldOpp.Deal__c))
                    {
                        lstUpdatedOpportunites.add(currentOpprotunity);
                        if(currentOpprotunity.Deal__c !=null)
                            setDealIds.add(currentOpprotunity.Deal__c);
                        
                    }
                }
            }
            
            Map<ID, Deal__c> mapDealToUpdate = new Map<ID, Deal__c>([SELECT Id, Status__c , Phase__c FROM Deal__c where Id IN :setDealIds]);
            
            for(Opportunity currentOpprotunity : lstUpdatedOpportunites)
            {
                Deal__c currentDeal = mapDealToUpdate.get(currentOpprotunity.Deal__c);
                if(currentDeal!=null && currentOpprotunity.StageName != null)
                {
                    if(mapDealStatus.get(currentOpprotunity.StageName) != null)
                        currentDeal.Status__c = mapDealStatus.get(currentOpprotunity.StageName);
                    else
                        currentDeal.Status__c = 'Active';
                    
                    currentDeal.Phase__c= mapDealGate.get(currentOpprotunity.StageName);
                    lstDealToUpdate.add(currentDeal); 
                }
            }
            
            update lstDealToUpdate;
        }
        catch(Exception ex)
        {
            Debug.log(ex.getMessage());
        }
    }
    
    
    
/*
Comment   : This method used for Change Type and Record type to Residential Space when LeadSource is 'WeLive' or 'WeLive.com' and also if Product Line is 'WeLive'.
Issue     : ST-412
Author    : Amol Darekar 
Date      : 14/06/2016
*/
    public static void setTypeAndRecordTypeOfOpprtunity()
    {
        try
        {   
            List<Opportunity> lstNewOpportunites = Trigger.New;
            
            for(Opportunity currentOpprotunity : lstNewOpportunites)
            {
                if(currentOpprotunity.LeadSource == 'WeLive.com' || currentOpprotunity.LeadSource == 'WeLive')
                {
                    currentOpprotunity.Type__c = 'Residential Space';
                    
                    currentOpprotunity.RecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Residential Space').getRecordTypeId();
                }
            }
        }
        catch(Exception ex)
        {
            Debug.log(ex.getMessage());
        }
    }
    
/*
Comment   : Update name of opportunity record.
Issue     : ST-434
Author    : Anant Kumar 
Date      : 15/June/2016
*/
    public static void updateOppName(){
        Map<ID,Schema.RecordTypeInfo> oppRecordTypeMap = Opportunity.sObjectType.getDescribe().getRecordTypeInfosById();
        Set<Id> accountIdSet = new Set<Id>();
        for(Opportunity opportunity : (List<Opportunity>)trigger.new){
            if(opportunity.AccountId != null){
                accountIdSet.add(opportunity.AccountId);
            }
        }
        Map<Id, Account> accountMap = New Map<Id, Account>([Select Name, (Select Name,RecordType.Name From Opportunities Where RecordType.Name='Enterprise Solutions') From Account Where Id In:accountIdSet]);
        Map<Integer, String> monthinMMMMap = new Map<Integer, String>{1 => 'Jan', 2 => 'Feb', 3 => 'Mar', 4 => 'Apr', 5 => 'May', 6 => 'Jun', 7 => 'Jul', 8 => 'Aug', 9 => 'Sep', 10 => 'Oct', 11 => 'Nov', 12 => 'Dec'};
            Integer oppCount = 1;    
        for(Opportunity opportunity : (List<Opportunity>)trigger.new){
            if(oppRecordTypeMap.get(opportunity.recordTypeID).getName().containsIgnoreCase('Enterprise Solutions')){
                Account account = accountMap.get(opportunity.AccountId);
                opportunity.Name = account.Name + ' - ' + (account.Opportunities.size() + oppCount) + ' - Enterprise';
                oppCount++;
            }
            else{
                DateTime todayDT;
                if(opportunity.CloseDate == null)
                    todayDT = System.now();
                else
                    todayDT = opportunity.CloseDate;
                if(opportunity.AccountId != null)
                    opportunity.Name = accountMap.get(opportunity.AccountId).Name + ' - ' + opportunity.Type__c + ' - ' + monthinMMMMap.get(todayDT.month()) + ' ' + todayDT.year();
                else{
                    opportunity.Name = opportunity.Type__c + ' - ' + monthinMMMMap.get(todayDT.month()) + ' ' + todayDT.year();
                }
            }
        }
    }
    
    /**
    * Comment   : Copy field from last opportunity
    * Issue     : ST-451
    * Author    : Samadhan Kadam 
    * Date      : 17/June/2016
    **/
    
     public static void copyFieldsFromLastOpportunity(){
        set<Id> setContacts = new set<Id>();
        map<Id, Opportunity> mapExistingOpp = new map<Id, Opportunity>();
        for(Opportunity opp : (list<Opportunity>)Trigger.New){
                setContacts.add(opp.Primary_Member__c);
        }
        DateTime last60Days = System.now();
        last60Days = last60Days.addDays(-60);
        Setting__c setting = Settings.get('OpportunityFromLatestOpportunity');
        if(setting != null){
	        Map<String, Object> mapData = (Map<String,Object>)JSON.deserializeUntyped(setting.Data__c);
	        
	        String strQuery = 'Select Primary_Member__c, CreatedDate, ';
	        for(String strKey : mapData.KeySet()){
	            strQuery += strKey + ',';
	        }
	        strQuery = strQuery.removeEnd(',');
	        strQuery += ' FROM Opportunity WHERE CreatedDate >: last60Days AND Primary_Member__c in :setContacts ORDER BY CreatedDate DESC';
	        
			for(Opportunity existingOpp : Database.Query(strQuery)){
	        	if(!mapExistingOpp.containsKey(existingOpp.Primary_Member__c)){
			   		mapExistingOpp.put(existingOpp.Primary_Member__c, existingOpp);
			   	}
		   	}
	         
         	for(Opportunity opportunity : (list<Opportunity>)Trigger.new)
            {
                Opportunity existing = mapExistingOpp.get(opportunity.Primary_Member__c);
                if(existing!=null)
                {
                    for(String strKey : mapData.keySet())
                    {
                        Object fieldObj = mapData.get(strKey);
                        Map<String, Object> fieldMap = (Map<String, Object>)fieldObj;
                        opportunity.put((String)fieldMap.get('name'), existing.get(strKey));
                    }
                }
            }
        }
   }
   
   /**
    * Comment   : Encode Opportunity Id
    * Issue     : ST-455
    * Author    : Anant Kumar
    * Date      : 21/June/2016
    **/
    public static void encodedOpportunityID(){
        List<Opportunity> opportunities = new List<Opportunity>();
        for (Id idOpp : Trigger.newMap.keyset())
        {
            opportunities.add(new Opportunity(Id = idOpp, Encoded_Id__c = EncodingUtil.base64Encode(Blob.valueOf(idOpp))));
        }
        update opportunities;
    }
    
    /**
    * Comment   : Update Opportunity Primary Member
    * Issue     : ST-463
    * Author    : Anant Kumar
    * Date      : 21/June/2016
    **/
    public static void updatePrimaryMemberOnOpportunity(){
        //Check which Opportunities don't have Primary Member
        Set<Id> oppsNoPMIds = new Set<Id>();
        Set<Id> accsNoPMIds = new Set<Id>();
        for(Opportunity opp : (List<Opportunity>)trigger.new){
            if(string.isBlank(opp.Primary_Member__c)){
                oppsNoPMIds.add(opp.Id);
                accsNoPMIds.add(opp.AccountId);
            }
        }
    
        //Get Primary Member from Account
        if(oppsNoPMIds.size() > 0){
            //Get accounts
            Map<Id,Account> parentAccsMap = new Map<Id,Account>([SELECT Id, Primary_Member__c 
                                                                 FROM Account
                                                                 WHERE Id IN :accsNoPMIds]);
            Debug.log('>>>>>> parentAccsMap ' + parentAccsMap);
            //Set primary member
            for(Opportunity opp : (List<Opportunity>)trigger.new){
                if(string.isBlank(opp.Primary_Member__c)){
                    Account parentAcc = parentAccsMap.get(opp.AccountId);
                    Debug.log('>>>>>> parentAcc ' + parentAcc); 
                    
                    if(parentAcc != null){
                        opp.Primary_Member__c = parentAcc.Primary_Member__c;
                        Debug.log('>>>>>> parentAcc.Primary_Member__c ' + parentAcc.Primary_Member__c); 
                    }
                }
            }
        }
        
        //Check if Primary Member is changed --> Update Account Primary Member
        Set<Id> oppsYesPMIds = new Set<Id>(); 
        Set<Id> accsYesPMIds = new Set<Id>();
        Map<Id, Opportunity> opportunityOldMap = (Map<Id, Opportunity>)trigger.oldMap;
        for(Opportunity opp : (List<Opportunity>)trigger.new){
            if(!string.isBlank(opp.Primary_Member__c)){
                if(trigger.isInsert){
                    oppsYesPMIds.add(opp.Id); 
                }
                if(trigger.isUpdate && opp.Primary_Member__c != opportunityOldMap.get(opp.Id).Primary_Member__c){
                    oppsYesPMIds.add(opp.Id);
                }
                accsYesPMIds.add(opp.AccountId);
            }
        }
        
        //Update Account Primary Member
        if(oppsYesPMIds.size() > 0){
            //Get accounts
            Map<Id,Account> parentAccsMap = new Map<Id,Account>([SELECT Id, Primary_Member__c 
                                                                 FROM Account
                                                                 WHERE Id IN :accsYesPMIds]);
            List<Account> accsForUpdate = new List<Account>();
            //Check if Opp Primary Member is different from Account Primary Member
            for(Opportunity opp : (List<Opportunity>)trigger.new){
                if(oppsYesPMIds.contains(opp.Id)){
                    Account parentAcc = parentAccsMap.get(opp.AccountId);
                    if(parentAcc.Primary_Member__c != opp.Primary_Member__c)
                        accsForUpdate.add(new Account(Id = opp.AccountId, 
                                                      Primary_Member__c = opp.Primary_Member__c));
                }
            }
            //Update Accounts
            if(accsForUpdate.size() > 0){
                update accsForUpdate;
            }
        }
    }

    static String NONE_BUILDING_NAME = 'None';
    /**
    * Comment   : Move related Building Interest records from Lead to current Opportunity when Opportunity is created
    * Issue     : Moving from BuildingInterestTrigger
    * Author    : Hemanshu Shah
    * Date      : 26/June/2016
    * Comments  : This is moved from trigger called BuildingInterestTrigger
    **/
    public static void MoveBuildingInterestsFromLead() {
        Map<Id,string> leadOppMap = new Map<Id,string>(); 
        
        for (sObject record : trigger.new) {
            Opportunity opp = (Opportunity)record;
            if (!String.IsBlank(opp.Lead_Id__c) && (trigger.isInsert || opp.Lead_Id__c != ((Opportunity)trigger.oldMap.get(opp.Id)).Lead_Id__c)) {
                leadOppMap.put(Id.valueOf(opp.Lead_Id__c), opp.Id);
            }
        }
        Debug.log('>>>>>leadOppMap ' + leadOppMap);
        
        if (!leadOppMap.isEmpty()) {

            List<Building_Interest__c> intsToTransfer = [SELECT
                                                            Id, Opportunity__c, Lead__c
                                                         FROM
                                                            Building_Interest__c
                                                         WHERE
                                                            Lead__c IN :leadOppMap.keySet()
                                                         ORDER BY
                                                            Lead__c];
            Debug.log('>>>>>intsToTransfer ' + intsToTransfer);
            for(Building_Interest__c bi : intsToTransfer) {
                bi.Opportunity__c = leadOppMap.get(bi.Lead__c);
                bi.Lead__c = null;
            }
            Debug.log('>>>>>intsToTransfer ' + intsToTransfer);
            if (intsToTransfer.size() > 0) {
                update intsToTransfer;
            }
            
            // When Lead conversion happens because of Tour Scheduled,
            // the "linkage" between Tour and the new Opportunity
            // happens inside the TourScheduledConvertLead trigger itself
            if (TriggersFlags.allowTourUpdates) {
                Tour_Outcome__c[] toursToTransfer = [select Id, Opportunity__c, Lead__c
                                                     from Tour_Outcome__c
                                                     where Lead__c in :leadOppMap.keySet()];
        
                for (Tour_Outcome__c tour:toursToTransfer) {
                    tour.Opportunity__c = leadOppMap.get(tour.Lead__c);
                    tour.Lead__c = null;
                }
                
                if (!toursToTransfer.isEmpty()) {
                    update toursToTransfer;
                }
            }
        }
    }

    /**
    * Comment   : Upsert related Building Interest records when Opportunity is created or updated
    * Issue     : Moving from BuildingInterestTrigger
    * Author    : Hemanshu Shah
    * Date      : 26/June/2016
    * Comments  : This is moved from trigger called BuildingInterestTrigger
    **/
    public static void UpdateBuildingInterestsOfficeType() {
        List<Building_Interest__c> bints = [SELECT Id, Opportunity__c, Office_Type__c FROM Building_Interest__c
                                            WHERE Opportunity__c IN :trigger.newMap.keySet()];
        List<Building_Interest__c> bintsForUpdate = new List<Building_Interest__c>();                                                    
        for(Building_Interest__c bint : bints){
            Opportunity parentOpp = (Opportunity)Trigger.newMap.get(bint.Opportunity__c);
            //Update if it is different
            if(bint.Office_Type__c != parentOpp.Office_Type__c){
                bint.Office_Type__c = parentOpp.Office_Type__c;
                bintsForUpdate.add(bint);    
            }
        }

        if(bintsForUpdate.size() > 0){
            update bintsForUpdate;
        }
    }

    /**
    * Comment   : Upsert related Building Interest records when Opportunity is created or updated
    * Issue     : Moving from BuildingInterestTrigger
    * Author    : Hemanshu Shah
    * Date      : 26/June/2016
    * Comments  : This is moved from trigger called BuildingInterestTrigger
    **/
    public static void UpsertBuildingInterests()
    {
    //Get all existing Building Interest records
        List<Building_Interest__c> existingInts = [SELECT
                                                        Id, Building__c, Building__r.Name, Opportunity__c, Opportunity__r.Locations_Interested__c
                                                   FROM
                                                        Building_Interest__c
                                                   WHERE
                                                        Opportunity__c IN :trigger.newMap.keySet()
                                                   ORDER BY
                                                        Opportunity__c];
        Debug.log('>>>>>existingInts ' + existingInts);
        //Lists for creation and deletion
        List<Building_Interest__c> intsForCreate = new List<Building_Interest__c>();
        List<Building_Interest__c> intsForDelete = new List<Building_Interest__c>();
    
        //Check if Building Interest is removed from Locations_Interested__c list
        Id lastOpp = null;
        Set<string> oppLocationsSet = new Set<string>();
        
        for(Building_Interest__c bi : existingInts){
            if(lastOpp != bi.Opportunity__c){
                lastOpp = bi.Opportunity__c;
                if(String.isBlank(bi.Opportunity__r.Locations_Interested__c)) {
                    oppLocationsSet = new Set<String>{NONE_BUILDING_NAME};
                } else {
                    oppLocationsSet = Common.splitStringToSet(bi.Opportunity__r.Locations_Interested__c , ';');    
                }
            }
            if(!oppLocationsSet.contains(bi.Building__r.Name)){
                intsForDelete.add(bi);
            }
        }
    
        //Check which have to be added
        Map<Id, Set<string>> oppExistingIns = new Map<Id, Set<string>>();
        for(Building_Interest__c bi : existingInts){
            if(!oppExistingIns.containsKey(bi.Opportunity__c)){
                oppExistingIns.put(bi.Opportunity__c, new Set<string>());
            }
            Set<string> biSet = oppExistingIns.get(bi.Opportunity__c);
            biSet.add(bi.Building__r.Name);
        }
    
        List<Building__c> buildings = [SELECT Id, Name FROM Building__c];
        Map<string, Building__c> buildingsMap = new Map<string, Building__c>();
        for(Building__c b : buildings){
            buildingsMap.put(b.Name, b);
        }
    
        for (sObject record : trigger.newMap.values()) {
            Opportunity o = (Opportunity)record;
            List<String> selectedLocations = new List<string>();
            if(string.isBlank(o.Locations_Interested__c)){
                selectedLocations.add(NONE_BUILDING_NAME);
            } else {
                selectedLocations = Common.splitStringToList(o.Locations_Interested__c, ';');
            }
            for (string selectedLocation : selectedLocations) {                 
                Set<string> existingLocations = oppExistingIns.get(o.Id);                 
                if (existingLocations == null || !existingLocations.contains(selectedLocation)) {                   
                    if (buildingsMap.containsKey(selectedLocation)) {
                        Building_Interest__c bi = new Building_Interest__c(Opportunity__c   = o.Id,
                                                                           Building__c      = buildingsMap.get(selectedLocation).Id);
                        intsForCreate.add(bi);
                    }
                }
            }
            
        }
    
        insert intsForCreate;
        delete intsForDelete;
    }

    /**
    * Comment   : Delete related Building Interest records when Opportunity is deleted
    * Issue     : Moving from BuildingInterestTrigger
    * Author    : Hemanshu Shah
    * Date      : 26/June/2016
    * Comments  : This is moved from trigger called BuildingInterestTrigger
    **/
    public static void DeleteBuildingInterests()
    {
        //Get all existing Building Interest records
        List<Building_Interest__c> existingInts = [SELECT
                                                        Id
                                                   FROM
                                                        Building_Interest__c
                                                   WHERE
                                                        Opportunity__c IN :trigger.oldMap.keySet()
                                                   ORDER BY
                                                        Opportunity__c];
        if (existingInts.size() > 0)
            delete existingInts;
    }
    
    /*
    * Comment : ST-530 : Auto tagging for referral app
    * Written By : Anant Kumar
    * Date : 20/July/2016
    */
    public static void updateActiveReferrer(){
    	Set<Id> contactIds = new Set<Id>();
    	for(Opportunity opp : (List<Opportunity>) Trigger.New)
    	{
    		if(opp.Primary_Member__c != null)
    			contactIds.add(opp.Primary_Member__c);
    	}
        if(contactIds.size() > 0)
    	{
	    	Set<String> primaryContactEmails = getPrimaryContactEmail(contactIds);
	    	if(primaryContactEmails.size() > 0)
	    	{
		    	Map<String, Id> mapActiveReferences = ReferenceHandler.getActiveReference(primaryContactEmails);
		    	for(Opportunity opp : (List<Opportunity>) Trigger.New)
		    	{
		    		opp.Referrer__c = mapActiveReferences.get(mapPrimaryContact.get(opp.Primary_Member__c).Email.toLowerCase());
		    	}
	    	}
    	}
    }
    
    public static Map<Id, Contact> mapPrimaryContact;
    public static Set<String> getPrimaryContactEmail(Set<Id> contactIds)
    {
    	Set<String> emails = new Set<String>();
    	mapPrimaryContact = new Map<Id, Contact>();
		mapPrimaryContact = new Map<Id, Contact>([SELECT Id, Email FROM Contact WHERE Id in:contactIds]);
    	for(Contact con : mapPrimaryContact.values())
    	{
    		emails.add(con.Email.toLowerCase());
    	}
    	return emails;
    }
    
    /*
    * Comment : ST-475 : Extend Reference for new Opportunities
    * Written By : Anant Kumar
    * Date : 21/July/2016
    */
    public static void extendReference()
    {
    	Set<Id> contactIds = new Set<Id>();
    	if(Trigger.IsInsert){
    		for(Opportunity opp : (List<Opportunity>) Trigger.New)
	    	{
	    		if(opp.Primary_Member__c != null)
	    			contactIds.add(opp.Primary_Member__c);
	    	}
    	}
    	else {
    		Map<Id, Opportunity> oldMap = (Map<Id, Opportunity>)Trigger.oldMap;
    		for(Opportunity Opp : (List<Opportunity>)Trigger.New)
    		{
    			if(Opp.StageName != oldMap.get(Opp.Id).StageName && Opp.StageName == 'Contract Sent')
    			{
    				if(opp.Primary_Member__c != null)
	    				contactIds.add(opp.Primary_Member__c);
    			}
    		}
    	}
    	if(contactIds.size() > 0)
    	{
    		Set<String> primaryContactEmails = getPrimaryContactEmail(contactIds);
	    	if(primaryContactEmails.size() > 0)
	    	{
	    		ReferenceHandler.ExtendReference(primaryContactEmails);
	    	}
    	}
    }
    
    
    /*
    * Comment : ST-508 : Map opportunity with latest booked tour on its primary member with same location interested
    * Written By : Anant Kumar
    * Date : 29/July/2016
    */
    public static void mapWithLatestTour()
    {
    	Set<Id> contactIds = new Set<Id>();
    	for(Opportunity opp : (List<Opportunity>) Trigger.New)
    	{
    		if(opp.Primary_Member__c != null)
    			contactIds.add(opp.Primary_Member__c);
    	}
    	Map<Id, Contact> mapContacts = new Map<Id, Contact>([SELECT Id, (Select Location__c, CreatedDate From Tours__r ORDER BY CreatedDate DESC Limit 1) FROM Contact WHERE Id in:contactIds]);
        
    	for(Opportunity opp : (List<Opportunity>) Trigger.New)
    	{
    		if(opp.Primary_Member__c != null)
    		{
    			for(Tour_Outcome__c tour : mapContacts.get(opp.Primary_Member__c).Tours__r)
    			{
    				if(tour.Location__c == opp.Building__c)
    					opp.Tour_Outcome__c = tour.Id;
    			}
    		}
    	}
    }

	/*
    * Comment : ST-490 - Workflow Cleanup : Move the workflows into a trigger on Opportunity Object
    * Written By : Pranay Jadhav
	* Comments  : Functionality For 'Default Contract Sign Email' Workflow 
    * Date : 02/08/2016
    */
	public static void updateContractEmail(){
		Set<Id> accountIds = new Set<Id>();
		for(Opportunity opp : (List<Opportunity>) Trigger.New){
    		if(opp.AccountId != null)
    			accountIds.add(opp.AccountId);
    	}
		Map<Id, Account> mapAccounts = new Map<Id, Account>([SELECT Id, Authorized_Signatory__c,Authorized_Signatory__r.Email, Primary_Member__c, Primary_Member__r.Email FROM Account WHERE Id in:accountIds]);
		for(Opportunity opp : (List<Opportunity>) Trigger.New){
    		if(opp.AccountId != null){
    			Account objAccount = mapAccounts.get(opp.AccountId);
    			if(String.isBlank(objAccount.Authorized_Signatory__c))
    				opp.Contract_Email__c = objAccount.Primary_Member__r.Email;
				else 
					opp.Contract_Email__c = objAccount.Authorized_Signatory__r.Email;
			}
    	}
	}

	/*
    * Comment : ST-490 - Workflow Cleanup : Move the workflows into a trigger on Opportunity Object
    * Written By : Pranay Jadhav
	* Comments  : Functionality For 'Update Related Account Lead Source (Only if Lead Source is blank)' Workflow 
    * Date : 03/08/2016
    */
	public static void updateRelatedAccountLeadSource(){
		Set<Id> accountIds = new Set<Id>();
		List<Account> accountToUpdate = new List<Account>();
		for(Opportunity opp : (List<Opportunity>) Trigger.New){
    		if(opp.AccountId != null)
    			accountIds.add(opp.AccountId);
    	}
		Map<Id, Account> mapAccounts = new Map<Id, Account>([SELECT Id, Lead_Source__c FROM Account WHERE Id in:accountIds]);
		for(Opportunity opp : (List<Opportunity>) Trigger.New){
    		if(opp.AccountId != null){
    			Account objAccount = mapAccounts.get(opp.AccountId);
    			if(String.isBlank(objAccount.Lead_Source__c)){
    				objAccount.Lead_Source__c = opp.LeadSource;
					accountToUpdate.add(objAccount);
				}
			}
    	}
		update accountToUpdate;
	}

	/*
    * Comment : ST-490 - Workflow Cleanup : Move the workflows into a trigger on Opportunity Object
    * Written By : Pranay Jadhav
	* Comments  : Functionality For 'Clear Payment Details' And 'Clear Payment Details - 2' Workflow 
    * Date : 03/08/2016
    */
	public static void clearPaymentDetails(){
		for(Opportunity opp : (List<Opportunity>) Trigger.New){
    		if(opp.Payment_Details_Status__c == 'Delete Details'){
    			opp.Bank_Name__c = null;
				opp.Account_Type__c = null;
				opp.Individual_Name_as_it_Appears_on_Card__c = null;
				opp.Billing_Street_Address__c = null;
				opp.Billing_City__c = null;
				opp.Billing_State__c = null;
				opp.Billing_Zip__c = null;
				opp.Credit_Card_Type__c = null;
				opp.CVC__c = null;
				opp.Card_Expiration_Year__c = null;
				opp.Card_Expiration_Month__c = null;
				opp.Credit_Card_Number__c = null;
				opp.Account_Number__c = null;
				opp.Routing_Number__c = null;
			}
    	}
	}

	/*
    * Comment : ST-490 - Workflow Cleanup : Move the workflows into a trigger on Opportunity Object
    * Written By : Pranay Jadhav
	* Comments  : Functionality For 'Update Primary Member Address on Account and
	* Update Primary Member City on Account &
	* Update Primary Member State on Account &
	* Update Primary Member Zip on Account &
	* Update Auth Sign Address on Account &
	* Update Auth Sign City on Account &
	* Update Auth Sign State on Account &
	* Update Auth Sign Zip on Account' Workflow 
    * Date : 03/08/2016
    */
	public static void updateAddressAndAuthorizeOnAccount(){
		Set<Id> accountIds = new Set<Id>();
		List<Account> accountToUpdate = new List<Account>();
		for(Opportunity opp : (List<Opportunity>) Trigger.New){
    		if(opp.AccountId != null)
    			accountIds.add(opp.AccountId);
    	}
		Map<Id, Account> mapAccounts = new Map<Id, Account>([SELECT Id, Primary_Member_Address__c,Primary_Member_City__c,Primary_Member_State__c,Primary_Member_Zip__c,Authorize_Signatory_Address__c,Authorize_Signatory_City__c,Authorize_Signatory_State__c,Authorize_Signatory_Zip__c   FROM Account WHERE Id in:accountIds]);
		for(Opportunity opp : (List<Opportunity>) Trigger.New){
			Account objAccount = mapAccounts.get(opp.AccountId);
			if(objAccount != null){
				objAccount.Primary_Member_Address__c = (String.isNotBlank(opp.Primary_Member_Address__c)) ? (String.isBlank(objAccount.Primary_Member_Address__c)) ? opp.Primary_Member_Address__c : objAccount.Primary_Member_Address__c : opp.Primary_Member_Address__c ;
				objAccount.Primary_Member_City__c = (String.isNotBlank(opp.Primary_Member_City__c)) ? (String.isBlank(objAccount.Primary_Member_City__c)) ? opp.Primary_Member_City__c : objAccount.Primary_Member_City__c : opp.Primary_Member_City__c ;
				objAccount.Primary_Member_State__c = (String.isNotBlank(opp.Primary_Member_State__c)) ? (String.isBlank(objAccount.Primary_Member_State__c)) ? opp.Primary_Member_State__c : objAccount.Primary_Member_State__c : opp.Primary_Member_State__c ;
				objAccount.Primary_Member_Zip__c = (String.isNotBlank(opp.Primary_Member_Zip__c)) ? (String.isBlank(objAccount.Primary_Member_Zip__c)) ? opp.Primary_Member_Zip__c : objAccount.Primary_Member_Zip__c : opp.Primary_Member_Zip__c ;
				objAccount.Authorize_Signatory_Address__c = (String.isNotBlank(opp.Authorize_Signatory_Address__c)) ? (String.isBlank(objAccount.Authorize_Signatory_Address__c)) ? opp.Authorize_Signatory_Address__c : objAccount.Authorize_Signatory_Address__c : opp.Authorize_Signatory_Address__c ;
				objAccount.Authorize_Signatory_City__c = (String.isNotBlank(opp.Authorize_Signatory_City__c)) ? (String.isBlank(objAccount.Authorize_Signatory_City__c)) ? opp.Authorize_Signatory_City__c : objAccount.Authorize_Signatory_City__c : opp.Authorize_Signatory_City__c ;
				objAccount.Authorize_Signatory_State__c = (String.isNotBlank(opp.Authorize_Signatory_State__c)) ? (String.isBlank(objAccount.Authorize_Signatory_State__c)) ? opp.Authorize_Signatory_State__c : objAccount.Authorize_Signatory_State__c : opp.Authorize_Signatory_State__c ;
				objAccount.Authorize_Signatory_Zip__c = (String.isNotBlank(opp.Authorize_Signatory_Zip__c)) ? (String.isBlank(objAccount.Authorize_Signatory_Zip__c)) ? opp.Authorize_Signatory_Zip__c : objAccount.Authorize_Signatory_Zip__c : opp.Authorize_Signatory_Zip__c ;
			}
			accountToUpdate.add(objAccount);
    	}
		update accountToUpdate;
	}

	/*
    * Comment : ST-490 - Workflow Cleanup : Move the workflows into a trigger on Opportunity Object
    * Written By : Pranay Jadhav
	* Comments  : Functionality For 'Update Account Start Date' Workflow 
    * Date : 03/08/2016
    */
	public static void updateAccountStartDate(){
		Set<Id> accountIds = new Set<Id>();
		List<Account> accountToUpdate = new List<Account>();
		for(Opportunity opp : (List<Opportunity>) Trigger.New){
    		if(opp.AccountId != null)
    			accountIds.add(opp.AccountId);
    	}
		Map<Id, Account> mapAccounts = new Map<Id, Account>([SELECT Id, Start_Date__c FROM Account WHERE Id in:accountIds]);
		for(Opportunity opp : (List<Opportunity>) Trigger.New){
    		if(opp.AccountId != null){
    			Account objAccount = mapAccounts.get(opp.AccountId);
				if(objAccount != null)
					objAccount.Start_Date__c = (opp.StageName == 'Contract Signed') ? (objAccount.Start_Date__c == null) ? opp.Actual_Start_Date__c : objAccount.Start_Date__c : objAccount.Start_Date__c ;
				accountToUpdate.add(objAccount);
			}
    	}
		update accountToUpdate;
	}

	/*
    * Comment : ST-490 - Workflow Cleanup : Move the workflows into a trigger on Opportunity Object
    * Written By : Pranay Jadhav
	* Comments  : Functionality For 'Contract Sent Date' Workflow 
    * Date : 03/08/2016
    */
	public static void updateContractSentDate(){
		for(Opportunity opp : (List<Opportunity>) Trigger.New){
    		if(opp.StageName == 'Contract Sent'){
    			opp.Contract_Sent_Date__c = System.today();
			}
    	}
	}

	/*
    * Comment : ST-490 - Workflow Cleanup : Move the workflows into a trigger on Opportunity Object
    * Written By : Pranay Jadhav
	* Comments  : Functionality For 'Opportunity Inquiry Date if nothing - TODAY' Workflow 
    * Date : 03/08/2016
    */
	public static void setOpportunityInquiryDate(){
		for(Opportunity opp : (List<Opportunity>) Trigger.New){
    		if(opp.Inquiry_Date__c == null){
    			opp.Inquiry_Date__c = System.today();
			}
    	}
	}	

	/*
    * Comment : ST-490 - Workflow Cleanup : Move the workflows into a trigger on Opportunity Object
    * Written By : Pranay Jadhav
	* Comments  : Functionality For 'Change Close Date to date Closed Won' Workflow 
    * Date : 03/08/2016
    */
	public static void changeCloseDatetoDateClosedWon(){
		Debug.turnDebugOn();
		for(Opportunity opp : (List<Opportunity>) Trigger.New){
    		if(opp.StageName == 'Closed Won' && opp.CloseDate < System.today()){
    			opp.CloseDate = System.today();
				Debug.log(' :: changeCloseDatetoDateClosedWon :: '+ opp);
			}
    	}
	}

	/*
    * Comment : ST-490 - Workflow Cleanup : Move the workflows into a trigger on Opportunity Object
    * Written By : Pranay Jadhav
	* Comments  : Functionality For 'if change Stage from Contract Sent, update Payment Details Status to null and null Payment URL' Workflow 
    * Date : 03/08/2016
    */
	public static void changeStagefromContractSent_UpdatePaymentDetailsStatustoNullandPaymentURL(){
		Set<String> excludeStageName = new Set<String>{'Contract Sent', 'Contract Signed', 'Closed Won', 'Closed Lost'};
		for(Opportunity opp : (List<Opportunity>) Trigger.New){
			Opportunity oldOpp = (Opportunity) Trigger.oldMap.get(opp.Id);
			Boolean isChangedStage = (!oldOpp.StageName.equals(opp.StageName));
    		if(isChangedStage && (!excludeStageName.contains(opp.StageName))){
				opp.Payment_Details_Status__c = null;
				opp.Payment_URL__c = null;
			}
    	}
	}

	/*
    * Comment : ST-490 - Workflow Cleanup : Move the workflows into a trigger on Opportunity Object
    * Written By : Pranay Jadhav
	* Comments  : Functionality For 'Set Building Email field' Workflow 
    * Date : 04/08/2016
    */
	public static void setBuildingEmailField(){
		Debug.turnDebugOn();
		Set<Id> buildingIds = new Set<Id>();
		for(Opportunity opp : (List<Opportunity>) Trigger.New){
    		if(opp.Building__c != null)
    			buildingIds.add(opp.Building__c);
    	}
		Map<Id, Building__c> mapBuildings = new Map<Id, Building__c>([SELECT Id, Email__c FROM Building__c WHERE Id in:buildingIds]);
		
		for(Opportunity opp : (List<Opportunity>) Trigger.New){
    		if(opp.Building__c != null){
				opp.Building_Email1__c = mapBuildings.get(opp.Building__c).Email__c;
				Debug.log(' :: setBuildingEmailField In IF :: ==>> '+ opp);
			}
    	}
	}


}