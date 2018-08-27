@isTest
private class AMS_UpdateAccountStateTest {

	@testSetup static void setup(){
		List<IATA_ISO_Country__c> countries = new List<IATA_ISO_Country__c>();
		IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='United States',ISO_Code__c='US');
		IATA_ISO_Country__c ctry1 = new IATA_ISO_Country__c (Name='Australia',AIMS_Area_Name__c='AUSTRALIA',ISO_Code__c='AU');
		countries.add(ctry);
		countries.add(ctry1);
        insert countries;

        List<IATA_ISO_State__c> states = new List<IATA_ISO_State__c>();
        IATA_ISO_State__c stt = new IATA_ISO_State__c(Name='Alabama',ISO_Code__c='US-AL',IATA_ISO_Country__c=ctry.id);
        IATA_ISO_State__c stt1 = new IATA_ISO_State__c(Name='ALABAMA-BAD',ISO_Code__c='US12',IATA_ISO_Country__c=ctry.id);
        IATA_ISO_State__c stt2 = new IATA_ISO_State__c(Name='Australian Capital Territory',ISO_Code__c='AU-AC',IATA_ISO_Country__c=ctry1.id);
        IATA_ISO_State__c stt3 = new IATA_ISO_State__c(Name='AUSTRALIAN CAPITAL TERR-BAD',ISO_Code__c='AU30',IATA_ISO_Country__c=ctry1.id);
        IATA_ISO_State__c stt4 = new IATA_ISO_State__c(Name='AU30',ISO_Code__c='AU30',IATA_ISO_Country__c=ctry1.id);
        IATA_ISO_State__c stt5 = new IATA_ISO_State__c(Name='AU',ISO_Code__c='AU30',IATA_ISO_Country__c=ctry1.id);
        IATA_ISO_State__c stt6 = new IATA_ISO_State__c(Name='AUSTRALIA',ISO_Code__c='AU30',IATA_ISO_Country__c=ctry1.id);
        states.add(stt);
        states.add(stt1);
        states.add(stt2);
        states.add(stt3);
        states.add(stt4);
        states.add(stt5);
        states.add(stt6);
        insert states;

        AMS_Agency__c a4 = new AMS_Agency__c(Country__c = ctry1.id, RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Agency__c', 'PASSENGER'), Name='Test Agency4', IATAcode__c = '1234561', Chk_dgt__c = '8', Legal_Name_1__c = 'Test Agency4', Legacy_External_ID__c = '12345618', Legacy_System__c = 'AIMS',OwnerId = UserInfo.getUserId());
        insert a4;
	}
	
