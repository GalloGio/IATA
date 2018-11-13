/**
This class is offering Web service supposed to be used mainly by DST tool to push data directly to SFDC with APEX processing [compare to API processing]
Can be used to push data without havoing them in DM
*/
global class AMSIntegrationServices {


/**
    This web service will assign agency Programs. It will create new programssbased on ame if needed
    
    */
    webservice static boolean assignAgency2Programs(String agId, String[] programsName){
        try{
            system.debug('[assignAgency2Programs]Assigned programs '+programsName+' to AGT:'+agid);
            //configure segments
            Id  programRT  =  RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Segment__c', 'IATA_Code_Programs');
            Map<String, AMS_Segment__c> programs = new Map<String,AMS_Segment__c>();
            List< AMS_Segment__c> newPrograms = new List< AMS_Segment__c>();
            Map<String, AMS_Segment__c> newProgramsPerNme= new Map<String,AMS_Segment__c>();
            for(AMS_Segment__c c:[select Name, Label__c, Id from AMS_Segment__c where RecordTypeId = :programRT])
                programs.put(c.Label__c.toLowerCase() ,c);
            system.debug('[assignAgency2Programs]found existing prgms '+programs.size());
            //get the agency to process
            Account agt = [select Id from Account  where Id = :agId];
            
            system.debug('[assignAgency2Programs] found agt  '+(agt!=null));
            //use to be sure we won 't save twice agencies segement
            Map<String, AMS_Agency_Segment__c> agencySegments = new Map<String, AMS_Agency_Segment__c>();
            for(AMS_Agency_Segment__c c:[select Name, Id, Segment__c  from AMS_Agency_Segment__c where Account__c = :agId and Segment__c in (select Id from AMS_Segment__c where RecordTypeId = :programRT)])
                agencySegments.put(c.Segment__c  ,c);
            system.debug('[assignAgency2Programs]found assinged pgms for agt '+(agencySegments.size()));
            //use to save new agency segments
            Map<String, AMS_Agency_Segment__c> newAgencySegments = new Map<String, AMS_Agency_Segment__c>();
            
            //
            for(String pName:programsName){
                //only add new agSeg is not already exisitng
                if(programs.get(pName.toLowerCase())!=null && agencySegments.get(programs.get(pName.toLowerCase()).Id) ==null){
                    newAgencySegments.put(pName, new AMS_Agency_Segment__c(Account__c =agId,Segment__c = programs.get(pName.toLowerCase()).Id));
                }
                else if(programs.get(pName.toLowerCase())==null && newProgramsPerNme.get(pName.toLowerCase())==null) {
                    AMS_Segment__c  s = new AMS_Segment__c (RecordtypeId =programRT  ,Label__c = pName );
                    newPrograms.add(s);
                    newProgramsPerNme.put(pName.toLowerCase(),s);
                }
            }
            system.debug('[assignAgency2Programs] new existing pgm assignmnet '+(newAgencySegments.size()));
            system.debug('[assignAgency2Programs] new pgm to create'+(newPrograms.size()));
            //insert new Programs
            insert newPrograms;
            for(AMS_Segment__c p:newPrograms)
                newAgencySegments.put(p.Label__c , new AMS_Agency_Segment__c(Account__c =agId,Segment__c = p.Id));
            system.debug('[assignAgency2Programs] total  pgm assignmnet '+(newAgencySegments.size()));                
            insert newAgencySegments.values();
        }catch(Exception e){
            return false;
        }
        return true;
    }

    /**
    This WS is used to update account irregularities fields
    As it is a dedicated field, is his managed by WEB serivce
    **/
    webservice static Boolean updateAccountIrregularities(String agencyId, Integer irregulaties){
        Boolean result = false;
        system.debug('[AMSIntegrationServices.updateAccountIregularities 1 ] FRequest for account from AGT '+agencyId);
        List<Account> acc = [select Id, Company_Type__c, Accumulated_Irregularities__c from Account where id = :agencyId];
        if(acc.size() == 0){
            system.debug('Failed to find Account  '+agencyId);
            return result;
        }
        Account theAgency = acc.get(0);
        theAgency.Accumulated_Irregularities__c = irregulaties;
        try{
            update theAgency;
           
        }catch(DmlException e){
             system.debug('Failed to update account '+e.getMessage());
             return result;
        }
        result = true;
        return result;
    }

    
    /**
    This WS is used to update account ShortName
    As it is a dedicated field, is his managed by WEB serivce
    **/
    webservice static Boolean updateAccountShortName(String agencyId, String shortname){
        Boolean result = false;
        system.debug('[AMSIntegrationServices.updateAccountShortName1 ] Request for account from AGT '+agencyId);
        List<Account> acc = [select id, Company_Type__c, Short_Name__c from Account where id = :agencyId];
        if(acc.size() == 0){
            system.debug('Failed to find Account  '+agencyId);
            return result;
        }
        Account theAgency = acc.get(0);
        theAgency.Short_Name__c= shortname;
        try{
            update theAgency;
           
        }catch(DmlException e){
             system.debug('Failed to update account '+e.getMessage());
             return result;
        }
        result = true;
        return result;
    }






  /**
    This WS is used to update account fields from Agency Id.
    It is looking for the Acocunt and try top update specific fields.
    USED for GDP Fields
    */
    webservice static Boolean updateAccountGDPData(String accountId, String GDP_Location_Type ){
        Boolean result = false;
        Account theAgency = [select id, Company_Type__c, GDP_Opt_In__c, GDP_Location_Type__c, Incorporation_Type__c from Account where id = :accountId];
      
         if(GDP_Location_Type != null && GDP_Location_Type != ''){
            system.debug('[AMSIntegrationServices.updateAccountGDPData] WS called with Location Type to set '+GDP_Location_Type );
            String t = GDP_Location_Type;
            t = t.replace('LOCTYP','');
            List<GDP_Reference_Table__c> loc = [select id from GDP_Reference_Table__c where Table__c=: 'LOCTYP' and Code__c =:t];
            if(loc.size() == 0){
                 system.debug('[AMSIntegrationServices.updateAccountGDPData]Failed to find location with name '+t);
                 //return result;
            }else
                theAgency.GDP_Location_Type__c = loc.get(0).Id;
        }
        
        try{

            update theAgency;
            
        }catch(DmlException e){
         system.debug('Failed to update account '+e.getMessage());
            return result;
        }

        result = true;
        return result;
    }

    

  /**
    This WS is used to update account fields from Agency Id.
    It is looking for the Acocunt and try top update specific fields.
    USED for GDP Fields
    */
    webservice static Boolean updateAccountGDPData2(String agencyId, String Company_Type, Boolean GDP_Opt_In, String GDP_Location_Type , String languageOfCorrespondance, String Tax2, String PaxAndCargo ){
        Boolean result = false;
        system.debug('[AMSIntegrationServices.updateAccountGDPData2] FRequest for account from AGT '+agencyId);
        List<Account> acc = [select id, Company_Type__c, Tax_ID_2__c, Passenger_And_Cargo__c, GDP_Opt_In__c, GDP_Location_Type__c, Incorporation_Type__c from Account where id = :agencyId];
        if(acc.size() == 0){
            system.debug('[AMSIntegrationServices.updateAccountGDPData2]Failed to find Account '+agencyId);
            return result;
        }else
            system.debug('[AMSIntegrationServices.updateAccountGDPData2] Find  Account '+acc.get(0).Id);


        Account theAgency = acc.get(0);
        theAgency.GDP_Opt_In__c = GDP_Opt_In;
        theAgency.Preferred_Language__c= languageOfCorrespondance ;
        theAgency.Tax_ID_2__c = Tax2;
        theAgency.Passenger_And_Cargo__c = PaxAndCargo ;
        if(GDP_Location_Type != null && GDP_Location_Type != ''){
            system.debug('[AMSIntegrationServices.updateAccountGDPData2] WS called with Location Type to set '+GDP_Location_Type );
            String t = GDP_Location_Type;
            t = t.replace('LOCTYP','');
            List<GDP_Reference_Table__c> loc = [select id from GDP_Reference_Table__c where Table__c=: 'LOCTYP' and Code__c =:t];
            if(loc.size() == 0){
                 system.debug('[AMSIntegrationServices.updateAccountGDPData2]Failed to find location with name '+t);
                 //return result;
            }else
                theAgency.GDP_Location_Type__c = loc.get(0).Id;
        }

        try{
            system.debug('[AMSIntegrationServices.updateAccountGDPData2]Updating Account');
            if(theAgency.Company_Type__c != Company_Type)
                theAgency.Company_Type__c = Company_Type;

            update theAgency;

        }catch(DmlException e){
             system.debug('[AMSIntegrationServices.updateAccountGDPData2]Failed to update account '+e.getMessage());
            return result;
        }
        system.debug('[AMSIntegrationServices.updateAccountGDPData2]Complete Account update for FDP fields');
        result = true;
        return result;
    }
    
   /**
    This WS is used to update account fields from Agency Id.
    It is looking for the Acocunt and try top update specific fields.
    USED for GDP Fields
    */
    webservice static Boolean updateAccountGDPData3(String agencyId, String Company_Type, Boolean GDP_Opt_In, String GDP_Location_Type , String languageOfCorrespondance, String PaxAndCargo, String Tax2, String BSPCassCode,String TicketingManagerln,String TicketingManagerfn,String locManagerln,String locManagerfn){
        Boolean result = false;
        system.debug('[AMSIntegrationServices.updateAccountGDPData2] FRequest for account from AGT '+agencyId);
        List<Account> acc = [select id, Company_Type__c, BSP_CASS_Code__c, Ticketing_Agent_First_Name__c, Ticketing_Agent_Last_Name__c, Tax_ID_2__c, Passenger_And_Cargo__c, GDP_Opt_In__c, GDP_Location_Type__c, Incorporation_Type__c from Account where id = :agencyId];
        //List<Ams_Person__c>  ticketingEmployees = [select First_Name__c, Lastname__c from Ams_Person__c where Id in (select Person__c from AMS_Employee__c where isTicketingAgent__c = true and Agency__c  = :agencyId) order by LastModifiedDate desc  ];
        
        if(acc.size() == 0){
            system.debug('[AMSIntegrationServices.updateAccountGDPData2]Failed to find Account '+agencyId);
            return result;
        }else
            system.debug('[AMSIntegrationServices.updateAccountGDPData2] Find  Account '+acc.get(0).Id);


        Account theAgency = acc.get(0);
        theAgency.GDP_Opt_In__c = GDP_Opt_In;
        theAgency.Preferred_Language__c= languageOfCorrespondance ;
        theAgency.Tax_ID_2__c = Tax2;
        theAgency.BSP_CASS_Code__c = BSPCassCode;
        theAgency.Passenger_And_Cargo__c = PaxAndCargo ;
       
        theAgency.Ticketing_Agent_First_Name__c =  TicketingManagerfn;
        theAgency.Ticketing_Agent_Last_Name__c =  TicketingManagerln;
        theAgency.Manager_First_Name__c=  locManagerfn;
        theAgency.Manager_Last_Name__c=  locManagerln;
       
        if(GDP_Location_Type != null && GDP_Location_Type != ''){
            system.debug('[AMSIntegrationServices.updateAccountGDPData2] WS called with Location Type to set '+GDP_Location_Type );
            String t = GDP_Location_Type;
            t = t.replace('LOCTYP','');
            List<GDP_Reference_Table__c> loc = [select id from GDP_Reference_Table__c where Table__c=: 'LOCTYP' and Code__c =:t];
            if(loc.size() == 0){
                 system.debug('[AMSIntegrationServices.updateAccountGDPData2]Failed to find location with name '+t);
                 //return result;
            }else
                theAgency.GDP_Location_Type__c = loc.get(0).Id;
        }

        try{

            if(theAgency.Company_Type__c != Company_Type)
                theAgency.Company_Type__c = Company_Type;

            system.debug('[AMSIntegrationServices.updateAccountGDPData2]Updating Agency');
            update theAgency;
            
        }catch(DmlException e){
             system.debug('[AMSIntegrationServices.updateAccountGDPData2]Failed to update account '+e.getMessage());
            return result;
        }
        system.debug('[AMSIntegrationServices.updateAccountGDPData2]Complete Acocunt update for FDP fields');
        result = true;
        return result;
    }



    /**
    This WS is used to update account fields from Agency Id.
    It is looking for the Acocunt and try top update specific fields.
    USED for GDP Fields
    */
    webservice static Boolean updateAccountGDPDataWithLegacyData2(String legacyId, String legacySystem, String Company_Type, Boolean GDP_Opt_In, String GDP_Location_Type, String languageOfCorrespondance, String Tax2, String PaxAndCargo ){
        Boolean result = false;

        List<Account> acc = [select id, Company_Type__c, GDP_Opt_In__c, GDP_Location_Type__c, Incorporation_Type__c
                                    from Account where (AIMS_ID__c = :legacyId OR WebStar_ID__c =:legacyId) and Source_System__c = :legacySystem];
        
        if(acc.size() == 0){
            system.debug('Failed to find Agency with ID  '+legacyId );
            return result;
        }
        Account theAgency = acc.get(0);
        theAgency.GDP_Opt_In__c = GDP_Opt_In;
        theAgency.Preferred_Language__c= languageOfCorrespondance ;
        theAgency.Tax_ID_2__c = Tax2;
        theAgency.Passenger_And_Cargo__c = PaxAndCargo ;
        system.debug('############### GDP_Location_Type = '+GDP_Location_Type);
        if(GDP_Location_Type != null && GDP_Location_Type != ''){
            String t = GDP_Location_Type;
            t = t.replace('LOCTYP','');
            List<GDP_Reference_Table__c> loc = [select id from GDP_Reference_Table__c where Table__c=: 'LOCTYP' and Code__c =:t];
            system.debug('############### loc.size() = '+loc.size());
            if(loc.size() == 0){
                system.debug('Failed to find location type for  '+t+'\n query: [select id from GDP_Reference_Table__c where Table__c=: LOCTYP and Code__c = "'+t+'"]');
                return result;
            }
            theAgency.GDP_Location_Type__c = loc.get(0).Id;   
        }

        try{
            if(theAgency.Company_Type__c != Company_Type)
                theAgency.Company_Type__c = Company_Type;

            update theAgency;
            
        }catch(DmlException e){
            system.debug('Failed to update account '+e.getMessage());
            return result;
        }
        result = true;
        return result;
    }

 /**
    This WS is used to update account fields from Agency Id.
    It is looking for the Acocunt and try top update specific fields.
    USED for GDP Fields
    */
    webservice static Boolean updateAccountGDPDataWithLegacyData(String legacyId, String legacySystem, String Company_Type, Boolean GDP_Opt_In, String GDP_Location_Type, String languageOfCorrespondance ){
        Boolean result = false;

        List<Account> acc = [select id, Company_Type__c, GDP_Opt_In__c, GDP_Location_Type__c, Incorporation_Type__c
                                    from Account where (AIMS_ID__c = :legacyId OR WebStar_ID__c =:legacyId) and Source_System__c = :legacySystem];
        
        if(acc.size() == 0){
            system.debug('Failed to find Agency with ID  '+legacyId );
            return result;
        }
        Account theAgency = acc.get(0);
        //Account theAccount = acc.get(0).Account__r;
        theAgency.GDP_Opt_In__c = GDP_Opt_In;
        theAgency.Preferred_Language__c= languageOfCorrespondance ;
        system.debug('############### GDP_Location_Type = '+GDP_Location_Type);
        if(GDP_Location_Type != null && GDP_Location_Type != ''){
            String t = GDP_Location_Type;
            t = t.replace('LOCTYP','');
            List<GDP_Reference_Table__c> loc = [select id from GDP_Reference_Table__c where Table__c=: 'LOCTYP' and Code__c =:t];
            system.debug('############### loc.size() = '+loc.size());
            if(loc.size() == 0){
                system.debug('Failed to find location type for  '+t+'\n query: [select id from GDP_Reference_Table__c where Table__c=: LOCTYP and Code__c = "'+t+'"]');
                return result;
            }
            theAgency.GDP_Location_Type__c = loc.get(0).Id;   
        }

        try{
            if(theAgency.Company_Type__c != Company_Type)
                theAgency.Company_Type__c = Company_Type;

            update theAgency;
            
        }catch(DmlException e){
            system.debug('Failed to update account '+e.getMessage());
            return result;
        }
        result = true;
        return result;
    }

    /*
    Force system to assign an Agency to a list of Operation, not only based on Agency Trigger
    */
    private static Boolean assignAgencyToOperations(Account theAgency ,List<AMS_Operation__c> ops ){
        try{
            List<AMS_Agency_Operations__c> agOps = new List<AMS_Agency_Operations__c>();
            for(AMS_Operation__c op:ops){
                AMS_Agency_Operations__c  ao = new AMS_Agency_Operations__c(Account__c = theAgency.Id, Operation__c =op.Id);
                agOps.add(ao);
            }
            insert agOps ;
            return true;
        }catch(Exception e){
            return false;
        }
    }

    /**
    
    Force system to assign an Agency to a list of Operation, not only based on Agency Trigger
    Operation are loaded from DPC and not with the Operation directly
    @deprecated
    */
    webservice static Boolean assignAgencyPerDPC(String agencyId, String isoCountryId){
        Boolean result = false;

        List<Account> acc = [select id, Operation__c,RecordtypeId, Sector__c from Account where id = :agencyId];
        
        if(acc.size() == 0)
            return result;

        Account theAgency = acc.get(0);
        
        //based on Account Sector, we check for the selected Operations
        List<AMS_Operation__c> ops =null;
        if(theAgency.Sector__c == 'Cargo Agent')
           ops = [select id from AMS_Operation__c where CASS_Operations__c ='' and Country__c = :isoCountryId];
        else if(theAgency.Sector__c == 'Travel Agent')
           ops = [select id from AMS_Operation__c where CASS_Operations__c !='' and Country__c = :isoCountryId];

        if(ops.size() == 0)
            return result;     
        return assignAgencyToOperations(theAgency ,ops );
    }
    
    /**
    Force system to assign an Agency to a list of Operation, not only based on Agency Trigger
    Operation list is loaded from dedicated country list.
    @deprecated
    */
    webservice static Boolean assignAgencyPerDPCandLegacyIDs(String agencylegacyId, String legacySystem, String isoCountryId){
        Boolean result = false;

        List<Account> acc = [select id, Operation__c, RecordTypeId, Sector__c
                                    from Account where (AIMS_ID__c = :agencylegacyId OR WebStar_ID__c =:agencylegacyId) and Source_System__c = :legacySystem];
        
        if(acc.size() == 0)
            return result;

        Account theAgency = acc.get(0);

        //based on Account Sector, we check for the selected Operations
        List<AMS_Operation__c> ops =null;
        if(theAgency.Sector__c == 'Cargo Agent')
           ops = [select id from AMS_Operation__c where CASS_Operations__c ='' and Country__c = :isoCountryId];
        else if(theAgency.Sector__c == 'Travel Agent')
           ops = [select id from AMS_Operation__c where CASS_Operations__c !='' and Country__c = :isoCountryId];

        if(ops.size() == 0)
            return result;
        return assignAgencyToOperations(theAgency ,ops );
    }
    
    /**

    Force system to assign an Agency to a list of Operation, not only based on Agency Trigger
    Operation are loaded from Settlements systems
    @deprecated
    */

    webservice static Boolean assignAgencyPerSettlement(String agencyId, String isoCountryId, String Settlement, Boolean isCass){
        Boolean result = false;

        List<Account> acc = [select id, Operation__c
                                    from Account where id = :agencyId];
        
        if(acc.size() == 0)
            return result;

        Account theAgency = acc.get(0);

        Id rtId;
        if(isCass)
            rtId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Settlement_System__c', 'CASS');
        else
            rtId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Settlement_System__c', 'BSP');

        List<AMS_Operation__c> op = [select id from AMS_Operation__c where Settlement__c IN (select id from AMS_Settlement_System__c where Name = :Settlement and recordTypeId = :rtId) and Country__c = :isoCountryId];

        if(op.size() == 0)
            return result;

        theAgency.Operation__c = op.get(0).id;

        try{
            update theAgency;
        }catch(DmlException e){
            return result;
        }

        result = true;
        return result;
    }
    
    webservice static Boolean assignAgencyPerSettlementandLegacyIDs(String agencylegacyId, String legacySystem, String isoCountryId, String Settlement, Boolean isCass){
        Boolean result = false;

        List<Account> acc = [select id, Operation__c from Account where (AIMS_ID__c = :agencylegacyId OR WebStar_ID__c =:agencylegacyId) and Source_System__c = :legacySystem];

        if(acc.size() == 0)
            return result;
        Account theAgency = acc.get(0);
        Id rtId;
        if(isCass)
            rtId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Settlement_System__c', 'CASS');
        else
            rtId = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_Settlement_System__c', 'BSP');
        List<AMS_Operation__c> op = [select id from AMS_Operation__c where Settlement__c IN (select id from AMS_Settlement_System__c where Name = :Settlement and recordTypeId = :rtId) and Country__c = :isoCountryId];
        if(op.size() == 0)
            return result;
        theAgency.Operation__c = op.get(0).id;
        try{
            update theAgency;
        }catch(DmlException e){
            return result;
        }

        result = true;
        return result;
    }



    /* ====================================================================*/
    /*              **     FOR STATS                     **                */
    /* ====================================================================*/
    
    /**
    return the number of Agencies per legacysystem
    */
    @ReadOnly
    webservice static Integer countAgenciesPerLegacySystem(String legacySystem){
       String query = 'select count() from Ams_agency__c ';
       if(legacySystem!=null)
           query = query + ' where Legacy_system__c = \''+legacySystem+'\'';
       return  database.countQuery(query);
    }
    
    
    /**
        return the number of Agencies UPDATED since a selected date.
        Update = base on SFDC standard Last_modification_date
    */
    @ReadOnly
    webservice static Integer countAgenciesModifiedFormSelectedDate( String selectedDate,String legacySystem ){
       String query = 'select count() from Ams_agency__c where  LastModifiedDate>=  '+selectedDate;
       if(legacySystem!=null)
           query = query + ' and Legacy_system__c = \''+legacySystem+'\' ';
       return  database.countQuery(query);
    }
    
      
    /**
        return the number of Agencies SYNCHRONIZED since a selected date.
        SYNCHRONIZED = base on custom last sync date
    */
    @ReadOnly
    webservice static Integer countAgenciesSynchronizedFormSelectedDate( String selectedDate,String legacySystem ){
       String query = 'select count() from Ams_agency__c where  ';
       //if(selectedDate!=null)
           query = query + ' LastModifiedDate>=  '+selectedDate;
       if(legacySystem!=null)
           query = query + ' and Legacy_system__c = \''+legacySystem+'\'';

      return  database.countQuery(query);
    }
    
    
    
    /**
        return the number of Agencies UNSYNCHRONIZED [optional since a selected date].
    */
    @ReadOnly
    webservice static Integer unSynchronizedAgencies(  String selectedDate){
       String query = 'select count() from Ams_agency__c where Legacy_system__c =null ';
       if(selectedDate!=null)
           query = query + '  and createddate >=  '+selectedDate;
       return  database.countQuery(query);
    }
    
    
    /**
        return the number of Agencies UNSYNCHRONIZED [optional since a selected date].
    */
    /*
    webservice static void dstActivityLogger(  String legacySystem, Integer succesRecords, Integer failedRecords,long time2process,String runningMode ){
       AMS_DST_Sync_log__c log = new AMS_DST_Sync_log__c(Log_system__c = legacySystem, Log_time__c = Datetime.now(), Success_records__c=succesRecords, Error_Records__c =failedRecords, Mode__c = runningMode, Time_to_proceed__c  = time2process);
       insert log;
    }
    */
       
}