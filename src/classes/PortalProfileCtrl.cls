/**
 * This class is used in GCS Portal to retrieve related contact and account information of the currently logged Community User,
 * this information can be seen/edited under CompanyProfile(account info) and MyProfile(contact info) pages in the GCS Portal.
 *
 * To be able to dynamically display different fields for each of the Account (company) RecordTypes, list of fields to be display by lightning base components
 * is generated based on Fieldsets. List of FieldWrappers is returned containg information about fieldName, additional access rules on top of FLS and information about
 * which section of the profile that field belongs to.
 *
 * Fieldsets are not used for Contact fields (MyProfile) as the recordType-based layouts are not required there.
 *
 * User stories: MTSL-257 ; MTSL-258 ; MTSL-259 ; MTSL-289 ; MTSL-290 ; MTSL-291 ; MTSL-293 ; MTSL-294
 */

public with sharing class PortalProfileCtrl {

    PRIVATE STATIC FINAL STRING FIELDSET_AIRLINE = 'GCS_Profile_Airline';
    PRIVATE STATIC FINAL STRING FIELDSET_AGENCY = 'GCS_Profile_Agency';
    PRIVATE STATIC FINAL STRING FIELDSET_GSA = 'GCS_Profile_GSA';
    PRIVATE STATIC FINAL STRING FIELDSET_STANDARD = 'GCS_Profile_Standard';
    PRIVATE STATIC FINAL STRING FIELDSET_OTHERS = 'GCS_Profile_Others';
    PRIVATE STATIC FINAL STRING FIELDSET_CONTACT = 'GCS_CompanyContact';

    PRIVATE STATIC FINAL STRING LABEL_BASICS = System.label.csp_Basics_Section_label;
    PRIVATE STATIC FINAL STRING LABEL_COMPANY_CONTACT = System.label.csp_CompanyContact_Section_label;
    PRIVATE STATIC FINAL STRING LABEL_PERSONAL_CONTACT = System.label.csp_Profile_PersonalContact;
    PRIVATE STATIC FINAL STRING LABEL_BUSINESS_CONTACT = System.label.csp_Profile_BusinessContact;
    PRIVATE STATIC FINAL STRING LABEL_ACCESSIBILITY = System.label.csp_Profile_PortalAccessibility;
    PRIVATE STATIC FINAL STRING LABEL_PROFESSIONAL = System.label.csp_Profile_Professional;


    PRIVATE STATIC FINAL STRING LABEL_FIRST_NAME = System.label.First_name;
    PRIVATE STATIC FINAL STRING LABEL_LAST_NAME = System.label.Last_name;
    PRIVATE STATIC FINAL STRING LABEL_LOCATION_CODE = System.label.ISSP_IATA_Location_Code;
    PRIVATE STATIC FINAL STRING LABEL_CITY = System.label.City;
    PRIVATE STATIC FINAL STRING LABEL_STATUS = System.label.Status;

    PRIVATE STATIC FINAL STRING LABEL_NAME = System.label.ISSP_Local_Groups_Contact_Name;
    PRIVATE STATIC FINAL STRING LABEL_EMAIL = System.label.Email;
    PRIVATE STATIC FINAL STRING LABEL_CONTACT_TYPE = System.label.ISSP_Airline_Contact_Type;
    PRIVATE STATIC FINAL STRING LABEL_LAST_LOGIN = System.label.csp_LastLoginDate;
    PRIVATE STATIC FINAL STRING LABEL_TRADE_NAME = System.label.ISSP_MyProfile_TradeName;
    PRIVATE STATIC FINAL STRING LABEL_ISO_COUNTRY = System.label.Country;


    PRIVATE STATIC FINAL STRING LABEL_INVOICE_CONTACT = System.label.CSP_cpcc_Invoice_Contact;
    PRIVATE STATIC FINAL STRING LABEL_AUTHORISED_SIGNATORY = System.label.CSP_cpcc_Authorised_Signatory;
    PRIVATE STATIC FINAL STRING LABEL_PAYMENT_CONTACT = System.label.CSP_cpcc_BSP_CASS_Payment_Contact;
    PRIVATE STATIC FINAL STRING LABEL_AGENT_CREDIT_RISK = System.label.CSP_cpcc_Agent_Credit_Risk;

    PRIVATE STATIC FINAL INTEGER CONTACT_BATCH= 15;
    PRIVATE STATIC FINAL INTEGER BRANCH_BATCH = 15;

    public static Contact contactInfo = new Contact();

    public static User myUser {
        get {
            if(myUser == null) {
                myUser = DAL_ISSP.getUser(UserInfo.getUserId());
            }
            return myUser;
        }
        set;
    }

    public static Contact myContact{
        get{
            if(myContact == null){
                myContact = DAL_ISSP.getContact(myUser.ContactId);
            }
            return myContact;
        }

        set;
    }

    /**
    * Todo: Implement contact search.
    * With infinite scrolling, search currently only filters records that are already on the client.
    * In the future - filtering, sorting to call backend methods and return data from the DB.
    */
    @AuraEnabled
    public static List<ContactWrapper> searchAccountContacts(String queryString, Integer offset){
        List<Contact> searchResults = DAL_WithoutSharing.searchContactsByAccountId(myContact.AccountId,offset,CONTACT_BATCH,queryString);
        List<ContactWrapper> wrappers = getContactWrappers(searchResults);
        return wrappers;
    }

    @AuraEnabled
    public static List<ContactWrapper> getAccountContacts(){
        return getAccountContacts(0);
    }


    @AuraEnabled
    public static List<ContactWrapper> getAccountContacts(Integer offset){
        List<Contact> contacts = DAL_WithoutSharing.getContactsByAccountId(myContact.AccountId,offset,CONTACT_BATCH);
        List<ContactWrapper> wrappers = getContactWrappers(contacts);
        return wrappers;
    }

    private static List<ContactWrapper> getContactWrappers(List<Contact> contacts){
        List<ContactWrapper> wrappers = new List<ContactWrapper>();
        List<Id> contactIds = new List<Id>();
        List<User> users = new List<User>();
        Map<Id,Contact> contactIdtoContact = new Map<Id,Contact>();

        Map<Id,List<PortalServicesCtrl.ServiceWrapper>> contactToServices = new Map<Id,List<PortalServicesCtrl.ServiceWrapper>>();

        if(!contacts.isEmpty()){
            for(Contact c :contacts){
                contactIds.add(c.Id);
                contactIdtoContact.put(c.Id,c);
            }

            users = DAL_ISSP.getUsersByContactId(contactIds);

            Map<Id,Id> contactToUser = new Map<Id,Id>();
            for(User u :users){
                contactToUser.put(u.ContactId,u.Id);
            }

            contactToServices = PortalServicesCtrl.getContactsAccessGrantedServices(contactToUser);

            ContactWrapper wrapper;
            for(User u :users){
                wrapper = new ContactWrapper();
                wrapper.contact = contactIdtoContact.get(u.ContactId);
                wrapper.contactUser = u;
                wrapper.services = contactToServices.get(u.ContactId);

                wrappers.add(wrapper);
            }

            for(Contact c: contacts){
                if(!contactToUser.containsKey(c.Id)){
                    wrapper = new ContactWrapper();
                    wrapper.contact = c;
                    wrapper.services = new List<PortalServicesCtrl.ServiceWrapper>();
                    wrappers.add(wrapper);
                }
            }
        }



        return wrappers;
    }


    @AuraEnabled
    public static List<Account> searchCompanyBranches(String queryString, Integer offset){
        List<Account> branches = new List<Account>();
        queryString =queryString+'%';

        branches = [select id,TradeName__c,Name,BillingCity,Status__c,BillingCountry,IATA_ISO_Country__r.Name,IATACode__c,BillingAddress,Phone,Fax
        from account
        where (id =:myContact.AccountId or parentId=:myContact.AccountId or top_parent__c =:myContact.AccountId)
        and (TradeName__c LIKE :queryString OR Name LIKE :queryString OR BillingCity LIKE :queryString OR IATACode__c LIKE :queryString)
        and (Status__c NOT IN ('Terminated','Not accredited', 'No longer a customer', 'New application pending'))
        ORDER BY Name ASC LIMIT:BRANCH_BATCH OFFSET :offset
        ];

        return branches;
    }

    @AuraEnabled
    public static List<Account> getCompanyBranches(){
        return getCompanyBranches(0);
    }

    @AuraEnabled
    public static List<Account> getCompanyBranches(Integer offset){
        List<Account> branches = new List<Account>();

        branches = [select id,TradeName__c,Name,BillingCity,Status__c,BillingCountry,IATA_ISO_Country__r.Name,IATACode__c,BillingAddress,Phone,Fax
        from account where (id =:myContact.AccountId or parentId=:myContact.AccountId or top_parent__c =:myContact.AccountId)
        and (Status__c NOT IN ('Terminated','Not accredited', 'No longer a customer', 'New application pending'))
        ORDER BY Name ASC LIMIT:BRANCH_BATCH OFFSET :offset
        ];

        return branches;
    }

    public class ContactWrapper{
        @AuraEnabled
        public Contact contact;

        @AuraEnabled
        public User contactUser;

        @AuraEnabled
        public List<PortalServicesCtrl.ServiceWrapper> services;
    }


    // OBJECT - FIELD NAME - EDITABLE - VISIBLE - SECTION;
    public static Map<String,List<FieldWrapper>> ContactFields() {

        User loggedUser = CSP_Utils.getLoggedUser();
        contactInfo = DAL_ISSP.getContact(loggedUser.contactId);

        FieldWrapper fw;

        Map<String,List<FieldWrapper>> wrapperMap = new Map<String,List<FieldWrapper>>();
        wrapperMap.put(LABEL_BASICS,new List<FieldWrapper>());
        wrapperMap.put(LABEL_PERSONAL_CONTACT,new List<FieldWrapper>());
        wrapperMap.put(LABEL_ACCESSIBILITY,new List<FieldWrapper>());
        wrapperMap.put(LABEL_PROFESSIONAL,new List<FieldWrapper>());

        wrapperMap.get(LABEL_BASICS).add(new FieldWrapper('Name',true,true));
        wrapperMap.get(LABEL_BASICS).add(new FieldWrapper('Birthdate',true,true));
        wrapperMap.get(LABEL_BASICS).add(new FieldWrapper('Title',true,true));
        wrapperMap.get(LABEL_BASICS).add(new FieldWrapper('Preferred_Language__c',true,true));

        wrapperMap.get(LABEL_PERSONAL_CONTACT).add(new FieldWrapper('Email',false,true));

        fw = new FieldWrapper('Phone',true,true);
        fw.isRequired = true;
        wrapperMap.get(LABEL_PERSONAL_CONTACT).add(fw);
        wrapperMap.get(LABEL_PERSONAL_CONTACT).add(new FieldWrapper('MobilePhone',true,true));
        wrapperMap.get(LABEL_PERSONAL_CONTACT).add(new FieldWrapper('MailingCountry',true,true));
        wrapperMap.get(LABEL_PERSONAL_CONTACT).add(new FieldWrapper('MailingCity',true,true));
        wrapperMap.get(LABEL_PERSONAL_CONTACT).add(new FieldWrapper('MailingState',true,true));
        wrapperMap.get(LABEL_PERSONAL_CONTACT).add(new FieldWrapper('MailingStreet',true,true));
        wrapperMap.get(LABEL_PERSONAL_CONTACT).add(new FieldWrapper('MailingPostalCode',true,true));

        wrapperMap.get(LABEL_ACCESSIBILITY).add(new FieldWrapper('User_Portal_Status__c',false,true));
        wrapperMap.get(LABEL_ACCESSIBILITY).add(new FieldWrapper('Authorization',false,true));

        fw = new FieldWrapper('ID_CARD',false,true,true);
        fw.isIdCardInfo = true;
        wrapperMap.get(LABEL_PROFESSIONAL).add(fw);

        fw = new FieldWrapper('Membership_Function__c',false,true,true);
        fw.isJobFunction = true;
        wrapperMap.get(LABEL_PROFESSIONAL).add(fw);

        return wrapperMap;
    }

    // OBJECT - FIELD NAME - EDITABLE - VISIBLE - SECTION;
    public static Map<String, List<FieldWrapper>> ContactFieldsAcc() {
        Map<String,List<FieldWrapper>> wrapperMap = new Map<String,List<FieldWrapper>>();
        wrapperMap.put(LABEL_BUSINESS_CONTACT,new List<FieldWrapper>());

        wrapperMap.get(LABEL_BUSINESS_CONTACT).add(new FieldWrapper('Phone_Number__c',true,true));
        wrapperMap.get(LABEL_BUSINESS_CONTACT).add(new FieldWrapper('Phone',true,true));
        wrapperMap.get(LABEL_BUSINESS_CONTACT).add(new FieldWrapper('Fax',true,true));
        wrapperMap.get(LABEL_BUSINESS_CONTACT).add(new FieldWrapper('BillingCountry',false,true));
        wrapperMap.get(LABEL_BUSINESS_CONTACT).add(new FieldWrapper('BillingState',false,true));
        wrapperMap.get(LABEL_BUSINESS_CONTACT).add(new FieldWrapper('BillingStreet',false,true));
        wrapperMap.get(LABEL_BUSINESS_CONTACT).add(new FieldWrapper('BillingPostalCode',false,true));

        return wrapperMap;
    }

    @AuraEnabled
    public static List<FieldWrapper> getContactFieldsToInsert() {
        return new List<FieldWrapper>{
                new FieldWrapper('FirstName', false),
                new FieldWrapper('LastName', false),
                new FieldWrapper('Email', false),
                new FieldWrapper('MobilePhone', false),
                new FieldWrapper('Phone', false),
                new FieldWrapper('Preferred_Language__c', false)
        };

    }


    public static Map<String,List<FieldWrapper>> AccountFields() { return getFieldsByRecordType();}

    @AuraEnabled
    public static Map<String, List<FieldWrapper>> getFieldsMap (String type){
        // CHECK IF ITS AN ACCOUNT OR CONTACT!!
        Map<String, List<FieldWrapper>> sectionMap = new  Map<String, List<FieldWrapper>>();

        List<String[]> fieldsList = new List<String[]>();
        if ( type == 'MyProfile' ){
            sectionMap = ContactFields();
        } else if (type == 'MyProfileAccFields') {
            sectionMap = ContactFieldsAcc();
        } else {
            sectionMap = AccountFields();
        }

        return sectionMap;
    }



    @AuraEnabled
    public static Account getCompanyInfo(String accountId){
        List<Account> accs = [SELECT Id,Name,Logo_File_ID__c,Website,IATACode__c,Email__c,Status__c FROM Account WHERE Id=: accountId];
        if(!accs.isEmpty()){
            return accs[0];
        }

        return null;
    }

    @AuraEnabled
    public static Boolean canEditBasics(){
        String rType = myContact.Account.RecordType.DeveloperName;
        return rType == 'IATA_Agency';
    }


    /**
    *
    * Returns list of FieldWrapper rows to be.
    * List of account fields to display is determined by record type and a relevant fieldset.
    *
    * Field access should be handled by field-level security, here it can be only more restrictive
    *                   with 'editable' attribute when editable by FL security.
    * */
    private static Map<String,List<FieldWrapper>> getFieldsByRecordType(){
        Map<String,List<FieldWrapper>> wrapperMap = new Map<String,List<FieldWrapper>>();
        wrapperMap.put(LABEL_BASICS,new List<FieldWrapper>());
        wrapperMap.put(LABEL_COMPANY_CONTACT,new List<FieldWrapper>());


        String rType = myContact.Account.RecordType.DeveloperName;
        Boolean newGen = myContact.Account.ANG_IsNewGenAgency__c;
        String legalName = myContact.Account.Legal_name__c;

        String fieldsetBasic;
        if(rType == 'IATA_Airline_BR' || rType == 'IATA_Airline'){fieldsetBasic = FIELDSET_AIRLINE;}
        else if(rType == 'IATA_Agency'){fieldsetBasic = FIELDSET_AGENCY;}
        else if(rType == 'IATA_GSA'){fieldsetBasic = FIELDSET_GSA;}
        else if(rType == 'Others'){fieldsetBasic = FIELDSET_OTHERS;}
        else {fieldsetBasic = FIELDSET_STANDARD;}


        Map<String,Schema.FieldSet> fieldsets =  SObjectType.Account.FieldSets.getMap();
        List<Schema.FieldSetMember>  basicsFields = fieldsets.get(fieldsetBasic).getFields();
        List<Schema.FieldSetMember>  contactFields = fieldsets.get(FIELDSET_CONTACT).getFields();


        for(Schema.FieldSetMember f : basicsFields) {
            Boolean editable = true;
            String fieldName = f.getFieldPath();

            if(fieldName == 'IATACode__c' && (String.isBlank(myContact.Account.Status__c) || myContact.Account.Status__c =='New application pending')){
                continue;
            }

            if((newGen && f.getFieldPath() == 'TradeName__c') || fieldName =='Legal_Name__c' || fieldName =='Sector__c' || fieldName == 'Category__c'){
                editable = false;
            }

            if(f.getFieldPath() == 'Legal_Name__c' && !String.isBlank(legalName) || f.getFieldPath() != 'Legal_Name__c'){
                wrapperMap.get(LABEL_BASICS).add(new FieldWrapper(f.getFieldPath(),editable,true));
            }
        }


        for(Schema.FieldSetMember f : contactFields) {
            Boolean editable = true;
            if(f.getFieldPath().toLowerCase() =='billingcountry' || (f.getFieldPath().toLowerCase().contains('billing') && rType != 'Standard_Account')){
                editable = false;
            }
            wrapperMap.get(LABEL_COMPANY_CONTACT).add(new FieldWrapper(f.getFieldPath(),editable,true));
        }

        return wrapperMap;

    }


    /** FIELD WRAPPER HELPER CLASS */
    public class FieldWrapper{
        @AuraEnabled
        public String fieldName;

        @AuraEnabled
        public Boolean editable;

        @AuraEnabled
        public Boolean visible;

        @AuraEnabled
        public Boolean fullSize;

        @AuraEnabled
        public String className;

        @AuraEnabled
        public String label;

        @AuraEnabled
        public Boolean labeled;

        @AuraEnabled
        public Boolean outputOnly;

        @AuraEnabled
        public Boolean changeUserStatus;

        @AuraEnabled
        public Boolean isAccessibility;

        @AuraEnabled
        public Boolean isJobFunction;

        @AuraEnabled
        public Boolean isIdCardInfo;

        @AuraEnabled
        public Boolean isContactServices;

        @AuraEnabled
        public Boolean isRequired;

        @AuraEnabled
        public List<accessibilityWrapper> accessibilityList;

        public FieldWrapper (String fieldName, Boolean fullSize) {
            this.fieldName = fieldName;
            this.fullSize = fullSize;
            this.labeled = false;
        }

        public FieldWrapper (String fieldName, Boolean editable, Boolean visible,Boolean output){
            this.fieldName = fieldName;
            this.editable = editable;
            this.visible = visible;
            this.outputOnly = output;
            this.labeled = false;

            if (fieldName == 'User_Portal_Status__c') {
                this.changeUserStatus = true;
            } else {
                this.changeUserStatus = false;
            }
        }

        public FieldWrapper (String fieldName, Boolean editable, Boolean visible){
            this.fieldName = fieldName;
            this.editable = editable;
            this.visible = visible;
            this.labeled = false;
            this.isAccessibility = (fieldName == 'Authorization' ? true : false);
            if (fieldName == 'Authorization') {
                this.accessibilityList = new List<accessibilityWrapper>{
                        new accessibilityWrapper(false, LABEL_INVOICE_CONTACT, 'Invoicing_Contact__c'),
                        new accessibilityWrapper(false, LABEL_AUTHORISED_SIGNATORY, 'Authorized_Signatory__c'),
                        new accessibilityWrapper(false, LABEL_PAYMENT_CONTACT, 'BSP_CASS_Payment_contact__c')
                };
                
                if ( myUser.profile.Name.touppercase().contains('AIRLINE') ) {
                    this.accessibilityList.add(new accessibilityWrapper(false, LABEL_AGENT_CREDIT_RISK, 'Airline_Credit_Risk_Manager__c'));
                }
            }

            if (fieldName == 'User_Portal_Status__c') {
                this.changeUserStatus = true;
            } else {
                this.changeUserStatus = false;
            }

            this.isContactServices = fieldName == 'ContactServices' ? true : false;

        }
        public FieldWrapper (String fieldName, Boolean editable, Boolean visible,String className, String label){
            this.fieldName = fieldName;
            this.editable = editable;
            this.visible = visible;
            this.className = className;
            this.label = label;

            if(!String.isEmpty(label)){
                this.labeled = true;
            }else{
                this.labeled = false;
            }
        }

    }

    /* checked: false, label: this.labels.Portal_Administrator, APINAME: "PortalAdmin" */

    public class accessibilityWrapper{

        @AuraEnabled
        public Boolean checked;

        @AuraEnabled
        public String label;

        @AuraEnabled
        public String APINAME;

        public accessibilityWrapper (Boolean checked, String label, String APINAME){
            this.checked = (Boolean) contactInfo.get(APINAME);
            this.label = label;
            this.APINAME = APINAME;
        }
    }


    /** Contacts & Branches Sections */

    @AuraEnabled
    public static Map<String,List<FieldWrapper>> getContactsListFields(){

        String rType = myContact.Account.RecordType.DeveloperName;

        String rowsFields = 'ROWS'; //Fields to display in columns of a closed accordion/record list
        String viewFields = 'VIEW'; //Fields to display in open accordion section/record detail
        String editFields = 'EDITS'; //Fields to display/edit in record edit modal dialog


        List<String> toRow = new List<String>{'Name','Email','Type_of_Contact__c','LocationCode','LastLogin'};
        Map<String,String> fieldLabels = new Map<String,String>();

        FieldWrapper fw;

        fieldLabels.put('FirstName',LABEL_FIRST_NAME);
        fieldLabels.put('LastName',LABEL_LAST_NAME);
        fieldLabels.put('Email',LABEL_EMAIL);
        fieldLabels.put('Type_of_Contact__c',LABEL_CONTACT_TYPE);
        fieldLabels.put('Name',LABEL_NAME);
        fieldLabels.put('LocationCode',LABEL_LOCATION_CODE);
        fieldLabels.put('LastLogin',LABEL_LAST_LOGIN);

        for(String fieldName: toRow){
            if(!fieldLabels.containsKey(fieldName)){ fieldLabels.put(fieldName,fieldName);}
        }


        Map<String,List<FieldWrapper>> wrapperMap = new Map<String,List<FieldWrapper>>();

        wrapperMap.put(rowsFields,new List<FieldWrapper>());
        for(String fieldName : toRow){
            wrapperMap.get(rowsFields).add(new FieldWrapper(fieldName,true,true,'underLinded inactive cursorPointer',fieldLabels.get(fieldName)));
        }

        wrapperMap.put(viewFields,new List<FieldWrapper>());
        wrapperMap.put(editFields,new List<FieldWrapper>());

        //VIEW
        wrapperMap.get(viewFields).add(new FieldWrapper('ISSP_Account_Name__c',true,true,true));
        wrapperMap.get(viewFields).add(new FieldWrapper('MobilePhone',true,true));
        wrapperMap.get(viewFields).add(new FieldWrapper('Phone',true,true));
        wrapperMap.get(viewFields).add(new FieldWrapper('User_Portal_Status__c',false,true,true));

        fw = new FieldWrapper('Membership_Function__c',false,true,true);
        fw.isJobFunction = true;
        wrapperMap.get(viewFields).add(fw);
        wrapperMap.get(viewFields).add(new FieldWrapper('ContactServices',false,true));

        //For Airlines & agencies only
        if((rType == 'IATA_Airline_BR' || rType == 'IATA_Airline') || rType == 'IATA_Agency') {
            wrapperMap.get(viewFields).add(new FieldWrapper('BSP_CASS_Payment_contact__c', true, true));
            wrapperMap.get(viewFields).add(new FieldWrapper('Invoicing_Contact__c', true, true));
        }

        wrapperMap.get(viewFields).add(new FieldWrapper('Authorized_Signatory__c',true,true));

        //EDIT
        wrapperMap.get(editFields).add(new FieldWrapper('ISSP_Account_Name__c',true,true,true));
        //wrapperMap.get(editFields).add(new FieldWrapper('Salutation',true,true)); - Salesforce bug, salutation picklist not loading values
        //wrapperMap.get(editFields).add(new FieldWrapper('ISO_Country__c',true,true,true));
        wrapperMap.get(editFields).add(new FieldWrapper('FirstName',true,true));
        wrapperMap.get(editFields).add(new FieldWrapper('LastName',true,true));
        wrapperMap.get(editFields).add(new FieldWrapper('Title',true,true));
        wrapperMap.get(editFields).add(new FieldWrapper('Email',false,true));
        wrapperMap.get(editFields).add(new FieldWrapper('MobilePhone',true,true));
        fw = new FieldWrapper('Phone',true,true);
        fw.isRequired = true;
        wrapperMap.get(editFields).add(fw);

        //For Airlines & agencies only
        if((rType == 'IATA_Airline_BR' || rType == 'IATA_Airline') || rType == 'IATA_Agency') {
            wrapperMap.get(editFields).add(new FieldWrapper('BSP_CASS_Payment_contact__c', true, true));
            wrapperMap.get(editFields).add(new FieldWrapper('Invoicing_Contact__c', true, true));
        }

        wrapperMap.get(editFields).add(new FieldWrapper('Authorized_Signatory__c',true,true));

        //Airline only
        if(rType == 'IATA_Airline_BR' || rType == 'IATA_Airline'){
            wrapperMap.get(editFields).add(new FieldWrapper('Airline_Credit_Risk_Manager__c',true,true));
        }

        return wrapperMap;

    }

    @AuraEnabled
    public static Map<String,List<FieldWrapper>> getBranchesListFields(){
        String rowsFields = 'ROWS'; //Fields to display in columns of a closed accordion/record list
        String viewFields = 'VIEW'; //Fields to display in open accordion section/record detail
        String editFields = 'EDITS'; //Fields to display/edit in record edit modal dialog

        String sectionBasic = LABEL_BASICS; //Fields to display in open accordion section/record detail - first section
        String sectionBranchContact = 'BranchContact'; //Fields to display in open accordion section/record detail + in edit modal dialog

        String rType = myContact.Account.RecordType.DeveloperName;

        List<String> toView = new List<String>{'Name','Status__c'};
        List<String> toRow = new List<String>{'TradeName__c','LocationCode','IsoCountry','BillingCity','Status__c'};
        List<String> toEdit = new List<String>{'Name','Status__c'};

        Map<String,List<FieldWrapper>> wrapperMap = new Map<String,List<FieldWrapper>>();
        Map<String,String> fieldLabels = new Map<String,String>();


        wrapperMap.put(rowsFields,new List<FieldWrapper>());
        wrapperMap.put(viewFields,new List<FieldWrapper>());
        wrapperMap.put(editFields,new List<FieldWrapper>());


        wrapperMap.put(sectionBranchContact,new List<FieldWrapper>());
        wrapperMap.put(sectionBasic,new List<FieldWrapper>());

        fieldLabels.put('Name',LABEL_NAME);
        fieldLabels.put('TradeName__c',LABEL_TRADE_NAME);
        fieldLabels.put('LocationCode',LABEL_LOCATION_CODE);
        fieldLabels.put('IsoCountry',LABEL_ISO_COUNTRY);
        fieldLabels.put('BillingCity',LABEL_CITY);
        fieldLabels.put('Status__c',LABEL_STATUS);


        for(String fieldName: toView){
            if(!fieldLabels.containsKey(fieldName)){
                fieldLabels.put(fieldName,fieldName);}
        }
        for(String fieldName: toRow){
            if(!fieldLabels.containsKey(fieldName)){
                fieldLabels.put(fieldName,fieldName);}
        }
        for(String fieldName: toEdit){
            if(!fieldLabels.containsKey(fieldName)){
                fieldLabels.put(fieldName,fieldName);}
        }


        wrapperMap.get(sectionBasic).add(new FieldWrapper('Legal_name__c',false,true));
        wrapperMap.get(sectionBasic).add(new FieldWrapper('Sector__c',false,true));
        wrapperMap.get(sectionBasic).add(new FieldWrapper('Category__c',false,true));
        wrapperMap.get(sectionBasic).add(new FieldWrapper('Location_Type__c',false,true));

        wrapperMap.get(sectionBranchContact).add(new FieldWrapper('Email__c',true,true));
        wrapperMap.get(sectionBranchContact).add(new FieldWrapper('Website',true,true));
        wrapperMap.get(sectionBranchContact).add(new FieldWrapper('Phone',true,true));
        wrapperMap.get(sectionBranchContact).add(new FieldWrapper('Fax',true,true));

        wrapperMap.get(sectionBranchContact).add(new FieldWrapper('BillingState',(rType == 'Standard_Account'),true));
        wrapperMap.get(sectionBranchContact).add(new FieldWrapper('BillingStreet',(rType == 'Standard_Account'),true));
        wrapperMap.get(sectionBranchContact).add(new FieldWrapper('BillingPostalCode',(rType == 'Standard_Account'),true));
        wrapperMap.get(sectionBranchContact).add(new FieldWrapper('BillingCountry',false,true));

        for(String fieldName : toRow){
            wrapperMap.get(rowsFields).add(new FieldWrapper(fieldName,true,true,'underLinded inactive cursorPointer',fieldLabels.get(fieldName)));
        }


        wrapperMap.put(viewFields,new List<FieldWrapper>());
        for(String fieldName : toView){
            wrapperMap.get(viewFields).add(new FieldWrapper(fieldName,true,true,'underLinded inactive cursorPointer',fieldLabels.get(fieldName)));
        }

        wrapperMap.put(editFields,new List<FieldWrapper>());
        for(String fieldName : toEdit){
            wrapperMap.get(editFields).add(new FieldWrapper(fieldName,true,true,'underLinded inactive cursorPointer',fieldLabels.get(fieldName)));
        }

        return wrapperMap;
    }

    @AuraEnabled
    public static Boolean checkCanEdit(){
        User loggedUser = CSP_Utils.getLoggedUser();
        if (loggedUser.Contact.User_Portal_Status__c == 'Approved Admin') {
            if (!loggedUser.Profile.Name.contains('Airline') ) {
                return true;
            } else {
                return false;
            }
        } else {
            return false;
        }
 
    }

}