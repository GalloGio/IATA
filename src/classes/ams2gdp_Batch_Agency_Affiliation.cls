/**
 * Batch Class to Synchronize AMS_Agency_Affiliation__c => Assoc_Affiliation_Membership__c
 * @author David Daboué <david.daboue@cgi.com>
 * @version 1.0
 */
global class ams2gdp_Batch_Agency_Affiliation implements Database.Batchable<sObject> , Database.Stateful
{
	public String query;
	public Integer errorsCount;
	public Integer totalRecords;
	public List<String> failed_records;
	public Datetime syncStartedDate;
	public Boolean processNextBatch;
	public Boolean throwException;
	public String batchName;
	public List<String> extraIds;
	Set<String> locationsSet;
	Set<String> statusSet;
	public Boolean isManual;

	public void init(Boolean runNext, List<String> ids, Boolean manual)
	{
		isManual = manual==null ? false : manual;
		batchName = 'Job 6: Assoc Affiliation Membership';
		processNextBatch = runNext;
		extraIds = ids;

		String fields = ' Id, Name, Legacy_External_ID__c, Account__c, Legacy_System__c '
			+ ', Affiliation__r.Name, Affiliation__r.Affiliation_Code__c ';


	    List<String> conditions = new List<String>{'Account__r.RecordTypeId= \''+ RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency') +'\''};
		conditions.addAll(ams2gdp_BusinessLogic.queryClauseAccountAndRelated(batchName));


		if(extraIds!=null && extraIds.size() > 0) {
			 if(extraIds[0]=='none'){
			 conditions.add('Id=null');}
			 else{
			//Run batch on specific Ids
			List<String> specificIds = new List<String>();
			for(String s: extraIds)
			{
				if(s.length() >= 15)
					specificIds.add(s.left(15));
			}

			if(specificIds.size() > 0)	conditions.add('Id IN (\''+String.join(specificIds,'\', \'')+'\')');}
		}else{
			if(!String.isBlank(AMS_2_GDP_Settings__c.getOrgDefaults().Status__c)) {
				statusSet = new Set<String>(AMS_2_GDP_Settings__c.getOrgDefaults().Status__c.split(';'));
				conditions.add('Account__r.Status__c IN  :statusSet ');

			}
			if(!String.isBlank(AMS_2_GDP_Settings__c.getOrgDefaults().Location_Classes__c)) {
				locationsSet = new Set<String>(AMS_2_GDP_Settings__c.getOrgDefaults().Location_Classes__c.split(';'));
				conditions.add('Account__r.Location_Class__c IN:  locationsSet');
			}

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

		query = String.format('SELECT {0} '
			+	'FROM AMS_Agency_Affiliation__c '
			+ 	'WHERE {1} ',
			new List<String>{fields,String.join(conditions, ' AND ')}
		);
	}

	global ams2gdp_Batch_Agency_Affiliation()
	{
		init(false, null, null);
	}

	global ams2gdp_Batch_Agency_Affiliation(Boolean runNext, Boolean manual)
	{
		init(runNext,null, manual);
	}

	global ams2gdp_Batch_Agency_Affiliation(Boolean runNext, List<String> extra, Boolean manual)
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

		return Database.getQueryLocator(query);
	}

   	global void execute(Database.BatchableContext BC, List<AMS_Agency_Affiliation__c> agencies)
   	{
   		//-- Total records to be processed
   		totalRecords += agencies.size();

   		// Process Errors
		List<ams2gdp_Error> errors = new List<ams2gdp_Error>();

   		List<Assoc_Affiliation_Membership__c> records_to_save = new List<Assoc_Affiliation_Membership__c>();
   		try
   		{
   			records_to_save = ams2gdp_BusinessLogic.formatAgency2Membership(agencies);

   			//-- Raise exception for Unit Tests
			if(Test.isRunningTest() &&   throwException) insert new Account();
   		}
   		catch(Exception ex)
   		{
   			errors.add(ams2gdp_Error.Exception2Error(batchName, ex));
   		}

   		List<Database.UpsertResult> save_results = Database.upsert(records_to_save,Assoc_Affiliation_Membership__c.AMS_GDP_Key__c.getDescribe().getSObjectField(),false);

   		//--Check if there is orphan GDP_Address records
		for(Assoc_Affiliation_Membership__c aam: records_to_save)
		{
			if(aam.Related_GDP_Products_Account_View__c == null)
			{
				errors.add(new ams2gdp_Error(batchName,aam.AMS_GDP_Key__c.left(18), null, 'ORPHAN_RECORD'));
			}
		}

		// Process Errors
		errors.addAll(ams2gdp_Error.formatUpsertResult(records_to_save, save_results, batchName, 'AMS_GDP_Key__c'));

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
		if(processNextBatch)Database.executeBatch(new ams2gdp_Batch_AMS_Account_Role(true, isManual));
		ams2gdp_Utils.upsertAMS_GDP_Batch(batchName, syncStartedDate, errorsCount, totalRecords, failed_records, isManual);
		//--Send completion notification
		ams2gdp_Utils.notifyBatchOutput(batchName, totalRecords, errorsCount, failed_records);
	}
}