@isTest
private class TIP_BINRangeTriggerHandlerTest {

	//public Id listedByIATARecordTypeId = TIP_Utils.LISTED_BY_IATA_RECORD_TYPE_ID;
	
	@testSetup static void createData() {
		IATA_ISO_Country__c country = new IATA_ISO_Country__c (Name = 'US', ISO_Code__c = 'US');
        insert country;

		Id paymentProviderRecordTypeId = RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Account').get('TIP_Payment_Provider');

		Account provider = new Account(Name = 'ProviderTest1',
			TIP_Provider_Type__c = 'Open Loop',
			TIP_HQ_Location__c = country.Id,
			RecordTypeId = paymentProviderRecordTypeId,
			Accreditation_date__c = Date.today());
		insert provider;

		Partner_products__c product = new Partner_products__c(Name = 'ProductTest1', 
			PP_Payment_Product_Code__c = 'co',
			PP_Form_of_payment__c = 'CC',
			Provider__c = provider.Id,
			PP_Payment_guarantee__c = 'COMMERCIAL_DISPUTE',
			PP_Accepted_transactions__c = 'Payment',
			PP_Pay_in_model__c = 'Prepaid',
			PP_VAN_type__c = 'Single Use VAN',
			PP_Settlement_terms__c = '12',
			Is_PCI_DSS_required__c = 'Yes',
			PP_Chargeback_airlines__c = 'No',
			PP_Interchange_fee__c = 12,
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
			RecordTypeId = listedByIATARecordTypeId);

		TIP_BIN_Range__c padBinRange2 = new TIP_BIN_Range__c(TIP_Payment_Provider_Product__c = product.Id,
			TIP_Effective_From_Date__c = Date.today(),
			TIP_Range_Start__c = '6000',
			TIP_Range_End__c = '6500',
			RecordTypeId = listedByIATARecordTypeId,
			TIP_Effective_To_Date__c = Date.today()+10);

		padBinRanges.add(padBinRange1);
		padBinRanges.add(padBinRange2);

		insert padBinRanges;

		TIP_BIN_Range__c singleBinRange = new TIP_BIN_Range__c(TIP_Payment_Provider_Product__c = product.Id,
			TIP_Effective_From_Date__c = Date.today(),
			TIP_Range_Start__c = '2000',
			TIP_Range_End__c = '2100',
			RecordTypeId = listedByIATARecordTypeId,
			TIP_Effective_To_Date__c = Date.today() + 10);

		insert singleBinRange;
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

		TIP_BIN_Range__c overlapBinRange1 = new TIP_BIN_Range__c(TIP_Payment_Provider_Product__c = product.Id,
			TIP_Effective_From_Date__c = Date.today(),
			TIP_Range_Start__c = '5200',
			TIP_Range_End__c = '5700',
			RecordTypeId = listedByIATARecordTypeId);

		TIP_BIN_Range__c overlapBinRange2 = new TIP_BIN_Range__c(TIP_Payment_Provider_Product__c = product.Id,
			TIP_Effective_From_Date__c = Date.today() - 1,
			TIP_Range_Start__c = '4700',
			TIP_Range_End__c = '5200',
			RecordTypeId = listedByIATARecordTypeId);

		TIP_BIN_Range__c overlapBinRange3 = new TIP_BIN_Range__c(TIP_Payment_Provider_Product__c = product.Id,
			TIP_Effective_From_Date__c = Date.today() + 11,
			TIP_Range_Start__c = '6200',
			TIP_Range_End__c = '6300',
			RecordTypeId = listedByIATARecordTypeId);

		TIP_BIN_Range__c overlapBinRange4 = new TIP_BIN_Range__c(TIP_Payment_Provider_Product__c = product.Id,
			TIP_Effective_From_Date__c = Date.today(),
			TIP_Range_Start__c = '5800',
			TIP_Range_End__c = '6700',
			RecordTypeId = listedByIATARecordTypeId,
			TIP_Effective_To_Date__c = Date.today() + 10);

		TIP_BIN_Range__c overlapBinRange5 = new TIP_BIN_Range__c(TIP_Payment_Provider_Product__c = product.Id,
			TIP_Effective_From_Date__c = Date.today() + 9,
			TIP_Range_Start__c = '6200',
			TIP_Range_End__c = '6700',
			RecordTypeId = listedByIATARecordTypeId,
			TIP_Effective_To_Date__c = Date.today() + 10);

		TIP_BIN_Range__c overlapBinRange6 = new TIP_BIN_Range__c(TIP_Payment_Provider_Product__c = product.Id,
			TIP_Effective_From_Date__c = Date.today() - 10,
			TIP_Range_Start__c = '6200',
			TIP_Range_End__c = '6700',
			RecordTypeId = listedByIATARecordTypeId,
			TIP_Effective_To_Date__c = Date.today() - 1);

		overlapBinRanges.add(overlapBinRange1);
		overlapBinRanges.add(overlapBinRange2);
		overlapBinRanges.add(overlapBinRange3);
		overlapBinRanges.add(overlapBinRange4);
		overlapBinRanges.add(overlapBinRange5);
		overlapBinRanges.add(overlapBinRange6);

		List<Database.SaveResult> results;

		try {
			results = Database.insert(overlapBinRanges, false);
		} catch (Exception e) {
			System.debug('exception: ' + e);
		}

		Integer sucessCounter = 0;

		for (Database.SaveResult result: results) {
			if (result.isSuccess()) sucessCounter ++;
		}

		System.assertEquals(2, sucessCounter);
		sucessCounter = 0;

		overlapBinRanges.clear();

		overlapBinRange5.TIP_Effective_From_Date__c = Date.today() + 3;
		overlapBinRange5.TIP_Effective_To_Date__c = null;
		overlapBinRange6.TIP_Range_Start__c = '6600';
		overlapBinRange6.TIP_Range_End__c = '7900';
		overlapBinRange6.TIP_Effective_To_Date__c = null;

		overlapBinRanges.add(overlapBinRange5);
		overlapBinRanges.add(overlapBinRange6);

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
}