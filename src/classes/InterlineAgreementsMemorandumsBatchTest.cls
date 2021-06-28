@isTest
public class InterlineAgreementsMemorandumsBatchTest {

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