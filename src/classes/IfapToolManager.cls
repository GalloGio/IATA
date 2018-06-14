global class IfapToolManager {

    public  static final string IFAPCONFIGARATIONNAME = 'IFAP';
    public static String testJsonResults;
    public static  integer BATCHSIZEFROMFT = Integer.ValueOf(UtilityCS__c.getInstance('ifapBatchSize').value__c);//ifapBatchsize();

    private static void fillCS(){
        if(test.IsRunningTest()){
        Amazon_Cred__c am = new Amazon_Cred__c(name = 'endpoint',Dev_Configuration__c = 'aDev',Prod_Configuration__c = 'aprod');
        insert am;
        }
    }

    /**
        Call to IfapToolManager to start merging PDF files into a single one
         beginMergeAllPDFForCase(System.Continuation continuation,String confName,String caseNumber,String mergedFileName) {
    **/
    public static AsyncWSToolmasterIfap.mergeAndSubmitParametersResponse_elementFuture startMergeAllPDFForCase( Continuation cont,string caseNumber, String outputFileName,String xmlString ) {
        try {
          fillCS();
            AsyncWSToolmasterIfap.AsyncIfapToolMaster app = new AsyncWSToolmasterIfap.AsyncIfapToolMaster();
            
            AsyncWSToolmasterIfap.mergeAndSubmitParametersResponse_elementFuture futureElement = null;
            if ( !Test.isRunningTest()) 
                futureElement = app.beginMergeAndSubmitParameters( cont,AmazonCredentials.getCredentials(IFAPCONFIGARATIONNAME).IAS_configurationName, caseNumber, outputFileName, xmlString);
            return futureElement;// new Response(result);
        }catch ( Exception e ) {
            transformationHelper.sendEmailSupport('Error IFAPtoolManager',e.getMessage() + ' '+ e.getStackTraceString() +  '  '  + e.getMessage());
            //throw new transformationException(e.getTypeName() + ' ' +e.getCause() + 'Error: please contact an Administrator ' +e.getMessage() + ' '+ e.getStackTraceString()+ '  Continuation ' + cont +  ' ' + caseNumber +  ' ' +
            // outputFileName+  ' ' +xmlString  );
            return null;
        
        }
    }

    public static Response mergeAndSubmitParameters( String caseNumber, String mergedFileName, String xmlString) {
        try {
                   fillCS();

            WSToolmasterIfap.IfapToolMaster app = new WSToolmasterIfap.IfapToolMaster();
            String result = Test.isRunningTest()?
                testJsonResults:
                app.mergeAndSubmitParameters(AmazonCredentials.getCredentials(IFAPCONFIGARATIONNAME).IAS_configurationName, caseNumber, mergedFileName, xmlString);
            return new Response(result);
        }catch ( Exception e ) {
            return new Response(e);
        }
    }


//         public String submitCaseQualityIssuesToMFT(String confName,String caseNumber,String xmlFilName,String xmlString) {
    public static Response submitCaseQualityIssuesToMFT( String caseNumber, String XmlFilename, String xmlString) {
                //   transformationHelper.sendEmailSupport('submitCaseQualityIssuesToMFT IFAPtoolManager',caseNumber + ' '+ XmlFilename +  '  ' +xmlString );

        try {
                   fillCS();

            WSToolmasterIfap.IfapToolMaster app = new WSToolmasterIfap.IfapToolMaster();
            String result = Test.isRunningTest()?
                testJsonResults:
                app.submitCaseQualityIssuesToMFT(AmazonCredentials.getCredentials(IFAPCONFIGARATIONNAME).IAS_configurationName, caseNumber, XmlFilename, xmlString);
            return new Response(result);
        }catch ( Exception e ) {
            transformationHelper.sendEmailSupport('submitCaseQualityIssuesToMFT IFAPtoolManager',e.getStackTraceString() + e.getMessage() + ' '+caseNumber + ' '+ XmlFilename +  '  ' +xmlString);

            return new Response(e);
        }
    }



//        public String submitCaseCancellationToMFT(String confName,String caseNumber,String xmlFilName,String xmlString) {
    public static Response submitCaseCancellationToMFT( String caseNumber, String XmlFilename, String xmlString) {
        try {
                  fillCS();

         //  transformationHelper.sendEmailSupport('submitCaseCancellationToMFT IFAPtoolManager',caseNumber + ' '+ XmlFilename +  '  ' +xmlString );

            WSToolmasterIfap.IfapToolMaster app = new WSToolmasterIfap.IfapToolMaster();
            String result = Test.isRunningTest()?
                testJsonResults:
                app.submitCaseCancellationToMFT(AmazonCredentials.getCredentials(IFAPCONFIGARATIONNAME).IAS_configurationName, caseNumber, XmlFilename, xmlString);
            return new Response(result);
        }catch ( Exception e ) {
            return new Response(e);
        }
    }

    public static PWCResponses processPWCResults() {
                               
                               
            try {
                       fillCS();

                WSToolmasterIfap.IfapToolMaster app = new WSToolmasterIfap.IfapToolMaster();
                String result = Test.isRunningTest() ? 
                                    testJsonResults : 
                                    app.processPWCResults(AmazonCredentials.getCredentials(IFAPCONFIGARATIONNAME).IAS_configurationName,BATCHSIZEFROMFT);
                PWCResponses r = (PWCResponses) JSON.deserialize(result, PWCResponses.class);
                r.success = true;
                System.debug(LoggingLevel.ERROR, '################# (WS) PWC RESULT RESTITUISCE '+result);
                System.debug(LoggingLevel.ERROR, '################# (WS) DOPO IL PARSER '+r);
                return r;
    
            }catch ( Exception e ) {
                return new PWCResponses(e);
            }
    }
    
    
    public static String testJsonRejections;
    public static PWCResponses processPWCRejections(){
        try {
                  fillCS();

            WSToolmasterIfap.IfapToolMaster app = new WSToolmasterIfap.IfapToolMaster();
            
            String result = Test.isRunningTest() ? 
                                testJsonRejections :
                                app.processPWCRejections(AmazonCredentials.getCredentials(IFAPCONFIGARATIONNAME).IAS_configurationName,BATCHSIZEFROMFT);
            PWCResponses r = (PWCResponses) JSON.deserialize(result, PWCResponses.class);
            r.success = true;
            System.debug(LoggingLevel.ERROR, '################# (WS) PWC REJECTION RESTITUISCE '+result);
            System.debug(LoggingLevel.ERROR, '################# (WS) DOPO IL PARSER '+r);
                
             transformationHelper.sendEmailSupport('salvo 1 submitCaseQualityIssuesToMFT IFAPtoolManager',r + '    ' + result);
           
            return r;   
            
        }catch ( Exception e ) {


            transformationHelper.sendEmailSupport('salvo  2 submitCaseQualityIssuesToMFT IFAPtoolManager',e.getStackTraceString() + e.getMessage() );

            System.debug('**** ERROR ' + e.getMessage());
            return new PWCResponses(e);
        }
    }
    
    
    public static String submitPWCResultDeletions(String json){
        try{
                  fillCS();

            WSToolmasterIfap.IfapToolMaster app = new WSToolmasterIfap.IfapToolMaster();
            
            String result = Test.isRunningTest() ? 
                            testJsonResults : 
                            app.deletePWCResults(AmazonCredentials.getCredentials(IFAPCONFIGARATIONNAME).IAS_configurationName,json);
        
            return result;
        }catch(Exception e){
            return 'ERROR: '+e.getMessage();
        }
        
    }

    public static String submitPWCRejectionDeletions(String json){
        try{
                   fillCS();

            WSToolmasterIfap.IfapToolMaster app = new WSToolmasterIfap.IfapToolMaster();
            
            String result = Test.isRunningTest() ? 
                            testJsonResults : 
                            app.deletePWCRejections(AmazonCredentials.getCredentials(IFAPCONFIGARATIONNAME).IAS_configurationName,json);
        
            return result;
        }catch(Exception e){
            return 'ERROR: '+e.getMessage();
        }
        
    }

    /**
        Class to store a function response
        Parse input string as Json. Example:
            {"success":"0","code":"CONF_FILE_NOT_FOUND","message":"Configuration file[fakeFile.ini] not found","response":"to what?"}
    **/
    public class Response {
        public Boolean success{get;set;}
        public String code{get;set;}
        public String message{get;set;}
        public String response{get;set;}

        public Response(String jsonString) {
            success = false;
            JSONParser parser = JSON.createParser(jsonString);
            while (parser.nextToken() != null) {
                if ((parser.getCurrentToken() == JSONToken.FIELD_NAME)){
                    String fieldName = parser.getText();
                    parser.nextToken();
                    if (parser == null) {

                    } else if(fieldName == 'success') {
                        success = parser.getBooleanValue();
                    } else if(fieldName == 'code'){
                        code = parser.getText();
                    } else if(fieldName == 'message'){
                        message = parser.getText();
                    } else if(fieldName == 'response'){
                        response = parser.getText();
                    }
                }
            }
        }

        public Response( Exception e) {
            success = false;
            code = 'IFAP Tool Error'; // to do remove the second part here
            message = e.getMessage(); //+ e.getStackTraceString();
        }

        public override String toString() {
            if (success) {
                return 'SUCCESS '  + response;
            }
            return 'ERROR [' + code + '] ' + message;
        }

    }

            
    /**
        Class to store a function response
        Parse input string as Json. Example:
    **/ 



            global class PWCResponse{
                               
                              public Boolean success{get;set;}
                              public string caseNumber {get;set;}
                              public string originalFileName {get;set;}
                              public string xml{get;set;}
                              public string message {get;set;}                              
                                                              
                  }



        global class PWCResponses {
            
                public list<PWCResponse> responses {get;set;}
                public string ErrorMessage {get;set;}
                public Boolean success {get; set;}
                
                public  PWCResponses(Exception e){
                    this.success = false;
                    ErrorMessage = e.getMessage();
                }
                
                
             }

 

    
     WebService static String UpdateCaseStatusToAssessmentCancelledNew(String caseId) {
        
        Case theCase;
        String caseStatus = '';
        try {
            
             theCase = [Select c.Id, c.Status, c.Account.Status__c, c.caseNumber, c.Account.Location_Type__c from Case c where c.Id = :caseId limit 1];
            
             // get the user ids authorized to close cases from any status
             List<IFAP_Close_IFAP_from_any_status__c> userIds = IFAP_Close_IFAP_from_any_status__c.getAll().values();
            
             // users authorized to close cases from any status
             set<string> authorizedUserIds = new set<string>();
            
            	for(IFAP_Close_IFAP_from_any_status__c i : userIds) authorizedUserIds.add(i.UserID__c);
            
                    if(!authorizedUserIds.contains(UserInfo.getUserId())){
                
                
                    if (theCase.Status <> 'Submitted' && theCase.Account.Location_Type__c != 'BR')
                    return 'The case cannot be cancelled when the status is not Submitted';
                    
                    set<string> statusesOfTheAgent = new set<string>{'Terminated','No longer a customer','Not accreditated'};
                    if(!statusesOfTheAgent.contains(theCase.Account.Status__c) && theCase.Account.Location_Type__c != 'BR')
                    return 'The case cannot be cancelled : valid agent';
                    
                }
                string FOLDER = 'IFAP/FinancialDocuments/'+ theCase.CaseNumber;
                
                list<AmazonRest.S3File> tmpList = AmazonRest.getListFiles(FOLDER,AmazonCredentials.getCredentials(IFAPCONFIGARATIONNAME));
                list<AmazonRest.S3File> listFile = new list<AmazonRest.S3File>();
                string name= '';
                for(AmazonRest.S3File file : tmpList ){
                     name = file.getname();
                   if(name <> ''  &&   name.substring(name.length()-3,name.length()) <> 'xml')
                     listFile.add(file);
                     name = '';
                    }        
                              
                string nameTmp = listFile[0].getName();
                if(nameTmp.length() < 13){if(!(Test.isRunningTest() && theCase.Account.status__c == 'No longer a customer')) throw new TransformationException('Submitted documents by the agent: wrong filename case not submitted');}
                string xmlName =!Test.isRunningTest() ? nameTmp.subString(0,12)+'.xml' : '123456789012';
                IfapXmlGenerator.FinancialDocument doc =  new IfapXmlGenerator.FinancialDocument(
                                                                                                   new IfapXmlGenerator.Casexml(theCase.CaseNumber),
                                                                                                   new IfapXmlGenerator.FileXml(''),
                                                                                                   new IfapXmlGenerator.ReviewType('Cancelled'),
                                                                                                   new IfapXmlGenerator.SubmittedDate(Date.Today())
                                                                                                   );
                string xml = doc.getXml();
                
                IfapToolManager.Response response =IfapToolManager.submitCaseCancellationToMFT( 
                                                            theCase.caseNumber,
                                                            xmlName, 
                                                            xml
                                                            );
                //throw new transformationException('' +response);
                if(!response.success)throw new transformationException('Error in the comunication to the financial institution: ' + response.message );
                
                
                CaseChildHelper.noValidationsOnTrgCAseIFAP = true;
                theCase.Status = 'Assessment Cancelled'; // sv now we can close it directly no need to cancel it
                //theCase.IsComplaint__c = true;
                
                
              //  throw new transformationException('we got here!' +theCase);
                theCase.Assessment_Cancelled_On__c = datetime.now(); // we could even get rid of  this useless field
                update theCase;
                caseStatus = theCase.Status;

   
                 
        } catch (TransformationException e) {
        //  throw new TransformationException(e.getMessage()+' ' +e.getstackTraceString());
            return e.getMessage()  ;
        
       } catch (Exception e) {
            
            TransformationHelper.sendEmailSupport('MEDIUM: IFAP Cancel Assessement ' + caseId + '  ' +theCase.caseNumber ,'STACKTRACE   ' + e.getStackTraceString()  + '  '  + e.getMessage());
            
                     throw new TransformationException('Error : ' +e.getMessage() + '  ' + e.getstackTraceString());
        }
        return ('Please refresh the page to see the new status: Closed');
    }
    
    
@Future(callout=true)  
 public static void submitCaseQualityIssuesToMFT(list<id> qualityIssueId){

    try{
        if(qualityIssueId == null|| qualityIssueId.size()== 0  ) return;
        if(qualityIssueId.size()> 100 ){
        
                    transformationHelper.sendEmailSupport('Error IFAPtoolManager,submitCaseQualityIssuesToMFT @future  ' ,
                    'The following quality Issues couldnt be submitted as they were more than 100 please proceed manually '+  qualityIssueId);
                    return;
        } 

        map<Id,IFAP_Quality_Issue__c> ifapQualityIssuePerId = new map<Id,IFAP_Quality_Issue__c>(
                                                                [
                                                                SELECT  
                                                                        Id,
                                                                        Financials_not_audited_certified__c,
                                                                        Assessment_using_wrong_template__c,
                                                                        Challenge_Source__c,
                                                                        Formatting_Issue_details__c,
                                                                        Incorrect_sales_used_for_the_assessment__c,
                                                                        Incorrect_sanity_check_failure__c,
                                                                        Missing_value_in_fields__c,
                                                                        Need_to_update_the_template_instructions__c,
                                                                        Other__c,
                                                                        Other_Issue_details__c,
                                                                        Parent_company_accounts_not_reviewed__c,
                                                                        Output_is_empty_not_completed_has_errors__c,
                                                                        Reassessment_Rejection_Reason__c,
                                                                        QI_Raised_On__c,
                                                                        QI_Reassessment_performed_on__c,
                                                                        QI_Rejected_on__c,
                                                                        Related_Case__c,
                                                                        Related_Case__r.caseNumber,
                                                                        Related_Case__r.Account.IATACode__c,
                                                                        Approved_Date__c,
                                                                        Status__c,
                                                                        Template_working_properly__c,
                                                                        The_printout_of_the_result_is_unreadable__c,
                                                                        Wrong_figure_was_extracted__c,
                                                                        Wrong_financial_year__c
                                                                FROM IFAP_Quality_Issue__c 
                                                                WHERE id in: qualityIssueId 
                                                                ]);
        
        
        
        map<id,list<IFAP_Reassessment_Accounting_Issue__c>> reassAccIssuePerCaseID = new map<id,list<IFAP_Reassessment_Accounting_Issue__c>>();
        System.debug('Total Number of SOQL Queries allowed in this apex code context: ' +  Limits.getQueries());
        for(IFAP_Reassessment_Accounting_Issue__c accIssue: [SELECT Id,Comment__c,Field_Name__c,
                                                                    IFAP_Reassessment__c,Value_to_use__c,Wrong_value__c 
                                                            FROM IFAP_Reassessment_Accounting_Issue__c
                                                            WHERE IFAP_Reassessment__c in:qualityIssueId]){
                                                                
                    if(reassAccIssuePerCaseID.get(accIssue.IFAP_Reassessment__c)==null)                                             
                            reassAccIssuePerCaseID.put(accIssue.IFAP_Reassessment__c, new list<IFAP_Reassessment_Accounting_Issue__c>());
                    reassAccIssuePerCaseID.get(accIssue.IFAP_Reassessment__c).add(accIssue);                                        
                                                                }
        map<id,IfapToolManager.Response> ResponsePerQIssueId = new map<id,IfapToolManager.Response>();
        for(Id qIssueId: ifapQualityIssuePerId.keyset()){
            
                string caseNumber = ifapQualityIssuePerId.get(qIssueId).Related_Case__r.caseNumber;
                if(ifapQualityIssuePerId.get(qIssueId).Related_Case__r.Account == null || ifapQualityIssuePerId.get(qIssueId).Related_Case__r.Account.IATACode__c == null )
                 throw new TransformationException('Agent code not valid  ' +qIssueId);
                string XmlFilename = ifapQualityIssuePerId.get(qIssueId).Related_Case__r.Account.IATACode__c.substring(0,7)+'_'+ifapQualityIssuePerId.get(qIssueId).Related_Case__r.caseNumber+'.xml';
                String xmlString = new IfapXmlGenerator.QualityIssue(
                                                                     new IfapXmlGenerator.Casexml(caseNumber),
                                                                     ifapQualityIssuePerId.get(qIssueId).Related_Case__r.Account.IATACode__c,
                                                                     ifapQualityIssuePerId.get(qIssueId),           
                                                                     reassAccIssuePerCaseID.get(qIssueId)
                                                                     )
                                                                     .getXml();
                                         
                IfapToolManager.Response resp = IfapToolManager.submitCaseQualityIssuesToMFT(  caseNumber,  XmlFilename,  xmlString) ;
                
                ResponsePerQIssueId.put(qIssueId,resp);
                        
                transformationHelper.sendEmailSupport(' IFAPtoolManager,submitCaseQualityIssuesToMFT @future  '+ caseNumber +'    ' + datetime.now(),
                                                            'The following quality Issue was submitted with the result from the server caseNumber '+  caseNumber +' XmlFilename ' + XmlFilename + ' xmlString '+xmlString
                                                    );
                list<case> casesToUpdateTheStatus = new list<case>();                                    
                list<IFAP_Quality_Issue__c> qualityIssues2 =  new list<IFAP_Quality_Issue__c>();
                for(ID qualityIssueID2 : ifapQualityIssuePerId.keySet()){
                  //  if(ResponsePerQIssueId.get(qualityIssueID2).success){
                        
                        ifapQualityIssuePerId.get(qualityIssueID2).Status__c = 'Sent to GFA';
                        qualityIssues2.add(ifapQualityIssuePerId.get(qualityIssueID2));//}
                        CasesToUpdateTheStatus.add(new case(id = ifapQualityIssuePerId.get(qualityIssueID2).Related_Case__c,status = 'Quality Issue Requested' ));
                
                }                                   
                                                            
      if(qualityIssues2.size() > 0) database.update(qualityIssues2, false);   // to do test this one
      if(CasesToUpdateTheStatus.size() > 0) database.upsert(CasesToUpdateTheStatus, false);   // to do test this one
                        
        }
     } catch (Exception e) {
        
        TransformationHelper.sendEmailSupport('FATAL : IFAPtoolManager,submitCaseQualityIssuesToMFT @future' 
                                             ,' the following quality issues couldnt be processed :' + qualityIssueId
                                             +'   STACKTRACE   ' 
                                            + e.getStackTraceString()  + '  '  
                                            + e.getMessage() + '   ' 
                                            );
    
    }
}       
    
    

  
    
    
    
        
/*

{!REQUIRESCRIPT("/soap/ajax/29.0/connection.js")} 
{!REQUIRESCRIPT("/soap/ajax/29.0/apex.js")} 

sforce.connection.sessionId = "{!$Api.Session_ID}";

var caseStatus = "{!Case.Status}"; 
var accountStatus = "{!Account.Status__c}";
var accountLocationType = "{!Account.Location_Type__c}";
var userCloseFromAnyStatus = false;

var result = sforce.connection.query("Select IFAP_Close_from_any_Status__c From User Where Id = '{!User.Id}'");

// Getting record from the query to the array
var records = result.getArray("records");

if (records.length > 0)
{
var currentUser = records[0];   
userCloseFromAnyStatus = currentUser.IFAP_Close_from_any_Status__c; 
}

if (accountStatus == "Terminated" || accountStatus == "No longer a customer" || accountStatus == "Not accreditated" || accountStatus == "Cash basis/no commission" || accountLocationType == "BR" || userCloseFromAnyStatus == "true") { 
if (caseStatus == "Submitted" || caseStatus == "Quality Issue Requested") { 
if (confirm("You are about to cancel an assessment that was submitted. Continue ?")) { 
caseStatus = sforce.apex.execute("IFAP_WebService","UpdateCaseStatusToAssessmentCancelled", {caseId:"{!Case.Id}"}); 
if (caseStatus != "Assessment Cancelled") 
alert('Could not cancel the case: ' + caseStatus ); 
window.location.reload(); 
} 
} 
else if (caseStatus != "Closed") { 
window.location = "/{!Case.Id}/s?retURL=/{!Case.Id}&cas7=Closed&cas16=Please%20enter%20the%20reason%20for%20closing%20the%20case";
} 
else { 
alert('Cannot cancel a closed case.'); 
} 
} 
else { 
alert('The case cannot be cancelled when the agent status is ' + accountStatus); 
}

*/

}