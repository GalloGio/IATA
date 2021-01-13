@isTest
public class PortalServiceTIPReportsCtrlTest {
	
	static testMethod void Test_1() {

		WrapperAttachTest.loadTestCredentials();

		//Account
		Account acc = ISSP_ObjectFactory.createNewAccount();
		insert acc;

		//Contact
		Contact con = ISSP_ObjectFactory.createNewContact();
		con.AccountId = acc.Id;
		insert con;

		//User
		User user = ISSP_ObjectFactory.createPortalUser(con);
		con.OwnerId = user.Id;
		update con;

		//Portal
		Portal_Applications__c portal = new Portal_Applications__c();
		portal.Name = 'TIP Reports';
		insert portal;

		//External report config (custom setting)
		ISSP_External_Reports_Config__c custom_setting = new ISSP_External_Reports_Config__c();
		custom_setting.Portal_Service_ID__c = portal.Id;
		custom_setting.Report_ID__c = 'ER-001';
		custom_setting.Name = 'ER-001';
		insert custom_setting;

		//Portal access
		Portal_Application_Right__c appRight = new Portal_Application_Right__c();
		appRight.Contact__c = con.Id;
		appRight.Portal_Application__c = portal.Id;
		appRight.Right__c = 'Access Granted';
		insert appRight;

		//External report
		ISSP_External_Report__c er = new ISSP_External_Report__c();
		er.Account__c = acc.Id;
		er.Report_ID__c = 'ER-001';
		er.Name = 'ER-001';
		insert er;

		//Amazon file
		AmazonFile file1 = WrapperAttachTest.createAmazonFile(er, 'testname');
		AmazonFile file2 = WrapperAttachTest.createAmazonFile(er, 'testname2');

		Test.startTest();
		System.runAs(user) {
			PortalServiceTIPReportsCtrl.TIPReportPageWrapper pageWrapper = PortalServiceTIPReportsCtrl.getTIPReportPageWrapper(PortalServiceTIPReportsCtrl.SERVICE_TIP_REPORTS);

			PortalServiceTIPReportsCtrl.TIPReportWrapperObject tipwrapperObjectAux = new PortalServiceTIPReportsCtrl.TIPReportWrapperObject();
			tipwrapperObjectAux.lastModifiedDate = Date.today();
			tipwrapperObjectAux.developerName = 'devname';
			tipwrapperObjectAux.masterLabel ='masterlabel';
			tipwrapperObjectAux.id = 'someid';
			tipwrapperObjectAux.reportType = 'typeA';
			tipwrapperObjectAux.reportTypeLabel = 'typeALabel';
			tipwrapperObjectAux.groupId = 'somegroupid';
			tipwrapperObjectAux.reportId = 'somereportid';
			tipwrapperObjectAux.isspExternalReportId = 'someisspexternalreportid';
			
			List<PortalServiceTIPReportsCtrl.TIPReportWrapperObject> lsttipwrapperObjectAux = new List< PortalServiceTIPReportsCtrl.TIPReportWrapperObject>();
			lsttipwrapperObjectAux.add(tipwrapperObjectAux);
		
			PortalServiceTIPReportsCtrl.TIPReportPageWrapper tipAux = new PortalServiceTIPReportsCtrl.TIPReportPageWrapper();
			PortalServiceTIPReportsCtrl.TIPReportPageWrapper tipAux2 = new PortalServiceTIPReportsCtrl.TIPReportPageWrapper(true, lsttipwrapperObjectAux);

			System.assertEquals(2, [select count() from AmazonFile__c]);

			PortalServiceTIPReportsCtrl.getExpiringLinkIfap('testname');

			PortalServiceTIPReportsCtrl.createDocumentTrackerRecord(file1.getId(), er.Id, PortalServiceTIPReportsCtrl.SERVICE_TIP_REPORTS);
			System.assertEquals(1, [select count() from ISSP_Document_Tracker__c where Type__c = 'TIP Report']);
		}
		Test.stopTest();
	}

}
