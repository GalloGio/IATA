@isTest
private class TIP_BINRangeTriggerHandlerTest {
	
	@testSetup static void createData() {
		IATA_ISO_Country__c country = new IATA_ISO_Country__c (Name = 'US', ISO_Code__c = 'US');
        insert country;

		Id paymentProviderRecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Payment Provider').getRecordTypeId();

		Account provider = new Account(Name = 'ProviderTest1',
			TIP_Provider_Type__c = 'Open Loop',
			TIP_HQ_Location__c = country.Id,
			RecordTypeId = paymentProviderRecordTypeId);
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
			PP_Payment_Network__c = 'Amex (AX)',
			PP_Category__c = 'CONSUMER');
		insert product;

		TIP_Payment_Network_Config__c paymentNetworkConfig = new TIP_Payment_Network_Config__c(Name = 'Amex Config', Maximum_Length__c = 15,
			Payment_Network__c = 'Amex (AX)');
		insert paymentNetworkConfig;

		Id listedByIATARecordTypeId = Schema.SObjectType.TIP_BIN_Range__c.getRecordTypeInfosByName().get('Listed by IATA').getRecordTypeId();

		List<TIP_BIN_Range__c> binRanges = new List<TIP_BIN_Range__c>();

		TIP_BIN_Range__c binRange1 = new TIP_BIN_Range__c(TIP_Payment_Provider_Product__c = product.Id,
			TIP_Status__c = 'Active',
			TIP_Effective_From_Date__c = Date.today(),
			TIP_Range_Start__c = '1234',
			TIP_Range_End__c = '1234',
			RecordTypeId = listedByIATARecordTypeId,
			TIP_Effective_To_Date__c = Date.today()+1);

		TIP_BIN_Range__c binRange2 = new TIP_BIN_Range__c(TIP_Payment_Provider_Product__c = product.Id,
			TIP_Status__c = 'Active',
			TIP_Effective_From_Date__c = Date.today(),
			TIP_Range_Start__c = '1234',
			TIP_Range_End__c = '',
			RecordTypeId = listedByIATARecordTypeId,
			TIP_Effective_To_Date__c = Date.today()+1);

		binRanges.add(binRange1);
		binRanges.add(binRange2);

		insert binRanges;
	}

	@isTest static void testRangeLength() {
		List<TIP_BIN_Range__c> binRanges = [SELECT Id, TIP_Range_Start__c, TIP_Range_End__c FROM TIP_BIN_Range__c];

		for (TIP_BIN_Range__c bin: binRanges) {
			System.assertEquals('123400000000000', bin.TIP_Range_Start__c, 'Not the expected padded number');
			System.assertEquals('123499999999999', bin.TIP_Range_End__c, 'Not the expected padded number');
		}

		
	}
}