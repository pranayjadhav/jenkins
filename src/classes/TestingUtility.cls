@isTest
public class TestingUtility {
    
    public static List<String> monthsList = new List<String>{'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'};
    public static final String CURRENT_YEAR = String.valueOf( Date.today().year() );
    
    // <summary>
    // Created By: Anant Kumar.
    // Created On: 23-02-2016.
    // Purpose: To Create multiple Test Records for Test methods.
    // Parameters:
    // 1. intRecordCount: Number of Records to be Created.
    // 2. sObjectTypeRequested: sObject Type for which record to be Created.
    // 3. recordValuesMap: If record has specific value for Fields.
    // 4. DoInsert: Perform insert or return Only records.
    // Return type: List of Requested sObject Type Records.
    
    public static List<sObject> createTestRecords(Integer intRecordCount,Schema.sObjectType sObjectTypeRequested, List<Map<String,Object>> recordValuesList,Boolean DoInsert){
        List<sObject> sObjectList = new List<sObject>();
        Map<String,Schema.DescribeFieldResult> requiredFieldsMap = getNullabelRequiredFields(sObjectTypeRequested);
        sObject record = null;
        for(integer index = 0; index < intRecordCount; index++){
            
            record = sObjectTypeRequested.newSobject();
            Map<String, Object> recordValuesMap;
            if(intRecordCount <= recordValuesList.size()){
                recordValuesMap = recordValuesList[index];
            }
            else if(recordValuesList.size() > 0){
                recordValuesMap = recordValuesList[0];
            }
            if(recordValuesMap != null && !recordValuesMap.isEmpty()){
                for(String strUserField : recordValuesMap.keySet()){                    
                    record.put(strUserField.trim(),recordValuesMap.get(strUserField));
                }   
            }            
            for(String strField : requiredFieldsMap.keySet()){
                if(recordValuesMap == null || recordValuesMap.isEmpty() || !recordValuesMap.containsKey(strField))
                {
                    record.put(strField,getTestValue(requiredFieldsMap.get(strField)));    
                }
            }          
            sObjectList.add(record);
        }
        if(DoInsert)
            InsertListWithAssert(sObjectList);
        
        return sObjectList;
    }
    
    // Created By: Anant Kumar
    // Created On: 23-02-2016
    // Purpose: To Create a Test Records for Test methods.
    // Parameters:
    // 1. sObjectTypeRequested: sObject Type for which record to be Created.
    // 2. recordValuesMap: If record has specific value for Fields.
    // 3. DoInsert: Perform insert or return Only records.
    // Return type: single sObject type record.
    public static sObject createTestRecords(Schema.sObjectType sObjectTypeRequested, Map<String,Object> recordValuesMap,Boolean DoInsert){
        List<Map<String,Object>> newListOfMap = new List<Map<String,Object>>(); 
        newListOfMap.add(recordValuesMap);
        return createTestRecords(1, sObjectTypeRequested, newListOfMap, DoInsert)[0];
    }
    
    //Return Type: Mulitple sObject type record
    public static List<sObject> createTestRecords(Schema.sObjectType sObjectTypeRequested, List<Map<String,Object>> recordValuesList,Boolean DoInsert){
        return createTestRecords(recordValuesList.size(), sObjectTypeRequested, recordValuesList, DoInsert);
    }
    
    // <summary>
    // Created By: Anant Kumar
    // Created On: 23-02-2016.
    // Purpose: To Get the Required Fields from sObject.
    // Parameters:
    // 1. sObjectTypeRequested: sObject Type to get Required Fields.    
    // Return type: List Field Describe Object of required Fields.
    static Map<String,Schema.DescribeFieldResult> getNullabelRequiredFields(Schema.sObjectType sObjectTypeRequested){
        Map<String,Schema.DescribeFieldResult> describeFieldMap = new Map<String,Schema.DescribeFieldResult>();
        Schema.DescribeSObjectResult dResult = sObjectTypeRequested.getDescribe();
        Map<String,Schema.SObjectField> fieldsMap = dResult.fields.getMap();
        for(Schema.SObjectField field : fieldsMap.values()){
             Schema.DescribeFieldResult fieldMetadata = field.getDescribe();
            if(fieldMetadata.IsCreateable() && !fieldMetadata.IsNillable() && !fieldMetadata.IsDefaultedOnCreate() ){
                describeFieldMap.put(fieldMetadata.getName(),fieldMetadata);
            }
        }
        return describeFieldMap;
    }    
    
