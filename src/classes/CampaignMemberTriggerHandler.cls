/*
* @Merge By	Pranay Jadhav
* @New Class CampaignMemberTriggerHandler
* @Date	05/07/2016
* @author RamseySolutions
*/
public class CampaignMemberTriggerHandler {
	static Map<Id,Lead> leadsMap;
    static Map<Id,Campaign> campaignsMap;
    static Map<String,String> fieldsMap = new Map<String,String>();
    static boolean initialized = false;
    
    public static void init(){
        if( !initialized ){
            fieldsMap.put('City', 'City__c');
            fieldsMap.put('State', 'State__c');
            initialized = true;
        }
    }
    
    public static void LoadCampaignsAndLeads(CampaignMember[] listNew){
        init();
        Set<Id> leadIds = new Set<Id>();
        Set<Id> campaignIds = new Set<Id>();
        for(CampaignMember member : listNew){
            if( !String.isBlank(member.LeadId) ){
                leadIds.add(member.LeadId);
                campaignIds.add(member.CampaignId);
            }
        }
        leadsMap = new Map<Id,Lead>([Select Id, City, State From Lead Where Id in :leadIds]);
        campaignsMap = new Map<Id,Campaign>([Select Id, City__c, State__c, Type From Campaign Where Id in :campaignIds]);
    }
    
    public static void updateCampaignsFieldsToLead(CampaignMember[] listNew){
            LoadCampaignsAndLeads(listNew);
            for(CampaignMember member : listNew){
                if( !String.IsBlank(member.CampaignId) && campaignsMap.containsKey(member.CampaignId) && !String.IsBlank(member.LeadId) && leadsMap.containsKey(member.LeadId) ){
                    Lead lead = leadsMap.get(member.LeadId);
                    Campaign campaign = campaignsMap.get(member.CampaignId);
                    if( campaign.Type == 'Splash Event'){
                        for(String leadField : fieldsMap.keySet()){
                            if( String.isBlank((String)lead.get(leadField)) )
                                lead.put(leadField, campaign.get(fieldsMap.get(leadField)));
                        }
                    }
                }
            }
            Database.DMLOptions dmo = new Database.DMLOptions();
            dmo.assignmentRuleHeader.useDefaultRule = true;
            Debug.log('In Campain member trigger==>');
            Database.update( leadsMap.values(), dmo);
    }
    
    public static void updateLeadFromSplashCampaigns(Map<Id, CampaignMember> newCampaignMembers,
                                               Map<Id, CampaignMember> oldCampaignMembers) {
		Set<CampaignMember> membersFilteredByStatus = new Set<CampaignMember>{};
        Set<Id> campaignIds = new Set<Id>{};
        Triggers__c triggerSettings = Settings.getTriggerSettings();
        //triggerSettings.Convert_Leads_To_Journeys__c = false;
		for (CampaignMember cm:newCampaignMembers.values()) {
            if (cm.LeadId != null &&
                cm.CampaignId != null &&
                cm.Status == 'RSVP_Yes' &&
                (oldCampaignMembers == null || oldCampaignMembers.get(cm.Id).Status != 'RSVP_Yes')) {
                campaignIds.add(cm.CampaignId);
				membersFilteredByStatus.add(cm);
            }            
        }
                                                   
		if (!membersFilteredByStatus.isEmpty()) {

            Map<Id, Campaign> campaignMap = new Map<Id, Campaign>([select Id,
                                                                	      Type,
                                                                          Name,
                                                                          StartDate
                                                                   from Campaign
                                                                   where Id in :campaignIds
                                                                   and (Type = 'Event' or Type = 'Splash Event')]);
            
            Set<CampaignMember> membersFilteredByCampaign = new Set<CampaignMember>{};
			Set<Id> leadIds = new Set<Id>{};
                
            for (CampaignMember cm:membersFilteredByStatus) {               
                if (campaignMap.containsKey(cm.CampaignId)) {
                    membersFilteredByCampaign.add(cm);
                    leadIds.add(cm.LeadId);
                }
            }
            
            if (!membersFilteredByCampaign.isEmpty()) {
                Map<Id, Lead> leadMap = new Map<Id, Lead>([select Id,
                                                                  Last_Event_Name__c,
                                                                  Last_Event_Date__c
                                                           from Lead
                                                           where Id in :leadIds]);
                
                for (CampaignMember cm:membersFilteredByCampaign) {
                    Lead l = leadMap.get(cm.LeadId);
                    Campaign c = campaignMap.get(cm.CampaignId);             
                    l.Last_Event_Name__c = c.Name;
                    l.Last_Event_Date__c = c.StartDate;
                }
                update leadMap.values();
            }
            
		}
    }
}