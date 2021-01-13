/**
 * Created by ukaya01 on 29/07/2019.
 */

public with sharing class PortalRegistrationUtils {

	public class UserLocation{
		@AuraEnabled
		public string countryCode{get;set;}
		@AuraEnabled
		public string country{get;set;}
		@AuraEnabled
		public string countryId{get;set;}
		@AuraEnabled
		public boolean isRestricted{get;set;}
	}

	@AuraEnabled
	public static UserLocation getUserLocation(String ipAddress){

		UserLocation loc = new UserLocation();
		loc.isRestricted = false;
		loc.country = null;
		loc.countryId = null;

		string country = '';
		string countryName = '';
		string countryId = '';

		ISSP_CS__c cs = ISSP_CS__c.getInstance('ipinfo_token');
		String ipinfo_token = cs.value__c;
		cs = ISSP_CS__c.getInstance('ipinfo_domain');
		String ipinfo_domain = cs.value__c;

		String IP_LOOKUP_URL = ipinfo_domain + ipAddress + '/json?token=' + ipinfo_token;
		Http h = new Http();
		HttpRequest req = new HttpRequest();
		req.setEndpoint(IP_LOOKUP_URL);
		req.setMethod('GET');
		req.setTimeout(2000);
		HttpResponse res;
		try{
			res = h.send(req);
			JSONParser parser = JSON.createParser(res.getBody());
			while (parser.nextToken() != null) {
				if ((parser.getCurrentToken() == JSONToken.FIELD_NAME) &&
						(parser.getText() == 'country')) {
					parser.nextToken();
					country = parser.getText();
				}
			}
			if (country != ''){
				List <IATA_ISO_Country__c> countryList = IATAIsoCountryDAO.getIsoCountryByIsoCodes(new Set<String>{country});
				if (!countryList.isEmpty()){
					countryName = countryList[0].Name;
					countryId = countryList[0].Id;
					if (countryList[0].Sanctioned_Country__c){
						loc.isRestricted = true;
					}
				}
			}
		}catch(Exception e){
			system.debug('Error Retrieving Location(ipinfo): ' + e.getMessage());
			return loc;
		}

		if ((ipAddress != '' && ipAddress != null && country == '') || test.isRunningTest()){
			List <String> ipList = ipAddress.split('\\.');
			Decimal ipInteger_1 = Decimal.valueOf(ipList[0]);
			Decimal ipInteger_2 = Decimal.valueOf(ipList[1]);
			Decimal ipInteger_3 = Decimal.valueOf(ipList[2]);
			Decimal ipInteger_4 = Decimal.valueOf(ipList[3]);
			Decimal ipTotal = (ipInteger_1*256*256*256) + (ipInteger_2*256*256) + (ipInteger_3*256) + (ipInteger_4);
			List <ISSP_IP_Locator__c> ipLocator = [SELECT Id, Country_Code__c FROM ISSP_IP_Locator__c WHERE Start_Integer__c <= :ipTotal AND End_Integer__c >= :ipTotal];
			if (!ipLocator.isEmpty()){
				country = ipLocator[0].Country_Code__c;
				List <IATA_ISO_Country__c> countryList = IATAIsoCountryDAO.getIsoCountryByIsoCodes(new Set<String>{country});
				if (!countryList.isEmpty()){
					countryName = countryList[0].Name;
					countryId = countryList[0].Id;
					if (countryList[0].Sanctioned_Country__c){
						loc.isRestricted = true;
					}
				}
			}
		}
		loc.countryCode = country;
		loc.country = countryName;
		loc.countryId = countryId;
		return loc;
	}

	@AuraEnabled
	public static Boolean isSystemAdmin(){

		List<User> userList =  [ SELECT Id FROM User WHERE Id = :UserInfo.getUserId() AND profile.name = 'System Administrator'];
		if(userList.isEmpty() == true){
			return false;
		}else{
			return true;
		}

	}

	@AuraEnabled
	public static Boolean isDisposableCheckActive(){
		return Forbidden_Disposable_Email_Domain_Check__c.getInstance().is_active__c;
	}
}
