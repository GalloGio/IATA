@isTest
private class MITA_AgreementsCtrlTest {

	private static void loadData() {
		IATA_ISO_Country__c countryFR = new IATA_ISO_Country__c(
			Name = 'France',
			ISO_Code__c = 'FR'
		);
		insert countryFR;
		IATA_ISO_Country__c countryCH = new IATA_ISO_Country__c(
			Name = 'Switzerland',
			ISO_Code__c = 'CH'
		);
		insert countryCH;

		list<Account> listAccount = new list<Account>{
			new Account(
				Name = 'Air France',
				IATA_ISO_Country__c = countryFR.Id,
				RecordtypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline'),
				Field_Head_Office__c = 'Headquearter',
				ACLI_Status__c = 'Active Company',
				Airline_designator__c = 'AF',
				IATACode__c = '001',
				Airline_Prefix__c = '001',
				Sector__c = 'Airline',
				Category__c = 'Passenger and cargo',
				MITA_Member__c = true,
				BIETA_Member__c = true,
				MITA_IATA_Interline_Passenger__c = Date.today(),
				MITA_IATA_Interline_Cargo__c = Date.today()
			),
			new Account(
				Name = 'Swissair',
				IATA_ISO_Country__c = countryCH.Id,
				RecordtypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline'),
				Field_Head_Office__c = 'Headquearter',
				ACLI_Status__c = 'Active Company',
				Airline_designator__c = 'SA',
				IATACode__c = '002',
				Airline_Prefix__c = '002',
				Sector__c = 'Airline',
				Category__c = 'Passenger and cargo',
				MITA_Member__c = true,
				BIETA_Member__c = true,
				MITA_IATA_Interline_Passenger__c = Date.today(),
				MITA_IATA_Interline_Cargo__c = Date.today()
			)
		};
		insert listAccount;
	}

	private static Contact createContact() {
		Contact contact = new Contact(
			FirstName = 'first1',
			LastName = 'last1',
			Title = 'title',
			Email = 'test@email.com',
			MITA_Contact_Type__c = 'CGO Billing'
		);
		return contact;
	}

	@isTest
	static void Test_Controller() {
		Test.startTest();
		MITA_AgreementsCtrl controller = new MITA_AgreementsCtrl();
		controller.getIsThereAnError();
		Test.stopTest();
	}

	@isTest
	static void Test_selectAccount_NoAccount() {
		MITA_AgreementsCtrl controller = new MITA_AgreementsCtrl();

		Test.startTest();
		controller.selectAccount();
		Test.stopTest();

		System.assertEquals(controller.acc, null);
	}

	@isTest
	static void Test_selectAccount_withAccount() {
		loadData();
		MITA_AgreementsCtrl controller = new MITA_AgreementsCtrl();
		Account account1 = [Select Id,Name from Account where Name = 'Air France'];
		Account account2 = [Select Id,Name from Account where Name = 'Swissair'];
		controller.accountid = account1.Id;

		MITA_Agreement__c agr = new MITA_Agreement__c(
			Airline_1__c = account1.Id,
			Airline_2__c = account2.Id,
			MITAorBIETA__c = 'MITA'
		);
		insert agr;

		Test.startTest();
		controller.selectAccount();
		controller.getAccountTable();
		Test.stopTest();

		System.assertEquals(controller.acc.Name, account1.Name);
		System.assertEquals(controller.agreements.size(), 1);
	}

	@isTest
	static void Test_saveAccount_ERROR() {
		loadData();
		MITA_AgreementsCtrl controller = new MITA_AgreementsCtrl();
		Account account1 = [Select Id,Name from Account where Name = 'Air France'];
		controller.accountid = account1.Id;
		controller.selectAccount();

		Test.startTest();
		controller.editAccount();
		controller.resetAccount();
		//an account without name throws an error
		controller.acc.Name = '';
		controller.saveAccount();
		Test.stopTest();

		// no change has been made to the account name
		System.assertEquals(controller.acc.Name, account1.Name);
	}

