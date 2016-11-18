@isTest
private class AMS_AccreditationContactControllerTest
{

    static Account acc;
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

        Map<string, Id> accountRoleRT = TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'AMS_Account_Role__c'}).get('AMS_Account_Role__c');
		
		Id accRtId = AMS_Utils.getId('Account', 'IATA_Agency');
        Account acc1 = new Account(Name='LegalName', Location_Type__c = 'HO', Email__c = 'test@test.com', Type='CASS Associate', Sector__c = 'Travel Agent', IATA_ISO_Country__c = isoc.id, IATAcode__c = '12345678', AIMS_ID__c = '12345678', Source_System__c = 'AIMS2', Legal_Name__c = 'LegalName', RecordTypeId = accRtId);
        insert acc1;
        
        Case testCase = ISSP_ObjectFactory.createNewCase();
        testCase.BSPCountry__c = 'Hong Kong (SAR), China';
        testCase.Reason1__c = 'Agency';
        testCase.Customer_recovery__c = false;
        testCase.New_AWB_only_to_be_used_after_17Mar_200__c = false;
        testCase.BounceEmailCounter__c = 0.0;
        testCase.Case_Language__c = 'English';
        testCase.Subject = 'Test 006';
        testCase.Reopened_case__c = 0.0;
        testCase.Continous_Feed_SAF__c = true;
        testCase.Account_Concerned__c = acc1.Id;
		testCase.IFAP_Country_ISO__c = 'tq';
        testCase.AccountId = acc1.id;
        insert testCase;
        
		AMS_Pax_Accreditation_Form__c onlineAccreditation = new AMS_Pax_Accreditation_Form__c(IsGSA__c = 'No', CurrencyIsoCode = isoc.CurrencyIsoCode, SAAM_Case__c = testCase.Id);
		insert onlineAccreditation;
		
		List<AMS_Accreditation_Contact__c> acList = new List<AMS_Accreditation_Contact__c>();
		acList.add(new AMS_Accreditation_Contact__c(AMS_Pax_Accreditation_Form__c = onlineAccreditation.Id, Company__c = acc1.id, First_name__c='NameToUse', Last_name__c='Last', Job_title__c='ABC', Mobile__c='+4112345678', Phone__c='3424322343', Email__c='unique@email.com', RecordTypeId=AMS_Utils.getId('AMS_Accreditation_Contact__c', 'Person')));
		insert acList;
    }
	
	static void setup()
    {
        accountAgencyRtId = AMS_Utils.getId('Account', 'IATA_Agency');
        aoa = [select id from AMS_Pax_Accreditation_Form__c].get(0);
        ac = [select id from AMS_Accreditation_Contact__c].get(0);
        acc = [select id from Account].get(0);
     	
    }

    static testMethod void testAddingNewContactAndCompanyRowsSucceeds()
    {
        setup();
        
        Test.startTest();
        	ApexPages.StandardController sc = new ApexPages.StandardController(aoa);
			AMS_AccreditationContactController ctrl = new AMS_AccreditationContactController(sc);
            
            PageReference pageRef = Page.AMSAccreditationContact;
            pageRef.getParameters().put('id', String.valueOf(aoa.Id));
            Test.setCurrentPage(pageRef);
            
            ctrl.cloneLastRow();
          	System.assertEquals(2, ctrl.acWrapper.size());
          	ctrl.addEmptyRow();
          	System.assertEquals(3, ctrl.acWrapper.size());
          	ctrl.toUnselect = 2;
          	ctrl.removeFromAcList();
          	System.assertEquals(2, ctrl.acWrapper.size());
          	System.assertEquals(0, ctrl.accountWrapper.size());
        	ctrl.addEmptyCompanyRow();
        	System.assertEquals(1, ctrl.accountWrapper.size());
        	ctrl.toUnselect = 0;
        	ctrl.removeFromAccountList();
        	System.assertEquals(0, ctrl.accountWrapper.size());
        	ctrl.onCancel();
        Test.stopTest();
    }
    
    
    static testMethod void testContactAndPersonLinkingSucceeds()
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
    
    static testMethod void testAccountLinkingSucceeds()
    {
        setup();
        
        Test.startTest();
        	ApexPages.StandardController sc = new ApexPages.StandardController(aoa);
			AMS_AccreditationContactController ctrl = new AMS_AccreditationContactController(sc);
            
            PageReference pageRef = Page.AMSAccreditationContact;
            pageRef.getParameters().put('id', String.valueOf(aoa.Id));
            Test.setCurrentPage(pageRef);
            
        	
        	ctrl.rowNumber = '00000000000000000000000000000000000000000000000000000000';
        	ctrl.addEmptyCompanyRow();
        	ctrl.accountWrapper.get(0).financialInterest = 100;
        	ctrl.linkedRecordId = acc.Id;
        	ctrl.linkAccountWithAccountSelection();
        	ctrl.onSave();
        	System.assertEquals(ctrl.accountWrapper.get(0).recordId, acc.id);
        Test.stopTest();
    }
    
    static testMethod void testPopUpControllerWithContactSearch()
    {
        setup();
        
        Contact c1 = new Contact(AccountId = acc.id, Firstname = 'c1ObsoleteName', Lastname='c1LastName', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com', Financial_Assessment_Contact__c = false, RecordTypeId = AMS_Utils.getId('Contact', 'Standard_Contact'));
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
    
    static testMethod void testPopUpControllerWithAccountSearch()
    {
        setup();
        
        Contact c1 = new Contact(AccountId = acc.id, Firstname = 'c1ObsoleteName', Lastname='c1LastName', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com', Financial_Assessment_Contact__c = false, RecordTypeId = AMS_Utils.getId('Contact', 'Standard_Contact'));
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
        	
        	System.assertEquals(1, lookupCtrl.accWrapper.size());
        Test.stopTest();
    }
    
}