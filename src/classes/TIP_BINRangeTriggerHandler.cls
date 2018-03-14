public class TIP_BINRangeTriggerHandler {
	
	public List<TIP_BIN_Range__c> triggerNew = (List<TIP_BIN_Range__c>) Trigger.new;

	public void onBeforeInsert() {
		// Gathers the netwok configurations and matches them with the
		// Bin Range parent (Partner Product) to get the required length to pad

		Map<String, List<TIP_BIN_Range__c>> productBinRangesMap = new Map<String, List<TIP_BIN_Range__c>>();

		for (TIP_BIN_Range__c bin: triggerNew) {
			if (!productBinRangesMap.containsKey(bin.TIP_Payment_Provider_Product__c)) {
				productBinRangesMap.put(bin.TIP_Payment_Provider_Product__c, new List<TIP_BIN_Range__c>());
			}
			productBinRangesMap.get(bin.TIP_Payment_Provider_Product__c).add(bin);
		}

		Set<String> productIds = productBinRangesMap.keySet();
		List<Partner_products__c> products = [SELECT Id, PP_Payment_network__c FROM Partner_products__c WHERE Id IN :productIds];

		Map<String, List<TIP_BIN_Range__c>> binRangesByCodeMap = new Map<String, List<TIP_BIN_Range__c>>();

		for (Partner_products__c product: products) {
			if (productBinRangesMap.containsKey(product.Id)) {
				binRangesByCodeMap.put(product.PP_Payment_network__c, productBinRangesMap.get(product.Id));
			}
		}

		Map<String, TIP_Payment_Network_Config__c> networkConfigs = TIP_Payment_Network_Config__c.getAll();

		for (String netKey: networkConfigs.keySet()) {

			TIP_Payment_Network_Config__c auxNetConfig = networkConfigs.get(netKey);
			if (binRangesByCodeMap.containsKey(auxNetConfig.Payment_Network__c)) {
				for (TIP_BIN_Range__c bin: binRangesByCodeMap.get(auxNetConfig.Payment_Network__c)) {
					if (String.isEmpty(bin.TIP_Range_End__c)) {
						bin.TIP_Range_End__c = fillRangeFields(bin.TIP_Range_Start__c, '9', (Integer) auxNetConfig.Maximum_Length__c);						
					} else {
						bin.TIP_Range_End__c = fillRangeFields(bin.TIP_Range_End__c, '9', (Integer) auxNetConfig.Maximum_Length__c);
					}

					if (bin.TIP_Range_Start__c.length() < auxNetConfig.Maximum_Length__c) {
						bin.TIP_Range_Start__c = fillRangeFields(bin.TIP_Range_Start__c, '0', (Integer) auxNetConfig.Maximum_Length__c);
					}
				}
			}
		}
	}

	private String fillRangeFields(String rangeText, String pad, Integer maxLength) {
		return rangeText.rightPad(maxLength, pad);
	}
}