public class GCS_CustomerType implements Comparable{

    public static Map<String,String> customLabels{
        get{
            if(customLabels == null){
                customLabels = new Map<String,String>{
						'Category' => Label.CSP_L2_Category,
						'Sector' => Label.CSP_L2_Sector,
                        'Select' => Label.ISSP_Select,
                        'Other' => Label.ISSP_Other,
                        'Student' => Label.ISSP_Contact_About_IATA_Courses,
                        'Yes' => Label.ISSP_Yes,
                        'No' => Label.ISSP_No,
                        'TSI_USA_Only' => Label.TSI_USA_Only
                };
            }
            return customLabels;
        }
        private set;
    }

    @AuraEnabled
    public GCS_Customer_Type_For_Registration__mdt metadataCustomerType;

    @AuraEnabled
    public String label;

    @AuraEnabled
    public String subCategorizationLabel;

    @AuraEnabled
    public String subCategorizationPlaceholder;

    @AuraEnabled
    public GCS_CustomerType parent;

    @AuraEnabled
    public List<GCS_CustomerType> children;

    private GCS_CustomerType(GCS_Customer_Type_For_Registration__mdt metadataCustomerType){
        this.metadataCustomerType = metadataCustomerType;
        this.label = metadataCustomerType.MasterLabel;
        this.subCategorizationlabel = metadataCustomerType.Sub_Categorization_Custom_Label__c;
        this.subCategorizationPlaceholder = metadataCustomerType.Placeholder_Custom_Label__c;

        children = new List<GCS_CustomerType>();
    }

    private void setParent(GCS_CustomerType parent){
        this.parent = parent;
        if(this.parent != null){
            this.parent.children.add(this);
        }
    }

    public static Map<String,GCS_CustomerType> getCustomerTypesMap(){
        Map<String,GCS_CustomerType> customerTypesMap = new Map<String,GCS_CustomerType>();

        for(GCS_Customer_Type_For_Registration__mdt customerType : [
                SELECT Id, DeveloperName, MasterLabel, Parent__c,
                        Can_Account_Be_Created__c,Display_Submit_for_Account_Creation__c,Created_Account_Category__c,Created_Account_Sector__c,
                        Display_Country__c,Fields_Displayed__c,Fields_Targeted_Partial_Match__c,Fields_Targeted_Exact_Match__c,
                        Filter_on_Category__c,Filter_on_Record_Type__c,Filter_on_Sector__c,
                        Search_Option__c,Sub_Categorization_Custom_Label__c, Placeholder_Custom_Label__c, Type__c
                FROM GCS_Customer_Type_For_Registration__mdt WHERE Is_Active__c = true]){

            customerTypesMap.put(customerType.DeveloperName, new GCS_CustomerType(customerType));
        }

        for(GCS_CustomerType customerType : customerTypesMap.values()){
            if(customerType.metadataCustomerType.Parent__c != null){
                GCS_CustomerType parent = customerTypesMap.get(customerType.metadataCustomerType.Parent__c);
                customerType.setParent(parent);
            }
        }

        Map<String,String> sectors = getSectors();
        Map<String,String> categories = getCategories();

        for(GCS_CustomerType customerType : customerTypesMap.values()){
            customerType.translate(sectors, categories);
        }

        List<GCS_CustomerType> customerTypesList = customerTypesMap.values();
        customerTypesList.sort();

        Map<String,GCS_CustomerType> customerTypesSortedMap = new Map<String,GCS_CustomerType>();
        for(GCS_CustomerType customerType : customerTypesList){
            customerType.children.sort();
            customerTypesSortedMap.put(customerType.metadataCustomerType.DeveloperName, customerType);
        }

        return customerTypesSortedMap;
    }

