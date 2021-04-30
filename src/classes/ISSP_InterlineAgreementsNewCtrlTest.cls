@isTest
public class ISSP_InterlineAgreementsNewCtrlTest {

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

	private static void verifyRows(list<ISSP_InterlineAgreementsNewController.AvailableAgreementsRow> listRow, Map<String,List<String>> mapExpectedAgreements) {
		System.assertEquals(mapExpectedAgreements.size(),listRow.size());
		for(ISSP_InterlineAgreementsNewController.AvailableAgreementsRow row: listRow) {
			System.assertEquals(airline2.Name, row.airlinename);
			set<String> existingAgreements = new Set<String>(row.agreements);
			list<String> expectedAgreements = mapExpectedAgreements.get(row.agreementname);
			System.assertEquals(expectedAgreements.size(), existingAgreements.size(), 'expected : ' + expectedAgreements + ', Actual: ' + existingAgreements);
			for (String expected: expectedAgreements) {
				System.assert(existingAgreements.contains(expected));
			}
		}
	}

	static TestMethod void testAllAgreements(){
		queryRecords();

		Test.StartTest();
		ISSP_InterlineAgreementsNewController ctrl = new ISSP_InterlineAgreementsNewController();
		ctrl.account = airline1;
		ctrl.hasRequestPermission = true;
		ctrl.getMinEffectiveAge();

		Map<String,List<String>> expectedAgreements = MITAutil.MAP_AGREEMENTS_BY_TYPE;
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
		ISSP_InterlineAgreementsNewController ctrl = new ISSP_InterlineAgreementsNewController();
		ctrl.account = airline1;
		ctrl.hasRequestPermission = true;

		Map<String,List<String>> expectedAgreements = MITAutil.MAP_AGREEMENTS_BY_TYPE;
		expectedAgreements.remove(MITAutil.MITA);
		expectedAgreements.remove(MITAutil.BIETA);

		verifyRows(ctrl.availableAgreementsRows,expectedAgreements);
		Test.stopTest();
	}

	static TestMethod void testOnlyEMD2(){
		queryRecords();

		// removing permission from all mita and bieta from theri respective date fields
		airline1.MITA_IATA_Interline_Passenger__c = null;
		airline2.MITA_IATA_Interline_Cargo__c = null;
		airline1.MITA_One_way_Pass_Issuing_Airline__c = null;
		airline2.MITA_One_way_Pass_Participating__c = null;
		airline1.BIETA_Bilateral_Date__c = null;
		airline2.BIETA_One_way_Electronic_Issuing_Airline__c = null;
		airline1.BIETA_One_way_Electronic_Participating__c = null;
		airline2.BIETA_One_way_Intermodal_Issuing_Airline__c = null;
		airline1.BIETA_One_way_Intermodal_Participating__c = null;
		update new list<Account>{airline1, airline2};
		//only EMD agreement will show

		Test.StartTest();
		ISSP_InterlineAgreementsNewController ctrl = new ISSP_InterlineAgreementsNewController();
		ctrl.account = airline1;
		ctrl.hasRequestPermission = true;

		Map<String,List<String>> expectedAgreements = MITAutil.MAP_AGREEMENTS_BY_TYPE;
		expectedAgreements.remove(MITAutil.MITA);
		expectedAgreements.remove(MITAutil.BIETA);

		verifyRows(ctrl.availableAgreementsRows,expectedAgreements);
		Test.stopTest();
	}

	static TestMethod void testOnlyBilateral(){
		queryRecords();

		airline2.BIETA_Member__c = false; //removing bieta agreements from the other side
		update new list<Account>{airline1, airline2};
		// insert all MITA agreements except TYPE_PAX, which is bilateral
		insert new list<MITA_Agreement__c>{
			new MITA_Agreement__c(Airline_1__c = airline1.Id, Airline_2__c = airline2.Id, MITAorBIETA__c=MITAutil.MITA, Effective_date__c = Date.today(), Agreement_Type__c = MITAutil.TYPE_CARGO),
			new MITA_Agreement__c(Airline_1__c = airline1.Id, Airline_2__c = airline2.Id, MITAorBIETA__c=MITAutil.MITA, Effective_date__c = Date.today(), Agreement_Type__c = MITAutil.TYPE_ISSUING_AIRLINE),
			new MITA_Agreement__c(Airline_1__c = airline1.Id, Airline_2__c = airline2.Id, MITAorBIETA__c=MITAutil.MITA, Effective_date__c = Date.today(), Agreement_Type__c = MITAutil.TYPE_PARTICIPATING_AIRLINE)
		};

		Test.StartTest();
		ISSP_InterlineAgreementsNewController ctrl = new ISSP_InterlineAgreementsNewController();
		ctrl.account = airline1;
		ctrl.hasRequestPermission = true;

		Map<String,List<String>> expectedAgreements = MITAutil.MAP_AGREEMENTS_BY_TYPE;
		expectedAgreements.put(MITAutil.MITA,new list<String>{MITAutil.TYPE_PAX}); //only PAX for MITA
		expectedAgreements.remove(MITAutil.BIETA);

		verifyRows(ctrl.availableAgreementsRows,expectedAgreements);
		Test.stopTest();
	}

