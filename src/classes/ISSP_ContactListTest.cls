@isTest
private class ISSP_ContactListTest {

    static testMethod void myUnitTest() {

        Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.IATACode__c = '132';
        acc.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
        insert acc;

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.Senior_Contact_Email__c = 'senior@dev.com';
        con.AccountId= acc.Id;
        con.User_Portal_Status__c = 'Active';
        con.Community__c = 'ISS Customer Portal';
        insert con;
        String newContactId = con.Id;

        ISSP_ContactList ctrl = new ISSP_ContactList();
        ISSPContactListView__c cs = new ISSPContactListView__c();
        cs.Name = 'Test';
        cs.Profiles_Id__c = Userinfo.getProfileId().substring(0,15);
        cs.Field_Set_API_Name__c = 'ISSP_Contacts_MyCompanyContacts';
        cs.Label_API_name__c = 'ISSP_Contacts_MyCompanyContacts';
        cs.SOQL_Filter__c = 'WHERE Status__c = \'Active\' AND User_Portal_Status__c != \'Rejected\'';
        insert cs;
        ctrl.initialization();

        System.AssertEquals(ctrl.isAdmin, true);
        ctrl.refresh();
        ctrl.getContactList();
        ctrl.contactList[0].selected = true;
        ctrl.contactStatus = 'Retired';
        ctrl.reject();
        List <Contact> newContactList = [SELECT Id, User_Portal_Status__c FROM Contact WHERE Id = :newContactId];
        System.AssertEquals(newContactList[0].User_Portal_Status__c, 'Rejected');
    }

    static testMethod void myUnitTest_2() {

        Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.IATACode__c = '132';
        acc.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
        insert acc;

        ISSP_ContactList ctrl = new ISSP_ContactList();
        ISSPContactListView__c cs = new ISSPContactListView__c();
        cs.Name = 'Test';
        cs.Profiles_Id__c = Userinfo.getProfileId().substring(0,15);
        cs.Field_Set_API_Name__c = 'ISSP_Contacts_MyCompanyContacts';
        cs.Label_API_name__c = 'ISSP_Contacts_MyCompanyContacts';
        cs.Permission_set__c = '12345';
        cs.SOQL_Filter__c = 'WHERE Status__c = \'Active\' AND User_Portal_Status__c != \'Rejected\'';
        insert cs;
        ctrl.initialization();

        ctrl.refresh();
        ctrl.getContactList();
    }

    static testMethod void myUnitTest_3() {
        ISSP_ContactListTest.createTestData();
        IECTestUtil.trgPortalUserAfterInserUpdate = true;
        Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.IATACode__c = '132';
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

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.Senior_Contact_Email__c = 'senior@dev.com';
        con.AccountId= acc.Id;
        con.User_Portal_Status__c = 'Pending Approval';
        insert con;
        String newContactId = con.Id;

        ISSP_ContactList ctrl = new ISSP_ContactList();
        ISSPContactListView__c cs = new ISSPContactListView__c();
        cs.Name = 'Test';
        cs.Profiles_Id__c = Userinfo.getProfileId().substring(0,15);
        cs.Field_Set_API_Name__c = 'ISSP_Contacts_MyCompanyContacts';
        cs.Label_API_name__c = 'ISSP_Contacts_MyCompanyContacts';
        cs.SOQL_Filter__c = 'WHERE Status__c = \'Active\' AND User_Portal_Status__c != \'Rejected\'';
        insert cs;
        ctrl.initialization();

        System.AssertEquals(ctrl.isAdmin, true);
        ctrl.refresh();
        ctrl.getContactList();
        ctrl.contactList[0].selected = true;
        test.startTest();
        ctrl.activateContact();
        ctrl.checkIdCard();
        test.stopTest();
        List <Contact> newContactList = [SELECT Id, User_Portal_Status__c FROM Contact WHERE Id = :newContactId];
        system.debug('XXXs newContactList ==> '+newContactList);

        ApexPages.StandardController sc = new ApexPages.StandardController(con);
        ISSP_Contact_User controller = new ISSP_Contact_User(sc);
    }

