@isTest
public class ISSP_InterlineAgreementsAllCtrlTest {

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
				SELECT Name, Airline_Prefix__c, Airline_designator__c, IATAcode__c, Membership_status__c, MITA_Member__c, BIETA_Member__c, Logo_File_ID__c,
				MITA_IATA_Interline_Passenger__c, MITA_IATA_Interline_Cargo__c, MITA_One_way_Pass_Issuing_Airline__c, MITA_One_way_Pass_Participating__c,
				BIETA_Bilateral_Date__c, BIETA_One_way_Electronic_Issuing_Airline__c, BIETA_One_way_Electronic_Participating__c, BIETA_One_way_Intermodal_Issuing_Airline__c,
				BIETA_One_way_Intermodal_Participating__c
				FROM Account])
		{
			if (account.Name == 'MyAirline1') airline1 = account;
			if (account.Name == 'MyAirline2') airline2 = account;
		}
	}

	static TestMethod void testController(){
		queryRecords();

		Test.StartTest();
		ISSP_InterlineAgreementsAllController ctrl = new ISSP_InterlineAgreementsAllController();
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
			MITAorBIETA__c = MITAutil.MITA,
			Agreement_Type__c = MITAutil.TYPE_PAX,
			Created_date__c = Date.today(),
			Agreement_processed_date__c = Date.today(),
			Effective_date__c = Date.today()
		);
		MITA_Agreement__c agreement2 = new MITA_Agreement__c(
			Airline_1__c = airline2.Id,
			Airline_2__c = airline1.Id,
			MITAorBIETA__c = MITAutil.BIETA,
			Agreement_Type__c = MITAutil.TYPE_PAX_PARTICIPATING_AIRLINE,
			Created_date__c = Date.today(),
			Agreement_processed_date__c = Date.today(),
			Effective_date__c = Date.today()
		);
		insert new List<MITA_Agreement__c>{agreement1, agreement2};

		Test.StartTest();
		ISSP_InterlineAgreementsAllController ctrl = new ISSP_InterlineAgreementsAllController();
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
		ctrl.selectedAgreementId = MITAutil.Encrypt(ISSP_InterlineAgreementsAllController.EncDecKey,agreement1.Id);
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