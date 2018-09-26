/**
    This class is only used to set a dependency of a custom field with an integration where the field is no explicitly exposed (ex. integration via data loader)
    The aim is that you receive a warning when you try to delete such filed which will redirect you to this class which besides creating the dependency also contains the information about the integration where this field is being used. 
    If you need to remove one of these fields, please make sure that you get the approval from the business process owner related to the integration using this field. 
**/

/**
    All the fields listed below are related to SAP Business Objects Platform and SalesForce Integration
    Mechanism used to extract data out of SalesForce and load it into IATA’s Business Intelligence Data Warehouse system using SAP Data Services. 
**/



@isTest
public class TestDependencies {


    public static testMethod void testAccountFields() {
        list<Account> lst  = [
            Select Id,
            Name,
            AIMS_ID__c,
            Fin_statements_submission_deadline__c,
            Identify_as_Key_Customer__c,
            CCG_IRR_Distribution_list__c,
            CreatedDate,
            LastModifiedDate,
            IATACode__c
            From Account
        ];
    }

    public static testMethod void testCaseIfapFields() {
        list<Case> lst  = [
            Select AccountId,
            AIMS_status__c,
            Assessment_Performed_Date__c,
            CaseNumber,            
            Deadline_Date__c,
            FA_Second_Deadline_Date__c,
            FA_Third_Deadline_Date__c,
            Financial_Review_Result__c,
            Financial_Review_Type__c,
            firstFAnonComplianceDate__c,
            firstFSnonComplianceDate__c,
            FS_Deadline_Date__c,
            FS_Second_Deadline_Date__c,
            FS_Submitted_Date__c,
            Id,
            IFAP_Agent_Type__c,
            IFAP_Financial_Year__c,
            Quality_Issue_performed_on__c,
            Quality_Issue_Raised_on__c,
            Quality_Issue_Rejected_by_RPM_on__c,
            Quality_Issue_Approved_by_RPM_On__c,
            Sanity_Check_Failure_Date__c,
            secondFAnonComplianceDate__c,
            secondFSnonComplianceDate__c,
            Status,
            IFAP_Country_ISO__c,
            Third_FA_non_Compliance_Date__c,
            ISS_participant_informed__c,
            Submitted_Date__c,
            CreatedDate,
            Quality_Issue_rejected_on__c
            From Case
        ];
    }
    
    public static testMethod void testCaseSidraFields() {
        list<Case> lst  = [
            Select CaseNumber,
            Id,
            AccountId,
            ContactId,
            AssetId,
            ParentId,
            SuppliedName,
            SuppliedEmail,
            SuppliedPhone,
            SuppliedCompany,
            Type,
            RecordTypeId,
            Status,
            Reason,
            Origin,
            BSP_CASS__c,
            Confirmation_moneys_not_received__c,
            Currency__c,
            CreatedDate,
            LASTMODIFIEDDATE,
            End_of_Grace_Period_Date__c,
            IATA_Charges__c,
            IATA_Code__c,
            Outstanding_Amount__c,
            Reason_for_Default__c,
            Remittance_Date__c,
            Recovered_Amount__c,
            Remittance_Period__c,
            Short_Payment_Amount__c,
            Short_Payment_Date__c,
            Status_SIDRA__c,
            Update_AIMS_DEF__c,
            Update_AIMS_IRR__c,
            Update_AIMS_IRRWITH__c,
            Update_AIMS_REI_DEFWITH__c,
            Update_AIMS_TER__c,
            TOTAL_DEFAULTED_AMOUNT__C,
            DEFAULTED_AMOUNT__C,
            CURRENT_OUTSTANDING_AMOUNT_ALL_PERIODS__C,
            COLLECTED_AMOUNT_ALL_PERIODS__C,
            SUBSEQUENT_SALES__C,
            RECOVERED_AFTER_DEFAULT__C,
            PAID_BACK_AMOUNT__C,
            PRO_RATED_AMOUNT__C
            From Case
        ];
    }
    

