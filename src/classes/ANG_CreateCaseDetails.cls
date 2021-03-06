/***********************************************************
	2019-02-15.
	Class expose a REST webservice which updates information regarding the GDI Case (payment status) 
	
	JIRA Issue Reference: 
		- https://iatasfdc.atlassian.net/browse/NEWGEN-4995
		- 
	Interface Catalogue:
		INT_066

	Sample URI
	/services/apexrest/case-create-details/500xxxxxxxxxxxx/payment-status?caller=<NameOfExtSystem>

	Sample body
	[
		{"paymentStatus":"Paid"}
	]
***********************************************************/

@RestResource(urlMapping='/case-create-details/*')
global without sharing class ANG_CreateCaseDetails {

	public static final set<string> setValidPaymentStatus = new set<string>{
		AMS_Utils.INVOICE_STATUS_NA,
		AMS_Utils.INVOICE_STATUS_PAID,
		AMS_Utils.INVOICE_STATUS_NOT_PAID,
		AMS_Utils.INVOICE_STATUS_FULLY_PAID,
		AMS_Utils.INVOICE_STATUS_OUTSTANDING
	};

	public static final set<string> setValidRequest = new set<string>{ANG_RestServiceHelper.URIRequest_CasePaymentStatus}; //Valid type of request, part of URI
	public static final set<string> setValidCaller = new set<string>{ANG_RestServiceHelper.Caller_SAP}; //Valid caller

	@HttpPost
	global static void doPost(){

		try{
			RestRequest req = RestContext.request;
			
			System.debug('[ANG_CreateCaseDetails]: Processing Request:'+req);
			
			string[] SplittedURI = req.requestURI.split('/');
			
			if(SplittedURI.size()<3){
				ANG_RestServiceHelper.GenerateResponse(json.serialize(new ANG_RestServiceHelper.ErrorPayload('400', 'Wrong URI:'+req.requestURI)), 400);
				return;
			}

			string caseId = SplittedURI[2]; //get the case identifier code request URI
			string requestType = SplittedURI[3]; //get the payment status from the request URI
			string requestCaller = req.params.get('caller'); //Name of the caller (e.g. GDI) //get the payment status from the request URI

			if(!ANG_CreateCaseDetails.setValidRequest.contains(requestType)){
				ANG_RestServiceHelper.GenerateResponse(json.serialize(new ANG_RestServiceHelper.ErrorPayload('400', 'Wrong URI:'+requestType)), 400);
				return;
			}

			/*** verification ***/
			if(caseId==null || caseId== ''){
				ANG_RestServiceHelper.GenerateResponse(json.serialize(new ANG_RestServiceHelper.ErrorPayload('400', 'No Case Id received')), 400);
				return;
			}
			
			if(requestType == ANG_RestServiceHelper.URIRequest_CasePaymentStatus){

				CasePaymentStatus casePaymentStatus = new CasePaymentStatus(req,caseId);

				if(casePaymentStatus.execute(requestCaller))
					ANG_RestServiceHelper.GenerateResponse(json.serialize(new INT066_SuccessPayload(caseId)), 200);
			}

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

	private class CasePaymentStatus{
		
		private RestRequest req;
		private String caseId;

		private final Map<String,String> paymentStatusMap = new Map<String,String>{
			AMS_Utils.INVOICE_STATUS_FULLY_PAID => AMS_Utils.INVOICE_STATUS_PAID,
			AMS_Utils.INVOICE_STATUS_NOT_PAID => AMS_Utils.INVOICE_STATUS_OUTSTANDING,
			AMS_Utils.INVOICE_STATUS_PAID => AMS_Utils.INVOICE_STATUS_PAID,
			AMS_Utils.INVOICE_STATUS_OUTSTANDING => AMS_Utils.INVOICE_STATUS_OUTSTANDING,
			AMS_Utils.INVOICE_STATUS_NA => AMS_Utils.INVOICE_STATUS_NA
		};

		public CasePaymentStatus(RestRequest req, String caseId){
			this.req = req;
			this.caseId = caseId;
		}

		public boolean execute(String caller){
			
			//payload
			INT066_Payload payloadList = (INT066_Payload)System.JSON.deserialize(req.requestBody.toString(), INT066_Payload.class);

			//Retrieve parameter from the querystring
			//string caller = payloadList.caller; //Name of the caller (e.g. GDI) 
			string paymentStatus = payloadList.paymentStatus; //e.g.: Paid

			if(caller==null || caller== '' || !setValidCaller.contains(caller)){
				ANG_RestServiceHelper.GenerateResponse(json.serialize(new ANG_RestServiceHelper.ErrorPayload('403', 'Caller not specified or invalid:'+caller)), 403);
				return false;
			}

			if(!ANG_CreateCaseDetails.setValidPaymentStatus.contains(paymentStatus)){
				ANG_RestServiceHelper.GenerateResponse(json.serialize(new ANG_RestServiceHelper.ErrorPayload('400', 'Invalid Payment Status:'+paymentStatus)), 400);
				return false;
			}
			
			//Fetch the case given by the case Id
			/* run the query, different based on caller/request type */
			list<Case> lsCase;
			AMS_OSCAR__c oscar;

			lsCase = [SELECT Id, OSCAR__c,  Account.ANG_IsNewGenAgency__c, Reason1__c FROM Case where Id =: caseId];

			if(lsCase==null || lsCase.isEmpty()){
				ANG_RestServiceHelper.GenerateResponse(json.serialize(new ANG_RestServiceHelper.ErrorPayload('404', 'Case with Id' + caseId +' not found')), 404);
				return false;
			}
			
			if(lsCase.size()>1){
				ANG_RestServiceHelper.GenerateResponse(json.serialize(new ANG_RestServiceHelper.ErrorPayload('409', 'Multiple records found with Case Id ' + caseId) ), 409);
				return false;
			}
			
			Case gdiCase = lsCase.get(0);
			
			//Perform Validations

			if(gdiCase.OSCAR__c == null){
				ANG_RestServiceHelper.GenerateResponse(json.serialize(new ANG_RestServiceHelper.ErrorPayload('404', 'The Oscar Record was not found in the case with Id ' + caseId) ), 404);
				return false;
			}

			if(!gdiCase.Account.ANG_IsNewGenAgency__c && gdiCase.Reason1__c != 'GDI setup'){
				ANG_RestServiceHelper.GenerateResponse(json.serialize(new ANG_RestServiceHelper.ErrorPayload('403', 'The Account Related the Case with Id' + caseId +' is not a NewGen agency nor a GDI case') ), 403);
				return false;
			}

			List<AMS_OSCAR__c> oscarLst = [Select Id, Invoice_status__c, Payment_Type__c,Oscar_Communication_Case_Id__c, Billing_Document_Number__c from AMS_OSCAR__c where Id = :gdiCase.OSCAR__c];
			
			if(oscarLst.isEmpty()){
				ANG_RestServiceHelper.GenerateResponse(json.serialize(new ANG_RestServiceHelper.ErrorPayload('404', 'Oscar with Id' + caseId +' not found')), 404);
				return false;
			}

			oscar = oscarLst.get(0);

			oscar.Invoice_status__c = paymentStatusMap.get(paymentStatus);

			if(oscar.Payment_Type__c == AMS_Utils.SAP_PAYMENT_TYPE_PPA){
				insert new CaseComment(ParentId = oscar.Oscar_Communication_Case_Id__c, CommentBody = 'Invoice ' +oscar.Billing_Document_Number__c+ ' is ' + paymentStatus);
				update new Case(id = oscar.Oscar_Communication_Case_Id__c, New_interaction__c = 'New comment');
			}

			update oscar;

			return true;
		}
	}
}