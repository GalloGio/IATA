@isTest
private class ISSP_PortalUserStatusChangeTest {

    public static testMethod void testISSP_PortalUserStatusChangeTest() {
        //ISSP_ObjectFactory.fiilIncludedFields();
        //Account acc =  (Account)ISSP_ObjectFactory.createSObject('Account',false,1);
        Account acc = ISSP_ObjectFactory.createNewAccount();
        insert acc;
        //Contact con = (Contact)ISSP_ObjectFactory.createSObject('Contact',false,1);
        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= acc.Id;
        insert con;
        ISSP_PortalUserStatusChange controler = new ISSP_PortalUserStatusChange(new Apexpages.Standardcontroller(con));

        controler.con.User_Portal_Status__c = 'Approved User';
        string actionName = ISSP_PortalUserStatusChange.getActionName(controler.con.User_Portal_Status__c,'');
        ISSP_PortalUserStatusChange.preformAction(actionName,controler.con.Id,controler.con.User_Portal_Status__c);

        ISSP_ObjectFactory.createPortalUser(con);

        controler.con.User_Portal_Status__c = 'Deactivate';
        actionName = ISSP_PortalUserStatusChange.getActionName(controler.con.User_Portal_Status__c,'');
        ISSP_PortalUserStatusChange.preformAction(actionName,controler.con.Id,controler.con.User_Portal_Status__c);

        //ISSP_PortalUserStatusChange.isUserDisabel(con.Id);
        //ISSP_PortalUserStatusChange.disabelUser(con.Id);
        Set<String> setIds = new Set<String>();
        setIds.add(con.Id);

        //ISSP_PortalUserStatusChange.futureDeactivateUsers(setIds);
        //ISSP_PortalUserStatusChange.futureUpdateUsers(setIds);

        controler.con.User_Portal_Status__c = 'Approved Admin';
        actionName = ISSP_PortalUserStatusChange.getActionName(controler.con.User_Portal_Status__c,'');
        ISSP_PortalUserStatusChange.preformAction(actionName,controler.con.Id,controler.con.User_Portal_Status__c);
        controler.save();

        ISSP_PortalUserStatusChange.createEmail(null,null, null);
        //controler.disabelUser();

 //       ISSP_PortalUserStatusChange.maasUserCreation(con);


    }

    public static testMethod void testISSP_PortalUserStatusChangeTest2() {
        //ISSP_ObjectFactory.fiilIncludedFields();
        //Account acc =  (Account)ISSP_ObjectFactory.createSObject('Account',false,1);
        Account acc = ISSP_ObjectFactory.createNewAccount();
        insert acc;
        //Contact con = (Contact)ISSP_ObjectFactory.createSObject('Contact',false,1);
        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= acc.Id;
        con.User_Portal_Status__c = 'Pending Approval';
        con.Community__c = 'E-Commerce';
        insert con;
        ISSP_PortalUserStatusChange controler = new ISSP_PortalUserStatusChange(new Apexpages.Standardcontroller(con));

        controler.disabelUser();

        controler.rejectUser();
    }

