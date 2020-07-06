public without sharing class PortalCaseClosureController {
	
	@AuraEnabled
	public static Boolean closeCase(String pageUrl) {
		PageReference pageRef = new PageReference(pageUrl);
		String parameters     = pageRef.getParameters().get('c');
		CloseCaseLinkParams params = getParams(parameters);

		Long validity = System.now().getTime() - params.generationTimestamp;
		validity = validity/(1000*60*60);
		if(validity > 48) {
			throw new AuraHandledException('Link expired.');
		}

		Case c = [SELECT Id, CaseNumber, Status, Portal_Closure_Status__c FROM Case WHERE Id = :params.caseId];
		if(c.Status !=CaseTriggerHelper.CASE_STATUS_CLOSED && (c.Portal_Closure_Status__c != CaseCommentAutoReply.CLOSURE_STATUS_STARTED || c.Portal_Closure_Status__c != CaseCommentAutoReply.CLOSURE_STATUS_ONGOING)) {
			throw new AuraHandledException('Cannot close this case');
		}

		c.Portal_Closure_Status__c = CaseCommentAutoReply.CLOSURE_STATUS_FINISHED_RESOLVED;
		update c;

		return true;
	}

	public static CloseCaseLinkParams getParams(String urlParams) {
		urlParams = EncodingUtil.urlDecode(urlParams, 'UTF-8');
		urlParams = PortalPasswordHandler.DecryptString(urlParams);
		urlParams = urlParams.replace(PortalPasswordHandler.plusReplacer,'+');
		CloseCaseLinkParams params = (CloseCaseLinkParams)JSON.deserialize(urlParams, CloseCaseLinkParams.class);
		return params;
	}

	public static String getCloseCaseLink(CloseCaseLinkParams params) {
		String paramsJson = JSON.serialize(params);
		paramsJson = paramsJson.replace('+', PortalPasswordHandler.plusReplacer);
		String encryptedStr = PortalPasswordHandler.EncryptString(paramsJson);
		String encodedPart = 'c=' + EncodingUtil.urlEncode(encryptedStr, 'UTF-8');

		String prefix = '';
		if(Network.getNetworkId() != null) prefix = Network.getLoginURL(Network.getNetworkId()).substring(0,Network.getLoginURL(Network.getNetworkId()).lastIndexOf('/'));
		String oneTimeUrl = prefix + '/' + 'case-closure' + '?' + encodedPart;
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

}