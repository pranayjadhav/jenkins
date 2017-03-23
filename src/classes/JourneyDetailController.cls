public class JourneyDetailController {
    public String journeyId {get; set;}
    public Journey__c journey {get; set;} 
    public Contact contact {get; set;}
    public Lead lead {get; set;}
    public String toId {get; set;}
    public Map<string,List<EmailTemplate>> mapEmailTemplate {get; set;}
    public JourneyDetailController(ApexPages.StandardController controller) {
        journeyId = controller.getId();
        if(journeyId != null){
        		journey = [Select Id,Name,Primary_Contact__c,Primary_Lead__c From Journey__c Where Id=:journeyId];

                if(journey.Primary_Contact__c != null){
                	contact =[SELECT Id,Name FROM Contact Where Id=:journey.Primary_Contact__c Limit 1];
                    toId = contact.Id;
                }
                if(journey.Primary_Lead__c != null){
                	lead = 	[SELECT Id,Name FROM Lead Where Id=:journey.Primary_Lead__c Limit 1];
                    toId =  lead.Id;
                }
            
           	List<EmailTemplate> lstEmailTemplates = [SELECT Name, Folder.Id,Folder.name, Id FROM EmailTemplate order by Name]; 
            mapEmailTemplate = new Map<string,List<EmailTemplate>>();  

            for(EmailTemplate currentEmailTemplate : lstEmailTemplates) { 
                if(currentEmailTemplate.Folder.name != null) {
                    if(mapEmailTemplate.containsKey(currentEmailTemplate.Folder.name)) {
                    List<EmailTemplate> lstEmailTemplate =  mapEmailTemplate.get(currentEmailTemplate.Folder.name);
                    lstEmailTemplate.add(currentEmailTemplate);
                    mapEmailTemplate.put(currentEmailTemplate.Folder.name,lstEmailTemplate);
                    }
                    else {
                        List<EmailTemplate> lstEmailTemplate = new List<EmailTemplate>();
                        lstEmailTemplate.add(currentEmailTemplate);
                        mapEmailTemplate.put(currentEmailTemplate.Folder.name,lstEmailTemplate);
                    } 
                }   
            }  	  
        }
    }    
}