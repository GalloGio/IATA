public class vfIECEBC_CampaignRecipient extends vfIECEBC_Controller {
    public EBC_Campaign__c campaign { get; set; } 
    public ApexPages.StandardController con { public get; private set; }
    
    public vfIECEBC_CampaignRecipient(ApexPages.StandardController stdController) {
        this.con = stdController;
        this.campaign = (EBC_Campaign__c)stdController.getRecord();
    }  
    
    public List<SelectOption> getMasterFilters() {
        List<EBC_Master_Filter__c> filters = [Select Id, Name, Number_of_Recipients__c, Audience__c From EBC_Master_Filter__c Where Billing_Account__c = :vfIECEBC.billingAccount.Id AND Is_Global_Filter__c = false]; 
        
        List<SelectOption> options = new List<SelectOption>();
        for (EBC_Master_Filter__c filter : filters) {
            Boolean isDisabled = (this.campaign.EBC_Master_Filter__c != null && this.campaign.EBC_Master_Filter__r.Audience__c != filter.Audience__c);            
            
            
            options.add(new SelectOption(filter.Id, filter.Name, isDisabled)); 
        }
        
        return options;
    }
      
    @Readonly @Remoteaction
    public static Integer getExistingFilterCnt(String filterId) {
        return Integer.valueOf(Database.query(IECEBC_Utility.getSOQLFromMasterFilter(null, filterId))[0].get('expr0'));
    }
    
}