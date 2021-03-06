@isTest
public class ANG_ExposeAccountInfo_Masterdata_Test {

	private static Integer HTTP_STATUS_OK = 200;

	@testSetup 
	static void setup() {

		Test.startTest();

		Portal_Applications__c pa = TestDataFactory_PortalApplications.createDefaultPortalApplication(1).get(0);
		pa.Name='TEST';
		insert pa;

		AMS_Settlement_System__c bspPT = new AMS_Settlement_System__c(
			Name = 'BSP-PT',
			CurrencyIsoCode = 'EUR',
			RecordTypeId = AMS_Utils.RECTYPE_BSP,
			RHC_Exceptional_Monitoring__c = true
		);
		insert bspPT;

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (
			Name='US',
			ISO_Code__c='US', 
			ANG_Enable_NewGen__c = true, 
			Multicountry_Enabled__c = true, 
			ISO_Code_Numeric__c = 445, 
			BSP_Country_free_text__c = 'test', 
			ANG_Portal_Service__c = pa.Id
		);

		IATA_ISO_Country__c ukCountry = new IATA_ISO_Country__c(
			Name = 'United Kingdom',
			CurrencyIsoCode = 'EUR',
			ISO_Code_Numeric__c = 999,
			ISO_Code__c = 'UK',
			AIMS_Area_ID__c='1',
			ANG_Enable_NewGen__c = true,
			ANG_IEP_Model__c = 'Model B+'
		);

		IATA_ISO_Country__c countryPT = new IATA_ISO_Country__c(
			Name = 'Portugal',
			ISO_Code__c = 'PT',
			AMS_Settlement_System__c = bspPT.Id,
			ANG_Enable_NewGen__c = false
		);

		insert new List<IATA_ISO_Country__c>{ctry, ukCountry, countryPT};

		IATA_ISO_State__c stt = new IATA_ISO_State__c(Name= 'Test', ISO_Code__c = 'TS', IATA_ISO_Country__c = ctry.Id);
		insert stt;

		Id accountAgencyRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
		Id aaRT = RecordTypeSingleton.getInstance().getRecordTypeId('Agency_Authorization__c', 'BSPLink');

		Account accHE = new Account(
			Name ='UK Test',
			Type = 'IATA Passenger Sales Agent',
			Sector__c='Travel Agent',
			Location_Type__c = AMS_Utils.HE,
			Location_Class__c = 'P',
			ANG_FA_Opt_out__c = false,
			IATACode__c='999999999',
			IATA_ISO_Country__c = ukCountry.Id,
			BillingCountry='UK Test',
			ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_CASH,
			Status__c = AMS_Utils.ACC_S9_APPROVED,
			ANG_HE_RiskHistoryAssessment__c = ANG_Risk_Helper.RISK_ASSESSMENT_PASSED,
			Financial_Review_Result__c = ANG_Risk_Helper.FR_UNSATISFACTORY,
			RecordTypeId = AMS_Utils.RECTYPE_IATAAGENCY,
			ANG_IEP_Status__c = 'In Progress'
		);

		Account accountGE = new Account();
		accountGE.Name = 'Main HE Account H1';
		accountGE.Sector__c = 'Travel Agent';
		accountGE.IATACode__c = '43215678';
		accountGE.Category__c = 'IATA Passenger Sales Agent';
		accountGE.Location_Class__c = 'P';
		accountGE.Location_Type__c = AMS_Utils.GE;
		accountGE.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY;
		accountGE.IATA_ISO_Country__c = ctry.Id;
		accountGE.RecordTypeId = accountAgencyRT;
		accountGE.GDI_Status__c = 'Open';
		accountGE.Purge_Flag__c = false;
		accountGE.Date_Organisation_Status_attained__c = date.today();
		accountGE.Accreditation_date__c = date.today();
		accountGE.Default_date__c = date.today();

		Account rhcMonitoringAccount = new Account();
		rhcMonitoringAccount.Name = 'Account for exceptional monitoring';
		rhcMonitoringAccount.IATACode__c = '912345678';
		rhcMonitoringAccount.IATA_ISO_Country__c = countryPT.Id;
		rhcMonitoringAccount.RecordTypeId = accountAgencyRT;
		rhcMonitoringAccount.Location_Type__c = AMS_Utils.HO;
		rhcMonitoringAccount.Sector__c = AMS_Utils.CATEGORY_TRAVEL_AGENT;
		rhcMonitoringAccount.Location_Class__c = AMS_Utils.LC_PASSENGER;
		rhcMonitoringAccount.Status__c = AMS_Utils.ACC_S9_APPROVED;

		insert new List<Account>{accHE, accountGE, rhcMonitoringAccount};

		Account account = new Account();
		account.Name = 'Main HE Account H1';
		account.Sector__c = 'Travel Agent';
		account.IATACode__c = '12345678';
		account.Category__c = 'IATA Passenger Sales Agent';
		account.Location_Class__c = 'P';
		account.Location_Type__c = AMS_Utils.AE;
		account.ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_MULTICOUNTRY;
		account.IATA_ISO_Country__c = ctry.Id;
		account.RecordTypeId = accountAgencyRT;
		account.GDI_Status__c = 'Open';
		account.parentId = accountGE.Id;
		account.Top_Parent__c = accountGE.Id;
		account.Purge_Flag__c = false;
		account.Date_Organisation_Status_attained__c = date.today();
		account.Accreditation_date__c = date.today();
		account.Default_date__c = date.today();
		account.Remittance_frequency__c = 'P';

		insert account;

		ANG_RHC_Currencies__c rhcCurrencies = new ANG_RHC_Currencies__c();
		rhcCurrencies.Name = 'USD';
		rhcCurrencies.CurrencyIsoCode = 'USD';
		rhcCurrencies.Currency_Name__c  = 'US Dollar';

		insert rhcCurrencies;

		ANG_RHC_Information__c rhc = new ANG_RHC_Information__c();
		rhc.ANG_AccountId__c = account.Id;
		rhc.ANG_RHC_Amount__c = 5;
		rhc.CurrencyIsoCode = 'USD';
		rhc.ANG_Financial_Security__c = 150;

		insert rhc;

		Agency_Authorization__c aa = new Agency_Authorization__c();
		aa.Account__c = account.Id;
		aa.RecordTypeId = aaRT;
		aa.Status__c = 'Active';

		insert aa;

		Agency_Applied_Change_code__c aacc = new Agency_Applied_Change_code__c(Change_Code__c = 'LSP', Account__c = account.Id);
		insert aacc;

		Financial_Institution__c fi = new Financial_Institution__c(Name = 'Financial Institution Test', Institution_Type__c = 'Bank');
		insert fi;

		Case receptionCase = new Case(AccountId = rhcMonitoringAccount.Id);
		insert receptionCase;

		Financial_Security__c activeFS = new Financial_Security__c(
			CurrencyIsoCode = 'USD', 
			Account__c = rhcMonitoringAccount.Id, 
			Amount__c = 10000, 
			Expiry_Date__c = System.Today().addDays(100), 
			Financial_Institution__c = fi.Id,
			SECURITY_STATUS__C = AMS_Utils.FINANCIAL_SECURITY_STATUS_ACTIVE, 
			Security_Type__c = 'Bank Guarantee', 
			Region__c = 'Europe', 
			Reception_Date__c = System.today(), 
			Reasonforrequest__c = 'New Application', 
			Reception_Case__c = receptionCase.Id, 
			Financial_Security_Validation_Case__c = receptionCase.Id
		);

		Financial_Security__c closeToExpiryDateFS = new Financial_Security__c(
			CurrencyIsoCode = 'USD', 
			Account__c = rhcMonitoringAccount.Id, 
			Amount__c = 30000, 
			Expiry_Date__c = System.Today().addDays(10), 
			Financial_Institution__c = fi.Id,
			SECURITY_STATUS__C = AMS_Utils.FINANCIAL_SECURITY_STATUS_CLOSE_EXPIRY, 
			Security_Type__c = 'Bank Guarantee', 
			Region__c = 'Europe', 
			Reception_Date__c = System.today().addDays(-100), 
			Reasonforrequest__c = 'New Application', 
			Reception_Case__c = receptionCase.Id, 
			Financial_Security_Validation_Case__c = receptionCase.Id
		);

		insert new List<Financial_Security__c>{activeFS, closeToExpiryDateFS};

		Test.stopTest();

	}