	@isTest
	static void Test_saveAccount_OK() {
		loadData();
		MITA_AgreementsCtrl controller = new MITA_AgreementsCtrl();
		Account account1 = [Select Id,Name,Website from Account where Name = 'Air France'];
		controller.accountid = account1.Id;
		controller.selectAccount();

		Test.startTest();
		controller.editAccount();
		controller.resetAccount();
		controller.acc.Website = 'www.acme.com';
		controller.saveAccount();
		Test.stopTest();

		Account result = [Select Id,Name,Website from Account where Id = :controller.acc.Id];
		System.assertEquals(result.Website, 'www.acme.com');
	}

	@isTest
	static void Test_newContact_Error() {
		loadData();
		MITA_AgreementsCtrl controller = new MITA_AgreementsCtrl();
		Account account1 = [Select Id,Name from Account where Name = 'Air France'];
		controller.accountid = account1.Id;
		controller.selectAccount();

		Test.startTest();
		controller.newContact();
		controller.c.FirstName = 'test contact';
		//saving a contact without Email throws an error
		controller.saveContact();
		controller.resetContact();
		controller.searchContact();
		controller.editContact();
		Test.stopTest();

		list<Contact> results = [Select Id, Email From Contact Where Email = 'test@email.com'];
		System.assert(results.isEmpty());
	}

	@isTest
	static void Test_newContact() {
		loadData();
		MITA_AgreementsCtrl controller = new MITA_AgreementsCtrl();
		Account account1 = [Select Id,Name from Account where Name = 'Air France'];
		controller.accountid = account1.Id;
		controller.selectAccount();

		Test.startTest();
		controller.newContact();
		controller.c.FirstName = 'test contact';
		controller.c.LastName = 'last';
		controller.c.Title = 'title';
		controller.c.Email = 'test@email.com';
		controller.c.MITA_Contact_Type__c = 'CGO Billing';
		controller.c.MITA_Teletype__c = 'tt';
		controller.saveContact();

		Contact result = [Select Id, Email From Contact Where Email = 'test@email.com'];
		System.assert(result!=null);

		controller.contactId = controller.c.Id;
		controller.selectContact();
		Test.stopTest();

		System.assert(controller.c.Id!=null);
		System.assertEquals('test contact last',controller.c.Name);
	}

	@isTest
	static void Test_chooseContact_Error() {
		MITA_AgreementsCtrl controller = new MITA_AgreementsCtrl();
		controller.duplicateContacts = new Map<Id, Contact>();

		Test.startTest();
		controller.chooseContact();
		Test.stopTest();

		System.assert(controller.foundContact==null);
	}

	@isTest
	static void Test_moveContact_NoEmail() {
		MITA_AgreementsCtrl controller = new MITA_AgreementsCtrl();

		Test.startTest();
		controller.moveContact();
		Test.stopTest();

		System.assert(controller.duplicateContactMode==false);
	}

	@isTest
	static void Test_moveContact_NoContact() {
		MITA_AgreementsCtrl controller = new MITA_AgreementsCtrl();
		controller.contactEmail = 'test@email.com';

		Test.startTest();
		controller.moveContact();
		Test.stopTest();

		System.assert(controller.duplicateContactMode==false);
	}

	@isTest
	static void Test_moveContact_OneContact() {
		MITA_AgreementsCtrl controller = new MITA_AgreementsCtrl();
		controller.contactEmail = 'test@email.com';

		Contact contact = createContact();
		insert contact;

		Test.startTest();
		controller.moveContact();
		Test.stopTest();

		System.assert(controller.confirmMoveContactMode);
		System.assert(controller.duplicateContacts == null);
	}

