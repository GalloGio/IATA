/*
 * Create Sender Profile by using current user Info
 * In Sender Profile, we define FromName and FromEmail
 * */

public class IECEBC_ETSenderProfileCreate {

	class UnexpectedResponse_Exception extends Exception{}

	public Static String createSenderProfile(String name, String customerKey, String fromName, String fromEmail){
		String SenderProfileId = '';

		//Using SF current user for sender information

		//From name = User full name in SF (To be comfirm by Abdella)
		//String userName = userInfo.getName();
		// Sender Customer Key is same as User SF ID
		//Id userId = userInfo.getUserId();

		//From email = User Email in SF (To be comfirm by Abdella)
		//String userEmail = userInfo.getUserEmail();
		String senderKey = ''; //contain Customer Key that will be used in Send Classification

		String bodyContent =
			'<CreateRequest xmlns="http://exacttarget.com/wsdl/partnerAPI">' +
			'<Objects xsi:type="SenderProfile">' +
			'<PartnerKey xsi:nil="true"/>' +
			'<ObjectID xsi:nil="true"/>' +
			'<Name>' + IECEBC_ETHelper.xmlEncode(name) + '</Name>' +
			'<CustomerKey>' + IECEBC_ETHelper.xmlEncode(customerKey) + '</CustomerKey>' +
			'<FromName>' + IECEBC_ETHelper.xmlEncode(fromName) + '</FromName>' +
			'<FromAddress>' + IECEBC_ETHelper.xmlEncode(fromEmail) + '</FromAddress>' +
			' </Objects>' +
			'</CreateRequest>';

		HttpRequest req = new HttpRequest();
		Http http = new Http();
		req.setTimeout(IECEBC_ETInit.TimeOut);
		IECEBC_ETHelper.SetSoapRequest(req, 'Create', bodyContent);

		HttpResponse res = http.send(req);
		system.debug('Sender Profile Create response:' + res.getBody());
		if (res.getStatusCode() == 200) {

			 if (IECEBC_ETHelper.parse(res, 'StatusCode') != 'OK') {
				System.debug(IECEBC_ETHelper.parse(res, 'StatusMessage'));
				throw new UnexpectedResponse_Exception('Unexpected Response');
			}
			senderKey = IECEBC_ETHelper.parse(res, 'CustomerKey');
			system.debug('Sender Profile creation finished with id :' + senderKey);
			return senderKey;
		} else{
			System.debug(res);
			throw new UnexpectedResponse_Exception('Unexpected Response');
		}
	}
}
