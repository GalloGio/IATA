/**
 * Created by pvavruska on 5/17/2019.
 */

@IsTest
public class GCS_RegistrationControllerTest {

    @TestSetup
    static void createData(){
        /**
		 1. Iso Countries
		*/
        List<IATA_ISO_Country__c> isoCountriesList = new List<IATA_ISO_Country__c>();


        IATA_ISO_Country__c italy = new IATA_ISO_Country__c(Name='Italy', ISO_Code__c='IT', Region__c='Europe', ISS_Office_Location__c='Italy');
        isoCountriesList.add(italy);


        IATA_ISO_Country__c portugal = new IATA_ISO_Country__c(Name='Portugal', ISO_Code__c='PT', Region__c='Europe', ISS_Office_Location__c='Portugal');
        isoCountriesList.add(portugal);

        IATA_ISO_Country__c us = new IATA_ISO_Country__c(Name='United States', ISO_Code__c='US', Region__c='Americas', ISS_Office_Location__c='United States');
        isoCountriesList.add(us);

        insert isoCountriesList;

        /**
         1. Iso State
        */
        List<IATA_ISO_State__c> isoStatesList = new List<IATA_ISO_State__c>();


        IATA_ISO_State__c alabama = new IATA_ISO_State__c(	IATA_ISO_Country__c = isoCountriesList.get(2).Id ,Name='Alabama', ISO_Code__c='	US-AL');
        isoStatesList.add(alabama);


        IATA_ISO_State__c alasca = new IATA_ISO_State__c(	IATA_ISO_Country__c = isoCountriesList.get(2).Id ,Name='Alaska', ISO_Code__c='US-AK');
        isoStatesList.add(alasca);


        insert isoStatesList;

        /** ISSP SETTINGS */
        ISSP_CS__c setting = new ISSP_CS__c();
        setting.Name = 'DefaultNewAccountOwnerId';
        setting.Value__c = UserInfo.getUserId();
        insert setting;

        ISSP_CS__c setting2 = new ISSP_CS__c();
        setting2.Name = 'IdentityPortal';
        setting2.Value__c = 'customer-portal-iata.force.com';
        insert setting2;

        Id profileId = [ SELECT Id FROM Profile WHERE Name = 'ISS Portal Agency User (Partner)' ][0].Id;

        ISSP_CS__c setting3 = new ISSP_CS__c();
        setting3.Name = 'ISS_Portal_Agency_User';
        setting3.Value__c = profileId;
        insert setting3;

        /** ACCOUNTS */
        List<Account> accs = new List<Account>();
        Id standardTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Account','Standard_Account');
        Id airlineRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
        Id agencyRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');

        Account gp = new Account(name = 'GP -PORTUGAL', Category__c='Student',Sector__c='General Public',IATA_ISO_Country__c = portugal.Id,recordTypeId=standardTypeId);
        accs.add(gp);

        Account cargoAgent = new Account(name = 'TEST CARGO AGENT', Category__c='IATA Cargo Agent',Sector__c='Cargo Agent',IATACode__c = '1234567', IATA_ISO_Country__c = portugal.Id,recordTypeId=agencyRT);
        accs.add(cargoAgent);
        
        Account airline = new Account(name = 'TEST AIRLINE', Category__c='Passenger only',Sector__c='Airline',IATACode__c = '057', IATA_ISO_Country__c = portugal.Id, recordTypeId = airlineRT);
        accs.add(airline);
        
        Account airline2 = new Account(name = 'TEST DEACTIVATED AIRLINE', Category__c='Passenger only',Sector__c='Airline',IATACode__c = '058', IATA_ISO_Country__c = portugal.Id, ACLI_Status__c = 'Inactive Company', recordTypeId = airlineRT);
        accs.add(airline2);
        
        insert accs;
    }

    @IsTest
    static void testLabelsAndCountries(){
        Map<String,String> getAccountLabels = GCS_RegistrationController.getAccountLabels();
        System.assert(!getAccountLabels.keySet().isEmpty());

        GCS_RegistrationController.CountryInformation countries = GCS_RegistrationController.getISOCountries();
        System.assert(!countries.countryList.isEmpty());
    }


