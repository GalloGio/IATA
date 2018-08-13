public with sharing class OneId_AddressDoctor {

    private static final String login = Label.ICAddressDoctor_login;
    private static final String password = Label.ICAddressDoctor_password;
    private static final String url = Label.ICAddressDoctor_url;
    private static final String ns = Label.ICAddressDoctor_ns;
    private static final String adns = Label.ICAddressDoctor_adns;

	private class AddressResponse {
		private String processStatus;
		private List<AddressInfo> addresses;
	}

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
    public static List<AddressInfo> quickSearch(String userInput, String countryCode) {
        Map<String, String> addressInformation = new Map<String, String>();
        addressInformation.put('Country', countryCode);
        addressInformation.put('Street', userInput);

        AddressResponse r = getAddressInformation(addressInformation, 'FASTCOMPLETION');

        System.debug(loggingLevel.FINE, '____ [cls OneId_AddressDoctor - quickSearch] response - ' + r);
        return r.addresses;
    }

    public static Boolean isValidAddress(AddressInfo info, String countryCode) {

    	Map<String, String> addressInformation = new Map<String, String>();
    	addressInformation.put('Country', countryCode);
    	if(String.isNotEmpty(info.street)) addressInformation.put('Street', info.street);
    	if(String.isNotEmpty(info.locality)) addressInformation.put('Locality', info.locality);
    	if(String.isNotEmpty(info.postalCode)) addressInformation.put('PostalCode', info.postalCode);
    	if(String.isNotEmpty(info.province)) addressInformation.put('Province', info.province);

        AddressResponse r = getAddressInformation(addressInformation, 'CERTIFIED');

        Set<String> validResponses = new Set<String>{'V4','V3','C4'};
        return validResponses.contains(r.processStatus);
        /*
        Dom.XmlNode resultData = resultDataSet.getChildren()[0]; // 1st result of suggestion

        if(resultData != null) {
            Dom.XmlNode resultNode = resultData.getChildElement('ResultPercentage', adns);
                String resultPercentage = resultNode.getText();
            if(resultPercentage=='100.00') { // If we have 100%, it's a valid address
                return true;
            }
        }
        return false; // Otherwise, it's not a correct address*/

    }

    public static AddressResponse getAddressInformation(Map<String, String> addressInformation, String mode) {

        // Get address validation response from Informatica Address Doctor
        String body = buildSoapRequest(addressInformation, mode);
        String xmlResponse = callout('POST', body, new map<String, String>{'Content-Type'=>'text/xml'});

        System.debug(loggingLevel.FINE, '____ [cls OneId_AddressDoctor - getAddressInformation] body - ' + body);
        System.debug(loggingLevel.FINE, '____ [cls OneId_AddressDoctor - getAddressInformation] xmlResponse - ' + xmlResponse);

        // Parse response to get suggestions from the service
        Dom.Document doc = new Dom.Document();
        doc.load(xmlResponse);

        Dom.XmlNode result = doc.getRootElement().getChildElement('Body', ns).getChildElements()[0].getChildElements()[0].getChildElement('Results', adns).getChildElement('Result', adns);
        Dom.XmlNode resultDataSet = result.getChildElement('ResultDataSet', adns);
        
        AddressResponse response = new AddressResponse();
        response.processStatus = result.getChildElement('ProcessStatus', adns).getText();

        List<AddressInfo> adds = new List<AddressInfo>();
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

            if(String.isEmpty(address.deliveryAddressLines) && String.isEmpty(address.street)) continue;

            adds.add(address);
        }
        response.addresses = adds;

        return response;
    }

	private static String buildSoapRequest(Map<String, String> addressInformation, String mode) {

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
							soapEnv+= '<v4:MaxResultCount>10</v4:MaxResultCount>';
							soapEnv+= '<v4:FormatWithCountry>false</v4:FormatWithCountry>';
							soapEnv+= '<v4:StreetWithNumber>true</v4:StreetWithNumber>';
							soapEnv+= '<v4:RangesToExpand>ALL</v4:RangesToExpand>';
							soapEnv+= '<v4:CountryType>ISO2</v4:CountryType>';
						soapEnv+= '</v4:ValidationParameters>';
					soapEnv+= '</v4:parameters>';

					soapEnv+= '<v4:addresses>';
						soapEnv+= '<v4:Address>';

							for(String addressField : addressInformation.keySet()){
								soapEnv+= '<v4:'+addressField+'>';
									soapEnv+= '<v4:string>'+addressInformation.get(addressField)+'</v4:string>';
								soapEnv+= '</v4:'+addressField+'>';
							}
						soapEnv+= '</v4:Address>';
					soapEnv+= '</v4:addresses>';
				soapEnv+= '</v4:Process>';
			soapEnv+= '</soapenv:Body>';
		soapEnv+= '</soapenv:Envelope>';
		return soapEnv;
	}

    private static string callout(String method, String body, map<String, String> requestHeaders) {

        Http h = new Http();
        HttpRequest req = new HttpRequest();
        req.setEndpoint(url);
        req.setMethod(method);
        if(requestHeaders != null) {
            for (String key : requestHeaders.keySet()){
                req.setHeader(key, requestHeaders.get(key));
            }
        }
        req.setBody(body);

        HttpResponse res = h.send(req);
        return res.getBody();
    }
}
