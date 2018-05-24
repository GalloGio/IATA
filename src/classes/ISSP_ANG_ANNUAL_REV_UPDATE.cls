public with sharing class ISSP_ANG_ANNUAL_REV_UPDATE {

	public ANG_AnnualRevCurrentAccount ca {get; set;}
    public string editContactId {get; set;}
    public String amsContactCountry {get; set;}

    public String applyLanguage {get; set;}
    public string txtHelpCurrency {get; set;}


	public ISSP_ANG_ANNUAL_REV_UPDATE() {
        txtHelpCurrency = '';
        applyLanguage = UserInfo.getLanguage();

        String fldName = 'ISSP_AMS_HelpText_' + applyLanguage + '__c';

        ISSP_AMS_Contextual_Help__c hlp = ISSP_AMS_Contextual_Help__c.getValues('CURRENCY');
        if (hlp != null) {
            if ((String)hlp.get(fldName) != null) {
                txtHelpCurrency =  (String)hlp.get(fldName);
            } else {
                txtHelpCurrency =  (String)hlp.get(fldName);
            }
        }


	}

    public void newAgencyContact() {
        ca.newContact = new AMS_Accreditation_Contact__c();
    }

	public void editAgencyContact() {
		ca.newContact = ca.fw.getAMSAccreditationContact(editContactId);
        amsContactCountry =  ca.newContact.AddressCountry__c;
	}

    public AMS_Accreditation_Country_CheckList__c CountryCheckList {

        get{

            List<AMS_Accreditation_Country_CheckList__c> aux = [
                SELECT License_required__c, Registration_required__c, Statement_of_International_Sales__c, Statement_of_International_Sales_Branch__c
                  FROM AMS_Accreditation_Country_CheckList__c
                 WHERE IATA_ISO_Country__r.ISO_Code__c = :ca.isocountry.Iso_code__c AND Operation__c = :ca.Account.Sector__c
            ];

            if(!aux.isEmpty()) {
                return aux[0];
            } else {
                return null;
            }
        }
        set{}
    }

}