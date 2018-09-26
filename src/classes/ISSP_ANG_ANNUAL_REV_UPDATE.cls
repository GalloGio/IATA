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

}