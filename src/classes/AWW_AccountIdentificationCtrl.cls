public with sharing class AWW_AccountIdentificationCtrl {

    @AuraEnabled
    public static Account getAccountDetails(Id accountId){
        return [SELECT Id, RecordTypeId, RecordType.Name, Name, Quality__c, AM_Ownership_Type__c, Other_Type_of_Subsidiaries__c,
                            IATA_ISO_Country__c, IATA_ISO_Country__r.Name, Top_Parent__c, VAT_Number__c,
                            Sector__c, Category__c, Account_Type__c, Logo_File_ID__c,
                            Company_Logo__c, Legal_Name__c, AccountNumber, Region_formula__c,
                            AM_Account_Manager__c, AM_Account_Manager__r.Name, AM_Account_Manager__r.PPD_Tittle__c,
                            AM_Account_Manager__r.PPD_Office__c, AM_Account_Manager__r.Email, AM_Account_Manager__r.Phone,
                            AM_Account_Manager__r.MobilePhone, BillingStreet, BillingCity, BillingState, BillingPostalCode,
                            BillingCountry, Sub_Region__c, Website
                       FROM Account
                       WHERE Id = :accountId];
    }

    @AuraEnabled
    public static Account saveAccountDetails(Account accountDetails){
        update accountDetails;
        return accountDetails;
    }
    
    @AuraEnabled
    public static Boolean canEditOtherTypeofSubsidiaries(){
         List<PermissionSetAssignment> permissions = [
            SELECT PermissionSet.Name
            FROM PermissionSetAssignment 
            WHERE AssigneeId = :UserInfo.getUserId() AND PermissionSet.Name =: 'AMP_Manage_Account_Ownership'
        ];

        if(permissions.isEmpty()) {
            return false;
        } else {
            return true;
        }
    }
    
    @AuraEnabled
    public static Boolean haveAMPAgencyManagement(){
         List<PermissionSetAssignment> permissions = [
            SELECT PermissionSet.Name
            FROM PermissionSetAssignment 
            WHERE AssigneeId = :UserInfo.getUserId() AND PermissionSet.Name =: 'AMP_Agency_Management'
        ];

        if(permissions.isEmpty()) {
            return false;
        } else {
            return true;
        }
    }
}