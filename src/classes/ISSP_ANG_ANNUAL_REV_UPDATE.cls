/*
	TEST CLASS : ISSP_ANG_ANNUAL_REVALIDATION_Test

*/
public with sharing class ISSP_ANG_ANNUAL_REV_UPDATE {

	public ANG_AnnualRevCurrentAccount ca {get; set;}
    public string editContactId {get; set;}
    public String amsContactCountry {get; set;}

    public String applyLanguage {get; set;}
    public string txtHelpCurrency {get; set;}
    public string txtHelpTaxNumber {get; set;}
    public String vatNumber {get; set;}
    public String vatNumber2 {get; set;}
    
    public list<selectOption> countryList{get{
                if(countryList==null){
                    countryList= new list<selectOption>();
                    countryList.add(new selectOption('',''));
                    map<string,IATA_ISO_Country__c> countryInfoByCountryNameMap = new map<string, IATA_ISO_Country__c>();//stores temporarely the values to be assing to a string

                    for(IATA_ISO_Country__c cnt:[select name,Postal_Code_Hint_Format__c, State_Province_Mandatory__c, IEC_Zip_Postal_Code_required__c, Informatica_Value__c
                        from IATA_ISO_Country__c 
                        where region__c!='' and Iso_code__c not in ('IO','TF','GS','UM','UP','VI') order by name asc]){

                        countryList.add(new selectOption(cnt.Informatica_Value__c.toUpperCase(), cnt.name));

                        countryInfoByCountryNameMap.put(cnt.Name.toUpperCase(), cnt);
                    }
                    countryInfoByCountryNameMapString = JSON.serialize(countryInfoByCountryNameMap);
                }
                return countryList;
        }   
        set;}

    public static map<string,IATA_ISO_Country__c> postalCodeRegexByCountryMap{
        get{
            if(postalCodeRegexByCountryMap==null){
                postalCodeRegexByCountryMap= new map<string,IATA_ISO_Country__c>();
                
                for(IATA_ISO_Country__c cnt:[select id,name,Postal_Code_Format_regEx__c, State_Province_Mandatory__c, IEC_Zip_Postal_Code_required__c
                    from IATA_ISO_Country__c 
                    where region__c!='' and Iso_code__c not in ('IO','TF','GS','UM','UP','VI') order by name asc]){

                    postalCodeRegexByCountryMap.put(cnt.Name.toUpperCase(), cnt);
                }

            } 
            return postalCodeRegexByCountryMap;
        }
        set;
    }
    
    public string countryInfoByCountryNameMapString {
        get{
            if(countryInfoByCountryNameMapString==null) countryInfoByCountryNameMapString='\'\'';//characters to avoid crashing stringfy method on vf page
            return countryInfoByCountryNameMapString;
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
            
            upsert ca.fw.newform;
        } else {
            ca.fw.newForm.ISSP_AMS_VAT_number_input__c.addError(Label.ISSP_PAX_Validating_VAT_Number_error);
            ca.fw.newForm.INVALID_Tax_Number__c = true;
            ca.errorFound = true;

            upsert ca.fw.newform;
        }
    }
    
    public void validateVATNumber2() {
        if (new ISSP_ANG_ANNUAL_REVALIDATION().vatNumberValidation(this.vatNumber2, ca.isocountry.ISO_Code__c)) {
            ca.fw.newForm.INVALID_Tax_Number_2__c = false;
            ca.errorFound = false;
            
            upsert ca.fw.newform;
        } else {
            ca.fw.newForm.ISSP_AMS_VAT_number_2_input__c.addError(Label.ISSP_PAX_Validating_VAT_Number_error);
            ca.fw.newForm.INVALID_Tax_Number_2__c = true;
            ca.errorFound = true;

            upsert ca.fw.newform;
        }
    }
    
    public void toggleCheckbox(){
        
    }

    public void newAgencyContact() {
        ca.newContact = new AMS_Accreditation_Contact__c();
    }

	public void editAgencyContact() {
		ca.newContact = ca.fw.getAMSAccreditationContact(editContactId);
        amsContactCountry =  ca.newContact.AddressCountry__c;
	}

    public AMS_Accreditation_Country_CheckList__c countryCheckList {

        get{

            List<AMS_Accreditation_Country_CheckList__c> aux = [
                SELECT License_required__c, Registration_required__c, Statement_of_International_Sales__c, Statement_of_International_Sales_Branch__c
                  FROM AMS_Accreditation_Country_CheckList__c
                 WHERE IATA_ISO_Country__r.ISO_Code__c = :ca.isocountry.Iso_code__c AND Operation__c = :ca.Account.Sector__c
            ];

            if(!aux.isEmpty()) return aux[0]; else return null;
        }
        set{}
    }
    
    public Boolean displayShipping{
        
        get{
            if(displayShipping == null) {
                displayShipping = false;
                if(ca.Account.BillingStreet == ca.Account.ShippingStreet &&
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
            ca.shippingSameAsBilling = displayShipping;
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

}