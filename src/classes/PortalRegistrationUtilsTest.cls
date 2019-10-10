/**
 * Created by ukaya01 on 14/08/2019.
 */

@isTest
public with sharing class PortalRegistrationUtilsTest {

    @isTest
    public static void unitTest(){


        insert new ISSP_CS__c(Name = 'ipinfo_token',Value__c = '^(http:\\/\\/|https:\\/\\/)?(www.)([a-zA-Z0-9\\-]+)([.])(([a-zA-Z]{3})|([a-zA-Z]{2}))');
        insert new ISSP_CS__c(Name = 'ipinfo_domain',Value__c = 'https://ipinfo.io/');
        insert new OneId_Global_Settings__c(ipinfo_call_enabled__c = true);

        IATA_ISO_Country__c isoCountry = new IATA_ISO_Country__c(ISO_Code__c='PT',Name='Portugal',Region__c='Europe', Sanctioned_Country__c = true);
        insert isoCountry;

        ISSP_IP_Locator__c newIP = new ISSP_IP_Locator__c();
        newIP.Start1__c = 83;
        newIP.Start2__c = 240;
        newIP.Start3__c = 229;
        newIP.Start4__c = 11;
        newIP.End1__c = 83;
        newIP.End2__c = 240;
        newIP.End3__c = 229;
        newIP.End4__c = 11;
        newIP.Country_Code__c = 'PT';
        insert newIP;

        Account parent = ISSP_ObjectFactory.createNewAccount();
        parent.BillingCity = 'test';
        parent.Name = 'test';
        insert parent;

        Account child = ISSP_ObjectFactory.createNewAccount();
        child.ParentId = parent.Id;
        child.IATA_ISO_Country__c = isoCountry.Id ;
        child.BillingCity = 'testCity';
        child.Name = 'test reg acc';
        child.Site = 'headSite';
        child.Top_Parent__c = parent.Id;
        child.Sector__c = 'Airline';
        child.BillingCountry = 'Italy';
        insert child;
        System.debug('child Id: ' + child.Id);

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockHttpResponseGenerator());
        PortalRegistrationUtils.getUserLocation('83.240.229.11');
        Test.stopTest();
    }


}