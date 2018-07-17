global class ANG_RHCEqualFSBatch implements Database.Batchable<SObject>, Database.Stateful {

	private static final String AGENCYRTID = AMS_Utils.RECTYPE_IATAAGENCY;
	private static final Set<String> ACTIVE_ACC_STATUS = AMS_Utils.ACTIVEAGENCYSTATUS;

	List<SObject> sObjectToUpdate = new List<SObject>();

	private List<String> errors = new List<String>();
	private Integer agenciesProcessed = 0;
	private Integer bspsProcessed = 0;

	private String mode;
	private Set<String> values = new Set<String>();

	// Expecting mode to be either 'bsp-apply', 'bsp-revert' or 'iatacode-apply' 'iatacode-revert'. Values can contain either iata codes or bsp operations depending on the mode 
	global ANG_RHCEqualFSBatch(String mode, Set<String> values) {
		this.mode = mode;
		this.values = values;
	}
	
	global Iterable<SObject> start(Database.BatchableContext BC) {

	    String queryBSP = 'SELECT Id, Name, ANG_RHC_Amount_Equals_FS__c '+
	    	'FROM AMS_Settlement_System__c '+
	    	'WHERE RecordType.Name = \'BSP\' '+
	    	'AND Name IN :values '+
	    	'AND ANG_RHC_Amount_Equals_FS__c = '+(mode.endsWithIgnoreCase('-apply') ? 'false' : 'true');

	    String queryIataCodes = 'SELECT Id, Name, IATACode__c, '+
	    	'(SELECT Id, ANG_RHC_Amount__c, ANG_Financial_Security__c, ANG_RHC_Amount_Equals_FS__c FROM RHC_Informations__r '+
	    		'WHERE ANG_RHC_Amount_Equals_FS__c = '+(mode.endsWithIgnoreCase('-apply') ? 'false' : 'true')+') '+
	    	'FROM Account '+
	    	'WHERE RecordTypeId = :AGENCYRTID '+
	    	'AND ANG_IsNewGenAgency__c = true '+
	    	'AND Location_Class__c IN (\'P\',\'D\') '+
	    	'AND Status__c IN :ACTIVE_ACC_STATUS '+
	    	'AND IATACode__c IN :values';

    	return Database.getQueryLocator((mode.startsWithIgnoreCase('iatacode-') ? 
    								queryIataCodes : mode.startsWithIgnoreCase('bsp-') ?
    								queryBSP : ''));
  	}

   	global void execute(Database.BatchableContext BC, List<SObject> scope) {

   		if (mode.startsWith('iatacode-')){

	   		List<String> iataCodesAndNames = new List<String>();
	   		List<ANG_RHC_Information__c> rhcInfosToUpdate = new List<ANG_RHC_Information__c>();
	   		ANG_RHC_Information__c rhcInfo;
		
			try{
				for (Account acc : (List<Account>)scope){
					if (!acc.RHC_Informations__r.isEmpty()){
						iataCodesAndNames.add(acc.IataCode__c+' - '+acc.Name);
						rhcInfo = new ANG_RHC_Information__c(Id = acc.RHC_Informations__r[0].Id, ANG_RHC_Amount_Equals_FS__c = (mode.endsWithIgnoreCase('-apply')));		
						rhcInfosToUpdate.add(rhcInfo);
					}						
				}
				if(!rhcInfosToUpdate.isEmpty()){
					//update rhcInfosToUpdate;
					sObjectToUpdate.addAll(rhcInfosToUpdate);
					agenciesProcessed += rhcInfosToUpdate.size();
				}

			}catch(Exception e){
				errors.add('Error running batch for Agencies with Iata code(s): '+String.join(iataCodesAndNames,',')+' - '+e.getMessage()+' - '+e.getStackTraceString());
			}

   		}else{

   			List<AMS_Settlement_System__c> operationsToUpdate = new List<AMS_Settlement_System__c>();
   			
   			try{
   				for(AMS_Settlement_System__c bsp :(List<AMS_Settlement_System__c>) scope){
   					bsp.ANG_RHC_Amount_Equals_FS__c = (mode.endsWithIgnoreCase('-apply'));
   					operationsToUpdate.add(bsp);			
   				}

	   			if(!operationsToUpdate.isEmpty()){
	   				sObjectToUpdate.addAll(operationsToUpdate);
	   				//update operationsToUpdate;
					bspsProcessed += operationsToUpdate.size();
	   			}

   			}catch(Exception e){
				errors.add('Error running batch for BSP: '+values+' - '+e.getMessage()+' - '+e.getStackTraceString());
			}
   		}
	}
	
	global void finish(Database.BatchableContext BC) {

		if (!sObjectToUpdate.isEmpty()){
			try{
				update sObjectToUpdate;
			}catch(Exception e){
				errors.add('Error running batch: '+values+' - '+e.getMessage()+' - '+e.getStackTraceString());
			}
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
			emailMessage = 'A total of '+(mode.startsWithIgnoreCase('iatacode-') ? agenciesProcessed + ' agencies' : bspsProcessed + ' BSPs' )+' processed successfully!';
		}
        
        if (emailMessage != ''){
            Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
            emailAddresses.add(UserInfo.getUserEmail());
            mail.setToAddresses(emailAddresses);    
            mail.setSubject('RHC Equal to FS Batch completed' + (errors.isEmpty() ? ' successfully'  :' with errors'+' - End time: '+ System.now()));
            mail.setSenderDisplayName('Batch Processing Completed');
            mail.setPlainTextBody('Batch Process has been completed'+ (errors.isEmpty() ? ' successfully.'  : ' with errors: ') +
            (errors.isEmpty() ?'\n\nBSPs Processed: '+bspsProcessed+'\nIATA codes processed: '+agenciesProcessed :'\n\n\tERRORS:\n\n' +String.join(errors,'\n')));
            Messaging.sendEmail(new Messaging.SingleEmailMessage[] {mail});
        }

		System.debug('[ANG_RHCEqualFSBatch] ERRORS: '+errors);
		System.debug('[ANG_RHCEqualFSBatch] PROCESSED AGENTS: '+agenciesProcessed);
		System.debug('[ANG_RHCEqualFSBatch] PROCESSED BSPs: '+bspsProcessed);
		
	}
	
}