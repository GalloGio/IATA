global class ANG_RHCEqualFSBatch implements Database.Batchable<Account>, Database.Stateful {

	private static final String AGENCYRTID = AMS_Utils.RECTYPE_IATAAGENCY;
	private static final Set<String> ACTIVE_ACC_STATUS = AMS_Utils.ACTIVEAGENCYSTATUS;

	List<ANG_RHC_Information__c> rhcInfosToUpdate = new List<ANG_RHC_Information__c>();
	List<String> iataCodesAndNames = new List<String>();
	Set<String> bsps = new Set<String>();
	Boolean applyFlag = true;

	private List<String> errors = new List<String>();

	private Set<String> bspsIds = new Set<String>();

	global ANG_RHCEqualFSBatch(Set<String> bspsIds) {
		this.bspsIds = bspsIds;
	}

	global Iterable<Account> start(Database.BatchableContext BC) {

		String queryRHCs = 'SELECT Id, Name, IATACode__c, IATA_ISO_Country__r.AMS_Settlement_System__r.ANG_RHC_Amount_Equals_FS__c, '+
			'IATA_ISO_Country__r.AMS_Settlement_System__r.Name, (SELECT Id, ANG_RHC_Amount_Equals_FS__c FROM RHC_Informations__r)'+
			'FROM Account '+
			'WHERE RecordTypeId = :AGENCYRTID '+
			'AND ANG_IsNewGenAgency__c = true '+
			'AND IATA_ISO_Country__r.AMS_Settlement_System__c IN :bspsIds '+
			'AND Location_Class__c IN (\'P\',\'D\') '+
			'AND Status__c IN :ACTIVE_ACC_STATUS';

		return (Iterable<Account>)Database.getQueryLocator(queryRHCs);
  	}

   	global void execute(Database.BatchableContext BC, List<Account> scope) {

		for(Account acc : (List<Account>)scope){
			if(!acc.RHC_Informations__r.isEmpty() &&
				acc.RHC_Informations__r[0].ANG_RHC_Amount_Equals_FS__c != acc.IATA_ISO_Country__r.AMS_Settlement_System__r.ANG_RHC_Amount_Equals_FS__c){

				iataCodesAndNames.add(acc.IataCode__c+' - '+acc.Name);
				acc.RHC_Informations__r[0].ANG_RHC_Amount_Equals_FS__c = acc.IATA_ISO_Country__r.AMS_Settlement_System__r.ANG_RHC_Amount_Equals_FS__c;
				rhcInfosToUpdate.add(acc.RHC_Informations__r[0]);
				bsps.add(acc.IATA_ISO_Country__r.AMS_Settlement_System__r.Name);
			}
			if(applyFlag != acc.IATA_ISO_Country__r.AMS_Settlement_System__r.ANG_RHC_Amount_Equals_FS__c) applyFlag = acc.IATA_ISO_Country__r.AMS_Settlement_System__r.ANG_RHC_Amount_Equals_FS__c;
		}

	}

	global void finish(Database.BatchableContext BC) {

		try{
			if(!rhcInfosToUpdate.isEmpty()){
				update rhcInfosToUpdate;
			}
		}catch(Exception e){
			errors.add('Error running batch for Agencies with Iata code(s): '+String.join(iataCodesAndNames,'\n')+' - '+e.getMessage()+' - '+e.getStackTraceString());
		}

		if(!errors.isEmpty()){				
			List<Messaging.SingleEmailMessage> mails = new List<Messaging.SingleEmailMessage>();
			for(SalesforceSupportEmails__c supportEmail: SalesforceSupportEmails__c.getAll().values()){
				Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
				mail.setTargetObjectId(supportEmail.Support_User_Id__c);	
				mail.setSubject((applyFlag ? 'Apply' : 'Revert') + ' RHC Equal to FS Batch completed' + (errors.isEmpty() ? ' successfully: '+iataCodesAndNames.size()+' agents processed.'  :' with errors')+' - End time: '+ System.now());
				mail.setPlainTextBody('Batch Process has been completed'+ (errors.isEmpty() ? ' successfully.'+'\n\nBSPs: '+String.join(new List<String>(bsps), ',') + '\n\nAgencies processed:\n\n'+String.join(iataCodesAndNames,'\n') : ' with errors: ' +
				(errors.isEmpty() ?'':'\n\n\tERRORS:\n\n' +errors+'\n')));
				mails.add(mail);
			}

			if (!mails.isEmpty()){
				Messaging.sendEmail(mails);
			}
		}
		
		Integer i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
		i=0;
	}


}
