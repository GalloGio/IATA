@isTest
private class ANG_SAP_PPA_Test {

	@testSetup static void createData() {
		WrapperAttachTest.loadTestCredentials();	

		IATA_ISO_Country__c country = new IATA_ISO_Country__c(Name = 'Country',
															  ANG_Enable_NewGen__c = true,
															  ISO_Code__c = 'HY');
		insert country;
		
		Account a = new Account(Name = 'Account', 
								Sector__c = 'Travel Agent', 
								Location_Type__c = 'HE', 
								Location_Class__c = 'P',
								RecordTypeId = AMS_Utils.RECTYPE_IATAAGENCY,
								IATACode__c = '12345678',
								IATA_ISO_Country__c = country.Id);
		insert a;

		List<AMS_Oscar__c> oscars = new List<AMS_Oscar__c>();

		AMS_Oscar__c oscar1 = new AMS_Oscar__c(Name = 'Oscar', Account__c = a.Id);
		AMS_Oscar__c oscar2 = new AMS_Oscar__c(Name = 'Oscar', Account__c = a.Id, Billing_Document_Number__c = '132');
		
		oscars.add(oscar1);
		oscars.add(oscar2);
		insert oscars;

		List<Case> cases = new List<Case>();

		Case c1 = new Case(OSCAR__c = oscar1.Id, Subject = 'Base');
		Case c2 = new Case(Subject = 'No');
		Case c3 = new Case(OSCAR__c = oscar2.Id, Subject = 'WithBill');

		cases.add(c1);
		cases.add(c2);
		cases.add(c3);
		insert cases;
	}
	
	@isTest static void emptyPPANumberTest() {
		Case fetchedCase = [SELECT Id, OSCAR__c FROM Case WHERE Subject = 'Base' LIMIT 1];

		Test.startTest();

		ANG_SAP_PPA.WSResponse resp = ANG_SAP_PPA.putPPAToSFDC(fetchedCase.Id, '', 'test', 'test');
		System.assertEquals('Empty PPANumber element', resp.statusDescription);
		System.assertEquals('400', resp.statusCode);

		Test.stopTest();
	}
	
	@isTest static void emptyCaseIdTest() {
		Test.startTest();

		ANG_SAP_PPA.WSResponse resp = ANG_SAP_PPA.putPPAToSFDC(null, '123', 'test', 'test');
		System.assertEquals('Empty CaseId element', resp.statusDescription);
		System.assertEquals('400', resp.statusCode);

		Test.stopTest();
	}

	@isTest static void emptyFileTypeTest() {
		Case fetchedCase = [SELECT Id, OSCAR__c FROM Case WHERE Subject = 'Base' LIMIT 1];

		Test.startTest();

		ANG_SAP_PPA.WSResponse resp = ANG_SAP_PPA.putPPAToSFDC(fetchedCase.Id, '123', 'test', '');
		System.assertEquals('Empty FileType element', resp.statusDescription);
		System.assertEquals('400', resp.statusCode);

		Test.stopTest();
	}

	@isTest static void invalidFileTypeTest() {
		Case fetchedCase = [SELECT Id, OSCAR__c FROM Case WHERE Subject = 'Base' LIMIT 1];

		Test.startTest();

		ANG_SAP_PPA.WSResponse resp = ANG_SAP_PPA.putPPAToSFDC(fetchedCase.Id, '123', 'test', 'test');
		System.assertEquals('Invalid FileType', resp.statusDescription);
		System.assertEquals('406', resp.statusCode);

		Test.stopTest();
	}

	@isTest static void noCasesTest() {
		Test.startTest();

		ANG_SAP_PPA.WSResponse resp = ANG_SAP_PPA.putPPAToSFDC('0987564', '123', 'test', 'PPA');
		System.assertEquals('Case not found', resp.statusDescription);
		System.assertEquals('404', resp.statusCode);

		Test.stopTest();
	}

	/*@isTest static void noOscarTest() {
		Case fetchedCase = [SELECT Id, OSCAR__c FROM Case WHERE Subject = 'No' LIMIT 1];

		Test.startTest();

		ANG_SAP_PPA.WSResponse resp = ANG_SAP_PPA.putPPAToSFDC(fetchedCase.Id, '123', 'test', 'PPA');
		System.assertEquals('Case has no associated OSCAR', resp.statusDescription);
		System.assertEquals('409', resp.statusCode);

		Test.stopTest();
	}*/

	@isTest static void oscarWithBillingTest() {
		Case fetchedCase = [SELECT Id, OSCAR__c FROM Case WHERE Subject = 'WithBill' LIMIT 1];

		Test.startTest();

		ANG_SAP_PPA.WSResponse resp = ANG_SAP_PPA.putPPAToSFDC(fetchedCase.Id, '123', 'test', 'PPA');
		System.assertEquals('Case has already a PPA Number', resp.statusDescription);
		System.assertEquals('409', resp.statusCode);

		Test.stopTest();
	}

	@isTest static void oscarWithFileBodyTest() {
		Case fetchedCase = [SELECT Id, OSCAR__c FROM Case WHERE Subject = 'Base' LIMIT 1];

		Test.startTest();

		ANG_SAP_PPA.WSResponse resp = ANG_SAP_PPA.putPPAToSFDC(fetchedCase.Id, '123', 'test', 'PPA');
		System.assertEquals('OK', resp.statusDescription);
		System.assertEquals('200', resp.statusCode);

		Test.stopTest();
	}

	@isTest static void oscarWithoutFileBodyTest() {
		Case fetchedCase = [SELECT Id, OSCAR__c FROM Case WHERE Subject = 'Base' LIMIT 1];

		TestDataGenerator.generateApexSetting();

		//Create Orders 
		List<Account> accounts = TestDataGenerator.generateAccounts(1,true); // 1 Account
		List<Contact> contacts = TestDataGenerator.generateContacts(accounts[0].Id,2,true); // 2 Contacts
		List<Order> orders = TestDataGenerator.generateOrder(1, accounts[0].Id, contacts[0].Id, contacts[1].Id,true); // 1 Order
		List<OrderItem> orderItems = TestDataGenerator.generateOrderItem(orders[0].Id, 3,true);// 3 lineItems for Order1
     	orderItems[0].Invoice_Number__c = '123456';
		update orderItems;

		PageReference pageRef = Page.IECInvoice;
		Test.setCurrentPage(pageRef);
		ApexPages.CurrentPage().getParameters().put('invoice',orderItems[0].Invoice_Number__c);

		Test.startTest();
		Test.setMock(WebServiceMock.class, new MockSAPDigitalInvoice());

		ANG_SAP_PPA.WSResponse resp = ANG_SAP_PPA.putPPAToSFDC(fetchedCase.Id, orderItems[0].Invoice_Number__c, '', 'PPA');
		System.assertEquals('500', resp.statusCode);

		Test.stopTest();
	}
}