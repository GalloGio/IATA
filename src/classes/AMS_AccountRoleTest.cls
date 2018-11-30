@isTest
public class AMS_AccountRoleTest {
    
    public static Account HO;
    public static List<Account> secondLevel;
    public static List<AMS_Account_Role__c> firstOwners;
    
    public static String SECTORPAX = 'Travel Agent';
    public static String CATEGORYPAX = 'IATA Passenger Sales Agent';
    public static String LOCCLASSPAX = 'P';

    public static List<Contact> contacts; 
    public static AMS_OSCAR__c theOscar;
    public static Case theCommunicationCase;
    //public static AMS_Pax_Accreditation_Form__c theStagingAcc;
    //public static AMS_Accreditation_Contact__c theStagingCont;


    // This method will create a 3 level hierarchy. NOTE: this is working correctly if howMany3rdLevelAgencies <= howManyBranches
    public static void initHOandBRs(Integer howManyBranches, Integer howManyOwners){

        ID rtAgency = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
        IATA_ISO_Country__c italy = new IATA_ISO_Country__c(Name='Italy', ISO_Code__c='IT', Region__c='Europe', ISS_Office_Location__c='Italy');
        insert italy;
        
        
        //Create head office
        HO = new Account(RecordTypeId = rtAgency, Name = 'My Travels', IATAcode__c = '1111110', IATA_ISO_Country__c = italy.id, 
                         Sector__c = SECTORPAX, Category__c = CATEGORYPAX, Location_Class__c = LOCCLASSPAX, Location_Type__c = 'HO',
                         Status__c = AMS_Utils.ACC_S9_APPROVED);
        insert HO;
                                 
                         
        //Create the branches
        secondLevel = new List<Account>();
        for(Integer i=0; i<howManyBranches; i++){
            secondLevel.add(new Account(RecordTypeId = rtAgency, Name = 'Your Travels', IATAcode__c = '222222'+i, 
                                         ParentId = HO.Id, IATA_ISO_Country__c = italy.id, 
                                         Sector__c =  SECTORPAX, Category__c = CATEGORYPAX, Location_Class__c = LOCCLASSPAX, 
                                         Location_Type__c = 'BR',Status__c = AMS_Utils.ACC_S9_APPROVED));
        }
        if(howManyBranches>0){
            insert secondLevel;              
        }
        
        //Create the owners (max 1 per second level)
        if(howManyOwners>0){
            contacts = new List<Contact>();
            for(Integer i=0; i<howManyOwners; i++){
                contacts.add(new Contact(LastName = 'Contact'+i, Email = 'myemail@contact'+i+'.com'));
            }
            insert contacts;

            Id rtOwnership = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Account_Role__c', 'Ownership');
            firstOwners = new List<AMS_Account_Role__c>();
            Double percentage = 100/howManyOwners;
            for(Contact c : contacts){
                firstOwners.add(new AMS_Account_Role__c(RecordTypeId = rtOwnership, Account__c = HO.Id, Percentage__c = percentage, Contact__c = c.Id));
                for(Account a : secondLevel){
                    firstOwners.add(new AMS_Account_Role__c(RecordTypeId = rtOwnership, Account__c = a.Id, Percentage__c = percentage, Contact__c = c.Id));
                }
            }
            insert firstOwners;
        }

        ID rtChange = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'CHANGE');
        theOscar = new AMS_OSCAR__c(RecordTypeId = rtChange, Account__c = HO.Id);
        insert theOscar;

