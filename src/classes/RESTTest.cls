@RestResource(urlMapping='/TTour/*')
global class RESTTest {
	@HttpPost
  	global static String doPost(String body) {
  		RestRequest req = RestContext.request;
    	system.debug('Test : The request ' + req);
  		System.debug('Test : body ::: ' + body);
  		return body;
  	}
	
}