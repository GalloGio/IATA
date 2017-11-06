@RestResource(urlMapping='/GSS/v0/FileDataAgency/*')
/*
 * GSS_REST_FilePayload returns the data file for Agency / GDP_Products_Account_View, 
 *  - URI Parameter:  FileSpecificationId, LastRetrievedRecordId, RequestSizeFactor
 *
 * Change log:
 *   20160212-sl: Order as defined in GDP_File_Description__c.Order_By, e.g. GSS_MDP_Sort_Key_Formula
 *   20160215-sl: Do not decode lastRetrievedRecordId back with EncodingUtil.urlDecode(), incoming parameter is already decoded
 *   20160407-sl: Add RequestSizeFactor parameter to allow reducing limit defined by Maximum_API_Request
 *
 */
global with sharing class GSS_REST_FilePayload {
    static final Integer BATCH_SIZE = 100;
    static final String MAILING_OBJECT='Mailing';
    static final String LOCATION_OBJECT='Location';
    static final String AGENCY_CODE='AG';
    static final String AIRLINE_CODE='AL';
    static final String TERITORY_CODE='TY';
    static final Integer MAX_TERRITORY=22;
    static final Boolean TestMode=false;
    static final String ENCODING_SCHEME = 'UTF-8'; // use in calling EncodingUtil class
    
    @HttpGet
    global static void getFilePayload() {
        
        //try{
        //Get and validate input parameters in the URL
        //Get REQUIRED FileSpecificationID parameter
        String FileSpecificationID = RestContext.request.params.get('FileSpecificationId');
        if (FileSpecificationID == '' || FileSpecificationID == null) throw new MyException('FileSpecificationID is required parameter');  
        Boolean IsTestMode =false;
        String isTestString = RestContext.request.params.get('IsTestMode');
        if (!(isTestString == '' || isTestString == null)) IsTestMode = true;
       
        //Based on the current File Specification record extract the Fields Arrays
        String DynamicSQL = '';
        String SOQL = '';
     
        
        //Get Optional lastRetrievedRecordId parameter
        //lastRetrievedRecordId will be used to recall the function to get more records than the BATCH_SIZE
        //the usage of value of lastRetrieveRecordId will also depend of related GDP_File_Description__c.Product_Type__c
        String lastRetrievedRecordIdParameter = RestContext.request.params.get('LastRetrievedRecordId');
        
        // Get Optional RequestSizeFactor parameter, and use it to set DividerFactor
        String RequestSizeFactorStr = RestContext.request.params.get('RequestSizeFactor');
        Integer RequestSizeFactor = (RequestSizeFactorStr == null) ? 0 : Integer.valueOf(RequestSizeFactorStr); 
        RequestSizeFactor = (RequestSizeFactor == null) ? 0 : RequestSizeFactor; 
        Integer DividerFactor = Integer.valueOf(Math.pow(2, RequestSizeFactor));
        
        //TODO: Load the SQL information from File Specification
        List<GDP_File_Description__c> filespecificationlist = new List<GDP_File_Description__c>();
        filespecificationlist = [SELECT Id
                                        ,Field_Group__c
                                        ,Field_API__c
                                        ,Field_Visible__c
                                        ,Field_Type__c
                                        ,Field_Filter__c
                                        ,Field_Filter_Value__c
                                        ,Field_Object_Name__c   
                                        ,Frequency__c
                                        ,Order_By__c
                                        ,Product_Type__c
                                        ,Reference_Clause__c
                                        ,Reference__c
                                        ,Reference__r.Field_Group__c
                                        ,Reference__r.Field_API__c
                                        ,Reference__r.Field_Visible__c
                                        ,Reference__r.Field_Type__c
                                        ,Reference__r.Field_Filter__c
                                        ,Reference__r.Field_Filter_Value__c
                                        ,Reference__r.Field_Object_Name__c
                                        ,Reference__r.Reference_Clause__c
                                        ,Reference__r.Product_Type__c
                                        ,Reference__r.Service_Target__c
                                        ,Reference__r.Maximum_API_Request__c
                                        ,Reference__r.Web_Service_Default_Response__c   
                                        ,Reference__r.Minimum_Digit_Search__c
                                        ,Class__c
                                        ,Magnitude__c
                                        ,Geo_Coverage_Definition__c
                                        ,Geo_Coverage_Definition__r.Country_Selection__c
                                     FROM GDP_File_Description__c
                                     WHERE id =: FileSpecificationID
                                       ];
        //TODO: Make sure to have File Specification or Reference File Specification to process
        if (filespecificationlist.size()==0){}
        // NEW_BATCH_SIZE is used to limit the number of rows requested
        Integer NEW_BATCH_SIZE= BATCH_SIZE;
        if (filespecificationlist[0].Reference__r.Maximum_API_Request__c!=null) NEW_BATCH_SIZE=Integer.ValueOf(filespecificationlist[0].Reference__r.Maximum_API_Request__c);
        
        NEW_BATCH_SIZE =  Integer.valueOf(Math.floor(NEW_BATCH_SIZE / DividerFactor)) + 1;
        
        List<GDP_File_Production__c> fileproductionlist = new List<GDP_File_Production__c>();
        fileproductionlist = [Select Id,File_Specification__c, LastModifiedDate 
                            From GDP_File_Production__c 
                            Where File_Specification__c=:FileSpecificationID
                            Limit 1]; 
    
        //the value of lastRetrieveRecordId is based on given http parameter and related GDP_File_Description__c.Product_Type__c
        String lastRetrievedRecordId = lastRetrievedRecordIdParameter; // default value for GSS
        //In the case that there is no lastRetrievedRecordId, return first records
        if(lastRetrievedRecordIdParameter == '' || lastRetrievedRecordIdParameter == null) {
            lastRetrievedRecordId = '000000000000000000';
        } else if ((filespecificationlist[0].Order_By__c != 'Id') && (filespecificationlist[0].Order_By__c != null))
        {
             //lastRetrievedRecordId =  EncodingUtil.urlDecode(lastRetrievedRecordIdParameter, ENCODING_SCHEME).replace( '\'', '\\\'' );
             lastRetrievedRecordId = String.escapeSingleQuotes(lastRetrievedRecordIdParameter);
        }
        List<GDP_Products_Account_View__c> myObjectRecordList = new List<GDP_Products_Account_View__c>();
      
        //Geo Coverage
        String Where_Geo_Coverage_SOQL='';
        if (filespecificationlist[0].Geo_Coverage_Definition__r.Country_Selection__c!=null){
           Where_Geo_Coverage_SOQL=filespecificationlist[0].Geo_Coverage_Definition__r.Country_Selection__c;
        }
        Where_Geo_Coverage_SOQL = Where_Geo_Coverage_SOQL.replaceAll('(?i)Related_GDP_Address__r.IATA_ISO_Country__c','object.Related_GDP_Address__r.IATA_ISO_Country__c');
         
        //Class Where Clause
        String Where_Class_SOQL = '';
        if (filespecificationlist[0].Class__c!=null || IsTestMode){
            //If the class is provided but do not exists the Select must not return nothing
            //so the value has to be something and not blank
            String classname='NOTFOUNDATALL';
            String ClassStr = filespecificationlist[0].Class__c;
            if (isTestMode) ClassStr='123123123,123232323';
            String[] ClassListStr = ClassStr.Split(',');
            Set<String> sclass = new Set<String>();
            for(String mystring:ClassListStr) {sclass.add(mystring);}
            Where_Class_SOQL = ' AND (';
            //, code__c, Definition__c, Table__c,System__c
            List<GDP_Reference_Table__c> classlist=[Select Id
                                                        ,name
                                                    From GDP_Reference_Table__c 
                                                    where Table__c='ORGCLASS'
                                                      AND Code__c=:sclass
                                                    ];
            integer cCounter=0;
            for(GDP_Reference_Table__c c:classlist){
                if (cCounter>0) Where_Class_SOQL += ' OR ';
                Where_Class_SOQL += 'object.Accreditation_Class__c=\''+ c.name + '\'';
                cCounter++;
            }
            if (cCounter==0) Where_Class_SOQL += 'object.Accreditation_Class__c=\''+ classname + '\'';
            Where_Class_SOQL += ')';    
            if (IsTestMode) Where_Class_SOQL='';   
        } 
        //Reference Where Clause                  
        String Where_Reference_Clause ='';
        if (filespecificationlist[0].Reference__r.Reference_Clause__c!=null) Where_Reference_Clause = filespecificationlist[0].Reference__r.Reference_Clause__c;
        if (filespecificationlist[0].Reference_Clause__c!=null) Where_Reference_Clause = filespecificationlist[0].Reference_Clause__c;
        if (Where_Reference_Clause.Trim()!='') Where_Reference_Clause =' AND ('+Where_Reference_Clause+')';

        boolean isObjectReferenceClause= false;
        if (Where_Reference_Clause.IndexOf('object.')>-1) isObjectReferenceClause=true;
        
        // Last Retrieved Id or Value in the batch of records selected previously
        String Order_Clause = ' Order by object.Id'; // this is the default, i.e. for non MDP
        String Where_Last_Retrieved_Id = ' And object.Id > \''; 
        //Order_Clause = ' Order by MDP_Sort_Key_Formula__c';
        //Where_Last_Retrieved_Id = ' And MDP_Sort_Key_Formula__c > \'';
       
        if (filespecificationlist[0].Order_By__c != null) {
            Order_Clause = ' Order by object.' + filespecificationlist[0].Order_By__c;
            Where_Last_Retrieved_Id = ' And object.' + filespecificationlist[0].Order_By__c + ' > \'';
        }
        /**** GDP-228 Start ****/
        Boolean ISDELTA=false;
        Boolean ISMASTER=false;
        if (filespecificationlist[0].Magnitude__c=='Delta') ISDELTA=true;
        if (filespecificationlist[0].Magnitude__c=='Master') ISMASTER=true;
        if (IsTestMode) { ISDELTA=true; ISMASTER=true;}
        //Magnitude Where Clause
        String Where_Magnitude_SOQL='';
        String DeltaPeriodSOQL =  '';
        Map<String,String> deltaChangeCodeMap = new Map<String,String>();
        set<string> deltaChangeCodeIdSet;
        if (ISDELTA)
        {


            //SOQL+=' AND Id > \'' + lastRetrievedRecordId + '\'' 
            String Delta_GDP_Account_SOQL= Where_Last_Retrieved_Id + lastRetrievedRecordId + '\''
                                     + Where_Class_SOQL
                                     + Where_Magnitude_SOQL
                                     + Where_Geo_Coverage_SOQL
                                     + Where_Reference_Clause;

            if (!isObjectReferenceClause) Delta_GDP_Account_SOQL = Delta_GDP_Account_SOQL.replaceAll('(?i)Related_Accreditation_Class__r.Accreditation_ID__c','object.Related_Accreditation_Class__r.Accreditation_ID__c');
            if (!isObjectReferenceClause) Delta_GDP_Account_SOQL = Delta_GDP_Account_SOQL.replaceAll('(?i)Agency_Status_Code__c','object.Agency_Status_Code__c');
          
            //SOQL = SOQL.replaceAll('','Related_GDP_Product_Account_View__r.');
            
            
            System.debug('Delta Delta_GDP_Account_SOQL: '+ Delta_GDP_Account_SOQL);
            
      
       
            //Get the Reference file specification related to the file specification
            String SearchBySpecificationId=FileSpecificationID;
            if (filespecificationlist[0].Reference__c!=null) SearchBySpecificationId=filespecificationlist[0].Reference__c;
            
            DeltaPeriodSOQL =  'SELECT GDP_File_Description__c, Related_GDP_Product_Account_View__c, Change_Code__c ';
            DeltaPeriodSOQL += ' FROM GDP_Delta__c  WHERE GDP_File_Description__c = \''+SearchBySpecificationId +'\'' ;
            String STARTDAY='';
            String ENDDAY='';
            if (filespecificationlist[0].Frequency__c=='Daily')   { STARTDAY='=YESTERDAY';}
            if (filespecificationlist[0].Frequency__c=='Weekly')   { STARTDAY='=LAST_WEEK';}
            if (filespecificationlist[0].Frequency__c=='Monthly')  { STARTDAY='=LAST_MONTH';}
            
            
            Date theEndOfMonth;
            Date theFirstOfMonth;
            Boolean isSemiMonthly= filespecificationlist[0].Frequency__c=='Semi-Monthly' ? true:false;
            //Intervals for Semi-Monthly PERIOD 1 are from theFirstOfMonth to the15thOfMonth
            //Intervals for Semi-Monthly PERIOD 2 are from the16thOfLastMonth  to theEndOfLastMonth
            //From the 16th to the last day of Month, generate semi-monthly files for the PERIOD 2 
            Boolean isAfter16 = Date.Today().Day() >= 16 ? true : false;
            if(isAfter16 && isSemiMonthly) theFirstOfMonth  = Date.newInstance(Date.TODAY().Year(), Date.TODAY().month(),1);
            if(isAfter16 && isSemiMonthly) theEndOfMonth    = Date.newInstance(Date.TODAY().Year(), Date.TODAY().month(),16);
            //From the first to the 15 of the month, generate semi-monthly files for the PERIOD 1
                    
            if(isAfter16==false && isSemiMonthly) theFirstOfMonth  = Date.TODAY().toStartOfMonth().addMonths(-1).addDays(16);
            if(isAfter16==false && isSemiMonthly) theEndOfMonth    = Date.newInstance(Date.TODAY().Year(), Date.TODAY().month(),1);
  
            if(isSemiMonthly) STARTDAY='>='+String.valueOf(theFirstOfMonth);
            if(isSemiMonthly) ENDDAY='<'+String.valueOf(theEndOfMonth);
            
            // Ordering for Delta always based on record Id, ignoring the value of Product_Type, Order_By, GSS_MDP_Sort_Key_Formula.
            // MDP file does not have delta. therefore this limitation will not affect MDP file generation
            String Delta_Order_Clause = Order_Clause+', CreatedDate ASC';
           
            //String Delta_Where_Last_Retrieved_Id = ' AND Related_GDP_Product_Account_View__c > \'';
            
            DeltaPeriodSOQL += ' AND DeltaLastModifiedDate__c '+STARTDAY;
            if (ENDDAY!='') DeltaPeriodSOQL += ' AND DeltaLastModifiedDate__c '+ENDDAY;
            //DeltaPeriodSOQL += ' AND Related_GDP_Product_Account_View__c > \'' + lastRetrievedRecordId + '\'';
            //DeltaPeriodSOQL += Delta_Where_Last_Retrieved_Id + lastRetrievedRecordId + '\'';
            DeltaPeriodSOQL += Delta_GDP_Account_SOQL;
            DeltaPeriodSOQL += Delta_Order_Clause;
            DeltaPeriodSOQL += ' LIMIT  ' + (NEW_BATCH_SIZE*4*30 > 50000 ? 50000 : NEW_BATCH_SIZE*4*30);
          
            DeltaPeriodSOQL = DeltaPeriodSOQL.replaceAll('(?i)object.Id','Related_GDP_Product_Account_View__c');
            DeltaPeriodSOQL = DeltaPeriodSOQL.replaceAll('(?i)object.','Related_GDP_Product_Account_View__r.');

            system.debug('DeltaPeriodSOQL: '+DeltaPeriodSOQL);
            
            
            //This map converts a list of Change code to a single change code
            map<String,String> deltaChangeMatrixMap = new map<String,String>();
            deltaChangeMatrixMap.put('AA','A');
            
            deltaChangeMatrixMap.put('AB','A');
            deltaChangeMatrixMap.put('BB','B');
            deltaChangeMatrixMap.put('CB','B');
            
            deltaChangeMatrixMap.put('AC','A');
            deltaChangeMatrixMap.put('BC','B');
            deltaChangeMatrixMap.put('CC','C');
            deltaChangeMatrixMap.put('DC','C');
            
            deltaChangeMatrixMap.put('CD','D');
            deltaChangeMatrixMap.put('DD','D');
            
            //deltaChangeMatrixMap.put('BA','');  //NA Should never happen
            //deltaChangeMatrixMap.put('CA','');  //NA Should never happen
            //deltaChangeMatrixMap.put('DA','');  //NA Should never happen          
            //deltaChangeMatrixMap.put('DB','');  //SEND NOTHING  OR send C??? Confirm with BA        
            //deltaChangeMatrixMap.put('AD','');  //SEND NOTHING
            //deltaChangeMatrixMap.put('BD','');  //SEND NOTHING   
            //Get all the changes for the speficic period and reference FileSpecification from the Delta update object
            for(GDP_Delta__c Delta : Database.Query(DeltaPeriodSOQL))
            {
                String Key = /*Delta.GDP_File_Description__c +'|'+ */ Delta.Related_GDP_Product_Account_View__c;
                //Merge consecutive code into first and Last code  ACCCCDB will become AB
                if(deltaChangeCodeMap.containsKey(Key)){
                        //Change code detected for this record. Change the last change code to the current change
                        deltaChangeCodeMap.put(Key,
                                                deltaChangeCodeMap.get(Key).Left(1)  //First change Code of sequence
                                                +Delta.Change_Code__c );             //Last change Code of sequence
                }
                else{
                    //First change code detected for a record (First code == last code)
                    deltaChangeCodeMap.put(Key, 
                                            Delta.Change_Code__c                     //First change Code of sequence
                                            + Delta.Change_Code__c);                 //Last change Code of sequence (same as first)
                }                              
            }
            
            
                     
            if (IsTestMode) deltaChangeCodeMap.put('test','AB');
            //Now that the list of DeltaChange code are in the deltaChangeCodeMap, 
            //iterate to replace that code list with a single change code
            for(String key : deltaChangeCodeMap.keySet()){
                if(deltaChangeMatrixMap.containsKey(deltaChangeCodeMap.get(key))){
                    deltaChangeCodeMap.put(key, 
                                           deltaChangeMatrixMap.get(deltaChangeCodeMap.get(key)));    
                }
                else{
                    //Do nothing: do not send the change in the Delta file
                    // 2015-11-16 [Samy]: Fix issue [GDP-322] Inconsistent delta code for same frequency of the delta (semi-monthly)
                    deltaChangeCodeMap.remove(key); 
                }
            }  
            if (IsTestMode) deltaChangeCodeMap.put('test','AB');
            //Build the Where clause with unique Records comming from the Delta Change object reduced with one code per record
            if(deltaChangeCodeMap.keyset().size() > 0)
            {
             /*   String idString = '(\'';
                for (Id thisId : deltaChangeCodeMap.keyset()) {
                    idString += thisId + '\',\'';
                }
                idString = idString.substring(0,idString.length()-2); 
                idString += ')';
                Where_Magnitude_SOQL = ' AND Id IN '+ idString;  
            */
                deltaChangeCodeIdSet = deltaChangeCodeMap.keyset();
                Where_Magnitude_SOQL = ' AND Id IN: deltaChangeCodeIdSet ';
                system.debug('deltaChangeCodeIdSet: '+deltaChangeCodeIdSet);
                System.debug('Where_Magnitude_SOQL: '+Where_Magnitude_SOQL);                
            }
            else{ Where_Magnitude_SOQL = ' AND Id =\'000000000000000000\''; }
            
        } // end if ISDELTA 
        //For the perpuse of the test coverage
        if (IsTestMode) {ISDELTA=false; Where_Magnitude_SOQL=''; DeltaPeriodSOQL =  '';}
        /**** GDP-228  end ****/
        
            
        
        FieldStructureCls fieldstructure= new FieldStructureCls();
            
        //Extract Address Fields
        String AccountView_Field_API='';
        String Address_Field_API='';
        String Address_FieldAPIList='';
        String Airline_Field_API= '';
        String Territory_Field_API=''; 
        
        //Reference is imposing the configuration otherwise take the regular configuration
        fieldstructure.LoadFieldStructure(
                        filespecificationlist[0].Reference__c!=null ? filespecificationlist[0].Reference__r.Field_API__c : filespecificationlist[0].Field_API__c
                        ,filespecificationlist[0].Reference__c!=null ? filespecificationlist[0].Reference__r.Field_Type__c :filespecificationlist[0].Field_Type__c
                        ,filespecificationlist[0].Reference__c!=null ? filespecificationlist[0].Reference__r.Field_Visible__c : filespecificationlist[0].Field_Visible__c
                        ,filespecificationlist[0].Reference__c!=null ? filespecificationlist[0].Reference__r.Field_Filter__c : filespecificationlist[0].Field_Filter__c
                        ,filespecificationlist[0].Reference__c!=null ? filespecificationlist[0].Reference__r.Field_Filter_Value__c : filespecificationlist[0].Field_Filter_Value__c
                        ,filespecificationlist[0].Reference__c!=null ? filespecificationlist[0].Reference__r.Field_Object_Name__c : filespecificationlist[0].Field_Object_Name__c
                        ,filespecificationlist[0].Reference__c!=null ? filespecificationlist[0].Reference__r.Field_Group__c : filespecificationlist[0].Field_Group__c
                        );
        
        // ----------------------------------------------------------------
        // Build the query for GDP_Products_Account_View
        //Get Query to return results - use of escapeSingleQuotes to avoid SOQL injection
        //Build logic to retrieve next batch of records
        
        
        
        AccountView_Field_API=fieldstructure.ExtractFieldSQL('GDP_Products_Account_View__c');
        
        DynamicSQL = 'Select Id, GSS_MDP_Sort_Key_Formula__c, '
                            + AccountView_Field_API.Replace('Id,','')
                            +' From GDP_Products_Account_View__c '
                            +' Where Id!=null ';
        
        //Build the object based on returned query value   
        FilePayload myFilePayload = new FilePayload();
        List<string> recordValueList = new List<string>();
        Set<Id> idaccountviewset = new Set<Id>();
        Set<Id> idairlineset = new Set<Id>();
        myObjectRecordList = new List<GDP_Products_Account_View__c>();
        SOQL = String.escapeSingleQuotes(DynamicSQL); 
        //SOQL+=' AND Id > \'' + lastRetrievedRecordId + '\'' 
        SOQL+= Where_Last_Retrieved_Id + lastRetrievedRecordId + '\''
                             + Where_Class_SOQL
                             + Where_Magnitude_SOQL
                             + Where_Geo_Coverage_SOQL
                             + Where_Reference_Clause
                             + Order_Clause
                             +' Limit ' + NEW_BATCH_SIZE ;
        System.debug('SOQL: '+ SOQL);
        SOQL = SOQL.replaceAll('(?i)object.','');
        String MasterSOQL=SOQL;
        myObjectRecordList  = database.query(SOQL);
        myFilePayload.SOQL=DeltaPeriodSOQL;
        
            //TODO:Build unique set of GDP_Account_View Ids
            //Retrieve the Airline and Territory and Address Information for the given list of GDP_Account_View Ids 
            //Build a map to load the three level of information
            // -- Agency
            //    -- Mailing and Location Address
            //    -- Airline
            //        -- Territory
            Map<Id, DataStructureCls> datastructure = new Map<Id, DataStructureCls>(); 
            for (GDP_Products_Account_View__c myObjectRecord : myObjectRecordList){
                  DataStructureCls ds=new DataStructureCls(myObjectRecord);
                  datastructure.put(myObjectRecord.Id,ds);
                  idaccountviewset.add(myObjectRecord.Id);
                  //System.Debug('myObjectRecord.Id >>>'+myObjectRecord.Id);
            }
            //TODO: Does it exist any Mailing or Location addresses to the file fields definition
            //Read the addresses from GDP_Address__c
            List<GDP_Address__c> myAddressList = new List<GDP_Address__c>();
            Address_Field_API=fieldstructure.ExtractFieldSQL('GDP_Address__c');
            System.Debug('Address_Field_API  >>>'+Address_Field_API );
            If (Address_Field_API!='')
            {
                //Build the DynamicSQL for the addresses
                Address_Field_API =Address_Field_API.Replace('Address_Type__c,','');
                DynamicSQL = 'Select Id,Related_GDP_Products_Account_View__c, Address_Type__c, '
                                + Address_Field_API
                                +' From GDP_Address__c '
                                +' WHERE Related_GDP_Products_Account_View__c in :idaccountviewset'
                                +' Order by Related_GDP_Products_Account_View__c';
                // System.Debug('idaccountviewset >>>'+idaccountviewset.Size());
                // System.Debug('DynamicSQL >>>'+DynamicSQL);
                
                SOQL = String.escapeSingleQuotes(DynamicSQL);
                myAddressList  = database.query(SOQL);
                for (GDP_Address__c addressRecord: myAddressList ){
                    //System.Debug('addressRecord >>>'+addressRecord);
                    DataStructureCls ds = (DataStructureCls) datastructure.get(addressRecord.Related_GDP_Products_Account_View__c);
                    if (addressRecord.Address_Type__c=='Mailing')  ds.MailingAddress = addressRecord;
                    if (addressRecord.Address_Type__c=='Location') ds.LocationAddress= addressRecord;
                    //idairlineset.add(airlineRecord.Id);
                }
            }
            //TODO:Sub objects to read
            String[] ObjectList = new string[]  {'GDP_Phone__c'
                                    ,'Agency_Owner__c'
                                    ,'GDP_Agency_Profile_Specialization__c'
                                    ,'Account_Category__c'
                                    ,'GDS__c'
                                    ,'Adjacent_Airport__c'
                                    ,'Assoc_Affiliation_Membership__c'
                                    ,'Accreditation__c'
                                    };
                                    
            
            for(String stringObjectName:ObjectList)
            {
                String Object_Field_API=fieldstructure.ExtractFieldSQL(stringObjectName);
                If (Object_Field_API!='')
                {
                    //Build the DynamicSQL for the addresses
                    //TODO: Filter Field to Extract to inject in the Query Filter Filer = Filter Value
                    String FilterClause = fieldstructure.ExtractFilterSOQL(stringObjectName);
                    String Object_Filters=fieldstructure.ExtractFilterSQL(stringObjectName, Object_Field_API);
                    //Query Builder
                    DynamicSQL = 'Select Id,Related_GDP_Products_Account_View__c,'
                                    + String.escapeSingleQuotes(Object_Field_API)
                                    + String.escapeSingleQuotes(Object_Filters)
                                    +' From '+stringObjectName
                                    +' WHERE Related_GDP_Products_Account_View__c in :idaccountviewset'
                                    + FilterClause
                                    +' Order by Related_GDP_Products_Account_View__c';
                    List<SObject> mySObjectList = new List<SObject>();
                    SOQL = String.escapeSingleQuotes(DynamicSQL); 
                    System.debug('DynamicSQL: '+ DynamicSQL); 
                    mySObjectList  = database.query(DynamicSQL);
                    String mapkey='';
                    String uniquekey='';
                    //TODO: Build the uniqueness of the key per object
                    String[] ObjectUniqueFilterValue = fieldstructure.ExtractUniqueFilterValue(stringObjectName);
                    // key value = Object name + id or Filter value
                    Set<String> filterkey = new Set<String>();
                    for (SObject objectRecord: mySObjectList ){
                        //System.Debug('objectRecord >>>'+objectRecord);
                        Id objectkey=(Id) objectRecord.get('Related_GDP_Products_Account_View__c');
                        DataStructureCls ds = (DataStructureCls) datastructure.get(objectkey);
                        mapkey=objectRecord.Id; 
                        uniquekey =  mapkey;
                        //TODO: Let see if filter value exist if so the unique key = object name + filter value
                        //TODO: Making sure the key is built according to the filter value 
                        
                        if (filterkey.Contains(uniquekey)) continue;
                        //Assign each object to the right Map
                        if (stringObjectName=='GDP_Phone__c') {ds.Phones.Put(mapkey,(GDP_Phone__c) objectRecord); continue;}
                        if (stringObjectName=='Agency_Owner__c') {ds.Owners.Put(mapkey,(Agency_Owner__c) objectRecord); continue;}
                        if (stringObjectName=='GDP_Agency_Profile_Specialization__c') {ds.Profiles.Put(mapkey,(GDP_Agency_Profile_Specialization__c) objectRecord); continue;}
                        if (stringObjectName=='Account_Category__c') {ds.Categories.Put(mapkey,(Account_Category__c) objectRecord); continue;}
                        if (stringObjectName=='GDS__c') {ds.GDSs.Put(mapkey,(GDS__c) objectRecord); continue;}
                        if (stringObjectName=='Adjacent_Airport__c') {ds.Airports.Put(mapkey,(Adjacent_Airport__c) objectRecord); continue;}
                        if (stringObjectName=='Assoc_Affiliation_Membership__c') {ds.Affiliations.Put(mapkey,(Assoc_Affiliation_Membership__c) objectRecord); continue;}
                        if (stringObjectName=='Accreditation__c') {ds.Accreditations.Put(mapkey,(Accreditation__c) objectRecord); continue;}
                        
                        
                        //idairlineset.add(airlineRecord.Id);
                    }
                }
            }
            //Just in case where the list is not empty
            List<Accreditation__c> myAirlineList = new List<Accreditation__c>();
            List<GSA_Territory__c> myTerritoryList = new List<GSA_Territory__c>();
            
            Airline_Field_API=fieldstructure.ExtractFieldSQL('Accreditation__c');
            if (Airline_Field_API!='')
            {
                //Build the DynamicSQL for the airlines
                DynamicSQL = 'Select Id, Related_GDP_Products_Account_View__c, '
                                + Airline_Field_API 
                                +' From Accreditation__c '
                                +' WHERE Related_GDP_Products_Account_View__c=:idaccountviewset'
                                +'  Order by Related_GDP_Products_Account_View__c';
                
                SOQL = String.escapeSingleQuotes(DynamicSQL);
                myAirlineList  = database.query(SOQL);
                //TODO:Build unique set of GDP_Account_View Ids
                //Retrieve the Airline Information for the given list of GDP_Account_View Ids
                //Add To the Data Structure datastructure map variable
                for (Accreditation__c airlineRecord: myAirlineList ){
                    DataStructureCls ds = (DataStructureCls) datastructure.get(airlineRecord.Related_GDP_Products_Account_View__c);
                    ds.Airlines.add(new AirlineCls(airlineRecord));
                    idairlineset.add(airlineRecord.Id);
                }
                Territory_Field_API=fieldstructure.ExtractFieldSQL('GSA_Territory__c');
                if (Territory_Field_API!='')
                {
                    //Build the DynamicSQL for the territories linked to the airlines
                    DynamicSQL = 'Select Id, Related_Accreditation__c, Related_Accreditation__r.Related_GDP_Products_Account_View__c, '
                                    +  Territory_Field_API
                                    +' From GSA_Territory__c '
                                    +' WHERE Related_Accreditation__c=:idairlineset'
                                    +' Order by Related_Accreditation__r.Related_GDP_Products_Account_View__c, Related_Accreditation__c, Id';
                    
                    SOQL = String.escapeSingleQuotes(DynamicSQL);
                    myTerritoryList  = database.query(SOQL);
                    for ( GSA_Territory__c territoryRecord: myTerritoryList ){
                        DataStructureCls ds = (DataStructureCls) datastructure.get(territoryRecord.Related_Accreditation__r.Related_GDP_Products_Account_View__c);
                        for(AirlineCls airline_cls: ds.Airlines)
                        {
                            if (airline_cls.Airline.id==territoryRecord.Related_Accreditation__c)
                            {
                                airline_cls.Territories.add(territoryRecord);
                            }
                        }
                        //idairlineset.add(airlineRecord.Id);
                    } // end for myTerritoryList
                }
            }
            
            
            //Get a map of all sObject fields
            Integer TYPE_API=0, TYPE_TYPE=1, TYPE_VISIBLE=2, TYPE_OBJECT=3, TYPE_FILTER=4, TYPE_VALUE=5;
            String[] Airline_FieldAPIList= fieldstructure.ExtractListByGroup(TYPE_API,'Airline');
            String[] Airline_FieldTypeList= fieldstructure.ExtractListByGroup(TYPE_TYPE,'Airline');
            System.Debug('objectrecord Airline_FieldAPIList Size >>>'+Airline_FieldAPIList.Size());
            System.Debug('objectrecord Airline_FieldAPIList >>>'+Airline_FieldAPIList);
            String[] Airline_FieldVisibleList= fieldstructure.ExtractListByGroup(TYPE_VISIBLE,'Airline');
            String[] Airline_FieldObjectList= fieldstructure.ExtractListByGroup(TYPE_OBJECT,'Airline');
            String[] Airline_FieldFilterList= fieldstructure.ExtractListByGroup(TYPE_FILTER,'Airline');
            String[] Airline_FieldFilterValueList= fieldstructure.ExtractListByGroup(TYPE_VALUE,'Airline');
            
            String[] Territory_FieldAPIList= fieldstructure.ExtractListByGroup(TYPE_API,'Airline');
            String[] Territory_FieldVisibleList= fieldstructure.ExtractListByGroup(TYPE_VISIBLE,'Airline');
                        
            String[] FieldAPIList= fieldstructure.ExtractListByGroup(TYPE_API,'Agency');
            String[] FieldTypeList= fieldstructure.ExtractListByGroup(TYPE_TYPE,'Agency');
            String[] FieldFilterList= fieldstructure.ExtractListByGroup(TYPE_FILTER,'Agency');
            String[] FieldFilterValueList= fieldstructure.ExtractListByGroup(TYPE_VALUE,'Agency');
            String[] FieldVisibleList= fieldstructure.ExtractListByGroup(TYPE_VISIBLE,'Agency');
            String[] FieldObjectList= fieldstructure.ExtractListByGroup(TYPE_OBJECT,'Agency');
            
            
            for (DataStructureCls myObjectRecord : datastructure.Values()){
                //Initialize RecordValue List
                //Iterate the list of ordered fields and build record based on list of fields
                //Process the Agency Record Fields
                Integer Fieldindex=-1;              
                for(string strAPIFieldName : FieldAPIList){
                    string fieldContent ='';
                    Fieldindex++;
                    if (FieldObjectList[Fieldindex]=='Reserve') continue;

/**** GDP-228 Start ****/  
                    if (FieldObjectList[Fieldindex]==''){ //No objects are associated with functions
                        if (strAPIFieldName == 'Function_RecID'){
                            //This will return the Change Code for this GDP_Product_Account_View__c Id
                            system.debug('  : '+deltaChangeCodeMap);
                            fieldContent = '  ';
                            if (ISDELTA) fieldContent = deltaChangeCodeMap.get(String.valueOf(myObjectRecord.AccountView.Id));
                        }
                        if (strAPIFieldName == 'Function_FileID_Member' && ISDELTA) fieldContent ='AC';
                        if (strAPIFieldName == 'Function_FileID_Member' && ISMASTER) fieldContent ='AM';
                        if (strAPIFieldName == 'Function_FileID_NonMember' && ISDELTA) fieldContent ='TC';
                        if (strAPIFieldName == 'Function_FileID_NonMember' && ISMASTER) fieldContent ='TM';
                    } 
 /**** GDP-228 End ****/    
                    if (FieldObjectList[Fieldindex]=='GDP_Products_Account_View__c' )
                    {
                        system.debug('strAPIFieldName '+strAPIFieldName);
                        if (strAPIFieldName.Contains('__r.'))
                        {
                            string[] fieldname= strAPIFieldName.Split('\\.');
                            //System.Debug('fieldname >>>'+strAPIFieldName);
                            try {
                                 fieldContent = String.valueOf(myObjectRecord.AccountView.getSObject(fieldname[0]).get(fieldname[1]));
                                }catch(Exception e) {}
                        }
                        
                        else{
                            fieldContent = String.valueOf(myObjectRecord.AccountView.get(strAPIFieldName));
                        }
                    }
                    else if (FieldObjectList[Fieldindex]=='GDP_Address__c')
                    {
                        
                        if (strAPIFieldName.Contains('__r.'))
                           {
                            string[] fieldname= strAPIFieldName.Split('\\.');
                            try {
                                if (myObjectRecord.MailingAddress!=null && FieldFilterValueList[Fieldindex]=='Mailing') fieldContent = String.valueOf(myObjectRecord.MailingAddress.getSObject(fieldname[0]).get(fieldname[1]));
                                if (myObjectRecord.LocationAddress!=null && FieldFilterValueList[Fieldindex]=='Location') fieldContent = String.valueOf(myObjectRecord.LocationAddress.getSObject(fieldname[0]).get(fieldname[1]));
                                }catch(Exception e) {}
                            }
                        else
                        {
                            if (myObjectRecord.MailingAddress!=null && FieldFilterValueList[Fieldindex]=='Mailing') fieldContent = String.valueOf(myObjectRecord.MailingAddress.get(strAPIFieldName));
                            if (myObjectRecord.LocationAddress!=null && FieldFilterValueList[Fieldindex]=='Location') fieldContent = String.valueOf(myObjectRecord.LocationAddress.get(strAPIFieldName));
                        }
                         
                    }
                 else if (FieldObjectList[Fieldindex]=='GDP_File_Description__c' )
                    {
                        system.debug('strAPIFieldName '+strAPIFieldName);
                        if (strAPIFieldName.Contains('__r.'))
                        {
                            string[] fieldname= strAPIFieldName.Split('\\.');
                            //System.Debug('fieldname >>>'+strAPIFieldName);
                            try {
                                 fieldContent = String.valueOf(filespecificationlist[0].getSObject(fieldname[0]).get(fieldname[1]));
                                }catch(Exception e) {}
                        }
                        
                        else{
                            fieldContent = String.valueOf(filespecificationlist[0].get(strAPIFieldName));
                        }
                    }
                    else if (FieldObjectList[Fieldindex]=='GDP_File_Production__c' )
                    {
                        system.debug('strAPIFieldName '+strAPIFieldName);
                        try {
                            if (strAPIFieldName.Contains('__r.'))
                            {
                                string[] fieldname= strAPIFieldName.Split('\\.');
                                //System.Debug('fieldname >>>'+strAPIFieldName);
                                 fieldContent = String.valueOf(fileproductionlist[0].getSObject(fieldname[0]).get(fieldname[1]));
                                    
                            }
                            
                            else{
                                fieldContent = String.valueOf(fileproductionlist[0].get(strAPIFieldName));
                            }
                        }catch(Exception e) {}
                    }
                    else 
                    {
                        //System.Debug('Index_fieldname >>>'+Fieldindex);
                        string ObjectMapId  = myObjectRecord.RetrieveObjectMapId(FieldObjectList[Fieldindex]
                                                                                ,FieldFilterList[Fieldindex]
                                                                                ,FieldFilterValueList[Fieldindex]);
                        if (ObjectMapId!='')
                        {
                            if (strAPIFieldName.Contains('__r.'))
                            {
                                string[] fieldname= strAPIFieldName.Split('\\.');
                                //System.Debug('fieldname >>>'+strAPIFieldName);
                                try {
                                    if (FieldObjectList[Fieldindex]=='GDP_Phone__c') fieldContent = String.valueOf(myObjectRecord.Phones.get(ObjectMapId).getSObject(fieldname[0]).get(fieldname[1]));
                                    if (FieldObjectList[Fieldindex]=='Agency_Owner__c') fieldContent = String.valueOf(myObjectRecord.Owners.get(ObjectMapId).getSObject(fieldname[0]).get(fieldname[1]));
                                    if (FieldObjectList[Fieldindex]=='GDP_Agency_Profile_Specialization__c') fieldContent = String.valueOf(myObjectRecord.Profiles.get(ObjectMapId).getSObject(fieldname[0]).get(fieldname[1]));
                                    if (FieldObjectList[Fieldindex]=='Account_Category__c' ) fieldContent = String.valueOf(myObjectRecord.Categories.get(ObjectMapId).getSObject(fieldname[0]).get(fieldname[1]));
                                    if (FieldObjectList[Fieldindex]=='GDS__c' ) fieldContent = String.valueOf(myObjectRecord.GDSs.get(ObjectMapId).getSObject(fieldname[0]).get(fieldname[1]));
                                    if (FieldObjectList[Fieldindex]=='Adjacent_Airport__c') fieldContent = String.valueOf(myObjectRecord.Airports.get(ObjectMapId).getSObject(fieldname[0]).get(fieldname[1]));
                                    if (FieldObjectList[Fieldindex]=='Assoc_Affiliation_Membership__c' ) fieldContent = String.valueOf(myObjectRecord.Affiliations.get(ObjectMapId).getSObject(fieldname[0]).get(fieldname[1]));
                                    if (FieldObjectList[Fieldindex]=='Accreditation__c' ) fieldContent = String.valueOf(myObjectRecord.Accreditations.get(ObjectMapId).getSObject(fieldname[0]).get(fieldname[1]));
                                        
                                }catch(Exception e) {}
                            }
                            else
                            {
                                if (FieldObjectList[Fieldindex]=='GDP_Phone__c') fieldContent = String.valueOf(myObjectRecord.Phones.Get(ObjectMapId).get(strAPIFieldName));
                                if (FieldObjectList[Fieldindex]=='Agency_Owner__c') fieldContent = String.valueOf(myObjectRecord.Owners.Get(ObjectMapId).get(strAPIFieldName));
                                if (FieldObjectList[Fieldindex]=='GDP_Agency_Profile_Specialization__c') fieldContent = String.valueOf(myObjectRecord.Profiles.Get(ObjectMapId).get(strAPIFieldName));
                                if (FieldObjectList[Fieldindex]=='Account_Category__c' )  fieldContent = String.valueOf(myObjectRecord.Categories.Get(ObjectMapId).get(strAPIFieldName));
                                if (FieldObjectList[Fieldindex]=='GDS__c' ) fieldContent = String.valueOf(myObjectRecord.GDSs.Get(ObjectMapId).get(strAPIFieldName));
                                if (FieldObjectList[Fieldindex]=='Adjacent_Airport__c') fieldContent = String.valueOf(myObjectRecord.Airports.Get(ObjectMapId).get(strAPIFieldName));
                                if (FieldObjectList[Fieldindex]=='Assoc_Affiliation_Membership__c' ) fieldContent = String.valueOf(myObjectRecord.Affiliations.Get(ObjectMapId).get(strAPIFieldName));
                                if (FieldObjectList[Fieldindex]=='Accreditation__c' ) fieldContent = String.valueOf(myObjectRecord.Accreditations.Get(ObjectMapId).get(strAPIFieldName));
                            }
                        }
                    }
                    /*
                    ,'Agency_Owner__c'
                                    ,'GDP_Agency_Profile_Specialization__c'
                                    ,'Account_Category__c'
                                    ,'GDS__c'
                                    ,'Adjacent_Airport__c'
                                    ,'Assoc_Affiliation_Membership__c'*/
                                    
                    if (fieldContent == null) fieldContent = '';
                    //TODO: validate the field format (date, number...)
                    //May have transformation to do according of type below
                    //DateTime YYYYMMDDHHMMSS
                    //Date YYYMMDD
                    //Decimal 0
                    //Decimal 1
                    //Decimal 2
                    //Decimal 3          
                    //Make sure to blank when not visible
                    if (FieldTypeList[Fieldindex]=='Boolean' &&  fieldContent=='true') fieldContent='Y';
                    if (FieldTypeList[Fieldindex]=='Boolean' &&  fieldContent=='false') fieldContent='N';
                    if (FieldTypeList[Fieldindex]=='Boolean' &&  fieldContent=='') fieldContent='N';
                    if (FieldVisibleList[Fieldindex]=='1' && fieldContent!= '')  fieldContent = fieldstructure.TransformDate(FieldTypeList[Fieldindex], fieldContent);
                    if (FieldVisibleList[Fieldindex]!='1' && fieldContent!= '')  fieldContent = '';
                    fieldstructure.AgencyRecordValue[Fieldindex]=fieldContent;
                    if (TestMode) fieldstructure.AgencyRecordValue[Fieldindex]=strAPIFieldName+':'+fieldContent;
                    
                    
                    
                }
                //Addition of the Agency record Line
                Record myAgencyRecordValue  = new Record(fieldstructure.AgencyRecordValue, AGENCY_CODE,myObjectRecord.AccountView.Id);
                myFilePayload.FileRecords.add(myAgencyRecordValue );
                myFilePayload.LastRecordID = myObjectRecord.AccountView.Id;  
                //if (filespecificationlist[0].Reference__r.Product_Type__c == 'MDP') {
                if (filespecificationlist[0].Order_By__c != null) {
                    //myFilePayload.LastRecordID =  EncodingUtil.urlEncode( myObjectRecord.AccountView.MDP_Sort_Key_Formula__c, ENCODING_SCHEME);
                    myFilePayload.LastRecordID =  EncodingUtil.urlEncode( (String) myObjectRecord.AccountView.get(filespecificationlist[0].Order_By__c), ENCODING_SCHEME);
                }
                
                myFilePayload.SOQL=MasterSOQL;
                
                //Process of the Airline Record Fields
                if (Airline_FieldAPIList.Size()>1)
                    for(AirlineCls myAirlineRecord:myObjectRecord.Airlines)
                    {
                        Fieldindex=0;
                        for(string strAPIFieldName : Airline_FieldAPIList){
                            string fieldContent = '';
                            if (Airline_FieldObjectList[Fieldindex]==''){ //No objects are associated with functions
                                if (strAPIFieldName == 'Function_RecID') fieldContent = 'R';
                                if (strAPIFieldName == 'Function_FileID') fieldContent ='  '; 
                                // 2060304 addition: Territory should also have the Function_FileID for member or non member
                                if (strAPIFieldName == 'Function_FileID_Member' && ISDELTA) fieldContent ='AC';
                                if (strAPIFieldName == 'Function_FileID_Member' && ISMASTER) fieldContent ='AM';
                                if (strAPIFieldName == 'Function_FileID_NonMember' && ISDELTA) fieldContent ='TC';
                                if (strAPIFieldName == 'Function_FileID_NonMember' && ISMASTER) fieldContent ='TM';
                            } 
                            if  (Airline_FieldObjectList[Fieldindex]=='GDP_Products_Account_View__c' )
                            {
                                if (strAPIFieldName.Contains('__r.'))
                                {
                                    string[] fieldname= strAPIFieldName.Split('\\.');
                                    //System.Debug('fieldname >>>'+strAPIFieldName);
                                    try {
                                        fieldContent = String.valueOf(myObjectRecord.AccountView.getSObject(fieldname[0]).get(fieldname[1]));
                                        }catch(Exception e) {}
                                }
                                else
                                    fieldContent = String.valueOf(myObjectRecord.AccountView.get(strAPIFieldName));
                            }
                            if  (Airline_FieldObjectList[Fieldindex]=='Accreditation__c' )
                            {
                                string ObjectMapId  = myObjectRecord.RetrieveObjectMapId(Airline_FieldObjectList[Fieldindex]
                                                                                ,Airline_FieldFilterList[Fieldindex]
                                                                                ,Airline_FieldFilterValueList[Fieldindex]);
                                if (ObjectMapId!='')
                                {
                                    if (strAPIFieldName.Contains('__r.'))
                                       {
                                        string[] fieldname= strAPIFieldName.Split('\\.');
                                        //System.Debug('fieldname >>>'+strAPIFieldName);
                                        try {
                                            fieldContent = String.valueOf(myAirlineRecord.Airline.getSObject(fieldname[0]).get(fieldname[1]));
                                            }catch(Exception e) {}
                                       }
                                    else
                                       fieldContent = String.valueOf(myAirlineRecord.Airline.get(strAPIFieldName));
                                }
                                if (fieldContent == null) fieldContent = '';
                                //TODO: validate the field format (date, number...)
                                //May have transformation to do according of type below
                                //DateTime YYYYMMDDHHMMSS
                                //Date YYYMMDD
                                //Decimal 0
                                //Decimal 1
                                //Decimal 2
                                //Decimal 3                          
                                //Make sure to blank when not visible
                                
                            }
                            if (Airline_FieldTypeList[Fieldindex]=='Boolean' &&  fieldContent=='true') fieldContent='Y';
                            if (Airline_FieldTypeList[Fieldindex]=='Boolean' &&  fieldContent=='false') fieldContent='N';
                            if (Airline_FieldTypeList[Fieldindex]=='Boolean' &&  fieldContent=='') fieldContent='N';
                            if (Airline_FieldVisibleList[Fieldindex]=='1' && fieldContent!= '')  fieldContent = fieldstructure.TransformDate(Airline_FieldTypeList[Fieldindex], fieldContent);
                            if (Airline_FieldVisibleList[Fieldindex]!='1' && fieldContent!= '')  fieldContent = '';
                            fieldstructure.AirlineRecordValue[Fieldindex]=fieldContent;
                            if (TestMode) fieldstructure.AirlineRecordValue[Fieldindex]=strAPIFieldName;
                            Fieldindex++;
                            
                            
                        }
                        //Territories have to be in the same line as the airline
                        if (myAirlineRecord.Territories.size()>0)
                        {
                            Integer TerritoryIndex=1;
                            for(GSA_Territory__c myTerritoryRecord: myAirlineRecord.Territories)
                            {
                                
                                Fieldindex=-1;
                                
                                for(string strAPIFieldName : Airline_FieldAPIList){
                                    Fieldindex++;
                                    
                                    string fieldContent ='';
                                    if (Airline_FieldObjectList[Fieldindex]!='GSA_Territory__c') continue;
                                    //Condition filter 
                                    //Repeat 1
                                    //Repeat 2
                                    //Repeat n
                                    Integer fieldContentIndex = Integer.valueOf(Airline_FieldFilterValueList[Fieldindex]);
                                    if (fieldContentIndex!=TerritoryIndex) continue;
                                    fieldContent ='';
                                    //System.Debug('fieldname >>>'+strAPIFieldName);
                                    if (strAPIFieldName.Contains('__r.'))
                                       {
                                        string[] fieldname= strAPIFieldName.Split('\\.');
                                        //System.Debug('fieldname >>>'+strAPIFieldName);
                                        try {
                                            fieldContent = String.valueOf(myTerritoryRecord.getSObject(fieldname[0]).get(fieldname[1]));
                                        }catch(Exception e) {}
                                       }
                                    else
                                       fieldContent = String.valueOf(myTerritoryRecord.get(strAPIFieldName));
                                    if (fieldContent == null) fieldContent = '';
                                    //TODO: validate the field format (date, number...)
                                    //May have transformation to do according of type below
                                    //DateTime YYYYMMDDHHMMSS
                                    //Date YYYMMDD
                                    //Decimal 0
                                    //Decimal 1
                                    //Decimal 2
                                    //Decimal 3 
                                    //Make sure to blank when not visible
                                    if (Airline_FieldTypeList[Fieldindex]=='Boolean' &&  fieldContent=='true') fieldContent='Y';
                                    if (Airline_FieldTypeList[Fieldindex]=='Boolean' &&  fieldContent=='false') fieldContent='N';
                                    if (Airline_FieldTypeList[Fieldindex]=='Boolean' &&  fieldContent=='') fieldContent='N';
                                    if (Airline_FieldVisibleList[Fieldindex]=='1' && fieldContent!= '')  fieldContent = fieldstructure.TransformDate(Airline_FieldTypeList[Fieldindex], fieldContent);
                                    if (Airline_FieldVisibleList[Fieldindex]!='1' && fieldContent!= '')  fieldContent = '';
                                    fieldstructure.AirlineRecordValue[Fieldindex]=fieldContent;
                                    if (TestMode) fieldstructure.AirlineRecordValue[Fieldindex]=strAPIFieldName;
                                }
                                //Maximum of territory per airline
                                if (TerritoryIndex==MAX_TERRITORY) break;
                                TerritoryIndex++;
                                
                            } // end for myTerritoryRecord
                        } // end if myAirlineRecord
                        //Addition of the Agency record Line
                        // Bugfix GDP-320 
                        //Check if record is empty before adding it.
                        Boolean isEmptyDoNotSend = true;
                        //first 5 fields are technical fields and should be ignored
                        if (fieldstructure.AirlineRecordValue.size() > 5){
                            for(integer i = 5; i < fieldstructure.AirlineRecordValue.size(); i++)
                            {
                                if(fieldstructure.AirlineRecordValue[i].length() > 0)
                                {
                                    isEmptyDoNotSend = false;
                                    break;
                                }
                            }
                        }
                        //Only add record if there is something in it
                        if(!isEmptyDoNotSend){
                            Record myAirlineRecordValue = new Record(fieldstructure.AirlineRecordValue, AIRLINE_CODE,myObjectRecord.AccountView.Id);
                            myFilePayload.FileRecords.add(myAirlineRecordValue );
                            myFilePayload.LastRecordID = myObjectRecord.AccountView.Id;
                            //if (filespecificationlist[0].Reference__r.Product_Type__c == 'MDP') {
                            if (filespecificationlist[0].Order_By__c != null) {
                                //myFilePayload.LastRecordID =  EncodingUtil.urlEncode( myObjectRecord.AccountView.MDP_Sort_Key_Formula__c, ENCODING_SCHEME);
                                myFilePayload.LastRecordID =  EncodingUtil.urlEncode( (String) myObjectRecord.AccountView.get(filespecificationlist[0].Order_By__c), ENCODING_SCHEME);
                            }
                        }
                        
                    } // for airlineCls
            } // end for DataStructureCls myObjectRecord
            
            RestContext.response.statuscode = 200; 
            
        try{
            //Prepare response
            RestContext.response.addHeader('Content-Type', 'application/json');
            if(myObjectRecordList.size() == 0){
                RestContext.response.addHeader('done', 'true'); 
            }
            else
            {
                //Send the url used to retrieve next records
                RestContext.response.addHeader('done', 'false');    
                RestContext.response.addHeader('nextRecordURL',
                                            URL.getSalesforceBaseUrl().toExternalForm() 
                                            + RestContext.request.resourcePath /* '/GSS/v0/FileData/' */
                                            +'?FileSpecificationID='+FileSpecificationID
                                            +'&lastRetrievedRecordId='+myObjectRecordList[myObjectRecordList.size()-1].Id);       
            }  // end else 
            //Return FilePayload object 
            RestContext.response.responseBody = Blob.valueOf(json.serialize(myFilePayload));        
        } 
        catch(exception e){
            RestContext.response.statuscode = 400;
            RestContext.response.responseBody  = Blob.valueOf(
                
                'getCause()' + e.getCause() + '\n' +
                'getMessage()' + e.getMessage() + '\n' +
                'getLineNumber()' + e.getLineNumber() + '\n' +
                'getStackTraceString()' + e.getStackTraceString() + '\n' + 
                'getTypeName()' + e.getTypeName()   
            );
        } // end catch
        
    } // end of getFilePayload
    //Transform Date 
    
    // ========================================================================
    //Master Field Structure
    global class FieldStructureCls {
        public String[] FieldAPIName {get;set;}
        public String[] FieldType {get;set;}
        public String[] FieldVisible {get;set;}
        public String[] FieldFilter {get;set;}
        public String[] FieldFilterValue {get;set;}
        public String[] FieldObjectName {get;set;}
        public String[] FieldGroup {get;set;}
         //private String[] key;
          //Values
        public String[] AirlineRecordValue {get;set;}
        public String[] AgencyRecordValue {get;set;}
        public FieldStructureCls()
        {
        }
         public void LoadFieldStructure(String vFieldAPIName,
                                String vFieldType,
                                String vFieldVisible,
                                String vFieldFilter,
                                String vFieldFilterValue,
                                String vFieldObjectName,
                                String vFieldGroup){
                                    
            if (vFieldAPIName!=null) FieldAPIName=vFieldAPIName.Split('\\|'); //.ReplaceAll(', ',',').Split(',');
            if (vFieldType!=null) FieldType=vFieldType.Split('\\|'); //.ReplaceAll(', ',',').Split(',');
            if (vFieldVisible!=null) FieldVisible=vFieldVisible.Split('\\|'); //.ReplaceAll(', ',',').Split(',');
            if (vFieldFilter!=null) FieldFilter=vFieldFilter.Split('\\|'); //.ReplaceAll(', ',',').Split(',');
            if (vFieldFilterValue!=null) FieldFilterValue=vFieldFilterValue.Split('\\|'); //.ReplaceAll(', ',',').Split(',');
            if (vFieldObjectName!=null) FieldObjectName=vFieldObjectName.Split('\\|'); //.ReplaceAll(', ',',').Split(',');
            if (vFieldGroup!=null) FieldGroup=vFieldGroup.Split('\\|'); //.ReplaceAll(', ',',').Split(',');
            System.Debug('API_fieldname >>>'+FieldAPIName.Size());
            System.Debug('Type_fieldname >>>'+FieldType.Size());
            System.Debug('Visible_fieldname >>>'+FieldVisible.Size());
            System.Debug('Filter_fieldname >>>'+FieldFilter.Size());
            System.Debug('FilterValue_fieldname >>>'+FieldFilterValue.Size());
            System.Debug('Object_fieldname >>>'+FieldObjectName.Size());
            System.Debug('Group_fieldname >>>'+FieldGroup.Size());
            //build key
            /*
            String stringreturn='';
            
            for(String stringvalue:this.FieldAPIName)
            {
                
                if (m>0) stringreturn +=','; 
                stringreturn +=this.FieldObjectName[m]+'.'+stringvalue; 
                m++;
            }   
            
            this.key = stringreturn.Split(',');
            */
            //Agency
            integer mAgency=0;
            integer mAirline=0;
            integer i=-1;
            for(String stringvalue:this.FieldAPIName)
            {
                i++;
                if (FieldGroup[i]=='Agency') mAgency++; 
                if (FieldGroup[i]=='Airline') mAirline++; 
            } 
                 
            this.AgencyRecordValue = new String[mAgency];    
            this.AirlineRecordValue= new String[mAirline];
        } // end of LoadFieldStructure
        
        public String[] ExtractUniqueFilterValue(String ObjectName)
        {
            String stringreturn='';
            integer i=-1;
            integer m=0;
            String skey='';
            Set<String> vkey = new Set<String>();
            for(String stringvalue:this.FieldAPIName)
            {
                i++;
                if (this.FieldObjectName[i]!=ObjectName) continue;
                if (FieldFilter[i].Trim()=='' || FieldFilterValue[i].Trim()=='') continue;
                skey=FieldFilter[i].Trim() + '~'+ FieldFilterValue[i].Trim();
                if (vkey.contains(skey)) continue;
                if (m>0) stringreturn +='|';
                stringreturn +=skey;
                vkey.add(skey); 
                m++;
            }
            return stringreturn.Split('|');
        } // end of ExtractUniqueFilterValue
        
        public String ExtractFilterSOQL(String ObjectName)
        {
            String stringreturn='';
            integer i=-1;
            integer m=0;
            String skey='';
            Set<String> vkey = new Set<String>();
            // Make the describe call
            // Get the fields
            integer vtype=0;
            
            //Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
            //Map <String, Schema.SObjectField> fieldMap = schemamap.get(ObjectName).getDescribe().fields.getMap();
            Map <String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get(ObjectName).getDescribe().fields.getMap();
            
            system.debug('this.FieldObjectName >>>'+this.FieldObjectName.Size());
            system.debug('this.FieldAPIName >>>'+this.FieldAPIName.Size());
            system.debug('this.FieldFilter >>>'+this.FieldFilter.Size());
            
            for(String stringvalue:this.FieldAPIName)
            {
                try{
                    i++;              
                    //system.debug('stringvalue >>>'+stringvalue + 'Filter>>>'+ FieldFilter[i].Trim());              
                    if (this.FieldObjectName[i]!=ObjectName) continue;
                    if (FieldFilter[i].Trim()=='' || FieldFilterValue[i].Trim()=='') continue;
                    skey=FieldFilter[i].Trim() +  FieldFilterValue[i].Trim();
                    if (vkey.contains(skey)) continue;
                    if (m>0) stringreturn +=' OR ';
                    //TODO: Verify against DescribeObject what is the type of the field filter
                    vtype=0;
                
                    Schema.DisplayType fielddataType=fieldMap.get(FieldFilter[i].toLowerCase()).getDescribe().getType();
                
                    //Anything that does not need to be in between \'\'
                    if (fielddataType==Schema.DisplayType.Currency) vtype=2;
                    if (fielddataType==Schema.DisplayType.Percent) vtype=2;
                    if (fielddataType==Schema.DisplayType.Boolean) vtype=2;
                    if (fielddataType==Schema.DisplayType.Double) vtype=2;
                    if (fielddataType==Schema.DisplayType.Integer) vtype=2;
                    if (fielddataType==Schema.DisplayType.Picklist) vtype=1;
                    if (fielddataType==Schema.DisplayType.MultiPicklist) vtype=1;
                
                    //system.debug('stringvalue >>>'+FieldFilter[i].toLowerCase()+' '+vtype);
                    if (vtype==0)  
                        stringvalue =  '(' + FieldFilter[i] + '=\''+ FieldFilterValue[i] +'\')';
                    else if (vtype==1)
                        stringvalue =  '(' + FieldFilter[i] + ' IN (\''+ FieldFilterValue[i] +'\'))';
                    else
                        stringvalue =  '(' + FieldFilter[i] + '='+ FieldFilterValue[i] +')';
                    //system.debug('stringvalue >>>'+stringvalue);
                    stringreturn +=stringvalue;
                    vkey.add(skey);            
                    m++;
                }catch(Exception e) {}
            }
            if (stringreturn!='') stringreturn = ' AND ( '+stringreturn+' )';
            return stringreturn;
        }
        public String ExtractFieldSQL(String ObjectName)
        {
            String stringreturn='';
            integer i=-1;
            integer m=0;
            Set<String> vkey = new Set<String>();
            for(String stringvalue:this.FieldAPIName)
            {
                i++;
                if (this.FieldObjectName[i]!=ObjectName) continue;
                if (vkey.contains(stringvalue)) continue;
                if (m>0) stringreturn +=','; 
                stringreturn +=stringvalue;
                //System.debug(' fieldsSoql>>>>'+ObjectName+'.'+stringvalue);
                vkey.add(stringvalue);  
                m++;
            }
            return stringreturn;
        } // end of ExtractFieldSQL
        public String ExtractFilterSQL( String ObjectName, String SQOLField)
        {
            String stringreturn='';
            integer i=-1;
            integer m=0;
            Set<String> vkey = new Set<String>();
            String[] fieldinsoql=SQOLField.Split('\\,');
            for(String stringvalue:fieldinsoql)
            {
                vkey.add(stringvalue); 
            }
            for(String stringvalue:this.FieldFilter)
            {
                i++;
                if (this.FieldObjectName[i]!=ObjectName) continue;
                if (vkey.contains(stringvalue)) continue;
                if (m>0) stringreturn +=','; 
                stringreturn +=stringvalue;
                vkey.add(stringvalue); 
                m++;
            }
            if (stringreturn!='') stringreturn =','+stringreturn;
            return stringreturn;
        } // end of ExtractFieldSQL
        //Load by Group
        public String[] ExtractListByGroup(Integer TypeList, String ObjectName)
        {
            String stringreturn='';
            integer i=-1;
            integer m=0;
            String[] ValueList;
            //Set<String> vkey = new Set<String>();
            Integer TYPE_API=0, TYPE_TYPE=1, TYPE_VISIBLE=2, TYPE_OBJECT=3, TYPE_FILTER=4, TYPE_VALUE=5;
            
            if (TypeList==TYPE_API) ValueList = this.FieldAPIName;
            if (TypeList==TYPE_TYPE) ValueList = this.FieldType;
            if (TypeList==TYPE_VISIBLE) ValueList = this.FieldVisible;
            if (TypeList==TYPE_OBJECT) ValueList = this.FieldObjectName;
            if (TypeList==TYPE_FILTER) ValueList = this.FieldFilter;
            if (TypeList==TYPE_VALUE) ValueList = this.FieldFilterValue;
            for(String stringvalue:ValueList)
            {
                i++; 
                if (this.FieldGroup[i]!=ObjectName) continue;
                //if (vkey.contains(this.key[i])) continue;
                if (m>0) stringreturn +=','; 
                stringreturn +=stringvalue; 
                //vkey.add(key[i]); 
                m++;
            }
            //if (stringreturn=='') return null;
            return stringreturn.Split(',');
        } // end of ExtractListByGroup
        //Load By Object
        
        public String TransformDate(String vFormat, String vValue)
        {
            if (!vFormat.Contains('Date')) return vValue;
            
            if (vValue.Trim().Length()<10) return vValue;
            
            if (vFormat=='Date YYYYMMDD') 
            {
                vValue=vValue.Trim();
                vValue = vValue.Substring(0,4)+vValue.Substring(5,7)+vValue.Substring(8,10);
            }
            else if (vFormat=='Date YYYYMMDDHHMM') 
            {
                vValue=vValue.Trim();
                vValue = vValue.Substring(0,4)+vValue.Substring(5,7)+vValue.Substring(8,10)+vValue.Substring(11,13)+vValue.Substring(14,16);
            }
             return vValue;
        } // end of TransformDate
        
    }
    
    // ========================================================================
    //Master data structure to hold all agencies data
    global class DataStructureCls {
        public GDP_Products_Account_View__c AccountView {get;set;}
        public GDP_Address__c MailingAddress {get;set;}
        public GDP_Address__c LocationAddress {get;set;}
        public List<AirlineCls> Airlines {get; set;}
        public Map<String, GDP_Phone__c> Phones {get;set;} //Related_GDP_Products_Account_View__c //Phone_Type__c
        public Map<String, Agency_Owner__c> Owners {get;set;} //Related_GDP_Products_Account_View__c //Percent__c
        public Map<String, GDP_Agency_Profile_Specialization__c> Profiles {get;set;} //Related_GDP_Products_Account_View__c
        public Map<String, Account_Category__c> Categories {get;set;} //Related_GDP_Products_Account_View__c
        public Map<String, GDS__c> GDSs {get;set;} //Related_GDP_Products_Account_View__c
        public Map<String, Adjacent_Airport__c> Airports {get;set;} //Related_GDP_Products_Account_View__c
        public Map<String, Assoc_Affiliation_Membership__c> Affiliations {get;set;} //Related_GDP_Products_Account_View__c
        public Map<String, Accreditation__c> Accreditations {get;set;} //Related_GDP_Products_Account_View__c
        
        
        //Find the unique key
        //Is there a unique Key to use or nothing
        //Object Name
        //Filter Field
        //Filter Value   
        public String RetrieveObjectMapId(String vObjectName, String vFilter, String vFilterValue){
            boolean selected=true;
            String ObjectMapId='';
            if (vObjectName=='GDP_Phone__c'){
                if (Phones.Size()==0) return '';
                for(GDP_Phone__c objectrecord:Phones.Values()){ 
                    // 2015-11-16 [Samy] : Fixing issue with repeating accreditation even if there is only one on record
                    if ((vFilter=='' || vFilterValue=='')) { ObjectMapId=String.ValueOf(objectrecord.id); selected=false;}
                    else if (String.ValueOf(objectrecord.get(vFilter))==vFilterValue) return String.ValueOf(objectrecord.id);
                }
            }
            else if (vObjectName=='Agency_Owner__c'){
                if (Owners.Size()==0) return '';
                for(Agency_Owner__c objectrecord:Owners.Values()){ 
                    // 2015-11-16 [Samy] : Fixing issue with repeating accreditation even if there is only one on record
                    if ((vFilter=='' || vFilterValue=='')) { ObjectMapId=String.ValueOf(objectrecord.id); selected=false;}
                    else if (String.ValueOf(objectrecord.get(vFilter))==vFilterValue) return String.ValueOf(objectrecord.id);
                }              
                return ObjectMapId;
            } 
            else if (vObjectName=='GDP_Agency_Profile_Specialization__c'){
                if (Profiles.Size()==0) return '';
                for(GDP_Agency_Profile_Specialization__c objectrecord:Profiles.Values()){ 
                    // 2015-11-16 [Samy] : Fixing issue with repeating accreditation even if there is only one on record
                    if ( (vFilter=='' || vFilterValue=='')) { ObjectMapId=String.ValueOf(objectrecord.id); selected=false;}
                    else if (String.ValueOf(objectrecord.get(vFilter))==vFilterValue) return String.ValueOf(objectrecord.id);
                } 
            }
            else if (vObjectName=='Account_Category__c'){
                if (Categories.Size()==0) return '';
                for(Account_Category__c objectrecord:Categories.Values()){ 
                    // 2015-11-16 [Samy] : Fixing issue with repeating accreditation even if there is only one on record
                    if ((vFilter=='' || vFilterValue=='')) { ObjectMapId=String.ValueOf(objectrecord.id); selected=false;}
                    else if (String.ValueOf(objectrecord.get(vFilter))==vFilterValue) return String.ValueOf(objectrecord.id);
                }              
            }
            else if (vObjectName=='GDS__c'){
                if (GDSs.Size()==0) return '';
                for(GDS__c objectrecord:GDSs.Values()){ 
                    // 2015-11-16 [Samy] : Fixing issue with repeating accreditation even if there is only one on record
                    if ((vFilter=='' || vFilterValue=='')) { ObjectMapId=String.ValueOf(objectrecord.id); selected=false;}
                    else if (String.ValueOf(objectrecord.get(vFilter))==vFilterValue) return String.ValueOf(objectrecord.id);
                } 
            }
            else if (vObjectName=='Adjacent_Airport__c'){
                if (Airports.Size()==0) return '';
                for(Adjacent_Airport__c objectrecord:Airports.Values()){ 
                    // 2015-11-16 [Samy] : Fixing issue with repeating accreditation even if there is only one on record
                    if (selected && (vFilter=='' || vFilterValue=='')) { ObjectMapId=String.ValueOf(objectrecord.id); selected=false;}
                    if (String.ValueOf(objectrecord.get(vFilter))==vFilterValue) return String.ValueOf(objectrecord.id);
                } 
            }
            else if (vObjectName=='Assoc_Affiliation_Membership__c'){
                if (Affiliations.Size()==0) return '';
                for(Assoc_Affiliation_Membership__c objectrecord:Affiliations.Values()){ 
                    // 2015-11-16 [Samy] : Fixing issue with repeating accreditation even if there is only one on record
                    if ( (vFilter=='' || vFilterValue=='')) { ObjectMapId=String.ValueOf(objectrecord.id); selected=false;}
                    else if (String.ValueOf(objectrecord.get(vFilter))==vFilterValue) return String.ValueOf(objectrecord.id);
                }
            }
            else if (vObjectName=='Accreditation__c'){
                if (Accreditations.Size()==0) return '';
                for(Accreditation__c objectrecord:Accreditations.Values()){
                    // 2015-11-16 [Samy] : Fixing issue with repeating accreditation even if there is only one on record
                    if ( (vFilter=='' || vFilterValue=='')) { ObjectMapId=String.ValueOf(objectrecord.id); selected=false;}
                    else if (String.ValueOf(objectrecord.get(vFilter))==vFilterValue) return String.ValueOf(objectrecord.id);
                }      
            }
            return ObjectMapId;
        }
        
        //DataStructureCls Constructor
        public DataStructureCls(GDP_Products_Account_View__c vAccountView)
        {
            this.AccountView=vAccountView;
            this.Airlines = new List<AirlineCls>();
            this.MailingAddress=null;
            this.LocationAddress=null;
            
            this.Phones = new Map<String, GDP_Phone__c>();
            this.Owners =  new Map<String, Agency_Owner__c>();
            this.Profiles= new Map<String, GDP_Agency_Profile_Specialization__c>();
            this.Categories=new Map<String, Account_Category__c>();
            this.GDSs =new Map<String, GDS__c>();
            this.Airports = new Map<String, Adjacent_Airport__c>();
            this.Affiliations  = new Map<String, Assoc_Affiliation_Membership__c>();
            this.Accreditations  = new Map<String, Accreditation__c>();
            
            
        }
    }
    //Sub Master data Structure for Airlines
    global class AirlineCls {
            public Accreditation__c Airline {get;set;}
            public List<GSA_Territory__c> Territories {get;set;}
            //Territory Class
            public AirlineCls(Accreditation__c vAirline)
            {
                this.Airline=vAirline;
                this.Territories = new List<GSA_Territory__c>();
            }
            
        }
    //Definition of JSON response
    global class FilePayload {
        public String LastRecordID {get; set;} // this can be set by GDP_Product_Account_View__c.Id or urlEncode(MDP_Sort_Key_Formula__c)
        public List<Record> FileRecords;
        public String SOQL {get;set;}
        
        //Constructor
        public FilePayload(){
            this.FileRecords = new list<Record>();
            this.SOQL='';
        }
    }
    
    // ========================================================================
    //Inner class
    //TODO this can be ajusted as needed and concatenated split by pipe or other. For now it is a list of string (discussed with Sony)
    global class Record{
        public string RecordType{get; set;}
        //public list<string> aRecord;   
        public string Record {get; set;}
        public string RecordId {get; set;}
        //Inner class Constructor
        public Record(String[] rec, string recType, string recid  ) {
            this.RecordType = recType;
            this.RecordId = recid;
            
            //Escape Pipe characters in payload with %7C prior to joining the list with pipes
            //for (integer i = 0 ; i < rec.size(); i++ ){
            //  system.debug('rec['+i+']='+rec[i]);
            //  if(rec[i]!=null){
            //      rec[i]= rec[i].replace('|','%7C'); 
            //  }
            //}
            
            this.Record = String.join(rec, '|');
        }  
        /*
        public list<string> getRecordAsListOfString(){
            list<string> strOutList = new list<string>();
            strOutList.addAll(Record.split('\\|'));
            for (Integer i = 0; i < strOutList.size(); i++)
                strOutList[i]=strOutList[i].replaceAll('%7C','|'); 
            return strOutList;
        }*/
    }
    // ========================================================================
    //Custom Exception Class    
    public class MyException extends Exception {} 
    
}