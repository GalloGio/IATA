/**
	* Description: This class contains batchable class for GDP Replication - GDS
	* Author: Samy Saied
	* Updated By: Bellahssan Abdellah; Sonny Leman
	* Version: 1.0
	* History:
	*  20151120-sl: exclude  Territory_IATA_Numeric_Country Code__c and RecordTypeId (of GSA_Territory) from the query
	*  20160204-sl: call GDP Replicate Territories using	BtchGDPReplicateTerritories.callBatchReplicateTerritories
	*
	*/

global class BtchGDPReplicateGDS implements Database.Batchable<sObject>, Database.Stateful {
	global List<IEC_Error_Log__c> logs;

	public String query;
	public Id idRecordTypeGDP;
	public DateTime dtSystemNow;
	private Boolean bErrorFound;

	// Initialize error log
	global BtchGDPReplicateGDS () {
		logs = new List<IEC_Error_Log__c>();
	}

	global Database.querylocator start(Database.BatchableContext BC){
		bErrorFound = false;
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope){
		List<GDS__c> lstAIMS = new List<GDS__c>();
		List<GDS__c> lstWebStar = new List<GDS__c>();
		List<String> lstAIMSIATACode = new List<String>();
		List<String> lstWebStarIATACode = new List<String>();
		List<Id> lstAIMSSFID = new List<Id>();
		List<Id> lstWebStarSFID = new List<Id>();

		for(sObject s : scope) {
			GDS__c liveRecord = (GDS__c) s;
			try {
				GDS__c gdpRecord = new GDS__c ();
				gdpRecord.RecordTypeId = idRecordTypeGDP;

				/**
				 * Direct Mapping
				 **/
				gdpRecord.Computer_Reservation_System__c = liveRecord.Computer_Reservation_System__c;
				gdpRecord.GDS_ID__c = liveRecord.GDS_ID__c;

				if (!String.isBlank(liveRecord.AIMS_ID__c)) {
					gdpRecord.Related_GDP_Products_Account_View__r = new GDP_Products_Account_View__c (AIMS_ID__c = liveRecord.Related_Account__r.AIMS_ID__c + 'GDP');
					gdpRecord.AIMS_ID__c = liveRecord.AIMS_ID__c + 'GDP';
					lstAIMS.add(gdpRecord);
					lstAIMSSFID.add(liveRecord.Id);
					lstAIMSIATACode.add(liveRecord.Related_Account__r.IATACode__c);
				}
				else if (!String.isBlank(liveRecord.WebStar_ID__c)) {
					gdpRecord.Related_GDP_Products_Account_View__r = new GDP_Products_Account_View__c (WebStar_ID__c = liveRecord.Related_Account__r.WebStar_ID__c + 'GDP');
					gdpRecord.WebStar_ID__c = liveRecord.WebStar_ID__c + 'GDP';
					lstWebStar.add(gdpRecord);
					lstWebStarSFID.add(liveRecord.Id);
					lstWebStarIATACode.add(liveRecord.Related_Account__r.IATACode__c);
				}

				if (Test.isRunningTest()) throw new IECApplicationException('Test');
			}
			catch (Exception e) {
				logs.add(IECErrorLogger.logBatchError('Error processing records.', e.getMessage(), 'Live GDS ID: ' + liveRecord.Id + ', IATA Code: ' + liveRecord.Related_Account__r.IATACode__c, 'GDP Replicate: GDS', e.getStackTraceString()));
			}
		}

		// Process AIMS records
		try {
			if (!lstAIMS.isEmpty()) {
				List<Database.UpsertResult> lstResult = Database.upsert(lstAIMS, GDS__c.AIMS_ID__c, false);
				List<IEC_Error_Log__c> lstErrors = IECErrorLogger.captureDMLError(lstAIMS, lstResult, 'GDP Replicate: GDS', new List<String> {'Live GDS ID', 'IATA Code'}, new List<List<String>> {lstAIMSSFID, lstAIMSIATACode});
				if (lstErrors != null && lstErrors.size() > 0)
					logs.addAll(lstErrors);
			}

			if (Test.isRunningTest()) throw new IECApplicationException('Test');
		}
		catch (Exception e) {
			logs.add(IECErrorLogger.logBatchError('Could not upsert AIMS records.', e.getMessage(), null, 'GDP Replicate: GDS', e.getStackTraceString()));
		}

		// Process WebStar records
		try {
			if (!lstWebStar.isEmpty()) {
				List<Database.UpsertResult> lstResult = Database.upsert(lstWebStar, GDS__c.WebStar_ID__c, false);

				List<IEC_Error_Log__c> lstErrors = IECErrorLogger.captureDMLError(lstWebStar, lstResult, 'GDP Replicate: GDS', new List<String> {'Live GDS ID', 'IATA Code'}, new List<List<String>> {lstWebStarSFID, lstWebStarIATACode});
				if (lstErrors != null && lstErrors.size() > 0)
					logs.addAll(lstErrors);
			}

			if (Test.isRunningTest()) throw new IECApplicationException('Test');
		}
		catch (Exception e) {
			logs.add(IECErrorLogger.logBatchError('Could not upsert WebStar records.', e.getMessage(), null, 'GDP Replicate: GDS', e.getStackTraceString()));
		}

		// Insert error logs if applicable
		if (!logs.isEmpty()) {
			bErrorFound = true;
			insert logs;
			logs.clear();
		}
	}

	// ========================================================================
	// when this is finished, log in IEC_Batch_Replication and call next batchable job as defined
	global void finish(Database.BatchableContext BC) {
		try {
			// Update the last modified date for the batch
			IECUtil.SetBatchReplication('GDP Replicate: GDS', dtSystemNow);

			if (Test.isRunningTest()) throw new IECApplicationException('Test');
		}
		catch (Exception e) {
			logs.add(IECErrorLogger.logBatchError('Could not set Batch Replication last modified date.', e.getMessage(), null, 'GDP Replicate: GDS', e.getStackTraceString()));
		}

		try {
			/**
			 * Call next batch step in the process
			 **/
			// IEC_Batch_Replication__c btchRepAcc = IECUtil.GetBatchReplication('GDP Replicate: Account');

			// Only run the job if the schedule interface is activated through the custom settings
			if (IECConstants.GDPReplication_ScheduleActive) {
				System.debug( 'call BtchGDPReplicateTerritories processing file updated up to ' + dtSystemNow ); // btchRepAcc.Last_Modified_Date__c);
				// the following method will execute batch procedure query GDP Replicate Terrritories
				BtchGDPReplicateTerritories.callBatchReplicateTerritories( dtSystemNow) ; // btchRepAcc.Last_Modified_Date__c);
			}

			if (Test.isRunningTest()) throw new IECApplicationException('Test');
		}
		catch (Exception e) {
			logs.add(IECErrorLogger.logBatchError('Could not start next batch process.', e.getMessage(), null, 'GDP Replicate: GDS', e.getStackTraceString()));
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
} // end of BtchGDPReplicateGDS class
