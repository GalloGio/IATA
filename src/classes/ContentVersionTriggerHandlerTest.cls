@IsTest
private class ContentVersionTriggerHandlerTest {

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

		Portal_Applications__c papp = new Portal_Applications__c();
		papp.Application_URL__c = '/ISSP_CurrencyCenterHome';
		insert papp;

		Portal_Application_Right__c par = new Portal_Application_Right__c(Contact__c = con.Id, Right__c = 'Access Granted', Portal_Application__c = papp.Id);
		insert par;

		Set<Id> contactsId = ContentVersionTriggerHandler.getAllActiveCurrencyCenterContactIds();

		System.assertEquals(1,contactsId.size());


		List<ContentVersion> reports = new List<ContentVersion>();

		//CurrencyCenterCurrencyRepatriation_
		ContentVersion report = new ContentVersion(Title = 'CurrencyCenterCurrencyRepatriation_201901', ContentUrl ='Url');
		reports.add(report);

		//CurrencyCenterAnnualRBF_
		report = new ContentVersion(Title = 'CurrencyCenterAnnualRBF_201812', ContentUrl ='Url');
		reports.add(report);

		insert reports;
		System.debug('reports: ' + reports);
		System.assertEquals(2,Limits.getEmailInvocations());
	}
}