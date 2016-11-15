public with sharing class ISSP_Ctrl_Country_Requirements {

    public AP_Country_Requierment__c countryRequirement {get;set;}
    public String typeFilter {get;set;}
    public String countryFilter {get;set;}
    public String searchFilter {get;set;}

    /**
        Check is the user has access to this service
    **/
    public static Boolean isAllowedAccess() {
        try {
            User user = [
                Select id,contact.Account.Sector__c, contact.Account.Category__c
                from User
                where Id = :UserInfo.getUserId()];

            return user.contact.Account.Sector__c == 'Airline'
                || user.contact.Account.Sector__c == 'General Sales Agent'
                || user.contact.Account.Category__c == 'GSA General Sales agent'
                || user.contact.Account.Category__c == 'GSSA Cargo';

        } catch (Exception e) {
            return false;
        }
    }

    //Constructor
    public ISSP_Ctrl_Country_Requirements(){
      clearFilters();
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

}