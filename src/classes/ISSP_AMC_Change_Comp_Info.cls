public class ISSP_AMC_Change_Comp_Info {
//public Account cenas {get;set;}

	public Account accountRecord {get; set;}
	public Boolean hasValue {get; set;}
	public Boolean hasLegalName {get;set;}
	public Boolean hasTradeName {get;set;}
	public Boolean hasDesignatorValue {get; set;}
	public Boolean hasAccountingCode {get; set;}
	public Boolean hasPrefixCode {get;set;}
	public Boolean hasSector {get;set;}
	public Boolean hasCategory {get;set;}
	public Boolean hasBusinessPhone {get;set;}
	public Boolean hasOfficeEmail {get;set;}
	public Boolean hasWebsite {get;set;}
	public Boolean hasISOCountry {get;set;}
	public Boolean hasAddressInfo {get;set;}
	public Boolean hasAOCExpirationDate {get;set;}
	public String scenario {get;set;}
	public String description {get;set;}
	public String address {get;set;}
	public String subtopic {get;set;}
	public String reason {get;set;}
	public String erro {get;set;}

	public ISSP_AMC_Change_Comp_Info(){
		hasValue = true;
		hasLegalName = true;
		hasTradeName = true;
		hasDesignatorValue = true;
		hasAccountingCode = true;
		hasPrefixCode = true;
		hasSector = true;
		hasCategory = true;
		hasBusinessPhone = true;
		hasOfficeEmail = true;
		hasWebsite = true;
		hasISOCountry = true;
		hasAddressInfo = true;
		hasAOCExpirationDate = true;

		erro = ' ';
		getAccountInfo();
	}

	public void getAccountInfo(){
		accountRecord = ISSP_AMC_DAO.getAccountInfo();

		if(accountRecord.AOC_Expiry_Date__c == null){
			hasAOCExpirationDate = false;
		}

		if(accountRecord.Legal_name__c == null || accountRecord.Legal_name__c == ''){
			hasLegalName = false;
		}

		if(accountRecord.TradeName__c == null || accountRecord.TradeName__c == ''){
			hasTradeName = false;
		}

		if(accountRecord.Airline_designator__c == null || accountRecord.Airline_designator__c == ''){
			hasDesignatorValue = false;
		}

		if(accountRecord.Accounting_Code__c == null || accountRecord.Accounting_Code__c == ''){
			hasAccountingCode = false;
		}
		
		if(accountRecord.Airline_Prefix__c == null || accountRecord.Airline_Prefix__c == ''){
			hasPrefixCode = false;
		}

		if(accountRecord.Sector__c == null || accountRecord.Sector__c == ''){
			hasSector = false;
		}

		if(accountRecord.Category__c == null || accountRecord.Category__c == ''){
			hasCategory = false;
		}

		if(accountRecord.Phone == null || accountRecord.Phone == ''){
			hasBusinessPhone = false;
		}

		if(accountRecord.Email__c == null || accountRecord.Email__c == ''){
			hasOfficeEmail = false;
		}

		if(accountRecord.Website == null || accountRecord.Website == ''){
			hasWebsite = false;
		}

		if(accountRecord.IATA_ISO_Country__r.Name == null || accountRecord.IATA_ISO_Country__r.Name == ''){
			hasISOCountry = false;
		}

		if((accountRecord.ShippingStreet == null || accountRecord.ShippingStreet == '') && (accountRecord.ShippingCity == null || accountRecord.ShippingCity == '') &&
			(accountRecord.ShippingPostalCode == null || accountRecord.ShippingPostalCode == '') && (accountRecord.ShippingCountry == null || accountRecord.ShippingCountry == '')){
			hasAddressInfo = false;
		}

		address = accountRecord.ShippingStreet + ', ' + accountRecord.ShippingCity + ' ' + accountRecord.ShippingPostalCode + ' ' + accountRecord.ShippingCountry;
	}

	public PageReference createCase(){
		Case newCase = new Case();
		description = 'values from form: ' + '\n' + 'Business phone - ' + accountRecord.phone +
		'\n' + 'Office Email - ' + accountRecord.email__c + '\n \t' + 'Website - ' + accountRecord.website +
		'\n' + 'ISO Country - ' + accountRecord.IATA_ISO_Country__r.Name + '\n \t' + 'Address information - ' + address;

		scenario = ISSP_AMC_Constants.AMC_PAR_ACLI_CODES_CHANGE_COMPANY_INFO;
		subtopic = ISSP_AMC_Constants.AMC_CASE_SUBTOPIC_CHANGE_COMPANY_INFO;
		reason = ISSP_AMC_Constants.AMC_CASE_REASON_COMPANY_INFO;

		//newCase = ISSP_AMC_DAO.getCase(scenario, description, subtopic, reason);

		try{
			newCase = ISSP_AMC_DAO.getCase(scenario, description, subtopic, reason, true);
			PageReference pr = new PageReference('/ISSP_Case?caseId=' + newCase.Id + '&mid=M1S2');
			pr.setRedirect(true);
			return pr;
		}
		catch(Exception ex){
			if(ex.getMessage().contains('There is already an open Airline Coding Application case with Reason')) {
				//ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING, 'There is already an open Airline Coding Application case with Reason "Manage Changes / Minor" on the selected Account'));
				erro = 'There is already an open Airline Coding Application case for this Account';
			}
			else {
				throw new errorPageException(ex.getMessage());
			}
		}

		return null;
	}


	public void clearMessage(){
		erro = ' ';
	}
	public class errorPageException extends Exception {
	}
}