@isTest
private class GlobalContactTriggerTest {

    private static Account acc1;
    private static Account acc2;
    private static Account acc1child;
    private static Account acc2child;

    private static void loadAccounts() {
        acc1 = new Account(Name='testAccount1', Type='IATA Passenger Sales Agent', Location_Type__c = 'AO');
        acc2 = new Account(Name='testAccount2', Type='IATA Passenger Sales Agent', Location_Type__c = 'AO');
        list<Account> listAccount = new list<Account>();
        listAccount.add(acc1);
        listAccount.add(acc2);
        insert listAccount;
        acc1 = getAccount(acc1.id);
        acc2 = getAccount(acc2.id);
    }

    private static Account getAccount(Id accountId) {
        return [Select Id, Name, ParentId from Account where id = :accountId];
    }
    
    @isTest
    private static void testHasFinancialAssessment1() {
        loadAccounts();
        
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User testUser = New User(
            Alias = 'standt', Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = testProfile.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='test.username@test.com', Is_Kavi_Internal_User__c=true,
            License_Cost_Center__c = 'ISF005CH01'
        );
        insert testUser;
        
        Contact contact = new Contact(
            FirstName='test', 
            LastName='test', 
            Email = 'standarduser@testorg.com',
            AccountId=acc1.Id, 
            Financial_Assessment_Contact__c = false,
            status__c = 'Inactive',
            kavi_user__c = testUser.id
        );
        Test.startTest();
        insert contact;
        Test.stopTest();
    }

    static testMethod void myUnitTest() {

        //ISSP_ObjectFactory.fiilIncludedFields();
        //Account acc =  (Account)ISSP_ObjectFactory.createSObject('Account',false,1);
        Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.IATACode__c = '132';
        acc.RecordTypeId = [SELECT Id FROM RecordType r WHERE SobjectType = 'Account' AND DeveloperName = 'IATA_Agency'][0].Id;
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
        ctrl.refresh();
        ctrl.getContactList();
        ctrl.contactList[0].selected = true;
        ctrl.contactStatus = 'Retired';
        ctrl.reject();
        List <Contact> newContactList = [SELECT Id, User_Portal_Status__c FROM Contact WHERE Id = :newContactId];
        System.AssertEquals(newContactList[0].User_Portal_Status__c, 'Rejected');
    }

    static testMethod void myUnitTest_5() {

        //ISSP_ObjectFactory.fiilIncludedFields();
        //Account acc =  (Account)ISSP_ObjectFactory.createSObject('Account',false,1);
        Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.IATACode__c = '132';
        acc.RecordTypeId = [SELECT Id FROM RecordType r WHERE SobjectType = 'Account' AND DeveloperName = 'IATA_Agency'][0].Id;
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
        acc.RecordTypeId = [SELECT Id FROM RecordType r WHERE SobjectType = 'Account' AND DeveloperName = 'IATA_Agency'][0].Id;
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
		
		Test.startTest();

        Portal_Applications__c app1 = new Portal_Applications__c(Name = 'MyTest', Critical_Service__c = true);
        insert app1;
        Portal_Application_Right__c appRight11 = new Portal_Application_Right__c(Contact__c = con.Id, Portal_Application__c = app1.Id, Right__c = 'Access Granted');
        insert appRight11;
        Portal_Application_Right__c appRight12 = new Portal_Application_Right__c(Contact__c = con2.Id, Portal_Application__c = app1.Id, Right__c = 'Access Granted');
        insert appRight12;
        Portal_Applications__c app2 = new Portal_Applications__c(Name = 'MyTest2');
        insert app2;
        Portal_Application_Right__c appRight21 = new Portal_Application_Right__c(Contact__c = con.Id, Portal_Application__c = app2.Id, Right__c = 'Access Granted');
        insert appRight21;

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
        Test.stopTest();

}

