public class AMS_2_MDM_WS_AgencyList {

	public class HTTP_Port {

		//QA
	  //public String endpoint_x = AMS_SAP_Settings__c.getOrgDefaults().Web_Service_endpoint__c + '?senderParty=&senderService=SFDC&receiverParty=&receiverService=&interface=SI_SFDC_AgencyList_OB&interfaceNamespace=http%3A%2F%2Fiata.com%2Fxi%2FSFDC%2FMDM%2FWID5700_AgencyDetails%2F';
		//PRE-PROD
		public String endpoint_x = AMS_SAP_Settings__c.getOrgDefaults().Web_Service_endpoint__c + '?senderParty=&senderService=SFDC&receiverParty=&receiverService=&interface=SI_SFDC_AgencyList_OB&interfaceNamespace=http%3A%2F%2Fiata.com%2Fxi%2FSFDC%2FMDM%2FWID5700_AgencyDetails%2F';


		public Map<String,String> inputHttpHeaders_x;
		public Map<String,String> outputHttpHeaders_x;
		public String clientCertName_x;
		public String clientCert_x;
		public String clientCertPasswd_x;
		public Integer timeout_x;
		private String[] ns_map_type_info = new String[]{'http://iata.com/xi/SFDC/MDM/WID5700_AgencyDetails/','AMS_2_MDM_WS_AgencyDetails'};

		private DOM.XmlNode populateDoc(DOM.Document doc,String s){
			String env = 'http://schemas.xmlsoap.org/soap/envelope/';
			String xsi = 'http://www.w3.org/2001/XMLSchema-instance';
			String xsd = 'http://www.w3.org/2001/XMLSchema';

			DOM.XmlNode envelope = doc.createRootElement('Envelope', env, 'soapenv');
			//envelope.setNamespace('xsd', xsd);
			//envelope.setNamespace('xsi', xsi);
			DOM.XmlNode header = envelope.addChildElement('Header', env, 'soapenv');
			AddHeader(header);

			DOM.XmlNode body = envelope.addChildElement('Body', env, 'soapenv');


			return body;

		}

		private void AddHeader(DOM.XmlNode header){
		}

		public String SI_SFDC_AgencyList_OB_Http(String s, String  authorizationHeader) {

			String sRespStatusCode = '';

			//need to remove the tag in order for the 2nd parse to work!
			s = s.remove('<?xml version="1.0" encoding="UTF-8"?>');

			DOM.Document doc = new DOM.Document();
			DOM.XmlNode body = populateDoc(doc,s);

			body.addTextNode('AgencyList');


			//Need to parse the doc again because of SFDC issue on the "<" char...
			String s2 = doc.toXmlString().replace('AgencyList',s);
			DOM.Document doc2 = new DOM.Document();
			doc2.load(s2);

			System.debug('---http message: ' + doc2.toXmlString());

			HttpRequest req = new HttpRequest();
			req.setEndpoint(endpoint_x);
			req.setMethod('POST');
			req.setHeader('Content-Type', 'text/xml; charset=UTF-8');
			req.setHeader('SOAPAction', 'http://sap.com/xi/WebService/soap1.1');
			req.setHeader('Authorization', authorizationHeader);
			req.setTimeout(timeout_x);

			req.setBodyDocument(doc2);
			System.debug('-----req.getBody: ' + req.getBody());

			if(!Test.isRunningTest()) {
				Http http = new Http();
				HTTPResponse res = http.send(req);
				//System.debug('-----res: ' + res);
				//System.debug('-----res.getBody: ' + res.getBody());
				System.debug('-----res.getStatusCode: ' + res.getStatusCode());

				sRespStatusCode = String.valueOf(res.getStatusCode());
			}else{
				sRespStatusCode = '200';
			}

			//Dom.Document responseDoc = res.getBodyDocument();
			//Dom.XmlNode rootNode = responseDoc.getRootElement();
			//Dom.XmlNode bodyNode = rootNode.getChildElement('Body','http://schemas.xmlsoap.org/soap/envelope/');
			//Dom.XmlNode AgencyListRespNode = bodyNode.getChildElement('xmln.AgencyListResp', 'http://iata.com/xi/SFDC/MDM/WID5700_AgencyDetails/');

			return sRespStatusCode;
		}
	}
}
