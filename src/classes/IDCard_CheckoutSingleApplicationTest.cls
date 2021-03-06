@isTest
public class IDCard_CheckoutSingleApplicationTest {

		public static ID_Card_Application__c app;

		public static void initData() {

				IATA_ISO_Country__c isoc = new IATA_ISO_Country__c( Name = 'Australia',
								ISO_Code__c = '12',
								AIMS_Area_Name__c = 'Australia'
																													);
				insert isoc;
				Price_Table__c  p1 = new Price_Table__c(CurrencyIsoCode = 'CAD', ISO_Country__c = isoc.Id, Type_Class_of_Agent__c  = 'Domestic', IATA_Package__c = 10, ID_Card_Fee__c = 8);
				Price_Table__c  p2 = new Price_Table__c(CurrencyIsoCode = 'CAD', ISO_Country__c = isoc.Id , Type_Class_of_Agent__c  = 'TIDS', IATA_Package__c = 14, ID_Card_Fee__c = 9);

				Insert p1;
				Insert p2;

				Id rtacc = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
				Id rtcon = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');

				Account a = new Account(Name = 'Test Account',
																IATACode__c = '12312312',
																Type = 'Domestic Agent',
																Industry = 'Cargo Agent',
																IDCard_Key_Account__c = true,
																RecordTypeId = rtacc,
																BillingCountry = 'Australia',
																Status__c = 'Approved'
															 );
				insert a;
				Account a2 = new Account(Name = 'Test Account',
																 IATACode__c = '87654321',
																 Type = 'Domestic Agent',
																 Industry = 'Cargo Agent',
																 IDCard_Key_Account__c = true,
																 RecordTypeId = rtacc,
																 BillingCountry = 'Australia',
																 Status__c = 'Approved'
																);
				insert a2;


				List<Contact> cs = new List<Contact>();
				for (integer i = 1; i <= 10; i++) {
						string si = (i < 10 ? '0' : '') + i;
						cs.add(new Contact(FirstName = 'Test ' + si,
															 LastName = 'Contact ' + si,
															 BirthDate = date.today().addYears(-30),
															 AccountId = a.id,
															 Phone = '+41 7777777777',
															 Email = 'test' + i + '@contact.com',
															 Date_of_birth__c = date.today().addYears(-30),
															 ID_Card_Holder__c = true,

															 VER_number_2__c = (i <= 100 ? '' + i : null),
															 UIR__c = (i <= 100 ? 'UIR' + i : null),
															 RecordTypeId = rtcon
															));
				}
				insert cs;


				list<Managed_agency__c> mas = new list<Managed_Agency__c>();
				mas.add(new Managed_agency__c(Contact__c = cs[0].id, Account__c = a.id));
				mas.add(new Managed_agency__c(Contact__c = cs[0].id, Account__c = a2.id));
				insert mas;

				Id rt =  RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c', 'Single_ID_Card_Operation');
				app = new ID_Card_Application__c(VER_Number__c = cs[0].VER_Number_2__c,
																				 Displayed_Name__c = cs[0].Name,
																				 First_Name__c = cs[0].FirstName,
																				 Last_Name__c = cs[0].LastName,
																				 Application_Status__c = 'Pending',
																				 Type_Of_Application__c = 'New',
																				 IATA_Code__c = a.IATAcode__c,
																				 RecordTypeId = rt );
				insert app;
		}

		@isTest
	static void testCheckoutSingleApplication() {
				initData();



				test.startTest();

				Test.setCurrentPage(Page.IDCard_CheckoutSingleApplication);
				List<Cookie> cookies = new List<Cookie>();
				cookies.add(new Cookie(IDCardUtil.PARAM_IATACODE, '12312312', null, -1, false));
				cookies.add(new Cookie(IDCardUtil.PARAM_VER, '1', null, -1, false));
				ApexPages.currentPage().setCookies(cookies);

				System.currentPageReference().getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter(app.Id));


				IDCard_CheckoutSingleApplication ctrl = new IDCard_CheckoutSingleApplication();

				system.assertEquals(null, ctrl.updateRecord());

