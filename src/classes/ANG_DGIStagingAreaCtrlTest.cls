@isTest
private class ANG_DGIStagingAreaCtrlTest {
	@testSetup static void setup(){

		Test.startTest();

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='France',ISO_Code__c='FR', ANG_Enable_NewGen__c = true, Region__c = 'Europe')  ;
		insert ctry ;

		IATA_ISO_State__c stt = new IATA_ISO_State__c(Name= 'FR20', ISO_Code__c = 'FR', IATA_ISO_Country__c = ctry.Id);
		insert stt;

		Id accountRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
		Id caseRT = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');

		List<Account> accountList = new List<Account>();
		Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountRT ,Name='NewGenAgency',Short_Name__c='NewGenAgency', Location_Class__c = 'P', Location_Type__c = 'HE', Remittance_frequency__c = 'M', Sector__C = 'Travel Agent' , Category__C = 'Non-IATA Passenger Agent', Reason_for_creation__c = 'Account is missing' , Company_Type__c = 'A', IATACODE__c = '1234567');

		insert a1;

		Case parentCase = new Case(accountId = a1.Id);
		insert parentCase;

		Contact co1 = new Contact(AccountId = a1.id, Firstname = 'John', Lastname='Rambo', Phone = '666123456', MobilePhone = '911111111', Email = 'rambo.johnj@test.com', Financial_Assessment_Contact__c = false);
		insert co1;

		ID oscarNewHeRt = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'ANG_GDI_SETUP');

		AMS_OSCAR__c oscar = new AMS_OSCAR__c(Process__c = AMS_Utils.NGGDI, Account__c = a1.id, Is_using_credit_card__c = true, RecordTypeId = oscarNewHeRt);

		insert oscar;

		Case oscarCase = new Case(Oscar__c = oscar.Id, RecordTypeId = caseRT, ParentId = parentCase.Id, caseArea__c = 'Accreditation Process', Reason1__c = 'GDI Setup');
		oscarCase.AccountId = a1.Id;
		oscarCase.ContactId = co1.Id;
		insert oscarCase;

		EF_AttachmentListController.runningForEF = false;
		TestDataFactory_AWSKeys.createAllEntries();

		AmazonFile__c aFile = new AmazonFile__c(
			Full_Name_Unique__c = 'test name',
			Case__c = oscarCase.Id
		);
		insert aFile;

		ID rtNew = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Pax_Accreditation_Form__c', 'Travel_Agent_Head_Entity_Standard_no_Cash');

		AMS_Pax_Accreditation_Form__c theAccreditation = new AMS_Pax_Accreditation_Form__c(RecordTypeId = rtNew);

		theAccreditation.Account_Name__c='NEWGEN-559 HE5';
		theAccreditation.ISSP_AMS_Legal_Status__c='Association';
		theAccreditation.Branch_Office_Country__c= ctry.Id;
		theAccreditation.Branch_Office_Street_name_number__c='sdfsdf';
		theAccreditation.Branch_Office_City__c='sdfsdfdf';
		theAccreditation.IATA_ISO_State__c= stt.Id;
		theAccreditation.Branch_Office_Email__c='sdfsdfgdg@f3434.com';
		theAccreditation.Branch_Office_Phone__c='123123123';
		theAccreditation.ISSP_AMS_Premises_located_at_airport__c='No';
		theAccreditation.Abbreviated_name__c='NEWGEN-559 HE5';
		theAccreditation.Abbreviated_Address__c='sdfsdf';
		theAccreditation.Remittance_frequency__c='M';
		theAccreditation.Solicitation_Flag__c=false;
		theAccreditation.Location_Class__c='P';
		theAccreditation.Location_Type__c='HE';
		theAccreditation.SAAM_Case__c=oscarCase.Id;
		theAccreditation.Account_Name__c = a1.Id;

		insert theAccreditation;

		oscar.AMS_Online_Accreditation__c = theAccreditation.Id;
		oscar.Is_PCI_compliant__c = 'Yes';
		oscar.ANG_PCI_compliance_expiry_date__c = Date.today();
		oscar.Oscar_Communication_Case_Id__c = oscarCase.Id;
		update oscar;

		Product2 prod = new Product2(Name = 'Laptop X200',
							 Family = 'Hardware');
		insert prod;

		Id pricebookId = Test.getStandardPricebookId();

		PricebookEntry standardPrice = new PricebookEntry(
			Pricebook2Id = pricebookId, Product2Id = prod.Id,
			UnitPrice = 10000, IsActive = true);

		insert standardPrice;

		Pricebook2 customPB = new Pricebook2(Name='NewGen Generic', isActive=true);
		insert customPB;

		PricebookEntry customPrice = new PricebookEntry(
			Pricebook2Id = customPB.Id, Product2Id = prod.Id,
			UnitPrice = 12000, IsActive = true);

		insert customPrice;

		// NEWGEN-5208 - The service will now also send the INT_011 request
		List<ANG_CalloutMapping__c> customsettings = new List<ANG_CalloutMapping__c>();
		customsettings.add(new ANG_CalloutMapping__c(Name = 'ENDORS_CERT', CalloutClass__c = 'ANG_RME_Alert_Service', Action__c = 'GET', Event_Type__C = 'WebService', Credential__c = '/v1/agencies/{agencyId}/offer/{offerId}/endorsement', Named_Credential__c = 'Mulesoft_Credential_Masterdata', Type__c = 'Button'));
		insert customsettings;

		Opportunity opp = new Opportunity();
		opp.CloseDate=date.today().addMonths(50);
		opp.Name='test opp';
		opp.StageName='Pending';
		opp.GDI_Offer_Id__c = '12343434';
		opp.RecordtypeId = RecordTypeSingleton.getInstance().getRecordType('Opportunity','GDI_FinancialSecurity').Id;
		opp.accountId = a1.Id;
		opp.CurrencyIsoCode='USD';
		opp.Related_Oscar__c = oscar.Id;
		insert opp;

		Financial_Institution__c FI = new Financial_Institution__c(Name = 'GDI - Euler Hermes', INSTITUTION_TYPE__C='Bank');
		insert FI;

		Test.stopTest();

	}

	@isTest static void acceptTest() {

		Case oscarCase = [Select id from Case where Oscar__c <> null];

		Account a1 = [Select Id from Account];

		Financial_Institution__c FI = [Select id from Financial_Institution__c];

		Financial_Security__c FS = new Financial_Security__c(CURRENCYISOCODE='USD', Account__c=a1.Id, AMOUNT__C=3000, EXPIRY_DATE__C=system.Today().AddDays(100), FINANCIAL_INSTITUTION__c=FI.Id, SECURITY_STATUS__C='Active', Security_Type__c='GDI', Region__c ='Europe', Reception_Date__c=system.today(), Reasonforrequest__c='New Application', Reception_Case__c=oscarCase.Id);
		insert FS;

		AMS_OSCAR__c oscar = [Select id from AMS_OSCAR__c];

		Test.startTest();

		PageReference pg = Page.ANG_DGIStagingArea;
		pg.getParameters().put('Id', oscar.Id);

		Test.setCurrentPage(pg);

		ANG_DGIStagingAreaCtrl controller = new ANG_DGIStagingAreaCtrl();

		controller.addCertificate = true;

		controller.createStagingAreaDefault();

		controller.createStagingArea();

		Boolean hasErrorMessages = controller.hasErrorMessages;
		AMS_Oscar__c oscarObj = controller.oscarObj;
		Case oscarCaseController = controller.oscarCase;
		oscarCaseController = controller.oscarCase;
		Boolean isOscarProcessed = controller.oscarProcessed;
		List<String> stagingFields = controller.stagingAreaFields;
		Boolean isWaitingForEndorsement = controller.waitingForEndorsement;
		Boolean isAddCertificate = controller.addCertificate;

		controller.stagingFs.AMOUNT__C = 1000;
		controller.stagingFs.Reason__c = 'New Application';
		controller.stagingFs.Expiry_Date__c = System.Today();

		update controller.stagingFs;

		controller.fetchStagingFs(controller.stagingFs.Id, null);

		controller.accept();

		Test.StopTest();
	}

	@isTest static void acceptNoFSTest() {

		Test.startTest();

		AMS_OSCAR__c oscar = [Select id from AMS_OSCAR__c];

		PageReference pg = Page.ANG_DGIStagingArea;
		pg.getParameters().put('Id', oscar.Id);

		Test.setCurrentPage(pg);

		ANG_DGIStagingAreaCtrl controller = new ANG_DGIStagingAreaCtrl();

		controller.addCertificate = true;

		controller.createStagingAreaDefault();

		controller.createStagingArea();


		controller.stagingFs.AMOUNT__C = 1000;
		controller.stagingFs.Reason__c = 'New Application';
		controller.stagingFs.Expiry_Date__c = System.Today();

		update controller.stagingFs;

		controller.fetchStagingFs(controller.stagingFs.Id, null);

		controller.accept();

		Test.StopTest();
	}

	@isTest static void rejectTest() {

		Case oscarCase = [Select id from Case where Oscar__c <> null];

		Account a1 = [Select Id from Account];

		Financial_Institution__c FI = [Select id from Financial_Institution__c];

		Financial_Security__c FS = new Financial_Security__c(CURRENCYISOCODE='USD', Account__c=a1.Id, AMOUNT__C=3000, EXPIRY_DATE__C=system.Today().AddDays(100), FINANCIAL_INSTITUTION__c=FI.Id, SECURITY_STATUS__C='Active', Security_Type__c='GDI', Region__c ='Europe', Reception_Date__c=system.today(), Reasonforrequest__c='New Application', Reception_Case__c=oscarCase.Id);
		insert FS;

		AMS_OSCAR__c oscar = [Select id from AMS_OSCAR__c];

		Test.startTest();

		PageReference pg = Page.ANG_DGIStagingArea;
		pg.getParameters().put('Id', oscar.Id);

		Test.setCurrentPage(pg);

		ANG_DGIStagingAreaCtrl controller = new ANG_DGIStagingAreaCtrl();

		controller.addCertificate = true;

		controller.createStagingAreaDefault();

		controller.createStagingArea();

		Boolean hasErrorMessages = controller.hasErrorMessages;
		AMS_Oscar__c oscarObj = controller.oscarObj;
		Case oscarCaseController = controller.oscarCase;
		Boolean isOscarProcessed = controller.oscarProcessed;
		List<String> stagingFields = controller.stagingAreaFields;
		Boolean isWaitingForEndorsement = controller.waitingForEndorsement;
		Boolean isAddCertificate = controller.addCertificate;

		controller.stagingFs.AMOUNT__C = 1000;
		controller.stagingFs.Reason__c = 'New Application';
		controller.stagingFs.Expiry_Date__c = System.Today();

		update controller.stagingFs;

		controller.fetchStagingFs(controller.stagingFs.Id, null);

		controller.reject();

		Test.StopTest();
	}

	@isTest static void acceptAdemdumTest() {

		Case oscarCase = [Select id from Case where Oscar__c <> null];

		Account a1 = [Select Id from Account];

		Financial_Institution__c FI = [Select id from Financial_Institution__c];

		Financial_Security__c FS = new Financial_Security__c(CURRENCYISOCODE='USD', Account__c=a1.Id, AMOUNT__C=3000, EXPIRY_DATE__C=system.Today().AddDays(100), FINANCIAL_INSTITUTION__c=FI.Id, SECURITY_STATUS__C='Active', Security_Type__c='GDI', Region__c ='Europe', Reception_Date__c=system.today(), Reasonforrequest__c='New Application', Reception_Case__c=oscarCase.Id);
		insert FS;

		AMS_OSCAR__c oscar = [Select id from AMS_OSCAR__c];

		Test.startTest();

		PageReference pg = Page.ANG_DGIStagingArea;
		pg.getParameters().put('Id', oscar.Id);

		Test.setCurrentPage(pg);

		ANG_DGIStagingAreaCtrl controller = new ANG_DGIStagingAreaCtrl();

		controller.addCertificate = true;

		controller.createStagingAreaDefault();

		controller.createStagingArea();

		controller.hasAdendum = true;

		Boolean hasErrorMessages = controller.hasErrorMessages;
		AMS_Oscar__c oscarObj = controller.oscarObj;
		Case oscarCaseController = controller.oscarCase;
		Boolean isOscarProcessed = controller.oscarProcessed;
		List<String> stagingFields = controller.stagingAreaFields;
		Boolean isWaitingForEndorsement = controller.waitingForEndorsement;
		Boolean isAddCertificate = controller.addCertificate;

		controller.stagingFs.AMOUNT__C = 1000;
		controller.stagingFs.Reason__c = 'New Application';
		controller.stagingFs.Expiry_Date__c = System.Today();

		update controller.stagingFs;

		controller.fetchStagingFs(controller.stagingFs.Id, null);

		controller.accept();

		Test.StopTest();
	}

	@isTest static void acceptAdemdumWithInvalidFsTest() {

		Case oscarCase = [Select id from Case where Oscar__c <> null];

		Account a1 = [Select Id from Account];

		Financial_Institution__c FI = [Select id from Financial_Institution__c];

		Financial_Security__c FS = new Financial_Security__c(
			CURRENCYISOCODE = 'USD', 
			Account__c = a1.Id, 
			AMOUNT__C = 3000,
			EXPIRY_DATE__C = system.Today().AddDays(100), 
			FINANCIAL_INSTITUTION__c = FI.Id, 
			SECURITY_STATUS__C = AMS_Utils.FINANCIAL_SECURITY_STATUS_ACTIVE,
			Security_Type__c = 'Bank Guarantee', 
			Region__c = 'Europe', 
			Reception_Date__c = system.today(), 
			Reasonforrequest__c = 'New Application',
			Reception_Case__c = oscarCase.Id,
			Financial_Security_Validation_Case__c = oscarCase.Id
		);
		insert FS;

		AMS_OSCAR__c oscar = [Select id from AMS_OSCAR__c];

		Test.startTest();

		PageReference pg = Page.ANG_DGIStagingArea;
		pg.getParameters().put('Id', oscar.Id);

		Test.setCurrentPage(pg);

		ANG_DGIStagingAreaCtrl controller = new ANG_DGIStagingAreaCtrl();

		controller.addCertificate = true;

		controller.createStagingAreaDefault();

		controller.createStagingArea();

		controller.hasAdendum = true;

		Boolean hasErrorMessages = controller.hasErrorMessages;
		AMS_Oscar__c oscarObj = controller.oscarObj;
		Case oscarCaseController = controller.oscarCase;
		Boolean isOscarProcessed = controller.oscarProcessed;
		List<String> stagingFields = controller.stagingAreaFields;
		Boolean isWaitingForEndorsement = controller.waitingForEndorsement;
		Boolean isAddCertificate = controller.addCertificate;

		controller.stagingFs.AMOUNT__C = 1000;
		controller.stagingFs.Reason__c = 'New Application';
		controller.stagingFs.Expiry_Date__c = System.Today();

		update controller.stagingFs;

		controller.accept();

		System.assert(findApexPagesMessage(ANG_DGIStagingAreaCtrl.FINANCIAL_SECURITY_ERROR_MESSAGE), 'Expected apex message is: ' + ANG_DGIStagingAreaCtrl.FINANCIAL_SECURITY_ERROR_MESSAGE);

		Test.StopTest();
	}

	private static Boolean findApexPagesMessage(String expectedMessage){

		ApexPages.Message[] pageMessages = ApexPages.getMessages();

		System.assertNotEquals(0, pageMessages.size());

		Boolean messageFound = false;

		for(ApexPages.Message message : pageMessages) {
			if(message.getDetail().contains(expectedMessage)){
				return true;
			}
		}

		return false;

	}
}