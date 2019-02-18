/***********************************************************
	2019-02-15.
	Class expose a REST webservice which updates information regarding the GDI Case (payment status) 
	
	JIRA Issue Reference: 
		- https://iatasfdc.atlassian.net/browse/NEWGEN-4995
        - 
	Interface Catalogue:
		INT_066

    Sample URI
    /services/apexrest/case-create-details/500XXXXXXXX/payment-status

    Sample body
    [
		{"caller"="GDI",
		"paymentStatus"="Paid"
		}
    ]
***********************************************************/

@RestResource(urlMapping='/case-create-details/*')
global without sharing class ANG_CreateCaseDetails {
    
    @HttpPost
    global static void doPost(){
		set<string> setValidPaymentStatus = new set<string>{'Paid;Outstanding;N/A'};	//Valid account type
        set<string> setValidRequest = new set<string>{ANG_RestServiceHelper.URIRequest_CaseDetails};    //Valid type of request, part of URI
        set<string> setValidCaller = new set<string>{ANG_RestServiceHelper.Caller_GDI};			//Valid caller

        try{
            RestRequest req = RestContext.request;
			
            System.debug('[ANG_CreateCaseDetails]: Processing Request:'+req);
            
            string[] SplittedURI = req.requestURI.split('/');
            
            if(SplittedURI.size()<3){
                ANG_RestServiceHelper.GenerateResponse(json.serialize(new ANG_RestServiceHelper.ErrorPayload('400', 'Wrong URI:'+req.requestURI)), 400);
                return;
            }

            string caseId = SplittedURI[2];   //get the case identifier code request URI
            string requestType = SplittedURI[3];    //get the payment status from the request URI

            if(!setValidRequest.contains(requestType)){
                ANG_RestServiceHelper.GenerateResponse(json.serialize(new ANG_RestServiceHelper.ErrorPayload('400', 'Wrong URI:'+requestType)), 400);
                return;
            }

			//payload
			INT066_Payload payloadList = (INT066_Payload)System.JSON.deserialize(RestContext.request.requestBody.toString(), INT066_Payload.class);

            //Retrieve parameter from the querystring
            string Caller = payloadList.caller;	//Name of the caller (e.g. GDI) 
            string paymentStatus = payloadList.paymentStatus; //e.g.: Paid

            /*** verification ***/
            if(caseId==null || caseId== ''){
                ANG_RestServiceHelper.GenerateResponse(json.serialize(new ANG_RestServiceHelper.ErrorPayload('400', 'No Case Id received')), 400);
                return;
            }
            
            if(Caller==null || Caller== ''){
                ANG_RestServiceHelper.GenerateResponse(json.serialize(new ANG_RestServiceHelper.ErrorPayload('400', 'Caller not specified')), 400);
                return;
            }

            if(paymentStatus==null || paymentStatus== ''){
                ANG_RestServiceHelper.GenerateResponse(json.serialize(new ANG_RestServiceHelper.ErrorPayload('400', 'Payment Status not specified')), 400);
                return;
            }

            if(!setValidPaymentStatus.contains(paymentStatus)){
            	ANG_RestServiceHelper.GenerateResponse(json.serialize(new ANG_RestServiceHelper.ErrorPayload('400', 'Invalid Payment Status')), 400);
                return;
            }
            
            if(!setValidCaller.contains(Caller)){
            	ANG_RestServiceHelper.GenerateResponse(json.serialize(new ANG_RestServiceHelper.ErrorPayload('400', 'Invalid Caller')), 400);
                return;
            }

            //Fetch the case given by the case Id
            /* run the query, different based on caller/request type */
            list<Case> lsCase;
			AMS_OSCAR__c oscar;

            if(Caller==ANG_RestServiceHelper.Caller_GDI){
                if (requestType==ANG_RestServiceHelper.URIRequest_CaseDetails)
                    lsCase = [SELECT Id, OSCAR__c FROM Case where Id =: caseId];
            }

			if(lsCase==null || lsCase.isEmpty()){
                ANG_RestServiceHelper.GenerateResponse(json.serialize(new ANG_RestServiceHelper.ErrorPayload('404', 'Case with Id' + caseId +' not found')), 404);
                return;
            }
            
            if(lsCase.size()>1){
                ANG_RestServiceHelper.GenerateResponse(json.serialize(new ANG_RestServiceHelper.ErrorPayload('409', 'Multiple records found with Case Id ' + caseId) ), 409);
                return;
            }
            
            Case gdiCase = lsCase.get(0);
            
			//Perform Validations

			if(gdiCase.OSCAR__c == null){
				ANG_RestServiceHelper.GenerateResponse(json.serialize(new ANG_RestServiceHelper.ErrorPayload('404', 'The Oscar Record was not found in the case with Id ' + caseId) ), 404);
				return;
            }

			List<AMS_OSCAR__c> oscarLst = [Select Id, Invoice_status__c from AMS_OSCAR__c where Id = :gdiCase.OSCAR__c];
			
			if(oscarLst.isEmpty()){
                ANG_RestServiceHelper.GenerateResponse(json.serialize(new ANG_RestServiceHelper.ErrorPayload('404', 'Oscar with Id' + caseId +' not found')), 404);
                return;
			}

			oscar = oscarLst.get(0);

			if(oscar == null){
				ANG_RestServiceHelper.GenerateResponse(json.serialize(new ANG_RestServiceHelper.ErrorPayload('404', 'The Oscar Record was not found in the case with Id ' + caseId) ), 404);
				return;
            }

			if(oscar.Invoice_status__c != null){
				ANG_RestServiceHelper.GenerateResponse(json.serialize(new ANG_RestServiceHelper.ErrorPayload('409', 'The Oscar Record from the case Id ' +caseID+' already has the payment status filled with value ' + oscar.Invoice_status__c) ), 404);
				return;
            }

			
			/*	Perform actions
			fetch the oscar associated to the case received
			Set the values of field Invoice_status__c
			Set other necessary fields (step passed, payment date, etc...)
			send HTTPCode 200 as response
			*/

			oscar.Invoice_status__c = paymentStatus;
			update oscar;

            //return message, Id of Record Created (oscar)
            ANG_RestServiceHelper.GenerateResponse(json.serialize(new INT066_SuccessPayload(oscar.Id)), 200);

        }catch(Exception e){
            ANG_RestServiceHelper.GenerateResponse(json.serialize(new ANG_RestServiceHelper.ErrorPayload('500', e.getMessage()) ), 500);
        }
    }

	private class INT066_SuccessPayload{
        string recordId;
        public INT066_SuccessPayload(string sId){
			this.recordId = sId;
        }
    }

	private class INT066_Payload{

		String caller;
		String paymentStatus;
	}
}


