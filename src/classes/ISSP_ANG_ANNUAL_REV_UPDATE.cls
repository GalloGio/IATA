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
    public Map<String, List<IATA_ISO_State__c>> stateListByCountryNameMap {get; set;}
    
    public List<SelectOption> countryList {
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
    
    public String countryInfoByCountryNameMapString {
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
            if (billingStateList == null) {
                billingStateList = new List<SelectOption>{new SelectOption('', Label.ISSP_SELECT_STATE)};

                for (IATA_ISO_State__c state: [SELECT Id, Name
                                            FROM IATA_ISO_State__c
                                            WHERE IATA_ISO_Country__c = :ca.account.IATA_ISO_Country__c
                                            ORDER BY Name]) {
                    billingStateList.add(new SelectOption(state.Name, state.Name));
                }
            }
            return billingStateList;
        }   
        set;
    }

    public String stateListByCountryName {
        get {
            if (stateListByCountryNameMap == null) {
                stateListByCountryNameMap = new Map<String, List<IATA_ISO_State__c>>();

                for (IATA_ISO_State__c state: [SELECT Id, Name, IATA_ISO_Country__r.Informatica_Value__c
                                            FROM IATA_ISO_State__c
                                            WHERE IATA_ISO_Country__r.State_Province_Picklist__c = true
                                            ORDER BY Name]) {
                    if (!stateListByCountryNameMap.containsKey(state.IATA_ISO_Country__r.Informatica_Value__c.toUpperCase())) {
                        stateListByCountryNameMap.put(state.IATA_ISO_Country__r.Informatica_Value__c.toUpperCase(), new List<IATA_ISO_State__c>());
                    }
                    stateListByCountryNameMap.get(state.IATA_ISO_Country__r.Informatica_Value__c.toUpperCase()).add(state);
                }
            }

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

        if(stateListByCountryNameMap.containsKey(ca.fw.newform.Shipping_Country__c.toUpperCase())) {
        	for (IATA_ISO_State__c state: stateListByCountryNameMap.get(ca.fw.newform.Shipping_Country__c.toUpperCase())) {
            	shippingStateList.add(new SelectOption(state.Name, state.Name));
        	}
    	}
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
            List<AMS_Accreditation_Country_CheckList__c> aux = [SELECT License_required__c, Registration_required__c, 
                                                                    Statement_of_International_Sales__c, Statement_of_International_Sales_Branch__c
                                                                FROM AMS_Accreditation_Country_CheckList__c
                                                                WHERE IATA_ISO_Country__r.ISO_Code__c = :ca.isocountry.Iso_code__c 
                                                                    AND Operation__c = :ca.Account.Sector__c];

            return (!aux.isEmpty()) ? aux[0] : null;
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
    }

}
