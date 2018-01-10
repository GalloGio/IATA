public with sharing class LVA_AfterChatTriggerHandler {
    
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