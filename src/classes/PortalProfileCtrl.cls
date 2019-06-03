/**
 * Created by pvavruska on 5/24/2019.
 */

public with sharing class PortalProfileCtrl {

    PRIVATE STATIC FINAL STRING PORTAL_ADMIN;
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


    // OBJECT - FIELD NAME - EDITABLE - VISIBLE - SECTION;
    public static List<String[]> ContactFields() {
        return new List<String[]>{
                new String[]{'true', 'Salutation', 'true', 'true', LABEL_BASICS},
                new String[]{'true', 'Birthdate', 'true', 'true', LABEL_BASICS},
                new String[]{'true', 'FirstName', 'true', 'true', LABEL_BASICS},
                new String[]{'true', 'LastName', 'true', 'true', LABEL_BASICS},
                new String[]{'true', 'Preferred_Language__c', 'true', 'true', LABEL_BASICS},

                new String[]{'true', 'Email', 'true', 'true', LABEL_PERSONAL_CONTACT},
                new String[]{'true', 'Phone', 'true', 'true', LABEL_PERSONAL_CONTACT},
                new String[]{'true', 'MobilePhone', 'true', 'true', LABEL_PERSONAL_CONTACT},
                new String[]{'true', 'MailingCountry', 'true', 'true', LABEL_PERSONAL_CONTACT},
                new String[]{'true', 'MailingCity', 'true', 'true', LABEL_PERSONAL_CONTACT},
                new String[]{'true', 'MailingState', 'true', 'true', LABEL_PERSONAL_CONTACT},
                new String[]{'true', 'MailingStreet', 'true', 'true', LABEL_PERSONAL_CONTACT},
                new String[]{'true', 'MailingPostalCode', 'true', 'true', LABEL_PERSONAL_CONTACT},

                new String[]{'true', 'Status__c', 'true', 'true', LABEL_ACCESSIBILITY},
                //new String[]{'Authorisation', 'false', 'true', LABEL_ACCESSIBILITY},
                new String[]{'true', 'Available_Services_Images__c', 'false', 'true', LABEL_ACCESSIBILITY},

                new String[]{'false', 'Phone_Number__c', 'true', 'true', LABEL_BUSINESS_CONTACT},
                new String[]{'false', 'Fax', 'true', 'true', LABEL_BUSINESS_CONTACT},
                new String[]{'false', 'BillingCountry', 'false', 'true', LABEL_BUSINESS_CONTACT},
                new String[]{'false', 'BillingState', 'false', 'true', LABEL_BUSINESS_CONTACT},
                new String[]{'false', 'BillingCity', 'false', 'true', LABEL_BUSINESS_CONTACT},
                new String[]{'false', 'BillingStreet', 'false', 'true', LABEL_BUSINESS_CONTACT},
                new String[]{'false', 'BillingPostalCode', 'false', 'true', LABEL_BUSINESS_CONTACT},
                 
                //new String[]{'Working Areas', 'false', 'true', LABEL_PROFESSIONAL},
                new String[]{'true', 'Area__c', 'true', 'true', LABEL_PROFESSIONAL}
                //new String[]{'Languages', 'false', 'true', LABEL_PROFESSIONAL}

        };
    }

    public static List<String[]> AccountFields() { return getFieldsByRecordType();}

    public static User myUser {
        get {
            if(myUser == null) {
                myUser = [
                        SELECT Id, AccountId, ContactId, Contact.AccountId, Contact.Financial_Assessment_Contact__c, Profile_Name__c,Contact.Account.RecordType.DeveloperName,Contact.Account.ANG_IsNewGenAgency__c
                        FROM User
                        WHERE Id = :UserInfo.getUserId()
                ];
            }
            return myUser;
        }
        set;
    }

    @AuraEnabled
    public static Map<String, List<FieldWrapper>> getFieldsMap (String type){
        // CHECK IF ITS AN ACCOUNT OR CONTACT!!

        List<String[]> fieldsList = new List<String[]>();
        if ( type == 'MyProfile' ){
            fieldsList = ContactFields();
        } else {
            fieldsList = AccountFields();
        }

        Map<String, List<FieldWrapper>> sectionMap = new  Map<String, List<FieldWrapper>>();

        List<FieldWrapper> listWrapper = new List<FieldWrapper>();
        for (String[] fieldInfo : fieldsList ) {
            if ( !sectionMap.containsKey(fieldInfo[4]) ){
                sectionMap.put(fieldInfo[4], new List<FieldWrapper>());
            }
            listWrapper = sectionMap.get(fieldInfo[4]);
            //                                     IS Contact  -   FIELD NAME  -  EDITABLE  -  VISIBLE
            FieldWrapper field = new FieldWrapper(fieldInfo[0], fieldInfo[1], fieldInfo[2], fieldInfo[3]);
            listWrapper.add(field);
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
    private static List<String[]> getFieldsByRecordType(){
        List<String[]> fieldNames = new List<String[]>();
        String fieldsetBasic;

        String rType = myUser.Contact.Account.RecordType.DeveloperName;
        Boolean newGen = myUser.Contact.Account.ANG_IsNewGenAgency__c;


        if(rType == 'IATA_Airline_BR' || rType == 'IATA_Airline'){fieldsetBasic = FIELDSET_AIRLINE;}
        else if(rType == 'IATA_Agency'){fieldsetBasic = FIELDSET_AGENCY;}
        else if(rType == 'IATA_GSA'){fieldsetBasic = FIELDSET_GSA;}
        else if(rType == 'Others'){fieldsetBasic = FIELDSET_OTHERS;}
        else {fieldsetBasic = FIELDSET_STANDARD;}


        Map<String,Schema.FieldSet> fieldsets =  SObjectType.Account.FieldSets.getMap();
        List<Schema.FieldSetMember>  basicsFields = fieldsets.get(fieldsetBasic).getFields();
        List<Schema.FieldSetMember>  contactFields = fieldsets.get(FIELDSET_CONTACT).getFields();

        for(Schema.FieldSetMember f : basicsFields) {
            String editable = 'true';
            if(newGen && f.getFieldPath() == 'TradeName__c'){
                editable = 'false';
            }
            fieldNames.add(new String[]{'false', f.getFieldPath(), editable, 'true', LABEL_BASICS});
        }

        for(Schema.FieldSetMember f : contactFields) {
            fieldNames.add(new String[]{'false', f.getFieldPath(), 'true', 'true', LABEL_COMPANY_CONTACT});
        }

        return fieldNames;

    }


    /** FIELD WRAPPER HELPER CLASS */
    public class FieldWrapper{
        @AuraEnabled
        public Boolean isContact;

        @AuraEnabled
        public String fieldName;

        @AuraEnabled
        public Boolean editable;

        @AuraEnabled
        public Boolean visible;

        public FieldWrapper () {}

        public FieldWrapper (String isContact, String fieldName, String editable, String visible){
            this.isContact =(isContact == 'true' ? true : false );
            this.fieldName = fieldName;
            this.editable = (editable == 'true' ? true : false );
            this.visible = (visible == 'true' ? true : false );
        }

    }

}