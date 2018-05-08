global class ANG_PCIComplianceRenewalBatch implements Database.Batchable<Account>, Database.Stateful {

	private static final String AGENCYRTID = AMS_Utils.RECTYPE_IATAAGENCY;
	private static final String OSCARCOMMRTID = AMS_Utils.RECTYPE_OSCARCOMM;

	private Date triggerRenewalDate;
	private Integer daysBeforeExpiry;

		
	global ANG_PCIComplianceRenewalBatch() {
		
	}

	// allows the batch to be run manually using a custom date to trigger the renewal
	global ANG_PCIComplianceRenewalBatch(Integer customDaysBeforeExpiry) {
		this.daysBeforeExpiry = customDaysBeforeExpiry;
	}
	
	global Iterable<Account> start(Database.BatchableContext BC) {

		triggerRenewalDate = Date.today().addDays(daysBeforeExpiry != null ? daysBeforeExpiry : 90);

	    String query = 'SELECT Id, Name, IataCode__c, BillingCountry, Region_formula__c,ANG_Accreditation_Model__c, Legal_name__c, '+
	    	'(SELECT Id, Name, Email, Preferred_Language__c, BSP_CASS_Payment_contact__c, Financial_Assessment_Contact__c FROM Contacts WHERE Status__c = \'Active\') '+
	    	'FROM Account '+
	    	'WHERE RecordTypeId = :AGENCYRTID '+
	    	'AND Is_PCI_compliant__c = \'Yes\' '+
	    	'AND ANG_IsNewGenAgency__c = true '+
	    	'AND ANG_PCI_compliance_expiry_date__c = :triggerRenewalDate '+
	    	'AND Id NOT IN (SELECT AccountId FROM Case WHERE RecordTypeId = OSCARCOMMRTID '+
	    		'AND Reason1__c = \'FoP Management\' AND Status = \'Open\')';
	    	
    	return (Iterable<Account>) Database.getQueryLocator(query);
  	}

   	global void execute(Database.BatchableContext BC, List<Account> scope) {
   		Map<Id,List<Contact>> contactsPerAcc = new Map<Id,List<Contact>>();
	
		for (Account acc : scope){
			contactsPerAcc.put(acc.Id, new List<Contact>{acc.contacts});					
		}

		List<Case> fopCases = ANG_OscarProcessHelper.createPCIComplianceOscars(scope, contactsPerAcc, contactsPerAcc.keySet(), AMS_Utils.ANG_FOP_AUTOMATIC_RENEWAL);
	}
	
	global void finish(Database.BatchableContext BC) {
		
	}
	
}