	static TestMethod void testOnlyOneWay1(){
		queryRecords();

		airline2.BIETA_Member__c = false; //removing bieta agreements from the other side
		update new list<Account>{airline1, airline2};
		// insert all MITA agreements except TYPE_ISSUING_AIRLINE, which is bilateral
		insert new list<MITA_Agreement__c>{
			new MITA_Agreement__c(Airline_1__c = airline1.Id, Airline_2__c = airline2.Id, MITAorBIETA__c=MITAutil.MITA, Effective_date__c = Date.today(), Agreement_Type__c = MITAutil.TYPE_PAX),
			new MITA_Agreement__c(Airline_1__c = airline1.Id, Airline_2__c = airline2.Id, MITAorBIETA__c=MITAutil.MITA, Effective_date__c = Date.today(), Agreement_Type__c = MITAutil.TYPE_CARGO),
			new MITA_Agreement__c(Airline_1__c = airline1.Id, Airline_2__c = airline2.Id, MITAorBIETA__c=MITAutil.MITA, Effective_date__c = Date.today(), Agreement_Type__c = MITAutil.TYPE_PARTICIPATING_AIRLINE)
		};

		Test.StartTest();
		ISSP_InterlineAgreementsNewController ctrl = new ISSP_InterlineAgreementsNewController();
		ctrl.account = airline1;
		ctrl.hasRequestPermission = true;

		Map<String,List<String>> expectedAgreements = MITAutil.MAP_AGREEMENTS_BY_TYPE;
		expectedAgreements.put(MITAutil.MITA,new list<String>{MITAutil.TYPE_ISSUING_AIRLINE}); //only ISSUING for MITA
		expectedAgreements.remove(MITAutil.BIETA);

		verifyRows(ctrl.availableAgreementsRows,expectedAgreements);
		Test.stopTest();
	}

	static TestMethod void testOnlyOneWay2(){
		queryRecords();

		airline2.BIETA_Member__c = false; //removing bieta agreements from the other side
		update new list<Account>{airline1, airline2};
		// insert all MITA agreements except TYPE_ISSUING_AIRLINE but acts as PARTICIPATING because Airline1 and Airline2 are interchanged
		insert new list<MITA_Agreement__c>{
			new MITA_Agreement__c(Airline_1__c = airline1.Id, Airline_2__c = airline2.Id, MITAorBIETA__c=MITAutil.MITA, Effective_date__c = Date.today(), Agreement_Type__c = MITAutil.TYPE_PAX),
			new MITA_Agreement__c(Airline_1__c = airline1.Id, Airline_2__c = airline2.Id, MITAorBIETA__c=MITAutil.MITA, Effective_date__c = Date.today(), Agreement_Type__c = MITAutil.TYPE_CARGO),
			new MITA_Agreement__c(Airline_1__c = airline2.Id, Airline_2__c = airline1.Id, MITAorBIETA__c=MITAutil.MITA, Effective_date__c = Date.today(), Agreement_Type__c = MITAutil.TYPE_PARTICIPATING_AIRLINE)
		};

		Test.StartTest();
		ISSP_InterlineAgreementsNewController ctrl = new ISSP_InterlineAgreementsNewController();
		ctrl.account = airline1;
		ctrl.hasRequestPermission = true;

		Map<String,List<String>> expectedAgreements = MITAutil.MAP_AGREEMENTS_BY_TYPE;
		//it expect only PARTICIPATING because the participating agreement inserted before is ISSUING for airline 1
		expectedAgreements.put(MITAutil.MITA,new list<String>{MITAutil.TYPE_PARTICIPATING_AIRLINE});
		expectedAgreements.remove(MITAutil.BIETA);

		verifyRows(ctrl.availableAgreementsRows,expectedAgreements);
		Test.stopTest();
	}

	static TestMethod void testModal(){
		queryRecords();

		ISSP_InterlineAgreementsNewController ctrl = new ISSP_InterlineAgreementsNewController();
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
		ctrl.selectedAccount = MITAutil.Encrypt(ISSP_InterlineAgreementsNewController.EncDecKey,airline2.Id);
		ctrl.selectedAgreementName = MITAutil.MITA;
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
		System.assertEquals('errorMsg',ctrl.alertModal.msgType, 'alertmodal ' + ctrl.alertModal);
		ctrl.resetAlertModal();

		// save agreement with an unexpected error: adding a random value in id field
		ctrl.newAgreement.Id = 'a6G1l000000xKRr';
		ctrl.saveNewAgreement();
		System.assert(ctrl.alertModal!=null);
		System.assertEquals('errorMsg',ctrl.alertModal.msgType, 'alertmodal ' + ctrl.alertModal);

		//finally saving the new agreement without errors
		ctrl.newAgreement.Id = null;
		ctrl.newAgreement.Agreement_type__c = MITAutil.TYPE_PAX;
		ctrl.newAgreement.Effective_date__c = Date.today();
		ctrl.saveNewAgreement();
		System.assert(ctrl.alertModal!=null);
		System.assertEquals('successMsgNew',ctrl.alertModal.msgType, 'alertmodal ' + ctrl.alertModal);

		// close modal
		ctrl.closeModalNewAgreement();
		System.assert(ctrl.selectedAccount!=null);
		System.assert(ctrl.selectedAgreementName!=null);
		System.assert(ctrl.showModalNewAgreement!=true);
		System.assert(ctrl.newAgreement==null);

		Test.stopTest();
	}
}