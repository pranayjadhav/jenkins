public class AccountServices {

    public Account a    {get; set;}
    public Contact c    {get; set;}

	public class AccountServicesException extends Exception {}
    
	// Load init from Web Handler
	public AccountServices(WWTypes.InboundLead pInboundLead) {

        // Load Account
		this.a = this.get_account_by_uuid(pInboundLead.account_uuid);

		// Load Contact
		this.c = this.get_contact_by_uuid(pInboundLead.contact_uuid);

        // Account exists
        if (this.a != null) {
            
            // Contact not exists
            if (this.c == null) {
                insert_contact_by_web(pInboundLead);
            }
            // Contact exists
            else if (this.c != null) {
                 Debug.log('In Account Service contact != null');
                // Do nothing if belongs to Account
                if (this.c.AccountId != this.a.Id) {
                    
                    // If Contact is Primary Member on another Account
                    if (this.c.Is_Primary_Member__c) {
                        throw new AccountServicesException('Contact is Primary Member on different Account');
                    }
                    // Contact is a regular member on another Account, move to this Account
                    else {
                    	Debug.log('In Account Service contact else');
                    	 // ST-164 :-Endpoint Tour: Should not update existing Contact's Account
                        //update_contact_account();
                    }
                }
            }
        }
        // Account not exists
        else {
            // Contact Exists
            if (this.c != null) {
                // If Contact is Primary Member on another Account
                if (this.c.Is_Primary_Member__c) {
                    throw new AccountServicesException('Contact is Primary Member on different Account');
                }
                // Contact is a regular member on another Account, create Account and transfer Contact
                else {
                    insert_account_by_web(pInboundLead);
                    update_contact_account();
                }
            }
            // Contact does not exist
            else {
                //System.debug(LoggingLevel.ERROR,'/*/*/*/*/ Cont Doest Exits'+pInboundLead);
                Debug.log('In Account Service Insert account and contact');
                insert_account_by_web(pInboundLead);
                insert_contact_by_web(pInboundLead);
            }
        }
    }
    
    private void insert_account_by_web(WWTypes.InboundLead pInboundLead) {
        
        this.a = new Account(
            Name = pInboundLead.company_name,
            UUID__c = pInboundLead.account_uuid,
            Company_Size__c = pInboundLead.company_size,
            Lead_Source__c = 'Id'
        );
        
        insert this.a;
    }

    private void insert_contact_by_web(WWTypes.InboundLead pInboundLead) {
        
        this.c = new Contact(
            FirstName = pInboundLead.first_name,
            LastName = pInboundLead.last_name,
            Phone = pInboundLead.phone,
            Email = pInboundLead.email,
            Locale__c = pInboundLead.locale,
            Product_Interests__c = LeadServices.getProduct_Interests(pInboundLead.product_interests),
            Country_Code__c = pInboundLead.country_code,
            Product_Line__c = pInboundLead.product_line,
            UUID__c = pInboundLead.contact_uuid,
            AccountId = this.a.Id,
            LeadSource = 'Id'
        );
        
        insert this.c;
        
        //reload
        this.c = get_contact_by_id(this.c.Id);        

        // Reload records as Contact might have been set as Primary Member for Account
        if (this.a.Primary_Member__c == null) {

            this.a = get_account_by_id(this.a.Id);
		}

        //explicit set of contact_uuid to the new one
        pInboundLead.contact_uuid = this.c.uuid__c;
        
	}

    private void update_contact_account() {
        
        this.c.AccountId = this.a.Id;
        update this.c;

        // Reload records as Contact might have been set as Primary Member for Account
        if (this.a.Primary_Member__c == null) {
            this.c = get_contact_by_id(this.c.Id);
            this.a = get_account_by_id(this.a.Id);
		}
    }
    
	private Contact get_contact_by_uuid(String uuid) {		
        //dramatic exit
        if (uuid == null || uuid == '') return null;

		Contact[] Cs = [SELECT Id,
                               AccountId,
                               OwnerId,
                               Is_Primary_Member__c,
                               FirstName,
                               LastName,
                               Phone,
                               Email,
                               Product_Interests__c,
                               Product_Line__c,	
                               UUID__c,
                               Id_Kind__c
						FROM Contact 
						WHERE UUID__c = :uuid 
						ORDER BY CreatedDate DESC
						LIMIT 1];

		return Cs.size() > 0 ? Cs[0] : null;
	}

	private Contact get_contact_by_id(Id contactId) {
        
		Contact[] Cs = [SELECT Id,
                               AccountId,
                               OwnerId,
                               Is_Primary_Member__c,
                               FirstName,
                               LastName,
                               Phone,
                               Email,
                               Product_Interests__c,
                               Product_Line__c,
                               UUID__c,
                               Id_Kind__c
						FROM Contact 
						WHERE Id = :contactId];

		return Cs.size() > 0 ? Cs[0] : null;
	}
    
	private Account get_account_by_uuid(String uuid) {
        //dramatic exit
        if (uuid == null || uuid == '') return null;
        
		Account[] Accs = [SELECT Id, OwnerId, Primary_Member__c
						  FROM Account
						  WHERE UUID__c = :uuid 
						  ORDER BY CreatedDate DESC
						  LIMIT 1];

		return Accs.size() > 0 ? Accs[0] : null;
	}
    
	private Account get_account_by_id(Id accountId) {
        
		Account[] Accs = [SELECT Id, OwnerId, Primary_Member__c
						  FROM Account
						  WHERE Id = :accountId];

		return Accs.size() > 0 ? Accs[0] : null;
	}
}