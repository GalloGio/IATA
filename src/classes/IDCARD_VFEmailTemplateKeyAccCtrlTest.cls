@isTest
private class IDCARD_VFEmailTemplateKeyAccCtrlTest{

	@TestSetup
	static void makeData(){
		IATA_ISO_Country__c country =  new IATA_ISO_Country__c();
		country.Name = 'Canada';
		country.AIMS_Area_Name__c = 'CANADA';
		country.ISO_Code_Numeric__c = 990;
		country.AIMS_Area_ID__c = '1';
		country.ISO_Code__c = 'CA';
		insert country;

		Account theAccount = new Account();
		theAccount.RecordTypeId = '012w0000000QBMW';
		theAccount.Name = 'UnitTest Account';
		theAccount.IATACode__c = '5553567';
		theAccount.Industry = 'Cargo Agent';
		theAccount.Type = 'TIDS Agent';
		theAccount.BillingCity = 'Montreal';
		theAccount.BillingCountry = 'Canada';
		theAccount.BillingPostalCode = 'H0H 0H0';
		theAccount.Status__c = 'Approved';
		insert theAccount;
		
		//create the contacts
		Contact con = new Contact();
		con.LastName = 'IDCard';
		con.FirstName = 'Contact';
		con.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
		con.AccountId = theAccount.Id;
		con.Email = 'idcardcontact@test.idcard';
		con.VER_Number_2__c = '1234';
		insert con;

		ID_Card_Application__c application = new ID_Card_Application__c();
		application.IATA_Code__c = '5553567';
		application.Type_of_application__c = IDCardUtil.APPLICATIONTYPE_NEW;
		application.First_Name__c = 'UTest';
		application.Last_Name__c = 'Unit';
		application.Displayed_Name__c = 'UTest Unit';
		insert application;

		EmailTemplate__c eTEN = new EmailTemplate__c();
		eTEN.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('EmailTemplate__c', 'ID_Card_Application');
		eTEN.Name = 'ID Card Email Template Application Approval EN';
		eTEN.greeting_line__c = 'Dear {!ID_Card_Application__c.Displayed_Name__c},';
		eTEN.Body_Section_1__c = 'Your application has the First Name: {!Account.KeyCountact.First_Name__c}.';
		eTEN.Body_Section_2__c = 'Your application has the Last Name: {!Account.KeyCountact.Last_Name__c}.';
		eTEN.Signature_Details__c = 'Best Regards {!ID_Card_Application__c.Case_Number__c}.';
		insert eTEN;
	}

	@isTest
	static void processText_Error_Test() {
		//call the function without a field (Displayed_Name__c) in the app query
		ID_Card_Application__c app = [SELECT Id, First_Name__c, Last_Name__c FROM ID_Card_Application__c WHERE IATA_Code__c = '5553567' LIMIT 1];
		Contact con = [SELECT ID, FirstName, LastName FROM Contact WHERE Email = 'idcardcontact@test.idcard'];
		IDCARD_VFEmailTemplateKeyAccController ctrl = new IDCARD_VFEmailTemplateKeyAccController();
		ctrl.myID = app.Id;
		ctrl.recipientId = con.Id;
		ctrl.language = 'English';
		ctrl = new IDCARD_VFEmailTemplateKeyAccController();
		String result = '';
		String text = 'Test for the Id Card with the First Name {!Account.KeyCountact.First_Name__c}, the Last Name {!Account.KeyCountact.Last_Name__c} and the Display Name {!ID_Card_Application__c.Displayed_Name__c}';

		Test.startTest();
			result = ctrl.processText(text, app, con);
		Test.stopTest();

		System.assert(result.contains('{!Account.KeyCountact.First_Name__c}'));
		System.assert(result.contains('{!Account.KeyCountact.Last_Name__c}'));
		System.assert(result.contains('{!ID_Card_Application__c.Displayed_Name__c}'));
		System.assert(result.equals('Test for the Id Card with the First Name {!Account.KeyCountact.First_Name__c}, the Last Name {!Account.KeyCountact.Last_Name__c} and the Display Name {!ID_Card_Application__c.Displayed_Name__c}'));
	}

