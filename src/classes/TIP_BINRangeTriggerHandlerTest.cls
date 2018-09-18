@isTest
private class TIP_BINRangeTriggerHandlerTest {

	//public Id listedByIATARecordTypeId = TIP_Utils.LISTED_BY_IATA_RECORD_TYPE_ID;
	
	@testSetup static void createData() {
		IATA_ISO_Country__c country = new IATA_ISO_Country__c (Name = 'US', ISO_Code__c = 'US');
        insert country;

		Account account = new Account(Name = 'ProviderTest1',
			RecordTypeId =TIP_Utils.PAYMENT_PROVIDER_RECORD_TYPE_ID,
			Accreditation_date__c = Date.today(),
			IATACode__c = '1000',
			category__c = TIP_Utils.ACCOUNT_CATEGORY_PAYMENT_PROVIDER,
			status__C='Active'
			);
		insert account;

		Account_Role__c provider = new Account_Role__c();
		provider.RecordTypeId = TIP_UTils.ACCOUNT_ROLE_PAYMENT_PROVIDER_RECORDTYPE_ID;
        provider.Account__c = account.Id;
        provider.Provider_Code__c = '1000';
        provider.HQ_Location__c = country.Id;
        insert provider;

        Contact contact = new Contact(FirstName = 'First Name', LastName = 'Last Name2', Salutation = 'Mr.', 
        							  Title = 'title', Email = 'abcde@test.org', Phone = '123456789');
        insert contact;

        Account_Contact_Role__c acr = new Account_Contact_Role__c();
        acr.Account__c = account.Id;
        acr.Account_Role__c = provider.Id;
        acr.Contact_Role__c = 'Primary Contact';
        acr.Contact__c = contact.Id;
        acr.Service_Rendered__c = 'TIP';
        insert acr;

        //provider.Status__c = TIP_UTils.PARTNER_STATUS_ACTIVE;
        provider.Effective_From_Date__c = System.today();
		update provider;

		Partner_products__c product = new Partner_products__c(Name = 'ProductTest1', 
			PP_Payment_Product_Code__c = 'co',
			PP_Form_of_payment__c = 'CC',
			Provider__c = account.Id,
			Payment_Provider_Account_Role__c = provider.Id,
			PP_Payment_guarantee__c = 'COMMERCIAL_DISPUTE',
			PP_Accepted_transactions__c = 'PAYMENT',
			PP_Pay_in_model__c = 'PREPAID',
			PP_VAN_type__c = 'SINGLE_USE_VAN',
			PP_Settlement_terms__c = '12',
			Is_PCI_DSS_required__c = 'YES',
			PP_Chargeback_airlines__c = 'NO',
			PP_Interchange_fee__c = '12',
			PP_Effective_from_Date__c = Date.today(),
			PP_status__c = 'Active',
			PP_Payment_Network__c = 'AX',
			PP_Category__c = 'CONSUMER');
		insert product;

		TIP_Payment_Network_Config__c paymentNetworkConfig = new TIP_Payment_Network_Config__c(Name = 'Amex Config', Maximum_Length__c = 15,
			Payment_Network__c = 'AX');
		insert paymentNetworkConfig;

		Id listedByIATARecordTypeId = TIP_Utils.LISTED_BY_IATA_RECORD_TYPE_ID;

		List<TIP_BIN_Range__c> padBinRanges = new List<TIP_BIN_Range__c>();

		TIP_BIN_Range__c padBinRange1 = new TIP_BIN_Range__c(TIP_Payment_Provider_Product__c = product.Id,
			TIP_Effective_From_Date__c = Date.today(),
			TIP_Range_Start__c = '5000',
			TIP_Range_End__c = '5500',
			RecordTypeId = listedByIATARecordTypeId,
			TIP_Status__c='ACTIVE');

		TIP_BIN_Range__c padBinRange2 = new TIP_BIN_Range__c(TIP_Payment_Provider_Product__c = product.Id,
			TIP_Effective_From_Date__c = Date.today(),
			TIP_Range_Start__c = '6000',
			TIP_Range_End__c = '6500',
			RecordTypeId = listedByIATARecordTypeId,
			TIP_Effective_To_Date__c = Date.today()+10,
			TIP_Status__c='IN_PROGRESS'
			);

		padBinRanges.add(padBinRange1);
		padBinRanges.add(padBinRange2);

		insert padBinRanges;

		TIP_BIN_Range__c singleBinRange = new TIP_BIN_Range__c(TIP_Payment_Provider_Product__c = product.Id,
			TIP_Effective_From_Date__c = Date.today(),
			TIP_Range_Start__c = '2000',
			TIP_Range_End__c = '2100',
			RecordTypeId = listedByIATARecordTypeId,
			TIP_Effective_To_Date__c = Date.today() + 10,
			TIP_Status__c='IN_PROGRESS'
			);

		insert singleBinRange;

		TIP_BIN_Range__c binRange1 = new TIP_BIN_Range__c(TIP_Payment_Provider_Product__c = product.Id,
			TIP_Effective_From_Date__c = Date.today(),
			TIP_Range_Start__c = '2000',
			TIP_Range_End__c = '2100',
			RecordTypeId = TIP_Utils.BIN_RANGE_PROVIDER_RECORD_TYPE_ID,
			TIP_Effective_To_Date__c = Date.today() + 10,
			TIP_Status__c='IN_PROGRESS');

		TIP_BIN_Range__c binRange2 = new TIP_BIN_Range__c(TIP_Payment_Provider_Product__c = product.Id,
			TIP_Effective_From_Date__c = Date.today(),
			TIP_Range_Start__c = '2000',
			TIP_Range_End__c = '2100',
			RecordTypeId = TIP_Utils.BIN_RANGE_PROVIDER_RECORD_TYPE_ID,
			TIP_Effective_To_Date__c = Date.today() + 10,
			TIP_Status__c='IN_PROGRESS');

		insert new List<TIP_BIN_Range__c>{binRange1,binRange2};
	}

