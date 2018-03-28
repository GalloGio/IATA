public class ANG_CaseTriggerHandler {

	public List<Case> triggerNew = (List<Case>) Trigger.new;
	public List<Case> triggerOld = (List<Case>) Trigger.old;

	public Map<Id, Case> newMap = (Map<Id,Case>) Trigger.newMap;
	public Map<Id, Case> oldMap = (Map<Id,Case>) Trigger.oldMap;

	// ************************************************************
	// ****************** distribution methods ********************
	// ************************************************************
	
	//public void onBeforeInsert() {}
	public void onAfterInsert() {
		updateFinancialReviewResultOnAccount();
		new ANG_RiskEventGenerator(Trigger.New, Trigger.oldMap).generate();
	}

	//public void onBeforeUpdate() {}
	public void onAfterUpdate() {
		updateFinancialReviewResultOnAccount();
		new ANG_RiskEventGenerator(Trigger.New, Trigger.oldMap).generate();
	}

	//public void onBeforeDelete() {}
	public void onAfterDelete() {}


	private void updateFinancialReviewResultOnAccount(){
		System.debug(loggingLevel.FINE, '____ [cls ANG_CaseTriggerHandler - updateFinancialReviewResultOnAccount]');
		//set filter Informations
		Set<String> saamStatus = new Set<String>{AMS_Utils.CASE_STATUS_CLOSED};
		Set<String> saamReason = new Set<String>{ANG_Risk_Helper.CASE_REASON_ADOC_REVIEW,ANG_Risk_Helper.CASE_REASON_YEARLY_REVIEW};
		String saamArea = ANG_Risk_Helper.CASE_AREA_RISK_MANAGEMENT_PROCESS;

		Set<String> ifapStatus = AMS_Utils.CASE_STATUS_UPDATE_FINANCIAL_REVIEW_SET;

		//filter cases
		Map<Id, List<Case>> casesPerAccount = new Map<Id, List<Case>>();
		for(Case c : triggerNew){
			System.debug(loggingLevel.FINEST, '____ [cls ANG_CaseTriggerHandler - updateFinancialReviewResultOnAccount] Status - ' + c.Status);
			System.debug(loggingLevel.FINEST, '____ [cls ANG_CaseTriggerHandler - updateFinancialReviewResultOnAccount] Reason1__c - ' + c.Reason1__c);
			System.debug(loggingLevel.FINEST, '____ [cls ANG_CaseTriggerHandler - updateFinancialReviewResultOnAccount] CaseArea__c - ' + c.CaseArea__c);
			System.debug(loggingLevel.FINEST, '____ [cls ANG_CaseTriggerHandler - updateFinancialReviewResultOnAccount] is SAAM - ' + (c.RecordTypeId == AMS_Utils.RECTYPE_SAAM));
			System.debug(loggingLevel.FINEST, '____ [cls ANG_CaseTriggerHandler - updateFinancialReviewResultOnAccount] has SAAM Status - ' + saamStatus.contains(c.status));
			System.debug(loggingLevel.FINEST, '____ [cls ANG_CaseTriggerHandler - updateFinancialReviewResultOnAccount] has SAAM Reason - ' + saamReason.contains(c.Reason1__c));
			System.debug(loggingLevel.FINEST, '____ [cls ANG_CaseTriggerHandler - updateFinancialReviewResultOnAccount] has SAAM Area - ' + (c.CaseArea__c == saamArea));
			System.debug(loggingLevel.FINEST, '____ [cls ANG_CaseTriggerHandler - updateFinancialReviewResultOnAccount] is IFAP - ' + (c.RecordTypeId == AMS_Utils.RECTYPE_IFAP));
			System.debug(loggingLevel.FINEST, '____ [cls ANG_CaseTriggerHandler - updateFinancialReviewResultOnAccount] has IFAP status - ' + ifapStatus.contains(c.status));

			if( (Trigger.isInsert || (Trigger.isUpdate && c.Status != oldMap.get(c.Id).Status)) && 
				(
					(c.RecordTypeId == AMS_Utils.RECTYPE_SAAM
					&& saamStatus.contains(c.status)
					&& saamReason.contains(c.Reason1__c)
					&& c.CaseArea__c == saamArea) 
					||
					(c.RecordTypeId == AMS_Utils.RECTYPE_IFAP
					&& ifapStatus.contains(c.status))
				)
			){
				if(!casesPerAccount.containsKey(c.AccountId)) casesPerAccount.put(c.AccountId, new List<Case>());
				casesPerAccount.get(c.AccountId).add(c);

				System.debug(loggingLevel.FINE, '____ [cls ANG_CaseTriggerHandler - updateFinancialReviewResultOnAccount] casesPerAccount - ' + casesPerAccount);
			}
		}

		//if no case matched the filter, no need to continue
		if(casesPerAccount.isEmpty()) return;

		//fetch account data. Legacy agents are handled on the CaseAfterTrigger
		List<Account> ngAccounts = [SELECT Id, Assessment_Performed_Date__c, Financial_Review_Result__c FROM Account WHERE Id IN :casesPerAccount.keySet() AND ANG_IsNewGenAgency__c = true ];


		System.debug(loggingLevel.FINE, '____ [cls ANG_CaseTriggerHandler - updateFinancialReviewResultOnAccount] ngAccounts - ' + ngAccounts);
		if(ngAccounts.isEmpty()) return;
		
		//set information on account
		List<Account> toUpdate = new List<Account>();
		for(Account a : ngAccounts){
			for(Case c : casesPerAccount.get(a.Id)){
				if(a.Financial_Review_Result__c != c.Financial_Review_Result__c){
					a.Financial_Review_Result__c = c.Financial_Review_Result__c;
					a.Assessment_Performed_Date__c = AMS_Utils.getBiggestDate(c.Assessment_Performed_Date__c, a.Assessment_Performed_Date__c);
					toUpdate.add(a);
					ANG_AccountTriggerHandler.isLastFinancialReviewUpgrade = true;
				}
			}
		}
		System.debug(loggingLevel.FINE, '____ [cls ANG_CaseTriggerHandler - updateFinancialReviewResultOnAccount] toUpdate - ' + toUpdate);

		if(!toUpdate.isEmpty()) update toUpdate;
	}
}