	@isTest
	static void processText_Success_Test() {
		ID_Card_Application__c app = [SELECT Id, First_Name__c, Last_Name__c, Displayed_Name__c FROM ID_Card_Application__c WHERE IATA_Code__c = '5553567' LIMIT 1];
		Contact con = [SELECT ID, FirstName, LastName FROM Contact WHERE Email = 'idcardcontact@test.idcard'];
		IDCARD_VFEmailTemplateKeyAccController ctrl = new IDCARD_VFEmailTemplateKeyAccController();
		ctrl.myID = app.Id;
		ctrl.recipientId = con.Id;
		ctrl.language = 'English';
		ctrl = new IDCARD_VFEmailTemplateKeyAccController();
		String result = '';
		String text = 'Test for the Id Card with the First Name {!Account.KeyCountact.First_Name__c}, the Last Name {!Account.KeyCountact.Last_Name__c} and the Display Name {!ID_Card_Application__c.Displayed_Name__c}';

		Test.startTest();
			result = ctrl.processText(text, app, con);
		Test.stopTest();

		System.assert(!result.contains('{!Account.KeyCountact.First_Name__c}'));
		System.assert(!result.contains('{!Account.KeyCountact.Last_Name__c}'));
		System.assert(!result.contains('{!ID_Card_Application__c.Displayed_Name__c}'));
		System.assert(result.equals('Test for the Id Card with the First Name Contact, the Last Name IDCard and the Display Name UTest Unit'));
	}

	@isTest
	static void replaceField_Test() {
		ID_Card_Application__c app = [SELECT Id, First_Name__c, Last_Name__c, Displayed_Name__c FROM ID_Card_Application__c WHERE IATA_Code__c = '5553567' LIMIT 1];
		Contact con = [SELECT ID, FirstName, LastName FROM Contact WHERE Email = 'idcardcontact@test.idcard'];
		IDCARD_VFEmailTemplateKeyAccController ctrl = new IDCARD_VFEmailTemplateKeyAccController();
		ctrl.myID = app.Id;
		ctrl.recipientId = con.Id;
		ctrl.language = 'French';
		ctrl.text1 = '';
		ctrl.text2 = '';
		ctrl.text3 = '';
		ctrl.text4 = '';
		ctrl.text5 = '';
		ctrl.text6 = '';
		ctrl.greeting = '';
		ctrl.emailBody1 = '';
		ctrl.emailBody2 = '';
		ctrl.emailBody3 = '';
		ctrl = new IDCARD_VFEmailTemplateKeyAccController();
		String result1 = '';
		String result2 = '';
		String result3 = '';
		String text = 'Test for the Id Card with the First Name {!Account.KeyCountact.First_Name__c}, the Last Name {!Account.KeyCountact.Last_Name__c} and the Display Name {!ID_Card_Application__c.Displayed_Name__c}';

		Test.startTest();
			result1 = ctrl.replaceField(text, '{!Account.KeyCountact.First_Name__c}', app, con);
			result2 = ctrl.replaceField(text, '{!Account.KeyCountact.Last_Name__c}', app, con);
			result3 = ctrl.replaceField(text, '{!ID_Card_Application__c.Displayed_Name__c}', app, con);
		Test.stopTest();

		System.assert(!result1.contains('{!Account.KeyCountact.First_Name__c}'));
		System.assert(result1.contains('{!Account.KeyCountact.Last_Name__c}'));
		System.assert(result1.contains('{!ID_Card_Application__c.Displayed_Name__c}'));
		System.assert(result1.equals('Test for the Id Card with the First Name Contact, the Last Name {!Account.KeyCountact.Last_Name__c} and the Display Name {!ID_Card_Application__c.Displayed_Name__c}'));

		System.assert(result2.contains('{!Account.KeyCountact.First_Name__c}'));
		System.assert(!result2.contains('{!Account.KeyCountact.Last_Name__c}'));
		System.assert(result2.contains('{!ID_Card_Application__c.Displayed_Name__c}'));
		System.assert(result2.equals('Test for the Id Card with the First Name {!Account.KeyCountact.First_Name__c}, the Last Name IDCard and the Display Name {!ID_Card_Application__c.Displayed_Name__c}'));

		System.assert(result3.contains('{!Account.KeyCountact.First_Name__c}'));
		System.assert(result3.contains('{!Account.KeyCountact.Last_Name__c}'));
		System.assert(!result3.contains('{!ID_Card_Application__c.Displayed_Name__c}'));
		System.assert(result3.equals('Test for the Id Card with the First Name {!Account.KeyCountact.First_Name__c}, the Last Name {!Account.KeyCountact.Last_Name__c} and the Display Name UTest Unit'));
	}
}