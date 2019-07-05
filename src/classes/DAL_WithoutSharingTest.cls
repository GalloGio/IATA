@isTest
public with sharing class DAL_WithoutSharingTest {

public static testMethod void DAL_WithoutSharingTest(){

	Profile testProfile = [SELECT Id FROM Profile WHERE Name = 'System Administrator'];

	IATA_ISO_Country__c country = new IATA_ISO_Country__c(name = 'test', IATA_Contry_KR__c = 'test', CASS_Import__c = 'Yes',
	                                                      IATA_COUNTRY_EN__c = 'testEN', IATA_Country_FR__c = 'testFR', IATA_Country_ZH__c = 'testZH',
	                                                      IATA_Country_IT__c = 'testIT', IATA_Country_JP__c = 'testJP', ISO_Code__c = 'tq',
	                                                      IATA_Country_PT__c = 'testPT', IATA_Country_SP__c = 'testSP', Case_BSP_Country__c = 'test' );
	insert country;

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

	Contact con = ISSP_ObjectFactory.createNewContact();
	con.AccountId = child.Id;
	con.Email = 'Test@test11.com';
	insert con;

	User newUser = ISSP_ObjectFactory.createPortalUser(con);
	con.OwnerId = newUser.Id;
	update con;


	Test.startTest();
	System.runAs(newUser) {
		String result = DAL_WithoutSharing.performCheckonPoll('IEP_EdenRed', 0);
        List<Contact> myContactsByAccountId = DAL_WithoutSharing.getContactsByAccountId(child.id, 0, 0);
        List<Contact> searchMyContactsByAccountId = DAL_WithoutSharing.searchContactsByAccountId(child.id, 0, 0, '');
	}

	Test.stopTest();
}
}