global class AMS_2_MDM_Batch implements Database.Batchable<sObject>, Database.AllowsCallouts, Database.Stateful{
 
   global final String query;


    String[] r = new String[6];
    
    global AMS_2_MDM_Batch() {
    }

    global AMS_2_MDM_Batch(String pQuery) {
        query = pQuery;
    }
    
    global Database.QueryLocator start(Database.BatchableContext BC) {
        return Database.getQueryLocator(query);
    }

    global void execute(Database.BatchableContext BC, List<Agency_Applied_Change_code__c> scope) {

        //Initiate Log
        Technical_Logs__c tlog = new Technical_Logs__c();
        tlog.Status__c = 'Success';
        tlog.Operation__c = 'AMS 2 MDM - Sales Order';
        DateTime dtStart = system.now();
        tlog.start_date__c = dtStart;
        String sLog = '';
        String sLogRecord = '';
        
        //Call AW webservice with the XSD AgencyList use for each by group - one call WS by group
        Integer i = 0;
        List<String> ids = new List<String>();
        Boolean bFirst = True;
        String sCurrentGroupBy = '';
        String sCurrentIndicator = '';

        system.debug('AMS_2_MDM_Batch: 1 - entrei - ' + scope);

        //if(scope.size() > 0){
        //    Agency_Applied_Change_code__c agUpd = scope.get(0);

        //    ////By Country Iso code and record type (Passenger/Cargo)
        //    //List<AMS_Agency__c> ag = [select Country__r.ISO_Code__c, RecordType.name from AMS_Agency__c where id = :agUpd.Agency__c limit 1 ];
        //    //if(ag.size() > 0){
        //    //  sCurrentGroupBy = ag[0].Country__r.ISO_Code__c;
        //    //  sCurrentIndicator = ag[0].RecordType.name;
        //    //}

        //    //sLogRecord = sCurrentGroupBy + '-' + sCurrentIndicator;
        //    ////By Settlement
        //    ////List<AMS_Agency_Operations__c> agOp = [select Operation__r.Settlement__r.Name from AMS_Agency_Operations__c where Agency__c = :agUpd.Agency__c limit 1 ];
        //    ////if(agOp.size() > 0){
        //    ////  sCurrentGroupBy = agOp[0].Operation__r.Settlement__r.Name;
        //    ////}
        //}
        
        for(Agency_Applied_Change_code__c au :scope){
            //i++;
            //ids.add(au.Account__c);
            sLog += au.Account__r.IATACode__c + ',';
        }
       

        String[] headerParams = new String[5];
        headerParams[0] = ''; //'PreviousID'
        headerParams[1] = ''; //'GroupID'
        headerParams[2] = String.valueOf(AMS_SAP_Settings__c.getOrgDefaults().Batch_Size__c); //'ChunkSize'
        headerParams[3] = ''; //'ChunkKey'
        headerParams[4] = ''; //'ChunkTotal'

        AMS_XML_Generator xmlGen = new AMS_XML_Generator();
        //String s = xmlGen.getAgencySalesOrder(ids);
        String s = xmlGen.getAgencySalesOrder(scope);

        //Decomment if XML is necessary on the Log entry
        sLog += 'XML Sent: '+s+'\n';
        
        //Call WebService
        // instantiate the web service proxy
        //AMS_2_MDM_WS_AgencyList.HTTP_Port ws = new AMS_2_MDM_WS_AgencyList.HTTP_Port();
        AMS_2_MDM_WS_SalesOrder.HTTP_Port ws = new AMS_2_MDM_WS_SalesOrder.HTTP_Port();
        
        // set the credentials
        String sPwd = '';
        sPwd = Test.isRunningTest() ? '3ZNLPwqIDRC7auxG/fUWZ3VY5tdS7e+WUMECjAy4L54=' : AMS_SAP_Settings__c.getOrgDefaults().Web_Service_Password__c;
        
        Blob headerValue = Blob.valueOf(AMS_SAP_Settings__c.getOrgDefaults().Web_Service_Username__c + ':' + AMS_Utils.DecryptParameter(sPwd));
        String authorizationHeader = 'Basic '+ EncodingUtil.base64Encode(headerValue);

        
        // set the timeout to maximum value (60 seconds)
        ws.timeout_x = 60000;        

                    
        try {
            
            String sRespStatusCode = '';

            if(!Test.isRunningTest()) {
                // Call SAP web service
                //sRespStatusCode = ws.SI_SFDC_AgencyList_OB_Http(s,authorizationHeader);
                sRespStatusCode = ws.SI_SFDC_SalesOrder_OB_Http(s,authorizationHeader);
            }else{
                sRespStatusCode = '200';
            }
            
            sLog += 'Response Status Code: '+sRespStatusCode+'\n';
            

            if(sRespStatusCode.equalsIgnoreCase('200')){

                //for(AMS_Agency_Updates__c au :scope){
                //    au.Update_Type__c = au.Update_Type__c + '_Sent';
                //}
                for(Agency_Applied_Change_code__c au :scope){
                    au.Sent_to_external_system__c = true;
                }
                update scope;

            }else{
                system.debug('SAP Web Service - SI_SFDC_SalesOrder_OB - callout ERROR! ');
                
                tlog.Status__c = 'Error';
                //TODO implement error handling
            }

        }
        catch (Exception ex) {
            system.debug('SAP Web Service callout error: ' + ex.getMessage());
            
            sLog += 'Exception: SAP Web Service callout error:'+ex.getMessage()+'\n';
            sLog += 'Exception StackTrace: '+ex.getStackTraceString() +'\n';
            tlog.Status__c = 'Error';
            //TODO implement error handling
        }
        
        
        //write Log
        DateTime dtEnd = system.now();
        tlog.End_Date__c = dtEnd;
        tlog.Log__c = sLog;
        tlog.Record__c = sLogRecord;
        try {
            insert tlog;
        }catch (Exception ex) {
                system.debug('Log writing error: ' + ex.getMessage());
        }    
            
    }
    
    global void finish(Database.BatchableContext BC) {
        
        //CLEAN UPDATE TABLE
        //List<AMS_Agency_Updates__c> lAMS_Agency_Updates = [SELECT Agency__r.BSP_Code__c ,Agency__c,Id,Name,OwnerId,RelationShip__c,Update_Type__c FROM AMS_Agency_Updates__c
        //                where Update_Type__c like '%_Sent' and  LastModifiedDate < LAST_N_DAYS:2 Limit 8000]; 
                        
        //delete lAMS_Agency_Updates;                               
        
    }
    
}