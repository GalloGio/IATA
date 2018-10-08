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

        IATA_ISO_Country__c algeria = new IATA_ISO_Country__c (Name = 'Algeria_test',
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
        
        IATA_ISO_Country__c error = new IATA_ISO_Country__c (Name = 'Error_test',
                                                                ISO_Code__c = 'ER',
                                                                ANG_Enable_NewGen__c = true,
                                                                Region__c = 'Europe');
        countries.add(portugal);
        countries.add(argentina);
        countries.add(algeria);
        countries.add(china);
        countries.add(australia);
        countries.add(error);

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
        
        AMS_Accreditation_Country_CheckList__c cc6 = new AMS_Accreditation_Country_CheckList__c(IATA_ISO_Country__c = error.id,
                                                                                            Operation__c = 'Travel Agent');
        checklists.add(cc1);
        checklists.add(cc2);
        checklists.add(cc3);
        checklists.add(cc4);
        checklists.add(cc5);
        checklists.add(cc6);

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
        
        AMS_Accreditation_Requirement__c ac6 = new AMS_Accreditation_Requirement__c(AMS_Accreditation_Country_CheckList__c = cc6.Id,
                                                                                    Name = 'Name1',
                                                                                    Requirement_text__c = 'Text1',
                                                                                    Language__c = 'English',
                                                                                    Type_Of_Agent__c = 'IATA Travel Agent',
                                                                                    RecordTypeId = AMS_Utils.RECTYPE_IEP_MODEL_A,
                                                                                    File_to_Upload__c = 'Mandatory',
                                                                                    File_Identifier2__c = 'REG_CERT');

        requirements.add(ac1);
        requirements.add(ac2);
        requirements.add(ac3);
        requirements.add(ac4);
        requirements.add(ac5);
        requirements.add(ac6);
        
        insert requirements;

        List<Account> accounts = new List<Account>();

        Account a1 = new Account (Name = 'Travel Portugal',
                                RecordTypeId = AMS_Utils.RECTYPE_IATAAGENCY,
                                IATA_ISO_Country__c = portugal.Id,
                                Region__c = portugal.Region__c,
                                Sector__c = Ams_Utils.SECTOR_PASSENGER,
                                Status__c = Ams_Utils.ACC_S9_APPROVED,
                                Location_type__c = AMS_Utils.HE,
                                Location_class__c = 'P',
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
                                Location_class__c = 'P',
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
                                Location_class__c = 'P',
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
                                Location_class__c = 'P',
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
                                Location_class__c = 'P',
                                ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_CASH,
                                OwnerId = UserInfo.getUserId(),
                                IATACode__c = '12345645');
        
        Account a6 = new Account (Name = 'Travel Error',
                                RecordTypeId = AMS_Utils.RECTYPE_IATAAGENCY,
                                IATA_ISO_Country__c = error.Id,
                                Region__c = error.Region__c,
                                Sector__c = Ams_Utils.SECTOR_PASSENGER,
                                Status__c = Ams_Utils.ACC_S9_APPROVED,
                                Location_type__c = AMS_Utils.HE,
                                Location_class__c = 'P',
                                ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_CASH,
                                OwnerId = UserInfo.getUserId(),
                                IATACode__c = '12345644');

        accounts.add(a1);
        accounts.add(a2);
        accounts.add(a3);
        accounts.add(a4);
        accounts.add(a5);
        accounts.add(a6);

        insert accounts;

        Portal_Applications__c portalApp = new Portal_Applications__c(Name = 'IATA EasyPay (EDENRED)');
        insert portalApp;

        List<Contact> contacts = new List<Contact>();

        Contact con1 = ISSP_ObjectFactory.createNewContact();
        con1.AccountId = a1.Id;

        Contact con2 = ISSP_ObjectFactory.createNewContact();
        con2.AccountId = a2.Id;

        Contact con3 = ISSP_ObjectFactory.createNewContact();
        con3.AccountId = a3.Id;

        Contact con4 = ISSP_ObjectFactory.createNewContact();
        con4.AccountId = a4.Id;

        Contact con5 = ISSP_ObjectFactory.createNewContact();
        con5.AccountId = a5.Id;
        
        Contact con6 = ISSP_ObjectFactory.createNewContact();
        con6.AccountId = a6.Id;

        contacts.add(con1);
        contacts.add(con2);
        contacts.add(con3);
        contacts.add(con4);
        contacts.add(con5);
        contacts.add(con6);

        insert contacts;

        List<Portal_Application_Right__c> rights = new List<Portal_Application_Right__c>();

        Portal_Application_Right__c par1 = new Portal_Application_Right__c(Contact__c = con1.Id,
                                                                        Portal_Application__c = portalApp.Id,
                                                                        Right__c = 'Access Granted',
                                                                        ANG_Portal_Service_Role__c = 'IEP Admin');

        Portal_Application_Right__c par2 = new Portal_Application_Right__c(Contact__c = con2.Id,
                                                                        Portal_Application__c = portalApp.Id,
                                                                        Right__c = 'Access Granted',
                                                                        ANG_Portal_Service_Role__c = 'IEP Admin');

        Portal_Application_Right__c par3 = new Portal_Application_Right__c(Contact__c = con3.Id,
                                                                        Portal_Application__c = portalApp.Id,
                                                                        Right__c = 'Access Granted',
                                                                        ANG_Portal_Service_Role__c = 'IEP Admin');

        Portal_Application_Right__c par4 = new Portal_Application_Right__c(Contact__c = con4.Id,
                                                                        Portal_Application__c = portalApp.Id,
                                                                        Right__c = 'Access Granted',
                                                                        ANG_Portal_Service_Role__c = 'IEP Admin');

        Portal_Application_Right__c par5 = new Portal_Application_Right__c(Contact__c = con5.Id,
                                                                        Portal_Application__c = portalApp.Id,
                                                                        Right__c = 'Access Granted',
                                                                        ANG_Portal_Service_Role__c = 'IEP Admin');
        
        Portal_Application_Right__c par6 = new Portal_Application_Right__c(Contact__c = con6.Id,
                                                                        Portal_Application__c = portalApp.Id,
                                                                        Right__c = 'Access Granted',
                                                                        ANG_Portal_Service_Role__c = 'IEP Admin');
        
        rights.add(par1);
        rights.add(par2);
        rights.add(par3);
        rights.add(par4);
        rights.add(par5);
        rights.add(par6);

        insert rights;
    }

    @isTest static void testFetchRequirementsEurope() {
        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, Name, IATACode__c, BillingCountry, Region_formula__c, ANG_Accreditation_Model__c FROM Account WHERE Name = 'Travel Portugal']);
        ANG_OscarProcessHelper.createIEPAccountOscar(accountMap, 'A');
        Case c = [SELECT Id FROM Case LIMIT 1];
        
        Test.setCurrentPageReference(new PageReference('Page.ISSP_ModelA_Onboarding'));
        System.currentPageReference().getParameters().put('caseId', c.Id);
        
        Test.startTest();
        
        ISSP_ModelA_Onboarding controller = new ISSP_ModelA_Onboarding();
        controller.submitForm();
        
        Group groupResult = [SELECT Id, Name FROM Group WHERE Type = 'Queue' AND Id IN (SELECT OwnerId FROM Case)];
        System.assertEquals('Agency Management - Europe', groupResult.Name);

        Test.stopTest();
    }
    
    @isTest static void testFetchRequirementsAmericas() {
        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, Name, IATACode__c, BillingCountry, Region_formula__c, ANG_Accreditation_Model__c FROM Account WHERE Name = 'Travel Argentina']);
        ANG_OscarProcessHelper.createIEPAccountOscar(accountMap, 'A');
        Case c = [SELECT Id FROM Case LIMIT 1];
        
        Test.setCurrentPageReference(new PageReference('Page.ISSP_ModelA_Onboarding'));
        System.currentPageReference().getParameters().put('caseId', c.Id);
        
        Test.startTest();
        
        ISSP_ModelA_Onboarding controller = new ISSP_ModelA_Onboarding();
        controller.submitForm();
        
        Group groupResult = [SELECT Id, Name FROM Group WHERE Type = 'Queue' AND Id IN (SELECT OwnerId FROM Case)];
        System.assertEquals('Agency Management - Americas', groupResult.Name);

        Test.stopTest();
    }

    @isTest static void testFetchRequirementsAfrica() {
        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, Name, IATACode__c, BillingCountry, Region_formula__c, ANG_Accreditation_Model__c FROM Account WHERE Name = 'Travel Algeria']);
        ANG_OscarProcessHelper.createIEPAccountOscar(accountMap, 'A');
        Case c = [SELECT Id FROM Case LIMIT 1];
        
        Test.setCurrentPageReference(new PageReference('Page.ISSP_ModelA_Onboarding'));
        System.currentPageReference().getParameters().put('caseId', c.Id);
        
        Test.startTest();
        
        ISSP_ModelA_Onboarding controller = new ISSP_ModelA_Onboarding();
        controller.submitForm();
        
        Group groupResult = [SELECT Id, Name FROM Group WHERE Type = 'Queue' AND Id IN (SELECT OwnerId FROM Case)];
        System.assertEquals('Agency Management - Africa & ME', groupResult.Name);

        Test.stopTest();
    }

    @isTest static void testFetchRequirementsChina() {
        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, Name, IATACode__c, BillingCountry, Region_formula__c, ANG_Accreditation_Model__c FROM Account WHERE Name = 'Travel China']);
        ANG_OscarProcessHelper.createIEPAccountOscar(accountMap, 'A');
        Case c = [SELECT Id FROM Case LIMIT 1];
        
        Test.setCurrentPageReference(new PageReference('Page.ISSP_ModelA_Onboarding'));
        System.currentPageReference().getParameters().put('caseId', c.Id);
        
        Test.startTest();
        
        ISSP_ModelA_Onboarding controller = new ISSP_ModelA_Onboarding();
        controller.submitForm();
        
        Group groupResult = [SELECT Id, Name FROM Group WHERE Type = 'Queue' AND Id IN (SELECT OwnerId FROM Case)];
        System.assertEquals('Agency Management - China & N. Asia', groupResult.Name);

        Test.stopTest();
    }

    @isTest static void testFetchRequirementsAsia() {
        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, Name, IATACode__c, BillingCountry, Region_formula__c, ANG_Accreditation_Model__c FROM Account WHERE Name = 'Travel Australia']);
        ANG_OscarProcessHelper.createIEPAccountOscar(accountMap, 'A');
        Case c = [SELECT Id FROM Case LIMIT 1];
        
        Test.setCurrentPageReference(new PageReference('Page.ISSP_ModelA_Onboarding'));
        System.currentPageReference().getParameters().put('caseId', c.Id);
        
        Test.startTest();
        
        ISSP_ModelA_Onboarding controller = new ISSP_ModelA_Onboarding();
        controller.submitForm();
        
        Group groupResult = [SELECT Id, Name FROM Group WHERE Type = 'Queue' AND Id IN (SELECT OwnerId FROM Case)];
        System.assertEquals('Agency Management - A&P', groupResult.Name);

        Test.stopTest();
    }
    
    @isTest static void testError() {
        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, Name, IATACode__c, BillingCountry, Region_formula__c, ANG_Accreditation_Model__c FROM Account WHERE Name = 'Travel Error']);
        ANG_OscarProcessHelper.createIEPAccountOscar(accountMap, 'A' );
        Case c = [SELECT Id FROM Case LIMIT 1];
        
        Test.setCurrentPageReference(new PageReference('Page.ISSP_ModelA_Onboarding'));
        System.currentPageReference().getParameters().put('caseId', c.Id);
        
        Test.startTest();
        
        ISSP_ModelA_Onboarding controller = new ISSP_ModelA_Onboarding();
        controller.submitForm();
        controller.cancel();
        
        Group groupResult = [SELECT Id, Name FROM Group WHERE Type = 'Queue' AND Id IN (SELECT OwnerId FROM Case)];
        System.assertEquals('Model A Onboarding - Europe', groupResult.Name);
        
        Test.stopTest();
    }
    
}