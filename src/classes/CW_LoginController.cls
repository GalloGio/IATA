public without sharing class CW_LoginController {
	public String portalUrl { get; set; }
	public String serviceId { get; set; }
	public String selfRegisterUrl { get; set; }

	public CW_LoginController() {
		portalUrl = 'https://' + ISSP_Constant.customSetingMap.get('HostCSP');
		if (String.isNotBlank(portalUrl)) {
			portalUrl = portalUrl.removeEnd('/');
		}
		serviceId = getOneSourceServiceId();
		selfRegisterUrl = getSelfRegisterUrl();
	}

	@AuraEnabled(cacheable=true)
	public static String getOneSourceServiceId() {
		List<Portal_Applications__c> oneSourceApp = [SELECT Id FROM Portal_Applications__c WHERE Name = 'One Source' LIMIT 1];
		if (!oneSourceApp.isEmpty()) {
			return oneSourceApp[0].Id;
		}
		return null;
	}

	@AuraEnabled(cacheable=true)
	public static String getSelfRegisterUrl() {
		String url = ISSP_Constant.customSetingMap.get('HostCSP');
		String serviceId = getOneSourceServiceId();

		if (String.isNotBlank(url) && String.isNotBlank(serviceId)) {
			url += 'login/SelfRegister?sourceService=' + serviceId;
			if (!url.startsWithIgnoreCase('https://')) {
				url = 'https://' + url;
			}
		}
		return url;
	}
}