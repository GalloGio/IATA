@isTest
private class ISSP_ModelA_Onboarding_Test {
    
    @testSetup static void setup() {
        IATA_ISO_Country__c portugal = new IATA_ISO_Country__c (Name = 'Portugal_test',
                                                                ISO_Code__c = 'PT',
                                                                ANG_Enable_NewGen__c = true,
                                                                Region__c = 'Europe');
        insert portugal;
        
        AMS_Accreditation_Country_CheckList__c cc = new AMS_Accreditation_Country_CheckList__c(IATA_ISO_Country__c = portugal.id,
                                                                                            Operation__c = 'Travel Agent');
        insert cc;
        
        AMS_Accreditation_Requirement__c ac = new AMS_Accreditation_Requirement__c(
                AMS_Accreditation_Country_CheckList__c = cc.id,
                Name = 'Name1',
                Requirement_text__c = 'Text1',
                Language__c = 'English',
                Type_Of_Agent__c = 'IATA Cargo Agent',
                RecordTypeId = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('AMS_Accreditation_Requirement__c').get('IEP_Model_A'),
                File_to_Upload__c = 'Mandatory',
                File_Identifier2__c = 'REG_CERT');

        Account a = new Account (Name = 'Travel agency',
                                RecordTypeId = AMS_Utils.RECTYPE_IATAAGENCY,
                                IATA_ISO_Country__c = portugal.Id,
                                Region__c = portugal.Region__c,
                                Sector__c = Ams_Utils.SECTOR_PASSENGER,
                                Status__c = Ams_Utils.ACC_S9_APPROVED,
                                Location_type__c = AMS_Utils.HE,
                                ANG_Accreditation_Model__c = AMS_Utils.ACCREDITATIONMODEL_CASH,
                                OwnerId = UserInfo.getUserId(),
                                IATACode__c = '12345678');
        insert a;

        Portal_Applications__c portalApp = new Portal_Applications__c(Name = 'IATA EasyPay (EDENRED)');
        insert portalApp;

        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = a.Id;
        insert con;

        Portal_Application_Right__c par = new Portal_Application_Right__c(Contact__c = con.Id,
                                                                        Portal_Application__c = portalApp.Id,
                                                                        Right__c = 'Access Granted',
                                                                        ANG_Portal_Service_Role__c = 'IEP Admin');
        insert par;
    }

    @isTest static void testFetchRequirements() {
        Map<Id, Account> accountMap = new Map<Id, Account>([SELECT Id, Name, IATACode__c, BillingCountry, Region_formula__c, ANG_Accreditation_Model__c FROM Account WHERE Name = 'Travel agency']);
        ANG_OscarProcessHelper.createIEPAccountOscar(accountMap);
        Case c = [SELECT Id FROM Case LIMIT 1];
        
        Test.setCurrentPageReference(new PageReference('Page.ISSP_ModelA_Onboarding'));
        System.currentPageReference().getParameters().put('caseId', c.Id);
        
        ISSP_ModelA_Onboarding controller = new ISSP_ModelA_Onboarding();

        //falta criar ficheiro :s

        /*list<AmazonFile__c> listAmazonFile = [
                Select Size_MB__c, Name, Full_Name_Unique__c, CreatedDate, CreatedById, CreatedBy.Name, Case__c , File_Identifier__c
                From AmazonFile__c
                Where Case__c = :caseId
                                             ];*/

        AmazonFile__c file = new AmazonFile__c(Case__c = c.Id, Name = 'Name1');
        
        controller.submitForm();
    }
    
}