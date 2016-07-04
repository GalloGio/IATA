@isTest
public with sharing class AMS_AccountRoleCreatorTest {
    
    @testSetup static void setup()
    {
        IATA_ISO_Country__c isoc = new IATA_ISO_Country__c(Name = 'Test', ISO_Code__c = 'TS');       
        insert isoc;

        Map<string, Id> accountRoleRT = TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'AMS_Account_Role__c'}).get('AMS_Account_Role__c');

        Account acc1 = new Account(Name='Test1 Account', Location_Type__c = 'HO', Type='CASS Associate', Sector__c = 'Travel Agent', IATA_ISO_Country__c = isoc.id, IATAcode__c = '12345678', AIMS_ID__c = '12345678', Source_System__c = 'AIMS2');
        insert acc1;
        
        AMS_OSCAR__c oscar = new AMS_OSCAR__c(Account__c = acc1.Id);
        insert oscar;
        
        Case testCase = ISSP_ObjectFactory.createNewCase();
        testCase.BSPCountry__c = 'Hong Kong (SAR), China';
        testCase.Reason1__c = 'Agency';
        testCase.Customer_recovery__c = false;
        testCase.New_AWB_only_to_be_used_after_17Mar_200__c = false;
        testCase.BounceEmailCounter__c = 0.0;
        testCase.Case_Language__c = 'English';
        testCase.Subject = 'Test 006';
        testCase.Reopened_case__c = 0.0;
        testCase.Continous_Feed_SAF__c = true;
        testCase.Account_Concerned__c = acc1.Id;
        testCase.IFAP_Country_ISO__c = 'tq';
        testCase.AccountId = acc1.id;
        testCase.Oscar__c = oscar.Id;
        insert testCase;
        
        AMS_Pax_Accreditation_Form__c onlineAccreditation = new AMS_Pax_Accreditation_Form__c(IsGSA__c = 'No', CurrencyIsoCode = isoc.CurrencyIsoCode, SAAM_Case__c = testCase.Id);
        insert onlineAccreditation;
        
        List<AMS_Accreditation_Contact__c> acList = new List<AMS_Accreditation_Contact__c>();
        acList.add(new AMS_Accreditation_Contact__c(AMS_Pax_Accreditation_Form__c = onlineAccreditation.Id, Company__c = acc1.id, First_name__c='NameToUse', Last_name__c='Last', Job_title__c='ABC', Mobile__c='+4112345678', Phone__c='3424322343', Email__c='unique@email.com', RecordTypeId=AMS_Utils.getId('AMS_Accreditation_Contact__c', 'Person')));
        insert acList;
        
        Contact c1 = new Contact(AccountId = acc1.id, Firstname = 'c1ObsoleteName', Lastname='c1LastName', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com', Financial_Assessment_Contact__c = false);
        // DT: Employee no more saved as role
        Contact c2 = new Contact(AccountId = acc1.id, Firstname = 'FirstNameNotToUse', Lastname='LastName', Phone = '922222222', MobilePhone = '922222222', Email = 'unique@email.com', Financial_Assessment_Contact__c = false);
        Contact c3 = new Contact(AccountId = acc1.id, Firstname = 'DontDelete', Lastname='notDelete', Phone = '933333333', MobilePhone = '933333333', Email = 'unique123@email.com', Financial_Assessment_Contact__c = false);
        
        List<Contact> listOfContacts = new List<Contact>();
        listOfContacts.add(c1);
        listOfContacts.add(c2);
        listOfContacts.add(c3);
        insert listOfContacts;
        
        AMS_Person__c p1 = new AMS_Person__c(Name='test1', LastName__c='LastName', First_Name__c='FirstNameNotToUse', Email__c='unique@email.com');
        insert p1;
        AMS_Person__c p2 = new AMS_Person__c(Name='do', LastName__c='notDelete', First_Name__c='DontDelete', Email__c='unique123@email.com');
        insert p2;
        // DT: Employee no more saved as role
        /*
        AMS_Account_Role__c e1 = new AMS_Account_Role__c(recordTypeId = accountRoleRT.get('Employee'), Account__c = acc1.id, Person__c = p1.id, Contact__c = null);
        insert e1;
        AMS_Account_Role__c e2 = new AMS_Account_Role__c(recordTypeId = accountRoleRT.get('Employee'), Account__c = acc1.id, Person__c = p2.id, Contact__c = null);
        insert e2;
        */
    }
    
    @isTest static void test_RunAccountOwnershipInsertthenUpdate_ExpectUpdatedAccountRole()
    {
        List<Contact> conList = [select Id, Email, AccountId from Contact];
        // One created by test setup, two by AMS_AccountRoleTrigger
        System.assertEquals(3, conList.size());
        String accId = conList.get(0).AccountId;
        delete conList;
        
        Contact newCon = new Contact(AccountId = accId, Firstname = 'c1ObsoleteName', Lastname='c1LastName', Phone = '911111111', MobilePhone = '911111111', Email = 'unique@email.com', Financial_Assessment_Contact__c = false);
        insert newCon;
        System.debug('******************** newCon: '+newCon.AccountId);
        
        List<AMS_Account_Role__c> roleList = [select id from AMS_Account_Role__c];
        delete roleList;
                
        Account ownerAccount = new Account(Name='OwnerAccount', Location_Type__c = 'HO', Type='CASS Associate', Sector__c = 'Travel Agent', IATAcode__c = '0004141234', AIMS_ID__c = '98765431', Source_System__c = 'AIMS2');
        insert ownerAccount;
        
        List<AMS_Accreditation_Contact__c> acList = [select Id, Contact__c, Person_AMS__c, AMS_Employee_Role__c, AMS_Ownership_Role__c, AMS_Pax_Accreditation_Form__c from AMS_Accreditation_Contact__c];
        acList.get(0).Contact__c = newCon.Id;
        acList.get(0).Person_AMS__c = null;

        // Create an Accreditation Contact record of type Account Ownership and expect a relevant account role to be created
        // Later expect updated values on AC record to match the role record
        AMS_Accreditation_Contact__c companyOwnershipAC = new AMS_Accreditation_Contact__c(AMS_Pax_Accreditation_Form__c = acList.get(0).AMS_Pax_Accreditation_Form__c, Agency_Owner__c = true, Financial_interest__c = 20, Company__c = ownerAccount.id, RecordTypeId=AMS_Utils.getId('AMS_Accreditation_Contact__c', 'Company'), Last_name__c = 'test', Phone__c = '23432434');
        acList.add(companyOwnershipAC);
        upsert acList;
        
        Test.startTest();
        List<AMS_Pax_Accreditation_Form__c> aoaList = [select id from AMS_Pax_Accreditation_Form__c limit 1];
        AMS_AccountRoleCreator.runRoleCreatorForOnlineAccreditations(aoaList);
        
        roleList = [select Contact__c, Percentage__c, Contact__r.Email, Person__c, Person__r.Email__c, Account__c, RecordType.DeveloperName, RecordTypeId from AMS_Account_Role__c order by RecordTypeId];
        // DT: Employee no more saved as role
        //System.assertEquals(2, roleList.size());
        //System.assertEquals('Employee', roleList.get(0).RecordType.DeveloperName);
        //System.assertEquals('Ownership', roleList.get(1).RecordType.DeveloperName);
        //System.assertEquals(20, roleList.get(1).Percentage__c);
        
        System.assertEquals(1, roleList.size());
        System.assertEquals('Ownership', roleList.get(0).RecordType.DeveloperName);
        System.assertEquals(20, roleList.get(0).Percentage__c);
        
        companyOwnershipAC.Financial_Interest__c = 100;
        update companyOwnershipAC;
        
        
        AMS_AccountRoleCreator.runRoleCreatorForOnlineAccreditations(aoaList);
        roleList = [select Percentage__c, Account__c, RecordType.DeveloperName, RecordTypeId from AMS_Account_Role__c order by RecordTypeId];
        /* DT: Employee no more saved as role
        System.assertEquals(2, roleList.size());
        System.assertEquals('Ownership', roleList.get(1).RecordType.DeveloperName);
        System.assertEquals(100, roleList.get(1).Percentage__c);
        */
        System.assertEquals(1, roleList.size());
        System.assertEquals('Ownership', roleList.get(0).RecordType.DeveloperName);
        System.assertEquals(100, roleList.get(0).Percentage__c);
        Test.stopTest();
    }
    
    @isTest static void test_RunAccountOwnershipInsertthenUpdateAndAnotherInsert()
    {
        List<Contact> conList = [select Id, Email, AccountId from Contact];
        // One created by test setup, two by AMS_AccountRoleTrigger
        System.assertEquals(3, conList.size());
        String accId = conList.get(0).AccountId;
        delete conList;
        
        Contact newCon = new Contact(AccountId = accId, Firstname = 'c1ObsoleteName', Lastname='c1LastName', Phone = '911111111', MobilePhone = '911111111', Email = 'unique@email.com', Financial_Assessment_Contact__c = false);
        insert newCon;
        System.debug('******************** newCon: '+newCon.AccountId);
        
        List<AMS_Account_Role__c> roleList = [select id from AMS_Account_Role__c];
        delete roleList;

        Account ownerAccount = new Account(Name='OwnerAccount', Location_Type__c = 'HO', Type='CASS Associate', Sector__c = 'Travel Agent', IATAcode__c = '0004141234', AIMS_ID__c = '98765431', Source_System__c = 'AIMS2');
        Account ownerAccount2 = new Account(Name='OwnerAccount2', Location_Type__c = 'HO', Type='CASS Associate', Sector__c = 'Travel Agent', IATAcode__c = '0004141231', AIMS_ID__c = '0001', Source_System__c = 'AIMS2');
        List<Account> ownerAccounts = new List<Account>{ownerAccount, ownerAccount2};
        insert ownerAccounts;
        
        List<AMS_Accreditation_Contact__c> acList = [select Id, Contact__c, Person_AMS__c, AMS_Employee_Role__c, AMS_Ownership_Role__c, AMS_Pax_Accreditation_Form__c from AMS_Accreditation_Contact__c];
        acList.get(0).Contact__c = newCon.Id;
        acList.get(0).Person_AMS__c = null;

        // Create an Accreditation Contact record of type Account Ownership and expect a relevant account role to be created
        // Later expect updated values on AC record to match the role record
        AMS_Accreditation_Contact__c companyOwnershipAC = new AMS_Accreditation_Contact__c(AMS_Pax_Accreditation_Form__c = acList.get(0).AMS_Pax_Accreditation_Form__c, Agency_Owner__c = true, Financial_interest__c = 20, Company__c = ownerAccount.id, RecordTypeId=AMS_Utils.getId('AMS_Accreditation_Contact__c', 'Company'), Last_name__c = 'test', Phone__c = '23432434');
        acList.add(companyOwnershipAC);
        upsert acList;
        
        Test.startTest();
        List<AMS_Pax_Accreditation_Form__c> aoaList = [select id from AMS_Pax_Accreditation_Form__c limit 1];
        AMS_AccountRoleCreator.runRoleCreatorForOnlineAccreditations(aoaList);
        
        roleList = [select Contact__c, Percentage__c, Contact__r.Email, Person__c, Person__r.Email__c, Account__c, RecordType.DeveloperName, RecordTypeId from AMS_Account_Role__c order by RecordTypeId];
        // DT: Employee no more saved as role
        /*
        System.assertEquals(2, roleList.size());
        System.assertEquals('Employee', roleList.get(0).RecordType.DeveloperName);
        System.assertEquals('Ownership', roleList.get(1).RecordType.DeveloperName);
        System.assertEquals(20, roleList.get(1).Percentage__c);
        */
        System.assertEquals(1, roleList.size());
        System.assertEquals('Ownership', roleList.get(0).RecordType.DeveloperName);
        System.assertEquals(20, roleList.get(0).Percentage__c);
        
        companyOwnershipAC.Financial_Interest__c = 40;
        update companyOwnershipAC;
        
        AMS_Accreditation_Contact__c companyOwnershipAC2 = new AMS_Accreditation_Contact__c(AMS_Pax_Accreditation_Form__c = acList.get(0).AMS_Pax_Accreditation_Form__c, Agency_Owner__c = true, Financial_interest__c = 60, Company__c = ownerAccount2.id, RecordTypeId=AMS_Utils.getId('AMS_Accreditation_Contact__c', 'Company'), Last_name__c = 'test2', Phone__c = '012345678');
        acList.add(companyOwnershipAC2);
        upsert acList;
        
        
        AMS_AccountRoleCreator.runRoleCreatorForOnlineAccreditations(aoaList);
        roleList = [select Percentage__c, Account__c, RecordType.DeveloperName, Owner_Account__c, Owner_Account__r.Name, RecordTypeId from AMS_Account_Role__c order by RecordTypeId, Owner_Account__r.Name];
        /* DT: Employee no more saved as role
        System.assertEquals(3, roleList.size());
        System.assertEquals('Ownership', roleList.get(1).RecordType.DeveloperName);
        System.assertEquals(40, roleList.get(1).Percentage__c);
        System.assertEquals('Ownership', roleList.get(2).RecordType.DeveloperName);
        System.assertEquals(60, roleList.get(2).Percentage__c);
        System.assertEquals(ownerAccount2.Id, roleList.get(2).Owner_Account__c);
        System.assertEquals('OwnerAccount2', roleList.get(2).Owner_Account__r.Name);
        */
        System.assertEquals(2, roleList.size());
        System.assertEquals('Ownership', roleList.get(0).RecordType.DeveloperName);
        System.assertEquals(40, roleList.get(0).Percentage__c);
        System.assertEquals('Ownership', roleList.get(1).RecordType.DeveloperName);
        System.assertEquals(60, roleList.get(1).Percentage__c);
        System.assertEquals(ownerAccount2.Id, roleList.get(1).Owner_Account__c);
        System.assertEquals('OwnerAccount2', roleList.get(1).Owner_Account__r.Name);
        Test.stopTest();
    }
    
    @isTest static void test_ContactEmailChangesBeforeRoleCreation()
    {
        List<Contact> conList = [select Id, Email from Contact];
        // One created by test setup, two by AMS_AccountRoleTrigger ()
        // DT: Employee no more saved as role. All of them, are created in the test setup
        System.assertEquals(3, conList.size());
        List<AMS_Accreditation_Contact__c> acList = [select Id, Contact__c, Person_AMS__c from AMS_Accreditation_Contact__c];
        acList.get(0).Contact__c = conList.get(1).Id;
        acList.get(0).Person_AMS__c = null;
        update acList;
        
        Contact con = conList.get(1);
        con.Email = 'newEmail@changed.com';
        update con;
        
        List<AMS_Account_Role__c> roleList = [select Contact__c, Contact__r.Email, Person__c, Account__c from AMS_Account_Role__c];
        system.debug('DUTLLO 215 --> ' + rolelist.size() + ';' + roleList);
        // DT: Employee no more saved as role
        //System.assertEquals(2, roleList.size());
        //roleList.get(0).Contact__c = conList.get(1).Id;
        //update roleList;
        System.assertEquals(0, roleList.size());
        
        Test.startTest();
        List<AMS_Pax_Accreditation_Form__c> aoaList = [select id from AMS_Pax_Accreditation_Form__c limit 1];
        AMS_AccountRoleCreator.runRoleCreatorForOnlineAccreditations(aoaList);
        
        roleList = [select Contact__c, Contact__r.Email, Termination_Date__c, Person__c, Person__r.Email__c, Account__c from AMS_Account_Role__c];
        
        // DT: Employee no more saved as role
        //System.assertEquals(3, roleList.size());
        System.assertEquals(0, roleList.size());
        
        List<AMS_Person__c> personList = [select id from AMS_Person__c];
        System.assertEquals(2, personList.size());
        
        Test.stopTest();
    }
    
    @isTest static void test_PersonsContactLinked_RoleWithContactLinkingCreated()
    {
        List<AMS_Account_Role__c> forDeletion = [select id from AMS_Account_Role__c];
        delete forDeletion;
        List<AMS_AccreditationContactController.AccreditationContactWrapper> wrapperList = new List<AMS_AccreditationContactController.AccreditationContactWrapper>();
        List<AMS_Account_Role__c> roleList = [select id from AMS_Account_Role__c];
        delete roleList;
        //Id employeeRtId = AMS_Utils.getId('AMS_Account_Role__c', 'Employee');
        
        Contact c = [select id, AccountId from Contact where email = 'unique@email.com' limit 1];
        List<AMS_Accreditation_Contact__c> acListToUpdate = [select email__c, Agency_owner__c, AMS_Pax_Accreditation_Form__r.SAAM_Case__r.OSCAR__r.Account__c, Agency_role__c, First_Name__c, Last_Name__c, contact__c from AMS_Accreditation_Contact__c];
        for(AMS_Accreditation_Contact__c ac : acListToUpdate)
        {
            ac.Contact__c = c.Id;
            ac.Company__c = c.AccountId;
            ac.Agency_role__c = true;
            ac.Agency_owner__c = true;
            ac.AMS_Pax_Accreditation_Form__r.SAAM_Case__r.OSCAR__r.Account__c = c.AccountId;
            AMS_AccreditationContactController.AccreditationContactWrapper wrapped = new AMS_AccreditationContactController.AccreditationContactWrapper(ac);
            wrapped.recordId = c.Id;
            wrapperList.add(wrapped);
        }
        update acListToUpdate;
        
        Test.startTest();
        
        AMS_AccreditationContactHelper.insertAmsRolesForAccreditationContacts(wrapperList);
        roleList = [select Employee_Name__c, IsManager__c, RecordType.DeveloperName, Contact__c from AMS_Account_Role__c];
        AMS_Account_Role__c role = roleList.get(0);
        System.assertEquals('NameToUse Last', role.Employee_Name__c);
        System.assertEquals(true, role.IsManager__c);
        System.assertEquals('Ownership', role.RecordType.DeveloperName);
        System.assertEquals(role.Contact__c, c.Id);
        Test.stopTest();
    }
    

    @isTest static void test_CreateAOCandACs_runProcessThriceForPerson()
    {
        List<Contact> conList = [select Id, Email, AccountId from Contact];
        // One created by test setup, two by AMS_AccountRoleTrigger
        System.assertEquals(3, conList.size());
        String accId = conList.get(0).AccountId;
        delete conList;
        
        List<AMS_Person__c> personList = [select Id from AMS_Person__c];
        delete personList;
        
        AMS_Person__c newPerson = new AMS_Person__c(First_name__c = 'c1ObsoleteName', Lastname__c='c1LastName', Phone__c = '911111111', Mobile__c = '911111111', Email__c = 'unique@email.com');
        insert newPerson;
        
        List<AMS_Account_Role__c> roleList = [select id from AMS_Account_Role__c];
        delete roleList;
        
        List<AMS_Accreditation_Contact__c> acList = [select Id, Contact__c, Person_AMS__c, AMS_Employee_Role__c, AMS_Ownership_Role__c from AMS_Accreditation_Contact__c];
        acList.get(0).Contact__c = null;
        acList.get(0).Person_AMS__c = newPerson.Id;
        update acList;
        
        
        Test.startTest();
        List<AMS_Pax_Accreditation_Form__c> aoaList = [select id from AMS_Pax_Accreditation_Form__c limit 1];
        AMS_AccountRoleCreator.runRoleCreatorForOnlineAccreditations(aoaList);
        
        roleList = [select Contact__c, Contact__r.Email, Person__c, Person__r.Email__c, Account__c, RecordType.DeveloperName from AMS_Account_Role__c];
        System.assertEquals(1, roleList.size());
        //DT: Employee are no more created in the Role Object
        //System.assertEquals('Employee', roleList.get(0).RecordType.DeveloperName);
        acList.get(0).Agency_Owner__c = true;
        update acList;
        
        AMS_AccountRoleCreator.runRoleCreatorForOnlineAccreditations(aoaList);
        roleList = [select Contact__c, Contact__r.Email, Person__c, Person__r.Email__c, Account__c, RecordType.DeveloperName from AMS_Account_Role__c];
        System.assertEquals(2, roleList.size());
        //System.assertEquals('Ownership', roleList.get(0).RecordType.DeveloperName);
    
    
        AMS_Accreditation_Contact__c newAc = new AMS_Accreditation_Contact__c(AMS_Pax_Accreditation_Form__c = aoaList.get(0).Id, Company__c = accId, First_name__c='NameToUse', Last_name__c='Last', Job_title__c='ABC', Mobile__c='+4112345678', Phone__c='3424322343', Email__c='unique@email2.com', Person_AMS__c = newPerson.Id, RecordTypeId=AMS_Utils.getId('AMS_Accreditation_Contact__c', 'Person'));
        insert newAc;
        
        AMS_AccountRoleCreator.runRoleCreatorForOnlineAccreditations(aoaList);
        roleList = [select Contact__c, Contact__r.Email, Person__c, Person__r.Email__c, Account__c, RecordType.DeveloperName from AMS_Account_Role__c];
        System.assertEquals(3, roleList.size());
        Test.stopTest();
    }
    
    @isTest static void test_CreateAOCandACs_runProcessThriceForNoLinking()
    {
        List<Contact> conList = [select Id, Email, AccountId from Contact];
        // One created by test setup, two by AMS_AccountRoleTrigger
        System.assertEquals(3, conList.size());
        String accId = conList.get(0).AccountId;
        //delete conList;
        
        List<AMS_Person__c> personList = [select Id from AMS_Person__c];
        delete personList;
        
        AMS_Person__c newPerson = new AMS_Person__c(First_name__c = 'c1ObsoleteName', Lastname__c='c1LastName', Phone__c = '911111111', Mobile__c = '911111111', Email__c = 'unique@email.com');
        insert newPerson;
        
        List<AMS_Account_Role__c> roleList = [select id from AMS_Account_Role__c];
        delete roleList;
        
        List<AMS_Accreditation_Contact__c> acList = [select Id, Contact__c, Person_AMS__c, AMS_Employee_Role__c, AMS_Ownership_Role__c from AMS_Accreditation_Contact__c];
        acList.get(0).Contact__c = null;
        acList.get(0).Person_AMS__c = null;
        update acList;
        
        
        Test.startTest();
        List<AMS_Pax_Accreditation_Form__c> aoaList = [select id from AMS_Pax_Accreditation_Form__c limit 1];
        AMS_AccountRoleCreator.runRoleCreatorForOnlineAccreditations(aoaList);
        
        roleList = [select Contact__c, Contact__r.Email, Person__c, Person__r.Email__c, Account__c, RecordType.DeveloperName from AMS_Account_Role__c];
        //DT: Employee are no more created in the Role Object
        //System.assertEquals(1, roleList.size());
        //System.assertEquals('Employee', roleList.get(0).RecordType.DeveloperName);
        System.assertEquals(0, roleList.size());
        acList.get(0).Agency_Owner__c = true;
        update acList;
        
        AMS_AccountRoleCreator.runRoleCreatorForOnlineAccreditations(aoaList);
        roleList = [select Contact__c, Contact__r.Email, Person__c, Person__r.Email__c, Account__c, RecordType.DeveloperName from AMS_Account_Role__c];
        System.assertEquals(1, roleList.size());
        System.assertEquals('Ownership', roleList.get(0).RecordType.DeveloperName);
    
    
        AMS_Accreditation_Contact__c newAc = new AMS_Accreditation_Contact__c(AMS_Pax_Accreditation_Form__c = aoaList.get(0).Id, Company__c = accId, First_name__c='NameToUse', Last_name__c='Last', Job_title__c='ABC', Mobile__c='+4112345678', Phone__c='3424322343', Email__c='unique@email.com', Person_AMS__c = newPerson.Id, RecordTypeId=AMS_Utils.getId('AMS_Accreditation_Contact__c', 'Person'));
        insert newAc;
        
        AMS_AccountRoleCreator.runRoleCreatorForOnlineAccreditations(aoaList);
        roleList = [select Contact__c, Contact__r.Email, Person__c, Person__r.Email__c, Account__c, RecordType.DeveloperName from AMS_Account_Role__c];
        //DT: Employee are no more created in the Role Object
        //System.assertEquals(2, roleList.size());
        System.assertEquals(2, roleList.size());
        Test.stopTest();
    }
    
    @isTest static void test_CreateAOCandACs_runWholeProcessForNoLinking()
    {
        List<AMS_Accreditation_Contact__c> acList = [select Id, Contact__c, Person_AMS__c, Company__c from AMS_Accreditation_Contact__c];
        acList.get(0).Contact__c = null;
        acList.get(0).Person_AMS__c = null;
        //acList.get(0).Company__c = null;
        update acList;
        
        List<AMS_Account_Role__c> roleList = [select Contact__c, Contact__r.Email, Person__c, Account__c from AMS_Account_Role__c];
        delete roleList;
        
        Test.startTest();
        List<AMS_Pax_Accreditation_Form__c> aoaList = [select id from AMS_Pax_Accreditation_Form__c limit 1];
        AMS_AccountRoleCreator.runRoleCreatorForOnlineAccreditations(aoaList);
        
        roleList = [select Contact__c, Contact__r.Email, Contact__r.FirstName, Person__c, Person__r.Email__c, Account__c from AMS_Account_Role__c];
        //DT: Employee are no more created in the Role Object
        /*System.assertEquals(1, roleList.size());
        System.assertEquals('NameToUse', roleList.get(0).Contact__r.FirstName);
        System.assertEquals('unique@email.com', roleList.get(0).Contact__r.Email);
        
        List<AMS_Accreditation_Contact__c> updatedAcList = [select id, AMS_Ownership_Role__c, AMS_Employee_Role__c from AMS_Accreditation_Contact__c];
        for(AMS_Accreditation_Contact__c ac : updatedAcList)
        {
            System.assertEquals(ac.AMS_Employee_Role__c, roleList.get(0).Id);
        }*/
        System.assertEquals(0, roleList.size());
        Test.stopTest();
    }
    
    @isTest static void test_CreateAOCandACs_runProcessThriceForContact()
    {
        List<Contact> conList = [select Id, Email, AccountId from Contact];
        // One created by test setup, two by AMS_AccountRoleTrigger
        System.assertEquals(3, conList.size());
        String accId = conList.get(0).AccountId;
        delete conList;
        
        Contact newCon = new Contact(AccountId = accId, Firstname = 'c1ObsoleteName', Lastname='c1LastName', Phone = '911111111', MobilePhone = '911111111', Email = 'unique@email.com', Financial_Assessment_Contact__c = false);
        insert newCon;
        
        List<AMS_Account_Role__c> roleList = [select id from AMS_Account_Role__c];
        delete roleList;
        
        List<AMS_Accreditation_Contact__c> acList = [select Id, Contact__c, Person_AMS__c, AMS_Employee_Role__c, AMS_Ownership_Role__c from AMS_Accreditation_Contact__c];
        acList.get(0).Contact__c = newCon.Id;
        acList.get(0).Person_AMS__c = null;
        update acList;
        
        
        Test.startTest();
        List<AMS_Pax_Accreditation_Form__c> aoaList = [select id from AMS_Pax_Accreditation_Form__c limit 1];
        AMS_AccountRoleCreator.runRoleCreatorForOnlineAccreditations(aoaList);
        
        roleList = [select Contact__c, Contact__r.Email, Person__c, Person__r.Email__c, Account__c, RecordType.DeveloperName from AMS_Account_Role__c];
        //DT: Employee are no more created in the Role Object
        //System.assertEquals(1, roleList.size());
        //System.assertEquals('Employee', roleList.get(0).RecordType.DeveloperName);
        System.assertEquals(0, roleList.size());
        acList.get(0).Agency_Owner__c = true;
        update acList;
        
        AMS_AccountRoleCreator.runRoleCreatorForOnlineAccreditations(aoaList);
        roleList = [select Contact__c, Contact__r.Email, Person__c, Person__r.Email__c, Account__c, RecordType.DeveloperName from AMS_Account_Role__c];
        System.assertEquals(1, roleList.size());
        System.assertEquals('Ownership', roleList.get(0).RecordType.DeveloperName);
    
        AMS_Accreditation_Contact__c newAc = new AMS_Accreditation_Contact__c(AMS_Pax_Accreditation_Form__c = aoaList.get(0).Id, Company__c = accId, First_name__c='NameToUse', Last_name__c='Last', Job_title__c='ABC', Mobile__c='+4112345678', Phone__c='3424322343', Email__c='unique@email.com', Contact__c = newCon.Id, RecordTypeId=AMS_Utils.getId('AMS_Accreditation_Contact__c', 'Person'));
        insert newAc;
        
        AMS_AccountRoleCreator.runRoleCreatorForOnlineAccreditations(aoaList);
        roleList = [select Contact__c, Contact__r.Email, Person__c, Person__r.Email__c, Account__c, RecordType.DeveloperName from AMS_Account_Role__c];
        //DT: Employee are no more created in the Role Object
        //System.assertEquals(2, roleList.size());
        System.assertEquals(1, roleList.size());
        Test.stopTest();
    }
    
    @isTest static void test_CreateAOCandACs_runWholeProcessForContactOnly()
    {
        List<Contact> conList = [select Id, Email from Contact];
        // One created by test setup, two by AMS_AccountRoleTrigger ()
        System.assertEquals(3, conList.size());
        List<AMS_Accreditation_Contact__c> acList = [select Id, Contact__c, Company__c, Person_AMS__c from AMS_Accreditation_Contact__c];
        acList.get(0).Contact__c = conList.get(1).Id;
        acList.get(0).Person_AMS__c = null;
        update acList;
        
        List<AMS_Account_Role__c> roleList = [select Contact__c, Contact__r.Email, Person__c, Person__r.Email__c, Account__c from AMS_Account_Role__c];
        //DT: Employee are no more created in the Role Object
        //System.assertEquals(2, roleList.size());
        //roleList.get(0).Contact__c = conList.get(1).Id;
        //update roleList;
        System.assertEquals(0, roleList.size());
        
        Test.startTest();
        List<AMS_Pax_Accreditation_Form__c> aoaList = [select id from AMS_Pax_Accreditation_Form__c limit 1];
        AMS_OSCAR__c oscar = [select AMS_Online_Accreditation__c from AMS_OSCAR__c limit 1];
        oscar.AMS_Online_Accreditation__c = aoaList.get(0).Id;
        update oscar;
        
        AMS_AccountRoleCreator.runRoleCreatorForOnlineAccreditations(aoaList);
        
        roleList = [select Contact__c, Contact__r.Email, Termination_Date__c, Person__c, Person__r.Email__c, Account__c from AMS_Account_Role__c];
        
        //DT: Employee are no more created in the Role Object
        //System.assertEquals(3, roleList.size());
        System.assertEquals(0, roleList.size());
        
        for(AMS_Account_Role__c role : roleList)
        {
            // Old role gets set to "Terminated today" status
            if(role.Termination_Date__c != System.today())
            {
                if(role.Contact__r.Email == 'unique@email.com')
                {
                    System.assertEquals(null, role.Person__c);
                    System.assertEquals('unique@email.com', role.Contact__r.Email);
                }
            } else
            {
                System.assert(role.Person__c != null);
            }
        }
        
        List<AMS_Person__c> personList = [select id from AMS_Person__c];
        System.assertEquals(2, personList.size());
        
        Test.stopTest();
    }
    
    
    //DT: Employee are no more created in the Role Object
    @isTest static void test_PersonNotFound_ContactFound_updateContactWithACdata()
    {
        List<AMS_Account_Role__c> roleList = [select id from AMS_Account_Role__c];
        delete roleList;
        //DT: Employee are no more created in the Role Object. Using Owner instead
        //Id employeeRtId = AMS_Utils.getId('AMS_Account_Role__c', 'Employee');
        Id ownerRtId = AMS_Utils.getId('AMS_Account_Role__c', 'Ownership');
        
        Contact c = [select id, AccountId from Contact where email = 'unique@email.com' limit 1];
        //AMS_Account_Role__c e1 = new AMS_Account_Role__c(recordTypeId = employeeRtId, Account__c = c.AccountId, Person__c = null, Contact__c = c.Id);
        AMS_Account_Role__c e1 = new AMS_Account_Role__c(recordTypeId = ownerRtId, Account__c = c.AccountId, Person__c = null, Contact__c = c.Id, Percentage__c=100.0);
        insert e1;
        List<AMS_Accreditation_Contact__c> acListToUpdate = [select email__c, contact__c from AMS_Accreditation_Contact__c];
        for(AMS_Accreditation_Contact__c ac : acListToUpdate)
        {
            ac.Contact__c = c.Id;
        }
        update acListToUpdate;
        
        
        Test.startTest();
        // change the name and update. AC processing later should rename this back to "NameToUse"
        c.FirstName = 'ChangedName';
        update c;
        c = [select id, FirstName from Contact where email = 'unique@email.com' limit 1];
        System.assertEquals(c.FirstName, 'ChangedName') ;
        
        String commaSeparatedFields = AMS_AccreditationContactHelper.loadFieldsDynamically('AMS_Accreditation_Contact__c');
        String query = 'select ' + commaSeparatedFields + ', AMS_Pax_Accreditation_Form__r.SAAM_Case__r.OSCAR__r.Account__c ';
        query = query + ' from AMS_Accreditation_Contact__c where Email__c = \'unique@email.com\'';
        List<AMS_Accreditation_Contact__c> aoContactList = Database.query(query);
        system.debug('DTULLO 523 --> ' + aoContactList.size());
        // Run the code, expecting to see the Contact record getting updated back to "NameToUse"
        Map<String, AMS_Account_Role__c> roleContactMap = AMS_AccountRoleCreator.findRoleAndContactRecords(aoContactList);
        system.debug('DTULLO 526 --> ' + roleContactMap.size());
        List<Contact> newContacts = AMS_AccountRoleCreator.transformACsWithContactLinkingToUpdatedList(aoContactList, roleContactMap);
        update newContacts;
        List<AMS_Account_Role__c> updatedRoles = AMS_AccountRoleCreator.retrieveContactAgencyLinking_updateIfNecessary(newContacts, roleContactMap);

        
        c = [select id, FirstName from Contact where email = 'unique@email.com' limit 1];
        System.assertEquals(c.FirstName, 'NameToUse');
        Test.stopTest();
    }
    
    
    //DT: Employee are no more created in the Role Object
    @isTest static void test_ContactLinked_RoleCreated()
    {
        List<AMS_Account_Role__c> roleList = [select id from AMS_Account_Role__c];
        delete roleList;
        //DT: Employee are no more created in the Role Object. Using Owner instead
        Id employeeRtId = AMS_Utils.getId('AMS_Account_Role__c', 'Ownership');
        
        Contact c = [select id, AccountId from Contact where email = 'unique@email.com' limit 1];
        AMS_Account_Role__c e1 = new AMS_Account_Role__c(recordTypeId = employeeRtId, Account__c = c.AccountId, Person__c = null, Contact__c = c.Id);
        insert e1;
        List<AMS_Accreditation_Contact__c> acListToUpdate = [select email__c, contact__c from AMS_Accreditation_Contact__c];
        for(AMS_Accreditation_Contact__c ac : acListToUpdate)
        {
            ac.Contact__c = c.Id;
        }
        update acListToUpdate;
        
        
        Test.startTest();
        // change the name and update. AC processing later should rename this back to "NameToUse"
        c.FirstName = 'ChangedName';
        update c;
        c = [select id, FirstName from Contact where email = 'unique@email.com' limit 1];
        System.assertEquals(c.FirstName, 'ChangedName') ;
        
        String commaSeparatedFields = AMS_AccreditationContactHelper.loadFieldsDynamically('AMS_Accreditation_Contact__c');
        String query = 'select ' + commaSeparatedFields + ', AMS_Pax_Accreditation_Form__r.SAAM_Case__r.OSCAR__r.Account__c ';
        query = query + ' from AMS_Accreditation_Contact__c where Email__c = \'unique@email.com\'';
        List<AMS_Accreditation_Contact__c> aoContactList = Database.query(query);
        
        // Run the code, expecting to see the Contact record getting updated back to "NameToUse"
        system.debug('DTULLO 587 -->' + aoContactList.size() + '; ' + aoContactList);
        Map<String, AMS_Account_Role__c> roleContactMap = AMS_AccountRoleCreator.findRoleAndContactRecords(aoContactList);
        system.debug('DTULLO 588 -->' + roleCOntactMap.size());
        List<Contact> newContacts = AMS_AccountRoleCreator.transformACsWithContactLinkingToUpdatedList(aoContactList, roleContactMap);
        update newContacts;
        List<AMS_Account_Role__c> updatedRoles = AMS_AccountRoleCreator.retrieveContactAgencyLinking_updateIfNecessary(newContacts, roleContactMap);

        
        c = [select id, FirstName from Contact where email = 'unique@email.com' limit 1];
        System.assertEquals(c.FirstName, 'NameToUse');
        Test.stopTest();
    }
    
    @isTest static void test_PersonsContactNotLinked_RoleWithContactLinkingCreated()
    {
        List<AMS_Account_Role__c> forDeletion = [select id from AMS_Account_Role__c];
        delete forDeletion;
        List<AMS_AccreditationContactController.AccreditationContactWrapper> wrapperList = new List<AMS_AccreditationContactController.AccreditationContactWrapper>();
        List<AMS_Account_Role__c> roleList = [select id from AMS_Account_Role__c];
        delete roleList;
        //DT: Employee are no more created in the Role Object
        //Id employeeRtId = AMS_Utils.getId('AMS_Account_Role__c', 'Employee');
        
        Contact c = [select id, AccountId from Contact where email = 'unique@email.com' limit 1];
        system.debug('Contact: ' + c);
        List<AMS_Accreditation_Contact__c> acListToUpdate = [select email__c, Person_AMS__c, AMS_Pax_Accreditation_Form__r.SAAM_Case__r.OSCAR__r.Account__c, Agency_owner__c, Agency_role__c, First_Name__c, Last_Name__c, contact__c from AMS_Accreditation_Contact__c];
        for(AMS_Accreditation_Contact__c ac : acListToUpdate)
        {
            ac.Contact__c = c.ID;
            //ac.Person_AMS__c = null;
            ac.Person_AMS__c = null;
            ac.Company__c = c.AccountId;
            ac.Agency_role__c = true;
            ac.Agency_owner__c = true;
            ac.Last_name__c = 'LastNameForTest';
            //ac.RecordTypeId = AMS_Utils.AccreditationContactCompanyRT;
            ac.AMS_Pax_Accreditation_Form__r.SAAM_Case__r.OSCAR__r.Account__c = c.AccountId;
            AMS_AccreditationContactController.AccreditationContactWrapper wrapped = new AMS_AccreditationContactController.AccreditationContactWrapper(ac);
            wrapped.recordId = c.Id;
            wrapperList.add(wrapped);
        }
        update acListToUpdate;
        
        Test.startTest();
        system.debug('wrapperList: ' + wrapperList);
        AMS_AccreditationContactHelper.insertAmsRolesForAccreditationContacts(wrapperList);
        
        roleList = [select Employee_Name__c, IsManager__c, RecordType.DeveloperName, Contact__c from AMS_Account_Role__c];
        AMS_Account_Role__c role = roleList.get(0);
        System.assert(role.Id != null);
        Test.stopTest();
    }
    
    
    @isTest static void test_CreateAOCandACs_runWholeProcessForPersonOnly()
    {
        List<Contact> conList = [select id from Contact];
        delete conList;
        
        List<AMS_Person__c> personList = [select Id from AMS_Person__c];
        System.assertEquals(2, personList.size());
        List<AMS_Accreditation_Contact__c> acList = [select Id, Contact__c, Person_AMS__c, Financial_Assessment_Contact__c from AMS_Accreditation_Contact__c];
        acList.get(0).Person_AMS__c = personList.get(0).Id;
        acList.get(0).Financial_Assessment_Contact__c = true;
        update acList;
        
        List<AMS_Account_Role__c> roleList = [select Contact__c, Contact__r.Email, Person__r.Email__c, Person__c, Account__c from AMS_Account_Role__c];
        
        Test.startTest();
        List<AMS_Pax_Accreditation_Form__c> aoaList = [select id from AMS_Pax_Accreditation_Form__c limit 1];
        AMS_AccountRoleCreator.runRoleCreatorForOnlineAccreditations(aoaList);
        
        roleList = [select Contact__c, Contact__r.Email, Person__c, Financial_Assessment_Contact__c, Termination_Date__c, Account__c from AMS_Account_Role__c];
        //DT: Employee are no more created in the Role Object
        //System.assertEquals(3, roleList.size());
        System.assertEquals(1, roleList.size());
        for(AMS_Account_Role__c role : roleList)
        {
            // Old role gets set to "Terminated today" status
            if(role.Termination_Date__c != System.today())
            {
                if(role.Contact__r.Email == 'unique@email.com')
                {
                    System.assertEquals(null, role.Person__c);
                    System.assertEquals('unique@email.com', role.Contact__r.Email);
                }
            } else
            {
                System.assert(role.Person__c != null);
            }
        }
        
        personList = [select Id from AMS_Person__c];
        System.assertEquals(2, personList.size());
        
        Test.stopTest();
    }
    
    
    @isTest static void test_BulkUpdateACsWithNoLinking()
    {
        List<AMS_Account_Role__c> roleList = [select id from AMS_Account_Role__c];
        delete roleList;
        //DT: Employee are no more created in the Role Object
        //Id employeeRtId = AMS_Utils.getId('AMS_Account_Role__c', 'Employee');
        
        Contact c = [select id, AccountId from Contact where email = 'unique@email.com' limit 1];
        //DT: Employee are no more created in the Role Object
        //AMS_Account_Role__c e1 = new AMS_Account_Role__c(recordTypeId = employeeRtId, Account__c = c.AccountId, Person__c = null, Contact__c = c.Id);
        //insert e1;
        
        IATA_ISO_Country__c isocountry = new IATA_ISO_Country__c(Name = '12314', ISO_Code__c = 'AG');       
        insert isocountry;
        
        List<Case> caseList = [select id from Case];
        
        List<AMS_Pax_Accreditation_Form__c> aoaList = new List<AMS_Pax_Accreditation_Form__c>();
        Map<Integer, AMS_Pax_Accreditation_Form__c> aoaMap = new Map<Integer, AMS_Pax_Accreditation_Form__c>();
        for(Integer i=0;i<170;i++)
        {
            AMS_Pax_Accreditation_Form__c onlineAccreditation = new AMS_Pax_Accreditation_Form__c(IsGSA__c = 'No', CurrencyIsoCode = isocountry.CurrencyIsoCode, SAAM_Case__c = caseList.get(0).Id);
            aoaMap.put(i, onlineAccreditation);
            aoaList.add(onlineAccreditation);
        }
        
        insert aoaMap.values();
        List<Contact> conList = [select Id from Contact];
        delete conList;
        List<AMS_Accreditation_Contact__c> acList = new List<AMS_Accreditation_Contact__c>();
        for(Integer i=0;i<170;i++)
        {
            acList.add(new AMS_Accreditation_Contact__c(AMS_Pax_Accreditation_Form__c = aoaMap.get(i).Id, Company__c = c.Accountid, First_name__c='NameToUse', Last_name__c='Last', Job_title__c='ABC', Mobile__c='+4112345678', Phone__c='3424322343', Email__c=i+'unique@email.com', RecordTypeId=AMS_Utils.getId('AMS_Accreditation_Contact__c', 'Person')));
        }
        
        insert acList;
        
        Test.startTest();
        
        AMS_AccountRoleCreator.runRoleCreatorForOnlineAccreditations(aoaList);
        conList = [select id from Contact];
        System.assertEquals(170, conList.size());
        Test.stopTest();
    }
    
    @isTest static void test_BulkUpdateACsWithContactLink()
    {
        List<AMS_Account_Role__c> roleList = [select id from AMS_Account_Role__c];
        delete roleList;
        //DT: Employee are no more created in the Role Object
        //Id employeeRtId = AMS_Utils.getId('AMS_Account_Role__c', 'Employee');
        
        Contact c = [select id, AccountId from Contact where email = 'unique@email.com' limit 1];
        
         //DT: Employee are no more created in the Role Object
        //AMS_Account_Role__c e1 = new AMS_Account_Role__c(recordTypeId = employeeRtId, Account__c = c.AccountId, Person__c = null, Contact__c = c.Id);
        //insert e1;
        
        IATA_ISO_Country__c isocountry = new IATA_ISO_Country__c(Name = '12314', ISO_Code__c = 'AG');       
        insert isocountry;
        
        List<Case> caseList = [select id from Case];
        
        List<AMS_Pax_Accreditation_Form__c> aoaList = new List<AMS_Pax_Accreditation_Form__c>();
        Map<Integer, AMS_Pax_Accreditation_Form__c> aoaMap = new Map<Integer, AMS_Pax_Accreditation_Form__c>();
        for(Integer i=0;i<170;i++)
        {
            AMS_Pax_Accreditation_Form__c onlineAccreditation = new AMS_Pax_Accreditation_Form__c(IsGSA__c = 'No', CurrencyIsoCode = isocountry.CurrencyIsoCode, SAAM_Case__c = caseList.get(0).Id);
            aoaMap.put(i, onlineAccreditation);
            aoaList.add(onlineAccreditation);
        }
        
        insert aoaMap.values();
        
        List<Contact> conList = new List<Contact>();
        for(Integer i=0;i<170;i++)
        {
            Contact c1 = new Contact(AccountId = c.AccountId, Firstname = 'c1ObsoleteName', Lastname='c1LastName', Phone = '911111111', MobilePhone = '911111111', Email = i+'test@test.com', Financial_Assessment_Contact__c = false);
            conList.add(c1);
        }
        insert conList;
        
        List<AMS_Accreditation_Contact__c> acList = new List<AMS_Accreditation_Contact__c>();
        for(Integer i=0;i<170;i++)
        {
            acList.add(new AMS_Accreditation_Contact__c(AMS_Pax_Accreditation_Form__c = aoaMap.get(i).Id, Contact__c = conList.get(i).Id, Company__c = c.Accountid, First_name__c='NameToUse', Last_name__c='Last', Job_title__c='ABC', Mobile__c='+4112345678', Phone__c='3424322343', Email__c=i+'test@test.com', RecordTypeId=AMS_Utils.getId('AMS_Accreditation_Contact__c', 'Person')));
        }
        
        insert acList;
        
        Test.startTest();
        
        AMS_AccountRoleCreator.runRoleCreatorForOnlineAccreditations(aoaList);
        acList = [select id from AMS_Accreditation_Contact__c];
        System.assertEquals(171, acList.size());
        Test.stopTest();
    }
    
    //DT: Seems that this method is no more used. Test on it anyway
    @isTest static void test_MethodfindRoleAndPersonRecords(){
        map<String, AMS_Account_Role__c> theMap = new map<String, AMS_Account_Role__c>();
        list<AMS_Accreditation_Contact__c> theList = [select Id, Person_AMS__c, Email__c, Contact__c from AMS_Accreditation_Contact__c];
        theMap = AMS_AccountRoleCreator.findRoleAndContactRecords(theList);
        
    }
    
    //DT: Seems that this method is no more used. Test on it anyway
    @isTest static void test_MethodtransformACsWithPersonLinking_createContactList(){
        List<Case> caseList = [select id from Case limit 2];
        
        AMS_Pax_Accreditation_Form__c onlineAccreditation = new AMS_Pax_Accreditation_Form__c(IsGSA__c = 'No', SAAM_Case__c = caseList.get(0).Id);
        
        insert onlineAccreditation;
        
        AMS_Accreditation_Contact__c accContact = new AMS_Accreditation_Contact__c(AMS_Pax_Accreditation_Form__c = onlineAccreditation.Id, First_name__c='NameToUse', Last_name__c='Last', Job_title__c='ABC', Mobile__c='+4112345678', Phone__c='3424322343', Email__c='ewrstdfgyhujntest@test.com', RecordTypeId=AMS_Utils.getId('AMS_Accreditation_Contact__c', 'Person'));
        
        insert accContact;

        list<AMS_Accreditation_Contact__c> lsAccCont = [select Id, Person_AMS__c, Email__c, Contact__c from AMS_Accreditation_Contact__c];
        list<Contact> lsContacts = AMS_AccountRoleCreator.transformACsWithPersonLinking_createContactList(lsAccCont, null); 
    }
    
}