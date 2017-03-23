/**
*	-Toured By updates Opportunity Owner
*	When tour record is updated and Tour.Status = Completed then change 
*	Opportunity Owner to the Tour.Toured By user.
*
**/
trigger TourCompleted on Tour_Outcome__c (after insert, after update) {

    //containers
	Map<Id, Id> MOpportunityOwners = new Map<Id, Id>();
	Tour_Outcome__c[] Ts 			= Trigger.new;
	Tour_Outcome__c[] Ts_old 	= Trigger.old;

	//iterate over tours
	for (Integer i = 0; i < Ts.size() ; i++) {
		//select new and old tours
		Tour_Outcome__c t 		= Ts[i];
		Tour_Outcome__c t_old = (Ts_old != null && Ts_old[i] != null) ? 
															Ts_old[i] : 
															new Tour_Outcome__c();

		//check acceptance condition
		if (t.Status__c != t_old.Status__c && 
				t.Status__c == 'Completed' && 
				t.Toured_By1__c != null && 
				t.Opportunity__c != null ) {
    	MOpportunityOwners.put(t.Opportunity__c, t.Toured_By1__c);
    }
	}

	//Select Opportunities
	Opportunity[] Os = [SELECT OwnerID 
											FROM Opportunity 
											WHERE ID IN :MOpportunityOwners.keyset()
										 ];

	//bind opportunities owners
	for (Opportunity o : Os) {
		o.OwnerId = MOpportunityOwners.get(o.Id);
	}

	//raise flag
	TriggersFlags.allowOpportunityUpdates = false;

	//dml
	update Os;

	//lower flag
	TriggersFlags.allowOpportunityUpdates = true;

}