@isTest
private class WorkflowHelperTest {

    @testSetup static void setup(){
        
    }

    @isTest static void  AccountUpdateIndustryTest(){

        Test.startTest();

        IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='Portugal',ISO_Code__c='PT', ANG_Enable_NewGen__c = true)  ;
        insert ctry ;

        IATA_ISO_State__c stt = new IATA_ISO_State__c(Name= 'PORTUGAL', ISO_Code__c = 'PT', IATA_ISO_Country__c = ctry.Id);
        insert stt;

        Id accountRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

        Map<String,Object> fieldsOfObject;

        fieldsOfObject = new Map<String,Object>();
        fieldsOfObject.put('Name','NewGenAgency');
        fieldsOfObject.put('Short_Name__c','NewGenAgency');
        fieldsOfObject.put('Location_Class__c','P');
        fieldsOfObject.put('Location_Type__c','HE');
        fieldsOfObject.put('Remittance_frequency__c','M');
        fieldsOfObject.put('Reason_for_creation__c','Account is missing');
        fieldsOfObject.put('Company_Type__c','A');
        fieldsOfObject.put('Is_AIMS_Account__c',true);
        fieldsOfObject.put('Type','IATA Passenger Sales Agent');

        Account acct = ANG_EntityCreator.createAccount(accountRT, ctry.Id, fieldsOfObject);

        fieldsOfObject = new Map<String,Object>();
        fieldsOfObject.put('Name','NewGenAgencyNoType');
        fieldsOfObject.put('Short_Name__c','NewGenAgency');
        fieldsOfObject.put('Location_Class__c','P');
        fieldsOfObject.put('Location_Type__c','HE');
        fieldsOfObject.put('Remittance_frequency__c','M');
        fieldsOfObject.put('Reason_for_creation__c','Account is missing');
        fieldsOfObject.put('Company_Type__c','A');
        fieldsOfObject.put('Is_AIMS_Account__c',true);

        Account acct2 = ANG_EntityCreator.createAccount(accountRT, ctry.Id, fieldsOfObject);
        
        insert new List<Account>{acct,acct2};

        Test.stopTest();

        acct = [Select Id, Industry, Type from Account where name = 'NewGenAgency'];

        System.assertEquals('Travel Agent',acct.Industry);

        acct = [Select Id, Industry, Type from Account where name = 'NewGenAgencyNoType'];

