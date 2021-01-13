@isTest
private class vfIECGADMaps_tst {

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
		insert oAccreditation1;
		System.assertNotEquals(null, oAccreditation1.Id);

		Accreditation__c oAccreditation2 = IECTestUtil.CreateSampleGDPAccreditation(oAccount2, oReferenceAcc_V, oReferenceStatus_4);
		insert oAccreditation2;
		System.assertNotEquals(null, oAccreditation2.Id);

		Accreditation__c oAccreditation3 = IECTestUtil.CreateSampleGDPAccreditation(oAccount3, oReferenceAcc_G, oReferenceStatus_4);
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



	}


	static testMethod void TestGADMaps() {
		System.debug('Unit Test: Start: TestGADMaps');

		Init();

		Test.startTest();
		PageReference pgRef = Page.IECGADMaps;
		Test.setCurrentPage(pgRef);

		vfIECGADMaps pgCont = new vfIECGADMaps();

		pgCont.WWMap();
		pgCont.AUMap();
		pgCont.USMap();
		pgCont.CAMap();
		pgCont.WWMapEmail();
		pgCont.AUMapEmail();
		pgCont.USMapEmail();
		pgCont.CAMapEmail();
		pgCont.buildPagereference('http://www.iata.org');

		PageReference pgRefTest = pgCont.wwAgenciesPage;
		pgRefTest = pgCont.auAgenciesPage;
		pgRefTest = pgCont.caAgenciesPage;
		pgRefTest = pgCont.usAgenciesPage;
		Test.stopTest();

		System.debug('Unit Test: Finish: TestGADMaps');
	}


	static testMethod void TestGADMapsFlags() {
	   	System.debug('Unit Test: Start: TestGADMaps Flags handling');

		Test.startTest();
		PageReference pgRef = Page.IECGADMapsWW;
		Test.setCurrentPage(pgRef);

		vfIECGADMapDetails pgCont = new vfIECGADMapDetails();
		pgCont.showFlags = true;
		String html1 = pgCont.HtmlInfo;

		pgCont.showFlags = false;
		String html12 = pgCont.HtmlInfo;

		pgCont.showAgencies = true;
		String html2 = pgCont.HtmlInfo;

		pgCont.showEmails = true;
		String html3 = pgCont.HtmlInfo;

		Test.stopTest();

	}



	static testMethod void TestGADMapsWW() {

	   	System.debug('Unit Test: Start: TestGADMaps WW');

		Init();

		Test.startTest();
		PageReference pgRef = Page.IECGADMapsWW;
		Test.setCurrentPage(pgRef);

		vfIECGADMapDetails pgCont = new vfIECGADMapDetails();
		pgCont.queryWWData();
		Test.stopTest();
	}

	static testMethod void TestGADMapsUS() {

	   	System.debug('Unit Test: Start: TestGADMaps US');

		Init();

		Test.startTest();
		PageReference pgRef = Page.IECGADMapsUS;
		Test.setCurrentPage(pgRef);

		vfIECGADMapDetails pgCont = new vfIECGADMapDetails();
		pgCont.queryUSData();
		Test.stopTest();
	}


	static testMethod void TestGADMapsCA() {

	   	System.debug('Unit Test: Start: TestGADMaps CA');

		Init();

		Test.startTest();
		PageReference pgRef = Page.IECGADMapsCA;
		Test.setCurrentPage(pgRef);

		vfIECGADMapDetails pgCont = new vfIECGADMapDetails();
		pgCont.queryCAData();
		Test.stopTest();
	}


	static testMethod void TestGADMapsAU() {

	   	System.debug('Unit Test: Start: TestGADMaps AU');

		Init();

		Test.startTest();
		PageReference pgRef = Page.IECGADMapsAU;
		Test.setCurrentPage(pgRef);

		vfIECGADMapDetails pgCont = new vfIECGADMapDetails();
		pgCont.queryAUData();
		Test.stopTest();
	}

}
