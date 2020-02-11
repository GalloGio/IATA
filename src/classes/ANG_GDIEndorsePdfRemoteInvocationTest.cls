@isTest
public class ANG_GDIEndorsePdfRemoteInvocationTest {
	
	@testSetup
	private static void setup() {
		
		Financial_Institution__c fi = new Financial_Institution__c(
			Name = 'GDI - Euler Hermes', 
			Region__c = 'Europe', 
			Country__c = 'Portugal',
			Institution_Type__c = 'Insurance Company'
		);
		insert fi;
		
		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c(
			Name = 'US', 
			ISO_Code__c = 'US', 
			ANG_Enable_NewGen__c = true
		);
		insert ctry;
		
		Product2 prod = new Product2(Name = 'Test', IsActive = true);
		insert prod;
		
		PricebookEntry pbe = new PricebookEntry(
			UnitPrice = 20, 
			CurrencyIsoCode = 'USD', 
			Product2id = prod.id, 
			IsActive = true, 
			Pricebook2Id = Test.getStandardPricebookId()
		);
		insert pbe; 

		Account acc = new Account(
			Name = 'account name', 
			Sector__c = 'Travel Agent',  
			IATACode__c = '1234567',
			Location_Type__c = AMS_Utils.HE, 
			Location_Class__c = AMS_Utils.LC_PASSENGER, 
			recordtypeid = AMS_Utils.RECTYPE_IATAAGENCY,
			IATA_ISO_Country__c = ctry.id
		);

		Account acc2 = new Account(
			Name = 'account name 2', 
			Sector__c = 'Travel Agent',  
			IATACode__c = '1234569',
			Location_Type__c = AMS_Utils.HE, 
			Location_Class__c = AMS_Utils.LC_PASSENGER, 
			recordtypeid = AMS_Utils.RECTYPE_IATAAGENCY,
			IATA_ISO_Country__c = ctry.id
		);

		insert new List<Account>{acc, acc2};
		
		AMS_OSCAR__c oscar = new AMS_OSCAR__c(
			STEP1__c = 'In Progress', 
			Account__c = acc.id, 
			Change_effective_as_of__c = Date.today(),
			Process__c = AMS_Utils.NGGDI
		);
		insert oscar;
		
		Contact contact = new Contact(
			AccountId = acc.id, 
			Firstname = 'teste1', 
			Lastname = 'test1', 
			Phone = '911111111', 
			MobilePhone = '911111111',
			Email = 'test@test.com', 
			Financial_Assessment_Contact__c = false
		);
		insert contact;
		
		Case oscarCase = new Case(
			Oscar__c = oscar.Id, 
			RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case','OSCAR_Communication')
		);

		oscarCase.AccountId = acc.Id;
		oscarCase.ContactId = contact.Id;
		insert oscarCase;
		
		oscar.Oscar_Communication_Case_Id__c = oscarCase.id;
		update oscar;
		
		Case cc = new Case(AccountId = acc.Id);
		insert cc;
		
		ANG_RHC_Information__c rhc = new ANG_RHC_Information__c(ANG_AccountId__c = acc.Id);
		insert rhc;
		
		Financial_Security__c fs = new Financial_Security__c(
			CURRENCYISOCODE = 'USD', 
			Account__c = acc.Id, 
			AMOUNT__C = 3000,
			EXPIRY_DATE__C = system.Today().AddDays(100), 
			FINANCIAL_INSTITUTION__c = fi.Id, 
			SECURITY_STATUS__C = 'Active',
			Security_Type__c = 'GDI', 
			Region__c = 'Europe', 
			Reception_Date__c = system.today(), 
			Reasonforrequest__c = 'New Application',
			Reception_Case__c = cc.Id
		);
		insert fs;
		
		ID oppRecordtype = RecordTypeSingleton.getInstance().getRecordTypeId('Opportunity', 'GDI_FinancialSecurity');
		
		// NEWGEN-5208 - The service will now also send the INT_011 request
		List<ANG_CalloutMapping__c> customsettings = new List<ANG_CalloutMapping__c>();
		customsettings.add(new ANG_CalloutMapping__c(Name = 'ENDORS_CERT', CalloutClass__c = 'ANG_RME_Alert_Service', Action__c = 'GET', Event_Type__C = 'WebService', Credential__c = '/v1/agencies/{agencyId}/offer/{offerId}/endorsement', Named_Credential__c = 'Mulesoft_Credential_Masterdata', Type__c = 'Button'));
		insert customsettings;
		
		Opportunity opp = new Opportunity(
			AccountId = acc.Id,
			CloseDate = Date.today(), 
			CurrencyIsoCode = 'USD',
			Name = 'OPP - ', 
			RecordTypeId = oppRecordtype, 
			StageName = 'Pending', 
			Related_Oscar__c = oscar.Id, 
			GDI_Offer_Id__c = '001'
		);

		Opportunity opp2 = new Opportunity(
			AccountId = acc2.Id,
			CloseDate = Date.today(), 
			CurrencyIsoCode = 'USD',
			Name = 'OPP 2 - ', 
			RecordTypeId = oppRecordtype, 
			StageName = 'Pending', 
			Related_Oscar__c = oscar.Id, 
			GDI_Offer_Id__c = '002'
		);

		insert new List<Opportunity>{opp, opp2};

		Opportunitylineitem	stagingFs = new Opportunitylineitem();

		stagingFs.OpportunityId = opp.Id;
		stagingFs.OSCAR_GDI__c = oscar.Id;
		stagingFs.Security_Type__c = AMS_Utils.FINANCIAL_SECURITY_TYPE_GDI;
		stagingFs.Security_Status__c = 'Draft';
		stagingFs.Quantity = 1;
		stagingFs.Financial_Institution__c = fi.Id;
		stagingFs.Financial_Security__c = fs.Id;
		stagingFs.TotalPrice = 1;
		stagingFs.pricebookentryid = pbe.id;
		stagingFs.FS_Currency__c = opp.currencyIsoCode;
		insert stagingFs;

	}
	
