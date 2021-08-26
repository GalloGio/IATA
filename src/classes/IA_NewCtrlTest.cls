@isTest
public class IA_NewCtrlTest {

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

	private static void verifyRows(list<IA_NewController.AvailableAgreementsRow> listRow, Map<String,List<String>> mapExpectedAgreements) {
		for(IA_NewController.AvailableAgreementsRow row: listRow) {
			System.assertEquals(airline2.Name, row.airlinename);
			list<IA_NewController.AvailableAgreementsDetailRow> existingAgreements = row.details;
			System.assertEquals(mapExpectedAgreements.size(),existingAgreements.size(), 'expected : ' + mapExpectedAgreements + ', Actual: ' + existingAgreements);
			for (IA_NewController.AvailableAgreementsDetailRow detailRow: existingAgreements) {
				list<String> expectedAgreements = mapExpectedAgreements.get(detailRow.agreementname);
				System.assertEquals(expectedAgreements.size(), detailRow.agreements.size(), 'expected : ' + expectedAgreements + ', Actual: ' + detailRow.agreements);
			}
		}
	}

	static TestMethod void testAllAgreements(){
		queryRecords();

		Test.StartTest();
		IA_NewController ctrl = new IA_NewController();
		ctrl.account = airline1;
		ctrl.hasRequestPermission = true;
		ctrl.getMinEffectiveAge();

		Map<String,List<String>> expectedAgreements = IA_util.MAP_AGREEMENTS_BY_TYPE;
		verifyRows(ctrl.availableAgreementsRows,expectedAgreements);
		System.assert(ctrl.getOptionNames()!=null);
		System.assert(ctrl.getOptionTypes()!=null);

		Test.stopTest();
	}

	static TestMethod void testOnlyEMD1(){
		queryRecords();

		airline1.MITA_Member__c = false; //removing mita agreements from one side
		airline2.BIETA_Member__c = false; //removing bieta agreements from the other side
		update new list<Account>{airline1, airline2};
		//only EMD agreement will show

		Test.StartTest();
		IA_NewController ctrl = new IA_NewController();
		ctrl.account = airline1;
		ctrl.hasRequestPermission = true;

		Map<String,List<String>> expectedAgreements = IA_util.MAP_AGREEMENTS_BY_TYPE;
		expectedAgreements.remove(IA_util.MITA);
		expectedAgreements.remove(IA_util.BIETA);

		verifyRows(ctrl.availableAgreementsRows,expectedAgreements);
		Test.stopTest();
	}

	static TestMethod void testOnlyEMD2(){
		queryRecords();

		// removing permission from all mita and bieta from theri respective date fields
		airline1.MITA_IATA_Interline_Passenger__c = null;
		airline2.MITA_IATA_Interline_Cargo__c = null;
		airline1.MITA_One_way_Pass_Issuing_Airline__c = null;
		airline2.MITA_One_way_Pass_Issuing_Airline__c = null;
		airline1.BIETA_Bilateral_Date__c = null;
		airline2.BIETA_One_way_Electronic_Issuing_Airline__c = null;
		airline1.BIETA_One_way_Electronic_Issuing_Airline__c = null;
		airline2.BIETA_One_way_Intermodal_Issuing_Airline__c = null;
		airline1.BIETA_One_way_Intermodal_Issuing_Airline__c = null;
		update new list<Account>{airline1, airline2};
		//only EMD agreement will show

		Test.StartTest();
		IA_NewController ctrl = new IA_NewController();
		ctrl.account = airline1;
		ctrl.hasRequestPermission = true;

		Map<String,List<String>> expectedAgreements = IA_util.MAP_AGREEMENTS_BY_TYPE;
		expectedAgreements.remove(IA_util.MITA);
		expectedAgreements.remove(IA_util.BIETA);

		verifyRows(ctrl.availableAgreementsRows,expectedAgreements);
		Test.stopTest();
	}

