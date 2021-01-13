@isTest
private class clsUpdateLetterSentBatchTest{

 static testMethod void testMybatch() {


			BatchNumber__c batch = new BatchNumber__c();
				 insert batch;

			Case ca = new Case();
					ca.Status = 'Agent to be Notified';
					ca.BatchNumber__c = batch.Id;
			 Insert ca;
				Case ca1 = new Case();
					ca1.Status = 'Agent to be Notified';
					ca1.BatchNumber__c = batch.Id;
			 Insert ca1;
				Case ca2 = new Case();
					ca2.Status = 'Agent to be Notified';
					ca2.BatchNumber__c = batch.Id;
			 Insert ca2;
				Case ca3 = new Case();
					ca3.Status = 'Financial Security Requested';
					ca3.BatchNumber__c = batch.Id;
			 Insert ca3;


			 List<Case> cases = new List<Case>();
			 cases.add(ca);
			 cases.add(ca1);
			 cases.add(ca2);
			 cases.add(ca3);



		 Test.startTest();
				clsUpdateLetterSentBatch cBatch = new clsUpdateLetterSentBatch();
				cBatch.caseList = cases;
				cBatch.isFALetterSent= true;
				cBatch.type = 'Update FA Letter Sent';
				cBatch.batchNum = batch.Id;
		 ID batchprocessid = Database.executeBatch(cBatch,5);

				clsUpdateLetterSentBatch cBatch2 = new clsUpdateLetterSentBatch();
				cBatch2.caseList = cases;
				cBatch2.isFALetterSent= false;
				cBatch2.type = 'Update FS Letter Sent';
				cBatch2.batchNum = batch.Id;
		 ID batchprocessid2 = Database.executeBatch(cBatch2,5);
		Test.stopTest();



		}



}
