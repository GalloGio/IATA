@isTest
private class AccountCreationCtrlTest {

	@TestSetup
	static void createData(){
		ISSP_CS__c setting = new ISSP_CS__c();
		setting.Name = 'DefaultNewAccountOwnerId';
		setting.Value__c = UserInfo.getUserId();
		insert setting;

		/** COUNTRIES */
		IATA_ISO_Country__c switzerland = new IATA_ISO_Country__c(
			Name='Switzerland',
			ISO_Code__c='CH',
			Region__c='Europe',
			Region_Province_and_Cities_Enabled__c = true,
			ISS_Office_Location__c='Switzerland'
		);
		insert switzerland;

		/** STATES */
		IATA_ISO_State__c vaud = new IATA_ISO_State__c(
			Name='Vaud',
			IATA_ISO_Country__c = switzerland.Id,
			Valid_for_Address__c = true,
			ISO_Code__c=' CH-VD'
		);
		insert vaud;
	}

    static testMethod void testUpdate() {
		IATA_ISO_Country__c country = [SELECT Id, Name from IATA_ISO_Country__c WHERE Name = 'Switzerland'];

		IATA_ISO_State__c state = [SELECT Id, Name FROM IATA_ISO_State__c WHERE Name = 'Vaud'];

		String cityName = 'Geneva';
		String cityId = PortalRegistrationSecondLevelCtrl.createIsoCity(cityName, state.Id, false);

		Account acc = new Account(
			Name = 'New Account',
			Sector__c = 'Airline',
            Category__c = 'Passenger and Cargo',
            Reason_for_creation__c = 'Created by customer',

			Business_Street__c = 'Street',
			BillingStreet = 'Street',
			ShippingStreet = 'Street',

			Business_Postal_Code__c = '1234',
			BillingPostalCode = '1234',
			ShippingPostalCode = '1234',

			BillingCountry = country.Name,
			ShippingCountry = country.Name,

			IATA_ISO_Country__c = country.Id,
			IATA_ISO_Shipping_Country__c = country.Id,

			Business_City__c = cityId,
			Business_City_Name__c = cityName,

			Geoname_Billing_City__c = cityId,
			BillingCity = cityName,

			Geoname_Shipping_City__c = cityId,
			ShippingCity = cityName,

			Iso_State__c = state.Id,
			Business_State_Name__c = state.Name,

			IATA_ISO_Billing_State__c = state.Id,
			BillingState = state.Name,

			IATA_ISO_Shipping_State__c = state.Id,
			ShippingState = state.Name
		);

        String theme = AccountCreationCtrl.getUIThemeDescription();

        String result = AccountCreationCtrl.createNewAccount(acc);
        
        System.assert(result.startsWith('accountId'));
    }
}