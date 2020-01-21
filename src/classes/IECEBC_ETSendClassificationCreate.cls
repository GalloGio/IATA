/*
* Create Send Classification for Triggered Send using name 'API_Creation_Test' for test
* In Send Classification, we define Sender Profile and Delievery Profile
*
*/

public class IECEBC_ETSendClassificationCreate {

	class UnexpectedResponse_Exception extends Exception{}

	public Static String createSendClassification(String name, String customerKey, String senderCustomerKey){

		String sendClassificationId = '';
		//Define Sender Profile as the user who send the emails (To be comfirm by Abdella)
		//String senderCustomerKey = IECEBC_ETSenderProfileCreate.createSenderProfile();
		//Using a default ET Delivery profile : Shawi_DP
		//Shawi_DP contans default Delivery information of the account: IP address, Header, Footer
		String deliveryCustomerKey = 'eBroadcast';
		String bodyContent =
			'<CreateRequest xmlns="http://exacttarget.com/wsdl/partnerAPI">' +
			'<Options/>' +
			'<Objects xsi:type="SendClassification">' +
			'<PartnerKey xsi:nil="true" />' +
			'<ObjectID xsi:nil="true" />'+
			'<Name>' + IECEBC_ETHelper.xmlEncode(name) + '</Name>' +
			'<CustomerKey>' + IECEBC_ETHelper.xmlEncode(customerKey) + '</CustomerKey>' +
			'<SenderProfile>' +
			'<CustomerKey>' + IECEBC_ETHelper.xmlEncode(senderCustomerKey) + '</CustomerKey>' +
			'</SenderProfile>' +
			'<DeliveryProfile>' +
			'<CustomerKey>' + IECEBC_ETHelper.xmlEncode(deliveryCustomerKey) +'</CustomerKey>' +
			'</DeliveryProfile>' +
			'</Objects>' +
			'</CreateRequest>';

		HttpRequest req = new HttpRequest();
		Http http = new Http();
		req.setTimeout(IECEBC_ETInit.TimeOut);
		IECEBC_ETHelper.SetSoapRequest(req, 'Create', bodyContent);

		HttpResponse res = http.send(req);
		system.debug('Send Classification Create response:' + res.getBody());
		if (res.getStatusCode() == 200) {

			 if (IECEBC_ETHelper.parse(res, 'StatusCode') != 'OK') {
				System.debug(IECEBC_ETHelper.parse(res, 'StatusMessage'));
				throw new UnexpectedResponse_Exception('Unexpected Response');
			}
			sendClassificationId = IECEBC_ETHelper.parse(res, 'ObjectID');
			system.debug('Send Classification creation finished with id :' + sendClassificationId);
			return sendClassificationId;
		} else{
			System.debug(res);
			throw new UnexpectedResponse_Exception('Unexpected Response');
		}
	}
}
