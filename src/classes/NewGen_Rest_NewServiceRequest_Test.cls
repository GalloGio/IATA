@isTest
private class NewGen_Rest_NewServiceRequest_Test
{
	private static Contact c;
	private static Portal_Applications__c p;

	private static void loadData(){
		c = new Contact();
        c.FirstName = 'test';
        c.LastName = 'test';
        c.Email = 'ISSP_test@test.test';
        insert c;

        p = new Portal_Applications__c();
        insert p;
	}

	@isTest
	static void testNewRequest()
	{
		loadData();
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		req.requestURI = '/newgenapp/v1/newServiceRequest/SendNewServiceRequest/';
		req.httpMethod = 'POST';

		JSONGenerator gen = JSON.createGenerator(true);
		gen.writeStartObject();
		gen.writeStringField('portalId', p.Id);
		gen.writeStringField('contactId', c.Id);
		gen.writeEndObject();

		Blob reqbody = Blob.valueof(gen.getAsString());

		req.requestBody = reqbody;


		RestContext.request = req;
		RestContext.response= res;

		Test.startTest();
			String actual = NewGen_Rest_NewServiceRequest.SendNewServiceRequest();
		Test.stopTest();

		System.assertEquals('SentServiceRequest', actual);
	}

	@isTest
	static void testErrorNewRequest()
	{
		loadData();
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		req.requestURI = '/newgenapp/v1/newServiceRequest/SendNewServiceRequest/';
		req.httpMethod = 'POST';

		JSONGenerator gen = JSON.createGenerator(true);
		gen.writeStartObject();
		gen.writeStringField('portalId', 'badID');
		gen.writeStringField('contactId', c.Id);
		gen.writeEndObject();

		Blob reqbody = Blob.valueof(gen.getAsString());

		req.requestBody = reqbody;


		RestContext.request = req;
		RestContext.response= res;

		Test.startTest();
			String actual = NewGen_Rest_NewServiceRequest.SendNewServiceRequest();
		Test.stopTest();

		System.assertEquals('SentServiceRequest', actual);
	}
}