    // <summary>
    // Created By: Anant Kumar.
    // Created On: 23-02-2016.
    // Purpose: To Get the Test Values for sObject's Required Fields.
    // Parameters:
    // 1. fieldDescribe: Result of Field Describe.    
    // Return type: Object of Test Value.
    static Object getTestValue(Schema.DescribeFieldResult fieldDescribe){
        Object TestValue = null;
        if(fieldDescribe != null){
            Schema.DisplayType displayType = fieldDescribe.getType();
            if(displayType.equals(Schema.DisplayType.Email)){ 
                TestValue = createStringValue() +'@Email.com';
            }
            else if(displayType.equals(Schema.DisplayType.DATETIME)){
                TestValue = DateTime.now();
            }
            else if(displayType.equals(Schema.DisplayType.STRING) || displayType.equals(Schema.DisplayType.TEXTAREA)){
                TestValue = createRandomString();
            }
            else if(displayType.equals(Schema.DisplayType.URL)){
                TestValue = 'https://'+ createStringValue() +'.com';
            }
            else if(displayType.equals(Schema.DisplayType.TIME)){
                TestValue = Time.newInstance(12, 00, 00, 00);
            }
            else if(displayType.equals(Schema.DisplayType.BASE64))
            {
                TestValue = Blob.valueOf(createStringValue());
            }
            else if(displayType.equals(Schema.DisplayType.Currency))
            {
                TestValue = math.rint( math.random() * 100000 );
            }
            else if(displayType.equals(Schema.DisplayType.Date))
            {
                TestValue = Date.today();
            }
            else if(displayType.equals(Schema.DisplayType.Double))
            {
                TestValue = math.rint( math.random() * 100000 );
            }
            else if(displayType.equals(Schema.DisplayType.Percent))
            {
                TestValue = math.rint( math.random() * 100000 );
            }
            else if(displayType.equals(Schema.DisplayType.Phone))
            {
                TestValue = 987654321;
            }
            else if(displayType.equals(Schema.DisplayType.Reference))
            {
                List<sObject> sObjectList = createTestRecords(1,fieldDescribe.getReferenceTo()[0], null,true);
                TestValue = sObjectList[0].Id;
            }
        }        
        return TestValue;
    }
    
    //Method to get the record type of sObjects By Name.
    public static Map<String,Id> getRecordTypeMapByName ( Schema.SObjectType sObjectType)
    {
        Map<String,Id> recordTypeByNameMap = new Map<String,Id>();
        for( RecordType recordType :  [SELECT Id, Name FROM RecordType WHERE sObjectType =: String.valueOf(sObjectType)])
            recordTypeByNameMap.put( recordType.Name, recordType.Id);            
        return recordTypeByNameMap;
    }
    
    //Method to get the Admin User
    public static User getAdminUser(){
        return [SELECT Id, Name, Email FROM User WHERE Profile.Name ='System Administrator' AND IsActive = true LIMIT 1]; 
    }
    
    //Method to get the guest User
    public static User getGuestUser(){
        User guestUser = [SELECT Id, alias, Email, LastName, ProfileId, UserName, CommunitynickName FROM User WHERE userType='Guest'  LIMIT 1];
        system.assert(guestUser != null,'No Guest User Found');
        return guestUser;
    }
    
    //Method to get the current User
    public static User getCurrentUser(){
         User currentUser = [SELECT Id, Alias, Email, Lastname, FirstName,Profileid, UserName, CommunitynickName,CompanyName FROM user WHERE Id = :UserInfo.getUserId()]; 
         return currentUser;
    }
    
