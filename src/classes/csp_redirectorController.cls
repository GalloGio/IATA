public class csp_redirectorController {

	@AuraEnabled
	public static string redirectToLogin(string startUrl,string retURL,string communityName,string servicename,string ipAddress){

		if(!String.isBlank(ipAddress))	csp_redirectorController.findLocation(true,ipAddress);
		string oneIDStatus = 'OFF';
		string identityLogin = '/identity/s/login'; // will work on sandboxes
		string tempserviceName='ISSP'; // default value old portal
		string tempStart='%2FISSP_Homepage'; // default value old portal

		string oldLoginForm ='/issp_login?communityName='+communityName;
		if(String.isBlank(servicename))servicename=tempserviceName;

		if(ISSP_CS__c.getValues('1ID redirect').value__c != null){
			oneIDStatus = String.ValueOF(ISSP_CS__c.getValues('1ID redirect').value__c);
		}

		if(ISSP_CS__c.getValues('Identity Login Page') != null){
			identityLogin = String.ValueOF(ISSP_CS__c.getValues('Identity Login Page').value__c);
		}

		if(ISSP_CS__c.getValues('ISSP Landing Page') != null){
			serviceName = String.ValueOF(ISSP_CS__c.getValues('ISSP Landing Page').value__c);
			tempStart = String.ValueOF(ISSP_CS__c.getValues('ISSP Landing Page').defaultvalue__c);
		}

		if(ISSP_CS__c.getValues('CS Portal Redirect') != null){
			serviceName = String.ValueOF(ISSP_CS__c.getValues('CS Portal Redirect').value__c);
			tempStart = String.ValueOF(ISSP_CS__c.getValues('CS Portal Redirect').defaultvalue__c);
		}

		string newlocation='';
		if(startUrl != null){
			if(oneIDStatus == 'ON'){
				newlocation= identityLogin+'?startURL='+startUrl+'&serviceName='+serviceName;
			}else{
				newlocation= oldLoginForm;
			}
		}
		else if(communityName == null && startUrl == null){
			startUrl=tempStart;

			if(oneIDStatus == 'ON'){
				newlocation= identityLogin+'?startURL='+startUrl+'&serviceName='+serviceName;
			}else{
				newlocation= oldLoginForm;
			}
		}
		else{
			newlocation= oldLoginForm;
		}

		if(communityName != null && newlocation!=oldLoginForm){
			newlocation+='&communityName='+communityName;
		}

		return newlocation;
	}

	@AuraEnabled
	public static void findLocation(Boolean saveLog,string ipAddress){
		//Adapted method found in ISSP_Login
		string country = '';

		ISSP_CS__c cs = ISSP_CS__c.getInstance('ipinfo_token');
		String ipinfo_token = cs.value__c;

		ISSP_Web_Service_Log__c newLog = new ISSP_Web_Service_Log__c();
		newLog.Web_Service__c = 'IP_Info';
		newLog.Method__c = 'checkIpCountry';
		newLog.System__c = 'IpInfo';
		newLog.Login_Ip__c = ipAddress;
		newLog.Finished__c = system.now();

		String IP_LOOKUP_URL = 'https://ipinfo.io/' + ipAddress + '/json?token=' + ipinfo_token;
		Http h = new Http();
		HttpRequest req = new HttpRequest();
		req.setEndpoint(IP_LOOKUP_URL);
		req.setMethod('GET');
		req.setTimeout(2000);
		HttpResponse res;
		try{
			res = h.send(req);
			JSONParser parser = JSON.createParser(res.getBody());
			system.debug('message:' + String.valueOf(parser));
			while (parser.nextToken() != null) {
				if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) &&
					(parser.getText() == 'country')) {
					parser.nextToken();
					country = parser.getText();
				}
			}
			if (country != ''){
				newLog.Success__c = true;
				if (saveLog){
					insert newLog;
				}

				system.debug('country: ' + country);
				List <IATA_ISO_Country__c> countryList = IATAIsoCountryDAO.getIsoCountryByIsoCodes(new Set<String>{country});

			}
			else{
				newLog.Success__c = false;
				String theError = String.valueOf(parser);
				if (theError.length() > 254){
					newLog.Error_Message__c = theError.substring(0,254);
				}
				else{
					newLog.Error_Message__c = theError;
				}
				newLog.Finished__c = system.now();
				if (saveLog){
					insert newLog;
				}
			}
		}catch(Exception e){
			system.debug('Error: ' + e);
			newLog.Success__c = false;
			String theError = e.getMessage();
			if (theError.length() > 254){
				newLog.Error_Message__c = theError.substring(0,254);
			}
			else{
				newLog.Error_Message__c = theError;
			}
			newLog.Finished__c = system.now();
			if (saveLog){
				insert newLog;
			}
		}

		if (ipAddress != '' && ipAddress != null && country == ''){
			List <String> ipList = ipAddress.split('\\.');
			Decimal ipInteger_1 = Decimal.valueOf(ipList[0]);
			Decimal ipInteger_2 = Decimal.valueOf(ipList[1]);
			Decimal ipInteger_3 = Decimal.valueOf(ipList[2]);
			Decimal ipInteger_4 = Decimal.valueOf(ipList[3]);
			Decimal ipTotal = (ipInteger_1*256*256*256) + (ipInteger_2*256*256) + (ipInteger_3*256) + (ipInteger_4);
		}

	}
}
