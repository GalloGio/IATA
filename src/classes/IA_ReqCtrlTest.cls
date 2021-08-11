@isTest
public class IA_ReqCtrlTest {

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
		IA_ReqController ctrl = new IA_ReqController();
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
			MITAorBIETA__c=IA_util.MITA,
			Agreement_Type__c = IA_util.TYPE_CARGO);

		Test.StartTest();
		IA_ReqController ctrl = new IA_ReqController();
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
			MITAorBIETA__c=IA_util.MITA,
			Agreement_Type__c = IA_util.TYPE_CARGO,
			Cancellation_date__c = Date.today(),
			Cancellation_processed_date__c = Date.today(),
			Cancellation_Reason__c = IA_util.REASON_REJECTION
			
		);

		Test.StartTest();
		IA_ReqController ctrl = new IA_ReqController();
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
			MITAorBIETA__c=IA_util.MITA,
			Agreement_Type__c = IA_util.TYPE_CARGO);
		insert agreement;

		Test.StartTest();
		IA_ReqController ctrl = new IA_ReqController();
		ctrl.account = airline1;
		ctrl.hasApprovePermission = true;

		System.assert(ctrl.RequesterAgreementsRows!=null);
		System.assertEquals(1,ctrl.RequesterAgreementsRows.size());

		//approve agreement
		ctrl.selectedAgreement = IA_util.Encrypt(IA_ReqController.EncDecKey,agreement.Id);
		ctrl.approveAgreement();

		System.assert(ctrl.toast!=null);
		System.assertEquals(IA_ReqController.ALERT_SUCCESS,ctrl.toast.msgType);
		agreement = [SELECT Id,Agreement_processed_date__c FROM MITA_Agreement__c WHERE Id = :agreement.Id];
		System.assertEquals(Date.today(),agreement.Agreement_processed_date__c);

		//undo approve agreement
		ctrl.undoId = ctrl.toast.undoid;
		ctrl.undoAction();
		System.assert(ctrl.toast!=null);
		System.assertEquals(IA_ReqController.ALERT_UNDO,ctrl.toast.msgType);
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
			MITAorBIETA__c=IA_util.MITA,
			Agreement_Type__c = IA_util.TYPE_CARGO);
		insert agreement;

		Test.StartTest();
		IA_ReqController ctrl = new IA_ReqController();
		ctrl.account = airline1;
		ctrl.hasApprovePermission = true;

		System.assert(ctrl.RequesterAgreementsRows!=null);
		System.assertEquals(1,ctrl.RequesterAgreementsRows.size());

		//reject agreement
		ctrl.selectedAgreement = IA_util.Encrypt(IA_ReqController.EncDecKey,agreement.Id);
		ctrl.rejectAgreement();

		System.assert(ctrl.toast!=null);
		System.assertEquals(IA_ReqController.ALERT_REJECTED,ctrl.toast.msgType);

		agreement = [SELECT Id,Cancellation_date__c, Cancellation_processed_date__c, Cancellation_Reason__c FROM MITA_Agreement__c WHERE Id = :agreement.Id];
		System.assertEquals(Date.today(),agreement.Cancellation_date__c);
		System.assertEquals(Date.today(),agreement.Cancellation_processed_date__c);
		System.assertEquals(IA_util.REASON_REJECTION,agreement.Cancellation_Reason__c);

		//undo reject agreement
		ctrl.undoId = ctrl.toast.undoid;
		ctrl.undoAction();
		System.assert(ctrl.toast!=null);
		System.assertEquals(IA_ReqController.ALERT_UNDO,ctrl.toast.msgType);
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
			MITAorBIETA__c=IA_util.MITA,
			Agreement_Type__c = IA_util.TYPE_CARGO);
		insert agreement;

		Test.StartTest();
		IA_ReqController ctrl = new IA_ReqController();
		ctrl.account = airline1;
		ctrl.hasApprovePermission = true;

		System.assert(ctrl.RequesterAgreementsRows!=null);
		System.assertEquals(1,ctrl.RequesterAgreementsRows.size());

		System.assertEquals(null,ctrl.selectedAgreementId);
		System.assertEquals(null,ctrl.selectedAgreementDetail);
		System.assertEquals(null,ctrl.selectedAgreementOtherAirline);
		System.assertEquals(null,ctrl.showModalAgreementDetail);

		ctrl.selectedAgreementId = IA_util.Encrypt(IA_ReqController.EncDecKey,agreement.Id);
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