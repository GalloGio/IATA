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


    //* Retrieves available lanaguages for the community*/
    @AuraEnabled
    public static List<PickListWrapper> getCommunityAvailableLanguages(string sobj,string field){
        List<PickListWrapper> options = new List<PickListWrapper>();

        Map<String,String> langMap = new Map<String,String>();

        for(Preferred_Language_on_ISS_Portal__c l : Preferred_Language_on_ISS_Portal__c.getAll().values())
            langMap.put(l.Language__c,l.languageLocalKey__c);

        List<String> auxList = new List<String>(langMap.keySet());
        auxList.sort();

        for(String key :auxList)
            options.add(new PickListWrapper(langMap.get(key), key));

        return options;
    }


    // sets new language
    @AuraEnabled
    public static void changeUserLanguage(string lang){
        List<Preferred_Language_on_ISS_Portal__c> pLangcs = Preferred_Language_on_ISS_Portal__c.getall().values();

        User user = [select Id,ContactId from User where Id=:Userinfo.getUserId()];
        user.LanguageLocaleKey = lang;
        update user;

        List<Contact> contacts = [select Id,Preferred_Language__c  from Contact where Id=:user.ContactId];
        if (!contacts.isEmpty()){
            
            Contact con = contacts[0];

            if(pLangcs!= null || !pLangcs.isEmpty()){
                for(Preferred_Language_on_ISS_Portal__c language : pLangcs){
                    if(language.languageLocalKey__c == lang){
                        con.Preferred_Language__c = language.Language__c;
                    }
                }
                update con;
            }
        }

       
       /* Pagereference pr = new Pagereference(retURL);
        pr.setCookies(new Cookie[]{new Cookie('lang',lang,null,100000000,false)});*/
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