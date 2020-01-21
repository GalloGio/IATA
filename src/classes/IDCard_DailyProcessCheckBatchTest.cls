@isTest
private class IDCard_DailyProcessCheckBatchTest {

	public static Account a;
	public static List<Contact> cs;
	public static List<ID_Card__c> idcs;
	public static String CRON_EXP1 = '0 0 0 15 3 ? 2050';
	public static String CRON_EXP2 = '0 0 0 17 3 ? 2050';

	public static void initData(){
		Id rtacc = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
		Id rtcon = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');

		Id rtidca = RecordTypeSingleton.getInstance().getRecordTypeId('ID_Card_Application__c', 'Single_ID_Card_Operation');

		IATA_ISO_Country__c isoc = new IATA_ISO_Country__c( Name = 'Australia',
										ISO_Code__c = '12',
										AIMS_Area_Name__c = 'Australia'
		);
		insert isoc;


		Price_Table__c  p1 = new Price_Table__c(CurrencyIsoCode='CAD',ISO_Country__c =isoc.Id, Type_Class_of_Agent__c  ='Domestic',ID_Card_Fee__c=100);
		Price_Table__c  p2 = new Price_Table__c(CurrencyIsoCode='CAD',ISO_Country__c =isoc.Id ,Type_Class_of_Agent__c  ='TIDS',ID_Card_Fee__c=100);
		Price_Table__c  p3 = new Price_Table__c(CurrencyIsoCode='CAD',ISO_Country__c =isoc.Id ,Type_Class_of_Agent__c  ='Passenger',ID_Card_Fee__c=100);
		Insert p1;
		Insert p2;
		insert p3;

		a = new Account(Name='Test Account',
						IATACode__c = '76543210',
						Type = 'Domestic Agent',
						Industry = 'Cargo Agent',
						IDCard_Key_Account__c = true,
						RecordTypeId = rtacc,
						BillingCountry = 'Australia',
						Status__c = 'Approved',
						ID_Card_Key_Account_Discount__c = 0
		);
		insert a;

		cs = new List<Contact>();
		cs.add(new Contact(FirstName = 'First',
							LastName = 'Contact',
							BirthDate = date.today(),
							AccountId = a.id,
							Phone = '+41 7777777777',
							Email = 'first@contact.com',
							Date_of_birth__c = date.today().addYears(-30),
							ID_Card_Holder__c = true,
							WebStar_ID__c = '999',
							VER_number_2__c = '111',
							RecordTypeId = rtcon
		));
		cs.add(new Contact(FirstName = 'Second',
							LastName = 'Contact',
							BirthDate = date.today(),
							AccountId = a.id,
							Phone = '+41 232342342342',
							Email = 'second@contact.com',
							Date_of_birth__c = date.today().addYears(-30),
							ID_Card_Holder__c = true,
							WebStar_ID__c = '1010',
							VER_number_2__c = '222',
							RecordTypeId = rtcon
		));
		cs.add(new Contact(FirstName = 'Third',
							LastName = 'Contact',
							BirthDate = date.today(),
							AccountId = a.id,
							Phone = '+41 56767867678',
							Email = 'third@contact.com',
							Date_of_birth__c = date.today().addYears(-30),
							ID_Card_Holder__c = true,
							WebStar_ID__c = '11111',
							VER_number_2__c = '333',
							RecordTypeId = rtcon
		));
		 cs.add(new Contact(WebStar_ID__c = '111', VER_number_2__c = '444',FirstName = 'fourth', LastName = 'Contact', BirthDate = date.today(), AccountId = a.id,     Phone = '+41 56767867678', Email = 'third4@contact.com', Date_of_birth__c = date.today().addYears(-30),ID_Card_Holder__c = true,RecordTypeId = rtcon));
		 cs.add(new Contact(WebStar_ID__c = '222', VER_number_2__c = '555',FirstName = 'fith', LastName = 'Contact',   BirthDate = date.today(), AccountId = a.id,     Phone = '+41 56767867678', Email = 'third5@contact.com', Date_of_birth__c = date.today().addYears(-30),ID_Card_Holder__c = true,RecordTypeId = rtcon));
		 cs.add(new Contact(WebStar_ID__c = '333', VER_number_2__c = '666',FirstName = 'Six', LastName = 'Contact',    BirthDate = date.today(), AccountId = a.id,     Phone = '+41 56767867678', Email = 'third6@contact.com', Date_of_birth__c = date.today().addYears(-30),ID_Card_Holder__c = true,RecordTypeId = rtcon));
		 cs.add(new Contact(WebStar_ID__c = '444', VER_number_2__c = '777',FirstName = 'Seven', LastName = 'Contact',  BirthDate = date.today(), AccountId = a.id,     Phone = '+41 56767867678', Email = 'third7@contact.com', Date_of_birth__c = date.today().addYears(-30),ID_Card_Holder__c = true,RecordTypeId = rtcon));
		 cs.add(new Contact(WebStar_ID__c = '5555', VER_number_2__c = '888',FirstName = 'height', LastName = 'Contact', BirthDate = date.today(), AccountId = a.id,     Phone = '+41 56767867678', Email = 'third8@contact.com', Date_of_birth__c = date.today().addYears(-30),ID_Card_Holder__c = true,RecordTypeId = rtcon));
		 cs.add(new Contact(IDcard_Email__c = 'third1@contact.com', WebStar_ID__c = '6666', VER_number_2__c = '999',FirstName = 'Nine', LastName = 'Contact',   BirthDate = date.today(), AccountId = a.id,     Phone = '+41 56767867678',  Date_of_birth__c = date.today().addYears(-30),ID_Card_Holder__c = true,RecordTypeId = rtcon));
		 cs.add(new Contact(IDcard_Email__c = 'third2@contact.com', WebStar_ID__c = '777', VER_number_2__c = '1000',FirstName = 'Ten', LastName = 'Contact',   BirthDate = date.today(), AccountId = a.id,     Phone = '+41 56767867678',  Date_of_birth__c = date.today().addYears(-30),ID_Card_Holder__c = true,RecordTypeId = rtcon));
		 cs.add(new Contact(IDcard_Email__c = 'third3@contact.com', WebStar_ID__c = '888', VER_number_2__c = '1001',FirstName = 'eleven', LastName = 'Contact',    BirthDate = date.today(), AccountId = a.id,     Phone = '+41 56767867678',  Date_of_birth__c = date.today().addYears(-30),ID_Card_Holder__c = true,RecordTypeId = rtcon));



		insert cs;

		Managed_agency__c ma = new Managed_agency__c(Account__c = a.id, Contact__c  = cs.get(0).Id);
		insert ma;
		Managed_agency__c ma2 = new Managed_agency__c(Account__c = a.id, Contact__c  = cs.get(1).Id);
		try{
			insert ma2;
		}catch(Exception e){
			//ok;
		}
		Managed_agency__c ma3 = new Managed_agency__c(Account__c = a.id, Contact__c  = cs.get(1).Id, Delegate__c = true);
		insert ma3;


		 string query = 'SELECT '+ TransformationHelper.selectAllFields('Contact')+
												   '  FROM Contact ';

		cs = (list<Contact>)(database.query(query));


		idcs = new List<ID_Card__c>();

		idcs.add(new ID_Card__c(WebStar_P00_Key__c = '111',
							Valid_To_Date__c = date.today().addMonths(5),
							Name_on_ID_Card__c = cs[0].FirstName + ' '+cs[0].LastName,
							Card_status__c = 'Sent ID Card',
							VER_Number__c = cs[0].VER_Number_2__c,
							Agency_IATA_Code__c = a.IATAcode__c,
							Photo__c = 'useless string'

		));

	  	// Contact 1 has also an older id card with status canceled
	  	idcs.add(new ID_Card__c(WebStar_P00_Key__c = '222',
								Valid_To_Date__c = date.today().addMonths(-8),
								Name_on_ID_Card__c = cs[1].FirstName + ' '+cs[1].LastName,
								Card_status__c = 'Cancelled ID Card',
								VER_Number__c = cs[1].VER_Number_2__c,
								Agency_IATA_Code__c = a.IATAcode__c,
								Photo__c = 'useless string'
		));

		// Contact 2 has also an older id card with status approved
	  	idcs.add(new ID_Card__c(WebStar_P00_Key__c = '333',
								Valid_To_Date__c = date.today().addMonths(-8),
								Name_on_ID_Card__c = cs[2].FirstName + ' '+cs[2].LastName,
								Card_status__c = 'Cancelled ID Card',
								VER_Number__c = cs[2].VER_Number_2__c,
								Agency_IATA_Code__c = a.IATAcode__c,
								Photo__c = 'useless string'
		));

		insert idcs;

	}


