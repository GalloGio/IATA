@isTest
public class ISSP_InterlineAgreementDetailCtrlTest {

	private static Id RT_AIRLINE = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
	private static Account airline1;
	private static Account airline2;

	@TestSetup
	public static void setup(){
		airline1 = new Account(
			RecordTypeId = RT_AIRLINE,
			Name='MyAirline1',
			ACLI_Status__c = 'Active Company',
			MITA_Member__c = true,
			BIETA_Member__c = true,
			Airline_designator__c = 'AA',
			IATACode__c = '111',
			Airline_Prefix__c = '111',
			MITA_IATA_Interline_Passenger__c = Date.today(),
			MITA_IATA_Interline_Cargo__c = Date.today(),
			MITA_One_way_Pass_Issuing_Airline__c = Date.today(),
			MITA_One_way_Pass_Participating__c = Date.today(),
			BIETA_Bilateral_Date__c = Date.today(),
			BIETA_One_way_Electronic_Issuing_Airline__c = Date.today(),
			BIETA_One_way_Electronic_Participating__c = Date.today(),
			BIETA_One_way_Intermodal_Issuing_Airline__c = Date.today(),
			BIETA_One_way_Intermodal_Participating__c = Date.today()
		);

		airline2 = new Account(
			RecordTypeId = RT_AIRLINE,
			Name='MyAirline2',
			ACLI_Status__c = 'Active Company',
			MITA_Member__c = true,
			BIETA_Member__c = true,
			Airline_designator__c = 'BB',
			IATACode__c = '222',
			Airline_Prefix__c = '222',
			MITA_IATA_Interline_Passenger__c = Date.today(),
			MITA_IATA_Interline_Cargo__c = Date.today(),
			MITA_One_way_Pass_Issuing_Airline__c = Date.today(),
			MITA_One_way_Pass_Participating__c = Date.today(),
			BIETA_Bilateral_Date__c = Date.today(),
			BIETA_One_way_Electronic_Issuing_Airline__c = Date.today(),
			BIETA_One_way_Electronic_Participating__c = Date.today(),
			BIETA_One_way_Intermodal_Issuing_Airline__c = Date.today(),
			BIETA_One_way_Intermodal_Participating__c = Date.today()
		);

		insert new list<Account>{airline1,airline2};
	}

	private static void queryRecords() {
		for ( Account account: [
				SELECT Name, Airline_Prefix__c, Airline_designator__c, IATAcode__c, Membership_status__c, MITA_Member__c, BIETA_Member__c, Company_Logo__c,
				MITA_IATA_Interline_Passenger__c, MITA_IATA_Interline_Cargo__c, MITA_One_way_Pass_Issuing_Airline__c, MITA_One_way_Pass_Participating__c,
				BIETA_Bilateral_Date__c, BIETA_One_way_Electronic_Issuing_Airline__c, BIETA_One_way_Electronic_Participating__c, BIETA_One_way_Intermodal_Issuing_Airline__c,
				BIETA_One_way_Intermodal_Participating__c
				FROM Account])
		{
			if (account.Name == 'MyAirline1') airline1 = account;
			if (account.Name == 'MyAirline2') airline2 = account;
		}
	}

	static testMethod void testController(){
		queryRecords();

		MITA_Agreement__c agreement =  new MITA_Agreement__c(
			Airline_1__c = airline2.Id,
			Airline_2__c = airline1.Id,
			Effective_date__c = Date.today(),
			Created_date__c = Date.today(),
			MITAorBIETA__c=MITAutil.MITA,
			Agreement_Type__c = MITAutil.TYPE_PARTICIPATING_AIRLINE);
		insert agreement;

		Test.StartTest();
		ISSP_InterlineAgreementDetailController ctrl = new ISSP_InterlineAgreementDetailController();
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
			MITAorBIETA__c=MITAutil.MITA,
			Agreement_Type__c = MITAutil.TYPE_PARTICIPATING_AIRLINE);
		insert agreement;

		Test.StartTest();
		ISSP_InterlineAgreementDetailController ctrl = new ISSP_InterlineAgreementDetailController();
		ctrl.selectedAgreement = agreement;
		ctrl.otherAirline = airline2;
		ctrl.hasWithdrawPermission = true;

		// withdraw doesn't work because the cancellation date is null
		System.assertEquals(null,ctrl.dummyAgreement.Cancellation_date__c);
		ctrl.withdrawAgreement();
		System.assertEquals(null,ctrl.dummyAgreement.Cancellation_date__c);

		// successfuly withdrawn
		ctrl.dummyAgreement.Cancellation_date__c = Date.today().addDays(ctrl.getDaysForWithdrawal());
		ctrl.withdrawAgreement();
		System.assertEquals(Date.today(),ctrl.selectedAgreement.Cancellation_processed_date__c);
		System.assertEquals(Date.today(),ctrl.selectedAgreement.Withdrawal_Request_Reception_Date__c);
		System.assertEquals('Airline 1 leaves agreement',ctrl.selectedAgreement.Cancellation_Reason__c);
		System.assertEquals(ctrl.dummyAgreement.Cancellation_date__c,ctrl.selectedAgreement.Cancellation_date__c);
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
			MITAorBIETA__c=MITAutil.MITA,
			Agreement_Type__c = MITAutil.TYPE_PARTICIPATING_AIRLINE);
		insert agreement;

		list<MITA_Agreement__history> fakeHistory = new list<MITA_Agreement__history>();
		fakeHistory.add(new MITA_Agreement__history(
			ParentId = agreement.Id,
			field='created'
		));
		fakeHistory.add(new MITA_Agreement__history(
			ParentId = agreement.Id,
			field='Cancellation_date__c'
		));
		fakeHistory.add(new MITA_Agreement__history(
			ParentId = agreement.Id,
			field='Agreement_processed_date__c'
		));
		insert fakeHistory;

		Test.StartTest();
		ISSP_InterlineAgreementDetailController ctrl = new ISSP_InterlineAgreementDetailController();
		ctrl.selectedAgreement = agreement;
		ctrl.otherAirline = airline2;
		ctrl.hasWithdrawPermission = true;

		System.assert(ctrl.AgreementHistory!=null);

		Test.stopTest();
	}

	static testMethod void testContact(){
		queryRecords();

		insert new Contact(
			FirstName = 'test contact',
			LastName = 'airline2',
			RecordtypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact'),
			Status__c = 'Active',
			AccountId = airline2.Id
		);

		Test.StartTest();
		ISSP_InterlineAgreementDetailController ctrl = new ISSP_InterlineAgreementDetailController();
		ctrl.otherAirline = airline2;
		ctrl.hasWithdrawPermission = true;

		List<ISSP_InterlineAgreementDetailController.AccountContactRow> listContactRows = ctrl.getAccountContactRows();
		System.assert(listContactRows!=null);
		System.assertEquals(1,listContactRows.size());

		Test.stopTest();
	}

}
