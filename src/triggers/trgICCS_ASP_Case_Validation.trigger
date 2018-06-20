/*
 * @author: Constantin BUZDUGA, blue-infinity
 * @description: This trigger only handles ICCS Cases with the "FDS ASP Management" record type and is used to ensure that:
 *		- there is only one open ASP case with the "FDS - Create ... " case area for any given account at any given time;
 *		- no ASP case can be closed unless all related tasks are closed (completed)
 * Since Oct 2015:
 * 		- this trigger ensures that there is no more than one open "Airline Coding Application" case per account at the same time  
 */
 
trigger trgICCS_ASP_Case_Validation on Case (before insert, before update) {
	Id RT_ICCS_ASP_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'FDS_ASP_Management');
	ID AirlineCodingRTId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Airline_Coding_Application');
	
	// get a list of the Ids of all the Accounts linked to the Trigger cases
	list<Id> lstRelatedAccountIds = new list<Id>();
	// get a list of the Ids of the ASP cases getting closed
	set<Id> lstClosingCasesIds = new set<Id>();
	
	for (Case c : Trigger.new) {
		if ((c.RecordTypeId == RT_ICCS_ASP_Id  &&  c.CaseArea__c == 'FDS - Create Authorized Signatories Package') ||
			c.RecordTypeId == AirlineCodingRTId ) {
			
			lstRelatedAccountIds.add(c.AccountId);
		}
		if ( c.RecordTypeId == RT_ICCS_ASP_Id  &&  c.Status == 'Closed'  &&  !Trigger.oldMap.get(c.Id).isClosed && c.AccountId != null ) {
			lstClosingCasesIds.add(c.Id);
		}
	}
	
	// only continue if there are related accounts
	set<Id> setRelatedAcctIds = new set<Id>();
	setRelatedAcctIds.addAll(lstRelatedAccountIds);
	
	// get a map of relevant cases per Account Id
	Map<Id, Case> mapCasesPerAccountId = new Map<Id, Case>(); // for ICCS ASP
	Map<Id, list<Case>> mapACCasesPerAccountId = new Map<Id, list<Case>>(); // for Airline coding, new from Oct 2015
	
	for (Case c : [SELECT Id, Subject, RecordTypeId, AccountId, IsClosed, CaseArea__c, Reason1__c FROM Case WHERE (RecordTypeId = :RT_ICCS_ASP_Id OR RecordTypeId = :AirlineCodingRTId) AND IsClosed = false AND AccountId IN :setRelatedAcctIds]) {
		if (c.RecordTypeId == RT_ICCS_ASP_Id) { 
			mapCasesPerAccountId.put(c.AccountId, c);
		}
		
		if (c.RecordTypeId == AirlineCodingRTId  ) {
			list<Case> listCase = mapACCasesPerAccountId.get(c.AccountId);
			if (listCase == null) {
				listCase = new list<Case>();
			}
			listCase.add(c);
			mapACCasesPerAccountId.put(c.AccountId, listCase);
		}
	}
	
	// Validate one single ASP creation case OR one single 
	// only continue if there are new ASP creation cases
	system.debug(LoggingLevel.ERROR,'aqui lstRelatedAccountIds ' + lstRelatedAccountIds);
	if (!lstRelatedAccountIds.isEmpty()) {
	
		for (Case c : Trigger.new) {
			// if there's already an open case on the same account, get it
			Case existingASPCase = mapCasesPerAccountId.get(c.AccountId); 
			
			// if the case is an ASP case and there already is an open ASP case on the same Account, raise an error
			if ( c.RecordTypeId == RT_ICCS_ASP_Id  &&  c.CaseArea__c == 'FDS - Create Authorized Signatories Package'  &&  
				 existingASPCase != null && existingASPCase.CaseArea__c == 'FDS - Create Authorized Signatories Package'  &&  
				 existingASPCase.Id != c.Id) {
				 	
				c.addError('There is already an open FDS ASP creation case on the selected Account. There can be only one open case of this type on an Account.');
			}
			
			// New from Oct 2015: if there's already another Airline Coding case open, raise an error
			// Mod from 2016/04/05: this restriction is only when the case has the same Reason1__c
			if (c.RecordTypeId == AirlineCodingRTId && mapACCasesPerAccountId.get(c.AccountId) != null) {
				for (Case cse: mapACCasesPerAccountId.get(c.AccountId) ) {
					if (cse.Reason1__c == c.Reason1__c && cse.Id != c.Id) {
						c.addError('There is already an open Airline Coding Application case with Reason "' + c.Reason1__c + '" on the selected Account. There can be only one open case of this type on an Account.');
					}
				}
			}
		}
	}
	
	// Prevent the closing of the ASP cases if there are related tasks still open
	// only continue if there are ASP cases getting closed
	system.debug(LoggingLevel.ERROR, + 'lstClosingCasesIds  ' + lstClosingCasesIds);
	if (! lstClosingCasesIds.isEmpty()) {
		//create a map of open tasks related to the cases
    	Map<Id, Task> mapTasksPerCaseId = new Map<Id, Task>();
    	
    	for(Task t : [SELECT Id, WhatId FROM Task WHERE IsClosed = false AND WhatId IN :lstClosingCasesIds]){
    		mapTasksPerCaseId.put(t.WhatId, t);
		}
    	
		for (Case c : Trigger.new) {
			// if the case is being closed and there is a related open task, raise an error and don't allow the ASP case to be closed
			if (lstClosingCasesIds.contains(c.Id) && mapTasksPerCaseId.get(c.Id) != null) {
				c.addError('You cannot close this case because there is at least one Task related to it that is still open.\nPlease mark all related Tasks as Complete and then try again to close the case.');
			}
		}
	}
	
	///////////////////////////////// TEMPORARILY DEACTIVATED 22.04.2015
	// Implement a new VR for certain types of cases (non-ICCS)
	//CaseChildHelper.ValidateCSRCases(Trigger.new);
	
}