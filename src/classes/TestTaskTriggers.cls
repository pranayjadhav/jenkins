/**
 * Test methods for different Task triggers
 * 
 * @author  RamseySolutions
 * @date    18/01/2016
 */
@isTest
private class TestTaskTriggers {

    private static void testUpdateLeadEngagementFields() {
        Lead l = new Lead(FirstName = 'Test', LastName = 'Test', Company = 'Test');
        insert l;
        
        Task t = new Task(WhoId = l.Id, Subject = 'Engage Campaign:');
        insert t;
       
        l = [select Engage_Emails_Sent__c, Last_Engage_Email_Sent__c from Lead where Id = :l.Id];
        t = [select CreatedDate from Task where Id = :t.Id];
        
        System.assertEquals(1, l.Engage_Emails_Sent__c);
        System.assertEquals(t.CreatedDate, l.Last_Engage_Email_Sent__c);
    }
    
}