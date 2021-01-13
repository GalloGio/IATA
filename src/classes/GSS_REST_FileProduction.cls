/******************************************************************************
    GSS_REST_FileProduction: HTTP GET REST API Service: FileProduction
    - Return the list of File_Description__c (a.k.a FileSpecification) to generate
    
    Created by Abdellah Bellahssan - 2015-10-09 
    Change log:
    - 2015-12-07: Sonny Leman: map File_Description__c.Product_Type__c to JSON FileProduction.ProductType
    - 2015-12-11: Abdellah Bellahssan/Sonny Leman: add LastRecordID in the return JSON message, add IsUniqueRequest parameter  
    - 2016-11-17: Abdellah Bellahssan Weekly Calendar needs to be on the Sundays and Semi-Monthly Calendar on the First of the Month and on The 16th of the Month

******************************************************************************/
@RestResource(urlMapping='/GSS/v0/FileProduction/*')
global with sharing class GSS_REST_FileProduction{

    @HttpGet
    global static void getFiletoProduce() {
        Integer BATCH_SIZE = 100; // So far, 200 will fail: Apex CPU time limit , or UNKNOWN_EXCEPTION 
        final String REF_AGENCY='Agency';
        final String REF_AIRLINE='Airline';

        RestContext.response.statuscode = 200;      //Create an empty list of FileSpecifiation that will be sent as a response
        FileProductionCls responseFSlist = new FileProductionCls();
        //Get the input parameters: expecting an class ListOfSubscriptionId
        //try{
        //system.debug('RestContext.request.requestBody.toString()>>>' +RestContext.request.requestBody.toString());                       
        //Get the input subscriptionID list by deserializing the header request

        String IsUniqueRequest = RestContext.request.params.get('IsUniqueRequest');
        String SpecificationId = RestContext.request.params.get('FileSpecificationId');
        String AtomId = RestContext.request.params.get('Atom');
        if (AtomId==null) AtomId='';
        //If the AtomId is empty this means all atom are selected at the expection of Atom 0 (read zero)
        Set<String> AtomSet = new Set<String>();
        Schema.DescribeFieldResult fieldResult = GDP_File_Description__c.Atom__c.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();            
        for( Schema.PicklistEntry f : ple)
        {
          if (f.getLabel()=='0') continue;
          if (AtomId!='' && AtomId.equals(f.getLabel())==false) continue;
          AtomSet.Add(f.getLabel());
        }       

        if (isUniqueRequest=='true') {
             List<GDP_File_Description__c> UniqueList = new List<GDP_File_Description__c>();
             UniqueList=  [Select id
                                 FROM GDP_File_Description__c
                                     WHERE Id <:SpecificationId
                                     Order By Id desc
                                 LIMIT 1];
            if (UniqueList.Size()>0) {
                SpecificationId=UniqueList[0].id;
            } else {
                SpecificationId='000000000000000';
            }
             BATCH_SIZE =1 ;
         }
       

        //Select the Valid Subscriptions and Where there is a need to generate the file
        //TempFileSpecificationLookup__c is the temporary lookup on the subscription to the specification
        //TODO : Retrieve the File Specification  Period and PeriodDay (WeekDay, MonthDay...)
        //Build set of delivery
        //Exclude from the list Subscription already processed
        //TODO: 
        //Query the GDP_File_Description__c to retrieve the File Specification details
        List<GDP_File_Description__c> SpecificationList = new List<GDP_File_Description__c>();
 
        //Because the Query is not dynamic
        
        SpecificationList = 
            [SELECT Id
             ,Geo_Coverage_Definition__c
             ,Class__c
             ,Atom__c
             ,File_Format__c
             ,Magnitude__c
             ,Master_File_Description__c
             ,Frequency__c
             ,Description__c
             ,Field_API__c
             ,Field_Label__c
             ,Field_Length__c
             ,Field_Type__c   
             ,Field_Group__c
             ,Field_Object_Name__c
             ,Field_Hidden_Columns__c
             ,File_Naming_Convention__c
             ,Field_Xml_Name__c
             ,Field_Xml_Structure__c
             ,Field_Xml_Hidden__c
             ,Field_Txt_Hidden__c
             ,Field_Xml_Group__c
             ,Database_Connector__c
             ,Product_Type__c
             ,Reference__c
             ,Reference__r.Field_API__c
             ,Reference__r.Field_Label__c
             ,Reference__r.Field_Length__c
             ,Reference__r.Field_Type__c  
             ,Reference__r.Field_Object_Name__c
             ,Reference__r.Field_Group__c
             ,Reference__r.Field_Hidden_Columns__c
             ,Reference__r.Field_Xml_Name__c
             ,Reference__r.Field_Xml_Structure__c
             ,Reference__r.Field_Xml_Hidden__c
             ,Reference__r.Field_Txt_Hidden__c
             ,Reference__r.Field_Xml_Group__c
             ,Reference__r.Service_Target__c
             ,Reference__r.Product_Type__c
             ,Reference__r.Payload_Procedure__c
             ,(select Id
               ,LastModifiedDate
               ,Production_Date__c
               ,Size__c
               ,Duration__c
               ,Status__c 
               From GDP_File_Productions__r 
               Where Status__c='Completed'
               Order By LastModifiedDate Desc 
               Limit 1)
             FROM GDP_File_Description__c
             WHERE Id >:SpecificationId
             and Is_Reference__c=false
             and Atom__c=:AtomSet
            /* and Magnitude__c='Master'*/
             Order By Id
         LIMIT :BATCH_SIZE];
        
        //Also load the last production list from GDP_File_Production
        boolean ProduceFile=false;
        DateTime LastDateFileProduction;
        String FileSize='';
        String FileDuration='';
        for(GDP_File_Description__c fs : SpecificationList){
          responseFSlist.LastRecordID=fs.id;
          //TODO: Make sure today I have to produce the file
          ProduceFile=true;
          
          LastDateFileProduction = System.Today();
          FileSize='';
          FileDuration='';          
          for(GDP_File_Production__c fp:fs.GDP_File_Productions__r)
          {
              ProduceFile=false;
              LastDateFileProduction=fp.Production_Date__c;
              if (fp.Size__c!=null) FileSize=String.ValueOf(fp.Size__c);
              if (fp.Duration__c!=null) FileSize=String.ValueOf(fp.Duration__c);
          }
          //Make sure to Generate when needed
          //What is the Calendar based on Weekly or Semi-Monthly
          //Semi-Monthly
          Date NextDateProduction = System.Today();

          Integer NextDay  =NextDateProduction.Day();
          Integer NextMonth=NextDateProduction.Month();
          Integer NextYear =NextDateProduction.Year();
          
          Integer LastDay  =LastDateFileProduction.Day();
          Integer LastMonth=LastDateFileProduction.Month(); 
          Integer LastYear =LastDateFileProduction.Year();

          Date LastFirstDate = Date.newInstance(LastYear, LastMonth, 1);
          Date LastSemiDate = Date.newInstance(LastYear, LastMonth, 16);
          
          Date NextFirstDate = Date.newInstance(NextYear, NextMonth, 1);
          Date NextSemiDate = Date.newInstance(NextYear, NextMonth, 16);
         
          //Weekly
          Datetime NextDateTimeProduction = DateTime.newInstance(NextDateProduction, Time.newInstance(0, 0, 0, 0));
          String dayOfWeek=NextDateTimeProduction.format('EEEE').ToLowerCase();
              
          if (fs.Frequency__c=='Daily' && LastDateFileProduction<NextDateProduction) ProduceFile=true;
          if (fs.Frequency__c=='Weekly' && (LastDateFileProduction<NextDateProduction && dayOfWeek=='sunday' )) ProduceFile=true;
         
          //Lpd>=1 && <16 of the month and today>=16 of the same month ==> production
          //Lpd>=16 of the last month && <1 of current month and today<16 of the current month ==> production
          //if (fs.Frequency__c=='Semi-Monthly' && LastDateFileProduction<NextDateProduction && (NextDateProduction.Day()==16 || NextDateProduction.Day()==1) )  ProduceFile=true;
          if (fs.Frequency__c=='Semi-Monthly' && (LastDateFileProduction>=LastFirstDate && LastDateFileProduction< LastSemiDate && NextDateProduction>=NextSemiDate )) ProduceFile=true;
          if (fs.Frequency__c=='Semi-Monthly' && (LastDateFileProduction>=LastSemiDate && LastDateFileProduction<NextFirstDate  && LastFirstDate<NextFirstDate ))  ProduceFile=true;
          if (fs.Frequency__c=='Monthly' && (LastFirstDate<NextFirstDate)) ProduceFile=true;
          
          if (ProduceFile)
          {
              FieldStructureCls fieldstructure = new FieldStructureCls();
              fieldstructure.LoadFieldStructure(
                     fs.Reference__c!=null ? fs.Reference__r.Field_API__c :fs.Field_API__c
                    ,fs.Reference__c!=null ? fs.Reference__r.Field_Label__c :fs.Field_Label__c
                    ,fs.Reference__c!=null ? fs.Reference__r.Field_Length__c:fs.Field_Length__c
                    ,fs.Reference__c!=null ? fs.Reference__r.Field_Type__c:fs.Field_Type__c
                    ,fs.Reference__c!=null ? fs.Reference__r.Field_Object_Name__c:fs.Field_Object_Name__c
                    ,fs.Reference__c!=null ? fs.Reference__r.Field_Group__c:fs.Field_Group__c
                    ,fs.Reference__c!=null ? fs.Reference__r.Field_Hidden_Columns__c:fs.Field_Hidden_Columns__c
                    ,fs.Reference__c!=null ? fs.Reference__r.Field_Xml_Name__c:fs.Field_Xml_Name__c
                    ,fs.Reference__c!=null ? fs.Reference__r.Field_Xml_Structure__c:fs.Field_Xml_Structure__c
                    ,fs.Reference__c!=null ? fs.Reference__r.Field_Xml_Hidden__c:fs.Field_Xml_Hidden__c
                    ,fs.Reference__c!=null ? fs.Reference__r.Field_Txt_Hidden__c:fs.Field_Txt_Hidden__c
                    ,fs.Reference__c!=null ? fs.Reference__r.Field_Xml_Group__c:fs.Field_Xml_Group__c
                    );
             FileProduction nfs = new FileProduction();
             Integer HIDDENFIELD=3;
             if (fs.File_Format__c=='XML') HIDDENFIELD=7;
             if (fs.File_Format__c=='TXT') HIDDENFIELD=8;
             //load all the configuration for the Agency, Territory and Airline if needed
             nfs.FileSpecificationID = fs.Id;
             nfs.AgencyFileFieldsLabels  = fieldstructure.ExtractField(HIDDENFIELD, 0, REF_AGENCY);
             nfs.AgencyFileFieldsLengths = fieldstructure.ExtractField(HIDDENFIELD, 1, REF_AGENCY);
             nfs.AgencyFileFieldsTypes   = fieldstructure.ExtractField(HIDDENFIELD, 2, REF_AGENCY);
             nfs.AgencyFileFieldsHidden  = fieldstructure.ExtractField(HIDDENFIELD, HIDDENFIELD, REF_AGENCY);
             nfs.AgencyFileObjectName    = fieldstructure.ExtractField(HIDDENFIELD, 4, REF_AGENCY);
             nfs.AgencyFileFieldsAPI     = fieldstructure.ExtractField(HIDDENFIELD, 5, REF_AGENCY);
             nfs.AgencyFileFieldsGroup   = fieldstructure.ExtractField(HIDDENFIELD, 11, REF_AGENCY);
             
             nfs.AgencyFileXmlName       = fieldstructure.ExtractField(HIDDENFIELD, 6, REF_AGENCY);
             nfs.AgencyFileFieldXmlStructure  = fieldstructure.ExtractField(HIDDENFIELD, 10, REF_AGENCY);
             nfs.AgencyFileXmlGroup      = fieldstructure.ExtractField(HIDDENFIELD, 9, REF_AGENCY); 
             
             nfs.AirlineFileFieldsLabels  = fieldstructure.ExtractField(HIDDENFIELD, 0, REF_AIRLINE);
             nfs.AirlineFileFieldsLengths = fieldstructure.ExtractField(HIDDENFIELD, 1, REF_AIRLINE);
             nfs.AirlineFileFieldsTypes   = fieldstructure.ExtractField(HIDDENFIELD, 2, REF_AIRLINE);
             nfs.AirlineFileFieldsHidden  = fieldstructure.ExtractField(HIDDENFIELD, HIDDENFIELD, REF_AIRLINE);
             nfs.AirlineFileObjectName    = fieldstructure.ExtractField(HIDDENFIELD, 4, REF_AIRLINE);
             nfs.AirlineFileFieldsAPI     = fieldstructure.ExtractField(HIDDENFIELD, 5, REF_AIRLINE);
             nfs.AirlineFileFieldsGroup   = fieldstructure.ExtractField(HIDDENFIELD, 11, REF_AIRLINE);
             
             nfs.AirlineFileXmlName       = fieldstructure.ExtractField(HIDDENFIELD, 6, REF_AIRLINE);
             nfs.AirlineFileFieldXmlStructure  = fieldstructure.ExtractField(HIDDENFIELD, 10, REF_AIRLINE);
             nfs.AirlineFileXmlGroup      = fieldstructure.ExtractField(HIDDENFIELD, 9, REF_AIRLINE); 
             
             nfs.DatabaseConnector = fs.Database_Connector__c ==null ? '': fs.Database_Connector__c;
             nfs.FileSubscribedFormat = fs.File_Format__c;
             nfs.ProductType = fs.Reference__r.Product_Type__c;
             nfs.PayloadName =fs.Reference__r.Payload_Procedure__c;
             nfs.Size=FileSize;
             nfs.Duration=FileDuration;
             responseFSlist.FileProductions.add(nfs);
          }
         }
           
         system.debug('responseFSlist>>>>' + responseFSlist);
         //Return   
         RestContext.response.addHeader('Content-Type', 'application/json');
         try {                                        
            RestContext.response.responseBody = Blob.valueOf(json.serialize(responseFSlist));  
         }
         catch(exception e){
            //Unable to deserialize in expected format
            system.debug('exception>>>>' + e.getMessage());
            //RestContext.response.statuscode = 400;
            RestContext.response.responseBody = Blob.valueOf(json.serialize(responseFSlist));
         }
    
    } // end of getFiletoProduce 
    
    
    //Master Field Structure
    global class FieldStructureCls {
         public String[] FieldLabel {get;set;}
         public String[] FieldLength {get;set;}
         public String[] FieldAPIName {get;set;}
         public String[] FieldType {get;set;}
         public String[] FieldObjectName {get;set;}
         public String[] FieldGroup {get;set;}
         public String[] FieldHiddenColumn {get;set;}
         public String[] XmlName {get;set;}
         public String[] FieldXmlStructure {get;set;}
         public String[] FieldXmlHiddenColumn {get;set;}
         public String[] FieldTxtHiddenColumn {get;set;}
         public String[] XmlGroup {get;set;}
         
         public FieldStructureCls()
         {
         }
         
         
         public void LoadFieldStructure(String vFieldAPIName,
                                        String vFieldLabel,
                                        String vFieldLength,
                                        String vFieldType,
                                        String vFieldObjectName,
                                        String vFieldGroup,
                                        String vFieldHiddenColumn,
                                        String vXmlName,
                                        String vFieldXmlStructure,
                                        String vXmlHiddenColumn,
                                        String vTxtHiddenColumn,
                                        String vXmlGroup
                                  ){
            if (vFieldAPIName!=null) FieldAPIName=vFieldAPIName.Split('\\|');
            if (vFieldType!=null) FieldType=vFieldType.Split('\\|');
            if (vFieldLabel!=null) FieldLabel=vFieldLabel.Split('\\|');
            if (vFieldLength!=null) FieldLength=vFieldLength.Split('\\|');
            if (vFieldGroup!=null) FieldGroup=vFieldGroup.Split('\\|');
            if (vFieldObjectName!=null) FieldObjectName=vFieldObjectName.Split('\\|');
            if (vFieldHiddenColumn!=null) FieldHiddenColumn=vFieldHiddenColumn.Split('\\|');
            if (vXmlName!=null)  XmlName=vXmlName.Split('\\|');
            if (vFieldXmlStructure!=null)  FieldXmlStructure=vFieldXmlStructure.Split('\\|');
            if (vXmlHiddenColumn!=null) FieldXmlHiddenColumn=vXmlHiddenColumn.Split('\\|');
            if (vTxtHiddenColumn!=null) FieldTxtHiddenColumn=vTxtHiddenColumn.Split('\\|');
            if (vXmlGroup!=null)  XmlGroup=vXmlGroup.Split('\\|');
           
        }
        public String ExtractField(Integer FileType, Integer TypeList, String ObjectName)
        {
            Integer TYPE_LABEL=0;
            Integer TYPE_LENGTH=1;
            Integer TYPE_TYPE=2;
            Integer TYPE_HIDDEN=3;
            Integer TYPE_OBJECT=4;
            Integer TYPE_API=5;
            Integer TYPE_XMLNAME=6;
            Integer TYPE_XMLHIDDEN=7;
            Integer TYPE_TXTHIDDEN=8;
            Integer TYPE_XMLGROUP=9;
            Integer TYPE_XMLSTRUCTURE=10;
            Integer TYPE_GROUP=11;
            
            String stringreturn='';
            integer i=-1;
            integer m=0;
            String[] ValueList;
            String[] FileValueList;

            if (TypeList==TYPE_LABEL) ValueList = this.FieldLabel;
            if (TypeList==TYPE_LENGTH) ValueList = this.FieldLength;
            if (TypeList==TYPE_TYPE) ValueList = this.FieldType;
            if (TypeList==TYPE_HIDDEN) ValueList = this.FieldHiddenColumn;
            if (TypeList==TYPE_OBJECT) ValueList = this.FieldObjectName;
            if (TypeList==TYPE_API) ValueList = this.FieldAPIName;
            if (TypeList==TYPE_XMLNAME) ValueList = this.XmlName;
            if (TypeList==TYPE_XMLHIDDEN) ValueList = this.FieldXmlHiddenColumn;
            if (TypeList==TYPE_TXTHIDDEN) ValueList = this.FieldTxtHiddenColumn;
            if (TypeList==TYPE_XMLGROUP) ValueList = this.XmlGroup;
            if (TypeList==TYPE_XMLSTRUCTURE) ValueList = this.FieldXmlStructure; 
            if (TypeList==TYPE_GROUP) ValueList = this.FieldGroup;

            if (FileType==TYPE_TXTHIDDEN && TypeList==TYPE_LENGTH) FileValueList = this.FieldTxtHiddenColumn;
            
            if (ValueList==null) return '';
            for(String stringvalue:ValueList)
             {
                  i++;                
                  if (this.FieldGroup[i]!=ObjectName) continue;  
                  if (m>0) stringreturn +=','; 
                  if (FileType==TYPE_TXTHIDDEN && TypeList==TYPE_LENGTH) { if (FileValueList[i]=='1') stringvalue='0';}
                  stringreturn +=stringvalue; 

                  m++;
             }
             return stringreturn;
        }
        
        
    }
    /*
    //Definition of JSON Request object
    global class ListOfSubscriptionId {
        public List<string> SubscriptionIdList;
        
        public ListOfSubscriptionId(List<string> l) {
            this.SubscriptionIdList = l;
        }
    } */   
    
    // ==============================================================
    //Definition of JSON Response object
    //
   
    global Class FileProductionCls
    {
        public String LastRecordID {get; set;}
        public List<FileProduction> FileProductions {get;set;}
        public FileProductionCls()
        {
            FileProductions= new List<FileProduction>();
            this.LastRecordID='';
        }
    } // end of FileProductionCls which will be the returned JSON format
    
    
    global class FileProduction{
        public string FileSpecificationID {get;set;}
        public string AgencyFileFieldsLabels {get;set;}
        public string AgencyFileFieldsLengths {get;set;}
        public string AgencyFileFieldsTypes {get;set;}
        public string AgencyFileFieldsHidden {get;set;}
        public string AgencyFileFieldsApi {get;set;}
        public string AgencyFileFieldsGroup {get;set;}
        public string AgencyFileObjectName {get;set;}
        public String AgencyFileXmlName {get;set;}
        public String AgencyFileFieldXmlStructure {get;set;}
        public String AgencyFileXmlGroup {get;set;}
        
        public string AirlineFileFieldsLabels {get;set;}
        public string AirlineFileFieldsLengths {get;set;}
        public string AirlineFileFieldsTypes {get;set;}
        public string AirlineFileFieldsHidden {get;set;}
        public string AirlineFileFieldsApi {get;set;}
        public string AirlineFileFieldsGroup {get;set;}
        public string AirlineFileObjectName {get;set;}
        public String AirlineFileXmlName {get;set;}
        public String AirlineFileFieldXmlStructure {get;set;}
        public String AirlineFileXmlGroup {get;set;}
        
        public String FilePeriod {get;set;}
        
        public String FileNamingPrefix {get;set;}
        public String FileNamingSuffix {get;set;}
        public String FileNaming {get;set;}
        public String FileSubscribedFormat {get;set;}
        
        
        public String FilePeriodDay {get;set;}
        public String FilePeriodWeekDay {get;set;}
        public String TdfRecipient {get;set;}
        public String DatabaseConnector {get;set;}
        
        public String ProductType {get;set;} // GSS or MDP
        public String PayloadName {get;set;}
        public String Size {get;set;}
        public String Duration {get;set;}
        
        public FileProduction()
        {
            this.AgencyFileFieldsLabels  = '';
            this.AgencyFileFieldsLengths = '';
            this.AgencyFileFieldsTypes   = '';
            this.AgencyFileFieldsHidden  = '';
            this.AgencyFileFieldsAPI  = '';
            this.AgencyFileFieldsGroup  = '';
            this.AgencyFileObjectName = '';
            this.AgencyFileXmlName = '';
            this.AgencyFileFieldXmlStructure = '';
            this.AgencyFileXmlGroup = '';       

            
            this.AirlineFileFieldsLabels  = '';
            this.AirlineFileFieldsLengths = '';
            this.AirlineFileFieldsTypes   = '';
            this.AirlineFileFieldsHidden  = '';
            this.AirlineFileFieldsAPI  = '';
            this.AirlineFileFieldsGroup  = '';
            this.AirlineFileObjectName = '';
            this.AirlineFileXmlName = '';
            this.AirlineFileFieldXmlStructure = '';
            this.AirlineFileXmlGroup = '';       
             
            this.FilePeriod='Daily';
            
            this.FileNamingPrefix='';
            this.FileNamingSuffix='';
            this.FileNaming='toto';
            this.FileSubscribedFormat='txt';
            
            this.FilePeriodDay='';
            this.FilePeriodWeekDay='';
            this.TdfRecipient='';
            this.DatabaseConnector='';
            
            this.ProductType = '';
            this.PayloadName='';
            
            this.Size='';
            this.Duration='';
        } // end of FileProduction constructor
    } // end of FileProduction class
}