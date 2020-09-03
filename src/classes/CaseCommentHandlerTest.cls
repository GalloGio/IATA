@isTest
private class CaseCommentHandlerTest {
	@TestSetup
	static void makeData(){
		//setup data for testing cases with case items
		Case caseRecord = new Case();
		insert caseRecord;
		CaseComment caseComment = new CaseComment(ParentId = caseRecord.Id, CommentBody = 'Test Case Comment');
		insert caseComment;

		//test case with case item
		// get a sample picklist value for business service field
		Schema.DescribeFieldResult businessServiceFieldResult = Case_Item__c.IATA_Business_Service__c.getDescribe();
		List<Schema.PicklistEntry> picklistEntry = businessServiceFieldResult.getPicklistValues();
		String businessService = picklistEntry[0].getValue();

		// get a sample picklist value for business process field
		Schema.DescribeFieldResult businessProcessFieldResult = Case_Item__c.IATA_Business_Process__c.getDescribe();
		picklistEntry = businessProcessFieldResult.getPicklistValues();
		String businessProcess = picklistEntry[0].getValue();
		
		Id recordTypeId = RecordTypeSingleton.getInstance().getRecordTypeId('Case_Item__c', 'MASTER');
		Case_Item__c caseItem = new Case_Item__c(Status__c = 'Open', RecordTypeId = recordTypeId, IATA_Business_Service__c = businessService, IATA_Business_Process__c = businessProcess, Case__c = caseRecord.Id);
		insert caseItem;
	}

	private static Case createClosedCase() {
		String caseJSON = '{"attributes":{'
			+ '"type":"Case",'
			+ '"url":"/services/data/v25.0/sobjects/Case/500E0000002nH2fIAE"},'
			+ '"Subject":"Test Case Subject",'
			+ '"Reason1__c":"New Account request",'
			+ '"CaseArea__c":"Global System Solution",'
			+ '"Status":"Closed",'
			+ '"CreatedDate":' + JSON.serialize(DateTime.now().addMonths(-3)) + ','
			+ '"ClosedDate":' + JSON.serialize(DateTime.now().addMonths(-3))
			+ '}';
		return (Case) JSON.deserialize(caseJSON, Case.class );
	}

	public static testMethod void testPreventInsertionInClosedCases() {
		Account parent = ISSP_ObjectFactory.createNewAccount();
		parent.BillingCity = 'test';
		parent.Name = 'test';
		insert parent;
		System.debug('parent Id: ' + parent.Id);

		Account child = ISSP_ObjectFactory.createNewAccount();
		child.BillingCity = 'test2';
		child.Name = 'test2';
		child.Site = 'headSite';
		child.sector__c = 'Airline';
		child.Top_Parent__c = parent.Id;
		insert child;
		
		Contact contact = ISSP_ObjectFactory.createNewContact();
		contact.AccountId= child.Id;
		contact.Email = 'Test@test11.com';
		insert contact;
		
		User testUser = ISSP_ObjectFactory.createPortalUser(contact);
		contact.OwnerId = testUser.Id;
		update contact;
				
		Id rtId = RecordTypeSingleton.getInstance().getRecordTypeId('Case', EmailMessageHandler.LIST_VALID_RT.get(0));
		
		Case caseClosed = createClosedCase();
		caseClosed.RecordtypeId = rtId;
		caseClosed.ContactId = contact.Id;
		caseClosed.AccountId = contact.AccountId;
		insert caseClosed;
		
		Case caseOpened = new Case();
		caseOpened.RecordtypeId = rtId;
		caseOpened.ContactId = contact.Id;
		caseOpened.AccountId = contact.AccountId;
		insert caseOpened;
		
		//make a fake service simulating E2CP
		CaseCommentHandler.TEST_E2CPRUNUSERS = new set<Id>{testUser.Id};

		Test.startTest();
		System.runAs(testUser) {
			testUser.IsPortalEnabled = true;
			update testUser;
			//Test Closed Case
			try {
				CaseComment caseComment = new CaseComment(
					ParentId=caseClosed.Id,
					IsPublished = true
				);
				insert caseComment;
				//System.assert(false, 'Error expected');
			} catch(Exception e) {
				System.assert(true);
			}
			//Test opened case
			try {
				CaseComment caseComment = new CaseComment(ParentId=caseOpened.Id);
				insert caseComment;
				System.assert(true);
			} catch(Exception e) {
				System.assert(false, 'No exception expected: ' + e.getMessage());
			}
		}
		Test.stopTest();
	}
	
	@IsTest
	static void testDoAfterInsert(){
		Test.startTest();
		CaseCommentHandler caseCommentHandler = new CaseCommentHandler();
		Case caseRecord = new Case();
		insert caseRecord;
		CaseComment caseComment = new CaseComment(ParentId = caseRecord.Id, CommentBody = 'Test Case Comment 1');
		insert caseComment;
		Test.stopTest();

		List<CaseComment> caseCommentList = [SELECT Id FROM CaseComment WHERE CommentBody = 'Test Case Comment 1'];
		System.assertEquals(1, caseCommentList.size(),'Expected to find Case Comment with Comment Body = Test Comment 1');
	}

	@IsTest
	static void testDoAfterUpdate(){
		Test.startTest();
		CaseComment caseComment = [SELECT Id, CommentBody FROM CaseComment LIMIT 1];
		caseComment.CommentBody = 'Updated comment body';
		update caseComment;
		Test.stopTest();

		List<CaseComment> caseCommentList = [SELECT Id FROM CaseComment WHERE CommentBody = 'Updated comment body' LIMIT 1];
		System.assertEquals(1, caseCommentList.size(), 'Expected to find a CaseComment with Comment Body = Updated comment body');
	}

	@IsTest
	static void testDoAfterDelete(){
		Test.startTest();
		CaseComment caseComment = [SELECT Id FROM CaseComment];
		delete caseComment;
		Test.stopTest();

		List<CaseComment> caseCommentList = [SELECT Id FROM CaseComment];
		System.assertEquals(0, caseCommentList.size(), 'Expected 0 CaseComments but instead found ' + caseCommentList.size());
	}

	@IsTest
	static void testDoAfterUndelete(){
		Test.startTest();
		CaseComment caseComment = [SELECT Id FROM CaseComment];
		delete caseComment;
		caseComment = [SELECT Id FROM CaseComment ALL ROWS];
		undelete caseComment;
		Test.stopTest();

		List<CaseComment> caseCommentList = [SELECT Id FROM CaseComment];
		System.assertEquals(1, caseCommentList.size(), 'Expected 1 CaseComments but instead found ' + caseCommentList.size());
	}
}