/*
* Created By: Anant Kumar
* Date : 15/June/2016
* Handler class for reference__c object
*/
public class ReferenceHandler {
	public static ReferenceSettings settingsReference;
	static {
		settingsReference = (ReferenceSettings)Settings.get('ReferenceSettings',ReferenceSettings.class);
		if( settingsReference == null )
			settingsReference = DefaultReferenceSettings();
	}
    
	public static ReferenceSettings DefaultReferenceSettings() {
        ReferenceHandler.ReferenceSettings settingReference;
		settingReference = new ReferenceHandler.ReferenceSettings();
        settingReference.expireafter = 60;
        return settingReference;
    }

	public class ReferenceSettings {
		public Integer expireafter{get;Set;}
	}

    public static void ExtendReference(Set<String> emails)
    {
    	List<Reference__c> references = [SELECT Id FROM Reference__c WHERE Referenced_Email__c in:emails AND IsActive__c=true];
    	for(Reference__c reference : references){
    		reference.Expires_On__c = System.today().addDays(settingsReference.expireafter);
    	}
    	update references;
    }
    
    public static map <string,Id> getActiveReference(Set<String> setEmail)
    {	
    	map <string,Id> mapActiveReference = new map<string,Id>();
    	
		for(Reference__c reference : [ SELECT Referenced_Email__c, Referrer_Email__c, Referrer__c FROM Reference__c WHERE Referenced_Email__c in:setEmail AND IsActive__c = true])
		{
			if(reference.Referrer__c != null)
			{ 
				if(!string.isBlank(reference.Referenced_Email__c) && !mapActiveReference.containsKey(reference.Referenced_Email__c))
				{
					mapActiveReference.put(reference.Referenced_Email__c.toLowerCase(),reference.Referrer__c);
				}
				//return reference.Referrer__c;
			}
		}
		return mapActiveReference;
    }
    
    public static Id getActiveReference(String email)
    {	
    	Reference__c[] reference = [ SELECT Referrer_Email__c, Referrer__c FROM Reference__c WHERE Referenced_Email__c = :email AND IsActive__c = true];
		if(reference.size() > 0)
		{
			return reference[0].Referrer__c;
		}
		return null;
    }
	/*
    * @Comment   : This method override for Extend Reference form given date. 
    * @Issue     : ST-529
    * @Author    : Pranay Jadhav
    * @Date      : 22/07/2016 */
	public static SaveResult ExtendReference(Id recordId, Date startDate){
    	try{
			SaveResult referenceResult;
			if(startDate < System.today().addDays(-settingsReference.expireafter)){
				Reference__c reference = [ Select Id,Expires_On__c From Reference__c where Id =: recordId AND IsActive__c = true Limit 1];
				if(reference != null){
					reference.Expires_On__c = startDate.addDays(settingsReference.expireafter);
					reference.Start_Date__c = startDate;
					reference.IsActive__c = false;
					referenceResult = new SaveResult(Database.update(reference));
				}
			}else{
				Reference__c reference = [ Select Id,Expires_On__c From Reference__c where Id =: recordId AND IsActive__c = true Limit 1];
				if(reference != null){
					reference.Expires_On__c = startDate.addDays(settingsReference.expireafter);
					reference.Start_Date__c = startDate;
					reference.IsActive__c = true;
					referenceResult = new SaveResult(Database.update(reference));
				}	
			}	
			return referenceResult;
		}catch(Exception ex){
			SaveResult referenceResult = new SaveResult();
			referenceResult.IsSuccess = false;
			return referenceResult;
		}
    }
}