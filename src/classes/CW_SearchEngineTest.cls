/*
 * @author
 * Description: CW_SearchEngine Tests
 */
@isTest
public with sharing class CW_SearchEngineTest {
	/*
	Test Setup:
	*/
	@testSetup
	public static void setupRows() {
		IATA_ISO_Country__c country = CW_TestDataFactory.newISOCountry();
		insert country;

		IATA_ISO_State__c state = new IATA_ISO_State__c(IEC_Valid_SAP__c = true, IATA_ISO_Country__c = country.Id, Name = 'Ontario', ISO_Code__c = 'CA-ON');
		insert state;

		IATA_ISO_City__c city = new IATA_ISO_City__c(Name = 'Madrid', IATA_ISO_State__c = state.id, Status__c = 'Verified', GeonameName__c = 'Madrid');
		insert city;

		Account acc = new Account(Name = 'Account01', IATA_ISO_Country__c = country.Id);
		acc.Business_City__c = city.Id;
		acc.Business_Geo_Coordinates__Latitude__s = 37;
		acc.Business_Geo_Coordinates__Longitude__s = 20;
		acc.RecordTypeId = CW_TestDataFactory.getRecTypesNotStandard().Id;

		insert acc;

		Airport_Detail__c airport = CW_TestDataFactory.newAirport(country.Id, acc.Id);
		insert airport;

		Account_Role__c accRole = CW_TestDataFactory.testAccountRole(acc.Id, 'Test');
		insert accRole;

		ICG_Account_Role_Detail__c accRoleDetail = CW_TestDataFactory.testICGAccountRoleDetail(accRole.Id, airport);
		accRoleDetail.Customer_Service_Email__c = 'custom@emai.es';
		accRoleDetail.Customer_Service_Phone_Number__c = '234123432';
		accRoleDetail.Is_On_Airport__c = true;
		accRoleDetail.Is_Direct_Ramp_Access__c = true;
		accRoleDetail.General_Cargo__c = true;
		accRoleDetail.Website__c = 'website.es';
		accRoleDetail.Online_Booking_System_Link__c = 'dummyvalue';
		insert accRoleDetail;

		ICG_Account_Role_Detail_Relationship__c ardr = new ICG_Account_Role_Detail_Relationship__c();
		ardr.ICG_Account_Role_Detail__c = accRoleDetail.Id;
		ardr.Handled_Airline__c = acc.Id;
		insert ardr;

		List<ICG_Certification__c> lstCertis = new List<ICG_Certification__c>();
		ICG_Certification__c cert = CW_TestDataFactory.newCertification();
		lstCertis.add(cert);
		ICG_Certification__c newcert = CW_TestDataFactory.newCertification();
		newcert.name = 'AnotherName';
		newcert.certification_type__C = 'Certifications of Excellency';
		lstCertis.add(newcert);

		insert lstCertis;

		List<ICG_Capability_Assignment_Group__c> lstJoins = new List<ICG_Capability_Assignment_Group__c>();
		ICG_Capability_Assignment_Group__c joinrow1 = new ICG_Capability_Assignment_Group__c();
		joinrow1.ICG_Certification__c = cert.Id;
		joinrow1.Expiration_Date__c = Date.valueOf('2025-09-16');
		joinrow1.Issue_Date__c = Date.valueOf('2020-09-09');
		joinrow1.ICG_Account_Role_Detail__c = accRoleDetail.Id;
		lstJoins.add(joinrow1);
		insert lstJoins;

		CW_SearchEngine.Certification cert2 = new CW_SearchEngine.Certification(joinrow1);
		CW_SearchEngine.Certification cert3 = new CW_SearchEngine.Certification(cert, joinrow1);

		ICG_Certification_Capability_Assignment__c capability = new ICG_Certification_Capability_Assignment__c();
		capability.ICG_Certification__c = cert.id;
		capability.Category__c = 'CCTV';
		capability.Equipment__c = 'CCTV';
        insert capability;

        Account_Role_Detail_Capability__c ardCap = CW_TestDataFactory.createAccountRoleDetailCapability('Beneficial_Insects_Bees', 'Live_Animals_Capacities_1', null);
		insert ardCap;
        
        ICG_Account_Role_Capability_Assignment__c assignment = CW_TestDataFactory.createIcgAccountRoleCapabilityAssignment(accRoleDetail.Id, ardCap.Id);
		assignment.ICG_Capability_Assignment_Group__c = joinrow1.id;
        insert assignment;
	}
	/*
	* @author
	* Description: case 1 - Query with Like, without inner queries
							- Sending one value per Country || City || NearestAirport too
	*/
	@isTest
	public static void queryLikeOk() {
		String queryLike = '[{"operator":"LIKE","value":"MAD","obj":"ICG_Account_Role_Detail__c","fields":["Nearest_Airport__r.name","Country_FOR__c","City_FOR__c"]}]';

		Test.startTest();
		String response = CW_SearchEngine.getInfo(queryLike, false, true, true, false, false, null, null, true);
		List<CW_SearchEngine.OutputRow> wrapperParams = (List<CW_SearchEngine.OutputRow>) JSON.deserialize(response, List<CW_SearchEngine.OutputRow>.class);

		System.assert(wrapperParams[0].isSuccess, 'communication with query mapquery fails');

		Test.stopTest();
	}

	/*
	* @author
	* Description: case 2 - Query with Like, with inner queries
						- Sending more than one certifications grouped in one row
						- Sending one value per Country || City || NearestAirport too
	*/
	@isTest
	public static void queryCertificationsOK() {
		String queryWithInner = '[{"obj":"ICG_Account_Role_Detail__c","field":"City_FOR__c","operator":"LIKE","value":"MAD","fields":["Nearest_Airport__r.name","Country_FOR__c","City_FOR__c"]},{"obj":"ICG_Capability_Assignment_Group__c","field":"ICG_Certification__r.Name","operator":"LIKE","relationfield":"ICG_Account_Role_Detail__c","value":"CEIV Security;CEIV Fresh;CEIV Live Animals","fields":["ICG_Certification__r.Name"]}]';

		Test.startTest();
		String response = CW_SearchEngine.getInfo(queryWithInner, false, true, true, false, false, null, null, false);
		List<CW_SearchEngine.OutputRow> wrapperParams = (List<CW_SearchEngine.OutputRow>) JSON.deserialize(response, List<CW_SearchEngine.OutputRow>.class);

		System.assert(wrapperParams[0].isSuccess, 'Response is not success');

		Test.stopTest();
	}

	/*
	 * @author
	 * Description: case 3 - mapQuery param True
	 */
	@isTest
	public static void mapQuery() {
		String queryLike = '[{"operator":"LIKE","value":"MAD","obj":"ICG_Account_Role_Detail__c","fields":["Nearest_Airport__r.name","Country_FOR__c","City_FOR__c"]}]';

		Test.startTest();
		String response = CW_SearchEngine.getInfo(queryLike, true, true, true, false, false, null, null, true);
		List<CW_SearchEngine.OutputRow> wrapperParams = (List<CW_SearchEngine.OutputRow>) JSON.deserialize(response, List<CW_SearchEngine.OutputRow>.class);

		System.assert(wrapperParams[0].isSuccess, 'communication with query mapquery fails');
		Test.stopTest();
	}
	/*
	 * @author
	 * Description: case 4 - searching by geocoordinates
	 */
	@isTest
	public static void mapByCoordinates() {
		String queryLike = '[{"obj":"ICG_Account_Role_Detail__c","fields":["Account_Role__r.Account__r.Business_Geo_Coordinates__Latitude__s"],"operator":"<","value":"46.16867468034823"},{"obj":"ICG_Account_Role_Detail__c","fields":["Account_Role__r.Account__r.Business_Geo_Coordinates__Longitude__s"],"operator":"<","value":"28.20297723702101"},{"obj":"ICG_Account_Role_Detail__c","fields":["Account_Role__r.Account__r.Business_Geo_Coordinates__Latitude__s"],"operator":">","value":"36.4259997342448"},{"obj":"ICG_Account_Role_Detail__c","fields":["Account_Role__r.Account__r.Business_Geo_Coordinates__Longitude__s"],"operator":">","value":"-26.42104620047899"}]';

		Test.startTest();
		String response = CW_SearchEngine.getInfo(queryLike, true, true, true, false, false, null, null, true);
		List<CW_SearchEngine.OutputRow> wrapperParams = (List<CW_SearchEngine.OutputRow>) JSON.deserialize(response, List<CW_SearchEngine.OutputRow>.class);

		System.assert(wrapperParams[0].isSuccess, 'communication with query mapquery fails');
		Test.stopTest();
	}

	/*
	 * @author
	 * Description: case 3 - mapQuery param True
	 */
	@isTest
	public static void filterResultsAfterQueryTest() {
		String queryLike = '[{"operator":"=","value":"Beneficial_Insects_Bees","obj":"ICG_Account_Role_Capability_Assignment__c", "field":"Account_Role_Detail_Capability__r.Equipment__c", "fields":["Account_Role_Detail_Capability__r.Equipment__c"], "isOutOfQuery": true}]';
		Test.startTest();
		String response = CW_SearchEngine.getInfo(queryLike, true, true, true, false, false, null, null, true);
		List<CW_SearchEngine.OutputRow> wrapperParams = (List<CW_SearchEngine.OutputRow>) JSON.deserialize(response, List<CW_SearchEngine.OutputRow>.class);

		System.assertEquals(wrapperParams[0].isSuccess, true, 'communication with query mapquery fails'+ response);
		Test.stopTest();
	}
}