@isTest
private class IEC_CreateIndAccAddressControllerTest {

	@testSetup static void setup() {
		/*** Set IATA ISO Country ***/
		IATA_ISO_Country__c country = new IATA_ISO_Country__c();
		country.Name = 'Wakanda';
		country.ISO_Code__c = 'XW';
		country.ISO_Code_Numeric__c = 11;
		insert country;

		/*** Set IATA ISO State ***/
		IATA_ISO_State__c state = new IATA_ISO_State__c();
		state.Name = 'WAKA';
		state.ISO_Code__c = 'XW';
		state.IATA_ISO_Country__c = country.Id;
		state.IEC_Valid_SAP__c = true;
		state.Informatica_Value__c = 'XW';
		insert state;

		/*** Set HO Account ***/
		Account ho = createAccount(null, 'P', 'HO', country, state, 'HO');
		insert ho;
	}

	private static Account createAccount(Id parentId, String locationClass, String locationType, IATA_ISO_Country__c country, IATA_ISO_State__c state, String code) {
		Account acc = new Account();
		acc.Top_Parent__c = parentId;
		acc.ParentId = parentId;
		acc.Name = 'Agency Name ' + code;
		acc.Legal_name__c = 'Agency Legal Name ' + code;
		acc.TradeName__c = 'Agency Trade Name ' + code;
		acc.IATACode__c = '1233456';
		acc.Company_Type__c = 'A';
		acc.Short_Name__c = 'Agency Short Name ' + code;
		acc.Location_Type__c = locationType;
		acc.Location_Class__c = locationClass;
		acc.License_Number__c = 'L-123456';
		acc.VAT_Number__c = 'V123456';
		acc.VAT_Number_2__c = 'V1234567';
		acc.GDS__c = 'ABAC';
		acc.IATA_ISO_Country__c = country.Id;
		acc.BillingStreet = 'BStreet';
		acc.BillingCity = 'BCity';
		acc.BillingCountry = 'Wakanda';
		acc.BillingPostalCode = 'WK1234';
		acc.IATA_ISO_Billing_State__c = state.Id;
		acc.Iso_State__c = state.Id;
		acc.IATA_ISO_Shipping_Country__c = country.Id;
		acc.IATA_ISO_Shipping_State__c = state.Id;
		acc.ShippingStreet = 'SStreet';
		acc.ShippingCity = 'SCity';
		acc.ShippingCountry = 'Wakanda';
		acc.ShippingPostalCode = 'WK1234';
		acc.Email__c = code + 'homail@mail.com';
		acc.Website = 'www.' + code + '.com';
		acc.Phone = '123456789';
		acc.Fax = '123456789';
		acc.In_a_Airport__c = false;
		acc.Mobile__c = '123456789';
		acc.Abbreviated_name__c = code;
		acc.Remittance_frequency__c = 'M';
		acc.Status__c = 'Approved';
		acc.Reason__c = '91-ACCREDITED-MEETS-STANDARDS';
		acc.Sector__c = 'Travel Agent';
		acc.Category__c = 'IATA Passenger Sales Agent';
		acc.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();

		return acc;
	}
	
	@isTest static void test1() {
		Test.startTest();
		IEC_CreateIndAccAddressController ctrl = new IEC_CreateIndAccAddressController();
		ctrl.acc = [SELECT Id, Name, BillingCountry, ShippingCountry FROM Account LIMIT 1];
		ctrl.defCountry = 'XW';
		List<SelectOption> countries = ctrl.countries;
		ctrl.listOfCountries = null;
		String listOfCountries = ctrl.listOfCountries;
		ctrl.mapOfStatesStr = null;
		String mapOfStatesStr = ctrl.mapOfStatesStr;
		Test.stopTest();
	}
		
}