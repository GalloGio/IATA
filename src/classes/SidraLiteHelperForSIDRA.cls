public with sharing class SidraLiteHelperForSIDRA {

	public static final Set<String> ALLOWED_ACCOUNT_STATUS = new Set<String>{'Approved', 'Changes processed'};
	
	public class SidraLiteException extends Exception {}


	public static void checkBussinessRules(Case parentCase){

		if(parentCase.GDI_Premium__c == null || parentCase.GDI_Premium__c == 0) throw new SidraLiteException('Conditions are not met to create a Financial security non-compliance case: GDI Premium cannot be 0.');
		if(parentCase.Short_Payment_Amount__c == null || parentCase.Short_Payment_Amount__c == null || parentCase.IATA_Charges__c == null || parentCase.Agency_Fees__c == null
				|| parentCase.Region__c == null || parentCase.ContactId == null || parentCase.BSPCountry__c == null) throw new SidraLiteException('Conditions are not met to create a Financial security non-compliance case: A value is required for Short Payment Amount, IATA Charges, Agency Fees fields, IATA Country, Contact Name and Region.');
		if(parentCase.Short_Payment_Amount__c > (parentCase.Short_Payment_Amount__c + parentCase.IATA_Charges__c + parentCase.Agency_Fees__c)) throw new SidraLiteException('Conditions are not met to create a Financial security non-compliance case: Short Payment Amount cannot exceed GDI Premium + IATA Charges + Agency Fees.');
		if(!ALLOWED_ACCOUNT_STATUS.contains(parentCase.Account.Status__c)) throw new SidraLiteException('Conditions are not met to create a Financial security non-compliance case: Invalid Account Status: '+parentCase.Account.Status__c+'.');
	}

	/**
        Create a dummy case to set the default values for first non compliance date
    **/
    public static Case createDummyCaseFirstNonCompliance(Case parentCase) {

        Case newCase = new Case();
        newCase.RecordTypeId = SidraLiteManager.RECORDTYPE_SIDRA_LITE;
        newCase.Subject = 'SIDRA Lite – Financial Security Non-compliance';
        newCase.ParentId = parentCase.Id;
        newCase.Region__c = parentCase.Region__c;
        newCase.BSPCountry__c = parentCase.BSPCountry__c;
        newCase.Priority = 'Normal';
        newCase.AccountId = parentCase.AccountId;
        newCase.ContactId = parentCase.ContactId;
        newCase.Origin = 'IATA Internal User';
        newCase.Status = 'Open';
        newCase.SIDRA_Lite_Reason__c = 'Financial Security Non-compliance';
        newCase.SIDRA_Lite_Default_Date__c = Date.today();
        newCase.Reason_for_Default__c ='Suspension - FS Non Compliance';

        return newCase;
    }

}