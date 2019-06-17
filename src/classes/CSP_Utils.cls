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


    /* 
    * @description Return a public URL from a shared file
    * @description The public URL (DistributionPublicUrl) is not ready in the moment it is inserted, so it's been retrieved using a SOQL instead
    * @params String documentName, Id documentId
    * @return String
    */
    @AuraEnabled
    public static ContentDistribution getContentDistribution(String documentName, Id documentId) {
        Datetime dt = Datetime.now();
        List<ContentDistribution> contentInfo = [SELECT ContentDownloadUrl, DistributionPublicUrl FROM ContentDistribution WHERE ContentVersionId = :documentId AND ExpiryDate >= :dt LIMIT 1];
        ContentDistribution contentToInsert;

        if(!contentInfo.isEmpty()) {
            return contentInfo[0];
        } else {
            contentToInsert = new ContentDistribution();
            contentToInsert.Name = documentName;
            contentToInsert.ContentVersionId = documentId;
            contentToInsert.PreferencesExpires = true;
            contentToInsert.ExpiryDate = Datetime.now().addMinutes(10);
            contentToInsert.PreferencesAllowViewInBrowser = true;
            contentToInsert.PreferencesLinkLatestVersion = true;
            contentToInsert.PreferencesAllowPDFDownload = false;
            contentToInsert.PreferencesNotifyOnVisit = false;
            contentToInsert.PreferencesPasswordRequired = false;
            contentToInsert.PreferencesAllowOriginalDownload = true;

            insert contentToInsert; 
        }

        return [SELECT ContentDownloadUrl, DistributionPublicUrl FROM ContentDistribution WHERE Id = :contentToInsert.Id LIMIT 1][0];
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