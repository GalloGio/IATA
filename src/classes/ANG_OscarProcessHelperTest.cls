@isTest
private class ANG_OscarProcessHelperTest {
	
	private static void loadCredentials() {
        Amazon_Cred__c Amazon_Cred =  new Amazon_Cred__c(name = 'IFAP', Prod_Configuration__c = 'adevconf' , Dev_Configuration__c = 'adevconf');
        Amazon_Cred__c GenericAttach =  new Amazon_Cred__c(name = 'GenericAttach', Prod_Configuration__c = 'adevconf' , Dev_Configuration__c = 'adevconf');
        Amazon_Cred__c recycleBin =  new Amazon_Cred__c(name = 'RecycleBin', Prod_Configuration__c = 'adevconf' , Dev_Configuration__c = 'adevconf');
        List<Amazon_Cred__c> creds = new List<Amazon_Cred__c>();
        creds.add(Amazon_Cred);
        creds.add(GenericAttach);
        creds.add(recycleBin);
        insert creds;


        list<AWSKey__c> AWS_KEYs = new list<AWSKey__c>{
            new AWSKey__c(
                name = 'adevconf',
                Key__c = 'asd', 
                Secret__c = 'asd',  
                IAS_configuration_name__c = 'asdas', 
                IAS_Access_Point__c = 'asd',
                Bucket__c = 'asd',
                AWS_ENDPOINT_URL__c = 'asd')
        };
        insert AWS_KEYs;
    }

	@testSetup static void setup(){

		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='France',ISO_Code__c='FR', ANG_Enable_NewGen__c = true, Region__c = 'Europe')  ;
        insert ctry ;

        IATA_ISO_State__c stt = new IATA_ISO_State__c(Name= 'FR20', ISO_Code__c = 'FR', IATA_ISO_Country__c = ctry.Id);
        insert stt;
		
		Id accountRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');
		Id caseRT = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');
		