    static testMethod void myUnitTest_7() {

        Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.IATACode__c = '132';
        acc.RecordTypeId = [SELECT Id FROM RecordType r WHERE SobjectType = 'Account' AND DeveloperName = 'IATA_Agency'][0].Id;
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
        con.RecordTypeId = [SELECT Id FROM RecordType r WHERE SobjectType = 'Contact' AND DeveloperName = 'Standard_Contact'][0].Id;
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

    static testMethod void triggerTestAdd1() {

        Account acc = ISSP_ObjectFactory.createNewAccount();
        acc.Type = 'IATA Passenger Sales Agent';
        insert acc;

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= acc.Id;
        con.Status__c = 'Active';
        con.title = 'Monsieur';
        con.Financial_Assessment_Contact__c = true;
        con.function__c = 'Aeropolitical;Cargo';
        con.Membership_Function__c = 'Gen.Management;Commercial;Cargo;Finance;Aeropolitical;Environment';
        con.RecordTypeId = [SELECT Id FROM RecordType r WHERE SobjectType = 'Contact' AND DeveloperName = 'Standard_Contact'][0].Id;
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
    }

    static testMethod void triggerTestRem1() {

        Account acc = ISSP_ObjectFactory.createNewAccount();
        insert acc;

        ID gdpContactRecordTypeID = clsContactTypeIDSingleton.getInstance().RecordTypes.get('GDP Contact');
        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= acc.Id;
        con.recordtypeid = gdpContactRecordTypeID;
        con.Status__c = 'Active';
        con.title = 'Monsieur';
        con.function__c = 'Aeropolitical;Cargo';
        con.Membership_Function__c = 'Gen.Management;Commercial;Cargo;Finance;Aeropolitical;Environment';
        con.RecordTypeId = [SELECT Id FROM RecordType r WHERE SobjectType = 'Contact' AND DeveloperName = 'Standard_Contact'][0].Id;
        insert con;

        delete con;

        undelete con;
    }

    static testMethod void triggerTestAdd2() {

        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'ISS Portal'];
        User testUser = New User(
            Alias = 'standt', Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = testProfile.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='test.username@test.com',
            License_Cost_Center__c = 'ISF005CH01'
        );
        
        Account acc = ISSP_ObjectFactory.createNewAccount();
        insert acc;

        Account acc2 = ISSP_ObjectFactory.createNewAccount();
        insert acc2;

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= acc.Id;
        con.Status__c = 'Active';
        con.title = 'Monsieur';
        con.function__c = 'Aeropolitical;Cargo';
        con.Membership_Function__c = 'Gen.Management;Commercial;Cargo;Finance;Aeropolitical;Environment';
        con.RecordTypeId = [SELECT Id FROM RecordType r WHERE SobjectType = 'Contact' AND DeveloperName = 'Standard_Contact'][0].Id;
        insert con;
		
        testUser.ContactId = con.id;
        testUser.ContactKaviId__c = con.id;
        insert testUser;

        con.Preferred_Language__c = 'Italian';
        con.Accountid = acc2.id;
        con.User_Portal_Status__c = 'Deactivated';
        con.status__c = 'Inactive';
        con.Kavi_User__c = testUser.id;

        /*Portal_Applications__c PA = new Portal_Applications__c(
            Name = 'Treasury Dashboard'
        );
        insert PA;

        Portal_Applications__c PA2 = new Portal_Applications__c(
            Name = 'Standards Setting Workspace'
        );
        insert PA2;

        Portal_Application_Right__c PAR = new Portal_Application_Right__c(
            Contact__c = con.Id,
            Portal_Application__c = PA.id
        );
        insert PAR;

        Portal_Application_Right__c PAR2 = new Portal_Application_Right__c(
            Contact__c = con.Id,
            
            Portal_Application__c = PA2.id
        );
        insert PAR2;*/

		User usr = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
		
		system.runAs(usr){
			
			Test.setMock(HttpCalloutMock.class, new HigherLogicServiceMock());
			
			Test.startTest();

	        try{
	        	update con;
	        }
	        catch(Exception e){
	            Boolean expectedExceptionThrown =  e.getMessage().contains('subscription') ? true : false;
	            //System.AssertEquals(expectedExceptionThrown, true);
	        }
	        
    		Test.stopTest();
    		
		}
        
    }

