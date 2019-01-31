/*
 * This class contains helper methods for the creation of Case records.
 */

public with sharing class CaseFactory {
	
	/*
	 * Creates a renewal reminder case for the Financial Security record provided as a parameter
	 */
	public static Case CreateFinancialSecurityCase(Financial_Security__c FSRecord, Boolean SaveToDB) {
		// Create a customer type mapping using the account Industry as key, and the corresponding case Type of Customer as value
		map<String, String> mapCustomerTypeMapping = new map<String, String>();
		mapCustomerTypeMapping.put('Travel Agent', 'IATA Travel Agent');
		mapCustomerTypeMapping.put('Cargo Agent', 'IATA Cargo Agent');
		
		// Create a cargo business mapping using the account Industry as key, and the corresponding case Cargo Business as value
		map<String, String> mapCargoBusinessMapping = new map<String, String>();
		mapCargoBusinessMapping.put('Cargo Agent', 'Export');
		
		
		// Create the new case
		Case fsCase = new Case();
		
				
		fsCase.Origin = 'Internal Case';
		fsCase.RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'ProcessEuropeSCE'); // label "Process (IDFS ISS)" / "SAAM"
		
		fsCase.Subject = '#SARA ' + FSRecord.Account_Country__c + ' Renewal - ' + FSRecord.IATA_code__c + ' - ' + FSRecord.Expiry_Date__c;
		fsCase.Status = 'Open';
		fsCase.CaseArea__c = 'Risk Management Process';
		fsCase.Reason1__c = 'Financial Security Renewal';
		fsCase.Region__c = FSRecord.Region__c;
		fsCase.BSPCountry__c = FSRecord.Account_Country__c;
		fsCase.AccountId = FSRecord.Account__c;
		//fsCase.Type_of_customer__c = FSRecord.Account__r.Industry != null ? mapCustomerTypeMapping.get(FSRecord.Account__r.Industry) : null;
		fsCase.Type_of_customer__c = FSRecord.Account__r.Type != null ? FSRecord.Account__r.Type : null;
		fsCase.Cargo_Business__c =  FSRecord.Account__r.Industry != null ? mapCargoBusinessMapping.get(FSRecord.Account__r.Industry) : null;
		
		system.debug('Account Industry: ' + FSRecord.Account__r.Industry);
		system.debug('Matched customer type: ' + mapCustomerTypeMapping.get(FSRecord.Account__r.Industry));
		
		fsCase.Description = 'Country: ' + FSRecord.Account_Country__c + '\n\n' + 
							'Agent: \n' + 
							'Account: ' + FSRecord.Account__r.Name + '\n' +  
							'IATA code: ' + FSRecord.IATA_code__c + '\n\n' +
							
							'Security: \n' + 
							'Amount: ' + FSRecord.Amount__c + '\n' + 
							'Expiry date: ' + FSRecord.Expiry_Date__c + '\n\n' +
							
							'Additional Information: \n' + 
							'Financial Security Name: ' + FSRecord.Name + '\n' + 
							'Security Type: ' + FSRecord.Security_Type__c + '\n' + 
							'Financial Institution: ' + FSRecord.Financial_Institution__r.Name + '\n' + 
							'Remarks: ' + (FSRecord.Remarks__c != null ? FSRecord.Remarks__c : '');
		
		// Set the option to assign the new Case using the default Assignment Rule
		Database.DMLOptions dmo = new Database.DMLOptions();
		dmo.assignmentRuleHeader.useDefaultRule= true;
		fsCase.setOptions(dmo);
		
		
		if (SaveToDB) {
			try {
				insert fsCase;
			} catch (System.DmlException e) {
				system.debug('## ERROR: ' + e.getMessage());
			} 
		}
		
		return fsCase;
	}
}