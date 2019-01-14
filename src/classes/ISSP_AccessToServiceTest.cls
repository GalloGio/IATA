@isTest
private class ISSP_AccessToServiceTest {
    @isTest static void test_method_one() {
        ISSP_AccessToService controller = new ISSP_AccessToService();
        ISSPAccServiceListView__c cs = new ISSPAccServiceListView__c();
        cs.Name = 'ISSP All';
        cs.Profiles_Id__c = Userinfo.getProfileId().substring(0,15);
        cs.Field_Set_API_Name__c = 'ISSPAccServiceListView';
        cs.Label_API_name__c = 'ISSP_All';
        insert cs;

        Portal_Applications__c app = new Portal_Applications__c(Name = 'Management Information Report'); 
        insert app;

        controller.initialization();
        controller.getAccServiceList();
        controller.getAccServices();
        controller.getSortDirection();
        controller.refresh();


    }

    public static testMethod void unitTest() {

        ISSP_AccessToService controller = new ISSP_AccessToService();
        ISSPAccServiceListView__c cs = new ISSPAccServiceListView__c();
        cs.Name = 'ISSP All';
        cs.Profiles_Id__c = Userinfo.getProfileId().substring(0,15);
        cs.Field_Set_API_Name__c = 'ISSPAccServiceListView';
        cs.Label_API_name__c = 'ISSP_All';
        insert cs;

        ISSP_PortalService_Test.createTestData();
        IATA_ISO_Country__c ISO_Country = new IATA_ISO_Country__c(ISO_Code__c='12',Name='test');
        insert ISO_Country;

        Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.IATACode__c = '1111';
        acc.IATA_ISO_Country__c = ISO_Country.Id;
        acc.BillingCity = 'Test';
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
        app.Confirm_Box__c = true;
        insert app;
        
        Portal_Application_Right__c appReq = new Portal_Application_Right__c();
        appReq.Portal_Application__c = app.Id;
        appReq.Right__c = 'Access Requested';
        appReq.Contact__c = con.Id;
        
        insert appReq;


        ISSP_AccessToService ctrl = new ISSP_AccessToService();

        User u = ISSP_AccessToService.currentPortalUser;

        Pagereference p;

        ctrl.sortExpression = 'name';
        ctrl.setSortDirection('asc');

        ctrl.initialization();

        ctrl.serviceId =  app.Id;
        ctrl.contactId = con.Id;

        ctrl.contactStatus = 'PA';

        ctrl.getAccServiceList();

        p = ctrl.denyAccess();

        p = ctrl.grantAccess();

        ctrl.contactStatus = 'NO';

        p = ctrl.grantAccess();

        p = ctrl.permissionSetPoller();

        p = ctrl.refreshList();

        ctrl.AlphaFilter = 'All';        

        // force errors
        ctrl.contactId = null;

        p = ctrl.denyAccess();

        p = ctrl.grantAccess();

        p = ctrl.permissionSetPoller();

        Test.stopTest();

    }

}