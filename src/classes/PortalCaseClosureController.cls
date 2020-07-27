public without sharing class PortalCaseClosureController {
	
	@AuraEnabled
	public static CloseCaseResult closeCase(String pageUrl) {
		PageReference pageRef = new PageReference(pageUrl);
		String parameters = pageRef.getParameters().get('c');
		CloseCaseLinkParams params = getParams(parameters);

		Case c = [SELECT Id, CaseNumber, Subject, Status, Portal_Closure_Status__c FROM Case WHERE Id = :params.caseId];
		CloseCaseResult result = new CloseCaseResult(c);

		Long validity = System.now().getTime() - params.generationTimestamp;
		validity = validity/(1000*60*60);
		if(validity <= 48 && c.Status == CaseTriggerHelper.CASE_STATUS_PENDING_CLOSURE && !CaseCommentAutoReply.CLOSURE_STATUS_FINISHED_VALUES.contains(c.Portal_Closure_Status__c)) {
			c.Portal_Closure_Status__c = CaseCommentAutoReply.CLOSURE_STATUS_FINISHED_RESOLVED;
			update c;
			result.setClosed();
		}
		
		return result;
	}

	@AuraEnabled
	public static Boolean ignoreSurvey(String caseId) {
		Case c = [SELECT Id, Instant_Survey_Feedback_requested__c FROM Case WHERE Id = :caseId LIMIT 1];
		c.Instant_Survey_Feedback_requested__c = true;
		update c;
		return true;
	}

	@AuraEnabled
	public static String answerSurvey(String caseId) {
		try {
			return PortalCasesCtrl.getSurveyLink(caseId);
		} catch(Exception e) {
			throw new AuraHandledException(Label.Case_Closure_Survey_Link_Error);
		}
	}

	public static CloseCaseLinkParams getParams(String urlParams) {
		urlParams = Encodingutil.urlDecode(PortalPasswordHandler.DecryptString(urlParams), 'UTF-8');
		urlParams = urlParams.replace(PortalPasswordHandler.plusReplacer,'+');
		CloseCaseLinkParams params = (CloseCaseLinkParams)JSON.deserialize(urlParams, CloseCaseLinkParams.class);
		return params;
	}

	public static String getCloseCaseLink(CloseCaseLinkParams params) {
		String paramsJson = JSON.serialize(params);
		paramsJson = paramsJson.replace('+', PortalPasswordHandler.plusReplacer);
		String encryptedStr = PortalPasswordHandler.EncryptString(paramsJson);
		String encodedPart = 'c=' + EncodingUtil.urlEncode(encryptedStr, 'UTF-8');

		String oneTimeUrl = 'case-closure' + '?' + encodedPart;
		return oneTimeUrl;
	}

	public class CloseCaseLinkParams {
		public String caseId {get; set;}
		public String contactId {get; set;}
		public Long generationTimestamp {get; set;}

		public CloseCaseLinkParams(String caseId, String contactId) {
			this.caseId = caseId;
			this.contactId = contactId;
			this.generationTimestamp = System.now().getTime();
		}
	}

	public class CloseCaseResult {
		@AuraEnabled public Boolean closed;
		@AuraEnabled public String caseId;
		@AuraEnabled public String caseNumber;
		@AuraEnabled public String caseSubject;

		public CloseCaseResult() {
			this.closed = false;
		}

		public CloseCaseResult(Case c) {
			this();
			this.caseId = c.Id;
			this.caseNumber = c.CaseNumber;
			this.caseSubject = c.Subject;
		}

		public void setClosed() {
			this.closed = true;
		}
		
	}

}