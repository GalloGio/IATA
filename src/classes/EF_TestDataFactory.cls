public with sharing class EF_TestDataFactory
{

    public static void createBaseData()
    {
        createCustomSettings();

        List <EF_Related_Records__c> locationList = new List <EF_Related_Records__c> ();
        EF_Related_Records__c locationMain = new EF_Related_Records__c(name='Main',
            recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('EF_Related_Records__c', 'Location')
            );
        locationList.add(locationMain);
        for(Integer i=1; i<5; i++)
        {
            EF_Related_Records__c location = new EF_Related_Records__c (name=String.valueOf(i),
                recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('EF_Related_Records__c', 'Location')
                );
            locationList.add(location);
        }

        insert locationList;

        // create iso country
        IATA_ISO_Country__c iso_country = new IATA_ISO_Country__c (
            name='United States',
            ISO_Code__c ='US',
            ISO_Code_Numeric__c=1,
            currencyIsoCode = 'USD');
        insert iso_country;

        //create account
        Account client = new Account(
            Name='Test Account client',
            RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Others'),
            Sector__c = 'IATA Supplier',
            Category__c = 'ANSP',
            EF_type__c = 'E&F Client',
            EF_Status__c = 'Active',
            //EF_SubStatus__c='None',
            EF_SIS_Code__c = 'test',
            EF_SIS_Designator__c = 'te',
            EF_SIS_Code_Verified__c = true,
            EF_Effective_Date__c = Date.today(),
            IATA_ISO_Country__c = iso_country.Id,
            Reason_for_creation__c = 'new client needed'
            );

        insert client;

        //create account
        Account customer = new Account(
            Name='Test Account customer',
            RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account'),
            Sector__c = 'IATA Supplier',
            Category__c = 'ANSP',
            EF_type__c = 'E&F Operator',
            EF_Status__c = 'Active',
            //EF_SubStatus__c='None',
            EF_SIS_Code__c = 'test',
            EF_SIS_Designator__c = 'te',
            EF_SIS_Code_Verified__c = true,
            EF_Effective_Date__c = Date.today(),
            IATA_ISO_Country__c = iso_country.Id,
            Reason_for_creation__c = 'new customer needed'
            );

        insert customer;

        //create contract
        Contract contract = new Contract (
            accountId= client.Id,
            CCF_Number__c= '1',
            Budget_Section__c='aaaa',
            CCF_Amount__c=250000,
            ContractTerm=12,
            EF_Allow_Billing_Agreements__c = 'Allowed',
            EF_Billing_Currency__c = 'USD;QAR',
            EF_Payment_Currency__c = 'USD;QAR',
            EF_Data_Currency__c = 'USD;QAR',
            RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Contract', 'EF_Client_Agreement'),
            StartDate= Date.today(),
            Type__c='Revenue',
            EF_Status__c='Active',
            EF_Admin_Fee__c=10
            );
        insert contract;

        //create location currencies
        EF_Related_Records__c mainLocation = [select Id, Name from EF_Related_Records__c where Name='Main' limit 1];
        EF_Location_Currency__c locCurrency = new EF_Location_Currency__c (
            Contract__c = contract.Id,
            Location_ID__c = mainLocation.Id,
            EF_Billing_Currency__c='QAR'
            );
        insert locCurrency;

        EF_Billing_Agreement__c rel = new EF_Billing_Agreement__c();
        rel.Client__c = client.Id;
        rel.Airline__c = customer.Id;
        rel.Contract__c = contract.Id;
        rel.EF_Location_ID__c =  [select Id, Name from EF_Related_Records__c where Name='Main' limit 1].Id;
        rel.EF_Status__c='Active';
        rel.Data_Currency__c = 'USD';
        rel.Billing_Currency__c = 'USD';
        rel.Payment_Currency__c = 'USD';
        insert rel;

        EF_Billing_Agreement__c rel2 = new EF_Billing_Agreement__c();
        rel2.Client__c = client.Id;
        rel2.Airline__c = customer.Id;
        rel2.Contract__c = contract.Id;
        rel2.EF_Location_ID__c =  [select Id, Name from EF_Related_Records__c where Name='Main' limit 1].Id;
        rel2.EF_Status__c='Active';
        rel2.Data_Currency__c = 'USD';
        rel2.Billing_Currency__c = 'QAR';
        rel2.Payment_Currency__c = 'USD';
        insert rel2;


    }

    public static void createLocationCodes()
    {
        Id locCodeId = RecordTypeSingleton.getInstance().getRecordTypeId('EF_Related_Records__c', 'Location_Code');
        EF_Related_Records__c rr1 = new EF_Related_Records__c(Name='ABC1', Location_Code_Details__c = 'Details 1', RecordTypeId=locCodeId);
        EF_Related_Records__c rr2 = new EF_Related_Records__c(Name='ABC2', Location_Code_Details__c = 'Details 2', RecordTypeId=locCodeId);
        EF_Related_Records__c rr3 = new EF_Related_Records__c(Name='ABC3', Location_Code_Details__c = 'Details 3', RecordTypeId=locCodeId);
        insert new List<EF_Related_Records__c>{rr1, rr2, rr3};
    }

     public static void createBaseDataWithoutLocCurr()
    {
        createCustomSettings();

        List <EF_Related_Records__c> locationList = new List <EF_Related_Records__c> ();
        EF_Related_Records__c locationMain = new EF_Related_Records__c(name='Main',
            recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('EF_Related_Records__c', 'Location')
            );
        locationList.add(locationMain);
        for(Integer i=1; i<5; i++)
        {
            EF_Related_Records__c location = new EF_Related_Records__c (name=String.valueOf(i),
                recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('EF_Related_Records__c', 'Location')
                );
            locationList.add(location);
        }

        insert locationList;

        // create iso country
        IATA_ISO_Country__c iso_country = new IATA_ISO_Country__c (
            name='United States',
            ISO_Code__c ='US',
            ISO_Code_Numeric__c=1,
            currencyIsoCode = 'USD');
        insert iso_country;

        //create account
        Account client2 = new Account(
            Name='Test Account client2',
            RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account'),
            Sector__c = 'IATA Supplier',
            Category__c = 'ANSP',
            EF_type__c = 'E&F Client',
            EF_Status__c = 'Active',
            //EF_SubStatus__c='None',
            EF_SIS_Code__c = 'test',
            EF_SIS_Designator__c = 'te',
            EF_SIS_Code_Verified__c = true,
            EF_Effective_Date__c = Date.today(),
            IATA_ISO_Country__c = iso_country.Id,
            Reason_for_creation__c = 'new client needed'
            );

        insert client2;

        //create account
        Account customer2 = new Account(
            Name='Test Account customer2',
            RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account'),
            Sector__c = 'IATA Supplier',
            Category__c = 'ANSP',
            EF_type__c = 'E&F Operator',
            EF_SIS_Code__c = 'test',
            EF_SIS_Designator__c = 'te',
            EF_SIS_Code_Verified__c = true,
            EF_Status__c = 'Active',
            //EF_SubStatus__c='None',
            EF_Effective_Date__c = Date.today(),
            IATA_ISO_Country__c = iso_country.Id,
            Reason_for_creation__c = 'new customer needed'
            );

        insert customer2;

        //create contract
        Contract contract2 = new Contract (
            accountId= client2.Id,
            CCF_Number__c= '1',
            Budget_Section__c='aaaa',
            CCF_Amount__c=250000,
            ContractTerm=12,
            EF_Allow_Billing_Agreements__c = 'Allowed',
            EF_Payment_Currency__c = 'USD;QAR',
            EF_Data_Currency__c = 'USD;QAR',
            RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Contract', 'EF_Client_Agreement'),
            StartDate= Date.today(),
            Type__c='Revenue',
            EF_Status__c='Active'
            );
        insert contract2;


    }

    public static void createCustomSettings()
    {
        EF_Approve_Fields__c appr1 = new EF_Approve_Fields__c();
        appr1.Billing_Agreement_Fields__c = 'Airline__c,Billing_Currency__c,EF_Location_ID__c,Payment_Currency__c,Payment_Method__c,Location_Code__c,EF_Status__c';
        appr1.Name = 'BillingAgreement';
        EF_Approve_Fields__c appr2 = new EF_Approve_Fields__c();
        appr2.Contract_Fields__c = 'EF_Payment_Terms__c,EF_Billing_Frequency__c,EF_Admin_Fee__c,CCF_Number__c,EF_Group_Code__c';
        appr2.Name = 'Contract';
        List<EF_Approve_Fields__c> approvals = new List<EF_Approve_Fields__c>{appr1, appr2};
        insert approvals;

        EF_Critical_Field_Notification__c cfn = new EF_Critical_Field_Notification__c ();
        cfn.Name='criticalFieldChangesTracking';
        cfn.Account_Airline_Fields__c = 'EF_Status__c,EF_Legacy_Code__c,EF_Airline_ID__c,EF_SIS_Code__c,EF_SIS_Designator__c,EF_SIS_Code_Verified__c';
        cfn.Account_Client_Fields__c='Legal_name__c,EF_SIS_Code__c,EF_SIS_Designator__c,EF_SIS_Code_Verified__c,EF_Status__c';
        cfn.Airline_Billing_Agreement_Fields__c='Bill_To__c,Ship_To__c,Payer__c,Sold_To__c';
        cfn.Contact_Fields__c='EF_Signatory__c,Email,FirstName,LastName,EF_Status__c';
        cfn.Contract_Fields__c='EF_Group_Code__c,EF_Admin_Fee__c,EF_Payment_Terms__c';
        insert cfn;

        EF_Skip_Validations__c skip = new EF_Skip_Validations__c();
        skip.Skip_Validation__c = false;
        insert skip;
    }

    public static void skipContractCreationValidationRule()
    {
        List<EF_Skip_Validations__c> customSettingList = [select Skip_Validation__c from EF_Skip_Validations__c];
        for(EF_Skip_Validations__c cs : customSettingList)
        {
            cs.Skip_Validation__c = true;
        }
        update customSettingList;
    }

    public static User getEfProfileAndRole(Integer profileNumber, Integer roleNumber)
    {
        User myUser = [select id, EF_User_Role__c, ProfileId from User where Id = :UserInfo.getUserId()];
        List<Profile> efProfileIds = [select id from Profile where Name like 'E&F%' order by Name asc];

        User u1 = new User(FirstName='Test1 User',Division='UnitTest',Manager=myUser,
                           EF_Billing_Agreement_Approver__c=myUser.Id,
                           EF_Contract_Approver__c=myUser.Id,
                           License_Cost_Center__c='AAA000AA00',
                           Username='efUnit@test.ch'+roleNumber, LastName='Test1',
                           Email='test1@iata.org', Alias='Test1', CommunityNickname='Test1'+roleNumber,
                           TimeZoneSidKey='Europe/Brussels', LocaleSidKey='en_US',
                           EmailEncodingKey='UTF-8', LanguageLocaleKey='en_US',
                           EF_Client_Reactivation__c=true, EF_Customer_Reactivation__c=true);
        
        if(efProfileIds.size() == 2)
        {
            u1.ProfileId = efProfileIds.get(profileNumber).Id;
        } else
        {
            List<Profile> adminId = [select id from Profile where Name like 'System Administrator' order by Name asc limit 1];
            u1.ProfileId = adminId.get(0).Id;
        }

        Map<Integer, String> roleNumberNameMap = new Map<Integer, String>();
        roleNumberNameMap.put(1,'Manager, Business Development');
        roleNumberNameMap.put(2,'Head, Client Services');
        roleNumberNameMap.put(3,'Manager, Airline Services & Head, Business Delivery');
        roleNumberNameMap.put(4,'Client Services Specialists');
        roleNumberNameMap.put(5,'Airline Services Specialists');
        roleNumberNameMap.put(6,'E&F General Access');
        roleNumberNameMap.put(7,'Manager, Invoicing & Accounting & Data Transformation');

        u1.EF_User_Role__c = roleNumberNameMap.get(roleNumber);
        insert u1;
        return u1;
    }

    public static void createBaseDataWithAllowedWithApproval()
    {
        List <EF_Related_Records__c> locationList = new List <EF_Related_Records__c> ();
        EF_Related_Records__c locationMain = new EF_Related_Records__c(name='Main',
            recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('EF_Related_Records__c', 'Location')
            );
        locationList.add(locationMain);
        for(Integer i=1; i<5; i++)
        {
            EF_Related_Records__c location = new EF_Related_Records__c (name=String.valueOf(i),
                recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('EF_Related_Records__c', 'Location')
                );
            locationList.add(location);
        }

        insert locationList;

        // create iso country
        IATA_ISO_Country__c iso_country = new IATA_ISO_Country__c (
            name='United States',
            ISO_Code__c ='US',
            ISO_Code_Numeric__c=1,
            currencyIsoCode = 'USD');
        insert iso_country;

        //create account
        Account client = new Account(
            Name='Test Account client',
            RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Others'),
            Sector__c = 'IATA Supplier',
            Category__c = 'ANSP',
            EF_type__c = 'E&F Client',
            EF_Status__c = 'Active',
            //EF_SubStatus__c='None',
            EF_SIS_Code__c = 'test',
            EF_SIS_Designator__c = 'te',
            EF_SIS_Code_Verified__c = true,
            EF_Effective_Date__c = Date.today(),
            IATA_ISO_Country__c = iso_country.Id,
            Reason_for_creation__c = 'new client needed'
            );

        insert client;

        //create account
        Account customer = new Account(
            Name='Test Account customer',
            RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'Standard_Account'),
            Sector__c = 'IATA Supplier',
            Category__c = 'ANSP',
            EF_type__c = 'E&F Operator',
            EF_Status__c = 'Active',
            //EF_SubStatus__c='None',
            EF_SIS_Code__c = 'test',
            EF_SIS_Designator__c = 'te',
            EF_SIS_Code_Verified__c = true,
            EF_Effective_Date__c = Date.today(),
            IATA_ISO_Country__c = iso_country.Id,
            Reason_for_creation__c = 'new customer needed'
            );

        insert customer;

        //create contract
        Contract contract = new Contract (
            accountId= client.Id,
            CCF_Number__c= '1',
            Budget_Section__c='aaaa',
            CCF_Amount__c=250000,
            ContractTerm=12,
            EF_Allow_Billing_Agreements__c = 'Allowed with Approval',
            EF_Billing_Currency__c = 'USD;QAR',
            EF_Payment_Currency__c = 'USD;QAR',
            EF_Data_Currency__c = 'USD;QAR',
            RecordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Contract', 'EF_Client_Agreement'),
            StartDate= Date.today(),
            Type__c='Revenue',
            EF_Status__c='Active',
            EF_Admin_Fee__c=10
            );
        insert contract;

        //create location currencies
        EF_Related_Records__c mainLocation = [select Id, Name from EF_Related_Records__c where Name='Main' limit 1];
        EF_Location_Currency__c locCurrency = new EF_Location_Currency__c (
            Contract__c = contract.Id,
            Location_ID__c = mainLocation.Id,
            EF_Billing_Currency__c='QAR'
            );
        insert locCurrency;
    }
    
    public static Product2 createEFProduct(){
        Product2 prod = new Product2 (
            name='EF Product Test',
            Product_Segment__c ='PAX',
            Product_Marketing_Manager__c ='Other / Does not Apply',
            Family ='E&F Services',
            Line_of_Business__c ='T & T');
        
        insert prod;
        return prod;
    }

}