    public static testMethod void testSIDRADefaultDetailsFields() {
        list<SIDRA_eDefault__c> lst  = [
            Select ACCOUNT__C,
            CONNECTIONRECEIVEDID,
            CONNECTIONSENTID,
            CREATEDBYID,
            CREATEDDATE,
            CURRENCY__C,
            CURRENCY_EXCHANGE_RATE__C,
            CURRENCYISOCODE,
            DATE_OF_MOVEMENT__C,
            DEFAULT_DATE__C,
            DEFAULT_RECORD_CODE__C,
            DEFAULTED_AMOUNT__C,
            DEFAULTED_AMOUNT_USD__C,
            ID,
            ISDELETED,
            LASTMODIFIEDBYID,
            LASTMODIFIEDDATE,
            NAME,
            OWNERID,
            PRORATED_AMOUNT__C,
            RECORDTYPEID,
            RECOVERED_AMOUNT__C,
            RECOVERED_AMOUNT_USD__C,
            SIDRA_CASE__C,
            SYSTEMMODSTAMP,
            TYPE__C
            From SIDRA_eDefault__c
        ];
    }
    
    public static testMethod void testIFAPQualityIssueFields() {
        list<IFAP_Quality_Issue__c> lst  = [
            Select Id,
            OwnerId,
            IsDeleted,
            Name,
            CurrencyIsoCode,
            CreatedDate,
            CreatedById,
            LastModifiedDate,
            LastModifiedById,
            SystemModstamp,
            ConnectionReceivedId,
            ConnectionSentId,
            Assessment_using_wrong_template__c,
            Challenge_Source__c,
            Financials_not_audited_certified__c,
            Formatting_Issue_details__c,
            Incorrect_sales_used_for_the_assessment__c,
            Incorrect_sanity_check_failure__c,
            Missing_value_in_fields__c,
            Need_to_update_the_template_instructions__c,
            Other_Issue_details__c,
            Other__c,
            Output_is_empty_not_completed_has_errors__c,
            Parent_company_accounts_not_reviewed__c,
            Reassessment_Rejection_Reason__c,
            Related_Case__c,
            Template_working_properly__c,
            The_printout_of_the_result_is_unreadable__c,
            Wrong_figure_was_extracted__c,
            Wrong_financial_year__c,
            Status__c,
            Approved_Date__c
            From IFAP_Quality_Issue__c
        ];
    }
    
    public static testMethod void testFinancialSecurityFields() {
        list<Financial_Security__c> lst  = [
            Select Id,
            IsDeleted,
            Name,
            CurrencyIsoCode,
            CreatedDate,
            CreatedById,
            LastModifiedDate,
            LastModifiedById,
            SystemModstamp,
            LastActivityDate,
            ConnectionReceivedId,
            ConnectionSentId,
            Account__c,
            Account_Country__c,
            Amount__c,
            Days_to_Expiry_date__c,
            Encashment_Date__c,
            Expiry_Date__c,
            External_Security_ID__c,
            Financial_Institution__c,
            IATA_code__c,
            Last_updated_by_source__c,
            Minimumrelease__c,
            Reasonforrequest__c,
            Reception_Case__c,
            Reception_Date__c,
            Region__c,
            Release_Case__c,
            Release_Date__c,
            Release_Reason__c,
            Remarks__c,
            Security_Status__c,
            Security_Type__c,
            Source__c,
            Status_image__c,
            Unlimited_Security__c,
            Validity_Start_Date__c,
            First_Call_Letter_required__c
            From Financial_Security__c
        ];
    }
    
    public static testMethod void testPortalServiceAccessFields() {
        list<Portal_Application_Right__c> lst  = [
            Select ACCESS_STATUS_REASON__C,
            ACCOUNT__C,
            ACCOUNT_COUNTRY__C,
            ACCOUNT_HQ_BR__C,
            ACCOUNT_NAME__C,
            ALLOWASSIGNFINCONTACTFLOWCHANGE__C,
            APPLICATION_ICON_DEL__C,
            APPLICATION_NAME__C,
            APPLICATION_START_ICON__C,
            CASE_CREATION_RECORD_TYPE__C,
            CONNECTIONRECEIVEDID,
            CONNECTIONSENTID,
            CONTACT__C,
            CONTACT_USER_PORTAL_STATUS__C,
            CONTACTID__C,
            CREATEDBYID,
            CREATEDDATE,
            CURRENCY1__C,
            CURRENCY2__C,
            CURRENCYISOCODE,
            IATA_CODE__C,
            ID,
            ISDELETED,
            LASTMODIFIEDBYID,
            LASTMODIFIEDDATE,
            NAME,
            PARENT_ACCOUNT__C,
            PORTAL_APPLICATION__C,
            RECORDTYPEID,
            RESTRICTED_APP__C,
            RIGHT__C,
            SYSTEMMODSTAMP,
            TD_RECORD__C
            From Portal_Application_Right__c
        ];
    }
    
