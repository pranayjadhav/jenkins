public class ListViewController {
    
    @RemoteAction
    public static List<SelectOption> getName() {
    List<Schema.SObjectType> gd = Schema.getGlobalDescribe().Values();     
    List<SelectOption> options = new List<SelectOption>();
    for(Schema.SObjectType f : gd){
       options.add(new SelectOption(f.getDescribe().getName(),f.getDescribe().getName()));
    }
    options.sort();
    return options;
   }
    
    @RemoteAction    
    public static Map<Id, string> getViews(string objectName) {        
        Map<Id, string> views = new Map<Id, string>();
       
            string queryString = 'Select Id,Name FROM '+objectName+' order by Name limit 1';
            ApexPages.StandardSetController setCtrl = new ApexPages.StandardSetController(Database.getqueryLocator(queryString));
            for(selectoption s: setCtrl.getListViewOptions()) {
                views.put(s.getValue(),s.getLabel());
            }    
          return views;
    }
    
    @RemoteAction
    public static sObject[] Query(String strQuery) {
        return Database.Query(strQuery);
    }
}