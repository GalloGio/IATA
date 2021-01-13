public class IECEBC_ETImage {

	// get status of image from ExactTarget
	Public static Map<String, Object> getImageStatus(String fileName) {
		// http instances and variables
		Http http = new Http();
		HttpRequest req = new HttpRequest();
		Map<String, Object> status = new Map<String, Object>();

		// header
		IECEBC_ETHelper.setSoapRequestHeader(req, 'Retrieve');
		// body
		// fileName = 'TestAug10.jpg'
		req.setBody(
			IECEBC_ETHelper.createXMLHeader()
			+ IECEBC_ETHelper.retrieveRequestImage(fileName)
			+ IECEBC_ETHelper.createXMLFooter()
		);
		//System.debug(req.getBody());
		req.setTimeout(IECEBC_ETInit.TimeOut);
		//system.debug('ImageStatus request body: ' + req.getBody());
		// get response
		//
		System.debug(req.getBody());
		HTTPResponse response;
		if (!Test.isRunningTest()) {
			response = http.send(req);
		} else {
			response = new HTTPResponse();
			response.setStatusCode(200);
			response.setBody('<?xml version="1.0" encoding="utf-8"?><soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:wsa="http://schemas.xmlsoap.org/ws/2004/08/addressing" xmlns:wsse="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-secext-1.0.xsd" xmlns:wsu="http://docs.oasis-open.org/wss/2004/01/oasis-200401-wss-wssecurity-utility-1.0.xsd"><soap:Header><wsa:Action>RetrieveResponse</wsa:Action><wsa:MessageID>urn:uuid:15167e1a-0a44-49b9-9265-17d701d94a53</wsa:MessageID><wsa:RelatesTo>urn:uuid:8474103d-de71-419a-be8a-6cd4b544f23f</wsa:RelatesTo><wsa:To>http://schemas.xmlsoap.org/ws/2004/08/addressing/role/anonymous</wsa:To><wsse:Security><wsu:Timestamp wsu:Id="Timestamp-656abaaf-613c-4a63-a7ae-02f8b18f6edb"><wsu:Created>2016-11-10T18:44:59Z</wsu:Created><wsu:Expires>2016-11-10T18:49:59Z</wsu:Expires></wsu:Timestamp></wsse:Security></soap:Header><soap:Body><RetrieveResponseMsg xmlns="http://exacttarget.com/wsdl/partnerAPI"><OverallStatus>OK</OverallStatus><RequestID>2ac37278-9461-4068-823e-226aa6ebe900</RequestID><Results xsi:type="Portfolio"><Client><ID>7237978</ID></Client><PartnerKey xsi:nil="true" /><ObjectID xsi:nil="true" /><CustomerKey>fe9b2b61-1505-434b-a633-c6710df07a6d</CustomerKey><CategoryID>739</CategoryID><FileName>a7d8E000000CbtyQAC.jpg</FileName><DisplayName>a7d8E000000CbtyQAC</DisplayName><Description /><TypeDescription>JPEG Image</TypeDescription><IsUploaded>true</IsUploaded><IsActive>true</IsActive><FileSizeKB>149</FileSizeKB><ThumbSizeKB>3</ThumbSizeKB><FileWidthPX>800</FileWidthPX><FileHeightPX>489</FileHeightPX><FileURL>http://image.S7.exacttarget.com/lib/fe84137276630d7a7d/m/1/a7d8E000000CbtyQAC.jpg</FileURL><ThumbURL>http://image.S7.exacttarget.com/lib/fe84137276630d7a7d/m/1/thumb/jpg/a7d8E000000CbtyQAC.jpg</ThumbURL></Results></RetrieveResponseMsg></soap:Body></soap:Envelope>');
		}
		System.debug(response.getBody());
		status.put('IsUploaded', false);
		if (response.getStatusCode() == 200) {
			status.put('IsUploaded', IECEBC_ETHelper.parse(response, 'IsUploaded') == 'true');
			status.put('Width', IECEBC_ETHelper.parse(response, 'FileWidthPX'));
			status.put('Height', IECEBC_ETHelper.parse(response, 'FileHeightPX'));
			status.put('Image_Url', IECEBC_ETHelper.parse(response, 'FileURL'));
			status.put('Thumb_Url', IECEBC_ETHelper.parse(response, 'ThumbURL'));
		}
		// return Image instance
		return status;
	}
}
