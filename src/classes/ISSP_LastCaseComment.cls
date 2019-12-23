public without sharing class ISSP_LastCaseComment {

	public string caseId {get;set;}
	public string caseComment {get{
		list<CaseComment> CaseCommentList  =[Select c.ParentId, c.CreatedDate, c.CommentBody From CaseComment c where ParentId =:caseId order by  CreatedDate DESC limit 1];
		if(CaseCommentList.size()>0){
			return CaseCommentList.get(0).CommentBody;
		}return '';

	}set;}

	public ISSP_LastCaseComment(){
	}


}
