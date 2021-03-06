//TEST CLASS : ISSP_ANG_ANNUAL_REVALIDATION_Test
public with sharing class ISSP_ANG_ANNUAL_REV_UPDATE {
	public ANG_AnnualRevCurrentAccount ca {get; set;}
	public string editContactId {get; set;}
	public String amsContactCountry {get; set;}
	public String applyLanguage {get; set;}
	public string txtHelpCurrency {get; set;}
	public string txtHelpTaxNumber {get; set;}
	public String vatNumber {get; set;}
	public String vatNumber2 {get; set;}
	public boolean isValError {get; set;}
	public boolean namEnabled {get; set;}

	public boolean chsb{get;set;}
	public boolean chss{get;set;}

	public static Map<String, List<IATA_ISO_State__c>> stateListByCountryNameMap {
		get {
			if (stateListByCountryNameMap == null) {
				stateListByCountryNameMap = new Map<String, List<IATA_ISO_State__c>>();

				for(IATA_ISO_State__c state :  [SELECT Id, Name, IATA_ISO_Country__r.Informatica_Value__c FROM IATA_ISO_State__c WHERE IATA_ISO_Country__r.State_Province_Picklist__c = true ORDER BY Name]){
					if(!stateListByCountryNameMap.containsKey(state.IATA_ISO_Country__r.Informatica_Value__c.toUpperCase())){
						stateListByCountryNameMap.put(state.IATA_ISO_Country__r.Informatica_Value__c.toUpperCase(), new List<IATA_ISO_State__c>());
					}
					stateListByCountryNameMap.get(state.IATA_ISO_Country__r.Informatica_Value__c.toUpperCase()).add(state);
				}

			}
			return stateListByCountryNameMap;
		}
		set;
	}
	public static List<IATA_ISO_City__c> billingCityListName {get;set;}    
	public static List<IATA_ISO_City__c> shippingCityListName {get;set;}

	private Id currentCountryId;

	public String geonameBillingCityId {get;set{ geonameBillingCityId = value; if(!String.isBlank(geonameBillingCityId)){ ca.fw.newForm.Geoname_Billing_City__c = geonameBillingCityId; } else {ca.fw.newForm.Geoname_Billing_City__c = null;} }}

	public String geonameShippingCityId {get;set{ geonameShippingCityId = value; if(!String.isBlank(geonameShippingCityId)){ ca.fw.newForm.Geoname_Shipping_City__c = geonameShippingCityId;} else {ca.fw.newForm.Geoname_Shipping_City__c = null;} }}

	public static String billingCityListNameStr {
	get{
		return JSON.serialize(billingCityListName);
	}
	set;
	}
	
	public static String shippingCityListNameStr {
	get{
		return JSON.serialize(shippingCityListName);
	}
	set;
	}

	public static List<SelectOption> countryList {
		get {
			if (countryList==null) {
				countryList= new List<selectOption>{new SelectOption('','')};

				Map<String, IATA_ISO_Country__c> countryInfoByCountryNameMap = new Map<String, IATA_ISO_Country__c>();//stores temporarely the values to be assing to a string

				for (IATA_ISO_Country__c cnt: [SELECT Name, Postal_Code_Hint_Format__c, State_Province_Mandatory__c,
												IEC_Zip_Postal_Code_required__c, Informatica_Value__c
											FROM IATA_ISO_Country__c
											WHERE Region__c != '' AND Iso_code__c NOT IN ('IO','TF','GS','UM','UP','VI')
											ORDER BY name ASC]) {
					countryList.add(new selectOption(cnt.Informatica_Value__c.toUpperCase(), cnt.Name));
					countryInfoByCountryNameMap.put(cnt.Name.toUpperCase(), cnt);
				}

				countryInfoByCountryNameMapString = JSON.serialize(countryInfoByCountryNameMap);
			}

			return countryList;
		}
		set;
	}

	public static Map<String,IATA_ISO_Country__c> postalCodeRegexByCountryMap{
		get {
			if (postalCodeRegexByCountryMap == null) {
				postalCodeRegexByCountryMap = new Map<String,IATA_ISO_Country__c>();

				for (IATA_ISO_Country__c cnt: [SELECT id, Name, Postal_Code_Format_regEx__c, State_Province_Mandatory__c,
												IEC_Zip_Postal_Code_required__c, State_Province_Picklist__c
											FROM IATA_ISO_Country__c
											WHERE Region__c != '' AND Iso_code__c NOT IN ('IO','TF','GS','UM','UP','VI')
											ORDER BY Name ASC]) {
					postalCodeRegexByCountryMap.put(cnt.Name.toUpperCase(), cnt);
				}
			}

			return postalCodeRegexByCountryMap;
		}
		set;
	}

	public static String countryInfoByCountryNameMapString {
		get {
			if (countryInfoByCountryNameMapString == null) {
				List<SelectOption> countryListPopulated = countryList;
			}

			return countryInfoByCountryNameMapString;
		}
		set;
	}

	public List<SelectOption> billingStateList {
		get {
			if (this.currentCountryId != ca.account.IATA_ISO_Country__c){
				billingStateList = new List<SelectOption>{new SelectOption('', Label.ISSP_SELECT_STATE)};

				List<IATA_ISO_Country__c> iataIsoCountryLst = IATAIsoCountryDAO.getIsoCountriesByIds(new Set<Id>{ca.account.IATA_ISO_Country__c});

				if(!iataIsoCountryLst.isEmpty()){
					IATA_ISO_Country__c country = iataIsoCountryLst.get(0);
					this.currentCountryId = country.Id;
					for (IATA_ISO_State__c state : country.IATA_ISO_States__r) {
						billingStateList.add(new SelectOption(state.Name, state.Name));
					}
				}	
			}

			for(SelectOption state : billingStateList){
				if(!String.isBlank(state.getValue()) && !String.isBlank(ca.fw.newform.State_Province__c))
					ca.fw.newform.State_Province__c = state.getValue().toUpperCase() == ca.fw.newform.State_Province__c.toUpperCase()?state.getValue():ca.fw.newform.State_Province__c;
			}

			return billingStateList;
		}
		set;
	}

	public static String stateListByCountryName {
		get {
			return JSON.serialize(stateListByCountryNameMap);
		}
		set;
	}

	public List<SelectOption> shippingStateList {get; set;}

	public String stateInfo {
		get {
			if (stateInfo == null) {
				stateInfo = '\'\'';
			}
			return stateInfo;
		}
		set;
	}

	public ISSP_ANG_ANNUAL_REV_UPDATE() {
		isValError = true;
		applyLanguage = UserInfo.getLanguage();

		String fldName = 'ISSP_AMS_HelpText_' + applyLanguage + '__c';

		txtHelpCurrency = (ISSP_AMS_Contextual_Help__c.getValues('CURRENCY') != null) ? (String) ISSP_AMS_Contextual_Help__c.getValues('CURRENCY').get(fldName) : '';
		txtHelpTaxNumber = (ISSP_AMS_Contextual_Help__c.getValues('TAX_NUMBER') != null) ? (String) ISSP_AMS_Contextual_Help__c.getValues('TAX_NUMBER').get(fldName) : '';
	}

	public void validateVATNumber() {
		if (new ISSP_ANG_ANNUAL_REVALIDATION().vatNumberValidation(this.vatNumber, ca.isocountry.ISO_Code__c)) {
			ca.fw.newForm.INVALID_Tax_Number__c = false;
			ca.errorFound = false;
		} else {
			ca.fw.newForm.ISSP_AMS_VAT_number_input__c.addError(Label.ISSP_PAX_Validating_VAT_Number_error);
			ca.fw.newForm.INVALID_Tax_Number__c = true;
			ca.errorFound = true;
		}

		upsert ca.fw.newform;
	}

	public void currentShippingCountryStates() {
		shippingStateList = new List<SelectOption>{new SelectOption('', Label.ISSP_SELECT_STATE)};

		if(stateListByCountryNameMap.containsKey(ca.fw.newform.Shipping_Country__c != null ? ca.fw.newform.Shipping_Country__c.toUpperCase():'')) {
			for (IATA_ISO_State__c state: stateListByCountryNameMap.get(ca.fw.newform.Shipping_Country__c.toUpperCase())) {
				shippingStateList.add(new SelectOption(state.Name, state.Name));
				if(!String.isBlank(state.Name) && !String.isBlank(ca.fw.newform.Shipping_State__c)){
						ca.fw.newform.Shipping_State__c = state.Name.toUpperCase() == ca.fw.newform.Shipping_State__c.toUpperCase()?state.Name:ca.fw.newform.Shipping_State__c;
					}
			}
		}
	}
	
	public void currentBillingStateCities() {        
		billingCityListName = new List<IATA_ISO_City__c>([SELECT Id, Name, GeonameName__c 
														  FROM IATA_ISO_City__c
														  WHERE IATA_ISO_State__r.Name = :ca.fw.newform.State_Province__c AND Status__c <> 'Pending'                                       
														  ORDER BY Name]);                
	}
	public void currentShippingStateCities() {       
		
		shippingCityListName = new List<IATA_ISO_City__c>([SELECT Id, Name, GeonameName__c
														  FROM IATA_ISO_City__c
														  WHERE IATA_ISO_State__r.Name = :ca.fw.newform.Shipping_State__c AND Status__c <> 'Pending'                                       
														  ORDER BY Name]);                
	}

	public void validateVATNumber2() {
		if (new ISSP_ANG_ANNUAL_REVALIDATION().vatNumberValidation(this.vatNumber2, ca.isocountry.ISO_Code__c)) {
			ca.fw.newForm.INVALID_Tax_Number_2__c = false;
			ca.errorFound = false;
		} else {
			ca.fw.newForm.ISSP_AMS_VAT_number_2_input__c.addError(Label.ISSP_PAX_Validating_VAT_Number_error);
			ca.fw.newForm.INVALID_Tax_Number_2__c = true;
			ca.errorFound = true;
		}
		upsert ca.fw.newform;
	}

	public void newAgencyContact() {
		ca.newContact = new AMS_Accreditation_Contact__c();
	}

	public void editAgencyContact() {
		ca.newContact = ca.fw.getAMSAccreditationContact(editContactId);
		amsContactCountry = ca.newContact.AddressCountry__c;
	}

	public AMS_Accreditation_Country_CheckList__c countryCheckList {
		get{
			if (countryCheckList == null) {
				List<AMS_Accreditation_Country_CheckList__c> aux = [SELECT License_required__c, Registration_required__c,
																	Statement_of_International_Sales__c, Statement_of_International_Sales_Branch__c
																FROM AMS_Accreditation_Country_CheckList__c
																WHERE IATA_ISO_Country__r.ISO_Code__c = :ca.isocountry.Iso_code__c
																	AND Operation__c = :ca.Account.Sector__c];

				return (!aux.isEmpty()) ? aux[0] : null;
			}
			return countryCheckList;
		}
		set;
	}

	public Boolean displayShipping{
		get{
			if(displayShipping == null) {
				displayShipping = false;
				if(ca.fw.newform.Saved_At_Least_Once__c == true) {
					displayShipping = ca.fw.newform.Shipping_Same_As_Billing__c;
				}else if(ca.Account.BillingStreet == ca.Account.ShippingStreet &&
						 ca.Account.BillingCity == ca.Account.ShippingCity &&
						 ca.Account.BillingPostalCode == ca.Account.ShippingPostalCode &&
						 ca.Account.BillingState == ca.Account.ShippingState &&
						 ca.Account.BillingCountry == ca.Account.ShippingCountry) {
							 displayShipping = true;
							 ca.fw.newform.shipping_street__c = '';
							 ca.fw.newform.shipping_city__c = '';
							 ca.fw.newform.shipping_postal_code__c = '';
							 ca.fw.newform.shipping_state__c = '';
							 ca.fw.newform.shipping_country__c = '';
							 ca.fw.newform.Geoname_Shipping_City__c = null;
						 } else if(ca.Account.ShippingStreet == null &&
								   ca.Account.ShippingCity == null &&
								   ca.Account.ShippingPostalCode == null &&
								   ca.Account.ShippingState == null &&
								   ca.Account.ShippingCountry == null) {
									   displayShipping = true;
									   ca.fw.newform.shipping_street__c = '';
									   ca.fw.newform.shipping_city__c = '';
									   ca.fw.newform.shipping_postal_code__c = '';
									   ca.fw.newform.shipping_state__c = '';
									   ca.fw.newform.shipping_country__c = '';
									   ca.fw.newform.Geoname_Shipping_City__c = null;
								   }

			}
			ca.fw.newform.Shipping_Same_As_Billing__c = displayShipping;
			return displayShipping;
		}
		set{
			displayShipping = value;
			if (displayShipping == false){
				ca.fw.newform.shipping_street__c = '';
				ca.fw.newform.shipping_city__c = '';
				ca.fw.newform.shipping_postal_code__c = '';
				ca.fw.newform.shipping_state__c = '';
				ca.fw.newform.shipping_country__c = '';
				ca.fw.newForm.Geoname_Shipping_City__c = null;
			}
		}
	}

	public void resetCheckbox() {
		displayShipping = null;
		ca.fw.newform.shipping_street__c = ca.Account.ShippingStreet;
		ca.fw.newform.shipping_city__c = ca.Account.ShippingCity;
		ca.fw.newform.shipping_postal_code__c = ca.Account.ShippingPostalCode;
		ca.fw.newform.shipping_state__c = ca.Account.ShippingState;
		ca.fw.newform.shipping_country__c = ca.Account.ShippingCountry;
		ca.fw.newForm.Geoname_Shipping_City__c = ca.Account.Geoname_Shipping_City__c;
	}

}
