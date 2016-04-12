public class vfIECEBC_CampaignRecipient {
    class Controller_Exception extends Exception{}
    
    public ApexPages.StandardController con {
        public get;
        private set;
    }

    public vfIECEBC_CampaignRecipient(ApexPages.StandardController stdController) {
        this.con = stdController;
    }
    
    public Integer getRecipientsCount() {
        return [select count() from Test_Object__c]; // @todo Replace this object with the filter object
    }
}