	@isTest
	public static void accountNotFoundTest(){

		Test.startTest();
		
		Remote_Invocation__c ri = new Remote_Invocation__c(
			Internal_ID__c = 'xxxxx', 
			Source__c = RemoteInvocationTriggerHandler.SOURCE_GDI,
			RecordTypeId = RemoteInvocationTriggerHandler.RECTYPE_GDI,
			Integration_Transaction_ID__c = 'idFromMulesoft', 
			Request_Type__c = RemoteInvocationTriggerHandler.NEWGEN_GDI_ENDO_PDF,
			Status__c = RemoteInvocationTriggerHandler.REMOTE_INVOCATION_STATUS_INITIALIZING
		);
		
		insert ri;
		
		Remote_Invocation_Artefact__c artifact = new Remote_Invocation_Artefact__c(
			Remote_Invocation__c = ri.id, 
			Internal_ID__c = 'xxxxx',
			External_ID__c = '001'
		);
		insert artifact;
		
		ri.Status__c = RemoteInvocationTriggerHandler.REMOTE_INVOCATION_STATUS_PROGRESS;
		update ri;
		
		Test.stopTest();

		Remote_Invocation__c processedRi = [SELECT Status__c, Status_detail__c FROM Remote_Invocation__c].get(0);

		System.assertEquals(AMS_Utils.FAILED, processedRi.Status__c, 'Remote invocation status must be FAILED');
		System.assertEquals(
			ANG_GDIEndorsementPdfRemoteInvocation.VERIFY_RELATED_ARTEFACTS, 
			processedRi.Status_detail__c, 
			'Remote invocation detail must be: ' + ANG_GDIEndorsementPdfRemoteInvocation.VERIFY_RELATED_ARTEFACTS
		);

		Remote_Invocation_Artefact__c processedArtefact = [SELECT Request_Result__c, Status_detail__c FROM Remote_Invocation_Artefact__c].get(0);

		System.assertEquals(AMS_Utils.FAILED, processedArtefact.Request_Result__c, 'Remote invocation artefact request result must be FAILED');
		System.assertEquals(
			ANG_GDIEndorsementPdfRemoteInvocation.ACCOUNT_NOT_FOUND, 
			processedArtefact.Status_detail__c, 
			'Remote invocation artefact detail must be: ' + ANG_GDIEndorsementPdfRemoteInvocation.ACCOUNT_NOT_FOUND
		);

	}
	