    //Method to get the admin profile id
    public static Id getAdminProfileId(){
        Id profileId = [SELECT Id FROM Profile WHERE Name =:'System Administrator' LIMIT 1].Id;
        return profileId;
    }
    //Purpose: To get the Random Name for Test Record.
    public static String createStringValue(){
      return'TestValue' + math.rint( math.random() * 100000 );
    }
    
    //Purpose: To get the Random Name for Test Record.
    public static String createRandomString(){
      return'Te' + math.rint( (math.random() * 1000));
    }
    
    // <summary>
    // Created By: Anant Kumar.
    // Created On: 23-02-2016.
    // Purpose: To Get the Test Values for sObject's Required Fields.
    // Parameters:
    // 1. objName: API Name of object.  
    // 2. fieldsToCheck : Fields name to be check for Access.  
    // 3. crudType: crudType i.e Delete, Update, Insert
    // Return type: Is Fields has specified Access.
    public Boolean checkObjectCrud( Schema.SObjectType objectType, Set<String> fieldsToCheck, String crudType ){  
      // Get the global describe
      Schema.DescribeSObjectResult objectResult = objectType.getDescribe();
        Map<String,Schema.SObjectField> fieldsMap = objectResult.fields.getMap();
        if(fieldsToCheck != null && !fieldsToCheck.isEmpty()){
            for(String field : fieldsToCheck){
                if(fieldsMap.containsKey(field)){
                    Schema.DescribeFieldResult fieldDescribe = fieldsMap.get( field ).getDescribe();
                    if( 'create'.equalsIgnoreCase( crudType ) && !fieldDescribe.isCreateable()){
                        return false;
                      }
                      else if( 'update'.equalsIgnoreCase( crudType ) && !fieldDescribe.isUpdateable() ){
                        return false;
                      }
                    else if( 'delete'.equalsIgnoreCase( crudType ) && !fieldDescribe.isRestrictedDelete()){
                        return false;
                      }
                }
                else
                {
                    return false;
                }
            }
        }
      return true;
    }
    
    
    /* Database Operations */
    // Insert Single Record and Assert.
    public static Database.SaveResult insertWithAssert( sObject dataObject)
    {
        Database.SaveResult saveResult = Database.insert( dataObject);
        System.assert( saveResult.isSuccess());
        return saveResult;
    }
    
    // Update Single Record and Assert.
    public static Database.SaveResult updateWithAssert( sObject dataObject)
    {
        Database.SaveResult saveResult = Database.update( dataObject);
        System.assert( saveResult.isSuccess());
        return saveResult;
    }
    
    // Upsert Single Record and Assert.
    public static Database.Upsertresult upsertWithAssert( sObject dataObject)
    {
        Database.Upsertresult upsertResult = Database.upsert( dataObject);
        System.assert( upsertResult.isSuccess());
        return upsertResult;
    }
    
    // Delete single Record and Assert.
    public static Database.DeleteResult deleteWithAssert( sObject dataObject)
    {
        Database.DeleteResult deleteResult = Database.delete( dataObject);
        System.assert( deleteResult.isSuccess());
        return deleteResult;
    }
    
    // Insert List of records and Assert.
    public static Database.SaveResult[] insertListWithAssert( List<sObject> sObjectsList)
    {
        Database.SaveResult[] arrSaveResult = Database.insert( sObjectsList);
        for(Database.SaveResult saveResult : arrSaveResult)
            System.assert( saveResult.isSuccess());
        return arrSaveResult;
    }
    
    // Update List of Records with Assert.
    public static Database.SaveResult[] updateListWithAssert( List<sObject> sObjectsList)
    {
        Database.SaveResult[] arrUpdateResult = Database.update( sObjectsList);
        for(Database.SaveResult saveResult : arrUpdateResult)
            System.assert( saveResult.isSuccess());
        return arrUpdateResult;
    }
    
