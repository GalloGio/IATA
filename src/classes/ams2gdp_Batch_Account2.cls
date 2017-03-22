global class ams2gdp_Batch_Account2 implements Database.Batchable<sObject> , Database.Stateful 
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
		batchName = 'Job 4: GDS & Account Category'; 
		processNextBatch = runNext;
		extraIds = ids; 
		Map<String, String> recordTypes = ams2gdp_Utils.getRecordTypeIdByName('Account');

		//-- Fields used for Sync
		String fields = ' Id, Airline_Code__c, BSP_CASS_Code__c, CASS_Number__c, Check_Digit__c, Company_Type__c, Email__c, GDP_Location_Type__c, GDP_Opt_In__c, IATACode__c, Incorporation_Type__c, GDS__c'
			+	', License_Number__c, Location_Category__c, Location_Type__c, Manager_First_Name__c, Manager_Last_Name__c, Name, PAX_Cargo__c, Preferred_Language__c'
			+	', Short_Name__c , Ticketing_Agent_First_Name__c, Ticketing_Agent_Last_Name__c, TradeName__c, TTY__c, VAT_Number__c, VAT_Number_2__c, Website';

		String idsCondition;
		if(extraIds!=null && extraIds.size() > 0) {
			idsCondition = 'Id IN (\''+String.join(extraIds,'\', \'')+'\')';
		}else{
			idsCondition = 'Id IN (SELECT Related_Account__c FROM Accreditation__c WHERE Endorsed_Accredited_By__r.Code__c IN (\'IATA\',\'IATAN\',\'DOM\') AND Status__r.Code__c IN (\'0\',\'4\',\'5\',\'6\',\'7\',\'8\',\'9\'))';

			
		}

		//-- Query conditions 
		List<String> conditions = new List<String>{'RecordTypeId= \''+recordTypes.get('Agency')+'\''
			,	'IATACode__c != null'
			, 	'CNS_Agency__c = false'
			,	idsCondition
		}; 

		AMS_GDP_Batch__c batchInfo = ams2gdp_Selector.getBatchInfo(batchName);
		if(batchInfo != null && (extraIds==null || extraIds.size() == 0))
		{
			//Run only on the deltas 
			String deltaConditions = String.format('LastModifiedDate >= {0}'
				,new List<String>{batchInfo.Last_Sync_Start_Date__c.format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'')});

			if(String.isNotBlank(batchInfo.Failed_Records__c))
			{
				// Reprocess failed records 
				List<String> failedAccountRecordIds = new List<String>(); 
				
				for(String s: batchInfo.Failed_Records__c.split(';'))
				{
					if(s.length() >= 15) failedAccountRecordIds.add(s.left(15));
				}
				
				if(failedAccountRecordIds.size() > 0) deltaConditions += ' OR Id IN (\'' + String.join(failedAccountRecordIds, '\' , \'') + '\') ';

			}

			conditions.add('('+deltaConditions+')');
		}
		
		query = String.format('SELECT {0} '
			+	'FROM Account '
			+ 	'WHERE {1} ', 
			new List<String>{fields,String.join(conditions, ' AND ')}
		);
	}

	global ams2gdp_Batch_Account2() 
	{
		init(false,null);			
	}

	global ams2gdp_Batch_Account2(Boolean runNext) 
	{
		init(runNext,null);			
	}

	global ams2gdp_Batch_Account2(Boolean runNext, List<String> extra) 
	{
		init(runNext,extra);			
	}
	
	global Database.QueryLocator start(Database.BatchableContext BC) 
	{
		errorsCount = 0;	
		totalRecords = 0;
		failed_records = new List<String>();
		syncStartedDate =Datetime.now();

		return Database.getQueryLocator(query);
	}

	/**
	 * Synchronize Account 
	 * 	=> 	Account Category
	 * 	=> 	GDS
	 */	
   	global void execute(Database.BatchableContext BC, List<Account> accounts) 
   	{
   		//-- Total records to be processed
   		totalRecords += accounts.size();

   		List<ams2gdp_Error> errors = new List<ams2gdp_Error>();	

		// Format Account to Account_Category__c 
		List<Account_Category__c> account_categories_to_save = new List<Account_Category__c>();		

		try
		{
			account_categories_to_save = ams2gdp_BusinessLogic.formatAccount2AccountCategory(accounts);

			//-- Raise exception for Unit Tests
			if(Test.isRunningTest() &&   throwException) insert new Account();	
		}
		catch(Exception ex)
		{
			errors.add(ams2gdp_Error.Exception2Error('Job 4: Account Category', ex));
		}

		// Format Account to GDS
		List<GDS__c> gds_to_save = new List<GDS__c>();  
		try
		{
			gds_to_save = ams2gdp_BusinessLogic.formatAccount2GDS(accounts);
			//-- Remove unselected GDS in Account  
			Set<String> accountIds = new Set<String>();
			for(Account acc : accounts)
				accountIds.add(acc.Id);

			Map<String, String> gdpProductIdByAccountId = ams2gdp_Selector.getGDP_Products_Account_View_By_Account(accountIds);

			delete [SELECT Id FROM GDS__c WHERE Related_GDP_Products_Account_View__c IN :gdpProductIdByAccountId.values()];

			//-- Raise exception for Unit Tests
			if(Test.isRunningTest() &&   throwException) insert new Account();	
		}
		catch(Exception ex)
		{
			errors.add(ams2gdp_Error.Exception2Error('Job 4: GDS', ex));
		}

		// Save Records 
		List<Database.UpsertResult> categories_save_results = Database.upsert(account_categories_to_save,Account_Category__c.AMS_GDP_Key__c.getDescribe().getSObjectField(),false);
		List<Database.UpsertResult> gds_save_results 		= Database.upsert(gds_to_save,GDS__c.AMS_GDP_Key__c.getDescribe().getSObjectField(),false);

		//--Check if there is orphan Account_Category__c records 
		for(Account_Category__c ac: account_categories_to_save)
		{
			if(ac.Related_GDP_Products_Account_View__c == null)
			{
				errors.add(new ams2gdp_Error('Job 4: Account Category',ac.AMS_GDP_Key__c.left(18), null, 'ORPHAN_RECORD'));
			}
		}

		//--Check if there is orphan GDS__c records 
		for(GDS__c gds: gds_to_save)
		{
			if(gds.Related_GDP_Products_Account_View__c == null)
			{
				errors.add(new ams2gdp_Error('Job 4: GDS',gds.AMS_GDP_Key__c.left(18), null, 'ORPHAN_RECORD'));
			}
		}


		// Process Errors 
		errors.addAll(ams2gdp_Error.formatUpsertResult(account_categories_to_save, categories_save_results, 'Account => Account Category', 'AMS_GDP_Key__c'));
		errors.addAll(ams2gdp_Error.formatUpsertResult(gds_to_save, gds_save_results, 'Account => GDS', 'AMS_GDP_Key__c'));
		
		//Log the current Errors
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
		//-- Start next batch 
		if(processNextBatch) Database.executeBatch(new ams2gdp_Batch_Address(true));	

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