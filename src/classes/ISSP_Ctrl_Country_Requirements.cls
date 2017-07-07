public with sharing class ISSP_Ctrl_Country_Requirements {

    public AP_Country_Requierment__c countryRequirement {get;set;}
    public String typeFilter {get;set;}
    public String countryFilter {get;set;}
    public String searchFilter {get;set;}

    public static User user;

    public String sector {get;set;}
    public String countryName {get;set;}
    public Boolean isHOAccredited {get;set;}
    public String category {get;set;}
    public Boolean isNewgenEnabled {get;set;}
    public String countryIsoCode {get; set;}
    public String selectedLang {get; set;}
    public String accredModel {get; set;}
    public RecordType TravelReqRecType {get; set;}
    public String amsOfficeType {get; set;}
    public String amsCountryLabel {get; set;}
    public IATA_ISO_Country__c isocountry {get; set;}
    public Boolean isNoticeOfChange {get; set;}
    public String sectorValue {get; set;}
    public Boolean newlabels {get; set;}
    public String agentType {get; set;}    

    public String accreditationType {get;set;}
    public List<AMS_Accreditation_Requirement__c> countryRequirementsList;
    public List<SelectOption> accreditationTypes;    

    /**
        Check is the user has access to this service
    **/
    public static Boolean isAllowedAccess() {

        getUser();
        if(user != null) {

            Boolean comp = (ApexPages.currentPage().getParameters().get('comp') == 'true');

            return user.contact.Account.Sector__c == 'Airline'
                || user.contact.Account.Sector__c == 'General Sales Agent'
                || user.contact.Account.Category__c == 'GSA General Sales agent'
                || user.contact.Account.Category__c == 'GSSA Cargo'
                || comp;
        } else {
            return false;
        }
    }

    private static User getUser() {
        if(user == null) {
            user = [Select id,
                           contact.Account.Sector__c,
                           contact.Account.Category__c,
                           contact.Account.IATA_ISO_Country__r.Name,
                           contact.Account.IATA_ISO_Country__r.ANG_Enable_NewGen__c,
                           contact.Account.IATA_ISO_Country__r.ISO_Code__c,
                           contact.Account.IATA_ISO_Country__r.Case_BSP_Country__c,
                           contact.Account.IATA_ISO_Country__r.IATA_Country_FR__c,
                           contact.Account.IATA_ISO_Country__r.IATA_Country_SP__c,
                           contact.Account.IATA_ISO_Country__r.AMS_Accreditation_New_Labels__c,
                           contact.Account.Top_Parent__c,
                           contact.Account.IATACode__c,
                           contact.Account.RecordType.DeveloperName,
                           contact.Account.Status__c
                      from User
                     where Id = :UserInfo.getUserId()];
        } 
        return user;    
    }

    //Constructor
    public ISSP_Ctrl_Country_Requirements(){
        clearFilters();

        try {

            getUser();

            Id vHQAccountId;

            if(user.contact.Account.Top_Parent__c == null) {
                vHQAccountId = user.contact.AccountId;
            } else {
                vHQAccountId = user.contact.Account.Top_Parent__c;
            }            

            Account hqAccount = [SELECT Id, 
                                Name, 
                                RecordType.DeveloperName,
                                Status__c,
                                IATACode__c  
                        FROM Account
                        WHERE Id = :vHQAccountId LIMIT 1];
             
            TravelReqRecType = [Select Id 
                                  From RecordType
                                 Where SobjectType = 'AMS_Accreditation_Requirement__c'
                                   and DeveloperName = 'Travel_Agent'];

            String applyLanguage = 'en_US';

            if (ApexPages.currentPage().getParameters().containsKey('isNoticeOfChange'))
                isNoticeOfChange = Boolean.valueOf(ApexPages.currentPage().getParameters().get('isNoticeOfChange'));

            if (applyLanguage == 'fr') {
                selectedLang = 'French';
            } else if (applyLanguage == 'es') {
                selectedLang = 'Spanish';
            } else {
                selectedLang = 'English';
            }

            countryIsoCode = user.contact.Account.IATA_ISO_Country__r.ISO_Code__c;
            
            category = user.contact.Account.Category__c;
            sector = user.contact.Account.Sector__c;
            countryName = user.contact.Account.IATA_ISO_Country__r.Name; 
            isHOAccredited = false;
            isNewgenEnabled = user.contact.Account.IATA_ISO_Country__r.ANG_Enable_NewGen__c;

            if (user.contact.Account.Top_Parent__c == null &&
                user.contact.Account.IATACode__c != null && 
                user.contact.Account.RecordType.DeveloperName == 'IATA_Agency' && 
                user.contact.Account.Status__c != 'Terminated' && 
                user.contact.Account.Status__c != 'Not accreditated' && 
                user.contact.Account.Status__c != 'New application pending' && 
                user.contact.Account.Status__c != 'No longer a customer')
            {
                isHOAccredited = true;
                
            } else {                
                if (hqAccount.RecordType.DeveloperName == 'IATA_Agency' &&
                    hqAccount.IATACode__c != null &&
                    hqAccount.Status__c != 'Terminated' && 
                    hqAccount.Status__c != 'Not accreditated' && 
                    hqAccount.Status__c != 'No longer a customer' && 
                    hqAccount.Status__c != 'New application pending')
                {
                    isHOAccredited = true;
                }
            }

            if (sector == 'Travel Agent') {
                sectorValue = 'Travel_Agent';
            } else {
                sectorValue = 'Cargo_Agent';
            }

            if (isHOAccredited) {
                amsOfficeType = 'Branch';
            } else {
                amsOfficeType = 'HO';    
            }

            if (applyLanguage == 'en_US') {
                amsCountryLabel = user.contact.Account.IATA_ISO_Country__r.Case_BSP_Country__c;
            } else if (applyLanguage == 'fr') {
                amsCountryLabel = user.contact.Account.IATA_ISO_Country__r.IATA_Country_FR__c;
            } else {
                amsCountryLabel = user.contact.Account.IATA_ISO_Country__r.IATA_Country_SP__c;
            }            
            
            if(user.contact.Account.IATA_ISO_Country__r.ISO_Code__c != null) {
                newlabels = user.contact.Account.IATA_ISO_Country__r.AMS_Accreditation_New_Labels__c;
            } else {            
                newlabels = false;    
            }

            agentType = 'IATA Cargo Agent';

            setAccreditationTypes();

        } catch (Exception e) {
            System.debug(LoggingLevel.ERROR, 'Exception caught : ' + e.getMessage());
        }
    }

    /**
        If access to this service is not allowed redirect to home
    **/
    public Pagereference checkAccess() {
        if (!isAllowedAccess()) {
            PageReference pageref = new PageReference('/ISSP_Homepage');
            pageref.setRedirect(true);
            return pageref;
        }
        return null;
    }

	/**
		Fill the filter countries picklist
	**/
    public List<SelectOption> getCountries() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '--None--'));
        for (IATA_ISO_Country__c isoCountry : [Select Id, Name From IATA_ISO_Country__c Where Name != 'All Countries' order by Name asc]) {
            options.add(new SelectOption(isoCountry.Id, isoCountry.Name));
        }
        return options;
    }

	/**
		Fill the filter PArticipation Types picklist
	**/
    public List<SelectOption> getParticipationTypes() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('', '--None--'));
        List<Schema.PicklistEntry> ple = AP_Country_Requierment__c.Line_of_business__c.getDescribe().getPicklistValues();
        for( Schema.PicklistEntry f : ple) {
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }
        return options;
    }

	/**
		Set to empty all filters and search the Country Requirements
	**/
	public PageReference clearFilters(){
	    this.typeFilter = '';
	    this.countryFilter = '';
	    this.searchFilter = '';
	    runSearch();
	    return null ;
	}

	/**
		Search the country Requirements aplying any active filter
	**/
    public PageReference runSearch() {
        list<AP_Country_Requierment__c> listCountryReqments = [
            SELECT Id, Name, Local_Representation_Mandatory__c, Local_accountant_mandatory__c, Local_VAT_Mandatory__c,
            Foreign_VAT_accepted__c, Special_VAT_status_allowed__c, Local_Representation_for_Fiscal_requirem__c,
            Currency_of_the_Settlement__c, Dual_currencies__c, bank_account_in_of_the_settlement__c,
            Mandatory_to_give_commission_to_agencies__c, Comments__c, Government_requirements__c, Type_of_address_accepted__c,
            VAT_no_always_inserted_into_ISS_systems__c, bank_account_in_of_the_settlement_com__c, Currency_of_the_Settlement_com__c,
            Dual_currencies_com__c, Foreign_VAT_accepted_com__c, Local_accountant_mandatory_com__c, Local_Representation_for_Fiscal_req_com__c,
            Local_Representation_Mandatory_com__c, Local_VAT_Mandatory_com__c, Mandatory_to_give_commission_to_agen_com__c, Special_VAT_status_allowed_com__c,
            Type_of_address_accepted_com__c, VAT_no_always_ins_into_ISS_systems_com__c, Government_requirements_com__c,Country__r.ISO_Code__c,
            Country__r.Case_BSP_Country__c,Bank_Account_Change_Comment__c, Line_of_business__c, Country__c, Country__r.Name
            FROM AP_Country_Requierment__c
            WHERE Line_of_business__c = :this.typeFilter
            AND Country__c = :this.countryFilter
            LIMIT 1];

        if (listCountryReqments.isEmpty()) {
            this.countryRequirement = null;
        } else {
            this.countryRequirement = listCountryReqments.get(0);
        }
        return null;
    }


    public boolean getNewLayout() {
        return (sector == 'Travel Agent');
    }

    public List<AMS_Accreditation_Requirement__c> getCountryRequirementsList() {
        if(countryRequirementsList == null) {

            countryRequirementsList = [SELECT Id,
                                              Name,
                                              Requirement_text__c,
                                              File_to_Upload__c,
                                              File_Identifier2__c
                                         FROM AMS_Accreditation_Requirement__c
                                        WHERE AMS_Accreditation_Country_CheckList__r.IATA_ISO_Country__r.ISO_Code__c = :countryIsoCode                                        
                                          AND AMS_Accreditation_Country_CheckList__r.Operation__c = :sector
                                          AND Location_type__c INCLUDES (:amsOfficeType)
                                          AND ANG_Accreditation_Model__c INCLUDES (:accredModel)
                                          AND Language__c = :selectedLang
                                          AND RecordTypeId = :TravelReqRecType.Id                                          
                                          ORDER BY Sort_Order__c ASC];

        }
        return countryRequirementsList;
    }

    public List<SelectOption> getAccreditationTypes() {
        if(accreditationTypes == null) {
            setAccreditationTypes();
        }
        return accreditationTypes;
    }

    public PageReference refreshRequirementsList() {
        countryRequirementsList = null;
        accredModel = accreditationType;
        
        return null;
    }

    private List<SelectOption> setAccreditationTypes() {
        accreditationTypes = new List<SelectOption>();

        if(isHOAccredited && category == 'IATA Passenger Sales Agent') {
            accredModel = 'Legacy';
            accreditationTypes.add(new SelectOption('Legacy', Label.ISSP_AMS_OPTION_PAX_BRANCH));
        } else {
            if(isNewgenEnabled) {
                accredModel = AMS_Utils.ACCREDITATIONMODEL_CASH;
                accreditationTypes.add(new SelectOption(AMS_Utils.ACCREDITATIONMODEL_CASH, Label.ISSP_AMS_Head_Entity_Cash));
                accreditationTypes.add(new SelectOption(AMS_Utils.ACCREDITATIONMODEL_CASHLESS, Label.ISSP_AMS_Head_Entity_No_Cash));
            } else {
                accredModel = 'Legacy';
                accreditationTypes.add(new SelectOption('Legacy', Label.ISSP_AMS_OPTION_PAX_HO));
            }
        }
        return accreditationTypes;
    }
}