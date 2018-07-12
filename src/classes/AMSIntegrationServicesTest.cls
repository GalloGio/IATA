@isTest
private class AMSIntegrationServicesTest {
    
    @testSetup static void setup(){
        IATA_ISO_Country__c isoc = new IATA_ISO_Country__c(Name = 'Test', ISO_Code__c = 'TS');
        insert isoc;

        Account acc1 = new Account(Sector__c = 'Travel Agent', Name='Test1 Account', recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency'), IATAcode__c = '12345678', IATA_ISO_Country__c = isoc.id, AIMS_ID__c = '12345678', Source_System__c = 'AIMS2');
        insert acc1;
        
        AMS_Settlement_System__c ass = new AMS_Settlement_System__c(Name = 'Test', recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Settlement_System__c', 'BSP'));
        insert ass;
        AMS_Operation__c op = new AMS_Operation__c(Settlement__c = ass.id, Country__c = isoc.id);
        insert op;
        GDP_Reference_Table__c gdp = new GDP_Reference_Table__c(Name = 'Test', Table__c = 'LOCTYP', Code__c = 'A');
        insert gdp;
        AMS_Segment__c seg = new AMS_Segment__c(Label__c = 'Test', recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Segment__c', 'IATA_Code_Programs'));
        insert seg;
    }

    @isTest static void test_assignAgency2Programs(){
        Test.startTest();
        String accountId = [select id from Account where Name = 'Test1 Account'].id;

        Boolean result = AMSIntegrationServices.assignAgency2Programs(accountId, new List<String>{'Test'});
        Test.stopTest();
    }

    @isTest static void test_assignAgencyPerDPC() {
        Test.startTest();
        String accountId = [select id from Account where Name = 'Test1 Account'].id;
        String isoCountryId = [select id from IATA_ISO_Country__c where Name = 'Test'].id;
       
        Boolean result = AMSIntegrationServices.assignAgencyPerDPC(accountId, isoCountryId);

        Account a = [select id from Account];
        //AMS_Operation__c o = [select id from AMS_Operation__c];
        delete a;
        result = AMSIntegrationServices.assignAgencyPerDPC(accountId, isoCountryId);
        System.assertEquals(false, result);
        Test.stopTest();
    }
    
    @isTest static void test_assignAgencyPerDPCandLegacyIDs() {
        Test.startTest();
        String isoCountryId = [select id from IATA_ISO_Country__c where Name = 'Test'].id;
       
        Boolean result = AMSIntegrationServices.assignAgencyPerDPCandLegacyIDs('12345678', 'AIMS2', isoCountryId);

        Account a = [select id from Account];
        //AMS_Operation__c o = [select id from AMS_Operation__c];
      
        delete a;
        result = AMSIntegrationServices.assignAgencyPerDPCandLegacyIDs('12345678', 'AIMS2', isoCountryId);
        System.assertEquals(false, result);
        Test.stopTest();
    }

    @isTest static void test_assignAgencyPerSettlement() {
        Test.startTest();
        String accountId = [select id from Account where Name = 'Test1 Account'].id;
        String isoCountryId = [select id from IATA_ISO_Country__c where Name = 'Test'].id;
        Boolean result = AMSIntegrationServices.assignAgencyPerSettlement(accountId, isoCountryId, 'Test', false);
        System.assertEquals(true, result);

        result = AMSIntegrationServices.assignAgencyPerSettlement(accountId, isoCountryId, 'Test', true);
        System.assertEquals(false, result);

        Account a = [select id, Operation__c from Account];
        AMS_Operation__c o = [select id from AMS_Operation__c];
        system.assertEquals(a.Operation__c, o.id);
        delete a;
        result = AMSIntegrationServices.assignAgencyPerSettlement(accountId, isoCountryId, 'Test', true);
        System.assertEquals(false, result);
        Test.stopTest();
    }

    @isTest static void test_assignAgencyPerSettlementandLegacyIDs() {
        Test.startTest();
        String isoCountryId = [select id from IATA_ISO_Country__c where Name = 'Test'].id;
        Boolean result = AMSIntegrationServices.assignAgencyPerSettlementandLegacyIDs('12345678', 'AIMS2', isoCountryId, 'Test', false);
        System.assertEquals(true, result);

        result = AMSIntegrationServices.assignAgencyPerSettlementandLegacyIDs('12345678', 'AIMS2', isoCountryId, 'Test', true);
        System.assertEquals(false, result);

        Account a = [select id, Operation__c from Account];
        AMS_Operation__c o = [select id from AMS_Operation__c];
        system.assertEquals(a.Operation__c, o.id);
        delete a;
        result = AMSIntegrationServices.assignAgencyPerSettlementandLegacyIDs('12345678', 'AIMS2', isoCountryId, 'Test', true);
        System.assertEquals(false, result);
        Test.stopTest();
    }

    @isTest static void test_updateAccountGDPData() {
        Test.startTest();
        String accountId = [select id from Account where Name = 'Test1 Account'].id;
        Boolean result = AMSIntegrationServices.updateAccountGDPData(accountId, 'LOCTYPA');
        System.assertEquals(true, result);
        //Boolean result = true;
        Account acc = [select id, GDP_Location_Type__c, GDP_Opt_In__c from Account];
        //system.assertEquals(true, acc.GDP_Opt_In__c);

        GDP_Reference_Table__c g = [select id from GDP_Reference_Table__c];
        System.assertEquals(g.id, acc.GDP_Location_Type__c);
        delete g;
        //result = AMSIntegrationServices.updateAccountGDPData(accountId, 'A', true, 'LOCTYPA','EN');
        System.assertEquals(true, result);

        /*Account a = [select id from Account];
        delete a;
        result = AMSIntegrationServices.updateAccountGDPData(accountId, 'LOCTYPA');
        System.assertEquals(false, result);
        */
        Test.stopTest();
    }

    @isTest static void test_updateAccountGDPDataWithLegacyData() {
        Test.startTest();
        String accountId = [select id from Account where Name = 'Test1 Account'].id;
        Boolean result = AMSIntegrationServices.updateAccountGDPDataWithLegacyData('12345678', 'AIMS2', 'A', true, 'LOCTYPA','EN');
        System.assertEquals(true, result);

        Account acc = [select id, GDP_Location_Type__c, GDP_Opt_In__c from Account];
        system.assertEquals(true, acc.GDP_Opt_In__c);

        GDP_Reference_Table__c g = [select id from GDP_Reference_Table__c];
        System.assertEquals(g.id, acc.GDP_Location_Type__c);
        delete g;
        result = AMSIntegrationServices.updateAccountGDPDataWithLegacyData('12345678', 'AIMS2', 'A', true, 'Test','EN');
        System.assertEquals(false, result);

        Account a = [select id from Account];
        delete a;
        result = AMSIntegrationServices.updateAccountGDPDataWithLegacyData('12345678', 'AIMS2', 'A', true, 'Test','EN');
        System.assertEquals(false, result);
        Test.stopTest();
    }
    
    @isTest static void test_updateAccountIrregularitiese() {
        Test.startTest();
        String accountId = [select id from Account where Name = 'Test1 Account'].id;
        
        Boolean result = AMSIntegrationServices.updateAccountIrregularities(accountId, 3);
        
//        Account acc = [select id, Accumulated_Irregularities__c from Account ];
        system.assertEquals(true, result); 
  //      system.assertEquals(3, acc.Accumulated_Irregularities__c);    
        
    }
    
    @isTest static void test_updateAccountGDPData2() {
        Test.startTest();
        String accountId = [select id,Name from Account where Name = 'Test1 Account'].id;
        Boolean result = AMSIntegrationServices.updateAccountGDPData2(accountId, 'A', true, 'LOCTYPA','EN','12345','P');
        System.assertEquals(true, result);
        
        result = AMSIntegrationServices.updateAccountIrregularities(accountId,12);
        System.assertEquals(true, result);
        result = AMSIntegrationServices.updateAccountShortName(accountId,'ashortname');
        System.assertEquals(true, result);

        Account acc = [select id, Name, GDP_Location_Type__c, GDP_Opt_In__c/*,Accumulated_Irregularities__c*/ ,Short_Name__c from Account];
        system.assertEquals(true, acc.GDP_Opt_In__c);
       // system.assertEquals(12, acc.Accumulated_Irregularities__c );
        system.assertEquals('Test1 Account', acc.Short_Name__c );

        GDP_Reference_Table__c g = [select id from GDP_Reference_Table__c];
        System.assertEquals(g.id, acc.GDP_Location_Type__c);
        delete g;
        result = AMSIntegrationServices.updateAccountGDPData2(accountId, 'A', true, 'LOCTYPA','EN','12345','P');
        //System.assertEquals(false, result);

        Account a = [select id from Account];
        delete a;
        result = AMSIntegrationServices.updateAccountGDPData2(accountId, 'A', true, 'LOCTYPA','EN','12345','P');
        System.assertEquals(false, result);
        Test.stopTest();
    }
    
    @isTest static void test_updateAccountGDPData3() {
        Test.startTest();
        String accountId = [select id from Account where Name = 'Test1 Account'].id;
        Boolean result = AMSIntegrationServices.updateAccountGDPData3(accountId, 'A', true, 'LOCTYPA','EN','12345','P','bsp','last','first','last','first');
        System.assertEquals(false, result);

        Account acc = [select id, GDP_Location_Type__c, GDP_Opt_In__c/*,Accumulated_Irregularities__c*/ ,Short_Name__c from Account];
        system.assertEquals(false, acc.GDP_Opt_In__c);


        GDP_Reference_Table__c g = [select id from GDP_Reference_Table__c];
        //System.assertEquals(g.id, acc.GDP_Location_Type__c);
        delete g;
        result = AMSIntegrationServices.updateAccountGDPData3(accountId, 'A', true, 'LOCTYPA','EN','12345','P','bsp','last','first','last','first');
        //System.assertEquals(false, result);

        Account a = [select id from Account];
        delete a;
        result = AMSIntegrationServices.updateAccountGDPData3(accountId, 'A', true, 'LOCTYPA','EN','12345','P','bsp','last','first','last','first');
        System.assertEquals(false, result);
        Test.stopTest();
    }
 
    @isTest static void test_updateAccountGDPDataWithLegacyData2() {
        Test.startTest();
        String accountId = [select id from Account where Name = 'Test1 Account'].id;
        Boolean result = AMSIntegrationServices.updateAccountGDPDataWithLegacyData2('12345678', 'AIMS2', 'A', true, 'LOCTYPA','EN','12345','P');
        System.assertEquals(true, result);

        Account acc = [select id, GDP_Location_Type__c, GDP_Opt_In__c from Account];
        system.assertEquals(true, acc.GDP_Opt_In__c);

        GDP_Reference_Table__c g = [select id from GDP_Reference_Table__c];
        System.assertEquals(g.id, acc.GDP_Location_Type__c);
        delete g;
        result = AMSIntegrationServices.updateAccountGDPDataWithLegacyData2('12345678', 'AIMS2', 'A', true, 'Test','EN','12345','P');
        System.assertEquals(false, result);

        Account a = [select id from Account];
        delete a;
        result = AMSIntegrationServices.updateAccountGDPDataWithLegacyData2('12345678', 'AIMS2', 'A', true, 'Test','EN','12345','P');
        System.assertEquals(false, result);
        Test.stopTest();
    }
    
    @isTest static void test_countAgenciesPerLegacySystem() {
        Test.startTest();
        Integer result = AMSIntegrationServices.countAgenciesPerLegacySystem('AIMS2');
        System.assertEquals(0, result);
        Test.stopTest();
    }
    
    @isTest static void test_countAgenciesModifiedFormSelectedDate() {
        Test.startTest();
        datetime dtSelectedDate = dateTime.now().addDays(-1);
        Integer result = AMSIntegrationServices.countAgenciesModifiedFormSelectedDate(dtSelectedDate.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''),'AIMS2');
        System.assertEquals(0, result);
        Test.stopTest();
    }
    
    @isTest static void test_countAgenciesSynchronizedFormSelectedDate() {
        Test.startTest();
        datetime dtSelectedDate = dateTime.now().addDays(-1);
        Integer result = AMSIntegrationServices.countAgenciesSynchronizedFormSelectedDate(dtSelectedDate.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''),'AIMS2');
        System.assertEquals(0, result);
        Test.stopTest();
    }

    @isTest static void test_unSynchronizedAgencies() {
        Test.startTest();
        datetime dtSelectedDate = dateTime.now().addDays(-1);
        Integer result = AMSIntegrationServices.unSynchronizedAgencies(dtSelectedDate.format('yyyy-MM-dd\'T\'HH:mm:ss\'Z\''));
        System.assertEquals(0, result);
        Test.stopTest();
    }

    @isTest static void test_failFindAccount() {
        String invalidAccountId = '001000000000000000';
        Boolean result;

        Test.startTest();

        result = AMSIntegrationServices.updateAccountIrregularities(invalidAccountId, 1);
        result = AMSIntegrationServices.updateAccountShortName(invalidAccountId, null);
        result = AMSIntegrationServices.updateAccountGDPData2(invalidAccountId, null, null, null, null, null, null);
        result = AMSIntegrationServices.updateAccountGDPData3(invalidAccountId, null, null, null, null, null, null, null, null, null, null, null);
        result = AMSIntegrationServices.updateAccountGDPDataWithLegacyData2(invalidAccountId, null, null, null, null, null, null, null);
        result = AMSIntegrationServices.updateAccountGDPDataWithLegacyData(invalidAccountId, null, null, null, null, null);
        result = AMSIntegrationServices.assignAgencyPerDPC(invalidAccountId, null);
        result = AMSIntegrationServices.assignAgencyPerDPCandLegacyIDs(invalidAccountId, null, null);
        result = AMSIntegrationServices.assignAgencyPerSettlementandLegacyIDs(invalidAccountId, null, null, null, null);

        Test.stopTest();
    }

    @isTest static void test_failUpdateAccount() {
        String longName = '123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890123456789012345678901234567890';
        Test.startTest();
        String accountId = [select id,Name from Account where Name = 'Test1 Account'].id;
        Boolean result;

        result = AMSIntegrationServices.updateAccountShortName(accountId,longName);
    }
}