    static testMethod void myUnitTest_4() {
        ISSP_ContactListTest.createTestData();
        Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.IATACode__c = '132';
        acc.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
        insert acc;

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.Senior_Contact_Email__c = 'senior@dev.com';
        con.AccountId= acc.Id;
        con.User_Portal_Status__c = 'Active';
        con.Community__c = 'ISS Customer Portal';
        insert con;
        String newContactId = con.Id;

        String profileId = [SELECT Id FROM Profile WHERE Name = 'ISS Portal Agency Delegated Admin User'].Id;
        ISSP_CS__c newCS = new ISSP_CS__c();
        newCS.Name = 'ISS_Portal_Agency_Delegated_Admin';
        newCS.Value__c = profileId;
        insert newCS;
        ISSP_CS__c newCS2 = new ISSP_CS__c();
        newCS2.Name = 'Host';
        newCS2.Value__c = 'test';
        insert newCS2;

        ISSP_ContactList ctrl = new ISSP_ContactList();
        ISSPContactListView__c cs = new ISSPContactListView__c();
        cs.Name = 'Test';
        cs.Profiles_Id__c = Userinfo.getProfileId().substring(0,15);
        cs.Field_Set_API_Name__c = 'ISSP_Contacts_MyCompanyContacts';
        cs.Label_API_name__c = 'ISSP_Contacts_MyCompanyContacts';
        cs.SOQL_Filter__c = 'WHERE Status__c = \'Active\' AND User_Portal_Status__c != \'Rejected\'';
        insert cs;
        IECTestUtil.trgPortalUserAfterInserUpdate = true;
        ctrl.initialization();
        //List <Contact> testContactList = ctrl.getContacts();
        //System.AssertEquals(testContactList.size(), 1);
        System.AssertEquals(ctrl.isAdmin, true);
        ctrl.refresh();
        ctrl.getContactList();
        ctrl.contactList[0].selected = true;
        test.startTest();
        ctrl.makeAdmin();
        ctrl.checkIdCard();
        test.stopTest();
        List <Contact> newContactList = [SELECT Id, User_Portal_Status__c FROM Contact WHERE Id = :newContactId];
        System.AssertEquals(newContactList[0].User_Portal_Status__c, 'Approved Admin');
    }

    static testMethod void myUnitTest_5() {

        //ISSP_ObjectFactory.fiilIncludedFields();
        //Account acc =  (Account)ISSP_ObjectFactory.createSObject('Account',false,1);
        Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.IATACode__c = '132';
        acc.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
        insert acc;

        //Contact con = (Contact)ISSP_ObjectFactory.createSObject('Contact',false);
        Contact con = ISSP_ObjectFactory.createNewContact();
        con.Senior_Contact_Email__c = 'senior@dev.com';
        con.AccountId= acc.Id;
        con.User_Portal_Status__c = 'Active';
        con.Community__c = 'ISS Customer Portal';
        insert con;
        String newContactId = con.Id;

        ISSP_ContactList ctrl = new ISSP_ContactList();
        ISSPContactListView__c cs = new ISSPContactListView__c();
        cs.Name = 'Test';
        cs.Profiles_Id__c = Userinfo.getProfileId().substring(0,15);
        cs.Field_Set_API_Name__c = 'ISSP_Contacts_MyCompanyContacts';
        cs.Label_API_name__c = 'ISSP_Contacts_MyCompanyContacts';
        cs.SOQL_Filter__c = 'WHERE Status__c = \'Active\' AND User_Portal_Status__c != \'Rejected\'';
        insert cs;
        ctrl.initialization();
        //List <Contact> testContactList = ctrl.getContacts();
        //System.AssertEquals(testContactList.size(), 1);
        System.AssertEquals(ctrl.isAdmin, true);
        ctrl.setSortDirection('DESC');
        system.assertEquals('DESC', ctrl.getSortDirection());
        //ctrl.sortExpression = 'ASC';
        ctrl.refresh();
        ctrl.getContactList();
        ctrl.contactList[0].selected = true;
        ctrl.contactStatus = 'Retired';
        ctrl.inactivate();
        List <Contact> newContactList = [SELECT Id, User_Portal_Status__c FROM Contact WHERE Id = :newContactId];
        System.AssertEquals(newContactList[0].User_Portal_Status__c, 'Deactivated');
    }

