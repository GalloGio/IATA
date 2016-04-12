public class vfIECEBC_Dashboard {
    class Controller_Exception extends Exception{}
    public List<EBC_Campaign__c> campaigns {
        get {
            User u = [Select ContactId, Contact.AccountId from User where id =: Userinfo.getUserid()];
            
            if (campaigns == null) campaigns = [Select Id, Name, Status__c, Scheduled_Date__c, Owner.Name From EBC_Campaign__c WHERE Account__c = :u.Contact.AccountId ORDER BY LastModifiedDate LIMIT 3];
            return campaigns;
        }
        private set;
    }
    public Integer getCampaignsCount() {
        return [Select count() From EBC_Campaign__c];
    }
    
    public vfIECEBC_Dashboard() {
    }
}