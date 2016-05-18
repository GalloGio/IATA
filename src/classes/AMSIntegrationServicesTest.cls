@isTest
private class AMSIntegrationServicesTest {
    
    @testSetup static void setup(){
        //Account acc = new Account(Name='Test Account1', IATAcode__c = '12345678');
        //insert acc;
        IATA_ISO_Country__c isoc = new IATA_ISO_Country__c(Name = 'Test', ISO_Code__c = 'TS');
        insert isoc;

        Map<string, Id> agenciesRT = TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'AMS_Agency__c'}).get('AMS_Agency__c');

        Account acc1 = new Account(Name='Test1 Account');
        insert acc1;
        
        AMS_Agency__c a = new AMS_Agency__c(Account__c= acc1.Id, RecordTypeId = agenciesRT.get('PASSENGER'), Name='Test Agency', IATAcode__c = '1234567', Chk_dgt__c = '8', Legal_Name_1__c = 'Test Agency', Legacy_External_ID__c = '12345678', Legacy_System__c = 'AIMS', Country__c = isoc.id);
        insert a;
        AMS_Settlement_System__c ass = new AMS_Settlement_System__c(Name = 'Test', recordTypeId = [Select Id From RecordType where sobjecttype = 'AMS_Settlement_System__c' and name = 'BSP'].id);
        insert ass;
        AMS_Operation__c op = new AMS_Operation__c(Settlement__c = ass.id, Country__c = isoc.id);
        insert op;
        GDP_Reference_Table__c gdp = new GDP_Reference_Table__c(Name = 'Test', Table__c = 'LOCTYP', Code__c = 'A');
        insert gdp;
    }

    @isTest static void test_assignAgencyPerDPC() {
        Test.startTest();
        String agencyId = [select id from AMS_Agency__c where Name = 'Test Agency'].id;
        String isoCountryId = [select id from IATA_ISO_Country__c where Name = 'Test'].id;
       
        Boolean result = AMSIntegrationServices.assignAgencyPerDPC(agencyId, isoCountryId);
        //System.assertEquals(true, result);

        AMS_Agency__c a = [select id, DPC_Operation__c from AMS_Agency__c];
        AMS_Operation__c o = [select id from AMS_Operation__c];
        delete a;
        result = AMSIntegrationServices.assignAgencyPerDPC(agencyId, isoCountryId);
        System.assertEquals(false, result);
        Test.stopTest();
    }
    
    @isTest static void test_assignAgencyPerDPCandLegacyIDs() {
        Test.startTest();
        String isoCountryId = [select id from IATA_ISO_Country__c where Name = 'Test'].id;
       
        Boolean result = AMSIntegrationServices.assignAgencyPerDPCandLegacyIDs('12345678', 'AIMS', isoCountryId);
        //System.assertEquals(true, result);

        AMS_Agency__c a = [select id, DPC_Operation__c from AMS_Agency__c];
        AMS_Operation__c o = [select id from AMS_Operation__c];
      
        delete a;
        result = AMSIntegrationServices.assignAgencyPerDPCandLegacyIDs('12345678', 'AIMS', isoCountryId);
        System.assertEquals(false, result);
        Test.stopTest();
    }

    @isTest static void test_assignAgencyPerSettlement() {
        Test.startTest();
        String agencyId = [select id from AMS_Agency__c where Name = 'Test Agency'].id;
        String isoCountryId = [select id from IATA_ISO_Country__c where Name = 'Test'].id;
        Boolean result = AMSIntegrationServices.assignAgencyPerSettlement(agencyId, isoCountryId, 'Test', false);
        System.assertEquals(true, result);

        result = AMSIntegrationServices.assignAgencyPerSettlement(agencyId, isoCountryId, 'Test', true);
        System.assertEquals(false, result);

        AMS_Agency__c a = [select id, DPC_Operation__c from AMS_Agency__c];
        AMS_Operation__c o = [select id from AMS_Operation__c];
        system.assertEquals(a.DPC_Operation__c, o.id);
        delete a;
        result = AMSIntegrationServices.assignAgencyPerSettlement(agencyId, isoCountryId, 'Test', true);
        System.assertEquals(false, result);
        Test.stopTest();
    }

    @isTest static void test_assignAgencyPerSettlementandLegacyIDs() {
        Test.startTest();
        String isoCountryId = [select id from IATA_ISO_Country__c where Name = 'Test'].id;
        Boolean result = AMSIntegrationServices.assignAgencyPerSettlementandLegacyIDs('12345678', 'AIMS', isoCountryId, 'Test', false);
        System.assertEquals(true, result);

        result = AMSIntegrationServices.assignAgencyPerSettlementandLegacyIDs('12345678', 'AIMS', isoCountryId, 'Test', true);
        System.assertEquals(false, result);

        AMS_Agency__c a = [select id, DPC_Operation__c from AMS_Agency__c];
        AMS_Operation__c o = [select id from AMS_Operation__c];
        system.assertEquals(a.DPC_Operation__c, o.id);
        delete a;
        result = AMSIntegrationServices.assignAgencyPerSettlementandLegacyIDs('12345678', 'AIMS', isoCountryId, 'Test', true);
        System.assertEquals(false, result);
        Test.stopTest();
    }

    @isTest static void test_updateAccountGDPData() {
        Test.startTest();
        String agencyId = [select id from AMS_Agency__c where Name = 'Test Agency'].id;
        Boolean result = AMSIntegrationServices.updateAccountGDPData(agencyId, 'A', true, 'LOCTYPA','EN');
        System.assertEquals(true, result);

        Account acc = [select id, GDP_Location_Type__c, GDP_Opt_In__c from Account];
        system.assertEquals(true, acc.GDP_Opt_In__c);

        GDP_Reference_Table__c g = [select id from GDP_Reference_Table__c];
        System.assertEquals(g.id, acc.GDP_Location_Type__c);
        delete g;
        result = AMSIntegrationServices.updateAccountGDPData(agencyId, 'A', true, 'LOCTYPA','EN');
        //System.assertEquals(false, result);

        AMS_Agency__c a = [select id from AMS_Agency__c];
        delete a;
        result = AMSIntegrationServices.updateAccountGDPData(agencyId, 'A', true, 'LOCTYPA','EN');
        System.assertEquals(false, result);
        Test.stopTest();
    }

    @isTest static void test_updateAccountGDPDataWithLegacyData() {
        Test.startTest();
        String agencyId = [select id from AMS_Agency__c where Name = 'Test Agency'].id;
        Boolean result = AMSIntegrationServices.updateAccountGDPDataWithLegacyData('12345678', 'AIMS', 'A', true, 'LOCTYPA','EN');
        System.assertEquals(true, result);

        Account acc = [select id, GDP_Location_Type__c, GDP_Opt_In__c from Account];
        system.assertEquals(true, acc.GDP_Opt_In__c);

        GDP_Reference_Table__c g = [select id from GDP_Reference_Table__c];
        System.assertEquals(g.id, acc.GDP_Location_Type__c);
        delete g;
        result = AMSIntegrationServices.updateAccountGDPDataWithLegacyData('12345678', 'AIMS', 'A', true, 'Test','EN');
        System.assertEquals(false, result);

        AMS_Agency__c a = [select id from AMS_Agency__c];
        delete a;
        result = AMSIntegrationServices.updateAccountGDPDataWithLegacyData('12345678', 'AIMS', 'A', true, 'Test','EN');
        System.assertEquals(false, result);
        Test.stopTest();
    }
    
    @isTest static void test_updateAccountIrregularitiese() {
        Test.startTest();
        String agencyId = [select id from AMS_Agency__c where Name = 'Test Agency'].id;
        
        Boolean result = AMSIntegrationServices.updateAccountIrregularities(agencyId, 3);
        
        Account acc = [select id, Accumulated_Irregularities__c from Account ];
        system.assertEquals(true, result); 
        system.assertEquals(3, acc.Accumulated_Irregularities__c);    
        
    }
    
    @isTest static void test_updateAccountGDPData2() {
        Test.startTest();
        String agencyId = [select id from AMS_Agency__c where Name = 'Test Agency'].id;
        Boolean result = AMSIntegrationServices.updateAccountGDPData2(agencyId, 'A', true, 'LOCTYPA','EN','12345','P');
        System.assertEquals(true, result);
        
        result = AMSIntegrationServices.updateAccountIrregularities(agencyId,12);
        System.assertEquals(true, result);
        result = AMSIntegrationServices.updateAccountShortName(agencyId,'ashortname');
        System.assertEquals(true, result);

        Account acc = [select id, GDP_Location_Type__c, GDP_Opt_In__c,Accumulated_Irregularities__c ,Short_Name__c from Account];
        system.assertEquals(true, acc.GDP_Opt_In__c);
        system.assertEquals(12, acc.Accumulated_Irregularities__c );
        system.assertEquals('ashortname', acc.Short_Name__c );

        GDP_Reference_Table__c g = [select id from GDP_Reference_Table__c];
        System.assertEquals(g.id, acc.GDP_Location_Type__c);
        delete g;
        result = AMSIntegrationServices.updateAccountGDPData2(agencyId, 'A', true, 'LOCTYPA','EN','12345','P');
        //System.assertEquals(false, result);

        AMS_Agency__c a = [select id from AMS_Agency__c];
        delete a;
        result = AMSIntegrationServices.updateAccountGDPData2(agencyId, 'A', true, 'LOCTYPA','EN','12345','P');
        System.assertEquals(false, result);
        Test.stopTest();
    }
    
    @isTest static void test_updateAccountGDPData3() {
        Test.startTest();
        String agencyId = [select id from AMS_Agency__c where Name = 'Test Agency'].id;
        Boolean result = AMSIntegrationServices.updateAccountGDPData3(agencyId, 'A', true, 'LOCTYPA','EN','12345','P','bsp','last','first','last','first');
        System.assertEquals(false, result);

        Account acc = [select id, GDP_Location_Type__c, GDP_Opt_In__c,Accumulated_Irregularities__c ,Short_Name__c from Account];
        system.assertEquals(false, acc.GDP_Opt_In__c);


        GDP_Reference_Table__c g = [select id from GDP_Reference_Table__c];
        //System.assertEquals(g.id, acc.GDP_Location_Type__c);
        delete g;
        result = AMSIntegrationServices.updateAccountGDPData3(agencyId, 'A', true, 'LOCTYPA','EN','12345','P','bsp','last','first','last','first');
        //System.assertEquals(false, result);

        AMS_Agency__c a = [select id from AMS_Agency__c];
        delete a;
        result = AMSIntegrationServices.updateAccountGDPData3(agencyId, 'A', true, 'LOCTYPA','EN','12345','P','bsp','last','first','last','first');
        System.assertEquals(false, result);
        Test.stopTest();
    }
 
    @isTest static void test_updateAccountGDPDataWithLegacyData2() {
        Test.startTest();
        String agencyId = [select id from AMS_Agency__c where Name = 'Test Agency'].id;
        Boolean result = AMSIntegrationServices.updateAccountGDPDataWithLegacyData2('12345678', 'AIMS', 'A', true, 'LOCTYPA','EN','12345','P');
        System.assertEquals(true, result);

        Account acc = [select id, GDP_Location_Type__c, GDP_Opt_In__c from Account];
        system.assertEquals(true, acc.GDP_Opt_In__c);

        GDP_Reference_Table__c g = [select id from GDP_Reference_Table__c];
        System.assertEquals(g.id, acc.GDP_Location_Type__c);
        delete g;
        result = AMSIntegrationServices.updateAccountGDPDataWithLegacyData2('12345678', 'AIMS', 'A', true, 'Test','EN','12345','P');
        System.assertEquals(false, result);

        AMS_Agency__c a = [select id from AMS_Agency__c];
        delete a;
        result = AMSIntegrationServices.updateAccountGDPDataWithLegacyData2('12345678', 'AIMS', 'A', true, 'Test','EN','12345','P');
        System.assertEquals(false, result);
        Test.stopTest();
    }
    
    @isTest static void test_countAgenciesPerLegacySystem() {
        Test.startTest();
        Integer result = AMSIntegrationServices.countAgenciesPerLegacySystem('AIMS');
        System.assertEquals(1, result);
        Test.stopTest();
    }
    
    @isTest static void test_countAgenciesModifiedFormSelectedDate() {
        Test.startTest();
        datetime dtSelectedDate = dateTime.now().addDays(-1);
        Integer result = AMSIntegrationServices.countAgenciesModifiedFormSelectedDate(dtSelectedDate.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''),'AIMS');
        System.assertEquals(1, result);
        Test.stopTest();
    }
    
    @isTest static void test_countAgenciesSynchronizedFormSelectedDate() {
        Test.startTest();
        datetime dtSelectedDate = dateTime.now().addDays(-1);
        Integer result = AMSIntegrationServices.countAgenciesSynchronizedFormSelectedDate(dtSelectedDate.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''),'AIMS');
        System.assertEquals(1, result);
        Test.stopTest();
    }

    @isTest static void test_unSynchronizedAgencies() {
        Test.startTest();
        datetime dtSelectedDate = dateTime.now().addDays(-1);
        Integer result = AMSIntegrationServices.unSynchronizedAgencies(dtSelectedDate.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''));
        System.assertEquals(0, result);
        Test.stopTest();
    }
}