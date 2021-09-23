@isTest
public class IA_DetailCtrlTest {

	private static Account airline1;
	private static Account airline2;

	@TestSetup
	public static void setup(){
		list<Account> listAccount = TestDataFactory_Accounts.createAirlineAccounts(2);
		for (Account account: listAccount) {
			account.ACLI_Status__c = 'Active Company';
			account.MITA_Member__c = true;
			account.BIETA_Member__c = true;
			account.MITA_IATA_Interline_Passenger__c = Date.today();
			account.MITA_IATA_Interline_Cargo__c = Date.today();
			account.MITA_One_way_Pass_Issuing_Airline__c = Date.today();
			account.MITA_One_way_Pass_Participating__c = Date.today();
			account.BIETA_Bilateral_Date__c = Date.today();
			account.BIETA_One_way_Electronic_Issuing_Airline__c = Date.today();
			account.BIETA_One_way_Electronic_Participating__c = Date.today();
			account.BIETA_One_way_Intermodal_Issuing_Airline__c = Date.today();
			account.BIETA_One_way_Intermodal_Participating__c = Date.today();
		}
		insert listAccount;
	}

	private static void queryRecords() {
		for ( Account account: [SELECT Name, Airline_Prefix__c, Airline_designator__c, IATAcode__c, Membership_status__c, MITA_Member__c, BIETA_Member__c, Company_Logo__c,
				MITA_IATA_Interline_Passenger__c, MITA_IATA_Interline_Cargo__c, MITA_One_way_Pass_Issuing_Airline__c, MITA_One_way_Pass_Participating__c,
				BIETA_Bilateral_Date__c, BIETA_One_way_Electronic_Issuing_Airline__c, BIETA_One_way_Electronic_Participating__c, BIETA_One_way_Intermodal_Issuing_Airline__c,
				BIETA_One_way_Intermodal_Participating__c
				FROM Account]
		) {
			if (account.Name == TestDataFactory_Accounts.DEFAULTNAME + ' 0') airline1 = account;
			if (account.Name == TestDataFactory_Accounts.DEFAULTNAME + ' 1') airline2 = account;
		}
		System.assert(airline1!=null, 'Airline 1 not found');
		System.assert(airline2!=null, 'Airline 2 not found');
	}

	static testMethod void testController(){
		queryRecords();

		MITA_Agreement__c agreement =  new MITA_Agreement__c(
			Airline_1__c = airline2.Id,
			Airline_2__c = airline1.Id,
			Effective_date__c = Date.today(),
			Created_date__c = Date.today(),
			MITAorBIETA__c=IA_util.MITA,
			Agreement_Type__c = IA_util.TYPE_PARTICIPATING_AIRLINE);
		insert agreement;

		Test.StartTest();
		IA_DetailController ctrl = new IA_DetailController();
		ctrl.selectedAgreement = agreement;
		ctrl.otherAirline = airline2;
		ctrl.hasWithdrawPermission = true;
		ctrl.getDaysForWithdrawal();
		ctrl.getWithdrawnDateFormatted();

		System.assert(ctrl.agreementDetail!=null);

		Test.stopTest();
	}

	static testMethod void testWithdraw(){
		queryRecords();

		MITA_Agreement__c agreement =  new MITA_Agreement__c(
			Airline_1__c = airline2.Id,
			Airline_2__c = airline1.Id,
			Effective_date__c = Date.today(),
			Created_date__c = Date.today(),
			MITAorBIETA__c=IA_util.MITA,
			Agreement_Type__c = IA_util.TYPE_PARTICIPATING_AIRLINE);
		insert agreement;

		Test.StartTest();
		IA_DetailController ctrl = new IA_DetailController();
		ctrl.selectedAgreement = agreement;
		ctrl.otherAirline = airline2;
		ctrl.hasWithdrawPermission = true;

		// withdraw doesn't work because the cancellation date is null
		System.assertEquals(null,ctrl.agreementCancellation.Cancellation_date__c);
		ctrl.withdrawAgreement();
		System.assertEquals(null,ctrl.agreementCancellation.Cancellation_date__c);

		// successfuly withdrawn
		ctrl.agreementCancellation.Cancellation_date__c = Date.today().addDays(ctrl.getDaysForWithdrawal());
		ctrl.withdrawAgreement();
		System.assertEquals(Date.today(),ctrl.selectedAgreement.Cancellation_processed_date__c);
		System.assertEquals(Date.today(),ctrl.selectedAgreement.Withdrawal_Request_Reception_Date__c);
		System.assertEquals(IA_util.REASON_CANCELLATION_AIRLINE1,ctrl.selectedAgreement.Cancellation_Reason__c);
		System.assertEquals(ctrl.agreementCancellation.Cancellation_date__c,ctrl.selectedAgreement.Cancellation_date__c);
		System.assertEquals(true,ctrl.showSuccessWithdrawn);

		Test.stopTest();
	}

	
	static testmethod void testHistory(){
		queryRecords();

		MITA_Agreement__c agreement =  new MITA_Agreement__c(
			Airline_1__c = airline2.Id,
			Airline_2__c = airline1.Id,
			Effective_date__c = Date.today(),
			Created_date__c = Date.today(),
			MITAorBIETA__c=IA_util.MITA,
			Agreement_Type__c = IA_util.TYPE_PARTICIPATING_AIRLINE);
		insert agreement;

		list<MITA_Agreement__history> fakeHistory = new list<MITA_Agreement__history>();
		fakeHistory.add(new MITA_Agreement__history(
			ParentId = agreement.Id,
			field = IA_DetailController.HISTORY_CREATED
		));
		fakeHistory.add(new MITA_Agreement__history(
			ParentId = agreement.Id,
			field = IA_DetailController.HISTORY_CANCELLATION_FIELDNAME
		));
		fakeHistory.add(new MITA_Agreement__history(
			ParentId = agreement.Id,
			field = IA_DetailController.HISTORY_AGREEMENT_FIELDNAME
		));
		insert fakeHistory;

		Test.StartTest();
		IA_DetailController ctrl = new IA_DetailController();
		ctrl.selectedAgreement = agreement;
		ctrl.otherAirline = airline2;
		ctrl.hasWithdrawPermission = true;

		System.assert(ctrl.AgreementHistory!=null);

		Test.stopTest();
	}

	static testMethod void testContact(){
		queryRecords();

		Id stdContactId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
	
		list<Contact> listContact = TestDataFactory_Contacts.createDefaultContact(10);
		for (Contact contact: listContact) {
			contact.AccountId = airline2.Id;
			contact.RecordtypeId = stdContactId;
			contact.Status__c = 'Active';
			contact.MITA_Contact_Type__c = IA_util.GENERIC_CONTACT;
		}
		insert listContact;

		Test.StartTest();
		IA_DetailController ctrl = new IA_DetailController();
		ctrl.otherAirline = airline2;
		ctrl.hasWithdrawPermission = true;

		List<IA_DetailController.AccountContactRow> listContactRows = ctrl.getAccountContactRows();
		System.assert(listContactRows!=null);
		System.assertEquals(10,listContactRows.size());

		Test.stopTest();
	}

}