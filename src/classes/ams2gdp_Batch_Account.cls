global class ams2gdp_Batch_Account implements Database.Batchable<sObject> , Database.Stateful
{
	public String query;
	public List<String> extraIds;
	public Integer errorsCount;
	public Integer totalRecords;
	public List<String> failed_records;
	public Datetime syncStartedDate;
	public Datetime previousSyncStartedDate;
	public Boolean processNextBatch;
	public Boolean throwException;
	public String batchName;
	Set<String> locationsSet;
	Set<String> statusSet;


	public void init(Boolean runNext, List<String> ids)
	{
		batchName = 'Job 1: GDP Products - Account View';
		processNextBatch = runNext;
		extraIds = ids;
		Map<String, String> recordTypes = ams2gdp_Utils.getRecordTypeIdByName('Account');

		//-- Fields used for Sync
		String fields = ' Id, Airline_Code__c, BSP_CASS_Code__c, CASS_Number__c, Check_Digit__c, Company_Type__c, Email__c, GDP_Location_Type__c, GDP_Opt_In__c, IATACode__c, Incorporation_Type__c, GDS__c'
			+	', License_Number__c, Location_Category__c, Location_Type__c, Manager_First_Name__c, Manager_Last_Name__c, Name, PAX_Cargo__c, Preferred_Language__c'
			+	', Short_Name__c , Ticketing_Agent_First_Name__c, Ticketing_Agent_Last_Name__c, TradeName__c, TTY__c, VAT_Number__c, VAT_Number_2__c, Website'
			+	', ParentId, AIMS_ID__c, Parent.AIMS_ID__c, WebStar_ID__c, Parent.WebStar_ID__c';

		String idsCondition;
		if(extraIds!=null && extraIds.size() > 0) {
			idsCondition = 'Id IN (\''+String.join(extraIds,'\', \'')+'\')';
		}else {
			idsCondition = 'Main_Accreditation_Organization__c IN (\'IATA\',\'IATAN\',\'DOM\') ';
			if(!String.isBlank(AMS_2_GDP_Settings__c.getOrgDefaults().Status__c)) {
				statusSet = new Set<String>(AMS_2_GDP_Settings__c.getOrgDefaults().Status__c.split(';'));
				idsCondition += ' AND Status__c IN  :statusSet ';

			}
			if(!String.isBlank(AMS_2_GDP_Settings__c.getOrgDefaults().Location_Classes__c)) {
				locationsSet = new Set<String>(AMS_2_GDP_Settings__c.getOrgDefaults().Location_Classes__c.split(';'));
				idsCondition += ' AND Location_Class__c IN:  locationsSet';
			}
		}
		// 	idsCondition = 'Status__c IN (\'Terminated\',\'Not Accredited\',\'New application pending\',\'Not in Operation\',\'Listed\',\'Cash basis/No commission\',\'Cash basis/With commission\',\'Under review\',\'Changes processed\',\'Approved\') AND Main_Accreditation_Organization__c IN (\'IATA\',\'IATAN\',\'DOM\')';
		// } else {
		// }
		// }else if(!String.isBlank(AMS_2_GDP_Settings__c.getOrgDefaults().Location_Classes__c)) {
		// 	locationsSet = new Set<String>(AMS_2_GDP_Settings__c.getOrgDefaults().Location_Classes__c.split(';'));
		// 	idsCondition = 'Status__c IN (\'Terminated\',\'Not Accredited\',\'New application pending\',\'Not in Operation\',\'Listed\',\'Cash basis/No commission\',\'Cash basis/With commission\',\'Under review\',\'Changes processed\',\'Approved\') AND Main_Accreditation_Organization__c IN (\'IATA\',\'IATAN\',\'DOM\') AND Location_Class__c IN:  locationsSet';
		// } else {
		// 	idsCondition = 'Status__c IN (\'Terminated\',\'Not Accredited\',\'New application pending\',\'Not in Operation\',\'Listed\',\'Cash basis/No commission\',\'Cash basis/With commission\',\'Under review\',\'Changes processed\',\'Approved\') AND Main_Accreditation_Organization__c IN (\'IATA\',\'IATAN\',\'DOM\')';
		// }

		//-- Query conditions
		List<String> conditions = new List<String>{'RecordTypeId= \''+recordTypes.get('Agency')+'\''
			,	'IATACode__c != null'
			,	'CNS_Agency__c = false'
			,	'CNS_Account__c = false'
			,	idsCondition
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
				String deltaConditions;
				//Keeps a copy of the Last_Sync_Start_Date__c to be used on the Job_1_Original_Start_Date__c
				previousSyncStartedDate = batchInfo.Last_Sync_Start_Date__c == null ? Datetime.now() : batchInfo.Last_Sync_Start_Date__c;
				//Run only on the deltas
				if(runNext){
					deltaConditions = String.format('LastModifiedDate >= {0}'
						,new List<String>{batchInfo.Last_Sync_Start_Date__c.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'','GMT')});
				}else{
					deltaConditions = String.format('LastModifiedDate >= {0}'
						,new List<String>{batchInfo.Job_1_Original_Start_Date__c.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'','GMT')});
				}

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
			+	'FROM Account '
			+ 	'WHERE {1} '
			+	'ORDER BY ParentId DESC ',
			new List<String>{fields,String.join(conditions, ' AND ')}
		);
	}

	global ams2gdp_Batch_Account()
	{
		init(false,null);
	}

	global ams2gdp_Batch_Account(Boolean runNext)
	{
		init(runNext, null);
	}

	global ams2gdp_Batch_Account(Boolean runNext, List<String> extra)
	{
		init(runNext, extra);
	}

	global Database.QueryLocator start(Database.BatchableContext BC)
	{
		errorsCount = 0;
		totalRecords = 0;
		failed_records = new List<String>();
		syncStartedDate = Datetime.now();

		return Database.getQueryLocator(query);
	}

	/**
	 * Synchronize Account
	 * 	=>	GDP Products - Account View
	 */
   	global void execute(Database.BatchableContext BC, List<Account> accounts)
   	{
   		//-- Total records to be processed
   		totalRecords += accounts.size();

   		//-- Errors list
   		List<ams2gdp_Error> errors = new List<ams2gdp_Error>();

		//-- Format Account to GDP_Products_Account_View
		List<GDP_Products_Account_View__c> products_to_save = new List<GDP_Products_Account_View__c>();
		try
		{
			products_to_save = ams2gdp_BusinessLogic.formatAccount2ProductAccountView(accounts);

			//-- Raise exception for Unit Tests
			if(Test.isRunningTest() &&   throwException) insert new Account();
		}
		catch(Exception ex)
		{
			errors.add(ams2gdp_Error.Exception2Error(batchName, ex));
		}

		//-- Save Records
		List<Database.UpsertResult> products_save_results = Database.upsert(products_to_save,GDP_Products_Account_View__c.AMS_GDP_Key__c.getDescribe().getSObjectField(),false);

		//-- Process Errors
		errors.addAll(ams2gdp_Error.formatUpsertResult(products_to_save, products_save_results, batchName, 'AMS_GDP_Key__c'));

		//-- Log the current Errors
		if(!errors.isEmpty())
		{
			errorsCount = errorsCount + errors.size();
			ams2gdp_Utils.logErrors(errors);

			//-- Save failed records
			Set<String> set_failed_records = new Set<String>(failed_records);

			for(ams2gdp_Error failed_rec : errors)
				set_failed_records.add(failed_rec.amsRecordId);

			failed_records =new List<String>(set_failed_records);
		}
	}

	global void finish(Database.BatchableContext BC)
	{
		AMS_GDP_Batch__c amsGdpBatch;

		if(processNextBatch){
			//-- Start next batch
			Database.executeBatch(new ams2gdp_Batch_Inspection(true));
			//creates last sync info in the first run
			amsGdpBatch = new AMS_GDP_Batch__c(
				Batch_Name__c=batchName,
				Last_Sync_Start_Date__c = syncStartedDate,
				Last_Sync_End_Date__c = Datetime.now(),
				Job_1_Original_Start_Date__c = previousSyncStartedDate,
				Total_Failed_Records__c = errorsCount,
				Total_Records_Processed__c = totalRecords,
				Failed_Records__c = String.join(failed_records, ';').left(32768));
		}else{
			//creates last sync info in reconciliation run (second time in this batches order)
			amsGdpBatch = new AMS_GDP_Batch__c(
				Batch_Name__c=batchName,
				Last_Sync_Start_Date__c = syncStartedDate,
				Last_Sync_End_Date__c = Datetime.now(),
				Total_Failed_Records__c = errorsCount,
				Total_Records_Processed__c = totalRecords,
				Failed_Records__c = String.join(failed_records, ';').left(32768));
		}

		//-- Update Last Sync Info
		upsert amsGdpBatch Batch_Name__c;

		//--Send completion notification
		ams2gdp_Utils.notifyBatchOutput(batchName, totalRecords, errorsCount, failed_records);
	}
}