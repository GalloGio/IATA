global class ams2gdp_Batch_Territory implements Database.Batchable<sObject> , Database.Stateful 
{	
	public String query;
	public List<String> extraIds;
	public String batchName; 
	public Integer errorsCount;
	public Integer totalRecords;
	public List<String> failed_records;
	public Datetime syncStartedDate;
	public Boolean processNextBatch;
	public Boolean throwException;

	public void init(Boolean runNext, List<String> ids)
	{
		processNextBatch = runNext;
		batchName = 'Job 3: GSA Territory';
		extraIds = ids; 
		Map<String, String> recordTypes = ams2gdp_Utils.getRecordTypeIdByName('Account');

		String fields = ' Id, Name, Comments__c, Appointment__c, Appointment__r.Account__c, Appointment__r.Accreditation_Endorsement_Status_code__c, Appointment__r.Date_Organisation_Status_attained__c, Appointment__r.Legacy_External_ID__c '
			+', Appointment__r.Account__r.Location_Class__c, Appointment__r.Account__r.Check_Digit__c, Appointment__r.Account__r.IATACode__c, Appointment__r.AMS_Appointment_Type__c ' 
			+', Appointment__r.Account__r.Organization_Last_Change_Date__c, Appointment__r.Account__r.Verification_Date__c,  Appointment__r.Account__r.Original_Approval_DAte__c '
			+', Appointment__r.Accreditation_Endorsement_organisation__r.Air_Code__c, Appointment__r.Accreditation_Endorsement_organisation__r.Name  '
			+',  ISO_Country__r.ISO_Code__c,  ISO_Country__r.Name, ISO_Country__r.ISO_Country_Short_Name__c,  ISO_State__r.ISO_Code__c '
			+', Appointment__r.Account__r.IATA_ISO_Billing_State__r.ISO_Code__c, Appointment__r.Account__r.IATA_ISO_Country__r.ISO_Code__c, Appointment__r.Account__r.IATA_ISO_Country__r.Name, Appointment__r.Account__r.IATA_ISO_Country__r.ISO_Country_Short_Name__c, Appointment__r.Account__r.IATA_ISO_Country__r.AIMS_Area_ID__c' 
			+', Appointment__r.Account__r.state_numeric_code__c';

		//-- Query conditions 
		List<String> conditions = new List<String>{'Appointment__r.Account__r.RecordTypeId= \''+recordTypes.get('Agency')+'\''
			, 'Appointment__r.Account__r.IATACode__c != null'
			, 'Appointment__r.Accreditation_Endorsement_organisation__r.Valid_Code_For_GDP_Replication__c = true '
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
			+	'FROM AMS_Territory__c '
			+ 	'WHERE {1} '
			+	'ORDER BY Appointment__r.Account__c, Appointment__r.Accreditation_Endorsement_organisation__r.Air_Code__c', 
			new List<String>{fields,String.join(conditions, ' AND ')}
		);
	}

	global ams2gdp_Batch_Territory(Boolean runNext, List<String> extra)
	{
		init(runNext,extra);
	}

	global ams2gdp_Batch_Territory(Boolean runNext)
	{
		init(runNext, null);
	}

	
	global ams2gdp_Batch_Territory() 
	{
		//-- Not Next batch to run by default
		init(false, null);
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

   	global void execute(Database.BatchableContext BC, List<AMS_Territory__c> territories) 
   	{
		//-- Total records to be processed
   		totalRecords += territories.size();

   		// Process Errors 
		List<ams2gdp_Error> errors = new List<ams2gdp_Error>();

		List<GSA_Territory__c> territories_to_save = new List<GSA_Territory__c>();  
		try
		{
			territories_to_save = ams2gdp_BusinessLogic.formatInspection2Territory(territories);  

			//-- Raise exception for Unit Tests
			if(Test.isRunningTest() &&   throwException) insert new Account();	
		}
		catch(Exception ex)
		{
			errors.add(ams2gdp_Error.Exception2Error(batchName, ex));
		}

		List<Database.UpsertResult> territories_save_results = Database.upsert(territories_to_save,GSA_Territory__c.AMS_GDP_Key__c.getDescribe().getSObjectField(),false);

		//Check for Orphan Accreditation
		for(GSA_Territory__c gt: territories_to_save)
		{
			if(gt.Related_GDP_Products_Account_View__c == null)
			{
				errors.add(new ams2gdp_Error(batchName,gt.AMS_GDP_Key__c.left(18), null, 'ORPHAN_RECORD'));
			}
		}

		// Process Errors 
		errors.addAll(ams2gdp_Error.formatUpsertResult(territories_to_save, territories_save_results, batchName, 'AMS_GDP_Key__c'));

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
		if(processNextBatch) Database.executeBatch(new ams2gdp_Batch_Account2(true));	

		//-- Update Last Sync Info 
		upsert new AMS_GDP_Batch__c(
			Batch_Name__c=batchName, 
			Last_Sync_Start_Date__c=syncStartedDate, 
			Last_Sync_End_Date__c=Datetime.now(),
			Total_Failed_Records__c = errorsCount,
			Total_Records_Processed__c = totalRecords,
			Failed_Records__c = String.join(failed_records, ';').left(32768)
		) Batch_Name__c; 

		//--Send completion notification 
		ams2gdp_Utils.notifyBatchOutput(batchName, totalRecords, errorsCount, failed_records); 	
	}
	
}