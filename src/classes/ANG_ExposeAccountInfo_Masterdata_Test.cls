@isTest
public class ANG_ExposeAccountInfo_Masterdata_Test {
    
    @testSetup static void setup() {
                
        Portal_Applications__c pa = new Portal_Applications__c (Name='TEST');
        insert pa;

        IATA_ISO_Country__c ctry = new IATA_ISO_Country__c (Name='US',ISO_Code__c='US', ANG_Enable_NewGen__c = true, ISO_Code_Numeric__c = 445, BSP_Country_free_text__c = 'test', ANG_Portal_Service__c = pa.Id)  ;
        insert ctry ;

        IATA_ISO_State__c stt = new IATA_ISO_State__c(Name= 'Test', ISO_Code__c = 'TS', IATA_ISO_Country__c = ctry.Id);
        insert stt;
        
        Id accountAgencyRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
        Id aaRT = RecordTypeSingleton.getInstance().getRecordTypeId('Agency_Authorization__c', 'BSPLink');
        
        Account accountGE = new Account();
        accountGE.Name = 'Main HE Account H1';
        accountGE.Sector__c = 'Travel Agent';
        accountGE.IATACode__c = '43215678';
        accountGE.Category__c = 'IATA Passenger Sales Agent';
        accountGE.Location_Class__c = 'P';
        accountGE.Location_Type__c = 'GE';
        accountGE.ANG_Accreditation_Model__c = 'Cashless';
        accountGE.IATA_ISO_Country__c = ctry.Id;
        accountGE.RecordTypeId = accountAgencyRT;
        accountGE.GDI_Status__c = 'Open';
        accountGE.Purge_Flag__c = false;
        accountGE.Date_Organisation_Status_attained__c = date.today();
        accountGE.Accreditation_date__c = date.today();
        accountGE.Default_date__c = date.today();
        
        insert accountGE;

        Account account = new Account();
        account.Name = 'Main HE Account H1';
        account.Sector__c = 'Travel Agent';
        account.IATACode__c = '12345678';
        account.Category__c = 'IATA Passenger Sales Agent';
        account.Location_Class__c = 'P';
        account.Location_Type__c = 'HE';
        account.ANG_Accreditation_Model__c = 'Cashless';
        account.IATA_ISO_Country__c = ctry.Id;
        account.RecordTypeId = accountAgencyRT;
        account.GDI_Status__c = 'Open';
        account.parentId = accountGE.Id;
        account.Top_Parent__c = accountGE.Id;
        account.Purge_Flag__c = false;
        account.Date_Organisation_Status_attained__c = date.today();
        account.Accreditation_date__c = date.today();
        account.Default_date__c = date.today();
        account.Remittance_frequency__c = 'P';
        
        insert account;
        
        ANG_RHC_Information__c rhc = new ANG_RHC_Information__c();
        rhc.ANG_AccountId__c = account.Id;
        rhc.ANG_RHC_Amount__c = 5;
        rhc.CurrencyIsoCode = 'USD';
        rhc.ANG_Financial_Security__c = 150;
        
        insert rhc;
        
        Agency_Authorization__c aa = new Agency_Authorization__c();
        aa.Account__c = account.Id;
        aa.RecordTypeId = aaRT;
        aa.Status__c = 'Active';
        
        insert aa;
        
        Agency_Applied_Change_code__c aacc1 = new Agency_Applied_Change_code__c(Change_Code__c = 'IRR',
                                                                                Account__c = account.Id);
        Agency_Applied_Change_code__c aacc2 = new Agency_Applied_Change_code__c(Change_Code__c = 'DFE',
                                                                                Account__c = account.Id);
        Agency_Applied_Change_code__c aacc3 = new Agency_Applied_Change_code__c(Change_Code__c = 'RCR',
                                                                                Account__c = account.Id);
        Agency_Applied_Change_code__c aacc4 = new Agency_Applied_Change_code__c(Change_Code__c = 'IRW',
                                                                                Account__c = account.Id);
        Agency_Applied_Change_code__c aacc5 = new Agency_Applied_Change_code__c(Change_Code__c = 'LSP',
                                                                                Account__c = account.Id);
        Agency_Applied_Change_code__c aacc6 = new Agency_Applied_Change_code__c(Change_Code__c = 'MaddY',
                                                                                Account__c = account.Id);
        
        insert new List<Agency_Applied_Change_code__c>{aacc1, aacc2, aacc3, aacc4, aacc5, aacc6};

    }
    
    @isTest static void testExposeAccMasterData() {
        
        list<Account> lsAccnt = [SELECT Id, Name, Sector__c, IATACode__c, Category__c, Location_Class__c, parentId, Top_Parent__c, Date_Organisation_Status_attained__c,
                                 Location_Type__c, ANG_Accreditation_Model__c, IATA_ISO_Country__c, RecordTypeId, GDI_Status__c, Purge_Flag__c, 
                                 Is_Branch_Abroad__c, Due_Diligence_Status__c, billingCity, billingCountry, billingPostalCode, billingState, 
                                 billingStreet, Accreditation_date__c, Default_date__c, IATA_ISO_Country__r.ISO_Code_Numeric__c, IATA_ISO_Country__r.ISO_Code__c,
                                 Email__c, fax, ANG_IEP_Status_FF__c, Parent.IATACode__c, IATA_ISO_Country__r.BSP_Country_free_text__c, ANG_RiskStatus__c, 
                                 IATA_ISO_Country__r.ANG_Portal_Service__r.Name, IATA_ISO_Country__r.Region__c, phone, Reason__c, VAT_Number__c,
                                 Remittance_frequency__c, Segmentation__c, Status__c, Tax_ID_1__c, TradeName__c, Top_Parent__r.IATACode__c, 
                                 IATA_ISO_Country__r.AMS_Settlement_System__r.CurrencyIsoCode, CurrencyIsoCode, Guaranteed_amount__c, ANG_IsNewGenAgency__c,
                                 (Select Id, ANG_RHC_Amount__c, CurrencyIsoCode, ANG_Financial_Security__c From RHC_Informations__r), 
                                 (Select Id, recordtype.developername, Email_Used_for_BSP_Creation__c, ANG_FormOfPayment_ID__c, Status__c From Agency_Authorizations__r where recordtype.developername in ('BSPLink','FormOfPayment')) 
                                 FROM Account 
                                 WHERE IATACode__c = '12345678'];
        
        
        test.startTest();
        RestResponse res = new RestResponse(); 
        RestContext.response = res;
        
        ANG_ExposeAccountInfo_Masterdata.ANG_ExposeAccountInfo_Masterdata(new Map<Id, Account>(lsAccnt), 'F', 'LSP');
        ANG_ExposeAccountInfo_Masterdata.ANG_ExposeAccountInfo_Masterdata(new Map<Id, Account>(lsAccnt), 'S', 'LSP');
        ANG_ExposeAccountInfo_Masterdata.ANG_ExposeAccountInfo_Masterdata(new Map<Id, Account>(lsAccnt), 'P', 'LSP');
        ANG_ExposeAccountInfo_Masterdata.ANG_ExposeAccountInfo_Masterdata(new Map<Id, Account>(lsAccnt), 'D', 'LSP');
        
        test.stopTest();
    }
}