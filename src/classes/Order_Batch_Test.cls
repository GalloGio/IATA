@isTest
private class Order_Batch_Test
{
	@isTest
	static void test_CleanUpQuotes()
	{
		TestDataGenerator.generateApexSetting();

		// Setup Data
		Account sfAccount = TestDataGenerator.generateAccounts(1, true)[0];
		Contact sfContact = TestDataGenerator.generateContacts(sfAccount.Id, 1, true)[0];

		Date dt = Date.today().addMonths(-4);
		Date today = Date.today();
		//-- Create Quotes older than 3 months : 5 are older than 3 months
		List<Order> quotes = TestDataGenerator.generateOrder(10, sfAccount.Id, sfContact.Id, sfContact.Id, false);
		Integer counter=1;

		// Loop over the renewal notice and update some fields
		for(Order quote : quotes)
		{
			// update half of the orders to use today's date, and the other half to use an old effective date
			quote.EffectiveDate = (Math.mod(counter, 2)==0)? dt : today;
			quote.Status = 'New';
			quote.Type = 'Quote';
			counter++;
		}

		insert quotes;

		//-- Run Batch
		Test.startTest();
			Order_Batch b = new Order_Batch('CleanUpQuotes', quotes);
			Database.ExecuteBatch(b);

			//-- Schedule Batch to run in 1s
			QuoteCleanUp_Scheduler.doSchedule('0 0 20 * * ?');
		Test.stopTest();

		// Confirm all data has been deleted
		Integer i = [SELECT COUNT() FROM Order WHERE EffectiveDate <= :dt];
			 	System.assertEquals(i, 0);
	}

	// Test cleaning up old renewal notifications
	@isTest
	static void test_CleanUpRenewalNotifications()
	{
		TestDataGenerator.generateApexSetting();

		// Setup data
		Account sfAccount = TestDataGenerator.generateAccounts(1, true)[0];
		Contact sfContact = TestDataGenerator.generateContacts(sfAccount.Id, 1, true)[0];

		Date dt = Date.today().addMonths(-7);
		Date today = Date.today();
		//-- Create Notices older than 6 months : 7 are older than 6 months
		List<Order> notices = TestDataGenerator.generateOrder(10, sfAccount.Id, sfContact.Id, sfContact.Id, false);
		Integer counter=1;

		// Loop over the renewal notice and update some fields
		for(Order notice : notices)
		{
			// update half of the orders to use today's date, and the other half to use an old effective date
			notice.EffectiveDate = (Math.mod(counter, 2)==0)? dt : today;
			notice.Status = 'New';
			notice.Type = 'Renewal Notification';
			counter++;
		}

		insert notices;

		//-- Run Batch
		Test.startTest();
			Order_Batch b = new Order_Batch('CleanUpRenewalNotifications', notices);
			Database.ExecuteBatch(b);

			//-- Schedule Batch to run in 1s
			RenewalNotificationCleanUp_Scheduler.doSchedule('0 0 20 * * ?');
		Test.stopTest();

		// Confirm all data has been deleted
		Integer i = [SELECT COUNT() FROM Order WHERE EffectiveDate <= :dt];
			 	System.assertEquals(i, 0);
	}


	@isTest
	static void test_CreateSalesOrders()
	{
		TestDataGenerator.generateApexSetting();
		TestDataGenerator.generateISOCountryState();

		// Setup Data
		Account sfAccount = TestDataGenerator.generateAccounts(1, true)[0];
		Contact sfContact = TestDataGenerator.generateContacts(sfAccount.Id, 1, true)[0];

		IECAddress__c address = TestDataGenerator.generateAddresses(1, true)[0];
		Location__c soldToLocation = TestDataGenerator.generateLocations(IECConstants.SOLDTO, address.Id, sfAccount.Id, null);
		Location__c billToLocation = TestDataGenerator.generateLocations(IECConstants.BILLTO, address.Id, sfAccount.Id,  sfContact.Id);
		Location__c shipToLocation = TestDataGenerator.generateLocations(IECConstants.SHIPTO, address.Id, sfAccount.Id,  sfContact.Id);

		sfAccount.SoldTo_Location__c = soldToLocation.Id;
		update sfAccount;

		sfContact.BillTo_Location__c = billToLocation.Id;
		sfContact.ShipTo_Location__c = shipToLocation.Id;
		update sfContact;


		List<Order> orders = TestDataGenerator.generateOrder(10, sfAccount.Id, sfContact.Id, sfContact.Id, true);
		for(Order ord : orders )
		{
			ord.SoldTo_Location__c = soldToLocation.Id;
			ord.ShipTo_Location__c = shipToLocation.Id;
			ord.BillTo_Location__c = billToLocation.Id;
		}
		update orders;



		Test.startTest();
			// Test creation of SAP orders
			Order_Batch b = new Order_Batch('CreateSalesOrders', orders);
			Database.ExecuteBatch(b);
		Test.stopTest();
	}
}
