@isTest
public class CampaignMemberTriggersTests {
    static Campaign campaign1, campaign2, campaign3;
    static Lead[] leads = new List<Lead>();
    static Id[] leadIds = new List<Id>();
    static Contact contact;
    static CampaignMember[] members = new List<CampaignMember>();

    @isTest
    public static void TestMethods(){        
        //Insert test campaigns
        campaign1 = new Campaign(Name = 'Test Campaign 1', City__c = 'Chicago', State__c = 'IL');
        campaign2 = new Campaign(Name = 'Test Campaign 2', City__c = 'Chicago', State__c = 'IL', Type = 'Splash Event');
        campaign3 = new Campaign(Name = 'Test Campaign 3', State__c = 'DC', City__c = 'Washington DC', Type = 'Splash Event');
    	insert campaign1;
        System.assert(campaign1.Id != null);
        
        insert campaign2;
        System.assert(campaign2.Id != null);
        
        insert campaign3;
        System.assert(campaign3.Id != null);
        
        leads.add(new Lead(LastName = 'Doe', FirstName = 'John', Company = 'WeWork Inc'));
        leads.add(new Lead(LastName = 'Doe', FirstName = 'Jane', Company = 'WeWork LLC'));
        insert leads;
        
        Account account = new Account(Name = 'Test Account');
        insert account;
        System.assert(account.Id != null);
        
        contact = new Contact(AccountId = account.Id, LastName = 'Smith');
        insert contact;
        System.assert(contact.Id != null);
        

        //Try adding members for a campign which is not a Splash Event campaign, it should not copy city and state to leads.
        members.add(new CampaignMember(CampaignId = campaign1.Id, ContactId = contact.Id));
        
        for(Lead lead : leads ){
            leadIds.add(lead.Id);
        	members.add(new CampaignMember(CampaignId = campaign1.Id, LeadId = lead.Id));
        }
       

        insert members;
        
        Lead[] leadsQueried = [Select Id, State, City From Lead Where Id in :leadIds];
        for(Lead lead : leadsQueried ){
            System.assert(lead.State == null);
            System.assert(lead.City == null);
        }
        
        //Without making the trigger active in the settings leads city/state should not be updated.
        //{
        members = new List<CampaignMember>();
        for(Lead lead : leads ){
            leadIds.add(lead.Id);
        	members.add(new CampaignMember(CampaignId = campaign2.Id, LeadId = lead.Id));
        }
        insert members;
        //Try adding members for a campign which is a Splash Event campaign, it should ideally copy city and state to leads
        //but as the trigger is not active it hsould not copy city/state
        leadsQueried = [Select Id, State, City From Lead Where Id in :leadIds];
        for(Lead lead : leadsQueried ){
            System.assert(lead.State == null);
            System.assert(lead.City == null);
        }
        //delete the members so we can add them again after activating the trigger
        delete members;
        //Make the trigger active
        Triggers__c triggersSettings = Triggers__c.getInstance();
        triggersSettings.Update_Lead_From_Splash_Campaigns__c = true;
        upsert triggersSettings;
        
        //Try adding members for a campign which is a Splash Event campaign, it should copy city and state to leads
        members = new List<CampaignMember>();
        for(Lead lead : leads ){
            leadIds.add(lead.Id);
        	members.add(new CampaignMember(CampaignId = campaign2.Id, LeadId = lead.Id));
        }
        
        members.add(new CampaignMember(CampaignId = campaign2.Id, ContactId = contact.Id));
        insert members;
        leadsQueried = [Select Id, State, City From Lead Where Id in :leadIds];
        for(Lead lead : leadsQueried ){
            System.assert(lead.State == campaign1.State__c);
            System.assert(lead.City == campaign1.City__c);
        }
        //}

        //Try adding members for a campign which is a Splash Event campaign, it should copy city and state to leads 
        //but not override if City and State already exists.
        Lead lead3 = new Lead(LastName = 'Smith', FirstName = 'Jane', Company = 'WeWork LLC');
        insert lead3;
        
        CampaignMember[] members2 = new List<CampaignMember>();
        
        members2.add(new CampaignMember(CampaignId = campaign3.Id, LeadId = leads[0].Id));
        members2.add(new CampaignMember(CampaignId = campaign3.Id, LeadId = lead3.Id));
        insert members2;
        
        leadsQueried = [Select Id, State, City From Lead Where Id in :leadIds];
        for(Lead lead : leadsQueried ){
            System.assert(lead.State == campaign2.State__c);
            System.assert(lead.City == campaign2.City__c);
        }
        
        lead3 = [Select Id, State, City From Lead Where Id = :lead3.Id];
        System.assert(lead3.State == campaign3.State__c);
        System.assert(lead3.City == campaign3.City__c);
    }
}