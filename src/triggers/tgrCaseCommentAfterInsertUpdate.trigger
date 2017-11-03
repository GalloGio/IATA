trigger tgrCaseCommentAfterInsertUpdate on CaseComment (after insert, after update) {

	Set<Id> caseIds = new Set<Id>();
	for (CaseComment caseComment : trigger.new) {

		caseIds.add(caseComment.parentId);
	}

	Map<Id, Case> casesMap = new Map<Id, Case>([Select Id from Case where Id IN :caseIds AND (RecordType.Name = 'Application Change Request (DPC Systems - locked)'
												OR RecordType.Name = 'Application Change Request (DPC System)' OR RecordType.Name = 'Application Change Request (DPC Systems) - ACCA')]);

	List<CaseComment> caseComments = new List<CaseComment>();
	for (CaseComment caseComment : Trigger.new) {

		if (casesMap.keySet().contains(caseComment.ParentId))
			caseComments.add(caseComment);
	}

	if (caseComments.size() > 0)
		clsCaseCommentManager.notifyContacts(caseComments);

	//INC163935 - fix issue with calculation of kpis
	BusinessDays.isAllowedRunTwice = True;

}