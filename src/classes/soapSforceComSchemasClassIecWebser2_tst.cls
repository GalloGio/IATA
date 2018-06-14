@isTest
private class soapSforceComSchemasClassIecWebser2_tst {
        
    static testMethod void test_declareVariables() {
        soapSforceComSchemasClassIecWebser2.LogInfo elem1 = new soapSforceComSchemasClassIecWebser2.LogInfo();
        soapSforceComSchemasClassIecWebser2.AllowFieldTruncationHeader_element elem2 = new soapSforceComSchemasClassIecWebser2.AllowFieldTruncationHeader_element();
        soapSforceComSchemasClassIecWebser2.DebuggingHeader_element elem3 = new soapSforceComSchemasClassIecWebser2.DebuggingHeader_element();
        soapSforceComSchemasClassIecWebser2.CallOptions_element elem4 = new soapSforceComSchemasClassIecWebser2.CallOptions_element();
        soapSforceComSchemasClassIecWebser2.UpdateContactResponse_element elem5 = new soapSforceComSchemasClassIecWebser2.UpdateContactResponse_element();
        soapSforceComSchemasClassIecWebser2.AssignOpportunityToQuoteResponse_element elem6 = new soapSforceComSchemasClassIecWebser2.AssignOpportunityToQuoteResponse_element();
        soapSforceComSchemasClassIecWebser2.SessionHeader_element elem7 = new soapSforceComSchemasClassIecWebser2.SessionHeader_element();
        soapSforceComSchemasClassIecWebser2.UpdateContact_element elem8 = new soapSforceComSchemasClassIecWebser2.UpdateContact_element();
        soapSforceComSchemasClassIecWebser2.DebuggingInfo_element elem9 = new soapSforceComSchemasClassIecWebser2.DebuggingInfo_element();
        soapSforceComSchemasClassIecWebser2.AssignOpportunityToQuote_element elem10 = new soapSforceComSchemasClassIecWebser2.AssignOpportunityToQuote_element();
    }

    public class IecWebserviceMock implements WebServiceMock {

        private String responseType = 'soapSforceComSchemasClassIecWebser2.';

        public IecWebserviceMock(String className){
            this.responseType += className;
        }

        public void doInvoke(
               Object stub,
               Object request,
               Map<String, Object> response,
               String endpoint,
               String soapAction,
               String requestName,
               String responseNS,
               String responseName,
               String responseType) {

            Object responseElement = Type.forName(responseType).newInstance();
            response.put('response_x', responseElement); 
       }
    }

    static testMethod void test_callouts() {

        IEC_Settings__c settings = IEC_Settings__c.getOrgDefaults();
        settings.Customer_Permission_Set_Id__c = 'Test';
        settings.PaymentMethod_Bank_Transfer_Zuora_ID__c = 'Test';
        settings.PaymentMethod_Other_Zuora_ID__c = 'Test';
        settings.Quote_Template_Zuora_ID_New_Subscription__c = 'Test';
        settings.Cart_cookie_session_timeout__c = -1;
        settings.Encryption_Algorythm__c = 'Test';
        settings.Encryption_Key__c = 'Test';
        settings.IEC_Web_Service_Endpoint__c = 'Test';
        settings.IEC_Web_Service_Password__c = 'Test';
        settings.IEC_Web_Service_Username__c = 'Test';
        settings.SchdlIECCompileUsage_Class_ID__c = 'Test';
        settings.Server_API_URL__c = 'Test';
        settings.CAC_Web_Service_API_Gateway__c = 'Test';
        settings.CAC_Web_Service_Usage_Url__c = 'Test';
        settings.SchdlCACWSUsageUpdate_Class_ID__c = 'Test';
        settings.Error_Log_Keep_Duration__c = 6;
        insert settings;

        Test.startTest();

        soapSforceComSchemasClassIecWebser2.IEC_WebService request = new soapSforceComSchemasClassIecWebser2.IEC_WebService();

        Test.setMock(WebServiceMock.class, new IecWebserviceMock('updateContactResponse_element'));
        request.updateContact('contactId', 'sFirstName', 'sLastName', 'sEmail', 'sSalutation', 'sTitle', 'sPhone', 'sTax1', 'sTax2', 'sVATCountryCode',  'sIECPortalStatus');


        Test.setMock(WebServiceMock.class, new IecWebserviceMock('assignOpportunityToQuoteResponse_element'));
        request.assignOpportunityToQuote('quoteId');

        Test.stopTest();
    }   
}