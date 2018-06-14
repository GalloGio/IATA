public class vfIECEBC_RecipientList extends vfIECEBC_Abstract_List {
    public static Integer ITEMS_PER_PAGE = 2;
    private boolean firsttimepageload=true; 
    public vfIECEBC_RecipientList() {
        SortBy='CreatedDate';
    }
    
    public PageReference duplicate() {
        EBC_Master_Filter__c castedSelectedItem = (EBC_Master_Filter__c)selectedItem;
        
        EBC_Master_Filter__c cloned = duplicate(selectedItem.Id, castedSelectedItem.Name);
        
        
        PageReference pr = new PageReference('/apex/IECEBC_Recipient?id=' + cloned.Id);
        pr.setRedirect(true);
        return pr;
    }
    public static EBC_Master_Filter__c duplicate(Id originalId, String name) {
        EBC_Master_Filter__c f = [Select Id,
                     Billing_Account__c,
                     Refinement_Condition__c,
                     Geo_Condition__c,
                     Audience__c,
                     IATA_Codes__c,
                     Number_of_Recipients__c,
                     Name
                     From EBC_Master_Filter__c
                     where Id = :originalId];
        
        EBC_Master_Filter__c cloned = (EBC_Master_Filter__c)f.clone(false, true, false, false);
        cloned.Name = name; 
        
        insert cloned;
        
        List<EBC_Customer_Filter__c> customerFilters = [
            Select Id,
            Name,
            API_Name__c ,
            EBC_Application_Filter__c ,
            Field_Name__c ,
            Field_Operator__c ,
            Field_Value__c 
            From EBC_Customer_Filter__c
            Where EBC_Master_Filter__c = :originalId
        ];
        
        for(EBC_Customer_Filter__c cf : customerFilters) {
            cf.Id = null;
            cf.EBC_Master_Filter__c = cloned.Id;
        }
        
        insert customerFilters;
        
        return cloned;
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
            fields.add('(Select Id, Status__c From eBroadcast_Campaigns__r)');
        }
        
        return 'Select ' + String.join(fields, ',') + ' FROM EBC_Master_Filter__c Where Is_Global_Filter__c  = false AND Billing_Account__c = \'' + vfIECEBC.billingAccount.Id + '\'';
    }
    
    public List<EBC_Master_Filter__c> getFilters() {
        return (List<EBC_Master_Filter__c>)items; 
    }
    public EBC_Master_Filter__c getSelectedFilter() {
        return (EBC_Master_Filter__c)selectedItem; 
    }
    private Boolean getIsFirstTimeLoadPage() { 
        if (firsttimepageload) {firsttimepageload=false; return true;}
        return false;
    }
    
    
    public override List<SelectOption> getSortByOptions() {
        List<SelectOption> options = new List<SelectOption>();
        /*
        options.add(new SelectOption('CreatedDate DESC ','Sort By', true)); 
        options.add(new SelectOption('CreatedDate DESC','Creation Date'));
        options.add(new SelectOption('LastModifiedDate DESC','Last Edited'));
        options.add(new SelectOption('Name ASC','Name')); 
        options.add(new SelectOption('Audience__c ASC', 'Audience'));
        */

        options.add(new SelectOption('CreatedDate','Sort By', true)); 
        options.add(new SelectOption('Name ASC ','List Name')); 
        options.add(new SelectOption('Audience__c ASC ', 'Audience'));
        options.add(new SelectOption('CreatedDate ASC ','Created Date - Ascending')); 
        options.add(new SelectOption('CreatedDate DESC ','Created Date - Descending')); 
        options.add(new SelectOption('LastModifiedDate ASC ','Last Edited - Ascending')); 
        options.add(new SelectOption('LastModifiedDate DESC ','Last Edited - Descending')); 
      
        return options;
    }
}