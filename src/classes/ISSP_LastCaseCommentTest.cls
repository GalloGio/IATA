@isTest
private class ISSP_LastCaseCommentTest {

	@isTest static void testISSP_LastCaseComment() {

		DateTime dt = DateTime.now();

		Case caseObj = new Case();
		insert caseObj;

		/*
		CaseComment comment = new CaseComment(ParentId = caseObj.Id, CommentBody = 'test CaseComment');
		insert comment;

		//force different CreatedDate - Method Test.setCreatedDate() (Spring'16) not working for CaseComment objects (bug) on 11th Aug 2016
		Test.setCreatedDate(comment.Id, dt);
		*/

		CaseComment commentLast = new CaseComment(ParentId = caseObj.Id, CommentBody = 'LAST test CaseComment');
		insert commentLast;

		/*
		//force different CreatedDate - Method Test.setCreatedDate() (Spring'16) not working for CaseComment objects (bug) on 11th Aug 2016
		Test.setCreatedDate(commentLast.Id, dt.addSeconds(5));
		*/

		Test.startTest();

		ISSP_LastCaseComment lastCaseComment = new ISSP_LastCaseComment();
		System.assertEquals('',lastCaseComment.caseComment);

		lastCaseComment.caseId = caseObj.Id;
		System.assertEquals('LAST test CaseComment',lastCaseComment.caseComment);

		Test.stopTest();
	}

}
