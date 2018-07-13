global class ANG_RHCEqualFSBatch  implements Database.Batchable<Account>, Database.Stateful {

	private static final String AGENCYRTID = AMS_Utils.RECTYPE_IATAAGENCY;
	private static final Set<String> ACTIVE_ACC_STATUS = AMS_Utils.ACTIVEAGENCYSTATUS;

	private List<String> errors = new List<String>();
	private Integer agenciesProcessed = 0;
	private List<String> bspsToUpdate = new List<String>();

	private String mode;
	private Set<String> values = new Set<String>();

	// Expecting mode to be either 'bspflagging', 'bspdeflagging' or 'iatacode'. Values can contain either iata codes or bsp operations depending on the mode 
	global ANG_RHCEqualFSBatch(String mode, Set<String> values) {
		this.mode = mode;
		this.values = values;
	}
	
	global Iterable<Account> start(Database.BatchableContext BC) {

	    String queryBSPflagging = '[SELECT Id, Name, IATACode__c, '+
	    	'(SELECT Id, ANG_RHC_Amount__c, ANG_Financial_Security__c FROM RHC_Informations__r ) '+
	    	'FROM Account '+
	    	'WHERE RecordTypeId = :AGENCYRTID '+
	    	'AND ANG_IsNewGenAgency__c = true '+
	    	'AND Location_Class__c IN (\'P\',\'D\') '+
	    	'AND Status__c IN :ACTIVE_ACC_STATUS '+
	    	'AND Id IN (SELECT Account__c FROM AMS_Agency_Operations__c WHERE Operation__r.Settlement__r.Name IN :values)';

	    String queryIataCodes = '[SELECT Id, Name, IATACode__c, '+
	    	'(SELECT Id, ANG_RHC_Amount__c, ANG_Financial_Security__c FROM RHC_Informations__r ) '+
	    	'FROM Account '+
	    	'WHERE RecordTypeId = :AGENCYRTID '+
	    	'AND ANG_IsNewGenAgency__c = true '+
	    	'AND Location_Class__c IN (\'P\',\'D\') '+
	    	'AND Status__c IN :ACTIVE_ACC_STATUS '+
	    	'AND IATACode__c IN :values';

    	return (Iterable<Account>) Database.getQueryLocator((mode.equalsIgnoreCase('iatacode') ? 
    								queryIataCodes : mode.equalsIgnoreCase('bspflagging') ?
    								queryBSPflagging : ''));
  	}

   	global void execute(Database.BatchableContext BC, List<Account> scope) {
   		List<String> iataCodesAndNames = new List<String>();
   		List<ANG_RHC_Information__c> rhcInfosToUpdate = new List<ANG_RHC_Information__c>();
   		ANG_RHC_Information__c rhcInfo;
	
		try{
			for (Account acc : scope){
				if (!acc.RHC_Informations__r.isEmpty() && acc.RHC_Informations__r[0].ANG_RHC_Amount__c != acc.RHC_Informations__r[0].ANG_Financial_Security__c){
					iataCodesAndNames.add(acc.IataCode__c+' - '+acc.Name);
					rhcInfo = new ANG_RHC_Information__c(Id = acc.RHC_Informations__r[0].Id, ANG_RHC_Amount__c = acc.RHC_Informations__r[0].ANG_Financial_Security__c);		
					rhcInfosToUpdate.add(rhcInfo);
				}						
			}
			if(!rhcInfosToUpdate.isEmpty()){
				update rhcInfosToUpdate;
				agenciesProcessed += rhcInfosToUpdate.size();
			}

		}catch(Exception e){
			errors.add('Error running batch for Agencies with Iata code(s): '+String.join(iataCodesAndNames,',')+' - '+e.getMessage()+' - '+e.getStackTraceString());
		}
	}
	
	global void finish(Database.BatchableContext BC) {

		String emailMessage = '';
		List<String> emailAddresses = new List<String>();

		if(!errors.isEmpty()){

			for (SalesforceSupportEmails__c supportEmail: SalesforceSupportEmails__c.getAll().values()){ 
                emailAddresses.add(supportEmail.Support_Email__c);
                //add more email addresses if needed
            }

			emailMessage = String.join(errors,'\n\n');
		} else {
			emailMessage = 'A total of '+agenciesProcessed+' agencies processed successfully!';
		}
        
        if (emailMessage != ''){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            emailAddresses.add(UserInfo.getUserEmail());
            mail.setToAddresses(emailAddresses);    
            mail.setSubject('RHC Equal to FS Batch completed' + (errors.isEmpty() ? ' successfully'  :' with errors'+' - End time: '+ System.now()));
            mail.setSenderDisplayName('Batch Processing Completed');
            mail.setPlainTextBody('Batch Process has been completed'+ (errors.isEmpty() ? ' successfully.'  : ' with errors: ') +
            (errors.isEmpty() ?'':'\n\n\tERRORS:\n\n' +String.join(errors,'\n')));
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
        }

		System.debug('[ANG_RHCEqualFSBatch] ERRORS: '+errors);
		System.debug('[ANG_RHCEqualFSBatch] PROCESSED AGENTS: '+agenciesProcessed);
		
	}
	
}