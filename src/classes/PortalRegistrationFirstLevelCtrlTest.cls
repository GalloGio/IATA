/**
 * Created by ukaya01 on 26/08/2019.
 */

@isTest
public class PortalRegistrationFirstLevelCtrlTest {

    @isTest
    static void unitTest(){

        Id rtHQ =  RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
        Account acc = new Account(
                RecordTypeId = rtHQ,
                Name='Bucket Airline',
                ACLI_Status__c = 'Active Company',
                MITA_Member__c = true,
                BIETA_Member__c = true,
                Airline_designator__c = 'AA',
                IATACode__c = '4321',
                Airline_Prefix__c = '765',
                Sector__c = 'Airline',
                Category__c = 'Passenger and Cargo');
        insert acc;

        Contact con = new Contact();
        con.firstName = 'test3';
        con.lastName = 'test3';
        con.AccountId = acc.Id;
        con.Email='contact@bucketline.com';
        insert con;
        User portalUser = ISSP_ObjectFactory.createPortalUser(con);

        PortalRegistrationFirstLevelCtrl.getConfig();
        PortalRegistrationFirstLevelCtrl.getUserInformationFromEmail('admin@iata.org');
        PortalRegistrationFirstLevelCtrl.getUserInformationFromEmail('contact@bucketline.com');

        string registrationJson = '{"email":"user@bucketline.com","firstName":"testFirstName","lastName":"testLastName","country":"","phone":"","extraChoice":"","language":"en_us","termsAndUsage":true}';
        string customerTypeJson = '{"Filter_on_Sector__c":"Airline", "Filter_on_Category__c": "Passenger and Cargo"}';
        PortalRegistrationFirstLevelCtrl.simulateRegister(registrationJson, customerTypeJson, con.Id, acc.Id );

        PortalRegistrationFirstLevelCtrl.RegistrationParameters params = new PortalRegistrationFirstLevelCtrl.RegistrationParameters();
        params.email = 'user@bucketline.com';
        params.firstName = 'testFirstName';
        params.firstName = 'testLastName';
        params.country = '';
        params.phone = '';
        params.language = 'en_us';
        params.contactId = con.Id;
        params.accountId = acc.Id;

        PortalRegistrationFirstLevelCtrl.register(params, 'password');
        PortalRegistrationFirstLevelCtrl.getCustomerTypePicklists(null);
        PortalRegistrationFirstLevelCtrl.getCustomerTypePicklists('Airline');
        PortalRegistrationFirstLevelCtrl.getMetadataCustomerType('Airline');

    }


}