    // Upsert List of records with Assert.
    public static Database.Upsertresult[] upsertListWithAssert( List<sObject> sObjectsList)
    {
        Database.Upsertresult[] arrSaveResult = Database.upsert( sObjectsList);
        for(Database.Upsertresult saveResult : arrSaveResult)
            System.assert( saveResult.isSuccess());
        return arrSaveResult;
    }
    
    //Delete List of records with Assert.
    public static Database.DeleteResult[] deleteListWithAssert( List<sObject> sObjectsList)
    {
        Database.DeleteResult[] arrDeleteResult = Database.delete( sObjectsList);
        for(Database.DeleteResult deleteResult : arrDeleteResult)
            System.assert( deleteResult.isSuccess());
        return arrDeleteResult;
    }
    
    //Current Pagereference
    public static pagereference currentPageReference( String pageName, Map<String,String> queryStringMap){
        
        PageReference pageRef =  new ApexPages.PageReference(pageName);
        for(String key : queryStringMap.keySet()){
            pageRef.getParameters().put(key,queryStringMap.get(key));
        }
        Test.setCurrentPageReference(pageRef);
        system.assert(pageRef != null);
        return pageRef;
    }
  
    // <summary>
    // Created By: Anant Kumar.
    // Created On: 23/02/2016.
    // Purpose: User create/insert method.
    // Parameters:
    // 1. Id: profileId.  
    // 2. Map Of User Fields 
    // 3. crudType: crudType i.e Insert
    // Return type: Single User.
    public static User insertUserWithAssert(Id profileId,Map<String,Object> recordValuesMap){
        return insertUserWithAssert(profileId, recordValuesMap, true);
    }
     
    public static User insertUserWithAssert(Id profileId, Map<String,Object> recordValuesMap, Boolean b_doInsert){
    	Map<String,Object> userRecordMap = new Map<String,Object>();
        userRecordMap.put('alias','te');
        userRecordMap.put('Username',createStringValue()+'standarduser@test.com');
        //userRecordMap.put('Email','standarduser@test.com');
        userRecordMap.put('ProfileId',profileId);
        userRecordMap.put('EmailEncodingKey','ISO-8859-1');
        userRecordMap.put('LanguageLocaleKey','en_US');
        userRecordMap.put('LocaleSidKey','en_US');
        userRecordMap.put('TimeZoneSidKey','America/Los_Angeles');
        if(recordValuesMap != null){
            for(String key : recordValuesMap.keySet()){
                userRecordMap.put(key,recordValuesMap.get(key));
            }
        }  
        User objUser = new User();
        objUser = (User)TestingUtility.createTestRecords(User.SObjectType, userRecordMap, b_doInsert);
        return objUser;
    }
    
    // Purpose: get sObject Picklist Values.
    // Parameters:
    // 1. String ObjectApiName: object Name.  
    // 2. String strFieldName: picklist field api name 
    // 3. crudType: crudType i.e Insert
    // Return type: List Of Picklist Values
    public static List<String> getPicklistValues(String strObjectApiName,String strFieldName){ 

        List<String> pickValsList=new List<String>();
        Schema.SObjectType targetType = Schema.getGlobalDescribe().get(strObjectApiName);
        Sobject sObjName = targetType.newSObject();
        Schema.sObjectType sObjType = sObjName.getSObjectType();
        Schema.DescribeSObjectResult sObjDescribe = sObjType.getDescribe();
        Map<String, Schema.SObjectField> fieldMap = sObjDescribe.fields.getMap();
        List<Schema.PicklistEntry> picklistEntryList = fieldMap.get(strFieldName).getDescribe().getPickListValues();
        for (Schema.PicklistEntry pcEntry : picklistEntryList) { 
            pickValsList.add(pcEntry.getValue());
        }
        return pickValsList;
    }
    
