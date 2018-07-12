@isTest
private class AMS_Batch_AggregatePwcDataTest {

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

        // Update linked collection and persist them
        isoCountriesWithoutId.add(isoCountry1);
        isoCountriesWithoutId.add(isoCountry2);
        isoCountriesWithoutId.add(isoCountry3);
        isoCountriesWithoutId.add(isoCountry4);
        isoCountriesWithoutId.add(isoCountry5);
        insert isoCountriesWithoutId;

        // Retrieve back deired record (with its ID)
        isoCountry1 = [SELECT ISO_Code__c, ISO_Code_Numeric__c FROM IATA_ISO_Country__c WHERE ISO_Code__c = 'CH' AND ISO_Code_Numeric__c = 100];
        isoCountry2 = [SELECT ISO_Code__c, ISO_Code_Numeric__c FROM IATA_ISO_Country__c WHERE ISO_Code__c = 'KZ' AND ISO_Code_Numeric__c = 200];
        isoCountry3 = [SELECT ISO_Code__c, ISO_Code_Numeric__c FROM IATA_ISO_Country__c WHERE ISO_Code__c = 'JP' AND ISO_Code_Numeric__c = 300];
        isoCountry4 = [SELECT ISO_Code__c, ISO_Code_Numeric__c FROM IATA_ISO_Country__c WHERE ISO_Code__c = 'FR' AND ISO_Code_Numeric__c = 400];
        isoCountry5 = [SELECT ISO_Code__c, ISO_Code_Numeric__c FROM IATA_ISO_Country__c WHERE ISO_Code__c = 'IT' AND ISO_Code_Numeric__c = 500];

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

        // Create accounts
        Account account1 = new Account(Name = 'AccountTest1');
        account1.Location_Class__c = 'P';
        Account account2 = new Account(Name = 'AccountTest2');
        account2.Location_Class__c = 'P';
        Account account3 = new Account(Name = 'AccountTest3');
        account3.Location_Class__c = 'P';
        Account account4 = new Account(Name = 'AccountTest4');
        account4.Location_Class__c = 'D';
        Account account5 = new Account(Name = 'AccountTest5');
        account5.Location_Class__c = 'P';
        Account account6 = new Account(Name = 'AccountTest6');
        account6.Location_Class__c = 'R';

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
        insert accountsWithoutId;

        // Retrieve back those (with IDs)
        account1 = [SELECT Id, IATA_ISO_Country__c FROM Account WHERE Name = 'AccountTest1'];
        account2 = [SELECT Id, IATA_ISO_Country__c FROM Account WHERE Name = 'AccountTest2'];
        account3 = [SELECT Id, IATA_ISO_Country__c FROM Account WHERE Name = 'AccountTest3'];
        account4 = [SELECT Id, IATA_ISO_Country__c FROM Account WHERE Name = 'AccountTest4'];
        account5 = [SELECT Id, IATA_ISO_Country__c FROM Account WHERE Name = 'AccountTest5'];
        account6 = [SELECT Id, IATA_ISO_Country__c FROM Account WHERE Name = 'AccountTest6'];

        // Required record types for Agency_Applied_Change_code__c
        Id recordTypeStandardId = RecordTypeSingleton.getInstance().getRecordTypeId('Agency_Applied_Change_code__c', 'Standard');
        Id recordTypeIrregularitiesId = RecordTypeSingleton.getInstance().getRecordTypeId('Agency_Applied_Change_code__c', 'Irregularities');

