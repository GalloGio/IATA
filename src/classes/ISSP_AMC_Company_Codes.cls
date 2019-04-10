/*
	Class Name: ISSP_AMC_Company_Codes
	Related Classes:

	Copyright @Right IT Services

	Purpose: Controller Class for ISSP_AMC_Company_Codes.component

	VERSION  	AUTHOR				DATE    		DETAIL/CHANGE REFERENCE
 	1.0		  	Filipa Martins		26-10-2018   	INITIAL DEVELOPMENT
	1.0			Inna Prokopieva		05-04-2019
*/
public class ISSP_AMC_Company_Codes {

	public Account accountRecord {get; set;}
	public Boolean hasInfo {get; set;}
	public Boolean isRecalled {get; set;}
	public Boolean hasDesignatorInfo {get; set;}
	public Boolean hasAccountingCodeInfo {get; set;}
	public Boolean hasPrefixCodeInfo {get; set;}
	public boolean hasBaggageCodeInfo {get; set;}
	public Boolean hasExpiryDateInfo {get; set;}
	//public String erros {get;set;}

	public ISSP_AMC_Company_Codes(){
		hasInfo = true;
		hasAccountingCodeInfo = true;
		hasExpiryDateInfo = true;
		hasDesignatorInfo = true;
		hasPrefixCodeInfo = true;
		hasBaggageCodeInfo = true;
		isRecalled = false;
		changeCompanyInfo();
	}

	public void changeCompanyInfo(){

		accountRecord = ISSP_AMC_DAO.getAccountInfo();

		if((accountRecord.Airline_designator__c == null || accountRecord.Airline_designator__c == '') && (accountRecord.IATACode__c == null || accountRecord.IATACode__c == '') && 
			(accountRecord.Airline_Prefix__c == null || accountRecord.Airline_Prefix__c == '') && (accountRecord.Baggage_Tag_Range_Code__c == null || accountRecord.Baggage_Tag_Range_Code__c == '') &&
			(accountRecord.AOC_Expiry_Date__c == null))
		{
			hasInfo = false;
		}

		if((accountRecord.Airline_designator__c == null || accountRecord.Airline_designator__c == '')){
			hasDesignatorInfo = false;
		}

		if((accountRecord.IATACode__c == null || accountRecord.IATACode__c == '')){
			hasAccountingCodeInfo = false;
		}

		if((accountRecord.Airline_Prefix__c == null || accountRecord.Airline_Prefix__c == '')){
			hasPrefixCodeInfo = false;
		}

		if((accountRecord.Baggage_Tag_Range_Code__c == null || accountRecord.Baggage_Tag_Range_Code__c == '')){
			hasBaggageCodeInfo = false;
		}


		if((accountRecord.AOC_Expiry_Date__c == null)){
			hasExpiryDateInfo = false;
		}

		System.debug('designator: ' + accountRecord.Airline_designator__c);
		System.debug('prefix: ' + accountRecord.IATACode__c);
		System.debug('date: ' + accountRecord.AOC_Expiry_Date__c);
	}
}
