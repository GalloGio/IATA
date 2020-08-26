@isTest
public class PortalCaseClosureTest {
	
	@testSetup
	static void setupData(){
		Id accountAgencyRT = RecordTypeSingleton.getInstance().getRecordTypeId('Account', 'IATA_Agency');
		Id casesEurope = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'CasesEurope');
		Id casesGlobal = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Cases_Global');

		Account newAcc = new Account(Name='Account Test Headquarter', Site = 'Site Test', Sector__c = 'Airline',
									 IATACode__c = '123', Field_Head_Office__c = 'Headquarter',
									 RecordTypeId = accountAgencyRT);
		insert newAcc;

		Contact newCon1 = new Contact(AccountId = newAcc.Id, FirstName = 'John', LastName = 'Doe', Email = System.today().dayOfYear() + 'testemail1@csp.testclass', User_Portal_Status__c = 'Approved Admin', Status__c = 'Active');
		insert newCon1;

		User newUser = ISSP_ObjectFactory.createPortalBasicAirlineUser(newCon1);

		Case newCase1 = new Case(Subject = 'Case Test 1', Region__c = 'Europe',
								Origin = 'Portal', CaseArea__c = 'CargoIS', RecordTypeId = casesEurope, ContactId = newCon1.Id);
		Case newCase2 = new Case(Subject = 'Case Test 2', Region__c = 'Africa & Middle East',
								 Origin = 'Portal', CaseArea__c = 'CargoIS', RecordTypeId = casesGlobal, ContactId = newCon1.Id);
		insert new List<Case> {newCase1, newCase2};

