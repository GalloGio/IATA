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
		+ '\n' + 'Aer Lingus Limited                                                              053 EINEI Dublin Airport                                                                  DUBLIN                                       Ireland                                                                                                                                                       YYY YI 053 0010000141X00000000                                         00000000   Aer Lingus Limited                                                              DIE'
		+ '\n' + 'AEROFLOT RUSSIAN AIRLINES                                                       555 AFLSU 37 LENINGRADSKY PROSPEKT                                                        MOSCOW                                       Russian Federation                          125167                                                                                                            YYY YI 555 0010000368X000000001234567890 Coding status                 20151014ACPAEROFLOT RUSSIAN AIRLINES                                                       IRU'
		+ '\n' + 'AEROLINEAS ARGENTINA                                                            044 ARGAR BOUCHARD 5471                           9TH FLOOR                               BUENOS AIRES                                 Argentina                                   1106                                                                                                              YYY YI 044 0010000088X00000000                                         00000000   AEROLINEAS ARGENTINA                                                            BAR'

		+ '\n' + 'Inconsistency 1                                                                 001 EINEI Dublin Airport                                                                  DUBLIN                                       Ireland                                                                                                                                                       YYY YE 001 0010000142X000000001234567890 Coding status                 20151014   Inconsistency 1                                                                 DIE'
		+ '\n' + 'Inconsistency 2                                                                 002 EINEI Dublin Airport                                                                  DUBLIN                                       Ireland                                                                                                                                                       YYY YS 002 0010000143X000000001234567890 Coding status                 20151014   Inconsistency 2                                                                 DIE'
		+ '\n' + 'Inconsistency 3                                                                 003 EINEI Dublin Airport                                                                  DUBLIN                                       Ireland                                                                                                                                                       YYY YE 003 0010000144X000000001234567890 Coding status                 20151014   Inconsistency 3                                                                 DIE'
		+ '\n' + 'Inconsistency 4                                                                 004 EINEI Dublin Airport                                                                  DUBLIN                                       Ireland                                                                                                                                                       YYY YS 004 0010000145X000000001234567890 Coding status                 20151014   Inconsistency 4                                                                 DIE'
		;
  
	static void loadData() {
		// create the custom setting values
		list<UtilityCS__c> utilities = new list<UtilityCS__c>{
															new UtilityCS__c(name ='AcliFileName',value__c = 'NewAcliSyncFile'),
															new UtilityCS__c(name = 'AcliConfirmationEmailRecipients',value__c = 'buzdugac@iata.org')
															};
		insert utilities;
	}

		@isTest	
		static void testAcliNewScheduler_Error() {
		loadData();

		AcliNewScheduler.acliResponse = new AcliJavaTool.Response('{"success":false,"content":"","code":"error","message":"error"}');

		// CRON expression: Because this is a test, job executes immediately after Test.stopTest().
		String CRON_EXP = '0 0 0 15 3 ? 2022';

		test.startTest();
			// Schedule the test job
			String jobId = System.schedule('AcliNewScheduler', CRON_EXP, new AcliNewScheduler());
		test.stopTest();
	}

		@isTest	
		static void testAcliNewScheduler_Ok() {
		loadData();

		AcliNewScheduler.acliResponse = new AcliJavaTool.Response('{"success":true,"content":"content","code":"","message":""}');

		// CRON expression: Because this is a test, job executes immediately after Test.stopTest().
		String CRON_EXP = '0 0 0 15 3 ? 2022';

		test.startTest();
			// Schedule the test job
			String jobId = System.schedule('AcliNewScheduler', CRON_EXP, new AcliNewScheduler());
		test.stopTest();
	}

		@isTest	
		static void testAcliLaunchBatchScheduler_Error() {
		loadData();
		// CRON expression: Because this is a test, job executes immediately after Test.stopTest().
		String CRON_EXP = '0 0 0 15 3 ? 2022';

		test.startTest();
			// Schedule the test job
			String jobId = System.schedule('AcliLaunchBatchScheduler', CRON_EXP, new AcliLaunchBatchScheduler());
		test.stopTest();
	}
	
		@isTest	
		static void testAcliLaunchBatchScheduler_Ok() {
		
		loadData();
		String c = 'NAME1,NAME2,NUM_CODE_NULL,ICAO_DES,DES_NULL,DES_SEC_FLAG,ADDRESS1,ADDRESS2,CITY,PROV_ST_NAME,COUNTRY,POSTAL,RES_TTYPE,RES_HEAD_NAME,RES_TITLE,CO_TTYPE,EMERG_TTYPE,EMERG_HEAD_NAME,EMERG_TITLE,SITA_FLAG,ARINC_FLAG,IATA_FLAG,ATA_FLAG,MITA_FLAG,CAT_PKEY,NUM_SEC_FLAG,AIRLINE_PRF_NULL,AIRLINE_SEC_FLAG,KUNNR,ACTIVE,AOC_date,MITA_MEMBER,REQUEST_ID,REQ_STATUS,REQ_STATUS_DESCR,RECEIVED,FORMTYPE'
		+ '\n' + 'Aer Lingus Limited                                                              053 EINEI Dublin Airport                                                                  DUBLIN                                       Ireland                                                                                                                                                       YYY YI 053 0010000141X00000000                                         00000000   Aer Lingus Limited                                                              DIE';
		Document doc = new Document();
		doc.Name = AcliNewScheduler.ACLI_DOC_NAME;
		doc.Body = Blob.ValueOf(c);
		doc.FolderId = AcliNewScheduler.ACLI_FOLDER.Id;
		insert doc;

		String CRON_EXP = '0 0 0 15 3 ? 2022';

		Test.startTest();
			System.schedule('AcliLaunchBatchScheduler', CRON_EXP, new AcliLaunchBatchScheduler());
		Test.stopTest();  

		List<Document> docResult = new List<Document>();
		docResult = [SELECT Id, Name FROM Document WHERE Name =: AcliNewScheduler.ACLI_DOC_NAME];

		System.assert(docResult.isEmpty());

	}

		@isTest	
		static void testBatch() {
			loadData();
			// Create a new ISO Country
			IATA_ISO_Country__c country_i = new IATA_ISO_Country__c(Name = 'Ireland', ISO_Code__c = 'IE');
			insert country_i;
	
			IATA_ISO_Country__c country_r = new IATA_ISO_Country__c(Name = 'Russian Federation', ISO_Code__c = 'RU');
			insert country_r;
	
			IATA_ISO_Country__c country_a = new IATA_ISO_Country__c(Name = 'Argentina', ISO_Code__c = 'AR', Acli_Country__c = 'Argentina');
			insert country_a;
	
			Id AirlineHQ_RT_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
			Account EI = new Account(Name = 'Aer Lingus INTENTIONAL TYPO', Airline_designator__c = 'EI', ACLI_SAP_Id__c = '0010000141', Membership_status__c = 'Non-IATA member', RecordTypeId = AirlineHQ_RT_Id,
						IATA_ISO_Country__c = country_i.Id);
			insert EI;
	
			Id AirlineBranch_RT_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline_BR');
			Account BR = new Account(Name = 'Aer Lingus Branch', Airline_designator__c = 'EI', RecordTypeId = AirlineBranch_RT_Id,
						IATA_ISO_Country__c = country_i.Id, ParentId = EI.id);
			insert BR;
	
			Account SU = new Account(Name = 'Aeroflot INTENTIONAL TYPO', Name_on_AOC__c = 'Aeroflot INTENTIONAL TYPO', Airline_designator__c = 'SU', ACLI_SAP_Id__c = '0010000368', Membership_status__c = 'IATA member', RecordTypeId = AirlineHQ_RT_Id,
						IATA_ISO_Country__c = country_r.Id);
			insert SU;	
	
			Account Inconsistency_1 = new Account(Name = 'Inconsistency 1', Airline_designator__c = 'EI', ACLI_SAP_Id__c = '0010000142', Membership_status__c = 'Non-IATA member', RecordTypeId = AirlineHQ_RT_Id,
						IATA_ISO_Country__c = country_i.Id, Type_of__c = 'A', Acli_Status__c = 'Active Company');
			insert Inconsistency_1;
	
			Account Inconsistency_2 = new Account(Name = 'Inconsistency 2', Airline_designator__c = 'EI', ACLI_SAP_Id__c = '0010000143', Membership_status__c = 'Non-IATA member', RecordTypeId = AirlineHQ_RT_Id,
						IATA_ISO_Country__c = country_i.Id, Type_of__c = 'E', Acli_Status__c = 'Active Company');
			insert Inconsistency_2;
	
			Account Inconsistency_3 = new Account(Name = 'Inconsistency 1', Airline_designator__c = 'EI', ACLI_SAP_Id__c = '0010000144', Membership_status__c = 'Non-IATA member', RecordTypeId = AirlineHQ_RT_Id,
						IATA_ISO_Country__c = country_i.Id, Type_of__c = 'Z', Acli_Status__c = 'Inactive Company');
			insert Inconsistency_3;
	
			Account Inconsistency_4 = new Account(Name = 'Inconsistency 1', Airline_designator__c = 'EI', ACLI_SAP_Id__c = '0010000145', Membership_status__c = 'Non-IATA member', RecordTypeId = AirlineHQ_RT_Id,
						IATA_ISO_Country__c = country_i.Id, Type_of__c = 'Z', Acli_Status__c = 'Inactive Company');
			insert Inconsistency_4;	
	
			// create 1 Airline Coding case
			ID AirlineCodingRTId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Airline_Coding_Application');
			Case cs1 = new Case(recordtypeID = AirlineCodingRTId,
								  Region__c = 'China & North Asia',
								  BSPCountry__c = 'China',
								  Status = 'Open',
								  Origin = 'asd',
								  CaseArea__c = 'Accreditation',
								  Reason1__c = '3 Digit Form',
								  AccountId = SU.id,
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
			
			User u1  = ISSP_ObjectFactory.createAdminUser();

			System.runAs(u1) {                
				PermissionSetAssignment psa = new PermissionSetAssignment
				(PermissionSetId = [Select Id From PermissionSet where name = 'Airline_HQ_ACLI'].id, AssigneeId = u1.id);
				insert psa;
			}
			
			System.runAs(u1) {                
					test.startTest();	
						AcliSyncBatch batch = new AcliSyncBatch(CSV);
						Database.executeBatch(batch);
					test.stopTest();
			}		
	
			EI = [SELECT Id, Name, billingCity, MITA_Member__c FROM Account WHERE Id = :EI.Id];
			// check that all the info was updated
			System.AssertEquals('Aer Lingus Limited', EI.Name);
			System.AssertEquals('DUBLIN', EI.billingCity);
	
			SU = [SELECT Id, Name, billingCity, MITA_Member__c FROM Account WHERE Id = :SU.Id];
			// check that nothing changed in the account
			System.AssertEquals('Aeroflot INTENTIONAL TYPO', SU.Name);	
	
			// check that the coding case was updated
			cs1 = [SELECT Id, Coding_Application_ID__c, Coding_Application_Status__c, Coding_Application_Reception_Date__c, Reason1__c FROM Case WHERE Id = :cs1.Id];	
	
			// check the existing SAP Account record with the wrong SAP Id was not updated
			sapSUwrong = [SELECT Id, SAP_ID__c, Airline_Coding__c FROM SAP_Account__c WHERE Id = :sapSUwrong.Id];
			system.assertEquals(false, sapSUwrong.Airline_Coding__c);
			system.assertEquals('wrong_id', sapSUwrong.SAP_ID__c);
	
			// check the existing SAP Account record with the SAP Id from ACLI was updated
			sapSUcorrect = [SELECT Id, SAP_ID__c, Airline_Coding__c FROM SAP_Account__c WHERE Id = :sapSUcorrect.Id];
	
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

		@isTest	
		static void testBatchFail() {
			loadData();
			// Create a new ISO Country
			IATA_ISO_Country__c country_i = new IATA_ISO_Country__c(Name = 'Ireland', ISO_Code__c = 'IE');
			insert country_i;

			Id AirlineHQ_RT_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
			Account EI = new Account(Name = 'Aer Lingus INTENTIONAL TYPO', Airline_designator__c = 'EI', ACLI_SAP_Id__c = '0010000141', Membership_status__c = 'Non-IATA member', RecordTypeId = AirlineHQ_RT_Id,
						IATA_ISO_Country__c = country_i.Id);
			insert EI;

			
			test.startTest();	
						AcliSyncBatch batch = new AcliSyncBatch(CSV);
						Database.executeBatch(batch);
			test.stopTest();

			EI = [SELECT Id, Name, billingCity, MITA_Member__c FROM Account WHERE Id = :EI.Id];
			// Check if it failied since its not an ACLI User
			System.AssertEquals('Aer Lingus INTENTIONAL TYPO', EI.Name);

		}

}
