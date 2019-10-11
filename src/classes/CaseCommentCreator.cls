global class CaseCommentCreator {

    global class CommentInfo {

        @InvocableVariable(label='Case ID' required=true)
        public string caseId;

        @InvocableVariable(label='Comment Body' required=true)
        public string commentBody;

        @InvocableVariable(required=true)
        public boolean isPublic;
    }
    
    @InvocableMethod(label='Create Case Comment')
    global static void createCaseComment(List<CommentInfo> commentInfos){
    	
        List<CaseComment> caseComments = new List<CaseComment>();

        for(CommentInfo info : commentInfos){
        	
            CaseComment cc 	= new CaseComment();
            cc.CommentBody 	= info.commentBody;
            cc.IsPublished 	= info.isPublic;
            cc.ParentId 	= info.caseId;

            caseComments.add(cc);
            
        }

        insert caseComments;
        
    }
    
}