    public static testMethod void testISSP_PortalUserStatusChangeTest3() {

        //ISSP_ObjectFactory.fiilIncludedFields();
        String profileId = [SELECT Id FROM Profile WHERE Name = 'ISS Portal DPC Admin' LIMIT 1].Id;
        //Account acc = (Account)ISSP_ObjectFactory.createSObject('Account',false,4);
        Account acc = ISSP_ObjectFactory.createNewAccount();
        insert acc;
        //Contact contact = (Contact)ISSP_ObjectFactory.createSObject('Contact',false,1);
        Contact contact = ISSP_ObjectFactory.createNewContact();
        contact.AccountId = acc.Id;
        contact.User_Portal_Status__c = 'Pending Approval';
        insert contact;
        User newUser = new User(alias = 'dsfsdfds',
                                email = contact.email,
                                emailencodingkey = 'UTF-8',
                                firstname = contact.firstName,
                                lastname = contact.lastname,
                                languagelocalekey = 'en_US',
                                localesidkey = 'en_US',
                                contactId = contact.Id,
                                timezonesidkey = 'Asia/Dubai',
                                username = contact.email+'dfgdf',
                                PortalRole = 'Manager',
                                CommunityNickname = contact.email.substring(0, contact.email.indexOf('@'))+Datetime.now().formatLong().substring(10,15),
                                ProfileId = profileId,
                                IsActive = true);
        insert newUser;
		/*
        Test.startTest();
        ISSP_PortalUserStatusChange controler = new ISSP_PortalUserStatusChange(new Apexpages.Standardcontroller(contact));
        controler.contactId = contact.Id;
        controler.sendEmailToUser();
		
        ISSP_PortalUserStatusChange.preformActionFuture(contact.Id,'Active','Approved User');
        ISSP_PortalUserStatusChange.preformActionImmediate(contact.Id,'Pending Approval','Approved User');

        ISSP_PortalUserStatusChange.DisableTheUser action = new ISSP_PortalUserStatusChange.DisableTheUser();
        action.processAction(contact.Id);

        Test.stopTest();
		*/
    }

    public static testMethod void testISSP_PortalUserStatusChangeTest4() {
        //ISSP_ObjectFactory.fiilIncludedFields();
        //Account acc =  (Account)ISSP_ObjectFactory.createSObject('Account',false,1);
        Account acc = ISSP_ObjectFactory.createNewAccount();
        insert acc;
        //Contact con = (Contact)ISSP_ObjectFactory.createSObject('Contact',false,1);
        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= acc.Id;
        con.User_Portal_Status__c = 'Pending Approval';
        con.Community__c = 'E-Commerce';
        insert con;
        ISSP_PortalUserStatusChange controler = new ISSP_PortalUserStatusChange(new Apexpages.Standardcontroller(con));
        controler.contactId = con.Id;
        controler.portalStatus = 'Approved User';
        controler.oldPortalStatus = 'Pending Approval';
        controler.preformAction();
        controler.portalStatus = 'Approved Admin';
        controler.oldPortalStatus = 'Approved User';
        controler.preformAction();
        controler.portalStatus = 'Approved User';
        controler.oldPortalStatus = 'Approved Admin';
        controler.preformAction();
        ISSP_PortalUserStatusChange.disabelUser(con.Id);
    }

    public static testMethod void testISSP_PortalUserStatusChangeTest5() {
        //ISSP_ObjectFactory.fiilIncludedFields();
        //Account acc =  (Account)ISSP_ObjectFactory.createSObject('Account',false,1);
        Account acc = ISSP_ObjectFactory.createNewAccount();
        insert acc;
        //Contact con = (Contact)ISSP_ObjectFactory.createSObject('Contact',false,1);
        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= acc.Id;
        con.User_Portal_Status__c = 'Pending Approval';
        con.Email = 'test1@test.com';
        insert con;
        //Contact con2 = (Contact)ISSP_ObjectFactory.createSObject('Contact',false,2);
        Contact con2 = ISSP_ObjectFactory.createNewContact();
        con2.AccountId= acc.Id;
        con2.User_Portal_Status__c = 'Pending Approval';
        con2.Email = 'test2@test.com';
        insert con2;
        List <Contact> contactList = new List <Contact>();
        contactList.add(con);
        contactList.add(con2);
        Set <String> contactListId = new Set <String>();
        contactListId.add(con.Id);
        contactListId.add(con2.Id);

        ISSP_PortalUserStatusChange.removeInactiveEmail(con2.Email);
        ISSP_PortalUserStatusChange.maasUserCreation(contactList, 'CNS');
        ISSP_PortalUserStatusChange.futureUpdateUsers(contactListId);
        ISSP_PortalUserStatusChange.futureDeactivateUsers(contactListId);

    }

