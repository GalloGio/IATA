global class Unbabel_CaseCommentTranslationHandler implements unbabelapi.ITranslationHandler {

    global unbabelapi.UnbabelRestEnvelope execute(unbabelapi.UnbabelRestEnvelope env, unbabelapi__Unbabel_Translation_Request__c tr) {

        try {

            if(!env.isSuccess){
                system.debug( LoggingLevel.Error, '____ [cls Unbabel_CaseCommentTranslationHandler - execute] Envelope Error Message - '  + env.message);
                return env;
            }            

            CaseComment sobj = (CaseComment) env.data;
            publishCaseComment(sobj,tr);

        }
        catch(Exception e) {
            system.debug( LoggingLevel.Error, '____ [cls Unbabel_CaseCommentTranslationHandler - execute] e.getMessage() - ' + e.getMessage());
            return new unbabelapi.UnbabelRestEnvelope(false, e.getMessage());
        }

        return env;

    }

    private static void publishCaseComment(CaseComment ccTranslated, unbabelapi__Unbabel_Translation_Request__c tr){

        system.debug( LoggingLevel.Info,'____ [cls Unbabel_CaseCommentTranslationHandler - publishCaseComment]' );

        CaseComment ccOriginal = [SELECT Id, ParentId, CommentBody,IsPublished FROM CaseComment where Id = :ccTranslated.Id];
        
        ccTranslated = ccTranslated.clone(false,false);

        if(!ccOriginal.IsPublished){
            ccTranslated.IsPublished = true;
            ccTranslated.IsNotificationSelected = true;
            ccOriginal.CommentBody = ccOriginal.CommentBody + '\n # Translated by Unbabel #';

        }else{
            ccTranslated.IsPublished = false;
            ccTranslated.CommentBody = ccTranslated.CommentBody + '\n\n # Translated by Unbabel #';

        }

        ccTranslated.ParentId = ccOriginal.ParentId;
        
        upsert new List<CaseComment>{ ccOriginal};

            // Use DML options to enable email delivery
        Database.DMLOptions dmlOpts = new Database.DMLOptions();
        dmlOpts.EmailHeader.triggerAutoResponseEmail = true;
        dmlOpts.EmailHeader.triggerOtherEmail = true;
        dmlOpts.EmailHeader.triggerUserEmail = true;

        database.insert(ccTranslated, dmlOpts);

    }
}