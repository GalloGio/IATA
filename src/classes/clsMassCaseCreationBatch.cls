global class clsMassCaseCreationBatch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts{

    global List<Case> caseList = new List<Case>();
    global List<String> caseContact = new List<String>();
    global Integer nCases;
    global String batchName,status,subject,description,reviewType,/*modeOfAssessment,SLAType*/reuploadStatus,templateNameOverride;
    global Date deadlineDate;
    global String agentsWithOpenCasesReportURL;
    global List<Tracked_Email__c> trackedEmails = new List<Tracked_Email__c>();

    List<String> insertedContacts = new List<String>(); 
    Database.SaveResult[] MySaveResult;

    global List<Case> start(Database.BatchableContext BC){
        return caseList;
    }

    global void execute(Database.BatchableContext BC, List<Case> scope){
        List<String> success = new List<String>();
        try{
            System.debug('begining of execution');
            if(scope.size() > 0){
                System.debug('inserting scope');
                MySaveResult = Database.Insert(scope,false);

                System.debug('database error:: '+ MySaveResult );
                System.debug('scope inserted');
            }

            Set<Id> caseIds = new Set<Id>();
            for(Case c : scope){
                caseIds.add(c.Id);
            }

            for(Case cobj : [Select Id, CaseNumber, IFAP_Country_ISO__c, IFAP_agent_type__c, Contact.email, Contact.Id, EmailTemplate__r.Name, Financial_Review_Type__c from Case where Id in :caseIds]){
                success.add(cObj.CaseNumber + ',' + cObj.Contact.Email + ',' + cObj.Contact.Id + ',' + cObj.EmailTemplate__r.Name);
                insertedContacts.add(cObj.ContactID);
            }

            // this part is dedicated to the mass sending of tracked email (Visualforce email template = IFAP)
            if(status == 'Agent Notified (Tracked Email)'){
                trackedEmails.addAll(SignaturitUtils.createTrackedEmails(scope, 'IFAP', 'IATA Financial Review', 'noreply.ifap@iata.org', 'FA'));
            }
        }
        catch (Exception ex) {
            System.debug('error'+ ex.getMessage());
        }

        finally{
            GetErrorsFromBatch();
            System.debug('** Send Batch Email ');
        }
    }

    global void GetErrorsFromBatch(){
        List<String> errorContacts = new List<String>();
        List<String> error = new List<String>();
        Map<ID,String> ContactAccountInfo = new Map<ID,String>();

        // get error messages and populate the inserted contact list
        for(Database.SaveResult sr:MySaveResult){
            if(!sr.isSuccess()){
                Database.Error err = sr.getErrors()[0];
                error.add(err.getMessage());
            }
        }

        // get uninserted contacts:
        if (insertedContacts.Size()==0){
            errorContacts = caseContact;
        }
        else{
            Set<String> caseContactSet = new Set<String>();
            Set<String> insertedContactsSet = new Set<String>();

            caseContactSet.addAll(caseContact);
            insertedContactsSet.addAll(insertedContacts);

            for (String s: caseContactSet){
                if (!insertedContactsSet.contains(s)){
                    errorContacts.add(s);
                }
            }
        }

        System.debug('** errorContacts Size GetErrorsFromBatch ' + errorContacts.size());

        //get list of Account info
        for (Contact r : [SELECT ID, Account.Name, Account.Id From Contact Where ID IN : errorContacts]) {
            ContactAccountInfo.put(r.ID,'Account: '+  r.Account.Name+' ID: '+r.Account.Id);
        }

        //populate the error message based on error contacts and error messages
        if (error.Size()>0){
            for (Integer k=0; k< error.Size() ; k++){
                String er = '    -    Error : ' + error.get(k);
                BatchError__c BatchError = new BatchError__c(BatchID__c= batchName,ErrorMsg__c=er,AccountInfo__c=ContactAccountInfo.get(errorContacts.get(k)));
                insert BatchError;
            }
        }
    }
    
    global void finish(Database.BatchableContext BC){
        try{         
            System.Debug('**** finish(Database.BatchableContext BC)');

            if(!trackedEmails.isEmpty()){
				Database.executeBatch(new SignaturitCalloutBatch(trackedEmails), 5);
            }

            sendBatchEmail();
        }
        catch(Exception e){
            System.debug('**** ERROR! '+ e);
        }
    }
        
    private void sendBatchEmail(){
        System.debug('** Send Batch Email 2');
		status = 'Agent Notified (Email)';

        List<BatchError__c> batchErrors = [Select BatchID__c,ErrorMsg__c, AccountInfo__c from BatchError__c where BatchID__c =: batchName];

        User currentUser = [Select Id, Email, FirstName, LastName from User where Id =: UserInfo.getUserId() limit 1];

        // build email body
        String htmlEmailBody = '<html><body link=\'blue\' vlink=\'purple\' style=\'font-family:"Calibri","sans-serif";color:#1F497D;\'>Dear ' + currentUser.FirstName + ' ' + currentUser.LastName + ', <br />';
        htmlEmailBody += '<br />';
        htmlEmailBody += 'Here is a summary of the batch that was just launched by your user:<br />';
        htmlEmailBody += '<br />';

        // batch infos
        htmlEmailBody += '<b>Batch Number:</b> ' + batchName + '<br />';
        htmlEmailBody += '<b>Case status (on creation):</b> ' + status + '<br />';
        htmlEmailBody += '<b>Subject:</b> ' + subject + '<br />';
        // htmlEmailBody += '<b>Description:</b> ' + description + '<br />';
        htmlEmailBody += '<b>Review Type:</b> ' + reviewType + '<br />';
        //htmlEmailBody += '<b>Mode of Assessment:</b> ' + modeOfAssessment + '<br />';
        // htmlEmailBody += '<b>SLA Type:</b> ' + SLAType + '<br />';
        htmlEmailBody += '<b>Deadline:</b> ' + deadlineDate + '<br />';
        htmlEmailBody += '<b>Reupload Status: </b> Normal<br />';
        htmlEmailBody += '<b>Initial Request Email template: </b> ' + templateNameOverride + '<br />';
        htmlEmailBody += '<br />';

        // include URL to Agents with Open Cases report
        if (agentsWithOpenCasesReportURL != null && agentsWithOpenCasesReportURL != '') {
            htmlEmailBody +=  'Report for <a href=\'' + URL.getSalesforceBaseUrl().toExternalForm() + agentsWithOpenCasesReportURL + '\'>Agents with Open Cases or Closed Case for same financial year</a><br />';
            htmlEmailBody += '<br />';
        }

        //errors from clsMassCaseCreationBatch
        if (batchErrors.size() > 0){
            htmlEmailBody += 'Case(s) for the following contact(s) could not be created:<br /><br />';
            htmlEmailBody += '<table border=\'0\' cellspacing=\'3px\' style=\'font-family:"Calibri","sans-serif";color:#1F497D; font-size: 10pt;\'>';

            for(BatchError__c b: batchErrors){
                htmlEmailBody += String.format('<tr><td><pre>{0}</pre></td><td> </td><td>{1}</td></tr>', new String[]{b.AccountInfo__c,b.ErrorMsg__c });
            }

            htmlEmailBody += '</table><br/>';
            htmlEmailBody += 'Number of failed cases: '+ batchErrors.size();
        }
        htmlEmailBody += '<br />Best Regards,<br />IFAP SF Administrator</body></html>';

        // build email object
        Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();  
        mail.setSenderDisplayName('IATA Financial Review');  
        mail.setTargetObjectId(currentUser.id);
        mail.setSubject('IFAP - Case Mass Creation confirmation email - Batch Number ' + batchName );
        mail.setHtmlBody(htmlEmailBody);
        mail.saveAsActivity = false;

        // send email if not running test
        //if (!Test.isRunningTest())
        Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail}); 

        System.debug('** Send Batch Email 3');
    }
}