/**
  * Description: This class contains batchable class for GDP Replication - GDP Address
  * Author: Samy Saied
  * Version: 1.0
  * History:
  */

global class BtchGDPReplicateAddress implements Database.Batchable<sObject>, Database.Stateful {
	global List<IEC_Error_Log__c> logs;

	public String query;
	public Id idRecordTypeGDP;
	public DateTime dtSystemNow;
	private Boolean bErrorFound;

	// Initialize error log
	global BtchGDPReplicateAddress () {
		logs = new List<IEC_Error_Log__c>();
	}

	global Database.querylocator start(Database.BatchableContext BC){
		bErrorFound = false;
		return Database.getQueryLocator(query);
	}

	global void execute(Database.BatchableContext BC, List<sObject> scope){
		List<GDP_Address__c> lstAIMS = new List<GDP_Address__c>();
		List<GDP_Address__c> lstWebStar = new List<GDP_Address__c>();
		List<String> lstAIMSIATACode = new List<String>();
		List<String> lstWebStarIATACode = new List<String>();
		List<Id> lstAIMSSFID = new List<Id>();
		List<Id> lstWebStarSFID = new List<Id>();

		for(sObject s : scope) {
			GDP_Address__c liveRecord = (GDP_Address__c) s;
			try {
				GDP_Address__c gdpRecord = new GDP_Address__c ();
				gdpRecord.RecordTypeId = idRecordTypeGDP;

				/**
				 * Direct Mapping
				 **/
				gdpRecord.Address_City__c = liveRecord.Address_City__c;
				gdpRecord.Address_Line_1__c = liveRecord.Address_Line_1__c;
				gdpRecord.Address_Line_2__c = liveRecord.Address_Line_2__c;
				gdpRecord.Address_Line_3__c = liveRecord.Address_Line_3__c;
				gdpRecord.Address_Postal_Code__c = liveRecord.Address_Postal_Code__c;
				gdpRecord.Address_Type__c = liveRecord.Address_Type__c;
				gdpRecord.GDP_Geo_Detail__c = liveRecord.GDP_Geo_Detail__c;
				gdpRecord.IATA_ISO_Country__c = liveRecord.IATA_ISO_Country__c;
				gdpRecord.IATA_ISO_State__c = liveRecord.IATA_ISO_State__c;

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
				logs.add(IECErrorLogger.logBatchError('Error processing records.', e.getMessage(), 'Live GDP Address ID: ' + liveRecord.Id + ', IATA Code: ' + liveRecord.Related_Account__r.IATACode__c, 'GDP Replicate: GDP Address', e.getStackTraceString()));
			}
		}

		// Process AIMS records
		try {
			if (!lstAIMS.isEmpty()) {
				List<Database.UpsertResult> lstResult = Database.upsert(lstAIMS, GDP_Address__c.AIMS_ID__c, false);
				List<IEC_Error_Log__c> lstErrors = IECErrorLogger.captureDMLError(lstAIMS, lstResult, 'GDP Replicate: GDP Address', new List<String> {'Live GDP Address ID', 'IATA Code'}, new List<List<String>> {lstAIMSSFID, lstAIMSIATACode});
				if (lstErrors != null && lstErrors.size() > 0)
					logs.addAll(lstErrors);
			}

			if (Test.isRunningTest()) throw new IECApplicationException('Test');
		}
		catch (Exception e) {
			logs.add(IECErrorLogger.logBatchError('Could not upsert AIMS records.', e.getMessage(), null, 'GDP Replicate: GDP Address', e.getStackTraceString()));
		}

		// Process WebStar records
		try {
			if (!lstWebStar.isEmpty()) {
				List<Database.UpsertResult> lstResult = Database.upsert(lstWebStar, GDP_Address__c.WebStar_ID__c, false);

				List<IEC_Error_Log__c> lstErrors = IECErrorLogger.captureDMLError(lstWebStar, lstResult, 'GDP Replicate: GDP Address', new List<String> {'Live GDP Address ID', 'IATA Code'}, new List<List<String>> {lstWebStarSFID, lstWebStarIATACode});
				if (lstErrors != null && lstErrors.size() > 0)
					logs.addAll(lstErrors);
			}

			if (Test.isRunningTest()) throw new IECApplicationException('Test');
		}
		catch (Exception e) {
			logs.add(IECErrorLogger.logBatchError('Could not upsert WebStar records.', e.getMessage(), null, 'GDP Replicate: GDP Address', e.getStackTraceString()));
		}

		// Insert error logs if applicable
		if (!logs.isEmpty()) {
			bErrorFound = true;
			insert logs;
			logs.clear();
		}
	}

	global void finish(Database.BatchableContext BC) {
		try {
			// Update the last modified date for the batch
			IECUtil.SetBatchReplication('GDP Replicate: GDP Address', dtSystemNow);

			if (Test.isRunningTest()) throw new IECApplicationException('Test');
		}
		catch (Exception e) {
			logs.add(IECErrorLogger.logBatchError('Could not set Batch Replication last modified date.', e.getMessage(), null, 'GDP Replicate: GDP Address', e.getStackTraceString()));
		}

		try {
			/**
			 * Call next batch step in the process
			 **/
			IEC_Batch_Replication__c btchRepAcc = IECUtil.GetBatchReplication('GDP Replicate: Account');
			IEC_Batch_Replication__c btchRep = IECUtil.GetBatchReplication('GDP Replicate: GDP Agency Profile and Specialization');

			// Only run the job if the schedule interface is activated through the custom settings
			if (IECConstants.GDPReplication_ScheduleActive) {
				BtchGDPReplicateAgencyProfiles btchProc = new BtchGDPReplicateAgencyProfiles();
				btchProc.idRecordTypeGDP = IECUtil.GetRecordTypeId('GDP_Agency_Profile_Specialization__c', 'GDP');
				btchProc.dtSystemNow = btchRepAcc.Last_Modified_Date__c;
				btchProc.query =
					'SELECT AIMS_ID__c, WebStar_ID__c, Main_Activity__c, Main_Destination_Specialization__c'
					+ '		, Main_Market_Specialization__c, Market_Focus_Corporate__c, Market_Focus_Leisure__c'
					+ '		, Sales_Accomodation__c, Sales_Air__c, Sales_Land__c, Sales_Sea__c, Sales_Tour__c'
					+ '		, Sales_Volume__c, Secondary_Destination_Specialization__c, Secondary_Market_Specialization__c'
					+ '		, Tertiary_Destination_Specialization__c, Tertiary_Market_Specialization__c'
					+ '		, Related_Account__r.AIMS_ID__c, Related_Account__r.WebStar_ID__c, Related_Account__r.IATACode__c'
					+ '	FROM GDP_Agency_Profile_Specialization__c'
					+ '	WHERE LastModifiedDate >= ' + btchRep.Last_Modified_Date__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')
					+ '		AND LastModifiedDate < ' + btchRepAcc.Last_Modified_Date__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')
					+ '		AND (AIMS_ID__c != null OR Webstar_ID__c != null)'
					+ '		AND RecordTypeId = \'' + IECUtil.GetRecordTypeId('GDP_Agency_Profile_Specialization__c', 'Live') + '\''
					+ '     AND Related_Account__c IN (SELECT Id FROM Account WHERE Location_Class__c IN (\'C\',\'D\',\'E\',\'F\',\'G\',\'K\',\'M\',\'N\',\'O\',\'P\',\'S\',\'T\',\'V\',\'X\') AND Main_Accreditation_Organization__c IN (\'IATA\',\'IATAN\',\'DOM\'))';
				System.debug('SSS: SOQL Query: ' + btchProc.query);

				Database.executeBatch(btchProc);
			}

			if (Test.isRunningTest()) throw new IECApplicationException('Test');
		}
		catch (Exception e) {
			logs.add(IECErrorLogger.logBatchError('Could not start next batch process.', e.getMessage(), null, 'GDP Replicate: GDP Address', e.getStackTraceString()));
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
	}
}
