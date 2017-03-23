trigger AllOpportunity on Opportunity (
	before insert, 
	before update, 
	before delete, 
	after insert, 
	after update, 
	after delete, 
	after undelete) {

	//containers
	Set<Id> SClosedWonOpportunityIDs 		= new Set<Id>();

	//unused containers
	Set<Id> SClosedWonAccountIDs 				= new Set<Id>();
	Set<Id> SContractSentAccountIDs 		= new Set<Id>();
	Set<Id> SContractSentOpportunityIDs = new Set<Id>();

	//before
	if (Trigger.isBefore) {
    	//call your handler.before method	   
	} 

	//after
	if (Trigger.isAfter) {
  	//call handler.after method	    	
  	if (Trigger.isInsert || Trigger.isUpdate) {			
			Opportunity[] Os_new = Trigger.new;
			Opportunity[] Os_old = Trigger.isUpdate ? Trigger.old : null;

			for (Integer i = 0 ; i < Os_new.size() ; i++) {
				//collect the account ID if the stagename changes to Contract Sent or inserted 
				if ((Trigger.isInsert && Os_new[i].StageName == 'Contract Sent' ) || (Os_old != null && Os_new[i].StageName != Os_old[i].StageName && Os_new[i].StageName == 'Contract Sent') ) {
					SContractSentAccountIDs.add(Os_new[i].AccountId);
					SContractSentOpportunityIDs.add(Os_new[i].Id);
				}

				//collect the account ID if the stagename changes to Closed Won or inserted
				if ((Trigger.isInsert && Os_new[i].StageName == 'Closed Won' ) || (Os_old != null && Os_new[i].StageName != Os_old[i].StageName && Os_new[i].StageName == 'Closed Won') )
					//SClosedWonAccountIDs.add(Os_new[i].AccountId);
					SClosedWonOpportunityIDs.add(Os_new[i].id);
			}
  	}

  	system.debug('update_closedwon_accounts: ids ' + SClosedWonOpportunityIDs);

  	//async
  	if (!SClosedWonOpportunityIDs.isEmpty()) 
  		OpportunityServices.update_closedwon_accounts(
  			new List<Id>(
  				SClosedWonOpportunityIDs
  			)
  		);
	}

}