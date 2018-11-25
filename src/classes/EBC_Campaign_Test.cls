public class EBC_Campaign_Test {
    public static Account IECTestUtil_Account;
    public static Contact IECTestUtil_Contact;
    public static User IECTestUtil_User;
    public static Id IECTestUtil_UserId;
    public static Zuora__CustomerAccount__c oBillingAccount;
    
    public static User initPreRunAs(Boolean grantEBCAccess) {
         Account a = new Account();
        a.RecordTypeId = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Standard Account').getRecordTypeId();
        a.BillingStreet = '123 main street';
        a.BillingPostalCode = 'H0H 0H0';
        a.BillingCountry = 'Canada';
        a.BillingCity = 'Montreal';
        a.Customer_Type__c = 'Third Party';
        a.Name = 'Company';
        a.OwnerId = '00520000002MSDBAA4';
        insert a;
        
        Contact c = new Contact();
        c.RecordTypeId = Schema.SObjectType.Contact.getRecordTypeInfosByName().get('Standard').getRecordTypeId();
        c.AccountId = a.Id;
        c.OwnerId = a.OwnerId;
        c.FirstName = 'Test';
        c.LastName = 'User';
        c.Title = 'TestTitle';
        c.Email = 'testIECGuest@test.iata.org';
        c.Phone = '514123345';
        c.User_IECPortal_Status__c = 'Privilege - Approved';
        insert c;

        oBillingAccount = new Zuora__CustomerAccount__c(
            Zuora__Account__c = a.Id
            , Contact__c = c.Id
            , Name = a.Name
            , eBroadcast_Product_Access__c = true
            , CRMContactID__c = String.valueOf(c.Id)
            , Zuora__DefaultPaymentMethod__c = 'CreditCard'
            , Zuora__BillToCity__c = 'Toronto'
            , Zuora__BillToCountry__c = 'Canada'
            , Zuora__BillToState__c = 'Ontario'
            , Zuora__BillToAddress1__c = '123 Test St'
            , Zuora__BillToPostalCode__c = 'A9A9A9'
        );
        
        insert oBillingAccount;
        
        
        
        User usr = new User(
            Username = 'testIECGuest.test.iata.org@partner.iata.org'
            , Email = 'testIECGuest@test.iata.org'
            , emailencodingkey = 'UTF-8'
            , Alias = 'testu'
            , FirstName = c.FirstName
            , LastName = c.LastName
            , LocaleSidKey = 'en_US'
            , CommunityNickname = 'testIECGuest@iata.org'
            , ProfileId = [Select Id From Profile p where p.Name = 'ISS Portal (Partner)'].Id
            , LanguageLocaleKey = 'en_US'
            , timezonesidkey = 'America/New_York'
            , ContactId = c.Id
            , IsActive = true
            , ReceivesAdminInfoEmails = false
            , ReceivesInfoEmails = false
        );
        insert usr;
        
        
        IECTestUtil.trgPortalUserAfterInserUpdate = true;
        String userId = Site.createPortalUser(usr, a.Id, 'testpassword');
        IECUserManager.login(usr.Username, 'testpassword', null);
           
        IECTestUtil_Account = a;
        IECTestUtil_Contact = c;
        //IECTestUtil_BillingAccount = ba;
        IECTestUtil_User = usr;
        IECTestUtil_UserId = userId;
        
        
        return usr;
    }
    
    public static List<GDP_Products_Account_View__c> createGDPProductsAccountViews() {
        GDP_Reference_Table__c grt = new GDP_Reference_Table__c(Code__c = '4');
        insert grt;
        Accreditation__c accr = new Accreditation__c(Status__c = grt.Id);
        insert accr;
            
        List<GDP_Products_Account_View__c> gpavs = new List<GDP_Products_Account_View__c>{
            new GDP_Products_Account_View__c(Name = 'a',                Related_Accreditation_Class__c = accr.Id,   GDP_Opt_In__c = true,   Email_Address__c = 'a@b.com',           Preferred_Language__c = 'X0',    IATA_Code__c='111110911', CASS_Number__c='', Check_Digit__c=''),
                new GDP_Products_Account_View__c(Name = 'b',            Related_Accreditation_Class__c = accr.Id,   GDP_Opt_In__c = true,   Email_Address__c = 'b@b.com',           Preferred_Language__c = 'X0',    IATA_Code__c='111110912', CASS_Number__c='', Check_Digit__c=''),
                new GDP_Products_Account_View__c(Name = 'c',            Related_Accreditation_Class__c = accr.Id,   GDP_Opt_In__c = true,   Email_Address__c = 'c@b.com',           Preferred_Language__c = 'X0',    IATA_Code__c='111110913', CASS_Number__c='', Check_Digit__c=''),
                new GDP_Products_Account_View__c(Name = 'd',            Related_Accreditation_Class__c = accr.Id,   GDP_Opt_In__c = true,   Email_Address__c = 'd@b.com',           Preferred_Language__c = 'X0',    IATA_Code__c='111110914', CASS_Number__c='', Check_Digit__c=''),
                new GDP_Products_Account_View__c(Name = 'e',            Related_Accreditation_Class__c = accr.Id,   GDP_Opt_In__c = true,   Email_Address__c = 'e@b.com',           Preferred_Language__c = 'X0',    IATA_Code__c='111110915', CASS_Number__c='', Check_Digit__c=''),
                new GDP_Products_Account_View__c(Name = 'f',            Related_Accreditation_Class__c = accr.Id,   GDP_Opt_In__c = true,   Email_Address__c = 'f@b.com',           Preferred_Language__c = 'X0',    IATA_Code__c='111110916', CASS_Number__c='', Check_Digit__c=''),
                new GDP_Products_Account_View__c(Name = 'notincluded',  Related_Accreditation_Class__c = accr.Id,   GDP_Opt_In__c = true,   Email_Address__c = 'notincluded@b.com', Preferred_Language__c = 'X1',    IATA_Code__c='111110917', CASS_Number__c='', Check_Digit__c=''),
                new GDP_Products_Account_View__c(Name = 'optout',       Related_Accreditation_Class__c = accr.Id,   GDP_Opt_In__c = false,  Email_Address__c = 'optout@b.com',      Preferred_Language__c = 'X0',    IATA_Code__c='111110918', CASS_Number__c='', Check_Digit__c=''),
                new GDP_Products_Account_View__c(Name = 'duplicate',    Related_Accreditation_Class__c = accr.Id,   GDP_Opt_In__c = true,   Email_Address__c = 'duplicate@b.com',   Preferred_Language__c = 'X0',    IATA_Code__c='111110919', CASS_Number__c='', Check_Digit__c=''),
                new GDP_Products_Account_View__c(Name = 'duplicate1',   Related_Accreditation_Class__c = accr.Id,   GDP_Opt_In__c = true,   Email_Address__c = 'duplicate@b.com',   Preferred_Language__c = 'X0',    IATA_Code__c='111110920', CASS_Number__c='', Check_Digit__c='')
            };
        insert gpavs;
        return gpavs;
    }
    
    public static Product_Category__c oProductCategory;
    public static Product_Information__c oProductInfo;
    public static zqu__ZProduct__c oProduct;
    public static zqu__ProductRatePlan__c oProductRatePlan;
    public static zqu__ProductRatePlanCharge__c oProductRatePlanCharge;
    public static Product_Rate_Plan_Information__c oProductRatePlanInfo;
    public static Zuora__Subscription__c subscription;
    public static Zuora__SubscriptionProductCharge__c subscriptionCharge;
    public static EBC_Preference__c oPref;
    public static IECCustomer currentCustomer;

    public static void initPostRunAs() {
        IECEBC_TestUtility.createEbcSetupAndRelatedData();
        oProductCategory = IECEBC_TestUtility.oEbcProductCategory;
        
        oProduct = IECEBC_TestUtility.oEbcProductNonMember;
        
        oProductInfo = IECEBC_TestUtility.mProductIdToProductInfoObj.get(oProduct.Id);
        
        oProductRatePlan = IECEBC_TestUtility.lEbcProductRatePlanNonMember[0];
        
        oProductRatePlanCharge = IECTestUtil.CreateSampleProductRatePlanCharge(oProductRatePlan
                                                                               , 'CHARGETEST'
                                                                               , 1);
        insert oProductRatePlanCharge;
        
        oProductRatePlanInfo = IECTestUtil.CreateSampleProductRatePlanInfo('Starter Edition'
                                                                           , false, oProductRatePlan
                                                                           , oProductInfo);
        insert oProductRatePlanInfo; 
        
        currentCustomer = IECCustomer.getCurrentIECCustomer(); 
        
        // create dummy subscription
        subscription = IECTestUtil.createSampleSubscription(IECTestUtil_Account.Id
                                                            , oBillingAccount.Id
                                                            , 'Subs 01'
                                                            , Date.today().addMonths(6));
        subscription.Product_Rate_Plan_Information__c = oProductRatePlanInfo.Id;
        insert subscription;
        
        // create dummy subscription charge
        subscriptionCharge = IECTestUtil.createSampleSubscriptionCharge(subscription.Id
                                                                        , Date.today().addMonths(-6)
                                                                        , oProduct
                                                                        , oProductRatePlan);
        insert subscriptionCharge;
        
        oPref = new EBC_Preference__c(Billing_Account__c = oBillingAccount.Id
                                      , PrimaryContact_Email__c = 'hello@world.com'
                                      , Default_From_Name__c = 'w00t'
                                      , PrimaryContact_Name__c = 'w00t');
        
        insert oPref;
    }
   
    public static void testElasticQuery(Boolean WithOrWithException, Boolean IsIdCard) {
        
        User usr = initPreRunAs(true); 
        
        oBillingAccount.eBroadcast_Trusted_Sender__c = true;
        update oBillingAccount;
        
        GDP_Reference_Table__c grt = new GDP_Reference_Table__c(Code__c = '4');
        insert grt;
        Accreditation__c accr = new Accreditation__c(Status__c = grt.Id);
        insert accr;
       
        List<GDP_Products_Account_View__c> gpavs = createGDPProductsAccountViews();
        EBC_Activity__c act = new EBC_Activity__c(Related_Billing_Account__c = oBillingAccount.Id
                                                  , New_Balance__c = 1000
                                                  , Total_Count__c = 1000
                                                  , Activity_Type__c = 'Credit'
                                                  , Activity_Date_Time__c = Datetime.now());
        insert act;
        EBC_Application_Filter__c af = new EBC_Application_Filter__c(Audience__c = IsIdCard ? 'Agent':'Agency'
                                                                     , Filter_Description__c = 'Preferred Language'
                                                                     , Data_Type__c = 'Text'
                                                                     , Filter_Field__c = 'Preferred_Language__c'
                                                                     , Source__c='Elastic/Salesforce');
        insert af;
        
        System.runAs(usr) {
            initPostRunAs();
            
            Test.setMock(HttpCalloutMock.class, new ET_SendMassMailingSuccess_Mock());
          
            EBC_Master_Filter__c masterFilter = new EBC_Master_Filter__c(Audience__c = 'Custom'
                                                                         , IATA_Codes__c = '111110911;11110912'
                                                                         , Billing_Account__c = oBillingAccount.Id
                                                                         , OwnerId = usr.Id);
            insert masterFilter;
            EBC_Customer_Filter__c cf = new EBC_Customer_Filter__c(EBC_Master_Filter__c = masterFilter.Id
                                                                   , EBC_Application_Filter__c = af.Id
                                                                   , Field_Operator__c = '='
                                                                   , Field_Value__c = 'X0');
            insert cf;
            EBC_Template__c tpl = new EBC_Template__c(Is_Tested__c = true
                                                      , OwnerId = usr.Id);
            insert tpl;
            EBC_Campaign__c camp = new EBC_Campaign__c(Name = 'Foo Bar'
                                                       , Number_of_Recipients__c = 7
                                                       , Subject__c = 'Foo Subject'
                                                       , From_Name__c = 'Foo From Name'
                                                       , Is_Google_Analytics_Tracker_Active__c = true
                                                       , Google_Analytics_Tracking_Code__c = 'UA-XXXXXX'
                                                       , Billing_Account__c = oBillingAccount.Id
                                                       , EBC_Master_Filter__c = masterFilter.Id
                                                       , EBC_Design__c = tpl.Id
                                                       , OwnerId = usr.Id
                                                       , Status__c = 'APPROVED'
                                                       , Send_Datetime__c = Datetime.now());
            insert camp;
            
            AWS_Task__c processlist = new AWS_Task__c();
            processlist.Task_Status__c='SEND TEST EMAILS';
            processlist.Process_Status__c='Not Started';
            processlist.Process_Request__c='';
            processlist.Process_Response__c='';
            processlist.Task_Campaign__c=camp.Id;
            insert processlist;
            
            Test.startTest();
            
            EBC_Master_Filter__c xmasterFilter = [Select Id,
                                               Name,
                                               Audience__c,
                                               Geo_Condition__c,
                                               Refinement_Condition__c,
                                               Billing_Account__c,
                                               IATA_Codes__c,
                                               (
                                                   Select Id,
                                                   Field_Name__c,
                                                   Field_Operator__c,
                                                   Field_Value__c,
                                                   EBC_Application_Filter__r.Filter_Field__c,
                                                   EBC_Application_Filter__r.Search_Level__c,
                                                   EBC_Application_Filter__r.Filter_RelatedList__c,
                                                   EBC_Application_Filter__r.Filter_RelatedList_Field__c
                                                   From EBC_Customer_Filters__r
                                               )
                                               FROM EBC_Master_Filter__c
                                               Where Id=:masterFilter.Id
                                               Limit 1];   
         
            String  custom_query = EBC_Campaign_Elastic.ES_getSOQLFromMasterFilter(xmasterFilter, 'list', '', '1000');
              
            masterFilter.IATA_Codes__c = '';
            masterFilter.Audience__c = 'Agency';
            update masterFilter;
            
            boolean elastic_switch=true;
            String cntQuery = IECEBC_Utility.getSOQLFromMasterFilter(null, camp.EBC_Master_Filter__c, elastic_switch);
            IECEBCNew_eBroadcast_Counter ebcreq = new IECEBCNew_eBroadcast_Counter(); 
            Integer counter=ebcreq.execute(cntQuery,true); 
            
            
            //Initialize Campaign with Amazon process
            RestRequest req = new RestRequest(); 
            RestResponse res = new RestResponse();
            RestContext.response = res;
            req.httpMethod = 'POST';  
            RestContext.request = req;
            req.addHeader('Content-Type', 'application/json');
          
          
            
            EBC_Campaign_InitializeWS.SourceData sourcedata = new EBC_Campaign_InitializeWS.SourceData();
            sourcedata.campaignId=camp.Id;
            sourcedata.elastic_query='';
            sourcedata.Group_Email=0;
            sourcedata.Ids='';
            sourcedata.isAgencyCode=false;
            sourcedata.isFinished=false;
            sourcedata.isDeleted=false;
            sourcedata.Task='';
            sourcedata.isError=WithOrWithException;
            sourcedata.MyException('Ok',new List<AWS_Task__c>{processlist});
            sourcedata.ComposeMessage(null);
            req.requestBody = Blob.valueOf(json.serialize(sourcedata));
            EBC_Campaign_InitializeWS.PostEBC_Campaign_InitializeWS();
      
            //Create Emails 
            RestRequest req1 = new RestRequest(); 
            RestResponse res1 = new RestResponse();
            RestContext.response = res1;
            req1.httpMethod = 'POST';  
            
            req1.addHeader('Content-Type', 'application/json');
          
            processlist.Task_Status__c='COLLECT EMAILS';
            update processlist;
            
            EBC_Campaign_CreateEmailsWS.SourceData sourcedata1 = new EBC_Campaign_CreateEmailsWS.SourceData();
            sourcedata1.campaignId=camp.Id; 
            sourcedata1.Ids='111110911\',\'11110912\',\'11110913\',\'11110914\',\'11110915\',\'11110916\',\'11110917\',\'11110918\',\'11110919\',\'11110910';
            sourcedata1.elastic_query='';
            sourcedata1.Group_Email=0;
            sourcedata1.isAgencyCode=true;
            sourcedata1.isFinished=false;
            sourcedata1.isDeleted=false;
            sourcedata1.Task='';
            sourcedata1.isError=WithOrWithException;
            req1.requestBody = Blob.valueOf(json.serialize(sourcedata1));
            RestContext.request = req1;
           
            EBC_Campaign_CreateEmailsWS.PostEBC_Campaign_CreateEmailsWS();
            sourcedata1.MyException('Ok',new List<AWS_Task__c>{processlist});
            sourcedata1.ComposeMessage(null);

            //Send Emails
            RestRequest req2 = new RestRequest(); 
            RestResponse res2 = new RestResponse();
            RestContext.response = res2;
            req2.httpMethod = 'POST';  
          
            req2.addHeader('Content-Type', 'application/json');
          
            processlist.Task_Status__c='SEND TEST EMAILS';
            update processlist;
            EBC_Campaign_SendEmailsWS.SourceData sourcedata2 = new EBC_Campaign_SendEmailsWS.SourceData();
            sourcedata2.campaignId=camp.Id; 
            sourcedata2.Ids='';
            sourcedata2.elastic_query='';
            sourcedata2.Group_Email=0;
            sourcedata2.isAgencyCode=false;
            sourcedata2.isFinished=false;
            sourcedata2.isDeleted=false;
            sourcedata2.Task='';
            sourcedata2.isError=WithOrWithException;
            req2.requestBody = Blob.valueOf(json.serialize(sourcedata2));
            RestContext.request = req2;
            EBC_Campaign_SendEmailsWS.PostEBC_Campaign_SendEmailsWS();
            sourcedata2.MyException('Ok',new List<AWS_Task__c>{processlist});
            sourcedata2.ComposeMessage(null);
          
            //Delete Emails
            RestRequest req3 = new RestRequest(); 
            RestResponse res3 = new RestResponse();
            RestContext.response = res3;
            req3.httpMethod = 'POST';  
            req3.addHeader('Content-Type', 'application/json');
          
            processlist.Task_Status__c='DELETE EMAILS';
            update processlist;
            EBC_Campaign_DeleteEmailsWS.SourceData sourcedata3 = new EBC_Campaign_DeleteEmailsWS.SourceData();
            sourcedata3.campaignId=camp.Id; 
            sourcedata3.Ids='';
            sourcedata3.elastic_query='';
            sourcedata3.Group_Email=0;
            sourcedata3.isAgencyCode=false;
            sourcedata3.isFinished=false;
            sourcedata3.isDeleted=false;
            sourcedata3.Task='';
            sourcedata3.isError=WithOrWithException;
            req3.requestBody = Blob.valueOf(json.serialize(sourcedata3));
            RestContext.request = req3;
            EBC_Campaign_DeleteEmailsWS.PostEBC_Campaign_DeleteEmailsWS();
            sourcedata3.MyException('Ok',new List<AWS_Task__c>{processlist});
            sourcedata3.ComposeMessage(null);
         
            
            //Finalize Campaign
            RestRequest req4 = new RestRequest(); 
            RestResponse res4 = new RestResponse();
            RestContext.response = res4;
            req4.httpMethod = 'POST';  
            req4.addHeader('Content-Type', 'application/json');
          
            EBC_Campaign_FinishWS.SourceData sourcedata4 = new EBC_Campaign_FinishWS.SourceData();
            sourcedata4.campaignId=camp.Id; 
            sourcedata4.Ids='';
            sourcedata4.elastic_query='';
            sourcedata4.Group_Email=0;
            sourcedata4.isAgencyCode=false;
            sourcedata4.isFinished=false;
            sourcedata4.isDeleted=false;
            sourcedata4.Task='';
            sourcedata4.isError=WithOrWithException;
            req4.requestBody = Blob.valueOf(json.serialize(sourcedata4));
            RestContext.request = req4;
            EBC_Campaign_FinishWS.PostEBC_Campaign_FinishWS();
            sourcedata4.MyException('Ok',new List<AWS_Task__c>{processlist});
            sourcedata4.ComposeMessage(null);
           
            Test.stopTest();
            
        }
    }
    
   
    class ET_SendMassMailingSuccess_Mock implements HttpCalloutMock {
        public HTTPResponse respond(HTTPRequest req) {
            HTTPResponse r = new HTTPResponse();
            
            r.setStatusCode(200);
            return r;
        }
    }
   
}