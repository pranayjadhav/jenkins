@RestResource(urlMapping='/Opportunities/*')
global with sharing class RESTOpportunities {
	
	// Get opportunities by account UUID
	@HttpGet
 	global static Response doGet() {
 		List<String> results;
 		RESTOpportunities.Response response = new RESTOpportunities.Response();
 		
	    try {
	    	//get account UUID
	      	String accountUUID = RestContext.request.requestURI.substring(
  				RestContext.request.requestURI.lastIndexOf('/') + 1
  			);
  			
  			//fetch account
  			List<Account> accounts = [SELECT id FROM Account WHERE UUID__c = :accountUUID LIMIT 1];
  			
  			//assert account exists
  			if (accounts.isEmpty()) {
  				throw new AccountDoesNotExistException('Could not find account with UUID ' + accountUUID);
  			}
  			
	    	//get the opportunity details list
	    	results = OpportunityServices.getEncodedOpportunityIdsForAccount(accounts.get(0).id);
	
	        //set response
	  		response.setSuccess(results);
	
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
 	
 	global class AccountDoesNotExistException extends Exception {}
}