	@isTest
	public static void offerIdNotFoundTest(){

		Test.startTest();
		
		Remote_Invocation__c ri = new Remote_Invocation__c(
			Internal_ID__c = '1234567', 
			Source__c = RemoteInvocationTriggerHandler.SOURCE_GDI,
			RecordTypeId = RemoteInvocationTriggerHandler.RECTYPE_GDI,
			Integration_Transaction_ID__c = 'idFromMulesoft', 
			Request_Type__c = RemoteInvocationTriggerHandler.NEWGEN_GDI_ENDO_PDF,
			Status__c = RemoteInvocationTriggerHandler.REMOTE_INVOCATION_STATUS_INITIALIZING
		);
		
		insert ri;
		
		Remote_Invocation_Artefact__c artifact = new Remote_Invocation_Artefact__c(
			Remote_Invocation__c = ri.id, 
			Internal_ID__c = '1234567',
			External_ID__c = 'xxx'
		);
		insert artifact;
		
		ri.Status__c = RemoteInvocationTriggerHandler.REMOTE_INVOCATION_STATUS_PROGRESS;
		update ri;
		
		Test.stopTest();

		Remote_Invocation__c processedRi = [SELECT Status__c, Status_detail__c FROM Remote_Invocation__c].get(0);

		System.assertEquals(AMS_Utils.FAILED, processedRi.Status__c, 'Remote invocation status must be FAILED');
		System.assertEquals(
			ANG_GDIEndorsementPdfRemoteInvocation.VERIFY_RELATED_ARTEFACTS, 
			processedRi.Status_detail__c, 
			'Remote invocation detail must be: ' + ANG_GDIEndorsementPdfRemoteInvocation.VERIFY_RELATED_ARTEFACTS
		);

		Remote_Invocation_Artefact__c processedArtefact = [SELECT Request_Result__c, Status_detail__c FROM Remote_Invocation_Artefact__c].get(0);

		System.assertEquals(AMS_Utils.FAILED, processedArtefact.Request_Result__c, 'Remote invocation artefact request result must be FAILED');
		System.assertEquals(
			ANG_GDIEndorsementPdfRemoteInvocation.OFFER_ID_NOT_FOUND, 
			processedArtefact.Status_detail__c, 
			'Remote invocation artefact detail must be: ' + ANG_GDIEndorsementPdfRemoteInvocation.OFFER_ID_NOT_FOUND
		);

	}

	@isTest
	public static void offerAssociatedWithDiffIataCodeTest(){

		Test.startTest();
		
		Remote_Invocation__c ri = new Remote_Invocation__c(
			Internal_ID__c = '1234567', 
			Source__c = RemoteInvocationTriggerHandler.SOURCE_GDI, 
			RecordTypeId = RemoteInvocationTriggerHandler.RECTYPE_GDI,
			Integration_Transaction_ID__c = 'idFromMulesoft', 
			Request_Type__c = RemoteInvocationTriggerHandler.NEWGEN_GDI_ENDO_PDF,
			Status__c = RemoteInvocationTriggerHandler.REMOTE_INVOCATION_STATUS_INITIALIZING
		);
		
		insert ri;
		
		Remote_Invocation_Artefact__c artifact = new Remote_Invocation_Artefact__c(
			Remote_Invocation__c = ri.id, 
			Internal_ID__c = '1234567',
			External_ID__c = '002'
		);
		insert artifact;
		
		ri.Status__c = RemoteInvocationTriggerHandler.REMOTE_INVOCATION_STATUS_PROGRESS;
		update ri;
		
		Test.stopTest();

		Remote_Invocation__c processedRi = [SELECT Status__c, Status_detail__c FROM Remote_Invocation__c].get(0);

		System.assertEquals(AMS_Utils.FAILED, processedRi.Status__c, 'Remote invocation status must be FAILED');
		System.assertEquals(
			ANG_GDIEndorsementPdfRemoteInvocation.VERIFY_RELATED_ARTEFACTS, 
			processedRi.Status_detail__c, 
			'Remote invocation detail must be: ' + ANG_GDIEndorsementPdfRemoteInvocation.VERIFY_RELATED_ARTEFACTS
		);

		Remote_Invocation_Artefact__c processedArtefact = [SELECT Request_Result__c, Status_detail__c FROM Remote_Invocation_Artefact__c].get(0);

		System.assertEquals(AMS_Utils.FAILED, processedArtefact.Request_Result__c, 'Remote invocation artefact request result must be FAILED');
		System.assertEquals(
			ANG_GDIEndorsementPdfRemoteInvocation.OFFER_ID_DIFFERENT_IATA_CODE, 
			processedArtefact.Status_detail__c, 
			'Remote invocation artefact detail must be: ' + ANG_GDIEndorsementPdfRemoteInvocation.OFFER_ID_DIFFERENT_IATA_CODE
		);

	}

