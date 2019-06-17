public without sharing class CSP_Utils {

    /* 
    * @description Return field labels. It needs to pass the sObject and the necessary fields to retrieve
    * @params String sObjectType, List<String> sObjectFields
    * @return Map<String,String>
    */
    @AuraEnabled(cacheable=true)
    public static Map<String, String> getSelectedColumns(String sObjectType, List<String> sObjectFields) {
        Map<String, String> allFieldsLabel = new Map<String, String>();
        
        Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
        Map<String, Schema.SObjectField> fieldMap = schemaMap.get(sObjectType).getDescribe().fields.getMap();

        for(String fields : sObjectFields) {
            String fieldName = fieldMap.get(fields).getDescribe().getName();
            String fieldLabel = fieldMap.get(fields).getDescribe().getLabel();

            if(sObjectFields.contains(fieldName)) {
                allFieldsLabel.put(fieldName, fieldLabel);
            }
        }

        return allFieldsLabel;
    }

    /* 
    * @description Get Logged User.
    * @return User
    */
    public static User getLoggedUser() {
        
        User loggedUser = [SELECT Id, contactId, Contact.Account.Top_Parent__c, Contact.AccountId, Contact.User_Portal_Status__c
                           FROM User
                           WHERE Id =: UserInfo.getUserId()];
        
        return loggedUser;
    }

    /* 
    * @description Return the type of the User.
    * @return String User Portal Status
    */
    @AuraEnabled
    public static Boolean isAdmin() {
        User loggedUser = getLoggedUser();
        return loggedUser.Contact.User_Portal_Status__c == 'Approved Admin';
    }

     /* 
     @AuraEnabled
    public static String redirectToOldPortal(string url) {
        return OneIdUtils.getCommunityRedirection (OneIdUtils.Mode.ISSP, url);
    }

     /* 
    * @description Returns picklist values from a specific fields
    * @return list<PickListWrapper> //wrapper used for picklist values- picklistEntry not available in lightning atm
    */
    @AuraEnabled
    public static List<PickListWrapper> getPickListValues(string sobj,string field){
        Schema.DescribeSObjectResult sobjectDescribe = Schema.getGlobalDescribe().get(sobj).getDescribe();
        List<Schema.PicklistEntry> pickListValues = sobjectDescribe.fields.getMap().get(field).getDescribe().getPickListValues();
        
        List<PickListWrapper> options = new List<PickListWrapper>();
        
        PickListWrapper emptySelection = new PickListWrapper(); 
        
        for (Schema.PicklistEntry a : pickListValues) {
            PickListWrapper selection = new PickListWrapper();  
            selection.label = a.getLabel();
            selection.value = a.getValue();
            selection.checked = false;
            options.add(selection);
        }
        return options;
    }

    @AuraEnabled(cacheable=true)
    public static String randomUUID() {
        String kHexChars = '0123456789abcdefABCDEF';
        String returnValue = '';
        Integer nextByte = 0;
        for(Integer i = 0; i < 16; i++){
            if(i==4 || i==6 || i==8 || i==10){
                returnValue += '-';
            }
            //generate a "byte"; i.e., number in range [-2^7,2^7-1]
            nextByte = (Math.round(Math.random() * 255)-128) & 255;

            if(i==6){
                nextByte = nextByte & 15;
                nextByte = nextByte | (4 << 4);
            }
            if(i==8){
                nextByte = nextByte & 63;
                nextByte = nextByte | 128;
            }

            returnValue += charAt(kHexChars,nextByte >> 4);
            returnValue += charAt(kHexChars,nextByte & 15);
        }
        return returnValue;
    }

    private static String charAt(String str, Integer index) {
        if(str == null){
            return null;
        }
        if(str.length() <= 0){
            return str;
        }
        if(index < 0 || index >= str.length()){
            return null;
        }
        return str.substring(index, index+1);
    }

    /*============================== Sidekick classes ==============*/

    // class side class used to wrap picklist values/
    public class PickListWrapper{
        @AuraEnabled
        public String label;
        @AuraEnabled
        public String value;
        @AuraEnabled
        public Boolean checked;
        
        public PickListWrapper (){

        }
    }
    


}