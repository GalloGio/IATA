public without sharing class AutomateCaseCommentToChildCase {

	public static void copyCommentToChilds(List<Id> caseIds){
		if(caseIds.isEmpty()){
			return;
		}

		List<Case> parentCases = [SELECT E2CP__Most_Recent_Public_Comment__c, (SELECT Id FROM Cases) FROM Case WHERE Id IN :caseIds];
		List<CaseComment> newComents = new List<CaseComment>();

		for(Case parentCase : parentCases){
			if(String.isNotBlank(parentCase.E2CP__Most_Recent_Public_Comment__c) && parentCase.cases.size() > 0){
				for(Case c: parentCase.cases){
					newComents.add(
						new CaseComment(
							CommentBody = parentCase.E2CP__Most_Recent_Public_Comment__c,
							ParentId =  c.Id
						)
					);
				}
			}
		}
		insert newComents;
	}
}