				system.assertNotEquals(null, ctrl.terminate());

		}


		@isTest
	static void testRaiseExceptions() {

				test.startTest();
				IDCard_CheckoutSingleApplication ctrl;
				boolean getException = false;
				try {
						ctrl = new IDCard_CheckoutSingleApplication();
				} catch (Exception e) {
						getException = true;
				}
				system.assert(getException);
				Test.setCurrentPage(Page.IDCard_CheckoutSingleApplication);
				List<Cookie> cookies = new List<Cookie>();
				cookies.add(new Cookie(IDCardUtil.PARAM_IATACODE, '12312312', null, -1, false));
				cookies.add(new Cookie(IDCardUtil.PARAM_VER, '1', null, -1, false));
				ApexPages.currentPage().setCookies(cookies);

				getException = false;
				try {
						System.currentPageReference().getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter('APPIDFAKE'));
						ctrl = new IDCard_CheckoutSingleApplication();
				} catch (Exception e) {
						getException = true;
				}

				Id rt =  RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c', 'Single_ID_Card_Operation');
				app = new ID_Card_Application__c(VER_Number__c = '123',
																				 Displayed_Name__c = 'Nome Cognome',
																				 First_Name__c = 'FirstName',
																				 Last_Name__c = 'LastName',
																				 Application_Status__c = 'Pending',
																				 Type_Of_Application__c = 'New',
																				 IATA_Code__c = '12312312',
																				 RecordTypeId = rt );
				insert app;
				Id rtacc = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

				Account a = new Account(Name = 'Test Account',
																IATACode__c = '12312312',
																Type = 'Domestic Agent',
																Industry = 'Cargo Agent',
																IDCard_Key_Account__c = true,
																RecordTypeId = rtacc,
																BillingCountry = 'Australia',
																Status__c = 'Approved'
															 );
				insert a;

				getException = false;
				try {
						System.currentPageReference().getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter(app.Id));
						ctrl = new IDCard_CheckoutSingleApplication();
				} catch (Exception e) {
						getException = true;
				}
				system.assert(!getException);


				getException = false;
				try {
						System.currentPageReference().getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter(app.Id));
						System.currentPageReference().getParameters().put(IDCardUtil.PARAM_ERRMSG, 'ERROR') ;
						ctrl = new IDCard_CheckoutSingleApplication();
				} catch (Exception e) {
						getException = true;
				}
				system.assert(getException);

				system.assertEquals(null, ctrl.updateRecord());

		}

	@isTest
	static void alertKeyContactForNewApplicationTest() {

		IATA_ISO_Country__c ct1 = new IATA_ISO_Country__c (
			Name = 'Portugal', 
			ISO_Code__c = 'PT', 
			AIMS_Area_ID__c = '2'
		);
		insert ct1;

		Account acc = new Account(
			Name = 'Test Agency',
			IATA_ISO_Country__c = ct1.Id,
			IATACode__c = '1234567'
		);
		insert acc;

		Contact con = new Contact(
			AccountId = acc.Id,
			LastName = 'test',
			Email = 'testContact@test.com',
			IDcard_Email__c = 'test@test.com'
		);
		insert con;

		User usr = [Select id from User where Id = :UserInfo.getUserId()];
		EmailTemplate template = new EmailTemplate(
			Name = 'Test_Template',
			DeveloperName = 'KeyAccount_New_Application',
			Subject = 'test template',
			HtmlValue = '<html></html>',
			TemplateType = 'text',
			isActive = true,
			FolderId = USerInfo.getUSerId()
		);
		System.RunAs(usr) {
			insert template; 
		}

		Managed_agency__c agency = new Managed_agency__c(
			Delegate__c = false,
			Account__c = acc.Id,
			Contact__c = con.Id
		);
		insert agency;

		ID_Card_Application__c idCardApp = new ID_Card_Application__c();
		idCardApp.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c', 'Single_ID_Card_Operation');
		idCardApp.Title__c = 'Mr';
		idCardApp.First_Name__c = 'FIRSTNAME1';
		idCardApp.Last_Name__c = 'LASTNAME1';
		idCardApp.Date_of_Birth__c = Date.newInstance(1980,12,12);
		idCardApp.Displayed_Name__c = 'FIRSTNAME LASTNAME 1';
		idCardApp.Type_of_application__c = 'New';
		idCardApp.IATA_Code__c = '1234567';
		idCardApp.Email_admin__c = 'testidcard1@testmassapp.test';
		idCardApp.UIR__c = 'PT000001';
		insert idCardApp;

		List<Case> caseList = new List<Case>();
		Case cs = new Case();
		cs.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ID_Card_Application');
		cs.Related_ID_Card_Application__c = idCardApp.Id;
		cs.Subject = 'Case ID Card Test';
		cs.AccountId = acc.Id;
		caseList.add(cs);
		insert cs;

		ID_Card__c idCard = new ID_Card__c();
		idCard.Related_Contact__c = con.Id;
		idCard.Name_on_ID_Card__c = 'test2';
		idCard.ID_Card_Application__c = idCardApp.Id;
		idCard.LastName__c = 'LASTNAME2';
		idCard.FirstName__c = 'FIRSTNAME2';
		idCard.Date_of_Birth__c = Date.newInstance(1989,11,25);
		idCard.Gender__c = 'FEMALE';
		idCard.Position__c = 'Employee';
		idCard.Duties__c = 'Sales';
		idCard.Hours_per_week__c  = '35 h or more';
		idCard.Start_Date_Agency_Month__c = 'July';
		idCard.Start_Date_Agency_Year__c = '2020';
		idCard.Start_Date_Industry__c = '12';
		idCard.Nature_of_ID_Card__c = 'Reissue';		
		insert idCard;		

		PageReference pageRef = Page.IDCard_CheckoutSingleApplication;
		Test.setCurrentPageReference(pageRef);
		pageRef.getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter(idCardApp.Id));		

		IDCard_CheckoutSingleApplication controller = new IDCard_CheckoutSingleApplication();

		Test.startTest();
			controller.updateRecord();
		Test.stopTest();

	}

	@isTest
	static void alertKeyContactForNewApplicationWithoutTemplateTest() {

		IATA_ISO_Country__c ct1 = new IATA_ISO_Country__c (
			Name = 'Portugal', 
			ISO_Code__c = 'PT', 
			AIMS_Area_ID__c = '2'
		);
		insert ct1;

		Account acc = new Account(
			Name = 'Test Agency',
			IATA_ISO_Country__c = ct1.Id,
			IATACode__c = '1234567'
		);
		insert acc;

		Contact con = new Contact(
			AccountId = acc.Id,
			LastName = 'test',
			Email = 'testContact@test.com'
		);
		insert con;

		User usr = [Select id from User where Id = :UserInfo.getUserId()];
		EmailTemplate template = new EmailTemplate(
			Name = 'Test_Template',
			DeveloperName = 'test',
			Subject = 'test template',
			HtmlValue = '<html></html>',
			TemplateType = 'text',
			isActive = true,
			FolderId = USerInfo.getUSerId()
		);
		System.RunAs(usr) {
			insert template; 
		}

		Managed_agency__c agency = new Managed_agency__c(
			Delegate__c = false,
			Account__c = acc.Id,
			Contact__c = con.Id
		);
		insert agency;

		ID_Card_Application__c idCardApp = new ID_Card_Application__c();
		idCardApp.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c', 'Single_ID_Card_Operation');
		idCardApp.Title__c = 'Mr';
		idCardApp.First_Name__c = 'FIRSTNAME1';
		idCardApp.Last_Name__c = 'LASTNAME1';
		idCardApp.Date_of_Birth__c = Date.newInstance(1980,12,12);
		idCardApp.Displayed_Name__c = 'FIRSTNAME LASTNAME 1';
		idCardApp.Type_of_application__c = 'New';
		idCardApp.IATA_Code__c = '1234567';
		idCardApp.Email_admin__c = 'testidcard1@testmassapp.test';
		idCardApp.UIR__c = 'PT000001';
		insert idCardApp;

		List<Case> caseList = new List<Case>();
		Case cs = new Case();
		cs.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ID_Card_Application');
		cs.Related_ID_Card_Application__c = idCardApp.Id;
		cs.Subject = 'Case ID Card Test';
		cs.AccountId = acc.Id;
		caseList.add(cs);
		insert cs;

		ID_Card__c idCard = new ID_Card__c();
		idCard.Related_Contact__c = con.Id;
		idCard.Name_on_ID_Card__c = 'test2';
		idCard.ID_Card_Application__c = idCardApp.Id;
		idCard.LastName__c = 'LASTNAME2';
		idCard.FirstName__c = 'FIRSTNAME2';
		idCard.Date_of_Birth__c = Date.newInstance(1989,11,25);
		idCard.Gender__c = 'FEMALE';
		idCard.Position__c = 'Employee';
		idCard.Duties__c = 'Sales';
		idCard.Hours_per_week__c  = '35 h or more';
		idCard.Start_Date_Agency_Month__c = 'July';
		idCard.Start_Date_Agency_Year__c = '2020';
		idCard.Start_Date_Industry__c = '12';
		idCard.Nature_of_ID_Card__c = 'Reissue';		
		insert idCard;		

		PageReference pageRef = Page.IDCard_CheckoutSingleApplication;
		Test.setCurrentPageReference(pageRef);
		pageRef.getParameters().put(IDCardUtil.PARAM_APPID, IDCardUtil.EncryptEncodeParameter(idCardApp.Id));		

		IDCard_CheckoutSingleApplication controller = new IDCard_CheckoutSingleApplication();
		controller.setSelectedLanguage('test');

		Test.startTest();
			controller.updateRecord();
		Test.stopTest();

		List<Apexpages.Message> msgs = ApexPages.getMessages();
		boolean b = false;

			for(Apexpages.Message msg:msgs){
				if (msg.getDetail().contains('We failed to contact your manager. Please contact IATA or your manager to validate your application3')) b = true;
			}

		System.assert(b);
	}

}
