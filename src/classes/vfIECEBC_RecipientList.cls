public class vfIECEBC_RecipientList extends vfIECEBC_Abstract_List {
    public vfIECEBC_RecipientList() {
    }
    
    
    private String getQuery(Boolean isCountOnly) {
        List<String> fields = new List<String>();
        if (isCountOnly) {
            fields.add('count()');
        } else {
            fields.add('Id');
            fields.add('Name');
            fields.add('Audience__c');
            fields.add('CreatedDate');
            fields.add('LastModifiedDate'); 
            fields.add('(Select Id From eBroadcast_Campaigns__r)');
        }
        
        return 'Select ' + String.join(fields, ',') + ' FROM EBC_Master_Filter__c Where Is_Global_Filter__c  = false AND Billing_Account__c = \'' + vfIECEBC.billingAccount.Id + '\'';
    }
    
    public List<EBC_Master_Filter__c> getFilters() {
        return (List<EBC_Master_Filter__c>)items; 
    }
    public EBC_Master_Filter__c getSelectedFilter() {
        return (EBC_Master_Filter__c)selectedItem; 
    }
        
    /*
    public List<SelectOption> getSortByOptions() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('CreatedDate DESC','Creation Date'));
        options.add(new SelectOption('LastModifiedDate DESC','Last Edited'));
        options.add(new SelectOption('Name ASC','Name'));
        options.add(new SelectOption('Audience__c ASC', 'Type'));
        
        return options;
    }*/
}