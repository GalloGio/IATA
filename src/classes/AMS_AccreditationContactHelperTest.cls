@isTest
private class AMS_AccreditationContactHelperTest {
	
	@testSetup static void setup(){

		Id ownerRtId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Account_Role__c', 'Employee');

        IATA_ISO_Country__c isoc = new IATA_ISO_Country__c(Name = 'Test', ISO_Code__c = 'TS');       
        insert isoc;

        Id agencyRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
        Account acc1 = new Account(RecordTypeId=agencyRT, Status__c = 'Approved', Reason_for_creation__c = 'Headquarter is missing', Name='Test1 Account', Location_Type__c = 'HO', Type='CASS Associate', Sector__c = 'Travel Agent', IATA_ISO_Country__c = isoc.id, IATAcode__c = '12345678', AIMS_ID__c = '12345678', Source_System__c = 'AIMS2');
        insert acc1;

		Contact c1 = new Contact(AccountId = acc1.id, Firstname = 'c1ObsoleteName', Lastname='c1LastName', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com', Financial_Assessment_Contact__c = false);
		insert c1;

		AMS_Person__c p1 = new AMS_Person__c(Email__c = 'test@test.com', Contact__c = c1.Id);
		insert p1;

        AMS_Account_Role__c e1 = new AMS_Account_Role__c(recordTypeId = ownerRtId, Account__c = acc1.Id, Person__c = null, Contact__c = c1.Id, Percentage__c=100.0);

        insert e1;

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
        testCase.QuantityProduct__c = '1';
        insert testCase;

 		AMS_Pax_Accreditation_Form__c onlineAccreditation = new AMS_Pax_Accreditation_Form__c(IsGSA__c = 'No', CurrencyIsoCode = isoc.CurrencyIsoCode, 
 			SAAM_Case__c = testCase.Id, Account_Name__c = acc1.Name);
        insert onlineAccreditation;
        
        List<AMS_Accreditation_Contact__c> acList = new List<AMS_Accreditation_Contact__c>();
        acList.add(new AMS_Accreditation_Contact__c(AMSPerson__c = p1.Id ,Contact__c =c1.Id, AMS_Pax_Accreditation_Form__c = onlineAccreditation.Id, 
        	Agency_owner__c = true, Company__c = acc1.id, First_name__c='NameToUse', Last_name__c='Last', Job_title__c='ABC', 
        	Mobile__c='+4112345678', Phone__c='3424322343', Email__c='unique@email.com', RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Person')));
		
		acList.add(new AMS_Accreditation_Contact__c(AMS_Pax_Accreditation_Form__c = onlineAccreditation.Id, Agency_owner__c = true, Company__c = acc1.id, 
			First_name__c='NameToUse2', Last_name__c='Last2', Job_title__c='ABC2', Mobile__c='+4112745678', Phone__c='3424372343', Email__c='unique123@email.com', 
			RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Current_Company_Owner')));

        insert acList;

        AMS_OSCAR__c oscar = new AMS_OSCAR__c(Account__c = acc1.Id,  AMS_Online_Accreditation__c = onlineAccreditation.Id);
        insert oscar;

		testCase.Oscar__c = oscar.Id;
		update testCase;

	}


	@isTest static void emulateMethodsOnAMS_AccreditationContactHelperTest() {
		
		Test.startTest();

		Id ownerRtId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Account_Role__c', 'Employee');

		Set<String> emailSet = new Set<String>();

		emailSet.add('test@test.com');

        Set<Id> acPersonSet = new Set<Id>();

		Map<String, AMS_Account_Role__c> roles = AMS_AccreditationContactHelper.findRolesAndPersonsByEmail(emailSet,acPersonSet);

		List<Account> accts = [SELECT Id from Account];

		Account acc = accts.get(0);

		AMS_Person__c person = [SELECT Id , Email__c, Contact__c from AMS_Person__c];

		AMS_Account_role__c role = [SELECT Id, Account__c, Person__c,Contact__c, Percentage__c from AMS_Account_role__c ];

		List<AMS_Accreditation_Contact__c> acontactList = [SELECT Id,Name, Person_AMS__c, Registration_number__c, Agency_owner__c,RecordType.DeveloperName, RecordType.Id, RecordType.Name, Agency_role__c,Time_devoted_to_Agency_business__c, Financial_Interest__c, AMSPerson__c, Contact__c, AMS_Pax_Accreditation_Form__c, AMS_Pax_Accreditation_Form__r.SAAM_Case__c, AMS_Pax_Accreditation_Form__r.SAAM_Case__r.Oscar__c, AMS_Pax_Accreditation_Form__r.SAAM_Case__r.Oscar__r.Account__c ,Company__c, First_name__c, Last_name__c, Job_title__c, Mobile__c, Phone__c, Email__c, Membership_Main_Contact__c, Financial_Assessment_Contact__c, FAX__c, Birthdate__c, ISO_Country__c, Training_dangerous_goods_completed__c, list_Dangerous_Goods_Awareness__c, Authorised_signatory__c, Portal_administrator__c, Invoicing_Contact__c, AddressStreet__c, AddressCity__c, AddressPostcode__c, AddressCountry__c, Date_Joined_agency__c, Prev_Job1_From__c, Prev_Job1_To__c, Prev_Job2_From__c, Prev_Job2_To__c from AMS_Accreditation_Contact__c];

		AMS_Accreditation_Contact__c acontact = acontactList.get(0);

		AMS_Accreditation_Contact__c acontact2 = acontactList.get(1);

		Contact contact = [SELECT Id, AccountId, Firstname, Lastname, Phone,MobilePhone, Email, Financial_Assessment_Contact__c from Contact ];

		AMS_AccreditationContactHelper.findContactsByNameOrEmail(contact.Firstname, contact.Lastname, contact.Email);

		AMS_AccreditationContactHelper.populateNewContactFields(contact, acontact2);

		AMS_AccreditationContactHelper.updateAmsAccountRole(role,acontact);

		AMS_AccreditationContactHelper.createAmsAccountRole(acontact);

		AMS_AccreditationContactHelper.createAmsAccountRole(acontact2);

		AMS_AccreditationContactHelper.createAmsRoleForAccount(acontact);

		AMS_AccreditationContactHelper.updateAmsRoleForAccount(role,acontact);

		AMS_AccreditationContactHelper.populateNewAccountFields(acc,acontact);

		AMS_AccreditationContactHelper.createAccreditationContactFromAccountRole(role, acontact.AMS_Pax_Accreditation_Form__c);

		AMS_Person__c p1 = new AMS_Person__c(Email__c = 'test@test.com', Contact__c = contact.Id);
		insert p1;

		AMS_Account_Role__c e1 = new AMS_Account_Role__c(recordTypeId = ownerRtId, Account__c = acc.Id, Person__c = p1.Id, Percentage__c=100.0);
        insert e1;

		AMS_AccreditationContactHelper.createAccreditationContactFromAccountRole(e1, acontact.AMS_Pax_Accreditation_Form__c);

		AMS_Account_Role__c e2 = new AMS_Account_Role__c(recordTypeId = ownerRtId, Account__c = acc.Id, Percentage__c=100.0 ,Legacy_External_ID__c = '123123123' , Legacy_System__c = 'AIMS2');
        insert e2;

		AMS_AccreditationContactHelper.createAccreditationContactFromAccountRole(e2, acontact.AMS_Pax_Accreditation_Form__c);

		AMS_Oscar__c oscar = [SELECT id, Type_of_change__c, AMS_Target_Agency__c, AMS_Online_Accreditation__c from AMS_OSCAR__c];

		oscar.Type_of_change__c = AMS_Utils.OWNERSHIP_IATA;
		oscar.AMS_Target_Agency__c= acc.Id;

		update oscar;

		AMS_AccreditationContactHelper.mirrorAccrediationContactsFromAccountRole(new List<AMS_OSCAR__c>{oscar},null);

		List<AMS_AccreditationContactController.AccreditationContactWrapper> wrapperList = new List<AMS_AccreditationContactController.AccreditationContactWrapper>();
		AMS_AccreditationContactController.AccreditationContactWrapper accwr1 = new AMS_AccreditationContactController.AccreditationContactWrapper(acontact);
		wrapperList.add(accwr1);
		AMS_AccreditationContactController.AccreditationContactWrapper accwr2 = new AMS_AccreditationContactController.AccreditationContactWrapper(acontact2);
		wrapperList.add(accwr2);
		AMS_AccreditationContactHelper.insertAmsRolesForAccreditationContacts(wrapperList);

		Test.stopTest();

	}


}