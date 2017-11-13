public class ANG_RHCInformationTriggerHandler{

	public final Double UPPERFLUCTUATION = 1;
	public final Double LOWERFLUCTUATION = 2;

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
		new ANG_AgencyEventsGenerator(triggerNew,tempMap,'RHC_Information','ANG_AccountId__c', 'ANG_AccountId__c').run();
	}
	public void onBeforeUpdate(){
		convertAndSumFS();
		sumRHCAmount();
		analyzeConsumedRHCAdjustment();
	}
	public void onAfterUpdate(){
		new ANG_AgencyEventsGenerator(triggerNew,oldMap,'RHC_Information','ANG_AccountId__c', 'ANG_AccountId__c').run();
	}

	public void onBeforeDelete(){}
	public void onAfterDelete(){}

	// ************************************************************
	// ********************* action methods ***********************
	// ************************************************************


	private void convertAndSumFS(){
		set<id> accIdSet = new set<id>();		
		map<id,ANG_RHC_Information__c> accRhcMap = new map<id,ANG_RHC_Information__c>();
		for(ANG_RHC_Information__c rhc:triggerNew){
			accIdSet.add(rhc.ANG_AccountId__c);
			accRhcMap.put(rhc.ANG_AccountId__c,rhc);
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
				)
			){
				rhcToSum.add(rhcInfo);
			}
		}

		if(!rhcToSum.isEmpty()) ANG_RHCHelper.calculateRHCAmount(rhcToSum);
	}

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
			toDeactivateAccounts = ANG_AgencyChangesHelper.extractAllAccounts(toDeactivateAccountsMap);

			toUpdate.addAll(performFOPaction(toDeactivateAccounts,UPPERFLUCTUATION));

		}
		if(!toActivateAccounts.isEmpty()){
			
			Map<Id, List<AMS_Agencies_relationhip__c>> toActivateAccountsMap = AMS_HierarchyHelper.getAccountsHierarchies(toActivateAccounts);		
			toActivateAccounts = ANG_AgencyChangesHelper.extractAllAccounts(toActivateAccountsMap);

			toUpdate.addAll(performFOPaction(toActivateAccounts,LOWERFLUCTUATION));

		}


		if(!toUpdate.isEmpty())
			update toUpdate;

		Set<Id> accountsToCreateFOP = new Set<Id>();

		for(Agency_Authorization__c aa: toUpdate){
			accountsToCreateFOP.add(aa.Account__c);
		}

		if(!accountsToCreateFOP.isEmpty())
			createChangeCodeForFOP(accountsToCreateFOP);


	}

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


	private List<Agency_Authorization__c> performFOPaction(Set<Id> accounts, Decimal action){

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

	public void createChangeCodeForFOP(Set<Id> accountIds) {

		AMS_ChangeCodes__c changeCodeConfigFOP = AMS_ChangeCodesConfigHelper.getChangeCodeConfig('FOP');

		List<Account> accountToCreateCC = [Select Id, Status__c from Account where Id in :accountIds];

		List<AMS_OSCAR_JSON.ChangeCode> listOfCCToInsert = new List<AMS_OSCAR_JSON.ChangeCode>();
		List<AMS_OSCAR__c> oscarsToAdd = new List<AMS_OSCAR__c>();

		For(Account acctToAddCC: accountToCreateCC){

			AMS_OSCAR_JSON.ChangeCode changeCode = new AMS_OSCAR_JSON.ChangeCode();

			changeCode.name = changeCodeConfigFOP.Change_Code__c;
			changeCode.reasonCode = changeCodeConfigFOP.Reason_Code__c;
			changeCode.memoText = changeCodeConfigFOP.Bulletin_Memo_Text__c.replace('due to <SIDRA Lite Reason>.','');
			changeCode.reasonDesc  = changeCodeConfigFOP.Reason_Code_Description__c;
			changeCode.status  = changeCodeConfigFOP.Account_status_change__c;

			listOfCCToInsert.add(changeCode);
		}

		AMS_ChangeCodesHelper.createAAChangeCodes(listOfCCToInsert, oscarsToAdd, accountToCreateCC, true);

	}
}