@isTest
private class NewGen_Rest_AcceptTermsAndConditionsTest
{
    @isTest
    static void TestAcceptTerms()
    {

    RestRequest req = new RestRequest();
    RestResponse res = new RestResponse();
    req.requestURI = '/services/apexrest/newgenapp/v1/acceptTermsAndConditions/*';
    req.httpMethod = 'POST';

    JSONGenerator gen = JSON.createGenerator(true);
    gen.writeStartObject();
    gen.writeStringField('termsVersion', '1');
    gen.writeEndObject();

    Blob reqbody = Blob.valueof(gen.getAsString());

    req.requestBody = reqbody;


    RestContext.request = req;
    RestContext.response= res;

    Test.startTest();
        String actual = NewGen_Rest_AcceptTermsAndConditions.AcceptTerms();
    Test.stopTest();

    System.assertEquals('SendTermsAcceptance', actual);
    }
}