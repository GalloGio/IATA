/**
 * @description This is a test class for class ISSP_CurrencyCenterSurveyListingCtrl
 *
 *
 * @creation  2019-02-07
 * @author    José Cardoso
 */
@IsTest
private class ISSP_CurrencyCenterSurveyListingCtrlTest {

	@IsTest
	static void test01(){

		Id rtIdHq = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');

		Account headQuarter = ISSP_ObjectFactory.createNewAccount();
		headQuarter.BillingCity = 'test2';
		headQuarter.Name = 'test2';
		headQuarter.RecordTypeId = rtIdHq;
		headQuarter.Site = 'headSite';
		insert headQuarter;

		Contact con = ISSP_ObjectFactory.createNewContact();
		con.Email = 'testxxaasddasdasda@test.com';
		con.AccountId= headQuarter.Id;
		insert con;

		User newUser = ISSP_ObjectFactory.createPortalBasicAirlineUser(con);

		List<Currency_Center_Survey__c> ccsList = new List<Currency_Center_Survey__c>();

		Currency_Center_Survey__c ccs = new Currency_Center_Survey__c(Airline__c = headQuarter.Id,
																		Survey__c = 'Annual',
																		Status__c = 'Draft',
																		Year_Survey__c = String.valueOf(System.now().year()),
																		Month_Survey__c = '');
		ccsList.add(ccs);

		ccs = new Currency_Center_Survey__c(Airline__c = headQuarter.Id,
				Survey__c = 'Monthly',
				Status__c = 'Draft',
				Year_Survey__c = String.valueOf(System.now().year()),
				Month_Survey__c = String.valueOf(System.now().month()));
		ccsList.add(ccs);

		ccs = new Currency_Center_Survey__c(Airline__c = headQuarter.Id,
				Survey__c = 'Monthly',
				Status__c = 'Draft',
				Year_Survey__c = String.valueOf(System.now().year()),
				Month_Survey__c = String.valueOf(System.now().addMonths(1).month()));
		ccsList.add(ccs);
		insert ccsList;

		System.runAs(newUser){
			ISSP_CurrencyCenterSurveyListingCtrl ctrl = new ISSP_CurrencyCenterSurveyListingCtrl();

			String monthName = ctrl.getMonthName(1);
			monthName = ctrl.getMonthName(2);
			monthName = ctrl.getMonthName(3);
			monthName = ctrl.getMonthName(4);
			monthName = ctrl.getMonthName(5);
			monthName = ctrl.getMonthName(6);
			monthName = ctrl.getMonthName(7);
			monthName = ctrl.getMonthName(8);
			monthName = ctrl.getMonthName(9);
			monthName = ctrl.getMonthName(10);
			monthName = ctrl.getMonthName(11);
			monthName = ctrl.getMonthName(12);
		}
	}
}