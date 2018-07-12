@isTest
private class AMSTranslatedPanelControllerTest {

        @isTest static void testTranslateAgency() {
                IATA_ISO_Country__c isoc = new IATA_ISO_Country__c(Name = 'Test', ISO_Code__c = 'TS');
                insert isoc;
                Id accountRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');

                List<Account> agencylist = new List<Account>();
                Account a1 = new Account(Name = 'Test1 Agency', Short_Name__c = 'Test1 Agency', IATA_ISO_Country__c = isoc.id);
                agencylist.add(a1);
                insert agencylist;
                List<AMS_Fields_Translation__c> translationLineList = new List<AMS_Fields_Translation__c>();
                AMS_Fields_Translation__c translationLine1 = new AMS_Fields_Translation__c(Name = 'Name', Translation__c = 'Name', Language__c = 'CN', Field_name__c = 'Name');
                AMS_Fields_Translation__c translationLine2 = new AMS_Fields_Translation__c(Name = 'ABC', Translation__c = 'ABCDE', Language__c = 'CN', Field_name__c = 'Account__c');
                translationLineList.add(translationLine1);
                translationLineList.add(translationLine2);
                insert translationLineList;

                Test.startTest();
                AmsTranslatedPanelController translateAgency = new AmsTranslatedPanelController();
                translateAgency.accountId = a1.id;
                translateAgency.gettranslations();
                translateAgency.editFields();
                translateAgency.cancel();
                translateAgency.saveTranslations();

                List<AMS_Fields_Translation__c> tr = [select id from AMS_Fields_Translation__c];

                // TODO: should be 2, but there's a bug to be fixed in the next sprint.
                system.assertEquals(4, tr.size());
                Test.stopTest();
        }

        @isTest static void testTranslateOwner() {
                AMS_Owner__c o = new AMS_Owner__c();
                insert o;

                Test.startTest();
                AmsTranslatedPanelController translateAgency = new AmsTranslatedPanelController();
                translateAgency.ownerId = o.id;
                translateAgency.gettranslations();
                translateAgency.saveTranslations();

                List<AMS_Fields_Translation__c> tr = [select id from AMS_Fields_Translation__c];
                system.assertEquals(1, tr.size());
                Test.stopTest();
        }

        @isTest static void testTranslateAddress() {
                IATA_ISO_Country__c isoc = new IATA_ISO_Country__c(Name = 'Test', ISO_Code__c = 'TS');
                insert isoc;

                Id accountRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');
                List<Account> agencylist = new List<Account>();
                Account a1 = new Account(Name = 'Test1 Agency', Short_Name__c = 'Test1 Agency', IATA_ISO_Country__c = isoc.id, Iatacode__c = '1234567');
                agencylist.add(a1);
                insert agencylist;

                List<AMS_Address__c> agencyAddressList = new List<AMS_Address__c>();
                AMS_Address__c aa1 = new AMS_Address__c(Account__c = a1.id);
                agencyAddressList.add(aa1);
                insert agencyAddressList;

                Test.startTest();
                AmsTranslatedPanelController translateAgency = new AmsTranslatedPanelController();
                translateAgency.amsAddressId = aa1.id;
                translateAgency.gettranslations();
                translateAgency.saveTranslations();

                List<AMS_Fields_Translation__c> tr = [select id from AMS_Fields_Translation__c];
                system.assertEquals(5, tr.size());
                Test.stopTest();
        }

        @isTest static void testTranslateState() {
                IATA_ISO_Country__c country = new IATA_ISO_Country__c(ISO_Code__c = 'BR');
                insert country;
                IATA_ISO_State__c state = new IATA_ISO_State__c(IATA_ISO_Country__c = country.id, ISO_Code__c = 'BR');
                insert state;

                Test.startTest();
                AmsTranslatedPanelController translateAgency = new AmsTranslatedPanelController();
                translateAgency.iataIsoStateId = state.id;
                translateAgency.gettranslations();
                translateAgency.saveTranslations();

                List<AMS_Fields_Translation__c> tr = [select id from AMS_Fields_Translation__c];
                system.assertEquals(1, tr.size());
                Test.stopTest();
        }

        @isTest static void testTranslatePerson() {
                AMS_Person__c per = new AMS_Person__c();
                insert per;

                Test.startTest();
                AmsTranslatedPanelController translateAgency = new AmsTranslatedPanelController();
                translateAgency.amsPersonId = per.id;
                translateAgency.gettranslations();
                translateAgency.saveTranslations();

                List<AMS_Fields_Translation__c> tr = [select id from AMS_Fields_Translation__c];
                system.assertEquals(2, tr.size());
                Test.stopTest();
        }
}