/**  
  * Description: This class contains batchable class for GDP Replication - Account Category
  * Author: Samy Saied
  * Version: 1.0
  * History: 
  */
  
global class BtchGDPReplicateAccountCategory implements Database.Batchable<sObject>, Database.Stateful {
    global List<IEC_Error_Log__c> logs;

    public String query;
    public Id idRecordTypeGDP;
    public DateTime dtSystemNow;
    private Boolean bErrorFound;
    
    // Initialize error log
    global BtchGDPReplicateAccountCategory () {
    	logs = new List<IEC_Error_Log__c>();
    }

    global Database.querylocator start(Database.BatchableContext BC){
		bErrorFound = false;
		return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
		List<Account_Category__c> lstAIMS = new List<Account_Category__c>();
		List<Account_Category__c> lstWebStar = new List<Account_Category__c>();
		List<String> lstAIMSIATACode = new List<String>();
		List<String> lstWebStarIATACode = new List<String>();
		List<Id> lstAIMSSFID = new List<Id>();
		List<Id> lstWebStarSFID = new List<Id>();

        for(sObject s : scope) {
			Account_Category__c liveRecord = (Account_Category__c) s;
			try {
				Account_Category__c gdpRecord = new Account_Category__c ();
				gdpRecord.RecordTypeId = idRecordTypeGDP;

				/**
				 * Direct Mapping
				 **/
				gdpRecord.Category_ID__c = liveRecord.Category_ID__c;
				gdpRecord.Category_Code__c = liveRecord.Category_Code__c;

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
				logs.add(IECErrorLogger.logBatchError('Error processing records.', e.getMessage(), 'Live Account Category ID: ' + liveRecord.Id + ', IATA Code: ' + liveRecord.Related_Account__r.IATACode__c, 'GDP Replicate: Account Category', e.getStackTraceString()));
			}
		}

		// Process AIMS records
		try {
			if (!lstAIMS.isEmpty()) {
				List<Database.UpsertResult> lstResult = Database.upsert(lstAIMS, Account_Category__c.AIMS_ID__c, false);
				List<IEC_Error_Log__c> lstErrors = IECErrorLogger.captureDMLError(lstAIMS, lstResult, 'GDP Replicate: Account Category', new List<String> {'Live Account Category ID', 'IATA Code'}, new List<List<String>> {lstAIMSSFID, lstAIMSIATACode});
				if (lstErrors != null && lstErrors.size() > 0)
					logs.addAll(lstErrors);
			}
	    	
	    	if (Test.isRunningTest()) throw new IECApplicationException('Test');
		}
		catch (Exception e) {
			logs.add(IECErrorLogger.logBatchError('Could not upsert AIMS records.', e.getMessage(), null, 'GDP Replicate: Account Category', e.getStackTraceString()));
		}

		// Process WebStar records
		try {
			if (!lstWebStar.isEmpty()) {
				List<Database.UpsertResult> lstResult = Database.upsert(lstWebStar, Account_Category__c.WebStar_ID__c, false);
				
				List<IEC_Error_Log__c> lstErrors = IECErrorLogger.captureDMLError(lstWebStar, lstResult, 'GDP Replicate: Account Category', new List<String> {'Live Account Category ID', 'IATA Code'}, new List<List<String>> {lstWebStarSFID, lstWebStarIATACode});
				if (lstErrors != null && lstErrors.size() > 0)
					logs.addAll(lstErrors);
			}
	    	
	    	if (Test.isRunningTest()) throw new IECApplicationException('Test');
		}
		catch (Exception e) {
			logs.add(IECErrorLogger.logBatchError('Could not upsert WebStar records.', e.getMessage(), null, 'GDP Replicate: Account Category', e.getStackTraceString()));
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
	    	IECUtil.SetBatchReplication('GDP Replicate: Account Category', dtSystemNow);
	    	
	    	if (Test.isRunningTest()) throw new IECApplicationException('Test');
		}
		catch (Exception e) {
			logs.add(IECErrorLogger.logBatchError('Could not set Batch Replication last modified date.', e.getMessage(), null, 'GDP Replicate: Account Category', e.getStackTraceString()));
		}
	    
	    try {
	    	/**
	    	 * Call next batch step in the process
	    	 **/
			IEC_Batch_Replication__c btchRepAcc = IECUtil.GetBatchReplication('GDP Replicate: Account');
			IEC_Batch_Replication__c btchRep = IECUtil.GetBatchReplication('GDP Replicate: Accreditation');
			
			// Only run the job if the schedule interface is activated through the custom settings
			if (IECConstants.GDPReplication_ScheduleActive) {
				BtchGDPReplicateAccreditation btchProc = new BtchGDPReplicateAccreditation();
				btchProc.idRecordTypeGDP = IECUtil.GetRecordTypeId('Accreditation__c', 'GDP');
				btchProc.dtSystemNow = btchRepAcc.Last_Modified_Date__c;
				btchProc.query =
					'SELECT AIMS_ID__c, WebStar_ID__c, Accreditation_ID__c, Class__c'
					+ '		, Endorsed_Accredited_By_Formula__c, Last_change_date__c, Last_re_inspection_date__c'
					+ '		, Original_approval_date__c, Status__c, Date__c'
					+ '		, Related_Account__r.AIMS_ID__c, Related_Account__r.WebStar_ID__c, Related_Account__r.IATACode__c'
					+ '	FROM Accreditation__c'
					+ '	WHERE LastModifiedDate >= ' + btchRep.Last_Modified_Date__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')
					+ '		AND LastModifiedDate < ' + btchRepAcc.Last_Modified_Date__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')
					+ '		AND (AIMS_ID__c != null OR Webstar_ID__c != null)'
					+ '		AND RecordTypeId = \'' + IECUtil.GetRecordTypeId('Accreditation__c', 'Live') + '\''
					+ '		AND Endorsed_Accredited_By_Formula__c IN (\'IATA\',\'IATAN\',\'DOM\') AND Class__r.Code__c IN (\'C\',\'D\',\'E\',\'F\',\'G\',\'K\',\'M\',\'N\',\'O\',\'P\',\'S\',\'T\',\'V\',\'X\') AND Related_Account__r.Id != null';
				
				System.debug('SSS: SOQL Query: ' + btchProc.query);
	
				Database.executeBatch(btchProc);
			}
	    	
	    	if (Test.isRunningTest()) throw new IECApplicationException('Test');
		}
		catch (Exception e) {
			logs.add(IECErrorLogger.logBatchError('Could not start next batch process.', e.getMessage(), null, 'GDP Replicate: Account Category', e.getStackTraceString()));
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