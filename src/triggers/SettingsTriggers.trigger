/* Created by @hemanshu.shah@enzigma.com on 24 Apr 2016
* This trigger should be used to redirect all the triggers of Settings to correct class.
* So that there is only one trigger for Settings object system wide
*/
trigger SettingsTriggers on Setting__c (before insert, before update) {
    if( trigger.isBefore && (trigger.isUpdate || trigger.isInsert) )
		Settings.UpdateUniqueKey(trigger.new);
}