    Public static testMethod void testISSP_SaveNewStatus1() {

        Account acc = ISSP_ObjectFactory.createNewAccount();
        insert acc;

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= acc.Id;
        con.User_Portal_Status__c = 'Pending Approval';
        con.Email = 'test1@test.com';
        con.Community__c = 'E-Commerce';
        insert con;

        Portal_Applications__c portalApp = new Portal_Applications__c();
        portalApp.Name = 'test portalApp';
        portalApp.Critical_Service__c = true;
        insert portalApp;

        Portal_Application_Right__c portAppRight = new Portal_Application_Right__c();
        portAppRight.Right__c = 'Access Granted';
        portAppRight.Contact__c = con.id;
        portAppRight.Portal_Application__c = portalApp.Id;
        insert portAppRight;

        con.User_Portal_Status__c = 'Deactivate'; //'DisableTheUser'
        update con;

        Test.startTest();

        ISSP_PortalUserStatusChange controller = new ISSP_PortalUserStatusChange(new Apexpages.Standardcontroller(con));

        controller.saveNewStatus();
        System.assert(checkPageMessages(portalApp.Name));

        portalApp.Critical_Service__c = false;

        update portalApp;
        controller.con = con;

        controller.saveNewStatus();
        System.assert(checkPageMessages('Error: Please provide a reason to inactivate this user'));

        controller.inactivationReason = 'Retired';
        controller.saveNewStatus();
        System.assertEquals([SELECT Id, Portal_Inactivation_Reason__c FROM Contact where Id = :con.Id].Portal_Inactivation_Reason__c, Label.ISSP_RejectReason_Retired);

        controller.inactivationReason = 'AccessDenied';
        controller.saveNewStatus();
        System.assertEquals([SELECT Id, Portal_Inactivation_Reason__c FROM Contact where Id = :con.Id].Portal_Inactivation_Reason__c, Label.ISSP_RejectReason_Denied);

        controller.inactivationReason = 'LeftCompany';
        controller.saveNewStatus();
        System.assertEquals([SELECT Id, Portal_Inactivation_Reason__c FROM Contact where Id = :con.Id].Portal_Inactivation_Reason__c, Label.ISSP_RejectReason_Left);

        controller.inactivationReason = 'UnknownContact';
        controller.saveNewStatus();
        System.assertEquals([SELECT Id, Portal_Inactivation_Reason__c FROM Contact where Id = :con.Id].Portal_Inactivation_Reason__c, Label.ISSP_RejectReason_Unknown);

        Test.stopTest();
    }

