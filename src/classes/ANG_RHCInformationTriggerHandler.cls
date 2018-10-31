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
            if(Limits.getLimitQueueableJobs() <= Limits.getQueueableJobs()) { 
                Database.executeBatch(new ANG_UpdateRHCInformationBatch(accIds, ANG_UpdateRHCInformationBatch.Process.CONSUMED, false, 1));
            } else {
                if(System.isBatch() && Limits.getQueueableJobs() == 1) {
                    Datetime execTime = Datetime.now().addSeconds(5);
                    String hour = String.valueOf(execTime.hour());
                    String min = String.valueOf(execTime.minute()); 
                    String ss = String.valueOf(execTime.second());
                    String nextFireTime = ss + ' ' + min + ' ' + hour + ' * * ?';
                    System.schedule('ANG_UpdateRHCInformationScheduler ' + String.valueOf(Math.random()), nextFireTime, 
                        new ANG_UpdateRHCInformationScheduler(accIds, ANG_UpdateRHCInformationBatch.Process.CONSUMED, false, 1));
                } else {
                    System.enqueueJob(new ANG_UpdateRHCInformationQueueable(accIds, ANG_UpdateRHCInformationBatch.Process.CONSUMED, false, 1));
                }               
            }
        }        	
	}

	/* as per NEWGEN-1085

	private void analyzeConsumedRHCAdjustment(){

		Set<Id> toActivateAccounts = new Set<Id>();
		Set<Id> toDeactivateAccounts = new Set<Id>(); 
		List<Agency_Authorization__c> toUpdate = new List<Agency_Authorization__c>();

		for(ANG_RHC_Information__c rhc:triggerNew){
			if(rhc.ANG_ConsumedRHC_Percent__c  <> oldMap.get(rhc.Id).ANG_ConsumedRHC_Percent__c){

				if(hasfluctuation(rhc.ANG_ConsumedRHC_Percent__c,oldMap.get(rhc.Id).ANG_ConsumedRHC_Percent__c) == UPPERFLUCTUATION){
					toDeactivateAccounts.add(rhc.ANG_AccountId__c);
				}
				else if(hasfluctuation(rhc.ANG_ConsumedRHC_Percent__c,oldMap.get(rhc.Id).ANG_ConsumedRHC_Percent__c) == LOWERFLUCTUATION){
					toActivateAccounts.add(rhc.ANG_AccountId__c);	
				}
			}
		}

		if(!toDeactivateAccounts.isEmpty()){
			
			Map<Id, List<AMS_Agencies_relationhip__c>> toDeactivateAccountsMap = AMS_HierarchyHelper.getAccountsHierarchies(toDeactivateAccounts);
			            
			if(isEmptySetOfLists(toDeactivateAccountsMap.values())){		
				toUpdate.addAll(performFOPaction(toDeactivateAccounts,UPPERFLUCTUATION));
			}else{
				toDeactivateAccounts = ANG_AgencyChangesHelper.extractAllAccounts(toDeactivateAccountsMap);
				toUpdate.addAll(performFOPaction(toDeactivateAccounts,UPPERFLUCTUATION));
			}
		}
		
		if(!toActivateAccounts.isEmpty()){
			
			Map<Id, List<AMS_Agencies_relationhip__c>> toActivateAccountsMap = AMS_HierarchyHelper.getAccountsHierarchies(toActivateAccounts);
			            
			if(isEmptySetOfLists(toActivateAccountsMap.values())){ // does not have a hierarchy
				toUpdate.addAll(performFOPaction(toActivateAccounts,LOWERFLUCTUATION));
			}else{
				toActivateAccounts = ANG_AgencyChangesHelper.extractAllAccounts(toActivateAccountsMap);
				toUpdate.addAll(performFOPaction(toActivateAccounts,LOWERFLUCTUATION));
			}



		}

		if(!toUpdate.isEmpty())
			update toUpdate;

		Map<Id,String> accountsToCreateFOP = new Map<Id,String> ();

		for(Agency_Authorization__c aa: toUpdate){

			accountsToCreateFOP.put(aa.Account__c,aa.Status__c);
		}

		if(!accountsToCreateFOP.isEmpty())
			createChangeCodeForFOP(accountsToCreateFOP);


	}
	*/

	/*private boolean isEmptySetOfLists(List<List<AMS_Agencies_relationhip__c>> setOfLists){

		if(setOfLists.isEmpty())
			return true;

		for(List<AMS_Agencies_relationhip__c> lst: setOfLists){
			if(!lst.isEmpty())
				return false;
		}

		return true;
	}
	*/

