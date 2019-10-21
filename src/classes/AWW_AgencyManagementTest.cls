@isTest
private class AWW_AgencyManagementTest {

    @testSetup static void setup() {         
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(
            Name= 'Portugal',
            ISO_Code__c= 'PT',
            ISO_Code_Numeric__c= 11
        );
        insert country;
        Account wwAccount = new Account(
            Name= 'World Wide Account',
            RecordTypeId= RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Agency_WW_HQ'),
            IATA_ISO_Country__c= country.Id
        );
        insert wwAccount;

        Account acc = new Account(
            Name= 'Test Ag',
            RecordTypeId= RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency'),
            IATA_ISO_Country__c= country.Id,
            World_Wide_Account__c= wwAccount.Id,
            Location_Type__c= 'HO',
            Location_Class__c= 'P',
            Sector__c= 'Travel Agent',
            Category__c= 'IATA Passenger Sales Agent',
            IATACode__c= '145362'
        );
        insert acc;
    }

    @isTest static void testUserPermissions() {
        List<PermissionSet> permissions = [SELECT Id, Name FROM PermissionSet WHERE Name IN ('AMP_admin','AMP_Profile_Visibility') ORDER BY Name ASC];
        List<PermissionSetAssignment> assignedPermissions = [SELECT Id FROM PermissionSetAssignment WHERE  AssigneeId = :UserInfo.getUserId() AND PermissionSetId IN :permissions];
        if(!assignedPermissions.isEmpty()) {
            delete assignedPermissions;
        }

        Test.startTest();
        String userAccessRight = AWW_AccountProfileCtrl.getUserAccessRights();
        System.assertEquals('no access', userAccessRight);

        PermissionSetAssignment p1 = new PermissionSetAssignment(
            AssigneeId= UserInfo.getUserId(),
            PermissionSetId= permissions[0].Id
        );
        insert p1;
        userAccessRight = AWW_AccountProfileCtrl.getUserAccessRights();
        System.assertEquals('read', userAccessRight);
        delete p1;
        PermissionSetAssignment p2 = new PermissionSetAssignment(
            AssigneeId= UserInfo.getUserId(),
            PermissionSetId= permissions[1].Id
        );
        insert p2;
        userAccessRight = AWW_AccountProfileCtrl.getUserAccessRights();
        System.assertEquals('full', userAccessRight);

        Test.stopTest();
    }

    @isTest static void testKeyContacts() {
        Account wwAccount = [SELECT Id FROM Account WHERE RecordType.DeveloperName= 'Agency_WW_HQ'];
        Contact c = new Contact(
            AccountId= wwAccount.Id,
            FirstName= 'FirstName',
            LastName= 'LastName',
            Title= 'Mr.',
            Email= 'email@test.com',
            CEO_CFO__c= 'CEO',
            Membership_Function__c= 'Training'
        );
        insert c;
        Test.startTest();
        List<AWW_KeyContactsCtrl.KeyContact> keyContacts = AWW_KeyContactsCtrl.getKeyContacts(wwAccount.Id);
        System.assertEquals(1, keyContacts.size());
        Test.stopTest();
    }

    @isTest static void testIdentificationAndHeader() {
        Account wwAccount = [SELECT Id FROM Account WHERE RecordType.DeveloperName= 'Agency_WW_HQ'];
        Test.startTest();
        Account res = AWW_AccountIdentificationCtrl.getAccountDetails(wwAccount.Id);
        Account res2 = AWW_AccountIdentificationCtrl.saveAccountDetails(wwAccount);
        res = AWW_AccountHeaderCtrl.getAccountHeader(wwAccount.Id);
        Test.stopTest();
    }

    @isTest static void testProductsAndServices() {
        Account wwAccount = [SELECT Id FROM Account WHERE RecordType.DeveloperName= 'Agency_WW_HQ'];
        Service__c publication = new Service__c(
            Name= 'Publication', Order__c= 1, Service_Publication__c= 'Publications'
        );
        Service__c service = new Service__c(
            Name= 'Service', Order__c= 1, Service_Publication__c= 'Services'
        );
        insert new List<Service__c> {publication, service};
        Account_Service__c pubToAccount = new Account_Service__c(
            Account__c= wwAccount.Id, Service__c= publication.Id
        );
        Account_Service__c serToAccount = new Account_Service__c(
            Account__c= wwAccount.Id, Service__c= service.Id
        );
        insert new List<Account_Service__c> {pubToAccount, serToAccount};
        Test.startTest();
        AWW_ProductsServicesCtrl.Response res = AWW_ProductsServicesCtrl.getProductsAndServices(wwAccount.Id);
        System.assertEquals(1, res.nonServices.services.size());
        System.assertEquals(1, res.services.services.size());
        Test.stopTest();
    }

