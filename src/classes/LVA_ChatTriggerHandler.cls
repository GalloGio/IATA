public with sharing class LVA_ChatTriggerHandler {
    public List<LiveChatTranscript> triggerNew = (List<LiveChatTranscript>) Trigger.new;
    public List<LiveChatTranscript> triggerOld = (List<LiveChatTranscript>) Trigger.old;
    
    public Map<Id, LiveChatTranscript> newMap = (Map<Id,LiveChatTranscript>) Trigger.newMap;
    public Map<Id, LiveChatTranscript> oldMap = (Map<Id,LiveChatTranscript>) Trigger.oldMap;

    public Set<string> closedStatusSet = new Set<String>{ 'Completed','Missed','Dropped' };
    public string INPROGRESS_STATUS = 'InProgress';
    
    // ************************************************************
    // ****************** distribution methods ********************
    // ************************************************************
    
    public void onBeforeInsert(){
        CreateCaseForLiveChat();
    }
    
    public void onAfterInsert(){
    }
    
    public void onBeforeUpdate(){
    }
    public void onAfterUpdate(){  
        processLiveChat();      
    }
    
  //  public void onBeforeDelete(){}
  //  public void onAfterDelete(){}
    
    // ************************************************************
    // ********************* action methods ***********************
    // ************************************************************
    
    public void CreateCaseForLiveChat(){
        Date mydate = Date.today();
        Map<Id, Case> mapCases = new Map<Id,Case>();
        List<Case> lstCases = new List<Case>();
        for(LiveChatTranscript lct : triggerNew){
            Case casec = new Case(
                RecordTypeId = lct.Case_Record_Type_ID__c,        
                Subject = 'Chat with IATA Customer Service '+ mydate.month() + '/' + mydate.day() + '/' + mydate.year(),
                Type = 'Case',            
                Country_concerned_by_the_query__c =  lct.Country_Concerned__c,
                AccountId =  lct.AccountId,
                ContactId = lct.ContactId,
                Status = 'Action Needed',
				assign__C= false,
                ownerId=lct.OwnerId
            );
            lstCases.add(casec);
            mapCases.put(lct.id, casec);
        }
        
        if(!lstCases.isEmpty()){
            insert lstCases;
            
            for(LiveChatTranscript lct : triggerNew){
                Case c = mapCases.get(lct.id);
                lct.CaseId = c.id;
            }
        }
    }


   
    public void processLiveChat(){
        List<LiveChatTranscript> lctlist= new List<LiveChatTranscript>(); 
        List<case> caseToUpdateList= new List<case>(); 

        for(LiveChatTranscript lct:triggerNew){
        
            if(lct.Status != oldMap.get(lct.id).Status ){
                
                //assign case owner
                if(lct.Status==INPROGRESS_STATUS)  caseToUpdateList.add(new case(id=lct.caseId,ownerId=lct.ownerId));
                else    
                //createLiveChatPDF
                if(oldMap.get(lct.id).Status ==INPROGRESS_STATUS && closedStatusSet.contains(lct.Status))   lctlist.add(lct);

            }
        }
        if(!lctlist.isEmpty()) ProcessLiveChatTranscript(lctlist);   
        
        if(!caseToUpdateList.isEmpty()) update caseToUpdateList;  

    }

     public static void ProcessLiveChatTranscript(List<LiveChatTranscript> liveChatTranscripts){
        List<CaseComment> ccs = new List<CaseComment>();
        List<Attachment> atts = new List<Attachment>();
        Set<Id> caseIds = new Set<Id>();
        Map<Id, String> mapCaseThread = new Map<Id, String>();
        boolean hasTranscriptBody = false;
        for(LiveChatTranscript lct: liveChatTranscripts){
            caseIds.add(lct.CaseId);
        }
        
        List<Id> lctIds = new List<Id>();
        for(LiveChatTranscript lct: liveChatTranscripts){
            if(lct.CaseId !=null){
                lctIds.add(lct.Id);
                caseIds.add(lct.CaseId);
                if(!String.isEmpty(lct.SupervisorTranscriptBody)){
                    CaseComment cc = CreateCaseComment(lct.SupervisorTranscriptBody, lct.CaseId);
                    ccs.add(cc);
                }
            }
        }
        
        LVA_CallGeneratePDFAttach.addPDFAttach(lctIds, caseIds);
        
        if(ccs.size()>0){
            insert ccs;
        }
    }
    
    private static CaseComment CreateCaseComment(String supervisorTranscriptBody, Id caseId){
        CaseComment cc = new CaseComment();
        cc.CommentBody = supervisorTranscriptBody;
        cc.ParentId = caseId;
        cc.IsPublished = false;
        
        return cc;
    }
}