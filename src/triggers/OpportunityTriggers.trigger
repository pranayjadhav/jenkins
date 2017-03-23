trigger OpportunityTriggers on Opportunity(before insert, before update, after insert, after update, before delete)
{
	TriggerSettings.TriggersMappedField triggerSetting = TriggerSettings.get();
    //Triggers__c triggerSettings1 = Settings.getTriggerSettings();
    Debug.LogTrigger('OpportunityTriggers');

    if (Trigger.isBefore && Trigger.isInsert)
    {
        if (triggerSetting.Opportunity_CreateDealOnOpportunityCreate)
            OpportunityTriggerHandler.createDealOnOpportunityCreate();

        //ST-412:Change Type and Record type for Residential Space
        if (triggerSetting.Opportunity_UpdateWeLiveOpportunityType)
            OpportunityTriggerHandler.setTypeAndRecordTypeOfOpprtunity();

        //ST-434
        //Changes made by : Anant Kumar
        //Date : 15-June-2016
        if (triggerSetting.Opportunity_UpdateOpportunityName)
        {
            OpportunityTriggerHandler.updateOppName();
        }
        
        if(triggerSetting.Opportunity_UpdateActiveReferrer){
        	OpportunityTriggerHandler.updateActiveReferrer();
        }
    }

    //Firing these trigger only on after update (removed after insert, because due to encoded id after update will also be called after insert)
    if (Trigger.isAfter && Trigger.isUpdate)
    {
        if (triggerSetting.Opportunity_UpdateDealOnOpportunityUpdate)
            OpportunityTriggerHandler.updateDealWhenOpprtunityStageChange();
            
        if( triggerSetting.Opportunity_GenerateBuildingInterests) {
            OpportunityTriggerHandler.MoveBuildingInterestsFromLead();
            OpportunityTriggerHandler.UpsertBuildingInterests();

            //The office type should be a formula field so deleting this trigger
            OpportunityTriggerHandler.UpdateBuildingInterestsOfficeType();
        }
    }
    
    if (Trigger.isAfter && Trigger.IsInsert)
    {
        if (triggerSetting.Opportunity_UpdateEncodedID)
        {
            OpportunityTriggerHandler.encodedOpportunityID();
        }
    }
    if (Trigger.isBefore && (Trigger.IsInsert || Trigger.IsUpdate))
    {
        if (triggerSetting.Opportunity_UpdateOpportunityPrimaryMember)
        {
            OpportunityTriggerHandler.updatePrimaryMemberOnOpportunity();
        }
        if(triggerSetting.Opportunity_ExtendReference)
        {
        	OpportunityTriggerHandler.extendReference();
        }
		/*
		* Comment : ST-490 - Workflow Cleanup : Move the workflows into a trigger on Opportunity Object
		* Written By : Pranay Jadhav
		* Date : 03/08/2016
		*/
		if(triggerSetting.Opportunity_Update_Contract_Email){
			OpportunityTriggerHandler.updateContractEmail();
		}
		if(triggerSetting.Opportunity_UpdateRelatedAccountLeadSource){
			OpportunityTriggerHandler.updateRelatedAccountLeadSource();
		}
		if(triggerSetting.Opportunity_ClearPaymentDetails){
			OpportunityTriggerHandler.clearPaymentDetails();
		}
		if(triggerSetting.Opportunity_UpdateAddressAndAuthorizeOnAccount){
			OpportunityTriggerHandler.updateAddressAndAuthorizeOnAccount();
		}
		if(triggerSetting.Opportunity_UpdateAccountStartDate){
			OpportunityTriggerHandler.updateAccountStartDate();
		}
		if(triggerSetting.Opportunity_UpdateContractSentDate){
			OpportunityTriggerHandler.updateContractSentDate();
		}
		if(triggerSetting.Opportunity_SetOpportunityInquiryDate){
			OpportunityTriggerHandler.setOpportunityInquiryDate();
		}
		if(triggerSetting.Opportunity_ChangeCloseDatetoDateClosedWon){
			OpportunityTriggerHandler.changeCloseDatetoDateClosedWon();
		}
		if(triggerSetting.Opportunity_SetBuildingEmailField){
			OpportunityTriggerHandler.setBuildingEmailField();
		}
		if(triggerSetting.Opportunity_ChangeStagefromContractSent_UpdatePaymentDetailsStatustoNullandPaymentURL){
			if (Trigger.isBefore && Trigger.IsUpdate)
				OpportunityTriggerHandler.changeStagefromContractSent_UpdatePaymentDetailsStatustoNullandPaymentURL();
		}
    }
	if (Trigger.isBefore && Trigger.isInsert)
    {
        if (triggerSetting.Opportunity_CopyFieldsFromLastOpportunity)
        {
            OpportunityTriggerHandler.copyFieldsFromLastOpportunity();
        }
        //ST-508
        if(triggerSetting.Opportunity_MapWithLatestTour)
        {
        	OpportunityTriggerHandler.mapWithLatestTour();
        }
    }
    if( Trigger.isBefore && Trigger.isDelete )
    {
    	if(triggerSetting.Opportunity_DeleteBuildingInterests)	
        OpportunityTriggerHandler.DeleteBuildingInterests();
    }
}