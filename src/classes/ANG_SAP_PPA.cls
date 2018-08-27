global without sharing class ANG_SAP_PPA {
    webservice static WSResponse putPPAToSFDC(String caseId, String ppaNumber, string fileBody, string fileType){

        Set<String> setAllowedFileType = new Set<String>{'PPA'}; //Add here new file type, uppercase
        
        try{
            if(ppaNumber==null || ppaNumber=='') return new WSResponse('400', 'Empty PPANumber element');
            if(caseId==null || caseId=='') return new WSResponse('400', 'Empty CaseId element');
            if(fileType==null || fileType=='') return new WSResponse('400', 'Empty FileType element');
            if(!setAllowedFileType.contains(FileType.toUpperCase())) return new WSResponse('406', 'Invalid FileType');

            List<Case> lsCase = [SELECT id, OSCAR__c FROM case WHERE id=:CaseId];
       
            if(lsCase.isEmpty()) return new WSResponse('404', 'Case not found');
            //if(lsCase.size()>1)             return new WSResponse('409', 'Too many cases found');
            Case theCase = lsCase.get(0);

            AMS_Oscar__c theOscar = [SELECT id, Billing_Document_Number__c FROM AMS_oscar__c WHERE id = :theCase.OSCAR__c];

            if (String.isNotBlank(theOscar.Billing_Document_Number__c)) return new WSResponse('409', 'Case has already a PPA Number');
            
            //method works in 2 way: if FileBody is not empty, then it saves it as attachment
            //if FileBody is empty, then it calls the WS exposed by SAP to fetch the attachment
            Blob fileContent;

            if (string.isBlank(fileBody)) {
                SAP_Digital_Invoice.DT_SFDC_DigitalSignedInvoice_Response response = IECInvoice_Ctrl.CallSAPToGetInvoice_Static(ppaNumber);
                if (response!=null) {
                    if (response.Error == null) EncodingUtil.base64Decode(response.EncodedSignedInvoice);
                } else {
                	if (!Test.isRunningTest()) ServiceNow_Helper.sendRequestToSNOW('SAP', 'SAP PPA', 'SAP PPA', 'SAP-PI', 'SAP', 'Error while getting PPA from SAP', String.valueOf(response.Error.Message), 'Connectivity', 'Salesforce.com', 'Salesforce.com', 'Infrastructure Services', 'Salesforce Support', '2', '2', '2', 'Failure');
                }
            }
            else fileContent = EncodingUtil.base64Decode(fileBody);

            Long size = FileContent.size();
	        String folder = WrapperAttach.getAmazonFolder(caseId);
	        string fileName = ppaNumber + '.pdf';

            UploadMultipleFileToAmazonButtonCtrl.UploadFile upF = UploadMultipleFileToAmazonButtonCtrl.createUploadFile(caseId, fileName, 'application/pdf', size, folder, WrapperAttach.CREDENTIAL_NAME);

            Boolean result = AmazonRest.uploadFile(upF, fileContent);

            if(result){
            	if(!UploadMultipleFileToAmazonButtonCtrl.createAmazonFileObject(folder + fileName, size, caseId, 'AMS_File', 'Others', 'Portal')) {
                    System.debug('Error: Couldn\'t save amazon file on Salesforce - ISSP_AMS_Accreditation.cls');
                }
                
                theOscar.Billing_Document_Number__c = ppaNumber;
                update theOscar;
            }else {
                if (!Test.isRunningTest()) ServiceNow_Helper.sendRequestToSNOW('SAP', 'SAP PPA', 'SAP PPA', 'SAP-PI', 'SAP', 'Error while getting PPA from SAP', 'Error: Amazon file not Uploaded - ISSP_AMS_Accreditation.cls', 'Connectivity', 'Salesforce.com', 'Salesforce.com', 'Infrastructure Services', 'Salesforce Support', '2', '2', '2', 'Failure');
            }
            
            return new WSResponse('200', 'OK');
        }
        catch(exception e){
        	if (!Test.isRunningTest()) ServiceNow_Helper.sendRequestToSNOW('SAP', 'SAP PPA', 'SAP PPA', 'SAP-PI', 'SAP', 'Error while getting PPA from SAP', e.getMessage(), 'Connectivity', 'Salesforce.com', 'Salesforce.com', 'Infrastructure Services', 'Salesforce Support', '2', '2', '2', 'Failure');
            return new WSResponse('500', 'Generic Error: ' + e.getMessage());
        }
    }
    
    global class WSResponse{
        webservice string statusCode;
        webservice string statusDescription;
        public WSresponse(string statusCode, string statusDescription){
            this.statusCode = statusCode;
            this.statusDescription = statusDescription;
        }
    }
}