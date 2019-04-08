@isTest
public with sharing class TestPortalSupportReachUsCtrl {
    
    public static testMethod void TestPortalSupportReachUsCtrl(){
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test', CASS_Import__c = 'Yes',
                                                              IATA_COUNTRY_EN__c = 'testEN' , IATA_Country_FR__c = 'testFR' , IATA_Country_ZH__c = 'testZH' ,
                                                              IATA_Country_IT__c = 'testIT' , IATA_Country_JP__c = 'testJP' , ISO_Code__c = 'tq',
                                                              IATA_Country_PT__c = 'testPT' , IATA_Country_SP__c = 'testSP' , Case_BSP_Country__c = 'test' );
        insert country;
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'test2', ISO_Code__c = 't2', Case_BSP_Country__c = 'test2', CASS_Import__c = 'Yes');
        insert country2;
        
        Id rtIdBr = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
        
        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = 'Travel Agent';
        parent.Location_Type__c = 'HO';
        parent.RecordTypeId = rtIdBr ;
        parent.IATACode__c = '100';
        
        insert parent;
        System.debug('parent Id: ' + parent.Id);
        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'test2';
        child.Name = 'test2';
        child.Site = 'headSite';
        child.sector__c = 'Travel Agent';
        child.Top_Parent__c = parent.Id;
        child.IATA_ISO_Country__c = country.Id;
        child.RecordTypeId = rtIdBr ;
        insert child;
        System.debug('child Id: ' + child.Id);
        
        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = child.Id;
        con.Email = 'Test@test11.com';
        insert con;
        
        System.debug('con Id: ' + con.Id);
        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        System.debug('newUser Id: ' + newUser.Id);
        con.OwnerId = newUser.Id;
        update con;
        
        list<ISSP_FAQ2Case_Permissions__c> listFaq2CasePermissions = new list<ISSP_FAQ2Case_Permissions__c>{
            new ISSP_FAQ2Case_Permissions__c(
                Name = '1',
                ISO_Country__c = 'All',
                Sector_Permission__c = 'All',
                Topic__c = 'CNS_Portal,CNS_CASS_Operations_Cargo,CNS_Endorsement_Cargo_Agent,TASF',
                Subtopic__c = ''),
                new ISSP_FAQ2Case_Permissions__c(
                    Name = '2',
                    ISO_Country__c = 'All',
                    Sector_Permission__c = 'All',
                    Topic__c = '',
                    Subtopic__c = 'CGO_Accreditations_Fees,CGO_Changes_to_my_Agency,CGO_Closure_of_my_Agency,New_Cargo_Agency_Application,PAX_Accreditation_Fees,PAX_Changes_to_my_Agency,PAX_Closure_of_my_Agency,ID_CardNew_Travel_Agency_Application,PORTAL_General_Information')
                };
                    insert listFaq2CasePermissions;
        
        test.startTest();
        
        System.runAs(newUser) {
            Boolean newisCNS = PortalSupportReachUsCtrl.isCNS;
            
            Map<String,String> myMap = new Map<String,String>();
            
            myMap = PortalSupportReachUsCtrl.getTopicPickListValues();
            
            Map<String,String> myMap2 = new Map<String,String>();
            
            Set <String> topicValueSet = myMap.keySet();
            
            string topic = null;
            for (string setElement : topicValueSet) {
                topic = setElement;
                break;
            }
            
            myMap2 = PortalSupportReachUsCtrl.getSubTopicPickListValues(topic);
            
            Map<String,String> myMapEs = new Map<String,String>();
            Map<String,String> myMapKo = new Map<String,String>();
            Map<String,String> myMapZHCN = new Map<String,String>();
            
            Map<String,String> myMapPTBR = new Map<String,String>();
            Map<String,String> myMapFR = new Map<String,String>();
            Map<String,String> myMapJA = new Map<String,String>();
            Map<String,String> myMapIT = new Map<String,String>();
            
            newUser.LanguageLocaleKey ='es';
            update newUser;
            myMapEs = PortalSupportReachUsCtrl.getCountryList();
            newUser.LanguageLocaleKey ='ko';
            update newUser;
            myMapKo = PortalSupportReachUsCtrl.getCountryList();
            newUser.LanguageLocaleKey ='zh_CN';
            update newUser;
            myMapZHCN = PortalSupportReachUsCtrl.getCountryList();
            newUser.LanguageLocaleKey ='pt_BR';
            update newUser;
            myMapPTBR = PortalSupportReachUsCtrl.getCountryList();
            newUser.LanguageLocaleKey ='fr';
            update newUser;
            myMapFR = PortalSupportReachUsCtrl.getCountryList();
            newUser.LanguageLocaleKey ='ja';
            update newUser;
            myMapJA = PortalSupportReachUsCtrl.getCountryList();
            newUser.LanguageLocaleKey ='it';
            update newUser;
            myMapIT = PortalSupportReachUsCtrl.getCountryList();
            test.stopTest();
        }
    }
}