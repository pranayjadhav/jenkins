/* 
* Created by @anant.kumar@enzigma.com on 11 July 2016
* This class should contain all the triggers settings
*/
public class TriggerSettings {
    static TriggerSettings.TriggersMappedField  mappedField = null;
    
	public static TriggerSettings.TriggersMappedField get()
	{
        if(mappedField == null){
        	Setting__c setting = Settings.get('TriggerSettings');
	        if(setting != null){
	            mappedField = (TriggerSettings.TriggersMappedField)JSON.deserialize(setting.Data__c, TriggerSettings.TriggersMappedField.class);
	        }
	        else{
	            mappedField = new TriggerSettings.TriggersMappedField();
	            mappedField.Account_SetAccountPrimaryMember = true;
	            mappedField.Account_GenerateUUID = true;
	            
	            mappedField.Contact_CheckForDuplicateEmail = true;
	            mappedField.Contact_GenerateUUID = true;
	            mappedField.Contact_ConvertMatchingLead = true;
	            mappedField.Contact_SetPrimaryContactOnAccount = true;
	            mappedField.Contact_UpdateAccounts = true;
	            
	            mappedField.CampMember_updateLeadFromSplashCampaigns = true;
	            mappedField.CampMember_updateCampaignsFieldsToLead = true;
	            
	            mappedField.Lead_SetOpprtunityStageDependsOnTour = true;
	            mappedField.Lead_UpdateBuildingInterestOnLead = true;
	            mappedField.Lead_CreateDeleteBuildingInterest = true;
	            mappedField.Lead_DeleteBuildingInterestOnLeadDelete = true;
	            mappedField.Lead_CopyOfficeTypeFromLeadToBuildingInterest = true;
	            mappedField.Lead_ChangeRelatedJourneyStatus = true;
	            mappedField.Lead_ConvertLeadsToJourneys = true;
	            mappedField.Lead_BlankEmailOrPhoneOnLead = true;
	            mappedField.Lead_UpdateJourneyPrimaryContact = true;
				mappedField.Lead_UpdateActiveReferrerOnLead = true;
	            
	            mappedField.Opportunity_ExtendReference = true;
				mappedField.Opportunity_UpdateActiveReferrer = true;
				mappedField.Opportunity_CreateDealOnOpportunityCreate = true;
				mappedField.Opportunity_UpdateWeLiveOpportunityType = true;
				mappedField.Opportunity_UpdateOpportunityName = true;
				mappedField.Opportunity_UpdateDealOnOpportunityUpdate = true;
				mappedField.Opportunity_GenerateBuildingInterests = true;
				mappedField.Opportunity_UpdateEncodedID = true;
				mappedField.Opportunity_UpdateOpportunityPrimaryMember = true;
				mappedField.Opportunity_CopyFieldsFromLastOpportunity = true;
				mappedField.Opportunity_DeleteBuildingInterests = true;
				mappedField.Opportunity_MapWithLatestTour = true;

				mappedField.Opportunity_Update_Contract_Email = true;
				mappedField.Opportunity_UpdateRelatedAccountLeadSource = true;
				mappedField.Opportunity_ClearPaymentDetails = true;
				mappedField.Opportunity_UpdateAddressAndAuthorizeOnAccount = true;
				mappedField.Opportunity_UpdateAccountStartDate = true;
				mappedField.Opportunity_UpdateContractSentDate = true;
				mappedField.Opportunity_SetOpportunityInquiryDate = true;
				mappedField.Opportunity_ChangeCloseDatetoDateClosedWon = true;
				mappedField.Opportunity_SetBuildingEmailField = true;
				mappedField.Opportunity_ChangeStagefromContractSent_UpdatePaymentDetailsStatustoNullandPaymentURL = true;
	
                mappedField.Tour_UpdateActiveReferrerOnTour = true;
                mappedField.Tour_ExtendValidityOfReference = true;
                mappedField.Tour_CloseAllOpenInboundLeadActivities = true;
                mappedField.Tour_UpdateTourEnditme = true;
                mappedField.Tour_ScheduledConvertLead = true;
                mappedField.Tour_StageUpdateforJourneyRecords = true;
	        
	            mappedField.Journey_SetPrimaryLeadToUnqualified = true;
	            mappedField.Journey_UpdateActiveReferrerOnJourney = true;
	            mappedField.Journey_CreateJourneyContactOnMemberChange = true;
	            mappedField.Journey_GenerateUUID = true;
	            
	            mappedField.Task_UpdateLeadEngagementFields = true;
	            mappedField.Task_ChangeOwnerToFirstUserWhoRespond = true;
	            mappedField.Task_UpdateJourneyStageToCompletedLost = true;
	            mappedField.Task_CallResultUpdateJourneyNMDDate = true;
	            
	            mappedField.Discount_VerifyStartDate = true;
	            
	            mappedField.DocuSign_CloseOpportunity = true;
	            
	            mappedField.Deal_SetClosedDealStatusToBlank = true;
	            
	            mappedField.Reservable_UpdateSpaceBasedOnSpaceUUID = true;
	        }
        }
        return mappedField;
	}
	
