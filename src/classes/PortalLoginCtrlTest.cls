/**
 * Created by ukaya01 on 07/08/2019.
 */
@isTest
public with sharing class PortalLoginCtrlTest {

    @isTest
    static void unitTest() {

        IATA_ISO_Country__c israel = new IATA_ISO_Country__c(Name = 'Israel', ISO_Code__c = 'IL');
        insert israel;
        
        Portal_Applications__c app = new Portal_Applications__c(Name = 'Deduction Notice', Application_URL__c = '/csportal/s/israel-disputes-create-new-case'); 
        insert app;

        Id rt =  RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
        Account acc = new Account(
                RecordTypeId = rt,
                Name='Bucket Airline',
                ACLI_Status__c = 'Active Company',
                MITA_Member__c = true,
                BIETA_Member__c = true,
                Airline_designator__c = 'AA',
                IATACode__c = '1234',
                Airline_Prefix__c = '567',
        		Category__c = 'IATA Passenger Sales Agent',
            	Status__c = 'Approved',
            	Sector__c = 'Travel Agent',
        		IATA_ISO_Country__c = israel.Id);
        insert acc;

        Contact con = new Contact();
        con.firstName = 'testcon1';
        con.lastName = 'testcon1';
        con.AccountId = acc.Id;
        con.Email='contact1@bucketairline.com';
        insert con;
        User portalUser = ISSP_ObjectFactory.createPortalUser(con);

        Contact con2 = new Contact();
        con2.firstName = 'testcon2';
        con2.lastName = 'testcon2';
        con2.AccountId = acc.Id;
        con2.User_Portal_Status__c = 'Approved User';
        con2.Email='contact2@bucketairline.com';
        insert con2;
        User portalUser2 = ISSP_ObjectFactory.createPortalUser(con2);

        Contact con3 = new Contact();
        con3.firstName = 'testcon3';
        con3.lastName = 'testcon3';
        con3.AccountId = acc.Id;
        con3.Email='contact3@bucketairline.com';
        insert con3;
        User portalUser3 = ISSP_ObjectFactory.createPortalUser(con3);

        PortalLoginCtrl.LoginConfig loginConfig = PortalLoginCtrl.getInitialConfig();
        PortalLoginCtrl.LoginResult loginResult = PortalLoginCtrl.login('contact1@bucketairline.com', 'password', '','');
        loginResult = PortalLoginCtrl.login('contact2@bucketairline.com', 'password', Label.CSP_PortalPath + 'test','');
        loginResult = PortalLoginCtrl.login('contact3@bucketairline.com', 'password', 'test','');
        loginResult = PortalLoginCtrl.login('contact3@bucketairline.com', '', '','');
        system.runAs(portalUser) {
            PortalLoginCtrl.reactivateUser(portalUser);
        }
    }

}