    public static testMethod void testAgencyAppliedChangeCodeFields() {
        list<AGENCY_APPLIED_CHANGE_CODE__C> lst  = [
            Select AIMS_ID__c,
            AIMS_Updated_by__c,
            Account__c,
            Active__c,
            Agency__c,
            Name,
            Amount__c,
            Bulletin_Information__c,
            Change_Code__c,
            CreatedById,
            CreatedDate,
            Created_Date_To_Show__c,
            CurrencyIsoCode,
            Date_Memo_Sent__c,
            Date_time_of_change__c,
            IsDeleted,
            Effective_Date__c,
            End_Date__c,
            For_Integration__c,
            IRR_Expiration_Date__c,
            Irregularities_Points__c,
            Irregularities_Expired__c,
            Irregularity_Type__c,
            LastModifiedById,
            LastModifiedDate,
            OSCAR__c,
            Operation__c,
            Reason_Code__c,
            Reason_Description__c,
            ConnectionReceivedId,
            Id,
            RecordTypeId,
            Related_Irregularity__c,
            Request_Step__c,
            SIDRA_Case__c,
            ConnectionSentId,
            Sent_to_external_system__c,
            Source__c,
            Start_Date__c,
            SystemModstamp,
            Updated_AIMS__c
            From AGENCY_APPLIED_CHANGE_CODE__C
        ];
    }
    
    public static testMethod void testAMSAccountRoleFields() {
        list<AMS_Account_Role__c> lst  = [
            Select ACCOUNT__C,
            ACTIVE__C,
            CONNECTIONRECEIVEDID,
            CONNECTIONSENTID,
            CONTACT__C,
            CONTACT_EMAIL__C,
            CONTACT_PHONE__C,
            CONTACT_TITLE__C,
            CREATEDBYID,
            CREATEDDATE,
            CURRENCYISOCODE,
            DUTY__C,
            EARNING__C,
            EMPLOYEE_NAME__C,
            EMPLOYEE_TYPE__C,
            FINANCIAL_ASSESSMENT_CONTACT__C,
            HOURS__C,
            ID,
            INCONSISTENT_CONTACT_INFO__C,
            ISDELETED,
            ISMANAGER__C,
            ISTICKETINGAGENT__C,
            LAST_SYNCHRONIZATION__C,
            LASTMODIFIEDBYID,
            LASTMODIFIEDDATE,
            LEGACY_EXTERNAL_ID__C,
            LEGACY_SYSTEM__C,
            NAME,
            OWNER_ACCOUNT__C,
            OWNER_NAME__C,
            OWNER_SEQUENCE__C,
            OWNERID,
            PERCENTAGE__C,
            PERSON__C,
            POSITION__C,
            RECORDTYPEID,
            REGISTRATION_DATE__C,
            SIMPLEX__C,
            STAGE__C,
            START_DATE__C,
            SYSTEMMODSTAMP,
            TERMINATION_DATE__C,
            TITLE__C,
            UNIQUE_IDENTIFIER__C,
            VALID__C
            From AMS_Account_Role__c
        ];
    }
    
    public static testMethod void testAMSAccreditationOrganizationFields() {
        list<AMS_Accreditation_Organization__c> lst  = [
            Select Name,
            Address_1__c,
            Address_2__c,
            Address_3__c,
            Air_Code__c,
            City__c,
            Country__c,
            CreatedById,
            CreatedDate,
            CurrencyIsoCode,
            IsDeleted,
            LastActivityDate,
            LastModifiedById,
            LastModifiedDate,
            OwnerId,
            ConnectionReceivedId,
            Id,
            ConnectionSentId,
            State__c,
            SystemModstamp
            From AMS_Accreditation_Organization__c
        ];
    }
    
    public static testMethod void testAMSInspectionFields() {
        list<AMS_Inspection__c> lst  = [
            Select Account__c,
            Accreditation_Endorsement_Status_code__c,
            Accreditation_Endorsement_organisation__c,
            Agency__c,
            Airline__c,
            Airline_Code__c,
            Name,
            BSPLink_or_CASSLink_activation__c,
            CreatedById,
            CreatedDate,
            CurrencyIsoCode,
            Date_Organisation_Status_attained__c,
            IsDeleted,
            IATA_Non_IATA_Carrier__c,
            LastActivityDate,
            LastModifiedById,
            LastModifiedDate,
            Last_synchronization__c,
            Legacy_External_ID__c,
            Legacy_System__c
            From AMS_Inspection__c
        ];
    }
    