    @IsTest
    static void testSearchAccounts(){
        IATA_ISO_Country__c country = [SELECT Id FROM IATA_ISO_Country__c WHERE ISO_Code__c='PT' LIMIT 1];

		List<GCS_CustomerType> customerTypesList = GCS_RegistrationController.getCustomerTypesList();
		System.assert(!customerTypesList.isEmpty());

		GCS_RegistrationController.getMetadataCustomerType(customerTypesList.get(0).metadataCustomerType.DeveloperName);

        GCS_RegistrationController.AccountListWrapper cargoAgents = GCS_RegistrationController.searchAccounts('IATA_Cargo_Agent',country.Id,'1234567',null);
        System.assert(!cargoAgents.accountIds.isEmpty() && cargoAgents.totalAccounts == 1);

        GCS_RegistrationController.AccountListWrapper airlines = GCS_RegistrationController.searchAccounts('Passenger_only',country.Id,'057','TEST');
        System.assert(!airlines.accountIds.isEmpty() && airlines.totalAccounts == 1);
    }

    @IsTest
    static void testNewAccountRegistration(){
        String serviceName = 'ISSP';
        IATA_ISO_Country__c country = [SELECT Id FROM IATA_ISO_Country__c WHERE ISO_Code__c='PT' LIMIT 1];

		GCS_Customer_Type_For_Registration__mdt customerType = GCS_AccountCreation.getMetadataCustomerType('Airline');

		Map<String,String> accountLabels = GCS_AccountCreation.getAccountLabels();

		List<GCS_AccountCreation.CustomerTypePicklist> picklists = GCS_AccountCreation.getCustomerTypePicklists('Airline', 'Passenger_and_Cargo');
		
		OneId_RegistrationProcessController.StatesAndAlternateNames states = GCS_AccountCreation.getStates(country.Id);
		//String cities = GCS_AccountCreation.getAllCities(country.Id);

        Account a = new Account(name = 'TEST ACCOUNT',Sector__c='Travel Agent', Category__c='Non-IATA Travel Agent',IATA_ISO_Country__c = country.Id);
        Contact c = new Contact(firstname='firstname', lastname = 'lastname',Salutation = 'sig', email='xpto@lls.com');

        GCS_RegistrationController.registration(a,c,serviceName,null);
    }

    @IsTest
    static void testExistingAccountRegistration(){
        String serviceName = 'ISSP';
        IATA_ISO_Country__c country = [SELECT Id FROM IATA_ISO_Country__c WHERE ISO_Code__c='PT' LIMIT 1];

        Account a = [SELECT Id FROM Account WHERE Name = 'TEST CARGO AGENT' LIMIT 1];
        Contact c = new Contact(firstname='firstname', lastname = 'lastname',Salutation = 'sig', email='xpto@lls.com');

        GCS_RegistrationController.registration(a,c,serviceName,null);
    }

    @IsTest
    static void testAutoRegistration(){
        String serviceName = 'ISSP';
        IATA_ISO_Country__c country = [SELECT Id FROM IATA_ISO_Country__c WHERE ISO_Code__c='PT' LIMIT 1];
		                
		GCS_Customer_Type_For_Registration__mdt customerType = [select Id, Filter_on_Record_Type__c, Filter_on_Sector__c, Filter_on_Category__c from GCS_Customer_Type_For_Registration__mdt Where DeveloperName = 'Student' Limit 1];
		
        Contact c = new Contact(firstname='firstname', lastname = 'lastname',Salutation = 'sig', email='xpto@lls.com');

        GCS_RegistrationController.automaticRegistration(c,country.Id,customerType,serviceName);
    }

    @IsTest
    static void testGetTypes(){
        Map<String,GCS_CustomerType> types = GCS_CustomerType.getCustomerTypesMap();
        System.assert(!types.keySet().isEmpty());

        List<GCS_CustomerType> typesList = GCS_CustomerType.getCustomerTypesList();
        System.assert(!typesList.isEmpty());

        typesList = GCS_CustomerType.getCustomerTypesList();
        System.assert(!typesList.isEmpty());

        System.debug(typesList.get(0));
    }

}