	@isTest
	public static void invalidRequestTypeTest(){

		Test.startTest();
		
		Remote_Invocation__c ri = new Remote_Invocation__c(
			Internal_ID__c = '1234567', 
			Source__c = 'IEP', 
			RecordTypeId = RemoteInvocationTriggerHandler.RECTYPE_GDI,
			Integration_Transaction_ID__c = 'idFromMulesoft', 
			Request_Type__c = RemoteInvocationTriggerHandler.NEWGEN_GDI_ENDO_PDF,
			Status__c = RemoteInvocationTriggerHandler.REMOTE_INVOCATION_STATUS_INITIALIZING
		);
		
		insert ri;
		
		Remote_Invocation_Artefact__c artifact = new Remote_Invocation_Artefact__c(
			Remote_Invocation__c = ri.id, 
			Internal_ID__c = '1234567',
			External_ID__c = '001'
		);
		insert artifact;
		
		ri.Status__c = RemoteInvocationTriggerHandler.REMOTE_INVOCATION_STATUS_PROGRESS;
		update ri;	

		Test.stopTest();

		Remote_Invocation__c processedRi = [SELECT Status__c, Status_detail__c FROM Remote_Invocation__c].get(0);

		System.assertEquals(AMS_Utils.FAILED, processedRi.Status__c, 'Remote invocation status must be FAILED');
		System.assertEquals(
			ANG_GDIEndorsementPdfRemoteInvocation.INVALID_REQUEST_TYPE, 
			processedRi.Status_detail__c, 
			'Remote invocation detail must be: ' + ANG_GDIEndorsementPdfRemoteInvocation.INVALID_REQUEST_TYPE
		);
		
	}
	
	@isTest
	public static void missingMandatoryFieldsTest() {
		
		Test.startTest();
		
		Remote_Invocation__c ri = new Remote_Invocation__c(
			Internal_ID__c = '1234567', 
			Source__c = RemoteInvocationTriggerHandler.SOURCE_GDI,
			RecordTypeId = RemoteInvocationTriggerHandler.RECTYPE_GDI,
			Integration_Transaction_ID__c = 'idFromMulesoft', 
			Request_Type__c = RemoteInvocationTriggerHandler.NEWGEN_GDI_ENDO_PDF,
			Status__c = RemoteInvocationTriggerHandler.REMOTE_INVOCATION_STATUS_INITIALIZING
		);
		
		insert ri;
		
		Remote_Invocation_Artefact__c artifact = new Remote_Invocation_Artefact__c(
			Remote_Invocation__c = ri.id, 
			Internal_ID__c = '1234567',
			External_ID__c = null
		);
		insert artifact;
		
		ri.Status__c = RemoteInvocationTriggerHandler.REMOTE_INVOCATION_STATUS_PROGRESS;
		update ri;
		
		Test.stopTest();

		Remote_Invocation__c processedRi = [SELECT Status__c, Status_detail__c FROM Remote_Invocation__c].get(0);

		System.assertEquals(AMS_Utils.FAILED, processedRi.Status__c, 'Remote invocation status must be FAILED');
		System.assertEquals(
			ANG_GDIEndorsementPdfRemoteInvocation.VERIFY_RELATED_ARTEFACTS, 
			processedRi.Status_detail__c, 
			'Remote invocation detail must be: ' + ANG_GDIEndorsementPdfRemoteInvocation.VERIFY_RELATED_ARTEFACTS
		);

		Remote_Invocation_Artefact__c processedArtefact = [SELECT Request_Result__c, Status_detail__c FROM Remote_Invocation_Artefact__c].get(0);

		System.assertEquals(AMS_Utils.FAILED, processedArtefact.Request_Result__c, 'Remote invocation artefact request result must be FAILED');
		System.assertEquals(
			ANG_GDIEndorsementPdfRemoteInvocation.MISSING_MANDATORY_FIELDS, 
			processedArtefact.Status_detail__c, 
			'Remote invocation artefact detail must be: ' + ANG_GDIEndorsementPdfRemoteInvocation.MISSING_MANDATORY_FIELDS
		);

	}
	
