/*
  Created By: Amol Darekar.
  Created Date: 16-06-2016.
*/
public class InboundCallController
{
	public static string inboundNumber {get;set;}

    public InboundCallController(WeworkEngine controller) {
        
	  inboundNumber = apexpages.currentpage().getparameters().get('inboundNumber');
        
    }
    
    public InboundCallController(ApexPages.StandardController stdController) {

    }
    
    /*
    Comment   : This method used get Journey Information related to Contact. 
    Issue     : ST-315
    Parameters: contactPhoneNo
    Author    : Amol Darekar 
    Date      : 16/06/2016 
    */
    @RemoteAction
    public static list<JourneyContactInfo> getContactAndRelatedJoureny(string searchParameter,string formattedNo,string unformattedNo , string contactId)
    {
    	list<JourneyContactInfo> lstJourneyContactInfo = new list<JourneyContactInfo>();
    	
    	set<Id> setContactIds = new set<Id>();
    	
    	map<Id,list<Journey__c>> mapLeadContactJournerys = new map<Id,list<Journey__c>>();
    	
    	list<contact> lstContactInfo  = new list<contact>();
    	
    	list<Lead> lstLeadInfo  = new list<Lead>();
    	
    	if(!string.isBlank(formattedNo))
    		formattedNo = '%' + formattedNo + '%';
    	else
    		formattedNo = '%*******%';
    		
       if(!string.isBlank(unformattedNo))
    		unformattedNo = '%' + unformattedNo + '%';
    	else
    		unformattedNo = '%*******%';
    		
    	string searchByNameOrEmail = '%'+searchParameter+'%';
    	
		if(!String.isBlank(contactId))
		{		 

		   lstContactInfo = [Select Id, Name,FirstName,LastName,Email,Company__c,Phone from contact where (phone =: searchParameter OR phone Like: formattedNo OR phone Like: unformattedNo OR Name Like : searchByNameOrEmail OR Email Like : searchByNameOrEmail OR Company__c Like : searchByNameOrEmail OR Account.Name Like : searchParameter)];
		  
		   if(lstContactInfo.size()== 0)
		   		lstLeadInfo = [Select Id, Name,FirstName,LastName,Email,Company,Phone from lead where (phone =: searchParameter OR phone Like: formattedNo OR phone Like: unformattedNo OR Name Like : searchByNameOrEmail OR Email Like : searchByNameOrEmail OR Company Like : searchByNameOrEmail) AND IsConverted = false];

		}
		else
		{
		   lstContactInfo = [Select Id, Name,FirstName,LastName,Email,Company__c,Phone from contact where (phone =: searchParameter OR phone Like: formattedNo OR phone Like: unformattedNo OR Name Like : searchByNameOrEmail OR Email Like : searchByNameOrEmail OR Company__c Like : searchByNameOrEmail OR Account.Name Like : searchParameter)];
		  
		   lstLeadInfo = [Select Id, Name,FirstName,LastName,Email,Company,Phone from lead where (phone =: searchParameter OR phone Like: formattedNo OR phone Like: unformattedNo OR Name Like : searchByNameOrEmail OR Email Like : searchByNameOrEmail OR Company Like : searchByNameOrEmail) AND IsConverted = false];
		}
		
		
		for(contact currentJourneyContact : lstContactInfo)
		{
		    JourneyContactInfo objJourneyContact = new JourneyContactInfo();
		    objJourneyContact.Id = currentJourneyContact.Id;
		    objJourneyContact.FirstName = currentJourneyContact.FirstName;
		    objJourneyContact.LastName = currentJourneyContact.LastName;
		    objJourneyContact.Company = currentJourneyContact.Company__c;
		    objJourneyContact.Email = currentJourneyContact.Email;
		    objJourneyContact.Phone = currentJourneyContact.Phone;
		    objJourneyContact.isLead = false;
		    setContactIds.add(currentJourneyContact.Id);
		    //mapContactAndJourenys.put(currentJourneyContact.Id,new List<Journey_Contact__c>());
		    //Store Id's of Contact and Journey
		    //mapJunctionContactJourneyIds.put(currentJourneyContact.Id,new Set<Id>());
		    lstJourneyContactInfo.add(objJourneyContact);
		}
		
		for(lead currentJourneyLead : lstLeadInfo)
		{
		    JourneyContactInfo objJourneyContact = new JourneyContactInfo();
		    objJourneyContact.Id = currentJourneyLead.Id;
		    objJourneyContact.FirstName = currentJourneyLead.FirstName;
		    objJourneyContact.LastName = currentJourneyLead.LastName;
		    objJourneyContact.Company = currentJourneyLead.Company;
		    objJourneyContact.Email = currentJourneyLead.Email;
		    objJourneyContact.Phone = currentJourneyLead.Phone;
		    objJourneyContact.isLead = true;
		    setContactIds.add(currentJourneyLead.Id);
		    
		    //mapContactAndJourenys.put(currentJourneyContact.Id,new List<Journey_Contact__c>());
		    //Store Id's of Contact and Journey
		    //mapJunctionContactJourneyIds.put(currentJourneyContact.Id,new Set<Id>());
		    lstJourneyContactInfo.add(objJourneyContact);
		}
		
		//get journey related to contacts
		Map<ID, Journey__c> mapJourneyRelatedToLeadContact = new Map<ID, Journey__c>([SELECT Id, Name, Primary_Contact__c,Primary_Contact__r.Name, Primary_Lead__c ,Primary_Lead__r.Name , Stage__c,NMD_Next_Contact_Date__c FROM Journey__c where ((Primary_Contact__c IN:setContactIds OR Primary_Lead__c IN:setContactIds) AND (Stage__c != 'Completed-Lost' And Stage__c != 'Completed-Won'))]);

		for(Id currentJourneyId : mapJourneyRelatedToLeadContact.keySet())
		{	
			Journey__c objCurrentJourney = mapJourneyRelatedToLeadContact.get(currentJourneyId);
			
			if(objCurrentJourney.Primary_Contact__c != null )
			{
				if(mapLeadContactJournerys.containsKey(objCurrentJourney.Primary_Contact__c))
	        	{
					 mapLeadContactJournerys.get(objCurrentJourney.Primary_Contact__c).add(objCurrentJourney);
	        	}
	        	else
	        	{
	        		mapLeadContactJournerys.put(objCurrentJourney.Primary_Contact__c , new list<Journey__c> {objCurrentJourney});
	        	}
			}
			else if(objCurrentJourney.Primary_Lead__c != null)
			{
				if(mapLeadContactJournerys.containsKey(objCurrentJourney.Primary_Lead__c))
	        	{
					 mapLeadContactJournerys.get(objCurrentJourney.Primary_Lead__c).add(objCurrentJourney);
	        	}
	        	else
	        	{
	        		mapLeadContactJournerys.put(objCurrentJourney.Primary_Lead__c , new list<Journey__c> {objCurrentJourney});
	        	}
				
			}
		}
	        
        for(JourneyContactInfo currentJourneyContact : lstJourneyContactInfo)
        {
        	if(mapLeadContactJournerys.containsKey(currentJourneyContact.Id))
        	{
        		list<Journey__c> lstCurrentJourney = mapLeadContactJournerys.get(currentJourneyContact.Id);
        		list<JourneyInfoController> lstJourneyInfo = new list<JourneyInfoController>();
        		for(Journey__c currentJourney : lstCurrentJourney)
        		{
		        	JourneyInfoController objJourneyInfo = new JourneyInfoController();
					objJourneyInfo.JourneyId = currentJourney.Id;
					objJourneyInfo.JourneyStage = currentJourney.Stage__c;
					objJourneyInfo.JourneyNMDDate = currentJourney.NMD_Next_Contact_Date__c;
					lstJourneyInfo.add(objJourneyInfo);
        		}
        		
        		currentJourneyContact.lstJourneyContacts = new list<JourneyInfoController>(); 
        		currentJourneyContact.lstJourneyContacts.addAll(lstJourneyInfo);
        	}
        	
        }
		return lstJourneyContactInfo;				
    }
    
    @RemoteAction
    public static string getRecordTypeInfo(string recordTypename)
    {
    	return Schema.SObjectType.Lead.getRecordTypeInfosByName().get('Default').getRecordTypeId();
    }
    
    public class JourneyContactInfo
    {
    	public string Id{get;set;}
	    public string Company{get;set;}
	    public string Email{get;set;}
	    public string FirstName{get;set;}
	    public string LastName{get;set;}
	    public string LeadSource{get;set;}  
	    public string Phone{get;set;}
	    public boolean isLead{get;set;}
	    public list<JourneyInfoController> lstJourneyContacts{get;set;}
    }
    
    public class JourneyInfoController
    {
    	public string Id{get;set;}
    	public string ContactId{get;set;}
    	public string ContactName{get;set;}
    	public string JourneyId{get;set;}
    	public string JourneyStage{get;set;}
    	public Date JourneyNMDDate{get;set;}
    	public string Role{get;set;}
    	
    }

}