	/*comment due to sfdc standard duplicate tool
	@isTest
	static void Test_moveContact_DuplicateContacts() {
		MITA_AgreementsCtrl controller = new MITA_AgreementsCtrl();
		controller.contactEmail = 'test@email.com';

		// 2 contacts same email
		Contact contact1 = createContact();
		insert contact1;
		Contact contact2 = createContact();
		contact2.FirstName = 'first1';
		contact2.LastName = 'last1';
		insert contact2;

		Test.startTest();
		controller.moveContact();
		Test.stopTest();

		System.assert(controller.duplicateContactMode == true);
	}
	*/

	@isTest
	static void Test_confirmMoveContact_Error() {
		MITA_AgreementsCtrl controller = new MITA_AgreementsCtrl();
		controller.searchContactMode = true;
		controller.confirmMoveContactMode = true;
		controller.duplicateContactMode = true;

		Contact contact = createContact();
		insert contact;
		controller.foundContact = contact;

		Test.startTest();
		controller.confirmMoveContact();
		Test.stopTest();

		System.assert(controller.searchContactMode == true);
		System.assert(controller.confirmMoveContactMode == true);
		System.assert(controller.duplicateContactMode == true);
	}

	@isTest
	static void Test_confirmMoveContact_OK() {
		loadData();
		MITA_AgreementsCtrl controller = new MITA_AgreementsCtrl();
		controller.searchContactMode = true;
		controller.confirmMoveContactMode = true;
		controller.duplicateContactMode = true;

		Account account1 = [Select Id,Name from Account where Name = 'Air France'];
		controller.accountId = account1.Id;

		Contact contact = createContact();
		insert contact;

		controller.foundContact = contact;

		Test.startTest();
		controller.confirmMoveContact();
		Test.stopTest();

		System.assert(controller.searchContactMode == false);
		System.assert(controller.confirmMoveContactMode == false);
		System.assert(controller.duplicateContactMode == false);
		Related_Contact__c relatedContact = [
			SELECT Id
			FROM Related_Contact__c
			WHERE Account__c = :account1.Id
			AND Contact__c = :contact.Id];
		System.assert(relatedContact != null);
	}

	@isTest
	static void Test_removeContactFromMITA_OK() {
		loadData();
		MITA_AgreementsCtrl controller = new MITA_AgreementsCtrl();

		Account account1 = [Select Id,Name from Account where Name = 'Air France'];
		controller.accountId = account1.Id;
		controller.selectAccount();

		Contact contact = createContact();
		insert contact;
		controller.foundContact = contact;
		controller.confirmMoveContact();
		controller.c = contact;

		list<Related_Contact__c> relatedContacts =[
			Select Contact__c
			from Related_Contact__c
			where Account__c = :account1.Id
			and Contact__c = :contact.Id
			and Contact__r.MITA_Contact__c = true ];

		System.assertEquals(relatedContacts.size(),1);

		Test.startTest();
		controller.removeContactFromMITA();
		Test.stopTest();

		relatedContacts =[
			Select Contact__c
			from Related_Contact__c
			where Account__c = :account1.Id
			and Contact__c = :contact.Id
			and Contact__r.MITA_Contact__c = true ];

		System.assertEquals(relatedContacts.size(),0);
	}

	@isTest
	static void Test_getMITAAgreementTypesAndTables() {
		loadData();
		MITA_AgreementsCtrl controller = new MITA_AgreementsCtrl();
		Account account1 = [Select Id,Name from Account where Name = 'Air France'];
		Account account2 = [Select Id,Name from Account where Name = 'Swissair'];
		controller.accountid = account1.Id;

		MITA_Agreement__c agr = new MITA_Agreement__c(
			Airline_1__c = account1.Id,
			Airline_2__c = account2.Id,
			MITAorBIETA__c = 'MITA'
		);
		insert agr;
		controller.selectAccount();

		Test.startTest();
		controller.getMITAAgreementTypes();
		controller.getBIETAAgreementTypes();
		controller.getMITAAgreementTable();
		controller.getBIETAAgreementTable();
		Test.stopTest();
	}