	@isTest static void test_method_one() {
		// Implement test code
		initData();

		Test.startTest();

		// Schedule the test job
		String jobId = System.schedule('IDCard_DailyProcessCheckBatch', CRON_EXP1, new IDCard_DailyProcessCheckBatch());
		String jobId2 = System.schedule('IDCard_DailyProcessCheckBatch2', CRON_EXP1, new IDCard_DailyProcessCheckBatch(200,'test@test.com,test2@test.com'));
		String jobId3 = System.schedule('IDCard_DailyProcessCheckBatch3', CRON_EXP1, new IDCard_DailyProcessCheckBatch(200,'test@test.com,test2@test.com','IDCard_RelatedContact'));

		// Get the information from the CronTrigger API object
		CronTrigger ct = [SELECT Id, CronExpression, TimesTriggered, NextFireTime FROM CronTrigger WHERE id = :jobId3];

		// Verify the expressions are the same
		System.assertEquals(CRON_EXP1, ct.CronExpression);

		// Verify the job has not run
		System.assertEquals(0, ct.TimesTriggered);

		// Verify the next time the job will run
		System.assertEquals('2050-03-15 00:00:00', String.valueOf(ct.NextFireTime));

		Date todayDate = Date.today();
		Date valDate = todayDate.addDays(2);


		Test.stopTest();

	}

