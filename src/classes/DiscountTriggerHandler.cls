public with sharing class DiscountTriggerHandler {
 	/*
 	* Notes: Code moved from DiscountStartDate trigger.
 	* Date : 07/July/2016
 	* Moved By : Anant Kumar
 	*/
 	public static void verifyStartDate()
 	{
        Set<Id> oppIdSet = new Set<Id>();
        for (Discount__c discount : (List<Discount__c>)Trigger.new) { 
            oppIdSet.add(discount.Opportunity__c);
        }
        Map<Id, Opportunity> allDiscountOnOpportunity = (new Map<Id, Opportunity>([SELECT Id, (SELECT start_date__c FROM Discounts__r) FROM Opportunity WHERE Id in:oppIdSet]));
        for (SObject s : Trigger.new) {
			Discount__c target = (Discount__c) s;
			if(allDiscountOnOpportunity.get(target.Opportunity__c).Discounts__r != null){
	            for(Discount__c oldDiscount: allDiscountOnOpportunity.get(target.Opportunity__c).Discounts__r){
	                if (oldDiscount.start_date__c == target.start_date__c) 
					s.addError(
						new GenericExceptions.DiscountStartDateException(
							'There is an existing discount for the given start date'
						),	false 			
					);
	            }
			}
		}
 	}   
}