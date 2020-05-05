@isTest
public class ADSRServiceTest {
	
	@testSetup
	static void setupTest() {
		IATA_ISO_Country__c canada = new IATA_ISO_Country__c(Name = 'Canada', ISO_Code__c = 'CA', Region__c = 'Americas', BSP__c = 'No',
			CASS_Export__c = 'Yes', CASS_Import__c = 'Yes', Enable_NewGen_Pilot__c = true, ANG_Enable_NewGen__c = true);
		IATA_ISO_Country__c brazil = new IATA_ISO_Country__c(Name = 'Brazil', ISO_Code__c = 'BR', Region__c = 'Americas', BSP__c = 'Yes',
			CASS_Export__c = 'Yes', CASS_Import__c = 'Yes', Enable_NewGen_Pilot__c = true, ANG_Enable_NewGen__c = true);
		IATA_ISO_Country__c mexico = new IATA_ISO_Country__c(Name = 'Mexico', ISO_Code__c = 'MX', Region__c = 'Americas', BSP__c = 'Yes',
			CASS_Export__c = 'No', CASS_Import__c = 'No', Enable_NewGen_Pilot__c = true, ANG_Enable_NewGen__c = true);
		IATA_ISO_Country__c colombia = new IATA_ISO_Country__c(Name = 'Colombia', ISO_Code__c = 'CO', Region__c = 'Americas',
			BSP__c = 'Yes', CASS_Export__c = 'Yes', CASS_Import__c = 'Yes', Enable_NewGen_Pilot__c = true, ANG_Enable_NewGen__c = true);
		IATA_ISO_Country__c cayman = new IATA_ISO_Country__c(Name = 'Cayman Islands', ISO_Code__c = 'CI', Region__c = 'Americas',
			BSP__c = 'Yes', CASS_Export__c = 'No', CASS_Import__c = 'No', Enable_NewGen_Pilot__c = true, ANG_Enable_NewGen__c = true);
		IATA_ISO_Country__c chile = new IATA_ISO_Country__c(Name = 'Chile', ISO_Code__c = 'CL', Region__c = 'Americas', BSP__c = 'Yes',
			CASS_Export__c = 'Yes', CASS_Import__c = 'Yes', Enable_NewGen_Pilot__c = true, ANG_Enable_NewGen__c = true);
		IATA_ISO_Country__c saintLucia = new IATA_ISO_Country__c(Name = 'Saint Lucia', ISO_Code__c = 'SL', Region__c = 'Americas',
			BSP__c = 'Yes', CASS_Export__c = 'No', CASS_Import__c = 'No', Enable_NewGen_Pilot__c = true, ANG_Enable_NewGen__c = true);
		IATA_ISO_Country__c ecuador = new IATA_ISO_Country__c(Name = 'Ecuador', ISO_Code__c = 'EC', Region__c = 'Americas',
			BSP__c = 'No', CASS_Export__c = 'Yes', CASS_Import__c = 'Yes', Enable_NewGen_Pilot__c = true, ANG_Enable_NewGen__c = true);
		IATA_ISO_Country__c peru = new IATA_ISO_Country__c(Name = 'Peru', ISO_Code__c = 'PR', Region__c = 'Americas', BSP__c = 'No',
			CASS_Export__c = 'Yes', CASS_Import__c = 'Yes', Enable_NewGen_Pilot__c = true, ANG_Enable_NewGen__c = true);
		insert new List<IATA_ISO_Country__c> {
			canada, brazil, mexico, colombia, cayman, chile, saintLucia, ecuador, peru
		};
		
		Id rtHQ = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
		
		Account MyAirline = new Account(RecordTypeId = rtHQ, Name = 'Flying Beaver', ACLI_Status__c = 'Active Company', MITA_Member__c = true,
			BIETA_Member__c = true, Airline_designator__c = 'AA', IATACode__c = '014', Airline_Prefix__c = '014', IATA_ISO_Country__c = canada.Id);
		insert MyAirline;
		
		Contact newCon = ISSP_ObjectFactory.createNewContact();
		newCon.AccountId = MyAirline.Id;
		newCon.Email = 'testemail1@csp.testclass';
		newCon.User_Portal_Status__c = 'Approved Admin';
		insert newCon;
		
		User newUser = ISSP_ObjectFactory.createPortalUser(newCon);
		
		Id rtId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
		Account agency1 = new Account(name = 'MALCA-AMIT CANADA, INC.', IATA_ISO_Country__c = canada.Id, Sector__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT,
			ANG_IEP_Status__c = ANG_ISSP_PortalServiceHelper.STATUS_OPEN, Location_type__c = 'HO', OwnerId = UserInfo.getUserId(),
			Location_Class__c = 'P', recordtypeId = rtId, Site = '60192990010', Status__c = 'Terminated');
		Account agency2 = new Account(name = 'ICNT LOGISTICS INC.', IATA_ISO_Country__c = canada.Id, Sector__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT,
			ANG_IEP_Status__c = ANG_ISSP_PortalServiceHelper.STATUS_OPEN, Location_type__c = 'HO', OwnerId = UserInfo.getUserId(),
			Location_Class__c = 'P', recordtypeId = rtId, Site = '60193230010', Status__c = 'Terminated');
		Account agency3 = new Account(name = 'CARGO ARTISTS INC.', IATA_ISO_Country__c = canada.Id, Sector__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT,
			ANG_IEP_Status__c = ANG_ISSP_PortalServiceHelper.STATUS_NO_IEP_ACCOUNT, Location_type__c = 'HO', OwnerId = UserInfo.getUserId(),
			Location_Class__c = 'P', recordtypeId = rtId, Site = '60193020010');
		Account agency4 = new Account(name = 'INTERCONTINENTAL VIAGENS E  TURISMO LTDA.', IATA_ISO_Country__c = brazil.Id,
			Sector__c = ANG_ISSP_PortalServiceHelper.TRAVEL_AGENT, ANG_IEP_Status__c = ANG_ISSP_PortalServiceHelper.STATUS_NO_IEP_ACCOUNT,
			Location_type__c = 'HO', OwnerId = UserInfo.getUserId(), Location_Class__c = 'P', recordtypeId = rtId, Site = '57528860');
		insert new List<Account> { agency1, agency2, agency3, agency4 };
		
		Financial_Institution__c fi1 = new Financial_Institution__c(Name = 'FI1', Institution_Type__c = 'IATA Agent', Region__c = 'Americas',
			Country__c = 'Canada');
		Financial_Institution__c fi2 = new Financial_Institution__c(Name = 'FI2', Institution_Type__c = 'IATA Agent', Region__c = 'Americas',
			Country__c = 'Brazil');
		insert new List<Financial_Institution__c> { fi1, fi2 };
		
		Id caseRT_FDS_ICCS_Email_to_Case = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'SIDRA');
		Case receptionCase = new Case(Subject = 'Case Test', Region__c = 'Americas', Origin = 'Portal', CaseArea__c = 'Accreditation');
		case sidraCase = new Case(Subject = 'SIDRA Case Agency 4', Region__c = 'Americas', Origin = 'Portal', CaseArea__c = 'Accreditation',
			BSP_CASS__c = 'BSP', E2CP__AdditionalCC__c = 'testqa.tcosta@yopmail.com.inactive.inactive', IATAcode__c = '57528860',
			RecordTypeId = caseRT_FDS_ICCS_Email_to_Case, Visible_on_ISS_Portal__c = true, ContactId = newCon.Id, Handover_Bankruptcy_Lawyer__c = Date.today(),
			First_Call_Letter__c = 'Sent');
		insert new List<Case> { receptionCase, sidraCase };
		