    static testMethod void myUnitTest_6() {

        Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.IATACode__c = '132';
        acc.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
        insert acc;

        List<Contact> cl = new List<Contact>();

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.Senior_Contact_Email__c = 'senior@dev.com';
        con.Email = 'test1@iata.org';
        con.AccountId= acc.Id;
        con.User_Portal_Status__c = 'Active';
        cl.add(con);

        String newContactId = con.Id;

        Contact con2 = ISSP_ObjectFactory.createNewContact();
        con2.Senior_Contact_Email__c = 'senior@dev.com';
        con2.Email = 'test2@iata.org';
        con2.AccountId= acc.Id;
        con2.User_Portal_Status__c = 'Active';
        cl.add(con2);

        insert cl;

        String newContactId2 = con2.Id;

        List<Portal_Applications__c> pal = new List<Portal_Applications__c>();

        Portal_Applications__c app1 = new Portal_Applications__c(Name = 'MyTest', Critical_Service__c = true);
        pal.add(app1);
        Portal_Applications__c app2 = new Portal_Applications__c(Name = 'MyTest2');
        pal.add(app2);

        insert pal;

        List<Portal_Application_Right__c> parl = new List<Portal_Application_Right__c>();

        Portal_Application_Right__c appRight11 = new Portal_Application_Right__c(Contact__c = con.Id, Portal_Application__c = app1.Id, Right__c = 'Access Granted');
        parl.add(appRight11);

        Portal_Application_Right__c appRight12 = new Portal_Application_Right__c(Contact__c = con2.Id, Portal_Application__c = app1.Id, Right__c = 'Access Granted');
        parl.add(appRight12);

        Portal_Application_Right__c appRight21 = new Portal_Application_Right__c(Contact__c = con.Id, Portal_Application__c = app2.Id, Right__c = 'Access Granted');
        parl.add(appRight21);

        insert parl;

        ISSP_ContactList ctrl = new ISSP_ContactList();
        ISSPContactListView__c cs = new ISSPContactListView__c();
        cs.Name = 'Test';
        cs.Profiles_Id__c = Userinfo.getProfileId().substring(0,15);
        cs.Field_Set_API_Name__c = 'ISSP_Contacts_MyCompanyContacts';
        cs.Label_API_name__c = 'ISSP_Contacts_MyCompanyContacts';
        cs.SOQL_Filter__c = 'WHERE Status__c = \'Active\' AND User_Portal_Status__c != \'Rejected\'';
        insert cs;
        ctrl.initialization();
        //List <Contact> testContactList = ctrl.getContacts();
        ctrl.refresh();
        ctrl.getContactList();
        ctrl.contactList[0].selected = true;
        ctrl.contactList[1].selected = true;
        ctrl.contactStatus = 'Retired';
        //ctrl.inactivate();
    }

    static testMethod void myUnitTest_7() {

        Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.IATACode__c = '132';
        acc.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
        insert acc;

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.Senior_Contact_Email__c = 'senior@dev.com';
        con.Email = 'test1@iata.org';
        con.AccountId= acc.Id;
        con.User_Portal_Status__c = 'Active';
        insert con;
        String newContactId = con.Id;

        Contact con2 = ISSP_ObjectFactory.createNewContact();
        con2.Senior_Contact_Email__c = 'senior@dev.com';
        con2.Email = 'test2@iata.org';
        con2.AccountId= acc.Id;
        con2.User_Portal_Status__c = 'Active';
        insert con2;
        String newContactId2 = con2.Id;

        ISSP_ContactList ctrl = new ISSP_ContactList();
        ISSPContactListView__c cs = new ISSPContactListView__c();
        cs.Name = 'Test';
        cs.Profiles_Id__c = Userinfo.getProfileId().substring(0,15);
        cs.Field_Set_API_Name__c = 'ISSP_Contacts_MyCompanyContacts';
        cs.Label_API_name__c = 'ISSP_Contacts_MyCompanyContacts';
        cs.SOQL_Filter__c = 'WHERE Status__c = \'Active\' AND User_Portal_Status__c != \'Rejected\'';
        insert cs;
        ctrl.initialization();
        //List <Contact> testContactList = ctrl.getContacts();
        ctrl.refresh();
        ctrl.getContactList();
        ctrl.changeUserPortalStatus();
        ctrl.contactList[0].selected = true;
        ctrl.contactList[1].selected = true;
        ctrl.changeUserPortalStatus();
        ctrl.contactList[1].selected = false;
        ctrl.changeUserPortalStatus();
        ISSP_ContactList.updateContact(con.Id, 'Active');
    }

