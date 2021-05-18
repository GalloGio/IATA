@isTest
public class InterlineAgreementsMemorandumCtrlTest {

	private static Id RT_AIRLINE = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');

	@TestSetup
	public static void setup(){
		Account airline1 = new Account(
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

		Account airline2 = new Account(
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

		MITA_Agreement__c agreement1 = new MITA_Agreement__c(
			Airline_1__c = airline1.Id,
			Airline_2__c = airline2.Id,
			MITAorBIETA__c = IA_util.MITA,
			Agreement_Type__c = IA_util.TYPE_PAX,
			Created_date__c = Date.parse('15/01/2021'),
			Agreement_processed_date__c = Date.parse('15/01/2021'),
			Effective_date__c = Date.parse('15/01/2021')
		);

		MITA_Agreement__c agreement2 = new MITA_Agreement__c(
			Airline_1__c = airline1.Id,
			Airline_2__c = airline2.Id,
			MITAorBIETA__c = IA_util.MITA,
			Agreement_Type__c = IA_util.TYPE_ISSUING_AIRLINE,
			Created_date__c = Date.parse('15/01/2021'),
			Agreement_processed_date__c = Date.parse('15/01/2021'),
			Effective_date__c = Date.parse('15/01/2021')
		);

		MITA_Agreement__c agreement3 = new MITA_Agreement__c(
			Airline_1__c = airline2.Id,
			Airline_2__c = airline1.Id,
			MITAorBIETA__c = IA_util.MITA,
			Agreement_Type__c = IA_util.TYPE_ISSUING_AIRLINE,
			Created_date__c = Date.parse('15/01/2021'),
			Agreement_processed_date__c = Date.parse('15/01/2021'),
			Effective_date__c = Date.parse('15/01/2021')
		);

		MITA_Agreement__c agreement4 = new MITA_Agreement__c(
			Airline_1__c = airline1.Id,
			Airline_2__c = airline2.Id,
			MITAorBIETA__c = IA_util.BIETA,
			Agreement_Type__c = IA_util.TYPE_PAX_ISSUING_AIRLINE,
			Created_date__c = Date.parse('20/12/2020'),
			Agreement_processed_date__c = Date.parse('20/12/2020'),
			Effective_date__c = Date.parse('20/12/2020'),
			Cancellation_Processed_Date__c = Date.parse('20/01/2021'),
			Cancellation_Reason__c = 'Requested by Airline 1'
		);

		MITA_Agreement__c agreement5 = new MITA_Agreement__c(
			Airline_1__c = airline2.Id,
			Airline_2__c = airline1.Id,
			MITAorBIETA__c = IA_util.BIETA,
			Agreement_Type__c = IA_util.TYPE_PAX_ISSUING_AIRLINE,
			Created_date__c = Date.parse('20/12/2020'),
			Agreement_processed_date__c = Date.parse('20/12/2020'),
			Effective_date__c = Date.parse('20/12/2020'),
			Cancellation_Processed_Date__c = Date.parse('20/01/2021'),
			Cancellation_Reason__c = 'Requested by Airline 1'
		);

		MITA_Agreement__c agreement6 = new MITA_Agreement__c(
			Airline_1__c = airline2.Id,
			Airline_2__c = airline1.Id,
			MITAorBIETA__c = IA_util.MITA,
			Agreement_Type__c = IA_util.TYPE_CARGO,
			Created_date__c = Date.parse('20/12/2020'),
			Agreement_processed_date__c = Date.parse('20/12/2020'),
			Effective_date__c = Date.parse('20/12/2020'),
			Cancellation_Processed_Date__c = Date.parse('20/01/2021'),
			Cancellation_Reason__c = 'Requested by Airline 1'
		);

		MITA_Agreement__c agreement7 = new MITA_Agreement__c(
			Airline_1__c = airline1.Id,
			Airline_2__c = airline2.Id,
			MITAorBIETA__c = IA_util.EMD,
			Agreement_Type__c = IA_util.TYPE_EMD,
			Created_date__c = Date.parse('20/12/2020'),
			Agreement_processed_date__c = Date.parse('20/12/2020'),
			Effective_date__c = Date.parse('20/12/2020'),
			Cancellation_Processed_Date__c = Date.parse('20/01/2021'),
			Cancellation_Reason__c = 'Requested by Airline 1'
		);

		insert new list<MITA_Agreement__c>{agreement1,agreement2, agreement3, agreement4, agreement5, agreement6, agreement7};
	}

	static testMethod void testController(){
		
		PageReference page = new PageReference('/apex/InterlineAgreementsMemorandum');
		page.getParameters().put('date','01/01/2021');
		page.getParameters().put('number','123456');
		Test.setCurrentPage(page);

		Test.StartTest();
		InterlineAgreementsMemorandumController ctrl = new InterlineAgreementsMemorandumController();
		System.assertEquals(null,ctrl.getIATALogoURL());
		Map<String,List<InterlineAgreementsMemorandumController.WrapperAgreement>> data = ctrl.getDataAgreements();
		Test.stopTest();

		System.assertEquals(6,data.size());
		System.assertEquals(3,data.get('MITA Concurrences').size());
		System.assertEquals(1,data.get('MITA Withdrawals').size());
		System.assertEquals(0,data.get('BIETA Concurrences').size());
		System.assertEquals(2,data.get('BIETA Withdrawals').size());
		System.assertEquals(0,data.get('EMD Concurrences').size());
		System.assertEquals(1,data.get('EMD Withdrawals').size());
	}

}
