@isTest
private class sendToRecicleBinCaseControllerTest {
	@TestSetup static void setupdata(){
		list<group> queueExists =[select id from group where developerName ='RecycleBinEurope'];
		if(queueExists.isEmpty())  { // in case queue doesn't exist in the sandbox/environment
			Group g1 = new Group(Name='Recycle Bin Europe',developerName='RecycleBinEurope', type='Queue');
			insert g1;
		}



	}
	@IsTest  static void testSendToRecicleBin(){

		Test.startTest();

		Account acc= new Account(
			name='Acc 1',
			region__c='Europe'
		);
		insert acc;
		case c= new case(
			accountId =acc.id,
			region__c ='Europe'
		);
		insert c;

		string res=sendToRecicleBinCaseController.findRecycleQueue(c.id);

		group q=[select id from group where developerName ='RecycleBinEurope'].get(0);

		test.stopTest();

		//Empty parameter check
		system.assertEquals('',sendToRecicleBinCaseController.findRecycleQueue(''));

		//moves succefully to the correct Recycle bin queue
		system.assertEquals(String.valueOf(q.id),sendToRecicleBinCaseController.findRecycleQueue(c.id));

		c.region__c='Narnia';
		update c;

		//not existing recycle bin for this region
		system.assertEquals('',sendToRecicleBinCaseController.findRecycleQueue(c.id));



	}
}
