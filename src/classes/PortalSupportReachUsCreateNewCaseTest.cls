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
        child.IATA_ISO_Country__c = country.Id;
        child.RecordTypeId = rtIdBr;
        insert child;
        
        Contact con = ISSP_ObjectFactory.createNewContact();
        con.AccountId = child.Id;
        con.Email = 'Test@test11.com';
        insert con;
        
        User newUser = ISSP_ObjectFactory.createPortalUser(con);
        System.debug('newUser Id: ' + newUser.Id);
        con.OwnerId = newUser.Id;
        update con;
        
        test.startTest();
        
        System.runAs(newUser) {
            List<PortalLookupSearchResult> lstSearchAccounts = PortalSupportReachUsCreateNewCaseCtrl.searchAccounts('asd');
            List<PortalLookupSearchResult> lstGetAccounts =  PortalSupportReachUsCreateNewCaseCtrl.getRelatedAccounts();
            
            List<PortalLookupSearchResult> lstSearchContacts = PortalSupportReachUsCreateNewCaseCtrl.searchContacts('asd');
            List<PortalLookupSearchResult> lstGetContacts =  PortalSupportReachUsCreateNewCaseCtrl.getRelatedContacts();
            
            Boolean agent = PortalSupportReachUsCreateNewCaseCtrl.isAgentProfile();
            
            Case newcase = PortalSupportReachUsCreateNewCaseCtrl.createCase('gb');
            
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