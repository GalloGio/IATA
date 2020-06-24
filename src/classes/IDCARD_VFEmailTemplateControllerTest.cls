@IsTest
public with sharing class IDCARD_VFEmailTemplateControllerTest {

	static Id massApplication = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ID_Card_Mass_Application');
	static Id singleApplication = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ID_Card_Application');

	@TestSetup
	static void makeData(){

		//create a country
		IATA_ISO_Country__c country =  new IATA_ISO_Country__c();
		country.Name = 'Portugal';
		country.ISO_Code_Numeric__c = 620;
		country.AIMS_Area_Name__c = 'Portugal';
		country.AIMS_Area_ID__c = '2';
		country.ISO_Code__c = 'PT';
		insert country;

		Price_Table__c  p1 = new Price_Table__c(CurrencyIsoCode = 'EUR', ISO_Country__c = country.Id, Type_Class_of_Agent__c  = 'Passenger', IATA_Package__c = 10, ID_Card_Fee__c = 8);
		insert p1;

		//create an account
		Account acc = new Account();
		acc.Name = 'Account Test';
		acc.IATACode__c = '1234567';
		acc.Type = 'IATA Passenger Sales Agent';
		acc.IATA_ISO_Country__c = country.Id;
		acc.Location_Type__c = 'HO';
		acc.Location_Class__c = 'P';
		acc.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
		acc.Status__c = 'Approved';
		acc.BillingCountry = 'Portugal';
		insert acc;

		//create the contacts
		Contact con = new Contact();
		con.LastName = 'IDCard';
		con.FirstName = 'Contact';
		con.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
		con.AccountId = acc.Id;
		con.Email = 'idcardcontact@test.idcard';
		con.VER_Number_2__c = '1234';
		insert con;

		//create a mass application
		ID_Card_Application__c idCardMassApp = new ID_Card_Application__c();
		idCardMassApp.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c', 'Mass_Order_Application');
		idCardMassApp.First_Name__c = 'FIRSTNAME';
		idCardMassApp.Last_Name__c = 'LASTNAME';
		idCardMassApp.Displayed_Name__c = 'FIRSTNAME LASTNAME';
		idCardMassApp.IATA_Code__c = '1234567';
		insert idCardMassApp;

		//create mass application case
		Case mass = new Case();
		mass.RecordTypeId = massApplication;
		mass.Related_ID_Card_Application__c = idCardMassApp.Id;
		mass.Subject = 'Case ID Card Test';
		mass.AccountId = acc.Id;
		insert mass;

		//create the idcard single applications
		List<ID_Card_Application__c> idCardApps = new List<ID_Card_Application__c>();
		ID_Card_Application__c ica1 = new ID_Card_Application__c();
		ica1.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c', 'Single_ID_Card_Operation');
		ica1.Title__c = 'Mr';
		ica1.First_Name__c = 'FIRSTNAME1';
		ica1.Last_Name__c = 'LASTNAME1';
		ica1.Date_of_Birth__c = Date.newInstance(1980,12,12);
		ica1.Displayed_Name__c = 'FIRSTNAME LASTNAME 1';
		ica1.Type_of_application__c = 'New';
		ica1.IATA_Code__c = '1234567';
		ica1.Email_admin__c = 'testidcard1@testmassapp.test';
		ica1.Mass_order_Application__c = idCardMassApp.Id;
		idCardApps.add(ica1);

		ID_Card_Application__c ica2 = new ID_Card_Application__c();
		ica2.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c', 'Single_ID_Card_Operation');
		ica2.Title__c = 'Mr';
		ica2.First_Name__c = 'FIRSTNAME3';
		ica2.Last_Name__c = 'LASTNAME3';
		ica2.Date_of_Birth__c = Date.newInstance(1980,12,12);
		ica2.Displayed_Name__c = 'FIRSTNAME LASTNAME 3';
		ica2.Type_of_application__c = 'New';
		ica2.IATA_Code__c = '1234567';
		ica2.Email_admin__c = 'testidcard3@testmassapp.test';
		idCardApps.add(ica2);
		insert idCardApps;

		Case single = new Case();
		single.RecordTypeId = singleApplication;
		single.Related_ID_Card_Application__c = ica2.Id;
		single.Subject = 'Case ID Card Test';
		single.AccountId = acc.Id;
		insert single;

		//create the idcards
		ID_Card__c idCard = new ID_Card__c();
		idCard.Related_Contact__c = con.id;
		idCard.Valid_To_Date__c = Date.today().addMonths(5);
		idCard.Name_on_ID_Card__c = 'test';
		idCard.VER_Number__c = '1234';
		idCard.ID_Card_Application__c = idCardApps.get(0).Id;
		idCard.Card_Status__c = IDCardUtil.CARDSTATUS_VALID;
		insert idCard;

	}

	@IsTest
	static void test_Renewal(){
		Contact c = [SELECT Id,VER_Number_2__c FROM Contact LIMIT 1];
		IDCARD_VFEmailTemplateController ctrl = new IDCARD_VFEmailTemplateController();
		
		insert new EmailTemplate__c(RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('EmailTemplate__c', 'ID_Card_Application'), Template_Type__c = 'Renewal Notice', Body_Section_1__c = 'Template Body Renewal', Template_Language__c = 'English', Signature_Details__c = '{!ID_Card__c.Fee}');
		
		Test.startTest();
		ctrl.isRenewal = true;
		ctrl.myId = c.VER_Number_2__c;

		Test.stopTest();
		System.assertEquals(ctrl.emailBody1, 'Template Body Renewal');

	}

	@IsTest
	static void test_ApprovalConfirm(){
		Case c = [SELECT Id FROM Case WHERE RecordTypeId = :massApplication LIMIT 1];
		IDCARD_VFEmailTemplateController ctrl = new IDCARD_VFEmailTemplateController();

		insert new EmailTemplate__c(RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('EmailTemplate__c', 'ID_Card_Application'), Name = 'ID Card Email Template Approval', Template_Language__c = 'English', Body_Section_1__c = 'Template Body ApprovalConfirm', Signature_Details__c = '{!ID_Card_Application__c.IATA_Code__c}');

		Test.startTest();
		ctrl.isRenewal = false;
		ctrl.isApprovalConfirm = true;
		ctrl.myId = c.Id;

		Test.stopTest();
        
		System.assertEquals(ctrl.emailBody1, 'Template Body ApprovalConfirm');

	}

	@IsTest
	static void test_v2CC(){
		Case c = [SELECT Id, Related_ID_Card_Application__c FROM Case WHERE RecordTypeId = :singleApplication LIMIT 1];
		Id_Card_Application__c ca = [SELECT Id FROM Id_Card_Application__c WHERE Id = :c.Related_ID_Card_Application__c];
		ca.Payment_Transaction_Number__c = '000';
		update ca;

		IDCARD_VFEmailTemplateController ctrl = new IDCARD_VFEmailTemplateController();

		insert new EmailTemplate__c(RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('EmailTemplate__c', 'ID_Card_Application'), Name = 'ID Card Email Template English', Template_Type__c = 'Confirmation Email', Template_Language__c = 'English', Body_Section_1__c = 'Template Body v2CC', Text_4__c = '[!2]a[2]', Signature_Details__c = '[!2]{!ID_Card_Application__c.IATA_Code__c}[2]');

		Test.startTest();
		ctrl.isRenewal = false;
		ctrl.isApprovalConfirm = false;
		ctrl.ismassApplication = false;
		ctrl.isPaymentbyCard = true;
		ctrl.myId = c.Id;

		Test.stopTest();
        
		System.assertEquals(ctrl.emailBody1, 'Template Body v2CC');

	}

	@IsTest
	static void test_v2Cheque(){
		Case c = [SELECT Id FROM Case WHERE RecordTypeId = :singleApplication LIMIT 1];
		IDCARD_VFEmailTemplateController ctrl = new IDCARD_VFEmailTemplateController();

		insert new EmailTemplate__c(RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('EmailTemplate__c', 'ID_Card_Application'), Name = 'ID Card Email Template English Cheque', Template_Type__c = 'Confirmation Email Cheque', Template_Language__c = 'English', Body_Section_1__c = 'Template Body v2Cheque', Text_4__c = '[!2]a[2]', Signature_Details__c = '{!ID_Card_Application__c.IATA_Code__c}');

		Test.startTest();
		ctrl.isRenewal = false;
		ctrl.isApprovalConfirm = false;
		ctrl.ismassApplication = false;
		ctrl.isPaymentbyCard = false;
		ctrl.myId = c.Id;

		Test.stopTest();

		System.assertEquals(ctrl.emailBody1, 'Template Body v2Cheque');

	}

	@IsTest
	static void test_v3CC(){
		Case c = [SELECT Id, Related_ID_Card_Application__c FROM Case WHERE RecordTypeId = :massApplication LIMIT 1];
		Id_Card_Application__c ca = [SELECT Id FROM Id_Card_Application__c WHERE Id = :c.Related_ID_Card_Application__c];
		ca.Payment_Transaction_Number__c = '000';
		update ca;

		IDCARD_VFEmailTemplateController ctrl = new IDCARD_VFEmailTemplateController();

		insert new EmailTemplate__c(RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('EmailTemplate__c', 'ID_Card_Application'), Name = 'ID Card Email Template English - Mass', Template_Type__c = 'Mass Confirmation Email', Template_Language__c = 'English', Body_Section_1__c = 'Template Body v3CC', Text_3__c = '[!2]a[2]', Signature_Details__c = '[!2]{!ID_Card_Application__c.IATA_Code__c}[2]');

		Test.startTest();
		ctrl.isRenewal = false;
		ctrl.isApprovalConfirm = false;
		ctrl.myId = c.Id;

		Test.stopTest();

		System.assertEquals(ctrl.emailBody1, 'Template Body v3CC');

	}

	@IsTest
	static void test_v3Cheque(){
		Case c = [SELECT Id FROM Case WHERE RecordTypeId = :massApplication LIMIT 1];
		IDCARD_VFEmailTemplateController ctrl = new IDCARD_VFEmailTemplateController();

		insert new EmailTemplate__c(RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('EmailTemplate__c', 'ID_Card_Application'), Name = 'ID Card Email Template English Cheque - Mass', Template_Type__c = 'Mass Confirmation Email Cheque', Template_Language__c = 'English', Body_Section_1__c = 'Template Body v3Cheque', Text_3__c = '[!2]a[2]', Signature_Details__c = '{!ID_Card_Application__c.IATA_Code__c}');

		Test.startTest();
		ctrl.isRenewal = false;
		ctrl.isApprovalConfirm = false;
		ctrl.myId = c.Id;

		Test.stopTest();

		System.assertEquals(ctrl.emailBody1, 'Template Body v3Cheque');

	}


}