	static TestMethod void testOnlyBilateral(){
		queryRecords();

		airline2.BIETA_Member__c = false; //removing bieta agreements from the other side
		update new list<Account>{airline1, airline2};
		// insert all MITA agreements except TYPE_PAX, which is bilateral
		insert new list<MITA_Agreement__c>{
			new MITA_Agreement__c(Airline_1__c = airline1.Id, Airline_2__c = airline2.Id, MITAorBIETA__c=IA_util.MITA, Effective_date__c = Date.today(), Agreement_Type__c = IA_util.TYPE_CARGO),
			new MITA_Agreement__c(Airline_1__c = airline1.Id, Airline_2__c = airline2.Id, MITAorBIETA__c=IA_util.MITA, Effective_date__c = Date.today(), Agreement_Type__c = IA_util.TYPE_ISSUING_AIRLINE),
			new MITA_Agreement__c(Airline_1__c = airline1.Id, Airline_2__c = airline2.Id, MITAorBIETA__c=IA_util.MITA, Effective_date__c = Date.today(), Agreement_Type__c = IA_util.TYPE_PARTICIPATING_AIRLINE)
		};

		Test.StartTest();
		IA_NewController ctrl = new IA_NewController();
		ctrl.account = airline1;
		ctrl.hasRequestPermission = true;

		Map<String,List<String>> expectedAgreements = IA_util.MAP_AGREEMENTS_BY_TYPE;
		expectedAgreements.put(IA_util.MITA,new list<String>{IA_util.TYPE_PAX}); //only PAX for MITA
		expectedAgreements.remove(IA_util.BIETA);

		verifyRows(ctrl.availableAgreementsRows,expectedAgreements);
		Test.stopTest();
	}

	static TestMethod void testOnlyOneWay1(){
		queryRecords();

		airline2.BIETA_Member__c = false; //removing bieta agreements from the other side
		update new list<Account>{airline1, airline2};
		// insert all MITA agreements except TYPE_ISSUING_AIRLINE, which is bilateral
		insert new list<MITA_Agreement__c>{
			new MITA_Agreement__c(Airline_1__c = airline1.Id, Airline_2__c = airline2.Id, MITAorBIETA__c=IA_util.MITA, Effective_date__c = Date.today(), Agreement_Type__c = IA_util.TYPE_PAX),
			new MITA_Agreement__c(Airline_1__c = airline1.Id, Airline_2__c = airline2.Id, MITAorBIETA__c=IA_util.MITA, Effective_date__c = Date.today(), Agreement_Type__c = IA_util.TYPE_CARGO),
			new MITA_Agreement__c(Airline_1__c = airline1.Id, Airline_2__c = airline2.Id, MITAorBIETA__c=IA_util.MITA, Effective_date__c = Date.today(), Agreement_Type__c = IA_util.TYPE_PARTICIPATING_AIRLINE)
		};

		Test.StartTest();
		IA_NewController ctrl = new IA_NewController();
		ctrl.account = airline1;
		ctrl.hasRequestPermission = true;

		Map<String,List<String>> expectedAgreements = IA_util.MAP_AGREEMENTS_BY_TYPE;
		expectedAgreements.put(IA_util.MITA,new list<String>{IA_util.TYPE_ISSUING_AIRLINE}); //only ISSUING for MITA
		expectedAgreements.remove(IA_util.BIETA);

		verifyRows(ctrl.availableAgreementsRows,expectedAgreements);
		Test.stopTest();
	}

