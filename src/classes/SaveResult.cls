public class SaveResult
{
    public String Id{get;set;}
    public Boolean IsSuccess {get;set;}
    public String Message{get;set;}
    public Boolean IsCreated { get; set; }
    public sObject SFObject {get;set;}
    public Object DataObject {get;set;}
    public Object[] Data {get;set;}
    
    public SaveResult(){
        Data = new List<Object>();
    }
    public SaveResult(Exception ex){
        IsSuccess =  false;
        Message = ex.getMessage();
    }
    public SaveResult(Database.Saveresult saveResult){
        IsSuccess = saveResult.isSuccess();
        if(IsSuccess)
            Id = saveResult.getId();
        Message = '';
        for(Database.Error dbError : saveResult.getErrors())
            Message += dbError + '\n';
    }
    public SaveResult(Database.Upsertresult upsertResult){
        IsSuccess = upsertResult.isSuccess();
        if(IsSuccess)
            Id = upsertResult.getId();
        Message = '';
        for(Database.Error dbError : upsertResult.getErrors())
            Message += dbError + '\n';
    }
    
    //Method to convert the database saveresult array to custom saveresult object
    public SaveResult(Database.SaveResult[] saveResultArray){
        IsSuccess = true;
        Message = '';
        for(Database.Saveresult saveResultNew : saveResultArray){
            if(!saveResultNew.isSuccess()){
                IsSuccess = false;
                for(Database.Error dbError : saveResultNew.getErrors())
                    Message += dbError + '\n';
            }else
                Id = saveResultNew.Id;
        }  
    }

    public SaveResult(Database.Upsertresult[] upsertResultArray){
        IsSuccess = true;
        Message = '';
        for(Database.Upsertresult upsertResultNew : upsertResultArray){
            if(!upsertResultNew.isSuccess()){
                IsSuccess = false;
                for(Database.Error dbError : upsertResultNew.getErrors())
                    Message += dbError + '\n';
            }
        }  
    }
    public SaveResult(Database.DeleteResult[] deleteResultArray){
        IsSuccess = true;
        Message = '';
        for(Database.DeleteResult deleteResultNew : deleteResultArray){
            if(!deleteResultNew.isSuccess()){
                IsSuccess = false;
                for(Database.Error dbError : deleteResultNew.getErrors())
                    Message += dbError + '\n';
            }
        }  
    }
}