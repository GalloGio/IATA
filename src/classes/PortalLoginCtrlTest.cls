/**
 * Created by ukaya01 on 07/08/2019.
 */
@isTest
public with sharing class PortalLoginCtrlTest {

    @isTest
    static void unitTest() {

        Id rtHQ =  RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
        Account acc = new Account(
                RecordTypeId = rtHQ,
                Name='Bucket Airline',
                ACLI_Status__c = 'Active Company',
                MITA_Member__c = true,
                BIETA_Member__c = true,
                Airline_designator__c = 'AA',
                IATACode__c = '1234',
                Airline_Prefix__c = '567');
        insert acc;

        Contact con = new Contact();
        con.firstName = 'test2';
        con.lastName = 'test2';
        con.AccountId = acc.Id;
        con.Email='contact@bucketairline.com';
        insert con;
        User portalUser = ISSP_ObjectFactory.createPortalUser(con);

        //PortalLoginCtrl.getInitialConfig();
        //PortalLoginCtrl.login('contact@bucketairline.com', 'password');
        //PortalLoginCtrl.login('contact@bucketairline.com', '');

    }

}