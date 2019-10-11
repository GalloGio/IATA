public class IEC_CreateIndAccAddressController {

	public Account acc {get;set;}
	public String defCountry {get;set;}
	public List<SelectOption> countries {
		get {
			if(countries == null) {
				loadCountries();
			}
			return countries;
		}
		set;
	}


	public String listOfCountries {
		get {
			if(listOfCountries == null) {
				loadCountries();
			}
			return listOfCountries;
		}
		set;
	}


	public String mapOfStatesStr {
		get {
			if(String.isBlank(mapOfStatesStr)) {
				loadCountries();
			}
			return mapOfStatesStr;
		}
		set;
	}

	private void loadCountries() {
		countries = new List<SelectOption>();
		List<Map<String,String>> listCountries = new List<Map<String,String>>();
		Map<String,List<Object>> mapOfStates = new Map<String,List<Object>>();
		for(IATA_ISO_Country__c iso : [SELECT Id, Name, ISO_Code__c, (SELECT Id, Name, Informatica_Value__c FROM IATA_ISO_States__r WHERE IEC_Valid_SAP__c = true AND Informatica_Value__c <> null ORDER BY Name) FROM IATA_ISO_Country__c WHERE Name != 'All Countries' AND Name != 'NO COUNTRY' ORDER BY Name]) {
			SelectOption opt = new SelectOption(iso.ISO_Code__c,iso.Name);
			if(String.isNotBlank(defCountry) && defCountry.equalsIgnoreCase(iso.ISO_Code__c)) {
				acc.BillingCountry = iso.ISO_Code__c;
				acc.ShippingCountry = iso.ISO_Code__c;
			}
			for(IATA_ISO_State__c state : iso.IATA_ISO_States__r) {
				List<Object> lstStates = mapOfStates.get(iso.ISO_Code__c);
				if(lstStates == null) {
					lstStates = new List<Object>();
					mapOfStates.put(iso.ISO_Code__c, lstStates);
				}
				lstStates.add(new Map<String,String> {'value' => state.Informatica_Value__c, 'label' => state.name});
			}
			countries.add(opt);
			listCountries.add(new Map<String,String> {'value' => iso.ISO_Code__c, 'label' => iso.name});
		}

		listOfCountries = JSON.serialize(listCountries).replace('"','\\"');

		
		mapOfStatesStr = JSON.serialize(mapOfStates);
	}
}