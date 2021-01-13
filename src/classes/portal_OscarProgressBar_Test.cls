@isTest
public class portal_OscarProgressBar_Test {

	@TestSetup
	public static void testSetup(){
		Id accountAgencyRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
		Id caseOscarCommunication = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'OSCAR_Communication');
		Id OscarNewHE = RecordTypeSingleton.getInstance().getRecordTypeId('AMS_OSCAR__c', 'ANG_New_HE');

		Account newAccHead = new Account(Name='Account Test Headquarter', Site = 'Site Test', Sector__c = 'Agency',
									 IATACode__c = '123', Field_Head_Office__c = 'Headquarter',
									 RecordTypeId = accountAgencyRT, Reason_for_creation__c = 'Account is missing');
		insert newAccHead;

		AMS_OSCAR__c oscar = new AMS_OSCAR__c(Process__c = 'ANG.NEW.HE.STANDARD.1.0', RecordTypeId = OscarNewHE,
												Account__c = newAccHead.Id);
		insert oscar;

		Case c = new Case(RecordTypeId = caseOscarCommunication, OSCAR__c = oscar.Id);
		insert c;

	}


	@IsTest
	static void testPortalProgressBar(){
		Case c = [SELECT Id FROM Case LIMIT 1];

		Test.startTest();
			portal_OscarProgressBar.getOscarProgress(c.Id);
		Test.stopTest();

	}
}
