/* Created by @hemanshu.shah@enzigma.com on 24 Apr 2016
 * This class should contain all test methods related to Settings
 * 
 * 
*/
@isTest
public class TestSettings {
    
    public static Settings.FieldMappings getTestMappings(){
        Settings.FieldMappings settingsMapping = new Settings.FieldMappings();
        settingsMapping.version = 1;
        settingsMapping.mappings = new Map<String, Settings.MappedField>();
        settingsMapping.mappings.put('Name', new Settings.MappedField('Name'));
        settingsMapping.mappings.put('Lead_Source__c', new Settings.MappedField('WeWork.com', true));
        return settingsMapping;
    }
	
    @isTest
    public static void testSettingsTriggerUpdateUniqueKey(){
        String strName = 'Test';
        Settings.FieldMappings fieldMappings = getTestMappings();
        String strData = JSON.serialize(fieldMappings);
        Setting__c setting = new Setting__c(Name = strName, Data__c = strData );
        insert setting;
        System.assert(setting.Id != null);
        
        Setting__c setting2 = null;
        try{
            setting2 = new Setting__c(Name = strName, Data__c = strData );
            insert setting2;
        }
        catch(Exception ex){
            System.assert(true);
        }
        
        setting2 = new Setting__c(Name = strName + '2', Data__c = strData );
        insert setting2;
        System.assert(setting2.Id != null);
        
        try{
            setting2.Name = strName;
            update setting2;
        }
        catch(Exception ex){
            System.assert(true);
        }
    }
    
    @isTest
    public static void testSettingsCaching(){
        String strName = 'FieldMappings:LeadToContact';
        Settings.FieldMappings fieldMappings = getTestMappings();

        Database.UpsertResult result = Settings.saveFieldMappings('LeadToContact', fieldMappings);
        System.assert(result.getId() != null);
        
        Integer iQueriesSoFar = Limits.getQueries();
        Setting__c setting = Settings.get(strName);
        System.assert(setting != null);
        System.assert(iQueriesSoFar + 1 == Limits.getQueries());
        
        setting = Settings.get(strName);
        System.assert(setting != null);
        System.assert(iQueriesSoFar + 1 == Limits.getQueries());
        
        Settings.FieldMappings mappings = Settings.getFieldMappings('LeadToContact');
        System.assert(mappings != null);
        Settings.MappedField mappedField = mappings.mappings.get('Name');
        System.assert(mappedField.fieldname == 'Name');
        
        setting = new Setting__c(Name = strName + '-2', Data__c = setting.Data__c );
        insert setting;
        System.assert(setting.Id != null);
        
        iQueriesSoFar = Limits.getQueries();
        Settings.LoadFieldMappings();
        System.assert(iQueriesSoFar + 1 == Limits.getQueries());
        mappings = Settings.getFieldMappings('LeadToContact');
        System.assert(mappings != null);
        mappedField = mappings.mappings.get('Name');
        System.assert(mappedField.fieldname == 'Name');
        System.assert(iQueriesSoFar + 1 == Limits.getQueries());
    }
    
    @isTest
    public static void testLoadSettings(){
        String strName = 'FieldMappings:LeadToContact';
        Settings.FieldMappings fieldMappings = getTestMappings();

        Database.UpsertResult result = Settings.saveFieldMappings('LeadToContact', fieldMappings);
        System.assert(result.getId() != null);

        Settings.LoadSettings(new List<String>{strName});
        integer iQueriesSoFar = Limits.getQueries();
        
        Setting__c setting = Settings.get(strName);
        System.assert( setting != null);
        System.assert( iQueriesSoFar == Limits.getQueries());
        
        Settings.LoadFieldMappings();
        iQueriesSoFar = Limits.getQueries();
        
        setting = Settings.get(strName);
        System.assert( setting != null);
        System.assert( iQueriesSoFar == Limits.getQueries());
    }
    
    @isTest
    public static void testTypedSetings(){
        MySettings settingsMy = new MySettings();
        settingsMy.count = 10;
        settingsMy.timestamp = Date.today();
        settingsMy.name = 'Test';
        
        Setting__c setting = new Setting__c( Name = 'Test', Data__c = JSON.serialize(settingsMy));
        insert setting;
        
        settingsMy = (MySettings)Settings.get('Test', MySettings.class);
        System.assert(settingsMy.count == 10);
        System.assert(settingsMy.timestamp == Date.today());
        System.assert(settingsMy.name == 'Test');
    }
    
    /*@isTest
    public static void testMappingSettings(){
        Settings.MappingSettings settingsMapping = new Settings.MappingSettings();
        settingsMapping.version = 1;
        settingsMapping.mappings = new Map<String, Settings.MappedField>();
        settingsMapping.mappings.put('Name', new Settings.MappedField('Name'));
        settingsMapping.mappings.put('Lead_Source__c', new Settings.MappedField('WeWork.com', true));
        Debug.turnDebugOn();
        Debug.Log(JSON.serialize(settingsMapping));
        
        String strSettings = '{"version":1,"mappings":{"Lead_Source__c":{"value":"WeWork.com","isvalue":true},"Name":{"isvalue":false,"fieldname":"Name"}}}';
        settingsMapping = (Settings.MappingSettings)JSON.deserialize(strSettings, Settings.MappingSettings.class);
        Debug.Log('' + settingsMapping);
    }*/
    
    public class MySettings {
        Integer count;
        Date timestamp;
        String name;
    }
}