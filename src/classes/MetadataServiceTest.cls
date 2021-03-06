@isTest
private class MetadataServiceTest
{
	private class WebServiceMockImpl implements WebServiceMock
	{
		public void doInvoke(
			Object stub, Object request, Map<String, Object> response,
			String endpoint, String soapAction, String requestName,
			String responseNS, String responseName, String responseType)
		{
			if(request instanceof MetadataService.updateMetadata_element)
				response.put('response_x', new MetadataService.updateMetadataResponse_element());
			else if(request instanceof  MetadataService.deleteMetadata_element)
				response.put('response_x', new MetadataService.deleteMetadataResponse_element());
			return;
		}
	}

	@IsTest
	private static void coverGeneratedCodeCRUDOperations()
	{
		System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
		MetadataService metaDataService = new MetadataService();
		Test.startTest();
		MetadataService.MetadataPort metaDataPort = new MetadataService.MetadataPort();
		Test.stopTest();
	}

	@IsTest
	private static void coverGeneratedCodeFileBasedOperations1()
	{
		System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
		MetadataService metaDataService = new MetadataService();
		Test.startTest();
		MetadataService.MetadataPort metaDataPort = new MetadataService.MetadataPort();
		metaDataPort.updateMetadata(null);
		Test.stopTest();
	}

	@IsTest
	private static void coverGeneratedCodeFileBasedOperations2()
	{
		System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
		MetadataService metaDataService = new MetadataService();
		Test.startTest();
		MetadataService.MetadataPort metaDataPort = new MetadataService.MetadataPort();
		metaDataPort.deleteMetadata(null, null);
		Test.stopTest();
	}

	@IsTest
	private static void coverGeneratedCodeTypes()
	{
		Test.startTest();
		new MetadataService();
		new MetadataService.NamedCredential();
		new MetadataService.SessionHeader_element();
		new MetadataService.Error();
		new MetadataService.ExtendedErrorDetails();
		new MetadataService.SaveResult();
		new MetadataService.DeleteResult();
		new MetadataService.deleteMetadata_element();
		new MetadataService.deleteMetadataResponse_element();
		new MetadataService.updateMetadata_element();
		new MetadataService.updateMetadataResponse_element();
		Test.stopTest();
	}
}