    static testMethod void triggerTestAdd3() {

        Account acc = ISSP_ObjectFactory.createNewAccount();
        insert acc;

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= acc.Id;
        con.Status__c = 'Active';
        con.Ver_Number_2__c = '212';
        insert con;

        con.User_Portal_Status__c = 'Regional Administrator';
        try{
            update con;
        }
        catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('subscription') ? true : false;
            //System.AssertEquals(expectedExceptionThrown, true);
        }
    }
    
    static testMethod void triggerTestAdd4() {

        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'ISS Portal'];
        User testUser = New User(
            Alias = 'standt', Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = testProfile.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='test.username@test.com',
            License_Cost_Center__c = 'ISF005CH01'
        );
        

        Account acc = ISSP_ObjectFactory.createNewAccount();
        insert acc;

        Account acc2 = ISSP_ObjectFactory.createNewAccount();
        insert acc2;

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= acc.Id;
        con.Status__c = 'Active';
        con.function__c = 'Aeropolitical;Cargo';
        con.title = 'Monsieur';
        con.Membership_Function__c = 'Gen.Management;Commercial;Cargo;Finance;Aeropolitical;Environment';
        con.RecordTypeId = [SELECT Id FROM RecordType r WHERE SobjectType = 'Contact' AND DeveloperName = 'Standard_Contact'][0].Id;
        insert con;

        testUser.ContactId = con.id;
        testUser.ContactKaviId__c = con.id;
        insert testUser;

        con.Preferred_Language__c = 'Italian';
        con.Accountid = acc2.id;
        con.User_Portal_Status__c = 'Deactivated';
        con.status__c = 'Inactive';
        con.Kavi_User__c = testUser.id;

		User usr = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
		
		system.runAs(usr){

			Test.setMock(HttpCalloutMock.class, new HigherLogicServiceMock());
			
	        Test.startTest();
	        
	        list<Portal_Applications__c> listApps = new list<Portal_Applications__c>();
	        Portal_Applications__c PA = new Portal_Applications__c(
	            Name = 'Test'
	        );
	        listApps.add(PA);
	
	        Portal_Applications__c PA2 = new Portal_Applications__c(
	            Name = 'Standards Setting Workspace'
	        );
	        listApps.add(PA2);
	        insert listApps;
	
	        list<Portal_Application_Right__c> listAppRights = new list<Portal_Application_Right__c>();
	        Portal_Application_Right__c PAR = new Portal_Application_Right__c(
	            Contact__c = con.Id,
	            Portal_Application__c = PA.id,
	            Right__c = 'Access Granted'
	        );
	        listAppRights .add(PAR);
	
	        Portal_Application_Right__c PAR2 = new Portal_Application_Right__c(
	            Contact__c = con.Id,
	            Portal_Application__c = PA2.id,
	            Right__c = 'Access Granted'
	        );
	        listAppRights .add(PAR2);
	        insert listAppRights ;
	
	        try{
	            update con;
	        }
	        catch(Exception e){
	            Boolean expectedExceptionThrown =  e.getMessage().contains('subscription') ? true : false;
	            //System.AssertEquals(expectedExceptionThrown, true);
	        }
        
	        Test.stopTest();
	        
		}
		
    }

    static testMethod void triggerTestAdd5() {

        Account acc = ISSP_ObjectFactory.createNewAccount();
        insert acc;

        ID gdpContactRecordTypeID = clsContactTypeIDSingleton.getInstance().RecordTypes.get('GDP Contact');
        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId= acc.Id;
        con.Status__c = 'Active';
        con.function__c = 'Aeropolitical;Cargo';
        con.Membership_Function__c = '';
        con.Ver_Number__c = 21.0;
        try{
            insert con;
        }
        catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('subscription') ? true : false;
            //System.AssertEquals(expectedExceptionThrown, true);
        }
        con.Membership_Function__c = 'Gen.Management;Commercial;Finance;Environment';
        try{
            insert con;
        }
        catch(Exception e){
            Boolean expectedExceptionThrown =  e.getMessage().contains('subscription') ? true : false;
            //System.AssertEquals(expectedExceptionThrown, true);
        }

    }
    
    static testMethod void triggerTestIdCardAvailableService1() {
        Contact contact = new Contact();
        contact.FirstName = 'first875454';
        contact.LastName = 'last2343246';
        contact.ID_Card_Holder__c = true;
        
        Test.startTest();
        insert contact;
        Test.stopTest();

        contact = [Select Id, Name, ID_Card_Holder__c, Available_Services__c, Available_Services_Images__c
            FROM Contact
            WHERE id = :contact.Id];
        System.assertEquals(IdCardUtil.IDCARD_SERVICE_NAME, contact.Available_Services__c);
        System.assert(contact.Available_Services_Images__c.contains(IdCardUtil.IDCARD_SERVICE_NAME));
    }
    
    static testMethod void triggerTestIdCardAvailableService2() {
        Contact contact = new Contact();
        contact.FirstName = 'first55667';
        contact.LastName = 'last2344237';
        contact.email = 'test98329832@email.com';
        contact.ID_Card_Holder__c = false;
        insert contact;
        
        contact = [Select Id, Name, ID_Card_Holder__c, Available_Services__c, Available_Services_Images__c
            FROM Contact
            WHERE id = :contact.Id];
        System.assertEquals(true,String.isBlank(contact.Available_Services__c));
        System.assertEquals(true,String.isBlank(contact.Available_Services_Images__c));
        System.debug('*** TEST START');
        IDCardUtil.isFirstTime = true;
        Test.startTest();
        contact.ID_Card_Holder__c = true;
        update contact;
        Test.stopTest();

        contact = [Select Id, Name, ID_Card_Holder__c, Available_Services__c, Available_Services_Images__c
            FROM Contact
            WHERE id = :contact.Id];
        System.assertEquals(IdCardUtil.IDCARD_SERVICE_NAME, contact.Available_Services__c);
        System.assert(contact.Available_Services_Images__c.contains(IdCardUtil.IDCARD_SERVICE_NAME), contact.Available_Services_Images__c);
    }
    
    static testMethod void triggerTestIdCardAvailableService3() {
        Contact contact = new Contact();
        contact.FirstName = 'first123123';
        contact.LastName = 'last31232131';
        contact.email = 'test98329833@email.com';
        contact.ID_Card_Holder__c = true;
        insert contact;
        
        contact = [Select Id, Name, ID_Card_Holder__c, Available_Services__c, Available_Services_Images__c
            FROM Contact
            WHERE id = :contact.Id];
        System.assertEquals(IdCardUtil.IDCARD_SERVICE_NAME, contact.Available_Services__c);
        System.assert(contact.Available_Services_Images__c.contains(IdCardUtil.IDCARD_SERVICE_NAME));
        
        IDCardUtil.isFirstTime = true;
        Test.startTest();
        contact.ID_Card_Holder__c = false;
        update contact;
        Test.stopTest();

        contact = [Select Id, Name, ID_Card_Holder__c, Available_Services__c, Available_Services_Images__c
            FROM Contact
            WHERE id = :contact.Id];
        System.assertEquals(true,String.isBlank(contact.Available_Services__c));
        System.assertEquals(true,String.isBlank(contact.Available_Services_Images__c));
    }
}