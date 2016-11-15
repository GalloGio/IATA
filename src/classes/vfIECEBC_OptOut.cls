public class vfIECEBC_OptOut {
    public String email {
        get {
            if (email == null) {
                email = IECUtil.DecryptParameter(ApexPages.currentPage().getParameters().get('e'));
            }
            return email;
        }
        set;
    }
    public String campaignId {
        get {
            if (campaignId == null) {
                campaignId = IECUtil.DecryptParameter(ApexPages.currentPage().getParameters().get('c'));
            }
            return campaignId;
        }
        set;
    }
    public String billingAccountId {
        get {
            if (billingAccountId == null) {
                billingAccountId = IECUtil.DecryptParameter(ApexPages.currentPage().getParameters().get('bai'));
            }
            return billingAccountId;
        }
        set;
    }
    public String billingAccountName {
        get {
            if (billingAccountName == null) {
                billingAccountName = IECUtil.DecryptParameter(ApexPages.currentPage().getParameters().get('ban'));
            }
            return billingAccountName;
        }
        set;
    }
    
    public String sender {
        get {
            if (sender == null) sender = billingAccountId;
            return sender;
        }
        set;
    }
    
    public PageReference unsubscribe() {
        List<String> userReasons = new List<String>();
        for(String reason : reasons.keySet()) {
            if (reasons.get(reason)) userReasons.add(reason);
        }
        
        EBC_Email_Exclusion__c ee = new EBC_Email_Exclusion__c();
        ee.Email__c = email;
        ee.Event_Date__c = Datetime.now();
        ee.Event_Date_Timestamp__c = ee.Event_Date__c.getTime();
        ee.Source_Campaign__c = campaignId;
        ee.Other_Reason__c = String.join(userReasons, '\n');
        
        ee.Type__c = 'OPTOUT';
        if (sender != 'all') {
	        ee.Unsubscribe_From__c = billingAccountId;
        }
        
        insert ee;
        
        PageReference pr = Page.IECEBC_PublicConfirmation;
        pr.setRedirect(true);
        //pr.getParameters().put('e', ApexPages.currentPage().getParameters().get('e'));
        return pr;
    }
    
    public Map<String, Boolean> reasons {
        get {
            if (reasons == null) {
                reasons = new Map<String, Boolean>{
                    'The content is not relevant to me' => false,
                    'This email address is not meant for such content' => false,
                    'You send too many emails' => false,
                    'I get too many emails in general' => false
                };
            }
            return reasons;
        }
        set;
    }
}