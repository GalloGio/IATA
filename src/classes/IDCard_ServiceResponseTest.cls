@isTest
public class IDCard_ServiceResponseTest
{
	@isTest
	public static void testMakeServiceResponse()
	{
		Test.startTest();
		IDCard_ServiceResponse r = IDCard_ServiceResponse.makeExceptionServiceResponse(new DummyException('message'));
		new IDCard_ServiceResponse(); // because coverage...
		IDCard_ServiceResponse s = new IDCard_ServiceResponse(r.apiResponse);
		Test.stopTest();

		System.assert(s.apiResponse instanceOf IDCard_ServiceResponse.ErrorResponse);
	}

	@isTest
	public static void testMakeExceptionServiceResponse()
	{
		Test.startTest();
		Exception e = null;
		try
		{
			Account a = new Account();
			insert a; // error - no Name field defined
		}
		catch (DmlException ex)
		{
			e = ex;
		}
		IDCard_ServiceResponse r1 = IDCard_ServiceResponse.makeExceptionServiceResponse(e);
		IDCard_ServiceResponse r2 = IDCard_ServiceResponse.makeExceptionServiceResponse(new IDCard_MobileAppRenewalService.IDCardException('message'));
		IDCard_ServiceResponse r3 = IDCard_ServiceResponse.makeExceptionServiceResponse(new DummyException('message'));
		Test.stopTest();

		System.assert(r1.apiResponse instanceOf IDCard_ServiceResponse.UnsucessResponse);
		System.assert(r2.apiResponse instanceOf IDCard_ServiceResponse.ErrorResponse);
		System.assert(r3.apiResponse instanceOf IDCard_ServiceResponse.ErrorResponse);
	}
	
	@isTest
	public static void testMakeErrorServiceResponse()
	{
		Test.startTest();
		IDCard_ServiceResponse r = IDCard_ServiceResponse.makeErrorServiceResponse('message');
		Test.stopTest();

		System.assert(r.apiResponse instanceOf IDCard_ServiceResponse.ErrorResponse);
	}
	
	@isTest
	public static void testMakeCreatedServiceResponse()
	{
		Test.startTest();
		IDCard_ServiceResponse r = IDCard_ServiceResponse.makeCreatedServiceResponse('message');
		Test.stopTest();

		System.assert(r.apiResponse instanceOf IDCard_ServiceResponse.GenericResponse);
	}
	
	@isTest
	public static void testMakeGenericServiceResponse()
	{
		Test.startTest();
		IDCard_ServiceResponse r = IDCard_ServiceResponse.makeGenericServiceResponse(new List<String>());
		Test.stopTest();

		System.assert(r.apiResponse instanceOf IDCard_ServiceResponse.GenericResponse);
	}

	public class DummyException extends Exception { }
}
