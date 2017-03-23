/**
 * Sends email to the Primary Member when Opportunity with Type = 'Office Space' is closed won
 * Trigger is required as we need to set 'From' address to the Opportunity owner
 * @author  itadic@ramseysolutions.com
 * @since   28/01/2014
 * 
 * ------------------------
 * Update most recent opportunity stage on related contact :- JIRA ST-32
 * @author Anant Kumar
 * @date 19/02/2016
 * ------------------------
 */
trigger OpportunityClosedWonNotification on Opportunity (after insert, after update) {

    string OPP_TYPE = 'Office Space';
    string OPP_STAGE = 'Closed Won';
    string EMAIL_TEMPLATE = 'Member List Email';
    string ORG_WIDE_EMAIL = 'joinus@wework.com';

    //Get list of Closed Won Opportunities
    List<Opportunity> closedWonOpps = new List<Opportunity>();
    Set<Id> oppOwnersSet = new Set<Id>();
    Set<Id> oppPrimaryMemIdSet = new Set<Id>();
    for(Opportunity newOpp : trigger.new){
        if(newOpp.Primary_Member__c != null)
            oppPrimaryMemIdSet.add(newOpp.Primary_Member__c);
        if(newOpp.Type__c == OPP_TYPE 
            && newOpp.StageName == OPP_STAGE 
            && !string.IsBlank(newOpp.Primary_Member_Email__c) 
            && !string.IsBlank(newOpp.Primary_Member_ID__c)){
            boolean isClosedWon = true;
            if(trigger.isUpdate){
                Opportunity oldOpp = trigger.oldMap.get(newOpp.Id);
                if(oldOpp.StageName == newOpp.StageName && oldOpp.Type__c == newOpp.Type__c)
                    isClosedWon = false;
            }
            if(isClosedWon){
                closedWonOpps.add(newOpp);
                oppOwnersSet.add(newOpp.OwnerId); 
            }
        }
    }
    
    // Changes made by Anant on 19/02/2016
    // Start
    // OpportunityTriggerHandler oppTrigerHandler = new OpportunityTriggerHandler();
    // OpportunityTriggerHandler.updateRecentOppStageOnContact(oppPrimaryMemIdSet);
    // End.
    
    //Go through each Opportunity and send an email
    if(closedWonOpps.size() > 0){
        
        //Get all users and their email addresses
        Map<Id,User> allOwners = new Map<Id,User>([SELECT Id, Email, Name FROM User WHERE Id IN :oppOwnersSet]);
        
        //Get Email Template Id
        EmailTemplate emlTmpl = [SELECT Id, Name FROM EmailTemplate WHERE Name = :EMAIL_TEMPLATE LIMIT 1];
        
        //Get Org Wide Email Address
        OrgWideEmailAddress orgWideEml = [SELECT Id FROM OrgWideEmailAddress WHERE Address = :ORG_WIDE_EMAIL LIMIT 1];
        
        //Create Email messages
        Messaging.SingleEmailMessage[] allEmails = new Messaging.SingleEmailMessage[]{};
        for(Opportunity opp : closedWonOpps){
            User owner = allOwners.get(opp.OwnerId);
            Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
            //email.setSenderDisplayName(owner.Name);
            email.setOrgWideEmailAddressId(orgWideEml.Id);
            email.setReplyTo(owner.Email);
            email.setTargetObjectId((Id)opp.Primary_Member_ID__c);
            email.setWhatId(opp.Id);
            email.setSaveAsActivity(true);
            email.setToAddresses(new String[]{opp.Primary_Member_Email__c});
            email.setTemplateId(emlTmpl.Id);
            email.setUseSignature(false);
            allEmails.add(email);
        }
        
        //Send email messages
        //if(allEmails.size() > 0)
            //Messaging.sendEmail(allEmails); 

            //WeWork requested to remove this email logic
    }
}