/**  
  * Description: This class contains batchable class for GDP Replication - Account 
  * Author: Samy Saied
  * Version: 1.0
  * History: 
  */
  
global class BtchGDPReplicateAccount implements Database.Batchable<sObject>, Database.Stateful {
    global List<IEC_Error_Log__c> logs;

    public String query;
    public Id idRecordTypeGDP;
    public DateTime dtSystemNow;
    private Boolean bErrorFound;
    
    // Initialize error log
    global BtchGDPReplicateAccount () {
    	logs = new List<IEC_Error_Log__c>();
    }

    global Database.querylocator start(Database.BatchableContext BC){
		dtSystemNow = system.now();
		bErrorFound = false;
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
		List<GDP_Products_Account_View__c> lstAIMS = new List<GDP_Products_Account_View__c>();
		List<GDP_Products_Account_View__c> lstWebStar = new List<GDP_Products_Account_View__c>();
		List<String> lstAIMSIATACode = new List<String>();
		List<String> lstWebStarIATACode = new List<String>();
		List<Id> lstAIMSSFID = new List<Id>();
		List<Id> lstWebStarSFID = new List<Id>();

        for(sObject s : scope) {
			Account liveRecord = (Account) s;
			try {
				GDP_Products_Account_View__c gdpRecord = new GDP_Products_Account_View__c ();
				gdpRecord.RecordTypeId = idRecordTypeGDP;

				/**
				 * Direct Mapping
				 **/
				gdpRecord.IATA_Code__c = liveRecord.IATACode__c.substring(0, 7);
				gdpRecord.Check_Digit__c = liveRecord.IATACode__c.substring(liveRecord.IATACode__c.length()-1);
				gdpRecord.CASS_Number__c = liveRecord.CASS_Number__c;
				gdpRecord.CASS_Number_Xref__c = liveRecord.CASS_Number_Xref__c;
				gdpRecord.Location_Type__c = liveRecord.GDP_Location_Type__c;
				gdpRecord.Airline_Code__c = liveRecord.Airline_Code__c;
				gdpRecord.Email_Address__c = liveRecord.Email__c;
				gdpRecord.Website__c = liveRecord.Website;
				gdpRecord.TTY__c = liveRecord.TTY__c;
				gdpRecord.Passenger_And_Cargo__c = liveRecord.Passenger_And_Cargo__c;
				gdpRecord.Incorporation_Type__c = liveRecord.Incorporation_Type__c;
				gdpRecord.GDP_Opt_In__c = liveRecord.GDP_Opt_In__c;
				gdpRecord.Tax_ID_1__c = liveRecord.Tax_ID_1__c;
				gdpRecord.Tax_ID_2__c = liveRecord.Tax_ID_2__c;
				gdpRecord.BSP_CASS_Code__c = liveRecord.BSP_CASS_Code__c;
				gdpRecord.License_Number__c = liveRecord.License_Number__c;
				gdpRecord.Preferred_Language__c = liveRecord.Preferred_Language__c;
				gdpRecord.Ticketing_Agent_Last_Name__c = liveRecord.Ticketing_Agent_Last_Name__c;
				gdpRecord.Ticketing_Agent_First_Name__c = liveRecord.Ticketing_Agent_First_Name__c;
				gdpRecord.Manager_Last_Name__c = liveRecord.Manager_Last_Name__c;
				gdpRecord.Manager_First_Name__c = liveRecord.Manager_First_Name__c;
				gdpRecord.Last_Date_of_Update__c = Date.today();
				gdpRecord.Agency_Short_Name__c = liveRecord.Short_Name__c;

				/**
				 * Transformations
				 **/
				// Truncate long names to maximum of 80 characters
				gdpRecord.Name = liveRecord.Name.length() > 80 ? liveRecord.Name.substring(0, 80) : liveRecord.Name;
				
				// Wrap the Legal Name
				List<String> lstLines = IECUtil.WrapText(liveRecord.Name, 32);
				gdpRecord.Legal_Name_1__c = (lstLines.size() > 0) ? lstLines.get(0) : null;
				gdpRecord.Legal_Name_2__c = (lstLines.size() > 1) ? lstLines.get(1) : null;
				gdpRecord.Legal_Name_3__c = (lstLines.size() > 2) ? lstLines.get(2) : null;
				
				// Wrap the Trading Name
				lstLines = IECUtil.WrapText(liveRecord.TradeName__c, 32);
				gdpRecord.Trading_Name_1__c = (lstLines.size() > 0) ? lstLines.get(0) : null;
				gdpRecord.Trading_Name_2__c = (lstLines.size() > 1) ? lstLines.get(1) : null;
				
				if (!String.isBlank(liveRecord.AIMS_ID__c)) {
					if (liveRecord.ParentId != null && !String.isBlank(liveRecord.Parent.AIMS_ID__c)) {
						gdpRecord.Parent_Account_AIMS_ID__c = liveRecord.Parent.AIMS_ID__c;
					}
					else {
						gdpRecord.Parent_Account_AIMS_ID__c = null;
					}
					
					gdpRecord.AIMS_ID__c = liveRecord.AIMS_ID__c + 'GDP';
					lstAIMS.add(gdpRecord);
					lstAIMSSFID.add(liveRecord.Id);
					lstAIMSIATACode.add(liveRecord.IATACode__c);
				}
				else if (!String.isBlank(liveRecord.WebStar_ID__c)) {
					if (liveRecord.ParentId != null && !String.isBlank(liveRecord.Parent.WebStar_ID__c)) {
						gdpRecord.Parent_Account_WebStar_ID__c = liveRecord.Parent.WebStar_ID__c;
					}
					else {
						gdpRecord.Parent_Account_AIMS_ID__c = null;
					}
					
					gdpRecord.WebStar_ID__c = liveRecord.WebStar_ID__c + 'GDP';
					lstWebStar.add(gdpRecord);
					lstWebStarSFID.add(liveRecord.Id);
					lstWebStarIATACode.add(liveRecord.IATACode__c);
				}
				
				if (Test.isRunningTest()) throw new IECApplicationException('Test');
			}
			catch (Exception e) {
				logs.add(IECErrorLogger.logBatchError('Error processing records.', e.getMessage(), 'Live Account ID: ' + liveRecord.Id + ', IATA Code: ' + liveRecord.IATACode__c, 'GDP Replicate: Account', e.getStackTraceString()));
			}
		}

		// Process AIMS records
		try {
			if (!lstAIMS.isEmpty()) {
				List<Database.UpsertResult> lstResult = Database.upsert(lstAIMS, GDP_Products_Account_View__c.AIMS_ID__c, false);
				List<IEC_Error_Log__c> lstErrors = IECErrorLogger.captureDMLError(lstAIMS, lstResult, 'GDP Replicate: Account', new List<String> {'Live Account ID', 'IATA Code'}, new List<List<String>> {lstAIMSSFID, lstAIMSIATACode});
				if (lstErrors != null && lstErrors.size() > 0)
					logs.addAll(lstErrors);
			}
			
			if (Test.isRunningTest()) throw new IECApplicationException('Test');
		}
		catch (Exception e) {
			logs.add(IECErrorLogger.logBatchError('Could not upsert AIMS records.', e.getMessage(), null, 'GDP Replicate: Account', e.getStackTraceString()));
		}

		// Process WebStar records
		try {
			if (!lstWebStar.isEmpty()) {
				List<Database.UpsertResult> lstResult = Database.upsert(lstWebStar, GDP_Products_Account_View__c.WebStar_ID__c, false);
				
				List<IEC_Error_Log__c> lstErrors = IECErrorLogger.captureDMLError(lstWebStar, lstResult, 'GDP Replicate: Account', new List<String> {'Live Account ID', 'IATA Code'}, new List<List<String>> {lstWebStarSFID, lstWebStarIATACode});
				if (lstErrors != null && lstErrors.size() > 0)
					logs.addAll(lstErrors);
			}
			
			if (Test.isRunningTest()) throw new IECApplicationException('Test');
		}
		catch (Exception e) {
			logs.add(IECErrorLogger.logBatchError('Could not upsert WebStar records.', e.getMessage(), null, 'GDP Replicate: Account', e.getStackTraceString()));
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
	    	IECUtil.SetBatchReplication('GDP Replicate: Account', dtSystemNow);
	    	
	    	if (Test.isRunningTest()) throw new IECApplicationException('Test');
		}
		catch (Exception e) {
			logs.add(IECErrorLogger.logBatchError('Could not set Batch Replication last modified date.', e.getMessage(), null, 'GDP Replicate: Account', e.getStackTraceString()));
		}
	    
	    try {
	    	/**
	    	 * Call next batch step in the process
	    	 **/
			IEC_Batch_Replication__c btchRepAcc = IECUtil.GetBatchReplication('GDP Replicate: Account');
			IEC_Batch_Replication__c btchRep = IECUtil.GetBatchReplication('GDP Replicate: Account Category');
			
			// Only run the job if the schedule interface is activated through the custom settings
			if (IECConstants.GDPReplication_ScheduleActive) {
				BtchGDPReplicateAccountCategory btchProc = new BtchGDPReplicateAccountCategory();
				btchProc.idRecordTypeGDP = IECUtil.GetRecordTypeId('Account_Category__c', 'GDP');
				btchProc.dtSystemNow = btchRepAcc.Last_Modified_Date__c;
				btchProc.query =
					'SELECT AIMS_ID__c, WebStar_ID__c, Category_ID__c, Category_Code__c'
					+ '		, Related_Account__r.AIMS_ID__c, Related_Account__r.WebStar_ID__c, Related_Account__r.IATACode__c'
					+ '	FROM Account_Category__c'
					+ '	WHERE LastModifiedDate >= ' + btchRep.Last_Modified_Date__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')
					+ '		AND LastModifiedDate < ' + btchRepAcc.Last_Modified_Date__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')
					+ '		AND (AIMS_ID__c != null OR Webstar_ID__c != null)'
					+ '		AND RecordTypeId = \'' + IECUtil.GetRecordTypeId('Account_Category__c', 'Live') + '\''
					+ '		AND Related_Account__c IN (SELECT Id FROM Account WHERE Status__c IN (\'Terminated\',\'Not Accredited\',\'New application pending\',\'Not in Operation\',\'Listed\',\'Cash basis/No commission\',\'Cash basis/With commission\',\'Under review\',\'Changes processed\',\'Approved\') AND Main_Accreditation_Organization__c IN (\'IATA\',\'IATAN\',\'DOM\'))';
					
					// AND Related_Account__c IN (SELECT Related_Account__c FROM Accreditation__c WHERE Endorsed_Accredited_By_Formula__c IN ('IATA','IATAN') AND Class__r.Code__c IN ('C','D','E','F','G','K','M','N','O','P','S','T','V','X') AND Related_Account__r.Id != null)
				
				System.debug('SSS: SOQL Query: ' + btchProc.query);
	
				Database.executeBatch(btchProc);
			}
	    	
	    	if (Test.isRunningTest()) throw new IECApplicationException('Test');
		}
		catch (Exception e) {
			logs.add(IECErrorLogger.logBatchError('Could not start next batch process.', e.getMessage(), null, 'GDP Replicate: Account', e.getStackTraceString()));
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