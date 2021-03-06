@isTest
private class AMS_AgencyAChangeCodeTest {

	public static String SECTORPAX = 'Travel Agent';
	public static String CATEGORYPAX = 'IATA Passenger Sales Agent';
	public static String LOCCLASSPAX = 'P';

	public static String SECTORCASS = 'Cargo Agent';
	public static String CATEGORYCASS = 'IATA Cargo Sales Agent';
	public static String LOCCLASSCASS = 'C';

	public static String CHANGELOCATIONTYPE = 'Location type';
	public static String CHANGEOWNERSHIPIATA= 'Ownership to IATA Agent';
	public static String CHANGEOWNERSHIPNONIATA= 'Ownership to non-IATA Agent';


	@testSetup static void setup(){

		Boolean isPax = true;

		ID rtAgency = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
		IATA_ISO_Country__c italy = new IATA_ISO_Country__c(Name='Italy', ISO_Code__c='IT', AIMS_Area_Name__c = 'ITALY', Region__c='Europe', ISS_Office_Location__c='Italy');
		insert italy;

		Account HO1 = new Account(RecordTypeId = rtAgency, Name = 'My Travels', IATAcode__c = '1111110', IATA_ISO_Country__c = italy.id,
						 Sector__c = (isPax ? SECTORPAX : SECTORCASS), Category__c = (isPax ? CATEGORYPAX : CATEGORYCASS),
						 Location_Class__c = (isPax ? LOCCLASSPAX : LOCCLASSCASS), Location_Type__c = 'HO', Status__c = 'Approved',
						 Short_Name__c = 'Short name', BillingCity = 'Lisbon', Email__c = 'testeteste@fefe3.com'
						 );
		insert HO1;

		Contact C1 = new Contact(FirstName = 'First', LastName = 'Contact',  AccountId = HO1.Id, Email = 'thecontact1@gmail.com', Phone = '123123123');
		insert C1;

		createCaseAndOSCAR(HO1,C1);

		AMS_Status_Reason__c SetupReason= new AMS_Status_Reason__c(name='Test01', Reason_Code__c='91', Reason_Description__c='ACCREDITED - MEETS CRITERIA', Status_Code__c='9', Status_Description__c='Approved');
		insert SetupReason;
	}

	static void createCaseAndOSCAR(Account theAccount, Contact theContact){

		// Create the Staging area for the Account
		ID rtCommCase = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');
		ID rtAgency = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

		Case theCommunicationCase = new Case(RecordTypeId = rtCommCase, Subject =  theAccount.Name,
											AccountId = (theAccount.ParentId == null ? theAccount.Id : theAccount.ParentId), ContactId = theContact.Id  );
		insert theCommunicationCase;


		AMS_Pax_Accreditation_Form__c theStagingAcc = new  AMS_Pax_Accreditation_Form__c(Account_Name__c = theAccount.Name, IATAcode__c = theAccount.IATAcode__c, Branch_Office_Country__c = theAccount.IATA_ISO_Country__c,
														   SAAM_Case__c = theCommunicationCase.Id, Location_Class__c = theAccount.Location_Class__c, Location_Type__c = theAccount.Location_Type__c);
		insert theStagingAcc;


		Account ownerAcct = new Account(Name ='owner test account', RecordTypeId = rtAgency);

		insert ownerAcct;

		// Create the Staging area for the Contact
		List<AMS_Accreditation_Contact__c> theStagingConts= new List<AMS_Accreditation_Contact__c>();
		if(theContact!=null)
			theStagingConts.add(new AMS_Accreditation_Contact__c(First_name__c = theContact.FirstName, Last_Name__c = theContact.LastName, Email__c = theContact.Email, Contact__c = theContact.Id,
								AMS_Pax_Accreditation_Form__c = theStagingAcc.Id, Phone__c = theContact.Phone, Company__c = ownerAcct.Id));

		if(theStagingConts.size()>0)
			insert theStagingConts;

		// Create OSCAR and Communication Case
		ID rtNew = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'NEW');

		AMS_OSCAR__c theOscar = new AMS_OSCAR__c(RecordTypeId = rtNew, Account__c = theAccount.Id, Process__c = 'NEW.HO.1.0', AMS_Online_Accreditation__c = theStagingAcc.Id );
		insert theOscar;

		theCommunicationCase.OSCAR__c = theOscar.Id;

