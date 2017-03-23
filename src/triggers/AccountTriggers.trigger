/*
*	Created By   	: Mayuresh Ghodke
*	Created Date 	: 05-07-2016
*	Summary       	: Merging of Trigger AccountPrimaryMember & GenerateUUIDAccount
*/
trigger AccountTriggers on Account (before insert, before update) {
	
    TriggerSettings.TriggersMappedField triggerSetting = TriggerSettings.get();
    /**
	* Sets Primary Contact on the Account if Primary Contact isn't selected
	* @Merge		Mayuresh Ghodke 
	* @Old Trigger	AccountPrimaryMember
	* @Date			05/07/2016
	* @author		itadic@ramseysolutions.com
	* @since		04/03/2014
	*/
	if (Trigger.isBefore && (Trigger.isInsert || Trigger.isUpdate)){
	    if(triggerSetting.Account_SetAccountPrimaryMember)
	    {
	       AccountTriggerHandler.setAccountPrimaryMember();
	    }
	}
    
    /**
	* Generate UUID for new account.
	* @Merge		Mayuresh Ghodke 
	* @Old Trigger	GenerateUUIDAccount 
	* @Date			05/07/2016
	*/
    if (Trigger.isBefore && Trigger.isInsert){
	    if(triggerSetting.Account_GenerateUUID){
	    	AccountTriggerHandler.generateUUID();
	    }
    }
}