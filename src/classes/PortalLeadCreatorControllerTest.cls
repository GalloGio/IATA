@isTest
public class PortalLeadCreatorControllerTest {
	 @TestSetup
	public static void testSetup() {
		User thisUser = [SELECT Id FROM User WHERE Id = :UserInfo.getUserId()];
		system.runAs(thisUser){

			Group testQueue=new Group(
				Type='Queue', 
				Name='test queue', 
				DeveloperName='test_queue');
			insert testQueue;
				
			QueuesObject queueObj = new QueueSObject(
				QueueID = testQueue.id, 
				SobjectType = 'Lead');
			insert queueObj;
		}
					
		Recommendations_Visibility__c rv = new Recommendations_Visibility__c(
			Content_Reference__c='content-url',
			title__c='this is a title',
			Lead_Queue__c='test queue',
			Opportunity_Owner__c=UserInfo.getUserId()
		);
		insert rv;

		Account acc = ISSP_ObjectFactory.createNewAccount();
		acc.Name = 'Account Test Recommendation Visibility';
		insert acc;

		Contact con = ISSP_ObjectFactory.createNewContact();
		con.AccountId = acc.Id;
		con.FirstName = 'Contact';
		con.LastName = 'Test Recommendation Visibility';
		con.Email = System.today().dayOfYear() + 'testemail1@csp.testclass';
		insert con;
	}

	@isTest
	public static void testGenerateAsLead() {
		Map<String,String> paramMap= new Map<String,String>{
			'firstName'=>'test firstName',
			'lastName'=>'test lastName',
			'country'=>'Portugal',
			'email'=>'test@test.com',
			'phone'=>'+4121321354645',
			'company'=>'Test Inc.',
			'recommendation'=>'content-url'
		};

		Test.startTest();
			PortalLeadCreatorController.handleContactRequest(JSON.serialize(paramMap));
		Test.stopTest();
		list<lead> leadList= [select ownerId from lead limit 1];
		system.assertEquals(leadList.size(),1);

		group q= [select id from group where type='queue' and  Name='test queue' limit 1 ];

		system.assertEquals(leadList.get(0).ownerId,q.id);
		system.assertEquals([select count() from opportunity],0);
		
	}
	
	@isTest
	public static void testGenerateAsOpportunity() {
		contact cont=[select email from contact limit 1];

		Map<String,String> paramMap= new Map<String,String>{
			'firstName'=>'test firstName',
			'lastName'=>'test lastName',
			'country'=>'Portugal',
			'email'=>cont.email,
			'phone'=>'+4121321354645',
			'company'=>'Test Inc.',
			'recommendation'=>'content-url'
		};

		Test.startTest();
			PortalLeadCreatorController.handleContactRequest(JSON.serialize(paramMap));
		Test.stopTest();
		system.assertEquals([select count() from lead],0);
		system.assertEquals([select count() from opportunity],1);
		
	}



}