	@isTest static void test_method_two() {
		initData();

		Test.startTest();

		IDCard_DailyProcessCheckBatch.start('IDCard_ContactEmail',CRON_EXP2,200,'test@test.com,test2@test.com');
		IDCard_DailyProcessCheckBatch.stop('IDCard_ContactEmail');

		Test.stopTest();
	}

	@isTest static void test_method_four() {
		initData();

		Test.startTest();

		IDCard_DailyProcessCheckBatch.start('IDCard_RelatedContact',CRON_EXP1,200,'test@test.com,test2@test.com');
		IDCard_DailyProcessCheckBatch.stop('IDCard_RelatedContact');

		Test.stopTest();
	}

	@isTest static void test_method_three() {
		initData();

		Test.startTest();

		IDCard_DailyProcessCheckBatch c = new IDCard_DailyProcessCheckBatch(200,'test@test.com,test2@test.com');
		Database.executeBatch(c, 200);

		List<String> exceptionMsg = new List<String>();
		exceptionMsg.add('test');

		c.sendReport(new List<IDCard_DailyProcessCheckBatch.ResultWrapper>(), exceptionMsg, 'operation');

		Test.stopTest();
	}

	@isTest static void test_method_five() {
		initData();

		Test.startTest();

		IDCard_DailyProcessCheckBatch c = new IDCard_DailyProcessCheckBatch(200,'test@test.com,test2@test.com');
		c.operation = 'IDCard_ContactEmail';
		Database.executeBatch(c, 200);

		List<String> exceptionMsg = new List<String>();
		exceptionMsg.add('test');

		c.sendReport(new List<IDCard_DailyProcessCheckBatch.ResultWrapper>(), exceptionMsg, 'operation');

		Test.stopTest();
	}
}
