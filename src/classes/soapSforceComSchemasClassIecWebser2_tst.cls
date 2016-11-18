@isTest
private class soapSforceComSchemasClassIecWebser2_tst {

    static testMethod void myUnitTest() {
        test.startTest();
        soapSforceComSchemasClassIecWebser2.AllowFieldTruncationHeader_element a = new soapSforceComSchemasClassIecWebser2.AllowFieldTruncationHeader_element();
        soapSforceComSchemasClassIecWebser2.assignOpportunityToQuote_element b = new soapSforceComSchemasClassIecWebser2.assignOpportunityToQuote_element();
        soapSforceComSchemasClassIecWebser2.assignOpportunityToQuoteResponse_element c = new soapSforceComSchemasClassIecWebser2.assignOpportunityToQuoteResponse_element();
        soapSforceComSchemasClassIecWebser2.CallOptions_element d = new soapSforceComSchemasClassIecWebser2.CallOptions_element();
        soapSforceComSchemasClassIecWebser2.DebuggingHeader_element e = new soapSforceComSchemasClassIecWebser2.DebuggingHeader_element();
        soapSforceComSchemasClassIecWebser2.DebuggingInfo_element f = new soapSforceComSchemasClassIecWebser2.DebuggingInfo_element();
        soapSforceComSchemasClassIecWebser2.IEC_WebService g = new soapSforceComSchemasClassIecWebser2.IEC_WebService();
        soapSforceComSchemasClassIecWebser2.LogInfo h = new soapSforceComSchemasClassIecWebser2.LogInfo();
        soapSforceComSchemasClassIecWebser2.SessionHeader_element i = new soapSforceComSchemasClassIecWebser2.SessionHeader_element();
        soapSforceComSchemasClassIecWebser2.updateContact_element j = new soapSforceComSchemasClassIecWebser2.updateContact_element ();
        soapSforceComSchemasClassIecWebser2.updateContactResponse_element k = new soapSforceComSchemasClassIecWebser2.updateContactResponse_element();
//        soapSforceComSchemasClassIecWebser2.updateContact(
        
        
        test.stopTest();
    }
    
    static testMethod void myUnitTest2() {
        test.startTest();
        soapSforceComSchemasClassIecWebser2.IEC_WebService g = new soapSforceComSchemasClassIecWebser2.IEC_WebService();
        Boolean tt = g.assignOpportunityToQuote('123');
        tt = g.updateContact('contactId','String sFirstName','String sLastName','Email', 'S','String sTitle','String','String','String','String','String sIECPortalStatus'); 
        
        test.stopTest();
    }
}