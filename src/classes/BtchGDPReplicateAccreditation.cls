/**  
  * Description: This class contains batchable class for GDP Replication - Accreditation
  * Author: Samy Saied
  * Version: 1.0
  * History: 
  */
  
global class BtchGDPReplicateAccreditation implements Database.Batchable<sObject>, Database.Stateful {
    global List<IEC_Error_Log__c> logs;

    public String query;
    public Id idRecordTypeGDP;
    public DateTime dtSystemNow;
    private Boolean bErrorFound;
    
    // Initialize error log
    global BtchGDPReplicateAccreditation () {
        logs = new List<IEC_Error_Log__c>();
    }

    global Database.querylocator start(Database.BatchableContext BC){
        bErrorFound = false;
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<sObject> scope){
        List<Accreditation__c> lstAIMS = new List<Accreditation__c>();
        List<Accreditation__c> lstWebStar = new List<Accreditation__c>();
        List<String> lstAIMSIATACode = new List<String>();
        List<String> lstWebStarIATACode = new List<String>();
        List<Id> lstAIMSSFID = new List<Id>();
        List<Id> lstWebStarSFID = new List<Id>();

        for(sObject s : scope) {
            Accreditation__c liveRecord = (Accreditation__c) s;
            try {
                Accreditation__c gdpRecord = new Accreditation__c ();
                gdpRecord.RecordTypeId = idRecordTypeGDP;

                /**
                 * Direct Mapping
                 **/
                gdpRecord.Accreditation_ID__c = liveRecord.Accreditation_ID__c;
                gdpRecord.Class__c = liveRecord.Class__c;
                // gdpRecord.Endorsed_Accredited_By_Formula__c = liveRecord.Endorsed_Accredited_By_Formula__c;
                gdpRecord.Last_change_date__c = liveRecord.Last_change_date__c;
                gdpRecord.Last_re_inspection_date__c = liveRecord.Last_re_inspection_date__c;
                gdpRecord.Original_approval_date__c = liveRecord.Original_approval_date__c;
                gdpRecord.Status__c = liveRecord.Status__c;
                gdpRecord.Date__c = liveRecord.Date__c;

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
                logs.add(IECErrorLogger.logBatchError('Error processing records.', e.getMessage(), 'Live Accreditation ID: ' + liveRecord.Id + ', IATA Code: ' + liveRecord.Related_Account__r.IATACode__c, 'GDP Replicate: Accreditation', e.getStackTraceString()));
            }
        }

        // Process AIMS records
        try {
            if (!lstAIMS.isEmpty()) {
                List<Database.UpsertResult> lstResult = Database.upsert(lstAIMS, Accreditation__c.AIMS_ID__c, false);
                List<IEC_Error_Log__c> lstErrors = IECErrorLogger.captureDMLError(lstAIMS, lstResult, 'GDP Replicate: Accreditation', new List<String> {'Live Accreditation ID', 'IATA Code'}, new List<List<String>> {lstAIMSSFID, lstAIMSIATACode});
                if (lstErrors != null && lstErrors.size() > 0)
                    logs.addAll(lstErrors);
            }
            
            if (Test.isRunningTest()) throw new IECApplicationException('Test');
        }
        catch (Exception e) {
            logs.add(IECErrorLogger.logBatchError('Could not upsert AIMS records.', e.getMessage(), null, 'GDP Replicate: Accreditation', e.getStackTraceString()));
        }

        // Process WebStar records
        try {
            if (!lstWebStar.isEmpty()) {
                List<Database.UpsertResult> lstResult = Database.upsert(lstWebStar, Accreditation__c.WebStar_ID__c, false);
                
                List<IEC_Error_Log__c> lstErrors = IECErrorLogger.captureDMLError(lstWebStar, lstResult, 'GDP Replicate: Accreditation', new List<String> {'Live Accreditation ID', 'IATA Code'}, new List<List<String>> {lstWebStarSFID, lstWebStarIATACode});
                if (lstErrors != null && lstErrors.size() > 0)
                    logs.addAll(lstErrors);
            }
            
            if (Test.isRunningTest()) throw new IECApplicationException('Test');
        }
        catch (Exception e) {
            logs.add(IECErrorLogger.logBatchError('Could not upsert WebStar records.', e.getMessage(), null, 'GDP Replicate: Accreditation', e.getStackTraceString()));
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
            IECUtil.SetBatchReplication('GDP Replicate: Accreditation', dtSystemNow);
            
            if (Test.isRunningTest()) throw new IECApplicationException('Test');
        }
        catch (Exception e) {
            logs.add(IECErrorLogger.logBatchError('Could not set Batch Replication last modified date.', e.getMessage(), null, 'GDP Replicate: Accreditation', e.getStackTraceString()));
        }
        
        try {
            /**
             * Call next batch step in the process
             **/
            IEC_Batch_Replication__c btchRepAcc = IECUtil.GetBatchReplication('GDP Replicate: Account');
            IEC_Batch_Replication__c btchRep = IECUtil.GetBatchReplication('GDP Replicate: Adjacent Airport');
            
            // Only run the job if the schedule interface is activated through the custom settings
            if (IECConstants.GDPReplication_ScheduleActive) {
                BtchGDPReplicateAdjacentAirports btchProc = new BtchGDPReplicateAdjacentAirports();
                btchProc.idRecordTypeGDP = IECUtil.GetRecordTypeId('Adjacent_Airport__c', 'GDP');
                btchProc.dtSystemNow = btchRepAcc.Last_Modified_Date__c;
                btchProc.query =
                    'SELECT AIMS_ID__c, WebStar_ID__c, Airport_ID__c, AirportCode__c'
                    + '     , Related_Account__r.AIMS_ID__c, Related_Account__r.WebStar_ID__c, Related_Account__r.IATACode__c'
                    + ' FROM Adjacent_Airport__c'
                    + ' WHERE LastModifiedDate >= ' + btchRep.Last_Modified_Date__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')
                    + '     AND LastModifiedDate < ' + btchRepAcc.Last_Modified_Date__c.formatGMT('yyyy-MM-dd\'T\'HH:mm:ss\'Z\'')
                    + '     AND (AIMS_ID__c != null OR Webstar_ID__c != null)'
                    + '     AND RecordTypeId = \'' + IECUtil.GetRecordTypeId('Adjacent_Airport__c', 'Live') + '\''
                    + '     AND Related_Account__c IN (SELECT Id FROM Account WHERE Location_Class__c IN (\'C\',\'D\',\'E\',\'F\',\'G\',\'K\',\'M\',\'N\',\'O\',\'P\',\'S\',\'T\',\'V\',\'X\') AND Main_Accreditation_Organization__c IN (\'IATA\',\'IATAN\',\'DOM\'))';                   
                
                System.debug('SSS: SOQL Query: ' + btchProc.query);
    
                Database.executeBatch(btchProc);
            }
            
            if (Test.isRunningTest()) throw new IECApplicationException('Test');
        }
        catch (Exception e) {
            logs.add(IECErrorLogger.logBatchError('Could not start next batch process.', e.getMessage(), null, 'GDP Replicate: Accreditation', e.getStackTraceString()));
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