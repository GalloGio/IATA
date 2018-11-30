@isTest
private class MITA_TxtCtrlTest {

	@isTest static void testControllerOK() {

		Test.startTest();
		MITA_TxtCtrl controller = new MITA_TxtCtrl();
		controller.getTitle();
		controller.getContent();
		Test.stopTest();
	}

	@testSetup static void initData() {
		Id rtHQ =  RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
		//ge
		List<Account> accounts = new List<Account>();
		for (Integer i = 0; i < 4; i++ ) {
			accounts.add(new Account(
			                 Name = 'test account ' + i ,
			                 BillingStreet = '123 Test',
			                 ACLI_Status__c = 'Active Company',
			                 IATACode__c = '123' + i,
			                 Name_on_AOC__c = 'AOC',
			                 MITA_IATA_Interline_Passenger__c = Date.today(),
			                 MITA_IATA_Interline_Cargo__c = Date.today(),
			                 MITA_One_way_Pass_Participating__c = Date.today(),
			                 MITA_Member__c = true,
			                 BIETA_Member__c = true,
			                 RecordTypeId = rtHQ,
			                 Airline_designator__c = 'AA',
			                 MITA_One_way_Pass_Issuing_Airline__c = Date.today(),
			                 MITA_IATA_Interline_Art3_Excepted_Status__c = true,
			                 MITA_IATA_Interline_Pass_Art3_Joined__c = Date.newInstance(2016 , 11 ,1),
			                 MITA_IATA_Interline_Cargo_Claims__c = Date.today(),
			                 MITA_IATA_Interline_Passenger_Charges__c = Date.today(),
			                 MITA_IATA_Interline_Cargo_Charges__c = Date.today(),
			                 ICH_Member__c = true,
			                 ACH_Member__c = true
			             ));
		}

		accounts[0].Membership_status__c = 'IATA Member';
		accounts[0].MITA_Currency__c = 'Euro';		
		accounts[1].Membership_status__c = 'Associate';
		accounts[1].MITA_Currency__c = 'US Dollar';	
		accounts[1].Top_Parent__c = accounts[0].id;	
		accounts[2].Membership_status__c = 'Non-IATA member';
		accounts[2].MITA_Currency__c = 'Pound Sterling';			
		accounts[2].Top_Parent__c = accounts[0].id;	
		accounts[3].Membership_status__c = 'XXX';
		accounts[3].MITA_Currency__c = '';	
		accounts[3].Top_Parent__c = accounts[0].id;	
		//accounts[3].id = '001w0000015LHUsAAO';	
		insert accounts;

		MITA_Agreement__c agr = new MITA_Agreement__c(
			Airline_1__c = accounts[0].Id,
			Airline_2__c = accounts[3].Id,
			MITAorBIETA__c = 'MITA'
		);
		insert agr;
		
		List<Contact> contacts = new List<Contact>();
		for(Account a : accounts)
			contacts.add(new Contact(FirstName = 'Name', LastName='Contact '+a.Name, AccountId=a.Id, Email='contact@'+a.Name.replace(' ','')+'.com', MITA_Contact_Type__c='CGO Billing'));
		insert contacts;

	}

