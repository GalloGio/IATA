public class vfIECEBroadcastCampaign {
    class Controller_Exception extends Exception{}
    
    public ApexPages.StandardController con {
        public get;
        private set;
    }
    
    private Map<Integer, PageReference> stepToPageReference = new Map<Integer, PageReference>{
        1 => Page.IECEBroadcastCampaign,
        2 => Page.IECEBroadcastCampaignRecipients,
        3 => Page.IECEBroadcastCampaignTemplate,
        4 => Page.IECEBroadcastCampaignDesign,
        5 => Page.IECEBroadcastCampaignSchedule,
        6 => Page.IECEBroadcastCampaignConfirm
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
    
    public eBroadcast_Campaign__c campaign { get; set; }
    
    public vfIECEBroadcastCampaign(ApexPages.StandardController stdController) {
        this.con = stdController;
        
        if (!Test.isRunningTest()) {
        	stdController.addFields(new List<String>{'Maximum_Allowed_Step__c'});
        }
        
        this.campaign = (eBroadcast_Campaign__c)stdController.getRecord();
    }
    
    public PageReference saveAndExit() {
        this.con.save();
        
        return Page.IECEBroadcast;
    }
    
    public PageReference previous() {
        currentStepNumber--;
        
        return getPRByStepNumber(currentStepNumber, true);
    }
    
    public PageReference saveAndContinue() {
        this.con.save();
        currentStepNumber++;
        
        return getPRByStepNumber(currentStepNumber, true);
    }
    
    public PageReference pageLoad() {
        // Check if the current step is allowed and if not, redirect to the last allowed step
		if (campaign.Maximum_Allowed_Step__c < (currentStepNumber - 1)) return getPRByStepNumber(Integer.valueOf(campaign.Maximum_Allowed_Step__c), true);
        
        return null;
    }
}