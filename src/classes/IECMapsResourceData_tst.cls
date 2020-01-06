@istest
class IECMapsResourceData_tst {


	 // CRON expression: midnight on March 15.
	 // Because this is a test, job executes
	 // immediately after Test.stopTest().
	 public static String CRON_EXP = '0 0 0 15 3 ? 2022';


		static void Init() {


				//Creates the accreditation reference table entries
				GDP_Reference_Table__c oReferenceAcc_M = IECTestUtil.createSampleGDPReferenceTableEntry('M', 'Airline Sales Office');
				oReferenceAcc_M.Table__c = 'ORGCLASS';
				insert oReferenceAcc_M;
				System.assertNotEquals(null, oReferenceAcc_M.Id);

				GDP_Reference_Table__c oReferenceAcc_G = IECTestUtil.createSampleGDPReferenceTableEntry('G', 'General Sales Agent');
				oReferenceAcc_G.Table__c = 'ORGCLASS';
				insert oReferenceAcc_G;
				System.assertNotEquals(null, oReferenceAcc_G.Id);

				GDP_Reference_Table__c oReferenceAcc_D = IECTestUtil.createSampleGDPReferenceTableEntry('D', 'Travel Agency - Domestic');
				oReferenceAcc_D.Table__c = 'ORGCLASS';
				insert oReferenceAcc_D;
				System.assertNotEquals(null, oReferenceAcc_D.Id);

				GDP_Reference_Table__c oReferenceAcc_V = IECTestUtil.createSampleGDPReferenceTableEntry('V', 'Travel Service Intermediaries');
				oReferenceAcc_V.Table__c = 'ORGCLASS';
				insert oReferenceAcc_V;
				System.assertNotEquals(null, oReferenceAcc_V.Id);




				//Creates the status reference table entries
				GDP_Reference_Table__c oReferenceStatus_4 = IECTestUtil.createSampleGDPReferenceTableEntry('4', 'ACTIVE');
				oReferenceStatus_4.Table__c = 'STATUS';
				insert oReferenceStatus_4;
				System.assertNotEquals(null, oReferenceStatus_4.Id);



				//Creates the ISO Country codes
				IATA_ISO_Country__c oISOCountry_US = IECTestUtil.CreateSampleIATAISOCountry();
				oISOCountry_US.ISO_Code__c = 'US';
				insert oISOCountry_US;
				System.assertNotEquals(null, oISOCountry_US.Id);

				IATA_ISO_Country__c oISOCountry_CA = IECTestUtil.CreateSampleIATAISOCountry();
				oISOCountry_CA.ISO_Code__c = 'CA';
				insert oISOCountry_CA;
				System.assertNotEquals(null, oISOCountry_CA.Id);




				IATA_ISO_State__c oISOState_NY = IECTestUtil.CreateSampleIATAISOState(oISOCountry_US);
				oISOState_NY.ISO_Code__c = 'US-NY';
				insert oISOState_NY;
				System.assertNotEquals(null, oISOState_NY.Id);

				IATA_ISO_State__c oISOState_WA = IECTestUtil.CreateSampleIATAISOState(oISOCountry_US);
				oISOState_WA.ISO_Code__c = 'US-WA';
				insert oISOState_WA;
				System.assertNotEquals(null, oISOState_WA.Id);

				IATA_ISO_State__c oISOState_QC = IECTestUtil.CreateSampleIATAISOState(oISOCountry_CA);
				oISOState_QC.ISO_Code__c = 'CA-QC';
				insert oISOState_QC;
				System.assertNotEquals(null, oISOState_QC.Id);





				GDP_Geo_Detail__c oGEODetail_S1 = IECTestUtil.CreateSampleGDPGeoDetail(oISOCountry_US);
				oGEODetail_S1.Sub_Continent__c = 'Sub Continent 1';
				insert oGEODetail_S1;
				System.assertNotEquals(null, oGEODetail_S1.Id);

				GDP_Geo_Detail__c oGEODetail_S2 = IECTestUtil.CreateSampleGDPGeoDetail(oISOCountry_CA);
				oGEODetail_S2.Sub_Continent__c = 'Sub Continent 1';
				insert oGEODetail_S2;
				System.assertNotEquals(null, oGEODetail_S2.Id);


				GDP_Products_Account_View__c oAccount1 = IECTestUtil.createSampleGDPAccount('Account 1', '12345678');
				oAccount1.Email_Address__c = 'account1@email.com';

				insert oAccount1;
				System.assertNotEquals(null, oAccount1.Id);

				GDP_Products_Account_View__c oAccount2 = IECTestUtil.createSampleGDPAccount('Account2', '87654321');
				oAccount2.Email_Address__c = 'account1@email.com';
				insert oAccount2;
				System.assertNotEquals(null, oAccount2.Id);

				GDP_Products_Account_View__c oAccount3 = IECTestUtil.createSampleGDPAccount('Account 3', '45698723');
				oAccount3.Email_Address__c = 'account2@email.com';
				insert oAccount3;
				System.assertNotEquals(null, oAccount3.Id);





				Accreditation__c oAccreditation1 = IECTestUtil.CreateSampleGDPAccreditation(oAccount1, oReferenceAcc_M, oReferenceStatus_4);
				oAccreditation1.Class__r = oReferenceAcc_D;
				oAccreditation1.Status__r = oReferenceStatus_4;
				insert oAccreditation1;
				System.assertNotEquals(null, oAccreditation1.Id);

				Accreditation__c oAccreditation2 = IECTestUtil.CreateSampleGDPAccreditation(oAccount2, oReferenceAcc_V, oReferenceStatus_4);
				oAccreditation2.Class__r = oReferenceAcc_G;
				oAccreditation2.Status__r = oReferenceStatus_4;
				insert oAccreditation2;
				System.assertNotEquals(null, oAccreditation2.Id);

				Accreditation__c oAccreditation3 = IECTestUtil.CreateSampleGDPAccreditation(oAccount3, oReferenceAcc_G, oReferenceStatus_4);
				oAccreditation3.Class__r = oReferenceAcc_M ;
				oAccreditation3.Status__r = oReferenceStatus_4;
				insert oAccreditation3;
				System.assertNotEquals(null, oAccreditation3.Id);



				GDP_Address__c oGDP_Address1 = IECTestUtil.CreateSampleGDPAddress(oAccount1, oISOCountry_US, oISOState_NY, oGEODetail_S1);
				insert oGDP_Address1;
				System.assertNotEquals(null, oGDP_Address1.Id);

				GDP_Address__c oGDP_Address2 = IECTestUtil.CreateSampleGDPAddress(oAccount2, oISOCountry_US, oISOState_WA, oGEODetail_S1);
				insert oGDP_Address2;
				System.assertNotEquals(null, oGDP_Address2.Id);

				GDP_Address__c oGDP_Address3 = IECTestUtil.CreateSampleGDPAddress(oAccount3, oISOCountry_CA, oISOState_QC, oGEODetail_S2);
				insert oGDP_Address3;
				System.assertNotEquals(null, oGDP_Address3.Id);


				oAccount1.Related_GDP_Address__c = oGDP_Address1.Id;
				oAccount1.Related_Accreditation_Class__c = oAccreditation1.Id;
				update oAccount1;

				oAccount2.Related_GDP_Address__c = oGDP_Address2.Id;
				oAccount2.Related_Accreditation_Class__c = oAccreditation2.Id;
				update oAccount2;

				oAccount3.Related_GDP_Address__c = oGDP_Address3.Id;
				oAccount3.Related_Accreditation_Class__c = oAccreditation3.Id;
				update oAccount3;





				//insert some stats
				GDP_Agency_Stats__c contin = new GDP_Agency_Stats__c();
				contin.Scope__c = 'Sub Continent';
				contin.Type__c = 'Daily';
				contin.Stats_Date__c = Date.today();
				contin.Key__c = 'test';
				contin.Code__c = 'test';//.toLowerCase();
				contin.Locations__c = 0;
				contin.Agencies_in_Default__c = 0;
				contin.Airline_Sales_Offices__c = 0;
				contin.Cargo_Agencies__c = 0;
				contin.Emails__c = 0;
				contin.General_Sales_Agents__c = 0;
				contin.Travel_Agencies__c = 0;
				contin.Unique_Emails__c = 0;
				contin.Agencies_in_Default_6__c = 0;
				insert contin;


		}



