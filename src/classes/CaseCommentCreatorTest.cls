@isTest
private class CaseCommentCreatorTest {

	
    static testMethod void createCaseCommentTest() {
		
		Account acc = new Account();
		acc.Name = 'Airline HQ Example';
		acc.Sector__c = 'Airline';
		acc.Legal_name__c = 'Airline HQ Example LN';
		
		insert acc;
		
		Case cse = new Case();
		cse.AccountId = acc.Id;
		cse.Subject = 'Test Case Comments';
		
		insert cse;
		
		CaseCommentCreator.CommentInfo info_A = new CaseCommentCreator.CommentInfo();
		
		info_A.caseId = cse.Id;
		info_A.commentBody = 'Add case private comment unit test';
		info_A.isPublic = false;

		CaseCommentCreator.CommentInfo info_B = new CaseCommentCreator.CommentInfo();
		
		info_B.caseId = cse.Id;
		info_B.commentBody = 'Add case public comment unit test';
		info_B.isPublic = true;
			        
		List<CaseCommentCreator.CommentInfo> inputCommentsLst = new List<CaseCommentCreator.CommentInfo>();
		
		inputCommentsLst.add(info_A);
		inputCommentsLst.add(info_B);
		
		CaseCommentCreator.createCaseComment(inputCommentsLst);
		
		List<CaseComment> caseCommentsLst = new List<CaseComment>(
			[SELECT
				Id,
				CommentBody,
				IsPublished
			 FROM
			 	CaseComment
			 WHERE
			  	ParentId = :cse.Id
			]
		);
		
		system.assert(caseCommentsLst.size() == 2, 'Expecting two case comments created');
		
    }
    
}