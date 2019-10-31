@isTest
private class AMS_AgencyContactsControllerTest {
    
    @testSetup static void setup(){
        IATA_ISO_Country__c isoc = new IATA_ISO_Country__c(Name = 'Test', ISO_Code__c = 'TS');       
        insert isoc;

        Id accountRoleRTId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Account_Role__c', 'Employee');

        Account acc1 = new Account(Name='Test1 Account', Location_Type__c = 'HO', Type='CASS Associate', Sector__c = 'Travel Agent', IATA_ISO_Country__c = isoc.id, IATAcode__c = '12345678', AIMS_ID__c = '12345678', Source_System__c = 'AIMS2');
        insert acc1;

        Contact c1 = new Contact(AccountId = acc1.id, Firstname = 'teste1', Lastname='test1',Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com',
                                    Financial_Assessment_Contact__c = false);
        Contact c2 = new Contact(AccountId = acc1.id, Firstname = 'teste3', Lastname='test3',Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com',
                                    Financial_Assessment_Contact__c = false, User_Portal_Status__c = 'Approved Admin');
        Contact c3 = new Contact(AccountId = acc1.id, Firstname = 'teste4', Lastname='test1',Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com',
                                    Financial_Assessment_Contact__c = true);
        insert new List<Contact>{c1, c2, c3};

        AMS_Person__c p1 = new AMS_Person__c(Name='test1', Contact__c = c1.id);
        AMS_Person__c p2 = new AMS_Person__c(Name='test2', Contact__c = c2.id);
        AMS_Person__c p3 = new AMS_Person__c(Name='test3', Contact__c = c3.id);
        AMS_Person__c p4 = new AMS_Person__c(Name='test4');
        insert new List<AMS_Person__c>{p1, p2, p3, p4};

        AMS_Account_Role__c e1 = new AMS_Account_Role__c(recordTypeId = accountRoleRTId, Account__c = acc1.id, Person__c = p1.id, Contact__c = c1.id);
        AMS_Account_Role__c e2 = new AMS_Account_Role__c(recordTypeId = accountRoleRTId, Account__c = acc1.id, Person__c = p2.id, Contact__c = c2.id);
        AMS_Account_Role__c e3 = new AMS_Account_Role__c(recordTypeId = accountRoleRTId, Account__c = acc1.id, Person__c = p3.id, Contact__c = c3.id);
        AMS_Account_Role__c e4 = new AMS_Account_Role__c(recordTypeId = accountRoleRTId, Account__c = acc1.id, Person__c = p4.id);
        insert new List<AMS_Account_Role__c>{e1, e2, e3, e4};
    }

    @isTest static void test_AgencyContactList() {

        Account ag = [select id from Account];

        PageReference pageRef = Page.AMS_AgencyContacts;
        pageRef.getparameters().put('pid', ag.id);
        Test.setCurrentPageReference(pageRef);

        Test.startTest();
        AMS_AgencyContactsController sic = new AMS_AgencyContactsController(new ApexPages.standardController(ag));
        sic.getcontactTable();
        Test.stopTest();
    }   
}