@isTest
private class portalProfileCustomBoxCtrlTest {

    @TestSetup
    static void testSetup(){
        Id accountAgencyRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

        Account newAcc = new Account(Name='Account Test Headquarter', Site = 'Site Test', Sector__c = 'Airline',
                                    IATACode__c = '123', Field_Head_Office__c = 'Headquarter',
                                    RecordTypeId = accountAgencyRT);
        insert newAcc;

        Contact newCon1 = new Contact(AccountId = newAcc.Id, FirstName = 'John', LastName = 'Doe', Email = System.today().dayOfYear() + 'testemail1@csp.testclass', User_Portal_Status__c = 'Approved Admin');
        Contact newCon2 = new Contact(AccountId = newAcc.Id, FirstName = 'John', LastName = 'Doe', Email = System.today().dayOfYear() + 'testemail1@csp.testclass', User_Portal_Status__c = 'Pending Approval', Community__c = 'ISS Customer Portal');
        insert new List<Contact>{newCon1, newCon2};

        User newUser = ISSP_ObjectFactory.createPortalUser(newCon1);

        Account newAcc1 = new Account(Name='Account Test 1', Site = 'Site Test 1', Sector__c = 'Airline',
                                    IATACode__c = '001', Field_Head_Office__c = 'Test 1',
                                    Top_Parent__c = newAcc.Id, RecordTypeId = accountAgencyRT);

        Account newAcc2 = new Account(Name='Account Test 2', Site = 'Site Test 2', Sector__c = 'Airline',
                                    IATACode__c = '002', Field_Head_Office__c = 'Test 2',
                                    Top_Parent__c = newAcc.Id, RecordTypeId = accountAgencyRT);

        Account newAcc3 = new Account(Name='Account Test 3', Site = 'Site Test 3', Sector__c = 'Airline',
                                    IATACode__c = '003', Field_Head_Office__c = 'Test 3',
                                    Top_Parent__c = newAcc.Id, RecordTypeId = accountAgencyRT);

        Account newAcc4 = new Account(Name='Account Test 4', Site = 'Site Test 4', Sector__c = 'Travel Agent',
                                    IATACode__c = '004', Field_Head_Office__c = 'Test 4',
                                    Top_Parent__c = newAcc.Id, RecordTypeId = accountAgencyRT);
        insert newAcc1;
        insert newAcc2;
        insert newAcc3;
        insert newAcc4;

        Portal_Applications__c pa = new Portal_Applications__c(name = 'Risk Profile and RHC');
		insert pa;
    }

    @IsTest
    static void testGetAccounts(){
        User usr = [SELECT Id, ContactId FROM User WHERE Email LIKE '%testemail1@csp.testclass' LIMIT 1];
        Contact con = [SELECT Id FROM Contact WHERE LastName = 'Doe' LIMIT 1];

        Contact con2 = [SELECT Id FROM Contact WHERE User_Portal_Status__c = 'Pending Approval'];

        usr.ContactId = con.Id;
        update usr;

        List<portalProfileCustomBoxCtrl.optionWrapper> lstAccounts = new List<portalProfileCustomBoxCtrl.optionWrapper>();
        System.runAs(usr) {
            Test.startTest();
            lstAccounts = portalProfileCustomBoxCtrl.getAccounts();

            portalProfileCustomBoxCtrl.updateUserStatus(con2.Id, 'Active');
            Test.stopTest();
        }

        System.assertEquals(5, lstAccounts.size());
        System.assertEquals([SELECT User_Portal_Status__c FROM Contact WHERE Id = :con2.Id][0].User_Portal_Status__c , 'Active');
    }

    @IsTest
    static void testCreatePortalApplicationRigth(){

        Contact con = [SELECT Id FROM Contact WHERE LastName = 'Doe' LIMIT 1];
        Portal_Applications__c pa = [SELECT Id FROM Portal_Applications__c WHERE name = 'Risk Profile and RHC' LIMIT 1];

        Test.startTest();
            Boolean inserted = portalProfileCustomBoxCtrl.createPortalApplicationRigth(con.Id,new List<Id>{pa.Id});
            List<Portal_Application_Right__c> rigths = [SELECT Id,Contact__c, Portal_Application__c, Right__c FROM Portal_Application_Right__c];
        Test.stopTest();

        System.assertEquals(true, inserted);
        System.assertEquals(1, rigths.size());
        System.assertEquals(pa.Id, rigths.get(0).Portal_Application__c);
        System.assertEquals(con.Id, rigths.get(0).Contact__c);
        System.assertEquals('Access Granted', rigths.get(0).Right__c);
    }

    @IsTest
    static void testCreatePortalApplicationRigthFail(){

        Contact con = [SELECT Id FROM Contact WHERE LastName = 'Doe' LIMIT 1];
        Portal_Applications__c pa = [SELECT Id FROM Portal_Applications__c WHERE name = 'Risk Profile and RHC' LIMIT 1];

        String Id = (String) pa.Id;
        id = id.substring(0, id.length() - 1);
        id += 'a';

        Test.startTest();
            Boolean inserted = portalProfileCustomBoxCtrl.createPortalApplicationRigth(con.Id,new List<Id>{id});
            List<Portal_Application_Right__c> rigths = [SELECT Id,Contact__c, Portal_Application__c, Right__c FROM Portal_Application_Right__c];
        Test.stopTest();

        System.assert(!inserted);
        System.assertEquals(0, rigths.size());
    }
}