	@isTest
	public static void noArtifactProvidedTest() {
		
		Test.startTest();
		
		Remote_Invocation__c ri = new Remote_Invocation__c(
			Internal_ID__c = '1111111', 
			Source__c = RemoteInvocationTriggerHandler.SOURCE_GDI,
			Integration_Transaction_ID__c = 'idFromMulesoft',
			Request_Type__c = RemoteInvocationTriggerHandler.NEWGEN_GDI_ENDO_PDF, 
			Status__c = RemoteInvocationTriggerHandler.REMOTE_INVOCATION_STATUS_INITIALIZING
		);
		
		insert ri;
		
		ri.Status__c = RemoteInvocationTriggerHandler.REMOTE_INVOCATION_STATUS_PROGRESS;
		update ri;
		
		Test.stopTest();

		Remote_Invocation__c processedRi = [SELECT Status__c, Status_detail__c FROM Remote_Invocation__c].get(0);

		System.assertEquals(AMS_Utils.FAILED, processedRi.Status__c, 'Remote invocation status must be FAILED');
		System.assertEquals(
			ANG_GDIEndorsementPdfRemoteInvocation.NO_ARTEFACT_MATCH, 
			processedRi.Status_detail__c, 
			'Remote invocation detail must be: ' + ANG_GDIEndorsementPdfRemoteInvocation.NO_ARTEFACT_MATCH
		);

	}
	
	@isTest
	public static void fetchStagingFinancialSecurityTest() {

		Test.startTest();
		
		Remote_Invocation__c ri = new Remote_Invocation__c(
			Internal_ID__c = '1234567', 
			Source__c = RemoteInvocationTriggerHandler.SOURCE_GDI,
			RecordTypeId = RemoteInvocationTriggerHandler.RECTYPE_GDI,
			Integration_Transaction_ID__c = 'idFromMulesoft', 
			Request_Type__c = RemoteInvocationTriggerHandler.NEWGEN_GDI_ENDO_PDF,
			Status__c = RemoteInvocationTriggerHandler.REMOTE_INVOCATION_STATUS_INITIALIZING
		);
		
		insert ri;
		
		Remote_Invocation_Artefact__c artifact = new Remote_Invocation_Artefact__c(
			Remote_Invocation__c = ri.id, 
			Internal_ID__c = '1234567',
			External_ID__c = '001'
		);
		insert artifact;
		
		ri.Status__c = RemoteInvocationTriggerHandler.REMOTE_INVOCATION_STATUS_PROGRESS;
		update ri;
		
		Test.stopTest();

		Remote_Invocation__c processedRi = [SELECT Status__c, Status_detail__c FROM Remote_Invocation__c].get(0);

		System.assertEquals(AMS_Utils.COMPLETED, processedRi.Status__c, 'Remote invocation status must be COMPLETED');
		System.assertEquals(null, processedRi.Status_detail__c, 'Remote invocation detail must be empty');

		Remote_Invocation_Artefact__c processedArtefact = [SELECT Request_Result__c, Status_detail__c, Object_ID_Created__c FROM Remote_Invocation_Artefact__c].get(0);
		
		OpportunityLineItem oli = [SELECT Id, Financial_Security__c FROM OpportunityLineItem];

		System.assertEquals(AMS_Utils.COMPLETED, processedArtefact.Request_Result__c, 'Remote invocation artefact request result must be COMPLETED');
		System.assertEquals(null, processedArtefact.Status_detail__c, 'Remote invocation artefact detail must be empty');
		System.assertEquals(oli.Id, processedArtefact.Object_ID_Created__c, 'Remote invocation artefact object id created must be: ' + oli.Id);

	}

