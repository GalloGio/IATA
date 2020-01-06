/**
	* Description: This class contains batchable class for GDP Replication - Accreditation / Territories
	* Author: Abdellah Bellahssan
	* Updated By: Sonny Leman
	* Version: 1.0
	* History:
	*   2016-02-05-sl: change Related_Accreditation__r.AIMS_ID__c value suffix to 'ACC1GDP', add callBatchReplicateTerritories, change query filter.
	*   2016-02-12-sl: use GSA_Territory.AIMS_Territory_Unique_Reference__c as the external id and map live GSA_Territory.Related_Accreditation directly
	*   2016-05-09-sl: bug fix on setting AIMS_Territory_Unique_Reference.
	*
	* Important note (Sonny Leman):
	*   - GSA_Territory.AIMS_ID is not unique, therefore GSA_Territory.AIMS_Territory_Unique_Reference__c is used as external id.
	*   - This code is written following the pattern of the other BtchGDPReplicate* classes, however, we need to informed that the original base pattern is not a recommended one.
	*   - While we tried to reduce the bad model, we are limited to the the fact that as this batch is running in cascading process with other and we avoid changing other codes.
	*   - This existing bad pattern also affected our ability to write the additional descent test method (in BtchGDPReplicate_tst).
	*
	*/

global class BtchGDPReplicateTerritories implements Database.Batchable<sObject>, Database.Stateful {
	global List<IEC_Error_Log__c> logs;

	public String query;
	public Id idRecordTypeGDP;
	public DateTime dtSystemNow;
	private Boolean bErrorFound;

	// Initialize error log
	global BtchGDPReplicateTerritories () {
		logs = new List<IEC_Error_Log__c>();
	}

	global Database.querylocator start(Database.BatchableContext BC){
		bErrorFound = false;
		return Database.getQueryLocator(query);
	} // end of queryLocator

	// ========================================================================
	// batch execution method
	global void execute(Database.BatchableContext BC, List<sObject> scope){
		System.debug( 'BtchGDPReplicateTerritories: execute(), scope length:' + scope.size());
		List<GSA_Territory__c> lstAIMS = new List<GSA_Territory__c>();
		List<GSA_Territory__c> lstWebStar = new List<GSA_Territory__c>();
		List<String> lstAIMSIATACode = new List<String>();
		List<String> lstWebStarIATACode = new List<String>();
		List<Id> lstAIMSSFID = new List<Id>();
		List<Id> lstWebStarSFID = new List<Id>();

		String liveRecAimsTerritoryUniqueRef;
		for(sObject s : scope) {
			GSA_Territory__c liveRecord = (GSA_Territory__c) s;
			try {
				liveRecAimsTerritoryUniqueRef = liveRecord.AIMS_Territory_Unique_Reference__c;
				if (( liveRecAimsTerritoryUniqueRef != null)
					&& ( !liveRecAimsTerritoryUniqueRef.endsWith( 'GDP')))
				{
					GSA_Territory__c gdpRecord = new GSA_Territory__c();
					//gdpRecord.RecordTypeId = idRecordTypeGDP;

					/**
					 * Direct Mapping
					 **/
					gdpRecord.Accreditation_ID__c =liveRecord.Accreditation_ID__c;
					gdpRecord.IATA_Code__c =liveRecord.IATA_Code__c;
					gdpRecord.AIMS_Territory_Unique_Reference__c = liveRecord.AIMS_Territory_Unique_Reference__c + 'GDP'; // external id, review later if we should add 'GDP' here.
					gdpRecord.Check_Digit__c =liveRecord.Check_Digit__c;
					gdpRecord.IATA_ISO_Country__c =liveRecord.IATA_ISO_Country__c;
					gdpRecord.IATA_ISO_NCode__c =liveRecord.IATA_ISO_NCode__c;
					gdpRecord.Location_Country_Name__c =liveRecord.Location_Country_Name__c;
					gdpRecord.Airline_Code__c =liveRecord.Airline_Code__c;
					gdpRecord.Airline_Name__c =liveRecord.Airline_Name__c;
					gdpRecord.Appointment_Type__c =liveRecord.Appointment_Type__c;
					gdpRecord.Appointment_Date__c =liveRecord.Appointment_Date__c;
					gdpRecord.Territory_ISO_Country__c =liveRecord.Territory_ISO_Country__c;
					gdpRecord.Territory_IATA_Numeric_Country_Code__c =liveRecord.Territory_IATA_Numeric_Country_Code__c;
					gdpRecord.Territory_Country_Name__c =liveRecord.Territory_Country_Name__c;
					gdpRecord.Territory_State_Abbreviation__c =liveRecord.Territory_State_Abbreviation__c;
					gdpRecord.Territory_Description__c =liveRecord.Territory_Description__c;
					gdpRecord.Related_Accreditation__c =liveRecord.Related_Accreditation__c;// this already points to the GDP version

					if (!String.isBlank(liveRecord.AIMS_ID__c)) {
						//Check How the structure is built
						//Under a given Accreditation
						// Note that Accreditation.AIMS_ID = GSA_Territory.Accreditation_ID = live GSA_Territory.AIMS_ID + 'ACC' + accreditation row_number + 'GDP'

						//For a given Product and Account View
						gdpRecord.Related_GDP_Products_Account_View__r = new GDP_Products_Account_View__c (IATA_Code__c = liveRecord.IATA_Code__c);

						gdpRecord.AIMS_ID__c = liveRecord.AIMS_ID__c; // not sure if adding 'GDP' is still relevant
						lstAIMS.add(gdpRecord);
						lstAIMSSFID.add(liveRecord.Id);
						lstAIMSIATACode.add(liveRecord.IATA_Code__c);
					}
				} // only replicate those not ending with GDP

				// (Test.isRunningTest()) throw new IECApplicationException('Test');
			}
			catch (Exception e) {
				System.debug('BatchGDPReplicateTerritories exception in copying territories: ' + e + '\n\n' + e.getMessage() + '\n\n'+ e.getStackTraceString());
				logs.add(IECErrorLogger.logBatchError('Error processing records.', e.getMessage(), 'Live GDS ID: ' + liveRecord.Id + ', IATA Code: ' + liveRecord.IATA_Code__c, 'GDP Replicate: Territories', e.getStackTraceString()));
			}
		}


		// Process AIMS records
		try {
			if (!lstAIMS.isEmpty()) {
				//List<Database.UpsertResult> lstResult = Database.upsert(lstAIMS, GSA_Territory__c.AIMS_ID__c, false);
				List<Database.UpsertResult> lstResult = Database.upsert(lstAIMS, GSA_Territory__c.AIMS_Territory_Unique_Reference__c, false);
				List<IEC_Error_Log__c> lstErrors = IECErrorLogger.captureDMLError(lstAIMS, lstResult, 'GDP Replicate: Territories', new List<String> {'Live GDS ID', 'IATA Code'}, new List<List<String>> {lstAIMSSFID, lstAIMSIATACode});
				if (lstErrors != null && lstErrors.size() > 0)
					logs.addAll(lstErrors);
				System.debug( 'BtchGDPReplicateTerritories reported IEC_Error_Log: ' + lstErrors);
			}

			// (Test.isRunningTest()) throw new IECApplicationException('Test');
		}
		catch (Exception e) {
			System.debug('BatchGDPReplicateTerritories exception:' + e + '\n\n' + e.getMessage() + '\n\n'+ e.getStackTraceString());
			logs.add(IECErrorLogger.logBatchError('Could not upsert AIMS records.', e.getMessage(), null, 'GDP Replicate: Territories', e.getStackTraceString()));
		}

		// Insert error logs if applicable
		if (!logs.isEmpty()) {
			bErrorFound = true;
			insert logs;
			logs.clear();
		}
	} // end of execute

	// ========================================================================
	// when this batch is finish, call next job on the line
	global void finish(Database.BatchableContext BC) {
		System.debug( 'BtchGDPReplicateTerritories: finish()');

		try {
			// Update the last modified date for the batch
			IECUtil.SetBatchReplication('GDP Replicate: Territories', dtSystemNow);

			//if (Test.isRunningTest()) throw new IECApplicationException('Test');
		}
		catch (Exception e) {
			logs.add(IECErrorLogger.logBatchError('Could not set Batch Replication last modified date.', e.getMessage(), null, 'GDP Replicate: Territories', e.getStackTraceString()));
		}

		try {
			/**
			 * Call next batch step in the process
			 **/
			IEC_Batch_Replication__c btchRep = IECUtil.GetBatchReplication('GDP Replicate: Account');

			// Only run the job if the schedule interface is activated through the custom settings
			if (IECConstants.GDPReplication_ScheduleActive) {
				BtchGDPReplicateAccountUpdate btchProc = new BtchGDPReplicateAccountUpdate();
				btchProc.dtSystemNow = btchRep.Last_Modified_Date__c;
				btchProc.query =
					'SELECT Id, AIMS_ID__c, Webstar_ID__c, Parent_Account_AIMS_ID__c, Parent_Account_WebStar_ID__c, IATA_Code__c'
					+ ' FROM GDP_Products_Account_View__c'
					+ ' WHERE LastModifiedDate >= ' + btchRep.Last_Modified_Date__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')
					+ '	 AND (AIMS_ID__c != null OR Webstar_ID__c != null)'
					+ '	 AND RecordTypeId = \'' + IECUtil.GetRecordTypeId('GDP_Products_Account_View__c', 'GDP') + '\'';

				System.debug('SSS: SOQL Query: ' + btchProc.query);

				Database.executeBatch(btchProc);
			}

			//if (Test.isRunningTest()) throw new IECApplicationException('Test');
		}
		catch (Exception e) {
			logs.add(IECErrorLogger.logBatchError('Could not start next batch process.', e.getMessage(), null, 'GDP Replicate: Territories', e.getStackTraceString()));
		}


		// Insert error logs if applicable
		if (!logs.isEmpty()) {
			bErrorFound = true;
			insert logs;
		}

		// Send email notification when errors are found
		if (bErrorFound) {
			if (!IECEmailUtility.notificationExistsToday(IECConstants.GDPReplication_SystemAdminEmail, IECConstants.Email_Template_GDPError)) {
				IECEmailUtility.sendEmail(null, IECConstants.GDPReplication_SystemAdminEmail, IECConstants.Email_Template_GDPError, null, null, null, null, null, null, null);
			}
		}

	} // end of finish


	// ========================================================================
	// use callBatchReplicateTerritories to do standard call to this batch class.
	// previously this block was on the BtchGDPReplicateGDS.cls
	// latestRecordUpdateTimeLimit is the upper limit of GSA_Territory__c.LastModifiedDate to be included in the query
	// previously it was set as btchRepAcc.Last_Modified_Date__c
	//
	// Query and Live Data assumptions:
	//  - Incoming live GSA_Territory is not expected to have the GSA_Territory__r.Related_Account__c populated.
	//  - Existing Accreditation referred in GSA_Territory__r.Related_Accreditation__c is not guaranteed to have GSA_Territory__r.Related_Accreditation__r.Related_Account__c populated.
	//
	public static void callBatchReplicateTerritories(DateTime batchStartTime)
	{
		IEC_Batch_Replication__c btchRep = IECUtil.GetBatchReplication('GDP Replicate: Territories');
		//IEC_Batch_Replication__c btchRepAcc = IECUtil.GetBatchReplication('GDP Replicate: Account');

		System.debug( 'BtchBDPReplicateTerritories.callBatchReplicateTerritories, IEC_Batch_Replication__c: '
						+ ' Id:' + btchRep.Id +', last run:' + btchRep.Last_Modified_Date__c);

		System.debug( 'catlling batch job BtchBDPReplicateTerritories.');
		BtchGDPReplicateTerritories btchProc = new BtchGDPReplicateTerritories();
		btchProc.dtSystemNow = batchStartTime;

		btchProc.query =
			'SELECT Id, AIMS_ID__c, IATA_Code__c'
			+ ', AIMS_Territory_Unique_Reference__c' // this is the external id for GSA_Territory
			//+ ', Related_Account__r.IATACode__c'
			+ ', Check_Digit__c'
			+ ', IATA_ISO_Country__c'
			+ ', IATA_ISO_NCode__c'
			+ ', Location_Country_Name__c'
			+ ', Accreditation_ID__c'
			+ ', Airline_Code__c'
			+ ', Airline_Name__c'
			+ ', Appointment_Type__c'
			+ ', Appointment_Date__c'
			+ ', Related_Accreditation__c'
			//+ ', Related_Accreditation__r.Related_Account__c'
			+ ', Territory_ISO_Country__c'
			+ ', Territory_IATA_Numeric_Country_Code__c'
			+ ', Territory_Country_Name__c'
			+ ', Territory_State_Abbreviation__c'
			+ ', Territory_Description__c'
			+ ', AIMS_Related_Account__c'
			+ '	FROM GSA_Territory__c'
			+ '	WHERE LastModifiedDate >= ' + btchRep.Last_Modified_Date__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')
			+ '		AND LastModifiedDate < ' + batchStartTime.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')
			+ '		AND (AIMS_ID__c != null)'
			//+ '		AND RecordTypeId = \'' + IECUtil.GetRecordTypeId('GSA_Territory__c', 'Live') + '\''
			//+ '		AND Related_Account__c IN (SELECT Related_Account__c FROM Accreditation__c WHERE Endorsed_Accredited_By__r.Code__c IN (\'IATA\',\'IATAN\',\'DOM\') AND Class__r.Code__c IN (\'C\',\'D\',\'E\',\'F\',\'G\',\'K\',\'M\',\'N\',\'O\',\'P\',\'S\',\'T\',\'V\',\'X\') AND Related_Account__r.Id != null)'
			+ '		AND Related_Accreditation__r.Endorsed_Accredited_By__r.Code__c IN (\'IATA\',\'IATAN\',\'DOM\') '
			+ '		AND Related_Accreditation__r.Class__r.Code__c IN (\'C\',\'D\',\'E\',\'F\',\'G\',\'K\',\'M\',\'N\',\'O\',\'P\',\'S\',\'T\',\'V\',\'X\') '
//			+ '		AND Related_Accreditation__r.Related_Account__r.Id != null'
			+ '		AND Related_Accreditation__c != null '
			;

		// showQuery(btchProc.query); // this is only for debugging
		Database.executeBatch(btchProc);
	} // callBatchReplicateTerritories


	/*
	// ========================================================================
	// debugging tool to show if the query return some records
	private static void showQuery( String query)
	{
		System.debug( '\n\nBtchGDPReplicateTerritories query at ' + DateTime.now() + ':\n' + query) ;
		List<GSA_Territory__c> territoryList = Database.query(query + ' LIMIT 5');
		System.debug( '\n\nTerritory query num of recs:' + territoryList.size());
		System.debug( 'Territory query result:' + territoryList);
	} // showQuery
	*/
} // end of BtchGDPReplicateTerritories class
