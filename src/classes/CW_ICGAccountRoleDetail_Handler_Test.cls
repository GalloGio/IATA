@isTest
public with sharing class CW_ICGAccountRoleDetail_Handler_Test {
	/*
	Test Setup:
	*/
	@testSetup
	public static void setupRows() {
		IATA_ISO_Country__c country = CW_TestDataFactory.newISOCountry();
		insert country;

		IATA_ISO_State__c state = new IATA_ISO_State__c(IEC_Valid_SAP__c = true, IATA_ISO_Country__c = country.Id, Name = 'Ontario', ISO_Code__c = 'CA-ON');
		insert state;

		IATA_ISO_City__c city = new IATA_ISO_City__c(Name = 'München', IATA_ISO_State__c = state.id, Status__c = 'Verified', GeonameName__c = 'Madrid');
		insert city;

		Account acc = new Account(Name = 'München tëst äccôúnt', IATA_ISO_Country__c = country.Id);
		acc.Business_City__c = city.Id;
		acc.Business_Geo_Coordinates__Latitude__s = 37;
		acc.Business_Geo_Coordinates__Longitude__s = 20;

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
		accRoleDetail.Website__c = 'black@mamba.test';
		accRoleDetail.Online_Booking_System_Link__c = 'dummyvalue';
		insert accRoleDetail;   
	}
	/**
	 * @description		Case 01 - check search field values 
	 *                  (Search_By_City__c, Search_By_Company__c, Search_By_Country__c) after insert
	 */
	@isTest
	public static void insert01ard() {
		List<ICG_Account_Role_Detail__c> lstARD = [SELECT Search_By_City__c, Search_By_Company__c, Search_By_Country__c,
													CITY_FOR__C, Company_FOR__c, Country_FOR__c
													FROM ICG_Account_Role_Detail__c WHERE Website__c = 'black@mamba.test'];

		Test.startTest();
		
		System.assertEquals('München', lstARD[0].CITY_FOR__C, 'CITY_FOR__C has wrong format');
		List<String> searchValues = lstARD[0].Search_By_City__c.split(';');
		System.assertEquals('munchen', searchValues[0], 'Search_By_City__c has wrong format');

		Test.stopTest();
	}
	/**
	 * @description		Case 02 - check search field values - Account TODO - it is async so it is tricky to be tested
	 *                  (Search_By_City__c, Search_By_Company__c, Search_By_Country__c) after update
	 */
	@isTest
	public static void update02account() {
		List<Account> lstAcc = [SELECT name FROM Account WHERE name ='München tëst äccôúnt'];
		lstAcc[0].name = 'çÇáéíóúýÁÉÍÓÚÝàèìòùÀÈÌÒÙãõñäëïöüÿÄËÏÖÕÑâêîôûÂÊÎÔÛ';
		
		Test.startTest();
		
		Database.SaveResult updateResult = Database.update(lstAcc[0], false);
		System.debug(LoggingLevel.FINE, 'updateResult - update02() : ' + JSON.serialize(updateResult));
		System.debug(LoggingLevel.FINE, 'lstAcc[0] - update02() : ' + JSON.serialize(lstAcc[0]));
		List<Account> lstAcc2 = [SELECT name FROM Account WHERE id = :lstAcc[0].Id];
		System.debug(LoggingLevel.FINE, 'lstAcc2 - update02() : ' + JSON.serialize(lstAcc2));

		List<ICG_Account_Role_Detail__c> lstARD = [SELECT Search_By_City__c, Search_By_Company__c, Search_By_Country__c,
													CITY_FOR__C, Company_FOR__c, Country_FOR__c
													FROM ICG_Account_Role_Detail__c WHERE Website__c = 'black@mamba.test'];
		
		System.assertEquals('çÇáéíóúýÁÉÍÓÚÝàèìòùÀÈÌÒÙãõñäëïöüÿÄËÏÖÕÑâêîôûÂÊÎÔÛ', lstARD[0].Company_FOR__c, 'Company_FOR__c has wrong format');


		Test.stopTest();
		
		List<ICG_Account_Role_Detail__c> lstARDASINC = [SELECT Search_By_City__c, Search_By_Company__c, Search_By_Country__c,
													CITY_FOR__C, Company_FOR__c, Country_FOR__c
													FROM ICG_Account_Role_Detail__c WHERE Website__c = 'black@mamba.test'];
		List<String> searchValues = lstARDASINC[0].Search_By_Company__c.split(';');
		System.assertEquals('ccaeiouyaeiouyaeiouaeiouaonaeiouyaeioonaeiouaeiou', searchValues[0], 'Search_By_Company__c has wrong format');
	}
	/**
	 * @description		Case 03 - check search field values - IATA_ISO_City__c
	 *                  (Search_By_City__c, Search_By_Company__c, Search_By_Country__c) after update
	 */
	@isTest
	public static void update03city() {
		List<IATA_ISO_City__c> lstCities = [SELECT name FROM IATA_ISO_City__c WHERE name ='München'];
		lstCities[0].name = 'çÇáéíóúýÁÉÍÓÚÝàèìòùÀÈÌÒÙãõñäëïöüÿÄËÏÖÕÑâêîôûÂÊÎÔÛ';
		Database.SaveResult updateResult = Database.update(lstCities[0], false);

		Test.startTest();
		List<ICG_Account_Role_Detail__c> lstARD = [SELECT Search_By_City__c, Search_By_Company__c, Search_By_Country__c,
													CITY_FOR__C, Company_FOR__c, Country_FOR__c
													FROM ICG_Account_Role_Detail__c WHERE Website__c = 'black@mamba.test'];

		System.assertEquals('çÇáéíóúýÁÉÍÓÚÝàèìòùÀÈÌÒÙãõñäëïöüÿÄËÏÖÕÑâêîôûÂÊÎÔÛ', lstARD[0].City_FOR__c, 'CITY_FOR__C has wrong format');
		List<String> searchValues = lstARD[0].Search_By_City__c.split(';');
		System.assertEquals('ccaeiouyaeiouyaeiouaeiouaonaeiouyaeioonaeiouaeiou', searchValues[0], 'Search_By_City__c has wrong format');

		Test.stopTest();
	}
	/**
	 * @description		Case 04 - check search field values - IATA_ISO_Country__c
	 *                  (Search_By_City__c, Search_By_Company__c, Search_By_Country__c) after update
	 */
	@isTest
	public static void update04country() {
		List<IATA_ISO_Country__c> lstCountries = [SELECT name FROM IATA_ISO_Country__c WHERE name ='Spain'];
		lstCountries[0].name = 'SpáÍñ';
		Database.SaveResult updateResult = Database.update(lstCountries[0], false);

		Test.startTest();
		List<ICG_Account_Role_Detail__c> lstARD = [SELECT Search_By_City__c, Search_By_Company__c, Search_By_Country__c,
													CITY_FOR__C, Company_FOR__c, Country_FOR__c
													FROM ICG_Account_Role_Detail__c WHERE Website__c = 'black@mamba.test'];
		
		System.assertEquals('SpáÍñ', lstARD[0].Country_FOR__c, 'Country_FOR__c has wrong format');
		List<String> searchValues = lstARD[0].Search_By_Country__c.split(';');
		System.assertEquals('spain', searchValues[0], 'Search_By_Country__c has wrong format');

		Test.stopTest();
	}
	/**
	 * @description		Case 05 - check search field values - IATA_ISO_City__c with umlaute values
	 *                  (Search_By_City__c, Search_By_Company__c, Search_By_Country__c) after update
	 */
	@isTest
	public static void update05cityUmlaute() {
		List<IATA_ISO_City__c> lstCities = [SELECT name FROM IATA_ISO_City__c WHERE name ='München'];
		lstCities[0].name = 'äöüßÄÖÜ';
		Database.SaveResult updateResult = Database.update(lstCities[0], false);

		Test.startTest();
		List<ICG_Account_Role_Detail__c> lstARD = [SELECT Search_By_City__c, Search_By_Company__c, Search_By_Country__c,
													CITY_FOR__C, Company_FOR__c, Country_FOR__c
													FROM ICG_Account_Role_Detail__c WHERE Website__c = 'black@mamba.test'];

													System.assertEquals('äöüßÄÖÜ', lstARD[0].City_FOR__c, 'CITY_FOR__C has wrong format');
		List<String> searchValues = lstARD[0].Search_By_City__c.split(';');
		System.assertEquals('aeoeuessaeoeue', searchValues[2], 'Search_By_City__c has wrong format');

		Test.stopTest();
	}
}