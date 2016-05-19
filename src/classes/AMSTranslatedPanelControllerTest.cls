@isTest
private class AMSTranslatedPanelControllerTest {
  
  @isTest static void testTranslateAgency() {
                IATA_ISO_Country__c isoc = new IATA_ISO_Country__c(Name = 'Test', ISO_Code__c = 'TS');
                insert isoc;

                Map<string, Id>  agenciesRT  =  TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'AMS_Agency__c'}).get('AMS_Agency__c');

    List<AMS_Agency__c> agencylist = new List<AMS_Agency__c>();
                AMS_Agency__c a1 = new AMS_Agency__c(Name='Test1 Agency',Legal_Name_1__c='Test1 Agency', Country__c = isoc.id);
                agencylist.add(a1);
                insert agencylist;
                
                Test.startTest();
                AmsTranslatedPanelController translateAgency = new AmsTranslatedPanelController();
                translateAgency.agencyId = a1.id;
                translateAgency.gettranslations();
                translateAgency.editFields();
                translateAgency.cancel();
                translateAgency.saveTranslations();

                List<AMS_Fields_Translation__c> tr = [select id from AMS_Fields_Translation__c];
           //     system.assertEquals(4,tr.size());
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
                system.assertEquals(1,tr.size());
                Test.stopTest();
  }

  @isTest static void testTranslateAddress() {
                IATA_ISO_Country__c isoc = new IATA_ISO_Country__c(Name = 'Test', ISO_Code__c = 'TS');
                insert isoc;

                Map<string, Id>  agenciesRT  =  TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'AMS_Agency__c'}).get('AMS_Agency__c');

    List<AMS_Agency__c> agencylist = new List<AMS_Agency__c>();
                AMS_Agency__c a1 = new AMS_Agency__c(Name='Test1 Agency',Legal_Name_1__c='Test1 Agency', Country__c = isoc.id, Iatacode__c = '1234567');
                agencylist.add(a1);
                insert agencylist;

                List<AMS_Address__c> agencyAddressList = new List<AMS_Address__c>();
                AMS_Address__c aa1 = new AMS_Address__c(Agency__c=a1.id);
                agencyAddressList.add(aa1);
                insert agencyAddressList;
                
                Test.startTest();
                AmsTranslatedPanelController translateAgency = new AmsTranslatedPanelController();
                translateAgency.amsAddressId = aa1.id;
                translateAgency.gettranslations();
                translateAgency.saveTranslations();

                List<AMS_Fields_Translation__c> tr = [select id from AMS_Fields_Translation__c];
                system.assertEquals(5,tr.size());
                Test.stopTest();
  }

  @isTest static void testTranslateState() {
                IATA_ISO_Country__c country = new IATA_ISO_Country__c(ISO_Code__c='BR');
                insert country;
                IATA_ISO_State__c state = new IATA_ISO_State__c(IATA_ISO_Country__c=country.id,ISO_Code__c='BR');
                insert state;
                
                Test.startTest();
                AmsTranslatedPanelController translateAgency = new AmsTranslatedPanelController();
                translateAgency.iataIsoStateId = state.id;
                translateAgency.gettranslations();
                translateAgency.saveTranslations();

                List<AMS_Fields_Translation__c> tr = [select id from AMS_Fields_Translation__c];
                system.assertEquals(1,tr.size());
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
                system.assertEquals(2,tr.size());
                Test.stopTest();
  }
}