	@isTest
	static void Test_selectAgreement() {
		loadData();
		MITA_AgreementsCtrl controller = new MITA_AgreementsCtrl();
		Account account1 = [Select Id,Name from Account where Name = 'Air France'];
		Account account2 = [Select Id,Name from Account where Name = 'Swissair'];
		controller.accountid = account1.Id;

		MITA_Agreement__c agr = new MITA_Agreement__c(
			Airline_1__c = account1.Id,
			Airline_2__c = account2.Id,
			MITAorBIETA__c = 'MITA'
		);
		insert agr;
		controller.selectAccount();
		controller.MITAagreementid = agr.Id;

		Test.startTest();
		controller.selectMITAAgreement();
		controller.selectBIETAAgreement();
		Test.stopTest();
	}

	@isTest
	static void Test_handleMITAAgreement() {
		loadData();
		MITA_AgreementsCtrl controller = new MITA_AgreementsCtrl();
		Account account1 = [Select Id,Name from Account where Name = 'Air France'];
		Account account2 = [Select Id,Name from Account where Name = 'Swissair'];
		controller.accountid = account1.Id;

		controller.selectAccount();

		Test.startTest();
		controller.newMITAAgreement();
		controller.saveMITAAgreement();
		controller.editMITAAgreement();
		controller.resetMITAAgreement();
		Test.stopTest();
	}

	@isTest
	static void Test_handleBIETAAgreement() {
		loadData();
		MITA_AgreementsCtrl controller = new MITA_AgreementsCtrl();
		Account account1 = [Select Id,Name from Account where Name = 'Air France'];
		Account account2 = [Select Id,Name from Account where Name = 'Swissair'];
		controller.accountid = account1.Id;

		controller.selectAccount();

		Test.startTest();
		controller.newBIETAAgreement();
		controller.saveBIETAAgreement();
		controller.editBIETAAgreement();
		controller.resetBIETAAgreement();
		Test.stopTest();
	}

	@isTest
	static void Test_deactivateMember() {
		loadData();
		Account account1 = [Select Id,Name from Account where Name = 'Air France'];
		Account account2 = [Select Id,Name from Account where Name = 'Swissair'];

		MITA_Agreement__c agr = new MITA_Agreement__c(
			Airline_1__c = account1.Id,
			Airline_2__c = account2.Id,
			MITAorBIETA__c = 'MITA',
			Effective_date__c = Date.today()
		);
		insert agr;

		MITA_AgreementsCtrl controller = new MITA_AgreementsCtrl();
		controller.accountid = account1.Id;
		controller.selectAccount();

		MITA_Agreement__c resultAgr;
		resultAgr = [Select id, Cancellation_date__c, Cancellation_processed_date__c, Cancellation_Reason__c from MITA_Agreement__c where id = :agr.Id];
		System.assert(resultAgr.Cancellation_date__c == null);
		System.assert(resultAgr.Cancellation_processed_date__c == null);
		System.assert(resultAgr.Cancellation_Reason__c == null);

		Test.startTest();
		controller.showDeactivateMITAPanel();
		controller.deactivateAgreements();
		controller.showDeactivateBIETAPanel();
		controller.deactivateAgreements();
		controller.cancelDeactivation();
		Test.stopTest();

		resultAgr = [Select id, Cancellation_date__c, Cancellation_processed_date__c, Cancellation_Reason__c from MITA_Agreement__c where id = :agr.Id];
		System.assertEquals(Date.today(),resultAgr.Cancellation_date__c);
		System.assertEquals(Date.today(),resultAgr.Cancellation_processed_date__c);
		System.assertEquals('Airline 1 leaves agreement',resultAgr.Cancellation_Reason__c);
	}

