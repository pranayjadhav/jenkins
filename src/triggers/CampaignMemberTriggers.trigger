/*
 * Placeholder for different triggers on the CampaignMember object
 * @Merge By Prranay Jadhav
 * @New Trigger CampaignMemberTriggers
 * @Modified Date	05/07/2016
 * @author	RamseySolutions
 * @date	01/22/2016
*/
trigger CampaignMemberTriggers on CampaignMember (after insert, after update) {
    TriggerSettings.TriggersMappedField triggerSetting = TriggerSettings.get();
    Debug.LogTrigger('CampaignMemberTriggers');
    
    if (Trigger.isAfter && (Trigger.isInsert || Trigger.isUpdate)) {
        if (triggerSetting.CampMember_updateLeadFromSplashCampaigns){
            CampaignMemberTriggerHandler.updateLeadFromSplashCampaigns(Trigger.newMap, Trigger.oldMap);
        }
        
        if(Trigger.isInsert){
            if (triggerSetting.CampMember_updateCampaignsFieldsToLead){
                CampaignMemberTriggerHandler.updateCampaignsFieldsToLead(trigger.new);
            }
        }
    }
}