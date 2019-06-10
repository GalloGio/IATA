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


    @AuraEnabled
    public static List<Contact> getAccountContacts(){
        return DAL_ISSP.getContactsByAccountId(myContact.AccountId);
    }

    @AuraEnabled
    public static List<Account> getCompanyBranches(){
        List<Account> branches = new List<Account>();

        branches = [select id,TradeName__c,Name,BillingCity,Status__c,BillingCountry from account where id =:myContact.AccountId or parentId=:myContact.AccountId or top_parent__c =:myContact.AccountId];

        return branches;
    }


    // OBJECT - FIELD NAME - EDITABLE - VISIBLE - SECTION;
    public static Map<String,List<FieldWrapper>> ContactFields() {
        Map<String,List<FieldWrapper>> wrapperMap = new Map<String,List<FieldWrapper>>();
        wrapperMap.put(LABEL_BASICS,new List<FieldWrapper>());
        wrapperMap.put(LABEL_PERSONAL_CONTACT,new List<FieldWrapper>());
        wrapperMap.put(LABEL_ACCESSIBILITY,new List<FieldWrapper>());
        wrapperMap.put(LABEL_PROFESSIONAL,new List<FieldWrapper>());


        wrapperMap.get(LABEL_BASICS).add(new FieldWrapper('Salutation',true,true));
        wrapperMap.get(LABEL_BASICS).add(new FieldWrapper('Birthdate',true,true));
        wrapperMap.get(LABEL_BASICS).add(new FieldWrapper('FirstName',true,true));
        wrapperMap.get(LABEL_BASICS).add(new FieldWrapper('LastName',true,true));
        wrapperMap.get(LABEL_BASICS).add(new FieldWrapper('Preferred_Language__c',true,true));

        wrapperMap.get(LABEL_PERSONAL_CONTACT).add(new FieldWrapper('Email',false,true));
        wrapperMap.get(LABEL_PERSONAL_CONTACT).add(new FieldWrapper('Phone',true,true));
        wrapperMap.get(LABEL_PERSONAL_CONTACT).add(new FieldWrapper('MobilePhone',true,true));
        wrapperMap.get(LABEL_PERSONAL_CONTACT).add(new FieldWrapper('MailingCountry',true,true));
        wrapperMap.get(LABEL_PERSONAL_CONTACT).add(new FieldWrapper('MailingCity',true,true));
        wrapperMap.get(LABEL_PERSONAL_CONTACT).add(new FieldWrapper('MailingState',true,true));
        wrapperMap.get(LABEL_PERSONAL_CONTACT).add(new FieldWrapper('MailingStreet',true,true));
        wrapperMap.get(LABEL_PERSONAL_CONTACT).add(new FieldWrapper('MailingPostalCode',true,true));

        wrapperMap.get(LABEL_ACCESSIBILITY).add(new FieldWrapper('Status__c',true,true));
        wrapperMap.get(LABEL_ACCESSIBILITY).add(new FieldWrapper('Available_Services_Images__c',false,true));

        wrapperMap.get(LABEL_PROFESSIONAL).add(new FieldWrapper('Area__c',true,true));


        return wrapperMap;
    }

    // OBJECT - FIELD NAME - EDITABLE - VISIBLE - SECTION;
    public static Map<String, List<FieldWrapper>> ContactFieldsAcc() {
        Map<String,List<FieldWrapper>> wrapperMap = new Map<String,List<FieldWrapper>>();
        wrapperMap.put(LABEL_BUSINESS_CONTACT,new List<FieldWrapper>());

        wrapperMap.get(LABEL_BUSINESS_CONTACT).add(new FieldWrapper('Phone_Number__c',true,true));
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
            new FieldWrapper('Preferred_Language__c', false),
            //new FieldWrapper('Membership_Function__c', true),
            new FieldWrapper('Available_Services__c', true)
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
        List<Account> accs = [SELECT Id,Name,Logo_File_ID__c,Website,IATACode__c,Email__c FROM Account WHERE Id=: accountId];
        if(!accs.isEmpty()){
            return accs[0];
        }

        return null;
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
            if(newGen && f.getFieldPath() == 'TradeName__c'){
                editable = false;
            }

            wrapperMap.get(LABEL_BASICS).add(new FieldWrapper(f.getFieldPath(),editable,true));
        }


        for(Schema.FieldSetMember f : contactFields) {
            wrapperMap.get(LABEL_COMPANY_CONTACT).add(new FieldWrapper(f.getFieldPath(),true,true));
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

        public FieldWrapper () {}

        public FieldWrapper (String fieldName, Boolean fullSize) {
            this.fieldName = fieldName;
            this.fullSize = fullSize;
        }

        public FieldWrapper (String fieldName, Boolean editable, Boolean visible){
            this.fieldName = fieldName;
            this.editable = editable;
            this.visible = visible;
        }
        public FieldWrapper (String fieldName, Boolean editable, Boolean visible,String className, String label){
            this.fieldName = fieldName;
            this.editable = editable;
            this.visible = visible;
            this.className = className;
            this.label = label;
        }

    }


    /** Contacts & Branches Sections */

    @AuraEnabled
    public static Map<String,List<FieldWrapper>> getContactsListFields(){
        String rowsFields = 'ROWS'; //Fields to display in columns of a closed accordion/record list
        String viewFields = 'VIEW'; //Fields to display in open accordion section/record detail
        String editFields = 'EDITS'; //Fields to display/edit in record edit modal dialog

        List<String> toView = new List<String>{'AccountId','MailingCountry','Name','MobilePhone','Services__c'};
        List<String> toRow = new List<String>{'LastName','FirstName','Email','Type_of_Contact__c'};
        List<String> toEdit = new List<String>{'FirstName','Email','MobilePhone','BusinessPhone','MailingCountry','LocationCode'};

        Map<String,String> fieldLabels = new Map<String,String>();
        for(String fieldName: toView){
            fieldLabels.put(fieldName,fieldName);
        }
        for(String fieldName: toRow){
            fieldLabels.put(fieldName,fieldName);
        }
        for(String fieldName: toEdit){
            fieldLabels.put(fieldName,fieldName);
        }

        Map<String,List<FieldWrapper>> wrapperMap = new Map<String,List<FieldWrapper>>();

        wrapperMap.put(rowsFields,new List<FieldWrapper>());
        for(String fieldName : toRow){
            wrapperMap.get(rowsFields).add(new FieldWrapper(fieldName,true,true,'underLinded inactive cursorPointer',fieldLabels.get(fieldName)));
        }

        wrapperMap.put(viewFields,new List<FieldWrapper>());
        for(String fieldName : toView){
            wrapperMap.get(viewFields).add(new FieldWrapper(fieldName,true,true));
        }

        wrapperMap.put(editFields,new List<FieldWrapper>());
        for(String fieldName : toEdit){
            wrapperMap.get(editFields).add(new FieldWrapper(fieldName,true,true));
        }

        return wrapperMap;

    }

    @AuraEnabled
    public static Map<String,List<FieldWrapper>> getBranchesListFields(){
        String rowsFields = 'ROWS'; //Fields to display in columns of a closed accordion/record list
        String viewFields = 'VIEW'; //Fields to display in open accordion section/record detail
        String editFields = 'EDITS'; //Fields to display/edit in record edit modal dialog

        String sectionBasic = LABEL_BASICS; //Fields to display in open accordion section/record detail - first section
        String sectionBranchContact = 'Branch Contact'; //Fields to display in open accordion section/record detail + in edit modal dialog

        List<String> toView = new List<String>{'Name','Status__c'};
        List<String> toRow = new List<String>{'TradeName__c','Name','BillingCity','BillingCountry','Status__c'};
        List<String> toEdit = new List<String>{'Name','Status__c'};

        Map<String,List<FieldWrapper>> wrapperMap = new Map<String,List<FieldWrapper>>();

        wrapperMap.put(rowsFields,new List<FieldWrapper>());
        for(String fieldName : toRow){
            wrapperMap.get(rowsFields).add(new FieldWrapper(fieldName,true,true,'underLinded inactive cursorPointer',fieldName));
        }

        wrapperMap.put(viewFields,new List<FieldWrapper>());
        for(String fieldName : toView){
            wrapperMap.get(viewFields).add(new FieldWrapper(fieldName,true,true,'underLinded inactive cursorPointer',fieldName));
        }

        wrapperMap.put(editFields,new List<FieldWrapper>());
        for(String fieldName : toEdit){
            wrapperMap.get(editFields).add(new FieldWrapper(fieldName,true,true,'underLinded inactive cursorPointer',fieldName));
        }

        return wrapperMap;

    }


}