public class IECEBC_ETPortfolioCreate {
	class UnexpectedResponse_Exception extends Exception{}

	public static void CreatePortfolioObject(Map<String, String> filenameToUrl){

		Http http = new Http();

		string xml = ''
			+ '<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://schemas.xmlsoap.org/ws/2004/08/addressing" xmlns:u="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">'
			+ '<s:Header>'
			+ '<a:Action s:mustUnderstand="1">Create</a:Action>'
			+ '<a:MessageID>urn:uuid:db7625ad-b909-48f7-a9e6-9819f5bd3ddb</a:MessageID>'
			+ '<a:ReplyTo>'
			+ '<a:Address>http://schemas.xmlsoap.org/ws/2004/08/addressing/role/anonymous</a:Address>'
			+ '</a:ReplyTo>'
			+ '<a:To s:mustUnderstand="1">'
			+ IECEBC_ETInit.ProductionEndpoint
			+ '</a:To>'
			+ '<o:Security xmlns:o="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" s:mustUnderstand="1">'
			+ '<o:UsernameToken>'
			+ '<o:Username>kejia.hu@cgi.com</o:Username>'
			+ '<o:Password>Alban2016%</o:Password>'
			+ '</o:UsernameToken>'
			+ '</o:Security>'
			+ '</s:Header>'
			+ '<s:Body xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'
			+ '<CreateRequest xmlns="http://exacttarget.com/wsdl/partnerAPI">'
			+ '<Options/>'
			;

		for(String filename : filenameToUrl.keySet()) {
			xml += ''+
				'<ns1:Objects xsi:type="ns1:Portfolio" xmlns:ns1="http://exacttarget.com/wsdl/partnerAPI">'+
					'<ns1:PartnerKey xsi:nil="true"/>'+
					'<ns1:ModifiedDate xsi:nil="true"/>'+
					'<ns1:ObjectID xsi:nil="true"/>'+
					'<ns1:CustomerKey/>'+
					'<ns1:Source>'+
						'<ns1:PartnerKey xsi:nil="true"/>'+
						'<ns1:ModifiedDate xsi:nil="true"/>'+
						'<ns1:ObjectID xsi:nil="true"/>'+
						'<ns1:URN>' +
							IECEBC_ETHelper.xmlEncode(filenameToUrl.get(filename)) +
						'</ns1:URN>'+
					'</ns1:Source>'+
					'<ns1:FileName>' +
						IECEBC_ETHelper.xmlEncode(filename) +
					'</ns1:FileName>'+
				'</ns1:Objects>';
		}

		xml += ''+
			'</CreateRequest>'+
			'</s:Body>'+
			'</s:Envelope>';

		System.debug(xml);

		HttpRequest req = new HttpRequest();
		req.setEndpoint(IECEBC_ETInit.ProductionEndpoint);
		req.setMethod('POST');
		req.setHeader('SOAPAction','Create');
		req.setHeader('Content-Type','text/xml;charset=UTF-8');
		req.setBody(xml);

		string bodyRes = '';
		HttpResponse res = http.send(req);
		bodyRes = res.getBody();
		System.debug(bodyRes);
		if (res.getStatusCode() == 200) {
			system.debug('Access success!');
			system.debug('Soapponse:' + bodyRes);
			if (IECEBC_ETHelper.parse(res, 'StatusCode') != 'OK') {
				System.debug(IECEBC_ETHelper.parse(res, 'StatusMessage'));
				throw new UnexpectedResponse_Exception('Unexpected Response');
			}
		}else{
			system.debug('This is a bad request!');
			throw new UnexpectedResponse_Exception('Unexpected Response');
		}
	}

	public static void CreateListPortfolioObjects(String restWS, String EBCResourceId){
		List<Attachment> attList = [SELECT Id, Name, Body, ContentType FROM Attachment WHERE ParentId = :EBCResourceId];
		Integer i = 0;
		for(Attachment a : attList){
			i ++;
			CreatePortfolioObject(restWS, 'att-' + i + '-' + a.Name, a.Id);
		}
	}

	public static void CreatePortfolioObject(String restWS, String fileName, String attachmentId){

		Http http = new Http();

		string xml ='<s:Envelope xmlns:s="http://www.w3.org/2003/05/soap-envelope" xmlns:a="http://schemas.xmlsoap.org/ws/2004/08/addressing" xmlns:u="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd">'+
			'<s:Header>'+
			'<a:Action s:mustUnderstand="1">Create</a:Action>'+
			'<a:MessageID>urn:uuid:db7625ad-b909-48f7-a9e6-9819f5bd3ddb</a:MessageID>'+
			'<a:ReplyTo>'+
			'<a:Address>http://schemas.xmlsoap.org/ws/2004/08/addressing/role/anonymous</a:Address>' +
			'</a:ReplyTo>'+
			'<a:To s:mustUnderstand="1">' +
			IECEBC_ETInit.ProductionEndpoint +
			'</a:To>'+
			'<o:Security xmlns:o="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" s:mustUnderstand="1">'+
			'<o:UsernameToken>'+
			'<o:Username>kejia.hu@cgi.com</o:Username>'+
			'<o:Password>Alban2016%</o:Password>'+
			'</o:UsernameToken>'+
			'</o:Security>'+
			'</s:Header>'+
			'<s:Body xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">'+
			'<CreateRequest xmlns="http://exacttarget.com/wsdl/partnerAPI">'+
			'<Options/>'+
		   	'<ns1:Objects xsi:type="ns1:Portfolio" xmlns:ns1="http://exacttarget.com/wsdl/partnerAPI">'+
			'<ns1:PartnerKey xsi:nil="true"/>'+
			'<ns1:ModifiedDate xsi:nil="true"/>'+
			'<ns1:ObjectID xsi:nil="true"/>'+
			'<ns1:CustomerKey/>'+
			'<ns1:Source>'+
			'<ns1:PartnerKey xsi:nil="true"/>'+
			'<ns1:ModifiedDate xsi:nil="true"/>'+
			'<ns1:ObjectID xsi:nil="true"/>'+
			'<ns1:URN>' +
			IECEBC_ETInit.IECRestAPI +
			IECEBC_ETHelper.xmlEncode(restWS) +
			'/' +
			IECEBC_ETHelper.xmlEncode(attachmentId) +
			'</ns1:URN>'+
			'</ns1:Source>'+
			'<ns1:FileName>' +
				IECEBC_ETHelper.xmlEncode(fileName) +
			'</ns1:FileName>'+
			'</ns1:Objects>' +
			'</CreateRequest>'+
			'</s:Body>'+
			'</s:Envelope>';

		HttpRequest req = new HttpRequest();
		req.setEndpoint(IECEBC_ETInit.ProductionEndpoint);
		req.setMethod('POST');
		req.setHeader('SOAPAction','Create');
		req.setHeader('Content-Type','text/xml;charset=UTF-8');
		req.setBody(xml);

		string bodyRes = '';
		HttpResponse res = http.send(req);
		bodyRes = res.getBody();
		if (res.getStatusCode() == 200) {
			system.debug('Access success!');
			system.debug('Soapponse:' + bodyRes);
		}else{
			system.debug('This is a bad request!');
		}
	}
}
