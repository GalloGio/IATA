@isTest
private class ISSP_CurrencyCenterHomeControllerTest {

	/* since this class has no business rules, we are not using asserts */

	@isTest static void testCtrl() {
        Test.startTest();

		ISSP_CurrencyCenterHomeController ctrl = new ISSP_CurrencyCenterHomeController();

        list<ISSP_CurrencyCenterHomeController.RSSNewsWrapper> news = ctrl.getNewsFeed();
        system.assertNotEquals(null, news);

        Test.stopTest();
    }

    @isTest static void testRedirections() {
        Test.startTest();

		ISSP_CurrencyCenterHomeController ctrl = new ISSP_CurrencyCenterHomeController();
		PageReference pr = ctrl.GoToBlockedFunds();
		pr = ctrl.GoToWatchList();
		pr = ctrl.GoToManageNotifications();
		pr = ctrl.GoToHeatMap();

        Test.stopTest();
    }

    @isTest static void testCheckAccess() {
        Test.startTest();

        ISSP_CurrencyCenterHomeController ctrl = new ISSP_CurrencyCenterHomeController();
        PageReference pr = ctrl.checkAccess();

        Test.stopTest();
    }

    @isTest static void testTDLink() {
        Test.startTest();

        Id accRtId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');

        Account acc = new Account (
        RecordTypeId = accRtId,
        Name = 'testAcc'
        );  
        insert acc;

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= acc.Id;
        con.Email = 'Test@test11tdlink.com';
        insert con;

        System.debug('con Id: ' + con.Id);
        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        System.debug('newUser Id: ' + newUser.Id);
        con.OwnerId = newUser.Id;
        con.User_Portal_Status__c = 'Approved User';
        con.Community__c = 'ISS Customer Portal';
        update con;

        Portal_Applications__c app = new Portal_Applications__c(Application_URL__c='/ISSP_TDNavigation');
        insert app;

        Portal_Application_Right__c par = 
            new Portal_Application_Right__c(Contact__c=newUser.ContactId,Right__c = 'Access Granted',Portal_Application__c=app.Id);
        insert par;

        par = [select id, Contact__c from Portal_Application_Right__c];

        //throw new TransformationException('profile id ' + p.id);

        System.runAs(newUser){           
        
            ISSP_CurrencyCenterHomeController ctrl = new ISSP_CurrencyCenterHomeController();

            List<Portal_Application_Right__c> parlist = [SELECT Id, Contact__c, Right__c,Portal_Application__c, Contact_User_Portal_Status__c, Application_Start_URL__c FROM Portal_Application_Right__c];
            //throw new TransformationException('Portal_Application__c-' + parlist[0].Portal_Application__c + '-Contact__c-' + parlist[0].Contact__c + '-Right__c-' + parlist[0].Right__c + '-Contact_User_Portal_Status__c-' + parlist[0].Contact_User_Portal_Status__c + '-Application_Start_URL__c-' + parlist[0].Application_Start_URL__c);
            System.assertEquals('/ISSP_TDNavigation', ctrl.tdLinkURL);
        }

        Test.stopTest();
    }


}