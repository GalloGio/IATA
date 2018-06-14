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
         return getCounter(filterId);
    }
    public static Integer getCounter(String filterId) {
        System.debug('vfIECEBC_CampaignRecipient.public static Integer getExistingFilterCnt(String filterId) >>>');
        boolean elastic_switch = IEC_Settings__c.getOrgDefaults().eBroadcast_Counter_Switch__c;
        String cntQuery=IECEBC_Utility.getSOQLFromMasterFilter(null, filterId,elastic_switch);
        if (!elastic_switch) return Integer.valueOf(Database.query(cntQuery)[0].get('expr0'));
        IECEBCNew_eBroadcast_Counter req = new IECEBCNew_eBroadcast_Counter();
        return req.execute(cntQuery,false); 
        //only query salesforce and return counter when elastic switch is false
        
    }
    
}