	@isTest
	public static void fetchWithoutStagingFinancialSecurityTest() {
		
		delete [SELECT Id FROM Opportunitylineitem];

		Test.startTest();
		
		Remote_Invocation__c ri = new Remote_Invocation__c(
			Internal_ID__c = '1234567', 
			Source__c = RemoteInvocationTriggerHandler.SOURCE_GDI,
			RecordTypeId = RemoteInvocationTriggerHandler.RECTYPE_GDI,
			Integration_Transaction_ID__c = 'idFromMulesoft', 
			Request_Type__c = RemoteInvocationTriggerHandler.NEWGEN_GDI_ENDO_PDF,
			Status__c = RemoteInvocationTriggerHandler.REMOTE_INVOCATION_STATUS_INITIALIZING
		);
		
		insert ri;
		
		Remote_Invocation_Artefact__c artifact = new Remote_Invocation_Artefact__c(
			Remote_Invocation__c = ri.id, 
			Internal_ID__c = '1234567',
			External_ID__c = '001'
		);
		insert artifact;
		
		ri.Status__c = RemoteInvocationTriggerHandler.REMOTE_INVOCATION_STATUS_PROGRESS;
		update ri;
		
		Test.stopTest();

		Remote_Invocation__c processedRi = [SELECT Status__c, Status_detail__c FROM Remote_Invocation__c].get(0);

		System.assertEquals(AMS_Utils.FAILED, processedRi.Status__c, 'Remote invocation status must be FAILED');
		System.assertEquals(
			ANG_GDIEndorsementPdfRemoteInvocation.VERIFY_RELATED_ARTEFACTS, 
			processedRi.Status_detail__c, 
			'Remote invocation detail must be: ' + ANG_GDIEndorsementPdfRemoteInvocation.VERIFY_RELATED_ARTEFACTS
		);

		Remote_Invocation_Artefact__c processedArtefact = [SELECT Request_Result__c, Status_detail__c FROM Remote_Invocation_Artefact__c].get(0);

		System.assertEquals(AMS_Utils.FAILED, processedArtefact.Request_Result__c, 'Remote invocation artefact request result must be FAILED');
		System.assertEquals(
			ANG_GDIEndorsementPdfRemoteInvocation.OPPORTUNITY_LINE_ITEM_DOES_NOT_EXIST, 
			processedArtefact.Status_detail__c, 
			'Remote invocation artefact detail must be: ' + ANG_GDIEndorsementPdfRemoteInvocation.OPPORTUNITY_LINE_ITEM_DOES_NOT_EXIST
		);
	}

	@isTest
	public static void fetchFinancialSecurityTest() {

		Test.startTest();
		
		Opportunity opp = [SELECT Id, StageName FROM Opportunity WHERE GDI_Offer_Id__c = '001'];
		opp.StageName = AMS_Utils.OPPORTUNITY_CLOSED_WON;
		update opp;

		Remote_Invocation__c ri = new Remote_Invocation__c(
			Internal_ID__c = '1234567', 
			Source__c = RemoteInvocationTriggerHandler.SOURCE_GDI,
			RecordTypeId = RemoteInvocationTriggerHandler.RECTYPE_GDI,
			Integration_Transaction_ID__c = 'idFromMulesoft', 
			Request_Type__c = RemoteInvocationTriggerHandler.NEWGEN_GDI_ENDO_PDF,
			Status__c = RemoteInvocationTriggerHandler.REMOTE_INVOCATION_STATUS_INITIALIZING
		);
		
		insert ri;
		
		Remote_Invocation_Artefact__c artifact = new Remote_Invocation_Artefact__c(
			Remote_Invocation__c = ri.id, 
			Internal_ID__c = '1234567',
			External_ID__c = '001'
		);
		insert artifact;
		
		ri.Status__c = RemoteInvocationTriggerHandler.REMOTE_INVOCATION_STATUS_PROGRESS;
		update ri;
		
		Test.stopTest();

		Remote_Invocation__c processedRi = [SELECT Status__c, Status_detail__c FROM Remote_Invocation__c].get(0);

		System.assertEquals(AMS_Utils.COMPLETED, processedRi.Status__c, 'Remote invocation status must be COMPLETED');
		System.assertEquals(null, processedRi.Status_detail__c, 'Remote invocation detail must be empty');

		Remote_Invocation_Artefact__c processedArtefact = [SELECT Request_Result__c, Status_detail__c, Object_ID_Created__c FROM Remote_Invocation_Artefact__c].get(0);
		
		OpportunityLineItem oli = [SELECT Id, Financial_Security__c FROM OpportunityLineItem];

		System.assertEquals(AMS_Utils.COMPLETED, processedArtefact.Request_Result__c, 'Remote invocation artefact request result must be COMPLETED');
		System.assertEquals(null, processedArtefact.Status_detail__c, 'Remote invocation artefact detail must be empty');
		System.assertEquals(oli.Financial_Security__c, processedArtefact.Object_ID_Created__c, 'Remote invocation artefact object id created must be: ' + oli.Financial_Security__c);

	}

