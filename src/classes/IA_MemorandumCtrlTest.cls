@isTest
public class IA_MemorandumCtrlTest {

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
		airline1 = listAccount.get(0);
		airline2 = listAccount.get(1);

		MITA_Agreement__c agreement1 = new MITA_Agreement__c(
			Airline_1__c = airline1.Id,
			Airline_2__c = airline2.Id,
			MITAorBIETA__c = IA_util.MITA,
			Agreement_Type__c = IA_util.TYPE_PAX,
			Created_date__c = Date.newInstance(2020,12,15),
			Agreement_processed_date__c = Date.newInstance(2020,12,15),
			Effective_date__c = Date.newInstance(2021,1,15)
		);

		MITA_Agreement__c agreement2 = new MITA_Agreement__c(
			Airline_1__c = airline1.Id,
			Airline_2__c = airline2.Id,
			MITAorBIETA__c = IA_util.MITA,
			Agreement_Type__c = IA_util.TYPE_ISSUING_AIRLINE,
			Created_date__c = Date.newInstance(2020,12,15),
			Agreement_processed_date__c = Date.newInstance(2020,12,15),
			Effective_date__c = Date.newInstance(2021,1,15)
		);

		MITA_Agreement__c agreement3 = new MITA_Agreement__c(
			Airline_1__c = airline2.Id,
			Airline_2__c = airline1.Id,
			MITAorBIETA__c = IA_util.MITA,
			Agreement_Type__c = IA_util.TYPE_ISSUING_AIRLINE,
			Created_date__c = Date.newInstance(2020,12,15),
			Agreement_processed_date__c = Date.newInstance(2020,12,15),
			Effective_date__c = Date.newInstance(2021,1,15)
		);

		MITA_Agreement__c agreement4 = new MITA_Agreement__c(
			Airline_1__c = airline1.Id,
			Airline_2__c = airline2.Id,
			MITAorBIETA__c = IA_util.BIETA,
			Agreement_Type__c = IA_util.TYPE_PAX_ISSUING_AIRLINE,
			Created_date__c = Date.newInstance(2020,12,20),
			Agreement_processed_date__c = Date.newInstance(2020,12,20),
			Effective_date__c = Date.newInstance(2020,12,20),
			Cancellation_Processed_Date__c = Date.newInstance(2020,12,20),
			Cancellation_Date__c = Date.newInstance(2021,1,20),
			Cancellation_Reason__c = IA_util.REASON_CANCELLATION_AIRLINE1
		);

		MITA_Agreement__c agreement5 = new MITA_Agreement__c(
			Airline_1__c = airline2.Id,
			Airline_2__c = airline1.Id,
			MITAorBIETA__c = IA_util.BIETA,
			Agreement_Type__c = IA_util.TYPE_PAX_ISSUING_AIRLINE,
			Created_date__c = Date.newInstance(2020,12,20),
			Agreement_processed_date__c = Date.newInstance(2020,12,20),
			Effective_date__c = Date.newInstance(2020,12,20),
			Cancellation_Processed_Date__c = Date.newInstance(2020,12,20),
			Cancellation_Date__c = Date.newInstance(2021,1,20),
			Cancellation_Reason__c = IA_util.REASON_CANCELLATION_AIRLINE1
		);

		MITA_Agreement__c agreement6 = new MITA_Agreement__c(
			Airline_1__c = airline2.Id,
			Airline_2__c = airline1.Id,
			MITAorBIETA__c = IA_util.MITA,
			Agreement_Type__c = IA_util.TYPE_CARGO,
			Created_date__c = Date.newInstance(2020,12,20),
			Agreement_processed_date__c = Date.newInstance(2020,12,20),
			Effective_date__c = Date.newInstance(2020,12,20),
			Cancellation_Processed_Date__c = Date.newInstance(2020,12,20),
			Cancellation_Date__c = Date.newInstance(2021,1,20),
			Cancellation_Reason__c = IA_util.REASON_CANCELLATION_AIRLINE2
		);

		MITA_Agreement__c agreement7 = new MITA_Agreement__c(
			Airline_1__c = airline1.Id,
			Airline_2__c = airline2.Id,
			MITAorBIETA__c = IA_util.EMD,
			Agreement_Type__c = IA_util.TYPE_EMD,
			Created_date__c = Date.newInstance(2020,12,20),
			Agreement_processed_date__c = Date.newInstance(2020,12,20),
			Effective_date__c = Date.newInstance(2020,12,20),
			Cancellation_Processed_Date__c = Date.newInstance(2020,12,20),
			Cancellation_Date__c = Date.newInstance(2021,1,20),
			Cancellation_Reason__c = IA_util.REASON_CANCELLATION_AIRLINE2
		);

		insert new list<MITA_Agreement__c>{agreement1,agreement2, agreement3, agreement4, agreement5, agreement6, agreement7};
	}

	static testMethod void testController(){
		
		PageReference page = new PageReference('/apex/InterlineAgreementsMemorandum');
		page.getParameters().put('date','01/01/2021');
		page.getParameters().put('number','123456');
		Test.setCurrentPage(page);

		Test.StartTest();
		IA_MemorandumController ctrl = new IA_MemorandumController();
		System.assertEquals(null,ctrl.getIATALogoURL());
		Map<String,List<IA_MemorandumController.WrapperAgreement>> data = ctrl.getDataAgreements();
		Test.stopTest();

		System.assertEquals(6,data.size());
		System.assertEquals(3,data.get(IA_util.MITA + ' ' + IA_util.CONCURRENCES).size());
		System.assertEquals(1,data.get(IA_util.MITA + ' ' + IA_util.WITHDRAWALS).size()); //1, 0
		System.assertEquals(0,data.get(IA_util.BIETA + ' ' + IA_util.CONCURRENCES).size());
		System.assertEquals(2,data.get(IA_util.BIETA + ' ' + IA_util.WITHDRAWALS).size());
		System.assertEquals(0,data.get(IA_util.EMD + ' ' + IA_util.CONCURRENCES).size());
		System.assertEquals(1,data.get(IA_util.EMD + ' ' + IA_util.WITHDRAWALS).size()); //1, 0
	}

}