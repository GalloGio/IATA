@isTest
public class IA_AllCtrlTest {

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
		for ( Account account: [SELECT Id,Name FROM Account]) {
			if (account.Name == TestDataFactory_Accounts.DEFAULTNAME + ' 0') airline1 = account;
			if (account.Name == TestDataFactory_Accounts.DEFAULTNAME + ' 1') airline2 = account;
		}
		System.assert(airline1!=null, 'Airline 1 not found');
		System.assert(airline2!=null, 'Airline 2 not found');
	}

	static TestMethod void testController(){
		queryRecords();

		Test.StartTest();
		IA_AllController ctrl = new IA_AllController();
		ctrl.account = airline1;
		ctrl.hasWithdrawPermission = true;
		System.assert(ctrl.AllAgreementsRows!=null);
		System.assertEquals(0,ctrl.AllAgreementsRows.size());
		System.assertEquals(0,ctrl.getOptionNames().size());
		System.assertEquals(0,ctrl.getOptionTypes().size());
		System.assertEquals(0,ctrl.getOptionStatus().size());
		Test.stopTest();
	}

	static TestMethod void testQueryAgreements(){
		queryRecords();

		MITA_Agreement__c agreement1 = new MITA_Agreement__c(
			Airline_1__c = airline1.Id,
			Airline_2__c = airline2.Id,
			MITAorBIETA__c = IA_util.MITA,
			Agreement_Type__c = IA_util.TYPE_PAX,
			Created_date__c = Date.today(),
			Agreement_processed_date__c = Date.today(),
			Effective_date__c = Date.today()
		);
		MITA_Agreement__c agreement2 = new MITA_Agreement__c(
			Airline_1__c = airline2.Id,
			Airline_2__c = airline1.Id,
			MITAorBIETA__c = IA_util.BIETA,
			Agreement_Type__c = IA_util.TYPE_PAX_PARTICIPATING_AIRLINE,
			Created_date__c = Date.today(),
			Agreement_processed_date__c = Date.today(),
			Effective_date__c = Date.today()
		);
		insert new List<MITA_Agreement__c>{agreement1, agreement2};

		Test.StartTest();
		IA_AllController ctrl = new IA_AllController();
		ctrl.account = airline1;
		ctrl.hasWithdrawPermission = true;

		// check if there are 2 agreements
		System.assert(ctrl.AllAgreementsRows!=null);
		System.assertEquals(2,ctrl.AllAgreementsRows.size());
		System.assertEquals(2,ctrl.getOptionNames().size());
		System.assertEquals(2,ctrl.getOptionTypes().size());
		System.assertEquals(1,ctrl.getOptionStatus().size());

		// modal is closed
		System.assert(ctrl.selectedAgreementId==null);
		System.assert(ctrl.selectedAgreement==null);
		System.assert(ctrl.selectedAgreementOtherAirline==null);
		System.assert(ctrl.showModalAgreementDetail!=true);

		// modal is open with the selected id
		ctrl.selectedAgreementId = IA_util.Encrypt(IA_AllController.EncDecKey,agreement1.Id);
		ctrl.OpenModalAgreementDetail();
		System.assert(ctrl.selectedAgreementId!=null);
		System.assert(ctrl.selectedAgreement!=null);
		System.assert(ctrl.selectedAgreementOtherAirline!=null);
		System.assert(ctrl.showModalAgreementDetail);

		// modal is closed again
		ctrl.closeModalAgreementDetail();
		System.assert(ctrl.selectedAgreementId==null);
		System.assert(ctrl.selectedAgreement==null);
		System.assert(ctrl.selectedAgreementOtherAirline==null);
		System.assert(ctrl.showModalAgreementDetail==false);

		Test.stopTest();
	}

}