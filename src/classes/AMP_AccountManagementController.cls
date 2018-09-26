public with sharing class AMP_AccountManagementController {

  @AuraEnabled
    public static Account getAccount(Id accountId) {
        return [SELECT Id, Name, Industry, Type, Phone, Company_Logo__c, IATA_ISO_Country__r.Name, Legal_name__c,
              Name_on_AOC__c, TradeName__c, Quality__c, Airline_designator__c, IATACode__c, ICAO_designator__c,
              Airline_Prefix__c, Category__c, Sector__c, Website, IATATrainingUrl__c, Region__c, AM_Ownership_Type__c,
              Membership_status__c, Admission_Date__c, IATA_Membership_History__c, BSP_Participant_value__c, CASS_Participant_value__c,
              Airline_BSP_Participations__c, Airline_CASS_Participations__c,
              RecordType.Name, Region_formula__c, MITA_Member__c, Membership_SITA__c,
              AM_Account_Manager__c, AM_Account_Manager__r.Name, AM_Account_Manager__r.Email,
              AM_Account_Manager__r.Phone, AM_Account_Manager__r.PPD_Tittle__c, AM_Account_Manager__r.PPD_Office__c,
              AM_Account_Manager__r.MobilePhone, SAP_BW_report_with_sales_figures__c, SAP_BW_report_without_sales_figures__c, SanctionNotice__c, Due_Diligence_Status__c,
              Airline_Model_Type__c
            FROM Account
            WHERE Id = :accountId
               LIMIT 1];
    }

}
