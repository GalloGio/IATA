@isTest
public class ISSP_LocalGroupsTest {
    
    public static final Id RT_LOCALGROUP = [SELECT Id FROM Recordtype WHERE sObjectType = 'LocalGovernance__c' AND DeveloperName = 'Local_Groups'].Id;

    public static User createTestUser(){
        Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];
        User tu = New User(
            Alias = 'standt', Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
            LocaleSidKey='en_US', ProfileId = testProfile.Id,
            TimeZoneSidKey='America/Los_Angeles', UserName='test.username@test.com',
            License_Cost_Center__c = 'ISF005CH01'
        );

        insert tu;

        PermissionSet myPermissionSet = [SELECT ID from permissionSet where Name = 'Local_group_owners'];
        PermissionSetAssignment psa = new PermissionSetAssignment (PermissionSetId = myPermissionSet.Id, AssigneeId = tu.Id);
        insert psa;

        return tu;
    }
    
    public static testMethod void testController() {
        User testUser = createTestUser();

        list<Participant__c> listParticipant = new list<Participant__c>();
        System.runAs(testUser){
            IATA_ISO_Country__c country = new IATA_ISO_Country__c();
            country.Name = 'Country';
            country.ISO_Code__c = 'XX';
            insert country;
            Account account = ISSP_ObjectFactory.createNewAccount();
            account.RecordtypeId = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Account').get('IATA_Airline');
            account.Name = 'Account1';
            account.IATA_ISO_Country__c = country.Id;
            insert account;
            
            Cluster__c cluster = new Cluster__c();
            cluster.name = 'testcluster';
            insert cluster;
            
            Cluster_to_ISO_Country__c clusterCountry = new Cluster_to_ISO_Country__c();
            clusterCountry.Cluster__c = cluster.Id;
            clusterCountry.IATA_ISO_Country__c = country.Id;
            insert clusterCountry;

            Contact contact = ISSP_ObjectFactory.createNewContact();
            contact.AccountId = account.Id;
            insert contact;
            update contact;

            String recordTypeId = [SELECT Id FROM RecordType WHERE DeveloperName = 'FDS_ICCS_Email_to_Case'].Id;
            list<LocalGovernance__c> listLocalGroups = new list<LocalGovernance__c>();
            list<Contact> listContacts = new list<Contact>();
            Integer counter = 0;
            for (Schema.PicklistEntry entry: LocalGovernance__c.Local_Governance_type__c.getDescribe().getPicklistValues()) {
                listLocalGroups.add(
                    new LocalGovernance__c(
                    RecordtypeId = RT_LOCALGROUP,
                    IATA_Office__c = account.Id,
                    Active__c = true,
                    Local_Governance_type__c = entry.getValue(),
                    Cargo_Passenger__c = 'Cargo',
                    Cluster__c = cluster.Id)
                );
                listContacts.add(
                    new Contact(
                    FirstName = 'Contact',
                    LastName = 'LastName'+counter,
                    Title = 'title',
                    Email = counter+'mail@example.com',
                    AccountId = account.Id)
                );
                counter++;
            }
            insert listLocalGroups;
            insert listContacts;
            
            //list<Participant__c> listParticipant = new list<Participant__c>();
            for (Integer i=0; i<listLocalGroups.size(); i++) {
                listParticipant.add(
                    new Participant__c(
                        Local_Governance__c = listLocalGroups.get(i).Id,
                        Contact__c = listContacts.get(i).Id
                    )
                );
            }
            insert listParticipant;
        }

        Test.startTest();
        System.runAs(testUser){
            ISSP_LocalGroups controller = new ISSP_LocalGroups();
            System.assertEquals(listParticipant.size(),controller.listWrapper.size());
            String comname = controller.communityName;
            controller.init();
            controller.getCSVHeader();
        }
        Test.stopTest();
    }

    static testMethod void testController_testHierarchy() {
        Account account1 = new Account(Name='test1');
        insert account1;
        
        Contact contact = new Contact(
            Salutation = 'Mr.',
            FirstName= 'first',
            LastName= 'last',
            Email='test@email.com',
            AccountId = account1.id);
        insert contact;

        ISSP_LocalGroups ctrl = new ISSP_LocalGroups();
        
        Test.StartTest();
        ctrl.getMaxParentAccount(account1.id);
        Account account2 = new Account(Name='test2', ParentId=account1.Id);
        insert account2;
        ctrl.getMaxParentAccount(account2.id);
        Account account3 = new Account(Name='test3', ParentId=account2.Id);
        insert account3;
        ctrl.getMaxParentAccount(account3.id);
        Account account4 = new Account(Name='test4', ParentId=account3.Id);
        insert account4;
        ctrl.getMaxParentAccount(account4.id);
        Account account5 = new Account(Name='test5', ParentId=account4.Id);
        insert account5;
        ctrl.getMaxParentAccount(account5.id);
        Test.StopTest();
    }

}