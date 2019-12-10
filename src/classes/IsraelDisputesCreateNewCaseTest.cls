@isTest
public with sharing class IsraelDisputesCreateNewCaseTest {

    public static testmethod void IsraelDisputesCreateNewCaseTest() {
        String recordTypeId = Schema.getGlobalDescribe().get('Account').getDescribe().getRecordTypeInfosByName().get('Airline Headquarters').getRecordTypeId();

        IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test', CASS_Import__c = 'Yes',
                                                              IATA_COUNTRY_EN__c = 'testEN', IATA_Country_FR__c = 'testFR', IATA_Country_ZH__c = 'testZH',
                                                              IATA_Country_IT__c = 'testIT', IATA_Country_JP__c = 'testJP', ISO_Code__c = 'tq',
                                                              IATA_Country_PT__c = 'testPT', IATA_Country_SP__c = 'testSP', Case_BSP_Country__c = 'test' );
        insert country;
        IATA_ISO_Country__c country2 = new IATA_ISO_Country__c(name = 'GB', ISO_Code__c = 'GB', Case_BSP_Country__c = 'GB', CASS_Import__c = 'Yes');
        insert country2;
                
        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        parent.sector__c = 'Travel Agent';
        parent.Location_Type__c = 'HO';
        parent.IATACode__c = '100';
        parent.Site = 'hi';
        parent.Sector__c = 'Airline';
        parent.Category__c = 'Passenger and Cargo';
        parent.Membership_status__c = 'IATA Member';
        parent.ACLI_Status__c = 'Active Company';
        parent.Airline_Prefix__c = '111';
        parent.Airline_Designator__c = 'BB';
        parent.RecordTypeId = recordTypeId;
        insert parent;
        
        Account child = ISSP_ObjectFactory.createNewAccount();
        child.BillingCity = 'GB';
        child.Name = 'GB';
        child.Site = 'headSite';
        child.sector__c = 'Travel Agent';
        child.Top_Parent__c = parent.Id;
        child.IATAcode__c = '1234567';
        child.IATA_ISO_Country__c = country.Id;
        child.Site = 'hi';
        child.Sector__c = 'Airline';
        child.Category__c = 'Passenger Only';
        child.Membership_status__c = 'IATA Member';
        child.ACLI_Status__c = 'Active Company';
        child.Airline_Prefix__c = '112';
        child.Airline_Designator__c = 'GB';
        child.RecordTypeId = recordTypeId;
        insert child;
        
        Account child2 = ISSP_ObjectFactory.createNewAccount();
        child2.BillingCity = 'GB';
        child2.Name = 'GB1';
        child2.Site = 'headSite';
        child2.sector__c = 'Travel Agent';
        child2.Top_Parent__c = parent.Id;
        child2.IATAcode__c = '1234565';
        child2.IATA_ISO_Country__c = country.Id;
        child2.Site = 'hi';
        child2.Sector__c = 'Airline';
        child2.Category__c = 'Passenger Only';
        child2.Membership_status__c = 'IATA Member';
        child2.ACLI_Status__c = 'Active Company';
        child2.Airline_Prefix__c = '112';
        child2.Airline_Designator__c = 'GB';
        child2.RecordTypeId = recordTypeId;
        insert child2;
        
        Account child3 = ISSP_ObjectFactory.createNewAccount();
        child3.Name = 'GB2';
        child3.Site = 'headSite';
        child3.sector__c = 'Travel Agent';
        child3.Top_Parent__c = parent.Id;
        child3.IATAcode__c = '1234566';
        child3.IATA_ISO_Country__c = country.Id;
        child2.Site = 'hi';
        child2.Sector__c = 'Airline';
        child2.Category__c = 'Passenger Only';
        child2.Membership_status__c = 'IATA Member';
        child2.ACLI_Status__c = 'Active Company';
        child2.Airline_Prefix__c = '112';
        child2.Airline_Designator__c = 'GB';
        child2.RecordTypeId = recordTypeId;
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

        List<PortalLookupSearchResult> lstSearchAccounts = new List<PortalLookupSearchResult>();
        List<PortalLookupSearchResult> lstSearchAccountsNoEntry = new List<PortalLookupSearchResult>();

        test.startTest();
        
        System.runAs(newUser) {
            Boolean fifteenth = IsraelDisputesCreateNewCaseCtrl.isBeforeFifteenth();
            lstSearchAccounts = IsraelDisputesCreateNewCaseCtrl.searchAccounts('112');
            lstSearchAccountsNoEntry = IsraelDisputesCreateNewCaseCtrl.searchAccounts('');
        }

        test.stopTest();

        System.assertEquals(2, lstSearchAccounts.size());
        System.assertEquals(3, lstSearchAccountsNoEntry.size());
    }
}
