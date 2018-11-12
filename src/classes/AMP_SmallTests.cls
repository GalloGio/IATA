@isTest
private class AMP_SmallTests {

	@isTest
	static void testAMP() {

		Id accountRecordTypeId = [SELECT Id FROM RecordType WHERE Name ='Airline Headquarters'].Id;
		Account a = new Account(name='testAccount', RecordTypeId=accountRecordTypeId, Sector__c='Airline', Category__c='Passenger and Cargo');
		insert a;

		ApexPages.currentPage().getParameters().put('id',a.id);
		ApexPages.StandardController stdController = new ApexPages.StandardController(a);

		AMP_AccountNewsFeedExtension controller = new AMP_AccountNewsFeedExtension(stdController);

		Service__c testService = new Service__c();
		testService.name = 'test';
		testService.Service_Publication__c = 'Services';
		insert testService;

		Account_Service__c ac = new Account_Service__c();
		ac.Account__c = a.Id;
		ac.Service__c = testService.Id;
		ac.Active__c = true;
		insert ac;

		AMP_ProductsController pcontroller = new AMP_ProductsController(stdController);
		Boolean canView = AMP_ProductsController.canViewSalesfigures();

		Account b = AMP_AccountManagementController.getAccount(a.Id);
		System.assertEquals(a.Name, b.Name, 'Accounts should be the same');

		Contact testContact = new Contact();
		testContact.FirstName = 'testFirstname';
		testContact.LastName = 'testLastname';
		testContact.Email = 'testLastname@test.ts';
		testContact.Title = 'test Title';
		testContact.AccountId = a.Id;
		testContact.Function__c = 'testFunction';
		testContact.Membership_Function__c = 'testFunction';
		insert testContact;

		testContact.Membership_Function__c = '';
		try {
			update testContact;

		} catch(Exception e) {
			Boolean expectedExceptionThrown =  e.getMessage().contains('Contact can only be Primary for values included in Job Functions') ? true : false;
			System.AssertEquals(expectedExceptionThrown, true);
		}
		testContact.Membership_Function__c = 'testFunction2';
		try {
			update testContact;
		} catch(Exception e) {
			Boolean expectedExceptionThrown =  e.getMessage().contains('Contact can only be Primary for values included in Job Functions') ? true : false;
			System.AssertEquals(expectedExceptionThrown, true);

		}

	}

	@isTest
	static void testChatterDigest() {
		Account a = new Account();
		a.name = 'testAccount';
		a.recordtypeId = [SELECT Id FROM Recordtype WHERE DeveloperName='IATA_Airline' LIMIT 1].Id;
		insert a;

		AMP_Account_Topics__c at = new AMP_Account_Topics__c();
		at.Name = 'test';
		insert at;

		FeedItem f = new FeedItem();
		f.ParentId = a.Id;
		f.Body = 'testBody #test';
		insert f;
		// another feeditem for the same topic to get the separator
		FeedItem f2 = new FeedItem();
		f2.ParentId = a.Id;
		f2.Body = 'testBody2 #test';
		insert f2;

		Account_Management_Settings__c ams = new Account_Management_Settings__c();
		ams.Topic_Digest_Time_Range_Aggregator__c = 5;
		insert ams;
		
		Profile p = [SELECT Id FROM Profile WHERE Name='Standard User'];
		User u = new User(Alias = 'standt', Email='testusertempname@foo.bar',
	               EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
	               LocaleSidKey='en_US', ProfileId = p.Id,
	               TimeZoneSidKey='America/Los_Angeles', UserName='testusertempname@foo.bar',
				   License_Cost_Center__c='ISF005CH01',
				   AMP_Digest_Topics__c = 'test', AMP_Digest_Daily_or_Weekly__c = 'daily');

	   	//-- SChedule next job execution
   		Datetime nextScheduleTime = system.now().addHours(0);
   		string month = string.valueof(nextScheduleTime.month());
   		string day = string.valueof(nextScheduleTime.day());
   		string hour = string.valueof(nextScheduleTime.hour());
   		string minute = string.valueof(nextScheduleTime.minute());
   		string second = string.valueof(nextScheduleTime.second ());
   		string cronvalue = second + ' ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?';
   		string jobName = 'AMP Chatter Email Digest ' + nextScheduleTime.format('yyyy-MM-dd HH:mm:ss');

   		System.debug(jobName);
   		System.schedule(jobName, cronvalue , new AMP_ChatterDigestScheduler());
		System.runAs(u) {
Test.startTest();
			Id batchId = Database.executeBatch(new AMP_Batch_EmailChatterDigest('daily'));
Test.stopTest();
			AMP_ChatterTopicSubscribeController con = new AMP_ChatterTopicSubscribeController();
			PageReference pr = con.savePreferences();
			pr = con.unsubscribe();
			// pr = con.filterTopicFeedItems();

			List<SelectOption> so = con.getDailyOrWeeklyOptions();

		}
	}


}