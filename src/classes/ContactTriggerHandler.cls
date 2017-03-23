/*
*	Created By   	: Mayuresh Ghodke
*	Created Date 	: 27-06-2016
*	Summary       	: This class will contain the business logic of ContactTrigger.
* 	Issue No.		: ST-420
*/
public with sharing class ContactTriggerHandler {
  
    public static void checkForDuplicateEmail(List<Contact> TriggerNew) {
    	Set<string> setUniqueEmailId  = new set<string>(); //Set of Email Ids for cuurent Contacts.
    	Set<string> setNewUniqueEmailId  = new set<string>(); //Set of Email Ids for cuurent Trigger.New.
    	Set<string> setNewInsertedUniqueEmailId  = new set<string>(); //Set of Email Ids which we are inserting.
    	
    	for(Contact contact : TriggerNew){
    		setNewUniqueEmailId.add(contact.Email);
    	}
    	//Fetch all contacts which are having email ids same as current Trigger.New email ids.
    	List<Contact> lstContact = new List<Contact>([Select Id,Email From Contact Where Email IN : setNewUniqueEmailId]);
		For(Contact oneContact :lstContact){ 
		    setUniqueEmailId.add(oneContact.Email); 
		}
		for(Contact contact : TriggerNew){
    		//Check email id is present in setUniqueEmailId.
    		Boolean prevContactEmailId = setUniqueEmailId.contains(contact.Email);
    		//Check email id is present in setNewInsertedUniqueEmailId.
    		Boolean newInsertedContactEmailId = setNewInsertedUniqueEmailId.contains(contact.Email);
    		if(!prevContactEmailId ){//&& !newInsertedContactEmailId
    			setNewInsertedUniqueEmailId.add(contact.Email);
    		}
    		else{
    			contact.Email.addError('Contact already exists with given Email');
    		}
    	}
    }
    
/*
*	Created By   	: Samadhan kadam
*	Created Date 	: 29-06-2016
*	Summary       	: This method convert lead to contact if Covert Lead checkbox on contact is true or checked.
* 	Issue No.		: 501
*/
    public static void convertMatchingLead(list<Contact> TriggerNew)
    {	
    	list<string> lstEmails = new list<string>();
    	for(Contact contact :TriggerNew){
    		 if(contact.Convert_Lead__c){
    			lstEmails.add(contact.Email);
    		 }		    	
    	}
		if( lstEmails.size() > 0){
			//LeadConvertor.ConvertLeadsToContact(lstEmails);
			LeadConvertor.FutureConvertLeadsToContact(lstEmails);
		}
    }

    /*
	*	Created By   	: Dipak Pawar
	*	Created Date 	: 04-07-2016
	*	Summary       	: Sets Primary Contact on the Account if Primary Contact isn't selected
	* 	Issue No.		: ST-518
	*/
	
	public static void setPrimaryContactOnAccount(List<Contact> TriggerNew){
		//Map of Accounts and new Contacts
		Map<Id,Contact> accContactMap = new Map<Id,Contact>();
		for(Contact currentContact : TriggerNew){
			if(!string.isBlank(currentContact.AccountId) && !accContactMap.containsKey(currentContact.AccountId)){
				accContactMap.put(currentContact.AccountId, currentContact);
			}
		}
		
		//Get parent Accounts and Opportunities
		if(accContactMap.size() > 0){
			List<Account> accsForUpdate = new List<Account>(); 
			List<Opportunity> oppsForUpdate = new List<Opportunity>();
			List<Account> accounts = [SELECT Id, Primary_Member__c,
									 (SELECT Id, Primary_Member__c FROM Opportunities) 
									  FROM Account WHERE Id IN :accContactMap.keySet()];
			//Go through all parent accounts
			for(Account currentAccount : accounts){
				//Check if Account Primary member is empty
				if(string.isBlank(currentAccount.Primary_Member__c)){
					accsForUpdate.add(new Account(Id = currentAccount.Id, Primary_Member__c = accContactMap.get(currentAccount.Id).Id));
				}
				//Go through all child opportunities
				for(Opportunity opp : currentAccount.Opportunities){
					//Check if Opportunity Primary member is empty
					if(string.isBlank(opp.Primary_Member__c)){
						oppsForUpdate.add(new Opportunity(Id = opp.Id, Primary_Member__c = accContactMap.get(currentAccount.Id).Id));
					}
				}
			}
			
			//Update Accounts
			if(accsForUpdate.size() > 0)
				update accsForUpdate;
				
			//Update Opportunities
			if(oppsForUpdate.size() > 0)
				update oppsForUpdate;
		}
	}
    
    /*
	*	Created By   	: Dipak Pawar
	*	Created Date 	: 04-07-2016
	*	Summary       	: Update accounts (that will automatically set Primary Member)
	* 	Issue No.		: ST-518
	*/
	
	public static void updateAccounts(List<Contact> TriggerNew){
		List<Account> lstAccountsToUpdate = new List<Account>();
		for(Contact currentContact : TriggerNew){
			if(!string.isBlank(currentContact.AccountId)){
				lstAccountsToUpdate.add(new Account(Id = currentContact.AccountId));
			}
		}
		if(lstAccountsToUpdate.size() > 0)
			update lstAccountsToUpdate;
	}
	
	/*
	*	Created By   	: Dipak Pawar
	*	Created Date 	: 06-07-2016
	*	Summary       	: GenerateUUIDContact 
	* 	Issue No.		: ST-518
	*/
	public static void generateUUID(List<Contact> TriggerNew) {
		for (Contact currentContact : TriggerNew) {
        if (String.isBlank(currentContact.UUID__c) && (currentContact.UUID__c == null || currentContact.Leadsource == null || !currentContact.LeadSource.equalsIgnoreCase('Id')))
            currentContact.UUID__c = UUIDHandler.generateVersion4();
    	}
    }
    
}