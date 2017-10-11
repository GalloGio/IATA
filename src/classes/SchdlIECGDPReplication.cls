/**
  * Description: This class contains schedulable class for starting the GDP Replication process
  * Author: Samy Saied
  * Version: 1.0
  * History: 
  *   20160129-sl: move the batch call to other method.
  */
 
global class SchdlIECGDPReplication implements Schedulable {
	global void execute(SchedulableContext sc) {
		try {
			// Only run the job if the schedule interface is activated through the custom settings
			if (IECConstants.GDPReplication_ScheduleActive) {
				executeGdpReplicateAccountBatch();
			}
			
			// This section of code will schedule the next execution X hours from now depending on the configured setting
			datetime nextScheduleTime = system.now().addHours(IECConstants.GDPReplication_SchedulePeriod);
			string month = string.valueof(nextScheduleTime.month());
			string day = string.valueof(nextScheduleTime.day());
			string hour = string.valueof(nextScheduleTime.hour());
			string minute = string.valueof(nextScheduleTime.minute());
			string second = string.valueof(nextScheduleTime.second ());
			string cronvalue = second + ' ' + minute + ' ' + hour + ' ' + day + ' ' + month + ' ?';
			string jobName = 'SchdlIECGDPReplication ' + nextScheduleTime.format('yyyy-MM-dd HH:mm:ss');
			
			system.schedule(jobName, cronvalue , new SchdlIECGDPReplication());
			
			// this section of code will abort the current schedule job
			system.abortJob(sc.getTriggerId());
		}
		catch (Exception e) {
			IECErrorLogger.logError(null, 'Error while starting GDP Replication schedule.', e.getMessage(), null, 'GDP Replicate Schedule', e.getStackTraceString());
			throw e;
		}
	} // end of execute
	
	
	// ========================================================================
	// executeGdpReplicateAccountBatch()
	// this is made public to ease the call in testing
	public static void executeGdpReplicateAccountBatch()
	{
		IEC_Batch_Replication__c btchRep = IECUtil.GetBatchReplication('GDP Replicate: Account');
			
		BtchGDPReplicateAccount btchProc = new BtchGDPReplicateAccount();
		btchProc.idRecordTypeGDP = IECUtil.GetRecordTypeId('GDP_Products_Account_View__c', 'GDP');
		btchProc.query =
			'SELECT Short_Name__c, AIMS_ID__c, Webstar_ID__c, GDP_Location_Type__c, Airline_Code__c, Name, TradeName__c'
			+ '		, Email__c, Website, TTY__c, Passenger_And_Cargo__c, Incorporation_Type__c, GDP_Opt_In__c'
			+ '		, Tax_ID_1__c, Tax_ID_2__c, BSP_CASS_Code__c, License_Number__c, Preferred_Language__c'
			+ '		, CASS_Number_Xref__c, IATACode__c, CASS_Number__c, Ticketing_Agent_Last_Name__c'
			+ '		, Ticketing_Agent_First_Name__c, Manager_Last_Name__c, Manager_First_Name__c'
			+ '		, ParentId, Parent.AIMS_ID__c, Parent.Webstar_ID__c'
			+ '	FROM Account'
			+ '	WHERE LastModifiedDate >= ' + btchRep.Last_Modified_Date__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')
			+ '		AND IATACode__c != null'
			+ '		AND ((Is_AIMS_Account__c = true AND AIMS_ID__c != null) OR Webstar_ID__c != null)'
			+ '		AND Account.ID IN ('
			+ '			SELECT Related_Account__c'
			+ '			FROM Accreditation__c'
			+ '			WHERE Endorsed_Accredited_By_Formula__c IN (\'IATA\',\'IATAN\',\'DOM\')'
			+ '				AND Class__r.Code__c IN (\'C\',\'D\',\'E\',\'F\',\'G\',\'K\',\'M\',\'N\',\'O\',\'P\',\'S\',\'T\',\'V\',\'X\')'
			+ '				AND Related_Account__r.Id != null'
			+ '			)'
			+ '		AND RecordTypeId = \'' + IECUtil.GetRecordTypeId('Account', 'IATA_Agency') + '\'';
			
		Database.executeBatch(btchProc);
	} // executeGdpReplicateAccountBatch
	
} // end of SchdlIECGDPReplication class