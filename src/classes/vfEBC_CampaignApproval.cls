public class vfEBC_CampaignApproval {
    private final EBC_Campaign__c c;

    public vfEBC_CampaignApproval(ApexPages.StandardController stdController) {
        if (!Test.isRunningTest()) {
            stdController.addFields(new List<String>{'EBC_Design__c'});
        }
        this.c = (EBC_Campaign__c)stdController.getRecord();
    }
    
    public Attachment getTemplateAttachment() {
        List<Attachment> attchs = [SELECT BodyLength,ContentType,Id,Name FROM Attachment Where ParentId = :c.EBC_Design__c LIMIT 1];
        if (attchs.size() > 0) return attchs[0];
        
        return null;
    }
    
    public ProcessInstanceWorkitem piWorkItem {
        get {
            if (piWorkItem == null) {
                List<ProcessInstanceWorkitem> piwis = [SELECT Id,Actor.Name,ElapsedTimeInHours,OriginalActor.Name,ProcessInstanceId FROM ProcessInstanceWorkitem Where ProcessInstance.Status = 'Pending' AND ProcessInstance.TargetObjectId = :c.Id LIMIT 1];
                if (piwis.size() > 0) {
                    piWorkItem = piwis[0];
                }
            }
            
            return piWorkItem;
        }
        set;
    }
    
    
    public PageReference Approve(){            
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        req.setAction('Approve');
        req.setWorkitemId(piWorkItem.Id);
        Approval.ProcessResult result =  Approval.process(req);
        
        PageReference pr = new PageReference('/apex/EBC_CampaignApproval?id=' + c.Id);
        pr.setRedirect(true);
        return pr;
    }
    
    public PageReference Reject(){            
        Approval.ProcessWorkitemRequest req = new Approval.ProcessWorkitemRequest();
        req.setAction('Reject');
        req.setWorkitemId(piWorkItem.Id);
        Approval.ProcessResult result =  Approval.process(req);
        
        PageReference pr = new PageReference('/apex/EBC_CampaignApproval?id=' + c.Id);
        pr.setRedirect(true);
        return pr;
    }
}