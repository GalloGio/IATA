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

	public void init(Boolean runNext, List<String> ids)
	{
		batchName = 'Job 6: Assoc Affiliation Membership'; 
		processNextBatch = runNext;
		extraIds = ids;

		Map<String, String> recordTypes = ams2gdp_Utils.getRecordTypeIdByName('Account');

		String fields = ' Id, Name, Legacy_External_ID__c, Account__c, Legacy_System__c '
			+ ', Affiliation__r.Name, Affiliation__r.Affiliation_Code__c ';

		//-- Query conditions 
		String accreditation_condition = 'SELECT Related_Account__c '
			+	'FROM Accreditation__c '
			+	'WHERE Endorsed_Accredited_By__r.Code__c IN (\'IATA\',\'IATAN\',\'DOM\')'
			+	'	AND Status__r.Code__c IN (\'0\',\'4\',\'5\',\'6\',\'7\',\'8\',\'9\') ';

		List<String> conditions = new List<String>{'Account__r.RecordTypeId= \''+recordTypes.get('Agency')+'\''
			, 'Account__r.IATACode__c != null'
			, 'Account__c IN ('+accreditation_condition+')'
		}; 

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
			AMS_GDP_Batch__c batchInfo = ams2gdp_Selector.getBatchInfo(batchName);
			if(batchInfo != null)
			{
				//Run only on the deltas 
				String deltaConditions = String.format('LastModifiedDate >= {0}'
					,new List<String>{batchInfo.Last_Sync_Start_Date__c.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'')});

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
		init(false,null);
	}

	global ams2gdp_Batch_Agency_Affiliation(Boolean runNext) 
	{
		init(runNext,null);
	}

	global ams2gdp_Batch_Agency_Affiliation(Boolean runNext, List<String> extra) 
	{
		init(runNext,extra);
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
		//-- Start next batch : Address
		if(processNextBatch) Database.executeBatch(new ams2gdp_Batch_AMS_Account_Role(true));

		//-- Update Last Sync Info 
		upsert new AMS_GDP_Batch__c(
			Batch_Name__c = batchName, 
			Last_Sync_Start_Date__c = syncStartedDate, 
			Last_Sync_End_Date__c = Datetime.now(),
			Total_Failed_Records__c = errorsCount,
			Total_Records_Processed__c = totalRecords,
			Failed_Records__c = String.join(failed_records, ';').left(32768)
		) Batch_Name__c; 
		
		//--Send completion notification 
		ams2gdp_Utils.notifyBatchOutput(batchName, totalRecords, errorsCount, failed_records);
	}
}