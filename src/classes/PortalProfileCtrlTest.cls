/**
 * Created by pvavruska on 6/3/2019.
 */

@IsTest
public with sharing class PortalProfileCtrlTest {

    public static Account MyAirline;
    public static List<Account> Airlines;
    public static List<Contact> Contacts;
    public static User portalUser;


    @IsTest
    static void testProfileInfo(){
        Id rtHQ =  RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
        MyAirline = new Account(
                RecordTypeId = rtHQ,
                Name='MyAirline',
                ACLI_Status__c = 'Active Company',
                MITA_Member__c = true,
                BIETA_Member__c = true,
                Airline_designator__c = 'AA',
                IATACode__c = '123',
                Airline_Prefix__c = '456');
        insert MyAirline;

        Contact MyContact = new Contact(FirstName = 'Name', LastName='My Contact', AccountId=MyAirline.Id, Email='contact@MyAirline.com');
        insert MyContact;

        Profile p = [SELECT Id FROM Profile WHERE Name='ISS Portal Airline User (Partner)'];
        portalUser = new User(Alias = 'standt', Email='standarduser@testorg.com',
                EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US',
                LocaleSidKey='en_US', ProfileId = p.Id, ContactId = MyContact.Id,
                TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');
        insert portalUser;

        System.runAs(portalUser){
            Account airline = PortalProfileCtrl.getCompanyInfo(MyAirline.Id);

            System.assert(airline.Id == MyAirline.Id);

            Map<String, List<PortalProfileCtrl.FieldWrapper>> contactWrappers = PortalProfileCtrl.getFieldsMap('MyProfile');
            System.assert(!contactWrappers.isEmpty());
            Map<String, List<PortalProfileCtrl.FieldWrapper>> companyWrappers = PortalProfileCtrl.getFieldsMap('CompanyProfile');
            System.assert(!companyWrappers.isEmpty());
        }
    }

}