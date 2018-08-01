global without sharing class ANG_SAP_PPA {
    webservice static WSResponse putPPAToSFDC(string CaseId, string PPANumber, string FileBody, string FileType){
        //FileBody = file content encoded base 64
        //ServiceNow_Helper.sendRequestToSNOW('Mulesoft', 'INT_008', 'Agency MasterData', 'Mulesoft', 'Mulesoft', iataCode + ' ' +  String.valueOf(res.getStatusCode()),  String.valueOf(res.getStatusCode()), 'Connectivity', 'Salesforce.com', 'Salesforce.com', 'Infrastructure Services', 'Mulesoft Support', '2', '2', '2', 'Failure');
        set<string> setAllowedFileType = new set<string>{'PPA'};	//Add here new file type, uppercase
        try{
            if(PPANumber==null || PPANumber=='')	return new WSResponse('400', 'Empty PPANumber element');    //throw new BadException('No PPANumber Received');
            if(CaseId==null || CaseId=='')			return new WSResponse('400', 'Empty CaseId element');   //throw new BadException('No CaseId Received');
            if(FileType==null || FileType=='')		return new WSResponse('400', 'Empty FileType element');   //throw new BadException('No CaseId Received');
            if(!setAllowedFileType.contains(FileType.toUpperCase()))	return new WSResponse('406', 'Invalid FileType');

            list<case> lsCase = [select id, OSCAR__c from case where id=:CaseId];
                    
            if(lsCase.isEmpty())            return new WSResponse('404', 'Case not found'); //throw new BadException('Case not found');
            if(lsCase.size()>1)             return new WSResponse('409', 'Too many cases found');
            
            Case theCase = lsCase.get(0);
            
            AMS_Oscar__c theOscar = [select id, Billing_Document_Number__c from AMS_oscar__c where id = :theCase.OSCAR__c];
            
            if (theOscar == null) return new WSResponse('409', 'Case has no associated OSCAR');
            if (String.isNotBlank(theOscar.Billing_Document_Number__c))  return new WSResponse('409', 'Case has already a PPA Number');
            
            //method works in 2 way: if FileBody is not empty, then it saves it as attachment
            //if FileBody is empty, then it calls the WS exposed by SAP to fetch the attachment
            blob FileContent;
            
            if(string.isBlank(FileBody)){
                SAP_Digital_Invoice.DT_SFDC_DigitalSignedInvoice_Response response = IECInvoice_Ctrl.CallSAPToGetInvoice_Static(PPANumber);
                if(response!=null){
                    if(response.Error == null){
                    	EncodingUtil.base64Decode(response.EncodedSignedInvoice);
                    }
                }else{
                	ServiceNow_Helper.sendRequestToSNOW('SAP', 'SAP PPA', 'SAP PPA', 'SAP-PI', 'SAP', 'Error while getting PPA from SAP', String.valueOf(response.Error.Message), 'Connectivity', 'Salesforce.com', 'Salesforce.com', 'Infrastructure Services', 'Salesforce Support', '2', '2', '2', 'Failure');
                	//IECErrorLogger.logApexError('AMS_OSCARTriggerHandler.CallSAP', mapToRetrieve.get(i), String.valueOf(response), true);
                }
            }
            else
                FileContent = EncodingUtil.base64Decode(FileBody);
            
            Long size = FileContent.size();
	        String folder = WrapperAttach.getAmazonFolder(CaseId);
	        string FileName = PPANumber + '.pdf';
            
            UploadMultipleFileToAmazonButtonCtrl.UploadFile upF = UploadMultipleFileToAmazonButtonCtrl.createUploadFile(caseId, FileName, 'application/pdf', size, folder,  WrapperAttach.CREDENTIAL_NAME);
            
            Boolean result = AmazonRest.uploadFile(upF, FileContent);
            
            if(result){
            	if(!UploadMultipleFileToAmazonButtonCtrl.createAmazonFileObject(folder+fileName, size, caseId, 'AMS_File', 'Others', 'Portal')) {
                    System.debug('Error: Couldn\'t save amazon file on Salesforce - ISSP_AMS_Accreditation.cls');
                }
                
                theOscar.Billing_Document_Number__c = PPANumber;
                update theOscar;
            }else {
                //System.debug('Error: Amazon file not Uploaded - ISSP_AMS_Accreditation.cls');
                ServiceNow_Helper.sendRequestToSNOW('SAP', 'SAP PPA', 'SAP PPA', 'SAP-PI', 'SAP', 'Error while getting PPA from SAP', 'Error: Amazon file not Uploaded - ISSP_AMS_Accreditation.cls', 'Connectivity', 'Salesforce.com', 'Salesforce.com', 'Infrastructure Services', 'Salesforce Support', '2', '2', '2', 'Failure');
            }
            
            return new WSResponse('200', 'OK');
        }
        catch(exception e){
        	ServiceNow_Helper.sendRequestToSNOW('SAP', 'SAP PPA', 'SAP PPA', 'SAP-PI', 'SAP', 'Error while getting PPA from SAP', e.getMessage(), 'Connectivity', 'Salesforce.com', 'Salesforce.com', 'Infrastructure Services', 'Salesforce Support', '2', '2', '2', 'Failure');
            return new WSResponse('500', 'Generic Error: ' + e.getMessage());   //throw new BadException(e.getMessage());
        }
    }
    
    global class WSResponse{
        webservice string statusCode;
        webservice string statusDescription;
        public WSresponse(string statusCode, string statusDescription){
            statusCode = statusCode;
            statusDescription = statusDescription;
        }  
    }
    
    //public virtual class BadException extends Exception {}
}