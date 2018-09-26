global class ANG_PCIComplianceRenewalBatch implements Database.Batchable<Account>, Database.Stateful {

	//Batch will run every day and create a pci renewal OSCAR for each account with PCI expiry date expiring in 90 days

	private static final String AGENCYRTID = AMS_Utils.RECTYPE_IATAAGENCY;
	private static final String OSCARCOMMRTID = AMS_Utils.RECTYPE_OSCARCOMM;
	private static final Set<String> ACTIVE_ACC_STATUS = new Set<String>{AMS_Utils.ACC_S9_APPROVED, AMS_Utils.ACC_S8_CHANGESPROCESSED, AMS_Utils.ACC_S7_UNDERREVIEW, 
																		AMS_Utils.ACC_S6_CASHWITHCOMMISSION, AMS_Utils.ACC_S5_CASHNOCOMMISSION, AMS_Utils.ACC_S4_LISTED, 'Review'};

	private Date triggerRenewalDate;
	private Integer daysBeforeExpiry;

	private List<String> errors = new List<String>();
	private List<String> agenciesWithoutContact = new List<String>();

		
	global ANG_PCIComplianceRenewalBatch() {
		
	}

	// allows the batch to be run manually using a custom date to trigger the renewal
	global ANG_PCIComplianceRenewalBatch(Integer customDaysBeforeExpiry) {
		this.daysBeforeExpiry = customDaysBeforeExpiry;
	}
	
	global Iterable<Account> start(Database.BatchableContext BC) {

		triggerRenewalDate = Date.today().addDays(daysBeforeExpiry != null ? daysBeforeExpiry : 90);

	    String query = 'SELECT Id, Name, IataCode__c, BillingCountry, Region_formula__c,ANG_Accreditation_Model__c, Legal_name__c, '+
	    	'(SELECT Id, Name, Email, Preferred_Language__c, BSP_CASS_Payment_contact__c, Financial_Assessment_Contact__c, User_Portal_Status__c, New_BSPLink_Contact__c, AccountId '+
	    		'FROM Contacts WHERE Status__c = \'Active\' AND (User_Portal_Status__c = \'Approved Admin\' OR Financial_Assessment_Contact__c = true OR BSP_CASS_Payment_contact__c = true)) '+
	    	'FROM Account '+
	    	'WHERE RecordTypeId = :AGENCYRTID '+
	    	'AND Is_PCI_compliant__c = \'Yes\' '+
	    	'AND ANG_IsNewGenAgency__c = true '+
	    	'AND ANG_PCI_compliance_expiry_date__c = :triggerRenewalDate '+
	    	'AND Location_Class__c IN (\'P\',\'D\') '+
	    	'AND Status__c IN :ACTIVE_ACC_STATUS '+
	    	'AND Id NOT IN (SELECT AccountId FROM Case WHERE RecordTypeId = :OSCARCOMMRTID '+
	    		'AND Reason1__c = \'FoP Management\' AND IsClosed = false)';
	    	
    	return (Iterable<Account>) Database.getQueryLocator(query);
  	}

   	global void execute(Database.BatchableContext BC, List<Account> scope) {
   		Map<Id,List<Contact>> contactsPerAcc = new Map<Id,List<Contact>>();
   		List<Account> accsToProcess = new List<Account>();
   		List<String> iataCodesAndNames = new List<String>();
	
		try{
			for (Account acc : scope){
				if (!acc.contacts.isEmpty()){
					iataCodesAndNames.add(acc.IataCode__c+' - '+acc.Name);			
					accsToProcess.add(acc);		
					contactsPerAcc.put(acc.Id, new List<Contact>(acc.contacts));				
				} else {
					agenciesWithoutContact.add (acc.IataCode__c+' - '+acc.Name);
				}
			}
			List<Case> fopCases = ANG_OscarProcessHelper.createPCIComplianceOscars(accsToProcess, contactsPerAcc, contactsPerAcc.keySet(), AMS_Utils.ANG_FOP_AUTOMATIC_RENEWAL);
		}catch(Exception e){
			errors.add('Error running batch for Accounts with Iata code(s): '+String.join(iataCodesAndNames,',')+' - '+e.getMessage()+' - '+e.getStackTraceString());
		}
	}
	
	global void finish(Database.BatchableContext BC) {

		if(!errors.isEmpty() || !agenciesWithoutContact.isEmpty()){
			String errorMsg;
			String noContactAgents;
			if (!errors.isEmpty())
				errorMsg = String.join(errors,'\n\n');
			if (!agenciesWithoutContact.isEmpty())
				noContactAgents = +String.join(agenciesWithoutContact,'\n');

			//send email w/ errors to support
			List<String> emailAddresses = new List<String>();
			for (SalesforceSupportEmails__c supportEmail: SalesforceSupportEmails__c.getAll().values()){ 
                emailAddresses.add(supportEmail.Support_Email__c);
                //add more email addresses if needed
            }

            if (!emailAddresses.isEmpty()){
                Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
                mail.setToAddresses(emailAddresses);    
                mail.setSubject('ANG_PCIComplianceRenewalBatch Completed With Issues - End time: '+ System.now());
                mail.setSenderDisplayName('Batch Processing Completed');
                mail.setPlainTextBody('Batch Process has been completed with issues. Some OSCARs were not created due to the following issues: \n\n\tUNEXPECTED ERRORS:\n\n'
                 +errorMsg+'\n\n-------------------\n\n\tAGENTS WITHOUT VALID CONTACTS:\n\n'+noContactAgents);
                Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
            }

			System.debug('[ANG_PCIComplianceRenewalBatch] ERRORS: '+errorMsg);
			System.debug('[ANG_PCIComplianceRenewalBatch] AGENTS WITHOUT CONTACTS: '+noContactAgents);
		}
		
	}
	
}