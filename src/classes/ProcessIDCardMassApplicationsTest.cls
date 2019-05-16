@isTest
private class ProcessIDCardMassApplicationsTest {
	
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
                acc.BillingCountry = 'Portugal';
                acc.BillingStreet = 'STREET';
                acc.BillingCity = 'CITY';
                acc.BillingPostalCode = '0101';
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
                idCardApp.Application_Status__c = 'Temp';
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
	static void testInsertApplicationStatusPaidMassApp() {

                //testing appStatus.tolowerCase().equals('paid') 
                //&& Trigger.isInsert 
                //&& accFeatures.contains(IDCardUtil.Key_Account_Feature_Immediate_Processing)

                delete [SELECT Id, Application_Status__c FROM ID_Card_Application__c];

		List<Account> accts = [SELECT Id, ID_Card_KeyAccount_features__c FROM Account];

		accts.get(0).ID_Card_KeyAccount_features__c = 'Process application without waiting for';
		update accts;
		
		ID_Card_Application__c idCardApp = new ID_Card_Application__c();
		idCardApp.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c', 'Mass_Order_Application');
		idCardApp.Title__c = 'Mr';
                idCardApp.First_Name__c = 'FIRSTNAME';
                idCardApp.Last_Name__c = 'INSERT';
                idCardApp.Approving_Manager_s_Email__c = 'managertest@admintest.test';
                idCardApp.Approving_Manager_s_Name__c = 'Manager';
                idCardApp.Date_of_Birth__c = Date.newInstance(1980,12,12);
                idCardApp.Displayed_Name__c = 'FIRSTNAME INSERT';
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
                idCardApp.Application_Status__c = 'Paid';

                Test.startTest();
                insert idCardApp;
                Test.stopTest();

                List<ID_Card_Application__c> iDCardAppList = [SELECT Id, Application_Status__c FROM ID_Card_Application__c WHERE Last_Name__c =: idCardApp.Last_Name__c];
                System.assertEquals('Paid', iDCardAppList.get(0).Application_Status__c);
	}


	@isTest 
	static void testInsertSingleApp() {

                //do nothing since is not executed in the batch
		
		ID_Card_Application__c idCardApp = new ID_Card_Application__c();
		idCardApp.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c', 'Single_ID_Card_Operation');
		idCardApp.Title__c = 'Mr';
                idCardApp.First_Name__c = 'FIRSTNAME';
                idCardApp.Last_Name__c = 'LASTNAME SINGLE';
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
                idCardApp.Application_Status__c = 'Paid';

                Test.startTest();
                insert idCardApp;
                Test.stopTest();

                List<ID_Card_Application__c> iDCardAppList = [SELECT Id, Application_Status__c FROM ID_Card_Application__c WHERE Last_Name__c =: idCardApp.Last_Name__c];
                System.assertEquals('Paid', iDCardAppList.get(0).Application_Status__c);
	}


	@isTest 
	static void testUpdateApplicationStatusPaidPaymentTypeMassApp() {

                //testing appStatus.tolowerCase().equals('paid') 
                //&& app.Payment_Type__c == IDCardUtil.PAYMENT_TYPE_CC

		List<ID_Card_Application__c> idCardApps = [SELECT Id, Application_Status__c, Payment_Type__c FROM ID_Card_Application__c];

		idCardApps.get(0).Application_Status__c = 'Paid';
		idCardApps.get(0).Payment_Type__c = 'Credit Card';

		Test.startTest();
		update idCardApps;
		Test.stopTest();

		List<Case> caseList = [SELECT Id, Status FROM Case];
                System.assertEquals('Ready for production', caseList.get(0).Status);

                List<ID_Card_Application__c> iDCardAppList = [SELECT Id, Application_Status__c FROM ID_Card_Application__c];
                System.assertEquals('Completed', iDCardAppList.get(0).Application_Status__c);
	}


