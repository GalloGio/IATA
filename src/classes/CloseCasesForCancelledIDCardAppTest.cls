@isTest
private class CloseCasesForCancelledIDCardAppTest {

	@testSetup
	static void testSetup(){

		//create a country
		IATA_ISO_Country__c country =  new IATA_ISO_Country__c();
        country.Name = 'Portugal';
        country.ISO_Code_Numeric__c = 620;
        country.AIMS_Area_ID__c = '2';
        country.ISO_Code__c = 'PT';
        insert country;

		//create an account
		Account acc = new Account();
		acc.Name = 'Account Test';
		acc.IATACode__c = '1234567';
        acc.Type = 'IATA Passenger Sales Agent';
		acc.IATA_ISO_Country__c = country.Id;
        acc.Location_Type__c = 'HO';
        acc.Location_Class__c = 'P';
        acc.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
        insert acc;

		//create a price table
		Price_Table__c  p1 = new Price_Table__c();
		p1.CurrencyIsoCode='CAD';
		p1.ISO_Country__c = country.Id;
		p1.Type_Class_of_Agent__c = 'Passenger';
		insert p1;

		//create one Id card application (mass application) to be updated
		ID_Card_Application__c idCardApp = new ID_Card_Application__c();
		idCardApp.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c', 'Mass_Order_Application');
		idCardApp.Title__c = 'Mr';
        idCardApp.First_Name__c = 'FIRSTNAME';
        idCardApp.Last_Name__c = 'LASTNAME';
        idCardApp.Approving_Manager_s_Email__c = 'managertest@admintest.test';
        idCardApp.Approving_Manager_s_Name__c = 'Manager';
        idCardApp.Date_of_Birth__c = Date.newInstance(1980,12,12);
        idCardApp.Displayed_Name__c = 'FIRSTNAME LASTNAME';
        idCardApp.Type_of_application__c = 'New';
        idCardApp.Gender__c = 'M';
        idCardApp.Solicitation_Flag__c = true;
        idCardApp.IATA_Code__c = '1234567';
        idCardApp.Start_Date_Agency_Year__c = '2001';
        idCardApp.Start_Date_Agency_Month__c = 'January';
        idCardApp.Start_Date_Industry__c = '2000';
        idCardApp.Duties_in_Current_Agency__c = 'Sales';
        idCardApp.Position_in_Current_Agency__c = 'Director';
        idCardApp.Hours_worked__c = '35 h or more';
        idCardApp.Email_admin__c = 'testidcard@testmassapp.test';
        idCardApp.Application_Status__c = 'Pending';
        insert idCardApp;

		//create a case
		Case cs = new Case();
		cs.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ID_Card_Application');
		cs.Related_ID_Card_Application__c = idCardApp.Id;
		cs.Subject = 'Case ID Card Test';
		cs.AccountId = acc.Id;
		insert cs;

	}


	@isTest
	static void testUpdateApplicationStatusToCompletedMassApp() {

		List<ID_Card_Application__c> idCardAppList = [SELECT Id, Application_Status__c FROM ID_Card_Application__c];

		Test.startTest();
		idCardAppList.get(0).Application_Status__c = 'Completed';

		update idCardAppList;

		Test.stopTest();

		List<Case> casesList = [SELECT Id, Status, ID_Card_Status__c FROM Case];

		//make sure that when the application status is not Cancelled, the case is not updated by the action
		System.assertNotEquals('Closed', casesList.get(0).Status);
		System.assertNotEquals('Cancelled', casesList.get(0).ID_Card_Status__c);
	}

	@isTest
	static void testUpdateApplicationStatusToCancelledMassApp() {

		List<ID_Card_Application__c> idCardAppList = [SELECT Id, Application_Status__c FROM ID_Card_Application__c];

		Test.startTest();
		idCardAppList.get(0).Application_Status__c = 'Cancelled';

		update idCardAppList;

		Test.stopTest();

		List<Case> casesList = [SELECT Id, Status, ID_Card_Status__c FROM Case];

		//make sure that when the application status is Cancelled, the case is updated by the action
		System.assertEquals('Closed', casesList.get(0).Status);
		System.assertEquals('Cancelled', casesList.get(0).ID_Card_Status__c);
	}


	@isTest
	static void testUpdateApplicationStatusToCompletedSingleApp() {

		List<ID_Card_Application__c> idCardAppList = [SELECT Id, Application_Status__c FROM ID_Card_Application__c];

		Test.startTest();
		idCardAppList.get(0).RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c', 'Single_ID_Card_Operation');
		idCardAppList.get(0).Application_Status__c = 'Completed';

		update idCardAppList;

		Test.stopTest();

		List<Case> casesList = [SELECT Id, Status, ID_Card_Status__c FROM Case];

		//make sure that when the application status is not Cancelled and not mass application, the case is not updated by the action
		System.assertNotEquals('Closed', casesList.get(0).Status);
		System.assertNotEquals('Cancelled', casesList.get(0).ID_Card_Status__c);
	}


	@isTest
	static void testUpdateApplicationStatusToCancelledSingleApp() {

		List<ID_Card_Application__c> idCardAppList = [SELECT Id, Application_Status__c FROM ID_Card_Application__c];

		Test.startTest();
		idCardAppList.get(0).RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c', 'Single_ID_Card_Operation');
		idCardAppList.get(0).Application_Status__c = 'Completed';

		update idCardAppList;

		Test.stopTest();

		List<Case> casesList = [SELECT Id, Status, ID_Card_Status__c FROM Case];

		//make sure that when the application status is Cancelled but not a mass application, the case is not updated by the action
		System.assertNotEquals('Closed', casesList.get(0).Status);
		System.assertNotEquals('Cancelled', casesList.get(0).ID_Card_Status__c);
	}


}