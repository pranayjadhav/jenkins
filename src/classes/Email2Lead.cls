global class Email2Lead implements Messaging.InboundEmailHandler {
	
	global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email,
																Messaging.InboundEnvelope env) {
 
		// Create an InboundEmailResult object for returning the result of the
		// Apex Email Service		
		Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
		
		try {	 
			//load lead or contact
			LeadServices ls = new LeadServices(email, env);
		
			//load task service
			TaskServices ts = new TaskServices(ls);

			//create task
			Task t = ts.create_task_from_email(email, env);

			insert t;
			result.success = true;

		}
		catch(Exception pEx) {
			result.success = false; //default value
			system.debug(pEx.getMessage());
			throw new Email2LeadException(pEx.getMessage());
		}

		return result;
	}

	
	public class Email2LeadException extends Exception{}
}