	private static RestResponse doCallOutToWS(String iataCode, String caller, String accountType){
		RestRequest request = new RestRequest();
		RestResponse response = new RestResponse();

		request.requestURI = '/account-details/'+iataCode + '/account-masterdata';
		request.httpMethod = 'GET';
		request.addParameter('caller', caller);
		request.addParameter('accountType', accountType);

		RestContext.request = request;
		RestContext.response = response;
		ANG_ExposeAccountInfo.doGet();

		return response;
	}

	@isTest static void testExposeAccMasterData() {

		list<Account> lsAccnt = [SELECT Id, Name, Sector__c, IATACode__c, Category__c, Location_Class__c, parentId, Top_Parent__c, Date_Organisation_Status_attained__c,
								 Location_Type__c, ANG_Accreditation_Model__c, IATA_ISO_Country__c, RecordTypeId, GDI_Status__c, Purge_Flag__c,
								 Is_Branch_Abroad__c, Due_Diligence_Status__c, billingCity, billingCountry, billingPostalCode, billingState,
								 billingStreet, Accreditation_date__c, Default_date__c, IATA_ISO_Country__r.ISO_Code_Numeric__c, IATA_ISO_Country__r.ISO_Code__c,
								 Email__c, fax, ANG_IEP_Status_FF__c, Parent.IATACode__c, IATA_ISO_Country__r.BSP_Country_free_text__c, ANG_RiskStatus__c,
								 IATA_ISO_Country__r.ANG_Portal_Service__r.Name, IATA_ISO_Country__r.Region__c, phone, Reason__c, VAT_Number__c,
								 Remittance_frequency__c, Segmentation__c, Status__c, Tax_ID_1__c, TradeName__c, Top_Parent__r.IATACode__c,
								 IATA_ISO_Country__r.AMS_Settlement_System__r.CurrencyIsoCode, CurrencyIsoCode, Guaranteed_amount__c, ANG_IsNewGenAgency__c,
								 (Select Id, ANG_RHC_Amount__c, CurrencyIsoCode, ANG_Financial_Security__c From RHC_Informations__r),
								 (Select Id, recordtype.developername, Email_Used_for_BSP_Creation__c, ANG_FormOfPayment_ID__c, Status__c From Agency_Authorizations__r where recordtype.developername in ('BSPLink','FormOfPayment'))
								 FROM Account
								 WHERE IATACode__c = '12345678'];


		test.startTest();
		RestResponse res = new RestResponse();
		RestContext.response = res;

		ANG_ExposeAccountInfo_Masterdata.ANG_ExposeAccountInfo_Masterdata(new Map<Id, Account>(lsAccnt), 'F', 'LSP');
		ANG_ExposeAccountInfo_Masterdata.ANG_ExposeAccountInfo_Masterdata(new Map<Id, Account>(lsAccnt), 'S', 'LSP');
		ANG_ExposeAccountInfo_Masterdata.ANG_ExposeAccountInfo_Masterdata(new Map<Id, Account>(lsAccnt), 'P', 'LSP');
		ANG_ExposeAccountInfo_Masterdata.ANG_ExposeAccountInfo_Masterdata(new Map<Id, Account>(lsAccnt), 'D', 'LSP');

		System.assertEquals(200, RestContext.response.statusCode);

		Test.stopTest();
	}

