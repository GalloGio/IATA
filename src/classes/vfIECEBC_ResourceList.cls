public class vfIECEBC_ResourceList extends vfIECEBC_Abstract_List {
    public static Integer ITEMS_PER_PAGE = 2;
    private boolean firsttimepageload=true;
    public vfIECEBC_ResourceList() {
    }
    
    
    private String getQuery(Boolean isCountOnly) {
        List<String> fields = new List<String>();
        if (isCountOnly) {
            fields.add('count()');
        } else {
            fields.add('Id');
            fields.add('Name');
            fields.add('CreatedDate');
            fields.add('LastModifiedDate'); 
        }
        return 'Select ' + String.join(fields, ',') + ' FROM EBC_Resource__c Where Billing_Account__c = \'' + vfIECEBC.billingAccount.Id + '\'';
        
        //return 'Select ' + String.join(fields, ',') + ' FROM EBC_Template__c Where Is_Reusable__c  = true AND Billing_Account__c = \'' + vfIECEBC.billingAccount.Id + '\'';
    }
    
    public List<EBC_Resource__c> getFilters() {
        return (List<EBC_Resource__c>)items; 
    }
    public EBC_Resource__c getSelectedFilter() {
        return (EBC_Resource__c)selectedItem; 
    }
    private Boolean getIsFirstTimeLoadPage() { 
        if (firsttimepageload) {firsttimepageload=false; return true;}
        return false;}
    
}