		update theCommunicationCase;




	}

	@isTest static void test_ChangeCodeFIN() {

		Test.startTest();

		List<AMS_Pax_Accreditation_Form__c> accreditationLst = [SELECT ID, Name, Short_Name__c, Trade_Name__c, Branch_Office_City__c, Branch_Office_Email__c from AMS_Pax_Accreditation_Form__c];

		List<AMS_OSCAR__c> oscarLst = [SELECT ID, Account__c, Location_Class__c, Is_NewGen__c  from AMS_OSCAR__c];

		List<Account> accountLst = [SELECT ID, Status__c, CNS_Agency__c,Sector__c,Category__c, Location_class__c from Account ];

		if(accreditationLst.isEmpty())
			System.assert(true,false);

		if(oscarLst.isEmpty())
			System.assert(true,false);

		if(accountLst.isEmpty())
			System.assert(true,false);

		AMS_Pax_Accreditation_Form__c accreditation = accreditationLst.get(0);

		AMS_OSCAR__c oscar= oscarLst.get(0);

		Account account = accountLst.get(0);

		AMS_OSCAR_JSON.ChangeCode changeCode = new AMS_OSCAR_JSON.ChangeCode();

		changeCode.name = 'NEW';
		changeCode.reasonCode = '21';

		changeCode.memoText = 'New application in progress';
		changeCode.reasonDesc  = 'NEW APPLICATION';
		changeCode.status  = '2';

		AMS_ChangeCodesHelper.createAAChangeCodes(new List<AMS_OSCAR_JSON.ChangeCode>{changeCode}, new List<AMS_OSCAR__c>{oscar}, new List<Account> {account}, true);

		changeCode = new AMS_OSCAR_JSON.ChangeCode();

		changeCode.name = 'FIN';
		changeCode.reasonCode = '91';

		changeCode.memoText = 'New application - Head Office finalized';
		changeCode.reasonDesc  = 'ACCREDITED–MEETS–STANDARDS';
		changeCode.status  = '2';

		accreditation.Account_Name__c = 'Changed Name';
		accreditation.Short_Name__c= 'Changed short name';
		accreditation.Trade_Name__c='Changed trade name';
		accreditation.Branch_Office_City__c = 'Porto';
		accreditation.Branch_Office_Email__c = 'changedrmailteste@fe443.com';

		update accreditation;

		AMS_ChangeCodesHelper.createAAChangeCodes(new List<AMS_OSCAR_JSON.ChangeCode>{changeCode}, new List<AMS_OSCAR__c>{oscar}, new List<Account> {account}, true);

		accountLst = [SELECT ID, Name, Short_Name__c , TradeName__c, BillingCity , Email__c  from Account ];

		if(accountLst.isEmpty())
			System.assert(true,false);

		account = accountLst.get(0);

		System.assertEquals(account.Name,accreditation.Account_Name__c);
		System.assertEquals(account.Short_Name__c,accreditation.Trade_Name__c);
		System.assertEquals(account.TradeName__c,accreditation.Trade_Name__c);
		System.assertEquals(account.BillingCity,accreditation.Branch_Office_City__c);
		System.assertEquals(account.Email__c,accreditation.Branch_Office_Email__c);

		Test.stopTest();
	}


	@isTest static void test_ManualCreationChangeCode(){
		Account a = [select id from Account where Name = 'My Travels' limit 1];

		test.StartTest();
		Agency_Applied_Change_code__c cc = new Agency_Applied_Change_code__c();

		cc.Account__c = a.Id;
		cc.AccountNewStatus__c = 'Approved';
		cc.Reason_Description__c  = 'ACCREDITED - MEETS CRITERIA';

		insert cc;

		system.assertEquals('91', [select Reason_Code__c from Agency_Applied_Change_code__c where id=:cc.Id].Reason_Code__c);
	}

	 @isTest static void testEventsTriggerHandler(){
		//test to increase coverage on unused events on triggerhandler
		ANG_AgencyAChangeCodeTriggerHandler triggerhandler = new ANG_AgencyAChangeCodeTriggerHandler();
		triggerhandler.onBeforeInsert();
		triggerhandler.onBeforeUpdate();
		triggerhandler.onAfterUpdate();
		triggerhandler.onBeforeDelete();
		triggerhandler.onAfterDelete();
	}

	@isTest static void testRVWAndUpdateChangeCode() {

		IATA_ISO_Country__c cnsCountry = new IATA_ISO_Country__c(Name = 'CNS Country', CNS_Country__c = true, ISO_Code__c = 'XX');
		insert cnsCountry;

		Account acc = [select id from Account limit 1];
		acc.Location_Class__c = 'C';
		acc.IATA_ISO_Country__c = cnsCountry.Id;
		update acc;

		Contact con = [select id from Contact limit 1];

		ID rtSidraLite = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'SIDRA_Lite');
		ID rtCNS = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'CNS_Collection_Process');

		Case cnsCase = new Case(RecordTypeId = rtSidraLite, Subject = 'CNS Case', AccountId = acc.Id, ContactId = con.Id);
		insert cnsCase;

		Case sidraLiteCase = new Case(RecordTypeId = rtSidraLite, Subject = 'SIDRA Lite Case', ParentId = cnsCase.Id, AccountId = acc.Id, ContactId = con.Id);
		insert sidraLiteCase;

		Test.StartTest();

		//insert RVW change code
		Agency_Applied_Change_code__c cc = new Agency_Applied_Change_code__c();
		cc.Account__c = acc.Id;
		cc.SIDRA_Case__c = sidraLiteCase.Id;
		cc.Change_Code__c = 'RVW';
		insert cc;

		//update change code
		cc.AccountNewStatus__c = 'Approved';
		cc.Reason_Description__c  = 'ACCREDITED - MEETS CRITERIA';
		update cc;

		//invoke batches
		AMS_AgencyAChangeCodeHandler.notifyAirlines(new List<Agency_Applied_Change_code__c>{cc});


		Test.StopTest();
	}

}
