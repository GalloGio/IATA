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
                agency.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
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

                Financial_Institution__c fi = new Financial_Institution__c();
                fi.Name = 'Bank Test';
                fi.Region__c = 'Europe';
                fi.Country__c = 'Portugal';
                fi.Institution_Type__c = 'Bank';
                insert fi;

                Financial_Security__c fs = new Financial_Security__c();
                fs.Region__c = 'Europe';
                fs.Security_Status__c = 'Active';
                fs.Security_Type__c = 'CCG';
                fs.Account__c = agency.Id;
                fs.Amount__c = 10000;
                fs.Financial_Institution__c = fi.Id;
                fs.Reception_Case__c = cse.Id;
                fs.Reception_Date__c = Date.today();
                fs.Reasonforrequest__c = 'New Application';
                fs.Expiry_Date__c = Date.today().addDays(90);
                insert fs;
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
                System.runAs(agencyAdmin) {
        	       ISSP_FinancialSecInformationController ctrl = new ISSP_FinancialSecInformationController();
                }
        	Test.stopTest();
        }
	
}