    @isTest static void testOwnership() {
        Account wwAccount = [SELECT Id FROM Account WHERE RecordType.DeveloperName= 'Agency_WW_HQ'];
        Account a1 = new Account(
            Name= 'A1',
            RecordTypeId= RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account')
        );
        Account a2 = new Account(
            Name= 'A2',
            RecordTypeId= RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account')
        );
        insert new List<Account> {a1, a2};
        Test.startTest();
        Map<String,Object> o1 = new Map<String,Object> {
            'accountId' => wwAccount.Id, 'ownerId' => a1.Id, 'percentage' => 2
        };
        Map<String,Object> o2 = new Map<String,Object> {
            'accountId' => wwAccount.Id, 'ownerName' => 'A3', 'percentage' => 2
        };
        Map<String,Object> o3 = new Map<String,Object> {
            'ownerId' => wwAccount.Id, 'accountId' => a1.Id, 'percentage' => 2
        };
        Map<String,Object> o4 = new Map<String,Object> {
            'ownerId' => wwAccount.Id, 'accountName' => 'A4', 'percentage' => 2
        };
        AWW_AccountOwnershipCtrl.addRecord(JSON.serialize(new List<Object> {o1}));
        AWW_AccountOwnershipCtrl.addRecord(JSON.serialize(new List<Object> {o2}));
        AWW_AccountOwnershipCtrl.addRecord(JSON.serialize(new List<Object> {o3}));
        AWW_AccountOwnershipCtrl.addRecord(JSON.serialize(new List<Object> {o4}));

        AWW_AccountOwnershipCtrl.getOwners(wwAccount.Id);
        AWW_AccountOwnershipCtrl.getSubsidiaries(wwAccount.Id);

        AWW_AccountOwnershipCtrl.searchBy('A1', wwAccount.Id, 'Subsidiary');
        Test.stopTest();
    }

    @isTest static void testCoreRelationships() {
        Account wwAccount = [SELECT Id FROM Account WHERE RecordType.DeveloperName= 'Agency_WW_HQ'];
        Test.startTest();
        AWW_CoreRelationshipCtrl.calculateAccountRelations(wwAccount.Id);
        Test.stopTest();
    }

    @isTest static void testHeadOffices() {
        Account wwAccount = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'Agency_WW_HQ'];
        Account agency = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'IATA_Agency'];
        Test.startTest();
        AWW_HeadOfficesCtrl.getHeadOffices(wwAccount.Id);
        AWW_HeadOfficesCtrl.searchAccounts('Test', wwAccount.Id, 'remove');
        AWW_HeadOfficesCtrl.getAgencyHierarchy(agency.Id);
        Test.stopTest();
    }

    @isTest static void testPerformance() {
        Account wwAccount = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'Agency_WW_HQ'];
        Test.startTest();
        Objective__c obj = new Objective__c(
            Unit_Type__c= 'Percentage', Deadline__c= Date.today(), Status__c= 'On Track', Type__c= 'BMA'
        );        
        AWW_PerformanceCtrl.upsertRecord(obj, wwAccount.Id);
        List<Objective__c> objectives = AWW_PerformanceCtrl.getRecords(wwAccount.Id);
        System.assertEquals(1, objectives.size());
        Test.stopTest();
    }

    @isTest static void testAccountPlan() {
        Account wwAccount = [SELECT Id FROM Account WHERE RecordType.DeveloperName = 'Agency_WW_HQ'];
        Test.startTest();
        Objective__c obj = new Objective__c(
            Unit_Type__c= 'Percentage', 
            Deadline__c= Date.today(), 
            Status__c= 'On Track', 
            Type__c= 'BMA', 
            Account__c= wwAccount.Id,
            Description__c= 'Test',
            Name= 'Test',
            RecordTypeId= RecordTypeSingleton.getInstance().getRecordTypeId('Objective__c', 'Key_Account_Plan')
        );     
        AWW_AccountPlanCtrl.ObjectiveWrapper objWrapper = new AWW_AccountPlanCtrl.ObjectiveWrapper(obj);   
        AWW_AccountPlanCtrl.upsertRecord(objWrapper);
        List<AWW_AccountPlanCtrl.ObjectiveWrapper> objectives = AWW_AccountPlanCtrl.getObjectives(wwAccount.Id);
        System.assertEquals(1, objectives.size());
        AWW_AccountPlanCtrl.deleteRecord(objectives[0].convertToSFRecord());
        objectives = AWW_AccountPlanCtrl.getObjectives(wwAccount.Id);
        System.assertEquals(0, objectives.size());
        Test.stopTest();
    }    

}