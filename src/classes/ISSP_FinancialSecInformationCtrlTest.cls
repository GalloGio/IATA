@isTest
private class ISSP_FinancialSecInformationCtrlTest {

        @testSetup 
        static void setup() {
                IATA_ISO_Country__c country = new IATA_ISO_Country__c();
                country.Name = 'Portugal';
                country.ISO_Code__c = 'PT';
                country.ISO_Code_Numeric__c = 11;
                insert country;

                Account agency = new Account();
                agency.Name = 'Agency';
                agency.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account','IATA_Agency');
                agency.IATACode__c = '24125';
                agency.Location_Type__c = 'HO';
                agency.Location_Class__c = 'P';
                agency.IATA_ISO_Country__c = country.Id;
                insert agency;

                Contact agencyContact = new Contact();
                agencyContact.FirstName = 'FirstName';
                agencyContact.LastName = 'LastName';
                agencyContact.Email = 'mail@test.com';
                agencyContact.AccountId = agency.Id;
                agencyContact.User_Portal_Status__c = 'Approved Admin';
                insert agencyContact;   

                Case cse = new Case();
                cse.AccountId = agency.Id;
                cse.Status = 'Open';
                cse.Origin = 'IATA Internal User';
                insert cse;

                Id rtGenericFIId = Schema.SObjectType.Financial_Institution__c.getRecordTypeInfosByDeveloperName().get('Generic_FI').getRecordTypeId();
                Id rtCCBankId = Schema.SObjectType.Financial_Institution__c.getRecordTypeInfosByDeveloperName().get('Currency_Center_Bank').getRecordTypeId();

                list<Financial_Institution__c> listFi = new list<Financial_Institution__c>();
                // Generic FI
                Financial_Institution__c fi1 = new Financial_Institution__c();
                fi1.RecordTypeId = rtGenericFIId;
                fi1.Name = 'Bank Test';
                fi1.Region__c = 'Europe';
                fi1.Country__c = 'Portugal';
                fi1.Institution_Type__c = 'Bank';
                // Vurrency Center Bank
                Financial_Institution__c fi2 = new Financial_Institution__c();
                fi2.RecordTypeId = rtCCBankId;
                fi2.Name = 'Bank Test';
                fi2.Region__c = 'Europe';
                fi2.Country__c = 'Portugal';
                fi2.Institution_Type__c = 'Bank';

                listFi.add(fi1);
                listFi.add(fi2);
                insert listFi;

                list<Financial_Security__c> listFs = new list<Financial_Security__c>();

                Financial_Security__c fs1 = new Financial_Security__c();
                fs1.Region__c = 'Europe';
                fs1.Security_Status__c = 'Active';
                fs1.Security_Type__c = 'CCG';
                fs1.Account__c = agency.Id;
                fs1.Amount__c = 10000;
                fs1.Financial_Institution__c = fi1.Id;
                fs1.Reception_Case__c = cse.Id;
                fs1.Reception_Date__c = Date.today();
                fs1.Reasonforrequest__c = 'New Application';
                fs1.Expiry_Date__c = Date.today().addDays(90);
                fs1.CurrencyIsoCode = 'USD';
                insert fs1;
        }

        @isTest 
        static void test_method_one() {
                User admin = [SELECT Id, ProfileId FROM User WHERE Id <> :UserInfo.getUserId() AND ProfileId = :UserInfo.getProfileId() AND IsActive = true LIMIT 1];

                //Avoid MIXED_DML_OPERATION on setup and non-setup objects exception
                System.runAs(admin) {
                        Contact c = [SELECT Id, FirstName, LastName, Email FROM Contact WHERE Email = 'mail@test.com'];
                        User u = ISSP_WS_Utilities.createUser(c.FirstName, c.LastName, c.email, 'OtherCompany', c.Id, false);
                        u.FederationIdentifier = String.valueOf(c.Id).substring(0, 15);
                        u.ProfileId = [SELECT Id FROM Profile WHERE Name = 'ISS Portal Agency Delegated Admin User'].Id;
                        insert u;
                }

                Test.startTest();
                User agencyAdmin = [SELECT Id, ProfileId FROM User WHERE Contact.Email = 'mail@test.com'];
                ISSP_FinancialSecInformationController ctrl;
                System.runAs(agencyAdmin) {
                   ctrl = new ISSP_FinancialSecInformationController();
                }
            Test.stopTest();

            System.assertEquals(ctrl.totalSecuredAmount,10000);
            System.assertEquals(ctrl.totalConvertedAmount,10000);
            System.assertEquals(ctrl.localCurrency,'USD');
            System.assertEquals(ctrl.showConvertedAmount,false);
        }
    
}