    Public static testMethod void testISSP_SaveNewStatus2() {

        List<Profile> portalProfiles = [SELECT Id, Name FROM Profile WHERE Name = 'ISS Portal (Partner)' OR Name = 'ISS Portal Delegated Admin User'];

        Map<String,Profile> profileMap = new Map<String,Profile>();
        for(Profile p : portalProfiles){
            profileMap.put(p.name,p);
        }

        List<ISSP_CS__c> cSettings = new List<ISSP_CS__c>();
        ISSP_CS__c cSetting1 = new ISSP_CS__c();
        cSetting1.Name = 'ISS_Portal';
        cSetting1.Value__c = String.valueOf(profileMap.get('ISS Portal (Partner)').Id).substring(0, 15);

        ISSP_CS__c cSetting2 = new ISSP_CS__c();
        cSetting2.Name = 'Host';
        cSetting2.Value__c = 'portal.iata.org';//'portal.iata.org'

        ISSP_CS__c cSetting3 = new ISSP_CS__c();
        cSetting3.Name = 'ISS_Portal_Delegated_Admin';
        cSetting3.Value__c = String.valueOf(profileMap.get('ISS Portal Delegated Admin User').Id).substring(0, 15);

        cSettings.add(cSetting1);
        cSettings.add(cSetting2);
        cSettings.add(cSetting3);
        insert cSettings;

        Map<String,String> customSetingMap = new Map<String,String>();
        for(ISSP_CS__c cs : [select Name,value__c from ISSP_CS__c]){
            customSetingMap.put(cs.Name.trim(),cs.Value__c);
            ISSP_Constant.customSetingMap.put(cs.Name.trim(),cs.Value__c);
        }

        List<Account> accs = new List<Account>();
        Account acc = ISSP_ObjectFactory.createNewAccount();
        insert acc;

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.FirstName = 'test';
        con.LastName = 'contact';
        con.AccountId= acc.Id;
        con.User_Portal_Status__c = 'Pending Approval';
        con.Email = 'test1@test.com';
        con.Preferred_Language__c = 'English';
        con.Community__c = 'E-Commerce';
        insert con;

        Portal_Applications__c portalApp = new Portal_Applications__c();
        portalApp.Name = 'test portalApp';
        portalApp.Critical_Service__c = false;
        insert portalApp;

        Portal_Application_Right__c portAppRight = new Portal_Application_Right__c();
        portAppRight.Right__c = 'Access Granted';
        portAppRight.Contact__c = con.id;
        portAppRight.Portal_Application__c = portalApp.Id;
        insert portAppRight;

        

        ISSP_PortalUserStatusChange controller = new ISSP_PortalUserStatusChange(new Apexpages.Standardcontroller(con));

        //'DisableTheUserReject';
        con.User_Portal_Status__c = 'Rejected';
        update con;
        controller.con = con;

        controller.saveNewStatus();
        System.assert(checkPageMessages('Error: Please provide a reason to reject this user'));
        Test.startTest();
        controller.rejectionReason = 'Retired';
        controller.saveNewStatus();
        System.assertEquals([SELECT Id, Portal_Inactivation_Reason__c FROM Contact where Id = :con.Id].Portal_Inactivation_Reason__c, Label.ISSP_RejectReason_Retired);

        controller.rejectionReason = 'LeftCompany';
        controller.saveNewStatus();
        System.assertEquals([SELECT Id, Portal_Inactivation_Reason__c FROM Contact where Id = :con.Id].Portal_Inactivation_Reason__c, Label.ISSP_RejectReason_Left);

        controller.rejectionReason = 'AccessDenied';
        controller.saveNewStatus();
        System.assertEquals([SELECT Id, Portal_Inactivation_Reason__c FROM Contact where Id = :con.Id].Portal_Inactivation_Reason__c, Label.ISSP_RejectReason_Denied);

        controller.rejectionReason = 'UnknownContact';
        controller.saveNewStatus();
        System.assertEquals([SELECT Id, Portal_Inactivation_Reason__c FROM Contact where Id = :con.Id].Portal_Inactivation_Reason__c, Label.ISSP_RejectReason_Unknown);

        ISSP_PortalUserStatusChange.removeInactiveEmail(con.email);

        //'CreateNewUserWithPartnerProfile',
        con.User_Portal_Status__c = 'Regional Administrator';
        controller.con = con;
        controller.saveNewStatus();
        
        Test.stopTest();

        System.assert([SELECT Id, ProfileId FROM User WHERE ProfileId = :profileMap.get('ISS Portal Delegated Admin User').Id].size() > 0, 'User should have been created');


    }

    Public static testMethod void testISSP_SaveNewStatus3() {

        Profile portalProfile = [SELECT Id, Name FROM Profile WHERE Name = 'ISS Portal Agency User'][0];

        List<ISSP_CS__c> cSettings = new List<ISSP_CS__c>();

        ISSP_CS__c cSetting = new ISSP_CS__c();
        cSetting.Name = 'ISS_Portal_Agency_User';
        cSetting.Value__c = String.valueOf(portalProfile.Id).substring(0, 15);
        cSettings.add(cSetting);

        ISSP_CS__c cSetting2 = new ISSP_CS__c();
        cSetting2.Name = 'Host';
        cSetting2.Value__c = 'portal.iata.org';
        cSettings.add(cSetting2);

        insert cSettings;

        Id rtId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
        Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.RecordTypeId = rtId;
        insert acc;

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.FirstName = 'test';
        con.LastName = 'contact';
        con.AccountId= acc.Id;
        con.User_Portal_Status__c = 'Rejected';
        con.Email = 'test1@test.com';
        con.Preferred_Language__c = 'English';
        con.Community__c = 'E-Commerce';
        insert con;

        Test.startTest();

        ISSP_PortalUserStatusChange controller = new ISSP_PortalUserStatusChange(new Apexpages.Standardcontroller(con));

        //'CreateNewUserWithCustomerProfile'
        con.User_Portal_Status__c = 'Active';
        controller.con = con;
        controller.saveNewStatus();
        System.assert([SELECT Id, ProfileId, Name FROM User WHERE ProfileId =:portalProfile.Id].size() > 0, 'User should have been created');

    }