	@isTest static void testRangeLength() {
		List<TIP_BIN_Range__c> binRanges = [SELECT Id, TIP_Range_Start__c, TIP_Range_End__c FROM TIP_BIN_Range__c];

		for (TIP_BIN_Range__c bin: binRanges) {
			String startPrefix = bin.TIP_Range_Start__c.substring(0,4);
			String endPrefix = bin.TIP_Range_End__c.substring(0,4);
			System.assertEquals(startPrefix + '00000000000', bin.TIP_Range_Start__c, 'Not the expected padded number');
			System.assertEquals(endPrefix + '99999999999', bin.TIP_Range_End__c, 'Not the expected padded number');
		}		
	}

	@isTest static void testOverlaps() {

		Partner_products__c product = [SELECT Id FROM Partner_products__c][0];
		Id listedByIATARecordTypeId = TIP_Utils.LISTED_BY_IATA_RECORD_TYPE_ID;

		List<TIP_BIN_Range__c> overlapBinRanges = new List<TIP_BIN_Range__c>();
		Integer sucessCounter = 0;
		List<Database.SaveResult> results;
		Database.SaveResult updateResult;

		//Insert single BIN to deploy error type A, expected success = 0

		TIP_BIN_Range__c singleInsErrorA = new TIP_BIN_Range__c(TIP_Payment_Provider_Product__c = product.Id,
			TIP_Effective_From_Date__c = Date.today(),
			TIP_Range_Start__c = '5800',
			TIP_Range_End__c = '6200',
			RecordTypeId = listedByIATARecordTypeId,
			TIP_Effective_To_Date__c = Date.today() + 5,
			TIP_Status__c='ACTIVE');

		overlapBinRanges.add(singleInsErrorA);

		try {
			results = Database.insert(overlapBinRanges, false);
		} catch (Exception e) {
			System.debug('exception: ' + e);
		}

		for (Database.SaveResult result: results) {
			if (result.isSuccess()) sucessCounter ++;
		}

		System.assertEquals(0, sucessCounter);

		//Insert multiple BINs to deploy error type A, expected success = 0

		TIP_BIN_Range__c doubleInsErrorA = new TIP_BIN_Range__c(TIP_Payment_Provider_Product__c = product.Id,
			TIP_Effective_From_Date__c = Date.today() - 2,
			TIP_Range_Start__c = '6300',
			TIP_Range_End__c = '6400',
			RecordTypeId = listedByIATARecordTypeId,
			TIP_Effective_To_Date__c = Date.today() + 1,
			TIP_Status__c='ACTIVE');

		overlapBinRanges.add(doubleInsErrorA);

		try {
			results = Database.insert(overlapBinRanges, false);
		} catch (Exception e) {
			System.debug('exception: ' + e);
		}

		for (Database.SaveResult result: results) {
			if (result.isSuccess()) sucessCounter ++;
		}

		System.assertEquals(0, sucessCounter);

		overlapBinRanges.clear();

		//Insert single BIN to deploy error type B, expected success = 0

		TIP_BIN_Range__c singleInsErrorB = new TIP_BIN_Range__c(TIP_Payment_Provider_Product__c = product.Id,
			TIP_Effective_From_Date__c = Date.today() + 10,
			TIP_Range_Start__c = '5400',
			TIP_Range_End__c = '5600',
			RecordTypeId = listedByIATARecordTypeId,
			TIP_Status__c='IN_PROGRESS');

		overlapBinRanges.add(singleInsErrorB);

		try {
			results = Database.insert(overlapBinRanges, false);
		} catch (Exception e) {
			System.debug('exception: ' + e);
		}

		for (Database.SaveResult result: results) {
			if (result.isSuccess()) sucessCounter ++;
		}

		System.assertEquals(0, sucessCounter);

		//Insert multiple BINs to deploy error type B, expected success = 0

		TIP_BIN_Range__c doubleInsErrorB = new TIP_BIN_Range__c(TIP_Payment_Provider_Product__c = product.Id,
			TIP_Effective_From_Date__c = Date.today() -2,
			TIP_Range_Start__c = '4900',
			TIP_Range_End__c = '5100',
			RecordTypeId = listedByIATARecordTypeId,
			TIP_Status__c='ACTIVE');

		overlapBinRanges.add(doubleInsErrorB);

		try {
			results = Database.insert(overlapBinRanges, false);
		} catch (Exception e) {
			System.debug('exception: ' + e);
		}

		for (Database.SaveResult result: results) {
			if (result.isSuccess()) sucessCounter ++;
		}

		System.assertEquals(0, sucessCounter);

		overlapBinRanges.clear();

		//Insert multiple BINs, expected success = 3

		TIP_BIN_Range__c mixedInsert1 = new TIP_BIN_Range__c(TIP_Payment_Provider_Product__c = product.Id,
			TIP_Effective_From_Date__c = Date.today(),
			TIP_Range_Start__c = '5800',
			TIP_Range_End__c = '5900',
			RecordTypeId = listedByIATARecordTypeId,
			TIP_Effective_To_Date__c = Date.today() + 7,
			TIP_Status__c='ACTIVE');

		TIP_BIN_Range__c mixedInsert2 = new TIP_BIN_Range__c(TIP_Payment_Provider_Product__c = product.Id,
			TIP_Effective_From_Date__c = Date.today() - 1,
			TIP_Range_Start__c = '5800',
			TIP_Range_End__c = '5900',
			RecordTypeId = listedByIATARecordTypeId,
			TIP_Status__c='ACTIVE');

		TIP_BIN_Range__c mixedInsert3 = new TIP_BIN_Range__c(TIP_Payment_Provider_Product__c = product.Id,
			TIP_Effective_From_Date__c = Date.today()+1,
			TIP_Range_Start__c = '7500',
			TIP_Range_End__c = '7800',
			RecordTypeId = listedByIATARecordTypeId,
			TIP_Effective_To_Date__c = Date.today() + 2,
			TIP_Status__c='IN_PROGRESS');

		TIP_BIN_Range__c mixedInsert4 = new TIP_BIN_Range__c(TIP_Payment_Provider_Product__c = product.Id,
			TIP_Effective_From_Date__c = Date.today() + 3,
			TIP_Range_Start__c = '7500',
			TIP_Range_End__c = '7800',
			RecordTypeId = listedByIATARecordTypeId,
			TIP_Effective_To_Date__c = Date.today() + 5,
			TIP_Status__c='IN_PROGRESS');

		TIP_BIN_Range__c mixedInsert5 = new TIP_BIN_Range__c(TIP_Payment_Provider_Product__c = product.Id,
			TIP_Effective_From_Date__c = Date.today() - 3,
			TIP_Range_Start__c = '4900',
			TIP_Range_End__c = '5100',
			RecordTypeId = listedByIATARecordTypeId,
			TIP_Effective_To_Date__c = Date.today() - 1,
			TIP_Status__c='INACTIVE');

		TIP_BIN_Range__c mixedInsert6 = new TIP_BIN_Range__c(TIP_Payment_Provider_Product__c = product.Id,
			TIP_Effective_From_Date__c = Date.today()+1,
			TIP_Range_Start__c = '8000',
			TIP_Range_End__c = '8100',
			RecordTypeId = listedByIATARecordTypeId,
			TIP_Effective_To_Date__c = Date.today() + 1,
			TIP_Status__c='IN_PROGRESS');

		overlapBinRanges.add(mixedInsert1);
		overlapBinRanges.add(mixedInsert2);
		overlapBinRanges.add(mixedInsert3);
		overlapBinRanges.add(mixedInsert4);
		overlapBinRanges.add(mixedInsert5);
		overlapBinRanges.add(mixedInsert6);

		try {
			results = Database.insert(overlapBinRanges, false);
		} catch (Exception e) {
			System.debug('exception: ' + e);
		}

		for (Database.SaveResult result: results) {
			if (result.isSuccess()) sucessCounter ++;
		}

		System.assertEquals(4, sucessCounter);

		sucessCounter = 0;
		overlapBinRanges.clear();

		//Update single BIN to deploy error type B, expected success = 0

		mixedInsert5.TIP_Effective_To_Date__c = null;

		try {
			updateResult = Database.update(mixedInsert5, false);
		} catch (Exception e) {
			System.debug('exception: ' + e);
		}
		
		if (updateResult.isSuccess()) sucessCounter ++;
		
		System.assertEquals(0, sucessCounter);

		//Update multiple BINs to deploy error type B, expected success = 0

		mixedInsert3.TIP_Effective_To_Date__c = null;


		overlapBinRanges.add(mixedInsert3);
		overlapBinRanges.add(mixedInsert5);

		try {
			results = Database.update(overlapBinRanges, false);
		} catch (Exception e) {
			System.debug('exception: ' + e);
		}

		for (Database.SaveResult result: results) {
			if (result.isSuccess()) sucessCounter ++;
		}

		System.assertEquals(0, sucessCounter);

		overlapBinRanges.clear();

		//Update single BIN to deploy error type A, expected success = 0

		mixedInsert3.TIP_Effective_To_Date__c = Date.today() + 3;

		try {
			updateResult = Database.update(mixedInsert3, false);
		} catch (Exception e) {
			System.debug('exception: ' + e);
		}

		if (updateResult.isSuccess()) sucessCounter ++;

		System.assertEquals(0, sucessCounter);

		//Update multiple BINs to deploy error type A, expected success = 0

		mixedInsert5.TIP_Range_End__c = '7600';
		mixedInsert5.TIP_Effective_To_Date__c = Date.today() + 4;

		overlapBinRanges.add(mixedInsert3);
		overlapBinRanges.add(mixedInsert5);

		try {
			results = Database.update(overlapBinRanges, false);
		} catch (Exception e) {
			System.debug('exception: ' + e);
		}

		for (Database.SaveResult result: results) {
			if (result.isSuccess()) sucessCounter ++;
		}

		System.assertEquals(0, sucessCounter);

		overlapBinRanges.clear();

		//Update multiple BINs, expected success = 3

		mixedInsert3.TIP_Range_End__c = '7900';
		mixedInsert3.TIP_Effective_To_Date__c = Date.today() + 2;

		mixedInsert4.TIP_Range_Start__c = '7400';

		mixedInsert6.TIP_Range_End__c = '8200';

		overlapBinRanges.add(mixedInsert3);
		overlapBinRanges.add(mixedInsert4);
		overlapBinRanges.add(mixedInsert5);
		overlapBinRanges.add(mixedInsert6);

		try {
			results = Database.update(overlapBinRanges, false);
		} catch (Exception e) {
			System.debug('exception: ' + e);
		}

		for (Database.SaveResult result: results) {
			if (result.isSuccess()) sucessCounter ++;
		}

		System.assertEquals(1, sucessCounter);
	}

	@isTest public static void testCreateConflict(){
		System.assertEquals(6, [SELECT ID FROM BIN_Range_Conflict__c].size());	
	}
}