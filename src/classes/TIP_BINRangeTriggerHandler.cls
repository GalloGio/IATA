public class TIP_BINRangeTriggerHandler {
	
	public List<TIP_BIN_Range__c> triggerNew = (List<TIP_BIN_Range__c>) Trigger.new;
	public List<TIP_BIN_Range__c> triggerOld = (List<TIP_BIN_Range__c>) Trigger.old;

	public Map<Id, TIP_BIN_Range__c> newMap = (Map<Id, TIP_BIN_Range__c>) Trigger.newMap;
	public Map<Id, TIP_BIN_Range__c> oldMap = (Map<Id, TIP_BIN_Range__c>) Trigger.oldMap;

	class BINRangeWrapper implements Comparable {

    	public TIP_BIN_Range__c biny;
    
    	public BINRangeWrapper(TIP_BIN_Range__c bin) {
        	biny = bin;
    	}
    
    	// Compare bin ranges based on the range and date.
    	public Integer compareTo(Object compareTo) {
        	// Cast argument to BinRangeWrapper
        	BINRangeWrapper compareToBiny = (BINRangeWrapper)compareTo;
        
        	// The return value of 0 indicates that both elements are equal.
        	Integer returnValue = 0;
        	if (biny.TIP_Range_Start__c > compareToBiny.biny.TIP_Range_Start__c) {
         	   // Set return value to a positive value.
         	   returnValue = 1;
        	} else if (biny.TIP_Range_Start__c < compareToBiny.biny.TIP_Range_Start__c) {
           		// Set return value to a negative value.
            	returnValue = -1;
        	} else if (biny.TIP_Effective_From_Date__c < compareToBiny.biny.TIP_Effective_From_Date__c) {
        		// Set return value to a negative value.
        		returnValue = -1;
        	} else if (biny.TIP_Effective_From_Date__c > compareToBiny.biny.TIP_Effective_From_Date__c) {
        		// Set return value to a positive value.
        		return 1;
        	}
        
        	return returnValue;       
    	}
	}

	//Helper to determine if the two bin ranges overlap
	//0 - No overlap
	//1 - Overlap on Ranges and Dates
	//2 - Overlap on Ranges and open-ended Dates 

	private Integer checkOverlap(TIP_BIN_Range__c bin1, TIP_BIN_Range__c bin2) {
		if (bin1.TIP_Range_Start__c <= bin2.TIP_Range_End__c && bin1.TIP_Range_End__c >= bin2.TIP_Range_Start__c) {
					
			if (bin2.TIP_Effective_To_Date__c == null) {
						
				if (bin1.TIP_Effective_To_Date__c == null) {
					return 2;

				} else if (bin1.TIP_Effective_To_Date__c >= bin2.TIP_Effective_From_Date__c) {
					return 2;
				}
			} else if (bin1.TIP_Effective_From_Date__c >= bin2.TIP_Effective_From_Date__c && bin1.TIP_Effective_From_Date__c <= bin2.TIP_Effective_To_Date__c) {
				return 1;
			}			
		}
		return 0;
	}

	public void onBeforeInsert() {
		padBinRanges();

		List<BINRangeWrapper> sortedBinRanges = new List<BINRangeWrapper>();

		for (TIP_BIN_Range__c b: triggerNew) {
			sortedBinRanges.add(new BINRangeWrapper(b));
		}

		sortedBinRanges.sort();

		//List<TIP_BIN_Range__c> overlappingRanges = new List<TIP_BIN_Range__c>();
		List<TIP_BIN_Range__c> notOverlappingRanges = new List<TIP_BIN_Range__c>();

		for (Integer i = 0; i < sortedBinRanges.size(); i++) {
			for (Integer j = 0; j < sortedBinRanges.size(); j++) {
				if (i != j) {
					Integer overlapCode = checkOverlap(sortedBinRanges[i].biny, sortedBinRanges[j].biny);
					if (overlapCode == 1) {
						//overlappingRanges.add(sortedBinRanges[i].biny);
						sortedBinRanges[i].biny.addError('The following overlapping BIN Range has been detected: <a href=\'https://iata--tiprlavos.cs88.my.salesforce.com/' + sortedBinRanges[j].biny.Id + '\'>'+ sortedBinRanges[j].biny.Name +'</a>', false);
						break;
					} else if (overlapCode == 2) {
						sortedBinRanges[i].biny.addError('The following overlapping, open-ended BIN Range has been detected: <a href=\'https://iata--tiprlavos.cs88.my.salesforce.com/' + sortedBinRanges[j].biny.Id + '\'>'+ sortedBinRanges[j].biny.Name +'</a>', false);
						break;
					} else if (j == sortedBinRanges.size()-1 && overlapCode == 0) {
						notOverlappingRanges.add(sortedBinRanges[i].biny);
					}
				}
			}
		}
		
		List<TIP_BIN_Range__c> existingBinRanges = [SELECT Id, Name, TIP_Range_Start__c, TIP_Range_End__c, TIP_Effective_From_Date__c, TIP_Effective_To_Date__c 
													FROM TIP_BIN_Range__c 
													WHERE (TIP_Status__c = 'Active' OR TIP_Status__c = 'In Progress') AND (RecordType.DeveloperName = 'Listed_by_IATA' OR RecordType.DeveloperName = 'Provider')
													ORDER BY TIP_Range_Start__c, TIP_Effective_From_Date__c];

		for (TIP_BIN_Range__c bin: notOverlappingRanges) {
			
			for (TIP_BIN_Range__c existingBin: existingBinRanges) {

				Integer overlapCode = checkOverlap(bin, existingBin);
				if (overlapCode == 1) {
					bin.addError('The following overlapping BIN Range has been detected: <a href=\'https://iata--tiprlavos.cs88.my.salesforce.com/' + existingBin.Id + '\'>'+ existingBin.Name +'</a>', false);
					break;
				} else if (overlapCode == 2) {
					bin.addError('The following overlapping, open-ended BIN Range has been detected: <a href=\'https://iata--tiprlavos.cs88.my.salesforce.com/' + existingBin.Id + '\'>'+ existingBin.Name +'</a>', false);
					break;
				}
			}
		}
	}

	public void onBeforeUpdate() {

	}

	private void padBinRanges() {
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
						bin.TIP_Range_End__c = bin.TIP_Range_Start__c.rightPad((Integer) auxNetConfig.Maximum_Length__c, '9');
					} else {
						bin.TIP_Range_End__c = bin.TIP_Range_End__c.rightPad((Integer) auxNetConfig.Maximum_Length__c, '9');
					}

					if (bin.TIP_Range_Start__c.length() < auxNetConfig.Maximum_Length__c) {
						bin.TIP_Range_Start__c = bin.TIP_Range_Start__c.rightPad((Integer) auxNetConfig.Maximum_Length__c, '0');
					}
				}
			}
		}
	}
}