        public static testMethod void testAMSPersonFields() {
        list<AMS_Person__c> lst  = [
            Select Contact__c,
            Language_of_correspondence__c,
            CreatedById,
            CreatedDate,
            CurrencyIsoCode,
            DOB__c,
            IsDeleted,
            Email__c,
            Fax__c,
            First_Name__c,
            Name,
            Industry_start_date__c,
            LastActivityDate,
            Last_Case_Assigned_Date_Time__c,
            LastModifiedById,
            LastModifiedDate,
            Last_synchronization__c,
            Lastname__c,
            Legacy_External_ID__c,
            Legacy_System__c
            From AMS_Person__c
        ];
    }
    
        public static testMethod void testFinancialInstitutionFields() {
        list<Financial_Institution__c> lst  = [
            Select ADDRESS__C,
            AGENT_IATA_CODE__C,
            CONNECTIONRECEIVEDID,
            CONNECTIONSENTID,
            CONTACT_PERSON__C,
            COUNTRY__C,
            CREATEDBYID,
            CREATEDDATE,
            CURRENCYISOCODE,
            EMAIL__C,
            ID,
            INSTITUTION_TYPE__C,
            ISDELETED,
            LASTACTIVITYDATE,
            LASTMODIFIEDBYID,
            LASTMODIFIEDDATE,
            NAME,
            OWNERID,
            PHONE__C,
            REGION__C,
            RELATED_IATA_AGENT_ACCOUNT__C,
            SYSTEMMODSTAMP,
            TAX_ID__C
            From Financial_Institution__c
        ];
    }

    public static testMethod void testIFACPoptoutFields() {
        list<IFACP_Opt_out__c> lst  = [
            Select ID,
            OWNERID,
            ISDELETED,
            NAME,
            CURRENCYISOCODE,
            RECORDTYPEID,
            CREATEDDATE,
            CREATEDBYID,
            LASTMODIFIEDDATE,
            LASTMODIFIEDBYID,
            SYSTEMMODSTAMP,
            CONNECTIONRECEIVEDID,
            CONNECTIONSENTID,
            AGENT_ACCOUNT__C,
            AGENT_CODE__C,
            AIRLINE_CODE__C,
            AIRLINE_COUNTRY_ACCOUNT__C,
            AIRLINE__C,
            COUNTRY__C,
            IFACP_OPT_OUT_ACTIVE__C,
            OPT_OUT_END_DATE__C,
            OPT_OUT_START_DATE__C
            From IFACP_Opt_out__c
        ];
    }

    public static testMethod void testRecordTypeFields() {
        list<RecordType> lst  = [
            Select IsActive,
            BusinessProcessId,
            CreatedById,
            CreatedDate,
            Description,
            LastModifiedById,
            LastModifiedDate,
            Name,
            NamespacePrefix,
            Id,
            DeveloperName,
            SobjectType,
            SystemModstamp
            From RecordType
        ];
    }

    public static testMethod void testContactFields(){
         list<Contact> lst  = [
            Select ACCOUNTID,
            ASSISTANTNAME,
            ASSISTANTPHONE,
            BIRTHDATE,
            CANALLOWPORTALSELFREG,
            CONNECTIONRECEIVEDID,
            CONNECTIONSENTID,
            CREATEDBYID,
            CREATEDDATE,
            CURRENCYISOCODE,
            DEPARTMENT,
            DESCRIPTION,
            DONOTCALL,
            EMAIL,
            EMAILBOUNCEDDATE,
            EMAILBOUNCEDREASON,
            FAX,
            FIRSTNAME,
            HASOPTEDOUTOFEMAIL,
            HASOPTEDOUTOFFAX,
            HOMEPHONE,
            ID,
            ISDELETED,
            LASTACTIVITYDATE,
            LASTCUREQUESTDATE,
            LASTCUUPDATEDATE,
            LASTMODIFIEDBYID,
            LASTMODIFIEDDATE,
            LASTNAME,
            LEADSOURCE,
            MAILINGCITY,
            MAILINGCOUNTRY,
            MAILINGPOSTALCODE,
            MAILINGSTATE,
            MAILINGSTREET,
            MASTERRECORDID,
            MOBILEPHONE,
            NAME,
            OTHERCITY,
            OTHERCOUNTRY,
            OTHERPHONE,
            OTHERPOSTALCODE,
            OTHERSTATE,
            OTHERSTREET,
            OWNERID,
            PHONE,
            RECORDTYPEID,
            REPORTSTOID,
            SALUTATION,
            SYSTEMMODSTAMP,
            TITLE
            From Contact
        ];
    }
}