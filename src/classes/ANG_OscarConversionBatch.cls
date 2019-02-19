global class ANG_OscarConversionBatch implements Database.Batchable<sObject>, Database.Stateful {
	
	global static final Set<String> oscarAMSProcessesToMigrate = new Set <String>{AMS_Utils.new_HO,AMS_Utils.new_BR,AMS_Utils.new_BR_ABROAD,AMS_Utils.new_SA,AMS_Utils.COR,AMS_Utils.AGENCYCHANGES};

	global static final Set<String> invalidOscarStatus = new Set<String>{'Closed (Closed)','Closed (Closed)','Closed','Closed_ Not Accepted','Closed_Rejected','Closed_Withdrawn'};

	global static final Set<Id> availableOscarRecordTypes = new Set<Id>{AMS_Utils.RECTYPE_CHANGE,AMS_Utils.RECTYPE_NEW, AMS_Utils.RECTYPE_CORRECTION};

    global static final Map<String,String> oscarProcessMap = new Map<String, String> {
        AMS_Utils.new_HO => AMS_Utils.NEWHESTANDARD,
        AMS_Utils.new_BR => AMS_Utils.NEWAE,
        AMS_Utils.new_BR_ABROAD => AMS_Utils.NEWAE,
        AMS_Utils.new_SA => AMS_Utils.NEWAE,
        AMS_Utils.AGENCYCHANGES => AMS_Utils.NGCHANGES,
        AMS_Utils.COR => AMS_Utils.NGCORRECTION
	};

    global static final Map<String,Id> oscarRecordTypeMap = new Map<String, Id> {
        AMS_Utils.new_HO => AMS_Utils.RECTYPE_NEWHE,
        AMS_Utils.new_BR => AMS_Utils.RECTYPE_NEWAE,
        AMS_Utils.new_BR_ABROAD => AMS_Utils.RECTYPE_NEWAE,
        AMS_Utils.new_SA => AMS_Utils.RECTYPE_NEWAE,
        AMS_Utils.AGENCYCHANGES => AMS_Utils.RECTYPE_NGCHANGES,
      	AMS_Utils.COR => AMS_Utils.RECTYPE_NGCORRECTION
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

	global static final Map<String,String> typeOfChangeMap = new Map<String, String> {
        'Ownership to non-IATA Agent' => 'Hierarchy;Ownership',
        'Ownership to IATA Agent' => 'Hierarchy;Ownership',
        'Location with inspection' => 'Location',
        'Name' => 'Legal name',
        'Major Shareholding' => 'Major shareholding',
        'Minor Shareholding' => 'Minor shareholding'
	};
	
	global ANG_OscarConversionBatch(String countryToSearch, String oscarName) {

		this.oscarName = oscarName;
		this.countryToSearch = countryToSearch;

		if(countryToSearch != null)
			this.query = 'SELECT Id,New_parent__c,AMS_Target_Agency__c, Type_of_change__c, Account__r.ANG_IsNewGenAgency__c, Account__r.Location_Type__c, Account__r.Name, Name, RecordTypeId, Process__c, AMS_Online_Accreditation__c, Account__r.Remittance_frequency__c, Account__r.Is_PCI_compliant__c from AMS_OSCAR__c where Status__c not in:invalidOscarStatus and Process__c in :oscarAMSProcessesToMigrate and account__r.ANG_IsNewGenAgency__c = true and account__r.IATA_ISO_Country__r.Name = :countryToSearch and recordTypeId in :availableOscarRecordTypes';
		else
			this.query = 'SELECT Id,New_parent__c,AMS_Target_Agency__c, Type_of_change__c, Account__r.ANG_IsNewGenAgency__c, Account__r.Location_Type__c, Account__r.Name, Name, RecordTypeId, Process__c, AMS_Online_Accreditation__c, Account__r.Remittance_frequency__c, Account__r.Is_PCI_compliant__c from AMS_OSCAR__c where Status__c not in:invalidOscarStatus and Process__c in :oscarAMSProcessesToMigrate and account__r.ANG_IsNewGenAgency__c = true and Name = :oscarName and recordTypeId in :availableOscarRecordTypes';

	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		System.debug('Query is:'+query);
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		
		AMS_OSCAR__c oscarToProcess = null;

		try{

			ANG_AgencyChangesHelper.isMigrationRunning = true;

	   		oscarToProcess = (AMS_OSCAR__c)scope.get(0);

	   		oscarToProcess = modifyOscar(oscarToProcess);

	   		System.debug('Oscar is now this:'+oscarToProcess);
			update oscarToProcess;

	   		AMS_Pax_Accreditation_Form__c stagingArea = modifyStagingArea(oscarToProcess);

	   		if(stagingArea != null)
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

	public static AMS_OSCAR__c modifyOscar(AMS_OSCAR__c oscarToProcess){

		oscarToProcess = Database.query(getAllSTEPSFieldQuery(oscarToProcess.Id));

		oscarToProcess.RecordTypeId = oscarRecordTypeMap.get(oscarToProcess.Process__c);
		oscarToProcess.Process__c = oscarProcessMap.get(oscarToProcess.Process__c);

	    Map<String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();

		Map<String, Schema.SObjectField> fieldMap = schemaMap.get('AMS_OSCAR__c').getDescribe().fields.getMap();

	    List<String> stepsOSCAR = new List<String>();

		for (String fieldName : fieldMap.keySet()) {
	        if (fieldName.startsWithIgnoreCase('STEP'))
    	        stepsOSCAR.add(fieldMap.get(fieldName).getDescribe().getLabel());
    	}

    	for (String step : stepsOSCAR) {
    		if(oscarToProcess.get(step + '__c') == null)
        		oscarToProcess.put(step + '__c', 'Not Started');
		}

		if(oscarToProcess.Process__c == AMS_Utils.NGCHANGES || oscarToProcess.Process__c == AMS_Utils.NGCORRECTION){
			
			String toReturn = '';

			oscarToProcess.New_parent__c = oscarToProcess.AMS_Target_Agency__c;

			String oldChanges = oscarToProcess.Type_of_change__c;

			if(oldChanges != null){

				List<String> multipleChanges = oscarToProcess.Type_of_change__c.split(';');

				for(String change: multipleChanges){

					String typeOfChange = typeOfChangeMap.get(change);

					if(typeOfChange != null)
						toReturn += typeOfChange + ';';
					else{ 
						toReturn += change + ';';

					}

				}

			toReturn = toReturn.removeEnd(';');

			oscarToProcess.ANG_Type_Of_Change__c = toReturn;

			}


		}

		if(oscarToProcess.Step6__c == AMS_Utils.PASSED)
			if(oscarToProcess.Process__c == AMS_Utils.NEWHESTANDARD || oscarToProcess.Process__c == AMS_Utils.NEWAE || oscarToProcess.Process__c == AMS_Utils.NEWHELITE)
				if(oscarToProcess.Is_PCI_compliant__c == null && oscarToProcess.Account__r.Is_PCI_compliant__c != null)
					oscarToProcess.Is_PCI_compliant__c = oscarToProcess.Account__r.Is_PCI_compliant__c;
				else
					oscarToProcess.Is_PCI_compliant__c = 'Yes';		
        
        return oscarToProcess;
	}

	public static String getAllSTEPSFieldQuery(String oscarToProcessId) {

       String fields = ' ';

		Map<String, Schema.SObjectField> fMap = Schema.sObjectType.AMS_OSCAR__c.fields.getMap();

		for(Schema.SObjectField field : fMap.values()){
		    
		    Schema.DescribeFieldResult fd = field.getDescribe();
		    if(fd.getName().startsWith('STEP')){ fields += fd.getName() + ', ';    System.debug('Field is:'+fd.getName());}
		}

		fields = fields.substring(0,fields.lastIndexOf(','));

		String toReturn = 'SELECT ' + fields + ', Type_of_change__c, New_parent__c, AMS_Target_Agency__c, RecordTypeId, Process__c, Account__r.ANG_IsNewGenAgency__c, Account__r.Location_Type__c, Account__r.Name, Name, AMS_Online_Accreditation__c, Account__r.Remittance_frequency__c, Account__r.Is_PCI_compliant__c FROM AMS_OSCAR__c where Id = \''+oscarToProcessId+'\' LIMIT 1';
		
        System.debug('Returning ' + toReturn);
        return toReturn;
		        
    }

	public static AMS_Pax_Accreditation_Form__c modifyStagingArea(AMS_OSCAR__c oscarToProcess){

		AMS_Pax_Accreditation_Form__c onlineForm = null;

		List<AMS_Pax_Accreditation_Form__c> onlineFormLst = [SELECT Id, Location_Type__c, Remittance_frequency__c from AMS_Pax_Accreditation_Form__c where Id = :oscarToProcess.AMS_Online_Accreditation__c LIMIT 1];

		if(onlineFormLst.isEmpty())
			return null;

		onlineForm = onlineFormLst.get(0);
			
		onlineForm.Location_Type__c = locationTypeMap.get(oscarToProcess.Account__r.Location_Type__c);
	
		if(onlineForm.Remittance_frequency__c == null)
			onlineForm.Remittance_frequency__c = oscarToProcess.Account__r.Remittance_frequency__c;
	
		return onlineForm;
	}

	public static Case modifyComunicationCase(AMS_OSCAR__c oscarToProcess){

		Case toReturn = null;

		List<Case> caseLst = [SELECT Id,Subject, CaseArea__c, Reason1__c from Case where RecordType.DeveloperName='OSCAR_Communication' and OSCAR__c = :oscarToProcess.Id and CaseNumber =: oscarToProcess.Name];
		
		if(!caseLst.isEmpty()){

			toReturn = caseLst.get(0);
		
			toReturn.CaseArea__c = 'Accreditation Process';
			
			if(oscarToProcess.Process__c == AMS_Utils.NEWHESTANDARD){
				toReturn.Subject = 'New HE standard' + ' - ' + oscarToProcess.Account__r.Name;
				toReturn.Reason1__c = 'New HE standard';
			}
			else if(oscarToProcess.Process__c == AMS_Utils.NEWAE){
				toReturn.Subject = 'New AE' + ' - ' + oscarToProcess.Account__r.Name;
				toReturn.Reason1__c = 'New AE';
			}
			else if(oscarToProcess.Process__c == AMS_Utils.NGCHANGES){
				toReturn.Subject = toReturn.Reason1__c + ' - ' + oscarToProcess.Account__r.Name;
				toReturn.CaseArea__c = 'Accreditation process';
			}



		}

		return toReturn;

	}

	global void finish(Database.BatchableContext BC) {
		
		ANG_AgencyChangesHelper.isMigrationRunning = false;

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