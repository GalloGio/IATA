@isTest
private class ImportantContactsControllerTest {
    static testMethod void test() {

        // CREATE TEST DATA

        // Create a new ISO Country
        IATA_ISO_Country__c country_fr = new IATA_ISO_Country__c(Name = 'France', ISO_Code__c = 'FR', Region__c = 'Europe');
        insert country_fr;

        // Create an Airline HQ account
        Id AirlineHQ_RT_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
        Account acct_hq = new Account(Name = 'Qatar Airways', Airline_designator__c = 'QR', ICCS_Membership_Status__c = 'Member', Industry='Airline', Type='Passenger',
                                RecordTypeId = AirlineHQ_RT_Id, IATA_ISO_Country__c = country_fr.Id, Membership_status__c = 'Aeropolitical');
        insert acct_hq;

        Id ContactStd_RT_Id = RecordTypeSingleton.getInstance().getRecordTypeId('Contact', 'Standard_Contact');
        Contact c1 = new Contact(FirstName = 'Test', LastName = 'Contact', Email = 'test@test.com', AccountId = acct_hq.Id, RecordTypeId = ContactStd_RT_Id);
        insert c1;

        Contact c2 = new Contact(FirstName = 'Another', LastName = 'Contact', Email = 'test2@test.com', Title = 'CEO', AccountId = acct_hq.Id, RecordTypeId = ContactStd_RT_Id, CEO_CFO__c = 'CEO',
                                Membership_Function__c = 'Aeropolitical');
        insert c2;

        test.startTest();
        	// instantiate the important contacts page controller
	        ApexPages.StandardController std = new ApexPages.StandardController(acct_hq);
	        ImportantContactsController controller = new ImportantContactsController(std);

	        // assess that the important contacts list only contains one of the 2 contacts above
	        system.assertEquals(1, controller.lstImportantContacts.size());

        test.stopTest();
    }
}