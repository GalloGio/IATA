public class LVA_BeforeChatTriggerHandler {
    
    public List<LiveChatTranscript> triggerNew = (List<LiveChatTranscript>) Trigger.new;
    public List<LiveChatTranscript> triggerOld = (List<LiveChatTranscript>) Trigger.old;
    
    public Map<Id, LiveChatTranscript> newMap = (Map<Id,LiveChatTranscript>) Trigger.newMap;
    public Map<Id, LiveChatTranscript> oldMap = (Map<Id,LiveChatTranscript>) Trigger.oldMap;
    
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
    }
    
    public void onBeforeDelete(){}
    public void onAfterDelete(){}
    
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
                Status = 'Action Needed'
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
}