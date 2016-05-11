public class vfIECEBC_Campaign {
    class Controller_Exception extends Exception{}
    
    private User u = [Select ContactId, AccountId from User where id =: Userinfo.getUserid()];
    
    public ApexPages.StandardController con {
        public get;
        private set;
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
                'EBC_Master_Filter__r.Audience__c'
            });
        	stdController.addFields(fields);
        }
        
        this.campaign = (EBC_Campaign__c)stdController.getRecord();
        
        if (!String.isBlank(this.campaign.Id) && this.campaign.Account__c != u.AccountId) {
            throw new Controller_Exception('You don\'t have access to this record (' + this.campaign.Account__c + ':' + u.AccountId + ').');
        }
        this.campaign.Account__c = u.AccountId;
    }
    
    public PageReference saveAndExit() {
        this.con.save();
        
        return Page.IECEBC_Dashboard;
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
        this.con.save();
        currentStepNumber++;
        
        return getPRByStepNumber(currentStepNumber, true);
    }
    
    public PageReference pageLoad() {
        // Check if the current step is allowed and if not, redirect to the last allowed step
		if (campaign.Maximum_Allowed_Step__c < currentStepNumber) return getPRByStepNumber(Integer.valueOf(campaign.Maximum_Allowed_Step__c), true);
        
        return null;
    }
}