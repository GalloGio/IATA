@isTest
private class ANG_BatchAggregatePwcDataTest {
	
	/**
     * Attributes
     */
    private static List<Account> accountsWithoutId = new List<Account>();
    private static List<IATA_ISO_Country__c> isoCountriesWithoutId = new List<IATA_ISO_Country__c>();
    private static List<AMS_Country_Specific_Attribute__c> countrySpecificAttributesWithoutId = new List<AMS_Country_Specific_Attribute__c>();
    private static List<Agency_Applied_Change_code__c> agencyAppliedChangeCodesWithoutId = new List<Agency_Applied_Change_code__c>();
    private static DateTime currentDateTime;

    /**
     * Prepare data for our tests
     */
    public static void init() {

        // Get current date time and update linked variable
        currentDateTime = DateTime.now();

        // Required record types for AMS_Country_Specific_Attribute__c
       	Id recordTypeDefLfcId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Country_Specific_Attribute__c', 'DEF_LFC');
        
       	Id recordTypeIrrsLfcId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Country_Specific_Attribute__c', 'IRRS_LFC');
        
        Id recordTypeIrrCpeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Country_Specific_Attribute__c', 'IRR_CPE');

        // Create ISO countries
        IATA_ISO_Country__c isoCountry1 = new IATA_ISO_Country__c();
        isoCountry1.ISO_Code__c = 'CH';
        isoCountry1.ISO_Code_Numeric__c = 100;
        IATA_ISO_Country__c isoCountry2 = new IATA_ISO_Country__c();
        isoCountry2.ISO_Code__c = 'KZ';
        isoCountry2.ISO_Code_Numeric__c = 200;
        IATA_ISO_Country__c isoCountry3 = new IATA_ISO_Country__c();
        isoCountry3.ISO_Code__c = 'JP';
        isoCountry3.ISO_Code_Numeric__c = 300;
        IATA_ISO_Country__c isoCountry4 = new IATA_ISO_Country__c();
        isoCountry4.ISO_Code__c = 'FR';
        isoCountry4.ISO_Code_Numeric__c = 400;
        IATA_ISO_Country__c isoCountry5 = new IATA_ISO_Country__c();
        isoCountry5.ISO_Code__c = 'IT';
        isoCountry5.ISO_Code_Numeric__c = 500;
        IATA_ISO_Country__c isoCountry6 = new IATA_ISO_Country__c();
        isoCountry6.ISO_Code__c = 'PT';
        isoCountry6.ISO_Code_Numeric__c = 600;
        isoCountry6.ANG_Enable_NewGen__c = true;

        // Update linked collection and persist them
        isoCountriesWithoutId.add(isoCountry1);
        isoCountriesWithoutId.add(isoCountry2);
        isoCountriesWithoutId.add(isoCountry3);
        isoCountriesWithoutId.add(isoCountry4);
        isoCountriesWithoutId.add(isoCountry5);
        isoCountriesWithoutId.add(isoCountry6);
        insert isoCountriesWithoutId;

        // Create country specific attributes
        AMS_Country_Specific_Attribute__c countrySpecificAttribute1 = new AMS_Country_Specific_Attribute__c();
        countrySpecificAttribute1.RecordTypeId = recordTypeDefLfcId;
        countrySpecificAttribute1.IATA_ISO_Country__c = isoCountry3.Id;
        countrySpecificAttribute1.Location_Class__c = 'P';
        countrySpecificAttribute1.Months_Count__c = 36;
        AMS_Country_Specific_Attribute__c countrySpecificAttribute2 = new AMS_Country_Specific_Attribute__c();
        countrySpecificAttribute2.RecordTypeId = recordTypeDefLfcId;
        countrySpecificAttribute2.IATA_ISO_Country__c = isoCountry3.Id;
        countrySpecificAttribute2.Location_Class__c = 'C';
        countrySpecificAttribute2.Months_Count__c = 24;
        AMS_Country_Specific_Attribute__c countrySpecificAttribute3 = new AMS_Country_Specific_Attribute__c();
        countrySpecificAttribute3.RecordTypeId = recordTypeIrrsLfcId;
        countrySpecificAttribute3.IATA_ISO_Country__c = isoCountry2.Id;
        countrySpecificAttribute3.Location_Class__c = 'P';
        countrySpecificAttribute3.Months_Count__c = 24;
        AMS_Country_Specific_Attribute__c countrySpecificAttribute4 = new AMS_Country_Specific_Attribute__c();
        countrySpecificAttribute4.RecordTypeId = recordTypeIrrCpeId;
        countrySpecificAttribute4.IATA_ISO_Country__c = isoCountry4.Id;
        countrySpecificAttribute4.Location_Class__c = 'D';
        countrySpecificAttribute4.Irregularity_Type__c = 'OV2';

        // Update linked collection and persist them
        countrySpecificAttributesWithoutId.add(countrySpecificAttribute1);
        countrySpecificAttributesWithoutId.add(countrySpecificAttribute2);
        countrySpecificAttributesWithoutId.add(countrySpecificAttribute3);
        countrySpecificAttributesWithoutId.add(countrySpecificAttribute4);
        insert countrySpecificAttributesWithoutId;

        Id accRTId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

        // Create accounts
        Account account1 = new Account(
        	Name = 'AccountTest1', 
	        RecordTypeId = accRTId,
	        Status__c = 'Approved',
	        Location_Class__c = 'P',
	        Location_Type__c = 'HO');
        Account account2 = new Account(
	        Name = 'AccountTest2', 
	        RecordTypeId = accRTId,
	        Status__c = 'Approved',
	        Location_Class__c = 'P',
	        Location_Type__c = 'HO');
        Account account3 = new Account(
	        Name = 'AccountTest3',
	        RecordTypeId = accRTId,
	        Status__c = 'Approved',
	        Location_Class__c = 'P',
	        Location_Type__c = 'HO');
        Account account4 = new Account(
	        Name = 'AccountTest4', 
	        RecordTypeId = accRTId,
	        Status__c = 'Approved',
	        Location_Class__c = 'D',
	        Location_Type__c = 'HO');
        Account account5 = new Account(
	        Name = 'AccountTest5', 
	        RecordTypeId = accRTId,
	        Status__c = 'Approved',
	        Location_Class__c = 'P',
	        Location_Type__c = 'HO');
        Account account6 = new Account(
	        Name = 'AccountTest6', 
	        RecordTypeId = accRTId,
	        Status__c = 'Approved',
	        Location_Class__c = 'R',
	        Location_Type__c = 'HO');

        //NewGen
        Account account7 = new Account(
            Name = 'AccountTest7', 
            RecordTypeId = accRTId,
            Status__c = 'Approved',
            Location_Class__c = 'P',
            Location_Type__c = 'HE',
            IATA_ISO_Country__c = isoCountry6.Id);

        // Update accounts with linked elements
        account1.IATA_ISO_Country__c = isoCountry1.Id;
        account2.IATA_ISO_Country__c = isoCountry2.Id;
        account3.IATA_ISO_Country__c = isoCountry3.Id;
        account4.IATA_ISO_Country__c = isoCountry4.Id;
        account6.IATA_ISO_Country__c = isoCountry5.Id;

        // Persist accounts
        accountsWithoutId.add(account1);
        accountsWithoutId.add(account2);
        accountsWithoutId.add(account3);
        accountsWithoutId.add(account4);
        accountsWithoutId.add(account5);
        accountsWithoutId.add(account6);
        accountsWithoutId.add(account7);
        insert accountsWithoutId;

        // Required record types for Agency_Applied_Change_code__c
        Id recordTypeStandard =  RecordTypeSingleton.getInstance().getRecordTypeId('Agency_Applied_Change_code__c', 'Standard');

        Id recordTypeIrregularities = RecordTypeSingleton.getInstance().getRecordTypeId('Agency_Applied_Change_code__c', 'Irregularities');

        // Create agency applied change codes for DEF & DEFNONPAY
        Agency_Applied_Change_code__c agencyAppliedChangeCode1 = new Agency_Applied_Change_code__c();
        agencyAppliedChangeCode1.RecordTypeId = recordTypeStandard;
        agencyAppliedChangeCode1.Account__c = account1.Id;
        agencyAppliedChangeCode1.Change_Code__c = 'DEF';
        agencyAppliedChangeCode1.Reason_Description__c = 'DEFAULT-OVERDUE REMITTANCE';
        //agencyAppliedChangeCode1.DEF_Non_Payment__c = true;
        agencyAppliedChangeCode1.Date_time_of_change__c = currentDateTime;
        Agency_Applied_Change_code__c agencyAppliedChangeCode2 = new Agency_Applied_Change_code__c();
        agencyAppliedChangeCode2.RecordTypeId = recordTypeStandard;
        agencyAppliedChangeCode2.Account__c = account1.Id;
        agencyAppliedChangeCode2.Change_Code__c = 'DEF';
        agencyAppliedChangeCode2.Reason_Description__c = 'nonnonpayment';
        //agencyAppliedChangeCode2.DEF_Non_Payment__c = false;
        agencyAppliedChangeCode2.Date_time_of_change__c = DateTime.newInstance(1970, 1, 1);
        Agency_Applied_Change_code__c agencyAppliedChangeCode3 = new Agency_Applied_Change_code__c();
        agencyAppliedChangeCode3.RecordTypeId = recordTypeStandard;
        agencyAppliedChangeCode3.Account__c = account2.Id;
        agencyAppliedChangeCode3.Change_Code__c = 'DEF';
        agencyAppliedChangeCode3.Date_time_of_change__c = currentDateTime;
        Agency_Applied_Change_code__c agencyAppliedChangeCode4 = new Agency_Applied_Change_code__c();
        agencyAppliedChangeCode4.RecordTypeId = recordTypeStandard;
        agencyAppliedChangeCode4.Account__c = account2.Id;
        agencyAppliedChangeCode4.Change_Code__c = 'DWD';
        agencyAppliedChangeCode4.Date_time_of_change__c = currentDateTime;
        Agency_Applied_Change_code__c agencyAppliedChangeCode5 = new Agency_Applied_Change_code__c();
        agencyAppliedChangeCode5.RecordTypeId = recordTypeStandard;
        agencyAppliedChangeCode5.Account__c = account3.Id;
        agencyAppliedChangeCode5.Change_Code__c = 'DEF';
        agencyAppliedChangeCode5.Date_time_of_change__c = currentDateTime.addMonths(-35); // More than 12 but less than 36
        Agency_Applied_Change_code__c agencyAppliedChangeCode15 = new Agency_Applied_Change_code__c();
        agencyAppliedChangeCode15.RecordTypeId = recordTypeStandard;
        agencyAppliedChangeCode15.Account__c = account6.Id;
        agencyAppliedChangeCode15.Change_Code__c = 'DEF';
        agencyAppliedChangeCode15.Date_time_of_change__c = currentDateTime;
        Agency_Applied_Change_code__c agencyAppliedChangeCode16 = new Agency_Applied_Change_code__c();
        agencyAppliedChangeCode16.RecordTypeId = recordTypeStandard;
        agencyAppliedChangeCode16.Account__c = account6.Id;
        agencyAppliedChangeCode16.Change_Code__c = 'DEF';
        agencyAppliedChangeCode16.Date_time_of_change__c = currentDateTime;
        Agency_Applied_Change_code__c agencyAppliedChangeCode17 = new Agency_Applied_Change_code__c();
        agencyAppliedChangeCode17.RecordTypeId = recordTypeStandard;
        agencyAppliedChangeCode17.Account__c = account6.Id;
        agencyAppliedChangeCode17.Change_Code__c = 'DWD';
        agencyAppliedChangeCode17.Date_time_of_change__c = currentDateTime;

        // Create agency applied change codes for IRRS also with some country exceptions
        Agency_Applied_Change_code__c agencyAppliedChangeCode6 = new Agency_Applied_Change_code__c();
        agencyAppliedChangeCode6.RecordTypeId = recordTypeIrregularities;
        agencyAppliedChangeCode6.Account__c = account1.Id;
        agencyAppliedChangeCode6.Change_Code__c = 'IRR';
        agencyAppliedChangeCode6.Operation__c = 'A';
        agencyAppliedChangeCode6.Irregularities_Points__c = 10;
        agencyAppliedChangeCode6.Date_time_of_change__c = currentDateTime;
        Agency_Applied_Change_code__c agencyAppliedChangeCode7 = new Agency_Applied_Change_code__c();
        agencyAppliedChangeCode7.RecordTypeId = recordTypeIrregularities;
        agencyAppliedChangeCode7.Account__c = account1.Id;
        agencyAppliedChangeCode7.Change_Code__c = 'IRR';
        agencyAppliedChangeCode7.Operation__c = '';
        agencyAppliedChangeCode7.Irregularities_Points__c = 5;
        agencyAppliedChangeCode7.Date_time_of_change__c = currentDateTime;
        Agency_Applied_Change_code__c agencyAppliedChangeCode8 = new Agency_Applied_Change_code__c();
        agencyAppliedChangeCode8.RecordTypeId = recordTypeIrregularities;
        agencyAppliedChangeCode8.Account__c = account1.Id;
        agencyAppliedChangeCode8.Change_Code__c = 'IRR';
        agencyAppliedChangeCode8.Operation__c = 'W';
        agencyAppliedChangeCode8.Irregularities_Points__c = 3;
        agencyAppliedChangeCode8.Date_time_of_change__c = currentDateTime;
        Agency_Applied_Change_code__c agencyAppliedChangeCode9 = new Agency_Applied_Change_code__c();
        agencyAppliedChangeCode9.RecordTypeId = recordTypeIrregularities;
        agencyAppliedChangeCode9.Account__c = account2.Id;
        agencyAppliedChangeCode9.Change_Code__c = 'IRS';
        agencyAppliedChangeCode9.Irregularities_Points__c = 10;
        agencyAppliedChangeCode9.Date_time_of_change__c = currentDateTime;
        Agency_Applied_Change_code__c agencyAppliedChangeCode10 = new Agency_Applied_Change_code__c();
        agencyAppliedChangeCode10.RecordTypeId = recordTypeIrregularities;
        agencyAppliedChangeCode10.Account__c = account2.Id;
        agencyAppliedChangeCode10.Change_Code__c = 'IRW';
        agencyAppliedChangeCode10.Irregularities_Points__c = 5;
        agencyAppliedChangeCode10.Date_time_of_change__c = currentDateTime.addMonths(-23); // More than 12 but less than 24
        Agency_Applied_Change_code__c agencyAppliedChangeCode11 = new Agency_Applied_Change_code__c();
        agencyAppliedChangeCode11.RecordTypeId = recordTypeIrregularities;
        agencyAppliedChangeCode11.Account__c = account4.Id;
        agencyAppliedChangeCode11.Change_Code__c = 'IRS';
        agencyAppliedChangeCode11.Irregularities_Points__c = 10;
        agencyAppliedChangeCode11.Date_time_of_change__c = currentDateTime;
        Agency_Applied_Change_code__c agencyAppliedChangeCode12 = new Agency_Applied_Change_code__c();
        agencyAppliedChangeCode12.RecordTypeId = recordTypeIrregularities;
        agencyAppliedChangeCode12.Account__c = account4.Id;
        agencyAppliedChangeCode12.Change_Code__c = 'IRR';
        agencyAppliedChangeCode12.Operation__c = 'W';
        agencyAppliedChangeCode12.Irregularities_Points__c = 5;
        agencyAppliedChangeCode12.Date_time_of_change__c = currentDateTime;
        Agency_Applied_Change_code__c agencyAppliedChangeCode13 = new Agency_Applied_Change_code__c();
        agencyAppliedChangeCode13.RecordTypeId = recordTypeIrregularities;
        agencyAppliedChangeCode13.Account__c = account4.Id;
        agencyAppliedChangeCode13.Change_Code__c = 'IRW';
        agencyAppliedChangeCode13.Irregularity_Type__c = 'OV2';
        agencyAppliedChangeCode13.Irregularities_Points__c = 5;
        agencyAppliedChangeCode13.Date_time_of_change__c = currentDateTime;

        // Create agency applied change codes for own/share change & own/share last date
        Agency_Applied_Change_code__c agencyAppliedChangeCode14 = new Agency_Applied_Change_code__c();
        agencyAppliedChangeCode14.RecordTypeId = recordTypeStandard;
        agencyAppliedChangeCode14.Account__c = account1.Id;
        agencyAppliedChangeCode14.Change_Code__c = 'CHO';
        agencyAppliedChangeCode14.Date_time_of_change__c = currentDateTime;

        // Update linked collection and persist them
        agencyAppliedChangeCodesWithoutId.add(agencyAppliedChangeCode1);
        agencyAppliedChangeCodesWithoutId.add(agencyAppliedChangeCode2);
        agencyAppliedChangeCodesWithoutId.add(agencyAppliedChangeCode3);
        agencyAppliedChangeCodesWithoutId.add(agencyAppliedChangeCode4);
        agencyAppliedChangeCodesWithoutId.add(agencyAppliedChangeCode5);
        agencyAppliedChangeCodesWithoutId.add(agencyAppliedChangeCode6);
        agencyAppliedChangeCodesWithoutId.add(agencyAppliedChangeCode7);
        agencyAppliedChangeCodesWithoutId.add(agencyAppliedChangeCode8);
        agencyAppliedChangeCodesWithoutId.add(agencyAppliedChangeCode9);
        agencyAppliedChangeCodesWithoutId.add(agencyAppliedChangeCode10);
        agencyAppliedChangeCodesWithoutId.add(agencyAppliedChangeCode11);
        agencyAppliedChangeCodesWithoutId.add(agencyAppliedChangeCode12);
        agencyAppliedChangeCodesWithoutId.add(agencyAppliedChangeCode13);
        agencyAppliedChangeCodesWithoutId.add(agencyAppliedChangeCode14);
        agencyAppliedChangeCodesWithoutId.add(agencyAppliedChangeCode15);
        agencyAppliedChangeCodesWithoutId.add(agencyAppliedChangeCode16);
        agencyAppliedChangeCodesWithoutId.add(agencyAppliedChangeCode17);
        insert agencyAppliedChangeCodesWithoutId;

       // (Select Id, ANG_Event_Status__c, ANG_Risk_Type__r.ANG_Risk_ID__c, ANG_Risk_Type__r.Name
        //                                    From Location_Risk_Events__r where ANG_Event_Status__c in :REStatus AND ANG_AccountId__r.Location_Type__c = 'HE')

        ANG_Agency_Risk_Calculation__c riskCalc1 = new ANG_Agency_Risk_Calculation__c(
            ANG_Accreditation_Model__c = 'Cash',
            ANG_Adjusted__c = 'Mixed',
            ANG_Limit_Cash_Condition__c = false,
            ANG_Occurrence_Num__c = 2
        );

        insert riskCalc1;

        ANG_Risk_Event_Type__c riskType1 = new ANG_Risk_Event_Type__c (
            Name = 'Fail Financial Security',
            ANG_Risk_ID__c = '9',
            ANG_Expiration__c = 12,
            ANG_Agency_Risk_Calculation__c = riskCalc1.Id
        );

        insert riskType1;

        ANG_Agency_Risk_Event__c riskEvent1 = new ANG_Agency_Risk_Event__c(
            ANG_AccountId__c = account7.Id,
            ANG_Risk_Type__c = riskType1.Id,
            ANG_Event_Status__c = 'Active',
            ANG_Issued_Date__c = Date.today()
        );

        insert riskEvent1;

        Contact con1 = new Contact(LastName = 'testCon1', Email = 'testEmail@isTest.dummy', Preferred_language__c = 'SPANISH', AccountId = account1.Id, 
                        Status__c = 'Active', User_Portal_Status__c = 'Approved Admin');
        Insert con1;
    }

