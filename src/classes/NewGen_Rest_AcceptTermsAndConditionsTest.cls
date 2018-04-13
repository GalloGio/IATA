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
    gen.writeStringField('appShortName', 'NewGen');
    gen.writeStringField('termsVersion', '1');
    gen.writeEndObject();

    Blob reqbody = Blob.valueof(gen.getAsString());

    req.requestBody = reqbody;


    RestContext.request = req;
    RestContext.response= res;

    Account account = ISSP_ObjectFactory.createNewAccount();
    insert account;

    Contact con = ISSP_ObjectFactory.createNewContact();
    con.AccountId= account.Id;
    con.Email = 'NewGen_Rest_Accept@test11.com';
    insert con;

    Portal_Applications__c app = new Portal_Applications__c();
    app.NewGenAPP_ShortName__c = 'NewGen';
    insert app;

    Portal_Application_Right__c appright = new Portal_Application_Right__c();
    appright.Portal_Application__c = app.Id;
    appright.Contact__c = con.Id;
    appright.Technical_Provisioning_Status__c = 'IATA Access Granted';
    appright.Right__c = 'Access Granted';
    insert appright;


    Test.startTest();
        String actual = NewGen_Rest_AcceptTermsAndConditions.AcceptTerms();
    Test.stopTest();

    System.assertEquals('SendTermsAcceptance', actual);
    }
}