	@isTest
	public static void fetchWithoutFinancialSecurityTest() {

		Test.startTest();
		
		Opportunity opp = [SELECT Id, StageName, (SELECT Id, Financial_Security__c FROM OpportunityLineItems) FROM Opportunity WHERE GDI_Offer_Id__c = '001'];

		OpportunityLineItem oli = opp.OpportunityLineItems[0];
		oli.Financial_Security__c = null;
		update oli;

		opp.StageName = AMS_Utils.OPPORTUNITY_CLOSED_WON;
		update opp;

		Remote_Invocation__c ri = new Remote_Invocation__c(
			Internal_ID__c = '1234567', 
			Source__c = RemoteInvocationTriggerHandler.SOURCE_GDI,
			RecordTypeId = RemoteInvocationTriggerHandler.RECTYPE_GDI,
			Integration_Transaction_ID__c = 'idFromMulesoft', 
			Request_Type__c = RemoteInvocationTriggerHandler.NEWGEN_GDI_ENDO_PDF,
			Status__c = RemoteInvocationTriggerHandler.REMOTE_INVOCATION_STATUS_INITIALIZING
		);
		
		insert ri;
		
		Remote_Invocation_Artefact__c artifact = new Remote_Invocation_Artefact__c(
			Remote_Invocation__c = ri.id, 
			Internal_ID__c = '1234567',
			External_ID__c = '001'
		);
		insert artifact;
		
		ri.Status__c = RemoteInvocationTriggerHandler.REMOTE_INVOCATION_STATUS_PROGRESS;
		update ri;
		
		Test.stopTest();

		Remote_Invocation__c processedRi = [SELECT Status__c, Status_detail__c FROM Remote_Invocation__c].get(0);

		System.assertEquals(AMS_Utils.FAILED, processedRi.Status__c, 'Remote invocation status must be FAILED');
		System.assertEquals(
			ANG_GDIEndorsementPdfRemoteInvocation.VERIFY_RELATED_ARTEFACTS, 
			processedRi.Status_detail__c, 
			'Remote invocation detail must be: ' + ANG_GDIEndorsementPdfRemoteInvocation.VERIFY_RELATED_ARTEFACTS
		);

		Remote_Invocation_Artefact__c processedArtefact = [SELECT Request_Result__c, Status_detail__c FROM Remote_Invocation_Artefact__c].get(0);

		System.assertEquals(AMS_Utils.FAILED, processedArtefact.Request_Result__c, 'Remote invocation artefact request result must be FAILED');
		System.assertEquals(
			ANG_GDIEndorsementPdfRemoteInvocation.FINANCIAL_SECURITY_NOT_ASSOCIATED_WITH_OPPLINEITEM, 
			processedArtefact.Status_detail__c, 
			'Remote invocation artefact detail must be: ' + ANG_GDIEndorsementPdfRemoteInvocation.FINANCIAL_SECURITY_NOT_ASSOCIATED_WITH_OPPLINEITEM
		);

	}

}
