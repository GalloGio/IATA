/**
 * Batch Class to Synchronize AMS_Account_Role => Agency_Owner__c
 * @author Bhanu Chandra Bulusu<bulusub@iata.org>
 * @version 1.0
 */

global class ams2gdp_Batch_AMS_Account_Role implements Database.Batchable<sObject>, Database.Stateful {
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

	public void init(Boolean runNext, List<String> ids, Boolean manual) {
		isManual = manual == null ? false : manual;
		batchName = 'Job 7: Agency Owner';
		processNextBatch = runNext;
		extraIds = ids;

		String fields = ' Id, Owner_Name__c,Percentage__c,Account__c, Contact__r.Name, Unified_Owner_Name__c';

		List<String> conditions = new List<String> {'Account__r.RecordTypeId= \'' + RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency') + '\''
		        , 'Account__r.IATACode__c != null'
		        , 'Account__r.Main_Accreditation_Organization__c IN (\'IATA\',\'IATAN\',\'DOM\') '
		        , 'Account__r.CNS_Agency__c = false'
		        , 'Account__r.CNS_Account__c = false'
		        , 'Active__c = true'
		        , 'RecordType.Name = \'Ownership\''
		        // , 'Account__c IN ('+accreditation_condition+')'
		                                           };

		if (extraIds != null && extraIds.size() > 0) {
			if (extraIds[0] == 'none') {
				conditions.add('Id=null');
			} else {
				//Run batch on specific Ids
				List<String> specificIds = new List<String>();
				for (String s : extraIds) {
					if (s.length() >= 15)
						specificIds.add(s.left(15));
				}

				if (specificIds.size() > 0)	conditions.add('Id IN (\'' + String.join(specificIds, '\', \'') + '\')');
			}
		} else {
			if (!String.isBlank(AMS_2_GDP_Settings__c.getOrgDefaults().Status__c)) {
				statusSet = new Set<String>(AMS_2_GDP_Settings__c.getOrgDefaults().Status__c.split(';'));
				conditions.add('Account__r.Status__c IN  :statusSet ');

			}
			if (!String.isBlank(AMS_2_GDP_Settings__c.getOrgDefaults().Location_Classes__c)) {
				locationsSet = new Set<String>(AMS_2_GDP_Settings__c.getOrgDefaults().Location_Classes__c.split(';'));
				conditions.add('Account__r.Location_Class__c IN:  locationsSet');
			}

			AMS_GDP_Batch__c batchInfo = ams2gdp_Selector.getBatchInfo(batchName);
			if (batchInfo != null) {
				//Run only on the deltas
				String deltaConditions = String.format('LastModifiedDate >= {0}'
				                                       , new List<String> {batchInfo.Last_Sync_Start_Date__c.addDays(-2).format('yyyy-MM-dd\'T\'hh:mm:ss\'Z\'', 'GMT')});

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
		                      +	'FROM AMS_Account_Role__c '
		                      + 	'WHERE {1} '
		                      +	'ORDER BY Account__c ASC, Percentage__c DESC',
		                      new List<String> {fields, String.join(conditions, ' AND ')}
		                     );
	}

	global ams2gdp_Batch_AMS_Account_Role() {
		init(false, null, null);
	}

	global ams2gdp_Batch_AMS_Account_Role(Boolean runNext, Boolean manual) {
		init(runNext, null, manual);
	}

	global ams2gdp_Batch_AMS_Account_Role(Boolean runNext, List<String> extra, Boolean manual) {
		init(runNext, extra, manual);
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		//-- No error when the batch starts
		errorsCount = 0;
		totalRecords = 0;
		failed_records = new List<String>();
		syncStartedDate = Datetime.now();

		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<AMS_Account_Role__c> scope) {

		//-- Total records to be processed
		totalRecords += scope.size();

		// Process Errors
		List<ams2gdp_Error> errors = new List<ams2gdp_Error>();

		List<Agency_Owner__c> records2Save = new List<Agency_Owner__c>();

		// delete the old ones
		List<Agency_Owner__c> records2Delete = ams2gdp_BusinessLogic.getAgencyOwnersToDelete(scope);
		Savepoint sp = Database.setSavepoint();

		try {
			delete records2Delete;

			records2Save = ams2gdp_BusinessLogic.formatAccountRole2AgencyOwner(scope);

			//-- Raise exception for Unit Tests
			if (Test.isRunningTest() &&   throwException) insert new Account();
		} catch (Exception ex) {
			Database.rollback(sp);
			errors.add(ams2gdp_Error.Exception2Error(batchName, ex));
		}

		List<Database.UpsertResult> save_results = Database.upsert(records2Save, Agency_Owner__c.AMS_GDP_Key__c.getDescribe().getSObjectField(), false);

		//--Check if there is orphan GDP records
		for (Agency_Owner__c ao : records2Save) {
			if (ao.Related_GDP_Products_Account_View__c == null) {
				errors.add(new ams2gdp_Error(batchName, ao.AMS_GDP_Key__c.left(18), null, 'ORPHAN_RECORD'));
			}
		}

		// Process Errors
		errors.addAll(ams2gdp_Error.formatUpsertResult(records2save, save_results, batchName, 'AMS_GDP_Key__c'));

		//Log the current Errors
		if (!errors.isEmpty()) {
			errorsCount = errorsCount + errors.size();
			ams2gdp_Utils.logErrors(errors);

			//-- Save failed records
			Set<String> set_failed_records = new Set<String>(failed_records);

			for (ams2gdp_Error failed_rec : errors)
				if (failed_rec.amsRecordId != null) {set_failed_records.add(failed_rec.amsRecordId.left(18));}

			failed_records = new List<String>(set_failed_records);
		}

	}

	global void finish(Database.BatchableContext BC) {
		if (processNextBatch)Database.executeBatch(new ams2gdp_Batch_AMS_Agency_Airport(true, isManual));
		ams2gdp_Utils.upsertAMS_GDP_Batch(batchName, syncStartedDate, errorsCount, totalRecords, failed_records, isManual);
		//--Send completion notification
		ams2gdp_Utils.notifyBatchOutput(batchName, totalRecords, errorsCount, failed_records);
	}
}