		// Agency 1
		Financial_Security__c fs1a = new Financial_Security__c(Account__c = agency1.Id, Reception_Date__c = Date.today().addDays(-1),
			Reception_Case__c = receptionCase.Id, Reasonforrequest__c = 'Default', Financial_Institution__c = fi1.Id, Security_Type__c = 'Financial Guarantee',
			Amount__c = 1, Expiry_Date__c = Date.today().addDays(1), Region__c = 'Americas', Security_Status__c = 'Encashment in progress',
			Two_months_passed_expiry__c = false, First_Call_Letter_required1__c = 'Yes');
		Financial_Security__c fs1b = new Financial_Security__c(Account__c = agency1.Id, Reception_Date__c = Date.newInstance(2020,
			4, 27), Reception_Case__c = receptionCase.Id, Reasonforrequest__c = 'Default', Financial_Institution__c = fi1.Id,
			Security_Type__c = 'Financial Guarantee', Amount__c = 1, Expiry_Date__c = Date.newInstance(2020, 4, 29), Region__c = 'Americas',
			Security_Status__c = 'Expired', Two_months_passed_expiry__c = false, First_Call_Letter_required1__c = 'Yes');
		// Agency 2
		Financial_Security__c fs2a = new Financial_Security__c(Account__c = agency2.Id, Reception_Date__c = Date.today().addDays(-3),
			Reception_Case__c = receptionCase.Id, Reasonforrequest__c = 'Default', Encashment_Date__c = Date.today().addDays(-1),
			Release_Date__c = Date.today().addDays(-1), Financial_Institution__c = fi1.Id, Security_Type__c = 'Financial Guarantee',
			Amount__c = 1, Expiry_Date__c = Date.today().addDays(1), Region__c = 'Americas', Security_Status__c = 'Encashed',
			First_Call_Letter_required1__c = 'Yes');
		Financial_Security__c fs2b = new Financial_Security__c(Account__c = agency2.Id, Reception_Date__c = Date.today().addDays(-3),
			Reception_Case__c = receptionCase.Id, Reasonforrequest__c = 'Default', Financial_Institution__c = fi1.Id, Security_Type__c = 'Financial Guarantee',
			Amount__c = 1, Expiry_Date__c = Date.today().addDays(-1), Region__c = 'Americas', Security_Status__c = 'Expired',
			First_Call_Letter_required1__c = 'Yes');
		// Agency 4
		Financial_Security__c fs4a = new Financial_Security__c(Account__c = agency4.Id, Reception_Date__c = Date.today(), Reception_Case__c = receptionCase.Id,
			Reasonforrequest__c = 'Default', Financial_Institution__c = fi1.Id, Security_Type__c = 'Financial Guarantee', Amount__c = 1,
			Expiry_Date__c = Date.today().addDays(+5), Region__c = 'Americas', Security_Status__c = 'Active', First_Call_Letter_required1__c = 'Yes');
		insert new List<Financial_Security__c> { fs1a, fs1b, fs2a, fs2b, fs4a };
		