    /**
     * Test our batch
     */
    @isTest
    public static void executeBatchTest() {

        // Prepare our data
        init();

        // Execute the batch with chunk of 50
        Test.startTest();
        ANG_BatchAggregatePwcData batchAggregatePwcData = new ANG_BatchAggregatePwcData();
       // batchAggregatePwcData.query = 'SELECT Id, IATA_ISO_Country__c, Location_Class__c, AMS_PWC_INT_OWNSHA_LASTDATE__c FROM Account';
        Database.executeBatch(batchAggregatePwcData, 200);
        Test.stopTest();

        // Retrieve right data
        Account resultAccount1 = [SELECT Id, (Select AMS_PWC_INT_DEF__c, AMS_PWC_INT_DEFNONPAY__c, AMS_PWC_INT_IRRS__c, AMS_PWC_INT_OWNSHA_CHANGE__c, AMS_PWC_INT_OWNSHA_LASTDATE__c FROM Account_Aggregation_for_Integrations__r) FROM Account WHERE Name = 'AccountTest1'];
        Account resultAccount2 = [SELECT Id, (Select AMS_PWC_INT_DEF__c, AMS_PWC_INT_IRRS__c From Account_Aggregation_for_Integrations__r) FROM Account WHERE Name = 'AccountTest2'];
        Account resultAccount3 = [SELECT Id, (Select AMS_PWC_INT_DEF__c FROM Account_Aggregation_for_Integrations__r)  FROM Account WHERE Name = 'AccountTest3'];
        Account resultAccount4 = [SELECT Id, (Select AMS_PWC_INT_DEF__c, AMS_PWC_INT_IRRS__c FROM Account_Aggregation_for_Integrations__r) FROM Account WHERE Name = 'AccountTest4'];


        // Check that our data are correct - DEF
        System.assertEquals(1, resultAccount1.Account_Aggregation_for_Integrations__r[0].AMS_PWC_INT_DEF__c);
        System.assertEquals(0, resultAccount2.Account_Aggregation_for_Integrations__r[0].AMS_PWC_INT_DEF__c);
        System.assertEquals(1, resultAccount3.Account_Aggregation_for_Integrations__r[0].AMS_PWC_INT_DEF__c);

        // Check that our data are correct - DEFNONPAY
        System.assertEquals(1, resultAccount1.Account_Aggregation_for_Integrations__r[0].AMS_PWC_INT_DEFNONPAY__c);

        // Check that our data are correct - IRRS
        System.assertEquals(7, resultAccount1.Account_Aggregation_for_Integrations__r[0].AMS_PWC_INT_IRRS__c);

        System.assertEquals(5, resultAccount2.Account_Aggregation_for_Integrations__r[0].AMS_PWC_INT_IRRS__c);

        //System.assertEquals(-5, resultAccount4.Account_Aggregation_for_Integrations__r[0].AMS_PWC_INT_IRRS__c);
        System.assertEquals(0, resultAccount4.Account_Aggregation_for_Integrations__r[0].AMS_PWC_INT_IRRS__c);

        // Check that our data are correct - Own/share change
        System.assertEquals('Y', resultAccount1.Account_Aggregation_for_Integrations__r[0].AMS_PWC_INT_OWNSHA_CHANGE__c);
    }
	
	
	@isTest
    public static void testBatchScheduler(){
    	Test.startTest();
    	AMS_BatchScheduler_AggregatePwcData sh1 = new AMS_BatchScheduler_AggregatePwcData();
    	String cronExp = '0 0 23 * * ?'; 
    	system.schedule('Test Aggregate PwC data scheduler', cronExp, sh1);
    	test.StopTest();
    }
}