    Public static testMethod void testISSP_SaveNewStatus4() {

        Profile portalProfile = [SELECT Id, Name FROM Profile WHERE Name = 'ISS Portal (Partner)'][0];

        List<ISSP_CS__c> cSettings = new List<ISSP_CS__c>();

        ISSP_CS__c cSetting = new ISSP_CS__c();
        cSetting.Name = 'ISS_Portal';
        cSetting.Value__c = String.valueOf(portalProfile.Id).substring(0, 15);
        cSettings.add(cSetting);

        ISSP_CS__c cSetting2 = new ISSP_CS__c();
        cSetting2.Name = 'Host';
        cSetting2.Value__c = 'portal.iata.org';
        cSettings.add(cSetting2);

        insert cSettings;

        Id rtId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
        Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.RecordTypeId = rtId;
        insert acc;

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.FirstName = 'test';
        con.LastName = 'contact';
        con.AccountId= acc.Id;
        con.User_Portal_Status__c = 'Rejected';
        con.Email = 'test1@test.com';
        con.Preferred_Language__c = 'English';
        con.Community__c = 'E-Commerce';
        insert con;

        Test.startTest();

        ISSP_PortalUserStatusChange controller = new ISSP_PortalUserStatusChange(new Apexpages.Standardcontroller(con));

        //'CreateNewUserWithStandardProfile'
        con.User_Portal_Status__c = 'Pending Approval';
        Controller.con = con;
        controller.saveNewStatus();
        
        Test.stopTest();
        

        System.assert([SELECT Id, ProfileId, Name FROM User WHERE ProfileId =:portalProfile.Id limit 10 ].size() > 0, 'User should have been created');

    }

    @isTest
    Public static void testUpdateUser(){

        Profile portalProfile = [SELECT Id, Name FROM Profile WHERE Name = 'ISS Portal (Partner)'][0];

        Id rtId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
        Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.RecordTypeId = rtId;
        insert acc;

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.FirstName = 'test';
        con.LastName = 'contact';
        con.AccountId= acc.Id;
        con.User_Portal_Status__c = 'Rejected';
        con.Email = 'test1@test.com';
        con.Preferred_Language__c = 'English';
        insert con;

        User newUser = new User(alias = 'dsfsdfds',
                                email = con.email,
                                emailencodingkey = 'UTF-8',
                                firstname = con.firstName,
                                lastname = con.lastname,
                                languagelocalekey = 'en_US',
                                localesidkey = 'en_US',
                                contactId = con.Id,
                                timezonesidkey = 'Asia/Dubai',
                                username = con.email+'dfgdf',
                                PortalRole = 'Manager',
                                CommunityNickname = con.email.substring(0, con.email.indexOf('@'))+Datetime.now().formatLong().substring(10,15),
                                ProfileId = portalProfile.Id,
                                IsActive = true);
        insert newUser;

        //System.runAs(newUser){
        Test.startTest();

        ISSP_PortalUserStatusChange.updateUser(con.Id, true, con.Email, portalProfile.Id, '');

        Test.stopTest();
        //}

    }

    // verifies if ApexPages.Message contains a specific message
    Private static Boolean checkPageMessages(String message){
        for (ApexPages.Message m: ApexPages.getMessages()){
            if (m.getDetail().contains(message)){
                return true;
            }
        }
        return false;
    }

}