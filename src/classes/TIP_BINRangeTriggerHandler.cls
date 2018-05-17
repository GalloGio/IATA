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

	public void onAfterInsert(){
		generateBinConflits();
	}
	public void onAfterUpdate(){
		generateBinConflits();
	}

	public void onBeforeInsert() {
		padBinRanges();

		List<TIP_BIN_Range__c> notOverlappingRanges;

		if (triggerNew.size() > 1) {
			notOverlappingRanges = checkOverlapsWithNewUpdated(triggerNew);
		} else {
			notOverlappingRanges = triggerNew;
		}

		List<TIP_BIN_Range__c> existingBinRanges = [SELECT Id, Name, TIP_Range_Start__c, TIP_Payment_Provider_Product__c,TIP_Range_End__c, TIP_Effective_From_Date__c, TIP_Effective_To_Date__c 
													FROM TIP_BIN_Range__c 
													WHERE (TIP_Status__c = 'ACTIVE' OR TIP_Status__c = 'IN_PROGRESS') AND (RecordTypeid =:TIP_Utils.LISTED_BY_IATA_RECORD_TYPE_ID OR RecordTypeid =:TIP_Utils.BIN_RANGE_PROVIDER_RECORD_TYPE_ID)
													ORDER BY TIP_Range_Start__c, TIP_Effective_From_Date__c];
		
		checkOverlapsWithExisting(notOverlappingRanges, existingBinRanges);
	}

	public void onBeforeUpdate() {
		List<TIP_BIN_Range__c> updatedBins = new List<TIP_BIN_Range__c>();

		for (TIP_BIN_Range__c b: triggerNew) {
			if (b.TIP_Range_Start__c != oldMap.get(b.Id).TIP_Range_Start__c 
				|| b.TIP_Range_End__c != oldMap.get(b.Id).TIP_Range_End__c 
				|| b.TIP_Effective_From_Date__c != oldMap.get(b.Id).TIP_Effective_From_Date__c 
				|| b.TIP_Effective_To_Date__c != oldMap.get(b.Id).TIP_Effective_To_Date__c) {
				updatedBins.add(b);
			}
		}

		if (!updatedBins.isEmpty()) {
			List<TIP_BIN_Range__c> notOverlappingRanges;

			if (updatedBins.size() > 1) {
				notOverlappingRanges = checkOverlapsWithNewUpdated(updatedBins);
			} else {
				notOverlappingRanges = updatedBins;
			}

			Set<Id> updatedIds = new Set<Id>();

			for (TIP_BIN_Range__c b: updatedBins) {
				updatedIds.add(b.Id);
			}

			List<TIP_BIN_Range__c> existingBinRanges = [SELECT Id, Name,TIP_Payment_Provider_Product__c, TIP_Range_Start__c, TIP_Range_End__c, TIP_Effective_From_Date__c, TIP_Effective_To_Date__c 
													FROM TIP_BIN_Range__c 
													WHERE (TIP_Status__c = 'ACTIVE' OR TIP_Status__c = 'IN_PROGRESS') AND (RecordTypeId =:TIP_Utils.LISTED_BY_IATA_RECORD_TYPE_ID OR RecordTypeId =:TIP_Utils.BIN_RANGE_PROVIDER_RECORD_TYPE_ID) AND Id NOT IN :updatedIds
													ORDER BY TIP_Range_Start__c, TIP_Effective_From_Date__c];

			List<TIP_BIN_Range__c> existingRanges = new List<TIP_BIN_Range__c>();

			for (TIP_BIN_Range__c b: existingBinRanges) {
				if (!notOverlappingRanges.contains(b)) {
					existingRanges.add(b);
				}
			}

			checkOverlapsWithExisting(notOverlappingRanges, existingRanges);
		}
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
					if (bin.TIP_Range_End__c.length() < auxNetConfig.Maximum_Length__c) {
						bin.TIP_Range_End__c = bin.TIP_Range_End__c.rightPad((Integer) auxNetConfig.Maximum_Length__c, '9');
					}

					if (bin.TIP_Range_Start__c.length() < auxNetConfig.Maximum_Length__c) {
						bin.TIP_Range_Start__c = bin.TIP_Range_Start__c.rightPad((Integer) auxNetConfig.Maximum_Length__c, '0');
					}
				}
			}
		}
	}

	private List<TIP_BIN_Range__c> checkOverlapsWithNewUpdated(List<TIP_BIN_Range__c> binsToCheck) {
		List<BINRangeWrapper> sortedBinRanges = new List<BINRangeWrapper>();

		for (TIP_BIN_Range__c b: binsToCheck) {
			sortedBinRanges.add(new BINRangeWrapper(b));
		}

		sortedBinRanges.sort();

		List<TIP_BIN_Range__c> notOverlappingRanges = new List<TIP_BIN_Range__c>();

		for (Integer i = 0; i < sortedBinRanges.size(); i++) {
			for (Integer j = 0; j < sortedBinRanges.size(); j++) {
				if (i != j) {
					Integer overlapCode = getOverlap(sortedBinRanges[i].biny, sortedBinRanges[j].biny);
					if (overlapCode == 1) {
						if (sortedBinRanges[i].biny.recordtypeid != TIP_Utils.BIN_RANGE_PROVIDER_RECORD_TYPE_ID && sortedBinRanges[i].biny.TIP_Payment_Provider_Product__c == sortedBinRanges[j].biny.TIP_Payment_Provider_Product__c) 
							sortedBinRanges[i].biny.addError('The following overlapping BIN Range has been detected: <a href=\'/' + sortedBinRanges[j].biny.Id + '?pv0={!TIP_BIN_Range__c.Id}\'>'+ sortedBinRanges[j].biny.Name +'</a>', false);
						break;
					} else if (overlapCode == 2) {
						if (sortedBinRanges[i].biny.recordtypeid != TIP_Utils.BIN_RANGE_PROVIDER_RECORD_TYPE_ID && sortedBinRanges[i].biny.TIP_Payment_Provider_Product__c == sortedBinRanges[j].biny.TIP_Payment_Provider_Product__c) 
							sortedBinRanges[i].biny.addError('The following overlapping, open-ended BIN Range has been detected: <a href=\'/' + sortedBinRanges[j].biny.Id + '?pv0={!TIP_BIN_Range__c.Id}\'>'+ sortedBinRanges[j].biny.Name +'</a>', false);
						break;
					} else if (j == sortedBinRanges.size()-1 && overlapCode == 0) {
						notOverlappingRanges.add(sortedBinRanges[i].biny);
					}
				}
			}
		}

		return notOverlappingRanges;		
	}

	private void checkOverlapsWithExisting(List<TIP_BIN_Range__c> newBinsToCheck, List<TIP_BIN_Range__c> existingBinsToCheck) {
		for (TIP_BIN_Range__c bin: newBinsToCheck) {
			
			for (TIP_BIN_Range__c existingBin: existingBinsToCheck) {
				if (bin.Id != existingBin.Id) {
					Integer overlapCode = getOverlap(bin, existingBin);
					if (overlapCode == 1) {
						
						if(bin.recordtypeid != TIP_Utils.BIN_RANGE_PROVIDER_RECORD_TYPE_ID && bin.TIP_Payment_Provider_Product__c == existingBin.TIP_Payment_Provider_Product__c) bin.addError('The following overlapping BIN Range has been detected: <a href=\'/' + existingBin.Id + '?pv0={!TIP_BIN_Range__c.Id}\'>'+ existingBin.Name +'</a>', false);
						
						break;
					} else if (overlapCode == 2) {
						if(bin.recordtypeid != TIP_Utils.BIN_RANGE_PROVIDER_RECORD_TYPE_ID && bin.TIP_Payment_Provider_Product__c == existingBin.TIP_Payment_Provider_Product__c) bin.addError('The following overlapping, open-ended BIN Range has been detected: <a href=\'/' + existingBin.Id + '?pv0={!TIP_BIN_Range__c.Id}\'>'+ existingBin.Name +'</a>', false);
						
						break;
					}
				}
				
			}
		}
	}

	private Integer getOverlap(TIP_BIN_Range__c bin1, TIP_BIN_Range__c bin2) {
		//Helper to determine if the two bin ranges overlap
		//0 - No overlap
		//1 - Overlap on Ranges and Dates
		//2 - Overlap on Ranges and open-ended Dates 
		if (bin1.TIP_Range_Start__c <= bin2.TIP_Range_End__c && bin1.TIP_Range_End__c >= bin2.TIP_Range_Start__c) {
			if ((bin1.TIP_Effective_To_Date__c == null && bin2.TIP_Effective_To_Date__c == null) 
				|| (bin1.TIP_Effective_To_Date__c == null && bin2.TIP_Effective_To_Date__c >= bin1.TIP_Effective_From_Date__c)
				|| (bin2.TIP_Effective_To_Date__c == null && bin1.TIP_Effective_To_Date__c >= bin2.TIP_Effective_From_Date__c)) {
				return 2;
			} else if (bin1.TIP_Effective_From_Date__c <= bin2.TIP_Effective_To_Date__c && bin1.TIP_Effective_To_Date__c >= bin2.TIP_Effective_From_Date__c) {
				return 1;
			}			
		}
		return 0;
	}

	private void generateBinConflits(){
		List<BIN_Range_Conflict__c> binRangeConflits = new List<BIN_Range_Conflict__c>(); 
		
		delete [SELECT ID FROM BIN_Range_Conflict__c where BIN_Range__c IN :newMap.keySet() OR BIN_Range_Conflict__c IN :newMap.keySet()];

		List<TIP_BIN_Range__c> binRanges = [SELECT Id, Name,TIP_Payment_Provider_Product__c, TIP_Range_Start__c, TIP_Range_End__c, TIP_Effective_From_Date__c, TIP_Effective_To_Date__c 
											FROM TIP_BIN_RANGE__C 
											WHERE TIP_Status__c <> :TIP_Utils.BIN_RANGE_STATUS_DRAFT
												AND ID NOT IN :newMap.keySet()];

		for (Integer i = 0; i < triggerNew.size(); i++) {
			//compare between the bin ranges that were inserted
			for (Integer j = i+1; j < triggerNew.size(); j++) {
				if( getOverlap(triggerNew[i], triggerNew[j]) != 0 && triggerNew[i].TIP_Status__c != TIP_Utils.BIN_RANGE_STATUS_DRAFT
					&& triggerNew[i].recordtypeid == TIP_Utils.BIN_RANGE_PROVIDER_RECORD_TYPE_ID) binRangeConflits.addAll(createBinRangeConflict(triggerNew[i], triggerNew[j]));
			}

			//compare with the alredy existing bin ranges
			for (Integer k = 0; k < binRanges.size(); k++) {
				if( getOverlap(triggerNew[i], binRanges[k]) != 0 && triggerNew[i].TIP_Status__c != TIP_Utils.BIN_RANGE_STATUS_DRAFT
					&& triggerNew[i].recordtypeid == TIP_Utils.BIN_RANGE_PROVIDER_RECORD_TYPE_ID) binRangeConflits.addAll(createBinRangeConflict(triggerNew[i], binRanges[k]));
			}
		}
		insert binRangeConflits;
		update matchBinRangeConflictWithTwin(binRangeConflits);
	}

	private List<BIN_Range_Conflict__c> createBinRangeConflict(TIP_BIN_Range__c bin1, TIP_BIN_Range__c bin2){
		BIN_Range_Conflict__c bc1 = new BIN_Range_Conflict__c(BIN_Range__c = bin1.id,BIN_Range_Conflict__c = bin2.id, Partner_Product__c = bin1.TIP_Payment_Provider_Product__c);
		BIN_Range_Conflict__c bc2 = new BIN_Range_Conflict__c(BIN_Range__c = bin2.id,BIN_Range_Conflict__c = bin1.id, Partner_Product__c = bin2.TIP_Payment_Provider_Product__c);
		return new List<BIN_Range_Conflict__c>{bc1,bc2};

	}
	private List<BIN_Range_Conflict__c> matchBinRangeConflictWithTwin(List<BIN_Range_Conflict__c> binRangeConflits){
		for(Integer i = 0; i <binRangeConflits.size(); i++){
			for(Integer j = i+1; j <binRangeConflits.size(); j++){
				if(binRangeConflits[i].BIN_Range__c == binRangeConflits[j].BIN_Range_Conflict__c && 
					binRangeConflits[i].BIN_Range_Conflict__c == binRangeConflits[j].BIN_Range__c){

					binRangeConflits[i].Twin_Conflict__c = binRangeConflits[j].id;
					binRangeConflits[j].Twin_Conflict__c = binRangeConflits[i].id;
				}
			}
		}
		return binRangeConflits;
	}
}