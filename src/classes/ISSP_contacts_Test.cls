@isTest
public class ISSP_contacts_Test {


	public static testMethod void unitTest1() {

		ISSP_PortalService_Test.createTestData();
		IATA_ISO_Country__c ISO_Country = new IATA_ISO_Country__c(ISO_Code__c='12',Name='test');
        insert ISO_Country;

		Account acc = ISSP_ObjectFactory.createNewAccount();
		acc.IATACode__c = '1111';
		acc.IATA_ISO_Country__c = ISO_Country.Id;
		acc.BillingCity = 'Test';
		acc.Category__c = 'IATA Passenger Sales Agent';
		acc.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
		insert acc;
		
		String agencyProfileId = [SELECT Id FROM Profile WHERE Name = 'ISS Portal Agency User (Partner)'].Id;
        ISSP_CS__c profileCS = new ISSP_CS__c();
        profileCS.Name = 'ISS_Portal_Agency_User';
        profileCS.Value__c = agencyProfileId;
        insert profileCS;
        ISSP_CS__c profileCS2 = new ISSP_CS__c();
        profileCS2.Name = 'Host';
        profileCS2.Value__c = 'preprod-customer-portal-iata.cs18.force.com';
        insert profileCS2;
        
        IECTestUtil.trgPortalUserAfterInserUpdate = true;
		
		//Contact con = [Select id from Contact where LastName = 'test123'];		

		Contact con = ISSP_ObjectFactory.createNewContact();
		con.AccountId = acc.Id;
		con.Community__c = '123';
		insert con;

		Test.startTest();

        Portal_Applications__c app = new Portal_Applications__c(Name = 'Test App'); 
        insert app;
        
        Portal_Application_Right__c appReq = new Portal_Application_Right__c();
        appReq.Portal_Application__c = app.Id;
        appReq.Right__c = 'Access Granted';
        appReq.Contact__c = con.Id;
        
        insert appReq;

        Apexpages.currentPage().getParameters().put('id', con.Id);
        Apexpages.currentPage().getParameters().put('action', 'edit');
        ISSP_Contact ctrl = new ISSP_Contact();        

        ctrl.psId = app.id;
        ctrl.serviceId =  app.Id;        
        ctrl.contactId = con.Id;

        ctrl.contactStatus = 'PA';

        ctrl.getAppsGrantedListAux();

        Pagereference p = ctrl.denyAccess();

        p = ctrl.grantAccess();

        ctrl.contactStatus = 'NO';

		p = ctrl.grantAccess();

        p = ctrl.permissionSetPoller();

        p = ctrl.refreshList();

        p = ctrl.changePortalStatus();

        p = ctrl.relocateContact();

        p = ctrl.assignIFAPContact();

        p = ctrl.cancel();

        p = ctrl.save();

        p = ctrl.edit();

        // force errors
		ctrl.contactId = null;

		p = ctrl.denyAccess();

		p = ctrl.grantAccess();

        p = ctrl.permissionSetPoller();

        Test.stopTest();

	}
}