@isTest
public class ISSP_InterlineAgreementsReqCtrlTest {

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
		ISSP_InterlineAgreementsReqController ctrl = new ISSP_InterlineAgreementsReqController();
		ctrl.account = airline1;
		ctrl.hasApprovePermission = true;

		System.assert(ctrl.RequesterAgreementsRows!=null);
		System.assertEquals(0,ctrl.RequesterAgreementsRows.size());
		System.assert(ctrl.getOptionNames()!=null);
		System.assert(ctrl.getOptionTypes()!=null);
		System.assert(ctrl.getOptionStatus()!=null);
		ctrl.refreshPage();

		Test.stopTest();
	}


	static TestMethod void testRequestedAgreement(){
		queryRecords();

		insert new MITA_Agreement__c(
			Airline_1__c = airline1.Id,
			Airline_2__c = airline2.Id,
			Effective_date__c = Date.today(),
			Created_date__c = Date.today(),
			MITAorBIETA__c=MITAutil.MITA,
			Agreement_Type__c = MITAutil.TYPE_CARGO);

		Test.StartTest();
		ISSP_InterlineAgreementsReqController ctrl = new ISSP_InterlineAgreementsReqController();
		ctrl.account = airline1;
		ctrl.hasApprovePermission = true;

		System.assert(ctrl.RequesterAgreementsRows!=null);
		System.assertEquals(1,ctrl.RequesterAgreementsRows.size());

		Test.stopTest();
	}

	static TestMethod void testRejectedAgreement(){
		queryRecords();

		insert new MITA_Agreement__c(
			Airline_1__c = airline2.Id,
			Airline_2__c = airline1.Id,
			Effective_date__c = Date.today(),
			Created_date__c = Date.today(),
			MITAorBIETA__c=MITAutil.MITA,
			Agreement_Type__c = MITAutil.TYPE_CARGO,
			Cancellation_date__c = Date.today(),
			Cancellation_processed_date__c = Date.today(),
			Cancellation_Reason__c = 'Rejected by Airline 2'
			
		);

		Test.StartTest();
		ISSP_InterlineAgreementsReqController ctrl = new ISSP_InterlineAgreementsReqController();
		ctrl.account = airline1;
		ctrl.hasApprovePermission = true;

		System.assert(ctrl.RequesterAgreementsRows!=null);
		System.assertEquals(1,ctrl.RequesterAgreementsRows.size());

		Test.stopTest();
	}

	static TestMethod void testRequestableAgreement_Approve(){
		queryRecords();

		MITA_Agreement__c agreement =  new MITA_Agreement__c(
			Airline_1__c = airline2.Id,
			Airline_2__c = airline1.Id,
			Effective_date__c = Date.today(),
			Created_date__c = Date.today(),
			MITAorBIETA__c=MITAutil.MITA,
			Agreement_Type__c = MITAutil.TYPE_CARGO);
		insert agreement;

		Test.StartTest();
		ISSP_InterlineAgreementsReqController ctrl = new ISSP_InterlineAgreementsReqController();
		ctrl.account = airline1;
		ctrl.hasApprovePermission = true;

		System.assert(ctrl.RequesterAgreementsRows!=null);
		System.assertEquals(1,ctrl.RequesterAgreementsRows.size());

		//approve agreement
		ctrl.selectedAgreement = MITAutil.Encrypt(ISSP_InterlineAgreementsReqController.EncDecKey,agreement.Id);
		ctrl.approveAgreement();

		System.assert(ctrl.toast!=null);
		System.assertEquals('success',ctrl.toast.type);
		agreement = [SELECT Id,Agreement_processed_date__c FROM MITA_Agreement__c WHERE Id = :agreement.Id];
		System.assertEquals(Date.today(),agreement.Agreement_processed_date__c);

		//undo approve agreement
		ctrl.undoId = ctrl.toast.undoactionId;
		ctrl.undoAction();
		System.assert(ctrl.toast!=null);
		System.assertEquals('undo',ctrl.toast.type);
		agreement = [SELECT Id,Agreement_processed_date__c FROM MITA_Agreement__c WHERE Id = :agreement.Id];
		System.assertEquals(null,agreement.Agreement_processed_date__c);

		Test.stopTest();
	}

	static TestMethod void testRequestableAgreement_Reject(){
		queryRecords();

		MITA_Agreement__c agreement =  new MITA_Agreement__c(
			Airline_1__c = airline2.Id,
			Airline_2__c = airline1.Id,
			Effective_date__c = Date.today(),
			Created_date__c = Date.today(),
			MITAorBIETA__c=MITAutil.MITA,
			Agreement_Type__c = MITAutil.TYPE_CARGO);
		insert agreement;

		Test.StartTest();
		ISSP_InterlineAgreementsReqController ctrl = new ISSP_InterlineAgreementsReqController();
		ctrl.account = airline1;
		ctrl.hasApprovePermission = true;

		System.assert(ctrl.RequesterAgreementsRows!=null);
		System.assertEquals(1,ctrl.RequesterAgreementsRows.size());

		//reject agreement
		ctrl.selectedAgreement = MITAutil.Encrypt(ISSP_InterlineAgreementsReqController.EncDecKey,agreement.Id);
		ctrl.rejectAgreement();

		System.assert(ctrl.toast!=null);
		System.assertEquals('rejected',ctrl.toast.type);

		agreement = [SELECT Id,Cancellation_date__c, Cancellation_processed_date__c, Cancellation_Reason__c FROM MITA_Agreement__c WHERE Id = :agreement.Id];
		System.assertEquals(Date.today(),agreement.Cancellation_date__c);
		System.assertEquals(Date.today(),agreement.Cancellation_processed_date__c);
		System.assertEquals('Rejected by Airline 2',agreement.Cancellation_Reason__c);

		//undo reject agreement
		ctrl.undoId = ctrl.toast.undoactionId;
		ctrl.undoAction();
		System.assert(ctrl.toast!=null);
		System.assertEquals('undo',ctrl.toast.type);
		agreement = [SELECT Id,Cancellation_date__c, Cancellation_processed_date__c, Cancellation_Reason__c FROM MITA_Agreement__c WHERE Id = :agreement.Id];
		System.assertEquals(null,agreement.Cancellation_date__c);
		System.assertEquals(null,agreement.Cancellation_processed_date__c);
		System.assertEquals(null,agreement.Cancellation_Reason__c);

		Test.stopTest();
	}

	static TestMethod void testModal(){
		queryRecords();

		MITA_Agreement__c agreement =  new MITA_Agreement__c(
			Airline_1__c = airline2.Id,
			Airline_2__c = airline1.Id,
			Effective_date__c = Date.today(),
			Created_date__c = Date.today(),
			MITAorBIETA__c=MITAutil.MITA,
			Agreement_Type__c = MITAutil.TYPE_CARGO);
		insert agreement;

		Test.StartTest();
		ISSP_InterlineAgreementsReqController ctrl = new ISSP_InterlineAgreementsReqController();
		ctrl.account = airline1;
		ctrl.hasApprovePermission = true;

		System.assert(ctrl.RequesterAgreementsRows!=null);
		System.assertEquals(1,ctrl.RequesterAgreementsRows.size());

		System.assertEquals(null,ctrl.selectedAgreementId);
		System.assertEquals(null,ctrl.selectedAgreementDetail);
		System.assertEquals(null,ctrl.selectedAgreementOtherAirline);
		System.assertEquals(null,ctrl.showModalAgreementDetail);

		ctrl.selectedAgreementId = MITAutil.Encrypt(ISSP_InterlineAgreementsReqController.EncDecKey,agreement.Id);
		ctrl.OpenModalAgreementDetail();
		System.assert(ctrl.selectedAgreementId!=null);
		System.assert(ctrl.selectedAgreementDetail!=null);
		System.assert(ctrl.selectedAgreementOtherAirline!=null);
		System.assertEquals(true,ctrl.showModalAgreementDetail);

		ctrl.closeModalAgreementDetail();
		System.assertEquals(null,ctrl.selectedAgreementId);
		System.assertEquals(null,ctrl.selectedAgreementDetail);
		System.assertEquals(null,ctrl.selectedAgreementOtherAirline);
		System.assertEquals(false,ctrl.showModalAgreementDetail);

		Test.stopTest();
	}
}
