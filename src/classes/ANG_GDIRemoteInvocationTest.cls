@isTest
public class ANG_GDIRemoteInvocationTest {

    public static void testSetup(String OpportunityCurrency, boolean forceException){

        Financial_Institution__c fi = new Financial_Institution__c(name= 'GDI - Euler Hermes', Region__c = 'Europe', Country__c = 'Portugal', Institution_Type__c = 'Insurance Company');
        insert fi;

        IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US', ANG_Enable_NewGen__c = true);
        insert ctry;

        Product2 prod = new Product2(Name = 'Test', IsActive = true);
        insert prod;

        /*using this instead of Test.getStandardPricebookId() will throw  STANDARD_PRICE_NOT_DEFINED
        pricebook2 pb = new pricebook2(name = 'NewGen Generic', IsActive = true);
        insert pb;*/

        ID standardPBID = Test.getStandardPricebookId();
        insert new pricebookentry(UnitPrice = 20, CurrencyIsoCode = 'USD', Product2id = prod.id, IsActive = true, Pricebook2Id = standardPBID);
        if(OpportunityCurrency!='USD')  insert new pricebookentry(UnitPrice = 20, CurrencyIsoCode = OpportunityCurrency, Product2id = prod.id, IsActive = true, Pricebook2Id = standardPBID);


        Account acc = new Account(name = 'account name', Sector__c = 'Travel Agent', Category__c = 'Cargo only', IATACode__c = '1234567',
            Location_Type__c =AMS_Utils.HE, Location_Class__c = AMS_Utils.LC_PASSENGER, recordtypeid = AMS_Utils.RECTYPE_IATAAGENCY, IATA_ISO_Country__c = ctry.id );
        insert acc;


        AMS_OSCAR__c oscar = new AMS_OSCAR__c(STEP1__c = 'In Progress', Account__c = acc.id,Change_effective_as_of__c = Date.today(), Process__c = AMS_Utils.NGGDI);
        insert oscar;

        Contact contact = new Contact(AccountId = acc.id, Firstname = 'teste1', Lastname='test1', Phone = '911111111', MobilePhone = '911111111', Email = 'test@test.com', Financial_Assessment_Contact__c = false);
        insert contact;

        Case oscarCase = new Case(Oscar__c = oscar.Id, RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication'));
        oscarCase.AccountId = acc.Id;
        oscarCase.ContactId = contact.Id;
        insert oscarCase;

        if(forceException) oscar.Oscar_Communication_Case_Id__c = 'fakeID';
        else               oscar.Oscar_Communication_Case_Id__c = oscarCase.id;
        update oscar;

        case cc = new case(AccountId = acc.Id);
        insert cc;
        Financial_Security__c FS = new Financial_Security__c(CURRENCYISOCODE='USD', Account__c=acc.Id, AMOUNT__C=3000, EXPIRY_DATE__C=system.Today().AddDays(100), FINANCIAL_INSTITUTION__c=fi.Id, SECURITY_STATUS__C='Active', Security_Type__c='GDI', Region__c ='Europe', Reception_Date__c=system.today(), Reasonforrequest__c='New Application', Reception_Case__c=cc.Id);
        insert FS;

        ID oppRecordtype = RecordTypeSingleton.getInstance().getRecordTypeId('Opportunity', 'GDI_FinancialSecurity'); 
        Opportunity opp = new Opportunity(AccountId = acc.id, CloseDate = Date.today(), CurrencyIsoCode = OpportunityCurrency, Name ='OPP - ' , RecordTypeId = oppRecordtype, StageName = 'Pending', Related_Oscar__c = oscar.id, GDI_Offer_Id__c='001');
        insert opp;
    }

    @isTest
    public static void testAccountNotFound(){
        testSetup('USD',false);
        test.startTest();

        Remote_Invocation__c ri = new Remote_Invocation__c(Internal_ID__c = 'xxxxx', Source__c='GDI',
                                                           RecordTypeId = RemoteInvocationTriggerHandler.RECTYPE_GDI,
                                                            Integration_Transaction_ID__c = 'idFromMulesoft', Request_Type__c = RemoteInvocationTriggerHandler.NEWGEN_GDI_ENDO,
                                                            status__c = RemoteInvocationTriggerHandler.REMOTE_INVOCATION_STATUS_INITIALIZING);
        
        insert ri;

        Remote_Invocation_Artefact__c artifact = new Remote_Invocation_Artefact__c(Remote_Invocation__c = ri.id, Internal_ID__c = 'xxxxx', External_ID__c='001', Valid_From__c=system.Today(), AMOUNT__C = 1000);
        insert artifact;
        
        ri.Status__c = RemoteInvocationTriggerHandler.REMOTE_INVOCATION_STATUS_PROGRESS;
        update ri;

        system.assertEquals('Failed', [select Status__c from Remote_Invocation__c limit 1].get(0).Status__c);
        System.assertEquals([SELECT id FROM Opportunitylineitem].size(), 0); 
        test.StopTest();
    }

    @isTest
    public static void testInvalidRequestType(){
        testSetup('USD',false);
        test.startTest();

        Remote_Invocation__c ri = new Remote_Invocation__c(Internal_ID__c = '1234567', Source__c='IEP',
                                                           RecordTypeId = RemoteInvocationTriggerHandler.RECTYPE_GDI,
                                                            Integration_Transaction_ID__c = 'idFromMulesoft', Request_Type__c = RemoteInvocationTriggerHandler.NEWGEN_GDI_ENDO,
                                                            status__c = RemoteInvocationTriggerHandler.REMOTE_INVOCATION_STATUS_INITIALIZING);
        
        insert ri;

        Remote_Invocation_Artefact__c artifact = new Remote_Invocation_Artefact__c(Remote_Invocation__c = ri.id, Internal_ID__c = '1234567', External_ID__c='001', Valid_From__c=system.Today(), AMOUNT__C = 1000);
        insert artifact;
        
        ri.Status__c = RemoteInvocationTriggerHandler.REMOTE_INVOCATION_STATUS_PROGRESS;
        update ri;

        system.assertEquals('Failed', [select Status__c from Remote_Invocation__c limit 1].get(0).Status__c);
        System.assertEquals([SELECT id FROM Opportunitylineitem].size(), 0); 
        test.StopTest();
    }

    @isTest
    public static void testMissingMandatoryFields(){
        testSetup('USD',false);
        test.startTest();

        Remote_Invocation__c ri = new Remote_Invocation__c(Internal_ID__c = '1234567', Source__c='GDI',
                                                           RecordTypeId = RemoteInvocationTriggerHandler.RECTYPE_GDI,
                                                            Integration_Transaction_ID__c = 'idFromMulesoft', Request_Type__c = RemoteInvocationTriggerHandler.NEWGEN_GDI_ENDO,
                                                            status__c = RemoteInvocationTriggerHandler.REMOTE_INVOCATION_STATUS_INITIALIZING);
        
        insert ri;

        Remote_Invocation_Artefact__c artifact = new Remote_Invocation_Artefact__c(Remote_Invocation__c = ri.id, Internal_ID__c = '1234567', External_ID__c='001');
        insert artifact;
        
        ri.Status__c = RemoteInvocationTriggerHandler.REMOTE_INVOCATION_STATUS_PROGRESS;
        update ri;

        system.assertEquals('Failed', [select Request_Result__c from Remote_Invocation_Artefact__c limit 1].get(0).Request_Result__c);
        System.assertEquals([SELECT id FROM Opportunitylineitem].size(), 0); 
        test.StopTest();
    }

    @isTest
    public static void testCreatingStagingFS() {

        testSetup('USD',false);

        test.startTest();
        Remote_Invocation__c ri = new Remote_Invocation__c(Internal_ID__c = '1234567', Source__c='GDI',
                                                           RecordTypeId = RemoteInvocationTriggerHandler.RECTYPE_GDI,
                                                            Integration_Transaction_ID__c = 'idFromMulesoft', Request_Type__c = RemoteInvocationTriggerHandler.NEWGEN_GDI_ENDO,
                                                            status__c = RemoteInvocationTriggerHandler.REMOTE_INVOCATION_STATUS_INITIALIZING);
        
        insert ri;

        Remote_Invocation_Artefact__c artifact = new Remote_Invocation_Artefact__c(Remote_Invocation__c = ri.id, Internal_ID__c = '1234567', External_ID__c='001', Valid_From__c=system.Today(), AMOUNT__C = 1000);
        insert artifact;

        //Making the process starting to create the Bank Account Case OSCAR 
        ri.Status__c = RemoteInvocationTriggerHandler.REMOTE_INVOCATION_STATUS_PROGRESS;
        update ri;

        system.debug('DTULLO 072 --> ' + [select id, status__c, status_detail__c from Remote_Invocation__c]);
        system.debug('DTULLO 073 --> ' + [select id, Request_Result__c, status_detail__c from Remote_Invocation_Artefact__c]);

        List<Opportunitylineitem> stagingFSs = [SELECT id FROM Opportunitylineitem];        
        System.assertEquals(stagingFSs.size(), 1); 
    }   

    @isTest
    public static void testConfirmOpportunityCurrencyChanged() {

        testSetup('EUR',false);

        Remote_Invocation__c ri = new Remote_Invocation__c(Internal_ID__c = '1234567',  Source__c='GDI',
            Integration_Transaction_ID__c = 'idFromMulesoft', Request_Type__c = RemoteInvocationTriggerHandler.NEWGEN_GDI_ENDO,
            status__c = RemoteInvocationTriggerHandler.REMOTE_INVOCATION_STATUS_INITIALIZING, currencyisoCode = 'USD');
        
        insert ri;

        Remote_Invocation_Artefact__c artifact = new Remote_Invocation_Artefact__c(Remote_Invocation__c = ri.id, Internal_ID__c = '1234567', External_ID__c='001', Valid_From__c=system.Today(), AMOUNT__C = 1000);
        insert artifact;

        //Making the process starting to create the Bank Account Case OSCAR 
        ri.Status__c = RemoteInvocationTriggerHandler.REMOTE_INVOCATION_STATUS_PROGRESS;
        update ri;

        system.debug('DTULLO 097 --> ' + [select id, status__c, status_detail__c from Remote_Invocation__c]);
        system.debug('DTULLO 098 --> ' + [select id, Request_Result__c, status_detail__c from Remote_Invocation_Artefact__c]);

        List<Opportunitylineitem> stagingFSs = [SELECT id FROM Opportunitylineitem];        
        System.assertEquals(stagingFSs.size(), 1); 

        List<Opportunity> Opportunities = [SELECT id,CurrencyIsoCode FROM Opportunity];     
        System.assertEquals(Opportunities.size(), 1); 
        System.assertEquals(Opportunities[0].CurrencyIsoCode, 'USD'); 
    }   

    @isTest
    public static void testNoMatchForIATACodeProvider() {

        testSetup('EUR',false);

        Remote_Invocation__c ri = new Remote_Invocation__c(Internal_ID__c = '1111111',  Source__c='GDI',
            Integration_Transaction_ID__c = 'idFromMulesoft', Request_Type__c = RemoteInvocationTriggerHandler.NEWGEN_GDI_ENDO,
            status__c = RemoteInvocationTriggerHandler.REMOTE_INVOCATION_STATUS_INITIALIZING, currencyisoCode = 'USD');
        
        insert ri;

        Remote_Invocation_Artefact__c artifact = new Remote_Invocation_Artefact__c(Remote_Invocation__c = ri.id, Internal_ID__c = '1111111', External_ID__c='001', Valid_From__c=system.Today(), AMOUNT__C = 1000);
        insert artifact;

        //Making the process starting to create the Bank Account Case OSCAR 
        ri.Status__c = RemoteInvocationTriggerHandler.REMOTE_INVOCATION_STATUS_PROGRESS;
        try{
            update ri;
        }catch(Exception e){
            ri.addError('The Remote invocation does not have a match for the IATA Code provided (\'1111111\') invocation artifact. [Id:'+ri.Id+'].');
        }

        List<Opportunitylineitem> stagingFSs = [SELECT id FROM Opportunitylineitem];        
        System.assertEquals(stagingFSs.size(), 0); 

    }   

    @isTest
    public static void testNoArtifactProvider() {

        testSetup('EUR',false);

        Remote_Invocation__c ri = new Remote_Invocation__c(Internal_ID__c = '1111111',  Source__c='GDI',
            Integration_Transaction_ID__c = 'idFromMulesoft', Request_Type__c = RemoteInvocationTriggerHandler.NEWGEN_GDI_ENDO,
            status__c = RemoteInvocationTriggerHandler.REMOTE_INVOCATION_STATUS_INITIALIZING, currencyisoCode = 'USD');
        
        insert ri;
        
        /*not inserting the artifact
        Remote_Invocation_Artefact__c artifact = new Remote_Invocation_Artefact__c(Remote_Invocation__c = ri.id, Internal_ID__c = '1111111');
        insert artifact;*/

        //Making the process starting to create the Bank Account Case OSCAR 
        ri.Status__c = RemoteInvocationTriggerHandler.REMOTE_INVOCATION_STATUS_PROGRESS;
        try{
            update ri;
        }catch(Exception e){
            ri.addError('The Remote invocation does not have a match for a remote invocation artifact. [Id:'+ri.Id+'].');
        }

        List<Opportunitylineitem> stagingFSs = [SELECT id FROM Opportunitylineitem];        
        System.assertEquals(stagingFSs.size(), 0); 

    }   

    @isTest
    public static void testvalidateException() {

        testSetup('EUR',true);

        Remote_Invocation__c ri = new Remote_Invocation__c(Internal_ID__c = '1234567',  Source__c='GDI',
            Integration_Transaction_ID__c = 'idFromMulesoft', Request_Type__c = RemoteInvocationTriggerHandler.NEWGEN_GDI_ENDO,
            status__c = RemoteInvocationTriggerHandler.REMOTE_INVOCATION_STATUS_INITIALIZING, currencyisoCode = 'USD');
        
        insert ri;
        
        Remote_Invocation_Artefact__c artifact = new Remote_Invocation_Artefact__c(Remote_Invocation__c = ri.id, Internal_ID__c = '1234567', External_ID__c='001', Valid_From__c=system.Today(), AMOUNT__C = 1000);
        insert artifact;

        //Making the process starting to create the Bank Account Case OSCAR 
        ri.Status__c = RemoteInvocationTriggerHandler.REMOTE_INVOCATION_STATUS_PROGRESS;
        try{
            update ri;
        }catch(Exception e){
            ri.addError('Unable to create staging are for the certificate of endorsment [Id:'+ri.Id+'].');
        }

        List<Opportunitylineitem> stagingFSs = [SELECT id FROM Opportunitylineitem];        
        System.assertEquals(stagingFSs.size(), 0); 

    }   

}