    public static List<GCS_CustomerType> getCustomerTypesList(){
        Map<String,GCS_CustomerType> customerTypesMap = new Map<String,GCS_CustomerType>();
        Map<String,GCS_CustomerType> customerTypes = new Map<String,GCS_CustomerType>();

        for(GCS_Customer_Type_For_Registration__mdt customerType : [
                SELECT Id, DeveloperName, MasterLabel, Parent__c,
                        Can_Account_Be_Created__c,Display_Submit_for_Account_Creation__c,Created_Account_Category__c,Created_Account_Sector__c,
                        Display_Country__c,Fields_Displayed__c,Fields_Targeted_Partial_Match__c,Fields_Targeted_Exact_Match__c,
                        Filter_on_Category__c,Filter_on_Record_Type__c,Filter_on_Sector__c,
                        Search_Option__c,Sub_Categorization_Custom_Label__c,Placeholder_Custom_Label__c,Type__c
                FROM GCS_Customer_Type_For_Registration__mdt WHERE Is_Active__c = true]){
            customerTypesMap.put(customerType.DeveloperName, new GCS_CustomerType(customerType));
        }

        for(GCS_CustomerType customerType : customerTypesMap.values()){
            if(customerType.metadataCustomerType.Parent__c != null){

                GCS_CustomerType parent = customerTypesMap.get(customerType.metadataCustomerType.Parent__c);
                customerType.setParent(parent);
            }
        }

        for(GCS_CustomerType customerType : customerTypesMap.values()){
            if(customerType.metadataCustomerType.Parent__c != null){
                if(customerType.parent != null && customerType.parent.parent == null && !customerTypes.containsKey(customerType.parent.metadataCustomerType.DeveloperName)){
                    customerTypes.put(customerType.parent.metadataCustomerType.DeveloperName,customerType.parent);
                }
            }
            else if(!customerTypes.containsKey(customerType.metadataCustomerType.DeveloperName)){
                customerTypes.put(customerType.metadataCustomerType.DeveloperName,customerType);
            }
        }
        /* Remove circural reference to parent*/
        for(GCS_CustomerType customerType : customerTypes.values()){
            customerType.parent = null;
            if(customerType.children != null){
                for(GCS_CustomerType customerType1 : customerType.children){
                    customerType1.parent = null;

                    if(customerType1.children != null){
                        for(GCS_CustomerType customerType2 : customerType1.children){
                            customerType2.parent = null;
                        }
                    }
                }
            }
        }

        Map<String,String> sectors = getSectors();
        Map<String,String> categories = getCategories();

        for(GCS_CustomerType customerType : customerTypes.values()){
            customerType.translate(sectors, categories);
        }
        List<GCS_CustomerType> customerTypeList = customerTypes.values();
        
        sortCustomerTypesList(customerTypeList);        

        return customerTypeList;
    }

    private static void sortCustomerTypesList(List<GCS_CustomerType> customerTypeList){
    	customerTypeList.sort();
    	for(GCS_CustomerType customerType : customerTypeList){
    		sortCustomerTypesList(customerType.children);
    	}
    }

    public void translate(Map<String,String> sectors, Map<String,String> categories){
        if(metadataCustomerType.Type__c == 'Sector'){
            String translation = sectors.get(label);
            if(translation != null){
                label = translation;
            }
        }
        else if(metadataCustomerType.Type__c == 'Category'){
            String translation = categories.get(label);
            if(translation != null){
                label = translation;
            }
        }
        else{
            String translation = customLabels.get(label);
            if(translation != null){
                label = translation;
            }
        }

        if(subCategorizationLabel != null && subCategorizationLabel != ''){
            String translation = customLabels.get(subCategorizationLabel);
            if(translation != null){
                subCategorizationLabel = translation;
            }
        }

        if(subCategorizationPlaceholder != null && subCategorizationPlaceholder != ''){
            String translation = customLabels.get(subCategorizationPlaceholder);
            if(translation != null){
                subCategorizationPlaceholder = translation;
            }
        }

        for(GCS_CustomerType child : children){
            child.translate(sectors, categories);
        }
    }

    public static Map<String, String> getSectors(){
        Map<String, String> sectors =  new Map<String, String>();

        for (Schema.PicklistEntry p : Schema.Account.Sector__c.getDescribe().getPickListValues()){
            sectors.put(p.getValue(),p.getLabel());
        }
        return sectors;
    }

    public static Map<String, String> getCategories(){
        Map<String, String> categories =  new Map<String, String>();

        for (Schema.PicklistEntry p : Schema.Account.Category__c.getDescribe().getPickListValues()){
            categories.put(p.getValue(),p.getLabel());
        }
        return categories;
    }

    public integer compareTo(Object compToObj){
        GCS_CustomerType compareToLabel = (GCS_CustomerType)compToObj;

        Integer result = 0;
        if(this.metadataCustomerType.MasterLabel == 'Other'){
            result = 1;
        }
        else if(compareToLabel.metadataCustomerType.MasterLabel == 'Other'){
            result = -1;
        }
        else if (this.label < compareToLabel.label) {
            result = -1;
        } else if (this.label > compareToLabel.label) {
            result = 1;
        }

        return result;
    }
}