	@isTest static void test_UpdateStates() {
		IATA_ISO_Country__c ctry = [select id,Name,ISO_Code__c,AIMS_Area_Name__c from IATA_ISO_Country__c where ISO_Code__c = 'AU'];
		IATA_ISO_State__c fakeState = [select id,Name,ISO_Code__c,IATA_ISO_Country__c from IATA_ISO_State__c where Name = 'AU30'];
		AMS_Agency__c a4 = [select id, Account__r.BillingState from AMS_Agency__c];
		Test.startTest();
        AMS_Address__c add4 = new AMS_Address__c(Country__c=ctry.id,State__c=fakeState.id,Agency__c=a4.id,Address_type__c='Billing');
        insert add4;
        //a4 = [select id, Account__r.BillingState from AMS_Agency__c];
		//system.assertEquals('AU30',a4.Account__r.BillingState);
		Database.executeBatch(new AMS_UpdateAccountState(), 100);
		Test.stopTest();
		//a4 = [select id, Account__r.BillingState from AMS_Agency__c];
		//system.assertEquals('',a4.Account__r.BillingState);
	}
	@isTest static void test_UpdateStates2() {
		IATA_ISO_Country__c ctry = [select id,Name,ISO_Code__c,AIMS_Area_Name__c from IATA_ISO_Country__c where ISO_Code__c = 'AU'];
		IATA_ISO_State__c fakeState = [select id,Name,ISO_Code__c,IATA_ISO_Country__c from IATA_ISO_State__c where Name = 'AU'];
		AMS_Agency__c a4 = [select id, Account__r.BillingState from AMS_Agency__c];
		Test.startTest();
        AMS_Address__c add4 = new AMS_Address__c(Country__c=ctry.id,State__c=fakeState.id,Agency__c=a4.id,Address_type__c='Billing');
        insert add4;
        //a4 = [select id, Account__r.BillingState from AMS_Agency__c];
		//system.assertEquals('AU30',a4.Account__r.BillingState);
		Database.executeBatch(new AMS_UpdateAccountState(), 100);
		Test.stopTest();
		//a4 = [select id, Account__r.BillingState from AMS_Agency__c];
		//system.assertEquals('',a4.Account__r.BillingState);
	}
	@isTest static void test_UpdateStates3() {
		IATA_ISO_Country__c ctry = [select id,Name,ISO_Code__c,AIMS_Area_Name__c from IATA_ISO_Country__c where ISO_Code__c = 'AU'];
		IATA_ISO_State__c fakeState = [select id,Name,ISO_Code__c,IATA_ISO_Country__c from IATA_ISO_State__c where Name = 'AUSTRALIA'];
		AMS_Agency__c a4 = [select id, Account__r.BillingState from AMS_Agency__c];
		Test.startTest();
        AMS_Address__c add4 = new AMS_Address__c(Country__c=ctry.id,State__c=fakeState.id,Agency__c=a4.id,Address_type__c='Billing');
        insert add4;
        //a4 = [select id, Account__r.BillingState from AMS_Agency__c];
		//system.assertEquals('AU30',a4.Account__r.BillingState);
		Database.executeBatch(new AMS_UpdateAccountState(), 100);
		Test.stopTest();
		//a4 = [select id, Account__r.BillingState from AMS_Agency__c];
		//system.assertEquals('',a4.Account__r.BillingState);
	}

	@isTest
	static void test_ExecuteMethod() {
		List<sObject> scopeList;

		Account account;
		IATA_ISO_Country__c country;
		IATA_ISO_State__c state;
		AMS_Address__c address;
		AMS_Agency__c agency;

		country = new IATA_ISO_Country__c(
			Name = 'Portugal',
			ISO_Code__c = 'PT',
			AIMS_Area_Name__c = 'Lisboa'
		);

		insert country;

		state = new IATA_ISO_State__c(
			Name = 'Lisboa',
			IATA_ISO_Country__c = country.Id,
			ISO_Code__c = 'LX'
		);

		insert state;
		
		address = new AMS_Address__c(
			State__c = state.Id,
			Country__c = country.Id
		);

		insert address;
		
		account = new Account(
			Name = 'Test Account',
			BillingState = 'Lisboa',
			BillingCity = 'Lisboa',
			Sector__c = 'Travel Agent',
			Location_Type__c = 'HO',
			Status__c = 'Approved',
			Company_Type__c = 'A',
			IATACode__c = '100',
			IATA_ISO_Country__c = country.Id,
			RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency')
		);

		insert account;

		agency = new AMS_Agency__c(
			Account__c = account.Id,
			Primary_Address__c = address.Id,
			Country__c = country.Id
		);

		insert agency;

		scopeList = [
			SELECT
				id,
				Primary_Address__r.State__c,
				Primary_Address__r.State__r.Name,
				Primary_Address__r.State__r.ISO_Code__c,
				Primary_Address__r.Country__r.AIMS_Area_Name__c,
				Primary_Address__r.Country__r.ISO_Code__c,
				Account__c,
				Account__r.Id,
				Account__r.BillingState
			FROM
				AMS_Agency__c
			WHERE
				    Primary_Address__c <> NULL
				AND Primary_Address__r.State__c <> NULL
				AND Primary_Address__r.Country__c <> NULL
				AND Account__r.BillingState <> NULL
		];

		AMS_UpdateAccountState updateAccountState = new AMS_UpdateAccountState();

		updateAccountState.execute(null, scopeList);
	}
}