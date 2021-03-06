@isTest
public class IDCard_TrainingCoursesFeeWebServiceTest
{
	@isTest
	public static void testValidRequest()
	{
		RestResponse response = new RestResponse();
		RestContext.response = response;

		RestRequest request = new RestRequest();
		request.params.put('iataCode', '12345678');
		RestContext.request = request;

		IDCard_TestDataHelper.createAccount();

		Test.startTest();
		IDCard_TrainingCoursesFeeWebService.doGet();
		Test.stopTest();

		Object actualResponse = getResponse(response);
		System.assertNotEquals(null, actualResponse);
		System.assert(actualResponse instanceof List<Object>, 'Value: ' + actualResponse);

		List<Object> listResponse = (List<Object>) actualResponse;
		System.assertEquals(1, listResponse.size());
		System.assert(listResponse.get(0) instanceof Map<String, Object>, 'Value: ' + listResponse.get(0));

		Map<String, Object> mapResponse = (Map<String, Object>) listResponse.get(0);
		System.assertEquals('EUR', mapResponse.get('CurrencyIsoCode'));
		System.assertEquals(100, mapResponse.get('IATA_Package__c'));
		System.assertEquals('Passenger', mapResponse.get('Type_Class_of_Agent__c'));
	}

	@isTest
	public static void testValidRequest_USAgent()
	{
		RestResponse response = new RestResponse();
		RestContext.response = response;

		RestRequest request = new RestRequest();
		request.params.put('iataCode', '87654321');
		RestContext.request = request;

		IDCard_TestDataHelper.createUSAccount();

		Test.startTest();
		IDCard_TrainingCoursesFeeWebService.doGet();
		Test.stopTest();

		Object actualResponse = getResponse(response);
		System.assertNotEquals(null, actualResponse);
		System.assert(actualResponse instanceof List<Object>, 'Value: ' + actualResponse);

		List<Object> listResponse = (List<Object>) actualResponse;
		System.assertEquals(1, listResponse.size());
		System.assert(listResponse.get(0) instanceof Map<String, Object>, 'Value: ' + listResponse.get(0));

		Map<String, Object> mapResponse = (Map<String, Object>) listResponse.get(0);
		System.assertEquals('USD', mapResponse.get('CurrencyIsoCode'));
		System.assertEquals(105, mapResponse.get('IATA_Package__c'));
		System.assertEquals('Passenger', mapResponse.get('Type_Class_of_Agent__c'));
	}

	@isTest
	public static void testInvalidRequest()
	{
		RestResponse response = new RestResponse();
		RestContext.response = response;

		RestRequest request = new RestRequest();
		request.params.put('iataCode', '1234567'); // invalid iataCode
		RestContext.request = request;

		IDCard_TestDataHelper.createAccount();

		Test.startTest();
		IDCard_TrainingCoursesFeeWebService.doGet();
		Test.stopTest();

		Object actualResponse = getResponse(response);
		System.assertNotEquals(null, actualResponse);
		System.assert(actualResponse instanceof Map<String, Object>);
		System.assertNotEquals(null, ((Map<String, Object>) actualResponse).get('message')); // The Agency with code <i>12345678</i> was not found.
	}

	private static Object getResponse(RestResponse response)
	{
		String txt = response.responseBody.toString();
		return (Object) JSON.deserializeUntyped(txt);
	}
}