		List<Account> accountList = new List<Account>();
		Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountRT ,Name='NewGenAgency',Short_Name__c='NewGenAgency', Location_Class__c = 'P', Location_Type__c = 'HE', Remittance_frequency__c = 'M', Sector__C = 'Travel Agent' , Category__C = 'Non-IATA Passenger Agent', Reason_for_creation__c = 'Account is missing' , Company_Type__c = 'A');

		insert a1;
        
        Contact co1 = new Contact(AccountId = a1.id, Firstname = 'John', Lastname='Rambo', Phone = '666123456', MobilePhone = '911111111', Email = 'rambo.johnj@test.com', Financial_Assessment_Contact__c = false);
		insert co1;

		ID oscarNewHeRt = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'ANG_New_HE');

		AMS_OSCAR__c oscar = new AMS_OSCAR__c(Process__c = AMS_Utils.NEWHESTANDARD, Account__c = a1.id, Is_using_credit_card__c = true, RecordTypeId = oscarNewHeRt);
		insert oscar;

		ID chinaRT = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'ANG_Agency_Changes_China');
		AMS_OSCAR__c oscar_china = new AMS_OSCAR__c(Process__c = AMS_Utils.NGCHINACONVERSION, Account__c = a1.id, Is_using_credit_card__c = true, RecordTypeId = chinaRT);
		insert oscar_china;

		Case oscarCase = new Case(Oscar__c = oscar.Id, RecordTypeId = caseRT);
        oscarCase.AccountId = a1.Id;
        oscarCase.ContactId = co1.Id;
        insert oscarCase;

		EF_AttachmentListController.runningForEF = false;
		loadCredentials();

		AmazonFile__c aFile = new AmazonFile__c(
			Full_Name_Unique__c = 'test name',
			Case__c = oscarCase.Id
		);
		insert aFile;
		
		ID rtNew = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Pax_Accreditation_Form__c','Travel_Agent_Head_Entity_Standard_no_Cash');

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

		ID personRT = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Person');

		AMS_Accreditation_Contact__c acontact = new AMS_Accreditation_Contact__c(AMS_Pax_Accreditation_Form__c = theAccreditation.Id, 
			First_name__c='Bugs', Last_name__c='Bunny', Agency_owner__c = true, Email__c='bugsandbunny@imagsd.com' , PhoneNational__c = '123123123',
			Phone__c='123123123', Contact__c = co1.Id, Financial_interest__c = 100, RecordTypeId=personRT);

		insert acontact;

		oscar.STEP6__c = AMS_Utils.PASSED;
		oscar.AMS_Online_Accreditation__c = theAccreditation.Id;
		oscar.Is_PCI_compliant__c = 'Yes';
		oscar.ANG_PCI_compliance_expiry_date__c = Date.today();
        oscar.Oscar_Communication_Case_Id__c = oscarCase.Id;
		update oscar;


		List<AMS_ChangeCodes__c> changeCodeList = new List<AMS_ChangeCodes__c>{
            new AMS_ChangeCodes__c(
                Name = 'FOP', Change_Code__c = 'FOP', Integration_RecId__c = 'C',Bulletin_Memo_Text__c = 'Agent has complied to Agency Rules. Card payment methods are reinstated.'
            ),
            new AMS_ChangeCodes__c(
                Name = 'PCA', Change_Code__c = 'PCA', Integration_RecId__c = 'C',Bulletin_Memo_Text__c = 'Agent has complied to Agency Rules. Cash and Card payment methods are reinstated.'
            ),
            new AMS_ChangeCodes__c(
                Name = 'PCR', Change_Code__c = 'PCR', Integration_RecId__c = 'C',Bulletin_Memo_Text__c = 'Agent has complied to Agency Rules. Cash payment methods are reinstated.'
            ),
            new AMS_ChangeCodes__c(
                Name = 'CCA', Change_Code__c = 'CCA', Integration_RecId__c = 'C',Bulletin_Memo_Text__c = 'Agent is restricted from using Card form of payment method due to <SIDRA Lite Reason>.'
            ),
            new AMS_ChangeCodes__c(
                Name = 'CCR', Change_Code__c = 'CCR', Integration_RecId__c = 'C',Bulletin_Memo_Text__c = 'Agent is restricted from using Cash and Card payment methods due to <SIDRA Lite Reason>.'
            ),
            new AMS_ChangeCodes__c(
                Name = 'FPR', Change_Code__c = 'FPR', Integration_RecId__c = 'C',Bulletin_Memo_Text__c = 'Agent is restricted from using Cash form of payment method due to <SIDRA Lite Reason>.'
            ),
            new AMS_ChangeCodes__c(
                Name = 'NEW-AMS', Change_Code__c = 'NEW', Integration_RecId__c = 'A'
            ),
            new AMS_ChangeCodes__c(
                Name = 'DOM', 
                Change_Code__c = 'DOM', 
                Integration_RecId__c = 'C', 
                Reason_Code__c = '43', 
                Reason_Code_Description__c = 'Voluntary relinquishment', 
                Bulletin_Memo_Text__c = 'Agent is upgrading from Domestic to International', 
                Published_in_bulletin__c = true,
                Account_status_change__c = '4'
            )
        };

        insert changeCodeList;		
	}

	@isTest static void testIATACodeGenerationOKNoDueDiligenceCase() {

		System.debug('Starting testIATACodeGenerationOKNoDueDiligenceCase');

		AMS_OSCAR__c oscar = [Select Id, Account__c, AMS_Online_Accreditation__c FROM AMS_OSCAR__c LIMIT 1];
		
		Test.startTest();
		
		String[] result = ANG_OscarProcessHelper.processIATACodeGeneration(oscar.Account__c, oscar.AMS_Online_Accreditation__c, oscar.Id);
		
		system.debug('testIATACodeGenerationOKNoDueDiligenceCase Result code is:'+result[0]);
		system.debug('testIATACodeGenerationOKNoDueDiligenceCase Result message is:'+result[1]);

		ANG_OscarProcessHelper.checkSFDCLimits();

		System.assertEquals('0',result[0], result[1]);

		oscar = [Select Id, Flag_IATACode__c, STEP10__c, Flag_Data_to_Account__c, Flag_Data_to_SAPECC__c FROM AMS_OSCAR__c LIMIT 1];

		System.assertEquals(true,oscar.Flag_IATACode__c);
		System.assertEquals(AMS_Utils.PASSED,oscar.STEP10__c);
		System.assertEquals(true,oscar.Flag_Data_to_Account__c);
		System.assertEquals(true,oscar.Flag_Data_to_SAPECC__c);

		Test.stopTest();
	}
	
	@isTest static void testIATACodeGenerationOKWithDueDiligenceCase() {

		System.debug('Starting testIATACodeGenerationOKWithDueDiligenceCase');

		AMS_OSCAR__c oscar = [Select Id, Account__c, AMS_Online_Accreditation__c FROM AMS_OSCAR__c LIMIT 1];
		
		IATA_ISO_Country__c theCountry = [Select id, Due_diligence_mandatory__c from IATA_ISO_Country__c LIMIT 1];
		theCountry.Due_diligence_mandatory__c = true;
		update theCountry;

		Test.startTest();
		
		String[] result = ANG_OscarProcessHelper.processIATACodeGeneration(oscar.Account__c, oscar.AMS_Online_Accreditation__c, oscar.Id);
		
		system.debug('testIATACodeGenerationOKWithDueDiligenceCase Result code is:'+result[0]);
		system.debug('testIATACodeGenerationOKWithDueDiligenceCase Result message is:'+result[1]);

		ANG_OscarProcessHelper.checkSFDCLimits();

		System.assertEquals('0',result[0], result[1]);
		System.assertEquals('0',result[2]); // due diligence was created

		oscar = [Select Id, Flag_IATACode__c, STEP10__c, Flag_Data_to_Account__c, Flag_Data_to_SAPECC__c FROM AMS_OSCAR__c LIMIT 1];

		System.assertEquals(true,oscar.Flag_IATACode__c);
		System.assertEquals(AMS_Utils.PASSED,oscar.STEP10__c);
		System.assertEquals(true,oscar.Flag_Data_to_Account__c);
		System.assertEquals(true,oscar.Flag_Data_to_SAPECC__c);

		Test.stopTest();
	}
	
	@isTest static void testIATACodeGenerationOKTwice() {

		System.debug('Starting testIATACodeGenerationOKTwice');

		AMS_OSCAR__c oscar = [Select Id, Account__c, AMS_Online_Accreditation__c FROM AMS_OSCAR__c LIMIT 1];
		
		IATA_ISO_Country__c theCountry = [Select id, Due_diligence_mandatory__c from IATA_ISO_Country__c LIMIT 1];
		theCountry.Due_diligence_mandatory__c = true;
		update theCountry;

		Test.startTest();
		
		String[] result = ANG_OscarProcessHelper.processIATACodeGeneration(oscar.Account__c, oscar.AMS_Online_Accreditation__c, oscar.Id);

		System.debug('Finished the first IATA Code Generation.');

		system.debug('testIATACodeGenerationOKTwice Result code is:'+result[0]);
		system.debug('testIATACodeGenerationOKTwice Result message is:'+result[1]);

		System.assertEquals('0',result[0], result[1]);

		ANG_OscarProcessHelper.checkSFDCLimits();

		result = ANG_OscarProcessHelper.processIATACodeGeneration(oscar.Account__c, oscar.AMS_Online_Accreditation__c, oscar.Id);

		system.debug('testIATACodeGenerationOKTwice Result code is:'+result[0]);
		system.debug('testIATACodeGenerationOKTwice Result message is:'+result[1]);

		ANG_OscarProcessHelper.checkSFDCLimits();

		System.assertEquals('0',result[0], result[1]);

		oscar = [Select Id, Flag_IATACode__c, STEP10__c, Flag_Data_to_Account__c, Flag_Data_to_SAPECC__c FROM AMS_OSCAR__c LIMIT 1];

		System.assertEquals(true,oscar.Flag_IATACode__c);
		System.assertEquals(AMS_Utils.PASSED,oscar.STEP10__c);
		System.assertEquals(true,oscar.Flag_Data_to_Account__c);
		System.assertEquals(true,oscar.Flag_Data_to_SAPECC__c);

		Test.stopTest();
	}

	@isTest static void testIATACodeGenerationOKAlreadyIATACodeGenerated() {
		
		System.debug('Starting testIATACodeGenerationOKAlreadyIATACodeGenerated');

		AMS_OSCAR__c oscar = [Select Id, Account__c, AMS_Online_Accreditation__c FROM AMS_OSCAR__c LIMIT 1];
		
		oscar.Flag_IATACode__c = true;
		update oscar;

		IATA_ISO_Country__c theCountry = [Select id, Due_diligence_mandatory__c from IATA_ISO_Country__c LIMIT 1];
		theCountry.Due_diligence_mandatory__c = true;
		update theCountry;

		Test.startTest();

		String[] result = ANG_OscarProcessHelper.processIATACodeGeneration(oscar.Account__c, oscar.AMS_Online_Accreditation__c, oscar.Id);

		system.debug('testIATACodeGenerationOKAlreadyIATACodeGenerated Result code is:'+result[0]);
		system.debug('testIATACodeGenerationOKAlreadyIATACodeGenerated Result message is:'+result[1]);

		ANG_OscarProcessHelper.checkSFDCLimits();

		System.assertEquals('0',result[0], result[1]);

		oscar = [Select Id, Flag_IATACode__c, STEP10__c, Flag_Data_to_Account__c, Flag_Data_to_SAPECC__c FROM AMS_OSCAR__c LIMIT 1];

		System.assertEquals(true,oscar.Flag_IATACode__c);
		System.assertEquals(AMS_Utils.PASSED,oscar.STEP10__c);
		System.assertEquals(true,oscar.Flag_Data_to_Account__c);
		System.assertEquals(true,oscar.Flag_Data_to_SAPECC__c);

		Test.stopTest();
	}

	@isTest static void testIATACodeGenerationOKAlreadyDataCopied() {
		
		System.debug('Starting testIATACodeGenerationOKAlreadyDataCopied');

		AMS_OSCAR__c oscar = [Select Id, Account__c, AMS_Online_Accreditation__c FROM AMS_OSCAR__c LIMIT 1];
		
		oscar.Flag_Data_to_Account__c = true;
		update oscar;

		Test.startTest();
		
		String[] result = ANG_OscarProcessHelper.processIATACodeGeneration(oscar.Account__c, oscar.AMS_Online_Accreditation__c, oscar.Id);

		system.debug('testIATACodeGenerationOKAlreadyDataCopied Result code is:'+result[0]);
		system.debug('testIATACodeGenerationOKAlreadyDataCopied Result message is:'+result[1]);

		ANG_OscarProcessHelper.checkSFDCLimits();

		System.assertEquals('0',result[0], result[1]);

		oscar = [Select Id, Flag_IATACode__c, STEP10__c, Flag_Data_to_Account__c, Flag_Data_to_SAPECC__c FROM AMS_OSCAR__c LIMIT 1];

		System.assertEquals(true,oscar.Flag_IATACode__c);
		System.assertEquals(AMS_Utils.PASSED,oscar.STEP10__c);
		System.assertEquals(true,oscar.Flag_Data_to_Account__c);
		System.assertEquals(true,oscar.Flag_Data_to_SAPECC__c);

		Test.stopTest();
	}


	@isTest static void testIATACodeGenerationOKAlreadyChangeCodeNew() {
		
		System.debug('Starting testIATACodeGenerationOKAlreadyChangeCodeNew');

		AMS_OSCAR__c oscar = [Select Id, Account__c, AMS_Online_Accreditation__c FROM AMS_OSCAR__c LIMIT 1];
		
		IATA_ISO_Country__c theCountry = [Select id, Due_diligence_mandatory__c from IATA_ISO_Country__c LIMIT 1];
		theCountry.Due_diligence_mandatory__c = true;
		update theCountry;

		Test.startTest();

		ANG_OscarProcessHelper.isIATACodeGenerationRunning = true;

        Agency_Applied_Change_code__c aacc = new Agency_Applied_Change_code__c(Account__c = oscar.Account__c, OSCAR__c = oscar.Id, Change_Code__c = 'NEW',  Sent_to_external_system__c = false);

        insert aacc;
		
		String[] result = ANG_OscarProcessHelper.processIATACodeGeneration(oscar.Account__c, oscar.AMS_Online_Accreditation__c, oscar.Id);

		system.debug('testIATACodeGenerationOKAlreadyChangeCodeNew Result code is:'+result[0]);
		system.debug('testIATACodeGenerationOKAlreadyChangeCodeNew Result message is:'+result[1]);

		ANG_OscarProcessHelper.checkSFDCLimits();

		System.assertEquals('0',result[0], result[1]);

		oscar = [Select Id, Flag_IATACode__c, STEP10__c, Flag_Data_to_Account__c, Flag_Data_to_SAPECC__c FROM AMS_OSCAR__c LIMIT 1];

		System.assertEquals(true,oscar.Flag_IATACode__c);
		System.assertEquals(AMS_Utils.PASSED,oscar.STEP10__c);
		System.assertEquals(true,oscar.Flag_Data_to_Account__c);
		System.assertEquals(true,oscar.Flag_Data_to_SAPECC__c);

		Test.stopTest();
	}

	@isTest static void testIATACodeGenerationOKWithDueDiligenceCaseInProgress() {

		System.debug('Starting testIATACodeGenerationOKWithDueDiligenceCaseInProgress');

		AMS_OSCAR__c oscar = [Select Id, Account__c, AMS_Online_Accreditation__c FROM AMS_OSCAR__c LIMIT 1];
		
		IATA_ISO_Country__c theCountry = [Select id, Due_diligence_mandatory__c from IATA_ISO_Country__c LIMIT 1];
		theCountry.Due_diligence_mandatory__c = true;
		update theCountry;

		Account acct = new Account(id = oscar.Account__c);
		acct.Due_Diligence_Status__c = AMS_Utils.IN_PROGRESS;
		update acct;

		Test.startTest();
		
		String[] result = ANG_OscarProcessHelper.processIATACodeGeneration(oscar.Account__c, oscar.AMS_Online_Accreditation__c, oscar.Id);
		
		system.debug('testIATACodeGenerationOKWithDueDiligenceCaseInProgress Result code is:'+result[0]);
		system.debug('testIATACodeGenerationOKWithDueDiligenceCaseInProgress Result message is:'+result[1]);

		ANG_OscarProcessHelper.checkSFDCLimits();

		System.assertEquals('0',result[0], result[1]);

		oscar = [Select Id, Flag_IATACode__c, STEP10__c, Flag_Data_to_Account__c, Flag_Data_to_SAPECC__c FROM AMS_OSCAR__c LIMIT 1];

		System.assertEquals(true,oscar.Flag_IATACode__c);
		System.assertEquals(AMS_Utils.PASSED,oscar.STEP10__c);
		System.assertEquals(true,oscar.Flag_Data_to_Account__c);
		System.assertEquals(true,oscar.Flag_Data_to_SAPECC__c);

		Test.stopTest();
	}

 	@isTest static void testIATACodeGenerationOKWithNOSTEP6PASSED() {
		
		System.debug('Starting testIATACodeGenerationOKWithNOSTEP6PASSED');

		AMS_OSCAR__c oscar = [Select Id, Account__c, AMS_Online_Accreditation__c FROM AMS_OSCAR__c LIMIT 1];
		
		oscar.STEP6__c = AMS_Utils.IN_PROGRESS;
		update oscar;

		Test.startTest();
		
		String[] result = ANG_OscarProcessHelper.processIATACodeGeneration(oscar.Account__c, oscar.AMS_Online_Accreditation__c, oscar.Id);
		
		system.debug('testIATACodeGenerationOKWithNOSTEP6PASSED Result code is:'+result[0]);
		system.debug('testIATACodeGenerationOKWithNOSTEP6PASSED Result message is:'+result[1]);

		ANG_OscarProcessHelper.checkSFDCLimits();

		System.assertEquals('-1',result[0]);

		oscar = [Select Id, Flag_IATACode__c, STEP10__c, Flag_Data_to_Account__c, Flag_Data_to_SAPECC__c FROM AMS_OSCAR__c LIMIT 1];

		System.debug('Oscar is:'+oscar);

		System.assertEquals(false,oscar.Flag_IATACode__c);
		System.assertNotEquals(AMS_Utils.PASSED,oscar.STEP10__c);
		System.assertEquals(false,oscar.Flag_Data_to_Account__c);
		System.assertEquals(false,oscar.Flag_Data_to_SAPECC__c);

		Test.stopTest();
	}


	@isTest static void testIATACodeGenerationBadDataMigration() {
		
		System.debug('Starting testIATACodeGenerationBadDataMigration');

		AMS_OSCAR__c oscar = [Select Id, Account__c, AMS_Online_Accreditation__c FROM AMS_OSCAR__c LIMIT 1];
		
				
		
		AMS_Pax_Accreditation_Form__c theAccreditation = new AMS_Pax_Accreditation_Form__c(id = oscar.AMS_Online_Accreditation__c);
		theAccreditation.Branch_Office_Email__c='sdf+dfgdg@~df3434.comsdsd';
		update theAccreditation;

		Test.startTest();
		
		String[] result = ANG_OscarProcessHelper.processIATACodeGeneration(oscar.Account__c, oscar.AMS_Online_Accreditation__c, oscar.Id);
		
		system.debug('testIATACodeGenerationBadDataMigration Result code is:'+result[0]);
		system.debug('testIATACodeGenerationBadDataMigration Result message is:'+result[1]);

		ANG_OscarProcessHelper.checkSFDCLimits();

		System.assertEquals('-1',result[0]);

		oscar = [Select Id, Flag_IATACode__c, STEP10__c, Flag_Data_to_Account__c, Flag_Data_to_SAPECC__c FROM AMS_OSCAR__c LIMIT 1];

		System.debug('Oscar is:'+oscar);

		System.assertEquals(false,oscar.Flag_IATACode__c);
		System.assertEquals(false,oscar.Flag_Data_to_Account__c);
		System.assertEquals(false,oscar.Flag_Data_to_SAPECC__c);

		Test.stopTest();
	}

	@isTest static void testFOPCreation() {

        Test.startTest();

        Account a = [Select Id, BillingCountry from Account LIMIT 1];

		ID FormOfPaymentRT = RecordTypeSingleton.getInstance().getRecordTypeId('Agency_Authorization__c','FormOfPayment');

		List<Agency_Authorization__c> authorizations = new List<Agency_Authorization__c>();

        authorizations.add(new Agency_Authorization__c(Account__c = a.Id, ANG_FormOfPayment_ID__c = 'CC', Status__c = 'Active', RecordTypeId = FormOfPaymentRT));
        authorizations.add(new Agency_Authorization__c(Account__c = a.Id, ANG_FormOfPayment_ID__c = 'CA', Status__c = 'Active', RecordTypeId = FormOfPaymentRT));
        insert authorizations;

        Map<String,Object> fieldsOfObject = new Map<String,Object>();

        fieldsOfObject.clear();
		fieldsOfObject.put('Process__c',AMS_Utils.NGFOP);

		AMS_Oscar__c oscar = ANG_EntityCreator.createOscar(AMS_Utils.RECTYPE_NEWGENFOP, a.Id, fieldsOfObject);
		insert oscar;

		Id caseRT = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');

        fieldsOfObject.clear();
        fieldsOfObject.put('Oscar__c',oscar.Id);
        fieldsOfObject.put('BSPCountry__c',a.BillingCountry);
        fieldsOfObject.put('CaseArea__c','Accreditation Process');
        fieldsOfObject.put('Origin','Internal User');
        fieldsOfObject.put('Reason1__c','FoP Management');
        fieldsOfObject.put('Subject','FoP Management - ');
        fieldsOfObject.put('Type_of_customer__c','IATA Travel Agent');

        Case newCaseFop =ANG_EntityCreator.createCase(caseRT, a.Id, fieldsOfObject);
        insert newCaseFop;

    	ANG_OscarProcessHelper.processRestrictFOP(oscar.Id, true , true);

    	ANG_OscarProcessHelper.processRestoreFOP(oscar.Id, true , true);

        Test.stopTest();
	 }

	@isTest static void testFOPCreation2() {

        Test.startTest();

        Account a = [Select Id, BillingCountry from Account LIMIT 1];

		ID FormOfPaymentRT = RecordTypeSingleton.getInstance().getRecordTypeId('Agency_Authorization__c','FormOfPayment');

		List<Agency_Authorization__c> authorizations = new List<Agency_Authorization__c>();

        authorizations.add(new Agency_Authorization__c(Account__c = a.Id, ANG_FormOfPayment_ID__c = 'CC', Status__c = 'Active', RecordTypeId = FormOfPaymentRT));
        authorizations.add(new Agency_Authorization__c(Account__c = a.Id, ANG_FormOfPayment_ID__c = 'CA', Status__c = 'Active', RecordTypeId = FormOfPaymentRT));
        insert authorizations;

        Map<String,Object> fieldsOfObject = new Map<String,Object>();

        fieldsOfObject.clear();
		fieldsOfObject.put('Process__c',AMS_Utils.NGFOP);
		fieldsOfObject.put('SIDRA_lite_reason__c','FOP Management');

		AMS_Oscar__c oscar = ANG_EntityCreator.createOscar(AMS_Utils.RECTYPE_NEWGENFOP, a.Id, fieldsOfObject);
		insert oscar;

		Id caseRT = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');

        fieldsOfObject.clear();
        fieldsOfObject.put('Oscar__c',oscar.Id);
        fieldsOfObject.put('BSPCountry__c',a.BillingCountry);
        fieldsOfObject.put('CaseArea__c','Accreditation Process');
        fieldsOfObject.put('Origin','Internal User');
        fieldsOfObject.put('Reason1__c','FoP Management');
        fieldsOfObject.put('Subject','FoP Management - ');
        fieldsOfObject.put('Type_of_customer__c','IATA Travel Agent');

        Case newCaseFop =ANG_EntityCreator.createCase(caseRT, a.Id, fieldsOfObject);
        insert newCaseFop;

    	ANG_OscarProcessHelper.processRestrictFOP(oscar.Id, false , true);

    	ANG_OscarProcessHelper.processRestoreFOP(oscar.Id, true , false);

        Test.stopTest();
	 }

	@isTest static void testFOPCreation3() {

        Test.startTest();

        Account a = [Select Id from Account LIMIT 1];

        Case c = [Select Id from Case LIMIT 1];

		ANG_OscarProcessHelper.createFOPOscar(a.Id, c.Id);
		ANG_OscarProcessHelper.fakemethod();

        Test.stopTest();
	 }

	@isTest static void testAnnualRevalidation() {

		AMS_ChangeCodes__c configCC = new AMS_ChangeCodes__c (Name = 'ARV', Change_code__c = 'ARV', Bulletin_Memo_Text__c = 'Test Annual Revalidation Non-Compliance', Published_in_bulletin__c = true, Integration_RecId__c = 'c');

		insert configCC;

		List<Group> testGroupList = [SELECT name FROM Group WHERE Type = 'Queue' and Name = 'Cases - France'];
		system.debug('Group :::: ' + testGroupList);

		System.runAs(new User(Id=UserInfo.getUserId()))
		{
			List<QueuesObject> testQueuesList = new List<QueuesObject>();
			testQueuesList.add(new QueueSObject(QueueId = testGroupList.get(0).id, SObjectType = 'AMS_OSCAR__c'));
			testQueuesList.add(new QueueSObject(QueueId = testGroupList.get(0).id, SObjectType = 'Case'));
			Database.insert(testQueuesList);
		}


		Account a = [select Abbreviated_address__c, Abbreviated_name__c,
						BillingState,
						BillingCity,
						Email__c,
						Fax,
						Phone,
						BillingPostalCode,
						BillingStreet,
						CASS_Number__c,
						BillingCountry,
						Name,
						Region_formula__c,
						ANG_Accreditation_Model__c,
						Id,
						Iata_iso_country__c,
						IATACode__c,
						Iso_State__c,
						GDS__c,
						Company_Type__c,
						License_Number__c,
						VAT_Number__c,
						Is_your_firm_handling_Dangerous_Goods__c,
						Location_Class__c,
						Location_Type__c,
						Mobile__c,
						Operation__c,
						Remittance_frequency__c,
						ShippingCity,
						ShippingCountry,
						IATA_ISO_Shipping_Country__c,
						IATA_ISO_Shipping_State__c,
						ShippingPostalCode,
						ShippingState,
						ShippingStreet,
						Short_Name__c,
						Solicitation_Flag__c,
						TradeName__c,
						VAT_Number_2__c,
						Website from account limit 1];

		a.IATACode__c = '7463812';
		a.Reason__c = '91-ACCREDITED-MEET-STANDARDS';

		update a;

	/*	a = [select Abbreviated_address__c, Abbreviated_name__c,
						BillingState,
						BillingCity,
						Email__c,
						Fax,
						Phone,
						BillingPostalCode,
						BillingStreet,
						CASS_Number__c,
						BillingCountry,
						Name,
						Region_formula__c,
						ANG_Accreditation_Model__c,
						Id,
						Iata_iso_country__c,
						IATACode__c,
						Iso_State__c,
						GDS__c,
						Company_Type__c,
						License_Number__c,
						VAT_Number__c,
						Is_your_firm_handling_Dangerous_Goods__c,
						Location_Class__c,
						Location_Type__c,
						Mobile__c,
						Operation__c,
						Remittance_frequency__c,
						ShippingCity,
						ShippingCountry,
						IATA_ISO_Shipping_Country__c,
						IATA_ISO_Shipping_State__c,
						ShippingPostalCode,
						ShippingState,
						ShippingStreet,
						Short_Name__c,
						Solicitation_Flag__c,
						TradeName__c,
						VAT_Number_2__c,
						Reason__c,
						Website from account limit 1]; 
	*/
        
		List<Contact> conts = [select Id, Name, Email, Preferred_Language__c, BSP_CASS_Payment_contact__c, Financial_Assessment_Contact__c, User_Portal_Status__c, AccountId from contact where accountid =:a.id];
		
		Test.startTest();

		// Test Oscar Creation
		String caseId = ANG_OscarProcessHelper.createRevalidationOscar(a, conts, true);

		List<AMS_Oscar__c> oscars = [select id, step43__c, step44__c, (Select id from Cases__r) from AMS_Oscar__c where Account__c = :a.Id and Process__c = :AMS_Utils.NGANNUALREVAL];

		System.assertEquals(1, oscars.size(), '1 Oscar record should to be created for this account');
		System.assertEquals(1, oscars[0].cases__r.size(), '1 case record should to be created for the account');
		
		// test Change Code and SIDRA Lite creation
		oscars[0].step43__c = 'Failed';
		oscars[0].step44__c = 'Failed';

		update oscars;

		System.assertEquals(1, [Select id from Agency_Applied_Change_code__c where change_code__c = 'ARV'].size(), '1 ARV change code should be created');

		AMS_OSCAR_Webservice.createSIDRALite(oscars[0].Id, '44',true);

		System.assertEquals(1, [Select id from Case where SIDRA_lite_reason__c = 'Annual Revalidation Non-Compliance' and RecordType.Name= 'SIDRA Lite'].size(), '1 Sidra Lite Case should be created');

		Test.stopTest();

	}

	 	@isTest static void testFetchKeyContact() {
			
			IATA_ISO_Country__c ctry = [Select Id from IATA_ISO_Country__c where Name='France'];
			Id accountRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');

			Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountRT ,Name='NewGenAgency',Short_Name__c='NewGenAgency', Location_Class__c = 'P', Location_Type__c = 'HE', Remittance_frequency__c = 'M', Sector__C = 'Travel Agent' , Category__C = 'IATA Passenger Sales Agent', Reason_for_creation__c = 'Account is missing' , Company_Type__c = 'A', IATACode__c = '1234567', Status__c = 'Approved');
			insert a1;

			Test.startTest();

			//Contact co2 = new Contact(AccountId = a1.id, Firstname = 'John1', Lastname='Rambo', Phone = '666123456', MobilePhone = '911111111', Email = 'rambo.john1j@test.com', User_Portal_Status__c = 'Approved Admin');
			Contact co1 = new Contact(AccountId = a1.id, Firstname = 'John', Lastname='Rambo', Phone = '666123456', MobilePhone = '911111111', Email = 'rambo.johnj4@test.com');
			Contact co3 = new Contact(AccountId = a1.id, Firstname = 'John2', Lastname='Rambo', Phone = '666123456', MobilePhone = '911111111', Email = 'rambo.john2j@test.com', Financial_Assessment_Contact__c = true);
			Contact co4 = new Contact(AccountId = a1.id, Firstname = 'John3', Lastname='Rambo', Phone = '666123456', MobilePhone = '911111111', Email = 'rambo.john3j@test.com', BSP_CASS_Payment_contact__c = true);

			List<Contact> contactsInserted =  new List<Contact>{co1,co4,co3};
			insert contactsInserted;
			
	

			List<Contact> contactsOrdered = ANG_OscarProcessHelper.fetchKeyContacts(a1, contactsInserted);

			System.debug(contactsOrdered);

			//System.assertEquals(co2, contactsOrdered.get(0));
			System.assertEquals(co3, contactsOrdered.get(0));
			System.assertEquals(co4, contactsOrdered.get(1));
			System.assertEquals(co1, contactsOrdered.get(2));

			Test.stopTest();

		}


	@isTest static void createGenericChangeCodeTest() {

		IATA_ISO_Country__c ctry = [Select Id from IATA_ISO_Country__c where Name = 'France'];
		Id accountRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');

		Account a1 = new Account(IATA_ISO_Country__c = ctry.id, RecordTypeId = accountRT, Name='NewGenAgency',Short_Name__c='NewGenAgency', Location_Class__c = 'D', Location_Type__c = 'HE', Remittance_frequency__c = 'M', Sector__C = 'Travel Agent', Category__C = 'IATA Passenger Sales Agent', Reason_for_creation__c = 'Account is missing', Company_Type__c = 'A', IATACode__c = '1234567', Status__c = 'Approved');
		insert a1;

		ID chinaRT = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'ANG_Agency_Changes_China');
		AMS_OSCAR__c oscar_china = new AMS_OSCAR__c(Process__c = AMS_Utils.NGCHINACONVERSION, Account__c = a1.id, Is_using_credit_card__c = true, RecordTypeId = chinaRT, ANG_Type_Of_Change__c = 'Conversion to International');
		insert oscar_china;

		List<AMS_Oscar__c> oscars = [select id, Account__c, Process__c, Is_NewGen__c, RecordTypeId, ANG_Type_Of_Change__c from AMS_Oscar__c where Process__c = :AMS_Utils.NGCHINACONVERSION AND Account__c = :a1.Id limit 1];

		Test.startTest();

		ANG_OscarProcessHelper.createGenericChangeCode(oscars[0], 'DOM');

		List<Agency_Applied_Change_code__c> changeCodes = [select Reason_Code__c, Reason_Description__c, Bulletin_Information__c, To_Publish_in_e_Bulletin__c from Agency_Applied_Change_code__c where Change_Code__c = 'DOM' and OSCAR__c = :oscars[0].id and Account__c = :oscars[0].Account__c];

		System.assertEquals('43', changeCodes[0].Reason_Code__c);
		System.assertEquals('VOLUNTARY RELINQUISHMENT', changeCodes[0].Reason_Description__c);
		System.assertEquals('AGENT IS UPGRADING FROM DOMESTIC TO INTERNATIONAL', changeCodes[0].Bulletin_Information__c);
		System.assertEquals(true, changeCodes[0].To_Publish_in_e_Bulletin__c);	
	
		Test.stopTest();
	}
}