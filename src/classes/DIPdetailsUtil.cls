public with sharing class DIPdetailsUtil {
	/*
	 * Create the child DIP Details records for the newly created cases with the DIP Review Process RT (called from CaseBeforeInsert trigger)
	 */
	public static void CreateDIPDetailsRecords (Set<Id> setCaseIds) {
		List<DIP_Details__c> lstDIPRecords = new List<DIP_Details__c>();
		for (Id caseId : setCaseIds) {
			DIP_Details__c newDIP = new DIP_Details__c(Case__c = caseId);
			lstDIPRecords.add(newDIP);
		}
		
		try {
			if(!lstDIPRecords.isEmpty())
				insert lstDIPRecords;
		} catch (Exception e) {
			system.debug(e.getMessage());
		}
	}
	
	
	/*
	 * Update the GPO or Legal approvers for a DIP detail if the Approval status has changed as a result of an approval
	 */
	public static void UpdateRecordApprovers (list<DIP_Details__c> TriggerNew, map<Id, DIP_Details__c> mapTriggerOld) {
		for (DIP_Details__c dip : TriggerNew) {
			// the below would represent the outcome of the 1st approval step (GPO Approval)
			if (dip.Approval_Status__c == 'Pending Legal Approval' && mapTriggerOld.get(dip.Id) != null & mapTriggerOld.get(dip.Id).Approval_Status__c != 'Pending Legal Approval') {
				dip.GPO_Approver_Name__c = UserInfo.getUserId();
			}
			
			// the below would represent the outcome of the 2nd approval step (Legal Approval)
			if (dip.Approval_Status__c == 'Pending RM&I Approval' && mapTriggerOld.get(dip.Id) != null & mapTriggerOld.get(dip.Id).Approval_Status__c != 'Pending RM&I Approval') {
				dip.Legal_Approver_Name__c = UserInfo.getUserId();
			}
		}
	}
	
	
}