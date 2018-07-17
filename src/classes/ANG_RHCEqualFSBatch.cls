global class ANG_RHCEqualFSBatch implements Database.Batchable<Account>, Database.Stateful {

	private static final String AGENCYRTID = AMS_Utils.RECTYPE_IATAAGENCY;
	private static final Set<String> ACTIVE_ACC_STATUS = AMS_Utils.ACTIVEAGENCYSTATUS;

	List<ANG_RHC_Information__c> rhcInfosToUpdate = new List<ANG_RHC_Information__c>();
	List<String> iataCodesAndNames = new List<String>();

	private List<String> errors = new List<String>();
	private Integer agenciesProcessed = 0;

	private Set<String> bspsIds = new Set<String>();

	global ANG_RHCEqualFSBatch(Set<String> bspsIds) {
		this.bspsIds = bspsIds;
	}
	
	global Iterable<Account> start(Database.BatchableContext BC) {

	    String queryRHCs = 'SELECT Id, Name, IATACode__c, IATA_ISO_Country__r.AMS_Settlement_System__r.ANG_RHC_Amount_Equals_FS__c '+
	    		'(SELECT Id, ANG_RHC_Amount_Equals_FS__c FROM RHC_Informations__r)'+
	    	'FROM Account '+
	    	'WHERE RecordTypeId = :AGENCYRTID '+
	    	'AND ANG_IsNewGenAgency__c = true '+
	    	'AND IATA_ISO_Country__r.AMS_Settlement_System__c IN :bspsIds '+
	    	'AND Location_Class__c IN (\'P\',\'D\') '+
	    	'AND Status__c IN :ACTIVE_ACC_STATUS';

    	return (Iterable<Account>)Database.getQueryLocator(queryRHCs);
  	}

   	global void execute(Database.BatchableContext BC, List<Account> scope) {
			
		for (Account acc : (List<Account>)scope){
			if (!acc.RHC_Informations__r.isEmpty() && 
				acc.RHC_Informations__r[0].ANG_RHC_Amount_Equals_FS__c != acc.IATA_ISO_Country__r.AMS_Settlement_System__r.ANG_RHC_Amount_Equals_FS__c){

				iataCodesAndNames.add(acc.IataCode__c+' - '+acc.Name);
				acc.RHC_Informations__r[0].ANG_RHC_Amount_Equals_FS__c = acc.IATA_ISO_Country__r.AMS_Settlement_System__r.ANG_RHC_Amount_Equals_FS__c;								
				rhcInfosToUpdate.add(acc.RHC_Informations__r[0]);
			}						
		}

		if(!rhcInfosToUpdate.isEmpty()){
			agenciesProcessed += rhcInfosToUpdate.size();
		}
	}
	
	global void finish(Database.BatchableContext BC) {

		try{
			if(!rhcInfosToUpdate.isEmpty()){
				update rhcInfosToUpdate;
			}
		}catch(Exception e){
			errors.add('Error running batch for Agencies with Iata code(s): '+String.join(iataCodesAndNames,',')+' - '+e.getMessage()+' - '+e.getStackTraceString());
		}

		String emailMessage = '';
		List<String> emailAddresses = new List<String>();

		if(!errors.isEmpty()){

			for (SalesforceSupportEmails__c supportEmail: SalesforceSupportEmails__c.getAll().values()){ 
                emailAddresses.add(supportEmail.Support_Email__c);
                //add more email addresses if needed
            }

			emailMessage = String.join(errors,'\n\n');
		} else {
			emailMessage = 'A total of '+agenciesProcessed + ' agencies processed successfully!';
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