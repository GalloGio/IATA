@isTest
private class NewGen_Rest_ToggleFavouriteService_Test
{
	private static Contact c;
	private static Portal_Applications__c p;
	private static Portal_Application_Right__c pr;

	private static void loadData(){
		c = new Contact();
        c.FirstName = 'test';
        c.LastName = 'test';
        c.Email = 'ISSP_test@test.test';
        insert c;

        p = new Portal_Applications__c();
        insert p;

        String appRight = 'Access Granted';

        pr = new Portal_Application_Right__c(Contact__c = c.Id,Portal_Application__c = p.Id, Right__c = appRight);
        insert pr;
	}

	@isTest
	static void testToggle()
	{
		loadData();
		RestRequest req = new RestRequest();
		RestResponse res = new RestResponse();
		req.requestURI = '/newgenapp/v1/toggleServiceFavouriteField/ToggleServiceFavouriteField/';
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
			String actual = NewGen_Rest_ToggleFavouriteService.ToggleServiceFavouriteField();
		Test.stopTest();

		System.assertEquals('FavouriteToggled', actual);
	}
}