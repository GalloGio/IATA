global class IfapProcessResultsBatch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful {

    public list<sObject> listObjectsToProcess;
    public List<String> errors;
    public Map<String, IfapToolManager.PWCResponse> IdToXml;
    public List<String> filesToBeDeleted;
    public List<AmazonFile__c> amazonFilesToInsert;
    public map<String,AmazonFile__c> setAmazonFilesToInsert;
    global Map<Id, String> errorMap {get; set;}
    

    public IfapProcessResultsBatch(IfapToolManager.PWCResponses pwcress ) {
        this.errors = new list<String>();
        this.IdToXml = new Map<String, IfapToolManager.PWCResponse>();
        this.filesToBeDeleted = new List<String>();
        this.amazonFilesToInsert = new List<AmazonFile__c>();
        this.setAmazonFilesToInsert = new map<String,AmazonFile__c>(); 
        listObjectsToProcess = processPWCResults(pwcress);
        errorMap = new Map<Id,String>();
    }

    global List<sObject> start(Database.BatchableContext BC){
        return this.listObjectsToProcess;
    }


    global void execute(Database.BatchableContext BC, List<sObject> scope){
        // Since it's not possible to execute an upsert on generic sObject list 
        // I'll split the records to be inserted and the ones to be updated
        try{
            List<sObject> listInserts = new List<sObject>();
            List<sObject> listUpdates = new List<sObject>();

            for(sObject so : scope){
                if(so.Id == null)
                    listInserts.add(so);
                else
                    listUpdates.add(so);
            }
            System.debug('*********** INSERTS ' + listInserts);
            System.debug('*********** UPDATES ' + listUpdates);
 
            TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = true;
            TransformationHelper.CalculateBusinessHoursAges = true;
          //  CaseChildHelper.noValidationsOnTrgCAseIFAP  = true;

            // Do the inserts
            Database.SaveResult[] listInsertResult = Database.insert(listInserts,false);
            for(Database.SaveResult sr : listInsertResult){
                if(sr.isSuccess()){
                    processSaveResults('INSERT', listInserts, listInsertResult);        
                }else{
                    for(Database.Error err : sr.getErrors()){
                        processSaveResults('INSERT', listInserts, listInsertResult);
                        String errMsg = 'ERROR INSERTING - IFAP ID ' + sr.getID() + ' error message ' + err.getMessage();
                        errorMap.put(sr.getId(), errMsg);
                    }
                }
            }
            
            //Do the updates
            Database.SaveResult[] listUpdateResult = Database.update(listUpdates,false);
            for(Database.SaveResult sr : listUpdateResult){
                if(sr.isSuccess()){
                    processSaveResults('UPDATE', listUpdates, listUpdateResult);        
                }
                else{
                    for(Database.Error err : sr.getErrors()){
                        processSaveResults('UPDATE', listUpdates, listUpdateResult);
                        String errMsg = 'ERROR UPDATING - IFAP ID ' + sr.getID() + ' error message ' + err.getMessage();
                        errorMap.put(sr.getId(), errMsg); 
                    }
                }
            }

            TransformationHelper.trgAccountISSP_AfterBeforInsertDeleteUpdateUndelete = false;
            TransformationHelper.CalculateBusinessHoursAges = false;
         //   CaseChildHelper.noValidationsOnTrgCAseIFAP  = false;

            System.debug(LoggingLevel.ERROR, '######################### (IfapProcessResultsBatch) BATCH CICLE FINISHED WITH '+errors.size()+' ERRORS');

        }catch(Exception e){

            TransformationHelper.sendEmailSupport('FATAL: IfapProcessBatch', e.getMessage() + '   ' + e.getStackTraceString());
        }
 
    }

    private void processSaveResults( String label, List<sObject> listObject, Database.SaveResult[] listSaveResult ) {
        System.debug(LoggingLevel.ERROR, '######################### (IfapProcessResultsBatch) BATCH ' + label + ' ' +listSaveResult.size()+' ELEMENTS');
        try{
        for(Integer i=0; i<listObject.size(); i++){
            Database.SaveResult sr = listSaveResult[i];
            sObject so = listObject[i];
            String objType = so.getSObjectType().getDescribe().getName();

            // get case Id from current Object
            String caseId = '';
            if(objType=='Case') {
                caseId = (String)so.get('Id');
            }
            if(objType=='CaseComment') {
                caseId = (String)so.get('ParentId');
            }
            if(objType=='Financial_Assessment_Result__c') {
                caseId = (String)so.get('Case__c');
            }
            if(objType=='IFAP_Quality_Issue__c') {
                caseId = (String)so.get('Related_Case__c');
            }

            if(!sr.isSuccess()){
                System.debug(LoggingLevel.ERROR, '     ----> (IfapProcessResultsBatch) ERROR ON ' + label + ' ' +objType+': '+sr.getErrors()[0]);
                errors.add('[Result File "' + IdToXml.get(caseId).originalFileName + '" ] ERROR on ' + label + ' '+objType+' related to case with ID '+ caseId +': '+sr.getErrors()[0] + '\nXML = '+IdToXml.get(caseId).xml);
            }else if(sr.isSuccess()){
                // if the case was successful add the file to delete
                IfapToolManager.PWCResponse pwcResponse = IdToXml.get(caseId);
                filesToBeDeleted.add(pwcResponse.originalFileName.substring(0,12)+'.zip');
                if(!pwcResponse.originalFileName.contains('.xml')){
                    AmazonFile__c amazonFile = getAmazonFile( pwcResponse.originalFileName, 0, caseId);
                        if ( amazonFile != null ) {
                            this.setAmazonFilesToInsert.put(amazonFile.Full_Name_Unique__c, amazonFile);
                            }
                }
                //  TransformationHelper.sendEmailSupport('SALVATORE DEBUG', 'amazonFile ' + amazonFile);
                system.debug(LoggingLevel.ERROR,'########### can delete file '+pwcResponse.originalFileName);
                System.debug(LoggingLevel.ERROR, '     ----> (IfapProcessResultsBatch) SUCCESS ON ' + label + ' '+objType+': '+so.Id);
            }else{
            
            throw new transformationException('Error during process saveResults the response from PWC is null!!' +' listObject '  + listObject  +   '  sr    '  + sr   +   '  label '   + label);
            
            
            }
        }
          }catch(Exception e){

            TransformationHelper.sendEmailSupport('FATAL in saving the amazonfile record: IfapProcessBatch processSaveResults',' amazonFilesToInsert  '  +amazonFilesToInsert + '  listObject ' + listObject+ e.getMessage() + '   ' + e.getStackTraceString());
        }
    }

    global void finish(Database.BatchableContext BC){
        try{
            deleteResults(filesToBeDeleted);
            //  insert AmazonFile__c objects
            amazonFilesToInsert.addAll( setAmazonFilesToInsert.values());
            Database.SaveResult[] listInsertResult = Database.insert(setAmazonFilesToInsert.values(),false);
                    ///    TransformationHelper.sendEmailSupport('SALVATORE finish',' amazonFile ' + amazonFilesToInsert);
            System.debug(LoggingLevel.ERROR, '######################### (IfapProcessResultsBatch)SALVATORE finish: '+listInsertResult +' ERRORS');
            string amazonFileFail = '';
            for(Database.SaveResult dr :listInsertResult )
                if(!dr.isSuccess()){    
                                    amazonFileFail =+ dr.getErrors()[0].getMessage() + '\r';                    
                                    }
            if(amazonFileFail <> '')TransformationHelper.sendEmailSupport('Finish IfapProcessResultsBatch amazonFileFail', ' amazonFileFail: ' + amazonFileFail);
                                    
            String title = 'Ifap process results batch ';
            IfapProcessScheduler.sendErrorEmail(title, errors);
            System.debug(LoggingLevel.ERROR, '######################### (IfapProcessResultsBatch) BATCH FINISHED: '+errors.size()+' ERRORS');

            //Sending email if something wrong happend
            List<String> supEmails = new List<String>();
             for (SalesforceSupportEmails__c email : SalesforceSupportEmails__c.getAll().values())
                  supEmails.add(email.Support_Email__c);

            if(!errorMap.isEmpty()){
                String body = 'The IfapProcessResultsBatch job has finished\n'
                              + 'There were ' + errorMap.size() + ' erros. Please find error list attached.';

                //Creating CSV file with errors
                String finalstr = 'Id,Error,Errors-XML\n';
                String subject = 'Ifap Process Results Batch Error List';

                for(Id id : errorMap.keySet()){
                    String err = errorMap.get(id);
                    String recordString = '"'+id+'","'+err+'","'+errors+'"\n';
                    finalstr = finalstr + recordString;
                }

                Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();

                Messaging.EmailFileAttachment efa = new Messaging.EmailFileAttachment();
                efa.setFileName('IfapProcessResultsBatchErrors_'+datetime.now()+'.csv');
                efa.setBody(Blob.valueOf(finalstr));

                //Set email parametrs
                email.setSubject(subject);
                email.setToAddresses(supEmails);
                email.setPlainTextBody( body );
                email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa});

                Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});   

            }

        }catch(Exception e){

            TransformationHelper.sendEmailSupport('FATAL finish: IfapProcessResultsBatch ', e.getMessage() + '   ' + e.getStackTraceString());

        }
        //Once the process it's finished we call again to the parent process to start again
        System.enqueueJob(new IfapProcessResultsQueueable());
    }

    private AmazonFile__c getAmazonFile(string filename, Long filesize, String caseId ) {
        try {
            case c = [SELECT ID, CASENUMBER FROM CASE WHERE ID =: caseID];
            AmazonFile__c amazonFile = new AmazonFile__c(
                Name = filename,
                Full_Name_Unique__c ='/IFAP/FinancialResults/'+c.caseNumber+'/'+filename,
                Size_MB__c = filesize* 0.000001, //convert to MB
                Case__c = caseId
            );
            return amazonFile;
        }catch(TransformationException e){

            TransformationHelper.sendEmailSupport('FATAL IfapProcessResultsBatch: IfapProcessResultsBatch', e.getMessage() + '   ' + e.getStackTraceString() );
            return null;
        

        
        } catch ( Exception e) {
            errors.add('[AmazonFile__c "' + filename + '" ] Case Id '+ caseId +' could not insert object AmazonFile__c for filename: ' + filename);
            return null;
        }
    }


    global List<sObject> processPWCResults( IfapToolManager.PWCResponses pwcress ){
System.debug('############ processPWCResults ' + pwcress);
        try{
        
        
                   if(pwcress == null)throw new transformationException('the response from pwc was null check the MFT connection it will be running again in one hour');

            //Getting all the cases
            List<String> casenumbers = new List<String>();
            List<String> qiscasenumbers = new List<String>();

            for(IfapToolManager.PWCResponse pwcres : pwcress.responses){
                casenumbers.add(pwcres.caseNumber);
                qiscasenumbers.add(pwcres.caseNumber);
            }
            Map<String,Case> caseMap = new Map<String,Case>();
            for(Case c : [SELECT CaseNumber, Status, OwnerId, Account.IATA_ISO_Country__r.BSP_Country_free_text__c FROM Case WHERE CaseNumber IN :casenumbers])
                caseMap.put(c.CaseNumber, c);

            //Getting all IFAP Quality issues
            Map<String,IFAP_Quality_Issue__c> qisMap = new Map<String,IFAP_Quality_Issue__c>();
            for(IFAP_Quality_Issue__c qis : [
                    SELECT Id, Name, Related_Case__r.CaseNumber
                    FROM IFAP_Quality_Issue__c 
                    WHERE Related_Case__r.CaseNumber IN :qiscasenumbers
                    AND (Related_Case__r.Status = 'Quality Issue Requested' OR Related_Case__r.Status = 'Submitted')
                    AND Status__c = 'Sent to GFA' 
                    ORDER BY CreatedDate ASC ]){
                qisMap.put(qis.Related_Case__r.CaseNumber, qis);
            }

            List<CaseComment> comments = new List<CaseComment>();
            List<Financial_Assessment_Result__c> assessmentresults = new List<Financial_Assessment_Result__c>();
            List<IFAP_Quality_Issue__c> ifapqis = new List<IFAP_Quality_Issue__c>();

            //For each result elaborate xml and update the case
            for(IfapToolManager.PWCResponse pwcres : pwcress.responses){
System.debug('############ pwcres ' + pwcres);
                IfapXmlParser parser = new IfapXmlParser();
                if(pwcres == null || pwcres.xml == null){

                    TransformationHelper.sendEmailSupport('FATAL processPWCResults: IfapProcessBatch',  '  response not valid xml please check error message  '  +  pwcres);

                }else{

                    XmlStreamReader reader = new XmlStreamReader(pwcres.xml);
                    IfapXmlParser.IfapResult xml = parser.parseIfapResult(reader);
System.debug('############ xml ' + xml);

                    Case theCase = caseMap.get(pwcres.caseNumber);
System.debug('############ theCase ' + theCase);
                    if(theCase==null){
                        errors.add('[Result File "' + pwcres.originalFileName + '" ] Case with CaseNumber '+pwcres.caseNumber+' not found in database.');
                        continue;
                    }

                    IdToXml.put(theCase.Id, pwcres);
                    /**filesToBeDeleted.add(pwcres.originalFileName);**/

                    // Save in the case Financial security data
                    // BEHAVIOUR COPIED FROM Ifap_webservices.FinancialSecurityInfo
                    if(xml.getFinancialSecurity()!=null){
                        if(xml.getFinancialSecurity().getAmount()!=null){
                            theCase.Financial_Security_Amount__c = decimalTryParse(xml.getFinancialSecurity().getAmount());
                        }if(xml.getFinancialSecurity().getCurrency_x()!=null)
                            theCase.Financial_Security_Currency__c = xml.getFinancialSecurity().getCurrency_x();
                    }


                    //Check whether the result contains errors or not
System.debug('############ xml.getError() ' + xml.getError());
                    if(xml.getError()!=null){
                        IfapXmlParser.Error err = xml.getError();

                        // BEHAVIOUR COPIED FROM IFAP_WebService.UpdateAssessmmentResult
System.debug('############ err.getErrorCode() ' + err.getErrorCode());
                        if(err.getErrorCode() == '0'){
System.debug('############ theCase.Status ' + theCase.Status);
                            if (theCase.Status == 'Assessment Cancelled')
                                continue;
System.debug('############ continue ' );
                            Financial_Assessment_Result__c FinRes = new Financial_Assessment_Result__c();
                            FinRes.Case__c = theCase.Id;
                            assessmentresults.add(FinRes);


                            /*
                            if(xml.getFiles()!=null){
                                for(IfapXmlparser.File file : xml.getFiles()){

                                    //ENZ__FTPAttachment__c ftpAttachment = new ENZ__FTPAttachment__c();
                                    //ftpAttachment.Name = file.getFileName();
                                    //ftpAttachment.ENZ__File__c = theCase.CaseNumber + '/' + file.getFileName();
                                    //ftpAttachment.ENZ__LastVersionID__c = 1;
                                    //ftpAttachment.ENZ__ServerProfile__c = 'FinancialResults';

                                    //ftpAttachment.Financial_Assessment_Result__c = FinRes.Id;
                                    //ftpAttachment.OwnerId  = theCase.OwnerId;

                                    //attachments.add(ftpAttachment);

                                    IdToXml.put(ftpAttachment.ENZ__File__c, pwcres.xml);
                                }
                            }
                            */
                            // AP: Assessment Performed Date update fix
                            theCase.Financial_Review_Result__c = xml.getGFAStatus();
                            theCase.Assessment_Performed_Date__c = Date.today();

                            if(theCase.Account.IATA_ISO_Country__r.BSP_Country_free_text__c == 'HK' || theCase.Account.IATA_ISO_Country__r.BSP_Country_free_text__c == 'MO'){

                                if(xml.getFinancialCriteriaTotalScore() == '' || xml.getFinancialCriteriaTotalScore() == null){
                                    errors.add('[Result File "' + pwcres.originalFileName + '" ] Case with CaseNumber '+pwcres.caseNumber+' does not contain information regarding Financial Criteria Score (FinancialCriteriaTotalScore).');
                                    continue;
                                }else{
                                    theCase.Financial_Assessment_Points__c = decimalTryParse(xml.getFinancialCriteriaTotalScore());
                                }
                            }

                            // FT: IFAP 4 enhancement if we are receiving a reply from a quality issue, we must set the Quality issue approved date
                            //also when case is going from Submitted to Assessment Performed and there is a Quality Issue
                            if (theCase.Status == 'Quality Issue Requested' || theCase.Status == 'Submitted') {
System.debug('############ theCase.Status ' + theCase.Status);
                                IFAP_Quality_Issue__c qi = qisMap.get(theCase.CaseNumber);
                                if(qi!=null){
                                    theCase.Quality_Issue_performed_on__c = datetime.Now();
                                    qi.QI_Reassessment_performed_on__c = datetime.now();
                                    ifapqis.add(qi);
                                }
                            }

                            if (theCase.Status != 'Closed') {
                                theCase.Status = 'Assessment Performed';
                            }

                            // BEHAVIOUR COPIED FROM IFAP_WebService.UpdateCaseToRejected 
                        }else{

                            theCase.Status = 'Sanity Check Failure';
                            theCase.SCF_Reason_IFAP__c = err.getErrorMessage();

                            if (err.getErrorCode()== '1')
                                theCase.Reason_of_rejection_IFAP__c = 'Assessment rejected';
                            else if (err.getErrorCode() == '2')
                                theCase.Reason_of_rejection_IFAP__c = 'Missing required file';
                            else if (err.getErrorCode() == '3')
                                theCase.Reason_of_rejection_IFAP__c = 'Corrupt file';
                            else
                                theCase.Reason_of_rejection_IFAP__c = '';


                            CaseComment comment = new CaseComment();

                            comment.CommentBody = xml.getError().getErrorMessage();
                            comment.ParentId = theCase.Id;
                            comments.add(comment);

                        }

                    }
System.debug('############ theCase.Status final ' + theCase.Status);
                }
            }

            List<sObject> everything = new List<sObject>();
            everything.addAll((List<sObject>) caseMap.values());
            everything.addAll((List<sObject>) comments);
            everything.addAll((List<sObject>) assessmentresults);
            //everything.addAll((List<sObject>) attachments);
            everything.addAll((List<sObject>) ifapqis);

            return everything;

        }catch(Exception e){

            TransformationHelper.sendEmailSupport('FATAL processPWCResults: IfapProcessBatch', e.getMessage() + '   ' + e.getStackTraceString() +  '  resp  '  +  pwcress);
            return null;
        }

    }
    
    
    private static Decimal decimalTryParse(string value) {
        try{
            return decimal.valueOf(value);
        } catch ( Exception e ) {
            return 0.0;
        }
    }
    
    public static void deleteResults( List<String> filesToBeDeleted ) {
        String json = '{"filenames" : [';
        for(integer i=0; i<filesToBeDeleted.size(); i++)
            json += (i==0?'':', ') + '"'+filesToBeDeleted[i]+'"';
        json += '] }';

        system.debug(LoggingLevel.INFO,'########################## WEB SERVICE CALL TO DELETE RESULTS. json: '+json);
        IfapToolManager.submitPWCResultDeletions(json);
    }

}