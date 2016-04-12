public class vfIECEBC_CampaignList {
    class Controller_Exception extends Exception{}
    public List<EBC_Campaign__c> campaigns {
        get {
            User u = [Select ContactId, Contact.AccountId from User where id =: Userinfo.getUserid()];
            
	        if (campaigns == null) campaigns = [Select Id, Name, Status__c, Scheduled_Date__c, Owner.Name From EBC_Campaign__c WHERE Account__c = :u.Contact.AccountId ORDER BY LastModifiedDate];
            return campaigns;
        }
        private set;
    }
    public Integer getCampaignsCount() {
        return [Select count() From EBC_Campaign__c];
    }
    
    public vfIECEBC_CampaignList() {
    }
}