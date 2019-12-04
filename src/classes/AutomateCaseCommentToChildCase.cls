public without sharing class AutomateCaseCommentToChildCase {

	/* This function is meant to be called from a process (from process builder) and is supposed to receive a list with only 1 case */
	@InvocableMethod(label='Copy comment to child cases' description='Copy a case coment to his child cases')
	public static List<Boolean> copyCommentToChilds(List<Id> caseIds){
		if(caseIds.size() != 1){
			return new List<Boolean>{false};
		}

		Case parentCase = [SELECT E2CP__Most_Recent_Public_Comment__c, (SELECT Id FROM Cases) FROM Case WHERE Id = :caseIds.get(0)];
		//List<Case> cases  = [SELECT Id FROM Case WHERE ParentId = :caseIds.get(0)];

		if(parentCase.E2CP__Most_Recent_Public_Comment__c != null && parentCase.E2CP__Most_Recent_Public_Comment__c != '' && parentCase.cases.size() > 0){
			List<CaseComment> newComents = new List<CaseComment>();
			for(Case c: parentCase.cases){
				newComents.add(
					new CaseComment(
						CommentBody = parentCase.E2CP__Most_Recent_Public_Comment__c,
						ParentId =  c.Id
					)
				);
			}
			try {
				insert newComents;
			} catch (Exception e) {
				return new List<Boolean>{false};
			}
			return new List<Boolean>{true};
		}
		return new List<Boolean>{false};
	}
}
