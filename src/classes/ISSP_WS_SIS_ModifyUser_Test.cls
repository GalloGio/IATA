@isTest
private class ISSP_WS_SIS_ModifyUser_Test {
	
	static testMethod void test_declareVariables() {
		ISSP_WS_SIS_ModifyUser.UpdateSisUserResponse_element elem1 = new ISSP_WS_SIS_ModifyUser.UpdateSisUserResponse_element();
		ISSP_WS_SIS_ModifyUser.UpdateSisUser_element elem2 = new ISSP_WS_SIS_ModifyUser.UpdateSisUser_element();
	}

	static testMethod void test_callouts() {
		ISSP_WS_SIS_ModifyUser.IcpWsInterfaceSoap request = new ISSP_WS_SIS_ModifyUser.IcpWsInterfaceSoap();

    	Test.setMock(WebServiceMock.class, new IcpWsInterfaceSoapMock('UpdateSisUserResponse_element'));
    	request.UpdateSisUser('request', true);

	}


	public class IcpWsInterfaceSoapMock implements WebServiceMock {

	    private String responseType = 'ISSP_WS_SIS_ModifyUser.';

	    public IcpWsInterfaceSoapMock(String className){
	        this.responseType += className;
	    }

	    public void doInvoke(
	           Object stub,
	           Object request,
	           Map<String, Object> response,
	           String endpoint,
	           String soapAction,
	           String requestName,
	           String responseNS,
	           String responseName,
	           String responseType) {

	        Object responseElement = Type.forName(responseType).newInstance();
	        response.put('response_x', responseElement); 
	   }
	}
}