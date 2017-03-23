@RestResource(urlMapping='/InboundLead/*')
global class RESTInboundLead {
  public Static String leadId;
  public Static String contactId;
  public  static Savepoint sp{get;set;}
  @HttpPost
  global static Response doPost(WWTypes.InboundLead body) {
    RESTInboundLead.Response response = new RESTInboundLead.Response();
	    
    try {
        //serialize - might throw exceptions
        //LeadHandler.upsert_inbound_lead(body);
        sp = Database.setSavepoint();
       	LeadServices objLeadSevice = new LeadServices();
       	body.generate_journeys = false;
       	set<Id> leadIds = new set<Id>(); 
        leadIds.add(objLeadSevice.call_insert_lead_by_web(body));
       	Debug.log('Test : leadIds ::: ' + leadIds);
        LeadConvertor.ConvertLeadsToJourneys(leadIds);
        //LeadConvertor.FutureConvertLeadsToJourneys(leadIds);
       	response.setSuccess('Lead processed!');
    }
    catch(Exception pEx) {
        Debug.log('Test : pEx ::: ' + pEx);
        response.setFailure('unable to process: ' + pEx.getMessage() );
    }
    
    return response;
  }
  
  global class Response {
    public Boolean success;
    public String message;
    public String result;
    public String lead_sfid;
    public String contact_sfid;

    public void setSuccess(Object pResult) {
        this.success = true;
        this.lead_sfid = RESTInboundLead.leadId;
        this.contact_sfid = RESTInboundLead.contactId;
        this.result = pResult != null ? JSON.serializePretty(pResult) : '';
    }
    
    public void setFailure(String pMessage) {
        this.success = false; 
        this.message = pMessage;
    }
  
  }
}