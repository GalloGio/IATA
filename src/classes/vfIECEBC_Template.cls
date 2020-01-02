public class vfIECEBC_Template extends vfIECEBC_Controller {
	public final EBC_Template__c tpl;

	public class ResourceNotReady_Exception extends Exception {
		public string filename;
	}

	public vfIECEBC_Template(ApexPages.StandardController stdController) {
		this.tpl = (EBC_Template__c)stdController.getRecord();
	}

	public static String getTemplateHtml(Id ebcTemplateId) {
		return getTemplateHtml(ebcTemplateId, false, null, null);
	}
	public static String exactTargetFooter = '<table cellpadding="2" cellspacing="0" width="600" ID="Table5" Border=0><tr><td><font face="verdana" size="1" color="#444444">This email was sent to:  %%emailaddr%% <br><br><b>Email Sent By:</b> %%Member_Busname%%<br>%%Member_Addr%% %%Member_City%%, %%Member_State%%, %%Member_PostalCode%%, %%Member_Country%%<br><br></font></td></tr></table><a href="%%profile_center_url%%" alias="Update Profile">Update Profile</a>';
	public static String getTemplateHtml(Id ebcTemplateId, Boolean includesExactTargetFooter, String googleAnalyticsId, String googleAnalyticsCampaignName) {
		String body;
		List<Attachment> atts = [SELECT Body,BodyLength,ContentType,Name FROM Attachment WHERE ParentId = :ebcTemplateId AND Name = 'template.html' LIMIT 1];
		if (atts.size() > 0) {
			body = replaceImagePlaceholders(atts[0].Body.toString());

			if (!String.isBlank(googleAnalyticsId)) {
				String pixelImage = '<img src="http://www.google-analytics.com/collect?v=1'
					+ '&tid=' + EncodingUtil.urlEncode(googleAnalyticsId, 'UTF-8')
					+ '&cid=%%SFID%%'
					+ '&t=event'
					+ '&ec=email'
					+ '&ea=open'
					+ '&el=recipient_id'
					+ '&cs=ebroadcast'
					+ '&cm=email'
					+ '&cn=' + EncodingUtil.urlEncode(googleAnalyticsCampaignName, 'UTF-8')
					+ '" />';
				body = body.replace('<!-- IATA_GOOGLEANALYTICS -->', pixelImage);
			}
		}


		return (!String.isBlank(body) ? body : 'No Content');
	}
	public static String regexImagePlaceholder = '\\{EBCResource\\{(00P[a-zA-Z0-9]{15})\\}/EBCResource\\}';
	public static String replaceImagePlaceholders(String body) {
		Pattern p = Pattern.compile(regexImagePlaceholder);
		Matcher mo = p.matcher(body);

		List<Id> attachmentIds = new List<Id>();
		while (mo.find()) {
			attachmentIds.add(mo.group(1));
		}

		Map<Id, Attachment> attachments = new Map<Id, Attachment>([Select Id, ParentId From Attachment Where Id in :attachmentIds]);
		Map<Id, Attachment> ebcResourceAttachment = new Map<Id, Attachment>();
		for(Id attachmentId : attachments.keySet()) {
			Attachment a = attachments.get(attachmentId);
			ebcResourceAttachment.put(a.ParentId, a);
		}
		List<EBC_Resource__c> ebcResources = [Select Id, Name, Image_URL__c, Is_Ready__c from EBC_Resource__c Where id in :ebcResourceAttachment.keySet()];
		Map<Id, String> attachmentIdToUrl = new Map<Id, String>();
		for(EBC_Resource__c res : ebcResources) {
			if(!res.Is_Ready__c) {
				ResourceNotReady_Exception e = new ResourceNotReady_Exception('The resource ' + res.Id + ' is not ready yet.');
				e.filename = res.Name;
				throw e;
			}
			Id attachmentId = ebcResourceAttachment.get(res.Id).Id;
			String url = res.Image_URL__c;
			attachmentIdToUrl.put(attachmentId, url);
		}

		mo = p.matcher(body);
		while (mo.find()) {
			if (!attachmentIdToUrl.containsKey(mo.group(1))) throw new ResourceMissing_Exception('Resource has been deleted.');
			body = body.replace(mo.group(), attachmentIdToUrl.get(mo.group(1)));

			mo = p.matcher(body);
		}

		return body;
	}

	public class ResourceMissing_Exception extends Exception {}

	public String getBody() {
		String body;
		try {
			body = getTemplateHtml(tpl.Id);
		} catch(ResourceNotReady_Exception e) {
			return 'The preview is not avaiable yet, please try again later.';
		}
		return body;
	}
}
