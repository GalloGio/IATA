/**
 * This test class test some GSS_REST classes 
 *  - GSS_REST_Subscription: /GSS/v0/Subscriptions/*
 *  - GSS_REST_FileSpecification: /GSS/v0/FileSpecification/*
 *  - GSS_REST_ConfirmFileDelivery: /GSS/v0/ConfirmFileDelivery/*
 *  - GSS_REST_FileProduction: /GSS/v0/FileProduction/*
 *  - GSS_REST_FilePayload: /GSS/v0/FileDataAgency/
 *  - GSS_REST_ConfirmFileProduction: /GSS/v0/ConfirmFileProduction
 *  - GSS_REST_ErrorHandler: /GSS/v0/ExceptionHandler
 *
 * Original Author: Alexandre Jaimes
 * Change log:
 *   2016-04-11-sl: fix and split testGetFileSpecification, add IINETUserID__c in myBillingAcct.
 *   2016-04-20-sl: update testGetFileProduction*() to increase coverage on GSS_REST_FileProduction.
 *
 */


@isTest (SeeAllData=false)
global class GSS_REST_Test {
    public static IATA_ISO_Country__c myCountry;
    public static Account myAcct;
    public static Zuora__CustomerAccount__c myBillingAcct;
    public static zqu__ZProduct__c myZProduct;
    public static Product_Category__c myProductCategory;
    public static Product_Information__c myProductInformation;
    public static Zuora__Subscription__c mySubscription;
    public static Zuora__Subscription__c mySubscriptionWeekly;
    public static GDP_File_Description__c myFileDescription;
    public static GDP_File_Description__c myFileDescriptionReference;
    public static GDP_File_Description__c myFileDescriptionDeltaDaily;
    public static GDP_File_Description__c myFileDescriptionDeltaWeekly;
    
    public static List<GDP_File_Fields_Description__c> myFileFieldsDescription;
    //public static Zuora__SubscriptionProductCharge__c mySubscriptionProductCharge;
    public static GSS_Subscription_Detail__c mySubscriptionDetail;
    public static GSS_Subscription_Detail__c mySubscriptionDetailWeekly;
    
    public static list<GDP_Products_Account_View__c> GDP_Products_Account_View_list;
    public static Accreditation__c myAccreditation1;
    public static Accreditation__c myAccreditation2;
    public static Map<String,id> ReferenceMap;
    
    private static String ZUORA_SUBSCRIPTION_ID_DAILY = '22345678901234567890123456789012';
    private static String ZUORA_SUBSCRIPTION_ID_WEEKLY = '11112222333344445555666677778888';
    
    private static final String FILE_DESCRIPTION_NAME_NON_REFERENCE_DELTA_DAILY_01 = 'CGO1DeltaDaily';
    
    @testSetup public static void SetupTestData() {
        // setup test data method shared with all testMethods
 
        //Create iso code for account creation
        myCountry = new IATA_ISO_Country__c (
            AIMS_Area_Name__c='Canada', 
            ISO_Code__c='CA', 
            AIMS_Area_ID__c='1'
        );
        insert myCountry;
        
        //Create an account
        myAcct  = new Account (
            name = 'testaccoppclone', 
            site = 'test',
            BillingCity='test',
            BillingCountry='Canada', 
            type='IATA Passenger Sales Agent', 
            Location_Type__c='BR'
        );
        Insert myAcct;
        
        //Create a zuora business account
        myBillingAcct = new Zuora__CustomerAccount__c(
            name = myAcct.name,
            Zuora__Account__c = myAcct.Id,
            Zuora__Zuora_Id__c = '12345678901234567890123456789012',
            IINETUserID__c = 'a10101'
        );
        Insert myBillingAcct;
        
        
        // add a ZProduct
        myZProduct = IECTestUtil.CreateSampleProduct('Test zProduct');
        insert myZProduct;
        
        // Create Product Category
        myProductCategory =IECTestUtil.CreateSampleProductCategory(IECConstants.ProductCategory_SF_CACPRO, true);
        insert myProductCategory;
        
        // Create Product Information                 
        myProductInformation = IECTestUtil.CreateSampleProductInfo('Test ProductInformation', myProductCategory, myZProduct);
        myProductInformation.Product_Audience__c = IECConstants.ProductInformationAudience_DEFAULT;
        insert myProductInformation;
        
        //Create an active subscription for this account / billing account
        mySubscription = new Zuora__Subscription__c (
            Name = myAcct.name+' Subscription',
            Zuora__Account__c =myAcct.id,
            Zuora__CustomerAccount__c = myBillingAcct.Id,
            Zuora__Zuora_Id__c = ZUORA_SUBSCRIPTION_ID_DAILY, // '22345678901234567890123456789012', 
            Zuora__SubscriptionStartDate__c = Date.today().addYears(-1),
            Zuora__SubscriptionEndDate__c = Date.today().addYears(1),
            Zuora__Status__c = 'Active'
        );
        mySubscriptionWeekly = new Zuora__Subscription__c (
            Name = myAcct.name+' SubscriptionWeekly',
            Zuora__Account__c =myAcct.id,
            Zuora__CustomerAccount__c = myBillingAcct.Id,
            Zuora__Zuora_Id__c = ZUORA_SUBSCRIPTION_ID_WEEKLY, //'11112222333344445555666677778888', 
            Zuora__SubscriptionStartDate__c = Date.today().addYears(-2),
            Zuora__SubscriptionEndDate__c = Date.today().addYears(1),
            Zuora__Status__c = 'Active'
        );
        List<Zuora__Subscription__c> zuoraSubscriptionList = new List<Zuora__Subscription__c>();
        zuoraSubscriptionList.add(mySubscription);
        zuoraSubscriptionList.add(mySubscriptionWeekly);
        Insert zuoraSubscriptionList;
        System.debug('zuoraSubscriptionList>>' + zuoraSubscriptionList);
        
        //Create the reference File Description
        myFileDescriptionReference = new GDP_File_Description__c(
            Name = 'CGO1Ref',
            File_Format__c='TXT',
            Frequency__c='Daily',
            Reference__c=null,
            Class__c='',
            Magnitude__c='Master',
            Field_Label__c='',
            Description__c='Test Reference File description',
            File_Naming_Convention__c='Name'
        );
        Insert myFileDescriptionReference;
        
        //Create a file specification master, non reference
        myFileDescription = new GDP_File_Description__c(
            Name = 'CGO1Master',
            File_Format__c='TXT',
            Frequency__c='Daily',
            Field_Label__c='',
            Reference__c=myFileDescriptionReference.id,
            Class__c='',
            Magnitude__c='Master',
            Description__c='File Description Child 1',
            File_Naming_Convention__c='[Prefix]CGO1Master_Day[ddd]_[yyyy][Suffix].AM',
            Atom__c = '1'
        );
        Insert myFileDescription;
        
        //Create a file specification master, non reference
        myFileDescriptionDeltaDaily = new GDP_File_Description__c(
            Name = FILE_DESCRIPTION_NAME_NON_REFERENCE_DELTA_DAILY_01, // CGO1DeltaDaily
            File_Format__c='TXT',
            Frequency__c='Daily',
            Field_Label__c='',
            Reference__c=myFileDescriptionReference.id,
            Master_File_Description__c= myFileDescription.Id,
            Class__c='',
            Magnitude__c='Delta',
            Description__c='File Description Delta Daily 1',
            File_Naming_Convention__c='[Prefix]CGO1Delta_Day[ddd]_[yyyy][Suffix].AD',
            Atom__c = '2'
        );
        //Create a file specification master, non reference
        myFileDescriptionDeltaWeekly = new GDP_File_Description__c(
            Name = 'CGO1DeltaWeekly',
            File_Format__c='TXT',
            Frequency__c='Weekly',
            Field_Label__c='',
            Reference__c=myFileDescriptionReference.id,
            Master_File_Description__c= myFileDescription.Id,
            Class__c='',
            Magnitude__c='Delta',
            Description__c='File Description Delta Weekly 2',
            File_Naming_Convention__c='[Prefix]CGO1Delta_Weekly [ddd]_[yyyy][Suffix].AD'
        );
        List<GDP_File_Description__c> fileDescriptionList = new List<GDP_File_Description__c>();
        fileDescriptionList.add(myFileDescriptionDeltaWeekly);
        fileDescriptionList.add(myFileDescriptionDeltaDaily);
        Insert fileDescriptionList;
        
        
        // insert GDP_File_Fields_Description test data related to myFileDescriptionReference
        insertGDPFileFieldsDescriptionTestData();
        
        List<GDP_File_Production__c> fileproductionlist = new List<GDP_File_Production__c>();
        fileproductionlist.Add(new GDP_File_Production__c(File_Specification__c=myFileDescriptionReference.id,Production_Date__c=System.Today(),Status__c='Completed'));
        fileproductionlist.Add(new GDP_File_Production__c(File_Specification__c=myFileDescription.id,Production_Date__c=System.Today(),Status__c='Completed'));

        insert fileproductionlist;
 
               
        //Insert GDP_Reference_Table__c 
        list<GDP_Reference_Table__c> Reference_TableList = new list<GDP_Reference_Table__c>();
        Reference_TableList.add(new GDP_Reference_Table__c(Code__c='0', Table__c='STATUS', System__c='WebStar', Definition__c='TERMINATED',                     Name='TERMINATED'));
        Reference_TableList.add(new GDP_Reference_Table__c(Code__c='1', Table__c='STATUS', System__c='WebStar', Definition__c='ONHOLD',                         Name='ONHOLD')); 
        Reference_TableList.add(new GDP_Reference_Table__c(Code__c='2', Table__c='STATUS', System__c='WebStar', Definition__c='APPLICANT',                      Name='APPLICANT'));
        Reference_TableList.add(new GDP_Reference_Table__c(Code__c='3', Table__c='STATUS', System__c='WebStar', Definition__c='UNREGISTERABLE STP',             Name='UNREGISTERABLE STP'));
        Reference_TableList.add(new GDP_Reference_Table__c(Code__c='4', Table__c='STATUS', System__c='WebStar', Definition__c='LISTED',                         Name='LISTED'));
        Reference_TableList.add(new GDP_Reference_Table__c(Code__c='5', Table__c='STATUS', System__c='WebStar', Definition__c='REGISTERED',                     Name='REGISTERED')); 
        Reference_TableList.add(new GDP_Reference_Table__c(Code__c='6', Table__c='STATUS', System__c='WebStar', Definition__c='UNDER REVIEW',                   Name='UNDER REVIEW')); 
        Reference_TableList.add(new GDP_Reference_Table__c(Code__c='7', Table__c='STATUS', System__c='WebStar', Definition__c='Endorsed',                       Name='Endorsed')); 
        Reference_TableList.add(new GDP_Reference_Table__c(Code__c='0', Table__c='STATUS', System__c='AIMS',    Definition__c='Terminated',                     Name='Terminated'));
        Reference_TableList.add(new GDP_Reference_Table__c(Code__c='1', Table__c='STATUS', System__c='AIMS',    Definition__c='1',                              Name='1')); 
        Reference_TableList.add(new GDP_Reference_Table__c(Code__c='2', Table__c='STATUS', System__c='AIMS',    Definition__c='2',                              Name='2')); 
        Reference_TableList.add(new GDP_Reference_Table__c(Code__c='3', Table__c='STATUS', System__c='AIMS',    Definition__c='3',                              Name='3')); 
        Reference_TableList.add(new GDP_Reference_Table__c(Code__c='4', Table__c='STATUS', System__c='AIMS',    Definition__c='Listed',                         Name='Listed'));
        Reference_TableList.add(new GDP_Reference_Table__c(Code__c='5', Table__c='STATUS', System__c='AIMS',    Definition__c='Cash Basis without commission',  Name='Cash Basis without commission'));
        Reference_TableList.add(new GDP_Reference_Table__c(Code__c='6', Table__c='STATUS', System__c='AIMS',    Definition__c='Cash basis with commissions',    Name='Cash basis with commissions')); 
        Reference_TableList.add(new GDP_Reference_Table__c(Code__c='7', Table__c='STATUS', System__c='AIMS',    Definition__c='Review',                         Name='Review')); 
        Reference_TableList.add(new GDP_Reference_Table__c(Code__c='8', Table__c='STATUS', System__c='AIMS',    Definition__c='Accredited-Change in process',   Name='Accredited-Change in process')); 
        Reference_TableList.add(new GDP_Reference_Table__c(Code__c='9', Table__c='STATUS', System__c='AIMS',    Definition__c='Accredited',                     Name='Accredited')); 
        Insert Reference_TableList;
        
        ReferenceMap= new map<String,id>();
        for(GDP_Reference_Table__c gr : Reference_TableList) {
            ReferenceMap.put(gr.Definition__c, gr.Id);
        }
        
        // insert data for file records, i.e. GDP_Products_Account_View and related objects
        insertGDPDataFileRecords();

        // insert file subscription detail
        mySubscriptionDetail = new GSS_Subscription_Detail__c(
            Name = 'Test Subscription Detail',
            Zuora_Subscription__c = mySubscription.Id,
            GDP_File_Description__c=myFileDescriptionDeltaDaily.Id,
            Calendar_Next_Submission_Date__c=System.Today(),
            Calendar_New_Submission_Effective_Date__c=null,
            //Calendar_Weekly_Option__c='',
            File_Name_Applies_on__c='Zip file only',
            File_Name_Prefix_Option__c = 'Custom',
            File_Name_Custom_Prefix__c='Prefix',
            File_Name_Suffix_Option__c='Custom',
            File_Name_Custom_Suffix__c='Suffix'
        );
        mySubscriptionDetailWeekly = new GSS_Subscription_Detail__c(
            Name = 'Test Subscription Detail',
            Zuora_Subscription__c = mySubscriptionWeekly.Id,
            GDP_File_Description__c=myFileDescriptionDeltaWeekly.Id,
            Calendar_Next_Submission_Date__c=System.Today(),
            Calendar_New_Submission_Effective_Date__c=null,
            Calendar_Weekly_Option__c = System.now().format('EEEE'),
            File_Name_Applies_on__c='Zip file only',
            File_Name_Prefix_Option__c = 'Custom',
            File_Name_Custom_Prefix__c='Prefix',
            File_Name_Suffix_Option__c='Custom',
            File_Name_Custom_Suffix__c='Suffix'
        );
        List<GSS_Subscription_Detail__c> subscriptionDetailList = new List<GSS_Subscription_Detail__c>();
        subscriptionDetailList.add(mySubscriptionDetail);
        subscriptionDetailList.add(mySubscriptionDetailWeekly);
        Insert subscriptionDetailList;        
        
        GDP_File_Production__c myFileProduction = new GDP_File_Production__c(
              Production_Date__c=System.today()
            , Status__c='Completed'
            , File_Specification__c=myFileDescription.Id
            );
            
        insert myFileProduction;
        
        //test.stopTest();
    }
    
    
    
    // GDP Test Data Definition
    // external input: myFileDescriptionReference.Id
    static private void insertGDPFileFieldsDescriptionTestData()
    {
        //Create Field to have the setup for id and name
        myFileFieldsDescription = new List<GDP_File_Fields_Description__c>();
        
        
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Function_RecID',API_Object_Name__c='',Filter_Field_API_Name__c='',Filter_Field_Value__c='',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='RecID',Position__c=1,Size__c=1,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Function_FileID_Member',API_Object_Name__c='',Filter_Field_API_Name__c='',Filter_Field_Value__c='',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='FileID',Position__c=2,Size__c=2,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Area__c',API_Object_Name__c='GDP_Products_Account_View__c',Filter_Field_API_Name__c='',Filter_Field_Value__c='',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Area',Position__c=4,Size__c=1,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='IATA_Code__c',API_Object_Name__c='GDP_Products_Account_View__c',Filter_Field_API_Name__c='',Filter_Field_Value__c='',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='IATACode',Position__c=5,Size__c=7,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Check_Digit__c',API_Object_Name__c='GDP_Products_Account_View__c',Filter_Field_API_Name__c='',Filter_Field_Value__c='',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='IATAChk',Position__c=12,Size__c=1,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='CASS_Number__c',API_Object_Name__c='GDP_Products_Account_View__c',Filter_Field_API_Name__c='',Filter_Field_Value__c='',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='CASSNum',Position__c=13,Size__c=4,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Location_Type__r.Code__c',API_Object_Name__c='GDP_Products_Account_View__c',Filter_Field_API_Name__c='',Filter_Field_Value__c='',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='SiteType',Position__c=17,Size__c=2,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Airline_Code__c',API_Object_Name__c='GDP_Products_Account_View__c',Filter_Field_API_Name__c='',Filter_Field_Value__c='',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='AirCode',Position__c=19,Size__c=3,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Legal_Name_1__c',API_Object_Name__c='GDP_Products_Account_View__c',Filter_Field_API_Name__c='',Filter_Field_Value__c='',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Legal1',Position__c=22,Size__c=32,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Legal_Name_2__c',API_Object_Name__c='GDP_Products_Account_View__c',Filter_Field_API_Name__c='',Filter_Field_Value__c='',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Legal2',Position__c=54,Size__c=32,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Legal_Name_3__c',API_Object_Name__c='GDP_Products_Account_View__c',Filter_Field_API_Name__c='',Filter_Field_Value__c='',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Legal3',Position__c=86,Size__c=32,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Trading_Name_1__c',API_Object_Name__c='GDP_Products_Account_View__c',Filter_Field_API_Name__c='',Filter_Field_Value__c='',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='DBA1',Position__c=118,Size__c=32,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Trading_Name_2__c',API_Object_Name__c='GDP_Products_Account_View__c',Filter_Field_API_Name__c='',Filter_Field_Value__c='',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='DBA2',Position__c=150,Size__c=32,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Address_Line_1__c',API_Object_Name__c='GDP_Address__c',Filter_Field_API_Name__c='Address_Type__c',Filter_Field_Value__c='Location',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='LAdd1',Position__c=182,Size__c=32,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=TRUE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Address_Line_2__c',API_Object_Name__c='GDP_Address__c',Filter_Field_API_Name__c='Address_Type__c',Filter_Field_Value__c='Location',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='LAdd2',Position__c=214,Size__c=32,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=TRUE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Address_Line_3__c',API_Object_Name__c='GDP_Address__c',Filter_Field_API_Name__c='Address_Type__c',Filter_Field_Value__c='Location',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='LAdd3',Position__c=246,Size__c=32,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=TRUE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Address_City__c',API_Object_Name__c='GDP_Address__c',Filter_Field_API_Name__c='Address_Type__c',Filter_Field_Value__c='Location',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='LCity',Position__c=278,Size__c=30,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Address_State_Name__c',API_Object_Name__c='GDP_Address__c',Filter_Field_API_Name__c='Address_Type__c',Filter_Field_Value__c='Location',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='LReg',Position__c=308,Size__c=30,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Address_State_Code__c',API_Object_Name__c='GDP_Address__c',Filter_Field_API_Name__c='Address_Type__c',Filter_Field_Value__c='Location',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='LRegISO',Position__c=338,Size__c=6,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Address_Country_Name__c',API_Object_Name__c='GDP_Address__c',Filter_Field_API_Name__c='Address_Type__c',Filter_Field_Value__c='Location',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='LCtry',Position__c=344,Size__c=30,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Address_ISO_Country_Code__c',API_Object_Name__c='GDP_Address__c',Filter_Field_API_Name__c='Address_Type__c',Filter_Field_Value__c='Location',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='LCtryISO',Position__c=374,Size__c=2,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='IATA_ISO_Country__r.Name',API_Object_Name__c='GDP_Address__c',Filter_Field_API_Name__c='Address_Type__c',Filter_Field_Value__c='Location',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='LCtryCode',Position__c=376,Size__c=2,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Address_Postal_Code__c',API_Object_Name__c='GDP_Address__c',Filter_Field_API_Name__c='Address_Type__c',Filter_Field_Value__c='Location',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='LPostal',Position__c=378,Size__c=10,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Address_Line_1__c',API_Object_Name__c='GDP_Address__c',Filter_Field_API_Name__c='Address_Type__c',Filter_Field_Value__c='Mailing',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='MAdd1',Position__c=388,Size__c=32,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=TRUE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Address_Line_2__c',API_Object_Name__c='GDP_Address__c',Filter_Field_API_Name__c='Address_Type__c',Filter_Field_Value__c='Mailing',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='MAdd2',Position__c=420,Size__c=32,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=TRUE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Address_City__c',API_Object_Name__c='GDP_Address__c',Filter_Field_API_Name__c='Address_Type__c',Filter_Field_Value__c='Mailing',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='MCity',Position__c=452,Size__c=30,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Address_State_Name__c',API_Object_Name__c='GDP_Address__c',Filter_Field_API_Name__c='Address_Type__c',Filter_Field_Value__c='Mailing',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='MReg',Position__c=482,Size__c=30,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Address_State_Code__c',API_Object_Name__c='GDP_Address__c',Filter_Field_API_Name__c='Address_Type__c',Filter_Field_Value__c='Mailing',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='MRegISO',Position__c=512,Size__c=6,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Address_Country_Name__c',API_Object_Name__c='GDP_Address__c',Filter_Field_API_Name__c='Address_Type__c',Filter_Field_Value__c='Mailing',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='MCtry',Position__c=518,Size__c=30,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Address_ISO_Country_Code__c',API_Object_Name__c='GDP_Address__c',Filter_Field_API_Name__c='Address_Type__c',Filter_Field_Value__c='Mailing',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='MCtryISO',Position__c=548,Size__c=2,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='IATA_ISO_Country__r.Name',API_Object_Name__c='GDP_Address__c',Filter_Field_API_Name__c='Address_Type__c',Filter_Field_Value__c='Mailing',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='MCtryCode',Position__c=550,Size__c=2,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Address_Postal_Code__c',API_Object_Name__c='GDP_Address__c',Filter_Field_API_Name__c='Address_Type__c',Filter_Field_Value__c='Mailing',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='MPostal',Position__c=552,Size__c=10,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='ISD_Code__c',API_Object_Name__c='GDP_Phone__c',Filter_Field_API_Name__c='Phone_Type__c',Filter_Field_Value__c='Phone 1',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='PhInt',Position__c=562,Size__c=6,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='STD_Code__c',API_Object_Name__c='GDP_Phone__c',Filter_Field_API_Name__c='Phone_Type__c',Filter_Field_Value__c='Phone 1',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='PhSTD',Position__c=568,Size__c=6,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Number__c',API_Object_Name__c='GDP_Phone__c',Filter_Field_API_Name__c='Phone_Type__c',Filter_Field_Value__c='Phone 1',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Phone',Position__c=574,Size__c=12,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='ISD_Code__c',API_Object_Name__c='GDP_Phone__c',Filter_Field_API_Name__c='Phone_Type__c',Filter_Field_Value__c='Phone 2',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ph2Int',Position__c=586,Size__c=6,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='STD_Code__c',API_Object_Name__c='GDP_Phone__c',Filter_Field_API_Name__c='Phone_Type__c',Filter_Field_Value__c='Phone 2',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ph2STD',Position__c=592,Size__c=6,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Number__c',API_Object_Name__c='GDP_Phone__c',Filter_Field_API_Name__c='Phone_Type__c',Filter_Field_Value__c='Phone 2',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Phone2',Position__c=598,Size__c=12,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='ISD_Code__c',API_Object_Name__c='GDP_Phone__c',Filter_Field_API_Name__c='Phone_Type__c',Filter_Field_Value__c='Fax',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='FXInt',Position__c=610,Size__c=6,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='STD_Code__c',API_Object_Name__c='GDP_Phone__c',Filter_Field_API_Name__c='Phone_Type__c',Filter_Field_Value__c='Fax',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='FXSTD',Position__c=616,Size__c=6,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Number__c',API_Object_Name__c='GDP_Phone__c',Filter_Field_API_Name__c='Phone_Type__c',Filter_Field_Value__c='Fax',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Fax',Position__c=622,Size__c=12,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='ISD_Code__c',API_Object_Name__c='GDP_Phone__c',Filter_Field_API_Name__c='Phone_Type__c',Filter_Field_Value__c='Toll Free',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='TollInt',Position__c=634,Size__c=6,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='STD_Code__c',API_Object_Name__c='GDP_Phone__c',Filter_Field_API_Name__c='Phone_Type__c',Filter_Field_Value__c='Toll Free',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='TollSTD',Position__c=640,Size__c=6,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Number__c',API_Object_Name__c='GDP_Phone__c',Filter_Field_API_Name__c='Phone_Type__c',Filter_Field_Value__c='Toll Free',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Toll',Position__c=646,Size__c=12,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Email_Address__c',API_Object_Name__c='GDP_Products_Account_View__c',Filter_Field_API_Name__c='',Filter_Field_Value__c='',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='LEmail',Position__c=658,Size__c=64,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Website__c',API_Object_Name__c='GDP_Products_Account_View__c',Filter_Field_API_Name__c='',Filter_Field_Value__c='',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='LWeb',Position__c=722,Size__c=96,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='TTY__c',API_Object_Name__c='GDP_Products_Account_View__c',Filter_Field_API_Name__c='',Filter_Field_Value__c='',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='TTY',Position__c=818,Size__c=10,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='XArea__c',API_Object_Name__c='GDP_Products_Account_View__c',Filter_Field_API_Name__c='',Filter_Field_Value__c='',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='XArea',Position__c=828,Size__c=1,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='XIATACode__c',API_Object_Name__c='GDP_Products_Account_View__c',Filter_Field_API_Name__c='',Filter_Field_Value__c='',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='XIATACode',Position__c=829,Size__c=7,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='XIATAChk__c',API_Object_Name__c='GDP_Products_Account_View__c',Filter_Field_API_Name__c='',Filter_Field_Value__c='',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='XIATAChk',Position__c=836,Size__c=1,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Category_Code__c',API_Object_Name__c='Account_Category__c',Filter_Field_API_Name__c='Category_ID__c',Filter_Field_Value__c='1',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Cat1',Position__c=837,Size__c=2,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Category_Code__c',API_Object_Name__c='Account_Category__c',Filter_Field_API_Name__c='Category_ID__c',Filter_Field_Value__c='2',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Cat2',Position__c=839,Size__c=2,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Category_Code__c',API_Object_Name__c='Account_Category__c',Filter_Field_API_Name__c='Category_ID__c',Filter_Field_Value__c='3',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Cat3',Position__c=841,Size__c=2,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Passenger_And_Cargo__c',API_Object_Name__c='GDP_Products_Account_View__c',Filter_Field_API_Name__c='',Filter_Field_Value__c='',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='PASCGO',Position__c=843,Size__c=1,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Incorporation_Type__r.Code__c',API_Object_Name__c='GDP_Products_Account_View__c',Filter_Field_API_Name__c='',Filter_Field_Value__c='',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='COType',Position__c=844,Size__c=1,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='GDP_Opt_In__c',API_Object_Name__c='GDP_Products_Account_View__c',Filter_Field_API_Name__c='',Filter_Field_Value__c='',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Solicit',Position__c=845,Size__c=1,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='Boolean',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Name',API_Object_Name__c='Agency_Owner__c',Filter_Field_API_Name__c='Owner_ID__c',Filter_Field_Value__c='1',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Owner1',Position__c=846,Size__c=40,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Percent__c',API_Object_Name__c='Agency_Owner__c',Filter_Field_API_Name__c='Owner_ID__c',Filter_Field_Value__c='1',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Percent1',Position__c=886,Size__c=6,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Name',API_Object_Name__c='Agency_Owner__c',Filter_Field_API_Name__c='Owner_ID__c',Filter_Field_Value__c='2',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Owner2',Position__c=892,Size__c=40,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Percent__c',API_Object_Name__c='Agency_Owner__c',Filter_Field_API_Name__c='Owner_ID__c',Filter_Field_Value__c='2',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Percent2',Position__c=932,Size__c=6,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Name',API_Object_Name__c='Agency_Owner__c',Filter_Field_API_Name__c='Owner_ID__c',Filter_Field_Value__c='3',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Owner3',Position__c=938,Size__c=40,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Percent__c',API_Object_Name__c='Agency_Owner__c',Filter_Field_API_Name__c='Owner_ID__c',Filter_Field_Value__c='3',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Percent3',Position__c=978,Size__c=6,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Name',API_Object_Name__c='Agency_Owner__c',Filter_Field_API_Name__c='Owner_ID__c',Filter_Field_Value__c='4',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Owner4',Position__c=984,Size__c=40,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Percent__c',API_Object_Name__c='Agency_Owner__c',Filter_Field_API_Name__c='Owner_ID__c',Filter_Field_Value__c='4',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Percent4',Position__c=1024,Size__c=6,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Name',API_Object_Name__c='Agency_Owner__c',Filter_Field_API_Name__c='Owner_ID__c',Filter_Field_Value__c='5',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Owner5',Position__c=1030,Size__c=40,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Percent__c',API_Object_Name__c='Agency_Owner__c',Filter_Field_API_Name__c='Owner_ID__c',Filter_Field_Value__c='5',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Percent5',Position__c=1070,Size__c=6,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Name',API_Object_Name__c='Agency_Owner__c',Filter_Field_API_Name__c='Owner_ID__c',Filter_Field_Value__c='6',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Owner6',Position__c=1076,Size__c=40,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Percent__c',API_Object_Name__c='Agency_Owner__c',Filter_Field_API_Name__c='Owner_ID__c',Filter_Field_Value__c='6',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Percent6',Position__c=1116,Size__c=6,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Name',API_Object_Name__c='Agency_Owner__c',Filter_Field_API_Name__c='Owner_ID__c',Filter_Field_Value__c='7',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Owner7',Position__c=1122,Size__c=40,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Percent__c',API_Object_Name__c='Agency_Owner__c',Filter_Field_API_Name__c='Owner_ID__c',Filter_Field_Value__c='7',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Percent7',Position__c=1162,Size__c=6,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Name',API_Object_Name__c='Agency_Owner__c',Filter_Field_API_Name__c='Owner_ID__c',Filter_Field_Value__c='8',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Owner8',Position__c=1168,Size__c=40,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Percent__c',API_Object_Name__c='Agency_Owner__c',Filter_Field_API_Name__c='Owner_ID__c',Filter_Field_Value__c='8',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Percent8',Position__c=1208,Size__c=6,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Name',API_Object_Name__c='Agency_Owner__c',Filter_Field_API_Name__c='Owner_ID__c',Filter_Field_Value__c='9',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Owner9',Position__c=1214,Size__c=40,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Percent__c',API_Object_Name__c='Agency_Owner__c',Filter_Field_API_Name__c='Owner_ID__c',Filter_Field_Value__c='9',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Percent9',Position__c=1254,Size__c=6,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Name',API_Object_Name__c='Agency_Owner__c',Filter_Field_API_Name__c='Owner_ID__c',Filter_Field_Value__c='10',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Owner10',Position__c=1260,Size__c=40,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Percent__c',API_Object_Name__c='Agency_Owner__c',Filter_Field_API_Name__c='Owner_ID__c',Filter_Field_Value__c='10',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Percent10',Position__c=1300,Size__c=6,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Ticketing_Agent_Last_Name__c',API_Object_Name__c='GDP_Products_Account_View__c',Filter_Field_API_Name__c='',Filter_Field_Value__c='',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='QTALName',Position__c=1306,Size__c=20,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Ticketing_Agent_First_Name__c',API_Object_Name__c='GDP_Products_Account_View__c',Filter_Field_API_Name__c='',Filter_Field_Value__c='',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='QTAFName',Position__c=1326,Size__c=20,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Manager_Last_Name__c',API_Object_Name__c='GDP_Products_Account_View__c',Filter_Field_API_Name__c='',Filter_Field_Value__c='',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='QMPLName',Position__c=1346,Size__c=20,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Manager_First_Name__c',API_Object_Name__c='GDP_Products_Account_View__c',Filter_Field_API_Name__c='',Filter_Field_Value__c='',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='QMPFName',Position__c=1366,Size__c=20,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Tax_ID_1__c',API_Object_Name__c='GDP_Products_Account_View__c',Filter_Field_API_Name__c='',Filter_Field_Value__c='',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='TaxRef1',Position__c=1386,Size__c=20,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Tax_ID_2__c',API_Object_Name__c='GDP_Products_Account_View__c',Filter_Field_API_Name__c='',Filter_Field_Value__c='',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='TaxRef2',Position__c=1406,Size__c=20,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Computer_Reservation_System__c',API_Object_Name__c='GDS__c',Filter_Field_API_Name__c='GDS_ID__c',Filter_Field_Value__c='1',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='CRS1',Position__c=1426,Size__c=4,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Computer_Reservation_System__c',API_Object_Name__c='GDS__c',Filter_Field_API_Name__c='GDS_ID__c',Filter_Field_Value__c='2',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='CRS2',Position__c=1430,Size__c=4,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Computer_Reservation_System__c',API_Object_Name__c='GDS__c',Filter_Field_API_Name__c='GDS_ID__c',Filter_Field_Value__c='3',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='CRS3',Position__c=1434,Size__c=4,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Computer_Reservation_System__c',API_Object_Name__c='GDS__c',Filter_Field_API_Name__c='GDS_ID__c',Filter_Field_Value__c='4',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='CRS4',Position__c=1438,Size__c=4,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Last_change_date__c',API_Object_Name__c='Accreditation__c',Filter_Field_API_Name__c='Accreditation_ID__c',Filter_Field_Value__c='1',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Org1LDate',Position__c=1442,Size__c=8,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='Date YYYYMMDD',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Last_re_inspection_date__c',API_Object_Name__c='Accreditation__c',Filter_Field_API_Name__c='Accreditation_ID__c',Filter_Field_Value__c='1',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Org1IDate',Position__c=1450,Size__c=8,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='Date YYYYMMDD',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Original_approval_date__c',API_Object_Name__c='Accreditation__c',Filter_Field_API_Name__c='Accreditation_ID__c',Filter_Field_Value__c='1',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Org1ADate',Position__c=1458,Size__c=8,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='Date YYYYMMDD',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Endorsed_Accredited_By_Formula__c',API_Object_Name__c='Accreditation__c',Filter_Field_API_Name__c='Accreditation_ID__c',Filter_Field_Value__c='1',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Org1',Position__c=1466,Size__c=6,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Agency_Status_Code__c',API_Object_Name__c='GDP_Products_Account_View__c',Filter_Field_API_Name__c='',Filter_Field_Value__c='',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Org1Status',Position__c=1472,Size__c=2,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Date__c',API_Object_Name__c='Accreditation__c',Filter_Field_API_Name__c='Accreditation_ID__c',Filter_Field_Value__c='1',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Org1Date',Position__c=1474,Size__c=8,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='Date YYYYMMDD',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Class__r.Code__c',API_Object_Name__c='Accreditation__c',Filter_Field_API_Name__c='Accreditation_ID__c',Filter_Field_Value__c='1',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Org1Class',Position__c=1482,Size__c=1,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Last_change_date__c',API_Object_Name__c='Accreditation__c',Filter_Field_API_Name__c='Accreditation_ID__c',Filter_Field_Value__c='2',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Org2LDate',Position__c=1483,Size__c=8,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='Date YYYYMMDD',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Last_re_inspection_date__c',API_Object_Name__c='Accreditation__c',Filter_Field_API_Name__c='Accreditation_ID__c',Filter_Field_Value__c='2',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Org2IDate',Position__c=1491,Size__c=8,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='Date YYYYMMDD',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Original_approval_date__c',API_Object_Name__c='Accreditation__c',Filter_Field_API_Name__c='Accreditation_ID__c',Filter_Field_Value__c='2',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Org2ADate',Position__c=1499,Size__c=8,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='Date YYYYMMDD',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Endorsed_Accredited_By_Formula__c',API_Object_Name__c='Accreditation__c',Filter_Field_API_Name__c='Accreditation_ID__c',Filter_Field_Value__c='2',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Org2',Position__c=1507,Size__c=6,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Status__r.Code__c',API_Object_Name__c='Accreditation__c',Filter_Field_API_Name__c='Accreditation_ID__c',Filter_Field_Value__c='2',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Org2Status',Position__c=1513,Size__c=2,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Date__c',API_Object_Name__c='Accreditation__c',Filter_Field_API_Name__c='Accreditation_ID__c',Filter_Field_Value__c='2',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Org2Date',Position__c=1515,Size__c=8,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='Date YYYYMMDD',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Class__r.Code__c',API_Object_Name__c='Accreditation__c',Filter_Field_API_Name__c='Accreditation_ID__c',Filter_Field_Value__c='2',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Org2Class',Position__c=1523,Size__c=1,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Last_change_date__c',API_Object_Name__c='Accreditation__c',Filter_Field_API_Name__c='Accreditation_ID__c',Filter_Field_Value__c='3',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Org3LDate',Position__c=1524,Size__c=8,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='Date YYYYMMDD',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Last_re_inspection_date__c',API_Object_Name__c='Accreditation__c',Filter_Field_API_Name__c='Accreditation_ID__c',Filter_Field_Value__c='3',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Org3IDate',Position__c=1532,Size__c=8,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='Date YYYYMMDD',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Original_approval_date__c',API_Object_Name__c='Accreditation__c',Filter_Field_API_Name__c='Accreditation_ID__c',Filter_Field_Value__c='3',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Org3ADate',Position__c=1540,Size__c=8,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='Date YYYYMMDD',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Endorsed_Accredited_By_Formula__c',API_Object_Name__c='Accreditation__c',Filter_Field_API_Name__c='Accreditation_ID__c',Filter_Field_Value__c='3',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Org3',Position__c=1548,Size__c=6,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Status__r.Code__c',API_Object_Name__c='Accreditation__c',Filter_Field_API_Name__c='Accreditation_ID__c',Filter_Field_Value__c='3',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Org3Status',Position__c=1554,Size__c=2,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Date__c',API_Object_Name__c='Accreditation__c',Filter_Field_API_Name__c='Accreditation_ID__c',Filter_Field_Value__c='3',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Org3Date',Position__c=1556,Size__c=8,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='Date YYYYMMDD',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Class__r.Code__c',API_Object_Name__c='Accreditation__c',Filter_Field_API_Name__c='Accreditation_ID__c',Filter_Field_Value__c='3',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Org3Class',Position__c=1564,Size__c=1,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Last_change_date__c',API_Object_Name__c='Accreditation__c',Filter_Field_API_Name__c='Accreditation_ID__c',Filter_Field_Value__c='4',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Org4LDate',Position__c=1565,Size__c=8,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='Date YYYYMMDD',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Last_re_inspection_date__c',API_Object_Name__c='Accreditation__c',Filter_Field_API_Name__c='Accreditation_ID__c',Filter_Field_Value__c='4',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Org4IDate',Position__c=1573,Size__c=8,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='Date YYYYMMDD',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Original_approval_date__c',API_Object_Name__c='Accreditation__c',Filter_Field_API_Name__c='Accreditation_ID__c',Filter_Field_Value__c='4',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Org4ADate',Position__c=1581,Size__c=8,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='Date YYYYMMDD',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Endorsed_Accredited_By_Formula__c',API_Object_Name__c='Accreditation__c',Filter_Field_API_Name__c='Accreditation_ID__c',Filter_Field_Value__c='4',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Org4',Position__c=1589,Size__c=6,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Status__r.Code__c',API_Object_Name__c='Accreditation__c',Filter_Field_API_Name__c='Accreditation_ID__c',Filter_Field_Value__c='4',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Org4Status',Position__c=1595,Size__c=2,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Date__c',API_Object_Name__c='Accreditation__c',Filter_Field_API_Name__c='Accreditation_ID__c',Filter_Field_Value__c='4',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Org4Date',Position__c=1597,Size__c=8,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='Date YYYYMMDD',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Class__r.Code__c',API_Object_Name__c='Accreditation__c',Filter_Field_API_Name__c='Accreditation_ID__c',Filter_Field_Value__c='4',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Org4Class',Position__c=1605,Size__c=1,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='BSP_CASS_Code__c',API_Object_Name__c='GDP_Products_Account_View__c',Filter_Field_API_Name__c='',Filter_Field_Value__c='',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='BSPCode',Position__c=1606,Size__c=4,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='AgRef__c',API_Object_Name__c='GDP_Products_Account_View__c',Filter_Field_API_Name__c='',Filter_Field_Value__c='',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='AgRef',Position__c=1610,Size__c=10,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='AgXRef__c',API_Object_Name__c='GDP_Products_Account_View__c',Filter_Field_API_Name__c='',Filter_Field_Value__c='',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='AgXRef',Position__c=1620,Size__c=10,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='AirportCode__c',API_Object_Name__c='Adjacent_Airport__c',Filter_Field_API_Name__c='Airport_ID__c',Filter_Field_Value__c='1',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Air1',Position__c=1630,Size__c=3,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='AirportCode__c',API_Object_Name__c='Adjacent_Airport__c',Filter_Field_API_Name__c='Airport_ID__c',Filter_Field_Value__c='2',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Air2',Position__c=1633,Size__c=3,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='AirportCode__c',API_Object_Name__c='Adjacent_Airport__c',Filter_Field_API_Name__c='Airport_ID__c',Filter_Field_Value__c='3',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Air3',Position__c=1636,Size__c=3,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='AirportCode__c',API_Object_Name__c='Adjacent_Airport__c',Filter_Field_API_Name__c='Airport_ID__c',Filter_Field_Value__c='4',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Air4',Position__c=1639,Size__c=3,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='AirportCode__c',API_Object_Name__c='Adjacent_Airport__c',Filter_Field_API_Name__c='Airport_ID__c',Filter_Field_Value__c='5',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Air5',Position__c=1642,Size__c=3,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='AirportCode__c',API_Object_Name__c='Adjacent_Airport__c',Filter_Field_API_Name__c='Airport_ID__c',Filter_Field_Value__c='6',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Air6',Position__c=1645,Size__c=3,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='AirportCode__c',API_Object_Name__c='Adjacent_Airport__c',Filter_Field_API_Name__c='Airport_ID__c',Filter_Field_Value__c='7',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Air7',Position__c=1648,Size__c=3,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='AirportCode__c',API_Object_Name__c='Adjacent_Airport__c',Filter_Field_API_Name__c='Airport_ID__c',Filter_Field_Value__c='8',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Air8',Position__c=1651,Size__c=3,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='AirportCode__c',API_Object_Name__c='Adjacent_Airport__c',Filter_Field_API_Name__c='Airport_ID__c',Filter_Field_Value__c='9',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Air9',Position__c=1654,Size__c=3,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='AirportCode__c',API_Object_Name__c='Adjacent_Airport__c',Filter_Field_API_Name__c='Airport_ID__c',Filter_Field_Value__c='10',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Air10',Position__c=1657,Size__c=3,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Assoc_Affiliation_Code__c',API_Object_Name__c='Assoc_Affiliation_Membership__c',Filter_Field_API_Name__c='Assoc_Affiliation_ID__c',Filter_Field_Value__c='1',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Affil1',Position__c=1660,Size__c=4,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Assoc_Affiliation_Code__c',API_Object_Name__c='Assoc_Affiliation_Membership__c',Filter_Field_API_Name__c='Assoc_Affiliation_ID__c',Filter_Field_Value__c='2',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Affil2',Position__c=1664,Size__c=4,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Assoc_Affiliation_Code__c',API_Object_Name__c='Assoc_Affiliation_Membership__c',Filter_Field_API_Name__c='Assoc_Affiliation_ID__c',Filter_Field_Value__c='3',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Affil3',Position__c=1668,Size__c=4,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='License_Number__c',API_Object_Name__c='GDP_Products_Account_View__c',Filter_Field_API_Name__c='',Filter_Field_Value__c='',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='License',Position__c=1672,Size__c=20,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Preferred_Language__c',API_Object_Name__c='GDP_Products_Account_View__c',Filter_Field_API_Name__c='',Filter_Field_Value__c='',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Lang',Position__c=1692,Size__c=4,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Market_Focus_Leisure__c',API_Object_Name__c='GDP_Agency_Profile_Specialization__c',Filter_Field_API_Name__c='',Filter_Field_Value__c='',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='FocusL',Position__c=1696,Size__c=2,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Market_Focus_Corporate__c',API_Object_Name__c='GDP_Agency_Profile_Specialization__c',Filter_Field_API_Name__c='',Filter_Field_Value__c='',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='FocusC',Position__c=1698,Size__c=2,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Sales_Volume__c',API_Object_Name__c='GDP_Agency_Profile_Specialization__c',Filter_Field_API_Name__c='',Filter_Field_Value__c='',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Volume',Position__c=1700,Size__c=2,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Sales_Air__c',API_Object_Name__c='GDP_Agency_Profile_Specialization__c',Filter_Field_API_Name__c='',Filter_Field_Value__c='',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='ModeAir',Position__c=1702,Size__c=2,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Sales_Sea__c',API_Object_Name__c='GDP_Agency_Profile_Specialization__c',Filter_Field_API_Name__c='',Filter_Field_Value__c='',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='ModeSea',Position__c=1704,Size__c=2,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Sales_Land__c',API_Object_Name__c='GDP_Agency_Profile_Specialization__c',Filter_Field_API_Name__c='',Filter_Field_Value__c='',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='ModeLand',Position__c=1706,Size__c=2,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Main_Market_Specialization__c',API_Object_Name__c='GDP_Agency_Profile_Specialization__c',Filter_Field_API_Name__c='',Filter_Field_Value__c='',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Mark1',Position__c=1708,Size__c=2,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Secondary_Market_Specialization__c',API_Object_Name__c='GDP_Agency_Profile_Specialization__c',Filter_Field_API_Name__c='',Filter_Field_Value__c='',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Mark2',Position__c=1710,Size__c=2,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Tertiary_Market_Specialization__c',API_Object_Name__c='GDP_Agency_Profile_Specialization__c',Filter_Field_API_Name__c='',Filter_Field_Value__c='',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Mark3',Position__c=1712,Size__c=2,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Main_Destination_Specialization__c',API_Object_Name__c='GDP_Agency_Profile_Specialization__c',Filter_Field_API_Name__c='',Filter_Field_Value__c='',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Dest1',Position__c=1714,Size__c=2,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Secondary_Destination_Specialization__c',API_Object_Name__c='GDP_Agency_Profile_Specialization__c',Filter_Field_API_Name__c='',Filter_Field_Value__c='',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Dest2',Position__c=1716,Size__c=2,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Tertiary_Destination_Specialization__c',API_Object_Name__c='GDP_Agency_Profile_Specialization__c',Filter_Field_API_Name__c='',Filter_Field_Value__c='',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Dest3',Position__c=1718,Size__c=2,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Main_Activity__c',API_Object_Name__c='GDP_Agency_Profile_Specialization__c',Filter_Field_API_Name__c='',Filter_Field_Value__c='',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Act',Position__c=1720,Size__c=2,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Sales_Accomodation__c',API_Object_Name__c='GDP_Agency_Profile_Specialization__c',Filter_Field_API_Name__c='',Filter_Field_Value__c='',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='ModeAcc',Position__c=1722,Size__c=2,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Sales_Tour__c',API_Object_Name__c='GDP_Agency_Profile_Specialization__c',Filter_Field_API_Name__c='',Filter_Field_Value__c='',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='ModeTour',Position__c=1724,Size__c=2,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Eth2__c',API_Object_Name__c='GDP_Products_Account_View__c',Filter_Field_API_Name__c='',Filter_Field_Value__c='',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Eth2',Position__c=1726,Size__c=2,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Eth3__c',API_Object_Name__c='GDP_Products_Account_View__c',Filter_Field_API_Name__c='',Filter_Field_Value__c='',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Eth3',Position__c=1728,Size__c=2,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='XIATACass__c',API_Object_Name__c='GDP_Products_Account_View__c',Filter_Field_API_Name__c='',Filter_Field_Value__c='',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='XIATACass',Position__c=1730,Size__c=4,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Address_Line_1__c',API_Object_Name__c='GDP_Address__c',Filter_Field_API_Name__c='Address_Type__c',Filter_Field_Value__c='Registered',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='RAdd1',Position__c=1734,Size__c=32,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=TRUE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Address_Line_2__c',API_Object_Name__c='GDP_Address__c',Filter_Field_API_Name__c='Address_Type__c',Filter_Field_Value__c='Registered',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='RAdd2',Position__c=1766,Size__c=32,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=TRUE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Address_City__c',API_Object_Name__c='GDP_Address__c',Filter_Field_API_Name__c='Address_Type__c',Filter_Field_Value__c='Registered',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='RCity',Position__c=1798,Size__c=30,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Address_State_Name__c',API_Object_Name__c='GDP_Address__c',Filter_Field_API_Name__c='Address_Type__c',Filter_Field_Value__c='Registered',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='RReg',Position__c=1828,Size__c=30,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Address_State_Code__c',API_Object_Name__c='GDP_Address__c',Filter_Field_API_Name__c='Address_Type__c',Filter_Field_Value__c='Registered',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='RRegISO',Position__c=1858,Size__c=6,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Address_Country_Name__c',API_Object_Name__c='GDP_Address__c',Filter_Field_API_Name__c='Address_Type__c',Filter_Field_Value__c='Registered',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='RCtry',Position__c=1864,Size__c=30,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Address_ISO_Country_Code__c',API_Object_Name__c='GDP_Address__c',Filter_Field_API_Name__c='Address_Type__c',Filter_Field_Value__c='Registered',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='RCtryISO',Position__c=1894,Size__c=2,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='IATA_ISO_Country__c',API_Object_Name__c='GDP_Address__c',Filter_Field_API_Name__c='Address_Type__c',Filter_Field_Value__c='Registered',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='RCtryCode',Position__c=1896,Size__c=2,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Address_Postal_Code__c',API_Object_Name__c='GDP_Address__c',Filter_Field_API_Name__c='Address_Type__c',Filter_Field_Value__c='Registered',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='RPostal',Position__c=1898,Size__c=10,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Reserve',API_Object_Name__c='Reserve',Filter_Field_API_Name__c='',Filter_Field_Value__c='',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Reserve',Position__c=1908,Size__c=141,Target__c='Agency',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Function_RecId',API_Object_Name__c='',Filter_Field_API_Name__c='',Filter_Field_Value__c='',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='RecID',Position__c=1,Size__c=1,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Function_FileId',API_Object_Name__c='',Filter_Field_API_Name__c='',Filter_Field_Value__c='',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='FileID',Position__c=2,Size__c=2,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Area__c',API_Object_Name__c='GDP_Products_Account_View__c',Filter_Field_API_Name__c='',Filter_Field_Value__c='',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Area',Position__c=4,Size__c=1,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='IATA_Code__c',API_Object_Name__c='GDP_Products_Account_View__c',Filter_Field_API_Name__c='',Filter_Field_Value__c='',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='IATACode',Position__c=5,Size__c=7,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Check_Digit__c',API_Object_Name__c='GDP_Products_Account_View__c',Filter_Field_API_Name__c='',Filter_Field_Value__c='',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='IATAChk',Position__c=12,Size__c=1,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Address_ISO_Country_Code__c',API_Object_Name__c='GDP_Address__c',Filter_Field_API_Name__c='Address_Type__c',Filter_Field_Value__c='Location',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='LCtryISO',Position__c=13,Size__c=2,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='IATA_ISO_Country__r.Name',API_Object_Name__c='GDP_Address__c',Filter_Field_API_Name__c='Address_Type__c',Filter_Field_Value__c='Location',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='LCtryCode',Position__c=15,Size__c=2,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Address_Country_Name__c',API_Object_Name__c='GDP_Address__c',Filter_Field_API_Name__c='Address_Type__c',Filter_Field_Value__c='Location',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='LCtry',Position__c=17,Size__c=30,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Airline_Code__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='1',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='AirCode',Position__c=47,Size__c=3,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Airline_Name__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='1',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='AirName',Position__c=50,Size__c=60,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Appointment_Type__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='1',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='AppType',Position__c=110,Size__c=1,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Appointment_Date__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='1',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='APPDate',Position__c=111,Size__c=8,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='Date YYYYMMDD',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_ISO_Country__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='1',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter1CtryISO',Position__c=119,Size__c=2,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_IATA_Numeric_Country_Code__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='1',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter1CtryCode',Position__c=121,Size__c=2,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Location_Country_Name__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='1',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter1Ctry',Position__c=123,Size__c=30,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_State_Abbreviation__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='1',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter1St',Position__c=153,Size__c=6,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_Description__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='1',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter1Desc',Position__c=159,Size__c=40,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_ISO_Country__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='2',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter2CtryISO',Position__c=199,Size__c=2,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_IATA_Numeric_Country_Code__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='2',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter2CtryCode',Position__c=201,Size__c=2,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Location_Country_Name__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='2',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter2Ctry',Position__c=203,Size__c=30,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_State_Abbreviation__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='2',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter2St',Position__c=233,Size__c=6,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_Description__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='2',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter2Desc',Position__c=239,Size__c=40,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_ISO_Country__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='3',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter3CtryISO',Position__c=279,Size__c=2,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_IATA_Numeric_Country_Code__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='3',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter3CtryCode',Position__c=281,Size__c=2,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Location_Country_Name__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='3',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter3Ctry',Position__c=283,Size__c=30,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_State_Abbreviation__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='3',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter3St',Position__c=313,Size__c=6,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_Description__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='3',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter3Desc',Position__c=319,Size__c=40,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_ISO_Country__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='4',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter4CtryISO',Position__c=359,Size__c=2,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_IATA_Numeric_Country_Code__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='4',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter4CtryCode',Position__c=361,Size__c=2,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Location_Country_Name__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='4',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter4Ctry',Position__c=363,Size__c=30,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_State_Abbreviation__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='4',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter4St',Position__c=393,Size__c=6,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_Description__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='4',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter4Desc',Position__c=399,Size__c=40,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_ISO_Country__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='5',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter5CtryISO',Position__c=439,Size__c=2,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_IATA_Numeric_Country_Code__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='5',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter5CtryCode',Position__c=441,Size__c=2,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Location_Country_Name__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='5',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter5Ctry',Position__c=443,Size__c=30,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_State_Abbreviation__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='5',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter5St',Position__c=473,Size__c=6,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_Description__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='5',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter5Desc',Position__c=479,Size__c=40,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_ISO_Country__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='6',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter6CtryISO',Position__c=519,Size__c=2,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_IATA_Numeric_Country_Code__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='6',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter6CtryCode',Position__c=521,Size__c=2,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Location_Country_Name__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='6',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter6Ctry',Position__c=523,Size__c=30,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_State_Abbreviation__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='6',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter6St',Position__c=553,Size__c=6,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_Description__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='6',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter6Desc',Position__c=559,Size__c=40,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_ISO_Country__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='7',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter7CtryISO',Position__c=599,Size__c=2,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_IATA_Numeric_Country_Code__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='7',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter7CtryCode',Position__c=601,Size__c=2,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Location_Country_Name__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='7',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter7Ctry',Position__c=603,Size__c=30,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_State_Abbreviation__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='7',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter7St',Position__c=633,Size__c=6,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_Description__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='7',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter7Desc',Position__c=639,Size__c=40,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_ISO_Country__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='8',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter8CtryISO',Position__c=679,Size__c=2,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_IATA_Numeric_Country_Code__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='8',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter8CtryCode',Position__c=681,Size__c=2,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Location_Country_Name__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='8',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter8Ctry',Position__c=683,Size__c=30,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_State_Abbreviation__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='8',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter8St',Position__c=713,Size__c=6,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_Description__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='8',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter8Desc',Position__c=719,Size__c=40,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_ISO_Country__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='9',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter9CtryISO',Position__c=759,Size__c=2,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_IATA_Numeric_Country_Code__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='9',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter9CtryCode',Position__c=761,Size__c=2,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Location_Country_Name__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='9',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter9Ctry',Position__c=763,Size__c=30,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_State_Abbreviation__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='9',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter9St',Position__c=793,Size__c=6,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_Description__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='9',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter9Desc',Position__c=799,Size__c=40,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_ISO_Country__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='10',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter10CtryISO',Position__c=839,Size__c=2,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_IATA_Numeric_Country_Code__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='10',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter10CtryCode',Position__c=841,Size__c=2,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Location_Country_Name__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='10',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter10Ctry',Position__c=843,Size__c=30,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_State_Abbreviation__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='10',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter10St',Position__c=873,Size__c=6,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_Description__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='10',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter10Desc',Position__c=879,Size__c=40,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_ISO_Country__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='11',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter11CtryISO',Position__c=919,Size__c=2,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_IATA_Numeric_Country_Code__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='11',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter11CtryCode',Position__c=921,Size__c=2,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Location_Country_Name__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='11',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter11Ctry',Position__c=923,Size__c=30,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_State_Abbreviation__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='11',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter11St',Position__c=953,Size__c=6,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_Description__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='11',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter11Desc',Position__c=959,Size__c=40,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_ISO_Country__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='12',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter12CtryISO',Position__c=999,Size__c=2,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_IATA_Numeric_Country_Code__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='12',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter12CtryCode',Position__c=1001,Size__c=2,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Location_Country_Name__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='12',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter12Ctry',Position__c=1003,Size__c=30,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_State_Abbreviation__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='12',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter12St',Position__c=1033,Size__c=6,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_Description__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='12',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter12Desc',Position__c=1039,Size__c=40,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_ISO_Country__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='13',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter13CtryISO',Position__c=1079,Size__c=2,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_IATA_Numeric_Country_Code__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='13',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter13CtryCode',Position__c=1081,Size__c=2,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Location_Country_Name__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='13',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter13Ctry',Position__c=1083,Size__c=30,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_State_Abbreviation__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='13',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter13St',Position__c=1113,Size__c=6,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_Description__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='13',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter13Desc',Position__c=1119,Size__c=40,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_ISO_Country__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='14',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter14CtryISO',Position__c=1159,Size__c=2,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_IATA_Numeric_Country_Code__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='14',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter14CtryCode',Position__c=1161,Size__c=2,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Location_Country_Name__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='14',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter14Ctry',Position__c=1163,Size__c=30,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_State_Abbreviation__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='14',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter14St',Position__c=1193,Size__c=6,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_Description__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='14',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter14Desc',Position__c=1199,Size__c=40,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_ISO_Country__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='15',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter15CtryISO',Position__c=1239,Size__c=2,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_IATA_Numeric_Country_Code__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='15',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter15CtryCode',Position__c=1241,Size__c=2,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Location_Country_Name__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='15',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter15Ctry',Position__c=1243,Size__c=30,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_State_Abbreviation__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='15',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter15St',Position__c=1273,Size__c=6,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_Description__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='15',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter15Desc',Position__c=1279,Size__c=40,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_ISO_Country__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='16',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter16CtryISO',Position__c=1319,Size__c=2,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_IATA_Numeric_Country_Code__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='16',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter16CtryCode',Position__c=1321,Size__c=2,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Location_Country_Name__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='16',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter16Ctry',Position__c=1323,Size__c=30,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_State_Abbreviation__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='16',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter16St',Position__c=1353,Size__c=6,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_Description__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='16',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter16Desc',Position__c=1359,Size__c=40,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_ISO_Country__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='17',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter17CtryISO',Position__c=1399,Size__c=2,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_IATA_Numeric_Country_Code__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='17',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter17CtryCode',Position__c=1401,Size__c=2,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Location_Country_Name__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='17',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter17Ctry',Position__c=1403,Size__c=30,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_State_Abbreviation__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='17',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter17St',Position__c=1433,Size__c=6,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_Description__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='17',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter17Desc',Position__c=1439,Size__c=40,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_ISO_Country__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='18',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter18CtryISO',Position__c=1479,Size__c=2,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_IATA_Numeric_Country_Code__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='18',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter18CtryCode',Position__c=1481,Size__c=2,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Location_Country_Name__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='18',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter18Ctry',Position__c=1483,Size__c=30,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_State_Abbreviation__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='18',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter18St',Position__c=1513,Size__c=6,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_Description__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='18',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter18Desc',Position__c=1519,Size__c=40,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_ISO_Country__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='19',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter19CtryISO',Position__c=1559,Size__c=2,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_IATA_Numeric_Country_Code__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='19',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter19CtryCode',Position__c=1561,Size__c=2,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Location_Country_Name__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='19',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter19Ctry',Position__c=1563,Size__c=30,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_State_Abbreviation__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='19',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter19St',Position__c=1593,Size__c=6,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_Description__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='19',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter19Desc',Position__c=1599,Size__c=40,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_ISO_Country__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='20',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter20CtryISO',Position__c=1639,Size__c=2,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_IATA_Numeric_Country_Code__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='20',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter20CtryCode',Position__c=1641,Size__c=2,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Location_Country_Name__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='20',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter20Ctry',Position__c=1643,Size__c=30,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_State_Abbreviation__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='20',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter20St',Position__c=1673,Size__c=6,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_Description__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='20',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter20Desc',Position__c=1679,Size__c=40,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_ISO_Country__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='21',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter21CtryISO',Position__c=1719,Size__c=2,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_IATA_Numeric_Country_Code__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='21',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter21CtryCode',Position__c=1721,Size__c=2,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Location_Country_Name__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='21',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter21Ctry',Position__c=1723,Size__c=30,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_State_Abbreviation__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='21',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter21St',Position__c=1753,Size__c=6,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_Description__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='21',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter21Desc',Position__c=1759,Size__c=40,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_ISO_Country__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='22',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter22CtryISO',Position__c=1799,Size__c=2,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_IATA_Numeric_Country_Code__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='22',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter22CtryCode',Position__c=1801,Size__c=2,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Location_Country_Name__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='22',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter22Ctry',Position__c=1803,Size__c=30,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_State_Abbreviation__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='22',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter22St',Position__c=1833,Size__c=6,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='Territory_Description__c',API_Object_Name__c='GSA_Territory__c',Filter_Field_API_Name__c='Index',Filter_Field_Value__c='22',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='Ter22Desc',Position__c=1839,Size__c=40,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        myFileFieldsDescription.add(new GDP_File_Fields_Description__c(API_Name__c='ReserveAirline',API_Object_Name__c='Reserve',Filter_Field_API_Name__c='',Filter_Field_Value__c='',GDP_File_Description__c=myFileDescriptionReference.id,Hidden_Column__c=FALSE,Name__c='ReserveAirline',Position__c=1879,Size__c=170,Target__c='Airline',TXT_Hidden_Column__c=FALSE,Type__c='String',Visible__c=TRUE,XML_Hidden_Column__c=FALSE));
        
        Insert myFileFieldsDescription;
    } // insertGDPFileFieldsDescriptionTestData
    
    
    // insert records that will be part of data file, i.e.
    // GDP_Products_Account_View and related objects
    private static void insertGDPDataFileRecords()
    {
        
        //test.startTest();
        //list of related view to be inserted outside of for loop:
        //
        //list<sObject> ObjToInsertList = new list<sObject>();
        //list<GDP_Address__c> GDP_AddressList = new list<GDP_Address__c>();    
        //List<GDP_Delta__c> GDP_DeltaList = new List<GDP_Delta__c>();
        GDP_Products_Account_View_list = new List <GDP_Products_Account_View__c>();
        list<sObject> ObjToInsertList = new list<sObject>();        
        
        list<GSA_Territory__c> TerritoryList = new list<GSA_Territory__c>();
        for(Integer i = 0; i<2; i++){

            GDP_Products_Account_View__c myProductAccountView = new GDP_Products_Account_View__c();
            myProductAccountView.name='Account'+i;
            myProductAccountView.Website__c = 'WebsiteExample'+i;
            myProductAccountView.IATA_Code__c='1234567'+i;
            Insert myProductAccountView;
            
            
            //Insert two addresses per record in related list
            GDP_Address__c myLocationAddress = new GDP_Address__c(
                Address_Type__c         = 'Location',
                Address_Line_1__c       = 'LocationAddressLine1-'+i,
                Address_Line_2__c       = 'LocationAddressLine2-'+i,
                Address_Line_3__c       = 'LocationAddressLine3-'+i,
                Address_City__c         = 'Location Address_City__c -'+i,
                Address_Postal_Code__c  = 'H0H0H0',             
                Related_GDP_Products_Account_View__c =myProductAccountView.Id
            );
            //GDP_AddressList.add(myLocationAddress);
            ObjToInsertList.add(myLocationAddress);
            GDP_Address__c myMailingAddress = new GDP_Address__c(
                Address_Type__c         = 'Mailing',
                Address_Line_1__c       = 'Mailing AddressLine1-'+i,
                Address_Line_2__c       = 'Mailing AddressLine2-'+i,
                Address_Line_3__c       = 'Mailing AddressLine3-'+i,
                Address_City__c         = 'Mailing Address_City__c -'+i,
                Address_Postal_Code__c  = 'H0H0H0',         
                Related_GDP_Products_Account_View__c = myProductAccountView.Id 
            );
            //GDP_AddressList.add(myMailingAddress);   
            ObjToInsertList.add(myMailingAddress);   

            

            //GDP-227 Insert two accreditations per record in related list, 
            //the first one will be the related accreditation (main)
            myAccreditation1 = new Accreditation__c(
                Status__c         = ReferenceMap.get('Accredited'),
                Related_GDP_Products_Account_View__c =myProductAccountView.Id
            );
            Insert myAccreditation1;

            
            myAccreditation2 = new Accreditation__c(
                Status__c         = ReferenceMap.get('Terminated'),
                Related_GDP_Products_Account_View__c =myProductAccountView.Id
            );
            Insert myAccreditation2;
       
            //Set is the 'Main' related accreditation
            myProductAccountView.Related_Accreditation_Class__c = myAccreditation1.id;
            GDP_Products_Account_View_list.add(myProductAccountView);
            
            //Insert a Territory for Each Accreditations
            ObjToInsertList.add(new GSA_Territory__c(Related_Accreditation__c=myAccreditation1.id,
                                                  Related_GDP_Products_Account_View__c=myProductAccountView.Id,
                                                  Appointment_Date__c=Date.valueOf('2014-06-09')));
            ObjToInsertList.add(new GSA_Territory__c(Related_Accreditation__c=myAccreditation2.id,
                                                  Related_GDP_Products_Account_View__c=myProductAccountView.Id,
                                                  Appointment_Date__c=Date.valueOf('2014-06-09')));
            
            
            //Insert Account_Category__c
            Account_Category__c myAccount_Category = new Account_Category__c(            
                Related_GDP_Products_Account_View__c =myProductAccountView.Id
            );
            ObjToInsertList.add(myAccount_Category);
            
            //Insert Adjacent_Airport__c
            Adjacent_Airport__c myAdjacent_Airport= new Adjacent_Airport__c(            
                Related_GDP_Products_Account_View__c =myProductAccountView.Id
            );
            ObjToInsertList.add(myAdjacent_Airport);
            
            //Insert Agency_Owner__c
            Agency_Owner__c myAgency_Owner= new Agency_Owner__c(            
                Related_GDP_Products_Account_View__c =myProductAccountView.Id
            );
            ObjToInsertList.add(myAgency_Owner);
            
            //Insert Assoc_Affiliation_Membership__c
            Assoc_Affiliation_Membership__c myAssoc_Affiliation_Membership= new Assoc_Affiliation_Membership__c(            
                Related_GDP_Products_Account_View__c =myProductAccountView.Id
            );
            ObjToInsertList.add(myAssoc_Affiliation_Membership);
            
            //Insert GDP_Profile_Specialization__c
            GDP_Agency_Profile_Specialization__c myGDP_Profile_Specialization = new GDP_Agency_Profile_Specialization__c(            
                Related_GDP_Products_Account_View__c =myProductAccountView.Id
            );
            ObjToInsertList.add(myGDP_Profile_Specialization);
            
            
            //Insert GDP_Phone__c
            GDP_Phone__c myGDP_Phone = new GDP_Phone__c(
                Related_GDP_Products_Account_View__c =myProductAccountView.Id
            );
            ObjToInsertList.add(myGDP_Phone);
            
            
            //Insert GDS__c
            GDS__c myGDS = new GDS__c( 
                Related_GDP_Products_Account_View__c =myProductAccountView.Id
            );
            ObjToInsertList.add(myGDS); 
            
            //Insert old GDP_Delta__c to be cleaned by batch job
            GDP_Delta__c delta = new GDP_Delta__c();
            delta.GDP_File_Description__c=myFileDescriptionReference.Id;
            delta.DeltaLastModifiedDate__c=System.Today().addDays(-78);
            delta.Change_Code__c='A';
            delta.Related_GDP_Product_Account_View__c=myProductAccountView.id;
            ObjToInsertList.add(delta);
        
        }
        ObjToInsertList.sort();
        Insert ObjToInsertList;   
        //Insert GDP_AddressList;
        //Insert TerritoryList;
        //Insert GDP_DeltaList;
        Update GDP_Products_Account_View_list;
        
    } // end of insertGDPDataFileRecords
    
    
    
/* test delta payload
 * created by Alex 18/11/2015
*/
    static testMethod void TestGetPayloadDeltaAfter_Add_Change(){
        Test.startTest();
        //Arrange
        //get the reference File Description
        myFileDescriptionReference = [SELECT id 
                                      FROM GDP_File_Description__c 
                                      WHERE is_Reference__c = true][0];            
       
        
        //Create a DELTA file specification 
        myFileDescription = new GDP_File_Description__c(
            File_Format__c='TXT',
            Frequency__c='Monthly',
            Field_Label__c='',
            Reference__c=myFileDescriptionReference.id,
            Class__c='',
            Magnitude__c='Delta',
            Description__c='File Description Child Delta',
            File_Naming_Convention__c='Name'
        );
        Insert myFileDescription;
 
        GDP_Products_Account_View__c myProductAccountView = new GDP_Products_Account_View__c();
        myProductAccountView.name='Test Account';
        myProductAccountView.Website__c = 'Test WebsiteExample';
        Insert myProductAccountView;
        
         //GDP_Delta  
        list<GDP_Delta__c> deltaList = new list<GDP_Delta__c>();
        deltaList.Add(new GDP_Delta__c(Change_Code__c='A', DeltaLastModifiedDate__c=Date.Today().toStartOfMonth().addDays(-15), GDP_File_Description__c=myFileDescriptionReference.id, Related_GDP_Product_Account_View__c=myProductAccountView.id));
        deltaList.Add(new GDP_Delta__c(Change_Code__c='C', DeltaLastModifiedDate__c=Date.Today().toStartOfMonth().addDays(-14), GDP_File_Description__c=myFileDescriptionReference.id, Related_GDP_Product_Account_View__c=myProductAccountView.id));
        insert deltaList;
        

        //Call Payload Rest API and inspect code in response

        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/GSS/v0/FileDataAgency/';  
        req.httpMethod = 'GET';
        
        //req.addParameter('FileSpecificationId', [Select Id From GDP_File_Description__c limit 1][0].Id);
        req.addParameter('FileSpecificationId', myFileDescription.id);
        //req.addParameter('IsTestMode', '1');

        
        system.debug('TestGetPayloadDeltaAfter_Add_Change FileSpecificationId: '+myFileDescription.id);
        
        RestContext.request = req;
        RestContext.response = res;
        
        //Act
        //Call Payload Rest API and inspect Delta code in response

        GSS_REST_FilePayload.getFilePayload();
        Test.stopTest();
        
        //Assert
        system.debug('TestGetPayloadDeltaAfter_Add_Change getFilePayload responseBody : ' + res.responseBody.toString());
        system.debug('TestGetPayloadDeltaAfter_Add_Change getFilePayload Status Code : ' +  res.statusCode);
        System.assertEquals(200, res.statusCode);
        
        // Inspect Response body to see if there is something expected
        GSS_REST_FilePayload.FilePayload ResponsePayload = new  GSS_REST_FilePayload.FilePayload();
        ResponsePayload=(GSS_REST_FilePayload.FilePayload)JSON.deserialize(
                                                                            res.responseBody.toString(), 
                                                                            GSS_REST_FilePayload.FilePayload.class);

        list<string> FieldValueList = new list<string>();
        for(GSS_REST_FilePayload.Record Rec : ResponsePayload.FileRecords){
            if(rec.RecordId == myProductAccountView.id){
                FieldValueList.addAll(rec.Record.split('\\|'));
                break;
            }
        }
        

        //Assert
        //A-C code should return an A code
        system.debug('FieldValueList: '+FieldValueList);
        //system.assertEquals('A',FieldValueList[0],'A Code expected if A-C present in delta code sequence'); 
    }    


    /*
    *   This test method tests the Gss_DeltaTriggerHelper
    *   Created by Alex  29/09/2015
    */
    static testMethod void TestGss_DeltaTriggerHelper2() {
       //Arrange
       system.debug('TestGss_DeltaTriggerHelper2: ');
       list<GDP_Products_Account_View__c> Products_Account_View_list =
           [Select Id, Related_Accreditation_Class__c, 
            (SELECT id, Last_change_date__c, Status__c, Status__r.Code__c From Accreditation__r)
            From GDP_Products_Account_View__c];
        
        ReferenceMap= new map<String,id>();
        for(GDP_Reference_Table__c gr : [Select Id, Definition__c From GDP_Reference_Table__c  WHERE Table__c='STATUS']) {
            ReferenceMap.put(gr.Definition__c, gr.Id);
        }
        

        //Scenario 2 Change a field on a object referenced by a specifcation
        //Expect a C code
        // 
        // Act
        test.startTest();
        Products_Account_View_list[0].Accreditation__r[0].Last_change_date__c = Date.today().addDays(1);
        Update Products_Account_View_list[0].Accreditation__r[0];
        
        list<GDP_Delta__c> DeltaList = [Select id, Change_Code__c 
                                        FROM GDP_Delta__c 
                                        WHERE Related_GDP_Product_Account_View__c = : Products_Account_View_list[0].id
                                        Order By Id Desc];
         test.StopTest();       
       //Assert
        System.assertEquals('C', DeltaList[0].Change_Code__c, 'Expect a C code');

    }  
    
    static testMethod void TestGss_DeltaTriggerHelper4_5() {
        //Arrange
        list<GDP_Products_Account_View__c> Products_Account_View_list =
            [Select Id, Related_Accreditation_Class__c, 
             Related_Accreditation_Class__r.Status__c, 
             Related_Accreditation_Class__r.Status__r.Code__c 
             From GDP_Products_Account_View__c];
        
        ReferenceMap= new map<String,id>();
        for(GDP_Reference_Table__c gr : [Select Id, Definition__c From GDP_Reference_Table__c  WHERE Table__c='STATUS']) 
            ReferenceMap.put(gr.Definition__c, gr.Id);
        
        //Scenario 4 Change Accreditation code from Accredited to Terminated 
        //expect a 'D' Code
        //
        
        //Act
        system.debug('TestGss_DeltaTriggerHelper Scenario 4: ');
        Accreditation__c Accr = Products_Account_View_list[0].Related_Accreditation_Class__r;
        Accr.Status__c = ReferenceMap.get('Accredited');
        test.startTest();
        Update Accr;
        Accr.Status__c = ReferenceMap.get('Terminated');
        Update Accr;
        
        list<GDP_Delta__c> DeltaList = [Select Id, Name, Change_Code__c
                                        FROM GDP_Delta__c 
                                        WHERE Related_GDP_Product_Account_View__c = : Products_Account_View_list[0].id
                                        Order By Id Desc];
        
        //Assert
        system.debug('DeltaList 4: '+DeltaList);
        system.debug('DeltaList 4 size: ' + DeltaList.size());
        System.assertEquals('D', DeltaList[0].Change_Code__c, 'Expect a D code');
        
        
        //Scenario 5 Change Accreditation code from Terminated to Accredited 
        //expect a 'B' Code
        // 
        //Act
        system.debug('TestGss_DeltaTriggerHelper Scenario 5: ');
        Accr.Status__c = ReferenceMap.get('Accredited');
        Update Accr;
        Test.stopTest();
        
        //Assert
        DeltaList =                     [Select Id, Name, Change_Code__c
                                         FROM GDP_Delta__c 
                                         WHERE Related_GDP_Product_Account_View__c = : Products_Account_View_list[0].id
                                         Order By Id Desc];
        system.debug('DeltaList 5: '+DeltaList);
        system.debug('DeltaList 5 size: ' + DeltaList.size());
        System.assertEquals('B', DeltaList[0].Change_Code__c, 'Expect a B code');     
    }

    static testMethod void TestGss_DeltaTriggerHelper6() {
        //Arrange
        list<GDP_Products_Account_View__c> Products_Account_View_list =
            [Select Id, Related_Accreditation_Class__c, 
             (SELECT id, Last_change_date__c, Status__c, Status__r.Code__c From Accreditation__r Order by Id Asc)
             From GDP_Products_Account_View__c];
        
        ReferenceMap= new map<String,id>();
        for(GDP_Reference_Table__c gr : [Select Id, Definition__c From GDP_Reference_Table__c]) {
            ReferenceMap.put(gr.Definition__c, gr.Id);
        }
        //Scenario 6 Change Reference Accreditation on an Account, 
        //From a Accredited to an Terminated Accreditation record expect a 'D' Code
        //          
        system.debug('TestGss_DeltaTriggerHelper Scenario 6: ');

        System.AssertEquals(Products_Account_View_list[0].Accreditation__r[0].Status__r.Code__c,'9'); //Accredited
        System.AssertEquals(Products_Account_View_list[1].Accreditation__r[1].Status__r.Code__c,'0'); //Terminated
        
        
        //Act
        Test.StartTest();                            
        Products_Account_View_list[0].Related_Accreditation_Class__c =  Products_Account_View_list[0].Accreditation__r[1].Id;
        Update Products_Account_View_list[0];  
         Test.StopTest();       
        
        
        //Assert
        list<GDP_Delta__c> DeltaList = [Select Id, Name, Change_Code__c
                                        FROM GDP_Delta__c 
                                        WHERE Related_GDP_Product_Account_View__c = : Products_Account_View_list[0].id
                                        Order By Id Desc];
        system.debug('DeltaList 6: '+DeltaList);
        system.debug('DeltaList 6 size: ' + DeltaList.size());
        System.assertEquals('D', DeltaList[0].Change_Code__c, 'Expect a D code');   
    }
    
    /*
     Author: Abdellah Bellahssan
     This test class is to test the batch to clean up Delta entries older than 2 month
    */
    static testMethod void TestGDP_DeltaFileCleanuptestBatch() {
        

        //Act
        Test.StartTest();

        BtchDeltaFileCleanup BDel = new BtchDeltaFileCleanup();
        Date d = Date.Today();
        d = d.addDays(-62);
        // Query for selecting the file dalta entry to delete
        BDel.query = 'SELECT Id FROM GDP_Delta__c WHERE DeltaLastModifiedDate__c < ' + String.ValueOf(d);
        // Invoke the batch job.
        ID batchprocessid = Database.executeBatch(BDel);
        System.debug('Returned batch process ID: ' + batchProcessId);

        Test.StopTest();

        //Assert
        System.AssertEquals(
               database.countquery('SELECT COUNT()'
                  +' FROM GDP_Delta__c WHERE DeltaLastModifiedDate__c <'+ String.ValueOf(d)), 
               0); 
     }

    
    /*
    *   This test method tests the Subscription REST API
    *   Created by Alex  22/09/2015
    */
    static testMethod void TestGetSubscriptionId() {
        system.debug('mySubscription2 >> ' + mySubscription);       
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/GSS/v0/Subscriptions';  
        req.httpMethod = 'GET';
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        //1 Tests positive scenario
        GSS_REST_Subscriptions.getActiveSubscription();
        System.assertEquals(200, res.statusCode);
        
        GSS_REST_Subscriptions.SubscriptionCls ResponseClass = new GSS_REST_Subscriptions.SubscriptionCls();
        //system.debug('responseBody toString: ' + res.responseBody.toString());
        ResponseClass=(GSS_REST_Subscriptions.SubscriptionCls)JSON.deserialize(
            res.responseBody.toString(), 
            GSS_REST_Subscriptions.SubscriptionCls.class);
        
        //Assert that the return object contains the subscription that was sent
        system.assertEquals([Select Id From Zuora__Subscription__c limit 1][0].Id, ResponseClass.Subscriptions[0].SubscriptionId);
        
        //TODO
        //2 Test passing an argument to query more and find no results
        req.addHeader('SubscriptionId', [Select Id From Zuora__Subscription__c limit 1][0].Id);
        GSS_REST_Subscriptions.getActiveSubscription();
        System.assertEquals(200, res.statusCode);
        test.stopTest();
        //TODO
        //3 Test a scenario retunrning an expected error shoud return status Code 400
        /*
        req.addHeader('SubscriptionId', '534534_GarbageIdCode_213123');
        GSS_REST_Subscriptions.getActiveSubscription();
        System.assertEquals(400, res.statusCode);
        */
    }
    
    // =========================================================================
    // test FileSpecification delivery for basic successful case
    // the delivery record has not been created
    static testmethod void testGetFileSpecification01_WillDeliver(){
        System.debug( 'testGetFileSpecification01_WillDeliver');
        Zuora__Subscription__c zuoraSubscription = [select Id, Name 
                                                   from Zuora__Subscription__c 
                                                   where Zuora__Zuora_Id__c = : ZUORA_SUBSCRIPTION_ID_DAILY 
                                                   limit 1];
        System.debug('Subscription: >> ' + zuoraSubscription);
        System.assertNotEquals(null, zuoraSubscription);
        String SubscriptionId= zuoraSubscription.Id;
        
        // first, ensure no delivery has been done
        System.assertNotEquals(null, SubscriptionId);
        List<GDP_File_Delivery__c> deliveryList = [select Id from GDP_File_Delivery__c 
                                                   where Subscription__c = : SubscriptionId
                                                        and Delivery_Date__c= :System.today()];
        delete deliveryList;
        
        // prepare calling the REST API
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/GSS/v0/FileSpecification/';  
        req.httpMethod = 'POST';
        req.addHeader('SpecificationId', SubscriptionId);
        
        system.debug('SubscriptionId >> ' + SubscriptionId);
        List<String> listid = new String [] { SubscriptionId };
            
        // ----------------------------------------------------------
        Test.startTest();
        
        GSS_REST_FileSpecification.ListOfSubscriptionId RequestClass = new GSS_REST_FileSpecification.ListOfSubscriptionId(listid);
        req.requestBody = Blob.valueOf(json.serialize(RequestClass));
        System.debug( 'testGetFileSpecification:requestBody:' + req.requestBody.toString());
        
        RestContext.request = req;
        RestContext.response = res;
        
        //1 Tests positive scenario with code 200
        GSS_REST_FileSpecification.getActiveSubscription();
        System.assertEquals(200, res.statusCode);
        //System.debug('testGetFileSpecification:responseBody toString: ' + res.responseBody.toString());
        
        Test.stopTest();
        // ----------------------------------------------------------
        
        GSS_REST_FileSpecification.FileSpecificationCls ResponseClass = new GSS_REST_FileSpecification.FileSpecificationCls();
        
        ResponseClass=(GSS_REST_FileSpecification.FileSpecificationCls)JSON.deserialize(
            res.responseBody.toString(), 
            GSS_REST_FileSpecification.FileSpecificationCls.class);
        
        System.debug( 'ResponseClass.FileSpecifications size:' + ResponseClass.FileSpecifications.size());
        //System.debug( 'ResponseClass:' + ResponseClass);
        
        //Assert that the return object contains the filespecification
        // it might deliver the file specification of the SubscriptionDetail or its Master file
        String FileSpecificationId = ResponseClass.FileSpecifications[0].FileSpecificationID;
        String SubscriptionDetailId = ResponseClass.FileSpecifications[0].SubscriptionDetailID;
        System.debug( 'FileSpecificationID:' + FileSpecificationId);
        System.debug( 'SubscriptionDetailId:' + SubscriptionDetailId);
        System.assertNotEquals( null, FileSpecificationID, 'FileSpecificationID should not be null.');
        System.assertNotEquals( null, SubscriptionDetailId, 'SubscriptionDetailId should not be null.');
        
        Map<Id,GDP_File_Description__c> fileSpecIdToObjectMap = new Map<Id,GDP_File_Description__c> ([Select Id, Name, Description__c 
                                                             From GDP_File_Description__c limit 100]);
        System.debug( 'stored file description:'+ fileSpecIdToObjectMap);
        GDP_File_Description__c returnedFileSpec = fileSpecIdToObjectMap.get(FileSpecificationId);
        System.debug( 'returned fileSpecification:' + returnedFileSpec);
        System.assertNotEquals(null, returnedFileSpec, 'Returned FileSpecification not found');
        
    } // end of testGetFileSpecification01_WillDeliver
    
    
    // =========================================================================
    // test FileSpecification delivery for basic successful case
    // the delivery record has not been created
    static testmethod void testGetFileSpecification02_WillDeliverWeekly(){
        System.debug( 'testGetFileSpecification02_WillDeliverWeekly');
        
        Zuora__Subscription__c zuoraSubscription = [select Id, Name 
                                                   from Zuora__Subscription__c 
                                                   where Zuora__Zuora_Id__c = : ZUORA_SUBSCRIPTION_ID_WEEKLY 
                                                   limit 1];
        System.debug('Subscription: >> ' + zuoraSubscription);
        System.assertNotEquals(null, zuoraSubscription);
        String SubscriptionId= zuoraSubscription.Id;
        
        // first, ensure no delivery has been done
        System.assertNotEquals(null, SubscriptionId);
        List<GDP_File_Delivery__c> deliveryList = [select Id from GDP_File_Delivery__c 
                                                   where Subscription__c = : SubscriptionId
                                                        and Delivery_Date__c= :System.today()];
        delete deliveryList;
        
        // prepare calling the REST API
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/GSS/v0/FileSpecification/';  
        req.httpMethod = 'POST';
        req.addHeader('SpecificationId', SubscriptionId);
        
        system.debug('SubscriptionId >> ' + SubscriptionId);
        
        List<String> listid = new String [] { SubscriptionId };
            
        // ----------------------------------------------------------
        Test.startTest();
        
        GSS_REST_FileSpecification.ListOfSubscriptionId RequestClass = new GSS_REST_FileSpecification.ListOfSubscriptionId(listid);
        req.requestBody = Blob.valueOf(json.serialize(RequestClass));
        System.debug( 'testGetFileSpecification:requestBody:' + req.requestBody.toString());
        
        RestContext.request = req;
        RestContext.response = res;
        
        //1 Tests positive scenario with code 200
        GSS_REST_FileSpecification.getActiveSubscription();
        System.assertEquals(200, res.statusCode);
        //System.debug('testGetFileSpecification:responseBody toString: ' + res.responseBody.toString());
        
        GSS_REST_FileSpecification.FileSpecificationCls ResponseClass = new GSS_REST_FileSpecification.FileSpecificationCls();
        
        Test.stopTest();
        // ----------------------------------------------------------
        
        ResponseClass=(GSS_REST_FileSpecification.FileSpecificationCls)JSON.deserialize(
            res.responseBody.toString(), 
            GSS_REST_FileSpecification.FileSpecificationCls.class);
        
        System.debug( 'ResponseClass.FileSpecifications size:' + ResponseClass.FileSpecifications.size());
        //System.debug( 'ResponseClass:' + ResponseClass);
        
        //Assert that the return object contains the filespecification
        // it might deliver the file specification of the SubscriptionDetail or its Master file
        String FileSpecificationId = ResponseClass.FileSpecifications[0].FileSpecificationID;
        String SubscriptionDetailId = ResponseClass.FileSpecifications[0].SubscriptionDetailID;
        System.debug( 'FileSpecificationID:' + FileSpecificationId);
        System.debug( 'SubscriptionDetailId:' + SubscriptionDetailId);
        System.assertNotEquals( null, FileSpecificationID, 'FileSpecificationID should not be null.');
        System.assertNotEquals( null, SubscriptionDetailId, 'SubscriptionDetailId should not be null.');
        
        Map<Id,GDP_File_Description__c> fileSpecIdToObjectMap = new Map<Id,GDP_File_Description__c> ([Select Id, Name, Description__c 
                                                             From GDP_File_Description__c limit 100]);
        System.debug( 'stored file description:'+ fileSpecIdToObjectMap);
        GDP_File_Description__c returnedFileSpec = fileSpecIdToObjectMap.get(FileSpecificationId);
        System.debug( 'returned fileSpecification:' + returnedFileSpec);
        System.assertNotEquals(null, returnedFileSpec, 'Returned FileSpecification not found');
        
    } // end of testGetFileSpecification02_WillDeliveryWeekly
    
    
    // =========================================================================
    // test FileSpecification non delivery 
    // the delivery record have been created for all the subscription details related to this subscription
    // Tests positive scenario with Delivery date exists for the given subscription and product and charge      
    static testmethod void testGetFileSpecification03_WillNotDeliver(){
        System.debug( 'testGetFileSpecification03_WillNotDeliver');
        
        Zuora__Subscription__c zuoraSubscription = [select Id, Name 
                                                   from Zuora__Subscription__c 
                                                   where Zuora__Zuora_Id__c = : ZUORA_SUBSCRIPTION_ID_WEEKLY 
                                                   limit 1];
        System.debug('Subscription: >> ' + zuoraSubscription);
        System.assertNotEquals(null, zuoraSubscription);
        String SubscriptionId= zuoraSubscription.Id;
        System.assertNotEquals(null, SubscriptionId);
        
        // ensure we have all subscription detail listed in the delivery
        List<GSS_Subscription_Detail__c> subscriptionDetailList = [select Id, Zuora_Subscription__c, GDP_File_Description__c
                                                                  from GSS_Subscription_Detail__c
                                                                  where Zuora_Subscription__c = : SubscriptionId];
        List<GDP_File_Delivery__c> fileDeliveryList = new List<GDP_File_Delivery__c>();
        for (GSS_Subscription_Detail__c subDetail : subscriptionDetailList)  
        {
            fileDeliveryList.add( new GDP_File_Delivery__c(
                                    File_Specification__c= subDetail.GDP_File_Description__c,
                                    Subscription__c=SubscriptionId,
                                    GSS_Subscription_Detail__c= subDetail.Id,
                                    Status__c='Completed',
                                    Delivery_Date__c=System.today())
                                );
        }
        insert fileDeliveryList;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/GSS/v0/FileSpecification/';  
        req.httpMethod = 'POST';
        req.addHeader('SpecificationId', SubscriptionId);
        
        system.debug('SubscriptionId >> ' + SubscriptionId);
        
        List<String> listid = new String [] { SubscriptionId };
            
        // ----------------------------------------------------------
        Test.startTest();
        GSS_REST_FileSpecification.ListOfSubscriptionId RequestClass = new GSS_REST_FileSpecification.ListOfSubscriptionId(listid);
        req.requestBody = Blob.valueOf(json.serialize(RequestClass));
        System.debug( 'testGetFileSpecification:requestBody:' + req.requestBody.toString());
        
        RestContext.request = req;
        RestContext.response = res;
        
        GSS_REST_FileSpecification.getActiveSubscription();
        system.debug('responseBody toString: ' + res.responseBody.toString());
        
        GSS_REST_FileSpecification.FileSpecificationCls ResponseClass = new GSS_REST_FileSpecification.FileSpecificationCls();
        ResponseClass=(GSS_REST_FileSpecification.FileSpecificationCls)JSON.deserialize(
            res.responseBody.toString(), 
            GSS_REST_FileSpecification.FileSpecificationCls.class);
        
        Test.stopTest();
        
        System.debug( 'ResponseClass.FileSpecifications size:' + ResponseClass.FileSpecifications.size());
        System.assertEquals(0, ResponseClass.FileSpecifications.size());
    } // end of testGetFileSpecification03_WillNotDeliver
    
    
    
    
    
    
    static testmethod void testGetFilePayload(){
        
        //Arrange
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/GSS/v0/FileDataAgency/';  
        req.httpMethod = 'GET';
        
        req.addParameter('FileSpecificationId', [Select Id From GDP_File_Description__c limit 1][0].Id);
        req.addParameter('IsTestMode', '1');
        system.debug('testGetFilePayload FileSpecificationId: '+[Select Id From GDP_File_Description__c limit 1][0].Id);
        
        RestContext.request = req;
        RestContext.response = res;
        
        //Act
        Test.startTest();
        //1 Tests positive scenario with code 200
        GSS_REST_FilePayload.getFilePayload();
        
        //Assert
        system.debug('testGetFilePayload getFilePayload responseBody : ' + res.responseBody.toString());
        system.debug('testGetFilePayload getFilePayload Status Code : ' +  res.statusCode);
        System.assertEquals(200, res.statusCode);
        
        // Inspect Response body to see if there is something expected
        // GSS_REST_FilePayload.FilePayload 
        Test.stopTest(); 
    }
    
    static testmethod void testConfirmFileDelivery(){
        system.debug('mySubscription3 >> ' + mySubscription);
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/GSS/v0/ConfirmFileDelivery';  
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        
        
        //1 Tests positive scenario
        //
        
        //Build request object
        list<GSS_Rest_ConfirmFileDelivery.DeliveryConfirmation> requestClassList = new list<GSS_Rest_ConfirmFileDelivery.DeliveryConfirmation>();
        GSS_Rest_ConfirmFileDelivery.DeliveryConfirmation requestClass = new GSS_Rest_ConfirmFileDelivery.DeliveryConfirmation();
        
        
        requestClass.SubscriptionId =  [Select Id From Zuora__Subscription__c limit 1][0].Id;
        requestClass.FileSpecificationId = [Select Id From GDP_File_Description__c limit 1][0].Id;
        requestClass.SubscriptionDetailId = [Select Id From GSS_Subscription_Detail__c limit 1][0].Id;
        requestClass.FailureMessage = 'This is a to do delivery example';
        requestClass.Status = 'In Progress';
        
        
        requestClassList.add(requestClass);
        system.debug('requestClassList TEST 1: ' +Json.serialize(requestClassList));        
        req.requestBody =  Blob.valueOf(Json.serialize(requestClassList));
        //Test #1 Call with successfull criterias to insert record
        Test.startTest();
        GSS_REST_ConfirmFileDelivery.postConfirmationFileDelivery();
        
        list<GSS_REST_ConfirmFileDelivery.ReturnId> ReturnIdResponse = new list<GSS_REST_ConfirmFileDelivery.ReturnId>();
        
        ReturnIdResponse = (list<GSS_REST_ConfirmFileDelivery.ReturnId>)JSON.deserialize(
            res.responseBody.toString(), 
            list<GSS_REST_ConfirmFileDelivery.ReturnId>.class);
        //Inspect the Response should include the Id of the created ReturnId
        System.assertNotEquals(ReturnIdResponse[0].Id,null);
        System.assertEquals(200, res.statusCode);
        
        
        
        //Test #1B Call with successfull criterias to upsert record with Completed status
        requestClassList[0].FileDeliveryId = ReturnIdResponse[0].Id;
        requestClassList[0].Status = 'Completed';
        system.debug('requestClassList TEST 1B: ' +Json.serialize(requestClassList));        
        req.requestBody =  Blob.valueOf(Json.serialize(requestClassList));
        GSS_REST_ConfirmFileDelivery.postConfirmationFileDelivery();
        
        ReturnIdResponse = (list<GSS_REST_ConfirmFileDelivery.ReturnId>)JSON.deserialize(
            res.responseBody.toString(), 
            list<GSS_REST_ConfirmFileDelivery.ReturnId>.class);
        //Inspect the Response should include the Id of the created ReturnId
        System.assertEquals(ReturnIdResponse[0].Id,requestClassList[0].FileDeliveryId);
        System.assertEquals(200, res.statusCode);
        
        
        
        
        //Test Negative scenarios
        GSS_Rest_ConfirmFileDelivery.DeliveryConfirmation bad_requestClass = new GSS_Rest_ConfirmFileDelivery.DeliveryConfirmation();
        
        
        //Test #2 Call with bad status
        bad_requestClass.SubscriptionId=         requestClass.SubscriptionId;
        bad_requestClass.FileSpecificationId =   requestClass.FileSpecificationId ;
        bad_requestClass.SubscriptionDetailId =  requestClass.SubscriptionDetailId ;
        bad_requestClass.FailureMessage=         requestClass.FailureMessage;
        bad_requestClass.Status=                 requestClass.Status;
        bad_requestClass.Status=                 'BogusStatus';
        //requestClassList.clear(); // there will be 2 items in the list
        requestClassList.add(bad_requestClass);
        req.requestBody =  Blob.valueOf(Json.serialize(requestClassList));
        system.debug('requestClassList' + bad_requestClass);
        system.debug('requestClassList TEST 2: ' +Json.serialize(requestClassList));        
        GSS_REST_ConfirmFileDelivery.postConfirmationFileDelivery();
        System.assertEquals(400, res.statusCode);
        
        //Test #3 Call with missing required FileSpecificationId
        bad_requestClass.SubscriptionId=         requestClass.SubscriptionId;
        bad_requestClass.FileSpecificationId =   requestClass.FileSpecificationId ;
        bad_requestClass.SubscriptionDetailId =  requestClass.SubscriptionDetailId ;
        bad_requestClass.FailureMessage=         requestClass.FailureMessage;
        bad_requestClass.Status=                 requestClass.Status;
        bad_requestClass.FileSpecificationId = null;
        requestClassList.clear();
        requestClassList.add(bad_requestClass);
        system.debug('requestClassList TEST 3: ' +Json.serialize(requestClassList));
        req.requestBody =  Blob.valueOf(Json.serialize(requestClassList));
        GSS_REST_ConfirmFileDelivery.postConfirmationFileDelivery();
        System.assertEquals(400, res.statusCode);  
        
        //Test #4 Call with missing required SubscriptionDetailId
        
        bad_requestClass.SubscriptionId=         requestClass.SubscriptionId;
        bad_requestClass.FileSpecificationId =   requestClass.FileSpecificationId ;
        bad_requestClass.SubscriptionDetailId =  requestClass.SubscriptionDetailId ;
        bad_requestClass.FailureMessage=         requestClass.FailureMessage;
        bad_requestClass.Status=                 requestClass.Status;
        bad_requestClass.SubscriptionDetailId =  null;
        system.debug('requestClassList TEST 4: ' +Json.serialize(requestClassList));        
        req.requestBody =  Blob.valueOf(Json.serialize(bad_requestClass));
        GSS_REST_ConfirmFileDelivery.postConfirmationFileDelivery();
        System.assertEquals(400, res.statusCode); 
        
        
        //Test #5 Call with missing required SubscriptionDetailId
        bad_requestClass.SubscriptionId=         requestClass.SubscriptionId;
        bad_requestClass.FileSpecificationId =   requestClass.FileSpecificationId ;
        bad_requestClass.SubscriptionDetailId =  requestClass.SubscriptionDetailId ;
        bad_requestClass.FailureMessage=         requestClass.FailureMessage;
        bad_requestClass.Status=                 requestClass.Status;
        bad_requestClass.SubscriptionDetailId =  null;
        requestClassList.clear();
        requestClassList.add(bad_requestClass);
        system.debug('requestClassList TEST 5: ' +Json.serialize(requestClassList));        
        req.requestBody =  Blob.valueOf(Json.serialize(requestClassList));
        GSS_REST_ConfirmFileDelivery.postConfirmationFileDelivery();
        System.assertEquals(400, res.statusCode);   
        
        //Test #6 Call with bogus SubscriptionDetailId
        bad_requestClass.SubscriptionId=         requestClass.SubscriptionId;
        bad_requestClass.FileSpecificationId =   requestClass.FileSpecificationId ;
        bad_requestClass.SubscriptionDetailId =  requestClass.SubscriptionDetailId ;
        bad_requestClass.FailureMessage=         requestClass.FailureMessage;
        bad_requestClass.Status=                 requestClass.Status;
        bad_requestClass.SubscriptionDetailId = 'bogusId';
        requestClassList.clear();
        requestClassList.add(bad_requestClass);
        system.debug('requestClassList TEST 6: ' +Json.serialize(requestClassList));
        req.requestBody =  Blob.valueOf(Json.serialize(requestClassList));
        GSS_REST_ConfirmFileDelivery.postConfirmationFileDelivery();
        System.assertEquals(400, res.statusCode);       
        Test.stopTest();
    }  

    // normal scenario in using GSS_REST_FileProduction
    static testmethod void testGetFileProduction01_NormalCase(){
        system.debug('File Production  >>> In progress');  
        
        String FileSpecificationId= [Select Id From GDP_File_Description__c 
                where Name = : FILE_DESCRIPTION_NAME_NON_REFERENCE_DELTA_DAILY_01
                      and Is_Reference__c = false
                limit 1][0].Id;
        
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/GSS/v0/FileProduction/';  
        req.httpMethod = 'GET';
        //req.addHeader('FileSpecification', '000000000000000');
        req.addParameter('FileSpecificationId', FileSpecificationId);
        req.addParameter('IsUniqueRequest', 'true');
        
        system.debug('FileSpecification >> ' + FileSpecificationId);
        
        List<String> listid = new String [] { FileSpecificationId };
            
        //    GSS_REST_FileProduction.ListOfSubscriptionId RequestClass = new GSS_REST_FileProduction.ListOfSubscriptionId(listid);
        // req.requestBody = Blob.valueOf(json.serialize(RequestClass));
        
        
        RestContext.request = req;
        RestContext.response = res;
        
        Test.startTest();
        //change Production Date    
        List<GDP_File_Production__c> fplist= new List<GDP_File_Production__c>();
        fplist=[Select id, Production_Date__c,Status__c from GDP_File_Production__c];
        if (fplist.Size()>0)
        {
             for(GDP_File_Production__c fp:fplist)
             {
                 fp.Production_Date__c = System.Today().AddMonths(-1);
                 fp.Status__c='Completed';
             }
             update fplist;
        }
        //1 Tests positive scenario with code 200
        GSS_REST_FileProduction.getFiletoProduce();
        System.assertEquals(200, res.statusCode);
        
        GSS_REST_FileProduction.FileProductionCls ResponseClass = new GSS_REST_FileProduction.FileProductionCls();
        
        system.debug('responseBody toString: ' + res.responseBody.toString());
        ResponseClass=(GSS_REST_FileProduction.FileProductionCls)JSON.deserialize(
            res.responseBody.toString(), 
            GSS_REST_FileProduction.FileProductionCls.class);
        
        
        //Assert that the return object contains the filespecification that was sent
        //system.assertEquals(ResponseClass.FileProductions[0].FileSpecificationID, FileSpecificationId);
        
        ResponseClass.FileProductions.Clear();
        GSS_REST_FileProduction.getFiletoProduce();
        system.debug('responseBody toString: ' + res.responseBody.toString());
        ResponseClass=(GSS_REST_FileProduction.FileProductionCls)JSON.deserialize(
            res.responseBody.toString(), 
            GSS_REST_FileProduction.FileProductionCls.class);

        Test.stopTest();
    }

    // additional calls to supporting methods in GSS_REST_FileProduction
    // simply added to increase coverage and ensure those little methods callable
    static testmethod void testGetFileProduction01_OtherCalls(){
        
        Test.startTest();
        
        GSS_REST_FileProduction.FieldStructureCls fieldStruct = new GSS_REST_FileProduction.FieldStructureCls();
        // call public String ExtractField(Integer TypeList, String ObjectName)
        fieldStruct.ExtractField(0,0, 'Account');
        
        // call public void LoadFieldStructure(...)
        String vFieldAPIName = 'Name|Name|Name';
        String vFieldLabel = 'One|Field Two|Name';
        String vFieldLength = '20|50|80';
        String vFieldType = 'String|String|String';
        String vFieldObjectName = 'GDP_Products_Account_View__c|Accreditation__c|Account';
        String vFieldGroup ='||';
        String vFieldHiddenColumn = '0|0|1';
        String vXmlName = 'Name|Name|Name';
        String vFieldXmlStructure = '||';
        String vXmlHiddenColumn  = '0|0|1';
        String vTxtHiddenColumn  = '0|0|0';
        String vXmlGroup = '||';        
        fieldStruct.LoadFieldStructure(vFieldAPIName,
                                         vFieldLabel,
                                         vFieldLength,
                                         vFieldType,
                                         vFieldObjectName,
                                         vFieldGroup,
                                         vFieldHiddenColumn,
                                         vXmlName,
                                         vFieldXmlStructure,
                                         vXmlHiddenColumn,
                                         vTxtHiddenColumn,
                                         vXmlGroup );
        
        // the calling FileProductionCls
        // this actually should be called when calling GSS_REST_FileProduction.getFileToProduce()
        GSS_REST_FileProduction.FileProductionCls fileProdList = new GSS_REST_FileProduction.FileProductionCls();
        
        // the calling FileProduction
        // this actually should be called when calling GSS_REST_FileProduction.getFileToProduce()
        GSS_REST_FileProduction.FileProduction fileProd = new GSS_REST_FileProduction.FileProduction();
        
        Test.stopTest();
    } // testGetFileProduction02_OtherCalls
    
    static testmethod void testConfirmFileProduction(){
        system.debug('myProduction >>> ConfirmFileProduction ' );
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/GSS/v0/ConfirmFileProduction';  
        req.httpMethod = 'POST';
        RestContext.request = req;
        RestContext.response = res;
        
        
        //1 Tests positive scenario
        //
        
        //Build request object
        list<GSS_Rest_ConfirmFileProduction.ProductionConfirmation> requestClassList = new list<GSS_Rest_ConfirmFileProduction.ProductionConfirmation>();
        GSS_Rest_ConfirmFileProduction.ProductionConfirmation requestClass = new GSS_Rest_ConfirmFileProduction.ProductionConfirmation();
        requestClass.FileSpecificationId = [Select Id From GDP_File_Description__c limit 1][0].Id;

        requestClass.FailureMessage = 'This is a to do delivery example';
        requestClass.Status = 'In Progress';
        
        
        requestClassList.add(requestClass);
        system.debug('requestClassList TEST 1: ' +Json.serialize(requestClassList));        
        req.requestBody =  Blob.valueOf(Json.serialize(requestClassList));
        //Test #1 Call with successfull criterias to insert record
        Test.startTest();
        GSS_REST_ConfirmFileProduction.postConfirmationFileProduction();
        
        list<GSS_REST_ConfirmFileProduction.ReturnId> ReturnIdResponse = new list<GSS_REST_ConfirmFileProduction.ReturnId>();
        
        ReturnIdResponse = (list<GSS_REST_ConfirmFileProduction.ReturnId>)JSON.deserialize(
            res.responseBody.toString(), 
            list<GSS_REST_ConfirmFileProduction.ReturnId>.class);
        //Inspect the Response should include the Id of the created ReturnId
        System.assertNotEquals(ReturnIdResponse[0].Id,null);
        System.assertEquals(200, res.statusCode);
        
        
        
        //Test #1B Call with successfull criterias to upsert record with Completed status
        //requestClassList[0].FileDeliveryId = ReturnIdResponse[0].Id;
        requestClassList[0].Status = 'Completed';
        requestClassList[0].FailureMessage = '';
        
        system.debug('requestClassList TEST 1B: ' +Json.serialize(requestClassList));        
        req.requestBody =  Blob.valueOf(Json.serialize(requestClassList));
        GSS_REST_ConfirmFileProduction.postConfirmationFileProduction();
        
        ReturnIdResponse = (list<GSS_REST_ConfirmFileProduction.ReturnId>)JSON.deserialize(
            res.responseBody.toString(), 
            list<GSS_REST_ConfirmFileProduction.ReturnId>.class);
        //Inspect the Response should include the Id of the created ReturnId
        System.assertEquals(ReturnIdResponse[0].FileSpecification,requestClassList[0].FileSpecificationId);
        System.assertEquals(200, res.statusCode);
        
        

        //Test Negative scenarios
        GSS_Rest_ConfirmFileProduction.ProductionConfirmation bad_requestClass = new GSS_Rest_ConfirmFileProduction.ProductionConfirmation();
        
        
        //Test #2 Call with bad status
        bad_requestClass.FileSpecificationId =   requestClass.FileSpecificationId ;
        bad_requestClass.FailureMessage=         requestClass.FailureMessage;
        bad_requestClass.Status=                 'BogusStatus';
        //requestClassList.clear(); // there will be 2 items in the list
        requestClassList.add(bad_requestClass);
        req.requestBody =  Blob.valueOf(Json.serialize(requestClassList));
        system.debug('requestClassList' + bad_requestClass);
        system.debug('requestClassList TEST 2: ' +Json.serialize(requestClassList));        
        GSS_REST_ConfirmFileProduction.postConfirmationFileProduction();
        System.assertEquals(400, res.statusCode);
        
        //Test #3 Call with missing required FileSpecificationId
        bad_requestClass.FailureMessage=         requestClass.FailureMessage;
        bad_requestClass.Status=                 requestClass.Status;
        bad_requestClass.FileSpecificationId = null;
        requestClassList.clear();
        requestClassList.add(bad_requestClass);
        system.debug('requestClassList TEST 3: ' +Json.serialize(requestClassList));
        req.requestBody =  Blob.valueOf(Json.serialize(requestClassList));
        GSS_REST_ConfirmFileProduction.postConfirmationFileProduction();
        System.assertEquals(400, res.statusCode);  
        
        Test.stopTest();
    }  

    
    static testmethod void testExceptionHandler(){          
        RestRequest req = new RestRequest(); 
        RestResponse res = new RestResponse();
        
        req.requestURI = '/GSS/v0/ExceptionHandler/';  
        req.httpMethod = 'POST';
        
        
        //1 Tests Negative scenario with missing required parameter, expected StatusCode 400            
        //Build a custom exception to send in request
        GSS_REST_ErrorHandler.ExceptionHandler myEx = new GSS_REST_ErrorHandler.ExceptionHandler();
        //myEx.ModuleProcess='The source module of the exception (missing required parameter)';
        myEx.ExceptionMessage = 'The message of the exception (required parameter)';
        myEx.StackTrace = 'Stack trace of the exception thrown (optional parameter)';        
        
        
        req.requestBody = Blob.valueOf(json.serialize(myEx));
        RestContext.request = req;
        RestContext.response = res;
        
        //Call the REST API
        GSS_REST_ErrorHandler.postException();
        system.debug('testExceptionHandler test1 Exception RequestBody : ' + json.serialize(myEx));
        system.debug('testExceptionHandler test1 Status Code : ' +  res.statusCode);
        System.assertEquals(400, res.statusCode);      
        
        //2 Tests Positive scenario , expected StatusCode 200            
        //Build a custom exception to send in request
        myEx.ModuleProcess='The source module of the exception (required parameter)';
        myEx.ExceptionMessage = 'The message of the exception (required parameter)';
        //myEx.StackTrace = 'Stack trace of the exception thrown (missing optionnal parameter)';        
        
        req.requestBody = Blob.valueOf(json.serialize(myEx));
        RestContext.request = req;
        RestContext.response = res;
        
        //Call the REST API
        GSS_REST_ErrorHandler.postException();
        system.debug('testExceptionHandler test2 Exception RequestBody : ' + json.serialize(myEx));
        system.debug('testExceptionHandler test2 Status Code : ' +  res.statusCode);
        System.assertEquals(200, res.statusCode);      
    }
}