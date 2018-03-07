public class ANG_CaseTriggerHandler {

	public List<Case> triggerNew = (List<Case>) Trigger.new;
	public List<Case> triggerOld = (List<Case>) Trigger.old;

	public Map<Id, Case> newMap = (Map<Id,Case>) Trigger.newMap;
	public Map<Id, Case> oldMap = (Map<Id,Case>) Trigger.oldMap;

	public static final String CASE_CLOSED = 'Closed';

	// ************************************************************
	// ****************** distribution methods ********************
	// ************************************************************
	
	public void onBeforeInsert(){
	}
	public void onAfterInsert() {
		updateFinancialReviewResultOnAccount();
		new ANG_RiskEventGenerator(Trigger.New, Trigger.oldMap).generate();
	}

	public void onBeforeUpdate(){
	}
	public void onAfterUpdate() {
		updateFinancialReviewResultOnAccount();
		new ANG_RiskEventGenerator(Trigger.New, Trigger.oldMap).generate();
	}

	public void onBeforeDelete(){}
	public void onAfterDelete() {}


	private void updateFinancialReviewResultOnAccount(){
		map<id,case> caseMap = new map<id,case>();

		set<string> statusSet=new set<string>{AMS_Utils.CASE_STATUS_CLOSED};
		set<string> caseReasonSet=new set<string>{ANG_Risk_Helper.CASE_REASON_ADOC_REVIEW,ANG_Risk_Helper.CASE_REASON_YEARLY_REVIEW};
		for(case c: triggerNew){
			if(c.recordtypeId == RecordTypeSingleton.getInstance().RtIDsPerDeveloperNamePerObj.get('Case').get('ProcessEuropeSCE') &&
				(Trigger.isInsert||(Trigger.isInsert || (Trigger.isUpdate && c.status != oldMap.get(c.id).status)))
				&& statusSet.contains(c.status)
				&& c.CaseArea__c==ANG_Risk_Helper.CASE_AREA_RISK_MANAGEMENT_PROCESS
				&& caseReasonSet.contains(c.Reason1__c)
				) 
				caseMap.put(c.accountId,c);
		}
		if(caseMap.isEmpty()) return;
		Map<Id, Account> ngAccounts = new Map<Id, Account>([SELECT id, Assessment_Performed_Date__c, Financial_Review_Result__c FROM account WHERE id IN :caseMap.keySet() AND ANG_IsNewGenAgency__c=true AND location_class__c='P']);
		
		list<account> accList = ANG_CaseTriggerHandler.setFinancialReviewResultOnAccount(caseMap.values(),ngAccounts,statusSet).values();

		if(accList.isEmpty()) return;
		update accList;

	}

	public static map<id,account> setFinancialReviewResultOnAccount(list<case> caseList, map<id,account> ngAccounts,set<string> statusSet){
		Map<Id, Case> oldMap = (Map<Id,Case>) Trigger.oldMap;
		map<id,account> accountMap = new map<id,account>();
		for(case c: caseList){
			if(	
				(Trigger.isInsert || (Trigger.isUpdate && c.status != oldMap.get(c.id).status))
				&& ngAccounts.containsKey(c.accountId) 
				&& statusSet.contains(c.status)
				&& ngAccounts.get(c.accountId).Financial_Review_Result__c != c.Financial_Review_Result__c){
					Account account = ngAccounts.get(c.accountId);
					//NEWGEN - adds NG account to be updated
					accountMap.put(c.accountId, new account(
							id =c.accountId,
							Financial_Review_Result__c=c.Financial_Review_Result__c,
							Assessment_Performed_Date__c = AMS_Utils.getBiggestDate(c.Assessment_Performed_Date__c, account.Assessment_Performed_Date__c)
						)
					);
					ANG_AccountTriggerHandler.isLastFinancialReviewUpgrade = true;
			}
		}

		return accountMap;
		
	}
	
}