	 static testmethod void test1() {


			Init();
			Test.startTest();

				// Schedule the test job
				String jobId = System.schedule('IECMapsResourceData', CRON_EXP, new IECMapsResourceData(0));

					// Get the information from the CronTrigger API object
				 CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

					// Verify the expressions are the same
					System.assertEquals(CRON_EXP, ct.CronExpression);
					// Verify the job has not run
					System.assertEquals(0, ct.TimesTriggered);
		 // system.abortJob(jobId);

			Test.stopTest();


			//Check for 3 countries: US, CA
			List<GDP_Agency_Stats__c> countryList = [SELECT id, Type__c, Code__c, Locations__c, Emails__c, Unique_Emails__c  FROM GDP_Agency_Stats__c WHERE Type__c = 'Daily' AND Scope__c = 'Country'];
		 // System.assertEquals(2, countryList.size());

			//Check for 2 states in US: NY and WA
			List<GDP_Agency_Stats__c> USStatesList = [SELECT id, Type__c, Code__c, Locations__c, Emails__c, Unique_Emails__c FROM GDP_Agency_Stats__c WHERE Type__c = 'Daily' AND Scope__c = 'US States'];
			//System.assertEquals(2, USStatesList.size());

			//Check for 1 province in CA: QC
			List<GDP_Agency_Stats__c> CAProvincesList = [SELECT id, Type__c, Code__c, Locations__c, Emails__c, Unique_Emails__c FROM GDP_Agency_Stats__c WHERE Type__c = 'Daily' AND Scope__c = 'CA Provinces'];
			//System.assertEquals(1, CAProvincesList.size());

			//Check for 2 sub continents: "Sub Continent 1" and "Sub Continent 2"
			List<GDP_Agency_Stats__c> subContinentList = [SELECT id, Type__c, Code__c, Locations__c, Emails__c, Unique_Emails__c FROM GDP_Agency_Stats__c WHERE Type__c = 'Daily' AND Scope__c = 'Sub Continent'];
			//System.assertEquals(1, subContinentList.size());


			//*******************************************************************************
			//Check some stats results values
			//*******************************************************************************
			GDP_Agency_Stats__c canada;
			GDP_Agency_Stats__c usa;
			GDP_Agency_Stats__c ny;
			GDP_Agency_Stats__c wa;

			for (GDP_Agency_Stats__c country : countryList) {
				if (country.Code__c == 'ca')
						canada = country;
				else if (country.Code__c == 'us')
						usa = country;
			}

			for (GDP_Agency_Stats__c state : USStatesList) {
				if (state.Code__c == 'us-ny')
						ny = state;
				else if (state.Code__c == 'us-wa')
						wa = state;
			}


	 }


