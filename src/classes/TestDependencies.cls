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
            AIMS_ID__c,
            Fin_statements_submission_deadline__c,
            Identify_as_Key_Customer__c,
            CCG_IRR_Distribution_list__c,
            CreatedDate
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
            Defaulted_Amount__c,
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
            Subsequent_Sales__c,
            Total_Defaulted_Amount__c,
            Current_Outstanding_Amount_all_periods__c,
            Collected_Amount_all_periods__c,
            Recovered_after_default__c,
            Paid_back_Amount__c,
            Pro_rated_Amount__c
            From Case
        ];
    }

    public static testMethod void testSIDRADefaultDetailsFields() {
        list<SIDRA_eDefault__c> lst  = [
            Select Account__c,
            CreatedById,
            CreatedDate,
            Currency__c,
            Currency_Exchange_Rate__c,
            CurrencyIsoCode,
            Date_of_movement__c,
            Default_date__c,
            Default_record_code__c,
            Defaulted_Amount__c,
            Defaulted_amount_USD__c,
            IsDeleted,
            LastModifiedById,
            LastModifiedDate,
            OwnerId,
            Prorated_amount__c,
            ConnectionReceivedId,
            Id,
            RecordTypeId,
            Recovered_Amount__c,
            Recovered_amount_USD__c,
            SIDRA_Case__c,
            Name,
            ConnectionSentId,
            SystemModstamp,
            Type__c
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
            Select Id,
            IsDeleted,
            Name,
            CurrencyIsoCode,
            RecordTypeId,
            CreatedDate,
            CreatedById,
            LastModifiedDate,
            LastModifiedById,
            SystemModstamp,
            ConnectionReceivedId,
            ConnectionSentId,
            Contact__c,
            Portal_Application__c,
            TD_Record__c,
            ContactId__c,
            IATA_Code__c
            From Portal_Application_Right__c
        ];
    }
}