	 @isTest 
	 static void pciCompliantTest(){

		Account acct = [
			SELECT
				Id,
				Name,
				IATACode__c,
				Is_PCI_Compliant__c
			 FROM Account
			 WHERE Name = 'Uk Test'
			 LIMIT 1
		];

		Test.startTest();

		RestResponse response = doCallOutToWS(acct.IATACode__c, ANG_RestServiceHelper.Caller_Mulesoft, 'Agency');
		System.assertEquals(HTTP_STATUS_OK, response.statusCode, 'The service response must be ' + HTTP_STATUS_OK);

		String respBody = response.responseBody.toString();

		List<ANG_ExposeAccountInfo_Masterdata.INT008_SuccessPayload> payloadLst = (List<ANG_ExposeAccountInfo_Masterdata.INT008_SuccessPayload>) JSON.deserialize(respBody, List<ANG_ExposeAccountInfo_Masterdata.INT008_SuccessPayload>.class);

		ANG_ExposeAccountInfo_Masterdata.INT008_SuccessPayload payload = payloadLst.get(0);

		System.assert(payload.isPciDss != null, 'Payload isPciDss element must NOT be empty');
		System.assert(!payload.isPciDss, 'Payload isPciDss element must be \'FALSE\'');

		acct.Is_PCI_Compliant__c = 'Nil CC';
		update acct;

		response = doCallOutToWS(acct.IATACode__c, ANG_RestServiceHelper.Caller_Mulesoft, 'Agency');
		System.assertEquals(HTTP_STATUS_OK, response.statusCode, 'The service response must be ' + HTTP_STATUS_OK);

		respBody = response.responseBody.toString();

		payloadLst = (List<ANG_ExposeAccountInfo_Masterdata.INT008_SuccessPayload>) JSON.deserialize(respBody, List<ANG_ExposeAccountInfo_Masterdata.INT008_SuccessPayload>.class);

		payload = payloadLst.get(0);

		System.assert(payload.isPciDss != null, 'Payload isPciDss element must NOT be empty');
		System.assert(!payload.isPciDss, 'Payload isPciDss element must be \'FALSE\'');

		acct.Is_PCI_Compliant__c = 'Corporate Card';
		update acct;

		response = doCallOutToWS(acct.IATACode__c, 'Mulesoft', 'Agency');
		System.assertEquals(HTTP_STATUS_OK, response.statusCode, 'The service response must be ' + HTTP_STATUS_OK);

		respBody = response.responseBody.toString();

		payloadLst = (List<ANG_ExposeAccountInfo_Masterdata.INT008_SuccessPayload>) JSON.deserialize(respBody, List<ANG_ExposeAccountInfo_Masterdata.INT008_SuccessPayload>.class);

		payload = payloadLst.get(0);

		System.assert(payload.isPciDss != null, 'Payload isPciDss element must NOT be empty');
		System.assert(payload.isPciDss, 'Payload isPciDss element must be \'TRUE\'');

		//When the IEP Status is not 'open' or 'in progress'
		//the pci compliant value must not be in the payload
		acct.ANG_IEP_Status__c = 'No IEP Account';
		update acct;

		response = doCallOutToWS(acct.IATACode__c, 'Mulesoft', 'Agency');
		System.assertEquals(HTTP_STATUS_OK, response.statusCode, 'The service response must be ' + HTTP_STATUS_OK);

		respBody = response.responseBody.toString();

		payloadLst = (List<ANG_ExposeAccountInfo_Masterdata.INT008_SuccessPayload>) JSON.deserialize(respBody, List<ANG_ExposeAccountInfo_Masterdata.INT008_SuccessPayload>.class);

		payload = payloadLst.get(0);

		System.assert(payload.isPciDss == null, 'Payload isPciDss element must be NULL');

		Test.stopTest();
	}

