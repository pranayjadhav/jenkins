global class WeworkEngine
{
    public static String currentSandboxPath{ get; set;}
    public static List<Building__c> listBuildings { get; set;}
    public static SelectOption[] availableTimes {get; set;}
    //System.URL.getSalesforceBaseURL().getHost();
    
    public WeworkEngine(){
        currentSandboxPath = System.URL.getSalesforceBaseURL().toExternalForm();
    }
    
    @RemoteAction
    public static sObject[] Query(String strQuery) {
        return Database.Query(strQuery);
    }
    
	@RemoteAction
    public static List<List<sObject>> searchQuery(String strSearchQuery) {
        return Search.query(strSearchQuery);
    }

    //Retuns all picklist value.
    @RemoteAction
    public static List<String> fetchObjectFields( String objectApiName, String fieldApiName )
    {
        List<String> lstFieldValues = new List<String>();
        Schema.SObjectType targetObjectType = Schema.getGlobalDescribe().get(objectApiName);
        Map<String, Schema.SObjectField> field_map = targetObjectType.getDescribe().fields.getMap();
        for(Schema.PicklistEntry picklistEntry : field_map.get(fieldApiName).getDescribe().getPickListValues())
            lstFieldValues.add(picklistEntry.getLabel());
        return lstFieldValues;
    }
    
    @RemoteAction
    public static User GetLoggedInUserInfo() {
        User currentUser = [SELECT Profile.Name, Id, Username, Profile.Id FROM User WHERE Id = :UserInfo.getUserId()];
        return currentUser;
    }
    
    public static sObject ConstructSobject(String sObjectApiName, String jSONSObject)
    {
        try
        {
            Map<String, Object> fieldMap = null;
            fieldMap = (Map<String, Object>)JSON.deserializeUntyped(jSONSObject);
            Schema.SObjectType targetType = Schema.getGlobalDescribe().get(sObjectApiName);
            SObject newSobject = targetType.newSObject();
            Map<String, Schema.sObjectField> targetFields = targetType.getDescribe().fields.getMap();
            for (String key : fieldMap.keySet()) 
            {
                Object value = fieldMap.get(key);
                Schema.DisplayType valueType = targetFields.get(key).getDescribe().getType();
                if (value instanceof String && valueType != null && valueType != Schema.DisplayType.String) 
                {
                    String svalue = (String)value;
                    if (valueType == Schema.DisplayType.Date)
                        newSobject.put(key, Date.valueOf(svalue));
                    else if(valueType == Schema.DisplayType.DateTime)
                        newSobject.put(key, DateTime.valueOfGmt(svalue));
                    else if (valueType == Schema.DisplayType.Percent || valueType == Schema.DisplayType.Currency) 
                        newSobject.put(key, svalue == '' ? null : Decimal.valueOf(svalue));
                    else if (valueType == Schema.DisplayType.Double)
                        newSobject.put(key, svalue == '' ? null : Double.valueOf(svalue));
                    else if (valueType == Schema.DisplayType.Integer)
                        newSobject.put(key, Integer.valueOf(svalue));
                    else if (valueType == Schema.DisplayType.Base64)
                        newSobject.put(key, Blob.valueOf(svalue));
                    else
                        newSobject.put(key, svalue);
                } 
                else
                    newSobject.put(key, value);
            }
            return newSobject;
        }
        catch(Exception ex)
        {
            Debug.log('Exception occured while creating sObject:'+ex.getMessage());
            return null;
        }
    }
    
    @RemoteAction
    public static String getUserName(){
        return UserInfo.getName();
    }
    
    @RemoteAction
    public static Boolean DeleteRecord(String strAPIName, String strJSONObject){
        sObject newSobject = ConstructSobject(strAPIName,strJSONObject);
        
        try{
            Database.delete(String.valueOf(newSobject.get('Id')));
            return true;
        }
        catch(Exception ex){
            Debug.log('Error occured while deleting the record:'+ex.getMessage());
        }
        return false;
        
    }
    
    @RemoteAction
    public static Setting__c getSettings(Id settingsId) {
        return [Select Id,Name,Data__c,Destination_Object__c,Source_Object__c,Type__c FROM Setting__c WHERE Id = :settingsId];
    }
    
    @RemoteAction
    public static List<Database.DeleteResult> DeleteRecords(List<Id> lstIds) 
    {   if(!lstIds.isEmpty())
        return Database.delete(lstIds); 
     else
         return null;    
    }
    
    @RemoteAction
    public static List<SaveResult> SaveRecords(List<sObject> lstObj){
        Debug.log('test==>'+lstObj);
        List<sObject> lstUpdateObj = new List<sObject>();
        List<sObject> lstNewObj = new List<sObject>();
        List<SaveResult> lstResult = new List<SaveResult>();
        try{
            for(sObject obj : lstObj){
                if(String.isNotEmpty(obj.Id))
                    lstUpdateObj.add(obj);
                else
                    lstNewObj.add(obj);
            }
            if(lstUpdateObj.size() > 0){
                for(Database.Saveresult newDatabaseUpdateResult : Database.update(lstUpdateObj)){
                    lstResult.add(new SaveResult(Database.update(lstUpdateObj)));
                }
            }
            if(lstNewObj.size() > 0){
                for(Database.Saveresult newDatabaseSaveResult : Database.insert(lstNewObj)){
                    lstResult.add(new SaveResult(newDatabaseSaveResult));
                }
            }
        }catch(Exception ex){
            lstResult.add(new SaveResult(ex));
        }
        return lstResult;
    }

    public class FieldResult{
        public string name { get; set;}
        public string label { get; set;}
        public integer length { get; set;}
        public Schema.Displaytype type { get; set;}
    }

    @RemoteAction
    public static List<FieldResult> GetAllFields(String objType){
        Map<String,DescribeFieldResult> fieldsWithDetails = new Map<String,DescribeFieldResult>();
        List<FieldResult> lstFieldResult = new List<FieldResult>();
        Schema.DescribeSobjectResult[] results = Schema.describeSObjects(new String[]{objType});
        for(Schema.DescribeSobjectResult res : results) {
            for(Schema.SObjectField field: res.fields.getMap().values()){
                DescribeFieldResult fieldDescribe = field.getDescribe();
                FieldResult result = new FieldResult ();
                result.name = fieldDescribe.name;
                result.label = fieldDescribe.label;
                result.length = fieldDescribe.length;
                result.type = fieldDescribe.type;
                lstFieldResult.add(result);
                fieldsWithDetails.put(fieldDescribe.name,fieldDescribe);
            }
        }
        Debug.log('Test : : ' + lstFieldResult);
        return lstFieldResult;
    }
    
    @RemoteAction
    public static Date addBusinessDays(String givenDateStr, Integer daysToAdd){
        Date givenDate = date.parse(givenDateStr);
        return DateUtilities.addBusinessDays(givenDate, daysToAdd);
    }
    
    @RemoteAction
    public static Date getNextBusinessDay(String givenDateStr){
        Date givenDate = date.parse(givenDateStr);
        return DateUtilities.getNextBusinessDay(givenDate);
    }
    
    @RemoteAction
    public static List<Building__c> getBuildingList(String product_line) {      
        listBuildings = new List<Building__c>();
        for (Tour_Schedule__c t:[Select Id,Building__r.UUID__c,Building__r.Id,Building__r.Name,Building__r.City__c,Building__r.Time_Zone__c,Building__r.Tour_Spacing__c From Tour_Schedule__c Where Product_Line__c =: product_line order by Building__r.Sort_Order__c asc]) {       
            Building__c b = new Building__c(Id = t.Building__r.Id, Name = t.Building__r.Name, City__c = t.Building__r.City__c, Time_Zone__c = t.Building__r.Time_Zone__c, Tour_Spacing__c = t.Building__r.Tour_Spacing__c, UUID__c = t.Building__r.UUID__c);
            listBuildings.add(b);
        }
        return listBuildings;
    }

    @RemoteAction
    public static LeadConvertor.ContactResult[] getLeadsToJourneys(List<Id> lstLeadIds) {
        Set<Id> setLeadIds = new Set<Id>(lstLeadIds);
        Debug.log('setLeadIds : '+ setLeadIds);
        List<LeadConvertor.ContactResult> resultRet = new List<LeadConvertor.ContactResult>();
        List<Lead> lstLead = new List<Lead>([Select Id,FirstName,LastName, IsConverted, Name, Phone, Email From Lead Where Id IN : setLeadIds]);
        List<String> lstEmail = new List<String>();
        for(Lead lead : lstLead)
            lstEmail.add(lead.Email);
            
        List<Contact> lstContact = new List<Contact>([Select Id, FirstName, LastName, Phone, Email From Contact Where Email IN : lstEmail]);
        debug.log('lstContact::'+lstContact);
        if(!lstLead[0].IsConverted){
            if(lstContact != null && lstContact.size() == 0){
                Contact newContact = new Contact();
                newContact.FirstName = lstLead[0].FirstName;
                newContact.LastName = lstLead[0].LastName;
                newContact.Phone = lstLead[0].Phone;
                newContact.Email = lstLead[0].Email;
                insert newContact;
                debug.log('newContact::'+newContact.id);
            }
            return resultRet = LeadConvertor.ConvertLeadsToContact(lstEmail);
        }
        else{
            LeadConvertor.ContactResult result = new LeadConvertor.ContactResult();
             result.ContactId = lstContact[0].Id;
             //result.AccountId = contact.AccountId;
             resultRet.add(result);
             return resultRet;
        }
        //return resultRet = LeadConvertor.ConvertLeadsToJourneys(setLeadIds);
    }
    
    @RemoteAction
    public static SelectOption[] loadAvailableTimes(Date tourDate,Id selectedBuilding,String product_line, String selectedBuildingTZ) {
        Debug.log('loadAvailableTimes ::'+tourDate);
        Debug.log('selectedBuilding ::'+selectedBuilding);    
        Debug.log('TourServices.getAvailableTimes(tourDate, selectedBuilding, product_line) ::'+TourServices.getAvailableTimes(tourDate, selectedBuilding, product_line));
        if(availableTimes == null)
            availableTimes = new List<SelectOption>();
        for (Time t:TourServices.getAvailableTimes(tourDate, selectedBuilding, product_line)) {
            String timeAsString = DateTime.newInstance(tourDate, t).format('h:mma', selectedBuildingTZ);
            Debug.log('timeAsString ::'+timeAsString);
            Debug.log('availableTimes ::'+availableTimes); 
            availableTimes.add(new SelectOption(timeAsString, timeAsString));
        }
        Debug.log('availableTimes ::'+availableTimes); 
        return availableTimes;
    }
    
    @RemoteAction
    public static SaveResult reScheduleTours(List<Tour_Outcome__c> lstNewTourRecords, List<Tour_Outcome__c> lstUpdateTourRecords) {     
        SaveResult tourResult;
        list<SaveResult> newTourRecordsResult,updateTourRecordsResult;
        Savepoint sp = Database.setSavepoint();
        try{
            if(!lstNewTourRecords.isEmpty() && !lstUpdateTourRecords.isEmpty()){
                newTourRecordsResult = WeworkEngine.SaveRecords(lstNewTourRecords);
                updateTourRecordsResult = WeworkEngine.SaveRecords(lstUpdateTourRecords);
            }
            if(newTourRecordsResult[0].IsSuccess==true && updateTourRecordsResult[0].IsSuccess==true){
                tourResult = new SaveResult();
                tourResult.IsSuccess = true;
                tourResult.Id = newTourRecordsResult[0].Id;
                tourResult.Message = 'Tour Reschedule Successful.';
            }else{
                Database.rollback(sp);
                tourResult = new SaveResult();
                tourResult.IsSuccess = false;
                tourResult.Message = 'Tour Reschedule Failed.';
            }
            
        }catch(Exception ex){
            Database.rollback(sp);
            tourResult = new SaveResult(ex);
        }
        return tourResult;
    }
    
	@RemoteAction
	public static SaveResult extendReference(Id recordId, Date expiryDate){
		SaveResult sr = ReferenceHandler.ExtendReference(recordId, expiryDate);
		return sr;
	}

	@RemoteAction
	public static Setting__c getSettingsRecord(String settingsName){
		return  Settings.get(settingsName);
	}

     /*
    Comment   : This method will create new Activity when new Tour get booked. 
    Author    : Mayuresh Ghodke 
    Date      : 16/07/2016 */
    @RemoteAction
    public static String createActivityForTour(String contactId,String journeyId,List<Task> lstTour) {
    	String result = null;
        try{
            Task newTask = new Task();
            Debug.log('contactId ::'+contactId);
            Debug.log('journeyId ::'+journeyId);
            Debug.log('lstTour ::'+lstTour);
            List<Contact> lstContcat = new List<Contact>();
            if(contactId != '')
            	lstContcat = [Select Id, Name, Phone, Email From Contact Where Id =: contactId];
            List<Task> lstNewTask = new List<Task>();
            if(lstContcat!=null && !lstContcat.isEmpty()){
            	for(sObject dueDate : lstTour){
            		newTask.Subject = 'Tour Booked';
	            	newTask.WhoId = lstContcat[0].Id;
	            	newTask.Status = 'In Progress';
	            	if(journeyId != '')
	            		newTask.WhatId = journeyId;
	            	newTask.Subject = 'Tour Booked';
	            	//newTask.Phone = lstContcat[0].Phone;
	            	//newTask.Email = 'lstContcat[0].Email';
	            	
	            	//newTask.ActivityDate = lstTour.Date;
	            	//newTask.Product_Line__c = lstTour.ProductLine;
	            	newTask.Subject = 'Tour Booked';
	            	lstNewTask.add(newTask);
            	}
            }
            if(lstNewTask!=null && !lstNewTask.isEmpty()){
            	insert lstNewTask;
            }
            result = 'Activities created.';
        }catch(Exception ex){
            //Database.rollback(sp);
            result = 'Activities creation failed.'+ex;
        }
        return result;
    }
    
    
     /*
    Comment   : This method used for create 'Journey' and 'Journey Contact' record . 
    Issue     : ST-380
    Parameters: ContactId, Lead Source
    Author    : Amol Darekar 
    Date      : 11/06/2016 */
    @RemoteAction
    public static List<SaveResult> createJourneryAndJourneyContact(String recordId,string leadSource, string buildingInterested, Boolean isLead)
    {
        try
        {
            List<SaveResult> lstJourneyResult = new List<SaveResult>();
            List<SaveResult> lstJourneyContactResult = new List<SaveResult>();
            List<Contact> lstContact = new List<Contact>();
            List<Lead> lstLead = new List<Lead>();
            
            if(isLead)
                lstlead = [Select Id,Name,FirstName,LastName,Market__c,Building_Interested_In__r.City__c, LeadSource from Lead where Id =:recordId];
            else
                lstContact  = [Select Id,Name,FirstName,LastName,Market__c,LeadSource from contact where Id =:recordId];
                
            Journey__c objNewJourney = new Journey__c();
            
            if((lstContact!=null && lstContact.size()>0) || (lstLead!=null && lstLead.size()>0))
            {
                
                if(isLead && lstLead[0].LastName !=null)
                {
                    //objNewJourney.Name = lstLead[0].FirstName;
                    objNewJourney.Name = lstLead[0].Name +'-'+(string.isBlank(lstLead[0].Building_Interested_In__r.City__c) ? '' :lstLead[0].Building_Interested_In__r.City__c+'-') +''+ lstLead[0].LeadSource;
                   
                }
                else if(lstContact[0].LastName !=null)
                {
                    //objNewJourney.Name = lstContact[0].FirstName;
                 
                    objNewJourney.Name = lstContact[0].Name +'-'+ (string.isBlank(lstContact[0].Market__c) ? '' :lstContact[0].Market__c+'-') +''+ lstContact[0].LeadSource;
                }
                
                if(objNewJourney.Name != null && objNewJourney.Name.length() > 80)
                 {
                    objNewJourney.Name =  objNewJourney.Name.substring(0, 80);
                 }
                 
                 objNewJourney.Building_Interested_In__c = buildingInterested;
                 objNewJourney.NMD_Next_Contact_Date__c = DateUtilities.addBusinessDays(Date.today(), 1);
                 objNewJourney.Lost_Reason__c = leadSource;
                 objNewJourney.Stage__c = 'Started';
                 
                 if(isLead)
                   objNewJourney.Primary_Lead__c = recordId;
                 else
                   objNewJourney.Primary_Contact__c = recordId;
                
                lstJourneyResult = WeworkEngine.SaveRecords(new List<Journey__c>{objNewJourney});
                Debug.log('lstJourneyResult : '+lstJourneyResult);
         }
        
          return lstJourneyResult;
        }
        catch(Exception ex)
        {
            Debug.log('Exception:'+ex);
            return null;
        }
    }
    
    /*
    Comment   : This will call from Lead's custom button. 
    			If that Lead's Company Size is > 15 then change its record type to 'Enterprise Solutions' and change owner to 'Enterprise Queue'.
    Issue     : ST-384
    Author    : Mayuresh Ghodke
    Date      : 25/07/2016 */
    webservice static string changeLeadRecordType(String leadId)
    {
         List<Lead> lstLead = new List<Lead>();
         lstLead = [Select Id, Company_Size__c, OwnerId, RecordTypeId From Lead Where Id =: leadId Limit 1];
         String reuslt = 'Please Try Angain.';
        
         List<Group> lstOwnerInfo = new List<Group>();
         lstOwnerInfo = [select Id From Group where Name = 'Enterprise Queue' limit 1];
         
         List<RecordType> lstRecordType = new List<RecordType>();
         lstRecordType = [select Id from RecordType where Name = 'Enterprise Solutions' and sObjectType = 'Lead'];
        
         if(lstLead[0].Company_Size__c != null){
         	Integer endRangeVal = null;
         	Boolean containsUpperRange = lstLead[0].Company_Size__c.contains('-');
            Boolean containsLowerRange = lstLead[0].Company_Size__c.contains('+');
            if(containsUpperRange){
               String[] range = lstLead[0].Company_Size__c.split('-');                    
               if(range.Size() > 1){
	               	String[] endRange = range[1].split(' ');
	                if(endRange[0] != '')
	                	endRangeVal = Integer.valueof(endRange[0]);
	                else
	                    endRangeVal = Integer.valueof(endRange[1]);
                }
             	else{
	                 String lastRange = range[0].substring(0,range[0].length()-1);
	                 endRangeVal = Integer.valueof(lastRange);	
              }
             }
             else if(containsLowerRange) {
             	String range = lstLead[0].Company_Size__c; 
                range = range.removeEnd('+');
                endRangeVal = Integer.valueof(range);
             }
             else{
             	endRangeVal = Integer.valueof(lstLead[0].Company_Size__c);
             }
			 if(endRangeVal > 14){
			 	if(lstLead[0].OwnerId != lstOwnerInfo[0].Id && lstLead[0].RecordTypeId != lstRecordType[0].Id){
					lstLead[0].OwnerId = lstOwnerInfo[0].Id;
					lstLead[0].RecordTypeId = lstRecordType[0].Id;
					update lstLead;
					reuslt = 'Lead is submitted to Enterprise Solution Team successfully';
					Task newTask = new Task();
					newTask.Subject = ' Owner and Record Type Change to Enterprise Solution Queue';
	            	newTask.WhoId = lstLead[0].Id;
	            	//newTask.Status = 'In Progress';
	            	insert newTask;
				}
				else if(lstLead[0].OwnerId != lstOwnerInfo[0].Id){
					lstLead[0].OwnerId = lstOwnerInfo[0].Id;
					update lstLead;
					reuslt = 'Lead is submitted to Enterprise Solution Team successfully';
					Task newTask = new Task();
					newTask.Subject = 'Owner Change to Enterprise Solution Queue';
	            	newTask.WhoId = lstLead[0].Id;
	            	//newTask.Status = 'In Progress';
	            	insert newTask;
				}
				else if(lstLead[0].RecordTypeId != lstRecordType[0].Id){
					lstLead[0].RecordTypeId = lstRecordType[0].Id;
					update lstLead;
					reuslt = 'Lead is submitted to Enterprise Solution Team successfully';
					Task newTask = new Task();
					newTask.Subject = 'Record Type Change to Enterprise Solution';
	            	newTask.WhoId = lstLead[0].Id;
	            	//newTask.Status = 'In Progress';
	            	insert newTask;
				}
				else{
				reuslt = 'Lead is already submitted to Enterprise Solution Team';
				}
			}
			else{
				reuslt = 'Company Size is less than 15 desk. Unable to submit to Enterprise Solution Team';
			}
		 }         
         else{
         	reuslt = 'Please update Company Size to submit to Enterprise Solution Team';
         }
         return reuslt;
    }
}