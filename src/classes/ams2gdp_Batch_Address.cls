global class ams2gdp_Batch_Address implements Database.Batchable<sObject> , Database.Stateful
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
		batchName = 'Job 5: Address & Phone';
		processNextBatch = runNext;
		extraIds = ids;

		//-- Fields used for Sync
		String fields = ' Id, BillingStreet, BillingCity, BillingCountry, IATA_ISO_Country__c, BillingState, IATA_ISO_Billing_State__c, BillingPostalCode'
			+	', ShippingStreet, ShippingCity, IATA_ISO_Shipping_Country__c, ShippingState,ShippingCountry, IATA_ISO_Shipping_State__c, ShippingPostalCode'
			+	', Phone, Fax, IATA_ISO_Country__r.ISO_Code__c';

		String idsCondition;
		//-- Query conditions
	    List<String> conditions = new List<String>{'RecordTypeId= \''+ RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency') +'\''};
		conditions.addAll(ams2gdp_BusinessLogic.queryClauseAccountAndRelated(batchName));
	
		if(extraIds!=null && extraIds.size() > 0) {
			idsCondition = 'Id IN (\''+String.join(extraIds,'\', \'')+'\')';
			if(extraIds[0]=='none'){
				conditions.add('Id=null');
			}
			else{
				//Run batch on specific Ids
				List<String> specificIds = new List<String>();
				for(String s: extraIds)
				{
					if(s.length() >= 15) specificIds.add(s.left(15));
				}

				if(specificIds.size() > 0)	conditions.add('Id IN (\''+String.join(specificIds,'\', \'')+'\')');
			}
		}else{
			// idsCondition = 'Status__c IN (\'Terminated\',\'Not Accredited\',\'New application pending\',\'Not in Operation\',\'Listed\',\'Cash basis/No commission\',\'Cash basis/With commission\',\'Under review\',\'Changes processed\',\'Approved\') AND Main_Accreditation_Organization__c IN (\'IATA\',\'IATAN\',\'DOM\')';
			// idsCondition = 'Main_Accreditation_Organization__c IN (\'IATA\',\'IATAN\',\'DOM\') ';
			if(!String.isBlank(AMS_2_GDP_Settings__c.getOrgDefaults().Status__c)) {
				statusSet = new Set<String>(AMS_2_GDP_Settings__c.getOrgDefaults().Status__c.split(';'));
				conditions.add(' Status__c IN :  statusSet');
			}
			if(!String.isBlank(AMS_2_GDP_Settings__c.getOrgDefaults().Location_Classes__c)) {
				locationsSet = new Set<String>(AMS_2_GDP_Settings__c.getOrgDefaults().Location_Classes__c.split(';'));
				conditions.add(' Location_Class__c IN :  locationsSet');
			}

		}


		AMS_GDP_Batch__c batchInfo = ams2gdp_Selector.getBatchInfo(batchName);
		if(batchInfo != null && (extraIds==null || extraIds.size() == 0))
		{
			//Run only on the deltas
			String deltaConditions = String.format('LastModifiedDate >= {0}'
					,new List<String>{batchInfo.Last_Sync_Start_Date__c.addDays(-2).format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'','GMT')});

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

	global ams2gdp_Batch_Address()
	{
		init(false, null, null);
	}

	global ams2gdp_Batch_Address(Boolean runNext, Boolean manual)
	{
		init(runNext,null, manual);
	}

	global ams2gdp_Batch_Address(Boolean runNext, List<String> extra, Boolean manual)
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

   	global void execute(Database.BatchableContext BC, List<Account> accounts)
   	{
   		//-- Total records to be processed
   		totalRecords += accounts.size();

   		List<ams2gdp_Error> errors = new List<ams2gdp_Error>();

   		// Format Account to GDP_Phone
		List<GDP_Phone__c> phones_to_save = new List<GDP_Phone__c>();
		try
		{
			phones_to_save = ams2gdp_BusinessLogic.formatAccount2Phone(accounts);

			//-- Raise exception for Unit Tests
			if(Test.isRunningTest() &&   throwException) insert new Account();
		}
		catch(Exception ex)
		{
			errors.add(ams2gdp_Error.Exception2Error('Job 5: Phone', ex));
		}

		// Format Account to GDP Address
		List<GDP_Address__c> addresses_to_save = new List<GDP_Address__c>();
		try
		{
			addresses_to_save = ams2gdp_BusinessLogic.formatAccount2Address(accounts);

			//-- Raise exception for Unit Tests
			if(Test.isRunningTest() &&   throwException) insert new Account();
		}
		catch(Exception ex)
		{
			errors.add(ams2gdp_Error.Exception2Error('Job 5: Address', ex));
		}


		// Save Records
		List<Database.UpsertResult> phones_save_results 	= Database.upsert(phones_to_save,GDP_Phone__c.AMS_GDP_Key__c.getDescribe().getSObjectField(),false);
		List<Database.UpsertResult> addresses_save_results 	= Database.upsert(addresses_to_save,GDP_Address__c.AMS_GDP_Key__c.getDescribe().getSObjectField(),false);

		//--Check if there is orphan GDP_Address records
		for(GDP_Address__c adr: addresses_to_save)
		{
			if(adr.Related_GDP_Products_Account_View__c == null)
			{
				errors.add(new ams2gdp_Error('Job 5: Address',adr.AMS_GDP_Key__c.left(18), null, 'ORPHAN_RECORD'));
			}
		}

		//--Check if there is orphan GDP_Phone records
		for(GDP_Phone__c p: phones_to_save)
		{
			if(p.Related_GDP_Products_Account_View__c == null)
			{
				errors.add(new ams2gdp_Error('Job 5: Phone',p.AMS_GDP_Key__c.left(18), null, 'ORPHAN_RECORD'));
			}
		}


		// Process Errors
		errors.addAll(ams2gdp_Error.formatUpsertResult(phones_to_save, phones_save_results, 'Job 5: Phone', 'AMS_GDP_Key__c'));
		errors.addAll(ams2gdp_Error.formatUpsertResult(addresses_to_save, addresses_save_results, 'Job 5: Address', 'AMS_GDP_Key__c'));

		//Log the current Errors
		if(!errors.isEmpty())
		{
			errorsCount += errors.size();
			ams2gdp_Utils.logErrors(errors);

			Set<String> set_failed_records = new Set<String>(failed_records);

			for(ams2gdp_Error failed_rec : errors)
				if(failed_rec.amsRecordId != null){set_failed_records.add(failed_rec.amsRecordId.left(18));}

			failed_records =new List<String>(set_failed_records);
		}
	}

	global void finish(Database.BatchableContext BC)
	{
		if(processNextBatch)Database.executeBatch(new ams2gdp_Batch_Agency_Affiliation(true, isManual));
		ams2gdp_Utils.upsertAMS_GDP_Batch(batchName, syncStartedDate, errorsCount, totalRecords, failed_records, isManual);		
		//--Send completion notification
		ams2gdp_Utils.notifyBatchOutput(batchName, totalRecords, errorsCount, failed_records);
	}
}
