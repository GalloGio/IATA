@IsTest
public with sharing class CW_LoginControllerTest {

	@testSetup
	private static void createData(){
		ISSP_CS__c icgid = new ISSP_CS__c();
		icgid.Name = 'HostCSP';
		icgid.Value__c = '/s/';
		insert icgid;

		Portal_Applications__c pa = TestDataFactory_PortalApplications.createDefaultPortalApplication(1).get(0);
		pa.Name = 'One Source';
		insert pa;
	}

	@IsTest
	private static void testGetOneSourceServiceId(){
		Test.startTest();
		CW_LoginController login = new CW_LoginController();
		System.assertNotEquals(login.serviceId, null, 'srvcId is null');
		System.assertNotEquals(login.portalUrl, null, 'login is null');
		System.assertNotEquals(login.loginUrl, null, 'loginUrl is null');
		System.assertNotEquals(login.selfRegisterUrl, null, 'selfRegisterUrl is null');
		Test.stopTest();
	}
}