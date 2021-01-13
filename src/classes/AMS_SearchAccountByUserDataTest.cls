@isTest
private class AMS_SearchAccountByUserDataTest {

	 @testSetup static void setup(){
		IATA_ISO_Country__c isoc = new IATA_ISO_Country__c(Name = 'Test', ISO_Code__c = 'TS');
		insert isoc;

		Account acc1HO = new Account(Name='Test Agency' ,Status__c = 'Approved' , Sector__c = 'Travel Agent' , type = 'IATA Passenger Sales Agent', Location_Class__c = 'R', IATA_ISO_Country__c = isoc.id, IATAcode__c = '1234567', Short_Name__c = 'Test Agency', AIMS_ID__c = '1234567', Is_AIMS_Account__c = true,Location_Type__c = 'HO');

		Account acc1BR = new Account(Name='Test Agency1' ,Status__c = 'Approved' , Sector__c = 'Travel Agent' , type = 'IATA Passenger Sales Agent', Location_Class__c = 'R', IATA_ISO_Country__c = isoc.id, IATAcode__c = '12345678', Short_Name__c = 'Test Agency1', AIMS_ID__c = '12345678', Is_AIMS_Account__c = true,Location_Type__c = 'BR');


		insert new List<Account>{acc1HO,acc1BR};

	}

	static testmethod void AMS_SearchAccountByUserDataTestsHO() {

	  	Test.startTest();


		Map<String,Object> inputParams = new Map<String,Object>();

		inputParams.put('Account_Name_Search_Input', 'Test Agency');
		inputParams.put('IATA_Code_searchHO', '1234567');
		inputParams.put('AccountSearchSector', 'Travel Agent');
		inputParams.put('Type_Of_OSCAR_Process', 'NEWHO');

		Process.PluginRequest request = new Process.PluginRequest(inputParams);

		AMS_SearchAccountByUserData plugin = new AMS_SearchAccountByUserData();
		plugin.invoke(request);



		inputParams = new Map<String,Object>();

		inputParams.put('Account_Name_Search_Input', 'Test Agency');
		inputParams.put('AccountSearchSector', 'Travel Agent');
		inputParams.put('Type_Of_OSCAR_Process', 'NEWHO');

		request = new Process.PluginRequest(inputParams);

		plugin = new AMS_SearchAccountByUserData();
		plugin.describe();
		plugin.invoke(request);



		inputParams = new Map<String,Object>();

		inputParams.put('IATA_Code_searchHO', '1234567');
		inputParams.put('AccountSearchSector', 'Travel Agent');
		inputParams.put('Type_Of_OSCAR_Process', 'NEWHO');

		request = new Process.PluginRequest(inputParams);

		plugin = new AMS_SearchAccountByUserData();
		plugin.invoke(request);

		Test.stopTest();

	}

	 static testmethod void AMS_SearchAccountByUserDataTestsBR() {

	  	Test.startTest();



		Map<String,Object> inputParams = new Map<String,Object>();

		inputParams.put('Account_Name_Search_Input', 'Test Agency1');
		inputParams.put('IATA_Code_searchHO', '12345678');
		inputParams.put('AccountSearchSector', 'Travel Agent');
		inputParams.put('Type_Of_OSCAR_Process', 'MAJOR.CHANGES');

		Process.PluginRequest request = new Process.PluginRequest(inputParams);

		AMS_SearchAccountByUserData plugin = new AMS_SearchAccountByUserData();
		plugin.invoke(request);

		inputParams = new Map<String,Object>();

		inputParams.put('Account_Name_Search_Input', 'Test Agency1');
		inputParams.put('AccountSearchSector', 'Travel Agent');
		inputParams.put('Type_Of_OSCAR_Process', 'MAJOR.CHANGES');

		request = new Process.PluginRequest(inputParams);

		plugin = new AMS_SearchAccountByUserData();
		plugin.describe();
		plugin.invoke(request);

		inputParams = new Map<String,Object>();

		inputParams.put('IATA_Code_searchHO', '12345678');
		inputParams.put('AccountSearchSector', 'Travel Agent');
		inputParams.put('Type_Of_OSCAR_Process', 'MAJOR.CHANGES');

		request = new Process.PluginRequest(inputParams);

		plugin = new AMS_SearchAccountByUserData();
		plugin.invoke(request);

		Test.stopTest();

	}
}
