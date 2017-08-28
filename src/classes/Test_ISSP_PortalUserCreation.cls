@isTest
private class Test_ISSP_PortalUserCreation {
    
    @isTest static void test_method_one() {
        RecordType rt = [Select id From RecordType Where DeveloperName = 'IATA_Airline' AND sObjectType='Account' limit 1];
        Account acc = new Account();
        acc.Name = 'Test_PortalUserCreation';
        acc.RecordTypeId = rt.id;
        insert acc;
        IATA_ISO_Country__c ISO_Country = new IATA_ISO_Country__c(ISO_Code__c='12',Name='test');
        insert ISO_Country;
        ApexPages.currentPage().getParameters().put('retUrl', '');
        ISSP_PortalUserCreation ctrl = new ISSP_PortalUserCreation();
        Contact con = ctrl.con;
        ctrl.LastName = 'Test';
        ctrl.accountId = acc.id;
        ctrl.emailAddress = 'iss.portal.test.class@Test.com';
        con.FirstName = 'Name';
        con.Phone = '1234';
        ctrl.saveActiveContact();
        con = ctrl.con;
        ctrl.LastName = 'Test';
        ctrl.accountId = acc.id;
        ctrl.emailAddress = 'iss.portal.test.class2@Test.com';
        con.Phone = '1234';
        ctrl.saveAndNew();
        
        ctrl.currentCon = con;
        
        ctrl.getCountries();
        ctrl.getAccounts();
        
        System.assertEquals('Approved User', con.User_Portal_Status__c);
        list<User> userList = [select id from User where email ='iss.portal.test.class@Test.com']; 
        System.assertEquals(userList.size(),0);
        ctrl.cancel();
        
    }
    @isTest static void exceptionsTest() {
        PageReference thePage = Page.ISSP_PortalUserCreation;
        thePage.getParameters().put('retUrl','');
        Test.setCurrentPage(thePage);
        ISSP_PortalUserCreation ctrl = new ISSP_PortalUserCreation();
        Contact con = ctrl.con;
        con.LastName = 'Test';
        con.Email = 'Test.test.test.test@Test.com';
        ctrl.saveActiveContact();
    }
}