        // Create agency applied change codes for DEF & DEFNONPAY
        Agency_Applied_Change_code__c agencyAppliedChangeCode1 = new Agency_Applied_Change_code__c();
        agencyAppliedChangeCode1.RecordTypeId = recordTypeStandardId;
        agencyAppliedChangeCode1.Account__c = account1.Id;
        agencyAppliedChangeCode1.Change_Code__c = 'DEF';
        agencyAppliedChangeCode1.Reason_Description__c = 'DEFAULT-OVERDUE REMITTANCE';
        //agencyAppliedChangeCode1.DEF_Non_Payment__c = true;
        agencyAppliedChangeCode1.Date_time_of_change__c = currentDateTime;
        Agency_Applied_Change_code__c agencyAppliedChangeCode2 = new Agency_Applied_Change_code__c();
        agencyAppliedChangeCode2.RecordTypeId = recordTypeStandardId;
        agencyAppliedChangeCode2.Account__c = account1.Id;
        agencyAppliedChangeCode2.Change_Code__c = 'DEF';
        agencyAppliedChangeCode2.Reason_Description__c = 'nonnonpayment';
        //agencyAppliedChangeCode2.DEF_Non_Payment__c = false;
        agencyAppliedChangeCode2.Date_time_of_change__c = DateTime.newInstance(1970, 1, 1);
        Agency_Applied_Change_code__c agencyAppliedChangeCode3 = new Agency_Applied_Change_code__c();
        agencyAppliedChangeCode3.RecordTypeId = recordTypeStandardId;
        agencyAppliedChangeCode3.Account__c = account2.Id;
        agencyAppliedChangeCode3.Change_Code__c = 'DEF';
        agencyAppliedChangeCode3.Date_time_of_change__c = currentDateTime;
        Agency_Applied_Change_code__c agencyAppliedChangeCode4 = new Agency_Applied_Change_code__c();
        agencyAppliedChangeCode4.RecordTypeId = recordTypeStandardId;
        agencyAppliedChangeCode4.Account__c = account2.Id;
        agencyAppliedChangeCode4.Change_Code__c = 'DWD';
        agencyAppliedChangeCode4.Date_time_of_change__c = currentDateTime;
        Agency_Applied_Change_code__c agencyAppliedChangeCode5 = new Agency_Applied_Change_code__c();
        agencyAppliedChangeCode5.RecordTypeId = recordTypeStandardId;
        agencyAppliedChangeCode5.Account__c = account3.Id;
        agencyAppliedChangeCode5.Change_Code__c = 'DEF';
        agencyAppliedChangeCode5.Date_time_of_change__c = currentDateTime.addMonths(-35); // More than 12 but less than 36
        Agency_Applied_Change_code__c agencyAppliedChangeCode15 = new Agency_Applied_Change_code__c();
        agencyAppliedChangeCode15.RecordTypeId = recordTypeStandardId;
        agencyAppliedChangeCode15.Account__c = account6.Id;
        agencyAppliedChangeCode15.Change_Code__c = 'DEF';
        agencyAppliedChangeCode15.Date_time_of_change__c = currentDateTime;
        Agency_Applied_Change_code__c agencyAppliedChangeCode16 = new Agency_Applied_Change_code__c();
        agencyAppliedChangeCode16.RecordTypeId = recordTypeStandardId;
        agencyAppliedChangeCode16.Account__c = account6.Id;
        agencyAppliedChangeCode16.Change_Code__c = 'DEF';
        agencyAppliedChangeCode16.Date_time_of_change__c = currentDateTime;
        Agency_Applied_Change_code__c agencyAppliedChangeCode17 = new Agency_Applied_Change_code__c();
        agencyAppliedChangeCode17.RecordTypeId = recordTypeStandardId;
        agencyAppliedChangeCode17.Account__c = account6.Id;
        agencyAppliedChangeCode17.Change_Code__c = 'DWD';
        agencyAppliedChangeCode17.Date_time_of_change__c = currentDateTime;

        // Create agency applied change codes for IRRS also with some country exceptions
        Agency_Applied_Change_code__c agencyAppliedChangeCode6 = new Agency_Applied_Change_code__c();
        agencyAppliedChangeCode6.RecordTypeId = recordTypeIrregularitiesId;
        agencyAppliedChangeCode6.Account__c = account1.Id;
        agencyAppliedChangeCode6.Change_Code__c = 'IRR';
        agencyAppliedChangeCode6.Operation__c = 'A';
        agencyAppliedChangeCode6.Irregularities_Points__c = 10;
        agencyAppliedChangeCode6.Date_time_of_change__c = currentDateTime;
        Agency_Applied_Change_code__c agencyAppliedChangeCode7 = new Agency_Applied_Change_code__c();
        agencyAppliedChangeCode7.RecordTypeId = recordTypeIrregularitiesId;
        agencyAppliedChangeCode7.Account__c = account1.Id;
        agencyAppliedChangeCode7.Change_Code__c = 'IRR';
        agencyAppliedChangeCode7.Operation__c = '';
        agencyAppliedChangeCode7.Irregularities_Points__c = 5;
        agencyAppliedChangeCode7.Date_time_of_change__c = currentDateTime;
        Agency_Applied_Change_code__c agencyAppliedChangeCode8 = new Agency_Applied_Change_code__c();
        agencyAppliedChangeCode8.RecordTypeId = recordTypeIrregularitiesId;
        agencyAppliedChangeCode8.Account__c = account1.Id;
        agencyAppliedChangeCode8.Change_Code__c = 'IRR';
        agencyAppliedChangeCode8.Operation__c = 'W';
        agencyAppliedChangeCode8.Irregularities_Points__c = 3;
        agencyAppliedChangeCode8.Date_time_of_change__c = currentDateTime;
        Agency_Applied_Change_code__c agencyAppliedChangeCode9 = new Agency_Applied_Change_code__c();
        agencyAppliedChangeCode9.RecordTypeId = recordTypeIrregularitiesId;
        agencyAppliedChangeCode9.Account__c = account2.Id;
        agencyAppliedChangeCode9.Change_Code__c = 'IRS';
        agencyAppliedChangeCode9.Irregularities_Points__c = 10;
        agencyAppliedChangeCode9.Date_time_of_change__c = currentDateTime;
        Agency_Applied_Change_code__c agencyAppliedChangeCode10 = new Agency_Applied_Change_code__c();
        agencyAppliedChangeCode10.RecordTypeId = recordTypeIrregularitiesId;
        agencyAppliedChangeCode10.Account__c = account2.Id;
        agencyAppliedChangeCode10.Change_Code__c = 'IRW';
        agencyAppliedChangeCode10.Irregularities_Points__c = 5;
        agencyAppliedChangeCode10.Date_time_of_change__c = currentDateTime.addMonths(-23); // More than 12 but less than 24
        Agency_Applied_Change_code__c agencyAppliedChangeCode11 = new Agency_Applied_Change_code__c();
        agencyAppliedChangeCode11.RecordTypeId = recordTypeIrregularitiesId;
        agencyAppliedChangeCode11.Account__c = account4.Id;
        agencyAppliedChangeCode11.Change_Code__c = 'IRS';
        agencyAppliedChangeCode11.Irregularities_Points__c = 10;
        agencyAppliedChangeCode11.Date_time_of_change__c = currentDateTime;
        Agency_Applied_Change_code__c agencyAppliedChangeCode12 = new Agency_Applied_Change_code__c();
        agencyAppliedChangeCode12.RecordTypeId = recordTypeIrregularitiesId;
        agencyAppliedChangeCode12.Account__c = account4.Id;
        agencyAppliedChangeCode12.Change_Code__c = 'IRR';
        agencyAppliedChangeCode12.Operation__c = 'W';
        agencyAppliedChangeCode12.Irregularities_Points__c = 5;
        agencyAppliedChangeCode12.Date_time_of_change__c = currentDateTime;
        Agency_Applied_Change_code__c agencyAppliedChangeCode13 = new Agency_Applied_Change_code__c();
        agencyAppliedChangeCode13.RecordTypeId = recordTypeIrregularitiesId;
        agencyAppliedChangeCode13.Account__c = account4.Id;
        agencyAppliedChangeCode13.Change_Code__c = 'IRW';
        agencyAppliedChangeCode13.Irregularity_Type__c = 'OV2';
        agencyAppliedChangeCode13.Irregularities_Points__c = 5;
        agencyAppliedChangeCode13.Date_time_of_change__c = currentDateTime;

