@isTest
public with sharing class AMS_AccountRoleCreatorTest {
    
    @testSetup static void setup()
    {
        IATA_ISO_Country__c isoc = new IATA_ISO_Country__c(Name = 'Test', ISO_Code__c = 'TS');       
        insert isoc;

        Id accountRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');
        Account acc1 = new Account(RecordTypeId = accountRT, Status__c = 'Approved', Reason_for_creation__c = 'Headquarter is missing', Name='Test1 Account', Location_Type__c = 'HO', Type='CASS Associate', Sector__c = 'Travel Agent', IATA_ISO_Country__c = isoc.id, IATAcode__c = '12345678', AIMS_ID__c = '12345678', Source_System__c = 'AIMS2');
        Account HO1, HO2, BR1, BR2, BR3, BR4, BR5, BR6;
        boolean isPax = true;

        String SECTORPAX = 'Travel Agent';
        String CATEGORYPAX = 'IATA Passenger Sales Agent';
        String LOCCLASSPAX = 'P';
        
        String SECTORCASS = 'Cargo Agent';
        String CATEGORYCASS = 'IATA Cargo Sales Agent';
        String LOCCLASSCASS = 'C';
        
        //Create 2 head offices
        HO1 = new Account(RecordTypeId = accountRT, Name = 'My Travels', IATAcode__c = '1111110', IATA_ISO_Country__c = isoc.id, 
                         Sector__c = (isPax ? SECTORPAX : SECTORCASS), Category__c = (isPax ? CATEGORYPAX : CATEGORYCASS), 
                         Location_Class__c = (isPax ? LOCCLASSPAX : LOCCLASSCASS), Location_Type__c = 'HO', Status__c = AMS_Utils.ACC_S9_APPROVED,
                         Reason_for_creation__c = 'Created by customer', Reason__c = '91-ACCREDITED–MEETS–STANDARDS' );
        HO2 = new Account(RecordTypeId = accountRT, Name = 'Your Travels', IATAcode__c = '2222220', IATA_ISO_Country__c = isoc.id, 
                         Sector__c =  (isPax ? SECTORPAX : SECTORCASS), Category__c = (isPax ? CATEGORYPAX : CATEGORYCASS), 
                         Location_Class__c = (isPax ? LOCCLASSPAX : LOCCLASSCASS), Location_Type__c = 'HO', Status__c = AMS_Utils.ACC_S9_APPROVED,
                         Reason_for_creation__c = 'Created by customer', Reason__c = '91-ACCREDITED–MEETS–STANDARDS' );
        
        //Create a separate Account for the Owners
        Account OwnersAccount =  new Account(Name = 'General account for owners');

        Apex_Setting__c idAccountOwner = new Apex_Setting__c(Name = 'Stop Owner Alignment');
        idAccountOwner.Text_1__c = '005w000000688eeAAA';
        insert idAccountOwner;

        List<Account> accs = new List<Account>{acc1, HO1, HO2, OwnersAccount};
        insert accs;
        //Create the 6 branches
        BR1 = new Account(RecordTypeId = accountRT, Name = 'My Travels', IATAcode__c = '1111111', IATA_ISO_Country__c = isoc.id, 
                         Sector__c =  (isPax ? SECTORPAX : SECTORCASS), Category__c = (isPax ? CATEGORYPAX : CATEGORYCASS), Status__c = AMS_Utils.ACC_S9_APPROVED,  
                         Location_Class__c = (isPax ? LOCCLASSPAX : LOCCLASSCASS), Location_Type__c = 'BR', ParentId = HO1.Id,
                         Reason_for_creation__c = 'Created by customer', Reason__c = '91-ACCREDITED–MEETS–STANDARDS' );
        BR2 = new Account(RecordTypeId = accountRT, Name = 'My Travels', IATAcode__c = '1111112', IATA_ISO_Country__c = isoc.id, 
                         Sector__c =  (isPax ? SECTORPAX : SECTORCASS), Category__c = (isPax ? CATEGORYPAX : CATEGORYCASS), Status__c = AMS_Utils.ACC_S9_APPROVED, 
                         Location_Class__c = (isPax ? LOCCLASSPAX : LOCCLASSCASS), Location_Type__c = 'BR', ParentId = HO1.Id,
                         Reason_for_creation__c = 'Created by customer', Reason__c = '91-ACCREDITED–MEETS–STANDARDS' );
        BR3 = new Account(RecordTypeId = accountRT, Name = 'My Travels', IATAcode__c = '1111113', IATA_ISO_Country__c = isoc.id, 
                         Sector__c =  (isPax ? SECTORPAX : SECTORCASS), Category__c = (isPax ? CATEGORYPAX : CATEGORYCASS), Status__c = AMS_Utils.ACC_S9_APPROVED, 
                         Location_Class__c = (isPax ? LOCCLASSPAX : LOCCLASSCASS), Location_Type__c = 'BR', ParentId = HO1.Id,
                         Reason_for_creation__c = 'Created by customer', Reason__c = '91-ACCREDITED–MEETS–STANDARDS' );
        BR4 = new Account(RecordTypeId = accountRT, Name = 'Your Travels', IATAcode__c = '2222221', IATA_ISO_Country__c = isoc.id, 
                         Sector__c =  (isPax ? SECTORPAX : SECTORCASS), Category__c = (isPax ? CATEGORYPAX : CATEGORYCASS), Status__c = AMS_Utils.ACC_S9_APPROVED, 
                         Location_Class__c = (isPax ? LOCCLASSPAX : LOCCLASSCASS), Location_Type__c = 'BR', ParentId = HO2.Id,
                         Reason_for_creation__c = 'Created by customer', Reason__c = '91-ACCREDITED–MEETS–STANDARDS' );
        BR5 = new Account(RecordTypeId = accountRT, Name = 'Your Travels', IATAcode__c = '2222222', IATA_ISO_Country__c = isoc.id, 
                         Sector__c =  (isPax ? SECTORPAX : SECTORCASS), Category__c = (isPax ? CATEGORYPAX : CATEGORYCASS), Status__c = AMS_Utils.ACC_S9_APPROVED, 
                         Location_Class__c = (isPax ? LOCCLASSPAX : LOCCLASSCASS), Location_Type__c = 'BR', ParentId = HO2.Id,
                         Reason_for_creation__c = 'Created by customer', Reason__c = '91-ACCREDITED–MEETS–STANDARDS' );
        BR6 = new Account(RecordTypeId = accountRT, Name = 'Your Travels', IATAcode__c = '2222223', IATA_ISO_Country__c = isoc.id, 
                         Sector__c =  (isPax ? SECTORPAX : SECTORCASS), Category__c = (isPax ? CATEGORYPAX : CATEGORYCASS), Status__c = AMS_Utils.ACC_S9_APPROVED, 
                         Location_Class__c = (isPax ? LOCCLASSPAX : LOCCLASSCASS), Location_Type__c = 'BR', ParentId = HO2.Id,
                         Reason_for_creation__c = 'Created by customer', Reason__c = '91-ACCREDITED–MEETS–STANDARDS' );
            
        
        accs = new list<Account>{BR1, BR2, BR3, BR4, BR5, BR6};
        insert accs;

        //Create the AMS hierarchies for the first group of agencies
        AMS_Agencies_Hierarchy__c H1 = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 1');
        AMS_Agencies_Hierarchy__c H2 = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 2');
        List<AMS_Agencies_Hierarchy__c> hs = new List<AMS_Agencies_Hierarchy__c>{H1, H2};
        insert hs;
        
        List<AMS_Agencies_relationhip__c> rels = new List<AMS_Agencies_relationhip__c>();
        rels.add(new AMS_Agencies_relationhip__c(Hierarchy__c = H1.Id, Parent_Account__c = HO1.Id, Child_Account__c = BR1.Id, HO_Flag__c = 'true'));
        rels.add(new AMS_Agencies_relationhip__c(Hierarchy__c = H1.Id, Parent_Account__c = HO1.Id, Child_Account__c = BR2.Id, HO_Flag__c = 'true'));
        rels.add(new AMS_Agencies_relationhip__c(Hierarchy__c = H1.Id, Parent_Account__c = HO1.Id, Child_Account__c = BR3.Id, HO_Flag__c = 'true'));
        
        rels.add(new AMS_Agencies_relationhip__c(Hierarchy__c = H2.Id, Parent_Account__c = HO2.Id, Child_Account__c = BR4.Id, HO_Flag__c = 'true'));
        rels.add(new AMS_Agencies_relationhip__c(Hierarchy__c = H2.Id, Parent_Account__c = HO2.Id, Child_Account__c = BR5.Id, HO_Flag__c = 'true'));
        rels.add(new AMS_Agencies_relationhip__c(Hierarchy__c = H2.Id, Parent_Account__c = HO2.Id, Child_Account__c = BR6.Id, HO_Flag__c = 'true'));
        
        insert rels;
        
        AMS_OSCAR__c oscar = new AMS_OSCAR__c(Account__c = acc1.Id);
        AMS_OSCAR__c oscar2 = new AMS_OSCAR__c(Account__c = HO1.Id);
        
        list<AMS_OSCAR__c> oscars = new list<AMS_OSCAR__c>{oscar, oscar2};
        insert oscars;
        
        Case testCase = ISSP_ObjectFactory.createNewCase();
        testCase.BSPCountry__c = 'Hong Kong (SAR), China';
        testCase.Reason1__c = 'Agency';
        testCase.Customer_recovery__c = false;
        //testCase.New_AWB_only_to_be_used_after_17Mar_200__c = false;
        testCase.BounceEmailCounter__c = 0.0;
        testCase.Case_Language__c = 'English';
        testCase.Subject = 'Test 006';
        testCase.Reopened_case__c = 0.0;
        //testCase.Continous_Feed_SAF__c = true;
        testCase.Account_Concerned__c = acc1.Id;
        testCase.IFAP_Country_ISO__c = 'tq';
        testCase.AccountId = acc1.id;
        testCase.Oscar__c = oscar.Id;

        Case testCase2 = ISSP_ObjectFactory.createNewCase();
        testCase2.BSPCountry__c = 'Hong Kong (SAR), China';
        testCase2.Reason1__c = 'Agency';
        testCase2.Customer_recovery__c = false;
        //testCase.New_AWB_only_to_be_used_after_17Mar_200__c = false;
        testCase2.BounceEmailCounter__c = 0.0;
        testCase2.Case_Language__c = 'English';
        testCase2.Subject = 'Test 006';
        testCase2.Reopened_case__c = 0.0;
        //testCase.Continous_Feed_SAF__c = true;
        testCase2.Account_Concerned__c = acc1.Id;
        testCase2.IFAP_Country_ISO__c = 'tq';
        testCase2.AccountId = HO1.id;
        testCase2.Oscar__c = oscar2.Id;
        
        list<Case> testCases = new list<Case>{testCase, testCase2};
        insert testCases;
        
        AMS_Pax_Accreditation_Form__c onlineAccreditation = new AMS_Pax_Accreditation_Form__c(IsGSA__c = 'No', CurrencyIsoCode = isoc.CurrencyIsoCode, SAAM_Case__c = testCase.Id, Account_Name__c = acc1.Name);
        insert onlineAccreditation;

        
        List<AMS_Accreditation_Contact__c> acList = new List<AMS_Accreditation_Contact__c>();
        acList.add(new AMS_Accreditation_Contact__c(AMS_Pax_Accreditation_Form__c = onlineAccreditation.Id, 
                                                    Company__c = acc1.id, First_name__c = 'NameToUse', 
                                                    Last_name__c = 'Last', Job_title__c = 'ABC', Mobile__c = '+4112345678', 
                                                    Phone__c = '3424322343', Email__c = 'unique@email.com', 
                                                    RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Person')));
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

        upsert new AMS_ChangeCodes__c(Integration_RecId__c = 'C', Name = 'CADM', Change_Code__c = 'CAD');

    }
    
    @isTest static void test_RunAccountOwnershipInsertthenUpdate_ExpectUpdatedAccountRole()
    {

        Map<Id,Set<Id>> aoMap = new Map<Id,Set<Id>>();

        boolean isCorrectionProcess = true;

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
        
        Id accountRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
        Account ownerAccount = new Account(Name='OwnerAccount', Location_Type__c = 'HO', Type='CASS Associate', Sector__c = 'Travel Agent', IATAcode__c = '0004141234', AIMS_ID__c = '98765431', Source_System__c = 'AIMS2');
        
        Account brAccount  = new Account(RecordtypeId=accountRT, Name='OwnerAccount', Location_Type__c = 'BR', Type='CASS Associate', Sector__c = 'Travel Agent', IATAcode__c = '0004141231', AIMS_ID__c = '98765432', Source_System__c = 'AIMS2', Top_Parent__c = ownerAccount.Id);
        
        insert new List<Account>{ownerAccount,brAccount};



        List<AMS_Accreditation_Contact__c> acList = [select Id, Contact__c, Person_AMS__c, AMS_Employee_Role__c, AMS_Ownership_Role__c, AMS_Pax_Accreditation_Form__c from AMS_Accreditation_Contact__c];
        acList.get(0).Contact__c = newCon.Id;
        acList.get(0).Person_AMS__c = null;

        // Create an Accreditation Contact record of type Account Ownership and expect a relevant account role to be created
        // Later expect updated values on AC record to match the role record
        AMS_Accreditation_Contact__c companyOwnershipAC = new AMS_Accreditation_Contact__c(First_Name__c = 'Name', 
                                                            AMS_Pax_Accreditation_Form__c = acList.get(0).AMS_Pax_Accreditation_Form__c, 
                                                            Agency_Owner__c = true, Financial_interest__c = 20, Company__c = ownerAccount.id,
                                                             RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Company'), 
                                                             Last_name__c = 'test', Phone__c = '23432434');
        acList.add(companyOwnershipAC);
        upsert acList;
        

        Test.startTest();
        
        List<AMS_Pax_Accreditation_Form__c> aoaList = [select id , SAAM_Case__r.AccountId from AMS_Pax_Accreditation_Form__c limit 1];

        System.assertEquals(1, aoaList.size());


        Set<Id> accountsInvolved = new Set<Id>();
        accountsInvolved.add(aoaList.get(0).SAAM_Case__r.AccountId);

        aoMap.put(aoaList.get(0).Id, accountsInvolved);
        
        AMS_AccountRoleCreator.runRoleCreatorForOnlineAccreditations(aoMap, isCorrectionProcess);
        
        roleList = [select Contact__c, Percentage__c, Contact__r.Email, Person__c, Person__r.Email__c, Account__c, RecordType.DeveloperName, RecordTypeId from AMS_Account_Role__c order by RecordTypeId];
        
        System.assertEquals(1, roleList.size());
        System.assertEquals('Ownership', roleList.get(0).RecordType.DeveloperName);
        System.assertEquals(20, roleList.get(0).Percentage__c);
        
        companyOwnershipAC.Financial_Interest__c = 100;
        companyOwnershipAC.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Person');
        update companyOwnershipAC;
        
        
        AMS_AccountRoleCreator.runRoleCreatorForOnlineAccreditations(aoMap, isCorrectionProcess);
        roleList = [select Percentage__c, Account__c, RecordType.DeveloperName, RecordTypeId from AMS_Account_Role__c order by RecordTypeId];

        System.assertEquals(1, roleList.size());
        System.assertEquals('Ownership', roleList.get(0).RecordType.DeveloperName);
        System.assertEquals(100, roleList.get(0).Percentage__c);


        AMS_OSCAR__c oscarToBR = new AMS_OSCAR__c(Account__c = brAccount.Id
                                      ,Process__c = 'NEW.BR'
                                      ,AMS_Online_Accreditation__c = acList.get(0).AMS_Pax_Accreditation_Form__c 
                                      );
        
        insert oscarToBR;

        oscarToBR.STEP6__c  = 'Passed';
        oscarToBR.STEP10__c = 'Passed';
        
        update oscarToBR;
        
        AMS_AccountRoleCreator.runRoleCreatorForOnlineAccreditations(aoMap, isCorrectionProcess);

        List<AMS_Accreditation_Contact__c> aclistLinkOnly = AMS_AccountRoleCreator.getPersonLinkingOnly(acList);
        
        Test.stopTest();
    }

    @isTest static void test_ContactEmailChangesBeforeRoleCreation()
    {

        Map<Id,Set<Id>> aoMap = new Map<Id,Set<Id>>();

        boolean isCorrectionProcess = true;

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
        
        List<AMS_Pax_Accreditation_Form__c> aoaList = [select id , SAAM_Case__r.AccountId from AMS_Pax_Accreditation_Form__c limit 1];

        Set<Id> accountsInvolved = new Set<Id>();
        accountsInvolved.add(aoaList.get(0).SAAM_Case__r.AccountId);

        aoMap.put(aoaList.get(0).Id, accountsInvolved);

        AMS_AccountRoleCreator.runRoleCreatorForOnlineAccreditations(aoMap, isCorrectionProcess);
        
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
        Set<Id> accountsInvolved = new Set<Id>();
        Map<Id,Set<Id>> aoMap = new Map<Id,Set<Id>>();

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
        acList.get(0).Agency_Owner__c = true;
        update acList;
        
        
        Test.startTest();
        List<AMS_Pax_Accreditation_Form__c> aoaList = [select id , SAAM_Case__r.AccountId from AMS_Pax_Accreditation_Form__c limit 1];

        accountsInvolved = new Set<Id>();
        accountsInvolved.add(aoaList.get(0).SAAM_Case__r.AccountId);

        aoMap.put(aoaList.get(0).Id, accountsInvolved);

        AMS_AccountRoleCreator.runRoleCreatorForOnlineAccreditations(aoMap, false);
        
        roleList = [select Contact__c, Contact__r.Email, Person__c, Person__r.Email__c, Account__c, RecordType.DeveloperName from AMS_Account_Role__c];
        System.assertEquals(1, roleList.size());

        acList.get(0).Agency_Owner__c = true;
        acList.get(0).Person_AMS__c = null;

        update acList;
        
        accountsInvolved = new Set<Id>();
        accountsInvolved.add(aoaList.get(0).SAAM_Case__r.AccountId);

        aoMap.put(aoaList.get(0).Id, accountsInvolved);

        AMS_AccountRoleCreator.runRoleCreatorForOnlineAccreditations(aoMap);
        roleList = [select Contact__c, Contact__r.Email, Person__c, Person__r.Email__c, Account__c, RecordType.DeveloperName from AMS_Account_Role__c];
        System.assertEquals(2, roleList.size());
        //System.assertEquals('Ownership', roleList.get(0).RecordType.DeveloperName);
    
    
        AMS_Accreditation_Contact__c newAc = new AMS_Accreditation_Contact__c(AMS_Pax_Accreditation_Form__c = aoaList.get(0).Id, 
                                                                            Company__c = accId, First_name__c ='NameToUse', Last_name__c ='Last', 
                                                                            Job_title__c ='ABC', Mobile__c ='+4112345678', Phone__c ='3424322343', 
                                                                            Email__c ='unique@email2.com', 
                                                                            RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Person'));
        insert newAc;
        
        accountsInvolved = new Set<Id>();
        accountsInvolved.add(aoaList.get(0).SAAM_Case__r.AccountId);

        aoMap.put(aoaList.get(0).Id, accountsInvolved);

        AMS_AccountRoleCreator.runRoleCreatorForOnlineAccreditations(aoMap);

        roleList = [select Contact__c, Contact__r.Email, Person__c, Person__r.Email__c, Account__c, RecordType.DeveloperName from AMS_Account_Role__c];
        System.assertEquals(3, roleList.size());
        Test.stopTest();
    }

    @isTest static void test_CreateAOCandACs_runProcessThriceForNoLinking()
    {

        Set<Id> accountsInvolved = new Set<Id>();
        Map<Id,Set<Id>> aoMap = new Map<Id,Set<Id>>();

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

        List<AMS_Pax_Accreditation_Form__c> aoaList = [select id , SAAM_Case__r.AccountId from AMS_Pax_Accreditation_Form__c limit 1];

        accountsInvolved = new Set<Id>();
        accountsInvolved.add(aoaList.get(0).SAAM_Case__r.AccountId);

        aoMap.put(aoaList.get(0).Id, accountsInvolved);

        AMS_AccountRoleCreator.runRoleCreatorForOnlineAccreditations(aoMap);
        
        roleList = [select Contact__c, Contact__r.Email, Person__c, Person__r.Email__c, Account__c, RecordType.DeveloperName from AMS_Account_Role__c];
        //DT: Employee are no more created in the Role Object
        //System.assertEquals(1, roleList.size());
        //System.assertEquals('Employee', roleList.get(0).RecordType.DeveloperName);
        System.assertEquals(0, roleList.size());
        acList.get(0).Agency_Owner__c = true;
        update acList;
        
        accountsInvolved = new Set<Id>();
        accountsInvolved.add(aoaList.get(0).SAAM_Case__r.AccountId);

        aoMap.put(aoaList.get(0).Id, accountsInvolved);

        AMS_AccountRoleCreator.runRoleCreatorForOnlineAccreditations(aoMap);

        roleList = [select Contact__c, Contact__r.Email, Person__c, Person__r.Email__c, Account__c, RecordType.DeveloperName from AMS_Account_Role__c];
        System.assertEquals(1, roleList.size());
        System.assertEquals('Ownership', roleList.get(0).RecordType.DeveloperName);
    
    
        AMS_Accreditation_Contact__c newAc = new AMS_Accreditation_Contact__c(AMS_Pax_Accreditation_Form__c = aoaList.get(0).Id, 
                                                                                Company__c = accId, First_name__c='NameToUse', Last_name__c='Last', 
                                                                                Job_title__c='ABC', Mobile__c='+4112345678', Phone__c='3424322343', 
                                                                                Email__c='unique2@email.com', Person_AMS__c = newPerson.Id, 
                                                                                RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Person'));
        insert newAc;
        
        accountsInvolved = new Set<Id>();
        accountsInvolved.add(aoaList.get(0).SAAM_Case__r.AccountId);

        aoMap.put(aoaList.get(0).Id, accountsInvolved);

        AMS_AccountRoleCreator.runRoleCreatorForOnlineAccreditations(aoMap);

        roleList = [select Contact__c, Contact__r.Email, Person__c, Person__r.Email__c, Account__c, RecordType.DeveloperName from AMS_Account_Role__c];
        //DT: Employee are no more created in the Role Object
        //System.assertEquals(2, roleList.size());
        System.assertEquals(2, roleList.size());
        Test.stopTest();
    }

    @isTest static void test_CreateAOCandACs_runWholeProcessForNoLinking()
    {

        Set<Id> accountsInvolved = new Set<Id>();
        Map<Id,Set<Id>> aoMap = new Map<Id,Set<Id>>();

        List<AMS_Accreditation_Contact__c> acList = [select Id, Contact__c, Person_AMS__c, Company__c from AMS_Accreditation_Contact__c];
        acList.get(0).Contact__c = null;
        acList.get(0).Person_AMS__c = null;

        update acList;
        
        List<AMS_Account_Role__c> roleList = [select Contact__c, Contact__r.Email, Person__c, Account__c from AMS_Account_Role__c];
        delete roleList;
        
        Test.startTest();

        List<AMS_Pax_Accreditation_Form__c> aoaList = [select id , SAAM_Case__r.AccountId from AMS_Pax_Accreditation_Form__c limit 1];

        accountsInvolved = new Set<Id>();
        accountsInvolved.add(aoaList.get(0).SAAM_Case__r.AccountId);

        aoMap.put(aoaList.get(0).Id, accountsInvolved);

        AMS_AccountRoleCreator.runRoleCreatorForOnlineAccreditations(aoMap);
        
        roleList = [select Contact__c, Contact__r.Email, Contact__r.FirstName, Person__c, Person__r.Email__c, Account__c from AMS_Account_Role__c];

        System.assertEquals(0, roleList.size());
        Test.stopTest();
    }

    @isTest static void test_CreateAOCandACs_runProcessThriceForContact()
    {
        Set<Id> accountsInvolved = new Set<Id>();
        Map<Id,Set<Id>> aoMap = new Map<Id,Set<Id>>();

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

        List<AMS_Pax_Accreditation_Form__c> aoaList = [select id , SAAM_Case__r.AccountId from AMS_Pax_Accreditation_Form__c limit 1];

        accountsInvolved = new Set<Id>();
        accountsInvolved.add(aoaList.get(0).SAAM_Case__r.AccountId);

        aoMap.put(aoaList.get(0).Id, accountsInvolved);

        AMS_AccountRoleCreator.runRoleCreatorForOnlineAccreditations(aoMap);

        roleList = [select Id, Contact__c, Contact__r.Email, Person__c, Person__r.Email__c, Account__c, RecordType.DeveloperName from AMS_Account_Role__c where Active__c = true];

        System.assertEquals(0, roleList.size());
        acList.get(0).Agency_Owner__c = true;
        update acList;
        
        AMS_AccountRoleCreator.runRoleCreatorForOnlineAccreditations(aoMap);
        roleList = [select Contact__c, Contact__r.Email, Person__c, Person__r.Email__c, Account__c, RecordType.DeveloperName from AMS_Account_Role__c where Active__c = true];
        System.assertEquals(1, roleList.size());
        System.assertEquals('Ownership', roleList.get(0).RecordType.DeveloperName);
    
        AMS_Accreditation_Contact__c newAc = new AMS_Accreditation_Contact__c(AMS_Pax_Accreditation_Form__c = aoaList.get(0).Id, 
                                                                                AMS_Ownership_Role__c = roleList.get(0).Id, Company__c = accId, 
                                                                                First_name__c='NameToUse', Last_name__c='Last', Job_title__c='ABC', 
                                                                                Mobile__c='+4112345678', Phone__c='3424322343', Email__c='unique@email.com', 
                                                                                Contact__c = newCon.Id, RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Person'));
        insert newAc;
        
        AMS_AccountRoleCreator.runRoleCreatorForOnlineAccreditations(aoMap);
        roleList = [select Contact__c, Contact__r.Email, Person__c, Person__r.Email__c, Account__c, RecordType.DeveloperName from AMS_Account_Role__c where Active__c = true];


        System.assertEquals(2, roleList.size());
        Test.stopTest();
    }
    
    @isTest static void test_CreateAOCandACs_runWholeProcessForContactOnly()
    {
        Set<Id> accountsInvolved = new Set<Id>();
        Map<Id,Set<Id>> aoMap = new Map<Id,Set<Id>>();

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
        List<AMS_Pax_Accreditation_Form__c> aoaList = [select id , SAAM_Case__r.AccountId from AMS_Pax_Accreditation_Form__c limit 1];

        AMS_OSCAR__c oscar = [select AMS_Online_Accreditation__c from AMS_OSCAR__c limit 1];
        oscar.AMS_Online_Accreditation__c = aoaList.get(0).Id;
        update oscar;
    

        accountsInvolved = new Set<Id>();
        accountsInvolved.add(aoaList.get(0).SAAM_Case__r.AccountId);

        aoMap.put(aoaList.get(0).Id, accountsInvolved);

        AMS_AccountRoleCreator.runRoleCreatorForOnlineAccreditations(aoMap);
        
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
        Id ownerRtId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Account_Role__c', 'Ownership');
        
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
        Id employeeRtId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Account_Role__c', 'Ownership');
        
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
        Set<Id> accountsInvolved = new Set<Id>();
        Map<Id,Set<Id>> aoMap = new Map<Id,Set<Id>>();

        List<Contact> conList = [select id from Contact];
        delete conList;
        
        List<AMS_Person__c> personList = [select Id from AMS_Person__c];
        System.assertEquals(2, personList.size());
        List<AMS_Accreditation_Contact__c> acList = [select Id, Contact__c, Person_AMS__c, Financial_Assessment_Contact__c from AMS_Accreditation_Contact__c];
        acList.get(0).Person_AMS__c = personList.get(0).Id;
        acList.get(0).Financial_Assessment_Contact__c = true;
        acList.get(0).Agency_owner__c = true;
        update acList;
        
        List<AMS_Account_Role__c> roleList = [select Contact__c, Contact__r.Email, Person__r.Email__c, Person__c, Account__c from AMS_Account_Role__c];
        
        Test.startTest();
        
        List<AMS_Pax_Accreditation_Form__c> aoaList = [select id , SAAM_Case__r.AccountId from AMS_Pax_Accreditation_Form__c limit 1];

        accountsInvolved = new Set<Id>();
        accountsInvolved.add(aoaList.get(0).SAAM_Case__r.AccountId);

        aoMap.put(aoaList.get(0).Id, accountsInvolved);

        AMS_AccountRoleCreator.runRoleCreatorForOnlineAccreditations(aoMap);
       
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
        System.assertEquals(1, personList.size());
        
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
        
        AMS_Accreditation_Contact__c accContact = new AMS_Accreditation_Contact__c(AMS_Pax_Accreditation_Form__c = onlineAccreditation.Id, 
                                                                                    First_name__c = 'NameToUse', Last_name__c = 'Last', Job_title__c = 'ABC', 
                                                                                    Mobile__c = '+4112345678', Phone__c = '3424322343', Email__c = 'ewrstdfgyhujntest@test.com', 
                                                                                    RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Person'));
        
        insert accContact;

        list<AMS_Accreditation_Contact__c> lsAccCont = [select Id, Person_AMS__c, Email__c, Contact__c from AMS_Accreditation_Contact__c];
        list<Contact> lsContacts = AMS_AccountRoleCreator.transformACsWithPersonLinking_createContactList(lsAccCont, null); 
    }

    @isTest static void test_RoleCreationForCorrectionProcess(){
    Test.startTest();
        Id ownerRecTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Account_Role__c', 'Ownership');
        Id correctionOSCARRecTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'CORRECTION');

        AMS_OSCAR__c oscar = [select AMS_Online_Accreditation__c from AMS_OSCAR__c limit 1];

        List<AMS_Pax_Accreditation_Form__c> aoaList = [select id from AMS_Pax_Accreditation_Form__c limit 1];

        List<Contact> conList = [select Id, Email, AccountId from Contact];
        List<Account> accList = [select Id, Name, Status__c from Account];

        AMS_Account_Role__c owner1 = new AMS_Account_Role__c(Account__c = accList.get(0).Id, Contact__c = conList.get(0).Id, Owner_Sequence__c = 1, Percentage__c = 1, recordTypeId = ownerRecTypeId);
        AMS_Account_Role__c owner2 = new AMS_Account_Role__c(Account__c = accList.get(0).Id, Owner_Account__c = accList.get(0).Id, Owner_Sequence__c = 1, Percentage__c = 1, recordTypeId = ownerRecTypeId);

        List<AMS_Account_Role__c> ownersList = new List<AMS_Account_Role__c>{owner1,owner2};
        insert ownersList;

        List<AMS_Accreditation_Contact__c> acList = new List<AMS_Accreditation_Contact__c>();
        acList.add(new AMS_Accreditation_Contact__c(AMS_Ownership_Role__c = owner1.Id, AMS_Pax_Accreditation_Form__c = aoaList.get(0).Id, Company__c = accList.get(0).Id, 
                                                        Contact__c = conList.get(0).id, First_name__c='NameToUse', Last_name__c ='Last', Job_title__c ='ABC',
                                                         Mobile__c ='+4112345678', Phone__c='3424322343', Agency_owner__c = true, Email__c ='unique@email.com', 
                                                         RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Person')));
        acList.add(new AMS_Accreditation_Contact__c(AMS_Ownership_Role__c = owner2.Id,AMS_Pax_Accreditation_Form__c = aoaList.get(0).Id, Company__c = accList.get(0).Id, 
                                                        First_name__c ='', Last_name__c ='Comapny', Job_title__c ='', Mobile__c ='+4112345678', Phone__c ='3424322343', 
                                                        Email__c ='company@email.com', Agency_owner__c = true, 
                                                        RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Company')));
        insert acList;

        oscar.RecordTypeId = correctionOSCARRecTypeId;
        oscar.AMS_Online_Accreditation__c = aoaList.get(0).Id;
        oscar.Type_of_change__c = AMS_Utils.COR;
        oscar.STEP6__c = 'Passed';
        oscar.AMS_Correction_change_code__c = 'COR';

        System.debug('test_RoleCreationForCorrectionProcess aoaList: ' + aoaList);
        System.debug('test_RoleCreationForCorrectionProcess oscar: ' + oscar);

        update oscar;

        Test.stopTest();
    }

    @isTest static void test_CORCCCorrectionProcess(){
        
        Test.startTest();
        
        Id correctionOSCARRecTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'CORRECTION');

        AMS_OSCAR__c oscar = [select Id, Account__c, AMS_Online_Accreditation__c from AMS_OSCAR__c where Account__r.Name = 'My Travels' limit 1];
        System.debug('test_CADCCCorrectionProcess oscar: ' + oscar);

        AMS_HierarchyHelper.createProcessDetailForFullHierarchy(oscar.Id, oscar.Account__c);

        //List<AMS_Pax_Accreditation_Form__c> aoaList = [select id from AMS_Pax_Accreditation_Form__c limit 1];
        Case c = [SELECT Id FROM Case WHERE Oscar__c = :oscar.Id];

        AMS_Pax_Accreditation_Form__c accre = new AMS_Pax_Accreditation_Form__c(
            SAAM_Case__c = c.id,
            Account_Name__c = 'My Travels',
            //CASS_Number__c = '126',
            Location_Class__c = 'C',
            //IATA_ISO_State__c = [SELECT Id FROM IATA_ISO_State__c LIMIT 1][0].Id,
            Branch_Office_Country__c = [SELECT Id FROM IATA_ISO_Country__c LIMIT 1][0].Id
        );
        insert accre;
        System.debug('test_CADCCCorrectionProcess accre: ' + accre);

        /*** AMSU-180 ***/
        AMS_Accreditation_Contact__c owner = new AMS_Accreditation_Contact__c(
            Name= 'test owner',
            First_name__c= 'test',
            Last_name__c = 'owner',
            Email__c= 'owner.test@test.com',
            Phone__c= '123456789',
            Financial_interest__c= 100,
            AMS_Pax_Accreditation_Form__c= accre.Id,
            RecordTypeId= RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Current_Owner')
        );
        insert owner;

        oscar.RecordTypeId = correctionOSCARRecTypeId;
        //oscar.AMS_Online_Accreditation__c = aoaList.get(0).Id;

        oscar.AMS_Online_Accreditation__c = accre.Id;
        oscar.Type_of_change__c = AMS_Utils.COR;
        oscar.STEP6__c = 'Passed';
        oscar.AMS_Correction_change_code__c = 'COR';
        System.debug('test_CADCCCorrectionProcess oscar: ' + oscar);

        update oscar;

        Test.stopTest();
    }

    @isTest static void test_CADCCCorrectionProcess(){
        
        Test.startTest();
        Id correctionOSCARRecTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'CORRECTION');

        AMS_OSCAR__c oscar = [select Id, Account__c, AMS_Online_Accreditation__c from AMS_OSCAR__c limit 1];

        List<AMS_Pax_Accreditation_Form__c> aoaList = [select id from AMS_Pax_Accreditation_Form__c limit 1];
        Case c = [SELECT Id FROM Case WHERE Oscar__c = :oscar.Id];


        oscar.RecordTypeId = correctionOSCARRecTypeId;
        oscar.AMS_Online_Accreditation__c = aoaList.get(0).Id;
        oscar.Type_of_change__c = AMS_Utils.COR;
        oscar.STEP6__c = 'Passed';
        oscar.AMS_Correction_change_code__c = 'CAD';

        update oscar;

        Test.stopTest();
    }

    @isTest static void test_CADCCCorrectionProcess2(){
        
        Test.startTest();
        
        Id correctionOSCARRecTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'CORRECTION');

        AMS_OSCAR__c oscar = [select Id, Account__c, AMS_Online_Accreditation__c from AMS_OSCAR__c where Account__r.Name = 'My Travels' limit 1];
        System.debug('test_CADCCCorrectionProcess oscar: ' + oscar);

        AMS_HierarchyHelper.createProcessDetailForFullHierarchy(oscar.Id, oscar.Account__c);

        //List<AMS_Pax_Accreditation_Form__c> aoaList = [select id from AMS_Pax_Accreditation_Form__c limit 1];
        Case c = [SELECT Id FROM Case WHERE Oscar__c = :oscar.Id];

        AMS_Pax_Accreditation_Form__c accre = new AMS_Pax_Accreditation_Form__c(
            SAAM_Case__c = c.id,
            Account_Name__c = 'My Travels',
            //CASS_Number__c = '125',
            Location_Class__c = 'C',
            //IATA_ISO_State__c = [SELECT Id FROM IATA_ISO_State__c LIMIT 1][0].Id,
            Branch_Office_Country__c = [SELECT Id FROM IATA_ISO_Country__c LIMIT 1][0].Id
        );
        insert accre;
        System.debug('test_CADCCCorrectionProcess accre: ' + accre);

        /*** AMSU-180 ***/
        AMS_Accreditation_Contact__c owner = new AMS_Accreditation_Contact__c(
            Name= 'test owner',
            First_name__c= 'test',
            Last_name__c = 'owner',
            Email__c= 'owner.test@test.com',
            Phone__c= '123456789',
            Financial_interest__c= 100,
            AMS_Pax_Accreditation_Form__c= accre.Id,
            RecordTypeId= RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Current_Owner')
        );
        insert owner;

        oscar.RecordTypeId = correctionOSCARRecTypeId;
        //oscar.AMS_Online_Accreditation__c = aoaList.get(0).Id;
        oscar.AMS_Online_Accreditation__c = accre.Id;
        oscar.Type_of_change__c = AMS_Utils.COR;
        oscar.STEP6__c = 'Passed';
        oscar.AMS_Correction_change_code__c = 'CAD';
        System.debug('test_CADCCCorrectionProcess oscar: ' + oscar);

        update oscar;

        Test.stopTest();
    }

    @isTest static void test_LETCCCorrectionProcess(){
        Test.startTest();
        Id correctionOSCARRecTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'CORRECTION');

        AMS_OSCAR__c oscar = [select AMS_Online_Accreditation__c from AMS_OSCAR__c limit 1];

        List<AMS_Pax_Accreditation_Form__c> aoaList = [select id from AMS_Pax_Accreditation_Form__c limit 1];

        oscar.RecordTypeId = correctionOSCARRecTypeId;
        oscar.AMS_Online_Accreditation__c = aoaList.get(0).Id;
        oscar.Type_of_change__c = AMS_Utils.COR;
        oscar.STEP6__c = 'Passed';
        oscar.AMS_Correction_change_code__c = 'LET';

        update oscar;

        Test.stopTest();
    }

    @isTest static void test_utilsMethods(){

        Test.startTest();

        AMS_AccountRoleCreator.OwnerFieldsEntity ofe1 = new AMS_AccountRoleCreator.OwnerFieldsEntity('TestUser','100');
        AMS_AccountRoleCreator.OwnerFieldsEntity ofe2 = new AMS_AccountRoleCreator.OwnerFieldsEntity();

        ofe1.decodeFromCSV('test,100');

        AMS_AccountRoleCreator.OwnerFieldsEntity ofe3 = new AMS_AccountRoleCreator.OwnerFieldsEntity('TestUser2','90');

        ofe1.compareTo(ofe3);

        List<Contact> contacts = [SELECT id from Contact];

        List<Id> contactIds = new List<Id>();

        For(Contact c: contacts)
            contactIDs.add(c.Id);

        AMS_AccountRoleCreator.removeFromList(contactIDs,contacts.get(0).Id);

        List<AMS_Accreditation_Contact__c> acontacts = [SELECT id, Person_AMS__c, Contact__c,Person_AMS__r.Contact__c from AMS_Accreditation_Contact__c];

        AMS_AccountRoleCreator.getNoPersonNorContactLing(acontacts);

        AMS_AccountRoleCreator.getContactLinking(acontacts);


        Test.stopTest();

    }


    @isTest static void test_OldAndNewOwnersMapping(){

    
        List<AMS_Pax_Accreditation_Form__c> aoaList = [select id , SAAM_Case__r.AccountId from AMS_Pax_Accreditation_Form__c limit 1];
        
        List<AMS_Accreditation_Contact__c> accreditationContactsToProcess = [select id,Agency_owner__c,First_Name__c,Last_Name__c,Financial_interest__c from AMS_Accreditation_Contact__c where AMS_Pax_Accreditation_Form__c in :aoaList  limit 1];
        
        accreditationContactsToProcess.get(0).Agency_owner__c = true;


        Set<Id> accounts = new Set<Id>();
        accounts.add(aoaList.get(0).SAAM_Case__r.AccountId);

        Id acctId = new List<Id>(accounts).get(0);
    
        List<AMS_Account_Role__c> allAccountRoles = new List<AMS_Account_Role__c>();       
        allAccountRoles.add(new AMS_Account_Role__c( Account__c = acctId,
                                                     Percentage__c = 100,
                                                     Owner_Name__c = 'Adrien Silva'
                                                    ));
        insert allAccountRoles;

        Test.startTest();

        system.debug('aaa allAccountRoles: ' + allAccountRoles);
        system.debug('aaa accreditationContactsToProcess: ' + accreditationContactsToProcess);
        system.debug('aaa aoaList: ' + aoaList);

        AMS_AccountRoleCreator.OldAndNewOwners oldNewOwners =  AMS_AccountRoleCreator.getNewAndOldOwnersForChangeCodeCreation(allAccountRoles ,accreditationContactsToProcess ,accounts);

        AMS_AccountRoleCreator.OwnersByAccountWrapper oldOwnersByAcctID = oldNewOwners.getOldOwnersByAccountId(acctId);
        AMS_AccountRoleCreator.OwnersByAccountWrapper newOwnersByAcctID = oldNewOwners.getNewOwnersByAccountId(acctId);

        system.debug('aaa oldOwnersByAcctID: ' + oldOwnersByAcctID.owners);
        system.debug('aaa newOwnersByAcctID: ' + newOwnersByAcctID.owners);


        //Old Owners
        
        system.assertEquals(acctId,oldOwnersByAcctID.acctId);
        
        system.assertEquals(oldOwnersByAcctID.owners.get(0).name,
                            allAccountRoles.get(0).Owner_Name__c
                            );

        system.assertEquals(oldOwnersByAcctID.owners.get(0).financialInterest,
                            String.valueOf(allAccountRoles.get(0).Percentage__c)
                            );

        //New Owners

        system.assertEquals(acctId,newOwnersByAcctID.acctId);

        system.assertEquals(newOwnersByAcctID.owners.get(0).name,
                            accreditationContactsToProcess.get(0).First_Name__c + ' ' + accreditationContactsToProcess.get(0).Last_Name__c
                            );

        system.assertEquals(newOwnersByAcctID.owners.get(0).financialInterest,
                            String.valueOf(accreditationContactsToProcess.get(0).Financial_interest__c)
                            );
        Test.stopTest(); 

    }
}