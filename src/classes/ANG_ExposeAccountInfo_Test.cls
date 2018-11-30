@isTest
private class ANG_ExposeAccountInfo_Test {

	@testSetup static void setup() {


		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US', ANG_Enable_NewGen__c = true)  ;
        insert ctry ;

        IATA_ISO_State__c stt = new IATA_ISO_State__c(Name= 'Test', ISO_Code__c = 'TS', IATA_ISO_Country__c = ctry.Id);
        insert stt;
		
		Id accountAgencyRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

		Account account = new Account();
		account.Name = 'Main HE Account H1';
		account.Sector__c = 'Travel Agent';
		account.IATACode__c = '12345678';
		account.Category__c = 'IATA Passenger Sales Agent';
		account.Location_Class__c = 'P';
		account.Location_Type__c = 'HE';
		account.ANG_Accreditation_Model__c = 'Cashless';
		account.IATA_ISO_Country__c = ctry.Id;
		account.ANG_IEP_HE_AccntNum__c = '1232132323';
		account.ANG_IEP_Status__c = 'Suspended' ;
		account.ANG_HE_CashCondition__c = true;
		account.ANG_HE_RiskHistoryAssessment__c = 'Not Applicable';
		account.ANG_HE_RiskStatus__c = 'Not Applicable';
		account.RecordTypeId = accountAgencyRT;

		insert account;

	}
	
	@isTest static void testAccountDetails() {
				
       	RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();

        req.requestURI = '/services/apexrest/account-details/12345678/'; 
        req.addParameter('requestType', 'account-files');
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;


        ANG_ExposeAccountInfo.doGet();
	}
	

}