@isTest
public class Test_Batch_LocationCounter 
{
    private static void initializeTestData()
    {
        List<GDP_Reference_Table__c> testReferenceTables = new List<GDP_Reference_Table__c>();
        GDP_Reference_Table__c referenceTableA = EBC_TestUtility.createSampleGDPReferenceTableEntry('3','First referenceTable');
        GDP_Reference_Table__c referenceTableB = EBC_TestUtility.createSampleGDPReferenceTableEntry('5','First referenceTable');
        testReferenceTables.add(referenceTableA);
        testReferenceTables.add(referenceTableB);
        try
        {
        	insert testReferenceTables;
        }
        catch(Exception e)
        {
            system.assertEquals(true, false,' An exception occurred while inserting Reference Tables '+e.getMessage());
        }
        Account acc = EBC_TestUtility.createSampleAccount();
        try
        {
        	insert acc;
        }
        catch(Exception e)
        {
            system.assertEquals(true, false,' An exception occurred while inserting an Account '+e.getMessage());
        }
        List<Accreditation__c> sampleAccrediations = new List<Accreditation__c>();
        Accreditation__c accrediationA = EBC_TestUtility.CreateSampleAccreditation(acc,null);
        accrediationA.Status__c = referenceTableA.Id;
        Accreditation__c accrediationB = EBC_TestUtility.CreateSampleAccreditation(acc,null);
        accrediationB.Status__c = referenceTableB.Id;
        Accreditation__c accrediationC = EBC_TestUtility.CreateSampleAccreditation(acc,null);
        accrediationC.Status__c = referenceTableB.Id;
        Accreditation__c accrediationD = EBC_TestUtility.CreateSampleAccreditation(acc,null);
        accrediationD.Status__c = referenceTableB.Id;
        sampleAccrediations.add(accrediationA);  
        sampleAccrediations.add(accrediationB);   
        sampleAccrediations.add(accrediationC);   
        sampleAccrediations.add(accrediationD);
        try
        {
        	insert sampleAccrediations;
        }
        catch(Exception e)
        {
            system.assertEquals(true, false,' An exception occurred while inserting Accrediations '+e.getMessage());
        }
        
        IATA_ISO_Country__c isoCountry = EBC_TestUtility.CreateSampleIATAISOCountry();
        try
        {
        	insert isoCountry;
        }
        catch(Exception e)
        {
            system.assertEquals(true, false,' An exception occurred while inserting ISO Country '+e.getMessage());
        }
        IATA_ISO_State__c isoState = EBC_TestUtility.CreateSampleIATAISOState(isoCountry);
        try
        {
        	insert isoState;
        }
        catch(Exception e)
        {
            system.assertEquals(true, false,' An exception occurred while inserting ISO State '+e.getMessage());
        }
        GDP_Geo_Detail__c geoDetail = EBC_TestUtility.CreateSampleGDPGeoDetail(isoCountry);
        try
        {
        	insert geoDetail;
        }
        catch(Exception e)
        {
            system.assertEquals(true, false,' An exception occurred while inserting geoDetail '+e.getMessage());
        }
        
        List<GDP_Products_Account_View__c> sampleAgencies = new List<GDP_Products_Account_View__c>();
        GDP_Products_Account_View__c sampleGDPProductAccountA = EBC_TestUtility.createSampleGDPAccount('ProductA','AC');       
        sampleGDPProductAccountA.Related_Accreditation_Class__c = accrediationA.Id;
        sampleGDPProductAccountA.AIMS_ID__c = '1234';
        sampleGDPProductAccountA.WebStar_ID__c = '2356';
        sampleGDPProductAccountA.IATA_Code__c='1234567';
        GDP_Products_Account_View__c sampleGDPProductAccountB = EBC_TestUtility.createSampleGDPAccount('ProductB','AO');
        sampleGDPProductAccountB.Related_Accreditation_Class__c = accrediationB.Id;
        sampleGDPProductAccountB.AIMS_ID__c = '5678';
        sampleGDPProductAccountB.WebStar_ID__c = '1289';
        sampleGDPProductAccountB.IATA_Code__c='1234568';
        GDP_Products_Account_View__c sampleGDPProductAccountC = EBC_TestUtility.createSampleGDPAccount('ProductC','AO');
        sampleGDPProductAccountC.Related_Accreditation_Class__c = accrediationC.Id;
        sampleGDPProductAccountC.AIMS_ID__c = '8667';
        sampleGDPProductAccountC.WebStar_ID__c = '3457';
        sampleGDPProductAccountC.IATA_Code__c='1234569';
        GDP_Products_Account_View__c sampleGDPProductAccountD = EBC_TestUtility.createSampleGDPAccount('ProductD','AC');
        sampleGDPProductAccountD.Related_Accreditation_Class__c = accrediationD.Id;
        sampleGDPProductAccountD.AIMS_ID__c = '0756';
        sampleGDPProductAccountD.WebStar_ID__c = '2357';
        sampleGDPProductAccountD.IATA_Code__c='1234566';
        sampleAgencies.add(sampleGDPProductAccountA);
        sampleAgencies.add(sampleGDPProductAccountB);
        sampleAgencies.add(sampleGDPProductAccountC);
        sampleAgencies.add(sampleGDPProductAccountD);
        try
        {
        	insert sampleAgencies;
        }
        catch(Exception e)
        {
            system.assertEquals(true, false,' An exception occurred while inserting GDP Product Accounts '+e.getMessage());
        }
        List<GDP_Address__c> testAddresses = new List<GDP_Address__c>();
        GDP_Address__c addressA = EBC_TestUtility.CreateSampleGDPAddress(sampleGDPProductAccountA,isoCountry,isoState,geoDetail);
        addressA.Address_City__c = 'Toronto';
        GDP_Address__c addressB = EBC_TestUtility.CreateSampleGDPAddress(sampleGDPProductAccountB,isoCountry,isoState,geoDetail);
        addressB.Address_City__c = 'Montreal';
        GDP_Address__c addressC = EBC_TestUtility.CreateSampleGDPAddress(sampleGDPProductAccountC,isoCountry,isoState,geoDetail);
        addressC.Address_City__c = 'Vancover';
        testAddresses.add(addressA);
        testAddresses.add(addressB);
        testAddresses.add(addressC);
        try
        {
        	insert testAddresses;
        }
        catch(Exception e)
        {
           system.assertEquals(true, false,' An exception occurred while inserting GDP Address '+e.getMessage());
        }
        
        sampleAgencies = new List<GDP_Products_Account_View__c>();
        sampleGDPProductAccountA.Related_GDP_Address__c = addressA.Id;
        sampleGDPProductAccountB.Related_GDP_Address__c = addressB.Id;
        sampleGDPProductAccountC.Related_GDP_Address__c = addressC.Id;
        sampleGDPProductAccountD.Related_GDP_Address__c = addressB.Id;
        sampleAgencies.add(sampleGDPProductAccountA);
        sampleAgencies.add(sampleGDPProductAccountB);
        sampleAgencies.add(sampleGDPProductAccountC);
        sampleAgencies.add(sampleGDPProductAccountD);
        try
        {
        	update sampleAgencies;
        }
        catch(Exception e)
        {
            system.assertEquals(true, false,' An exception occurred while updating GDP Product Accounts '+e.getMessage());
        }
    }
    private static testMethod void testBatch()
    {
        initializeTestData();
        List<GDP_Products_Account_View__c> products = [Select Id,Agency_Status_Code__c,City__c,Country_Name__c,State_Province__c,Sub_Continent__c
                                                      from GDP_Products_Account_View__c];
        system.assertNotEquals(null, products,' Exception. No GDP Records have been created during test data initialization');
        EBC_Statistic__c ebc_Stat = new EBC_Statistic__c();
        ebc_Stat.Key__c='SC-North America';
        ebc_Stat.Agency_Counter__c=3;
        ebc_Stat.Sub_Continent__c='North America';
        try
        {
        	insert ebc_Stat;
        }
        catch(Exception e)
        {
            system.assertEquals(true, false,' An exception occurred while inserting a sample EBC_Statistic__c record '+e.getMessage());
        }
        test.startTest();
        	Database.executeBatch(new Batch_DeleteExistingLocationCounter(), 1);
        test.stopTest();
        List<EBC_Statistic__c> allStatistics = [Select Id,Key__c,Agency_Counter__c,City__c,Country__c,State_Province__c,Sub_Continent__c
                                               from EBC_Statistic__c];
        system.assertNotEquals(null, allStatistics,' The batch needs to add records ');
    }
    private static testMethod void testSchedule()
    {
        initializeTestData();
        List<GDP_Products_Account_View__c> products = [Select Id,Agency_Status_Code__c,City__c,Country_Name__c,State_Province__c,Sub_Continent__c
                                                      from GDP_Products_Account_View__c];
        system.assertNotEquals(null, products,' Exception. No GDP Records have been created during test data initialization');
        EBC_Statistic__c ebc_Stat = new EBC_Statistic__c();
        ebc_Stat.Key__c='SC-North America';
        ebc_Stat.Agency_Counter__c=3;
        ebc_Stat.Sub_Continent__c='North America';
        try
        {
        	insert ebc_Stat;
        }
        catch(Exception e)
        {
            system.assertEquals(true, false,' An exception occurred while inserting a sample EBC_Statistic__c record '+e.getMessage());
        }
        test.startTest();
        	String CRON_EXP = '0 0 0 15 3 ? 2022';
        	String jobId = System.schedule('ScheduleApexClassTest',
                        CRON_EXP,
                        new Schdl_Batch_LocationCounter());
        test.stopTest();
        List<EBC_Statistic__c> allStatistics = [Select Id,Key__c,Agency_Counter__c,City__c,Country__c,State_Province__c,Sub_Continent__c
                                               from EBC_Statistic__c];
        system.assertNotEquals(null, allStatistics,' The batch needs to add records ');
    }
}