/*
	private Decimal hasfluctuation(Decimal newValue, Decimal oldValue){

		Decimal UPPERTHRESHOLD = 100;

		newValue = newValue == null ? 0 : newValue;
		oldValue = oldValue == null ? 0 : oldValue;
		 
		if(newValue > oldValue && oldValue < UPPERTHRESHOLD && newValue >= UPPERTHRESHOLD) // If the value goes from below 100 to above/equals 100
			return UPPERFLUCTUATION;

		if(newValue < oldValue && oldValue >= UPPERTHRESHOLD && newValue < UPPERTHRESHOLD) // If the value goes from above/equal 100 to below 100  
			return LOWERFLUCTUATION;

		return -1;

	}
*/

/*
	private List<Agency_Authorization__c> performFOPaction(Set<Id> accounts, Decimal action){

		System.debug('Performing FOP actions on accounts ' + accounts + ' with action ' + action);

		List<Agency_Authorization__c> toReturn = new List<Agency_Authorization__c>();

		String statusFOP = action == UPPERFLUCTUATION ? 'Non-Active' : 'Active';

        Id formOfPaymentRT = Schema.Agency_Authorization__c.sObjectType.getDescribe().getRecordTypeInfosByName().get('Form Of Payment').getRecordTypeId();

		List<Agency_Authorization__c> aaLst = [Select Id, ANG_FormOfPayment_ID__c, Status__c, Account__r.Is_PCI_compliant__c from Agency_Authorization__c where Account__c in :accounts and ANG_FormOfPayment_ID__c = 'CA' and recordTypeId = :formOfPaymentRT and Account__r.recordTypeId = :AMS_Utils.RECTYPE_IATAAGENCY];

		for(Agency_Authorization__c aa: aaLst){
			
			if(aa.Status__c != statusFOP){
				aa.Status__c = statusFOP;
				toReturn.add(aa);
			}

		}
		
		return toReturn;

	}
*/

/*
	public void createChangeCodeForFOP(Map<Id,String> accountsAndStatus) {

		AMS_ChangeCodes__c changeCodeConfigPCA = AMS_ChangeCodes__c.getInstance('PCA');
		AMS_ChangeCodes__c changeCodeConfigPCR = AMS_ChangeCodes__c.getInstance('PCR');

		Set<Id> accountIds = accountsAndStatus.keySet();

		List<Agency_Applied_Change_code__c> activeChangeCodes =
		    new List<Agency_Applied_Change_code__c>([SELECT Id, Account__c, Reason_Code__c, Reason_Description__c, Bulletin_Information__c FROM Agency_Applied_Change_code__c WHERE Account__c IN :accountIds AND Active__c = true]);

		//map accountId -> active change code
		Map<Id, Agency_Applied_Change_code__c> accountsChangeCode = new Map<Id, Agency_Applied_Change_code__c>();

		for (Id accId : accountIds) {
			for (Agency_Applied_Change_code__c changeCode : activeChangeCodes)
				if (changeCode.Account__c == accId)
					accountsChangeCode.put(accId, changeCode);
		}

		List<Account> accountToCreateCC = [Select Id, Status__c from Account where Id in :accountIds];

		List<AMS_OSCAR_JSON.ChangeCode> listOfCCToInsert = new List<AMS_OSCAR_JSON.ChangeCode>();
		List<AMS_OSCAR__c> oscarsToAdd = new List<AMS_OSCAR__c>();

		For(Account acctToAddCC: accountToCreateCC){

			oscarsToAdd.add(null);

			AMS_OSCAR_JSON.ChangeCode changeCode = new AMS_OSCAR_JSON.ChangeCode();

			AMS_ChangeCodes__c toUse = accountsAndStatus.get(acctToAddCC.Id) == 'Active' ? changeCodeConfigPCR : changeCodeConfigPCA;

			changeCode.name = toUse.Change_Code__c;
			changeCode.reasonCode = toUse.Reason_Code__c;

			if(accountsAndStatus.get(acctToAddCC.Id) == 'Active')
				changeCode.memoText	='Agent has complied to Agency Rules. Cash payment methods are reinstated.';
			else
				changeCode.memoText = 'Agent is restricted from using Cash form of payment method as all amounts Owing are higher than the Remittance Holding Capacity.';

			changeCode.reasonDesc  = toUse.Reason_Code_Description__c;


			if(changeCode.reasonCode == null && accountsChangeCode.get(acctToAddCC.Id) != null){
				changeCode.reasonCode = accountsChangeCode.get(acctToAddCC.Id).Reason_Code__c;
			}

			if(changeCode.reasonDesc == null && accountsChangeCode.get(acctToAddCC.Id) != null){
				changeCode.reasonDesc = accountsChangeCode.get(acctToAddCC.Id).Reason_Description__c;
			}

			changeCode.status  = toUse.Account_status_change__c;

			listOfCCToInsert.add(changeCode);
		}

		if(!listOfCCToInsert.isEmpty())
			AMS_ChangeCodesHelper.createAAChangeCodes(listOfCCToInsert, oscarsToAdd, accountToCreateCC, true);

	}
	*/
}