        // Create agency applied change codes for own/share change & own/share last date
        Agency_Applied_Change_code__c agencyAppliedChangeCode14 = new Agency_Applied_Change_code__c();
        agencyAppliedChangeCode14.RecordTypeId = recordTypeStandardId;
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
        AMS_Batch_AggregatePwcData batchAggregatePwcData = new AMS_Batch_AggregatePwcData();
        batchAggregatePwcData.query = 'SELECT Id, IATA_ISO_Country__c, Location_Class__c, AMS_PWC_INT_OWNSHA_LASTDATE__c FROM Account';
        Database.executeBatch(batchAggregatePwcData, 50);
        Test.stopTest();

        // Retrieve right data
        Account resultAccount1 = [SELECT Id, AMS_PWC_INT_DEF__c, AMS_PWC_INT_DEFNONPAY__c, AMS_PWC_INT_IRRS__c, AMS_PWC_INT_OWNSHA_CHANGE__c, AMS_PWC_INT_OWNSHA_LASTDATE__c FROM Account WHERE Name = 'AccountTest1'];
        Account resultAccount2 = [SELECT Id, AMS_PWC_INT_DEF__c, AMS_PWC_INT_IRRS__c FROM Account WHERE Name = 'AccountTest2'];
        Account resultAccount3 = [SELECT Id, AMS_PWC_INT_DEF__c FROM Account WHERE Name = 'AccountTest3'];
        Account resultAccount4 = [SELECT Id, AMS_PWC_INT_DEF__c, AMS_PWC_INT_IRRS__c FROM Account WHERE Name = 'AccountTest4'];

        // Check that our data are correct - DEF
        System.assertEquals(1, resultAccount1.AMS_PWC_INT_DEF__c);
        System.assertEquals(0, resultAccount2.AMS_PWC_INT_DEF__c);
        System.assertEquals(1, resultAccount3.AMS_PWC_INT_DEF__c);

        // Check that our data are correct - DEFNONPAY
        System.assertEquals(1, resultAccount1.AMS_PWC_INT_DEFNONPAY__c);

        // Check that our data are correct - IRRS
        System.assertEquals(12, resultAccount1.AMS_PWC_INT_IRRS__c);
        System.assertEquals(5, resultAccount2.AMS_PWC_INT_IRRS__c);
        System.assertEquals(-5, resultAccount4.AMS_PWC_INT_IRRS__c);

        // Check that our data are correct - Own/share change
        System.assertEquals('Y', resultAccount1.AMS_PWC_INT_OWNSHA_CHANGE__c);

        // Check that our data are correct - Own/share change
        System.assertEquals(currentDateTime, resultAccount1.AMS_PWC_INT_OWNSHA_LASTDATE__c);

    }
      
      
      @isTest
    public static void testBatchScheduler(){
      Test.startTest();
      AMS_BatchScheduler_AggregatePwcData sh1 = new AMS_BatchScheduler_AggregatePwcData();
      String sch = '0 0 23 * * ?'; 
      system.schedule('Test Aggregate PwC data scheduler', sch, sh1);
      test.StopTest();
    }
}