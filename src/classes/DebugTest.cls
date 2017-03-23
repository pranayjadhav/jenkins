@isTest
public class DebugTest {

    public testMethod static void testDebugLog(){
        //pre-context
        Tour_Outcome__c testTourOutcome = new Tour_Outcome__c(
            Tour_Date__c	= Date.today(),
            Status__c		= 'Completed',
            Start_Time__c	= '8:00AM'
        );
        insert testTourOutcome; // To call LogTrigger() which get call from trigger only.
        
        Debug.Log('Test 1'); // Call Log() method.
        
        Debug.turnDebugOn(); // Call turnDebugOn() method.
        
        
    }
}