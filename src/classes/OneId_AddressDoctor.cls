public with sharing class OneId_AddressDoctor {
/**
			 ADDRESS VALIDATION
*/	
	public class AddressInfo {
		@AuraEnabled public String addressComplete {get;set;}
		@AuraEnabled public String street {get;set;}
		@AuraEnabled public String houseNumber {get;set;}
		@AuraEnabled public String locality {get;set;}
		@AuraEnabled public String postalCode {get;set;}
		@AuraEnabled public String province {get;set;}
		@AuraEnabled public String deliveryAddressLines {get;set;}
		@AuraEnabled public String countrySpecificLocalityLine {get;set;}
	}	

	@AuraEnabled
	public static List<AddressInfo> getSuggestedAddress(String userInput, String countryCode) {
		List<AddressInfo> adds = new List<AddressInfo>();

		// Get address validation reponse from Informatica Address Doctor
		String login = '162866';
		String password = 'Hus3esastAcr';
		String mode =  'FASTCOMPLETION';

		String soapRequest = buildSoapRequest(userInput, countryCode, login, password, mode);
		String url ='https://validator5.addressdoctor.com/webservice5/v4/addressvalidation.asmx';
		String xmlResponse = callout('POST', url, soapRequest, new map<String, String>{'Content-Type'=>'text/xml'});

		System.debug(loggingLevel.FINE, '____ [cls OneId_AddressDoctor - getSuggestedAddress] soapRequest - ' + soapRequest);
		System.debug(loggingLevel.FINE, '____ [cls OneId_AddressDoctor - getSuggestedAddress] xmlResponse - ' + xmlResponse);

		// Parse response to get suggestions from the service
		Dom.Document doc = new Dom.Document();
		doc.load(xmlResponse);
		String ns = 'http://schemas.xmlsoap.org/soap/envelope/';
		String adns = 'http://validator5.AddressDoctor.com/Webservice5/v4';
		Dom.XmlNode resultDataSet = doc.getRootElement().getChildElement('Body', ns).getChildElements()[0].getChildElements()[0].getChildElement('Results', adns).getChildElement('Result', adns).getChildElement('ResultDataSet', adns);

 
		for (Dom.XmlNode resultData : resultDataSet.getChildren()) {
			AddressInfo address =  new AddressInfo();
			Dom.XmlNode addressNode = resultData.getChildElement('Address', adns);

			Dom.XmlNode ad = addressNode.getChildElement('HouseNumber', adns);
			if(ad != null) address.houseNumber = ad.getChildElement('string', adns).getText();
			ad = addressNode.getChildElement('Street', adns);
			if(ad != null) address.street = ad.getChildElement('string', adns).getText();
			ad = addressNode.getChildElement('Locality', adns);
			if(ad != null) address.locality = ad.getChildElement('string', adns).getText();
			ad = addressNode.getChildElement('PostalCode', adns);
			if(ad != null) address.postalCode = ad.getChildElement('string', adns).getText();
			ad = addressNode.getChildElement('Province', adns);
			if(ad != null) address.province = ad.getChildElement('string', adns).getText();
			ad = addressNode.getChildElement('DeliveryAddressLines', adns);
			if(ad != null) address.deliveryAddressLines = ad.getChildElement('string', adns).getText();
			ad = addressNode.getChildElement('CountrySpecificLocalityLine', adns);
			if(ad != null) address.countrySpecificLocalityLine = ad.getChildElement('string', adns).getText();

			ad = addressNode.getChildElement('AddressComplete', adns);
	 		if(ad != null) address.addressComplete = ad.getText();

	 		if(address.addressComplete == null || address.deliveryAddressLines == null) continue;

			adds.add(address);
		}
		
		System.debug(loggingLevel.FINE, '____ [cls OneId_AddressDoctor - getSuggestedAddress] adds - ' + adds);
		return adds;
	}


	private static String buildSoapRequest(String address, String countryCode, String login, String password, String mode) {

		String soapEnv = '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:v4="http://validator5.AddressDoctor.com/Webservice5/v4">';
						soapEnv+= '<soapenv:Header/>';
						soapEnv+= '<soapenv:Body>';
							 soapEnv+= '<v4:Process>';
								soapEnv+= '<v4:login>'+login+'</v4:login>';
								soapEnv+= '<v4:password>'+password+'</v4:password>';
								soapEnv+= '<v4:parameters>';
									 soapEnv+= '<v4:ProcessMode>'+mode+'</v4:ProcessMode>';
									 soapEnv+= '<v4:ServiceParameters>';
										soapEnv+= '<v4:UseTransactionPool>PRODUCTION</v4:UseTransactionPool>';
									 soapEnv+= '</v4:ServiceParameters>';
									 soapEnv+= '<v4:ValidationParameters>';
										soapEnv+= '<v4:MaxResultCount>5</v4:MaxResultCount>';
										soapEnv+= '<v4:GlobalPreferredDescriptor>SHORT</v4:GlobalPreferredDescriptor>';
										soapEnv+= '<v4:FormatWithCountry>false</v4:FormatWithCountry>';
										soapEnv+= '<v4:StreetWithNumber>true</v4:StreetWithNumber>';
										soapEnv+= '<v4:CountryType>ISO2</v4:CountryType>';
									soapEnv+= '</v4:ValidationParameters>';
								soapEnv+= '</v4:parameters>';

								soapEnv+= '<v4:addresses>';
									 soapEnv+= '<v4:Address>';
										soapEnv+= '<v4:Country>';
											soapEnv+= '<v4:string>'+countryCode+'</v4:string>';
										soapEnv+= '</v4:Country>';
										soapEnv+= '<v4:AddressComplete>'+address+'</v4:AddressComplete>';
									 soapEnv+= '</v4:Address>';
								soapEnv+= '</v4:addresses>';
							 soapEnv+= '</v4:Process>';
						soapEnv+= '</soapenv:Body>';
					 soapEnv+= '</soapenv:Envelope>';
			 return soapEnv;
   }

	private static string callout(String verb, String url, String body, map<String, String> requestHeaders) {
		Http h = new Http();
			HttpRequest req = new HttpRequest();
			req.setEndpoint(url);
			req.setMethod(verb);
			if(requestHeaders != null) {
				for (String key : requestHeaders.keySet()){
					 req.setHeader(key, requestHeaders.get(key));
				}
			}
			if(body != null)
			 req.setBody(body);

			HttpResponse res = h.send(req);
			return res.getBody();
	}
}