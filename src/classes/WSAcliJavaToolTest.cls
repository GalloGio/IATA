@isTest
public class WSAcliJavaToolTest {

	private class WebServiceMockImpl implements WebServiceMock {
		public void doInvoke(
			Object stub, Object request, Map<String, Object> response,
			String endpoint, String soapAction, String requestName,
			String responseNS, String responseName, String responseType) {

			if(request instanceof WSAcliJavaTool.deleteFileFromServer_element) {
				WSAcliJavaTool.deleteFileFromServerResponse_element responseElem = new WSAcliJavaTool.deleteFileFromServerResponse_element();
				response.put('response_x', responseElem);
			}
			if(request instanceof WSAcliJavaTool.getFileFromServer_element) {
				WSAcliJavaTool.getFileFromServerResponse_element responseElem = new WSAcliJavaTool.getFileFromServerResponse_element();
				response.put('response_x', responseElem);
			}
			return;
		}
	}

	private static testMethod void coverMethods() {
		test.startTest();
		System.Test.setMock(WebServiceMock.class, new WebServiceMockImpl());
		WSAcliJavaTool.AcliJavaTool acliJavaTool = new WSAcliJavaTool.AcliJavaTool();
		acliJavaTool.deleteFileFromServer('confname');
		acliJavaTool.getFileFromServer('confname');
		test.stopTest();
	}

}