	@isTest static void testControllerIAB2D1() {
		PageReference pageRef = Page.MITA_Txt;
		pageRef.getParameters().put('type', MITA_TxtCtrl.IAB2D1);
		Test.setCurrentPage(pageRef);

		Test.startTest();
		MITA_TxtCtrl controller = new MITA_TxtCtrl();
		controller.getContent();
		Test.stopTest();
	}
	@isTest static void testControllerIAB2D2() {

		PageReference pageRef = Page.MITA_Txt;
		pageRef.getParameters().put('type', MITA_TxtCtrl.IAB2D2);
		Test.setCurrentPage(pageRef);

		Test.startTest();
		MITA_TxtCtrl controller = new MITA_TxtCtrl();
		controller.getContent();
		Test.stopTest();
	}
	@isTest static void testControllerIAB2D3() {

		PageReference pageRef = Page.MITA_Txt;
		pageRef.getParameters().put('type', MITA_TxtCtrl.IAB2D3);
		Test.setCurrentPage(pageRef);

		Test.startTest();
		MITA_TxtCtrl controller = new MITA_TxtCtrl();
		controller.getContent();
		Test.stopTest();
	}
	@isTest static void testControllerIAB2D4() {

		PageReference pageRef = Page.MITA_Txt;
		pageRef.getParameters().put('type', MITA_TxtCtrl.IAB2D4);
		Test.setCurrentPage(pageRef);

		Test.startTest();
		MITA_TxtCtrl controller = new MITA_TxtCtrl();
		controller.getContent();
		Test.stopTest();
	}
	@isTest static void testControllerIAB2D5() {

		PageReference pageRef = Page.MITA_Txt;
		pageRef.getParameters().put('type', MITA_TxtCtrl.IAB2D5);
		Test.setCurrentPage(pageRef);

		Test.startTest();
		MITA_TxtCtrl controller = new MITA_TxtCtrl();
		controller.getContent();
		Test.stopTest();
	}
	@isTest static void testControllerIAB2D6() {

		PageReference pageRef = Page.MITA_Txt;
		pageRef.getParameters().put('type', MITA_TxtCtrl.IAB2D6);
		Test.setCurrentPage(pageRef);

		Test.startTest();
		MITA_TxtCtrl controller = new MITA_TxtCtrl();
		controller.getContent();
		Test.stopTest();
	}

	@isTest static void testControllerIAB2P2() {

		PageReference pageRef = Page.MITA_Txt;
		pageRef.getParameters().put('type', MITA_TxtCtrl.IAB2P2);
		Test.setCurrentPage(pageRef);

		Test.startTest();
		MITA_TxtCtrl controller = new MITA_TxtCtrl();
		controller.getContent();
		Test.stopTest();
	}
	@isTest static void testControllerIAB3D1() {

		PageReference pageRef = Page.MITA_Txt;
		pageRef.getParameters().put('type', MITA_TxtCtrl.IAB3D1);
		Test.setCurrentPage(pageRef);

		Test.startTest();
		MITA_TxtCtrl controller = new MITA_TxtCtrl();
		controller.getContent();
		Test.stopTest();
	}
	@isTest static void testControllerIAB3D2() {

		PageReference pageRef = Page.MITA_Txt;
		pageRef.getParameters().put('type', MITA_TxtCtrl.IAB3D2);
		Test.setCurrentPage(pageRef);

		Test.startTest();
		MITA_TxtCtrl controller = new MITA_TxtCtrl();
		controller.getContent();
		Test.stopTest();
	}

	@isTest static void testControllerIAB4D2() {

		PageReference pageRef = Page.MITA_Txt;
		pageRef.getParameters().put('type', MITA_TxtCtrl.IAB4D2);
		Test.setCurrentPage(pageRef);

		Test.startTest();
		MITA_TxtCtrl controller = new MITA_TxtCtrl();
		controller.getContent();
		Test.stopTest();
	}
	@isTest static void testControllerIAB5D3() {

		PageReference pageRef = Page.MITA_Txt;
		pageRef.getParameters().put('type', MITA_TxtCtrl.IAB5D3);
		Test.setCurrentPage(pageRef);

		Test.startTest();
		MITA_TxtCtrl controller = new MITA_TxtCtrl();
		controller.getContent();
		Test.stopTest();
	}
	@isTest static void testControllerIAB7D1() {

		PageReference pageRef = Page.MITA_Txt;
		pageRef.getParameters().put('type', MITA_TxtCtrl.IAB7D1);
		Test.setCurrentPage(pageRef);

		Test.startTest();
		MITA_TxtCtrl controller = new MITA_TxtCtrl();
		controller.getContent();
		Test.stopTest();
	}
	@isTest static void testControllerIAB7D2() {

		PageReference pageRef = Page.MITA_Txt;
		pageRef.getParameters().put('type', MITA_TxtCtrl.IAB7D2);
		Test.setCurrentPage(pageRef);

		Test.startTest();
		MITA_TxtCtrl controller = new MITA_TxtCtrl();
		controller.getContent();
		Test.stopTest();
	}
	@isTest static void testControllerMITA27() {

		PageReference pageRef = Page.MITA_Txt;
		pageRef.getParameters().put('type', MITA_TxtCtrl.MITA27);
		Test.setCurrentPage(pageRef);

		Test.startTest();
		MITA_TxtCtrl controller = new MITA_TxtCtrl();
		controller.getContent();
		Test.stopTest();
	}
}