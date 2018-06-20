@isTest
private class ISSP_ModelA_Onboarding_Test {
    
    @testSetup static void setup() {
        List<IATA_ISO_Country__c> countries = new List<IATA_ISO_Country__c>();

        IATA_ISO_Country__c portugal = new IATA_ISO_Country__c (Name = 'Portugal_test',
                                                                ISO_Code__c = 'PT',
                                                                ANG_Enable_NewGen__c = true,
                                                                Region__c = 'Europe');

        IATA_ISO_Country__c argentina = new IATA_ISO_Country__c (Name = 'Argentina_test',
                                                                ISO_Code__c = 'AR',
                                                                ANG_Enable_NewGen__c = true,
                                                                Region__c = 'Americas');

        IATA_ISO_Country__c algeria = new IATA_ISO_Country__c (Name = 'Alegria_test',
                                                                ISO_Code__c = 'DZ',
                                                                ANG_Enable_NewGen__c = true,
                                                                Region__c = 'Africa & Middle East');

        IATA_ISO_Country__c china = new IATA_ISO_Country__c (Name = 'China_test',
                                                                ISO_Code__c = 'CN',
                                                                ANG_Enable_NewGen__c = true,
                                                                Region__c = 'China & North Asia');

        IATA_ISO_Country__c australia = new IATA_ISO_Country__c (Name = 'Australia_test',
                                                                ISO_Code__c = 'AU',
                                                                ANG_Enable_NewGen__c = true,
                                                                Region__c = 'Asia & Pacific');
        countries.add(portugal);
        countries.add(argentina);
        countries.add(algeria);
        countries.add(china);
        countries.add(australia);

        insert countries;

        List<AMS_Accreditation_Country_CheckList__c> checklists = new List<AMS_Accreditation_Country_CheckList__c>();
        
        AMS_Accreditation_Country_CheckList__c cc1 = new AMS_Accreditation_Country_CheckList__c(IATA_ISO_Country__c = portugal.id,
                                                                                            Operation__c = 'Travel Agent');

        AMS_Accreditation_Country_CheckList__c cc2 = new AMS_Accreditation_Country_CheckList__c(IATA_ISO_Country__c = argentina.id,
                                                                                            Operation__c = 'Travel Agent');

        AMS_Accreditation_Country_CheckList__c cc3 = new AMS_Accreditation_Country_CheckList__c(IATA_ISO_Country__c = algeria.id,
                                                                                            Operation__c = 'Travel Agent');

        AMS_Accreditation_Country_CheckList__c cc4 = new AMS_Accreditation_Country_CheckList__c(IATA_ISO_Country__c = china.id,
                                                                                            Operation__c = 'Travel Agent');

        AMS_Accreditation_Country_CheckList__c cc5 = new AMS_Accreditation_Country_CheckList__c(IATA_ISO_Country__c = australia.id,
                                                                                            Operation__c = 'Travel Agent');
        checklists.add(cc1);
        checklists.add(cc2);
        checklists.add(cc3);
        checklists.add(cc4);
        checklists.add(cc5);

        insert checklists;

        List<AMS_Accreditation_Requirement__c> requirements = new List<AMS_Accreditation_Requirement__c>();
        
        AMS_Accreditation_Requirement__c ac1 = new AMS_Accreditation_Requirement__c(AMS_Accreditation_Country_CheckList__c = cc1.Id,
                                                                                    Name = 'Name1',
                                                                                    Requirement_text__c = 'Text1',
                                                                                    Language__c = 'English',
                                                                                    Type_Of_Agent__c = 'IATA Travel Agent',
                                                                                    RecordTypeId = AMS_Utils.RECTYPE_IEP_MODEL_A,
                                                                                    File_to_Upload__c = 'Optional',
                                                                                    File_Identifier2__c = 'REG_CERT');

        AMS_Accreditation_Requirement__c ac2 = new AMS_Accreditation_Requirement__c(AMS_Accreditation_Country_CheckList__c = cc2.Id,
                                                                                    Name = 'Name1',
                                                                                    Requirement_text__c = 'Text1',
                                                                                    Language__c = 'English',
                                                                                    Type_Of_Agent__c = 'IATA Travel Agent',
                                                                                    RecordTypeId = AMS_Utils.RECTYPE_IEP_MODEL_A,
                                                                                    File_to_Upload__c = 'Optional',
                                                                                    File_Identifier2__c = 'REG_CERT');

        AMS_Accreditation_Requirement__c ac3 = new AMS_Accreditation_Requirement__c(AMS_Accreditation_Country_CheckList__c = cc3.Id,
                                                                                    Name = 'Name1',
                                                                                    Requirement_text__c = 'Text1',
                                                                                    Language__c = 'English',
                                                                                    Type_Of_Agent__c = 'IATA Travel Agent',
                                                                                    RecordTypeId = AMS_Utils.RECTYPE_IEP_MODEL_A,
                                                                                    File_to_Upload__c = 'Optional',
                                                                                    File_Identifier2__c = 'REG_CERT');

        AMS_Accreditation_Requirement__c ac4 = new AMS_Accreditation_Requirement__c(AMS_Accreditation_Country_CheckList__c = cc4.Id,
                                                                                    Name = 'Name1',
                                                                                    Requirement_text__c = 'Text1',
                                                                                    Language__c = 'English',
                                                                                    Type_Of_Agent__c = 'IATA Travel Agent',
                                                                                    RecordTypeId = AMS_Utils.RECTYPE_IEP_MODEL_A,
                                                                                    File_to_Upload__c = 'Optional',
                                                                                    File_Identifier2__c = 'REG_CERT');

        AMS_Accreditation_Requirement__c ac5 = new AMS_Accreditation_Requirement__c(AMS_Accreditation_Country_CheckList__c = cc5.Id,
                                                                                    Name = 'Name1',
                                                                                    Requirement_text__c = 'Text1',
                                                                                    Language__c = 'English',
                                                                                    Type_Of_Agent__c = 'IATA Travel Agent',
                                                                                    RecordTypeId = AMS_Utils.RECTYPE_IEP_MODEL_A,
                                                                                    File_to_Upload__c = 'Optional',
                                                                                    File_Identifier2__c = 'REG_CERT');

        requirements.add(ac1);
        requirements.add(ac2);
        requirements.add(ac3);
        requirements.add(ac4);
        requirements.add(ac5);
        
        insert requirements;

        List<Account> accounts = new List<Account>();

        Account a1 = new Account (Name = 'Travel Portugal',
                                RecordTypeId = AMS_Utils.RECTYPE_IATAAGENCY,
                                IATA_ISO_Country__c = portugal.Id,
                                Region__c = portugal.Region__c,
                                Sector__c = Ams_Utils.SECTOR_PASSENGER,
                                Status__c = Ams_Utils.ACC_S9_APPROVED,
                                Location_type__c = AMS_Utils.HE,
                                ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_CASH,
                                OwnerId = UserInfo.getUserId(),
                                IATACode__c = '12345678');

        Account a2 = new Account (Name = 'Travel Argentina',
                                RecordTypeId = AMS_Utils.RECTYPE_IATAAGENCY,
                                IATA_ISO_Country__c = argentina.Id,
                                Region__c = argentina.Region__c,
                                Sector__c = Ams_Utils.SECTOR_PASSENGER,
                                Status__c = Ams_Utils.ACC_S9_APPROVED,
                                Location_type__c = AMS_Utils.HE,
                                ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_CASH,
                                OwnerId = UserInfo.getUserId(),
                                IATACode__c = '12345679');

        Account a3 = new Account (Name = 'Travel Algeria',
                                RecordTypeId = AMS_Utils.RECTYPE_IATAAGENCY,
                                IATA_ISO_Country__c = algeria.Id,
                                Region__c = algeria.Region__c,
                                Sector__c = Ams_Utils.SECTOR_PASSENGER,
                                Status__c = Ams_Utils.ACC_S9_APPROVED,
                                Location_type__c = AMS_Utils.HE,
                                ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_CASH,
                                OwnerId = UserInfo.getUserId(),
                                IATACode__c = '12345670');

        Account a4 = new Account (Name = 'Travel China',
                                RecordTypeId = AMS_Utils.RECTYPE_IATAAGENCY,
                                IATA_ISO_Country__c = china.Id,
                                Region__c = china.Region__c,
                                Sector__c = Ams_Utils.SECTOR_PASSENGER,
                                Status__c = Ams_Utils.ACC_S9_APPROVED,
                                Location_type__c = AMS_Utils.HE,
                                ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_CASH,
                                OwnerId = UserInfo.getUserId(),
                                IATACode__c = '12345671');

        Account a5 = new Account (Name = 'Travel Australia',
                                RecordTypeId = AMS_Utils.RECTYPE_IATAAGENCY,
                                IATA_ISO_Country__c = australia.Id,
                                Region__c = australia.Region__c,
                                Sector__c = Ams_Utils.SECTOR_PASSENGER,
                                Status__c = Ams_Utils.ACC_S9_APPROVED,
                                Location_type__c = AMS_Utils.HE,
                                ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_CASH,
                                OwnerId = UserInfo.getUserId(),
                                IATACode__c = '12345672');

        accounts.add(a1);
        accounts.add(a2);
        accounts.add(a3);
        accounts.add(a4);
        accounts.add(a5);

        insert accounts;

        /*Portal_Applications__c portalApp = new Portal_Applications__c(Name = 'IATA EasyPay (EDENRED)');
        insert portalApp;

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = a1.Id;
        insert con;

        Portal_Application_Right__c par = new Portal_Application_Right__c(Contact__c = con.Id,
                                                                        Portal_Application__c = portalApp.Id,
                                                                        Right__c = 'Access Granted',
                                                                        ANG_Portal_Service_Role__c = 'IEP Admin');
        insert par;*/
    }

    @isTest static void testFetchRequirementsEurope() {
        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, Name, IATACode__c, BillingCountry, Region_formula__c, ANG_Accreditation_Model__c FROM Account WHERE Name = 'Travel Portugal']);
        ANG_OscarProcessHelper.createIEPAccountOscar(accountMap);
        Case c = [SELECT Id FROM Case LIMIT 1];
        
        Test.setCurrentPageReference(new PageReference('Page.ISSP_ModelA_Onboarding'));
        System.currentPageReference().getParameters().put('caseId', c.Id);
        
        Test.startTest();
        
        ISSP_ModelA_Onboarding controller = new ISSP_ModelA_Onboarding();
        controller.submitForm();

        Test.stopTest();
    }
    
}