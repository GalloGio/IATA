public class ANG_RiskEventTriggerHandler {

	public List<ANG_Agency_Risk_Event__c> triggerNew = (List<ANG_Agency_Risk_Event__c>) Trigger.new;
	public List<ANG_Agency_Risk_Event__c> triggerOld = (List<ANG_Agency_Risk_Event__c>) Trigger.old;

	public Map<Id, ANG_Agency_Risk_Event__c> newMap = (Map<Id,ANG_Agency_Risk_Event__c>) Trigger.newMap;
	public Map<Id, ANG_Agency_Risk_Event__c> oldMap = (Map<Id,ANG_Agency_Risk_Event__c>) Trigger.oldMap;

	// ************************************************************
	// ****************** distribution methods ********************
	// ************************************************************

	public void onBeforeInsert(){
		loadInformationsInsert();
	}
	public void onAfterInsert(){
		generateMultiples();
		assessRisk();
	}

	public void onBeforeUpdate(){
		loadInformationsUpdate();
	}
	public void onAfterUpdate(){
		generateMultiples();
		assessRisk();
	}

	public void onBeforeDelete(){}
	public void onAfterDelete(){}

	// ************************************************************
	// ********************* action methods ***********************
	// ************************************************************

	private void loadInformationsInsert() {
		new ANG_RiskEventGenerator(triggerNew).loadInitialInformations();
	}

	private void loadInformationsUpdate() {
		List<ANG_Agency_Risk_Event__c> changedRisks = new List<ANG_Agency_Risk_Event__c>();

		for(ANG_Agency_Risk_Event__c re : triggerNew){
			ANG_Agency_Risk_Event__c oldRe = oldMap.get(re.Id);
			if(
				re.ANG_AccountId__c != oldRe.ANG_AccountId__c
				|| re.ANG_Issued_Date__c != oldRe.ANG_Issued_Date__c
				|| re.ANG_Risk_Type__c != oldRe.ANG_Risk_Type__c
				|| re.ANG_Source_Id__c != oldRe.ANG_Source_Id__c
				|| re.ANG_Event_Status__c != oldRe.ANG_Event_Status__c
			){
				changedRisks.add(re);
			}
		}

		if(!changedRisks.isEmpty()) new ANG_RiskEventGenerator(changedRisks).loadInitialInformations();
	}

	private void generateMultiples(){
		List<ANG_Agency_Risk_Event__c> changedRisks = new List<ANG_Agency_Risk_Event__c>();

		for(ANG_Agency_Risk_Event__c re : triggerNew){
			if(
				re.ANG_TargetAgency__c == 'Selected Accounts' &&
				(Trigger.isInsert || re.ANG_OscarId__c != oldMap.get(re.Id).ANG_OscarId__c)
			){
				changedRisks.add(re);
			}
		}

		if(!changedRisks.isEmpty()) new ANG_RiskEventGenerator(changedRisks).generateMultiples();
	}

	private void assessRisk() {

		Map<Id,Map<Id,Integer>> involvedAccounts = new Map<Id,Map<Id,Integer>>();
		for(ANG_Agency_Risk_Event__c re : triggerNew){

			if(!isEligibleForRiskAssessment(re)) continue;

			if(re.ANG_HE_AccountId__c != null) involvedAccounts.put(re.ANG_HE_AccountId__c,null);

			if(Trigger.isUpdate){
				ANG_Agency_Risk_Event__c oldRe = oldMap.get(re.Id);
				if(re.ANG_HE_AccountId__c != oldRe.ANG_HE_AccountId__c && oldRe.ANG_HE_AccountId__c != null) involvedAccounts.put(oldRe.ANG_HE_AccountId__c,null);
			}
		}

		if(involvedAccounts.isEmpty()) return;

		new ANG_RiskAssessmentEngine(involvedAccounts).assessment();
	}

	private Boolean isEligibleForRiskAssessment(ANG_Agency_Risk_Event__c re){

		if(Trigger.isUpdate){
			ANG_Agency_Risk_Event__c oldRe = oldMap.get(re.Id);
			return (re.ANG_HE_AccountId__c != oldRe.ANG_HE_AccountId__c ||
					re.ANG_Event_Status__c != oldRe.ANG_Event_Status__c ||
					re.ANG_Issued_Date__c != oldRe.ANG_Issued_Date__c ||
					re.ANG_Risk_Type__c != oldRe.ANG_Risk_Type__c ||
					re.ANG_Limit_Cash_Conditions__c != oldRe.ANG_Limit_Cash_Conditions__c);
		}

		return true;

	}
}
