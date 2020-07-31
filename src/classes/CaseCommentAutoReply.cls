public with sharing class CaseCommentAutoReply implements Queueable {

	public static final String AUTO_REPLY_ID = 'Auto-Reply:';
	public static final String USER_ANSWER_ID = 'User-Answer:';
	
	public static final String AUTO_REPLY_HAVE_BEEN_RESOLVED = 'Have_been_resolved_question';
	public static final String AUTO_REPLY_NEED_MORE_HELP = 'Need_more_help_question';
	public static final String AUTO_REPLY_SURVEY = 'Case_survey_message';
	public static final String AUTO_REPLY_PROVIDE_ADITIONAL_COMMENTS = 'Provide_aditional_comments';
	
	public static final String CLOSURE_STATUS_STARTED = 'Started';
	public static final String CLOSURE_STATUS_ONGOING = 'Ongoing';
	public static final String CLOSURE_STATUS_FINISHED_RESOLVED = 'Finished_Resolved';
	public static final String CLOSURE_STATUS_FINISHED_UNRESOLVED = 'Finished_Unresolved';
	public static final String CLOSURE_STATUS_FINISHED_NEW_CASE = 'Finished_New_Case';
	public static final String CLOSURE_STATUS_CLOSURE_DECLINED = 'Closure_Declined';
	
	public static final List<String> AUTO_REPLY_ELIGIBLE_STATUS = new List<String> {
		CLOSURE_STATUS_STARTED, CLOSURE_STATUS_ONGOING, CLOSURE_STATUS_FINISHED_RESOLVED, CLOSURE_STATUS_FINISHED_UNRESOLVED, CLOSURE_STATUS_CLOSURE_DECLINED
	};
	
	public static final List<String> CLOSURE_STATUS_FINISHED_VALUES = new List<String> {
		CLOSURE_STATUS_FINISHED_RESOLVED, CLOSURE_STATUS_FINISHED_UNRESOLVED, CLOSURE_STATUS_FINISHED_NEW_CASE
	};
	
	public static List<Id> processedIds = new List<Id>();
	
	private List<Id> caseIds;
	
	public CaseCommentAutoReply(List<Id> ids) {
		this.caseIds = ids;
		if (ids != null) {
			processedIds.addAll(ids);
		}
	}
	
	public void execute(QueueableContext context) {
		List<CaseComment> toInsert = new List<CaseComment>();
		List<Notification__c> notifications = new List<Notification__c>();
		Map<String, List<String>> fieldBindingByGroupMap = new Map<String, List<String>>();
		
		for (Case current : [SELECT Id, Portal_Closure_Status__c, ContactId FROM Case WHERE Id IN :this.caseIds]) {
			if (AUTO_REPLY_ELIGIBLE_STATUS.contains(current.Portal_Closure_Status__c)) {
				String commentBody = AUTO_REPLY_ID + ' ';
				
				if (current.Portal_Closure_Status__c == CLOSURE_STATUS_STARTED) {
					commentBody += AUTO_REPLY_HAVE_BEEN_RESOLVED;
					fieldBindingByGroupMap.put(current.ContactId, new List<String> { (Label.CSP_PortalBaseURL + Label.CSP_PortalPath), current.Id });
				} else if (current.Portal_Closure_Status__c == CLOSURE_STATUS_ONGOING) {
					commentBody += AUTO_REPLY_NEED_MORE_HELP;
				} else if (current.Portal_Closure_Status__c == CLOSURE_STATUS_CLOSURE_DECLINED) {
					commentBody += AUTO_REPLY_PROVIDE_ADITIONAL_COMMENTS;
				} else if (current.Portal_Closure_Status__c == CLOSURE_STATUS_FINISHED_RESOLVED
					|| current.Portal_Closure_Status__c == CLOSURE_STATUS_FINISHED_UNRESOLVED) {
					commentBody += AUTO_REPLY_SURVEY;
				}
				
				CaseComment comment = new CaseComment();
				comment.ParentId = current.Id;
				comment.CommentBody = commentBody;
				comment.IsPublished = true;
				toInsert.add(comment);
			}
			
		}
		
		if (!toInsert.isEmpty()) {
			Database.insert(toInsert);
		}
		if (!fieldBindingByGroupMap.isEmpty()) {
			String templateName;
			if(Test.isRunningTest()){
				templateName = [SELECT Name FROM Notification_template__c LIMIT 1].Name;
			}
			else {
				templateName = Label.Case_Comment_Notification_Template_Name;
			}
			System.debug('CMS :: reading name: ' + templateName);
			Notification_template__c template = [SELECT Id, Name, Message__c, Subject__c, Language__c, Expire_in_days__c, Alert_Contact_By_Email__c,
													 Type__c, Notification_color__c, CriticalNotification__c
												 FROM Notification_template__c
												 WHERE Name = :templateName
												 LIMIT 1];
			
			List<Contact> contacts = new List<Contact>();
			for (String contactId : fieldBindingByGroupMap.keySet()) {
				contacts.add(new Contact(Id = contactId));
			}
			
			ISSP_NotificationUtilities.sendNotification(contacts, template, null, fieldBindingByGroupMap, 'Id');
		}
		
	}
	
	public static Boolean isProcessed(Id caseId) {
		/* if(processedIds.contains(caseId)) {
		 * return true;
		 * }
		 * processedIds.add(caseId);
		 * return false; */
		return processedIds.contains(caseId);
	}
	
}