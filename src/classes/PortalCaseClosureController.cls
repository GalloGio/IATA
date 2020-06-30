public without sharing class PortalCaseClosureController {
	
	@AuraEnabled
	public static Boolean closeCase(String pageUrl) {
		PageReference pageRef = new PageReference(pageUrl);
		String parameters     = pageRef.getParameters().get('c');
		CloseCaseLinkParams params = getParams(parameters);

		Case c = [SELECT Id, CaseNumber, Status, Portal_Closure_Status__c FROM Case WHERE Id = :params.caseId];
		c.Portal_Closure_Status__c = CaseCommentAutoReply.CLOSURE_STATUS_FINISHED_RESOLVED;
		update c;

		return true;
	}

	public static CloseCaseLinkParams getParams(String urlParams) {
		System.debug('1: ' + urlParams);
		urlParams = EncodingUtil.urlDecode(urlParams, 'UTF-8');
		System.debug('2: ' + urlParams);
		urlParams = PortalPasswordHandler.DecryptString(urlParams);
		System.debug('3: ' + urlParams);
		urlParams = urlParams.replace(PortalPasswordHandler.plusReplacer,'+');
		System.debug('4: ' + urlParams);
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

		public CloseCaseLinkParams(String caseId, String contactId) {
			this.caseId = caseId;
			this.contactId = contactId;
		}
	}

}