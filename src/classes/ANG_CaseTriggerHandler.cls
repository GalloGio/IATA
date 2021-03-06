public class ANG_CaseTriggerHandler {

	private static final Set<String> MULTICOUNTRY_CREATE_PROCESS_DETAIL_REVIEW_TYPES = new Set<String>{
		AMS_Utils.FINANCIAL_REVIEW_MULTICOUNTRY_ANNUAL,
		AMS_Utils.FINANCIAL_REVIEW_MULTICOUNTRY_ADHOC
	};

	private static final String CASE_REASON_FINANCIAL_SECURITY_TOKEN = 'Financial Security';

	public List<Case> triggerNew = (List<Case>) Trigger.new;
	public List<Case> triggerOld = (List<Case>) Trigger.old;

	public Map<Id, Case> newMap = (Map<Id,Case>) Trigger.newMap;
	public Map<Id, Case> oldMap = (Map<Id,Case>) Trigger.oldMap;

	// ************************************************************
	// ****************** distribution methods ********************
	// ************************************************************

	public void onBeforeInsert(){
		handleMulticountryCases(triggerNew, oldMap);
	}

	public void onAfterInsert() {
		updateFinancialReviewResultOnAccount();
		handleMulticountryCases(triggerNew, oldMap);
		new ANG_RiskEventGenerator(Trigger.New, Trigger.oldMap).generate();
	}

	public void onBeforeUpdate(){
		handleMulticountryCases(triggerNew, oldMap);
	}

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
			System.debug(loggingLevel.FINEST, '____ [cls ANG_CaseTriggerHandler - updateFinancialReviewResultOnAccount] Financial Review Type - ' + c.Financial_Review_Type__c);
			System.debug(loggingLevel.FINEST, '____ [cls ANG_CaseTriggerHandler - updateFinancialReviewResultOnAccount] Exception Approved On: ' + c.Exception_Approved_on__c);

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
				//Skip updating the financial result on the multicountry account considering the following scenario
				if(AMS_Utils.MULTICOUNTRY_FINANCIAL_REVIEW_TYPES.contains(c.Financial_Review_Type__c) && c.Exception_Approved_on__c != null){
					//A Financial Review is done on a multicountry key hierarchy and an exception is raised to evaluate
					//if the consequences should be applied or not. If the exception is approved,
					//it means that the consequences of the new Financial Assessment result
					//do not need to be applied on the hierarchy and so
					//the new Financial Assessment result will not be copied at all on the account
					System.debug(loggingLevel.FINE, '____ [cls ANG_CaseTriggerHandler - updateFinancialReviewResultOnAccount] Skip case with exception approved: ' + c.CaseNumber);
					continue;
				}

				if(!casesPerAccount.containsKey(c.AccountId)) casesPerAccount.put(c.AccountId, new List<Case>());
				casesPerAccount.get(c.AccountId).add(c);

				System.debug(loggingLevel.FINE, '____ [cls ANG_CaseTriggerHandler - updateFinancialReviewResultOnAccount] casesPerAccount - ' + casesPerAccount);
			}
		}

		//if no case matched the filter, no need to continue
		if(casesPerAccount.isEmpty()) return;

		//fetch account data. Legacy agents are handled on the CaseAfterTrigger
		List<Account> ngAccounts = [SELECT Id, Assessment_Performed_Date__c, Financial_Review_Result__c, Financial_Assessment_Points__c FROM Account WHERE Id IN :casesPerAccount.keySet() AND ANG_IsNewGenAgency__c = true ];


		System.debug(loggingLevel.FINE, '____ [cls ANG_CaseTriggerHandler - updateFinancialReviewResultOnAccount] ngAccounts - ' + ngAccounts);
		if(ngAccounts.isEmpty()) return;

		//set information on account
		List<Account> toUpdate = new List<Account>();
		for(Account a : ngAccounts){
			for(Case c : casesPerAccount.get(a.Id)){
				Boolean updateAcct = false;
				if(a.Financial_Assessment_Points__c != c.Financial_Assessment_Points__c){
					a.Financial_Assessment_Points__c = c.Financial_Assessment_Points__c;
					updateAcct = true;
				}
				if(a.Financial_Review_Result__c != c.Financial_Review_Result__c){
					a.Financial_Review_Result__c = c.Financial_Review_Result__c;
					updateAcct = true;
					ANG_AccountTriggerHandler.isLastFinancialReviewUpgrade = true;
				}
				if(a.Assessment_Performed_Date__c != c.Assessment_Performed_Date__c){
					a.Assessment_Performed_Date__c = AMS_Utils.getBiggestDate(c.Assessment_Performed_Date__c, a.Assessment_Performed_Date__c);
					updateAcct = true;
				}
				if(updateAcct) toUpdate.add(a);
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

		List<Financial_Security__c> financialSecurities = [SELECT Id, Account__c, ANG_isToUpdateRHC__c, ANG_Minimum_Financial_Security__c, ANG_Financial_Security_Currency__c, Security_Status__c, Amount__c FROM Financial_Security__c WHERE Reception_Case__c IN :caseIds AND Security_Status__c IN ('Close to Expiry Date','Active') AND Account__c IN :accsIds AND Account__r.ANG_IsNewGenAgency__c = TRUE];

		System.debug(LoggingLevel.FINE, '____ [cls ANG_CaseTriggerHandler - updateRHCInfoFSMinimumAmount] Financial Securities - ' + financialSecurities);

		if(!financialSecurities.isEmpty()){
			ANG_FinancialSecurityTriggerHandler fsth = new ANG_FinancialSecurityTriggerHandler();
			fsth.updateRHCInfoFSMinimumAmount(accsIds, financialSecurities);
		}

	}

	private static void handleMulticountryCases(List<Case> caseLst, Map<Id,Case> caseOldMap){

		Id financialReviewPdRecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Process_Detail__c', 'Multicountry_Yearly_Financial_Review');

		List<AMS_Process_Detail__c> pdLst = new List<AMS_Process_Detail__c>();
		List<Case> casesToRunFsCurrencyValidationsLst = new List<Case>();

		for(Case cse : caseLst){
			if(cse.RecordTypeId == AMS_Utils.RECTYPE_IFAP && AMS_Utils.MULTICOUNTRY_FINANCIAL_REVIEW_TYPES.contains(cse.Financial_Review_Type__c)){
				if(Trigger.isInsert && Trigger.isAfter && MULTICOUNTRY_CREATE_PROCESS_DETAIL_REVIEW_TYPES.contains(cse.Financial_Review_Type__c)){
					//Only create the Process Detail record for "Multicountry Annual" and "Multicountry Adhoc" financial review types
					pdLst.add(new AMS_Process_Detail__c(Case__c = cse.Id, RecordTypeId = financialReviewPdRecordTypeId));
				}
				if(shouldRunFsCurrencyValidations(cse, caseOldMap)){
					casesToRunFsCurrencyValidationsLst.add(cse);
				}
			}
			else if(cse.RecordTypeId == AMS_Utils.RECTYPE_SAAM && String.isNotBlank(cse.Reason1__c) && cse.Reason1__c.contains(CASE_REASON_FINANCIAL_SECURITY_TOKEN) &&
							cse.Account_Location_Type__c == AMS_Utils.GE && shouldRunFsCurrencyValidations(cse, caseOldMap)){
				casesToRunFsCurrencyValidationsLst.add(cse);
			}
		}

		if(!pdLst.isEmpty()){
			insert pdLst;
		}

		if(!casesToRunFsCurrencyValidationsLst.isEmpty()){
			AMS_Utils.runCurrencyValidations(casesToRunFsCurrencyValidationsLst, 'Financial_Security_Currency__c');
		}

	}

	private static Boolean shouldRunFsCurrencyValidations(Case cse, Map<Id, Case> caseOldMap){

		if(Trigger.isInsert && Trigger.isBefore && String.isNotBlank(cse.Financial_Security_Currency__c)){
			return true;
		}

		if(Trigger.isUpdate && Trigger.isBefore && String.isNotBlank(cse.Financial_Security_Currency__c) &&
			 cse.Financial_Security_Currency__c != caseOldMap.get(cse.Id).Financial_Security_Currency__c){
			return true;
		}

		return false;

	}

}
