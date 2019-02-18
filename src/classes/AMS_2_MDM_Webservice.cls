global class AMS_2_MDM_Webservice {

    global class AMSException extends Exception {}


    webservice static List<String> getUpdatedAgenciesList(String dpc,String operation){
        List<String> result = new List<String>();

        //List<AMS_Agency_Updates__c> agencyUpdates = [select Agency__c from AMS_Agency_Updates__c where Update_Type__c = 'Update' AND Agency__c != null]; - #AMSFTS
        List<AMS_Agency_Updates__c> agencyUpdates = [select Account__c from AMS_Agency_Updates__c where Update_Type__c in ('Update','Create','Delete') AND Account__c != null AND Integration_System__c = 'SAP PI'];
        
        for(AMS_Agency_Updates__c au :agencyUpdates){
            result.add(au.Account__c);
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
        /*** AMSU-158 ***/
        List<String> listOfErrors = new List<String>();
        
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

        //Pass Ids in the order that they were requested, in order to use later to return the data in the same order
        String sIds = '';
        for(Integer i=0;i<ids.size();i++){
            sIds += ids[i]+',';
        }
        r[5] = sIds.removeEnd(',');
        
        try{
            
            
            
            System.debug('Requested Agencies from MDM PI - ' + ids);
/*
            List<Account> ag = [SELECT Airline_Code__c,A_Code__c,
                    CASS_Number__c,Check_Digit__c,GDS__c,
                    BillingCity, BillingCountry, BillingPostalCode, BillingState, BillingStreet, Iso_State__c, 
                    ShippingCity, ShippingCountry, ShippingPostalCode, ShippingState, ShippingStreet,
                    Company_Type__c,C_Code__c,IATACode__c,Id,Location_Type__c,
                    Last_Inspection_Date__c,Last_synchronization__c,
                    License_Number__c,Location_Category__c,Location_Class__c,Name,GDP_Opt_In__c,
                    N_Code__c,Organization_Last_Change_Date__c,
                    Original_Approval_DAte__c,VAT_Number_2__c,OwnerId,
                    Phone_Number__c, Phone, Fax, Primary_address__c,
                    RecordTypeId,RecordType.name,
                    STD_Code__c,VAT_Number__c,
                    TradeName__c,Unique_ID__c,Verification_Date__c,IATA_ISO_Country__c, IATA_ISO_Country__r.Name,
                    Short_Name__c,Sector__c,AIMS_ID__c,BSP_CASS_Code__c,
                    Email__c,TTY__c,Website,Accreditation_date__c,
                    Abbreviated_name__c, Abbreviated_address__c,Status__c,
                    Top_Parent__c, Top_Parent__r.IATACode__c, Default_date__c
                    FROM Account where id in :ids
                    ORDER BY Location_Type__c DESC, IATA_ISO_Country__r.ISO_Code__c, Sector__c, Id, IATA_ISO_Country__r.IATA_Regional_Office__c];

*/
/**  NEWGEN-801 **/
            List<Account> ag = [SELECT Airline_Code__c,A_Code__c,
                    CASS_Number__c,Check_Digit__c,GDS__c,
                    BillingCity, BillingCountry, BillingPostalCode, BillingState, BillingStreet, Iso_State__c, 
                    ShippingCity, ShippingCountry, ShippingPostalCode, ShippingState, ShippingStreet,
                    Company_Type__c,C_Code__c,IATACode__c,Id,Location_Type__c,
                    Last_Inspection_Date__c,Last_synchronization__c,
                    License_Number__c,Location_Category__c,Location_Class__c,Name,GDP_Opt_In__c,
                    N_Code__c,Organization_Last_Change_Date__c,
                    Original_Approval_DAte__c,VAT_Number_2__c,OwnerId,
                    Phone_Number__c, Phone, Fax, Primary_address__c,
                    RecordTypeId,RecordType.name,
                    STD_Code__c,VAT_Number__c,
                    TradeName__c,Unique_ID__c,Verification_Date__c,IATA_ISO_Country__c, IATA_ISO_Country__r.Name,
                    Short_Name__c,Sector__c,AIMS_ID__c,BSP_CASS_Code__c,
                    Email__c,TTY__c,Website,Accreditation_date__c,
                    Abbreviated_name__c, Abbreviated_address__c,Status__c,
                    Top_Parent__c, Top_Parent__r.IATACode__c, Default_date__c, ANG_Accreditation_Model__c, Remittance_frequency__c,
                    ANG_RiskStatus__c, ANG_IEP_Status_FF__c,Segmentation__c,Purge_Flag__c,Is_Branch_Abroad__c, 
                    IATA_ISO_Country__r.BSP__c, IATA_ISO_Country__r.BSP_Country_free_text__c, Reason__c, //AMSU-158
					Expiry_Date__c //AMSU-207
                    FROM Account where id in :ids
                    ORDER BY Location_Type__c DESC, IATA_ISO_Country__r.ISO_Code__c, Sector__c, Id, IATA_ISO_Country__r.IATA_Regional_Office__c];

                    
 /* EOF NEWGEN-801 */
            AMS_XML_Generator xmlGen = new AMS_XML_Generator();
            Integer inicioCPU = Limits.getCpuTime();
            Integer inicioCPUx = Limits.getLimitCpuTime();
            
            String s = '';
            try{

                String accErrors = '';

                sLogRecord += ' - IATACodes: ';
                for(Account a : ag){

                    sLogRecord += a.IATACode__c + ',';

                    //Check if IATACODE exists! if not end with error
                    if(a.IATACode__c == Null){
                        accErrors += 'IATACode error - Agency needs to have an IATACode! Agency: '+a.Name+' ('+a.Id+')';
                    }

                    //Check billing address
                    if(AMS_Utils.isAddressEmpty(a, 'Billing')){
                        accErrors += '\nBilling address empty - Agency: '+a.Name+' ('+a.Id+')';
                    }
                }
                sLogRecord = sLogRecord.removeEnd(',');
                System.debug(loggingLevel.Debug, '____ [cls AMS_2_MDM_Webservice - sendAgenciesContent] accErrors - ' + accErrors);
                if(String.isNotEmpty(accErrors)) throw new AMSException('The following accounts have no Billing/Primary Address:'+accErrors);


                //s = xmlGen.getAgencyDetail(ag, r); - #AMSFTS
                s = xmlGen.getAgencyDetail(ag, r, 'Master','');
                
                //Decomment if XML is necessary on the Log entry
                sLog += 'XML Sent: '+s+'\n';
                
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

            
                        
            try {
                
                String sRespStatusCode = '';

                if(!Test.isRunningTest()) {
                    // Call SAP web service
                    sRespStatusCode = ws.SI_SFDC_AgenciesData_OB_Http(s,authorizationHeader);
                }else{
                    if(GroupID.equalsIgnoreCase('exception')){
                        String a;
                        String b = a;
                    }else if(GroupID.equalsIgnoreCase('error')){
                        sRespStatusCode = '503';
                    }else{
                        sRespStatusCode = '200';    
                    }
                }
                
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

        /*** AMSU-158 ***/
        try {
            if(listOfErrors != null && !listOfErrors.isEmpty()) {
            	sendCSVReport(listOfErrors);
            }
        } catch(Exception ex) {
            System.debug('Error sending report: ' + ex.getMessage());
        }
    }

    /*** AMSU-158 ***/
    public static void sendCSVReport(List<String> listOfErrors) {
        String body = 'Account Id, Reason';
        
        for(String error : listOfErrors) {
            body += error + '\n';
        }

        Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
        message.subject = 'XML Generator report - ' + listOfErrors.size() + ' errors';
        message.setPlainTextBody('XML Generator errors - Check attachment with execution results - ' + DateTime.now());

        if(!listOfErrors.isEmpty()) {
            Messaging.EmailFileAttachment csvAttc = new Messaging.EmailFileAttachment();
            Blob csvReport = Blob.valueOf(body);
            csvAttc.setFileName('XML Generator errors report.csv');
            csvAttc.setBody(csvReport);
            message.setFileAttachments(new Messaging.EmailFileAttachment[]{csvAttc});
        }        
        
        Messaging.SingleEmailMessage[] messages =  new List<Messaging.SingleEmailMessage> {message};

        if(!Test.isRunningTest() && !String.isBlank(Label.AMS_XML_GEN_ERROR_RECEIVER)) {
            List<String> emailAddresses = Label.AMS_XML_GEN_ERROR_RECEIVER.split(';');
            message.setToaddresses(emailAddresses);
            Messaging.sendEmail(messages);
        }
    }
    
   
    webservice static String sendAgencyECC(Id agencyId, Id oscarId){    

        //Check's if the Integration Channel to SAP is active or inactive, in case of inactive there's no attempt of communication and an error is return informing that the channel is inactive!
        if(AMS_SAP_Settings__c.getOrgDefaults().Active__c == False){
            return 'Integration Channel to SAP is inactive!';
        }


        //Initiate Log
        Technical_Logs__c tlog = new Technical_Logs__c();
        tlog.Status__c = 'Success';
        tlog.Operation__c = 'AMS 2 MDM - ECC';
        DateTime dtStart = system.now();
        tlog.start_date__c = dtStart;
        String sLog = '';
        String sLogRecord = agencyId;
        
        Boolean bError = False;
        String sError = 'OK';
        
        String[] r = new String[6];
        r[0]='SAP';
        r[1]='1';
        r[2]='1';
        r[3]='1';
        r[4]='true';
        r[5]=agencyId;
        
        try{
/*            
            Account ag = [SELECT Airline_Code__c,A_Code__c,
                    CASS_Number__c,Check_Digit__c,GDS__c,
                    BillingCity, BillingCountry, BillingPostalCode, BillingState, BillingStreet, Iso_State__c, 
                    ShippingCity, ShippingCountry, ShippingPostalCode, ShippingState, ShippingStreet,
                    Company_Type__c,C_Code__c,IATACode__c,Id,Location_Type__c,
                    Last_Inspection_Date__c,Last_synchronization__c,
                    License_Number__c,Location_Category__c,Location_Class__c,Name,GDP_Opt_In__c,
                    N_Code__c,Organization_Last_Change_Date__c,
                    Original_Approval_DAte__c,VAT_Number_2__c,OwnerId,
                    Phone_Number__c, Phone, Fax, Primary_address__c,
                    RecordTypeId,RecordType.name,
                    STD_Code__c,VAT_Number__c,
                    TradeName__c,Unique_ID__c,Verification_Date__c,IATA_ISO_Country__c, IATA_ISO_Country__r.Name,
                    Short_Name__c,Sector__c,AIMS_ID__c,BSP_CASS_Code__c,
                    Email__c,TTY__c,Website,Accreditation_date__c,
                    IATA_ISO_Country__r.Region__c,
                    Abbreviated_name__c, Abbreviated_address__c,Status__c,
                    Top_Parent__c, Top_Parent__r.IATACode__c, Default_date__c
                    FROM Account where id = :agencyId];
         */   
 /* NEWGEN-801 */

             Account ag = [SELECT Airline_Code__c,A_Code__c,
                    CASS_Number__c,Check_Digit__c,GDS__c,
                    BillingCity, BillingCountry, BillingPostalCode, BillingState, BillingStreet, Iso_State__c, 
                    ShippingCity, ShippingCountry, ShippingPostalCode, ShippingState, ShippingStreet,
                    Company_Type__c,C_Code__c,IATACode__c,Id,Location_Type__c,
                    Last_Inspection_Date__c,Last_synchronization__c,
                    License_Number__c,Location_Category__c,Location_Class__c,Name,GDP_Opt_In__c,
                    N_Code__c,Organization_Last_Change_Date__c,
                    Original_Approval_DAte__c,VAT_Number_2__c,OwnerId,
                    Phone_Number__c, Phone, Fax, Primary_address__c,
                    RecordTypeId,RecordType.name,
                    STD_Code__c,VAT_Number__c,
                    TradeName__c,Unique_ID__c,Verification_Date__c,IATA_ISO_Country__c, IATA_ISO_Country__r.Name,
                    Short_Name__c,Sector__c,AIMS_ID__c,BSP_CASS_Code__c,
                    Email__c,TTY__c,Website,Accreditation_date__c,
                    IATA_ISO_Country__r.Region__c,
                    Abbreviated_name__c, Abbreviated_address__c,Status__c,
                    Top_Parent__c, Top_Parent__r.IATACode__c, Default_date__c,
                    ANG_Accreditation_Model__c, Remittance_frequency__c,
                    ANG_RiskStatus__c, ANG_IEP_Status_FF__c,Segmentation__c,Purge_Flag__c,Is_Branch_Abroad__c,
                    IATA_ISO_Country__r.BSP__c, IATA_ISO_Country__r.BSP_Country_free_text__c, Reason__c, //AMSU-158
                    Expiry_Date__c //AMSU-207
                    FROM Account where id = :agencyId];

/* EOF NEWGEN-801 */

            sLogRecord += ' - IATACodes: ' + ag.IATACode__c;
                
            //Check if IATACODE exists! if not end with error
            if(ag.IATACode__c == Null){
                sError = 'IATACode error - Agency needs to have an IATACode!';
            }

            if(AMS_Utils.isAddressEmpty(ag, 'Billing')){
                sError = (sError == 'OK' ? '' : sError+'\n')+'Agency needs to have a Billing Address';
            }

            
            if(sError != 'OK') return sError;

            AMS_XML_Generator xmlGen = new AMS_XML_Generator();
            
            String s = '';
            try{
            
                //s = xmlGen.getAgencyDetail(ag, r); //- #AMSFTS
                s = xmlGen.getAgencyDetail(ag, r, 'ECC', String.valueOf(oscarId));

                //Decomment if XML is necessary on the Log entry
                sLog += 'XML Sent: '+s+'\n';
                
            }catch (Exception ex) {
                system.debug('sendAgencyECC - XML Generator error: ' + ex.getMessage());
                bError = True;
                sError = 'XML Generator error: ' + ex.getMessage();

                sLog += 'XML Generator error: ' + ex.getMessage() +'\n';
                sLog += 'Exception StackTrace: '+ex.getStackTraceString() +'\n';
                    
                tlog.Status__c = 'Error';
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

                try {
                    
                    String sRespStatusCode = '';
    
                    
                    if(!Test.isRunningTest()) {
                        // Call SAP web service
                        sRespStatusCode = ws.SI_SFDC_AgenciesData_OB_Http(s,authorizationHeader);
                    }else{
                        if(ag.IATACode__c.equalsIgnoreCase('1000503')){
                            String a;
                            String b = a;
                        }else if(ag.IATACode__c.equalsIgnoreCase('1000404')){
                            sRespStatusCode = '404';
                        }else{
                            sRespStatusCode = '200';    
                        }
                    }
                    
                    sLog += 'Response Status Code: '+sRespStatusCode+'\n';

                    if(!sRespStatusCode.equalsIgnoreCase('200')){
    
                        system.debug('SAP Web Service - SI_SFDC_AgenciesData_OB_OB - callout ERROR! ');
                        bError = True;
                        sError = 'SAP Web Service - SI_SFDC_AgenciesData_OB_OB - callout ERROR! ';

                        tlog.Status__c = 'Error';
    
                    }else{
                        system.debug('sendAgencyECC - SAP Web Service callout Resp Status Code: ' + sRespStatusCode);
                    }
                }
                catch (Exception ex) {
                    system.debug('sendAgencyECC - SAP Web Service callout error: ' + ex.getMessage());
                    bError = True;
                    sError = 'SAP Web Service callout error: ' + ex.getMessage();


                    sLog += 'Exception: general error:'+ex.getMessage()+'\n';
                    sLog += 'Exception StackTrace: '+ex.getStackTraceString() +'\n';
                        
                    tlog.Status__c = 'Error';
                }
            }
        }catch(Exception e){
            system.debug('sendAgencyECC - Exception error: ' + e.getMessage());
            bError = True;
            sError = 'Exception error: ' + e.getMessage();

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

        return sError;
    }
 

}