	@isTest
	static void rhcExceptionalMonitoringTest(){

		Account acct = [
			SELECT
				Id, Name, IATACode__c, CurrencyIsoCode,
				IATA_ISO_Country__r.AMS_Settlement_System__r.CurrencyIsoCode,
				(SELECT Id, Amount__c 
				FROM Financial_Securities__r)
			 FROM Account
			 WHERE Name = 'Account for exceptional monitoring'
			 LIMIT 1
		];

		Test.startTest();

		RestResponse response = doCallOutToWS(acct.IATACode__c, ANG_RestServiceHelper.Caller_Mulesoft, 'Agency');
		System.assertEquals(HTTP_STATUS_OK, response.statusCode, 'The service response must be ' + HTTP_STATUS_OK);

		String respBody = response.responseBody.toString();

		List<ANG_ExposeAccountInfo_Masterdata.INT008_SuccessPayload> payloadLst = (List<ANG_ExposeAccountInfo_Masterdata.INT008_SuccessPayload>) JSON.deserialize(respBody, List<ANG_ExposeAccountInfo_Masterdata.INT008_SuccessPayload>.class);

		ANG_ExposeAccountInfo_Masterdata.INT008_SuccessPayload payload = payloadLst.get(0);

		Decimal totalFsAmount = 0;
		for(Financial_Security__c fs : acct.Financial_Securities__r) {
			totalFsAmount += fs.Amount__c;
		}

		String bspCurrency = acct.IATA_ISO_Country__r.AMS_Settlement_System__r.CurrencyIsoCode;

		System.assertEquals(bspCurrency, payload.RHCInfo.RHCCurrency, 'The RHC currency must be ' + bspCurrency);

		Decimal totalFsConverted = ANG_Risk_Helper.currencyConverter(acct.CurrencyIsoCode, totalFsAmount, bspCurrency);

		System.assertEquals(totalFsConverted, payload.RHCInfo.RHCAmount, 'The RHC amount must be ' + totalFsConverted);
		System.assertEquals(totalFsConverted, payload.RHCInfo.RHCTotalFSProvided, 'The RHC Total FS Provided amount must be ' + totalFsConverted);

		Test.stopTest();
	}

