/**
 * Placeholder for different Task triggers logic
 * 
 * @author  RamseySolutions
 * @date    18/01/2016
 */
public class TaskTriggers {

    public static void updateLeadEngagementFields(Task[] newTasks) {
        
        Set<Task> tasksToProcess = new Set<Task>{};
        Set<Id> leadIds = new Set<Id>{};
            
        for (Task t:newTasks) {
            
            if (!String.isBlank(t.WhoId) &&
                String.valueOf(t.WhoId).startsWith('00Q') &&
                !String.isBlank(t.Subject) &&
                t.Subject.startsWith('Engage Campaign:')) {
                    
                tasksToProcess.add(t);
                leadIds.add(t.WhoId);
            }
        }
        
        if (!tasksToProcess.isEmpty()) {
            
            Map<Id, Lead> leadMap = new Map<Id, Lead>([select Id,
                                                              Engage_Emails_Sent__c,
                                                              Last_Engage_Email_Sent__c
                                                       from Lead
                                                       where Id in :leadIds]);

            for (Task t:tasksToProcess) {
                
                Lead l = leadMap.get(t.WhoId);
                
                l.Engage_Emails_Sent__c = l.Engage_Emails_Sent__c == null ? 1 : l.Engage_Emails_Sent__c + 1;
                l.Last_Engage_Email_Sent__c = t.CreatedDate;
            }
            
            update leadMap.values();
        }
    }
    
    
    public class QueueRoundRobinSettings {
        public String excludeprofiles {get; set;}
        public String[] types {get;set;}
        public String[] status {get;set;}
        public String[] excludesubjects {get;set;}
    }
    /**
     * ST-421 : Change owner to first User who responds
     * @author  Anant Kumar
     * @date    13/June/2016
     * @updated Mayuresh Ghodke & Samadhan Kadam
     * @comment	This function will fire on update task. If task is related to Lead and Lead having owner Queue. 
     *			Then if we update task with Status : Completed, Type : Call/Email/Phone, Subject : !Inbound Lead submission.
     *			Then current user is of that same lead owner's queue then lead's owner get change with current user.
     *			Same for Journey WhatId.
     * @date	18/July/2016
     */
  	public static void changeTaskOwner() {
      Setting__c settingsQueue = Settings.get('QueueManagementSettings');
      Set<String> setTypes = new Set<String>();
      Set<String> setStatus = new Set<String>();
      Set<String> setExcludeSubjects = new Set<String>();
      
      Set<Id> whatIdJourneySet = new Set<Id>();
      Set<Id> whoIdLeadSet = new Set<Id>();
      
      Id currentUserProfileId = userinfo.getProfileId();
      Id currentUser = userinfo.getUserId();
      
      //If no settings are found do not process the queue
      if( settingsQueue == null || String.IsBlank(settingsQueue.Data__c))
          return;
      
      QueueRoundRobinSettings setting = (QueueRoundRobinSettings)JSON.deserialize(settingsQueue.Data__c, QueueRoundRobinSettings.class);
      String excludedProfileId = setting.excludeprofiles;
      if(setting.types != null)
          setTypes = new Set<String>(setting.types);
      if(setting.status != null)
          setStatus = new Set<String>(setting.status);
      if(setting.excludesubjects != null)
          setExcludeSubjects = new Set<String>(setting.excludesubjects);
          
      String journeyPrefix = Journey__c.SObjectType.getDescribe().getKeyPrefix();
      
      for(Task task : (List<Task>)Trigger.New){
          if(setStatus.contains(task.Status) && (setTypes.contains(task.Type)) && (!setExcludeSubjects.contains(task.Subject))){
              //Find out WhatId which are Journey.
              if(task.WhatId != null){
                  if(String.valueOf(task.WhatId).startsWith(journeyPrefix)){
                      whatIdJourneySet.add(task.WhatId);  
                  }
              }
              //Find out WhoId which are Lead.
              if(task.WhoId != null){
                  if(String.valueOf(task.WhoId).startsWith('00Q')){
                      whoIdLeadSet.add(task.WhoId);
                  }
              }
          }
      }
	  
	  //For Lead whoId
      List<GroupMember> listQueueMember = new List<GroupMember>();
      Set<Id> setLeadOwnerFromQueue = new Set<id>();
      List<Lead> lstLeadToUpdate = new List<Lead>();
      List<Journey__c> lstLeadsJourneyToUpdate = new List<Journey__c>();
      
      if(whoIdLeadSet != null && !whoIdLeadSet.isEmpty()){
          List<Lead> lstLeadOwnerId = new List<Lead>([Select Id,OwnerId From Lead Where Id IN : whoIdLeadSet]);
          List<Journey__c> lstLeadsJourney = new List<Journey__c>([Select Id,OwnerId,Primary_Lead__c From Journey__c Where Primary_Lead__c IN : whoIdLeadSet]);
          //Find out list of queues which are require.
          for(Lead leadOwnerId : lstLeadOwnerId){
              if(String.ValueOf(leadOwnerId.OwnerId).startsWith('00G')){
                  setLeadOwnerFromQueue.add(leadOwnerId.OwnerId);
              }
          } 
          //Find out members of queue.
          if(setLeadOwnerFromQueue !=null && !setLeadOwnerFromQueue.isEmpty()){
              listQueueMember =[select Id,GroupId, UserOrGroupId from GroupMember where groupId =:setLeadOwnerFromQueue];
              for(Lead leadIterator : lstLeadOwnerId){
                  for(GroupMember queueMember : listQueueMember){
                      if(queueMember.GroupId == leadIterator.OwnerId && queueMember.UserOrGroupId == currentUser){
                      	  //Find out Lead's Journey which are having same Queue like Lead and change owner of that journey to current user.
                          for(Journey__c journeyIterator : lstLeadsJourney){
                          	if(journeyIterator.Primary_Lead__c == leadIterator.Id && journeyIterator.OwnerId == leadIterator.OwnerId){
                          		journeyIterator.OwnerId = currentUser;
                          		lstLeadsJourneyToUpdate.add(journeyIterator);
                          	}
                          }
                          leadIterator.OwnerId = currentUser;
                          lstLeadToUpdate.add(leadIterator);
                      }
                  }
              }
          }
      }
      
      //For Journey whatId
      List<GroupMember> listQueueMemberJaourney = new List<GroupMember>();
      Set<Id> setJaourneyOwnerFromQueue = new Set<id>();
      List<Journey__c> lstJaourneyToUpdate = new List<Journey__c>();
      
      //Find out list of queues which are require.
      if(whatIdJourneySet!=null && !whatIdJourneySet.isEmpty()){
          Set<Journey__c> lstJourneyOwnerId = new Set<Journey__c>([Select OwnerId From Journey__c Where Id IN : whatIdJourneySet]);
          for(Journey__c journeyOwnerId : lstJourneyOwnerId){
              if(String.ValueOf(journeyOwnerId.OwnerId).startsWith('00G')){
                  setJaourneyOwnerFromQueue.add(journeyOwnerId.OwnerId);
              }
          }
          //Find out members of queue.
          if(setJaourneyOwnerFromQueue !=null && !setJaourneyOwnerFromQueue.isEmpty()){
              listQueueMemberJaourney =[select Id,GroupId, UserOrGroupId from GroupMember where groupId =:setJaourneyOwnerFromQueue];
              for(Journey__c journeyIterator : lstJourneyOwnerId){
                  for(GroupMember queueMember : listQueueMemberJaourney){
                      if(queueMember.GroupId == journeyIterator.OwnerId && queueMember.UserOrGroupId == currentUser){
                          journeyIterator.OwnerId = currentUser;
                          lstJaourneyToUpdate.add(journeyIterator);
                      }
                  }
              }
          }
      }
      
      if(lstLeadToUpdate!=null && !lstLeadToUpdate.isEmpty())
      	update lstLeadToUpdate;
      	
      if(lstLeadsJourneyToUpdate!=null && !lstLeadsJourneyToUpdate.isEmpty())
      	update lstLeadsJourneyToUpdate;
      	
      if(lstJaourneyToUpdate!=null && !lstJaourneyToUpdate.isEmpty())	
      	update lstJaourneyToUpdate;  
    }
    