		Notification_template__c notificationTemplate = new Notification_template__c(
				Message__c = '<p>Please click <a href="https://{0}case-details?caseId={1}" target="_blank">here</a> to read the comment.</p>',
				Subject__c = 'You have a new Case Comment pending feedback',
				Language__c = 'English',
				Expire_in_days__c = 90,
				Alert_Contact_By_Email__c = false,
				Type__c = 'Action',
				Notification_color__c = '#FF5E4D',
				CriticalNotification__c = false);
		insert notificationTemplate;
	}

	@isTest
	public static void testCloseLink() {
		Case c1 = [SELECT Id, Status FROM Case WHERE Subject LIKE '%Test 1%' LIMIT 1];
		c1.Status = CaseTriggerHelper.CASE_STATUS_PENDING_CLOSURE;
		update c1;

		User guestUser = [SELECT Id, Name FROM User WHERE UserType='Guest' AND Name LIKE '%CS%'];
		PortalCaseClosureController.CloseCaseResult result;
		String surveyLink;

		Test.startTest();
			
		c1 = [SELECT Id, Status, Portal_Closure_Status__c, Portal_Closure_Link__c FROM Case WHERE Id = :c1.Id];
		System.runAs(guestUser) {
			result = PortalCaseClosureController.closeCase(Label.CSP_PortalBaseUrl + Label.CSP_PortalPath + c1.Portal_Closure_Link__c);
			surveyLink = PortalCaseClosureController.answerSurvey(c1.Id);
		}

		Test.stopTest();

		c1 = [SELECT Id, Status, Portal_Closure_Status__c, Portal_Closure_Link__c, Instant_Survey_Feedback_requested__c FROM Case WHERE Id = :c1.Id];
		
		System.assert(result.closed);
		System.assertEquals(c1.Id, result.caseId);
		System.assert(!c1.Instant_Survey_Feedback_requested__c);
		System.assertEquals(CaseTriggerHelper.CASE_STATUS_CLOSED, c1.Status);
		System.assertEquals(CaseCommentAutoReply.CLOSURE_STATUS_FINISHED_RESOLVED, c1.Portal_Closure_Status__c);
		
	}

	@isTest
	public static void testCloseLinkForClosedCase() {
		Case c1 = [SELECT Id, Status FROM Case WHERE Subject LIKE '%Test 1%' LIMIT 1];
		c1.Status = CaseTriggerHelper.CASE_STATUS_PENDING_CLOSURE;
		update c1;
		PortalCasesCtrl.updateClosureStatus(c1.Id, CaseCommentAutoReply.CLOSURE_STATUS_FINISHED_RESOLVED);

		User guestUser = [SELECT Id, Name FROM User WHERE UserType='Guest' AND Name LIKE '%CS%'];
		PortalCaseClosureController.CloseCaseResult result;
		Boolean ignoreSurveyResult;

		Test.startTest();

		c1 = [SELECT Id, Status, Portal_Closure_Status__c, Portal_Closure_Link__c FROM Case WHERE Id = :c1.Id];
		System.runAs(guestUser) {
			result = PortalCaseClosureController.closeCase(Label.CSP_PortalBaseUrl + Label.CSP_PortalPath + c1.Portal_Closure_Link__c);
			ignoreSurveyResult = PortalCaseClosureController.ignoreSurvey(c1.Id);
		}

		Test.stopTest();

		c1 = [SELECT Id, Status, Portal_Closure_Status__c, Portal_Closure_Link__c, Instant_Survey_Feedback_requested__c FROM Case WHERE Id = :c1.Id];
		
		System.assert(!result.closed);
		System.assertEquals(c1.Id, result.caseId);
		System.assert(c1.Instant_Survey_Feedback_requested__c);
		System.assertEquals(CaseTriggerHelper.CASE_STATUS_CLOSED, c1.Status);
		System.assertEquals(CaseCommentAutoReply.CLOSURE_STATUS_FINISHED_RESOLVED, c1.Portal_Closure_Status__c);
		
	}

	@isTest
	public static void testMovePendingClosure() {
		Case c1 = [SELECT Id, Status, RecordType.DeveloperName, Visible_on_ISS_Portal__c FROM Case WHERE Subject LIKE '%Test 1%' LIMIT 1];
		CaseCommentAutoReply.NOTIFICATION_TEMPLATE =
			[SELECT Id, Name, Message__c, Subject__c, Language__c, Expire_in_days__c, Alert_Contact_By_Email__c,
					Type__c, Notification_color__c, CriticalNotification__c
			FROM Notification_template__c
			LIMIT 1];

		Test.startTest();

		c1.Status = CaseTriggerHelper.CASE_STATUS_PENDING_CLOSURE;
		update c1;
		
		Test.stopTest();

		c1 = [SELECT Id, Status, Portal_Closure_Status__c, Portal_Closure_Link__c FROM Case WHERE Id = :c1.Id];
		System.assertEquals(CaseTriggerHelper.CASE_STATUS_PENDING_CLOSURE, c1.Status);
		System.assertEquals(CaseCommentAutoReply.CLOSURE_STATUS_STARTED, c1.Portal_Closure_Status__c);
		System.assert(!String.isBlank(c1.Portal_Closure_Link__c));

	}

	@isTest
	public static void testClosedUnresolved() {
		Case c1 = [SELECT Id, Status FROM Case WHERE Subject LIKE '%Test 1%' LIMIT 1];
		c1.Status = CaseTriggerHelper.CASE_STATUS_PENDING_CLOSURE;
		update c1;

		Test.startTest();

		PortalCasesCtrl.updateClosureStatus(c1.Id, CaseCommentAutoReply.CLOSURE_STATUS_ONGOING);
		PortalCasesCtrl.updateClosureStatus(c1.Id, CaseCommentAutoReply.CLOSURE_STATUS_FINISHED_UNRESOLVED);

		Test.stopTest();

		c1 = [SELECT Id, Status, Portal_Closure_Status__c FROM Case WHERE Id = :c1.Id];
		
		System.assertEquals(CaseTriggerHelper.CASE_STATUS_CLOSED, c1.Status);
		System.assertEquals(CaseCommentAutoReply.CLOSURE_STATUS_FINISHED_UNRESOLVED, c1.Portal_Closure_Status__c);
	}

	
	@isTest
	public static void testCloseWithNewCase() {
		Case c1 = [SELECT Id, Status FROM Case WHERE Subject LIKE '%Test 1%' LIMIT 1];
		c1.Status = CaseTriggerHelper.CASE_STATUS_PENDING_CLOSURE;
		update c1;

		Test.startTest();

		PortalCasesCtrl.updateClosureStatus(c1.Id, CaseCommentAutoReply.CLOSURE_STATUS_ONGOING);
		PortalCasesCtrl.updateClosureStatus(c1.Id, CaseCommentAutoReply.CLOSURE_STATUS_FINISHED_NEW_CASE);

		Test.stopTest();

		c1 = [SELECT Id, Status, Portal_Closure_Status__c FROM Case WHERE Id = :c1.Id];

		System.assertEquals(CaseTriggerHelper.CASE_STATUS_CLOSED, c1.Status);
		System.assertEquals(CaseCommentAutoReply.CLOSURE_STATUS_FINISHED_NEW_CASE, c1.Portal_Closure_Status__c);

	}

	@isTest
	public static void testDeclineClosure() {
		Case c1 = [SELECT Id, Status FROM Case WHERE Subject LIKE '%Test 1%' LIMIT 1];
		c1.Status = CaseTriggerHelper.CASE_STATUS_PENDING_CLOSURE;
		update c1;

		Test.startTest();

		PortalCasesCtrl.updateClosureStatus(c1.Id, CaseCommentAutoReply.CLOSURE_STATUS_ONGOING);
		PortalCasesCtrl.updateClosureStatus(c1.Id, CaseCommentAutoReply.CLOSURE_STATUS_CLOSURE_DECLINED);
		
		Test.stopTest();

		c1 = [SELECT Id, Status, Portal_Closure_Status__c FROM Case WHERE Id = :c1.Id];

		System.assertEquals(CaseTriggerHelper.CASE_STATUS_ACTION_NEEDED, c1.Status);
		System.assertEquals(CaseCommentAutoReply.CLOSURE_STATUS_CLOSURE_DECLINED, c1.Portal_Closure_Status__c);
		
	}
	
	@isTest
	public static void testCloseResolved() {
		Case c1 = [SELECT Id, Status FROM Case WHERE Subject LIKE '%Test 1%' LIMIT 1];
		c1.Status = CaseTriggerHelper.CASE_STATUS_PENDING_CLOSURE;
		update c1;

		Test.startTest();

		PortalCasesCtrl.updateClosureStatus(c1.Id, CaseCommentAutoReply.CLOSURE_STATUS_ONGOING);
		PortalCasesCtrl.updateClosureStatus(c1.Id, CaseCommentAutoReply.CLOSURE_STATUS_FINISHED_RESOLVED);

		Test.stopTest();

		c1 = [SELECT Id, Status, Portal_Closure_Status__c FROM Case WHERE Id = :c1.Id];

		System.assertEquals(CaseTriggerHelper.CASE_STATUS_CLOSED, c1.Status);
		System.assertEquals(CaseCommentAutoReply.CLOSURE_STATUS_FINISHED_RESOLVED, c1.Portal_Closure_Status__c);
		
	}
	
}