	@isTest
	static void rhcExceptionalMonitoringInvalidTest(){

		Account acct = [
			SELECT
				Id, Name, IATACode__c, CurrencyIsoCode,
				IATA_ISO_Country__r.AMS_Settlement_System__r.CurrencyIsoCode,
				(SELECT Id, Amount__c 
				FROM Financial_Securities__r)
			 FROM Account
			 WHERE Name = 'Account for exceptional monitoring'
			 LIMIT 1
		];

		AMS_Settlement_System__c bspPT = new AMS_Settlement_System__c(Id = acct.IATA_ISO_Country__r.AMS_Settlement_System__c);
		bspPT.RHC_Exceptional_Monitoring__c = false;
		update bspPT;

		Test.startTest();

		RestResponse response = doCallOutToWS(acct.IATACode__c, ANG_RestServiceHelper.Caller_Mulesoft, 'Agency');
		System.assertEquals(HTTP_STATUS_OK, response.statusCode, 'The service response must be ' + HTTP_STATUS_OK);

		String respBody = response.responseBody.toString();

		List<ANG_ExposeAccountInfo_Masterdata.INT008_SuccessPayload> payloadLst = (List<ANG_ExposeAccountInfo_Masterdata.INT008_SuccessPayload>) JSON.deserialize(respBody, List<ANG_ExposeAccountInfo_Masterdata.INT008_SuccessPayload>.class);

		ANG_ExposeAccountInfo_Masterdata.INT008_SuccessPayload payload = payloadLst.get(0);

		Decimal totalFsAmount = 0;
		for(Financial_Security__c fs : acct.Financial_Securities__r) {
			totalFsAmount += fs.Amount__c;
		}

		String bspCurrency = acct.IATA_ISO_Country__r.AMS_Settlement_System__r.CurrencyIsoCode;

		System.assertEquals(bspCurrency, payload.RHCInfo.RHCCurrency, 'The RHC currency must be ' + bspCurrency);

		Decimal totalFsConverted = ANG_Risk_Helper.currencyConverter(acct.CurrencyIsoCode, totalFsAmount, bspCurrency);

		System.assertEquals(null, payload.RHCInfo.RHCAmount, 'The RHC amount must be null');
		System.assertEquals(totalFsConverted, payload.RHCInfo.RHCTotalFSProvided, 'The RHC Total FS Provided amount must be ' + totalFsConverted);

		Test.stopTest();
	}

}
