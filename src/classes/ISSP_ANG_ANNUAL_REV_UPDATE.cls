public with sharing class ISSP_ANG_ANNUAL_REV_UPDATE {
    /*public static  Integer MAX_IFAP_Contacts {get{ return 1;} private set;}
    private static final string ISO_8859_1_regEx = '^[\\x00-\\x7F\\xA0-\\xFF]+$';  //Reg exp to limit inputted chars to ISO-8859-1
    private static integer MAX_AgencyAccount_LOOKUPS_ALLOWED = 20;
    */

	public ANG_AnnualRevCurrentAccount ca {get; set;}
    public string editContactId {get; set;}
    public String amsContactCountry {get; set;}
/*

	//public AMS_Accreditation_Contact__c newContact {get; set;}
	public string iatacode {get; set;}
	public Boolean contactSaved {get; set;}


    public string contactType {get; set;}
    public string companyModalNameOfEmployer {get; set;}
    public Integer cntIFAPContacts {get; set;}
    public string legalStatus {get; set;}
    public string legalstatusAfterChange {get; set;}
    public string companyModalAddress {get; set;}
    public Account TravelAgentPrevAccount {get; set;}
    Integer cntAgencyLookups;
    public Boolean isAddCompanyModal {get; set;}
    */
    public String applyLanguage {get; set;}
    public string txtHelpCurrency {get; set;}


	public ISSP_ANG_ANNUAL_REV_UPDATE() {
        /*
		amsContactCountry = '';
		contactSaved = false;
        companyModalNameOfEmployer = '';
        cntIFAPContacts = 0;
        legalstatus = '';
        companyModalAddress = '';
        cntAgencyLookups = 0;




        if(this.ca != null && this.ca.fw != null && this.ca.fw.newForm != null && this.ca.fw.newForm.ISSP_AMS_Legal_Status__c != null) {
            legalstatus = this.ca.fw.newForm.ISSP_AMS_Legal_Status__c.toLowerCase();
        }

        if (applyLanguage != 'en_US' && applyLanguage != 'es' && applyLanguage != 'fr') applyLanguage = 'en_US';



        */
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

        System.debug('alex editAgencyContact : ' + editContactId);

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


/*

    public void cancelAgentUpdate() {
        //Need to clear pointer to newContact on cancel of update; to avoid replacing contact on adding New Person
		System.debug('alex cancelAgentUpdate');

        ca.newContact = new AMS_Accreditation_Contact__c();
        iatacode = '';
        contactSaved = false;
    }

    public void deleteAgencyContact() {
        System.debug('alex deleteAgencyContact : ' + editContactId);


		ca.fw.deleteAgencyContact(editContactId);
    }

    public List<SelectOption> countryNameList {
        get {
            List<SelectOption> options = new List<SelectOption>();

            list<IATA_ISO_Country__c> isoList;
            if (applyLanguage == 'es') {
                isoList = [SELECT Name, Id, IATA_Contry_KR__c, IATA_COUNTRY_EN__c, ISO_Code__c, AMS_Pilot_Country__c,
                                  IATA_Country_FR__c, IATA_Country_IT__c, IATA_Country_JP__c,
                                  IATA_Country_PT__c, IATA_Country_SP__c, IATA_Country_ZH__c
                             FROM IATA_ISO_Country__c
                            WHERE Case_BSP_Country__c != null
                              AND Case_BSP_Country__c != ''
                         ORDER BY IATA_Country_SP__c];
            } else if (applyLanguage == 'fr') {
                isoList = [SELECT Name, Id, IATA_Contry_KR__c, IATA_COUNTRY_EN__c, ISO_Code__c, AMS_Pilot_Country__c,
                                  IATA_Country_FR__c, IATA_Country_IT__c, IATA_Country_JP__c,
                                  IATA_Country_PT__c, IATA_Country_SP__c, IATA_Country_ZH__c
                             FROM IATA_ISO_Country__c
                            WHERE Case_BSP_Country__c != null
                              AND Case_BSP_Country__c != ''
                         ORDER BY IATA_Country_FR__c];
            } else {
                isoList = [SELECT Name, Id, IATA_Contry_KR__c, IATA_COUNTRY_EN__c, ISO_Code__c, AMS_Pilot_Country__c,
                                  IATA_Country_FR__c, IATA_Country_IT__c, IATA_Country_JP__c,
                                  IATA_Country_PT__c, IATA_Country_SP__c, IATA_Country_ZH__c
                             FROM IATA_ISO_Country__c
                            WHERE Case_BSP_Country__c != null
                              AND Case_BSP_Country__c != ''
                         ORDER BY Name];
            }

            options.add(new SelectOption('', Label.ISSP_SELECT_COUNTRY));
            for (IATA_ISO_Country__c iso : isoList) {
                if (applyLanguage == 'es') {
                    if (iso.IATA_Country_SP__c != null)
                        options.add(new SelectOption(iso.IATA_Country_SP__c , iso.IATA_Country_SP__c));
                    else
                        options.add(new SelectOption(iso.Name , iso.Name));
                } else if (applyLanguage == 'fr') {
                    if (iso.IATA_Country_FR__c != null)
                        options.add(new SelectOption(iso.IATA_Country_FR__c, iso.IATA_Country_FR__c));
                    else
                        options.add(new SelectOption(iso.Name, iso.Name));
                } else {
                    options.add(new SelectOption(iso.Name, iso.Name));
                }
            }

            return options;
        }
        set;
    }

    public PageReference fetchAgentDetails() {
        String qCargoCode;
        TravelAgentPrevAccount = new Account();
        Account generalAccount = null;
        companyModalAddress = '';
        companyModalNameOfEmployer = '';

        if (iatacode == null)
            return null;

        //Limit how many calls can be made to this service, to prevent a user from attempting to retrieve full list of agents
        cntAgencyLookups += 1;
        if (cntAgencyLookups > MAX_AgencyAccount_LOOKUPS_ALLOWED) {
            TravelAgentPrevAccount = new Account();
            return null;
        }

        qCargoCode = iatacode + '%';

        List <Account> agentaccounts = null;

        agentaccounts = [Select Id, BillingStreet, BillingCity, BillingState, BillingPostalCode,
                                BillingCountry, Name
                           From Account
                          Where RecordType.DeveloperName = 'IATA_Agency'
                            And Sector__c = :AMS_Utils.SECTOR_PASSENGER  // agentSector
                            And IATACode__c Like :qCargoCode];

        system.debug('agentaccounts:' + agentaccounts);

        if (agentaccounts!= null && !agentaccounts.isEmpty()) {
            String agentAddress;

            TravelAgentPrevAccount = agentaccounts[0];
            System.Debug('Travel Agent name:' + TravelAgentPrevAccount.Name);

            agentAddress = AMS_Utils.notNull(TravelAgentPrevAccount.BillingStreet) + ' \r\n' +
                            AMS_Utils.notNull(TravelAgentPrevAccount.BillingCity) + '' + AMS_Utils.notNull(TravelAgentPrevAccount.BillingState) +
                            ' \r\n' + AMS_Utils.notNull(TravelAgentPrevAccount.BillingCountry);

            System.Debug('IATA Agent address lookup:' + agentAddress);

            ca.newContact.Prev_Job2_Address__c = agentAddress;
            ca.newContact.Prev_Job2_Employer__c = TravelAgentPrevAccount.Name;
            ca.newContact.Accredited_employer_2__c = TravelAgentPrevAccount.Id;

            return null;
        } else {
            ca.newContact.Prev_Job2_Address__c = '';
            ca.newContact.Prev_Job2_Employer__c = '';

            if (isAddCompanyModal != null && isAddCompanyModal == true) {
                companyModalAddress = '';
                companyModalNameOfEmployer = '';
            }

            return null;
        }
    }
    */
}