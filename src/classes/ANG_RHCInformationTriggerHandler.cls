public class ANG_RHCInformationTriggerHandler{

	//public final Double UPPERFLUCTUATION = 1;
	//public final Double LOWERFLUCTUATION = 2;

	public List<ANG_RHC_Information__c> triggerNew = (List<ANG_RHC_Information__c>) Trigger.new;
	public List<ANG_RHC_Information__c> triggerOld = (List<ANG_RHC_Information__c>) Trigger.old;

	public Map<Id, ANG_RHC_Information__c> newMap = (Map<Id,ANG_RHC_Information__c>) Trigger.newMap;
	public Map<Id, ANG_RHC_Information__c> oldMap = (Map<Id,ANG_RHC_Information__c>) Trigger.oldMap;

	// ************************************************************
	// ****************** distribution methods ********************
	// ************************************************************
	
	public void onBeforeInsert(){
		convertAndSumFS();
		sumRHCAmount();
	}
	public void onAfterInsert(){
		Map<Id, ANG_RHC_Information__c> tempMap =new Map<Id, ANG_RHC_Information__c>();
		for(ANG_RHC_Information__c rhcrec:triggerNew){
			tempMap.put(rhcrec.id, new ANG_RHC_Information__c());
		}
		new ANG_AgencyEventsGenerator(filterByIATACode(triggerNew),tempMap,'RHC_Information','ANG_AccountId__c').run();
	}
	public void onBeforeUpdate(){
		convertAndSumFS();
		sumRHCAmount();
		//analyzeConsumedRHCAdjustment(); as per NEWGEN-1085

		List<ANG_RHC_Information__c> updatedFlagsForRHCEqsFS = new List<ANG_RHC_Information__c>();
		
		for(ANG_RHC_Information__c rhc : triggerNew) 
			if(rhc.ANG_RHC_Amount_Equals_FS__c != oldMap.get(rhc.id).ANG_RHC_Amount_Equals_FS__c)
				updatedFlagsForRHCEqsFS.add(rhc);

		if (!updatedFlagsForRHCEqsFS.isEmpty()) ANG_RHCHelper.calculateRHCAmount(updatedFlagsForRHCEqsFS);
	}
	public void onAfterUpdate(){
		new ANG_AgencyEventsGenerator(filterByIATACode(triggerNew),oldMap,'RHC_Information','ANG_AccountId__c').run();
		refreshRMEData();
	}

	public void onBeforeDelete(){}
	public void onAfterDelete(){}

	// ************************************************************
	// ********************* action methods ***********************
	// ************************************************************


	public static List<ANG_RHC_Information__c> filterByIATACode(List<ANG_RHC_Information__c> changeCodes){

		List<ANG_RHC_Information__c> toReturn = new List<ANG_RHC_Information__c>();

		for(ANG_RHC_Information__c rhc : changeCodes)
			if(rhc.ANG_IATA_Code__c <> null)
				toReturn.add(rhc);

		return toReturn;
	}

	private void convertAndSumFS(){
		set<id> accIdSet = new set<id>();		
		map<id,ANG_RHC_Information__c> accRhcMap = new map<id,ANG_RHC_Information__c>();
		for(ANG_RHC_Information__c rhc:triggerNew){
			if(Trigger.isInsert || Trigger.isUpdate && rhc.currencyIsoCode != oldMap.get(rhc.id).currencyIsoCode){				
			accIdSet.add(rhc.ANG_AccountId__c);
			accRhcMap.put(rhc.ANG_AccountId__c,rhc);
		}
		}

		if(!accIdSet.isEmpty()){
			Map<id,list<Financial_Security__c>> accFSmap =new map<id,list<Financial_Security__c>>();
			for(account acc:[SELECT Id, (SELECT Id, amount__c,CurrencyIsoCode,Security_Status__c FROM Financial_Securities__r) FROM Account WHERE Id IN :accIdSet]){
				accFSmap.put(acc.id,acc.Financial_Securities__r);
			}
			list<Financial_Security__c> fsList= new list<Financial_Security__c>();
			for(id accid :accFSmap.KeySet()){
				ANG_Risk_Helper.convertFSAmountToTargetCur(accFSmap.get(accid),accRhcMap.get(accid).CurrencyIsoCode);
				accRhcMap.get(accid).ANG_Financial_Security__c =ANG_Risk_Helper.sumFSConvertedAmounts(accFSmap.get(accid));
				
				//only updates the minimum FS on update rhc record
				if(Trigger.isUpdate)accRhcMap.get(accid).ANG_Minimum_Financial_Security__c =ANG_Risk_Helper.currencyConverter(oldMap.get(accRhcMap.get(accid).id).currencyIsoCode,accRhcMap.get(accid).ANG_Minimum_Financial_Security__c,accRhcMap.get(accid).currencyIsoCode);
				fsList.addAll(accFSmap.get(accid));
			}
			if(!fsList.isEmpty()){
				update fsList;
			}
		}
	}

	private void sumRHCAmount() {
		List<ANG_RHC_Information__c> rhcToSum = new List<ANG_RHC_Information__c>();
		for(ANG_RHC_Information__c rhcInfo : triggerNew){
			if(
				rhcinfo.ANG_Enable_Calculation__c &&
				(
					Trigger.isInsert
					|| rhcInfo.ANG_CashCondition__c != oldMap.get(rhcInfo.Id).ANG_CashCondition__c
					|| rhcInfo.ANG_RME_Amount__c != oldMap.get(rhcInfo.Id).ANG_RME_Amount__c
					|| rhcInfo.ANG_Financial_Security__c != oldMap.get(rhcInfo.Id).ANG_Financial_Security__c
					|| rhcInfo.ANG_Minimum_Financial_Security__c != oldMap.get(rhcInfo.Id).ANG_Minimum_Financial_Security__c
					|| rhcInfo.ANG_RHC_Amount_Provisional__c != oldMap.get(rhcInfo.Id).ANG_RHC_Amount_Provisional__c
					|| rhcInfo.ANG_RHC_Amount_Equals_FS__c != oldMap.get(rhcInfo.Id).ANG_RHC_Amount_Equals_FS__c
				)
			){
				rhcToSum.add(rhcInfo);
			}
		}

		if(!rhcToSum.isEmpty()) ANG_RHCHelper.calculateRHCAmount(rhcToSum);

		for(ANG_RHC_Information__c rhc : triggerNew){
			if(Trigger.isInsert || oldMap.get(rhc.id).ANG_RHC_Amount__c != rhc.ANG_RHC_Amount__c) rhc.ANG_RHC_Effective_Date__c=System.Today();
		}
	}

	private void refreshRMEData() {

		Set<Id> accIds = new Set<Id>();
		for(ANG_RHC_Information__c r : triggerNew){
			if(!r.ANG_CashCondition__c && oldMap.get(r.Id).ANG_CashCondition__c) accIds.add(r.ANG_AccountId__c);
		}
		/* **** INC424176 ****
		   ****  Disable the Provisional RHC re-calculation call from RME ****
		if(!accIds.isEmpty()) {
			if(Limits.getLimitQueueableJobs() <= Limits.getQueueableJobs()) Database.executeBatch(new ANG_UpdateRHCInformationBatch(accIds, ANG_UpdateRHCInformationBatch.Process.PROVISIONAL, true, 1));
			else System.enqueueJob(new ANG_UpdateRHCInformationQueueable(accIds, ANG_UpdateRHCInformationBatch.Process.PROVISIONAL, true, 1));
		}*/

		if(!accIds.isEmpty()) {
			if(Limits.getLimitQueueableJobs() <= Limits.getQueueableJobs()) Database.executeBatch(new ANG_UpdateRHCInformationBatch(accIds, ANG_UpdateRHCInformationBatch.Process.CONSUMED, false, 1));
			else System.enqueueJob(new ANG_UpdateRHCInformationQueueable(accIds, ANG_UpdateRHCInformationBatch.Process.CONSUMED, false, 1));
		}	
	}

}
