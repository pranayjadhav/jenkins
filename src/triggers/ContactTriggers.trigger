trigger ContactTriggers on Contact (before insert,after insert, after delete) {

    TriggerSettings.TriggersMappedField triggerSetting = TriggerSettings.get();
    
    if (Trigger.isBefore && Trigger.isInsert){
	   /*
		 * Created By   : Mayuresh Ghodke
		 * Created Date : 27-06-2016
		 * Comment      : To avoid duplicate EmailIds while creating new Contact record.
		*/
	    if(triggerSetting.Contact_CheckForDuplicateEmail)
	    {
	       ContactTriggerHandler.checkForDuplicateEmail(Trigger.New);
	    }
        if(triggerSetting.Contact_GenerateUUID)
	   	{	
	   		ContactTriggerHandler.generateUUID(Trigger.New);
	    }
    }
    
if (Trigger.isAfter) 
{
	if (Trigger.isInsert) 
	{
		/*
		 * Created By   : Samadhan Kadam
		 * Created Date : 30-06-2016
		 * Comment      : To call Lead Convert method of Convert to Lead checkbox is checked
		*/
		if(triggerSetting.Contact_ConvertMatchingLead)
	   	{	
	   		ContactTriggerHandler.convertMatchingLead(Trigger.New);
	    }
	
	    /*
		*	Created By   	: Dipak Pawar
		*	Created Date 	: 04-07-2016
		*	Summary       	: Sets Primary Contact on the Account if Primary Contact isn't selected
		* 	Issue No.		: 
		*/ 
	   	if(triggerSetting.Contact_SetPrimaryContactOnAccount)
	   	{	
	   		ContactTriggerHandler.setPrimaryContactOnAccount(Trigger.New);
	    }
	}
    
	if (Trigger.isDelete) 
	{
	    /*
		*	Created By   	: Dipak Pawar
		*	Created Date 	: 04-07-2016
		*	Summary       	: Update accounts (that will automatically set Primary Member)
		* 	Issue No.		: 
		*/
	   	if(triggerSetting.Contact_UpdateAccounts)
	   	{	
	   		ContactTriggerHandler.updateAccounts(Trigger.Old);
	    }
	}
} 
}