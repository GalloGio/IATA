@isTest
private class ISSP_ANG_ANNUAL_REVALIDATION_Test {

	private static Id rtAgency = Schema.SObjectType.Account.getRecordTypeInfosByName().get('Agency').getRecordTypeId();
	private static Id rtOscar = Schema.SObjectType.AMS_OSCAR__c.getRecordTypeInfosByName().get('ANG.ANNUAL.REVALIDATION').getRecordTypeId();
	private static Id rtCase = Schema.SObjectType.Case.getRecordTypeInfosByName().get('OSCAR Communication').getRecordTypeId();


	@isTest
	static void test1() {
		try {
			ISSP_ANG_ANNUAL_REVALIDATION ctrl = new ISSP_ANG_ANNUAL_REVALIDATION();
			System.assert(false);
		} catch (Exception e) {
			System.assert(true);
		}
	}

	@isTest
	static void test2() {
		try {
			Account account = ISSP_ObjectFactory.createNewAccount();
			account.BillingCity = 'test';
			account.Name = 'test';
			account.sector__c = 'Travel Agent';
			account.Location_Type__c = 'HE';
			account.RecordTypeId = rtAgency ;
			account.IATACode__c = '12345678';

			insert account;

			Case testcase = new Case (
				Account_Concerned__c = account.id,
				AccountId = account.id,
				Reason1__c = 'Bla bla bla bla',
				RecordTypeId = rtCase,
				Type = 'Case',
				Type_of_customer__c = 'IATA Travel Agent'
			);

			insert testcase;

			Test.setCurrentPageReference(new PageReference('Page.ISSP_ANG_ANNUAL_REVALIDATION'));
			System.currentPageReference().getParameters().put('caseId', testcase.id);

			ISSP_ANG_ANNUAL_REVALIDATION ctrl = new ISSP_ANG_ANNUAL_REVALIDATION();
			System.assert(false);
		} catch (Exception e) {
			System.assert(true);
		}
	}

	@isTest
	static void test3() {

        Account account = ISSP_ObjectFactory.createNewAccount();
        account.BillingCity = 'test';
        account.Name = 'test';
        account.sector__c = 'Travel Agent';
        account.Location_Type__c = 'HE';
        account.RecordTypeId = rtAgency ;
        account.IATACode__c = '12345678';

		insert account;

		AMS_OSCAR__c oscar = New AMS_OSCAR__c (
			Account__c = account.id,
			Process__c = 'ANG.ANNUAL.REVALIDATION',
			RecordTypeId = rtOscar
		);

		insert oscar;

		Case testcase = new Case (
			Account_Concerned__c = account.id,
			AccountId = account.id,
			OSCAR__c  = oscar.id,
			Reason1__c = 'Annual revalidation',
			RecordTypeId = rtCase,
			Subject = 'Annual revalidation - GoStandard - test',
			Type = 'Case',
			Type_of_customer__c = 'IATA Travel Agent'
		);

		insert testcase;

		Test.setCurrentPageReference(new PageReference('Page.ISSP_ANG_ANNUAL_REVALIDATION'));
		System.currentPageReference().getParameters().put('caseId', testcase.id);

		ISSP_ANG_ANNUAL_REVALIDATION ctrl = new ISSP_ANG_ANNUAL_REVALIDATION();
	}
}