        System.assertEquals(null,acct.Industry);
    }

    @isTest static void  updateAirlineMembershipTestPositive(){
        Test.startTest();

        IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='Portugal',ISO_Code__c='PT', ANG_Enable_NewGen__c = true)  ;
        insert ctry ;

        IATA_ISO_State__c stt = new IATA_ISO_State__c(Name= 'PORTUGAL', ISO_Code__c = 'PT', IATA_ISO_Country__c = ctry.Id);
        insert stt;

        Id accountRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

        Map<String,Object> fieldsOfObject;

        fieldsOfObject = new Map<String,Object>();
        fieldsOfObject.put('Name','NewGenAgency');
        fieldsOfObject.put('Short_Name__c','NewGenAgencyHE');
        fieldsOfObject.put('Location_Class__c','P');
        fieldsOfObject.put('Location_Type__c','HE');
        fieldsOfObject.put('Remittance_frequency__c','M');
        fieldsOfObject.put('Reason_for_creation__c','Account is missing');
        fieldsOfObject.put('Company_Type__c','A');
        fieldsOfObject.put('Is_AIMS_Account__c',true);
        fieldsOfObject.put('Type','IATA Passenger Sales Agent');
        fieldsOfObject.put('IATA_Member__c',true);

        Account acct = ANG_EntityCreator.createAccount(accountRT, ctry.Id, fieldsOfObject);

        insert acct;

        fieldsOfObject = new Map<String,Object>();
        fieldsOfObject.put('Name','NewGenAgencyAE');
        fieldsOfObject.put('Short_Name__c','NewGenAgency');
        fieldsOfObject.put('Location_Class__c','P');
        fieldsOfObject.put('Location_Type__c','HE');
        fieldsOfObject.put('Remittance_frequency__c','M');
        fieldsOfObject.put('Reason_for_creation__c','Account is missing');
        fieldsOfObject.put('Company_Type__c','A');
        fieldsOfObject.put('Is_AIMS_Account__c',true);
        fieldsOfObject.put('Type','IATA Passenger Sales Agent');
        fieldsOfObject.put('ParentId',acct.Id);

        Account acctAE = ANG_EntityCreator.createAccount(accountRT, ctry.Id, fieldsOfObject);

        insert acctAE;

        Test.stopTest();
    
        acctAE = [Select Id, IATA_Member__c from Account where name = 'NewGenAgencyAE'];

        System.assertEquals(true,acctAE.IATA_Member__c);

        acct.IATA_Member__c = false;
        update acct;

        update acctAE;

        acctAE = [Select Id, IATA_Member__c from Account where name = 'NewGenAgencyAE'];

        System.assertEquals(false,acctAE.IATA_Member__c);

    }

    @isTest static void  updateAirlineMembershipTest(){
        Test.startTest();

        IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='Portugal',ISO_Code__c='PT', ANG_Enable_NewGen__c = true)  ;
        insert ctry ;

        IATA_ISO_State__c stt = new IATA_ISO_State__c(Name= 'PORTUGAL', ISO_Code__c = 'PT', IATA_ISO_Country__c = ctry.Id);
        insert stt;

        Id accountRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

        Map<String,Object> fieldsOfObject;

        fieldsOfObject = new Map<String,Object>();
        fieldsOfObject.put('Name','NewGenAgency');
        fieldsOfObject.put('Short_Name__c','NewGenAgencyHE');
        fieldsOfObject.put('Location_Class__c','P');
        fieldsOfObject.put('Location_Type__c','HE');
        fieldsOfObject.put('Remittance_frequency__c','M');
        fieldsOfObject.put('Reason_for_creation__c','Account is missing');
        fieldsOfObject.put('Company_Type__c','A');
        fieldsOfObject.put('Is_AIMS_Account__c',true);
        fieldsOfObject.put('Type','IATA Passenger Sales Agent');
        fieldsOfObject.put('IATA_Member__c',true);

        Account acct = ANG_EntityCreator.createAccount(accountRT, ctry.Id, fieldsOfObject);

        insert acct;

        fieldsOfObject = new Map<String,Object>();
        fieldsOfObject.put('Name','NewGenAgencyAE');
        fieldsOfObject.put('Short_Name__c','NewGenAgency');
        fieldsOfObject.put('Location_Class__c','P');
        fieldsOfObject.put('Location_Type__c','HE');
        fieldsOfObject.put('Remittance_frequency__c','M');
        fieldsOfObject.put('Reason_for_creation__c','Account is missing');
        fieldsOfObject.put('Company_Type__c','A');
        fieldsOfObject.put('Is_AIMS_Account__c',true);
        fieldsOfObject.put('Type','IATA Passenger Sales Agent');
        fieldsOfObject.put('ParentId',acct.Id);

        Account acctAE = ANG_EntityCreator.createAccount(accountRT, ctry.Id, fieldsOfObject);

        insert acctAE;

        Test.stopTest();
    
        acctAE = [Select Id, IATA_Member__c from Account where name = 'NewGenAgencyAE'];

        System.assertEquals(true,acctAE.IATA_Member__c);

        acct.IATA_Member__c = false;
        update acct;

        update acctAE;

        acctAE = [Select Id, IATA_Member__c from Account where name = 'NewGenAgencyAE'];

        System.assertEquals(false,acctAE.IATA_Member__c);

    }

    @isTest static void  updateLastModifiedDateByIntegrationsTest(){
        Test.startTest();

        IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='Portugal',ISO_Code__c='PT', ANG_Enable_NewGen__c = true)  ;
        insert ctry ;

        IATA_ISO_State__c stt = new IATA_ISO_State__c(Name= 'PORTUGAL', ISO_Code__c = 'PT', IATA_ISO_Country__c = ctry.Id);
        insert stt;

        Id accountRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

        Map<String,Object> fieldsOfObject;

        fieldsOfObject = new Map<String,Object>();
        fieldsOfObject.put('Name','NewGenAgency');
        fieldsOfObject.put('Short_Name__c','NewGenAgency');
        fieldsOfObject.put('Location_Class__c','P');
        fieldsOfObject.put('Location_Type__c','HE');
        fieldsOfObject.put('Remittance_frequency__c','M');
        fieldsOfObject.put('Reason_for_creation__c','Account is missing');
        fieldsOfObject.put('Company_Type__c','A');
        fieldsOfObject.put('Is_AIMS_Account__c',true);
        fieldsOfObject.put('Type','IATA Passenger Sales Agent');

        Account acct = ANG_EntityCreator.createAccount(accountRT, ctry.Id, fieldsOfObject);

        insert acct;

        fieldsOfObject = new Map<String,Object>();
        fieldsOfObject.put('Name','NewGenAgency2');
        fieldsOfObject.put('Short_Name__c','NewGenAgency');
        fieldsOfObject.put('Location_Class__c','P');
        fieldsOfObject.put('Location_Type__c','HE');
        fieldsOfObject.put('Remittance_frequency__c','M');
        fieldsOfObject.put('Reason_for_creation__c','Account is missing');
        fieldsOfObject.put('Company_Type__c','A');
        fieldsOfObject.put('Is_AIMS_Account__c',true);

        Account acct2 = ANG_EntityCreator.createAccount(accountRT, ctry.Id, fieldsOfObject);
        

        // Create a unique UserName
          String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';

        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        User u = new User(
            Alias = 'standt',
            Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8',
            FirstName = 'System',
            LastName='Integrations',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName=uniqueUserName,
            License_Cost_Center__c ='IDS005CH01'
            );

        System.runAs(u) {
            insert acct2;
        }


        Test.stopTest();
    
        acct =  [Select Id, Last_Modified_by_Source__c from Account where name = 'NewGenAgency'];
        acct2 = [Select Id, Last_Modified_by_Source__c from Account where name = 'NewGenAgency2'];

        System.assertEquals(null,acct.Last_Modified_by_Source__c);

        Date date1 = date.newinstance(System.today().year(), System.today().month(), System.today().day());
        Date date2 = date.newinstance(acct2.Last_Modified_by_Source__c.year(), acct2.Last_Modified_by_Source__c.month(), acct2.Last_Modified_by_Source__c.day());

        System.assertEquals(date1,date2);

        System.runAs(u) {
            update acct;
        }

        acct =  [Select Id, Last_Modified_by_Source__c from Account where name = 'NewGenAgency'];
        
        date1 = date.newinstance(System.today().year(), System.today().month(), System.today().day());
        date2 = date.newinstance(acct.Last_Modified_by_Source__c.year(), acct.Last_Modified_by_Source__c.month(), acct.Last_Modified_by_Source__c.day());

        System.assertEquals(date1,date2);

    }

    @isTest static void  updateWebstarAccountCategoryTest(){

        Test.startTest();

        IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='Portugal',ISO_Code__c='PT', ANG_Enable_NewGen__c = true)  ;
        insert ctry ;

        IATA_ISO_State__c stt = new IATA_ISO_State__c(Name= 'PORTUGAL', ISO_Code__c = 'PT', IATA_ISO_Country__c = ctry.Id);
        insert stt;

        Id accountRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

        Map<String,Object> fieldsOfObject;

        fieldsOfObject = new Map<String,Object>();
        fieldsOfObject.put('Name','NewGenAgency');
        fieldsOfObject.put('Short_Name__c','NewGenAgency');
        fieldsOfObject.put('Location_Class__c','P');
        fieldsOfObject.put('Location_Type__c','HE');
        fieldsOfObject.put('Remittance_frequency__c','M');
        fieldsOfObject.put('Reason_for_creation__c','Account is missing');
        fieldsOfObject.put('Company_Type__c','A');
        fieldsOfObject.put('Is_AIMS_Account__c',true);
        fieldsOfObject.put('Source_System__c','webstar');

        Account acct = ANG_EntityCreator.createAccount(accountRT, ctry.Id, fieldsOfObject);

        insert acct;

        Test.stopTest();

        acct =  [Select Id, sector__c, Category__c from Account where name = 'NewGenAgency'];

        System.assertEquals('Travel Agent',acct.sector__c);
        System.assertEquals('IATAN Passenger Agent',acct.Category__c);
        
    }

    @isTest static void  updateAIMSAccountRecordtypeTest(){

        Test.startTest();

        IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='Portugal',ISO_Code__c='PT', ANG_Enable_NewGen__c = true)  ;
        insert ctry ;

        IATA_ISO_State__c stt = new IATA_ISO_State__c(Name= 'PORTUGAL', ISO_Code__c = 'PT', IATA_ISO_Country__c = ctry.Id);
        insert stt;

        Id standardRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');

        Map<String,Object> fieldsOfObject;

        fieldsOfObject = new Map<String,Object>();
        fieldsOfObject.put('Name','NewGenAgency');
        fieldsOfObject.put('Short_Name__c','NewGenAgency');
        fieldsOfObject.put('Location_Class__c','P');
        fieldsOfObject.put('Location_Type__c','HE');
        fieldsOfObject.put('Remittance_frequency__c','M');
        fieldsOfObject.put('Reason_for_creation__c','Account is missing');
        fieldsOfObject.put('Company_Type__c','A');
        fieldsOfObject.put('Is_AIMS_Account__c',true);
        fieldsOfObject.put('Source_System__c','webstar');

        Account acct = ANG_EntityCreator.createAccount(standardRT, ctry.Id, fieldsOfObject);

        insert acct;

        Test.stopTest();

        acct =  [Select Id, recordTypeId from Account where name = 'NewGenAgency'];

        Id accountRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

        System.assertEquals(accountRT,acct.recordTypeId);
        
    }    

    @isTest static void  resetAccountIdCardDiscountTest(){

        Test.startTest();

        IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='Portugal',ISO_Code__c='PT', ANG_Enable_NewGen__c = true)  ;
        insert ctry ;

        IATA_ISO_State__c stt = new IATA_ISO_State__c(Name= 'PORTUGAL', ISO_Code__c = 'PT', IATA_ISO_Country__c = ctry.Id);
        insert stt;

        Id standardRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

        Map<String,Object> fieldsOfObject;

        fieldsOfObject = new Map<String,Object>();
        fieldsOfObject.put('Name','NewGenAgency');
        fieldsOfObject.put('Short_Name__c','NewGenAgency');
        fieldsOfObject.put('Location_Class__c','P');
        fieldsOfObject.put('Location_Type__c','HE');
        fieldsOfObject.put('Remittance_frequency__c','M');
        fieldsOfObject.put('Reason_for_creation__c','Account is missing');
        fieldsOfObject.put('Company_Type__c','A');
        fieldsOfObject.put('ID_Card_Key_Account_Discount__c',50);
        fieldsOfObject.put('IDCard_Key_Account__c',true);

        Account acct = ANG_EntityCreator.createAccount(standardRT, ctry.Id, fieldsOfObject);

        insert acct;

        Test.stopTest();

        acct.IDCard_Key_Account__c = false;
        update acct;

        acct =  [Select Id, ID_Card_Key_Account_Discount__c from Account where name = 'NewGenAgency'];

        System.assertEquals(0,acct.ID_Card_Key_Account_Discount__c);
        
    }    
    
    @isTest static void resetAccountTypeTest(){

        Test.startTest();

        IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='Portugal',ISO_Code__c='PT', ANG_Enable_NewGen__c = true)  ;
        insert ctry ;

        IATA_ISO_State__c stt = new IATA_ISO_State__c(Name= 'PORTUGAL', ISO_Code__c = 'PT', IATA_ISO_Country__c = ctry.Id);
        insert stt;

        ID airLineRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline') ;

        Map<String,Object> fieldsOfObject;

        fieldsOfObject = new Map<String,Object>();
        fieldsOfObject.put('Name','NewGenAgency');
        fieldsOfObject.put('Short_Name__c','NewGenAgency');
        fieldsOfObject.put('Location_Class__c','P');
        fieldsOfObject.put('Location_Type__c','HE');
        fieldsOfObject.put('Remittance_frequency__c','M');
        fieldsOfObject.put('Reason_for_creation__c','Account is missing');
        fieldsOfObject.put('Company_Type__c','A');
        fieldsOfObject.put('Sector__c','Airline');
        fieldsOfObject.put('ACLI_Status__c','Active Company');
        fieldsOfObject.put('Account_Type__c','Not Applicable');

        Account acct = ANG_EntityCreator.createAccount(airLineRT, ctry.Id, fieldsOfObject);

        fieldsOfObject = new Map<String,Object>();
        fieldsOfObject.put('Name','NewGenAgency2');
        fieldsOfObject.put('Short_Name__c','NewGenAgency');
        fieldsOfObject.put('Location_Class__c','P');
        fieldsOfObject.put('Location_Type__c','HE');
        fieldsOfObject.put('Remittance_frequency__c','M');
        fieldsOfObject.put('Reason_for_creation__c','Account is missing');
        fieldsOfObject.put('Company_Type__c','A');
        fieldsOfObject.put('Sector__c','Airline');
        fieldsOfObject.put('ACLI_Status__c','Active Company');
        fieldsOfObject.put('Account_Type__c','Not Applicable');
        fieldsOfObject.put('Membership_status__c','IATA member');

        Account acct2 = ANG_EntityCreator.createAccount(airLineRT, ctry.Id, fieldsOfObject);

        insert new List<Account>{acct,acct2};

        Test.stopTest();

        acct =  [Select Id, Account_Type__c from Account where name = 'NewGenAgency'];

        System.assertEquals(null,acct.Account_Type__c);

        acct2 =  [Select Id, Account_Type__c from Account where name = 'NewGenAgency2'];

        System.assertEquals('Not Applicable',acct2.Account_Type__c);

    }


    @isTest static void restoreAccountTypeTest(){

        Test.startTest();

        IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='Portugal',ISO_Code__c='PT', ANG_Enable_NewGen__c = true)  ;
        insert ctry ;

        IATA_ISO_State__c stt = new IATA_ISO_State__c(Name= 'PORTUGAL', ISO_Code__c = 'PT', IATA_ISO_Country__c = ctry.Id);
        insert stt;

        ID airLineRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline') ;

        Map<String,Object> fieldsOfObject;

        fieldsOfObject = new Map<String,Object>();
        fieldsOfObject.put('Name','NewGenAgency');
        fieldsOfObject.put('Short_Name__c','NewGenAgency');
        fieldsOfObject.put('Location_Class__c','P');
        fieldsOfObject.put('Location_Type__c','HE');
        fieldsOfObject.put('Remittance_frequency__c','M');
        fieldsOfObject.put('Reason_for_creation__c','Account is missing');
        fieldsOfObject.put('Company_Type__c','A');
        fieldsOfObject.put('Sector__c','Airline');
        fieldsOfObject.put('ACLI_Status__c','Active Company');
        fieldsOfObject.put('Membership_status__c','IATA member');

        Account acct = ANG_EntityCreator.createAccount(airLineRT, ctry.Id, fieldsOfObject);

        insert new List<Account>{acct};

        Test.stopTest();

        acct =  [Select Id,Sector__c,Membership_status__c,ACLI_Status__c,Account_Type__c from Account where name = 'NewGenAgency'];

        system.debug('dudu account is:'+acct);

        System.assertEquals('Not Applicable',acct.Account_Type__c);


    }

    @isTest static void setAccountSiteTest(){

        Test.startTest();

        IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='Portugal',ISO_Code__c='PT', ANG_Enable_NewGen__c = true)  ;
        insert ctry ;

        IATA_ISO_State__c stt = new IATA_ISO_State__c(Name= 'PORTUGAL', ISO_Code__c = 'PT', IATA_ISO_Country__c = ctry.Id);
        insert stt;

        Id standardRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account');
        ID airLineRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline') ;

        Map<String,Object> fieldsOfObject;

        fieldsOfObject = new Map<String,Object>();
        fieldsOfObject.put('Name','NewGenAgency');
        fieldsOfObject.put('Short_Name__c','NewGenAgency');
        fieldsOfObject.put('Location_Class__c','P');
        fieldsOfObject.put('Location_Type__c','HE');
        fieldsOfObject.put('Remittance_frequency__c','M');
        fieldsOfObject.put('Reason_for_creation__c','Created by customer');
        fieldsOfObject.put('Company_Type__c','A');
        fieldsOfObject.put('Industry','Travel Agent');
        fieldsOfObject.put('Site','Site');
        fieldsOfObject.put('Sector__c','Travel Agent');
        
        Account acct = ANG_EntityCreator.createAccount(airLineRT, ctry.Id, fieldsOfObject);

        fieldsOfObject = new Map<String,Object>();
        fieldsOfObject.put('Name','NewGenAgency2');
        fieldsOfObject.put('Short_Name__c','NewGenAgency2');
        fieldsOfObject.put('Location_Class__c','P');
        fieldsOfObject.put('Location_Type__c','HE');
        fieldsOfObject.put('Remittance_frequency__c','M');
        fieldsOfObject.put('Reason_for_creation__c','Created by customer');
        fieldsOfObject.put('Airline_designator__c','1234');
        fieldsOfObject.put('IATACode__c','1234567');
        fieldsOfObject.put('Industry','Travel Agent');
        fieldsOfObject.put('Site','Site');
        fieldsOfObject.put('Sector__c','Airline');

        Account acct2 = ANG_EntityCreator.createAccount(standardRT, ctry.Id, fieldsOfObject);
            
        insert new List<Account>{acct,acct2};

        Test.stopTest();

        acct =   [Select Id,Industry,Site,Airline_designator__c,IATACode__c, IATA_ISO_Country__r.ISO_Code__c from Account where name = 'NewGenAgency'];
        acct2 =  [Select Id,Industry,Site,Airline_designator__c,IATACode__c, IATA_ISO_Country__r.ISO_Code__c from Account where name = 'NewGenAgency2'];

        System.assertEquals('Site',acct.site);
        System.assertEquals('1234 1234567 PT',acct2.site);

    }

    @isTest static void setDataQualityHistoryTest(){

        Test.startTest();

        IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='Portugal',ISO_Code__c='PT', ANG_Enable_NewGen__c = true)  ;
        insert ctry ;

        IATA_ISO_State__c stt = new IATA_ISO_State__c(Name= 'PORTUGAL', ISO_Code__c = 'PT', IATA_ISO_Country__c = ctry.Id);
        insert stt;

        ID airLineRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline') ;

        Map<String,Object> fieldsOfObject;

        fieldsOfObject = new Map<String,Object>();
        fieldsOfObject.put('Name','NewGenAgency');
        fieldsOfObject.put('Short_Name__c','NewGenAgency');
        fieldsOfObject.put('Location_Class__c','P');
        fieldsOfObject.put('Location_Type__c','HE');
        fieldsOfObject.put('Remittance_frequency__c','M');
        fieldsOfObject.put('Reason_for_creation__c','Created by customer');
        fieldsOfObject.put('Company_Type__c','A');
        fieldsOfObject.put('Industry','Travel Agent');

        Account acct = ANG_EntityCreator.createAccount(airLineRT, ctry.Id, fieldsOfObject);

        insert new List<Account>{acct};

        Test.stopTest();

        acct =   [Select Id,Data_quality_history__c from Account where name = 'NewGenAgency'];

        System.assertEquals(null, acct.Data_quality_history__c);

        acct.Comment_data_quality_feedback__c = 'XPTO';
        update acct;

        acct =   [Select Id,Data_quality_history__c from Account where name = 'NewGenAgency'];

        String formattedDate = System.now().format('YYYY-MM-dd');

        System.assertEquals(formattedDate+': XPTO', acct.Data_quality_history__c);
    }

    @isTest static void  updateAirlineTradeNameParentTest(){

        Test.startTest();

        IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='Portugal',ISO_Code__c='PT', ANG_Enable_NewGen__c = true)  ;
        insert ctry ;

        IATA_ISO_State__c stt = new IATA_ISO_State__c(Name= 'PORTUGAL', ISO_Code__c = 'PT', IATA_ISO_Country__c = ctry.Id);
        insert stt;

        ID airLineRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline') ;

        Map<String,Object> fieldsOfObject;

        fieldsOfObject = new Map<String,Object>();
        fieldsOfObject.put('Name','NewGenAgency');
        fieldsOfObject.put('Short_Name__c','NewGenAgencyHE');
        fieldsOfObject.put('Location_Class__c','P');
        fieldsOfObject.put('Location_Type__c','HE');
        fieldsOfObject.put('Remittance_frequency__c','M');
        fieldsOfObject.put('Reason_for_creation__c','Account is missing');
        fieldsOfObject.put('Company_Type__c','A');
        fieldsOfObject.put('Type','IATA Passenger Sales Agent');
        fieldsOfObject.put('IATA_Member__c',true);
        fieldsOfObject.put('TradeName__c','tradenameParent');

        Account acct = ANG_EntityCreator.createAccount(airLineRT, ctry.Id, fieldsOfObject);

        insert acct;

        fieldsOfObject = new Map<String,Object>();
        fieldsOfObject.put('Name','NewGenAgencyAE');
        fieldsOfObject.put('Short_Name__c','NewGenAgency');
        fieldsOfObject.put('Location_Class__c','P');
        fieldsOfObject.put('Location_Type__c','AE');
        fieldsOfObject.put('Remittance_frequency__c','M');
        fieldsOfObject.put('Reason_for_creation__c','Account is missing');
        fieldsOfObject.put('Company_Type__c','A');
        fieldsOfObject.put('Type','IATA Passenger Sales Agent');
        fieldsOfObject.put('ParentId',acct.Id);
        fieldsOfObject.put('TradeName__c','AE Trade Name');

        Account acctAE = ANG_EntityCreator.createAccount(AMS_Utils.RECTYPE_AIRLINE_BR, ctry.Id, fieldsOfObject);

        insert acctAE;

        Test.stopTest();
    
        acctAE = [Select Id, TradeName__c, name from Account where location_type__c = 'AE'];

        System.assertEquals('tradenameParent',acctAE.TradeName__c);
        System.assertEquals('tradenameParent',acctAE.name);

        acct.TradeName__c = 'NewTradeNameParent';        
        acctAE.TradeName__c = 'XPTO';


        Profile p = [SELECT Id FROM Profile WHERE Name='Account management team'];
        
        User u = [Select id from User where ProfileId = :p.Id LIMIT 1];

        System.runAs(u) {
            
            update new List<Account>{acct,acctAE};
        }

        acctAE = [Select Id, TradeName__c, name from Account where location_type__c = 'AE'];

        System.assertEquals('NewTradeNameParent',acctAE.name);

    }


    @isTest static void setAccountDDSUpdateDateTest(){

        Test.startTest();

        IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='Portugal',ISO_Code__c='PT', ANG_Enable_NewGen__c = true)  ;
        insert ctry ;

        IATA_ISO_State__c stt = new IATA_ISO_State__c(Name= 'PORTUGAL', ISO_Code__c = 'PT', IATA_ISO_Country__c = ctry.Id);
        insert stt;

        ID airLineRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline') ;

        Map<String,Object> fieldsOfObject;

        fieldsOfObject = new Map<String,Object>();
        fieldsOfObject.put('Name','NewGenAgency');
        fieldsOfObject.put('Short_Name__c','NewGenAgency');
        fieldsOfObject.put('Location_Class__c','P');
        fieldsOfObject.put('Location_Type__c','HE');
        fieldsOfObject.put('Remittance_frequency__c','M');
        fieldsOfObject.put('Reason_for_creation__c','Created by customer');
        fieldsOfObject.put('Company_Type__c','A');
        fieldsOfObject.put('Industry','Travel Agent');
        fieldsOfObject.put('DDS_Status__c','No Reply');

        Account acct = ANG_EntityCreator.createAccount(airLineRT, ctry.Id, fieldsOfObject);

        insert new List<Account>{acct};

        Test.stopTest();

        acct =   [Select Id,DDS_Last_Update_Date__c from Account where name = 'NewGenAgency'];

        System.assertEquals(null,acct.DDS_Last_Update_Date__c);

        acct.DDS_Status__c = 'multinational';
        update acct;

        acct =   [Select Id,DDS_Last_Update_Date__c from Account where name = 'NewGenAgency'];
        
        Date date1 = date.newinstance(System.today().year(), System.today().month(), System.today().day());
        Date date2 = date.newinstance(acct.DDS_Last_Update_Date__c.year(), acct.DDS_Last_Update_Date__c.month(), acct.DDS_Last_Update_Date__c.day());

        System.assertEquals(date1,date2);

    }

    @isTest static void setACLIAccountNameTest(){

        // Create a unique UserName
        String uniqueUserName = 'standarduser' + DateTime.now().getTime() + '@testorg.com';
        
        // This code runs as the system user
        Profile p = [SELECT Id FROM Profile WHERE Name='System Administrator'];
        
        User u = new User(
            Alias = 'standt',
            Email='standarduser@testorg.com',
            EmailEncodingKey='UTF-8',
            FirstName = 'System',
            LastName='Integrations',
            LanguageLocaleKey='en_US',
            LocaleSidKey='en_US',
            ProfileId = p.Id,
            TimeZoneSidKey='America/Los_Angeles',
            UserName=uniqueUserName,
            License_Cost_Center__c ='IDS005CH01'
            );
        
        insert u;

        PermissionSet ps = [SELECT Id FROM PermissionSet WHERE Name = 'Airline_HQ_ACLI'];
        insert new PermissionSetAssignment(AssigneeId = u.id, PermissionSetId = ps.Id);
        
        Test.startTest();

        System.runAs(u) {
            
        IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='Portugal',ISO_Code__c='PT', ANG_Enable_NewGen__c = true)  ;
        insert ctry ;

        IATA_ISO_State__c stt = new IATA_ISO_State__c(Name= 'PORTUGAL', ISO_Code__c = 'PT', IATA_ISO_Country__c = ctry.Id);
        insert stt;

        ID airLineRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline') ;

        Map<String,Object> fieldsOfObject;

        fieldsOfObject = new Map<String,Object>();
        fieldsOfObject.put('Name','NewGenAgency');
        fieldsOfObject.put('Short_Name__c','NewGenAgency');
        fieldsOfObject.put('Location_Class__c','P');
        fieldsOfObject.put('Location_Type__c','HE');
        fieldsOfObject.put('Remittance_frequency__c','M');
        fieldsOfObject.put('Reason_for_creation__c','Created by customer');
        fieldsOfObject.put('Company_Type__c','A');
        fieldsOfObject.put('Name_on_AOC__c','NEWNAME');

        Account acct = ANG_EntityCreator.createAccount(airLineRT, ctry.Id, fieldsOfObject);

        insert new List<Account>{acct};

        Test.stopTest();

        acct =   [Select Id,Name from Account];

        System.assertEquals('NEWNAME', acct.Name);

        acct.Name_on_AOC__c = null;
        acct.Legal_name__c  = 'OLDNAME';


        update acct;
            
        acct =   [Select Id,Name from Account];

        System.assertEquals('OLDNAME', acct.Name);
        
        }


    }
}