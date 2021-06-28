@isTest
public class IA_MemorandumsBatchTest {

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
		IA_MemorandumsSchedule.doSchedule();
		Test.stopTest();
	}

	static testMethod void testCallBatch(){
		Test.StartTest();
		new IA_MemorandumsSchedule().createMemorandums();
		Test.stopTest();
	}

	static testMethod void testRunBatch_Error(){
		IA_MemorandumsBatch.testContent = null;

		Test.StartTest();
		IA_MemorandumsBatch batch = new IA_MemorandumsBatch(Date.newInstance(2021,1,1));
		batch.createMemorandum();
		Test.stopTest();

		list<ContentVersion> listfile = [SELECT Id, Title FROM ContentVersion];
		System.assertEquals(0,listFile.size());
	}

	static testMethod void testRunBatch(){
		IA_MemorandumsBatch.testContent = Blob.valueOf('testbody');

		Test.StartTest();
		IA_MemorandumsBatch batch1 = new IA_MemorandumsBatch(Date.newInstance(2021,1,1));
		batch1.createMemorandum();

		IA_MemorandumsBatch batch2 = new IA_MemorandumsBatch(Date.newInstance(2021,2,1));
		batch2.createMemorandum();
		Test.stopTest();

		list<ContentVersion> listfile = [SELECT Id, Title FROM ContentVersion];
		System.assertEquals(2,listFile.size());
		System.assertEquals('Memorandum 1 - Monthly Interline Agreements - January 2021.pdf',listFile[0].Title);
		System.assertEquals('Memorandum 2 - Monthly Interline Agreements - February 2021.pdf',listFile[1].Title);
	}

}