/* Created by Mayuresh Ghodke on 27 Jun 2016
* This class should contain all test methods related to Common class.
*/
@isTest
public class TestCommon {
    @isTest static void testCommon() {
        String InputString1 = 'Test1;Test2';
        List<string> splitStringList = new List<string>();
        List<string> expSplitStringList = new List<string>();
        expSplitStringList.add('Test1');
       	expSplitStringList.add('Test2');
        splitStringList = Common.splitStringToList(InputString1, ';');
        system.assertEquals(expSplitStringList, splitStringList);
        
        String InputString2 = 'Test1;Test2';
        Set<string> setInputString = new Set<string>();
        Set<string> expSetInputString = new Set<string>();
        expSetInputString.add('Test1');
        expSetInputString.add('Test2');
        setInputString = Common.splitStringToSet(InputString2, ';');
        system.assertEquals(expSetInputString, setInputString);
    } 
}