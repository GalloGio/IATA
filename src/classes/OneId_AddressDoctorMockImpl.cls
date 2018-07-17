@isTest
global class OneId_AddressDoctorMockImpl implements HttpCalloutMock {
    
    global HTTPResponse respond(HTTPRequest req) {
        System.assertEquals('https://validator5.addressdoctor.com/webservice5/v4/addressvalidation.asmx', req.getEndpoint());
        System.assertEquals('POST', req.getMethod());
        
        // Create Address Doctor fake response
        HttpResponse res = new HttpResponse();
        res.setHeader('Content-Type', 'application/xml');
        res.setBody(mockResponse());
        res.setStatusCode(200);
        return res;
    }
    
    private String mockResponse() {
        String resp = '';
        resp += '<soap:Envelope xmlns:soap="http://schemas.xmlsoap.org/soap/envelope/" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">';
   resp += '<soap:Body>';
      resp += '<ProcessResponse xmlns="http://validator5.AddressDoctor.com/Webservice5/v4">';
         resp += '<ProcessResult>';
            resp += '<StatusCode>100</StatusCode>';
            resp += '<StatusMessage>OK</StatusMessage>';
            resp += '<JobToken>3d28b65c-d41f-4117-adb0-56d4addd9108</JobToken>';
            resp += '<Results>';
               resp += '<Result>';
                  resp += '<ProcessStatus>Q3</ProcessStatus>';
                  resp += '<CountryISO3>CHE</CountryISO3>';
                  resp += '<ResultDataSet>';
                     resp += '<ResultData>';
                        resp += '<ResultNumber>1</ResultNumber>';
                        resp += '<MailabilityScore>2</MailabilityScore>';
                        resp += '<ResultPercentage>85.22</ResultPercentage>';
                        resp += '<ElementInputStatus>60600040600000000060</ElementInputStatus>';
                        resp += '<ElementResultStatus>F0F08070F000000000E0</ElementResultStatus>';
                        resp += '<ElementRelevance>10100010100000000010</ElementRelevance>';
                        resp += '<ExtElementStatus>00505000000000000000</ExtElementStatus>';
                        resp += '<AddressResolutionCode>00000000000000000000</AddressResolutionCode>';
                        resp += '<AddressType>S</AddressType>';
                        resp += '<LanguageISO3>FRA</LanguageISO3>';
                        resp += '<Address>';
                           resp += '<Street>';
                              resp += '<string>avenue de l\'Avant-Poste</string>';
                           resp += '</Street>';
                           resp += '<HouseNumber>';
                              resp += '<string>5</string>';
                           resp += '</HouseNumber>';
                           resp += '<Locality>';
                              resp += '<string>Lausanne</string>';
                           resp += '</Locality>';
                           resp += '<PostalCode>';
                              resp += '<string>1005</string>';
                           resp += '</PostalCode>';
                           resp += '<Province>';
                              resp += '<string>VD</string>';
                           resp += '</Province>';
                           resp += '<Country>';
                              resp += '<string>CH</string>';
                           resp += '</Country>';
                           resp += '<DeliveryAddressLines>';
                              resp += '<string>avenue de l\'Avant-Poste 5</string>';
                           resp += '</DeliveryAddressLines>';
                           resp += '<CountrySpecificLocalityLine>';
                              resp += '<string>1005 Lausanne</string>';
                           resp += '</CountrySpecificLocalityLine>';
                           resp += '<FormattedAddress>';
                              resp += '<string>avenue de l\'Avant-Poste 5</string>';
                              resp += '<string>1005 Lausanne</string>';
                           resp += '</FormattedAddress>';
                           resp += '<AddressComplete>avenue de l\'Avant-Poste 5;1005 Lausanne</AddressComplete>';
                        resp += '</Address>';
                     resp += '</ResultData>';
				resp += '</ResultDataSet>';
               resp += '</Result>';
            resp += '</Results>';
         resp += '</ProcessResult>';
      resp += '</ProcessResponse>';
   resp += '</soap:Body>';
resp += '</soap:Envelope>';
        return resp;
    }
    
}