	@isTest 
	static void testUpdateApplicationStatusPendingPaymentTypeAndFeaturesMassApp() {

                //testing app.Payment_Type__c != IDCardUtil.PAYMENT_TYPE_CC 
                //&& accFeatures.contains(IDCardUtil.Key_Account_Feature_Immediate_Processing) 
                //&& appStatus.tolowerCase().equals('pending')

		List<Account> accts = [SELECT Id, ID_Card_KeyAccount_features__c FROM Account];

		accts.get(0).ID_Card_KeyAccount_features__c = 'Process application without waiting for';
		update accts;
		
		List<ID_Card_Application__c> idCardApps = [SELECT Id, Application_Status__c, Payment_Type__c FROM ID_Card_Application__c];

                idCardApps.get(0).Payment_Type__c = 'Invoice';
		idCardApps.get(0).Application_Status__c = 'Pending';

		Test.startTest();
		update idCardApps;
		Test.stopTest();

		List<Case> caseList = [SELECT Id, Status FROM Case];
                System.assertNotEquals('Ready for production', caseList.get(0).Status);

                List<ID_Card_Application__c> iDCardAppList = [SELECT Id, Application_Status__c FROM ID_Card_Application__c];
                System.assertEquals('Unpaid', iDCardAppList.get(0).Application_Status__c);
	}


	@isTest 
	static void testUpdateApplicationStatusPaidPaymentTypeAndFeaturesMassApp() {

                //testing app.Payment_Type__c != IDCardUtil.PAYMENT_TYPE_CC 
                //&& Trigger.isUpdate 
                //&& !appStatus.equals(oldMap.get(app.Id).Application_Status__c) 
                //&& !accFeatures.contains(IDCardUtil.Key_Account_Feature_Immediate_Processing) 
                //&& appStatus.tolowerCase().equals('paid') 

		List<ID_Card_Application__c> idCardApps = [SELECT Id, Application_Status__c FROM ID_Card_Application__c];

		idCardApps.get(0).Application_Status__c = 'Paid';
		
		Test.startTest();
		update idCardApps;
		Test.stopTest();

		List<Case> caseList = [SELECT Id, Status FROM Case];
                System.assertEquals('Ready for production', caseList.get(0).Status);

                List<ID_Card_Application__c> iDCardAppList = [SELECT Id, Application_Status__c FROM ID_Card_Application__c];
                System.assertEquals('Completed', iDCardAppList.get(0).Application_Status__c);
	}