		Agency_Applied_Change_code__c ch1 = new Agency_Applied_Change_code__c(Account__c = agency1.Id, Change_Code__c = 'DEF');
		Agency_Applied_Change_code__c ch2 = new Agency_Applied_Change_code__c(Account__c = agency2.Id, Change_Code__c = 'RPY');
		Agency_Applied_Change_code__c ch3 = new Agency_Applied_Change_code__c(Account__c = agency3.Id, Change_Code__c = 'REI');
		Agency_Applied_Change_code__c ch4 = new Agency_Applied_Change_code__c(Account__c = agency4.Id, Change_Code__c = 'NEW',
			SIDRA_Case__c = sidraCase.Id);
		insert new List<Agency_Applied_Change_Code__c> { ch1, ch2, ch3, ch4 };
	}
	
	@isTest
	static void testGetRefData() {
		
		User u = [SELECT Id FROM User WHERE Contact.Account.IATACode__c = '014'];
		
		Test.startTest();
		System.runAs(u) {
			List<ADSRController.PicklistWrapper> regions = ADSRController.getRegions();
			List<ADSRController.PicklistWrapper> allMarkets = ADSRController.getMarkets(null);
			List<ADSRController.PicklistWrapper> americasMarkets = ADSRController.getMarkets('Americas');
			
			System.assertEquals(5, regions.size());
			System.assertEquals(9, allMarkets.size());
			System.assertEquals(9, americasMarkets.size());
		}
		
		Test.stopTest();
		
	}
	
	@isTest
	static void testGetReportByRegion() {
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('ADSR_API_Mock');
		mock.setStatusCode(200);
		mock.setHeader('Content-Type', 'application/json');
		
		Test.setMock(HttpCalloutMock.class, mock);
		
		User u = [SELECT Id FROM User WHERE Contact.Account.IATACode__c = '014'];
		
		Test.startTest();
		
		System.runAs(u) {
			ADSRService.SummaryReport report = ADSRController.getReport('Americas', '', '', '');
			
			Boolean hasCassColombia = false;
			for (ADSRService.SummaryReportGroup reportGroup : report.groups) {
				if (reportGroup.operation.toLowerCase().contains('colombia')
					&& reportGroup.operation.toLowerCase().contains('cass')) {
					hasCassColombia = true;
					Decimal charged = 0;
					for (ADSRService.SummaryReportDetail detail : reportGroup.details) {
						charged += detail.charged;
					}
					System.assertEquals(charged, reportGroup.totalCharged);
				}
			}
			
			System.assertEquals('014', report.airlineCode);
			System.assert(hasCassColombia);
		}
		
		Test.stopTest();
		
	}
	
	@isTest
	static void testGetReportByAgent() {
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('ADSR_API_Mock');
		mock.setStatusCode(200);
		mock.setHeader('Content-Type', 'application/json');
		
		Test.setMock(HttpCalloutMock.class, mock);
		
		User u = [SELECT Id FROM User WHERE Contact.Account.IATACode__c = '014'];
		
		Test.startTest();
		
		System.runAs(u) {
			ADSRService.SummaryReport report = ADSRController.getReport('', '', '', '6019323001');
			
			System.assertNotEquals(null, report.groups);
		}
		
		Test.stopTest();
	}
	
	@isTest
	static void testGetReportServerError() {
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('ADSR_API_Mock_Error');
		mock.setStatusCode(500);
		mock.setHeader('Content-Type', 'application/json');
		
		Test.setMock(HttpCalloutMock.class, mock);
		
		User u = [SELECT Id FROM User WHERE Contact.Account.IATACode__c = '014'];
		
		Test.startTest();
		
		Boolean throwsError = false;
		
		System.runAs(u) {
			try {
				ADSRController.getReport('Americas', '', '', '');
			} catch (AuraHandledException e) {
				throwsError = true;
			}
			
			System.assert(throwsError);
		}
		
		Test.stopTest();
		
	}
	
	@isTest
	static void testGetReportMissingParameters() {
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('ADSR_API_Mock_Error');
		mock.setStatusCode(400);
		mock.setHeader('Content-Type', 'application/json');
		
		Test.setMock(HttpCalloutMock.class, mock);
		
		User u = [SELECT Id FROM User WHERE Contact.Account.IATACode__c = '014'];
		
		Test.startTest();
		
		Boolean throwsError = false;
		
		System.runAs(u) {
			try {
				ADSRController.getReport('', '', '', '');
			} catch (AuraHandledException e) {
				throwsError = true;
			}
			
			System.assert(throwsError);
		}
		
		Test.stopTest();
		
	}
	
	@isTest
	static void testGetReportWrongParameters() {
		StaticResourceCalloutMock mock = new StaticResourceCalloutMock();
		mock.setStaticResource('ADSR_API_Mock_Error');
		mock.setStatusCode(404);
		mock.setHeader('Content-Type', 'application/json');
		
		Test.setMock(HttpCalloutMock.class, mock);
		
		User u = [SELECT Id FROM User WHERE Contact.Account.IATACode__c = '014'];
		
		Test.startTest();
		
		Boolean throwsError = false;
		
		System.runAs(u) {
			try {
				ADSRController.getReport('Americas', '', '', 'XPTO123');
			} catch (AuraHandledException e) {
				throwsError = true;
			}
			
			System.assert(throwsError);
		}
		
		Test.stopTest();
		
	}
	
	@isTest
	static void testExportPDF() {
		String jsonString = [SELECT Body FROM StaticResource WHERE Name = 'ADSR_Export_Data_Test'].Body.toString();
		Map<String, Object> jsonObject = (Map<String, Object>) ((List<Object>) JSON.deserializeUntyped(jsonString)).get(0);
		
		Test.startTest();
		
		PageReference pdfPage = Page.ADSRExportPDF;
		Test.setCurrentPage(pdfPage);
		
		for (String key : jsonObject.keySet()) {
			if (jsonObject.get(key) instanceof String) {
				ApexPages.currentPage().getParameters().put(key, (String) jsonObject.get(key));
			} else {
				ApexPages.currentPage().getParameters().put(key, JSON.serialize(jsonObject.get(key)));
			}
		}
		
		ADSRExportController exportPdf = new ADSRExportController();
		
		System.assertEquals('pdf', exportPdf.exportFormat);
		
		Test.stopTest();
		
	}
	
	@isTest
	static void testExportCSV() {
		String jsonString = [SELECT Body FROM StaticResource WHERE Name = 'ADSR_Export_Data_Test'].Body.toString();
		Map<String, Object> jsonObject = (Map<String, Object>) ((List<Object>) JSON.deserializeUntyped(jsonString)).get(1);
		
		Test.startTest();
		
		PageReference csvPage = Page.ADSRExportCSV;
		Test.setCurrentPage(csvPage);
		
		for (String key : jsonObject.keySet()) {
			if (jsonObject.get(key) instanceof String) {
				ApexPages.currentPage().getParameters().put(key, (String) jsonObject.get(key));
			} else {
				ApexPages.currentPage().getParameters().put(key, JSON.serialize(jsonObject.get(key)));
			}
		}
		
		ADSRExportController exportCsv = new ADSRExportController();
		
		System.assertEquals('csv', exportCsv.exportFormat);
		
		Test.stopTest();
	}
	
}