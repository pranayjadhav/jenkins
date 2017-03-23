/* Created by @hemanshu.shah@enzigma.com on 24 Apr 2016
* This class should contain all the triggers related to Settings
* As well as static methods to retreive Settings with Caching for optimized usage.
* 
*/

public class Settings {
    /* Created by hemanshu.shah@enzigma.com on 24 Apr 2016
     * This method used by the trigger to update the Unique Key so there are no duplicate Settings with same name.
     * In future if we use user or profile based settings, this should be modified to make sure there are no duplicates.
     */    
    public static void UpdateUniqueKey(Setting__c[] settings){
        for(Setting__c setting : settings ){
            setting.Unique_Key__c = setting.Name;
        }
    }

	static Triggers__c triggerSettings = null;
	public static Triggers__c getTriggerSettings(){
		if( triggerSettings == null ) {
			triggerSettings = Triggers__c.getOrgDefaults();
			if( String.isBlank(triggerSettings.Id) ) {

				triggerSettings.Debug__c = true;
				triggerSettings.Change_Owner_To_First_User_Who_Respond__c = true;
				triggerSettings.Close_All_Open_Inbound_Lead_Activities__c = true;
				triggerSettings.Copy_Fields_From_Last_Opportunity__c = true;
				triggerSettings.Create_Deal_On_Opportunity_Create__c = true;
				triggerSettings.Create_Journey_Contact_On_Journey_Create__c = true;
				triggerSettings.Create_Journey_Contact_On_Member_Change__c = true;
				triggerSettings.Deals_Set_Closed_Deal_Status_To_Blank__c = true;
				triggerSettings.Generate_Building_Interests__c = true;
				triggerSettings.Opportunity_Upate_Encoded_ID__c = true;
				triggerSettings.Task_Call_Result_Update_Journey_NMD_Date__c = true;
				triggerSettings.Tour_Scheduled_Convert_Lead__c = true;
				triggerSettings.Update_Building_Interest_On_Lead__c = true;
				triggerSettings.Update_ClosedWon_Accounts__c = true;
				triggerSettings.Update_Contact_Most_Recent_Opp_Stage__c = true;
				triggerSettings.Update_Deal_On_Opportunity_Update__c = true;
				triggerSettings.Update_Journey_Stage_To_CompletedLost__c = true;
				triggerSettings.Update_Most_Recent_Tour_Date__c = true;
				triggerSettings.Update_Name_for_EnterpriseSolution_Type__c = true;
				triggerSettings.Update_Opportunity_Name__c = true;
				triggerSettings.Update_Space_BasedOn_SpaceUUID__c = true;
				triggerSettings.Update_Task_Due_Date_From_Journey_NMD__c = true;
				triggerSettings.Update_Task_Owner__c = true;
				triggerSettings.Update_Tour_Enditme__c = true;
				triggerSettings.Update_WeLive_Opportunity_Type__c = true;
		        
				upsert triggerSettings;
			}
		}
		return triggerSettings;
	}
    
    /* Created by hemanshu.shah@enzigma.com on 24 Apr 2016
     * This method caches queried setttings so for subsequent usage it does not query it again.
     */
    static Map<String,Setting__c> mapSettingsToName = new Map<String, Setting__c>();
    public static Setting__c get(String strName){
        strName = strName.toLowerCase();
        if( !mapSettingsToName.containsKey(strName) ){
        	Setting__c[] settings = [Select Id, Name, Data__c From Setting__c Where Name = :strName];
            if( settings.size() > 0 ) {
                mapSettingsToName.put(strName, settings[0]);
                return settings[0];
            }
            return null;
        }
        return mapSettingsToName.get(strName);
    }
    
    /* Created by hemanshu.shah@enzigma.com on 24 Apr 2016
     * This method caches all given settings using one query so
     * query is not fired for each setting
     */
    public static object get(string strName, Type type){
        Setting__c setting = get(strName);
		if( setting != null )
			return JSON.deserialize(setting.Data__c, type);
		return null;
    }
    
    /* Created by hemanshu.shah@enzigma.com on 24 Apr 2016
     * This method caches all given settings using one query so
     * query is not fired for each setting
     */
    public static void LoadSettings(String[] names){
        Setting__c[] settings = [Select Id, Name, Data__c From Setting__c Where Name in :names];
        for(Setting__c setting : settings){
            mapSettingsToName.put(setting.Name.toLowerCase(), setting);
        }
    }
    
    /* Created by hemanshu.shah@enzigma.com on 24 Apr 2016
     * This method caches all given field mappings settings using one query so
     * query is not fired for each setting
     */
    public static void LoadFieldMappings(){
        Setting__c[] settings = [Select Id, Name, Data__c From Setting__c Where Name Like 'FieldMappings:%'];
        for(Setting__c setting : settings){
            mapSettingsToName.put(setting.Name.toLowerCase(), setting);
        }
    }
    
    /* Created by hemanshu.shah@enzigma.com on 23 June 2016
     * Use this method to load field mapping which always returns map of string of string
     * it internally uses cached data to avoid queries
     */
    public static Database.UpsertResult saveFieldMappings(String strName, Settings.FieldMappings mappings){
        String strSettingsName = 'FieldMappings:' + strName;
        Setting__c settings = get(strSettingsName);
        if( settings == null )
            settings = new Setting__c(Name = strSettingsName);
        settings.Data__c = JSON.serialize(mappings);
        return Database.upsert(settings);
    }
    
    /* Created by hemanshu.shah@enzigma.com on 24 Apr 2016
     * Use this method to load field mapping which always returns map of string of string
     * it internally uses cached data to avoid queries
     */
    static Map<String, FieldMappings> mapFieldMappings = new Map<String, FieldMappings>();
    public static FieldMappings getFieldMappings(String strName){
        if( mapFieldMappings.containsKey(strName))
            return mapFieldMappings.get(strName);
        
        Setting__c setting = get('FieldMappings:' + strName);
		if( setting == null )
			return null;
		
		Settings.FieldMappings fieldMappings = (Settings.FieldMappings)JSON.deserialize(setting.Data__c, Settings.FieldMappings.class);

        mapFieldMappings.put(strName, fieldMappings);
        return fieldMappings;
    }
    
    public class FieldMappings {
        public integer version {get; set;}
        public Map<String, MappedField> mappings{get; set;}
    }
    
    public class MappedField {
        
        public MappedField(String strValue){
            this(strValue, false);
        }
        
        public MappedField(String strValue, Boolean isValue){
            this.isvalue = isValue;
            if( isValue )
                this.value = strValue;
            else
            	this.fieldname = strValue;
            this.overwrite = false;
        }

        public boolean isvalue {get; set;}
        public String value{get; set;}
        public String fieldname {get;set;}
        public boolean overwrite {get; set;}
    }
}