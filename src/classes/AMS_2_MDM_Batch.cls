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
        Set<String> countryIsoCodes = new Set<String>();
        Boolean bFirst = True;
        String sCurrentGroupBy = '';
        String sCurrentIndicator = '';

        system.debug('AMS_2_MDM_Batch: 1 - entrei - ' + scope);

        SET<Id> setAccountKeys = new SET<Id>();
        List<Account> lstAccount = new List<Account>();
        Map<ID, Account> mAccountData = new Map<ID, Account>();
        List<Agency_Applied_Change_code__c> scopeValidBillable = new List<Agency_Applied_Change_code__c>(); 
        Map<String,AMS_ChangeCodes__c> mapChangeCodes = new Map<String,AMS_ChangeCodes__c>();
        List<AMS_ChangeCodes__c> lBillableChangeCodes = [SELECT Change_Code__c, Billable_Location_Class__c FROM AMS_ChangeCodes__c where Billable__c = true];

        system.debug('AMS_2_MDM_Batch: lBillableChangeCodes - ' + lBillableChangeCodes);

        //Fetch agency data that's not comming in the "scope"
        for(Sobject au :scope){
            Agency_Applied_Change_code__c aacc = (Agency_Applied_Change_code__c)au;
            setAccountKeys.add(aacc.Account__c); 
            countryIsoCodes.add(aacc.Account__r.IATA_ISO_Country__r.Iso_code__c);
        }

        system.debug('AMS_2_MDM_Batch: countryIsoCodes - ' + countryIsoCodes);    

        //WMO-456 added special remarks
        List<AMS_Change_Codes_Billable_Setup__c> lChangeCodesBillableSetup = new List<AMS_Change_Codes_Billable_Setup__c>();
        for(AMS_Change_Codes_Billable_Setup__c bchangeCodeExclude : [SELECT Change_Code__c, Country_To_Exclude__c, Location_Class_To_Exclude__c, Location_Type_To_Exclude__c, Special_Remarks__c 
                                                                                FROM AMS_Change_Codes_Billable_Setup__c]) {

            if(countryIsoCodes.contains(bchangeCodeExclude.Country_To_Exclude__c) || String.isNotBlank(bchangeCodeExclude.Special_Remarks__c)) 
                lChangeCodesBillableSetup.add(bchangeCodeExclude); 
        }

        //lstAccount = [SELECT Id, Name, Location_Class__c, Country_ISO_Code__c FROM Account WHERE id in :setAccountKeys];
        lstAccount = [SELECT Id, Name, Location_Class__c, Location_Type__c,Country_ISO_Code__c, Special_Remarks__c FROM Account WHERE id in :setAccountKeys]; //FM AMSU-116 //WMO-456
        system.debug('AMS_2_MDM_Batch: lstAccount - ' + lstAccount);
        for(Account auxAccount :lstAccount){
            //system.debug('AMS_2_MDM_Batch: auxAccount - ' + auxAccount);
            mAccountData.put(auxAccount.Id, auxAccount);
        }

        //Validate NULL values
        for(AMS_ChangeCodes__c auxCC :lBillableChangeCodes){
            if(auxCC.Billable_Location_Class__c == null){
                auxCC.Billable_Location_Class__c = '';
            }
            mapChangeCodes.put(auxCC.Change_Code__c, auxCC);
        }

        system.debug('AMS_2_MDM_Batch: mapChangeCodes - ' + mapChangeCodes);

        for(Agency_Applied_Change_code__c au :scope){
           
            system.debug('AMS_2_MDM_Batch: Agency_Applied_Change_code__c au - ' + au);

            //FM 31-03-2017 - add validation and validated list to use data to send to SAP
            AMS_ChangeCodes__c accToValidate = mapChangeCodes.get(au.Change_Code__c);
            Account auxAccAccount = mAccountData.get(au.Account__c);
            
            //system.debug('AMS_2_MDM_Batch: accToValidate - ' + accToValidate);
            //system.debug('AMS_2_MDM_Batch: auxAccAccount - ' + auxAccAccount);

            //Check if account location class is included in the list setup for the change code
            if(accToValidate.Billable_Location_Class__c.containsIgnoreCase(auxAccAccount.Location_Class__c) ){

                Boolean bToSend = true;

                //cycle throught the AMS_Change_Codes_Billable_Setup__c in order to check if it's valid to send the sales order
                for(AMS_Change_Codes_Billable_Setup__c ccbs : lChangeCodesBillableSetup){
                    //Change_Code__c, Country_To_Exclude__c, Location_Class_To_Exclude__c, Location_Type_To_Exclude__c

                    //FM AMSU-116
                    Boolean bLocation_Type_To_Exclude_Empty = ccbs.Location_Type_To_Exclude__c == null ? true : false;
                    Boolean bLocation_Type_To_Exclude_Contains = false;
                    if(!bLocation_Type_To_Exclude_Empty) {
                        bLocation_Type_To_Exclude_Contains = ccbs.Location_Type_To_Exclude__c.containsIgnoreCase(auxAccAccount.Location_Type__c) ? true : false;
                    }

                    //WMO-456                   
                    Boolean excludeSpecialRemarks = String.isNotBlank(ccbs.Special_Remarks__c) && String.isNotBlank(auxAccAccount.Special_Remarks__c) && 
                        auxAccAccount.Special_Remarks__c.split(';').contains(ccbs.Special_Remarks__c) && 
                        auxAccAccount.Location_Class__c == ccbs.Location_Class_To_Exclude__c && 
                        ( bLocation_Type_To_Exclude_Empty || bLocation_Type_To_Exclude_Contains); 
                    Boolean excludeByCountry = auxAccAccount.Country_ISO_Code__c == ccbs.Country_To_Exclude__c 
                        && auxAccAccount.Location_Class__c == ccbs.Location_Class_To_Exclude__c
                        && ( bLocation_Type_To_Exclude_Empty || bLocation_Type_To_Exclude_Contains);
                        
                    if(au.Change_Code__c == ccbs.Change_Code__c && (excludeByCountry || excludeSpecialRemarks)){  //FM AMSU-116 //WMO-456                        
                        bToSend = false;                            
                    }
                    
                }

                if(bToSend){
                    sLog += au.Account__r.IATACode__c + ',';
                    scopeValidBillable.add(au);
                }

            }
            
        }
       
        system.debug('AMS_2_MDM_Batch: scopeValidBillable - ' + scopeValidBillable);
        system.debug('AMS_2_MDM_Batch: scopeValidBillable.size() - ' + scopeValidBillable.size());

        if(scopeValidBillable.size() > 0){

            String[] headerParams = new String[5];
            headerParams[0] = ''; //'PreviousID'
            headerParams[1] = ''; //'GroupID'
            headerParams[2] = String.valueOf(AMS_SAP_Settings__c.getOrgDefaults().Batch_Size__c); //'ChunkSize'
            headerParams[3] = ''; //'ChunkKey'
            headerParams[4] = ''; //'ChunkTotal'

            AMS_XML_Generator xmlGen = new AMS_XML_Generator();
     
            //FM 31-03-2017 - Change from scope to validated list
            String s = xmlGen.getAgencySalesOrder(scopeValidBillable);

            //Decomment if XML is necessary on the Log entry
            sLog += 'XML Sent: '+s+'\n';
            
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
                        
            try {
                
                String sRespStatusCode = '';

                if(!Test.isRunningTest()) {
                    // Call SAP web service
                    sRespStatusCode = ws.SI_SFDC_SalesOrder_OB_Http(s,authorizationHeader);
                }else{
                    sRespStatusCode = '200';
                }
                
                sLog += 'Response Status Code: '+sRespStatusCode+'\n';
                

                if(sRespStatusCode.equalsIgnoreCase('200')){

                    //update scope;
                    for(Agency_Applied_Change_code__c au :scopeValidBillable){
                        au.Sent_to_external_system__c = true;
                    }
                    update scopeValidBillable;

                    

                }else{
                    system.debug('SAP Web Service - SI_SFDC_SalesOrder_OB - callout ERROR! ');
                    
                    tlog.Status__c = 'Error';
                }

            }
            catch (Exception ex) {
                system.debug('SAP Web Service callout error: ' + ex.getMessage());
                
                sLog += 'Exception: SAP Web Service callout error:'+ex.getMessage()+'\n';
                sLog += 'Exception StackTrace: '+ex.getStackTraceString() +'\n';
                tlog.Status__c = 'Error';
            }
            
        }else{
            //there were no records to send! adding info to the Log
            sLog += 'No change codes to send! \n No Communication sent to external system! \n';
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