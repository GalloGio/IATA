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
		checkMinimumFSChanged(triggerNew, oldMap);
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

	private static void checkMinimumFSChanged(List<Case> triggerNew, Map<Id,Case> oldMap){
		Set<Id> accsIds = new Set<Id>();
		for(Case c : triggerNew){
			if (c.Financial_Security_Amount__c != null && oldMap.get(c.Id).Financial_Security_Amount__c != c.Financial_Security_Amount__c){
				accsIds.add(c.AccountId);			
			}
		}

		if(!accsIds.isEmpty())
			updateRHCInfoFSMinimumAmount(oldMap.keySet(), accsIds); //call method @future
	}

	@future
	private static void updateRHCInfoFSMinimumAmount(Set<Id> caseIds, Set<Id> accsIds){

		List<ANG_RHC_Information__c> rhcInfos = new List<ANG_RHC_Information__c>();

		//List<Financial_Security__c> financialSecurities = [SELECT Id, Account__c FROM Financial_Security__c WHERE Reception_Case__c IN newMap.keySet() AND Security_Status__c IN ('Close to Expiry Date','Active')];
		for(Account a : [SELECT Id, 
							(SELECT Id, Financial_Security_Amount__c FROM Cases WHERE Id IN :caseIds),
							(SELECT Id, Account__c, Release_Case__c FROM Financial_Securities__r WHERE Reception_Case__c IN :caseIds AND Security_Status__c IN ('Close to Expiry Date','Active')), 
							(SELECT Id, ANG_AccountId__c, ANG_Minimum_Financial_Security__c FROM RHC_Informations__r) 
						FROM Account
						WHERE ANG_IsNewGenAgency__c = true AND Id IN :accsIds]){

			if(!a.Financial_Securities__r.isEmpty() && !a.RHC_Informations__r.isEmpty() 
				&& a.Cases[0].Financial_Security_Amount__c != a.RHC_Informations__r[0].ANG_Minimum_Financial_Security__c){

					a.RHC_Informations__r[0].ANG_Minimum_Financial_Security__c = a.Cases[0].Financial_Security_Amount__c;
					rhcInfos.add(a.RHC_Informations__r[0]);													
			}
		}

		if(rhcInfos.isEmpty()) return;

		update rhcInfos;
	}

}