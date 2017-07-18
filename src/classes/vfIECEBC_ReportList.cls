public class vfIECEBC_ReportList extends vfIECEBC_Abstract_List {
    public static Integer ITEMS_PER_PAGE = 3;
    private boolean firsttimepageload=true;
    public vfIECEBC_ReportList() {
    }
    
    public List<EBC_Campaign__c> getCampaigns() {
        return (List<EBC_Campaign__c>)items; 
    }
    private String getQuery(Boolean isCountOnly) {
        List<String> fields = new List<String>();
        if (isCountOnly) {
            fields.add('count()');
        } else {
            fields.add('Id');
            fields.add('Name');
            fields.add('Status__c');
            fields.add('Send_Datetime__c'); 
            fields.add('Number_of_Recipients__c');
            fields.add('Number_of_Unique_Opens__c');
            fields.add('NumberSent__c');
            fields.add('Number_of_Unique_Clicks__c');
            fields.add('EBC_Design__c');
            fields.add('Is_Step5_Writable__c');
            fields.add('Is_Step4_Valid__c');  
            fields.add('Owner.Name'); 
            fields.add('EBC_Master_Filter__r.Name');
            fields.add('LastModifiedDate');
            fields.add('OpenRate7Days__c');
            fields.add('ClickRate7Days__c');
        }
        
        return 'Select ' + String.join(fields, ',') + ' FROM EBC_Campaign__c WHERE Billing_Account__c = \'' + vfIECEBC.billingAccount.Id + '\' AND Status__c IN (\'SENT\',\'STARTED\')';
    }
    
    private Boolean getIsFirstTimeLoadPage() { 
        if (firsttimepageload) {firsttimepageload=false; return true;}
        return false;
    }
}