	@isTest 
	static void testUpdateApplicationStatusToPaidMassApp() {

                //testing appStatus.tolowerCase().equals('paid')

                List<Account> accts = [SELECT Id, ID_Card_KeyAccount_features__c FROM Account];

                accts.get(0).ID_Card_KeyAccount_features__c = 'Process application without waiting for';
                update accts;
		
		List<ID_Card_Application__c> idCardApps = [SELECT Id, Application_Status__c, Payment_Type__c FROM ID_Card_Application__c];

		Id singleRT = RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c', 'Single_ID_Card_Operation');
		Id massRT = RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c', 'Mass_Order_Application');

		ID_Card_Application__c idCardApp = new ID_Card_Application__c();
		idCardApp.RecordTypeId = singleRT;
		idCardApp.Title__c = 'Mr';
                idCardApp.First_Name__c = 'FIRSTNAME SINGLE';
                idCardApp.Last_Name__c = 'LASTNAME';
                idCardApp.Approving_Manager_s_Email__c = 'managertest@admintest.test';
                idCardApp.Approving_Manager_s_Name__c = 'Manager';
                idCardApp.Date_of_Birth__c = Date.newInstance(1980,12,12);
                idCardApp.Displayed_Name__c = 'SINGLE';
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
                idCardApp.Mass_order_Application__c = idCardApps.get(0).Id;
                idCardApp.VER_Number__c = '1234';
                idCardApp.Single_Application_Processing_Step__c = 'In Queue for processing';

                insert idCardApp;

                Contact con = new Contact();
                con.FirstName = 'FirstName';
                con.LastName = 'LastName';
                con.Email = 'FirstName@LastName.idcard';
                con.AccountId = accts.get(0).Id;
                con.VER_Number_2__c = '1234';
                insert con;

		ID_Card__c idCard = new ID_Card__c();
		idCard.Related_Contact__c = con.id;
                idCard.Valid_To_Date__c = Date.today().addMonths(5);
                idCard.Name_on_ID_Card__c = 'test';
                idCard.Card_status__c = 'Sent ID Card';
                idCard.VER_Number__c = '1234';
                insert idCard;

                idCardApps.get(0).Application_Status__c = 'Paid';
                idCardApps.get(0).Payment_Type__c = 'Invoice';

		Test.startTest();
		update idCardApps;
		Test.stopTest();

		List<Case> caseList = [SELECT Id, Status FROM Case];
                System.assertNotEquals('Ready for production', caseList.get(0).Status);

                List<ID_Card_Application__c> massApps = [SELECT Id, Payment_Credit_Card_Number__c, Payment_Type__c, Payment_Currency__c, Payment_Transaction_Number__c, Payment_Date__c, Application_Status__c FROM ID_Card_Application__c WHERE RecordTypeId = :massRT];
                List<ID_Card_Application__c> singleApps = [SELECT Id, Payment_Credit_Card_Number__c, Payment_Type__c, Payment_Currency__c, Payment_Transaction_Number__c, Payment_Date__c, Application_Status__c FROM ID_Card_Application__c WHERE RecordTypeId = :singleRT];

                System.assertEquals(massApps.get(0).Payment_Credit_Card_Number__c, singleApps.get(0).Payment_Credit_Card_Number__c);
                System.assertEquals(massApps.get(0).Payment_Type__c, singleApps.get(0).Payment_Type__c);
                System.assertEquals(massApps.get(0).Payment_Currency__c, singleApps.get(0).Payment_Currency__c);
                System.assertEquals(massApps.get(0).Payment_Transaction_Number__c, singleApps.get(0).Payment_Transaction_Number__c);
                System.assertEquals(massApps.get(0).Payment_Date__c, singleApps.get(0).Payment_Date__c);
                System.assertEquals('Paid', massApps.get(0).Application_Status__c);
                System.assertEquals('Paid', singleApps.get(0).Application_Status__c);
	}


	@isTest 
	static void testUpdatePaymentDateMassApp() {

                /*testing trigger.isUpdate 
                //&& app.Payment_Date__c != NULL 
                //&& !app.Payment_Date__c.equals(oldMap.get(app.Id).Payment_Date__c) */

                List<Account> accts = [SELECT Id, ID_Card_KeyAccount_features__c FROM Account];

                accts.get(0).ID_Card_KeyAccount_features__c = 'Process application without waiting for';
                update accts;
		
		List<ID_Card_Application__c> idCardApps = [SELECT Id, Payment_Date__c, Application_Status__c FROM ID_Card_Application__c];

		Id singleRT = RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c', 'Single_ID_Card_Operation');
		Id massRT = RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c', 'Mass_Order_Application');

		ID_Card_Application__c idCardApp = new ID_Card_Application__c();
		idCardApp.RecordTypeId = singleRT;
		idCardApp.Title__c = 'Mr';
                idCardApp.First_Name__c = 'FIRSTNAME SINGLE';
                idCardApp.Last_Name__c = 'LASTNAME';
                idCardApp.Approving_Manager_s_Email__c = 'managertest@admintest.test';
                idCardApp.Approving_Manager_s_Name__c = 'Manager';
                idCardApp.Date_of_Birth__c = Date.newInstance(1980,12,12);
                idCardApp.Displayed_Name__c = 'SINGLE';
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
                idCardApp.Mass_order_Application__c = idCardApps.get(0).Id;
                idCardApp.VER_Number__c = '1234';
                idCardApp.Single_Application_Processing_Step__c = 'In Queue for processing';

                insert idCardApp;

		idCardApps.get(0).Payment_Date__c = String.valueOf(Date.today());
		idCardApps.get(0).Application_Status__c = 'Completed';

		Test.startTest();
		update idCardApps;
		Test.stopTest();

		List<Case> caseList = [SELECT Id, Status FROM Case];
                System.assertNotEquals('Ready for production', caseList.get(0).Status);

                List<ID_Card_Application__c> massApps = [SELECT Id, Payment_Credit_Card_Number__c, Payment_Type__c, Payment_Currency__c, Payment_Transaction_Number__c, Payment_Date__c, Application_Status__c FROM ID_Card_Application__c WHERE RecordTypeId = :massRT];
                List<ID_Card_Application__c> singleApps = [SELECT Id, Payment_Credit_Card_Number__c, Payment_Type__c, Payment_Currency__c, Payment_Transaction_Number__c, Payment_Date__c, Application_Status__c FROM ID_Card_Application__c WHERE RecordTypeId = :singleRT];

                System.assertEquals(massApps.get(0).Payment_Credit_Card_Number__c, singleApps.get(0).Payment_Credit_Card_Number__c);
                System.assertEquals(massApps.get(0).Payment_Type__c, singleApps.get(0).Payment_Type__c);
                System.assertEquals(massApps.get(0).Payment_Currency__c, singleApps.get(0).Payment_Currency__c);
                System.assertEquals(massApps.get(0).Payment_Transaction_Number__c, singleApps.get(0).Payment_Transaction_Number__c);
                System.assertEquals(massApps.get(0).Payment_Date__c, singleApps.get(0).Payment_Date__c);
                System.assertEquals('Completed', massApps.get(0).Application_Status__c);
                System.assertEquals('Paid', singleApps.get(0).Application_Status__c);
	}


