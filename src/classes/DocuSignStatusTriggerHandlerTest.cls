/*
* Test class moved by TestDocusignTriggers test class
* Moved By : Aanat Kumar
* Date : 07-July-2016
*/
@isTest
private class DocuSignStatusTriggerHandlerTest {
    
    static testMethod void testDocusignStatusOpportunityWon() {
    	Opportunity o = new Opportunity(Name = 'Test', CloseDate = Date.today(), StageName = 'Inquiry');
    	insert o;
    	
    	dsfs__DocuSign_Status__c dsStatus = new dsfs__DocuSign_Status__c(dsfs__Opportunity__c = o.Id, dsfs__Envelope_Status__c = 'Fake status');
    	insert dsStatus;
    	
    	o = [select StageName from Opportunity where Id = :o.Id];
    	System.assertNotEquals('Contract Signed', o.StageName);

        dsStatus.dsfs__Envelope_Status__c = 'Completed';
        update dsStatus;

        o = [select StageName from Opportunity where Id = :o.Id];
        System.assertEquals('Contract Signed', o.StageName);
    }
}