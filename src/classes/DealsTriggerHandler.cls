/*
	Summary       : This class contains methods get called from DealTrigger 
	Created By    : Amol Darekar 
	Created Date  : 13/05/2016 
*/

public class DealsTriggerHandler {
	
	/*
    Comment   : This method used for Set Deal Gate(Phase__c) value to Blank when Deal Status is Closed.
    Issue     : ST-325
    Author    : Amol Darekar 
    Date      : 13/05/2016 
    */
	public static void updateClosedDealStatusToBlank()
	{
		list<Deal__c> lstDeals = Trigger.New;

		for(Deal__c currentDeal : lstDeals)
		{
			if(currentDeal.Status__c == 'Closed')
			{
				currentDeal.Phase__c ='';
			}
		}	
	}
}