	@isTest 
	static void testUpdateApplicationStatusToPendingMassApp() {

                //testing execute: do nothing
		
		List<ID_Card_Application__c> idCardApps = [SELECT Id, Application_Status__c FROM ID_Card_Application__c];

		idCardApps.get(0).Application_Status__c = 'Pending';

		Test.startTest();
		update idCardApps;
		Test.stopTest();

		List<Case> caseList = [SELECT Id, Status FROM Case];
                System.assertNotEquals('Ready for production', caseList.get(0).Status);

                List<ID_Card_Application__c> iDCardAppList = [SELECT Id, Application_Status__c FROM ID_Card_Application__c];
                System.assertNotEquals('Unpaid', iDCardAppList.get(0).Application_Status__c);
	}


	@isTest 
	static void testUpdateApplicationStatusSingleApp() {
		
                //testing single app - shouldn't be updated - opposite result of testUpdateApplicationStatusPaidPaymentTypeAndFeaturesMassApp

                List<ID_Card_Application__c> idCardApps = [SELECT Id, Application_Status__c FROM ID_Card_Application__c];

                idCardApps.get(0).Application_Status__c = 'Paid';
                idCardApps.get(0).RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c', 'Single_ID_Card_Operation');
                
                Test.startTest();
                update idCardApps;
                Test.stopTest();

                List<Case> caseList = [SELECT Id, Status FROM Case];
                System.assertNotEquals('Ready for production', caseList.get(0).Status);

                List<ID_Card_Application__c> iDCardAppList = [SELECT Id, Application_Status__c FROM ID_Card_Application__c];
                System.assertNotEquals('Completed', iDCardAppList.get(0).Application_Status__c);
	}


	@isTest 
	static void testUpdateApprovingManagerNameMassApp() {

                //testing the update of a field that is not relevant for the action
		
		List<ID_Card_Application__c> idCardApps = [SELECT Id, Approving_Manager_s_Name__c FROM ID_Card_Application__c];

		idCardApps.get(0).Approving_Manager_s_Name__c = 'Manager Test';

		Test.startTest();
		update idCardApps;
		Test.stopTest();

		List<Case> caseList = [SELECT Id, Status FROM Case];
                System.assertNotEquals('Ready for production', caseList.get(0).Status);

                List<ID_Card_Application__c> iDCardAppList = [SELECT Id, Application_Status__c FROM ID_Card_Application__c];
                System.assertNotEquals('Completed', iDCardAppList.get(0).Application_Status__c);
	}
	
}