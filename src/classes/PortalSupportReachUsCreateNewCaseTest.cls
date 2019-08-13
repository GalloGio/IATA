@isTest
public with sharing class PortalSupportReachUsCreateNewCaseTest {
    
    public static testMethod void PortalSupportReachUsCreateNewCaseTest(){
        
        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test', CASS_Import__c = 'Yes',
                                                              IATA_COUNTRY_EN__c = 'testEN', IATA_Country_FR__c = 'testFR', IATA_Country_ZH__c = 'testZH',
                                                              IATA_Country_IT__c = 'testIT', IATA_Country_JP__c = 'testJP', ISO_Code__c = 'tq',
                                                              IATA_Country_PT__c = 'testPT', IATA_Country_SP__c = 'testSP', Case_BSP_Country__c = 'test' );
        insert country;
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'GB', ISO_Code__c = 'GB', Case_BSP_Country__c = 'GB', CASS_Import__c = 'Yes');
        insert country2;
        
        Id rtIdBr = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
        
        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = 'Travel Agent';
        parent.Location_Type__c = 'HO';
        parent.RecordTypeId = rtIdBr; 
        parent.IATACode__c = '100';
        insert parent;
        
        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'GB';
        child.Name = 'GB';
        child.Site = 'headSite';
        child.sector__c = 'Travel Agent';
        child.Top_Parent__c = parent.Id;
        child.IATAcode__c = '1234567';
        child.IATA_ISO_Country__c = country.Id;
        child.RecordTypeId = rtIdBr;
        insert child;
        
        Account child2 = ISSP_ObjectFactory.createNewAccount();
        child2.BillingCity = 'GB';
        child2.Name = 'GB1';
        child2.Site = 'headSite';
        child2.sector__c = 'Travel Agent';
        child2.Top_Parent__c = parent.Id;
        child2.IATAcode__c = '1234565';
        child2.IATA_ISO_Country__c = country.Id;
        child2.RecordTypeId = rtIdBr;
        insert child2;
        
        Account child3 = ISSP_ObjectFactory.createNewAccount();
        child3.Name = 'GB2';
        child3.Site = 'headSite';
        child3.sector__c = 'Travel Agent';
        child3.Top_Parent__c = parent.Id;
        child3.IATAcode__c = '1234566';
        child3.IATA_ISO_Country__c = country.Id;
        child3.RecordTypeId = rtIdBr;
        insert child3;
        
        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = child.Id;
        con.Email = 'Test@test11.com';
        insert con;
        
        Contact con2 = ISSP_ObjectFactory.createNewContact();
        con2.AccountId = child2.Id;
        con2.Email = 'Test@test22.com';
        insert con2;
        
        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        con.OwnerId = newUser.Id;
        update con;
        
        list<ISSP_FAQ2Case_Record_Type__c> listFaq2CaseRT = new list<ISSP_FAQ2Case_Record_Type__c>();
        listFaq2CaseRT.add(new ISSP_FAQ2Case_Record_Type__c(
            Name = '1',
            Complaint__c = false,
            Recordtype__c = 'Cases_Global',
            Topic__c = 'Airline_Management__c',
            Subtopic__c = 'MITA_Interline_Agreements__c',
            Country_concerned_by_the_query__c = 'GB'));
        listFaq2CaseRT.add(new ISSP_FAQ2Case_Record_Type__c(
            Name = '3',
            Complaint__c = true,
            Recordtype__c = 'Cases_Global',
            Topic__c = 'TIESS__c',
            Subtopic__c = 'TIESS_General_Information__c,TIESS_Link_request_to_Supplier__c,TIESS_New_registration__c,TIESS_Settlement_amount__c,TIESS_User_Profile__c',
            Country_concerned_by_the_query__c = 'GB'));
        listFaq2CaseRT.add( new ISSP_FAQ2Case_Record_Type__c(
            Name = '2',
            Complaint__c = true,
            Recordtype__c = 'Cases_Global',
            Topic__c = 'ICCS__c',
            Subtopic__c = '',
            Country_concerned_by_the_query__c = 'GB'));
        listFaq2CaseRT.add( new ISSP_FAQ2Case_Record_Type__c(
            Name = '4',
            Complaint__c = true,
            Recordtype__c = 'Cases_Global',
            Topic__c = '',
            Subtopic__c = '',
            Country_concerned_by_the_query__c = 'GB'));
        insert listFaq2CaseRT;
        
        test.startTest();
        
        System.runAs(newUser) {
            List<PortalLookupSearchResult> lstSearchAccounts = PortalSupportReachUsCreateNewCaseCtrl.searchAccounts('asd');
            List<PortalLookupSearchResult> lstSearchAccountsNoEntry = PortalSupportReachUsCreateNewCaseCtrl.searchAccounts('');
            List<PortalLookupSearchResult> lstSearchContacts = PortalSupportReachUsCreateNewCaseCtrl.searchContacts('Test@test22.com');
            List<PortalLookupSearchResult> lstSearchContactsNoEntry = PortalSupportReachUsCreateNewCaseCtrl.searchContacts('');
            
            Case newcase = PortalSupportReachUsCreateNewCaseCtrl.createCase('GB', true, 'Airline_Management__c', 'MITA_Interline_Agreements__c');
            
            Case newcaseNoEntry = PortalSupportReachUsCreateNewCaseCtrl.createCase('GB', false, 'TIESS__c', 'TIESS_Link_request_to_Supplier__c');
            
            Contact cont = PortalSupportReachUsCreateNewCaseCtrl.getContact();
            
            String profile = PortalSupportReachUsCreateNewCaseCtrl.getProfile();
            

            Id recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'DPC_Service_Request');
            newcase.RecordTypeId = recordTypeId;
            newcase.BSPCountry__c = 'GB';
            newcase.Subject = 'test';
            newcase.Description = 'test';
            List<String> lstRecipient = new List<String>();
            lstRecipient.add('Test@test11.com');
            
            Case insertedcase =  PortalSupportReachUsCreateNewCaseCtrl.insertCase(newcase,lstRecipient);
        }
        test.stopTest();
    }
    
}