	 static testmethod void test2() {


			Init();
			Test.startTest();

				// Schedule the test job
				String jobId = System.schedule('IECMapsResourceData', CRON_EXP, new IECMapsResourceData(-3));

					// Get the information from the CronTrigger API object
				 CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];


			Test.stopTest();
	 }



			static testmethod void test3() {


			Init();
			Test.startTest();

				// Schedule the test job
				String jobId = System.schedule('IECMapsResourceData', CRON_EXP, new IECMapsResourceData(-2));

					// Get the information from the CronTrigger API object
				 CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

			Test.stopTest();
	 }


	static testmethod void test4() {


			Init();
			Test.startTest();

				// Schedule the test job
				String jobId = System.schedule('IECMapsResourceData', CRON_EXP, new IECMapsResourceData(-1));

					// Get the information from the CronTrigger API object
				 CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

			Test.stopTest();
	 }


		 static testmethod void test5() {


			Init();
			Test.startTest();

				// Schedule the test job
				String jobId = System.schedule('IECMapsResourceData', CRON_EXP, new IECMapsResourceData(1));

					// Get the information from the CronTrigger API object
				 CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

			Test.stopTest();
	 }


	 static testmethod void test6() {


			Init();
			Test.startTest();

				// Schedule the test job
				String jobId = System.schedule('IECMapsResourceData', CRON_EXP, new IECMapsResourceData(1111));

					// Get the information from the CronTrigger API object
				 CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId];

			Test.stopTest();
	 }






}
