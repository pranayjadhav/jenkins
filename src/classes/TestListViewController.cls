/**
 * This class should contain all the test methods related ListViewController 
 * 
 * @author  Dipak Pawar
 * @date    25/06/2016
 */

@isTest
public class TestListViewController {
    
    /**
	 * ST-382 : Test method for get SObjectList.
	 * @author  Dipak Pawar
	 * @date    21/June/2016
	 */
	@isTest
    private static void testGetName() {
        List<SelectOption> options = new List<SelectOption>();
        options = ListViewController.getName();
        System.assert(options != null);
        System.assert(options.size() > 1);
    }
    
    /**
	 * ST-382 : Test method for get ListViews for particular SObject.
	 * @author  Dipak Pawar
	 * @date    21/June/2016
	 */
    @isTest
    private static void testGetViews() {
        Map<Id, string> views = new Map<Id, string>();
        views = ListViewController.getViews('Lead');
        System.assert(views != null);
        System.assert(views.size() > 1);
    }

    /**
	 * ST-382 : Test method for get ListView data.
	 * @author  Dipak Pawar
	 * @date    21/June/2016
	 */
    @isTest
    private static void testGetQuery() {
        sObject[] objectList;
        Building__c b = new Building__c(
            City__c = 'Test',
            Name = 'b1',
            uuid__c = 'bui001',
            time_zone__c = 'America/New_York'
        );
        insert b;
        objectList = ListViewController.Query('SELECT Id,Name From Building__c');
        System.assert(objectList != null);
        System.assert(objectList.size() > 0);
    }
}