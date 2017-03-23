@RestResource(urlMapping='/Tour/*')
global class RESTTour {
  @HttpPost
  global static Response doPost(WWTypes.InboundLead body) {
    RESTTour.Response response = new RESTTour.Response();
    SavePoint sp = Database.setSavePoint();
    try {
      //serialize - might throw exceptions and rollback
      Id so_id = LeadHandler.book_a_tour(body);

      //LeadHandler.upsert_inbound_lead(body);
      response.setSuccess(so_id);     
    }
    catch(Exception pEx) {
      response.setFailure('unable to process: ' + pEx.getMessage() + ' stack:' + pEx.getStackTraceString() );
     	Database.rollback(sp);   
    }
    
    return response;
  }

  @HttpGet
  global static Response doGet() {
    WWTypes.TourDetail result;
    Response response = new Response();

    try {

      //get encoded opportunity id
      String tour_id = RestContext.request.requestURI.substring(
                          RestContext.request.requestURI.lastIndexOf('/') + 1
                       );

      //get the tour details object
      result = TourServices.get_tour_by_id( Id.valueOf(tour_id) );

      //set response
      response.setSuccess(result); 

    }
    catch(Exception pEx) {
      response.setFailure('unable to process: ' + pEx.getMessage() );
    }
    
    return response;
  }
  
  global class Response {
    public Boolean success;
    public String message;
    public String result;

    public void setSuccess(Object pResult) {
        this.success = true; 
        this.result = pResult != null ? JSON.serializePretty(pResult) : '';
    }
    
    public void setFailure(String pMessage) {
        this.success = false; 
        this.message = pMessage;
    }
  
  }
}