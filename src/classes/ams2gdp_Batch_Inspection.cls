global class ams2gdp_Batch_Inspection implements Database.Batchable<sObject> , Database.Stateful
{
	public String query;
	public List<String> extraIds;
	public Integer errorsCount;
	public Integer totalRecords;
	public List<String> failed_records;
	public Datetime syncStartedDate;
	public Boolean processNextBatch;
	public Boolean throwException;
	public String batchName;
	Set<String> locationsSet;
	Set<String> statusSet;
	public Boolean isManual;
	public void init(Boolean runNext, List<String> ids, Boolean manual)
	{
		batchName = 'Job 2: Accreditation';
		processNextBatch = runNext;
		extraIds = ids;
		isManual = manual==null ? false : manual;		

		Map<String, String> recordTypes = ams2gdp_Utils.getRecordTypeIdByName('Account');

		String fields = ' Id, Name, Status__c, Date_Organisation_Status_attained__c, AIMS_ID__c, Webstar_ID__c '
			+', Location_Class__c, Check_Digit__c, IATACode__c '
			+', Organization_Last_Change_Date__c,  Original_Approval_DAte__c, Accreditation_date__c '
			+', Main_Accreditation_Organization__c, Verification_Date__c '
			+', ANG_IsNewGenAgency__c, ANG_Accreditation_Model__c, ANG_RiskStatus__c, ANG_CashCondition__c, Due_Diligence_Status__c'
			+', IATA_ISO_Billing_State__r.ISO_Code__c, IATA_ISO_Country__r.ISO_Code__c, IATA_ISO_Country__r.AIMS_Area_ID__c,CNS_Agency__c' ;

		//-- Query conditions
		List<String> conditions = new List<String>{'RecordTypeId= \''+recordTypes.get('Agency')+'\''
			,	'IATACode__c != null'
			// ,	'Status__c NOT IN (\'Not accreditated\',\'New application pending\',\'Not in operation\',\'On hold\',\'applicant\',\'Unregisterable STP\')'
			,	'Main_Accreditation_Organization__c IN (\'IATA\',\'IATAN\',\'DOM\') '
			,	'CNS_Agency__c = false'
			,	'CNS_Account__c = false'
		};

		if(!String.isBlank(AMS_2_GDP_Settings__c.getOrgDefaults().Status__c)) {
			statusSet = new Set<String>(AMS_2_GDP_Settings__c.getOrgDefaults().Status__c.split(';'));
			conditions.add(' Status__c IN :  statusSet');
		}
		if(!String.isBlank(AMS_2_GDP_Settings__c.getOrgDefaults().Location_Classes__c)) {
			locationsSet = new Set<String>(AMS_2_GDP_Settings__c.getOrgDefaults().Location_Classes__c.split(';'));
			conditions.add(' Location_Class__c IN :  locationsSet');
		}


		if(extraIds!=null && extraIds.size() > 0) {
			 if(extraIds[0]=='none'){
			 conditions.add('Id=null');}
			 else{
			//Run batch on specific Ids
			List<String> specificIds = new List<String>();
			for(String s: extraIds)
			{
				if(s.length() >= 15) specificIds.add(s.left(15));
			}

			if(specificIds.size() > 0)	conditions.add('Id IN (\''+String.join(specificIds,'\', \'')+'\')');}
		}else{
			AMS_GDP_Batch__c batchInfo = ams2gdp_Selector.getBatchInfo(batchName);
			if(batchInfo != null)
			{
				//Run only on the deltas
				String deltaConditions = String.format('LastModifiedDate >= {0}'
					,new List<String>{batchInfo.Last_Sync_Start_Date__c.addDays(-2).format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'','GMT')});

				if(String.isNotBlank(batchInfo.Failed_Records__c))
				{
					// Reprocess failed records
					List<String> failedRecordIds = new List<String>();
					for(String s: batchInfo.Failed_Records__c.split(';'))
					{
						if(s.length() >= 15)
							failedRecordIds.add(s.left(15));
					}
					if(failedRecordIds.size() > 0)
						deltaConditions += ' OR Id IN (\'' + String.join(failedRecordIds, '\' , \'') + '\') ';
				}

				conditions.add('('+deltaConditions+')');
			}
		}

		System.debug('conditions::'+conditions);

		query = String.format('SELECT {0} '
			+	'FROM Account '
			+ 	'WHERE {1} '
			+	'ORDER BY IATACode__c ',
			new List<String>{fields,String.join(conditions, ' AND ')}
		);

        system.debug(LOGGINGLEVEL.ERROR, 'LF: QUERY: '+query);
	}

	global ams2gdp_Batch_Inspection()
	{
		init(false, null, null);
	}

	global ams2gdp_Batch_Inspection(Boolean runNext, Boolean manual)
	{
		init(runNext,null, manual);
	}

	global ams2gdp_Batch_Inspection(Boolean runNext, List<String> extra, Boolean manual)
	{
		init(runNext,extra,manual);
	}

	global Database.QueryLocator start(Database.BatchableContext BC)
	{
		syncStartedDate =Datetime.now();
		//-- No error when the batch starts
		errorsCount = 0;
		totalRecords = 0;
		failed_records = new List<String>();
		system.debug(LOGGINGLEVEL.ERROR, 'LF: QUERY: '+query);
		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<Account> accounts)
   	{
   		//-- Total records to be processed
   		totalRecords += accounts.size();

   		// Process Errors
		List<ams2gdp_Error> errors = new List<ams2gdp_Error>();

   		List<Accreditation__c> accreditations_to_save = new List<Accreditation__c>();
   		try
		{
			accreditations_to_save 	= ams2gdp_BusinessLogic.formatInspection2Accreditation(accounts);

			//-- Raise exception for Unit Tests
			if(Test.isRunningTest() &&   throwException) insert new Account();
		}
		catch(Exception ex)
		{
			errors.add(ams2gdp_Error.Exception2Error(batchName, ex));
		}

		List<Database.UpsertResult> accreditations_save_results = Database.upsert(accreditations_to_save,Accreditation__c.AMS_GDP_Key__c.getDescribe().getSObjectField(),false);

		//Check for Orphan Accreditation
		for(Accreditation__c ac: accreditations_to_save)
		{
			if(ac.Related_GDP_Products_Account_View__c == null)
			{
				errors.add(new ams2gdp_Error(batchName,ac.AMS_GDP_Key__c.left(18), null, 'ORPHAN_RECORD'));
			}
		}

		// Process Errors
		errors.addAll(ams2gdp_Error.formatUpsertResult(accreditations_to_save, accreditations_save_results, 'Accounts (AMS) => Accreditation', 'AMS_GDP_Key__c'));


		//Log the current Errors
		if(!errors.isEmpty())
		{
			errorsCount = errorsCount + errors.size();
			ams2gdp_Utils.logErrors(errors);

			Set<String> set_failed_records = new Set<String>(failed_records);

			for(ams2gdp_Error failed_rec : errors)
				if(failed_rec.amsRecordId != null){set_failed_records.add(failed_rec.amsRecordId.left(18));}

			failed_records =new List<String>(set_failed_records);
		}

	}

	global void finish(Database.BatchableContext BC)
	{

		//-- Start next batch :
		if(processNextBatch)Database.executeBatch(new ams2gdp_Batch_Territory(true,isManual));
		ams2gdp_Utils.upsertAMS_GDP_Batch(batchName, syncStartedDate, errorsCount, totalRecords, failed_records, isManual);
		
		//--Send completion notification
		ams2gdp_Utils.notifyBatchOutput(batchName, totalRecords, errorsCount, failed_records);
		}	
}
