/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 *
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class AcliSyncBatchTest {
    // create the sync file contents
    private static String CSV = 'NAME1,NAME2,NUM_CODE_NULL,ICAO_DES,DES_NULL,DES_SEC_FLAG,ADDRESS1,ADDRESS2,CITY,PROV_ST_NAME,COUNTRY,POSTAL,RES_TTYPE,RES_HEAD_NAME,RES_TITLE,CO_TTYPE,EMERG_TTYPE,EMERG_HEAD_NAME,EMERG_TITLE,SITA_FLAG,ARINC_FLAG,IATA_FLAG,ATA_FLAG,MITA_FLAG,CAT_PKEY,NUM_SEC_FLAG,AIRLINE_PRF_NULL,AIRLINE_SEC_FLAG,KUNNR,ACTIVE,AOC_date,MITA_MEMBER,REQUEST_ID,REQ_STATUS,REQ_STATUS_DESCR,RECEIVED,FORMTYPE'
        + '\n' + 'Aer Lingus Limited                                                              053 EINEI Dublin Airport                                                                  DUBLIN                                       Ireland                                                                                                                                                       YYY YI 053 0010000141X000000001234567890 Coding status                 20151014ACP'
        + '\n' + 'AEROFLOT RUSSIAN AIRLINES                                                       555 AFLSU 37 LENINGRADSKY PROSPEKT                                                        MOSCOW                                       Russian Federation                          125167                                                                                                            YYY YI 555 0010000368X00000000                                         00000000   '
        + '\n' + 'AEROLINEAS ARGENTINA                                                            044 ARGAR BOUCHARD 5471                           9TH FLOOR                               BUENOS AIRES                                 Argentina                                   1106                                                                                                              YYY YI 044 0010000088X00000000                                         00000000   ';

    static void loadData() {
        // create the custom setting values
        list<UtilityCS__c> utilities = new list<UtilityCS__c>{
                                                            new UtilityCS__c(name ='AcliFileName',value__c = 'NewAcliSyncFile'),
                                                            new UtilityCS__c(name = 'AcliConfirmationEmailRecipients',value__c = 'buzdugac@iata.org')
                                                            };
        insert utilities;
    }


    static testMethod void testAcliNewScheduler_Error() {
        loadData();

        AcliNewScheduler.acliResponse = new AcliJavaTool.Response('{"success":false,"content":"","code":"error","message":"error"}');


        // CRON expression: Because this is a test, job executes immediately after Test.stopTest().
        String CRON_EXP = '0 0 0 15 3 ? 2022';

        test.startTest();
            // Schedule the test job
            String jobId = System.schedule('AcliNewScheduler', CRON_EXP, new AcliNewScheduler());
        test.stopTest();
    }

    static testMethod void testAcliNewScheduler_Ok() {
        loadData();

        AcliNewScheduler.acliResponse = new AcliJavaTool.Response('{"success":true,"content":"content","code":"","message":""}');


        // CRON expression: Because this is a test, job executes immediately after Test.stopTest().
        String CRON_EXP = '0 0 0 15 3 ? 2022';

        test.startTest();
            // Schedule the test job
            String jobId = System.schedule('AcliNewScheduler', CRON_EXP, new AcliNewScheduler());
        test.stopTest();
    }

    static testMethod void testAcliLaunchBatchScheduler_Error() {
        loadData();
        // CRON expression: Because this is a test, job executes immediately after Test.stopTest().
        String CRON_EXP = '0 0 0 15 3 ? 2022';

        test.startTest();
            // Schedule the test job
            String jobId = System.schedule('AcliLaunchBatchScheduler', CRON_EXP, new AcliLaunchBatchScheduler());
        test.stopTest();
    }
    static testMethod void testAcliLaunchBatchScheduler_Ok() {
        loadData();
        Document doc = new Document();
        doc.Name = AcliNewScheduler.ACLI_DOC_NAME;
        doc.Body = Blob.ValueOf(CSV);
        doc.FolderId = AcliNewScheduler.ACLI_FOLDER.Id;
        insert doc;

        // CRON expression: Because this is a test, job executes immediately after Test.stopTest().
        String CRON_EXP = '0 0 0 15 3 ? 2022';

        test.startTest();
            // Schedule the test job
            String jobId = System.schedule('AcliLaunchBatchScheduler', CRON_EXP, new AcliLaunchBatchScheduler());
        test.stopTest();
    }

    static testMethod void testBatch() {
        loadData();
        // Create a new ISO Country
        IATA_ISO_Country__c country_i = new IATA_ISO_Country__c(Name = 'Ireland', ISO_Code__c = 'FR');
        insert country_i;

        IATA_ISO_Country__c country_r = new IATA_ISO_Country__c(Name = 'Russian Federation', ISO_Code__c = 'RU');
        insert country_r;

        IATA_ISO_Country__c country_a = new IATA_ISO_Country__c(Name = 'Argentina', ISO_Code__c = 'AR', Acli_Country__c = 'Argentina');
        insert country_a;

        Id AirlineHQ_RT_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
        Account EI = new Account(Name = 'Aer Lingus INTENTIONAL TYPO', Airline_designator__c = 'EI', ACLI_SAP_Id__c = '0010000141', Membership_status__c = 'Non-IATA member', RecordTypeId = AirlineHQ_RT_Id,
        			IATA_ISO_Country__c = country_i.Id);
        insert EI;

        Account SU = new Account(Name = 'Aeroflot INTENTIONAL TYPO', Name_on_AOC__c = 'Aeroflot INTENTIONAL TYPO', Airline_designator__c = 'SU', ACLI_SAP_Id__c = '0010000368', Membership_status__c = 'IATA member', RecordTypeId = AirlineHQ_RT_Id,
        			IATA_ISO_Country__c = country_r.Id);
        insert SU;

        // create 1 Airline Coding case
        ID AirlineCodingRTId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Airline_Coding_Application');
        Case cs1 = new Case(recordtypeID = AirlineCodingRTId,
                              Region__c = 'China & North Asia',
                              BSPCountry__c = 'China',
                              Status = 'Open',
                              Origin = 'asd',
                              CaseArea__c = 'Accreditation',
                              Reason1__c = '3 Digit Form',
                              AccountId = EI.id,
                              Coding_Application_ID__c = null,
                              Coding_Application_Status__c = null,
                              Coding_Application_Reception_Date__c = null,
                              Subject = 'cs1');
        insert cs1;

        // create SAP Account with wrong sap id
        SAP_Account__c sapSUwrong = new SAP_Account__c(Account__c = SU.Id, SAP_ID__c = 'wrong_id');
        insert sapSUwrong;

        // create SAP Account with wrong sap id
        SAP_Account__c sapSUcorrect = new SAP_Account__c(Account__c = SU.Id, SAP_ID__c = '0010000368');
        insert sapSUcorrect;



        // CRON expression: Because this is a test, job executes immediately after Test.stopTest().
	    String CRON_EXP = '0 0 0 15 3 ? 2022';

        test.startTest();
        	// Schedule the test job
      		//String jobId = System.schedule('ScheduleApexClassTest', CRON_EXP, new AcliLaunchBatchScheduler());

      		// test the batch
        	AcliSyncBatch batch = new AcliSyncBatch(CSV);
        	Database.executeBatch(batch);
        test.stopTest();

        EI = [SELECT Id, Name, billingCity, MITA_Member__c FROM Account WHERE Id = :EI.Id];
        // check that all the info was updated
        System.AssertEquals('Aer Lingus Limited', EI.Name);
        System.AssertEquals('DUBLIN', EI.billingCity);

        SU = [SELECT Id, Name, billingCity, MITA_Member__c FROM Account WHERE Id = :SU.Id];
        // check that name & address didn't change (only MER can change this for IATA Members)
        System.AssertEquals('AEROFLOT RUSSIAN AIRLINES', SU.Name);
        System.AssertEquals('MOSCOW', SU.billingCity);
        // check that other info did change



        // check that the coding case was updated
        cs1 = [SELECT Id, Coding_Application_ID__c, Coding_Application_Status__c, Coding_Application_Reception_Date__c, Reason1__c FROM Case WHERE Id = :cs1.Id];
        system.assertEquals(Date.newinstance(2015,10,14), cs1.Coding_Application_Reception_Date__c);
        system.assertEquals('1234567890', cs1.Coding_Application_ID__c);
        system.assertEquals('Coding status', cs1.Coding_Application_Status__c.trim());
        system.assertEquals('3 Digit Form', cs1.Reason1__c.trim());


        // check the existing SAP Account record with the wrong SAP Id was not updated
        sapSUwrong = [SELECT Id, SAP_ID__c, Airline_Coding__c FROM SAP_Account__c WHERE Id = :sapSUwrong.Id];
        system.assertEquals(false, sapSUwrong.Airline_Coding__c);
        system.assertEquals('wrong_id', sapSUwrong.SAP_ID__c);

        // check the existing SAP Account record with the SAP Id from ACLI was updated
        sapSUcorrect = [SELECT Id, SAP_ID__c, Airline_Coding__c FROM SAP_Account__c WHERE Id = :sapSUcorrect.Id];
        system.assertEquals(true, sapSUcorrect.Airline_Coding__c);

        // check that a new SAP Account record was created for EI
        SAP_Account__c sapEI = [SELECT Id, SAP_ID__c, Airline_Coding__c FROM SAP_Account__c WHERE Account__c = :EI.Id];
        system.assertEquals(true, sapEI.Airline_Coding__c);
        system.assertEquals('0010000141', sapEI.SAP_ID__c);


        // check that a new account was created for AR
        Account AR = [SELECT Id, Name, billingCity, IATA_ISO_Country__c FROM Account WHERE ACLI_SAP_Id__c = '0010000088'];
        system.assertNotEquals(null, AR);
        System.AssertEquals('AEROLINEAS ARGENTINA', AR.Name);
        System.AssertEquals('BUENOS AIRES', AR.billingCity);
        System.AssertEquals(country_a.Id, AR.IATA_ISO_Country__c);

        // check that a new SAP Account record was created for the new account
        SAP_Account__c sapAR = [SELECT Id, SAP_ID__c, Airline_Coding__c FROM SAP_Account__c WHERE Account__c = :AR.Id];
        system.assertNotEquals(null, sapAR);
        system.assertEquals(true, sapAR.Airline_Coding__c);
        system.assertEquals('0010000088', sapAR.SAP_ID__c);
    }
}