/**
 * This class contains unit tests for the Schedule Job SchdlCACWSUsageUpdate for retrieving live usage from RDS to live usage in SFDC
 */
@isTest
global class SchdlCACWSUsageUpdate_tst {
    public static IATA_ISO_Country__c myCountry;
    public static Account myAcct;
    public static Zuora__CustomerAccount__c myBillingAcct;
    public static Product_Category__c myProductCategory;
    public static Product_Information__c myProductInformation;
    public static Zuora__Subscription__c mySubscription;
    public static GDP_File_Description__c myFileDescription;
    public static GDP_File_Description__c myFileDescriptionReference;
    public static CAC_Subscription_Detail__c mySubscriptionDetail;

    private static void setupData() {
        
        //Adding new Subscription Record
        //Adding New File Description Reference and Live Description
        //Adding New CAC Subscription Detail Record

        
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
            Zuora__Zuora_Id__c = '12345678901234567890123456789012'
        );
        Insert myBillingAcct;
        
        // Create Product Information                 
        //myProductInformation = IECTestUtil.CreateSampleProductInfo('Test ProductInformation', myProductCategory, myZProduct);
        //myProductInformation.Product_Audience__c = IECConstants.ProductInformationAudience_DEFAULT;
        //insert myProductInformation;
        
        //Create an active subscription for this account / billing account
        mySubscription = new Zuora__Subscription__c (
            Name = myAcct.name+' Subscription',
            Zuora__Account__c =myAcct.id,
            Zuora__CustomerAccount__c = myBillingAcct.Id,
            Zuora__Zuora_Id__c = '22345678901234567890123456789012', 
            Zuora__SubscriptionStartDate__c = Date.today().addYears(-1),
            Zuora__SubscriptionEndDate__c = Date.today().addYears(1),
            Zuora__Status__c = 'Active'
        );
        Insert mySubscription;
        system.debug('mySubscription >> ' + mySubscription);
        
        //Create the reference File Description
        myFileDescriptionReference = new GDP_File_Description__c(
            File_Format__c='Database',
            Payload_Procedure__c='Agency',
            Frequency__c='Daily',
            Product_Type__c='CACSWS',
            Reference__c=null,
            Class__c='',
            Magnitude__c='Master',
            Field_Label__c='',
            Description__c='Test Reference File description',
            File_Naming_Convention__c='Name'
            
        );
        Insert myFileDescriptionReference;
        
        //Create a file specification with file field desctiption (for GetFileSpecification)
        myFileDescription = new GDP_File_Description__c(
            File_Format__c='Database',
            Payload_Procedure__c='Agency',
            Frequency__c='Daily',
            Product_Type__c='CACSWS',
            Field_Label__c='',
            Reference__c=myFileDescriptionReference.id,
            Class__c='',
            Magnitude__c='Master',
            Description__c='File Description Child 1',
            File_Naming_Convention__c='[Prefix]CGO1_Day[ddd]_[yyyy][Suffix].AD'
        );
        Insert myFileDescription;
        
       //ADD New Subscription Detail  
        mySubscriptionDetail = new CAC_Subscription_Detail__c(
            Name = 'Test CAC Subscription Detail',
            Subscription__c = mySubscription.Id,
            Service_Specification__c=myFileDescription.Id,
            Service_Token__c='My token',
            Max_API_Call_Per_Month__c=10000,
            Status__c='Active'
        );
        Insert mySubscriptionDetail;       
        
       
        
    
    }

    static testMethod void testCACWSUsageSchdl() {
        Test.startTest();
        // Set up scheduled job
        datetime nextScheduleTime = system.now().addMinutes(1);
        string minute = string.valueof(nextScheduleTime.minute());
        string second = string.valueof(nextScheduleTime.second ());
        string cronvalue = second + ' ' + minute + ' * * * ?' ;
        string jobName = 'SchdlCACWSUsageUpdate ' + nextScheduleTime.format('hh:mm');
        system.schedule(jobName, cronvalue , new SchdlCACWSUsageUpdate());
        Test.stopTest();
    }
    
    static testMethod void testCACWSUsageToCompile() {
        
        setupData();
        
        Test.startTest();
        // Set up batch job
        BtchCACWSUsageUpdate btchProc = new BtchCACWSUsageUpdate();
        String StringResponse='';
        List<CAC_Subscription_Detail__c> caclist = new List<CAC_Subscription_Detail__c>();
        caclist = [select  id
                     From CAC_Subscription_Detail__c                                   
                     Limit 1];  
        
        StringResponse += '[';
        StringResponse += '  {';
        StringResponse += '    "uniqueid": "1",';
        StringResponse += '    "service_specification": "a6G8E000000028ZUAQ",';
        StringResponse += '    "service_product": "'+String.ValueOf(caclist[0].id) +'",';
        StringResponse += '    "response_type": "",';
        StringResponse += '    "request_period": "20151231",';
        StringResponse += '    "api_counter": "60",';
        StringResponse += '    "api_max": "300",';
        StringResponse += '   "goodapi_counter": "59",';
        StringResponse += '    "badapi_counter": "1"';
        StringResponse += '  },';
        StringResponse += '  {';
        StringResponse += '    "uniqueid": "11",';
        StringResponse += '    "service_specification": "a6G8E000000028ZUAQ",';
        StringResponse += '    "service_product": "'+String.ValueOf(caclist[0].id) +'",';
        StringResponse += '    "response_type": "",';
        StringResponse += '    "request_period": "20160211",';
        StringResponse += '    "api_counter": "64",';
        StringResponse += '    "api_max": "300",';
        StringResponse += '   "goodapi_counter": "63",';
        StringResponse += '    "badapi_counter": "1"';
        StringResponse += '  }';
        StringResponse += ']';
        btchProc.Response = StringResponse; 
        btchProc.IsTest   =true;
        // test #1 - run the batch with a target date of 3 days ago (should not compile anything)
       
        Database.executeBatch(btchProc, 50);
        
        Test.stopTest();
         
        //system.assertEquals(iNbrLiveUsageBefore, iNbrLiveUsageAfter, 'No live usage should be compiled');
    }
    
    
}