@isTest
	private class partnerSoapSforceCom_tst {

	static testMethod void test_declareVariables() {
		partnerSoapSforceCom.Login_element elem68 = new partnerSoapSforceCom.Login_element();
		partnerSoapSforceCom.LoginResponse_element elem10 = new partnerSoapSforceCom.LoginResponse_element();
		partnerSoapSforceCom.LoginScopeHeader_element elem148 = new partnerSoapSforceCom.LoginScopeHeader_element();
		partnerSoapSforceCom.LoginResult elem99 = new partnerSoapSforceCom.LoginResult();
		partnerSoapSforceCom.GetUserInfoResult elem120 = new partnerSoapSforceCom.GetUserInfoResult();
	}

	public class partnerSoapMock implements WebServiceMock {

	private String responseType = 'partnerSoapSforceCom.';

	public partnerSoapMock(String className){
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

	static testMethod void test_callouts() {
		partnerSoapSforceCom.Soap request = new partnerSoapSforceCom.Soap();
		Test.setMock(WebServiceMock.class, new partnerSoapMock('loginResponse_element'));
		request.login('test','test');
	}
}