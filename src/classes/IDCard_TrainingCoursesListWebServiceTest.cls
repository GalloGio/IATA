@isTest
public class IDCard_TrainingCoursesListWebServiceTest
{
	@isTest
	public static void testValidRequest()
	{
		RestResponse response = new RestResponse();
		RestContext.response = response;

		RestRequest request = new RestRequest();
		RestContext.request = request;

		Test.startTest();
		IDCard_TrainingCoursesListWebService.doGet();
		Test.stopTest();

		Object actualResponse = getResponse(response);
		System.assertNotEquals(null, actualResponse);
		System.assert(actualResponse instanceof List<Object>, 'Value: ' + actualResponse);

		List<Object> listResponse = (List<Object>) actualResponse;
		Schema.DescribeFieldResult fieldResult = ID_Card_Application__c.Package_of_Travel_Professionals_Course_2__c.getDescribe();
		System.assertEquals(fieldResult.getPicklistValues().size(), listResponse.size());
		System.assert(listResponse.get(0) instanceof Map<String, Object>, 'Value: ' + listResponse.get(0));

		for (Object r : listResponse)
		{
			Map<String, Object> mapResponse = (Map<String, Object>) r;
			System.assert(mapResponse.containsKey('title'));
			System.assert(mapResponse.containsKey('description'));
			System.assert(String.isNotBlank((String) mapResponse.get('title')));
			System.assert(String.isNotBlank((String) mapResponse.get('description')), 'Description for: ' + mapResponse.get('title'));
		}
	}

	private static Object getResponse(RestResponse response)
	{
		String txt = response.responseBody.toString();
		return (Object) JSON.deserializeUntyped(txt);
	}
}
