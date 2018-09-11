@isTest
public with sharing class AMS_AccountRoleCreatorTest {
    
    @testSetup static void setup()
    {
        IATA_ISO_Country__c isoc = new IATA_ISO_Country__c(Name = 'Test', ISO_Code__c = 'TS');       
        insert isoc;

        Id accountRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');
        Id agencyRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

        Account HO1, BR1, BR2, BR3, HO2, BR4;

        String SECTORPAX = 'Travel Agent';
        String CATEGORYPAX = 'IATA Passenger Sales Agent';
        String LOCCLASSPAX = 'P';

        
        
        //Create the 2 head offices
        HO1 = new Account(RecordTypeId = agencyRT, Name = 'My Travels', IATAcode__c = '1111110', IATA_ISO_Country__c = isoc.id, 
                         Sector__c = SECTORPAX, Category__c = CATEGORYPAX, 
                         Location_Class__c = LOCCLASSPAX, Location_Type__c = 'HO', Status__c = AMS_Utils.ACC_S9_APPROVED,
                         Reason_for_creation__c = 'Created by customer', Reason__c = '91-ACCREDITED–MEETS–STANDARDS' );

        HO2 = new Account(RecordTypeId = accountRT, Reason_for_creation__c = 'Headquarter is missing', Name='Head Office', 
                        Location_Type__c = 'HO', Location_Class__c = LOCCLASSPAX, Sector__c = SECTORPAX, Category__c = CATEGORYPAX, IATA_ISO_Country__c = isoc.id, 
                        IATAcode__c = '12345678', AIMS_ID__c = '12345678', Source_System__c = 'AIMS2');

        List<Account> accs = new List<Account>{HO1, HO2};
        insert accs;
        //Create the 4 branches
        BR1 = new Account(RecordTypeId = agencyRT, Name = 'My Travels', IATAcode__c = '1111111', IATA_ISO_Country__c = isoc.id, 
                         Sector__c = SECTORPAX, Category__c = CATEGORYPAX, Status__c = AMS_Utils.ACC_S9_APPROVED,  
                         Location_Class__c = LOCCLASSPAX, Location_Type__c = 'BR', ParentId = HO1.Id,
                         Reason_for_creation__c = 'Created by customer', Reason__c = '91-ACCREDITED–MEETS–STANDARDS' );
        BR2 = new Account(RecordTypeId = agencyRT, Name = 'My Travels', IATAcode__c = '1111112', IATA_ISO_Country__c = isoc.id, 
                         Sector__c = SECTORPAX, Category__c = CATEGORYPAX, Status__c = AMS_Utils.ACC_S9_APPROVED, 
                         Location_Class__c = LOCCLASSPAX, Location_Type__c = 'BR', ParentId = HO1.Id,
                         Reason_for_creation__c = 'Created by customer', Reason__c = '91-ACCREDITED–MEETS–STANDARDS' );
        BR3 = new Account(RecordTypeId = agencyRT, Name = 'My Travels', IATAcode__c = '1111113', IATA_ISO_Country__c = isoc.id, 
                         Sector__c =  SECTORPAX, Category__c = CATEGORYPAX, Status__c = AMS_Utils.ACC_S9_APPROVED, 
                         Location_Class__c = LOCCLASSPAX, Location_Type__c = 'BR', ParentId = HO1.Id,
                         Reason_for_creation__c = 'Created by customer', Reason__c = '91-ACCREDITED–MEETS–STANDARDS' );

        BR4 = new Account(RecordTypeId = accountRT, Name = 'Branch', IATAcode__c = '1111113', IATA_ISO_Country__c = isoc.id, 
                         Sector__c =  SECTORPAX, Category__c = CATEGORYPAX, Location_Class__c = LOCCLASSPAX, 
                         Location_Type__c = 'BR', ParentId = HO1.Id, Reason_for_creation__c = 'Created by customer' );              
        
        accs = new list<Account>{BR1, BR2, BR3, BR4};
        insert accs;

        //Create the AMS hierarchies for the first group of agencies
        AMS_Agencies_Hierarchy__c H1 = new AMS_Agencies_Hierarchy__c(Hierarchy_Name__c = 'Hierarchy 1');
        insert H1;
        
        List<AMS_Agencies_relationhip__c> rels = new List<AMS_Agencies_relationhip__c>();
        rels.add(new AMS_Agencies_relationhip__c(Hierarchy__c = H1.Id, Parent_Account__c = HO1.Id, Child_Account__c = BR1.Id, HO_Flag__c = 'true'));
        rels.add(new AMS_Agencies_relationhip__c(Hierarchy__c = H1.Id, Parent_Account__c = HO1.Id, Child_Account__c = BR2.Id, HO_Flag__c = 'true'));
        rels.add(new AMS_Agencies_relationhip__c(Hierarchy__c = H1.Id, Parent_Account__c = HO1.Id, Child_Account__c = BR3.Id, HO_Flag__c = 'true'));
        
        insert rels;
        
        AMS_OSCAR__c oscar = new AMS_OSCAR__c(Account__c = HO2.Id);
        AMS_OSCAR__c oscar2 = new AMS_OSCAR__c(Account__c = HO1.Id);
        
        list<AMS_OSCAR__c> oscars = new list<AMS_OSCAR__c>{oscar, oscar2};
        insert oscars;
        
        Case testCase = ISSP_ObjectFactory.createNewCase();
        testCase.BSPCountry__c = 'Hong Kong (SAR), China';
        testCase.Reason1__c = 'Agency';
        testCase.Customer_recovery__c = false;
        testCase.BounceEmailCounter__c = 0.0;
        testCase.Case_Language__c = 'English';
        testCase.Subject = 'Test 006';
        testCase.Reopened_case__c = 0.0;
        testCase.Account_Concerned__c = HO2.Id;
        testCase.IFAP_Country_ISO__c = 'tq';
        testCase.AccountId = HO2.id;
        testCase.Oscar__c = oscar.Id;

        Case testCase2 = ISSP_ObjectFactory.createNewCase();
        testCase2.BSPCountry__c = 'Hong Kong (SAR), China';
        testCase2.Reason1__c = 'Agency';
        testCase2.Customer_recovery__c = false;
        testCase2.BounceEmailCounter__c = 0.0;
        testCase2.Case_Language__c = 'English';
        testCase2.Subject = 'Test 006';
        testCase2.Reopened_case__c = 0.0;
        testCase2.Account_Concerned__c = HO2.Id;
        testCase2.IFAP_Country_ISO__c = 'tq';
        testCase2.AccountId = HO1.id;
        testCase2.Oscar__c = oscar2.Id;
        
        list<Case> testCases = new list<Case>{testCase, testCase2};
        insert testCases;
        
        AMS_Pax_Accreditation_Form__c onlineAccreditation = new AMS_Pax_Accreditation_Form__c(IsGSA__c = 'No', CurrencyIsoCode = isoc.CurrencyIsoCode, SAAM_Case__c = testCase2.Id, Account_Name__c = HO1.Name);
        AMS_Pax_Accreditation_Form__c onlineAccreditation2 = new AMS_Pax_Accreditation_Form__c(IsGSA__c = 'No', CurrencyIsoCode = isoc.CurrencyIsoCode, SAAM_Case__c = testCase.Id, Account_Name__c = HO2.Name);
        list<AMS_Pax_Accreditation_Form__c> onlineAccreditations = new list<AMS_Pax_Accreditation_Form__c>{onlineAccreditation, onlineAccreditation2};
        insert onlineAccreditations;

        AMS_Accreditation_Contact__c accContact = new AMS_Accreditation_Contact__c(AMS_Pax_Accreditation_Form__c = onlineAccreditation.Id, 
                                                                                    First_name__c = 'NameToUse', Last_name__c = 'Last', 
                                                                                    Job_title__c = 'ABC', Mobile__c = '+4112345678', 
                                                                                    Phone__c = '3424322343', Email__c = 'unique@email.com', 
                                                                                    RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Person'));
        insert accContact;
        
        Contact c1 = new Contact(AccountId = HO2.id, Firstname = 'personContact', Lastname='c1LastName', Phone = '911111111', MobilePhone = '911111111', Email = 'personContact@test.com', Financial_Assessment_Contact__c = false);
        Contact c2 = new Contact(AccountId = HO2.id, Firstname = 'linkedContact', Lastname='c2LastName', Phone = '922222222', MobilePhone = '922222222', Email = 'linkedContact@email.com', Financial_Assessment_Contact__c = false);
        Contact c3 = new Contact(AccountId = HO1.id, Firstname = 'contact', Lastname='c3LastName', Phone = '933333333', MobilePhone = '933333333', Email = 'contact@email.com', Financial_Assessment_Contact__c = false);
        
        List<Contact> listOfContacts = new List<Contact>();
        listOfContacts.add(c1);
        listOfContacts.add(c2);
        listOfContacts.add(c3);
        insert listOfContacts;

        AMS_Account_Role__c owner = new AMS_Account_Role__c(Account__c = HO1.Id, Contact__c = c1.Id, Owner_Sequence__c = 1, Percentage__c = 100, recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Account_Role__c', 'Ownership'));
        insert owner;
        
        AMS_Person__c p1 = new AMS_Person__c(Name='test1', LastName__c='LastName', First_Name__c='FirstNameNotToUse', Email__c='unique@email.com');
        insert p1;
        AMS_Person__c p2 = new AMS_Person__c(Name='do', LastName__c='notDelete', First_Name__c='DontDelete', Email__c='unique123@email.com');
        insert p2;
        AMS_Person__c p3 = new AMS_Person__c(Name='test', LastName__c='personLast', First_Name__c='personFirst', Email__c='unique456@email.com');
        insert p3;

        upsert new AMS_ChangeCodes__c(Integration_RecId__c = 'C', Name = 'CADM', Change_Code__c = 'CAD');

    }

    @isTest static void test_newHO(){

        //get oscar for new application
        Map<Id,AMS_OSCAR__c> oscars = new Map<Id,AMS_OSCAR__c>([SELECT Id, STEP10__c, STEP6__c, Account__c, Account__r.Location_Type__c, Account__r.Top_Parent__r.Id, AMS_Online_Accreditation__c, AMS_Online_Accreditation__r.Id, RecordTypeId, RecordType.DeveloperName, Process__c, Is_PCI_compliant__c FROM AMS_OSCAR__c WHERE Account__r.Name = 'Head Office' LIMIT 1]);
        List<Contact> contacts = [SELECT Id, Email, Firstname, Lastname FROM Contact WHERE AccountId =: oscars.values().get(0).Account__c];
        AMS_Pax_Accreditation_Form__c onlineAccreditation = [SELECT id, SAAM_Case__r.AccountId FROM AMS_Pax_Accreditation_Form__c WHERE SAAM_Case__r.AccountId =: oscars.values().get(0).Account__c LIMIT 1];

        oscars.values().get(0).Process__c = AMS_Utils.new_HO;
        oscars.values().get(0).AMS_Online_Accreditation__c = onlineAccreditation.Id;
        update oscars.values();

        List<AMS_Accreditation_Contact__c> accreditationContacts = new List<AMS_Accreditation_Contact__c>();

        AMS_Accreditation_Contact__c owner1 = new AMS_Accreditation_Contact__c(AMS_Pax_Accreditation_Form__c = onlineAccreditation.Id, Agency_Owner__c = true, Financial_interest__c = 50,
                                                                                RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Company'), 
                                                                                Last_name__c = 'test');
        AMS_Accreditation_Contact__c owner2 = new AMS_Accreditation_Contact__c(AMS_Pax_Accreditation_Form__c = onlineAccreditation.Id, Agency_Owner__c = true, Financial_interest__c = 50,
                                                                                RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Person'), 
                                                                                Last_name__c = contacts.get(0).Lastname, First_Name__c = contacts.get(0).Firstname, Contact__c = contacts.get(0).Id, 
                                                                                Email__c = contacts.get(0).Email);
        AMS_Accreditation_Contact__c contact1 = new AMS_Accreditation_Contact__c(AMS_Pax_Accreditation_Form__c = onlineAccreditation.Id, Agency_Owner__c = false,
                                                                                RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Person'), 
                                                                                Last_name__c = 'Not Owner', First_Name__c = 'Just Contact', Email__c = 'justContact@notOwner.test');
        accreditationContacts.add(owner1);
        accreditationContacts.add(owner2);
        accreditationContacts.add(contact1);
        insert accreditationContacts;

        Test.startTest();

        //step to generate iata code
        AMS_AccountRoleCreator.runRoleCreatorForOnlineAccreditations(new Map<Id,Set<Id>>{onlineAccreditation.Id => new Set<Id>{onlineAccreditation.SAAM_Case__r.AccountId}}, 
                                                                    true, true, oscars, new Map<Id,String>{oscars.values().get(0).Id => oscars.values().get(0).Account__r.Location_Type__c}, 
                                                                    new Map<Id,Id>{oscars.values().get(0).Id => oscars.values().get(0).Account__r.Top_Parent__r.Id == null ? oscars.values().get(0).Account__c : oscars.values().get(0).Account__r.Top_Parent__r.Id});

        List<AMS_Account_Role__c> accountRoles = [SELECT Id, Percentage__c FROM AMS_Account_Role__c WHERE RecordType.DeveloperName = 'Ownership' AND Account__c =: onlineAccreditation.SAAM_Case__r.AccountId];
        List<Contact> contactsAfter = [SELECT Id FROM Contact WHERE AccountId =: onlineAccreditation.SAAM_Case__r.AccountId];

        Decimal financialInterest = 0;

        for(AMS_Account_Role__c ar : accountRoles)
            financialInterest += ar.Percentage__c;

        System.assertEquals(2, accountRoles.size());
        System.assertEquals(3, contactsAfter.size());
        System.assertEquals(100, financialInterest);


        accreditationContacts.clear();

        owner1.Financial_interest__c = 30;
        accreditationContacts.add(owner1);

        owner2.Financial_interest__c = 40;
        accreditationContacts.add(owner2);

        AMS_Accreditation_Contact__c owner3 = new AMS_Accreditation_Contact__c(AMS_Pax_Accreditation_Form__c = onlineAccreditation.Id, Agency_Owner__c = true, Financial_interest__c = 30,
                                                                                RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Person'), 
                                                                                Last_name__c = contacts.get(1).Lastname, First_Name__c = contacts.get(1).Firstname, Contact__c = contacts.get(1).Id, 
                                                                                Email__c = contacts.get(1).Email);
        accreditationContacts.add(owner3);
        upsert accreditationContacts;

        //approval step
        AMS_AccountRoleCreator.runRoleCreatorForOnlineAccreditations(new Map<Id,Set<Id>>{onlineAccreditation.Id => new Set<Id>{onlineAccreditation.SAAM_Case__r.AccountId}}, 
                                                                    true, false, oscars, new Map<Id,String>{oscars.values().get(0).Id => oscars.values().get(0).Account__r.Location_Type__c}, 
                                                                    new Map<Id,Id>{oscars.values().get(0).Id => oscars.values().get(0).Account__r.Top_Parent__r.Id == null ? oscars.values().get(0).Account__c : oscars.values().get(0).Account__r.Top_Parent__r.Id});

        Test.stopTest();

        accountRoles = [SELECT Id, Percentage__c FROM AMS_Account_Role__c WHERE RecordType.DeveloperName = 'Ownership' AND Account__c =: onlineAccreditation.SAAM_Case__r.AccountId];
        contactsAfter = [SELECT Id FROM Contact WHERE AccountId =: onlineAccreditation.SAAM_Case__r.AccountId];

        financialInterest = 0;

        for(AMS_Account_Role__c ar : accountRoles)
            financialInterest += ar.Percentage__c;

        System.assertEquals(3, accountRoles.size());
        System.assertEquals(3, contactsAfter.size());
        System.assertEquals(100, financialInterest);
       
    }

    @isTest static void test_newBR(){

        //get oscar for new application
        Account branch = [SELECT Id, Location_Type__c, Top_Parent__r.Id FROM Account WHERE Name = 'Branch' LIMIT 1];
        Map<Id,AMS_OSCAR__c> oscars = new Map<Id,AMS_OSCAR__c>([SELECT Id, STEP10__c, STEP6__c, Account__c, Account__r.Location_Type__c, Account__r.Top_Parent__r.Id, AMS_Online_Accreditation__c, AMS_Online_Accreditation__r.Id, RecordTypeId, RecordType.DeveloperName, Process__c, Is_PCI_compliant__c FROM AMS_OSCAR__c WHERE Account__r.Name = 'Head Office' LIMIT 1]);
        Case cse = [SELECT Id, AccountId FROM Case WHERE AccountId =: oscars.values().get(0).Account__c LIMIT 1];

        cse.AccountId = branch.Id;
        update cse;

        AMS_Pax_Accreditation_Form__c onlineAccreditation = [SELECT id, SAAM_Case__r.AccountId FROM AMS_Pax_Accreditation_Form__c WHERE SAAM_Case__r.AccountId =: branch.Id LIMIT 1];

        oscars.values().get(0).Process__c = AMS_Utils.new_BR;
        oscars.values().get(0).AMS_Online_Accreditation__c = onlineAccreditation.Id;
        oscars.values().get(0).Account__c = branch.Id;
        oscars.values().get(0).STEP10__c = 'Passed';
        oscars.values().get(0).STEP6__c = 'Passed';
        update oscars.values();

        Test.startTest();

        //step to generate iata code
        AMS_AccountRoleCreator.runRoleCreatorForOnlineAccreditations(new Map<Id,Set<Id>>{onlineAccreditation.Id => new Set<Id>{branch.Id}}, 
                                                                    true, false, oscars, new Map<Id,String>{oscars.values().get(0).Id => branch.Location_Type__c}, 
                                                                    new Map<Id,Id>{oscars.values().get(0).Id => branch.Top_Parent__r.Id == null ? branch.Id : branch.Top_Parent__r.Id});

        List<AMS_Account_Role__c> accountRoles = [SELECT Id, Percentage__c, Account__c FROM AMS_Account_Role__c WHERE RecordType.DeveloperName = 'Ownership'];
        List<Contact> contactsAfter = new List<Contact>();
        contactsAfter.addAll([SELECT Id FROM Contact WHERE AccountId =: branch.Id]);

        Test.stopTest();

        Set<Id> accountsWithRoles = new Set<Id>();

        for(AMS_Account_Role__c ar : accountRoles)
            accountsWithRoles.add(ar.Account__c);

        System.assertEquals(2, accountRoles.size());
        System.assertEquals(true, accountsWithRoles.contains(branch.Id));
        System.assertEquals(true, accountsWithRoles.contains(branch.Top_Parent__r.Id));
        System.assertEquals(true, contactsAfter.isEmpty());

    }

    @isTest static void test_majorChanges(){

        //get oscar for new application
        Map<Id,Account> accountsInvolved = new Map<Id,Account>([SELECT Id FROM Account WHERE Name = 'My Travels']); 
        Map<Id,AMS_OSCAR__c> oscars = new Map<Id,AMS_OSCAR__c>([SELECT Id, STEP10__c, STEP6__c, Account__c, Account__r.Location_Type__c, Account__r.Top_Parent__r.Id, AMS_Online_Accreditation__c, AMS_Online_Accreditation__r.Id, RecordTypeId, RecordType.DeveloperName, Process__c, Is_PCI_compliant__c FROM AMS_OSCAR__c WHERE Account__r.Name = 'My Travels' AND Account__r.Location_Type__c = 'HO' LIMIT 1]);
        Contact con = [SELECT Id, Email, Firstname, Lastname FROM Contact WHERE Email = 'linkedContact@email.com' LIMIT 1];
        AMS_Pax_Accreditation_Form__c onlineAccreditation = [SELECT id, SAAM_Case__r.AccountId FROM AMS_Pax_Accreditation_Form__c WHERE SAAM_Case__r.AccountId =: oscars.values().get(0).Account__c LIMIT 1];
        AMS_Account_Role__c previousOwner = [SELECT Id, Percentage__c, RecordTypeId, Contact__c, Contact__r.Firstname, Contact__r.Lastname, Contact__r.Email FROM AMS_Account_Role__c LIMIT 1];

        oscars.values().get(0).Process__c = AMS_Utils.AGENCYCHANGES;
        oscars.values().get(0).AMS_Online_Accreditation__c = onlineAccreditation.Id;
        update oscars.values();

        delete [SELECT Id FROM AMS_Accreditation_Contact__c];

        List<AMS_Accreditation_Contact__c> accreditationContacts = new List<AMS_Accreditation_Contact__c>();

        AMS_Accreditation_Contact__c owner1 = new AMS_Accreditation_Contact__c(AMS_Pax_Accreditation_Form__c = onlineAccreditation.Id, Agency_Owner__c = true, Financial_interest__c = 50,
                                                                                RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Current_Owner'), 
                                                                                Last_name__c = previousOwner.Contact__r.Lastname, First_Name__c = previousOwner.Contact__r.Firstname, Contact__c = previousOwner.Contact__c, 
                                                                                Email__c = previousOwner.Contact__r.Email, AMS_Ownership_Role__c = previousOwner.Id);
        AMS_Accreditation_Contact__c owner2 = new AMS_Accreditation_Contact__c(AMS_Pax_Accreditation_Form__c = onlineAccreditation.Id, Agency_Owner__c = true, Financial_interest__c = 30,
                                                                                RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Current_Owner'), 
                                                                                Last_name__c = con.Lastname, First_Name__c = con.Firstname, Email__c = con.Email, Contact__c = con.Id);
        AMS_Accreditation_Contact__c owner3 = new AMS_Accreditation_Contact__c(AMS_Pax_Accreditation_Form__c = onlineAccreditation.Id, Agency_Owner__c = true, Financial_interest__c = 20,
                                                                                RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Current_Owner'), 
                                                                                Last_name__c = 'New Owner', First_Name__c = 'New Contact', Email__c = 'newContact@newOwner.test');
        accreditationContacts.add(owner1);
        accreditationContacts.add(owner2);
        accreditationContacts.add(owner3);
        insert accreditationContacts;

        Test.startTest();

        //step to generate iata code
        AMS_AccountRoleCreator.runRoleCreatorForOnlineAccreditations(new Map<Id,Set<Id>>{onlineAccreditation.Id => accountsInvolved.keySet()}, 
                                                                    false, false, oscars, new Map<Id,String>{oscars.values().get(0).Id => oscars.values().get(0).Account__r.Location_Type__c}, 
                                                                    new Map<Id,Id>{oscars.values().get(0).Id => oscars.values().get(0).Account__r.Top_Parent__r.Id == null ? oscars.values().get(0).Account__c : oscars.values().get(0).Account__r.Top_Parent__r.Id});

        Test.stopTest();

        List<AMS_Account_Role__c> allAccountRoles = [SELECT Id, Percentage__c FROM AMS_Account_Role__c WHERE RecordType.DeveloperName = 'Ownership'];
        List<AMS_Account_Role__c> activeAccountRoles = [SELECT Id, Percentage__c FROM AMS_Account_Role__c WHERE RecordType.DeveloperName = 'Ownership' AND Active__c = true];
        List<Contact> contactsAfter = [SELECT Id, Email FROM Contact];

        System.assertEquals(13, allAccountRoles.size());
        System.assertEquals(12, activeAccountRoles.size());
        System.assertEquals(4, contactsAfter.size());
       
    }

    @isTest static void test_corrections(){

        //get oscar for new application
        Map<Id,Account> accountsInvolved = new Map<Id,Account>([SELECT Id FROM Account WHERE Name = 'My Travels']); 
        Map<Id,AMS_OSCAR__c> oscars = new Map<Id,AMS_OSCAR__c>([SELECT Id, STEP10__c, STEP6__c, Account__c, Account__r.Location_Type__c, Account__r.Top_Parent__r.Id, AMS_Online_Accreditation__c, AMS_Online_Accreditation__r.Id, RecordTypeId, RecordType.DeveloperName, Process__c, Is_PCI_compliant__c FROM AMS_OSCAR__c WHERE Account__r.Name = 'My Travels' AND Account__r.Location_Type__c = 'HO' LIMIT 1]);
        Contact con = [SELECT Id, Email, Firstname, Lastname FROM Contact WHERE Email = 'linkedContact@email.com' LIMIT 1];
        AMS_Pax_Accreditation_Form__c onlineAccreditation = [SELECT id, SAAM_Case__r.AccountId FROM AMS_Pax_Accreditation_Form__c WHERE SAAM_Case__r.AccountId =: oscars.values().get(0).Account__c LIMIT 1];
        AMS_Account_Role__c previousOwner = [SELECT Id, Percentage__c, RecordTypeId, Contact__c, Contact__r.Firstname, Contact__r.Lastname, Contact__r.Email FROM AMS_Account_Role__c LIMIT 1];

        oscars.values().get(0).Process__c = AMS_Utils.COR;
        oscars.values().get(0).AMS_Online_Accreditation__c = onlineAccreditation.Id;
        update oscars.values();

        delete [SELECT Id FROM AMS_Accreditation_Contact__c];

        List<AMS_Accreditation_Contact__c> accreditationContacts = new List<AMS_Accreditation_Contact__c>();

        AMS_Accreditation_Contact__c owner1 = new AMS_Accreditation_Contact__c(AMS_Pax_Accreditation_Form__c = onlineAccreditation.Id, Agency_Owner__c = true, Financial_interest__c = 50,
                                                                                RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Current_Owner'), 
                                                                                Last_name__c = previousOwner.Contact__r.Lastname, First_Name__c = previousOwner.Contact__r.Firstname, Contact__c = previousOwner.Contact__c, 
                                                                                Email__c = previousOwner.Contact__r.Email, AMS_Ownership_Role__c = previousOwner.Id);
        AMS_Accreditation_Contact__c owner2 = new AMS_Accreditation_Contact__c(AMS_Pax_Accreditation_Form__c = onlineAccreditation.Id, Agency_Owner__c = true, Financial_interest__c = 30,
                                                                                RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Current_Owner'), 
                                                                                Last_name__c = con.Lastname, First_Name__c = con.Firstname, Email__c = con.Email, Contact__c = con.Id);
        AMS_Accreditation_Contact__c owner3 = new AMS_Accreditation_Contact__c(AMS_Pax_Accreditation_Form__c = onlineAccreditation.Id, Agency_Owner__c = true, Financial_interest__c = 20,
                                                                                RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Current_Owner'), 
                                                                                Last_name__c = 'New Owner', First_Name__c = 'New Contact', Email__c = 'newContact@newOwner.test');
        accreditationContacts.add(owner1);
        accreditationContacts.add(owner2);
        accreditationContacts.add(owner3);
        insert accreditationContacts;

        Test.startTest();

        //step to generate iata code
        AMS_AccountRoleCreator.runRoleCreatorForOnlineAccreditations(new Map<Id,Set<Id>>{onlineAccreditation.Id => accountsInvolved.keySet()}, 
                                                                    true, false, oscars, new Map<Id,String>{oscars.values().get(0).Id => oscars.values().get(0).Account__r.Location_Type__c}, 
                                                                    new Map<Id,Id>{oscars.values().get(0).Id => oscars.values().get(0).Account__r.Top_Parent__r.Id == null ? oscars.values().get(0).Account__c : oscars.values().get(0).Account__r.Top_Parent__r.Id});

        Test.stopTest();

        List<AMS_Account_Role__c> allAccountRoles = [SELECT Id, Percentage__c FROM AMS_Account_Role__c WHERE RecordType.DeveloperName = 'Ownership'];
        List<AMS_Account_Role__c> activeAccountRoles = [SELECT Id, Percentage__c FROM AMS_Account_Role__c WHERE RecordType.DeveloperName = 'Ownership' AND Active__c = true];
        List<Contact> contactsAfter = [SELECT Id, Email FROM Contact];

        System.debug('SS## contactsAfter: ' + contactsAfter);

        System.assertEquals(13, allAccountRoles.size());
        System.assertEquals(12, activeAccountRoles.size());
        System.assertEquals(4, contactsAfter.size());
       
    }

    @isTest static void test_duplicatedContacts(){

        //get oscar for new application
        Map<Id,AMS_OSCAR__c> oscars = new Map<Id,AMS_OSCAR__c>([SELECT Id, STEP10__c, STEP6__c, Account__c, Account__r.Location_Type__c, Account__r.Top_Parent__r.Id, AMS_Online_Accreditation__c, AMS_Online_Accreditation__r.Id, RecordTypeId, RecordType.DeveloperName, Process__c, Is_PCI_compliant__c FROM AMS_OSCAR__c WHERE Account__r.Name = 'Head Office' LIMIT 1]);
        List<Contact> contacts = [SELECT Id, Email, Firstname, Lastname FROM Contact WHERE AccountId =: oscars.values().get(0).Account__c];
        AMS_Pax_Accreditation_Form__c onlineAccreditation = [SELECT id, SAAM_Case__r.AccountId FROM AMS_Pax_Accreditation_Form__c WHERE SAAM_Case__r.AccountId =: oscars.values().get(0).Account__c LIMIT 1];

        oscars.values().get(0).Process__c = AMS_Utils.new_HO;
        oscars.values().get(0).AMS_Online_Accreditation__c = onlineAccreditation.Id;
        update oscars.values();

        List<AMS_Accreditation_Contact__c> accreditationContacts = new List<AMS_Accreditation_Contact__c>();

        AMS_Accreditation_Contact__c owner1 = new AMS_Accreditation_Contact__c(AMS_Pax_Accreditation_Form__c = onlineAccreditation.Id, Agency_Owner__c = true, Financial_interest__c = 50,
                                                                                RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Company'), 
                                                                                Last_name__c = 'test');
        AMS_Accreditation_Contact__c owner2 = new AMS_Accreditation_Contact__c(AMS_Pax_Accreditation_Form__c = onlineAccreditation.Id, Agency_Owner__c = true, Financial_interest__c = 25,
                                                                                RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Person'), 
                                                                                Last_name__c = contacts.get(0).Lastname, First_Name__c = contacts.get(0).Firstname, Contact__c = contacts.get(0).Id, 
                                                                                Email__c = contacts.get(0).Email);
        AMS_Accreditation_Contact__c owner3 = new AMS_Accreditation_Contact__c(AMS_Pax_Accreditation_Form__c = onlineAccreditation.Id, Agency_Owner__c = true, Financial_interest__c = 25,
                                                                                RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Person'), 
                                                                                Last_name__c = 'last', First_Name__c = 'first', Contact__c = contacts.get(0).Id, 
                                                                                Email__c = 'first@last.test');
        AMS_Accreditation_Contact__c contact1 = new AMS_Accreditation_Contact__c(AMS_Pax_Accreditation_Form__c = onlineAccreditation.Id, Agency_Owner__c = false,
                                                                                RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Person'), 
                                                                                Last_name__c = 'Not Owner', First_Name__c = 'Just Contact', Email__c = 'justContact@notOwner.test');
        accreditationContacts.add(owner1);
        accreditationContacts.add(owner2);
        accreditationContacts.add(owner3);
        accreditationContacts.add(contact1);
        insert accreditationContacts;

        Test.startTest();

        try{
            AMS_AccountRoleCreator.runRoleCreatorForOnlineAccreditations(new Map<Id,Set<Id>>{onlineAccreditation.Id => new Set<Id>{onlineAccreditation.SAAM_Case__r.AccountId}}, 
                                                                    true, true, oscars, new Map<Id,String>{oscars.values().get(0).Id => oscars.values().get(0).Account__r.Location_Type__c}, 
                                                                    new Map<Id,Id>{oscars.values().get(0).Id => oscars.values().get(0).Account__r.Top_Parent__r.Id == null ? oscars.values().get(0).Account__c : oscars.values().get(0).Account__r.Top_Parent__r.Id});
        } catch(Exception ex) {
            System.assertEquals(true, ex.getMessage().contains('Duplicated Contact with Id:'));
            System.assertEquals('AMS_ApplicationException', ex.getTypeName());
        }
        

        Test.stopTest();
       
    }

    @isTest static void test_personAMS(){
        //get oscar for new application
        Map<Id,AMS_OSCAR__c> oscars = new Map<Id,AMS_OSCAR__c>([SELECT Id, STEP10__c, STEP6__c, Account__c, Account__r.Location_Type__c, Account__r.Top_Parent__r.Id, AMS_Online_Accreditation__c, AMS_Online_Accreditation__r.Id, RecordTypeId, RecordType.DeveloperName, Process__c, Is_PCI_compliant__c FROM AMS_OSCAR__c WHERE Account__r.Name = 'Head Office' LIMIT 1]);
        List<Contact> contacts = [SELECT Id, Email, Firstname, Lastname FROM Contact];
        List<AMS_Person__c> persons = [SELECT Id, Contact__c FROM AMS_Person__c];
        persons.get(0).Contact__c = contacts.get(0).Id;
        persons.get(1).Contact__c = contacts.get(1).Id;
        update persons;
        AMS_Pax_Accreditation_Form__c onlineAccreditation = [SELECT id, SAAM_Case__r.AccountId FROM AMS_Pax_Accreditation_Form__c WHERE SAAM_Case__r.AccountId =: oscars.values().get(0).Account__c LIMIT 1];

        oscars.values().get(0).Process__c = AMS_Utils.new_HO;
        oscars.values().get(0).AMS_Online_Accreditation__c = onlineAccreditation.Id;
        update oscars.values();

        List<AMS_Accreditation_Contact__c> accreditationContacts = new List<AMS_Accreditation_Contact__c>();

        AMS_Accreditation_Contact__c owner1 = new AMS_Accreditation_Contact__c(AMS_Pax_Accreditation_Form__c = onlineAccreditation.Id, Agency_Owner__c = true, Financial_interest__c = 25,
                                                                                RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Person'), 
                                                                                Last_name__c = 'last', First_Name__c = 'first', Email__c = 'first@last.test', Person_AMS__c = persons.get(2).Id);
        AMS_Accreditation_Contact__c owner2 = new AMS_Accreditation_Contact__c(AMS_Pax_Accreditation_Form__c = onlineAccreditation.Id, Agency_Owner__c = true, Financial_interest__c = 50,
                                                                                RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Person'), 
                                                                                Last_name__c = contacts.get(0).Lastname, First_Name__c = contacts.get(0).Firstname, Person_AMS__c = persons.get(0).Id,
                                                                                Email__c = contacts.get(0).Email);
        AMS_Accreditation_Contact__c owner3 = new AMS_Accreditation_Contact__c(AMS_Pax_Accreditation_Form__c = onlineAccreditation.Id, Agency_Owner__c = true, Financial_interest__c = 50,
                                                                                RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Person'), 
                                                                                Last_name__c = contacts.get(1).Lastname, First_Name__c = contacts.get(1).Firstname, Person_AMS__c = persons.get(1).Id,
                                                                                Email__c = contacts.get(1).Email, Contact__c = contacts.get(1).Id);
        accreditationContacts.add(owner1);
        accreditationContacts.add(owner2);
        accreditationContacts.add(owner3);
        insert accreditationContacts;

        Test.startTest();

        //step to generate iata code
        AMS_AccountRoleCreator.runRoleCreatorForOnlineAccreditations(new Map<Id,Set<Id>>{onlineAccreditation.Id => new Set<Id>{onlineAccreditation.SAAM_Case__r.AccountId}}, 
                                                                    true, true, oscars, new Map<Id,String>{oscars.values().get(0).Id => oscars.values().get(0).Account__r.Location_Type__c}, 
                                                                    new Map<Id,Id>{oscars.values().get(0).Id => oscars.values().get(0).Account__r.Top_Parent__r.Id == null ? oscars.values().get(0).Account__c : oscars.values().get(0).Account__r.Top_Parent__r.Id});

        List<AMS_Account_Role__c> accountRoles = [SELECT Id, Percentage__c FROM AMS_Account_Role__c WHERE RecordType.DeveloperName = 'Ownership' AND Account__c =: onlineAccreditation.SAAM_Case__r.AccountId];
        List<Contact> contactsAfter = [SELECT Id FROM Contact];
        List<AMS_Person__c> personsAfter = new List<AMS_Person__c>();
        personsAfter = [SELECT Id FROM AMS_Person__c];

        Test.stopTest();

        System.assertEquals(3, accountRoles.size());
        System.assertEquals(4, contactsAfter.size());
        System.assertEquals(true, personsAfter.isEmpty());

    }

    @isTest static void test_accreditationContactLinkedWithNonActiveRole(){

        //get oscar for new application
        Map<Id,AMS_OSCAR__c> oscars = new Map<Id,AMS_OSCAR__c>([SELECT Id, STEP10__c, STEP6__c, Account__c, Account__r.Location_Type__c, Account__r.Top_Parent__r.Id, AMS_Online_Accreditation__c, AMS_Online_Accreditation__r.Id, RecordTypeId, RecordType.DeveloperName, Process__c, Is_PCI_compliant__c FROM AMS_OSCAR__c WHERE Account__r.Name = 'Head Office' LIMIT 1]);
        List<Contact> contacts = [SELECT Id, Email, Firstname, Lastname FROM Contact WHERE AccountId =: oscars.values().get(0).Account__c];
        AMS_Pax_Accreditation_Form__c onlineAccreditation = [SELECT id, SAAM_Case__r.AccountId FROM AMS_Pax_Accreditation_Form__c WHERE SAAM_Case__r.AccountId =: oscars.values().get(0).Account__c LIMIT 1];

        oscars.values().get(0).Process__c = AMS_Utils.new_HO;
        oscars.values().get(0).AMS_Online_Accreditation__c = onlineAccreditation.Id;
        update oscars.values();

        List<AMS_Accreditation_Contact__c> accreditationContacts = new List<AMS_Accreditation_Contact__c>();

        AMS_Accreditation_Contact__c owner = new AMS_Accreditation_Contact__c(AMS_Pax_Accreditation_Form__c = onlineAccreditation.Id, Agency_Owner__c = true, Financial_interest__c = 100,
                                                                                RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Person'), 
                                                                                Last_name__c = contacts.get(0).Lastname, First_Name__c = contacts.get(0).Firstname, Contact__c = contacts.get(0).Id, 
                                                                                Email__c = contacts.get(0).Email);
        insert owner;

        Test.startTest();

        //step to generate iata code
        AMS_AccountRoleCreator.runRoleCreatorForOnlineAccreditations(new Map<Id,Set<Id>>{onlineAccreditation.Id => new Set<Id>{onlineAccreditation.SAAM_Case__r.AccountId}}, 
                                                                    true, true, oscars, new Map<Id,String>{oscars.values().get(0).Id => oscars.values().get(0).Account__r.Location_Type__c}, 
                                                                    new Map<Id,Id>{oscars.values().get(0).Id => oscars.values().get(0).Account__r.Top_Parent__r.Id == null ? oscars.values().get(0).Account__c : oscars.values().get(0).Account__r.Top_Parent__r.Id});

        List<AMS_Account_Role__c> accountRoles = [SELECT Id, Percentage__c FROM AMS_Account_Role__c WHERE RecordType.DeveloperName = 'Ownership' AND Account__c =: onlineAccreditation.SAAM_Case__r.AccountId];

        System.assertEquals(1, accountRoles.size());

        accountRoles.get(0).Termination_Date__c = System.today();
        update accountRoles;

        try{
        //approval step
        AMS_AccountRoleCreator.runRoleCreatorForOnlineAccreditations(new Map<Id,Set<Id>>{onlineAccreditation.Id => new Set<Id>{onlineAccreditation.SAAM_Case__r.AccountId}}, 
                                                                    true, false, oscars, new Map<Id,String>{oscars.values().get(0).Id => oscars.values().get(0).Account__r.Location_Type__c}, 
                                                                    new Map<Id,Id>{oscars.values().get(0).Id => oscars.values().get(0).Account__r.Top_Parent__r.Id == null ? oscars.values().get(0).Account__c : oscars.values().get(0).Account__r.Top_Parent__r.Id});
        } catch(Exception ex){
            System.assertEquals(true, ex.getMessage().contains('Sync Accreditations With Roles went wrong !'));
            System.assertEquals('AMS_ApplicationException', ex.getTypeName());
        }

        Test.stopTest();
       
    }

    @isTest static void test_CORCCCorrectionProcess(){
        
        Test.startTest();
        
        Id correctionOSCARRecTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'CORRECTION');

        Account branch = [SELECT Id, Location_Type__c, Top_Parent__r.Id FROM Account WHERE Name = 'Branch' LIMIT 1];
        delete branch;

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

        AMS_Accreditation_Contact__c owner3 = new AMS_Accreditation_Contact__c(AMS_Pax_Accreditation_Form__c = accre.Id, Agency_Owner__c = true, Financial_interest__c = 100,
                                                                                RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Current_Owner'), 
                                                                                Last_name__c = 'New Owner', First_Name__c = 'New Contact', Email__c = 'newContact@newOwner.test');
        insert owner3;

        oscar.RecordTypeId = correctionOSCARRecTypeId;
        //oscar.AMS_Online_Accreditation__c = aoaList.get(0).Id;

        oscar.AMS_Online_Accreditation__c = accre.Id;
        oscar.Type_of_change__c = AMS_Utils.COR;
        oscar.Process__c = AMS_Utils.COR;
        oscar.STEP6__c = 'Passed';
        oscar.AMS_Correction_change_code__c = 'COR';
        System.debug('test_CADCCCorrectionProcess oscar: ' + oscar);

        update oscar;

        Test.stopTest();
    }

    @isTest static void test_CADCCCorrectionProcess(){
        
        Test.startTest();
        Id correctionOSCARRecTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'CORRECTION');

        AMS_OSCAR__c oscar = [select Id, Account__c, AMS_Online_Accreditation__c from AMS_OSCAR__c where Account__r.Name = 'My Travels' limit 1];

        List<AMS_Pax_Accreditation_Form__c> aoaList = [select Id from AMS_Pax_Accreditation_Form__c limit 1];
        Case c = [SELECT Id FROM Case WHERE Oscar__c = :oscar.Id];

        AMS_Accreditation_Contact__c owner3 = new AMS_Accreditation_Contact__c(AMS_Pax_Accreditation_Form__c = aoaList.get(0).Id, Agency_Owner__c = true, Financial_interest__c = 100,
                                                                                RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Current_Owner'), 
                                                                                Last_name__c = 'New Owner', First_Name__c = 'New Contact', Email__c = 'newContact@newOwner.test');
        insert owner3;

        oscar.RecordTypeId = correctionOSCARRecTypeId;
        oscar.AMS_Online_Accreditation__c = aoaList.get(0).Id;
        oscar.Type_of_change__c = AMS_Utils.COR;
        oscar.Process__c = AMS_Utils.COR;
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

        AMS_Accreditation_Contact__c owner3 = new AMS_Accreditation_Contact__c(AMS_Pax_Accreditation_Form__c = accre.Id, Agency_Owner__c = true, Financial_interest__c = 100,
                                                                                RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Current_Owner'), 
                                                                                Last_name__c = 'New Owner', First_Name__c = 'New Contact', Email__c = 'newContact@newOwner.test');
        insert owner3;

        System.debug('test_CADCCCorrectionProcess accre: ' + accre);

        oscar.RecordTypeId = correctionOSCARRecTypeId;
        //oscar.AMS_Online_Accreditation__c = aoaList.get(0).Id;
        oscar.AMS_Online_Accreditation__c = accre.Id;
        oscar.Type_of_change__c = AMS_Utils.COR;
        oscar.Process__c = AMS_Utils.COR;
        oscar.STEP6__c = 'Passed';
        oscar.AMS_Correction_change_code__c = 'CAD';
        System.debug('test_CADCCCorrectionProcess oscar: ' + oscar);

        update oscar;

        Test.stopTest();
    }

    @isTest static void test_LETCCCorrectionProcess(){
        Test.startTest();
        Id correctionOSCARRecTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'CORRECTION');

        AMS_OSCAR__c oscar = [select AMS_Online_Accreditation__c from AMS_OSCAR__c where Account__r.Name = 'My Travels' limit 1];

        List<AMS_Pax_Accreditation_Form__c> aoaList = [select id from AMS_Pax_Accreditation_Form__c limit 1];

        AMS_Accreditation_Contact__c owner3 = new AMS_Accreditation_Contact__c(AMS_Pax_Accreditation_Form__c = aoaList.get(0).Id, Agency_Owner__c = true, Financial_interest__c = 100,
                                                                                RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Current_Owner'), 
                                                                                Last_name__c = 'New Owner', First_Name__c = 'New Contact', Email__c = 'newContact@newOwner.test');
        insert owner3;

        oscar.RecordTypeId = correctionOSCARRecTypeId;
        oscar.AMS_Online_Accreditation__c = aoaList.get(0).Id;
        oscar.Type_of_change__c = AMS_Utils.COR;
        oscar.Process__c = AMS_Utils.COR;
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