	static TestMethod void testOnlyOneWay2(){
		queryRecords();

		airline2.BIETA_Member__c = false; //removing bieta agreements from the other side
		update new list<Account>{airline1, airline2};
		// insert all MITA agreements except TYPE_ISSUING_AIRLINE but acts as PARTICIPATING because Airline1 and Airline2 are interchanged
		insert new list<MITA_Agreement__c>{
			new MITA_Agreement__c(Airline_1__c = airline1.Id, Airline_2__c = airline2.Id, MITAorBIETA__c=IA_util.MITA, Effective_date__c = Date.today(), Agreement_Type__c = IA_util.TYPE_PAX),
			new MITA_Agreement__c(Airline_1__c = airline1.Id, Airline_2__c = airline2.Id, MITAorBIETA__c=IA_util.MITA, Effective_date__c = Date.today(), Agreement_Type__c = IA_util.TYPE_CARGO),
			new MITA_Agreement__c(Airline_1__c = airline2.Id, Airline_2__c = airline1.Id, MITAorBIETA__c=IA_util.MITA, Effective_date__c = Date.today(), Agreement_Type__c = IA_util.TYPE_PARTICIPATING_AIRLINE)
		};

		Test.StartTest();
		IA_NewController ctrl = new IA_NewController();
		ctrl.account = airline1;
		ctrl.hasRequestPermission = true;

		Map<String,List<String>> expectedAgreements = IA_util.MAP_AGREEMENTS_BY_TYPE;
		//it expect only PARTICIPATING because the participating agreement inserted before is ISSUING for airline 1
		expectedAgreements.put(IA_util.MITA,new list<String>{IA_util.TYPE_PARTICIPATING_AIRLINE});
		expectedAgreements.remove(IA_util.BIETA);

		verifyRows(ctrl.availableAgreementsRows,expectedAgreements);
		Test.stopTest();
	}

	static TestMethod void testModal(){
		queryRecords();

		IA_NewController ctrl = new IA_NewController();
		ctrl.account = airline1;
		ctrl.hasRequestPermission = true;
	
		Test.StartTest();

		// check modal is closed
		System.assert(ctrl.selectedAccount==null);
		System.assert(ctrl.selectedAgreementName==null);
		System.assert(ctrl.showModalNewAgreement!=true);
		System.assert(ctrl.newAgreementAirlineName==null);
		System.assert(ctrl.listOptionAgreementTypes==null);
		System.assert(ctrl.newAgreement==null);

		// open modal with an account
		ctrl.selectedAccount = IA_util.Encrypt(IA_NewController.EncDecKey,airline2.Id);
		ctrl.selectedAgreementName = IA_util.MITA;
		ctrl.openModalNewAgreement();
		System.assert(ctrl.selectedAccount!=null);
		System.assert(ctrl.selectedAgreementName!=null);
		System.assert(ctrl.showModalNewAgreement==true);
		System.assert(ctrl.newAgreementAirlineName!=null);
		System.assert(ctrl.listOptionAgreementTypes!=null);
		System.assert(ctrl.newAgreement!=null);

		//save agreement with error
		ctrl.saveNewAgreement();
		System.assert(ctrl.alertModal!=null);
		System.assertEquals(IA_util.ALERTMODAL_ERROR,ctrl.alertModal.msgType, 'alertmodal ' + ctrl.alertModal);
		ctrl.resetAlertModal();

		// save agreement with an unexpected error: adding a random value in id field
		ctrl.newAgreement.Id = 'a6G1l000000xKRr';
		ctrl.saveNewAgreement();
		System.assert(ctrl.alertModal!=null);
		System.assertEquals(IA_util.ALERTMODAL_ERROR,ctrl.alertModal.msgType, 'alertmodal ' + ctrl.alertModal);

		//finally saving the new agreement without errors
		ctrl.newAgreement.Id = null;
		ctrl.newAgreement.Agreement_type__c = IA_util.TYPE_PAX;
		ctrl.newAgreement.Effective_date__c = Date.today();
		ctrl.saveNewAgreement();
		System.assert(ctrl.alertModal!=null);
		System.assertEquals(IA_util.ALERTMODAL_SUCCESSNEW,ctrl.alertModal.msgType, 'alertmodal ' + ctrl.alertModal);

		// close modal
		ctrl.closeModalNewAgreement();
		System.assert(ctrl.selectedAccount!=null);
		System.assert(ctrl.selectedAgreementName!=null);
		System.assert(ctrl.showModalNewAgreement!=true);
		System.assert(ctrl.newAgreement==null);

		Test.stopTest();
	}
}