    static testMethod void triggerTest_1() {

        Account acc = ISSP_ObjectFactory.createNewAccount();
        insert acc;

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= acc.Id;
        con.Status__c = 'Active';
        con.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
        insert con;

        IEC_Subscription_History__c product = new IEC_Subscription_History__c();
        product.Related_Contact__c = con.id;
        product.Billing_Account_Number__c = '1234';
        insert product;

        con.Status__c = 'Retired';
        try{
            update con;
        }
        catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('subscription') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }

        ID_Card__c idCard = new ID_Card__c();
        idCard.Related_Contact__c = con.id;
        idCard.Valid_To_Date__c = date.today().addMonths(5);
        idCard.Name_on_ID_Card__c = 'test';
        idCard.Card_status__c = 'Sent ID Card';
        idCard.VER_Number__c = '1234';
        insert idCard;

        con.Status__c = 'Retired';
        try{
            update con;
        }
        catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('Card') ? true : false;
            System.AssertEquals(expectedExceptionThrown, true);
        }
    }
    
    static testMethod void myUnitTest_8() {
        createTestData();
        Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.IATACode__c = '132';
        acc.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
        insert acc;

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.Senior_Contact_Email__c = 'senior@dev.com';
        con.Email = 'test1@iata.org';
        con.AccountId= acc.Id;
        con.User_Portal_Status__c = 'Active';
        insert con;
        String newContactId = con.Id;

        Contact con2 = ISSP_ObjectFactory.createNewContact();
        con2.Senior_Contact_Email__c = 'senior@dev.com';
        con2.Email = 'test2@iata.org';
        con2.AccountId= acc.Id;
        con2.User_Portal_Status__c = 'Active';
        insert con2;
        String newContactId2 = con2.Id;

        ISSP_ContactList ctrl = new ISSP_ContactList();
        ISSPContactListView__c cs = new ISSPContactListView__c();
        cs.Name = 'Test';
        cs.Profiles_Id__c = Userinfo.getProfileId().substring(0,15);
        cs.Field_Set_API_Name__c = 'ISSP_Contacts_MyCompanyContacts';
        cs.Label_API_name__c = 'ISSP_Contacts_MyCompanyContacts';
        cs.SOQL_Filter__c = 'WHERE Status__c = \'Active\' AND User_Portal_Status__c != \'Rejected\'';
        insert cs;
        ctrl.initialization();
        
        Test.startTest();
        ctrl.getCSVContent();
        Test.stopTest();
    }
    
    static testMethod void test_ProfilePermissionFilter() {
        ISSPContactListView__c cs = new ISSPContactListView__c();
        cs.Name = 'Test';
        cs.Profiles_Id__c = Userinfo.getProfileId().substring(0,15);
        cs.Field_Set_API_Name__c = 'ISSP_Contacts_MyCompanyContacts';
        cs.Label_API_name__c = 'ISSP_Contacts_MyCompanyContacts';
        cs.SOQL_Filter__c = 'WHERE Status__c = \'Active\' AND User_Portal_Status__c != \'Rejected\'';
        insert cs;
        Test.startTest();
        ISSP_ContactList.ProfilePermissionFilter pfilter = new ISSP_ContactList.ProfilePermissionFilter();
        pfilter.isUserPermittedFor(cs);
        pfilter.isDataEmpty(cs);
        Test.stopTest();
    }
    
    static testMethod void test_PermissionSetFilter() {
        User sysadmin = [Select id from User where Profile.Name = 'System Administrator' and isActive = true limit 1];
        PermissionSet ps = new PermissionSet(Name = 'Test_PS', Label='TestPS');
        System.runAs(sysadmin) {
            insert ps;
        }
        
        ISSPContactListView__c cs = new ISSPContactListView__c();
        cs.Name = 'Test';
        cs.Profiles_Id__c = Userinfo.getProfileId().substring(0,15);
        cs.Field_Set_API_Name__c = 'ISSP_Contacts_MyCompanyContacts';
        cs.Label_API_name__c = 'ISSP_Contacts_MyCompanyContacts';
        cs.SOQL_Filter__c = 'WHERE Status__c = \'Active\' AND User_Portal_Status__c != \'Rejected\'';
        cs.Permission_set__c = ps.Id;
        insert cs;
        
        Test.startTest();
        ISSP_ContactList.PermissionSetFilter psetfilter = new ISSP_ContactList.PermissionSetFilter(new set<String>{ps.Id});
        psetfilter.isUserPermittedFor(cs);
        psetfilter.isDataEmpty(cs);
        Test.stopTest();
    }

    public static void createTestData(){

        List<ISSP_CS__c> csList = new List<ISSP_CS__c>();

        ISSP_CS__c cs1 = new ISSP_CS__c();
        cs1.Name = 'DefaultNewAccountOwnerId';
        cs1.Value__c = UserInfo.getUserId();
        csList.add(cs1);
        ISSP_CS__c cs2 = new ISSP_CS__c();
        cs2.Name = 'Host';
        cs2.Value__c = 'test';
        csList.add(cs2);

        List<Profile> profileList = [SELECT Id, Name FROM Profile WHERE Name LIKE 'ISS%'];
        for (Profile thisProfile : profileList){
            ISSP_CS__c newCS = new ISSP_CS__c();
            newCS.Value__c = thisProfile.Id;
            if (thisProfile.Name == 'ISS Portal (Partner)'){
                newCS.Name = 'ISS_Portal';
                csList.add(newCS);
            }
            else if (thisProfile.Name == 'ISS Portal Agency Delegated Admin User'){
                newCS.Name = 'ISS_Portal_Agency_Delegated_Admin';
                csList.add(newCS);
            }
            else if (thisProfile.Name == 'ISS Portal Agency User (Partner)'){
                newCS.Name = 'ISS_Portal_Agency_User';
                csList.add(newCS);
            }
            else if (thisProfile.Name == 'ISS Portal Airline Delegated Admin User'){
                newCS.Name = 'ISS_Portal_Airline_Delegated_Admin';
                csList.add(newCS);
            }
            else if (thisProfile.Name == 'ISS Portal Airline User (Partner)'){
                newCS.Name = 'ISS_Portal_Airline_User';
                csList.add(newCS);
            }
            else if (thisProfile.Name == 'ISS Portal Delegated Admin User'){
                newCS.Name = 'ISS_Portal_Delegated_Admin';
                csList.add(newCS);
            }
            else if (thisProfile.Name == 'ISS Portal GSA Delegated Admin User'){
                newCS.Name = 'ISS_Portal_GSA_Delegated_Admin';
                csList.add(newCS);
            }
            else if (thisProfile.Name == 'ISS Portal GSA User (Partner)'){
                newCS.Name = 'ISS_Portal_GSA_User';
                csList.add(newCS);
            }
        }
        insert csList;
    }

    static testMethod void myUnitTest_22() {

        //ISSP_ObjectFactory.fiilIncludedFields();
        //Account acc =  (Account)ISSP_ObjectFactory.createSObject('Account',false,1);
        Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.IATACode__c = '132';
        acc.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
        insert acc;

        ISSP_ContactList ctrl = new ISSP_ContactList();
        ISSPContactListView__c cs = new ISSPContactListView__c();
        cs.Name = 'Test';
        cs.Profiles_Id__c = Userinfo.getProfileId().substring(0,15);
        cs.Field_Set_API_Name__c = 'ISSP_Contacts_MyCompanyContacts';
        cs.Label_API_name__c = 'ISSP_Contacts_MyCompanyContacts';
        cs.Permission_set__c = '12345';
        cs.SOQL_Filter__c = 'WHERE Status__c = \'Active\' AND User_Portal_Status__c != \'Rejected\'';
        insert cs;
        ctrl.initialization();
        ctrl.refresh();
        ctrl.getContactList();
        ctrl.reject();
        ctrl.checkIdCard();
        ctrl.resetIdCard();
        ctrl.inactivate();
        ctrl.activateContact();
    }

}