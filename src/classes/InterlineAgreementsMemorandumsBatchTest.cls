@isTest
public class InterlineAgreementsMemorandumsBatchTest {

	private static Id RT_AIRLINE = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Airline');
	private static Account airline1;
	private static Account airline2;
	private static Contact contact1;
	private static Contact contact2;

	@TestSetup
	public static void setup(){

		insert new ISSP_CS__c(
			Name = 'Interline Memorandums Library Name',
			Value__c = 'Memo folder'
		);
		System.assertEquals('Memo folder', IA_util.LIBRARY_CS);

		User user = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
		System.runAs(user) {
			ContentWorkspace workspace = new ContentWorkspace(
				Name = IA_util.LIBRARY_CS
			);
			insert workspace;
		}
	}

	private static void queryRecords() {
		for ( Account account: [
				SELECT Name, Airline_Prefix__c, Airline_designator__c, IATAcode__c, Membership_status__c, MITA_Member__c, BIETA_Member__c, Logo_File_ID__c,
				MITA_IATA_Interline_Passenger__c, MITA_IATA_Interline_Cargo__c, MITA_One_way_Pass_Issuing_Airline__c, MITA_One_way_Pass_Participating__c,
				BIETA_Bilateral_Date__c, BIETA_One_way_Electronic_Issuing_Airline__c, BIETA_One_way_Electronic_Participating__c, BIETA_One_way_Intermodal_Issuing_Airline__c,
				BIETA_One_way_Intermodal_Participating__c
				FROM Account])
		{
			if (account.Name == 'MyAirline1') airline1 = account;
			if (account.Name == 'MyAirline2') airline2 = account;
		}
		for ( Contact contact: [
				SELECT Id, RecordTypeId, AccountId, FirstName, LastName, Email, Phone, Status__c, MITA_Contact_Type__c
				FROM Contact])
		{
			if (contact.Email == 'test1email@test.com') contact1 = contact;
			if (contact.Email == 'test2email@test.com') contact2 = contact;
		}
	}

	static testMethod void testscheduler(){
		Test.StartTest();
		InterlineAgreementsMemorandumsSchedule.doSchedule();
		Test.stopTest();
	}

	static testMethod void testCallBatch(){
		Test.StartTest();
		new InterlineAgreementsMemorandumsSchedule().createMemorandums();
		Test.stopTest();
	}

	static testMethod void testRunBatch_Error(){
		InterlineAgreementsMemorandumsBatch.testContent = null;

		Test.StartTest();
		InterlineAgreementsMemorandumsBatch batch = new InterlineAgreementsMemorandumsBatch(Date.newInstance(2021,1,1));
		batch.createMemorandum();
		Test.stopTest();

		list<ContentVersion> listfile = [SELECT Id, Title FROM ContentVersion];
		System.assertEquals(0,listFile.size());
	}

	static testMethod void testRunBatch(){
		InterlineAgreementsMemorandumsBatch.testContent = Blob.valueOf('testbody');

		Test.StartTest();
		InterlineAgreementsMemorandumsBatch batch1 = new InterlineAgreementsMemorandumsBatch(Date.newInstance(2021,1,1));
		batch1.createMemorandum();

		InterlineAgreementsMemorandumsBatch batch2 = new InterlineAgreementsMemorandumsBatch(Date.newInstance(2021,2,1));
		batch2.createMemorandum();
		Test.stopTest();

		list<ContentVersion> listfile = [SELECT Id, Title FROM ContentVersion];
		System.assertEquals(2,listFile.size());
		System.assertEquals('Memorandum 1 - Monthly Interline Agreements - January 2021.pdf',listFile[0].Title);
		System.assertEquals('Memorandum 2 - Monthly Interline Agreements - February 2021.pdf',listFile[1].Title);
	}

}