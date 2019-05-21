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
        
        User loggedUser = [SELECT Id, Contact.User_Portal_Status__c
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

}