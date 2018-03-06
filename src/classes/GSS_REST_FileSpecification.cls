/*
*  REST API Service returning the File Specification and Subscription Details to be delivered
*  - External class will call getActiveSubscription (@HttpGet) method
*  - URI Parameter:  none
*  - REST API Input (body): {SubscriptionIdList:[]}
*  - REST API response: FileSpecificationCls containing FileSpecification array
*  Change log:
*   20150917: Alexandre James: initial version
*   20151223: Abdellah Bellahssan: File delivery for the Delta With Master Files (First Time and Recurring time)
*   20160104: Sonny Leman: Change field name Subscription_Detail.Calendar_Bi_Monthly to Calendar_Semi_Monthly, ProductChargeID to SubscriptionDetailID
*   20160115: Sonny Leman: Master file sent on delta will have customized name format
*   20160229: Sonny Leman: add Frequency in the returned FileSpecification.
*   20160314: Sonny Leman: record with null TdfRecipient will not be part of the delivery, as IINET will not process the whole file. 
*   20160317: Sonny Leman: Subscription with TermSetting='EVERGREEN' can have no SubscriptionEndDate
*
*
*/

@RestResource(urlMapping='/GSS/v0/FileSpecification/*')
global with sharing class GSS_REST_FileSpecification{
    private static final String FILE_NAME_APPLIES_ON_ZIP_ONLY = 'Zip file only';               // GDP_Subscription_Detail__c.File_Name_Applies_on__c picklist
    private static final String FILE_NAME_APPLIES_ON_ZIP_AND_DATA = 'Zip file and Data file';  // GDP_Subscription_Detail__c.File_Name_Applies_on__c picklist
    
    @HttpPost
    global static void getActiveSubscription() {
        Integer BATCH_SIZE = 200;
        RestContext.response.statuscode = 200;      //Create an empty list of FileSpecifiation that will be sent as a response
        FileSpecificationCls responseFSlist = new FileSpecificationCls();
        //Get the input parameters in the URL
        //if the TodayDate is not empty it will replace TodaySystem value
        //in order to simulate the response for a specific date.
        //SimulateTodayDate format is MM-DD-YYYY
        Date TodaySystem = Date.today();
        Boolean IsSimulation=false;
        String SimulateTodayDate = RestContext.request.params.get('SimulateTodayDate');
        System.debug('SimulateTodayDate >>>'+SimulateTodayDate);
        if (!(SimulateTodayDate==null || SimulateTodayDate=='')){
            String[] ArraySimulateTodayDate = SimulateTodayDate.split('-');
            integer SimulateDay=Integer.ValueOf(ArraySimulateTodayDate[1]);
            integer SimulateMonth=Integer.ValueOf(ArraySimulateTodayDate[0]);
            integer SimulateYear=Integer.ValueOf(ArraySimulateTodayDate[2]);
            TodaySystem = Date.newInstance(SimulateYear,SimulateMonth,SimulateDay);
            System.debug('TodaySystem >>>'+TodaySystem);
            IsSimulation=true;
        }
        //Get the input parameters: expecting an class ListOfSubscriptionId
        //try{
            system.debug('RestContext.request.requestBody.toString()>>>' +RestContext.request.requestBody.toString());                       
            //Get the input subscriptionID list by deserializing the header request
            ListOfSubscriptionId RequestedListOfSubscriptionId  =  (ListOfSubscriptionId)json.deserialize(RestContext.request.requestBody.toString(), 
                                                       ListOfSubscriptionId.class);
            system.debug('RequestedListOfSubscriptionId>>>>' + RequestedListOfSubscriptionId);
            map<id, GDP_File_Description__c> subcriberID_FileDescriptionMap = new map<id, GDP_File_Description__c>();

            //Select the Valid Subscriptions and Where there is a need to generate the file
            //TempFileSpecificationLookup__c is the temporary lookup on the subscription to the specification
            //TODO : Retrieve the File Specification  Period and PeriodDay (WeekDay, MonthDay...)
            List<Zuora__Subscription__c> subscriptionlist = new List<Zuora__Subscription__c>();
            subscriptionlist = [SELECT Id
                                        ,Name
                                        ,Zuora__CustomerAccount__r.IINETUserID__c // used for the case when GSS_Subscription_Detail needs help in matching its Zuora_Subscription
                                    FROM Zuora__Subscription__c 
                                    WHERE Zuora__SubscriptionStartDate__c<=:TodaySystem
                                      AND ( Zuora__SubscriptionEndDate__c >=:TodaySystem
                                            OR ( Zuora__SubscriptionEndDate__c = null
                                                AND  Zuora__TermSettingType__c = 'EVERGREEN'
                                              )
                                            ) 
                                      AND Zuora__Status__c = 'Active'
                                      AND Id=: RequestedListOfSubscriptionId.SubscriptionIdList
                                    ORDER BY Id
                                    LIMIT :BATCH_SIZE];
            System.Debug('subscriptionlist >>>'+subscriptionlist);
            if (IsSimulation) RequestedListOfSubscriptionId.SubscriptionIdList.clear();
            if (IsSimulation) for(Zuora__Subscription__c su:subscriptionlist) {RequestedListOfSubscriptionId.SubscriptionIdList.add(su.Id); }
            
            //When the subscription list is empty the response should be returned empty 
            if (subscriptionlist.size()==0)  RestContext.response.responseBody = Blob.valueOf(json.serialize(responseFSlist));
            //Map<String,Id> subscriptionlistname = new Map<String,Id>();
            Map<String,Zuora__Subscription__c> subscriptionNameToObjectMap = new Map<String,Zuora__Subscription__c>();
            for(Zuora__Subscription__c su:subscriptionlist) {subscriptionNameToObjectMap.put(su.Name,su); }
            //TODO:Get all the file specification for the sub Product & Charges related to this list Subscription
            
            //First GSSGoLive
            boolean IsGSSGolive=false;
            List<GDP_Area_Definition__c> golive = new List<GDP_Area_Definition__c>();
            golive = [Select id, name From GDP_Area_Definition__c Where Name='GSSGoLive' Limit 1];
            if (golive.size()>0) {isGSSGolive=true;}

            //Read and build the List of Specification file per Subscription
            /*
            List<Zuora__SubscriptionProductCharge__c> subscriptiondetaillist = new List<Zuora__SubscriptionProductCharge__c>();
            subscriptiondetaillist = [Select id
                                        ,GDP_File_Layout__c
                                        ,GDP_File_Layout__r.File_Format__c      
                                        ,GDP_File_Layout__r.Frequency__c  
                                        ,GDP_File_Layout__r.File_Naming_Convention__c
                                        ,Zuora__Subscription__c
                                        ,Delivery_Period_Day__c
                                        ,Delivery_Period_Week_Day__c
                                        ,TDF_Recipient__c
                                        ,File_Suffix__c
                                        ,File_Prefix__c
                                   From Zuora__SubscriptionProductCharge__c
                                   Where Zuora__Subscription__c=: RequestedListOfSubscriptionId.SubscriptionIdList
                                    AND GDP_File_Layout__c!=null
                                    ORDER BY  Zuora__Subscription__c];         
            */                                  
            //Read and build the List of Specification file per Subscription
            List<GSS_Subscription_Detail__c> subscriptiondetaillist = new List<GSS_Subscription_Detail__c>();
            subscriptiondetaillist = [Select id
                                    ,Name
                                    ,Calendar_Semi_Monthly_First_Option__c    
                                    ,Calendar_Semi_Monthly_Second_Option__c
                                    ,Calendar_Monthly_Option__c
                                    ,Calendar_New_Submission_Effective_Date__c
                                    ,Calendar_Next_Submission_Date__c
                                    ,Calendar_Weekly_Option__c
                                    ,File_Name_Applies_on__c
                                    ,File_Name_Custom_Prefix__c
                                    ,File_Name_Custom_Suffix__c
                                    ,File_Name_Prefix_Option__c
                                    ,File_Name_Suffix_Option__c
                                    ,FileRecipent_iiNet_TDF_Recipient__c
                                    ,FileRecipientEmail__c
                                    ,FileRecipientFirstName__c
                                    ,FileRecipientLastName__c
                                    ,GDP_File_Description__c
                                    ,GDP_File_Description__r.Frequency__c
                                    ,GDP_File_Description__r.File_Naming_Convention__c
                                    ,Master_File_Delivery__c
                                    ,Next_Master_File_Delivery__c
                                    ,GDP_File_Description__r.Magnitude__c
                                    ,GDP_File_Description__r.Master_File_Description__c
                                    ,GDP_File_Description__r.Master_File_Description__r.Frequency__c
                                    ,GDP_File_Description__r.Master_File_Description__r.File_Naming_Convention__c
                                    ,Trigger_File_Name__c
                                    ,Zuora_Subscription__c
                                   From GSS_Subscription_Detail__c
                                   Where Zuora_Subscription__c=: RequestedListOfSubscriptionId.SubscriptionIdList
                                    AND GDP_File_Description__c!=null
                                    ORDER BY  Zuora_Subscription__c]; 
            //TODO: Make sure to capture also the Record without Subscription Id
            //Situation where there was an amendment likewise           
            List<GSS_Subscription_Detail__c> bsubscriptiondetaillist = new List<GSS_Subscription_Detail__c>();
            bsubscriptiondetaillist = [Select id
                                    ,Name
                                    ,Calendar_Semi_Monthly_First_Option__c 
                                    ,Calendar_Semi_Monthly_Second_Option__c
                                    ,Calendar_Monthly_Option__c
                                    ,Calendar_New_Submission_Effective_Date__c
                                    ,Calendar_Next_Submission_Date__c
                                    ,Calendar_Weekly_Option__c
                                    ,File_Name_Applies_on__c
                                    ,File_Name_Custom_Prefix__c
                                    ,File_Name_Custom_Suffix__c
                                    ,File_Name_Prefix_Option__c
                                    ,File_Name_Suffix_Option__c
                                    ,FileRecipent_iiNet_TDF_Recipient__c
                                    ,FileRecipientEmail__c
                                    ,FileRecipientFirstName__c
                                    ,FileRecipientLastName__c
                                    ,GDP_File_Description__c
                                    ,GDP_File_Description__r.Frequency__c
                                    ,GDP_File_Description__r.File_Naming_Convention__c
                                    ,Master_File_Delivery__c
                                    ,Next_Master_File_Delivery__c
                                    ,GDP_File_Description__r.Magnitude__c
                                    ,GDP_File_Description__r.Master_File_Description__c
                                    ,GDP_File_Description__r.Master_File_Description__r.Frequency__c
                                    ,GDP_File_Description__r.Master_File_Description__r.File_Naming_Convention__c
                                    ,Trigger_File_Name__c
                                    ,Zuora_Subscription__c
                                   From GSS_Subscription_Detail__c
                                   Where Name=:subscriptionNameToObjectMap.KeySet()
                                    AND Zuora_Subscription__c=null
                                    AND GDP_File_Description__c!=null
                                    ORDER BY  Zuora_Subscription__c]; 
                                    
            //Add the missing record to the main list
            if (bsubscriptiondetaillist.size()>0)  subscriptiondetaillist.addAll(bsubscriptiondetaillist);
            System.Debug('0 subscriptiondetaillist >>>'+subscriptiondetaillist);
            //TODO: Make sure the subscription has not been processed already today
            //The Temporary object for Delivery is named GDP_File_Delivery__c
            //TODO: Create the object
            List<GDP_File_Delivery__c> deliverylist = new List<GDP_File_Delivery__c>();
            deliverylist = [SELECT Id
                                        ,Subscription__c
                                        ,File_Specification__c
                                        ,GSS_Subscription_Detail__c                                        
                                    FROM GDP_File_Delivery__c 
                                    WHERE Subscription__c=: RequestedListOfSubscriptionId.SubscriptionIdList
                                      AND Delivery_Date__c=:TodaySystem
                                      And Status__c='Completed'
                                    ORDER BY Id
                                    LIMIT :BATCH_SIZE];
            //Build set of delivery
            Set<String> deliveryset = new Set<String>();
            for(GDP_File_Delivery__c delivery : deliveryList)
                {
                 deliveryset.add(delivery.GSS_Subscription_Detail__c);
                }
                
            System.Debug('deliverylist >>>'+deliverylist);
            //Create a Map of Subscription Product and Charge Class 
            //Exclude from the list Subscription already processed
            Set<Id> SetUniqueSpecificationIds = new Set<Id>();
            
            String fileNamePrefix;
            String fileNameSuffix;
            
            for(GSS_Subscription_Detail__c subscriptiondetail: subscriptiondetaillist)
            {
                System.Debug('1 subscriptiondetail >>>'+subscriptiondetail);
          
                if(!deliveryset.Contains(subscriptiondetail.id))
                {
                    
                    Boolean DayIncluded = isTodayTheDeliveryDay(TodaySystem,subscriptionDetail);
                    System.Debug('2 DayIncluded >>>'+DayIncluded);
                    // if the frequency, delivery calendar option, and today do not match there will be no file delivery
                    if (!DayIncluded) continue;
                    System.Debug('3 DayIncluded >>>'+DayIncluded);
                    
                    // -------------------------------------------------------
                    // start preparing FileSpecification, for the delivery file, while still prequalifying the subscriptiondetail
                    FileSpecification fs = new FileSpecification();
                    fs.SubscriptionDetailID = subscriptiondetail.id;
                    fs.SubscriptionID = subscriptiondetail.Zuora_Subscription__c;
                    fs.FileSpecificationID = subscriptiondetail.GDP_File_Description__c;
                   
                    //if (subscriptiondetail.FileRecipent_iiNet_TDF_Recipient__c!=null) 
                    fs.TdfRecipient=subscriptiondetail.FileRecipent_iiNet_TDF_Recipient__c;
                   
                    // in case Zuora_Subscription__c is null, try to match using subscription record name
                    if (subscriptiondetail.Zuora_Subscription__c==null)
                    {
                        if (subscriptionNameToObjectMap.ContainsKey(subscriptiondetail.Name)) {
                            Zuora__Subscription__c zuoraSub = subscriptionNameToObjectMap.get(subscriptiondetail.Name);
                            subscriptiondetail.Zuora_Subscription__c = (zuoraSub==null) ? null : zuoraSub.Id;
                            
                            fs.TdfRecipient = (zuoraSub==null) ? null : zuoraSub.Zuora__CustomerAccount__r.IINETUserID__c;
                        } else { // cannot find matching Zuora_Subscription, therefore, do not include this subscription detail
                            continue;
                        }
                    } // end if subscriptiondetail.Zuora_Subscription
                    
                    if (fs.TdfRecipient==null) continue; // after all efforts, if this is still null, then there is no delivery
                    
                    /* GDP-222   Send dynamically the filename base on filenaming convension*/
                    fs.FileNaming = subscriptiondetail.GDP_File_Description__r.File_Naming_Convention__c;
                    fs.ZIPFileName = subscriptiondetail.GDP_File_Description__r.File_Naming_Convention__c;
                    fs.Frequency = subscriptiondetail.GDP_File_Description__r.Frequency__c;
                    if (fs.ZIPFileName!=null) { fs.ZIPFileName = fs.ZIPFileName.replace('&','');}
                    if (fs.FileNaming!=null) { fs.FileNaming = fs.FileNaming.replace('&','.');}
                    setCustomizedCoreFileName(TodaySystem, fs, subscriptiondetail); // set intermediate customized FileNaming and ZIPFileName
                    
                    //Temporary solution for the golive only
                    //When delta with master 
                    //do not send delta but send master only
                    boolean masteronly=false;
                    if (subscriptiondetail.GDP_File_Description__r.Magnitude__c=='Delta' 
                        && subscriptiondetail.GDP_File_Description__r.Master_File_Description__c !=null) { masteronly=true;}
                    if (!IsGSSGolive) masteronly=false;

                    // -------------------------------------------------------
                    // Delta and Master Delivery cases for delta file subscription
                    //
                    // check if we need to skip the normal file description delivery.
                    // the delta file will not be part of first time ever delivery for a delta subscription  
                    // check for the case of a new delta subscription: Master_File_Delivery and Next_Master_File_Delivery are null
                    if ( (
                          (subscriptiondetail.GDP_File_Description__r.Master_File_Description__c == null) // without master desc, it is not a delta  
                           || (subscriptiondetail.Master_File_Delivery__c != null)      // master file has been delivered, 
                           || (subscriptionDetail.Next_Master_File_Delivery__c != null) // next master has been set 
                        )
                         && masteronly == false
                        ) 
                    { // normal subscription delivery case will be done here: normal delta file, or master subscription 
                        responseFSlist.FileSpecifications.add(fs); 
                        SetUniqueSpecificationIds.Add(subscriptiondetail.GDP_File_Description__c);
                        System.Debug('4 subscriptiondetail.GDP_File_Description__c >>>'+subscriptiondetail.GDP_File_Description__c);
                    }
                    
                    // check for a delta subscription, whether we need to send the master
                    if (subscriptiondetail.GDP_File_Description__r.Master_File_Description__c!=null)
                    {
                        System.Debug('5 subscriptiondetail.Next_Master_File_Delivery__c >>>'+subscriptiondetail.Next_Master_File_Delivery__c);
                        //Make sur the Next Master File Delivery Date is Reached
                        integer delta_state=0;
                        if (subscriptiondetail.Master_File_Delivery__c==null) delta_state=1; // master has never been sent
                        if (subscriptiondetail.Next_Master_File_Delivery__c!=null)
                            if (TodaySystem>=subscriptiondetail.Next_Master_File_Delivery__c) delta_state=1;
                        
                        if (delta_state==0 && masteronly==false) continue;
                        System.Debug('6 masteronly >>>'+masteronly);
                        FileSpecification fs1 = new FileSpecification();
                        fs1.SubscriptionDetailID = fs.SubscriptionDetailID;
                        fs1.SubscriptionID = fs.SubscriptionID;                     
                        fs1.FileSpecificationID =subscriptiondetail.GDP_File_Description__r.Master_File_Description__c;
                        fs1.Frequency = subscriptiondetail.GDP_File_Description__r.Frequency__c;
                        fs1.TdfRecipient=fs.TdfRecipient;
                        fs1.FileSubscribedFormat = fs.FileSubscribedFormat; // assumed here that the delta and master have same format
                         
                        // Master File & Zip File should have the master file name, set the original name first
                        fs1.FileNaming = subscriptiondetail.GDP_File_Description__r.Master_File_Description__r.File_Naming_Convention__c; 
                        fs1.ZIPFileName = subscriptiondetail.GDP_File_Description__r.Master_File_Description__r.File_Naming_Convention__c;
                        if (fs1.ZIPFileName!=null) { fs1.ZIPFileName = fs1.ZIPFileName.replace('&','');}
                        if (fs1.FileNaming!=null) { fs1.FileNaming = fs1.FileNaming.replace('&','.');}
                        setCustomizedCoreFileName(TodaySystem, fs1, subscriptiondetail); // set intermediate customized FileNaming and ZIPFileName
                        
                        responseFSlist.FileSpecifications.add(fs1); 
                        SetUniqueSpecificationIds.Add(subscriptiondetail.GDP_File_Description__r.Master_File_Description__c);
                         
                    }
                    
                } // end if deliveryset.Contains(subscriptiondetail.id)
            } // end for GSS_Subscription_Detail__c
            
            
            //When the set of specification File Ids is empty the response should be returned empty 
            if (SetUniqueSpecificationIds.Size()==0)  RestContext.response.responseBody = Blob.valueOf(json.serialize(responseFSlist));
            boolean FileProduced=false;
            DateTime LastDateFileProduction;
            String LastIdFileProduction='';
            //TODO: 
            //Query the GDP_File_Description__c to retrieve the File Specification details
            for(GDP_File_Description__c FileDescription: 
                [SELECT Id
                    ,Frequency__c
                    ,Description__c
                    ,File_Format__c
                    ,Field_API__c
                    ,Field_Label__c
                    ,Field_Length__c
                    ,Field_Type__c   
                    ,Field_Group__c
                    ,Field_Object_Name__c
                    ,File_Naming_Convention__c 
                    ,Product_Type__c
                    ,Reference__c
                    ,XSD_Schema__c
                    ,(Select id, Production_Date__c
                        From GDP_File_Productions__r
                        Where Status__c='Completed'
                        Order By LastModifiedDate Desc
                        Limit 1)                   
                    ,Reference__r.Field_API__c
                    ,Reference__r.Field_Label__c
                    ,Reference__r.Field_Length__c
                    ,Reference__r.Field_Type__c  
                    ,Reference__r.Field_Object_Name__c
                    ,Reference__r.Field_Group__c
                    ,Reference__r.XSD_Schema__c                    
                 FROM GDP_File_Description__c
                 WHERE Id in : SetUniqueSpecificationIds ])
            {
                //Find out the date of the last file production
                 FileProduced=false;
                 LastDateFileProduction = TodaySystem;
                 LastIdFileProduction = '';
                 for(GDP_File_Production__c fileproduction:FileDescription.GDP_File_Productions__r)
                 {
                     //Loading the Production Date
                     LastDateFileProduction=fileproduction.Production_Date__c;
                     LastIdFileProduction = fileproduction.id;
                     FileProduced=true;
                 }
                 //For every set of subscription and File specification
                 if (FileProduced) {
                    for(FileSpecification fs:responseFSlist.FileSpecifications) {
                        if (FileDescription.Id==fs.FileSpecificationID)
                        {
                             String Year  =String.ValueOf(LastDateFileProduction.Year()).Trim();
                             String Month =String.ValueOf(LastDateFileProduction.Month()).Trim().leftPad(2).replace(' ','0'); 
                             //fs.TDFFileName= getTDFFileName(FileDescription.Frequency__c, Year, Month);
                             fs.TDFFileName= getTdfFileName(FileDescription, LastDateFileProduction);
                             //fs.TDFFolder  = getTDFFileName(FileDescription.Frequency__c, Year, Month);
                             fs.TDFFolder  = getTdfFolderName(FileDescription.Product_Type__c, FileDescription.Frequency__c, Year, LastDateFileProduction.Month());
                             fs.Frequency = FileDescription.Frequency__c;
                             fs.FileProductionName=getProductionFileName(LastIdFileProduction, Year, Month);
                             fs.TriggerFileName=''; 
                             fs.XSDSchema ='';
                             if (!IsSimulation) {fs.XSDSchema = FileDescription.Reference__r.XSD_Schema__c !=null ? FileDescription.Reference__r.XSD_Schema__c :FileDescription.XSD_Schema__c;}
                             fs.FileSubscribedFormat=FileDescription.File_Format__c;
                             
                             // for non TEXT format, add the proper extension to file name and zip file name
                             if (FileDescription.File_Format__c == 'XLSX') {
                                fs.FileNaming = fs.FileNaming.replace( '.',''); 
                                fs.FileNaming += '.xlsx';
                                fs.ZipFileName += '_xlsx';
                             } else if (FileDescription.File_Format__c == 'XML') {
                                fs.FileNaming = fs.FileNaming.replace( '.',''); 
                                fs.FileNaming += '.xml';
                                fs.ZipFileName += '_xml';
                             } // end if FileSubscribedFormat
                             
                             fs.ZipFileName = getZipFileName(fs.ZipFileName);
                        } // end if FileDescription
                    } // end for FileSpecification
                 }
            } // end for soql GDP_File_Description__c 
            
            
            system.debug('responseFSlist>>>>' + responseFSlist);
            //Return   
        
        RestContext.response.addHeader('Content-Type', 'application/json');
        try {
            RestContext.response.responseBody = Blob.valueOf(json.serialize(responseFSlist));  
        } catch(Exception e){
            //Unable to deserialize in expected format
            system.debug('exception>>>>' + e.getMessage());
            //RestContext.response.statuscode = 400;
            RestContext.response.responseBody = Blob.valueOf(json.serialize(responseFSlist));
        } // end catch
        
    } // end of getActiveSubscription
    
    
    
    // ========================================================================
    // setCustomizedCoreFileName will update fs.FileNaming, fs.ZipFileName
    // This is the first part that does not include the file extension (zip, xlsx, xml)
    // assumption:
    //  - fs.FileNaming already set with original/core file name (GDP_File_Description__r.File_Naming_Convention__c)
    //  - fs.ZIPFileName already set with original/core file name (GDP_File_Description__r.File_Naming_Convention__c)
    private static void setCustomizedCoreFileName( Date TodaySystem, FileSpecification fs
        , GSS_Subscription_Detail__c subscriptionDetail)
    {
        /* GDP-222   Send dynamically the filename base on filenaming convension*/
        // get the zip/data prefix/suffix pattern
        String fileNameSuffix ='';
        String fileNamePrefix ='';
        if (subscriptiondetail.File_Name_Prefix_Option__c== null) subscriptiondetail.File_Name_Prefix_Option__c='';
        if (subscriptiondetail.File_Name_Suffix_Option__c== null) subscriptiondetail.File_Name_Suffix_Option__c='';
        // Date
        if (subscriptiondetail.File_Name_Prefix_Option__c =='Date') fileNamePrefix = String.valueOf(Date.today()).replace( '-',''); 
        if (subscriptiondetail.File_Name_Suffix_Option__c =='Date') fileNameSuffix = String.valueOf(Date.today()).replace( '-',''); 
        // Custom                     
        if (subscriptiondetail.File_Name_Prefix_Option__c =='Custom') fileNamePrefix = subscriptiondetail.File_name_Custom_Prefix__c;  
        if (subscriptiondetail.File_Name_Suffix_Option__c =='Custom') fileNameSuffix = subscriptiondetail.File_Name_Custom_Suffix__c;                   
        
        //if (fileNameSuffix!='') fileNameSuffix = '_'+fileNameSuffix;
        //if (fileNamePrefix!='') fileNamePrefix = fileNamePrefix + '_';
         
        // apply the prefix/suffix pattern to data file as required 
        if (subscriptiondetail.File_Name_Applies_on__c == FILE_NAME_APPLIES_ON_ZIP_AND_DATA )
        {
            // fs.FileNaming = getFileNameDynamic(subscriptiondetail.GDP_File_Description__r.File_Naming_Convention__c,
            fs.FileNaming = getFileNameDynamic( TodaySystem, fs.FileNaming, fileNamePrefix, fileNameSuffix); 
        } else {
            fs.FileNaming = getFileNameDynamic( TodaySystem, fs.FileNaming, '', ''); 
        } // end if for applying data file name
         
        // set core ZIPFileName, no zip extension yet, might be extended later based on file type
        // apply the prefix/suffix pattern to zip file as required 
        if (subscriptiondetail.File_Name_Applies_on__c == FILE_NAME_APPLIES_ON_ZIP_ONLY 
             || subscriptiondetail.File_Name_Applies_on__c == FILE_NAME_APPLIES_ON_ZIP_AND_DATA )
        { 
            // fs.ZIPFileName = getFileNameDynamic(subscriptiondetail.GDP_File_Description__r.File_Naming_Convention__c,
            fs.ZIPFileName = getFileNameDynamic(TodaySystem, fs.ZIPFileName, fileNamePrefix, fileNameSuffix); 
        } else {
            fs.ZIPFileName = getFileNameDynamic(TodaySystem, fs.ZIPFileName, '', ''); 
        } // end if for applying zip file name
        
    } // setCustomizedCoreFileName
    
    
    // ========================================================================
    //Definition of JSON Request object
    global class ListOfSubscriptionId {
        public List<string> SubscriptionIdList;
        
        public ListOfSubscriptionId(List<string> l) {
            this.SubscriptionIdList = l;
        }
    }    
    //Definition of JSON Response object
    //
    global Class FileSpecificationCls
    {
        public List<FileSpecification> FileSpecifications {get;set;}
        public FileSpecificationCls()
        {
            FileSpecifications= new List<FileSpecification>();
        }
    } // end of FileSpecificationCls
    
    // ========================================================================
    // FileSpecification unique key is ( SubscriptionDetailID + FileSpecificationID)
    global class FileSpecification{
        public string SubscriptionDetailID; // was ProductChargeID; this  field is based on GSS_Subscription_Detail.Id
        public string SubscriptionID;
        public string FileSpecificationID;
       
        public String ZIPFileName {get;set;}
        public String TDFFileName {get;set;}
        public String TriggerFileName {get;set;}
        public String TDFFolder {get;set;}
        public String FileProductionName {get;set;}
      
        public String FileNaming {get;set;}
        public String FileSubscribedFormat {get;set;}

        public String TdfRecipient {get;set;}
        public String XSDFileName {get;set;}
        public String XSDSchema {get;set;}
        public String Frequency {get;set;} // GDP_File_Description__c.Frequency__c, i.e. file delivery frequency
         
        public FileSpecification()
        {
            this.SubscriptionDetailID = '';
            this.TDFFileName  = '';
            this.TDFFolder ='';
            this.FileProductionName='';

            this.FileNaming='';
            this.TdfRecipient='';
            this.XSDFileName='XMLDefinition.xsd';
            this.XSDSchema='';
            this.FileSubscribedFormat='txt';
            this.Frequency = '';
                
        } // end of FileSpecification constructor  
    } // end FileSpecification class
    
    
    //global static String getZipFFileName(String FileName)
    static String getZipFileName(String FileName)
    {
      //return FileName.replace('.', '')+'.zip';
      //Per Luc request mainframe client system requires zip in uppercase
      return FileName+'.ZIP'; 
    }
    
    
    /*
    global static String getTDFFolder(String Frequency, String YearProduction, String MonthProduction)
    {
      return Frequency+'_'+YearProduction+'_'+MonthProduction; 
    }
    */
    // monthName list is used for quick setting of the month name
    static private List<String> monthName = new List<String> { 'XXX', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec' };
    // TDF Folder is under <backup> folder: ./<MDP|GSS>/<Month>/<Frequency>/
    static String getTdfFolderName(String productType, String Frequency, String YearProduction, Integer MonthProduction)
    {
        String result = (productType == 'MDP') ? 'MDP' : 'GSS'; // gss is the default
        String monthString = String.valueOf(MonthProduction).trim().leftPad(2).replace(' ','0'); 
        result += '/' + monthString + '-' + monthName[MonthProduction];
        result += '/' + Frequency;
        // return Frequency+'_'+YearProduction+'_'+MonthProduction;
        return result; 
    }
    
    // TDF File Name: TDF_ + <Product_Type> + _ + <Frequency> + <date in DD_MM_YYY>
    // Old model has issue with duplicate name: TDF File Name: TDF_ + <Frequency> + <date in DD_MM_YYY>
    //global static String getTDFFileName(String Frequency, String YearProduction, String MonthProduction)
    static String getTdfFileName(GDP_File_Description__c FileDescription, DateTime LastDateFileProduction)
    {
        //
        String YearProduction  = String.ValueOf(LastDateFileProduction.Year()).Trim();
        String MonthProduction = ( FileDescription.Frequency__c == 'Weekly') ? '' : String.ValueOf(LastDateFileProduction.Month()).Trim().leftPad(2).replace(' ','0'); 
        String weekOfYear = ( FileDescription.Frequency__c != 'Weekly' ) ? '' : String.ValueOf(LastDateFileProduction.format('w')).trim() + '_' ;
        String dayOfMonth = ( FileDescription.Frequency__c != 'Daily' ) ? '' :  String.valueOf(Date.today().day()).trim().leftPad(2).replace( ' ', '0') + '_';
        String dateStamp =  ( FileDescription.Frequency__c == 'Daily' ) ? '' : '_' + String.ValueOf(Date.today().day()).trim().leftPad(2).replace(' ','0');
        
        String returnString = 'TDF_'+ FileDescription.Product_Type__c + '_' + FileDescription.Frequency__c 
                            + '_' + weekOfYear + dayOfMonth + MonthProduction + YearProduction
                            + dateStamp
                            + '.tdf';
        return returnString; 
    }
     
    // this has to be consistent with the naming in GSS_REST_ConfirmFileProduction.cls
    // the internal file production name is <GDP_File_Production__c.Id-18_digit>_YYYY_MM.dat
    global static String getProductionFileName(String Source, String YearProduction, String MonthProduction)
    {
        String Month = MonthProduction.trim().leftPad(2).replace(' ','0'); 
        return Source +'_' + YearProduction +'_' + Month +'.dat'; 
    }
    
    /* GDP-222 Send dynamically the filename base on filenaming convension*/
    //Keep this function static global as it will be called by GUI 
    //This function converts the FileNamingConvension with today parameters replacements and adds prefix and suffix
    global static  String getFileNameDynamic(Date TodaySystem, String FileNaming, String Prefix, String Suffix){
        //Example substitution
        //String Prefix = '-PREFIX-';
        //String FileNaming = 'CGOLA_Week[ww]_[yyyy].AW';
        //String Suffix = '-SUFFIX-';
        //                  11111111112222
        //        012345678901234567890123  
        //        [Prefix]CGOLA_Week[ww]_[yyyy][Suffix].AW
        //-PREFIX-CGOLA_Week.43_201-SUFFIX-.AW
        String DynamicFileName = FileNaming;
        DynamicFileName = DynamicFileName.Replace('[yyyy]', DateTime.now().Format('yyyy'));
        DynamicFileName = DynamicFileName.Replace('[ddd]' , String.valueOf( TodaySystem.dayOfYear()).leftPad(3).replace(' ','0'));
        DynamicFileName = DynamicFileName.Replace('[ww]'  , DateTime.now().Format('w').leftPad(2).replace(' ','0'));
        DynamicFileName = DynamicFileName.Replace('[1-2]' , TodaySystem.Day() >= 16 ? '1': '2');
        
        //The suffix and prefix have to be a replacement like above 
        //EX: String FileNaming = '[prefix]CGOLA_Week[ww]_[yyyy][suffix].AW';
        //EX: DynamicFileName = DynamicFileName.Replace('[prefix]' , Prefix);
        //EX: DynamicFileName = DynamicFileName.Replace('[suffix]' , Suffix);
        
        //Suffix injection
        if(Suffix == null) Suffix='';
        if(DynamicFileName.containsIgnoreCase('[suffix]')) DynamicFileName = DynamicFileName.replaceAll('(?i)\\[suffix\\]' , Suffix);
           
        
        //Prefix injection
        if  (Prefix == null) Prefix='';
        if(DynamicFileName.containsIgnoreCase('[prefix]')) DynamicFileName = DynamicFileName.replaceAll('(?i)\\[prefix\\]' , Prefix);
       
        //System.debug(DynamicFileName);    
        Return DynamicFileName;               
    } // end of getFileNameDynamic
    
    
    // =======================================================================
    // isTodayTheDeliveryDay 
    //   return true if today is the day to do the file delivery on this GSS_Subscription_Detail
    //   originally, this is only based on Calendar_*_Option, Frequency, and Date.today()
    //   but to cover the change of Calendar_*_Option values we also use: 
    //   Calendar_Next_SubmissioN_Date and Calendar_New_Submission_Effective_Date
    private static Boolean isTodayTheDeliveryDay(Date TodaySystem, GSS_Subscription_Detail__c subscriptionDetail)
    {
        Boolean DayIncluded=false;
        if (subscriptiondetail.GDP_File_Description__r.Frequency__c=='Daily') DayIncluded=true;
        System.Debug('1-1 DayIncluded >>>'+DayIncluded);
        if (subscriptionDetail.Calendar_Next_Submission_Date__c == TodaySystem) 
        {
            DayIncluded = true;
        }
        System.Debug('2-1 DayIncluded >>>'+DayIncluded);
        if ( (subscriptionDetail.Calendar_New_Submission_Effective_Date__c != null)
            && (subscriptionDetail.Calendar_New_Submission_Effective_Date__c > TodaySystem) )
        { // this is the transition period after changing the Calendar_*_Option__c values
            // do not use Calendar_*_Option for decided to include or not.
            return DayIncluded;
        }
        System.Debug('3-1 DayIncluded >>>'+DayIncluded);
        // --------------------------------------------------------------------
        // check the possibility that today is the delivery day based on the normal Calendar_*_Option values.
        String Delivery_Period_Day='';
        if (subscriptiondetail.Calendar_Semi_Monthly_First_Option__c!=null) Delivery_Period_Day = subscriptiondetail.Calendar_Semi_Monthly_First_Option__c;
        if (subscriptiondetail.Calendar_Semi_Monthly_Second_Option__c!=null) Delivery_Period_Day += ';' +subscriptiondetail.Calendar_Semi_Monthly_Second_Option__c;
        if (subscriptiondetail.Calendar_Monthly_Option__c!=null) Delivery_Period_Day += ';' +subscriptiondetail.Calendar_Monthly_Option__c;
        if (Delivery_Period_Day!='')
        {
            String[] Pday = Delivery_Period_Day.Split(';');
            //Get the day of  today
            Integer  Day = TodaySystem.Day(); 
            System.Debug('4-0 Day >>>'+Day);
            for (String dayofthemonth: Pday) 
            {
                System.Debug('4-1 dayofthemonth >>>'+dayofthemonth);
                if ( dayofthemonth.length()>0 
                    && Integer.ValueOf(dayofthemonth)==Day) 
                {
                    DayIncluded=true;
                }
            }
        }
        System.Debug('4-2 DayIncluded >>>'+DayIncluded);
        Delivery_Period_Day='';
        if (subscriptiondetail.Calendar_Weekly_Option__c!=null) Delivery_Period_Day = subscriptiondetail.Calendar_Weekly_Option__c;
        if (Delivery_Period_Day!='')
        {
            //Get the day of the week       
            String dayOfWeek=System.Now().format('EEEE');
            String[] Pday = Delivery_Period_Day.Split(';');                                               
            for (String dayoftheweek: Pday) if (dayoftheweek==DayOfWeek) DayIncluded=true;
        }
        //The Period and the day is not matching so there is no file generation
        //happening
        System.Debug('5-1 DayIncluded >>>'+DayIncluded);
        
        return DayIncluded;
    }
}