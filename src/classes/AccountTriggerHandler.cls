/*
*	Created By   	: Mayuresh Ghodke
*	Created Date 	: 05-07-2016
*	Summary       	: Logic of AccountTriggers.
*/
public with sharing class AccountTriggerHandler {
    public static void setAccountPrimaryMember() {
    	Debug.log('In setAccountPrimaryMember');
    	//Check which Accounts don't have Primary Member
		Set<Id> accsToProcessIds = new Set<Id>();
		for(Account acc : (List<Account>)trigger.new){
			if(string.isBlank(acc.Primary_Member__c)){
				accsToProcessIds.add(acc.Id);
				Debug.log('accsToProcessIds :: '+accsToProcessIds);
			}
		}
		
		//Get Accounts and first contacts
		if(accsToProcessIds.size() > 0){
			List<Account> accsToUpdate = [SELECT 
											Id, 
											(SELECT Id FROM Contacts ORDER BY CreatedDate LIMIT 1) 
										  FROM Account
										  WHERE Id IN :accsToProcessIds];
			//Set Primary Member
			Debug.log('accsToUpdate :: '+accsToUpdate);
			for(Account acc : accsToUpdate){
				if(acc.Contacts.size() > 0){
					Account triggerAcc = (Account)trigger.newMap.get(acc.Id);
					triggerAcc.Primary_Member__c = acc.Contacts[0].Id;
					Debug.log('triggerAcc :: '+triggerAcc);
				}		
			}
		}	
    }
    public static void generateUUID() {
		for (Account acc : (List<Account>)Trigger.new) {
			if (String.isBlank(acc.UUID__c) && (acc.Lead_Source__c == null || !acc.Lead_Source__c.equalsIgnoreCase('Id')) )
				acc.UUID__c = UUIDHandler.generateVersion4();
		}
    }
}