 /**
 * This method fire the trigger whenever call result assigned to Do Not Call 
 * Also Journey Stage is updated to Completed-Lost
 * @author  Samadhan Kadam
 * @date    17/05/2016
 */
    public static void updateJourneyStageField() 
      {
            String callResult,upperStr;
            List<Journey__c> lstJourneyToUpdate = new List<Journey__c>();
            
        for(Task task : (List<Task>)Trigger.New)
        {       
                if(!string.isBlank(task.CallDisposition))
                {
                    callResult = task.CallDisposition;
                    upperStr = callResult.toUpperCase();
                }
                
            if(upperStr == 'DO NOT CALL')
            {
                Journey__c journey = new Journey__c();
                journey.Id = task.whatId;
                journey.Stage__c = 'Completed-Lost';
                journey.Lost_Reason__c = 'Not Interested';
                lstJourneyToUpdate.add(journey);            
            }
        }
            if(lstJourneyToUpdate.size() > 0)
                update lstJourneyToUpdate;
      }
      
      
    /*
    Comment   : This method used for set NMD Next Contact Date on task create.
    Issue     : ST-297 , ST-298
    Author    : Amol Darekar 
    Date      : 19 May 2016 */
     public static void updateJourneyNMDNextContactDate()
      {
        try
        {
         list<Task> lstTask = Trigger.New;
         map<Id,String> mapTaskCallResult = new map<Id,String>();
         map<String,Integer> mapAddDays = new map<String,Integer>();
         map<Id,Id> mapJourneyContactIds = new map<Id,Id>();
         set<Id> setTaskJournyWhatIds = new set<Id>();
         
         
         list<Task> lstOpenTask = new list<Task>();
         set<Id> setTaskWhatId = new set<Id>();
         
         String NMDJson = [Select Data__c from Setting__c where Name=:'JourneySettings'].Data__c;
         list<NMDNextDateClass> lstNMDJson =  (List<NMDNextDateClass>) JSON.deserialize(NMDJson, List<NMDNextDateClass>.class);
         
         for(NMDNextDateClass currentNMDJson : lstNMDJson)
         {
            mapAddDays.put(currentNMDJson.CallResult,currentNMDJson.NextDate);
         }
         
         Schema.sObjectType sObjectTypeJourney = Schema.Journey__c.getSObjectType();
    
         for(Task currentTask : lstTask)
         {
            //Task objOldTask = (Task) Trigger.oldMap.get(currentTask.Id);
            //objOldTask.status == 'Not Started' && 

            if(currentTask.status == 'Completed' && currentTask.whatId != null && currentTask.whatId.getSObjectType() == sObjectTypeJourney)
            {

                if(!String.isBlank(currentTask.CallDisposition) && (currentTask.CallDisposition.contains('Left VM') || currentTask.CallDisposition.contains('No Answer/Busy')))
                {
                    mapTaskCallResult.put(currentTask.whatId,currentTask.CallDisposition);
                    
                    if(currentTask.CallDisposition.contains('Left VM'))
                          currentTask.ActivityDate = DateUtilities.addBusinessDays(Date.today(), mapAddDays.get('Left VM'));
                    else
                          currentTask.ActivityDate = DateUtilities.addBusinessDays(Date.today(), mapAddDays.get('No Answer/Busy'));
                }
            }
         }

         if(mapTaskCallResult !=null && mapTaskCallResult.size()>0)
         {
             /*list<Journey__c> lstJourney = [Select Id, Name, Primary_Contact__c, NMD_Next_Contact_Date__c from Journey__c where Id IN:mapTaskCallResult.keySet()];
             
             for(Journey__c currentJourney: lstJourney)
             {
                mapJourneyContactIds.put(currentJourney.Id,currentJourney.Primary_Contact__c);
                
                if(mapTaskCallResult.get(currentJourney.Id).contains('Left VM'))
                {
                    currentJourney.NMD_Next_Contact_Date__c = DateUtilities.addBusinessDays(Date.today(), mapAddDays.get('Left VM'));
                }
                else
                {
                    currentJourney.NMD_Next_Contact_Date__c = DateUtilities.addBusinessDays(Date.today(), mapAddDays.get('No Answer/Busy'));
                }
             }*/
             
             
             //Set WhoId for task
            if(mapJourneyContactIds !=null && mapJourneyContactIds.size()>0)
            {
             for(Task currentTask : lstTask)
             {
                currentTask.whoId = mapJourneyContactIds.get(currentTask.whatId);
             }
             
            }
            
             
             /*if(lstJourney != null && lstJourney.size() >0)
             {
                        update lstJourney;  
             }*/
         }
         
         //Issue: ST-298
         for(Task currentTask : lstTask)
             {
                system.debug(loggingLevel.ERROR,'Status*********************'+currentTask.Status);
                if(currentTask.whatId != null && currentTask.whatId.getSObjectType() == sObjectTypeJourney)
                {
                    if(currentTask.status != 'Completed')
                    {
                        setTaskWhatId.add(currentTask.whatId);
                        lstOpenTask.add(currentTask);
                        
                        if(currentTask.status == 'Not Started')
                              setTaskJournyWhatIds.add(currentTask.whatId);
                    }
                }
             }
             
             /*if(setTaskWhatId != null && setTaskWhatId.size()>0)
             {
                 map<Id,Journey__c> mapJourney = new map<Id,Journey__c>([Select Id, Name, Primary_Contact__c, NMD_Next_Contact_Date__c from Journey__c where Id IN:setTaskWhatId]);
                 
                 for(Task currentTask : lstOpenTask)
                 {
                    if(currentTask.ActivityDate == null)
                        currentTask.ActivityDate = mapJourney.get(currentTask.whatId).NMD_Next_Contact_Date__c;
                        
                    currentTask.whoId = mapJourney.get(currentTask.whatId).Primary_Contact__c;
                    system.debug(logginglevel.ERROR,'ActivityDate==>'+currentTask.ActivityDate);
                 }
             }*/
             
            
        if(setTaskJournyWhatIds !=null && setTaskJournyWhatIds.size()> 0)
          {
            list<Task> lstTaskToBeCompleted = [Select status , ActivityDate,Subject from Task Where WhatId IN:setTaskJournyWhatIds and ActivityDate <: Date.today() and status !=: 'Completed'];
            
            if(lstTaskToBeCompleted != null && lstTaskToBeCompleted.size()>0)
            {
                for(Task currentTask : lstTaskToBeCompleted)
                {
                    system.debug(loggingLevel.ERROR,'CURRENT TASK+++++++++++++++++++++'+currentTask);
                 if(currentTask.subject != null && currentTask.subject.contains('Follow-Up'))
                 {
                    
                     currentTask.status = 'Completed'; 
                 }
                }
                
                update lstTaskToBeCompleted;
            }
          }
         
        }
        catch(Exception ex)
        {
            system.debug(logginglevel.ERROR,'Exception:'+ex.getMessage());
        }
      }
      
      
    /*
    Comment   : This method used for set open Tasks due date to Journeys NMD Next Contact Date.
    Issue     : ST-298
    Author    : Amol Darekar 
    Date      : 19 May 2016 
    public static void updateTaskDueDateToJournyNextContactDate()
    {
        //try
        //{
            list<Task> lstTask = Trigger.New;
            list<Task> lstOpenTask = new list<Task>();
            set<Id> setTaskWhatId = new set<Id>();
            
            Schema.sObjectType sObjectTypeJourney = Schema.Journey__c.getSObjectType();
            
            for(Task currentTask : lstTask)
             {
                if(currentTask.whatId != null && currentTask.whatId.getSObjectType() == sObjectTypeJourney)
                {
                    if(currentTask.status == 'Not Started')
                    {
                        setTaskWhatId.add(currentTask.whatId);
                        lstOpenTask.add(currentTask);
                    }
                }
             }
             
             map<Id,Journey__c> mapJourney = new map<Id,Journey__c>([Select Id, Name, NMD_Next_Contact_Date__c from Journey__c where Id IN:setTaskWhatId]);
             system.debug(logginglevel.ERROR,' mapJourney==>'+mapJourney);
             for(Task currentTask : lstTask)
             {
                if(setTaskWhatId.contains(currentTask.whatId))
                    currentTask.ActivityDate = mapJourney.get(currentTask.whatId).NMD_Next_Contact_Date__c;
                    
             }
             
             
            list<Task> lstTaskToBeCompleted = [Select status , subject , ActivityDate from Task Where WhatId IN:mapJourney.keySet() and ActivityDate <: Date.today() and status !=: 'Completed'];
            
            for(Task currentTask : lstTaskToBeCompleted)
            {
                if(currentTask.subject != null && currentTask.subject.contains('Follow-Up'))
                {
                    currentTask.status = 'Completed';
                }
            }
            
            
            
          if(lstTaskToBeCompleted != null && lstTaskToBeCompleted.size() > 0)   
                    update lstTaskToBeCompleted;
        }
        catch(Exception ex)
        {
            system.debug(ex.getMessage());
        }
    } */    

    public class NMDNextDateClass
    {
        public String CallResult{get;set;}
        public Integer NextDate{get;set;}  
    }   
  }