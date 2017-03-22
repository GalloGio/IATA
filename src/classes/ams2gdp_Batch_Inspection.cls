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

	public void init(Boolean runNext, List<String> ids)
	{
		batchName = 'Job 2: Accreditation'; 
		processNextBatch = runNext;
		extraIds = ids; 

		Map<String, String> recordTypes = ams2gdp_Utils.getRecordTypeIdByName('Account');

		String fields = ' Id, Name, Account__c, Accreditation_Endorsement_Status_code__c, Date_Organisation_Status_attained__c, Legacy_External_ID__c '
			+', Account__r.Location_Class__c, Account__r.Check_Digit__c, Account__r.IATACode__c, Account__r.Status__c' 
			+', Account__r.Organization_Last_Change_Date__c, Account__r.Verification_Date__c,  Account__r.Original_Approval_DAte__c '
			+', Accreditation_Endorsement_organisation__r.Air_Code__c, Accreditation_Endorsement_organisation__r.Name  '
			+', Account__r.IATA_ISO_Billing_State__r.ISO_Code__c, Account__r.IATA_ISO_Country__r.ISO_Code__c, Account__r.IATA_ISO_Country__r.AIMS_Area_ID__c,Account__r.CNS_Agency__c' ;

		//-- Query conditions 
		List<String> conditions = new List<String>{'Account__r.RecordTypeId= \''+recordTypes.get('Agency')+'\''
			,	'Account__r.IATACode__c != null'
			,	'Account__r.Status__c NOT IN (\'Not accreditated\',\'New application pending\',\'Not in operation\',\'On hold\',\'applicant\',\'Unregisterable STP\')'
			,	'Accreditation_Endorsement_organisation__r.Air_Code__c IN (\'IATA\',\'IATAN\',\'DOM\') '
			,	'Account__r.CNS_Agency__c = false'
		}; 
		
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

		System.debug('conditions::'+conditions);

		query = String.format('SELECT {0} '
			+	'FROM AMS_Inspection__c '
			+ 	'WHERE {1} '
			+	'ORDER BY Account__c, AMS_GDP_Sort_By__c', 
			new List<String>{fields,String.join(conditions, ' AND ')}
		);
	}

	global ams2gdp_Batch_Inspection() 
	{
		init(false, null);
	}
	
	global ams2gdp_Batch_Inspection(Boolean runNext) 
	{
		init(runNext,null);
	}

	global ams2gdp_Batch_Inspection(Boolean runNext, List<String> extra) 
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

   	global void execute(Database.BatchableContext BC, List<AMS_Inspection__c> inscpections) 
   	{
   		//-- Total records to be processed
   		totalRecords += inscpections.size();

   		// Process Errors 
		List<ams2gdp_Error> errors = new List<ams2gdp_Error>();

   		List<Accreditation__c> accreditations_to_save = new List<Accreditation__c>(); 
   		try
		{
			accreditations_to_save 	= ams2gdp_BusinessLogic.formatInspection2Accreditation(inscpections);

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
		errors.addAll(ams2gdp_Error.formatUpsertResult(accreditations_to_save, accreditations_save_results, 'Appointment (AMS) => Accreditation', 'AMS_GDP_Key__c'));
		

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
		if(processNextBatch) Database.executeBatch(new ams2gdp_Batch_Territory(true));

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