	public class TriggersMappedField {
    	public boolean Account_SetAccountPrimaryMember {get; set;}
    	public boolean Account_GenerateUUID {get; set;}
        public boolean Contact_CheckForDuplicateEmail {get; set;}
    	public boolean Contact_GenerateUUID {get; set;}
    	public boolean Contact_ConvertMatchingLead {get; set;}
    	public boolean Contact_SetPrimaryContactOnAccount {get; set;}
    	public boolean Contact_UpdateAccounts {get; set;}
        public boolean CampMember_updateLeadFromSplashCampaigns {get; set;}
    	public boolean CampMember_updateCampaignsFieldsToLead {get; set;}
        public boolean Lead_SetOpprtunityStageDependsOnTour {get; set;}
    	public boolean Lead_UpdateBuildingInterestOnLead {get; set;}
    	public boolean Lead_CreateDeleteBuildingInterest {get; set;}
    	public boolean Lead_DeleteBuildingInterestOnLeadDelete {get; set;}
    	public boolean Lead_CopyOfficeTypeFromLeadToBuildingInterest {get; set;}
    	public boolean Lead_ChangeRelatedJourneyStatus {get; set;}
    	public boolean Lead_ConvertLeadsToJourneys {get; set;}
    	public boolean Lead_UpdateJourneyPrimaryContact {get; set;}
    	public boolean Lead_BlankEmailOrPhoneOnLead {get; set;}
    	public boolean Lead_UpdateActiveReferrerOnLead {get; set;}
    	public boolean Opportunity_UpdateActiveReferrer {get; set;}
    	public boolean Opportunity_ExtendReference {get; set;}
    	public boolean Opportunity_CreateDealOnOpportunityCreate {get;set;}
    	public boolean Opportunity_UpdateWeLiveOpportunityType {get;set;}
    	public boolean Opportunity_UpdateOpportunityName {get;set;}
    	public boolean Opportunity_UpdateDealOnOpportunityUpdate {get;set;}
    	public boolean Opportunity_GenerateBuildingInterests {get;set;}
    	public boolean Opportunity_UpdateEncodedID {get;set;}
    	public boolean Opportunity_UpdateOpportunityPrimaryMember {get;set;}
    	public boolean Opportunity_CopyFieldsFromLastOpportunity {get;set;}
    	public boolean Opportunity_DeleteBuildingInterests {get;set;}
    	public boolean Opportunity_MapWithLatestTour {get;set;}

		public boolean Opportunity_Update_Contract_Email {get;Set;}	
		public boolean Opportunity_UpdateRelatedAccountLeadSource {get;Set;}	
		public boolean Opportunity_ClearPaymentDetails {get;Set;}	
		public boolean Opportunity_UpdateAddressAndAuthorizeOnAccount {get;Set;}	
		public boolean Opportunity_UpdateAccountStartDate {get;Set;}	
		public boolean Opportunity_UpdateContractSentDate {get;Set;}	
		public boolean Opportunity_SetOpportunityInquiryDate {get;Set;}	
		public boolean Opportunity_ChangeCloseDatetoDateClosedWon {get;Set;}	
		public boolean Opportunity_SetBuildingEmailField {get;Set;}	
		public boolean Opportunity_ChangeStagefromContractSent_UpdatePaymentDetailsStatustoNullandPaymentURL {get;Set;}	

    	public boolean Tour_UpdateActiveReferrerOnTour {get; set;}
    	public boolean Tour_ExtendValidityOfReference {get;set;}
    	public boolean Tour_CloseAllOpenInboundLeadActivities {get;set;}
    	public boolean Tour_UpdateTourEnditme {get;set;}
    	public boolean Tour_ScheduledConvertLead {get;set;}
    	public boolean Tour_StageUpdateforJourneyRecords {get;set;}
        public boolean Journey_SetPrimaryLeadToUnqualified {get; set;}
        public boolean Journey_UpdateActiveReferrerOnJourney {get;set;}
        public boolean Journey_CreateJourneyContactOnMemberChange {get;set;}
    	public boolean Journey_GenerateUUID {get;set;}
    	public boolean Task_UpdateLeadEngagementFields {get;set;}
    	public boolean Task_ChangeOwnerToFirstUserWhoRespond {get;set;}
    	public boolean Task_UpdateJourneyStageToCompletedLost {get;set;}
    	public boolean Task_CallResultUpdateJourneyNMDDate {get;set;}
    	public boolean Discount_VerifyStartDate {get; set;}	
    	public boolean DocuSign_CloseOpportunity {get; set;}  	
    	public boolean Deal_SetClosedDealStatusToBlank {get;set;}
    	public boolean Reservable_UpdateSpaceBasedOnSpaceUUID {get;set;}			
    }
}