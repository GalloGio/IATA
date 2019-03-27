/**
 * @description This is a test class for class ISSP_CurrencyCenterReportListingCtrl
 *
 *
 * @creation  2019-02-07
 * @author    José Cardoso
 */
@IsTest
private class ISSP_CurrencyCenterReportListingCtrlTest {

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


		List<ContentVersion> reports = new List<ContentVersion>();

		String[] months = new String[]{'201801','201802','201803','201804','201805','201806','201807','201808','201809','201810','201811','201812'};
		for(String s: months){
			ContentVersion report = new ContentVersion(Title = 'CurrencyCenterCurrencyRepatriation_'+s, ContentUrl ='Url');
			reports.add(report);
		}

		//CurrencyCenterAnnualRBF_
		ContentVersion report = new ContentVersion(Title = 'CurrencyCenterAnnualRBF_'+months[11], ContentUrl ='Url');
		reports.add(report);

		//CurrencyCenterMiscelaneous_
		report = new ContentVersion(Title = 'CurrencyCenterMiscelaneous_'+months[11], ContentUrl ='Url');
		reports.add(report);

		insert reports;
		System.debug('reports: ' + reports);

		//System.runAs(newUser){

			List<ContentVersion> tmp  = [SELECT Id, Title, Description, FileType, Owner.Name, VersionNumber, IsLatest FROM ContentVersion WHERE Title LIKE 'CurrencyCenterCurrencyRepatriation_%' ORDER BY Title];
			System.debug('tmp: ' + tmp);

			ISSP_CurrencyCenterReportListingCtrl ctrl = new ISSP_CurrencyCenterReportListingCtrl();
		//}
	}
}