    //create single account record with assertion
    public static Account createAccount(String strAccountName, Boolean b_doInsert ){
        
        Map<String,Object> recordValuesMap = new Map<String,Object>();
        List<Map<String,Object>> newListOfMap = new List<Map<String,Object>>(); 
        recordValuesMap.put('Name',strAccountName);
        newListOfMap.add(recordValuesMap);
        return (Account)createTestRecords(1, Account.sObjectType, newListOfMap, b_doInsert)[0];
        
    }
    //create account records with assertion
    public static List<Account> createAccounts( Integer i_AccCount, String strName, Boolean b_doInsert ) 
    {
        //create different account records with assertion
        List<Map<String,Object>> accountRecordListOfMap = new List<Map<String,Object>>();
        for( Integer i = 0; i < i_AccCount; i++ ){
            Map<String,Object> accountRecordMap = new Map<String,Object>();
            accountRecordMap.put('Name',strName+i);
            accountRecordListOfMap.add(accountRecordMap);
        }
        return createTestRecords(Account.sObjectType, accountRecordListOfMap, b_doInsert);
    }
    
    //create single contact records with assertion
    public static Contact createContact( Id acctId, String strLastName, Boolean b_doInsert ){
        //Create Contact Data
        Map<String,Object> recordValuesMap = new Map<String,Object>();
        List<Map<String,Object>> newListOfMap = new List<Map<String,Object>>(); 
        recordValuesMap.put('LastName',strLastName);
        recordValuesMap.put('AccountId',acctId);
        newListOfMap.add(recordValuesMap);
        return (Contact)createTestRecords(1, Contact.sObjectType, newListOfMap, b_doInsert)[0];
        
    }
    
    //create single Opportunity records with assertion
    public static Opportunity createOpportunity(Id accountId, Boolean b_doInsert){
        List<String> stageValsList = TestingUtility.getPicklistValues('Opportunity','StageName');    
        Map<String,Object> recordValuesMap = new Map<String,Object>();
        recordValuesMap.put('StageName',stageValsList[0]);
        recordValuesMap.put('Name','Test Opportunity');
        recordValuesMap.put('CloseDate',System.today().addDays(30));
        recordValuesMap.put('AccountId',accountId);
        return (Opportunity)createTestRecords(Opportunity.sObjectType, recordValuesMap, b_doInsert);        
    }
    
    //enum PortalType { CSPLiteUser, PowerPartner, PowerCustomerSuccess, CustomerSuccess }
     
    public static User getPortalUser(Id portalProfileId, String portalType, User userWithRole, Boolean b_doInsert) {
    	Id portalProfId;
    	Account accObj;
        Contact conObj;
        //Make sure the running user has a role otherwise an exception will be thrown. 
        if(userWithRole == null) {   
            
            if(UserInfo.getUserRoleId() == null) {
                UserRole userRoleObj = new UserRole(name = 'TEST ROLE');
                Database.insert(userRoleObj);
                Map<String,Object> userRecordMap = new Map<String,Object>();
                userRecordMap.put('UserRoleId',userRoleObj.id);
             	userWithRole = TestingUtility.insertUserWithAssert(UserInfo.getProfileId(),userRecordMap);               
            } else {
                userWithRole = new User(Id = UserInfo.getUserId(), UserRoleId = UserInfo.getUserRoleId());
            }
            
        }
        
        System.runAs(userWithRole) {
            accObj = TestingUtility.createAccount('Test Account', true);
            conObj = TestingUtility.createContact(accObj.Id,'Test Contact',true);
        }
       
        // Get any profile Id for the given type.
        if(portalProfileId != null){
        	portalProfId = portalProfileId;
        }
        else{
        	portalProfId = [SELECT Id FROM Profile WHERE Usertype = :portalType LIMIT 1].Id;
        }       
    	Map<String,Object> userRecordMap = new Map<String,Object>();
    	userRecordMap.put('ContactId',conObj.Id);
    	userRecordMap.put('Email','asuniqueasme@sunGard.com');
        
        User portalUser = TestingUtility.insertUserWithAssert(portalProfId,userRecordMap,b_doInsert);
        return portalUser;
    }
}