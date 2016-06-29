public class vfIECEBC_Campaign {
    class Controller_Exception extends Exception{}
    
    public ApexPages.StandardController con {
        public get;
        private set;
    }
    public PageReference doNothing() {
        return null;
    }
    
    public PageReference submitForApproval() {
        // Create an approval request for the account
        Approval.ProcessSubmitRequest req1 = new Approval.ProcessSubmitRequest();
        //req1.setComments('Submitting request for approval.');
        req1.setObjectId(campaign.id);
        
        // Submit on behalf of a specific submitter
        req1.setSubmitterId(UserInfo.getUserId());
        // Submit the record to specific process and skip the criteria evaluation
        req1.setProcessDefinitionNameOrId('EBC_Campaign_Approval');
        if (Test.isRunningTest()) {
        	req1.setSkipEntryCriteria(true);
        }
        // Submit the approval request for the account
        Approval.ProcessResult result = Approval.process(req1);
        // Verify the result
        System.assert(result.isSuccess());
         

    
        return null;
    }
    
    private Map<Integer, PageReference> stepToPageReference = new Map<Integer, PageReference>{
        1 => Page.IECEBC_Campaign,
        2 => Page.IECEBC_CampaignRecipients,
        3 => Page.IECEBC_CampaignTemplate,
        4 => Page.IECEBC_CampaignDesign,
        5 => Page.IECEBC_CampaignSchedule,
        6 => Page.IECEBC_CampaignConfirm
    };
    
    public Integer currentStepNumber {
        get {
            if (currentStepNumber == null) {
                PageReference currentPage = ApexPages.currentPage();
                currentPage.getParameters().clear();
                
                for(Integer i = 1; i <= 6; i++) {
                    if (currentPage.getUrl().toLowerCase() == getPRByStepNumber(i, false).getUrl().toLowerCase()) currentStepNumber = i;
                }
            }
            
            return currentStepNumber;
        }
        private set;
    }
    public PageReference getPRByStepNumber(Integer stepNumber, Boolean withParams) {
        PageReference pr = stepToPageReference.get(stepNumber);
        
        if (withParams) {
        	if (!String.isBlank(this.con.getId())) pr.getParameters().put('id', this.con.getId());
        }
        
        pr.setRedirect(true);
        
        return pr;
    }
    
    public EBC_Campaign__c campaign { get; set; }
    
    public vfIECEBC_Campaign(ApexPages.StandardController stdController) {        
        this.con = stdController;
        
        if (!Test.isRunningTest()) {
            List<String> fields = new List<String>();
            fields.addAll(Schema.sObjectType.EBC_Campaign__c.fields.getMap().keySet());
            fields.addAll(new List<String>{
                'EBC_Master_Filter__r.Audience__c',
                'EBC_Master_Filter__r.Name',
                'EBC_Master_Filter__r.Number_of_Recipients__c'
            });
        	stdController.addFields(fields);
        }
        
        this.campaign = (EBC_Campaign__c)stdController.getRecord();
        
        if (!String.isBlank(this.campaign.Id) && this.campaign.Account__c != vfIECEBC.usr.Contact.AccountId) {
            throw new Controller_Exception('You don\'t have access to this record (' + this.campaign.Account__c + ':' + vfIECEBC.usr.Contact.AccountId + ').');
        }
        this.campaign.Account__c = vfIECEBC.usr.Contact.AccountId;
        this.campaign.Billing_Account__c = vfIECEBC.billingAccount.Id;
    }
    
    public PageReference saveAndExit() {
        PageReference pr = this.con.save();
        
        if (!ApexPages.hasMessages()) {
            pr = Page.IECEBC_Dashboard;
        }
        
        return pr;
    }
    
    public PageReference previous() {
        currentStepNumber--;
        
        return getPRByStepNumber(currentStepNumber, true);
    }
    public PageReference next() {
        currentStepNumber++;
        
        return getPRByStepNumber(currentStepNumber, true);
    }
    
    public PageReference saveAndContinue() {
        PageReference pr = this.con.save();
        
        if (!ApexPages.hasMessages()) {
            currentStepNumber++;
            
            pr = getPRByStepNumber(currentStepNumber, true);
        }
        
        return pr;
    }
    
    public PageReference pageLoad() {
        // Check if the current step is allowed and if not, redirect to the last allowed step
		if (campaign.Maximum_Allowed_Step__c < currentStepNumber) return getPRByStepNumber(Integer.valueOf(campaign.Maximum_Allowed_Step__c), true);
        
        return null;
    }
}