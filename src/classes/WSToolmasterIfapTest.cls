@IsTest
public with sharing class WSToolmasterIfapTest {

	private class WebServiceMockImpl implements WebServiceMock {
		public void doInvoke(
			Object stub, Object request, Map<String, Object> response,
			String endpoint, String soapAction, String requestName,
			String responseNS, String responseName, String responseType) {

			if(request instanceof WSToolmasterIfap.processPWCResults_element) {
				WSToolmasterIfap.processPWCResultsResponse_element responseElem = new WSToolmasterIfap.processPWCResultsResponse_element();
				response.put('response_x', responseElem);
			}
			if(request instanceof WSToolmasterIfap.mergeAllPDFForCase_element) {
				WSToolmasterIfap.mergeAllPDFForCaseResponse_element responseElem = new WSToolmasterIfap.mergeAllPDFForCaseResponse_element();
				response.put('response_x', responseElem);
			}
			if(request instanceof WSToolmasterIfap.submitCaseQualityIssuesToMFT_element) {
				WSToolmasterIfap.submitCaseQualityIssuesToMFTResponse_element responseElem = new WSToolmasterIfap.submitCaseQualityIssuesToMFTResponse_element();
				response.put('response_x', responseElem);
			}
			if(request instanceof WSToolmasterIfap.deletePWCResults_element) {
				WSToolmasterIfap.deletePWCResultsResponse_element responseElem = new WSToolmasterIfap.deletePWCResultsResponse_element();
				response.put('response_x', responseElem);
			}
			if(request instanceof WSToolmasterIfap.deletePWCRejections_element) {
				WSToolmasterIfap.deletePWCRejectionsResponse_element responseElem = new WSToolmasterIfap.deletePWCRejectionsResponse_element();
				response.put('response_x', responseElem);
			}
			if(request instanceof WSToolmasterIfap.submitCaseCancellationToMFT_element) {
				WSToolmasterIfap.submitCaseCancellationToMFTResponse_element responseElem = new WSToolmasterIfap.submitCaseCancellationToMFTResponse_element();
				response.put('response_x', responseElem);
			}
			if(request instanceof WSToolmasterIfap.submitCaseParametersToMFT_element) {
				WSToolmasterIfap.submitCaseParametersToMFTResponse_element responseElem = new WSToolmasterIfap.submitCaseParametersToMFTResponse_element();
				response.put('response_x', responseElem);
			}
			if(request instanceof WSToolmasterIfap.processPWCRejections_element) {
				WSToolmasterIfap.processPWCRejectionsResponse_element responseElem = new WSToolmasterIfap.processPWCRejectionsResponse_element();
				response.put('response_x', responseElem);
			}
			if(request instanceof WSToolmasterIfap.mergeAndSubmitParameters_element) {
				WSToolmasterIfap.mergeAndSubmitParametersResponse_element responseElem = new WSToolmasterIfap.mergeAndSubmitParametersResponse_element();
				response.put('response_x', responseElem);
			}
			return;
		}
	}

	private static testMethod void coverTypes() {


		Amazon_Cred__c Amazon_Cred =  new Amazon_Cred__c(name = 'IFAP', Prod_Configuration__c = 'adevconf' , Dev_Configuration__c = 'adevconf');
		insert Amazon_Cred;
 Amazon_Cred__c Amazon_Cred2 =  new Amazon_Cred__c(name = 'endpoint', Prod_Configuration__c = 'adevconf' , Dev_Configuration__c = 'adevconf');
		insert Amazon_Cred2 ;
		list<AWSKey__c> AWS_KEYs = new list<AWSKey__c>{
			new AWSKey__c(
				name = 'adevconf',
				Key__c = 'asd',
				Secret__c = 'asd',
				IAS_configuration_name__c = 'asdas',
				IAS_Access_Point__c = 'asd',
				Bucket__c = 'asd',
				AWS_ENDPOINT_URL__c = 'asd',
				WS_Endpoint__c = 'apoint')
		};
		insert AWS_KEYs;

		test.startTest();
		new WSToolmasterIfap.mergeAndSubmitParametersResponse_element();
		new WSToolmasterIfap.submitCaseQualityIssuesToMFT_element();
		new WSToolmasterIfap.submitCaseCancellationToMFTResponse_element();
		new WSToolmasterIfap.submitCaseCancellationToMFT_element();
		new WSToolmasterIfap.mergeAllPDFForCase_element();
		new WSToolmasterIfap.processPWCRejections_element();
		new WSToolmasterIfap.deletePWCResults_element();
		new WSToolmasterIfap.mergeAndSubmitParameters_element();
		new WSToolmasterIfap.deletePWCRejectionsResponse_element();
		new WSToolmasterIfap.processPWCResults_element();
		new WSToolmasterIfap.processPWCRejectionsResponse_element();
		new WSToolmasterIfap.mergeAllPDFForCaseResponse_element();
		new WSToolmasterIfap.submitCaseQualityIssuesToMFTResponse_element();
		new WSToolmasterIfap.deletePWCResultsResponse_element();
		new WSToolmasterIfap.submitCaseParametersToMFTResponse_element();
		new WSToolmasterIfap.processPWCResultsResponse_element();
		new WSToolmasterIfap.submitCaseParametersToMFT_element();
		new WSToolmasterIfap.deletePWCRejections_element();
		test.stopTest();
	}

	private static testMethod void coverMethods() {
		Amazon_Cred__c Amazon_Cred =  new Amazon_Cred__c(name = 'IFAP', Prod_Configuration__c = 'adevconf' , Dev_Configuration__c = 'adevconf');
		insert Amazon_Cred;
		Amazon_Cred__c Amazon_Cred2 =  new Amazon_Cred__c(name = 'endpoint', Prod_Configuration__c = 'adevconf' , Dev_Configuration__c = 'adevconf');
		insert Amazon_Cred2;
		list<AWSKey__c> AWS_KEYs = new list<AWSKey__c>{
			new AWSKey__c(
				name = 'adevconf',
				Key__c = 'asd',
				Secret__c = 'asd',
				IAS_configuration_name__c = 'asdas',
				IAS_Access_Point__c = 'asd',
				Bucket__c = 'asd',
				AWS_ENDPOINT_URL__c = 'asd',
				WS_Endpoint__c = 'apoint')
		};
		insert AWS_KEYs;
			test.startTest();

		System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
		WSToolmasterIfap.IfapToolMaster ifapToolMaster = new WSToolmasterIfap.IfapToolMaster();
		ifapToolMaster.processPWCResults(null,1);
		ifapToolMaster.mergeAllPDFForCase(null, null, null);
		ifapToolMaster.submitCaseQualityIssuesToMFT(null, null, null, null);
		ifapToolMaster.deletePWCResults(null, null);
		ifapToolMaster.deletePWCRejections(null, null);
		ifapToolMaster.submitCaseCancellationToMFT(null, null, null, null);
		ifapToolMaster.submitCaseParametersToMFT(null, null, null, null);
		ifapToolMaster.processPWCRejections(null,1);
		ifapToolMaster.mergeAndSubmitParameters(null, null, null, null);
				test.stopTest();

	}

}
