@isTest
private class AMS_AccreditationContactControllerTest
{

    static Account acc;
    static Account accBR;
	static String accountAgencyRtId;
	static String accountStandardRtId;
	static String acContactRtId;
	static String acCompanyRtId;
	static AMS_Pax_Accreditation_Form__c aoa;
	static AMS_Accreditation_Contact__c ac;
	
	
	 @testSetup static void setupTestData()
    {
		IATA_ISO_Country__c isoc = new IATA_ISO_Country__c(Name = 'Test', ISO_Code__c = 'TS');       
        insert isoc;

		Id accRtId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

        List<Account> accs = new List<Account>();

        Account acc1 = new Account(Name='LegalName', Location_Type__c = 'HO', Email__c = 'test@test.com', Type='CASS Associate', Sector__c = 'Travel Agent', IATA_ISO_Country__c = isoc.id, IATAcode__c = '12345678', AIMS_ID__c = '12345678', Source_System__c = 'AIMS2', Legal_Name__c = 'LegalName', RecordTypeId = accRtId);
        Account acc2 = new Account(Name='LegalName2', Location_Type__c = 'BR', Email__c = 'test2@test.com', Type='CASS Associate', Sector__c = 'Travel Agent', IATA_ISO_Country__c = isoc.id, IATAcode__c = '12345672', AIMS_ID__c = '12345672', Source_System__c = 'AIMS2', Phone_Number__c = '638273481', RecordTypeId = accRtId);
        accs.add(acc1);
        accs.add(acc2);
        insert accs;
        
        Case testCase = ISSP_ObjectFactory.createNewCase();
        testCase.BSPCountry__c = 'Hong Kong (SAR), China';
        testCase.Reason1__c = 'Agency';
        testCase.Customer_recovery__c = false;
        //testCase.New_AWB_only_to_be_used_after_17Mar_200__c = false;
        testCase.BounceEmailCounter__c = 0.0;
        testCase.Case_Language__c = 'English';
        testCase.Subject = 'Test 006';
        testCase.Reopened_case__c = 0.0;
        //testCase.Continous_Feed_SAF__c = true;
        testCase.Account_Concerned__c = acc1.Id;
		testCase.IFAP_Country_ISO__c = 'tq';
        testCase.AccountId = acc1.id;
        insert testCase;
        
		AMS_Pax_Accreditation_Form__c onlineAccreditation = new AMS_Pax_Accreditation_Form__c(IsGSA__c = 'No', CurrencyIsoCode = isoc.CurrencyIsoCode, SAAM_Case__c = testCase.Id);
		insert onlineAccreditation;

        Contact c1 = new Contact(AccountId = acc1.id, Firstname = 'John', Lastname='Doe', Phone = '911111111', MobilePhone = '911111111', Email = 'jd@test.com', 
            Financial_Assessment_Contact__c = false, RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact'));
        insert c1;

        AMS_Person__c p1 = new AMS_Person__c(Name='Jane', LastName__c='Doe', First_Name__c='Jane', Email__c='janed@email.com');
        insert p1;
		
		List<AMS_Accreditation_Contact__c> acList = new List<AMS_Accreditation_Contact__c>();
		acList.add(new AMS_Accreditation_Contact__c(AMS_Pax_Accreditation_Form__c = onlineAccreditation.Id, First_name__c = 'NameToUse', Last_name__c = 'Last', 
            Job_title__c = 'ABC', Mobile__c = '+4112345678', Phone__c = '3424322343', Email__c = 'unique@email.com', 
            RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Person')));

        acList.add(new AMS_Accreditation_Contact__c(AMS_Pax_Accreditation_Form__c = onlineAccreditation.Id, First_name__c='NameToUse2', Last_name__c='Last2', 
            Job_title__c='ABC2', Mobile__c='+41123456782', Phone__c='34243223432', Email__c='unique2@email.com', Contact__c = c1.Id, 
            RecordTypeId=RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Person')));

        acList.add(new AMS_Accreditation_Contact__c(AMS_Pax_Accreditation_Form__c = onlineAccreditation.Id, First_name__c='NameToUse3', 
            Last_name__c='Last3', Job_title__c='ABC3', Mobile__c='+41123456783', Phone__c='34243223433', Email__c='unique3@email.com', Person_AMS__c = p1.Id, 
            RecordTypeId=RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Person')));

        acList.add(new AMS_Accreditation_Contact__c(AMS_Pax_Accreditation_Form__c = onlineAccreditation.Id, First_name__c='Joan', Last_name__c='Wylde', 
            Phone__c='323562762', Email__c='jw@email.com', Valid_Until__c = Date.today(), 
            RecordTypeId=RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Trained_Staff')));

        acList.add(new AMS_Accreditation_Contact__c(AMS_Pax_Accreditation_Form__c = onlineAccreditation.Id, Last_name__c = 'TEST', Financial_interest__c = 0, 
            Company__c=acc2.Id, RecordTypeId=RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Company')));

        acList.add(new AMS_Accreditation_Contact__c(AMS_Pax_Accreditation_Form__c = onlineAccreditation.Id, Last_name__c = 'TEST2', 
            Financial_interest__c = 0, RecordTypeId=RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Company')));

		insert acList;
    }
	
	static void setup()
    {
        accountAgencyRtId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
        aoa = [select id from AMS_Pax_Accreditation_Form__c].get(0);
        ac = [select id from AMS_Accreditation_Contact__c].get(0);
        List<Account> accounts = [select id, Location_Type__c from Account];
        for(Account account: accounts){
            if(account.Location_Type__c == AMS_Utils.HO)
                acc = account;
            if(account.Location_Type__c == AMS_Utils.BR)
                accBR = account;
        }
     	
    }

    @isTest
	static void testAddingNewContactAndCompanyRowsSucceeds()
    {
        setup();
        
        Test.startTest();
        	ApexPages.StandardController sc = new ApexPages.StandardController(aoa);
			AMS_AccreditationContactController ctrl = new AMS_AccreditationContactController(sc);
            
            PageReference pageRef = Page.AMSAccreditationContact;
            pageRef.getParameters().put('id', String.valueOf(aoa.Id));
            Test.setCurrentPage(pageRef);
            
            ctrl.cloneLastRow();
          	System.assertEquals(4, ctrl.acWrapper.size());
          	ctrl.addEmptyRow();
          	System.assertEquals(5, ctrl.acWrapper.size());
          	ctrl.toUnselect = 2;
          	ctrl.removeFromAcList();
          	System.assertEquals(4, ctrl.acWrapper.size());
          	System.assertEquals(2, ctrl.accountWrapper.size());
        	ctrl.addEmptyCompanyRow();
        	System.assertEquals(3, ctrl.accountWrapper.size());
        	ctrl.toUnselect = 0;
        	ctrl.removeFromAccountList();
        	System.assertEquals(2, ctrl.accountWrapper.size());
        	ctrl.onCancel();
        Test.stopTest();
    }
    
    
    @isTest
	static void testContactAndPersonLinkingSucceeds()
    {
        setup();
        
        Test.startTest();
        	ApexPages.StandardController sc = new ApexPages.StandardController(aoa);
			AMS_AccreditationContactController ctrl = new AMS_AccreditationContactController(sc);
            
            PageReference pageRef = Page.AMSAccreditationContact;
            pageRef.getParameters().put('id', String.valueOf(aoa.Id));
            Test.setCurrentPage(pageRef);
            
            Contact c1 = new Contact(AccountId = acc.id, Firstname = 'c1ObsoleteName', Lastname='c1LastName', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com', Financial_Assessment_Contact__c = false);
        	insert c1;
        	
        	ctrl.rowNumber = '00000000000000000000000000000000000000000000000000000000';
        	ctrl.linkedRecordId = c1.Id;
        	ctrl.acWrapper.get(0).ac.Financial_interest__c = 100;
        	ctrl.acWrapper.get(0).ac.Agency_owner__c = true;
        	ctrl.linkACwithContactOrPersonSelection();
        	ctrl.onSave();
        	System.assertEquals(ctrl.acWrapper.get(0).recordId, c1.id);
        	AMS_Person__c p1 = new AMS_Person__c(Name='test1', LastName__c='LastName', First_Name__c='FirstNameNotToUse', Email__c='unique@email.com');
        	insert p1;
        	
        	ctrl.linkedRecordId = p1.Id;
        	ctrl.linkACwithContactOrPersonSelection();
        	ctrl.onSave();
        	System.assertEquals(ctrl.acWrapper.get(0).recordId, p1.id);
        Test.stopTest();
    }
    
    @isTest
	static void testAccountLinkingSucceeds()
    {
        setup();
        
        Test.startTest();
        	ApexPages.StandardController sc = new ApexPages.StandardController(aoa);
			AMS_AccreditationContactController ctrl = new AMS_AccreditationContactController(sc);
            
            PageReference pageRef = Page.AMSAccreditationContact;
            pageRef.getParameters().put('id', String.valueOf(aoa.Id));
            Test.setCurrentPage(pageRef);
            
        	
        	ctrl.rowNumber = '20000000000000000000000000000000000000000000000000000000';
        	ctrl.addEmptyCompanyRow();
        	ctrl.accountWrapper.get(2).financialInterest = 100;
        	ctrl.linkedRecordId = acc.Id;
        	ctrl.linkAccountWithAccountSelection();
        	ctrl.onSave();
        	System.assertEquals(ctrl.accountWrapper.get(2).recordId, acc.id);
        Test.stopTest();
    }
    
    @isTest
	static void testPopUpControllerWithContactSearch()
    {
        setup();
        
        Contact c1 = new Contact(AccountId = acc.id, Firstname = 'c1ObsoleteName', Lastname='c1LastName', Phone = '911111111', MobilePhone = '911111111', 
            Email = 'test@test.com', Financial_Assessment_Contact__c = false, RecordTypeId =RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact'));
        insert c1;
        
        Test.startTest();
            PageReference pageRef = Page.AMSAccreditationContactLookup;
            pageRef.getParameters().put('object', 'contact');
            pageRef.getParameters().put('fieldId', 'fake:fieldId');
            pageRef.getParameters().put('firstName', 'c1ObsoleteName');
            pageRef.getParameters().put('lastName', 'c1LastName');
            pageRef.getParameters().put('email', 'test@test.com');
            pageRef.getParameters().put('legalName', '');
            Test.setCurrentPage(pageRef);
            
            AMS_AccreditationContactLookUpController lookupCtrl = new AMS_AccreditationContactLookUpController();
        	
        	System.assertEquals(1, lookupCtrl.wrapper.size());
        Test.stopTest();
    }
    
    @isTest
	static void testPopUpControllerWithAccountSearch()
    {
        setup();
        
        Contact c1 = new Contact(AccountId = acc.id, Firstname = 'c1ObsoleteName', Lastname='c1LastName', Phone = '911111111', MobilePhone = '911111111', 
            Email = 'test@test.com', Financial_Assessment_Contact__c = false, RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact'));
        insert c1;
        
        Test.startTest();
            PageReference pageRef = Page.AMSAccreditationContactLookup;
            pageRef.getParameters().put('object', 'account');
            pageRef.getParameters().put('fieldId', 'fake:fieldId');
            pageRef.getParameters().put('firstName', 'c1ObsoleteName');
            pageRef.getParameters().put('lastName', 'c1LastName');
            pageRef.getParameters().put('email', 'test@test.com');
            pageRef.getParameters().put('legalName', 'LegalName');
            Test.setCurrentPage(pageRef);
            
            AMS_AccreditationContactLookUpController lookupCtrl = new AMS_AccreditationContactLookUpController();
        	
        	System.assertEquals(2, lookupCtrl.accWrapper.size());
            System.assertEquals(null, lookupCtrl.accWrapper[0].registrationNumber);
        Test.stopTest();
    }
    
    @isTest
	static void testPopUpControllerWithPersonSearch()
    {
        setup();
        
        AMS_Person__c p1 = new AMS_Person__c(Name='c1ObsoleteName', LastName__c='c1LastName', First_Name__c='c1ObsoleteName', Email__c='test@test.com');
        insert p1;
        
        Test.startTest();
            PageReference pageRef = Page.AMSAccreditationContactLookup;
            pageRef.getParameters().put('object', 'contact');
            pageRef.getParameters().put('fieldId', 'fake:fieldId');
            pageRef.getParameters().put('firstName', 'c1ObsoleteName');
            pageRef.getParameters().put('lastName', 'c1LastName');
            pageRef.getParameters().put('email', 'test@test.com');
            pageRef.getParameters().put('legalName', '');
            Test.setCurrentPage(pageRef);
            
            AMS_AccreditationContactLookUpController lookupCtrl = new AMS_AccreditationContactLookUpController();
            
            System.assertEquals(1, lookupCtrl.wrapper.size());
        Test.stopTest();
    }

    @isTest
	static void testPopUpControllerErrors() {
        setup();
        
        Test.startTest();
            PageReference pageRef = Page.AMSAccreditationContactLookup;
            pageRef.getParameters().put('fieldId', 'fake:fieldId');
            Test.setCurrentPage(pageRef);

            ApexPages.currentPage().getParameters().put('object', 'error');
            AMS_AccreditationContactLookUpController noObject = new AMS_AccreditationContactLookUpController();

            ApexPages.currentPage().getParameters().put('object', 'account');
            ApexPages.currentPage().getParameters().put('legalName', '');
            AMS_AccreditationContactLookUpController noLegalName = new AMS_AccreditationContactLookUpController();

            pageRef.getParameters().put('legalName', 'ErrorLegalName');
            AMS_AccreditationContactLookUpController noAccount = new AMS_AccreditationContactLookUpController();

            ApexPages.currentPage().getParameters().put('object', 'contact');
            ApexPages.currentPage().getParameters().put('email', '');
            ApexPages.currentPage().getParameters().put('lastName', '');
            AMS_AccreditationContactLookUpController noContactName = new AMS_AccreditationContactLookUpController();

            ApexPages.currentPage().getParameters().put('email', 'errortest@test.com');
            ApexPages.currentPage().getParameters().put('lastName', 'errorName');
            pageRef.getParameters().put('firstName', 'errorName');
            AMS_AccreditationContactLookUpController noValues = new AMS_AccreditationContactLookUpController();
            
        Test.stopTest();
    }

    @isTest
	static void testaddTrainedStaff()
    {
        setup();
        
        Test.startTest();
            ApexPages.StandardController sc = new ApexPages.StandardController(aoa);
            AMS_AccreditationContactController ctrl = new AMS_AccreditationContactController(sc);
            
            //add owner from contact
            Contact c1 = new Contact(AccountId = acc.id, Firstname = 'c1ObsoleteName', Lastname='c1LastName', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com', Financial_Assessment_Contact__c = false);
            insert c1; 

            ctrl.toNullify = 0;
            ctrl.removeOwnership();

            ctrl.rowNumber = '00000000000000000000000000000000000000000000000000000000';
            ctrl.linkedRecordId = c1.Id;
            ctrl.acWrapper.get(0).ac.Financial_interest__c = 50;
            ctrl.acWrapper.get(0).ac.Agency_owner__c = true;
            ctrl.acWrapper.get(0).dateJoined = '2010-01-01';
            ctrl.acWrapper.get(0).prev1From = '2010-01-01';
            ctrl.acWrapper.get(0).prev1To = '2010-01-01';
            ctrl.acWrapper.get(0).prev2From = '2010-01-01';
            ctrl.acWrapper.get(0).prev2To = '2010-01-01';
            ctrl.linkACwithContactOrPersonSelection();

            ctrl.rowNumber = '20000000000000000000000000000000000000000000000000000000';

            ctrl.addEmptyCompanyRow();
            ctrl.accountWrapper.get(2).financialInterest = 50;
            ctrl.linkedRecordId = accBR.Id;
            ctrl.linkAccountWithAccountSelection();

            System.assertEquals(false, ctrl.acWrapper.get(0).blockEdit);
           
           //add trained staff
            ctrl.addEmptyTrainedStaffRow();
            ctrl.trainedStaffWrapper.get(1).ac.Last_name__c = 'Verne';
            ctrl.trainedStaffWrapper.get(1).ac.Type_of_certificate__c = AMS_Utils.CERT_DGR;
            ctrl.trainedStaffWrapper.get(1).validUntil = '2018-10-26';
            ctrl.trainedStaffWrapper.get(1).certificateIssueDate = '2017-01-01';

            ctrl.addEmptyTrainedStaffRow();
            ctrl.trainedStaffWrapper.get(2).ac.Last_name__c = 'Rambo';
            ctrl.trainedStaffWrapper.get(2).ac.Type_of_certificate__c = AMS_Utils.CERT_DGR;
            ctrl.trainedStaffWrapper.get(2).validUntil = '2018-10-26';

            ctrl.onSave();

            System.assertEquals(3, ctrl.trainedStaffWrapper.size());

        Test.stopTest();
    }

    @isTest
	static void testIncorrectDateTrainedStaff()
    {
        setup();
        
        Test.startTest();
            ApexPages.StandardController sc = new ApexPages.StandardController(aoa);
            AMS_AccreditationContactController ctrl = new AMS_AccreditationContactController(sc);
            
            //add owner from contact
            Contact c1 = new Contact(AccountId = acc.id, Firstname = 'c1ObsoleteName', Lastname='c1LastName', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com', Financial_Assessment_Contact__c = true);
            insert c1; 

            ctrl.rowNumber = '00000000000000000000000000000000000000000000000000000000';
            ctrl.linkedRecordId = c1.Id;
            ctrl.acWrapper.get(0).ac.Financial_interest__c = 100;
            ctrl.acWrapper.get(0).ac.Agency_owner__c = true;
            ctrl.acWrapper.get(0).dateJoined = '2010-01-10';
            ctrl.linkACwithContactOrPersonSelection();

           //add trained staff
            ctrl.addEmptyTrainedStaffRow();
            ctrl.trainedStaffWrapper.get(1).ac.Last_name__c = 'Verne';
            ctrl.trainedStaffWrapper.get(1).ac.Type_of_certificate__c = AMS_Utils.CERT_DGR;
            ctrl.trainedStaffWrapper.get(1).validUntil = '2018-10-26-2';
            ctrl.trainedStaffWrapper.get(1).certificateIssueDate = '2017-01-01';

            ctrl.onSave();

            System.assert(wasMessageAdded(new ApexPages.Message(ApexPages.Severity.Error, 'Please make sure the date field format is "YYYY-MM-DD". First error with:  '+ ctrl.trainedStaffWrapper.get(1).ac.Last_Name__c + ' with date: 2018-10-26-2')));

            ctrl.addEmptyTrainedStaffRow();
            ctrl.trainedStaffWrapper.get(1).ac.Last_name__c = 'Vernon';
            ctrl.trainedStaffWrapper.get(1).ac.Type_of_certificate__c = AMS_Utils.CERT_DGR;
            ctrl.trainedStaffWrapper.get(1).validUntil = '20182';
            ctrl.trainedStaffWrapper.get(1).certificateIssueDate = '2017-01-01';

            ctrl.onSave();

            ctrl.addEmptyTrainedStaffRow();
            ctrl.trainedStaffWrapper.get(1).ac.Last_name__c = 'Trumbo';
            ctrl.trainedStaffWrapper.get(1).ac.Type_of_certificate__c = AMS_Utils.CERT_DGR;
            ctrl.trainedStaffWrapper.get(1).validUntil = '2018a-10-11';
            ctrl.trainedStaffWrapper.get(1).certificateIssueDate = '2017-01-01';

            ctrl.onSave();

            ctrl.addEmptyTrainedStaffRow();
            ctrl.trainedStaffWrapper.get(1).ac.Last_name__c = 'Honor';
            ctrl.trainedStaffWrapper.get(1).ac.Type_of_certificate__c = AMS_Utils.CERT_DGR;
            ctrl.trainedStaffWrapper.get(1).validUntil = '1920-10-11';
            ctrl.trainedStaffWrapper.get(1).certificateIssueDate = '2017-01-01';

            ctrl.onSave();

        Test.stopTest();
    }

    @isTest
	static void verifyOwnerFlagIsSelectIfFinancialInterestAboveZero(){

        setup();
        
        Test.startTest();

        ApexPages.StandardController sc = new ApexPages.StandardController(aoa);
        AMS_AccreditationContactController ctrl = new AMS_AccreditationContactController(sc);
            
        //add owner from contact
        Contact c1 = new Contact(AccountId = acc.id, Firstname = 'c1ObsoleteName', Lastname='c1LastName', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com', Financial_Assessment_Contact__c = true);
        insert c1; 

        ctrl.rowNumber = '00000000000000000000000000000000000000000000000000000000';
        ctrl.linkedRecordId = c1.Id;
        ctrl.acWrapper.get(0).ac.Financial_interest__c = 100;
        ctrl.acWrapper.get(0).ac.Agency_owner__c = false;
        ctrl.acWrapper.get(0).dateJoined = '2010-01-10';
        ctrl.linkACwithContactOrPersonSelection();

        ctrl.onSave();

        System.assert(wasMessageAdded(new ApexPages.Message(ApexPages.Severity.Error, 'Please make sure all contacts with Financial Interest % value greater than zero (0%) are checked as Owners as well. First error with '+ctrl.acWrapper.get(0).ac.First_Name__c + ' ' + ctrl.acWrapper.get(0).ac.Last_Name__c+'.')));

        Test.stopTest();

    }

    @isTest
	static void verifyDGRTrainedStaffValiduntilPopulated(){

        setup();
        
        Test.startTest();

        ApexPages.StandardController sc = new ApexPages.StandardController(aoa);
        AMS_AccreditationContactController ctrl = new AMS_AccreditationContactController(sc);
            
        //add owner from contact
        Contact c1 = new Contact(AccountId = acc.id, Firstname = 'c1ObsoleteName', Lastname='c1LastName', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com', Financial_Assessment_Contact__c = true);
        insert c1; 

        ctrl.rowNumber = '00000000000000000000000000000000000000000000000000000000';
        ctrl.linkedRecordId = c1.Id;
        ctrl.acWrapper.get(0).ac.Financial_interest__c = 100;
        ctrl.acWrapper.get(0).ac.Agency_owner__c = true;
        ctrl.acWrapper.get(0).dateJoined = '2010-01-10';
        ctrl.linkACwithContactOrPersonSelection();

        ctrl.addEmptyTrainedStaffRow();
        ctrl.trainedStaffWrapper.get(1).ac.First_name__c = 'Jules';
        ctrl.trainedStaffWrapper.get(1).ac.Last_name__c = 'Verne';
        ctrl.trainedStaffWrapper.get(1).ac.Type_of_certificate__c = AMS_Utils.CERT_DGR;
        ctrl.trainedStaffWrapper.get(1).certificateIssueDate = '2017-01-01';

        ctrl.onSave();

        System.assert(wasMessageAdded(new ApexPages.Message(ApexPages.Severity.Error, ''+ctrl.trainedStaffWrapper.get(1).ac.First_name__c+' '+ctrl.trainedStaffWrapper.get(1).ac.Last_name__c + ' '+ctrl.trainedStaffWrapper.get(1).ac.Type_of_certificate__c+' Certificate needs to have the field Valid Until populated.')));

        Test.stopTest();

    }

    @isTest
	static void verifyAccountIdNull(){

        setup();
        
        Test.startTest();

        ApexPages.StandardController sc = new ApexPages.StandardController(aoa);
        AMS_AccreditationContactController ctrl = new AMS_AccreditationContactController(sc);

        PageReference pageRef = Page.AMSAccreditationContact;
        pageRef.getParameters().put('id', String.valueOf(aoa.Id));
        Test.setCurrentPage(pageRef);

        Id accRtId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
        Account acc3 = new Account(Name='LegalName3', Location_Type__c = 'HO', Email__c = 'test3@test.com', Type='CASS Associate', Sector__c = 'Travel Agent', 
            IATAcode__c = '123456783', AIMS_ID__c = '123456783', Source_System__c = 'AIMS2', Legal_Name__c = 'LegalName3', RecordTypeId = accRtId);
        acc3.Id = null;
            
        ctrl.rowNumber = '20000000000000000000000000000000000000000000000000000000';
        ctrl.addEmptyCompanyRow();
        ctrl.accountWrapper.get(2).financialInterest = 100;
        ctrl.accountWrapper.get(2).account = acc3;
        ctrl.onSave();
        //System.assertEquals(ctrl.accountWrapper.get(1).recordId, acc.id);
            
        Test.stopTest();

    }

    @isTest
	static void testBlockExistingEmails(){

        setup();
        
        Test.startTest();

        ApexPages.StandardController sc = new ApexPages.StandardController(aoa);
        AMS_AccreditationContactController ctrl = new AMS_AccreditationContactController(sc);

        AMS_Accreditation_Contact__c acDupeEmail = new AMS_Accreditation_Contact__c(AMS_Pax_Accreditation_Form__c = aoa.Id, First_name__c='NameToUse3', Last_name__c='Last3', 
            Job_title__c='ABC3', Mobile__c='+41123456783', Phone__c='34243223433', Email__c='jd@test.com', 
            RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Person'));
        AMS_AccreditationContactController.AccreditationContactWrapper wrapDupeEmail = new AMS_AccreditationContactController.AccreditationContactWrapper(acDupeEmail);
        ctrl.acWrapper.add(wrapDupeEmail);
        ctrl.acWrapper.get(3).ac.Financial_interest__c = 100;
        ctrl.acWrapper.get(3).ac.Agency_owner__c = true;

        ctrl.onSave();

        ApexPages.Message errorMsg = new ApexPages.Message(ApexPages.Severity.Error,'People with the following emails already exist in the system. Please link them to their original records by selecting \"Choose an existing contact\".\n\n[jd@test.com]'); 

        System.assert(wasMessageAdded(errorMsg));

        Boolean bIsAllHierarchySelected = ctrl.isAllHierarchySelected;
        String sDateFormatToShow = ctrl.dateFormatToShow;
            
        Test.stopTest();

    }

    //AMSU-132
    static testMethod void testImportTrainedStaff(){
        Test.startTest();
        AMS_OSCAR_TestDataFactory.createCargoAgencyOSCARtestData();
        
        Account a = [SELECT id from Account where Name = 'Test Cargo HO' LIMIT 1];

        AMS_OSCAR__c oscar = [SELECT id, AMS_Online_Accreditation__c,RecordTypeId from AMS_OSCAR__c where Account__c =: a.Id limit 1];

        AMS_Pax_Accreditation_Form__c af = [SELECT id, Name, Account_Name__c, IATACode__c, Type_of_Operation__c, Shipping_Street__c, Shipping_Postal_Code__c, 
                            Shipping_City__c, Shipping_State__c, Shipping_Country__c, SAAM_Case__r.AccountId, SAAM_Case__r.OSCAR__r.Account__c, 
                            SAAM_Case__r.OSCAR__r.Account__r.Location_class__c, SAAM_Case__r.OSCAR__r.Account__r.CNS_Agency__c, 
                            SAAM_Case__r.OSCAR__r.Account__r.Location_Type__c, SAAM_Case__r.OSCAR__r.Process__c, SAAM_Case__r.OSCAR__r.Type_of_change__c,
                            SAAM_Case__r.OSCAR__r.Account__r.Sector__c, SAAM_Case__r.OSCAR__r.Account__r.Category__c,
                            SAAM_Case__r.OSCAR__r.CNS_process__c, ANG_IsNewGenAgency__c,  SAAM_Case__r.OSCAR__r.ANG_Type_Of_Change__c, SAAM_Case__r.OSCAR__r.RecordTypeId,
                            SAAM_Case__r.OSCAR__c from AMS_Pax_Accreditation_Form__c where id = :oscar.AMS_Online_Accreditation__c];
    
        ApexPages.StandardController sc = new ApexPages.StandardController(af);
        AMS_AccreditationContactController ctrl = new AMS_AccreditationContactController(sc);

        AMS_Agency_Regulation__c ar = new AMS_Agency_Regulation__c(Expiry_Date__c=(System.today()+91), Type_Of_Certificate__c = 'DGR', Account__c = af.SAAM_Case__r.OSCAR__r.Account__c, Last_name__c='test');
        insert ar;
        List<AMS_Agency_Regulation__c> lar = new List<AMS_Agency_Regulation__c>();
        lar.add(ar);

        List<AMS_AccreditationContactController.AgRegItemWrapper> agRegValuesForDisplaytest = ctrl.agRegValuesForDisplay;

        ctrl.doSelectAll();
        Boolean selectAllLocal = ctrl.selectAll;

        ctrl.saveImport();
        ctrl.convertExistingAgencyRegulationsToAccContact(af.id, lar);

        Test.stopTest();

    }

    private static Boolean wasMessageAdded(ApexPages.Message message) {
        ApexPages.Message[] pageMessages = ApexPages.getMessages();
        System.assertNotEquals(0, pageMessages.size());

        // Check that the error message you are expecting is in pageMessages
        Boolean messageFound = false;

        for(ApexPages.Message msg : pageMessages) {
            if(msg.getSummary() == message.getSummary()
                && msg.getDetail() == message.getDetail()
                && msg.getSeverity() == message.getSeverity()) {
                messageFound = true;        
            }
        }

        return messageFound;
    }
 
    @isTest static void blockOwnershipChinaConversionTest(){

        Test.startTest();

        IATA_ISO_Country__c chinaCountry = new IATA_ISO_Country__c(
            Name = 'China (People\'s Republic of)', 
            ISO_Code__c = 'CN',
            Enable_NewGen_Pilot__c = true,
            CurrencyIsoCode = 'CNY'
        );

        insert chinaCountry;

        Id accRtId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

        Account chinaHE = new Account(
            Name='My China Test HE', 
            Location_Type__c = 'HO', 
            Email__c = 'chinatestacct@test.com', 
            Type='Domestic Agent', 
            Sector__c = 'Travel Agent', 
            IATA_ISO_Country__c = chinaCountry.id, 
            IATAcode__c = '12345672', 
            RecordTypeId = accRtId
        );

        insert chinaHE;
        
        Contact contactChina = new Contact();
        contactChina.AccountId = chinaHE.Id;
        contactChina.Firstname = 'Bob';
        contactChina.Lastname = 'Yung';
        contactChina.Phone = '921111333';
        contactChina.MobilePhone = '911111331';
        contactChina.Email = 'test@china.com';

        insert contactChina;

        Id chinaConversionsRT = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'ANG_Agency_Changes_China');
        
        AMS_OSCAR__c chinaConversionOscar = new AMS_OSCAR__c();

        chinaConversionOscar.Account__c = chinaHE.id;
        chinaConversionOscar.New_parent__c = chinaHE.id;
        chinaConversionOscar.RecordTypeId = chinaConversionsRT;
        chinaConversionOscar.Process__c = AMS_Utils.NGCHINACONVERSION;
        chinaConversionOscar.ANG_Type_Of_Change__c = AMS_Utils.CONVERTTOLEGACY;

        insert chinaConversionOscar;

        Id oscarRecordType = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');

        Case chinaOscarCase = new Case(Oscar__c = chinaConversionOscar.Id, RecordTypeId = oscarRecordType);
        chinaOscarCase.AccountId = chinaHE.Id;
        chinaOscarCase.ContactId = contactChina.Id;
        chinaOscarCase.Reason = 'Product Inquiry';
        chinaOscarCase.Type = 'Case';
        chinaOscarCase.Subject = 'Conversion to Domestic with Cash - My China Test HE';
        chinaOscarCase.CaseArea__c = 'Accreditation Process';
        chinaOscarCase.Reason1__c = AMS_Utils.CONVERTTOLEGACY;
        chinaOscarCase.Type_of_customer__c = 'IATA Travel Agent';
        chinaOscarCase.Account_Concerned__c = chinaHE.Id;
        chinaOscarCase.Region__c = 'China & North Asia';

        insert chinaOscarCase;
        
        AMS_Pax_Accreditation_Form__c onlineAccreditation = new AMS_Pax_Accreditation_Form__c(
            IsGSA__c = 'No', 
            CurrencyIsoCode = chinaCountry.CurrencyIsoCode, 
            SAAM_Case__c = chinaOscarCase.Id
        );

        insert onlineAccreditation;
        
        Test.stopTest();

        ApexPages.StandardController sc = new ApexPages.StandardController(onlineAccreditation);
        AMS_AccreditationContactController ctrl = new AMS_AccreditationContactController(sc);

        System.debug(LoggingLevel.FINE, '____ [cls AMS_AccreditationContactController - blockOwnershipChinaConversionTest] blockOwnershipEdit: ' + ctrl.blockOwnershipEdit);

        System.assert(ctrl.blockOwnershipEdit, 'The ownership modification must be blocked for China Conversions');

    }
    
}