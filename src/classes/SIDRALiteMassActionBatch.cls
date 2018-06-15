global class SIDRALiteMassActionBatch implements Database.Batchable<Case>, Database.Stateful {

    public static final Id RECORDTYPE_SIDRA_LITE = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'SIDRA_Lite');

    public DateTime startDate;
    public list<Case> listCase;
    public Id userId;
    public map<Id,WrapperResult> mapResult;

    global SIDRALiteMassActionBatch (list<Case> listCase, Id userId){
        this.startDate = DateTime.now();
        this.listcase = listCase;
        this.userId = userId;
        this.mapResult = new map<Id,WrapperResult>();
    }

    global list<Case> start(Database.BatchableContext BC){
        return this.listCase;
    }

    global void execute(Database.BatchableContext BC, List<Case> scope){
        // Each case is processed separately, stringly recommend to call this batch with 1 element
        for (Case cse: scope) {
            processCase(cse);
        }
    }

    private void processCase(Case cse) {
        try {
            System.debug('**** before upsert '+ cse);
            upsert cse;
            System.debug('**** after upsert '+ cse);
            addCaseToResults(cse, new MyUpsertResult());
            SIDRAliteMassActionController.insertCommentForMassAction(new list<Id>{cse.Id});
            WSSidraLite.insertComments(new list<Case>{cse});

        } catch (Exception e) {
            System.debug('**** EXCEPTION  ' + e.getMessage());
            addCaseToResults(cse, new MyUpsertResult(false, e.getMessage()));

        }
    }

    global void finish(Database.BatchableContext BC){
        AsyncApexJob job = [
            SELECT Id, TotalJobItems, Status, ExtendedStatus, NumberOfErrors, CreatedDate, CompletedDate
            FROM AsyncApexJob
            WHERE Id = :BC.getJobId()];


        // prepare a email with the results
        String subject = 'Results for SIDRA Lite Mass Action on ' + this.startDate.format();
        String message = 'Job information:\n\n';

        message += '\tJob Id: ' + job.Id + '\n';
        message += '\tStatus: ' + job.Status + '\n';
        if (job.ExtendedStatus!=null) {
            message += '\tExtended Status: ' + job.ExtendedStatus + '\n';
        }
        message += '\tNumber of Items: ' + job.TotalJobItems + '\n';
        message += '\tNumber of Errors: ' + job.NumberOfErrors + '\n';
        message += '\tJob started: ' + job.CreatedDate.format() + '\n';
        message += '\tJob completed: ' + job.CompletedDate.format() + '\n';

        message += '\n\n';

        for (WrapperResult wrapper: this.mapResult.values()) {
            message += wrapper.toString() + '\n';
        }
        sendEmailResults(this.userId, subject, message);

    }

    public static void sendEmailResults( id userId, string subject, string message ){
        List<Messaging.SingleEmailMessage> emailsToSend = new List<Messaging.SingleEmailMessage>();

        try{
            system.debug('Try to send message . '+subject+' ******  '+ message);
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            mail.setTargetObjectId(userId);
            mail.setSubject(subject);
            mail.setSaveAsActivity(false);
            mail.setPlainTextBody(message);
            emailsToSend.add(mail);

            if (!Test.isRunningTest() ) Messaging.sendEmail(emailsToSend);

        }catch(Exception  e){
            system.debug('Failed to send email to User ' + userId);
        }
    }

    private void addCaseToResults(Case cse, MyUpsertResult result) {
        System.debug('**** addCaseToResults ' + cse);
        if (cse.RecordtypeId == RECORDTYPE_SIDRA_LITE) {
            System.debug('**** SIDRALITE ');
            Case sidraliteCase = [Select id, CaseNumber, ParentId, Parent.CaseNumber from Case where id = :cse.Id];
            WrapperResult wrapper = this.mapResult.get(sidraliteCase.ParentId);
            System.debug('**** wrapper ' + wrapper);
            if (wrapper==null) {
                wrapper = new WrapperResult();
            }
            wrapper.child = sidraliteCase;
            wrapper.childResult = result;
            this.mapResult.put(sidraliteCase.ParentId, wrapper);

        } else {
            System.debug('**** PARENT ');
            WrapperResult wrapper = this.mapResult.get(cse.Id);
            System.debug('**** wrapper ' + wrapper);
            if (wrapper==null) {
                wrapper = new WrapperResult();
            }
            wrapper.parent = cse;
            wrapper.parentResult = result;
            this.mapResult.put(cse.Id, wrapper);
        }
        System.debug('**** mapResult ' + mapResult);
    }

    public class WrapperResult {
        public Case parent {get; set;}
        public Case child {get; set;}
        public MyUpsertResult parentResult {get;set;}
        public MyUpsertResult childResult {get;set;}

        public override String toString() {
            String out = '';
            // print parent section
            if (parent != null) {
                out += '- Parent case ' + parent.CaseNumber + ' ';
                if (parentResult.IsSuccess ) {
                    out += 'Updated OK\n';
                } else {
                    out += 'Error was found: \n';
                    for ( String error:  parentResult.errors ) {
                        out += '\t\t * ' + error + '\n';
                    }
                }
            }
            // print child section
            if (child != null) {
                if (parent == null) {
                    out += '- Parent case ' + child.Parent.CaseNumber + ' OK\n';
                }
                out += '\tSIDRA Lite case ' + child.CaseNumber + ' ';
                if (childResult.IsSuccess ) {
                    out += 'Updated OK\n';
                } else {
                    out += '\tError was found: \n';
                    for ( String error:  childResult.errors ) {
                        out += '\t\t\t * ' + error + '\n';
                    }
                }
            }
            return out;
        }
    }

    public class MyUpsertResult {
        public Boolean isSuccess {get;set;}
        public list<String> errors {get;set;}

        public MyUpsertResult() {
            this.isSuccess = true;
            this.errors = new list<String>();
        }

        public MyUpsertResult(Boolean isSuccess, String error) {
            this.isSuccess = isSuccess;
            this.errors = new list<String>();
            this.errors.add(error);
        }
    }

}