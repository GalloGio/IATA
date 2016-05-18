global class AMS_2_MDM_Webservice {

    webservice static List<String> getUpdatedHierarchiesList(String dpc,String operation){
        List<String> result = new List<String>();

        List<AMS_Agencies_relationhip__c> agenciesRel = [select Hierarchy__c from AMS_Agencies_relationhip__c where id in (select RelationShip__c from AMS_Agency_Updates__c where Update_Type__c = 'Update' AND RelationShip__c != null)];
        for(AMS_Agencies_relationhip__c ar :agenciesRel){
            result.add(ar.Hierarchy__c);
        }

        return result;
    }

    webservice static List<String> getUpdatedAgenciesList(String dpc,String operation){
        List<String> result = new List<String>();

        List<AMS_Agency_Updates__c> agencyUpdates = [select Agency__c from AMS_Agency_Updates__c where Update_Type__c = 'Update' AND Agency__c != null];
        for(AMS_Agency_Updates__c au :agencyUpdates){
            result.add(au.Agency__c);
        }

        return result;
    }
    
    
    //webservice static String[] getAgenciesContent(String GroupID, String ChunkSize , String ChunkKey, String ChunkTotal, List<String> ids){
    webservice static String[] getAgenciesContent(String GroupID, String ChunkSize , String ChunkKey, String ChunkTotal, List<String> ids){
        
        sendAgenciesContent(GroupID, ChunkSize, ChunkKey, ChunkTotal, ids);
        
        String[] r = new String[6];
        r[0]=GroupID;
        r[1]=ChunkSize;
        r[2]=ChunkKey;
        r[3]=ChunkTotal;
        r[4]='TRUE';
        r[5]= '';
      
        return r;
       
    }
    
    @future(callout=true)
    static void sendAgenciesContent(String GroupID, String ChunkSize , String ChunkKey, String ChunkTotal, List<String> ids){
        
        //Initiate Log
        Technical_Logs__c tlog = new Technical_Logs__c();
        tlog.Status__c = 'Success';
        tlog.Operation__c = 'AMS 2 MDM - AgencyDetails';
        DateTime dtStart = system.now();
        tlog.start_date__c = dtStart;
        String sLog = '';
        String sLogRecord = GroupID + '-' + ids;
        
        String[] r = new String[6];
        r[0]=GroupID;
        r[1]=ChunkSize;
        r[2]=ChunkKey;
        r[3]=ChunkTotal;
        r[4]='true';
        
        try{
            
            
            
            System.debug('Requested Agencies from MDM PI - ' + ids);
            
            List<AMS_Agency__c> ag = [SELECT Account__c,Administrator__c,Airline_Code__c,
                        A_Code__c,BSP_Code__c,CASS_Number__c,Chk_Dgt__c,GDS__c,
                        Company_Type__c,C_Code__c,DPC_Operation__c,IATACode__c,Id,
                        Last_Inspection_Date__c,Last_synchronization__c,Legacy_External_ID__c,
                        Legacy_System__c,Legal_Name_2__c,Legal_Name_3__c,License_Number__c,
                        Location_Category__c,Location_Class__c,Name,Solicitation_Flag__c,
                        N_Code__c,Organization_Last_Change_Date__c,
                        Original_Approval_DAte__c,Other_Tax_Reference_Number__c,OwnerId,
                        Parent_Reference_Number__c,Phone_Number__c,Primary_address__c,
                        Qualified_ticketing_agent__c,Recert_Expiry_Date__c,RecordTypeId,RecordType.name,
                        Reference_Number__c,STD_Code__c,SystemModstamp,Tax_Reference_Number__c,
                        Trading_Name_1__c,Trading_Name_2__c,Unique_ID__c,Verification_Date__c,
                        Site_Type__c,Country__c, Abbreviated_name__c
                        FROM AMS_Agency__c where id in :ids];
 

            AMS_XML_Generator xmlGen = new AMS_XML_Generator();
            Integer inicioCPU = Limits.getCpuTime();
            Integer inicioCPUx = Limits.getLimitCpuTime();
            
            String s = '';
            try{
            
                s = xmlGen.getAgencyDetail(ag, r);
                
                //Decomment if XML is necessary on the Log entry
                //sLog += 'XML Sent: '+s+'\n';
                
            }catch (Exception ex) {
                
                s = xmlGen.getErrorMessage(ids, r);
                
                sLog += 'Exception: '+ex.getMessage()+'\n';
                sLog += 'Exception StackTrace: '+ex.getStackTraceString() +'\n';
                sLog += 'Error XML Sent: '+s+'\n';
                tlog.Status__c = 'Error';
                
            }
            
            //String s2 = xmlGen.getAgencyHierarchy(ag, r);
            Integer fimCPU = Limits.getCpuTime();
            Integer fimCPUx = Limits.getLimitCpuTime();
            
            System.debug('WS inicioCPU:' + inicioCPU);
            System.debug('WS fimCPU:' + fimCPU);
            System.debug('WS inicioCPUx:' + inicioCPUx);
            System.debug('WS fimCPUx:' + fimCPUx);
            
            r[5] = s;

            //Call WebService
        // instantiate the web service proxy
        AMS_2_MDM_WS_AgencyDetails.HTTP_Port ws = new AMS_2_MDM_WS_AgencyDetails.HTTP_Port();
        
        // set the credentials
        String sPwd = '';
        sPwd = Test.isRunningTest() ? '3ZNLPwqIDRC7auxG/fUWZ3VY5tdS7e+WUMECjAy4L54=' : AMS_SAP_Settings__c.getOrgDefaults().Web_Service_Password__c;
        
        Blob headerValue = Blob.valueOf(AMS_SAP_Settings__c.getOrgDefaults().Web_Service_Username__c + ':' + AMS_Utils.DecryptParameter(sPwd));
        String authorizationHeader = 'Basic '+ EncodingUtil.base64Encode(headerValue);

        
        // set the timeout to maximum value (60 seconds)
        ws.timeout_x = 60000;        

        if(!Test.isRunningTest()) {
                    
            try {
                
                String sRespStatusCode = '';

                // Call SAP web service
                sRespStatusCode = ws.SI_SFDC_AgenciesData_OB_Http(s,authorizationHeader);
                
                sLog += 'Response Status Code: '+sRespStatusCode+'\n';
                
                if(!sRespStatusCode.equalsIgnoreCase('200')){

                    system.debug('SAP Web Service - SI_SFDC_AgenciesData_OB_OB - callout ERROR! ');
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
        }

        }catch(Exception e){
            sLog += 'Exception: general error:'+e.getMessage()+'\n';
            sLog += 'Exception StackTrace: '+e.getStackTraceString() +'\n';
                
            tlog.Status__c = 'Error';
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
    
        
    webservice static Boolean sendAgencyECC(Id agencyId){

        //Initiate Log
        Technical_Logs__c tlog = new Technical_Logs__c();
        tlog.Status__c = 'Success';
        tlog.Operation__c = 'AMS 2 MDM - ECC';
        DateTime dtStart = system.now();
        tlog.start_date__c = dtStart;
        String sLog = '';
        String sLogRecord = agencyId;
        
        Boolean bError = False;
        
        String[] r = new String[6];
        r[0]='SAP';
        r[1]='1';
        r[2]='1';
        r[3]='1';
        r[4]='true';
        
        try{
            
            AMS_Agency__c ag = [SELECT Account__c,Administrator__c,Airline_Code__c,
                        A_Code__c,BSP_Code__c,CASS_Number__c,Chk_Dgt__c,GDS__c,
                        Company_Type__c,C_Code__c,DPC_Operation__c,IATACode__c,Id,
                        Last_Inspection_Date__c,Last_synchronization__c,Legacy_External_ID__c,
                        Legacy_System__c,Legal_Name_2__c,Legal_Name_3__c,License_Number__c,
                        Location_Category__c,Location_Class__c,Name,Solicitation_Flag__c,
                        N_Code__c,Organization_Last_Change_Date__c,
                        Original_Approval_DAte__c,Other_Tax_Reference_Number__c,OwnerId,
                        Parent_Reference_Number__c,Phone_Number__c,Primary_address__c,
                        Qualified_ticketing_agent__c,Recert_Expiry_Date__c,RecordTypeId,RecordType.name,
                        Reference_Number__c,STD_Code__c,SystemModstamp,Tax_Reference_Number__c,
                        Trading_Name_1__c,Trading_Name_2__c,Unique_ID__c,Verification_Date__c,
                        Site_Type__c, Country__r.Region__c, Country__c, Abbreviated_name__c
                        FROM AMS_Agency__c where id = :agencyId];
 

            AMS_XML_Generator xmlGen = new AMS_XML_Generator();
            
            String s = '';
            try{
            
                s = xmlGen.getAgencyDetail(ag, r);

                //Decomment if XML is necessary on the Log entry
                //sLog += 'XML Sent: '+s+'\n';
                
            }catch (Exception ex) {
                system.debug('sendAgencyECC - XML Generator error: ' + ex.getMessage());
                bError = True;
            }
            
            r[5] = s;
            
            if(!bError){
            
                //Call WebService
                // instantiate the web service proxy
                AMS_2_MDM_WS_AgencyDetails.HTTP_Port ws = new AMS_2_MDM_WS_AgencyDetails.HTTP_Port();
                
                // set the credentials
                String sPwd = '';
                sPwd = Test.isRunningTest() ? '3ZNLPwqIDRC7auxG/fUWZ3VY5tdS7e+WUMECjAy4L54=' : AMS_SAP_Settings__c.getOrgDefaults().Web_Service_Password__c;
        
                Blob headerValue = Blob.valueOf(AMS_SAP_Settings__c.getOrgDefaults().Web_Service_Username__c + ':' + AMS_Utils.DecryptParameter(sPwd));
                String authorizationHeader = 'Basic '+ EncodingUtil.base64Encode(headerValue);
        
                
                // set the timeout to maximum value (60 seconds)
                ws.timeout_x = 60000;        

                if(!Test.isRunningTest()) {
                            
                    try {
                        
                        String sRespStatusCode = '';
        
                        // Call SAP web service
                        sRespStatusCode = ws.SI_SFDC_AgenciesData_OB_Http(s,authorizationHeader);
                        
                        sLog += 'Response Status Code: '+sRespStatusCode+'\n';

                        if(!sRespStatusCode.equalsIgnoreCase('200')){
        
                            system.debug('SAP Web Service - SI_SFDC_AgenciesData_OB_OB - callout ERROR! ');
                            bError = True;

                            tlog.Status__c = 'Error';
        
                        }else{
                            system.debug('sendAgencyECC - SAP Web Service callout Resp Status Code: ' + sRespStatusCode);
                        }
                    }
                    catch (Exception ex) {
                        system.debug('sendAgencyECC - SAP Web Service callout error: ' + ex.getMessage());
                        bError = True;

                        sLog += 'Exception: general error:'+ex.getMessage()+'\n';
                        sLog += 'Exception StackTrace: '+ex.getStackTraceString() +'\n';
                            
                        tlog.Status__c = 'Error';
                    }
                }
            }
        }catch(Exception e){
            system.debug('sendAgencyECC - Exception error: ' + e.getMessage());
            bError = True;

            sLog += 'Exception: general error:'+e.getMessage()+'\n';
            sLog += 'Exception StackTrace: '+e.getStackTraceString() +'\n';
                
            tlog.Status__c = 'Error';
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

        return bError;
    }
 
    
/*
    webservice static Boolean sendAgencySalesOrder(Id agencyId){

        //Initiate Log
        Technical_Logs__c tlog = new Technical_Logs__c();
        tlog.Status__c = 'Success';
        tlog.Operation__c = 'AMS 2 MDM - SalesOrder';
        DateTime dtStart = system.now();
        tlog.start_date__c = dtStart;
        String sLog = '';
        String sLogRecord = agencyId;
        
        Boolean bError = False;
        
        String[] r = new String[6];
        r[0]='SAP';
        r[1]='1';
        r[2]='1';
        r[3]='1';
        r[4]='true';
        
        try{
            
            AMS_Agency__c ag = [SELECT Account__c,Administrator__c,Airline_Code__c,
                        A_Code__c,BSP_Code__c,CASS_Number__c,Chk_Dgt__c,GDS__c,
                        Company_Type__c,C_Code__c,DPC_Operation__c,IATACode__c,Id,
                        Last_Inspection_Date__c,Last_synchronization__c,Legacy_External_ID__c,
                        Legacy_System__c,Legal_Name_2__c,Legal_Name_3__c,License_Number__c,
                        Location_Category__c,Location_Class__c,Name,Solicitation_Flag__c,
                        N_Code__c,Organization_Last_Change_Date__c,
                        Original_Approval_DAte__c,Other_Tax_Reference_Number__c,OwnerId,
                        Parent_Reference_Number__c,Phone_Number__c,Primary_address__c,
                        Qualified_ticketing_agent__c,Recert_Expiry_Date__c,RecordTypeId,RecordType.name,
                        Reference_Number__c,STD_Code__c,SystemModstamp,Tax_Reference_Number__c,
                        Trading_Name_1__c,Trading_Name_2__c,Unique_ID__c,Verification_Date__c,
                        Site_Type__c, Country__c, Abbreviated_name__c,
                        Country__r.IATA_Regional_Office__c
                        FROM AMS_Agency__c where id = :agencyId];
 

            AMS_XML_Generator xmlGen = new AMS_XML_Generator();
            
            String s = '';
            try{
            
                s = xmlGen.getAgencySalesOrder(ag);

                sLog += 'XML Sent: '+s+'\n';
                
            }catch (Exception ex) {
                system.debug('sendAgencySalesOrder - XML Generator error: ' + ex.getMessage());
                bError = True;
            }
            
            r[5] = s;
            
            if(!bError){
            
                //Call WebService
                // instantiate the web service proxy
                AMS_2_MDM_WS_SalesOrder.HTTP_Port ws = new AMS_2_MDM_WS_SalesOrder.HTTP_Port();
                
                // set the credentials
                String sPwd = '';
                sPwd = Test.isRunningTest() ? '3ZNLPwqIDRC7auxG/fUWZ3VY5tdS7e+WUMECjAy4L54=' : AMS_SAP_Settings__c.getOrgDefaults().Web_Service_Password__c;
        
                Blob headerValue = Blob.valueOf(AMS_SAP_Settings__c.getOrgDefaults().Web_Service_Username__c + ':' + AMS_Utils.DecryptParameter(sPwd));
                String authorizationHeader = 'Basic '+ EncodingUtil.base64Encode(headerValue);
        
                
                // set the timeout to maximum value (60 seconds)
                ws.timeout_x = 60000;        

                if(!Test.isRunningTest()) {
                            
                    try {
                        
                        String sRespStatusCode = '';
        
                        // Call SAP web service
                        sRespStatusCode = ws.SI_SFDC_SalesOrder_OB_Http(s,authorizationHeader);
                        
                        sLog += 'Response Status Code: '+sRespStatusCode+'\n';

                        if(!sRespStatusCode.equalsIgnoreCase('200')){
        
                            system.debug('SAP Web Service - SI_SFDC_AgenciesData_OB_OB - callout ERROR! ');

                            bError = True;

                            tlog.Status__c = 'Error';
        
                        }else{
                            system.debug('sendAgencySalesOrder - SAP Web Service callout Resp Status Code: ' + sRespStatusCode);
                        }
                    }
                    catch (Exception ex) {
                        system.debug('sendAgencySalesOrder - SAP Web Service callout error: ' + ex.getMessage());
                        bError = True;

                        sLog += 'Exception: general error:'+ex.getMessage()+'\n';
                        sLog += 'Exception StackTrace: '+ex.getStackTraceString() +'\n';
                            
                        tlog.Status__c = 'Error';
                    }
                }
            }
        }catch(Exception e){
            system.debug('sendAgencySalesOrder - Exception error: ' + e.getMessage());
            bError = True;

            sLog += 'Exception: general error:'+e.getMessage()+'\n';
            sLog += 'Exception StackTrace: '+e.getStackTraceString() +'\n';
                
            tlog.Status__c = 'Error';
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

        return bError;
    }
*/ 
}