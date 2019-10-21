public with sharing class CSP_Utils {

    public class LoginConfig {
        @AuraEnabled
        public String selfRegistrationUrl {get;set;}
    }

    @AuraEnabled
    public static LoginConfig getAuthConfig(){
        Id networkId = Network.getNetworkId();
        Auth.AuthConfiguration authConfig = new Auth.AuthConfiguration(networkId,'');

        LoginConfig config = new LoginConfig();
        config.selfRegistrationUrl = authConfig.getSelfRegistrationUrl();

        return config;
    }    

    /* 
    * @description Indicates whether the current user isn’t logged in to the community.
    * @params
    * @return Boolean
    */    
    @AuraEnabled
    public static Boolean isGuestUser(){
        return Auth.CommunitiesUtil.isGuestUser();
    } 

    public static String toDatetime(Date dte) {
        DateTime dtAndTime = DateTime.newInstanceGmt(dte.year(), dte.month(), dte.day(), 0, 0, 0);

        return dtAndTime.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'');
    }

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
    @AuraEnabled
    public static User getLoggedUser() {
        
        User loggedUser = [SELECT Id, Profile.Name, contactId, Contact.Account.Top_Parent__c, Contact.Account.Category__c, 
                                    Contact.Account.Sector__c, Contact.Account.Parent.Category__c, Contact.Account.Top_Parent__r.Category__c, 
                                    Contact.Account.ParentId, Contact.Account.RecordType.DeveloperName, Contact.Account.Status__c, 
                                    Contact.AccountId, Contact.User_Portal_Status__c, Contact.Account.IATA_ISO_Country__r.ISO_Code__c
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
    * @description Return list of notifications for a specific contact. It needs to pass contact Id to get the respective notifications
    * @params String contactId
    * @return List<Notification__c>
    */
    public static List<Notification__c> getContactNotifications(String contactId) {

        return [SELECT Id 
                FROM Notification__c 
                WHERE Contact__c =: contactId 
                    AND (Number_of_views__c = 0 OR Number_of_views__c = null) 
                    AND Archive__c = false 
                ORDER BY Critical_notification__c DESC, CreatedDate DESC];
    }
    
    /* 
    * @description Return list of portal users to approve. It needs to pass top parent Id to get the respective pending contacts to be approved
    * @params String topParentId
    * @return List<Contact>
    */
    public static List<Contact> getContactsToApprove(String topParentId) {

        return [SELECT Id 
                FROM Contact 
                WHERE (Account.Top_Parent__c =: topParentId OR AccountId =: topParentId) 
                    AND User_Portal_Status__c = 'Pending Approval'];
    }

    /* 
    * @description Return list of portal users to approve. It needs to pass top parent Id to get the respective pending contacts
    * @params String topParentId
    * @return List<Notification__c>
    */
    public static List<Portal_Application_Right__c> getPortalAppRightsToApprove(String topParentId) {

        return [SELECT Id 
                FROM Portal_Application_Right__c 
                WHERE Contact__r.AccountId =: topParentId 
                    AND Right__c = 'Access Requested' 
                    AND Portal_Application__r.Cannot_be_managed_by_portal_admin__c = false];
    }

    /* 
    * @description Return number of notifications for the respective user. It needs to be a string to let the result be 99+ for more than 99
    * @return String
    */
    @AuraEnabled
    public static String getNotificationsCount() {
    
        User loggedUser = [SELECT Id, ContactId , Contact.AccountId, Contact.Account.Top_Parent__c, Contact.User_Portal_Status__c
                           FROM User
                           WHERE Id =: UserInfo.getUserId()];

        //check if the user is a portal user
        if(loggedUser == null || loggedUser.ContactId == null) return null;

        Integer numNotifications = 0;        
        List<Notification__c> notifications = getContactNotifications(loggedUser.ContactId);

        if(!notifications.isEmpty())
            numNotifications += notifications.size();

        //Count also Users and Portal Service Requests to Approve for Admin Users
        if(loggedUser.Contact.User_Portal_Status__c == 'Approved Admin') {

            String topParentId = loggedUser.Contact.Account.Top_Parent__c == null ? loggedUser.Contact.AccountId : loggedUser.Contact.Account.Top_Parent__c;
            
            numNotifications += getContactsToApprove(topParentId).size() + getPortalAppRightsToApprove(topParentId).size();
        }

        return numNotifications > 99 ? '99+' : String.valueOf(numNotifications);
    }

     @AuraEnabled
    public static String redirectToOldPortal(string url) {
        return OneIdUtils.getCommunityRedirection (OneIdUtils.Mode.ISSP, url);
    }

     /* 
    * @description Returns picklist values from a specific fields
    * @return list<PickListWrapper> //wrapper used for picklist values- picklistEntry not available in lightning atm
    */
    @AuraEnabled(cacheable=true)
    public static List<PickListWrapper> getPickListValues(string sobj,string field){
        Map<String,Schema.SOBjectType> gd = Schema.getGlobalDescribe();
        List<PickListWrapper> options = new List<PickListWrapper>();

        // return empty list if object name was not found in the schema
        if (!gd.containsKey(sobj)) return options;

        Schema.DescribeSObjectResult sor = gd.get(sobj).getDescribe();
        Map<String,Schema.SObjectField> sofs = sor.fields.getMap();

        // return empty list if field name was not found in the object's field list
        if (!sofs.containsKey(field)) return options;

        Schema.DescribeFieldResult dfr = sofs.get(field).getDescribe();

        // return empty list if the field type is not picklist
        if (dfr.getType() != Schema.DisplayType.Picklist && dfr.getType() != Schema.DisplayType.MultiPicklist) return options;
        
        for (Schema.PicklistEntry ple : dfr.getPicklistValues()) {
            if (ple.isActive()) {
                PickListWrapper selection = new PickListWrapper();  
                selection.label = ple.getLabel();
                selection.value = ple.getValue();
                selection.checked = false;
                options.add(selection);
            }
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
        user.LocaleSidKey = lang;
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

       //Flag used to know if the new portal (CSPortal) is live or not.
    @AuraEnabled
    public static Boolean CSPortalRedirectExists(){
        ISSP_CS__c issp_cs = ISSP_CS__c.getValues('CS Portal Redirect');
        
        if(issp_cs != null){
            return true;
        }
        return false;
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
        public PickListWrapper (string value,string label){
            this.value=value;
            this.label=label;
        }
    }
    
    @AuraEnabled
    public static Boolean isNewPortalActive() {
        User usr = [SELECT Id, Profile.Name, CNS_Account_or_Agency__c FROM User WHERE Id =: UserInfo.getUserId()];
        return ISSP_CS__c.getValues('CS Portal Redirect') != null && !usr.Profile.Name.toUpperCase().contains('DPC') && !usr.Profile.Name.toUpperCase().contains('PWC') && !usr.CNS_Account_or_Agency__c;
    }

    public static Pagereference redirectToNewPortalPage(String pageName) {
        String host = ISSP_Constant.customSetingMap.get('HostCSP');
        return new Pagereference('https://' + host + pageName);
    }

    @AuraEnabled
    public static String redirectfromPortalHeader(String pageName) {
        String host = ISSP_Constant.customSetingMap.get('HostCSP');
        return 'https://' + host + pageName;
    }

     /* 
    * @description Return if the user is an Airline User
    * @return boolean is airline user
    */
    @AuraEnabled
    public static Boolean isAirlineUser() {
        User loggedUser = getLoggedUser();
        return loggedUser.Profile.Name.contains('Airline');
    }


}