	@isTest
	static void Test_WrapperAgreement_NotMixed() {
		loadData();
		Account account1 = [Select Id,Name from Account where Name = 'Air France'];
		Account account2 = [Select Id,Name from Account where Name = 'Swissair'];

		MITA_Agreement__c agr = new MITA_Agreement__c(
		Airline_1__c = account1.Id,
		Airline_2__c = account2.Id,
		MITAorBIETA__c = 'MITA',
		Agreement_type__c = 'The Passenger Interline Agreement',
		Effective_date__c = Date.today()
		);

		Test.startTest();
		MITA_AgreementsCtrl.WrapperAgreement wrapper = new MITA_AgreementsCtrl.WrapperAgreement(agr, account1);
		wrapper.checkMixAgreement(null);
		//System.assertEquals(wrapper.checkMixAgreement(), false);
		wrapper.viewSeparated = false;
		wrapper.save(true);
		Id resultId = wrapper.getId();
		wrapper.getOtherDesignatorCode();
		wrapper.getOtherAirlineName();
		wrapper.getAgreementType();
		wrapper.getEffectiveDate();
		wrapper.getStatus();
		wrapper.getActive();
		Test.stopTest();

		MITA_Agreement__c resultAgr = [Select id from MITA_Agreement__c where id = :resultId];
		System.assert(resultAgr!= null);
	}

	@isTest
	static void Test_WrapperAgreement_MixedAgreement() {
		loadData();
		Account account1 = [Select Id,Name from Account where Name = 'Air France'];
		Account account2 = [Select Id,Name from Account where Name = 'Swissair'];

		MITA_Agreement__c agrPAX = new MITA_Agreement__c(
			Airline_1__c = account1.Id,
			Airline_2__c = account2.Id,
			MITAorBIETA__c = 'MITA',
			Agreement_type__c = 'The Passenger Interline Agreement',
			Effective_date__c = Date.today()
		);
		insert agrPAX;
		agrPAX = [SELECT Airline_1__c, Airline_2__c, Active__c, Status__c, Agreement_type__c, Cancellation_date__c, Created_date__c, Effective_date__c, Airline_1__r.Name_on_AOC__c , Airline_2__r.Name_on_AOC__c ,
			Airline1_designator_code__c , Airline2_designator_code__c , MITAorBIETA__c, Withdrawal_Request_Reception_Date__c, Agreement_processed_date__c, Cancellation_processed_date__c
			from MITA_Agreement__c where id =:agrPAX.Id];

		MITA_Agreement__c agrCARGO = new MITA_Agreement__c(
			Airline_1__c = account1.Id,
			Airline_2__c = account2.Id,
			MITAorBIETA__c = 'MITA',
			Agreement_type__c = 'The Cargo Interline Agreement',
			Effective_date__c = Date.today()
		);
		insert agrCARGO;
		agrCARGO = [SELECT Airline_1__c, Airline_2__c, Active__c, Status__c, Agreement_type__c, Cancellation_date__c, Created_date__c, Effective_date__c, Airline_1__r.Name_on_AOC__c , Airline_2__r.Name_on_AOC__c ,
			Airline1_designator_code__c , Airline2_designator_code__c , MITAorBIETA__c, Withdrawal_Request_Reception_Date__c, Agreement_processed_date__c, Cancellation_processed_date__c
			from MITA_Agreement__c where id =:agrCARGO.Id];

		System.assertEquals(true, agrPAX.Active__c);
		System.assertEquals(true, agrCARGO.Active__c);
		System.assertEquals('MITA', agrPAX.MITAorBIETA__c);
		System.assertEquals('MITA', agrCARGO.MITAorBIETA__c);

		Test.startTest();
		MITA_AgreementsCtrl.WrapperAgreement wrapper = new MITA_AgreementsCtrl.WrapperAgreement(agrPAX, account1);
		Boolean result = wrapper.checkMixAgreement(agrCARGO);
		System.assertEquals(true, result);

		wrapper.save(true);

		MITA_Agreement__c resultAgr = wrapper.getAgreement();
		wrapper.getId();
		wrapper.getOtherDesignatorCode();
		wrapper.getOtherAirlineName();
		wrapper.getAgreementType();
		wrapper.getEffectiveDate();
		wrapper.getStatus();
		wrapper.getActive();

		Test.stopTest();

	}

}