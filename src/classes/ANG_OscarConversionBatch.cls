global class ANG_OscarConversionBatch implements Database.Batchable<sObject>, Database.Stateful {
	
	global static final Set<String> oscarAMSProcessesToMigrate = new Set <String>{AMS_Utils.new_HO,AMS_Utils.new_BR,AMS_Utils.new_BR_ABROAD,AMS_Utils.new_SA};

	global static final Set<String> locationClassAllowed = new Set <String>{'P'};

	global static final Set<String> invalidOscarStatus = new Set<String>{'Closed (Closed)','Closed (Closed)','Closed','Closed_ Not Accepted','Closed_Rejected','Closed_Withdrawn'};

    global static final Map<String,String> oscarProcessMap = new Map<String, String> {
        AMS_Utils.new_HO => AMS_Utils.NEWHESTANDARD,
        AMS_Utils.new_BR => AMS_Utils.NEWAE,
        AMS_Utils.new_BR_ABROAD => AMS_Utils.NEWAE,
        AMS_Utils.new_SA => AMS_Utils.NEWAE
	};

    global static final Map<String,Id> oscarRecordTypeMap = new Map<String, Id> {
        AMS_Utils.new_HO => AMS_Utils.RECTYPE_NEWHE,
        AMS_Utils.new_BR => AMS_Utils.RECTYPE_NEWAE,
        AMS_Utils.new_BR_ABROAD => AMS_Utils.RECTYPE_NEWAE,
        AMS_Utils.new_SA => AMS_Utils.RECTYPE_NEWAE
	};

    global static final Map<String,String> locationTypeMap = new Map<String, String> {
        AMS_Utils.HO => AMS_Utils.HE,
        AMS_Utils.AO => AMS_Utils.HE,
        AMS_Utils.BR => AMS_Utils.AE,
        AMS_Utils.SA => AMS_Utils.AE,
        AMS_Utils.AE => AMS_Utils.AE,
        AMS_Utils.HE => AMS_Utils.HE
	};

	global Map<String,String> executionStatusOk = new Map<String, String>();
	global Map<String,String> executionStatusNOk = new Map<String, String>();

	String query;

	global String oscarName;

	global String countryToSearch;
	
	global ANG_OscarConversionBatch(String countryToSearch, String oscarName) {
		
		this.oscarName = oscarName;
		this.countryToSearch = countryToSearch;

		if(countryToSearch != null)
			this.query = 'SELECT Id, Account__r.Location_Type__c, Account__r.Name, Name, RecordTypeId, Process__c, AMS_Online_Accreditation__c from AMS_OSCAR__c where Status__c not in:invalidOscarStatus and Process__c in :oscarAMSProcessesToMigrate and account__r.Location_Class__c in :locationClassAllowed and account__r.IATA_ISO_Country__r.Name = :countryToSearch and recordTypeId = \''+AMS_Utils.RECTYPE_NEW +'\'';
		else
			this.query = 'SELECT Id, Account__r.Location_Type__c, Account__r.Name, Name, RecordTypeId, Process__c, AMS_Online_Accreditation__c from AMS_OSCAR__c where Status__c not in:invalidOscarStatus and Process__c in :oscarAMSProcessesToMigrate and account__r.Location_Class__c in :locationClassAllowed and Name = :oscarName and recordTypeId = \''+AMS_Utils.RECTYPE_NEW +'\'';

	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		System.debug('Query is:'+query);
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		
		AMS_OSCAR__c oscarToProcess = null;

		try{

	   		oscarToProcess = (AMS_OSCAR__c)scope.get(0);

	   		modifyOscar(oscarToProcess);
			update oscarToProcess;

	   		AMS_Pax_Accreditation_Form__c stagingArea = modifyStagingArea(oscarToProcess);
			update stagingArea;

	   		Case communicationCase = modifyComunicationCase(oscarToProcess);

	   		if(communicationCase != null)
		   		update communicationCase;
		   	else
		   		throw new AMS_ApplicationException('Could not find case for OSCAR ' + oscarToProcess.Name);

	   		executionStatusOk.put(oscarToProcess.Name,'Success');

		}catch(Exception e){
			System.debug('Failed to process OSCAR ' + oscarToProcess.Name + '. Reason:'+e.getStackTraceString());executionStatusNOk.put(oscarToProcess.Name,e.getMessage());throw e;
		}
	}

	public static void modifyOscar(AMS_OSCAR__c oscarToProcess){

		oscarToProcess.RecordTypeId = oscarRecordTypeMap.get(oscarToProcess.Process__c);
		oscarToProcess.Process__c = oscarProcessMap.get(oscarToProcess.Process__c);
	}

	public static AMS_Pax_Accreditation_Form__c modifyStagingArea(AMS_OSCAR__c oscarToProcess){

		AMS_Pax_Accreditation_Form__c onlineForm = [SELECT Id, Location_Type__c from AMS_Pax_Accreditation_Form__c where Id = :oscarToProcess.AMS_Online_Accreditation__c LIMIT 1];

		onlineForm.Location_Type__c = locationTypeMap.get(oscarToProcess.Account__r.Location_Type__c);

		return onlineForm;
	}

	public static Case modifyComunicationCase(AMS_OSCAR__c oscarToProcess){

		Case toReturn = null;

		List<Case> caseLst = [SELECT Id,Subject, CaseArea__c, Reason1__c from Case where RecordType.DeveloperName='OSCAR_Communication' and OSCAR__c = :oscarToProcess.Id and Subject like 'New%' and CaseNumber =: oscarToProcess.Name];
		
		if(!caseLst.isEmpty()){

			toReturn = caseLst.get(0);
		
			toReturn.CaseArea__c = 'Accreditation Process';
			
			if(oscarToProcess.Process__c == AMS_Utils.NEWHESTANDARD){
				toReturn.Subject = 'New HE standard' + ' - ' + oscarToProcess.Account__r.Name;
				toReturn.Reason1__c = 'New HE standard';
			}
			else{
				toReturn.Subject = 'New AE' + ' - ' + oscarToProcess.Account__r.Name;
				toReturn.Reason1__c = 'New AE';
			}

		}

		return toReturn;

	}

	global void finish(Database.BatchableContext BC) {
		
		Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();

		//Below code will fetch the job Id
		AsyncApexJob a = [Select a.TotalJobItems, a.Status, a.NumberOfErrors, a.JobType, a.JobItemsProcessed, a.ExtendedStatus, a.CreatedById, a.CompletedDate From AsyncApexJob a WHERE id = :BC.getJobId()];
		
		System.debug('$$$ Jobid is'+BC.getJobId());

		String userName = UserInfo.getUserName();
		User activeUser = [Select Email From User where Username = : userName limit 1];
		String userEmail = activeUser.Email;

		//below code will send an email to User about the status
		mail.setToAddresses( new String[] {userEmail} );
		mail.setSenderDisplayName('Apex Newgen Conversion Batch Processing Module');
		mail.setSubject('Batch Processing '+a.Status);

		String toReturnBody = 'The Batch Apex job ('+BC.getJobId()+')processed  '+a.TotalJobItems+' batches with '+a.NumberOfErrors+' failures.'+' Job Item processed are'+a.JobItemsProcessed+'\n\n';

		toReturnBody+= ':: OSCARs Processed ::'+'\n';

		Set<String> valuesOK = executionStatusOk.keySet();

		for(String item: valuesOK)
				toReturnBody+=item+':'+executionStatusOk.get(item)+'\n';

		toReturnBody+= '\n\n';

		toReturnBody+= ':: OSCARs in ERROR ::'+'\n';

		Set<String> valuesNOK = executionStatusNOk.keySet();

		for(String item: valuesNOK)
				toReturnBody+=item+':'+executionStatusNOk.get(item)+'\n';

		mail.setPlainTextBody(toReturnBody);

		 if(Test.isRunningTest()){
		 	return;
		 }

		Messaging.sendEmail(new Messaging.Singleemailmessage [] {mail});

	}
	
}