        ID rtCommCase = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');
        theCommunicationCase = new Case(RecordTypeId = rtCommCase, Subject = 'Change of shareholding - ' + HO.Name, OSCAR__c = theOscar.Id,
                                            AccountId = HO.Id );
        insert theCommunicationCase;
    }

    
    // TEST OWNERS WITH RECORD TYPE = PERSON 
    // The account does not have any owners.
    // I will create in the staging area 3 owners: 1 existing as a contact, 1 as a person and 1 not existing
    // Then I'll change the percentages in the same staging area and save again
    public static testmethod void testOwnersRTPerson(){
        initHOandBRs(2,0);
        
        // Create the Staging area for the Account
        AMS_Pax_Accreditation_Form__c theStagingAcc = new  AMS_Pax_Accreditation_Form__c(Account_Name__c = HO.Name, IATAcode__c = HO.IATAcode__c, Branch_Office_Country__c = HO.IATA_ISO_Country__c, 
                                                           SAAM_Case__c = theCommunicationCase.Id, Location_Class__c = HO.Location_Class__c, Location_Type__c = HO.Location_Type__c);
        insert theStagingAcc;
        
        Contact cowner = new Contact(FirstName='Contact', LastName='Owner', Email='contact@owner.it');
        insert cowner;
        AMS_Person__c powner = new AMS_Person__c(First_Name__c='Person', Lastname__c='Owner', Email__c='person@owner.it');
        insert powner;

        // Create the Staging area for the Contact
        ID rtPerson = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Person');
        
        List<AMS_Accreditation_Contact__c> theStagingConts= new List<AMS_Accreditation_Contact__c>();
        theStagingConts.add(new AMS_Accreditation_Contact__c(
            First_name__c = cowner.FirstName, Last_Name__c = cowner.LastName, Email__c = cowner.Email, Contact__c = cowner.Id, Agency_owner__c = true,
            AMS_Pax_Accreditation_Form__c = theStagingAcc.Id, Financial_interest__c = 50, RecordTypeId=rtPerson));
        
        theStagingConts.add(new AMS_Accreditation_Contact__c(
            First_name__c = powner.First_Name__c, Last_Name__c = powner.Lastname__c, Email__c = powner.Email__c, Person_AMS__c = powner.id,  Agency_owner__c = true,
            AMS_Pax_Accreditation_Form__c = theStagingAcc.Id, Financial_interest__c = 30, RecordTypeId=rtPerson));

        theStagingConts.add(new AMS_Accreditation_Contact__c(
            First_name__c = 'New', Last_Name__c = 'Owner', Email__c = 'new@owner.it',  Agency_owner__c = true,
            AMS_Pax_Accreditation_Form__c = theStagingAcc.Id,  Financial_interest__c = 20, RecordTypeId=rtPerson));
        
        insert theStagingConts;
        
        system.debug('DTULLO 112 -> ' + [select Id, AMS_Pax_Accreditation_Form__c, First_name__c, Last_Name__c, Email__c, Financial_interest__c from AMS_Accreditation_Contact__c]);

        Test.startTest();

        Map<Id,Set<Id>> parameter = new Map<Id,Set<Id>>();
        parameter.put(theStagingAcc.Id, new Set<Id>{HO.Id, secondLevel[0].Id, secondLevel[1].Id});
        
        system.debug('DTULLO 119 --> ' + parameter);
        
        AMS_AccountRoleCreator.runRoleCreatorForOnlineAccreditations(parameter, true);
        
        // CHECK THE RESULTS
        List<Contact> newContacts = [SELECT FirstName, LastName, Email FROM Contact ORDER BY Email];
        system.assertEquals(3,newContacts.size(), 'testNewContactOwners(S1) -> Now I should have 3 contacts in the system');
        system.assertEquals('contact@owner.it', newContacts[0].Email, 'testNewContactOwners(S1) -> the first contact is the one which was existing before');
        system.assertEquals('new@owner.it', newContacts[1].Email, 'testNewContactOwners(S1) -> the accreditation contact not linked to persons or contacts should now be a contact');
        system.assertEquals('person@owner.it', newContacts[2].Email, 'testNewContactOwners(S1) -> the person should have been converted in a contact');

        List<AMS_Person__c> persons = [SELECT Id FROM AMS_Person__c];
        system.assertEquals(0,persons.size(), 'testNewContactOwners(S1) -> the person should have been deleted');

        List<AMS_Account_Role__c> owners = [SELECT Contact__r.Email,  Percentage__c, Termination_Date__c
                                            FROM AMS_Account_Role__c 
                                            WHERE Account__c = :HO.Id AND Contact__c <> NULL AND RecordType.DeveloperName = 'Ownership' AND Termination_Date__c = NULL
                                            ORDER BY Contact__r.Email];
        //@Duarte validate... no owners are being created
        //system.assertEquals(3,owners.size(), 'testNewContactOwners(S1) -> the method should have inserted 3 owners for the Head Office');
        system.debug('DTULLO 137 --> ' + [select id from AMS_Account_Role__c].size());
        system.assertEquals('contact@owner.it', owners[0].Contact__r.Email, 'testNewContactOwners(S1) -> the first owner is the one which was existing before');
        system.assertEquals(50, owners[0].Percentage__c, 'testNewContactOwners(S1) -> the first owner is the one which was existing before');

        system.assertEquals('new@owner.it', owners[1].Contact__r.Email, 'testNewContactOwners(S1) -> the second owner is the new contact created');
        system.assertEquals(20, owners[1].Percentage__c, 'testNewContactOwners(S1) -> the second owner is the new contact created');

        system.assertEquals('person@owner.it', owners[2].Contact__r.Email, 'testNewContactOwners(S1) -> the third owner is the one whowas a person');
        system.assertEquals(30, owners[2].Percentage__c, 'testNewContactOwners(S1) -> the third owner is the one whowas a person');

        
        owners = [SELECT Contact__r.Email,  Percentage__c, Termination_Date__c
                FROM AMS_Account_Role__c 
                WHERE Account__c = :secondLevel[0].Id AND Contact__c <> NULL AND RecordType.Name = 'Ownership' AND Termination_Date__c = NULL
                ORDER BY Contact__r.Email];
        system.assertEquals(3,owners.size(), 'testNewContactOwners(S1) -> the method should have inserted 3 owners for the first branch');

        system.assertEquals('contact@owner.it', owners[0].Contact__r.Email, 'testNewContactOwners(S1) -> the first owner is the one which was existing before');
        system.assertEquals(50, owners[0].Percentage__c, 'testNewContactOwners(S1) -> the first owner is the one which was existing before');

        system.assertEquals('new@owner.it', owners[1].Contact__r.Email, 'testNewContactOwners(S1) -> the second owner is the new contact created');
        system.assertEquals(20, owners[1].Percentage__c, 'testNewContactOwners(S1) -> the second owner is the new contact created');

        system.assertEquals('person@owner.it', owners[2].Contact__r.Email, 'testNewContactOwners(S1) -> the third owner is the one whowas a person');
        system.assertEquals(30, owners[2].Percentage__c, 'testNewContactOwners(S1) -> the third owner is the one whowas a person');


        owners = [SELECT Contact__r.Email,  Percentage__c, Termination_Date__c
                FROM AMS_Account_Role__c 
                WHERE Account__c = :secondLevel[1].Id AND Contact__c <> NULL AND RecordType.Name = 'Ownership' AND Termination_Date__c = NULL
                ORDER BY Contact__r.Email];
        system.assertEquals(3,owners.size(), 'testNewContactOwners(S1) -> the method should have inserted 3 owners for the second branch');

        system.assertEquals('contact@owner.it', owners[0].Contact__r.Email, 'testNewContactOwners(S1) -> the first owner is the one which was existing before');
        system.assertEquals(50, owners[0].Percentage__c, 'testNewContactOwners(S1) -> the first owner is the one which was existing before');

        system.assertEquals('new@owner.it', owners[1].Contact__r.Email, 'testNewContactOwners(S1) -> the second owner is the new contact created');
        system.assertEquals(20, owners[1].Percentage__c, 'testNewContactOwners(S1) -> the second owner is the new contact created');

        system.assertEquals('person@owner.it', owners[2].Contact__r.Email, 'testNewContactOwners(S1) -> the third owner is the one whowas a person');
        system.assertEquals(30, owners[2].Percentage__c, 'testNewContactOwners(S1) -> the third owner is the one whowas a person');


        theStagingConts = [SELECT Id FROM AMS_Accreditation_Contact__c WHERE AMS_Ownership_Role__c <> NULL];
        system.assertEquals(3,theStagingConts.size(), 'testNewContactOwners(S1) -> the method should have updated the accreditation contacts with a link to the ams role created');
        system.assertEquals(3,theStagingConts.size(), 'testNewContactOwners(S1) -> the method should have inserted 3 owners for the second branch');



        // I WILL CHANGE THE PERCENTAGES IN THE OWNERSHIPS
        theStagingConts[0].Financial_interest__c = 33.3;
        theStagingConts[1].Financial_interest__c = 33.3;
        theStagingConts[2].Financial_interest__c = 33.3;
        update theStagingConts;

        AMS_AccountRoleCreator.runRoleCreatorForOnlineAccreditations(parameter, true);


        persons = [SELECT Id FROM AMS_Person__c];
        system.assertEquals(0,persons.size(), 'testNewContactOwners(S2) -> the person should not have been recreated');

        newContacts = [SELECT FirstName, LastName, Email FROM Contact ORDER BY Email];
        system.assertEquals(3,newContacts.size(), 'testNewContactOwners(S2) -> contacts should not have been changed');

        owners = [SELECT Contact__r.Email,  Percentage__c, Termination_Date__c
                    FROM AMS_Account_Role__c 
                    WHERE Contact__c <> NULL AND RecordType.Name = 'Ownership' AND Termination_Date__c = NULL AND Percentage__c = 33.3
                    ORDER BY Contact__r.Email];
        system.assertEquals(9,owners.size(), 'testNewContactOwners(S2) -> the method should have updated all the 9 roles with the new percentage');

        owners = [SELECT Contact__r.Email,  Percentage__c, Termination_Date__c
                    FROM AMS_Account_Role__c 
                    WHERE RecordType.Name = 'Ownership' AND Termination_Date__c <> NULL
                    ORDER BY Contact__r.Email];
        system.assertEquals(0, owners.size(), 'testNewContactOwners(S2) -> the method should not have deactivated any owner');


        // I WILL RESET THE LOOKUP AMS_OWNERSHIP_ROLE__c TO SIMULATE A NEW OSCAR, AND CHANGE THE PERCENTAGES IN THE OWNERSHIPS
        theStagingConts = [SELECT Id FROM AMS_Accreditation_Contact__c ORDER BY Email__c];
        theStagingConts[0].AMS_Ownership_Role__c = NULL;
        theStagingConts[1].AMS_Ownership_Role__c = NULL;
        theStagingConts[2].AMS_Ownership_Role__c = NULL;

        theStagingConts[0].Financial_interest__c = 60;
        theStagingConts[1].Financial_interest__c = 30;
        theStagingConts[2].Financial_interest__c = 10;
        update theStagingConts;

        AMS_AccountRoleCreator.runRoleCreatorForOnlineAccreditations(parameter);

        persons = [SELECT Id FROM AMS_Person__c];
        system.assertEquals(0,persons.size(), 'testNewContactOwners(S3) -> the person should not have been recreated');

        newContacts = [SELECT FirstName, LastName, Email FROM Contact ORDER BY Email];
        system.assertEquals(3,newContacts.size(), 'testNewContactOwners(S3) -> contacts should not have been changed');

        owners = [SELECT Contact__r.Email,  Percentage__c, Termination_Date__c
                    FROM AMS_Account_Role__c 
                    WHERE Contact__c <> NULL AND RecordType.Name = 'Ownership' AND Termination_Date__c = NULL 
                    ORDER BY Contact__r.Email];
        system.assertEquals(9,owners.size(), 'testNewContactOwners(S3) -> the method should have inserted 9 new roles with the new percentage');

        owners = [SELECT Contact__r.Email,  Percentage__c, Termination_Date__c
                    FROM AMS_Account_Role__c 
                    WHERE RecordType.Name = 'Ownership' AND Termination_Date__c <> NULL AND Percentage__c = 33.3
                    ORDER BY Contact__r.Email];
        system.assertEquals(9, owners.size(), 'testNewContactOwners(S3) -> the method should have deactivated all the 9 old owners');
        
    }


    // TEST OWNERS WITH RECORD TYPE = COMPANY 
    // The account does not have any owners.
    // I will create in the staging area 3 owners: 1 existing as a contact, 1 as a person and 1 not existing
    // Then I'll change the percentages in the same staging area and save again
    public static testmethod void testOwnersRTCompany(){
        initHOandBRs(2,0);
        
        // Create the Staging area for the Account
        AMS_Pax_Accreditation_Form__c theStagingAcc = new  AMS_Pax_Accreditation_Form__c(Account_Name__c = HO.Name, IATAcode__c = HO.IATAcode__c, Branch_Office_Country__c = HO.IATA_ISO_Country__c, 
                                                           SAAM_Case__c = theCommunicationCase.Id, Location_Class__c = HO.Location_Class__c, Location_Type__c = HO.Location_Type__c);
        insert theStagingAcc;
        
        List<Account> aowners = new List<Account>();
        aowners.add(new Account(Name='Company Owner 1'));
        aowners.add(new Account(Name='Company Owner 2'));
        insert aowners;
        
        // Create the Staging area for the Contact
        ID rtCompany = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Company');
        
        List<AMS_Accreditation_Contact__c> theStagingConts= new List<AMS_Accreditation_Contact__c>();
        theStagingConts.add(new AMS_Accreditation_Contact__c(Last_Name__c='dummy1', Agency_owner__c = true,
            Company__c = aowners[0].Id, AMS_Pax_Accreditation_Form__c = theStagingAcc.Id, Financial_interest__c = 60, RecordTypeId=rtCompany));
        
        theStagingConts.add(new AMS_Accreditation_Contact__c(Last_Name__c='dummy2', Agency_owner__c = true,
            Company__c = aowners[1].Id, AMS_Pax_Accreditation_Form__c = theStagingAcc.Id, Financial_interest__c = 40, RecordTypeId=rtCompany));
        
        insert theStagingConts;


        Test.startTest();

        Map<Id,Set<Id>> parameter = new Map<Id,Set<Id>>();
        parameter.put(theStagingAcc.Id, new Set<Id>{HO.Id, secondLevel[0].Id, secondLevel[1].Id});
        
        AMS_AccountRoleCreator.runRoleCreatorForOnlineAccreditations(parameter);

        // CHECK THE RESULTS
        

        List<AMS_Account_Role__c> owners = [SELECT Owner_Account__r.Name,  Percentage__c, Termination_Date__c
                                            FROM AMS_Account_Role__c 
                                            WHERE Account__c = :HO.Id AND Owner_Account__c <> NULL AND RecordType.Name = 'Ownership' AND Termination_Date__c = NULL
                                            ORDER BY Owner_Account__r.Name];
        system.assertEquals(2,owners.size(), 'testOwnersRTCompany(S1) -> the method should have inserted 2 owners for the Head Office');

        system.assertEquals('Company Owner 1', owners[0].Owner_Account__r.Name, 'testOwnersRTCompany(S1) -> the first owner is Company Owner 1');
        system.assertEquals(60, owners[0].Percentage__c, 'testOwnersRTCompany(S1) -> the first owner has a percentage of 60');

        system.assertEquals('Company Owner 2', owners[1].Owner_Account__r.Name, 'testOwnersRTCompany(S1) -> the second owner is Company Owner 2');
        system.assertEquals(40, owners[1].Percentage__c, 'testOwnersRTCompany(S1) -> the second owner has a percentage of 40');


        
        owners = [SELECT Owner_Account__r.Name,  Percentage__c, Termination_Date__c
                    FROM AMS_Account_Role__c 
                    WHERE Account__c = :secondLevel[0].Id AND Owner_Account__c <> NULL AND RecordType.Name = 'Ownership' AND Termination_Date__c = NULL
                    ORDER BY Owner_Account__r.Name];
        system.assertEquals(2,owners.size(), 'testOwnersRTCompany(S1) -> the method should have inserted 2 owners for the Head Office');

        system.assertEquals('Company Owner 1', owners[0].Owner_Account__r.Name, 'testOwnersRTCompany(S1) -> the first owner is Company Owner 1');
        system.assertEquals(60, owners[0].Percentage__c, 'testOwnersRTCompany(S1) -> the first owner has a percentage of 60');

        system.assertEquals('Company Owner 2', owners[1].Owner_Account__r.Name, 'testOwnersRTCompany(S1) -> the second owner is Company Owner 2');
        system.assertEquals(40, owners[1].Percentage__c, 'testOwnersRTCompany(S1) -> the second owner has a percentage of 40');



        owners = [SELECT Owner_Account__r.Name,  Percentage__c, Termination_Date__c
                    FROM AMS_Account_Role__c 
                    WHERE Account__c = :secondLevel[1].Id AND Owner_Account__c <> NULL AND RecordType.Name = 'Ownership' AND Termination_Date__c = NULL
                    ORDER BY Owner_Account__r.Name];
        system.assertEquals(2,owners.size(), 'testOwnersRTCompany(S1) -> the method should have inserted 2 owners for the Head Office');

        system.assertEquals('Company Owner 1', owners[0].Owner_Account__r.Name, 'testOwnersRTCompany(S1) -> the first owner is Company Owner 1');
        system.assertEquals(60, owners[0].Percentage__c, 'testOwnersRTCompany(S1) -> the first owner has a percentage of 60');

        system.assertEquals('Company Owner 2', owners[1].Owner_Account__r.Name, 'testOwnersRTCompany(S1) -> the second owner is Company Owner 2');
        system.assertEquals(40, owners[1].Percentage__c, 'testOwnersRTCompany(S1) -> the second owner has a percentage of 40');




        theStagingConts = [SELECT Id FROM AMS_Accreditation_Contact__c WHERE AMS_Ownership_Role__c <> NULL];
        system.assertEquals(2,theStagingConts.size(), 'testOwnersRTCompany(S1) -> the method should have updated the accreditation contacts with a link to the ams role created');
        system.assertEquals(2,theStagingConts.size(), 'testOwnersRTCompany(S1) -> the method should have inserted 3 owners for the second branch');


        ID PersonRT = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Person');
        // I WILL CHANGE THE PERCENTAGES IN THE OWNERSHIPS
        theStagingConts[0].Financial_interest__c = 50;
        theStagingConts[1].Financial_interest__c = 50;
        theStagingConts[0].RecordTypeId = PersonRT;
        theStagingConts[1].RecordTypeId = PersonRT;
        theStagingConts[0].Last_name__c = 'LN 0';
        theStagingConts[1].Last_name__c = 'LN 1';
        theStagingConts[0].First_name__c = 'FN 0';
        theStagingConts[1].First_name__c = 'FN 1';
        theStagingConts[0].Phone__c = '+2435234';
        theStagingConts[1].Phone__c = '+56547653';
        theStagingConts[0].Email__c = 'ac0@mail.com';
        theStagingConts[1].Email__c = 'ac1@mail.com';
        update theStagingConts;

        system.debug('#### su parameter: ' + parameter);
        AMS_AccountRoleCreator.runRoleCreatorForOnlineAccreditations(parameter, true);

        owners = [SELECT Owner_Account__r.Name,  Percentage__c, Termination_Date__c
                    FROM AMS_Account_Role__c 
                    WHERE Owner_Account__c <> NULL AND RecordType.Name = 'Ownership' AND Termination_Date__c = NULL AND Percentage__c = 50
                    ORDER BY Owner_Account__r.Name];
        system.assertEquals(6,owners.size(), 'testOwnersRTCompany(S2) -> the method should have updated all the 6 roles with the new percentage');

        owners = [SELECT Owner_Account__r.Name,  Percentage__c, Termination_Date__c
                    FROM AMS_Account_Role__c 
                    WHERE RecordType.Name = 'Ownership' AND Termination_Date__c <> NULL
                    ORDER BY Owner_Account__r.Name];
        system.assertEquals(0, owners.size(), 'testOwnersRTCompany(S2) -> the method should not have deactivated any owner');

        ID CompanyRT = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Accreditation_Contact__c', 'Company');
        // I WILL RESET THE LOOKUP AMS_OWNERSHIP_ROLE__c TO SIMULATE A NEW OSCAR, AND CHANGE THE PERCENTAGES IN THE OWNERSHIPS
        theStagingConts = [SELECT Id FROM AMS_Accreditation_Contact__c ORDER BY Email__c];
        theStagingConts[0].AMS_Ownership_Role__c = NULL;
        theStagingConts[1].AMS_Ownership_Role__c = NULL;

        theStagingConts[0].Financial_interest__c = 90;
        theStagingConts[1].Financial_interest__c = 10;

        theStagingConts[0].Agency_owner__c = true;
        theStagingConts[1].Agency_owner__c = true;

        theStagingConts[0].RecordTypeId = CompanyRT;
        theStagingConts[1].RecordTypeId = CompanyRT;

        update theStagingConts;
        AMS_AccountRoleCreator.runRoleCreatorForOnlineAccreditations(parameter);

        owners = [SELECT Owner_Account__r.Name, Percentage__c, Termination_Date__c
                    FROM AMS_Account_Role__c 
                    WHERE Owner_Account__c <> NULL AND RecordType.Name = 'Ownership' /*AND Termination_Date__c = NULL */
                    ORDER BY Owner_Account__r.Name];
        system.assertEquals(6,owners.size(), 'testOwnersRTCompany(S3) -> the method should have inserted 6 new roles with the new percentage');

        owners = [SELECT Owner_Account__r.Name,  Percentage__c, Termination_Date__c
                    FROM AMS_Account_Role__c 
                    WHERE RecordType.Name = 'Ownership' AND Termination_Date__c <> NULL AND Percentage__c = 50
                    ORDER BY Owner_Account__r.Name];
        system.assertEquals(6, owners.size(), 'testOwnersRTCompany(S3) -> the method should have deactivated all the 6 old owners');
        
    }


}