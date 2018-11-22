global class ams2gdp_Batch_Account implements Database.Batchable<sObject> , Database.Stateful {
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
	public Boolean secondRun;


	public void init(Boolean runNext, List<String> ids, Boolean manual, Boolean secondR) {
		isManual = manual == null ? false : manual;
		batchName = 'Job 1: GDP Products - Account View';
		processNextBatch = runNext;
		extraIds = ids;
		secondRun = secondR;

		//-- Fields used for Sync

		String fields = ' Id, Airline_Code__c, BSP_CASS_Code__c, CASS_Number__c, Check_Digit__c, Company_Type__c, Email__c, GDP_Location_Type__c, GDP_Opt_In__c, IATACode__c, Incorporation_Type__c, GDS__c'
		                +	', License_Number__c, Location_Category__c, Location_Type__c, Manager_First_Name__c, Manager_Last_Name__c, Name, PAX_Cargo__c, Preferred_Language__c'
		                +	', Short_Name__c , Ticketing_Agent_First_Name__c, Ticketing_Agent_Last_Name__c, TradeName__c, TTY__c, VAT_Number__c, VAT_Number_2__c, Website'
						+   ', ANG_IsNewGenAgency__c, ANG_Accreditation_Model__c, Remittance_frequency__c, ANG_IEP_Status_FF__c, Is_PCI_compliant__c, ANG_PCI_compliance_expiry_date__c, Due_Diligence_Status__c'
		                +	', ParentId, AIMS_ID__c, Parent.AIMS_ID__c, WebStar_ID__c, Parent.WebStar_ID__c, Location_Class__c, CNS_Agency__c ';

		String idsCondition;
		if (extraIds != null && extraIds.size() > 0) {
			idsCondition = 'Id IN (\'' + String.join(extraIds, '\', \'') + '\')';
		} else {
			if (!String.isBlank(AMS_2_GDP_Settings__c.getOrgDefaults().Status__c)) {
				statusSet = new Set<String>(AMS_2_GDP_Settings__c.getOrgDefaults().Status__c.split(';'));
				idsCondition += 'Status__c IN :statusSet ';

			}
			if (!String.isBlank(AMS_2_GDP_Settings__c.getOrgDefaults().Location_Classes__c)) {
				locationsSet = new Set<String>(AMS_2_GDP_Settings__c.getOrgDefaults().Location_Classes__c.split(';'));
				if (idsCondition!=null) idsCondition += ' AND '; else idsCondition='';
                idsCondition += 'Location_Class__c IN :locationsSet';
			}
		}

		//-- Query conditions
		List<String> conditions = new List<String> {'RecordTypeId= \'' + RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency') + '\''};
        if (idsCondition!=null) conditions.add(idsCondition);
		conditions.addAll(ams2gdp_BusinessLogic.queryClauseAccountAndRelated(batchName));


		if (extraIds != null && extraIds.size() > 0) {
			if (extraIds[0] == 'none') {
				conditions.add('Id=null');
			} else {
				//Run batch on specific Ids
				List<String> specificIds = new List<String>();
				for (String s : extraIds) {
					if (s.length() >= 15) specificIds.add(s.left(15));
				}

				if (specificIds.size() > 0)	conditions.add('Id IN (\'' + String.join(specificIds, '\', \'') + '\')');
			}
		} else {
			AMS_GDP_Batch__c batchInfo = ams2gdp_Selector.getBatchInfo(batchName);

			if (batchInfo != null) {
				//Run only on the deltas
				String deltaConditions;
				if(secondRun){
					deltaConditions = String.format('LastModifiedDate >= {0}'
					,new List<String>{batchInfo.Last_Sync_Start_Date__c.addDays(-3).format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'','GMT')});
				}else{
					deltaConditions = String.format('LastModifiedDate >= {0}'
					,new List<String>{batchInfo.Last_Sync_Start_Date__c.addDays(-2).format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'','GMT')});
				}

				system.debug('##deltaConditions: ' + deltaConditions);

				if (String.isNotBlank(batchInfo.Failed_Records__c)) {
					// Reprocess failed records
					List<String> failedRecordIds = new List<String>();
					for (String s : batchInfo.Failed_Records__c.split(';')) {
						if (s.length() >= 15)
							failedRecordIds.add(s.left(15));
					}
					if (failedRecordIds.size() > 0)
						deltaConditions += ' OR Id IN (\'' + String.join(failedRecordIds, '\' , \'') + '\') ';
				}

				conditions.add('(' + deltaConditions + ')');
			}
		}

		query = String.format('SELECT {0} '
		                      +	'FROM Account '
		                      + 	'WHERE {1} '
		                      +	'ORDER BY ParentId DESC ',
		                      new List<String> {fields, String.join(conditions, ' AND ')}
		                     );
	}

	global ams2gdp_Batch_Account() {
		init(false, null, false, false);
	}

	global ams2gdp_Batch_Account(Boolean runNext, Boolean manual, Boolean secondRun) {
		init(runNext, null, manual, secondRun);
	}

	global ams2gdp_Batch_Account(Boolean runNext, List<String> extra, Boolean manual) {
		system.debug('##ams2gdp_Batch_Account, extra: ' + extra);
		init(runNext, extra, manual, false);
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
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
	global void execute(Database.BatchableContext BC, List<Account> accounts) {
		//-- Total records to be processed
		totalRecords += accounts.size();

		//-- Errors list
		List<ams2gdp_Error> errors = new List<ams2gdp_Error>();

		//-- Format Account to GDP_Products_Account_View
		List<GDP_Products_Account_View__c> products_to_save = new List<GDP_Products_Account_View__c>();
		try {
			products_to_save = ams2gdp_BusinessLogic.formatAccount2ProductAccountView(accounts);

			//-- Raise exception for Unit Tests
			if (Test.isRunningTest() &&   throwException) insert new Account();
		} catch (Exception ex) {
			errors.add(ams2gdp_Error.Exception2Error(batchName, ex));
		}

		//-- Save Records
		List<Database.UpsertResult> products_save_results = Database.upsert(products_to_save, GDP_Products_Account_View__c.AMS_GDP_Key__c.getDescribe().getSObjectField(), false);

		//-- Process Errors
		errors.addAll(ams2gdp_Error.formatUpsertResult(products_to_save, products_save_results, batchName, 'AMS_GDP_Key__c'));

		//-- Log the current Errors
		if (!errors.isEmpty()) {
			errorsCount = errorsCount + errors.size();
			ams2gdp_Utils.logErrors(errors);

			//-- Save failed records
			Set<String> set_failed_records = new Set<String>(failed_records);

			for (ams2gdp_Error failed_rec : errors)
				set_failed_records.add(failed_rec.amsRecordId);

			failed_records = new List<String>(set_failed_records);
		}
	}

	global void finish(Database.BatchableContext BC) {
		if(processNextBatch){
			Database.executeBatch(new ams2gdp_Batch_Inspection(true, isManual));
		}
		ams2gdp_Utils.upsertAMS_GDP_Batch(batchName, syncStartedDate, errorsCount, totalRecords, failed_records, isManual);
		//--Send completion notification
		ams2gdp_Utils.notifyBatchOutput(batchName, totalRecords, errorsCount, failed_records);
	}
}