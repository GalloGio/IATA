public class EBC_Resource_TriggerHandler {
	public static Map<String, String> getFileNameToUrlMap(List<EBC_Resource__c> resources) {
		Map<String, String> filenameToUrl = new Map<String, String>();
		for(EBC_Resource__c resource : resources) {
			if (!String.isBlank(resource.Image_URL__c)) continue;
			if (resource.Name.lastIndexOf('.') == -1) continue;

			String filename = resource.Id;
			filename += resource.Name.substring(resource.Name.lastIndexOf('.'));

			filenameToUrl.put(filename, IECEBC_Utility.ebcSetup.E_Commerce_Base_Url__c + '/services/apexrest/Resources/' + resource.Id + '?client=exacttarget');
		}

		return filenameToUrl;
	}

	public static void triggerExactTargetDownloadRequest(List<EBC_Resource__c> resources) {
		//IECEBC_ETImage.getImageStatus(String fileName) .... is ready for realtime request.... and we are working on IECEBC_ETImage.getLastUpdate(String date) ..... executed by Cron Job.
		// Hi Mathieu, on a : IECEBC.ETImage.getLastUpdate() et IECEBC_LastImagesGetScheduled pretes pour le test , (Le test de notre coté ont donné timeout)
		//

		Map<String, String> filenameToUrl = getFileNameToUrlMap(resources);

		if (filenameToUrl.size() > 0) {
			triggerExactTargetDownloadRequest(filenameToUrl);
		}
	}

	@future (callout=true)
	public static void triggerExactTargetDownloadRequest(Map<String, String> filenameToUrl) {
		System.debug(filenameToUrl);
		if (!Test.isRunningTest()) IECEBC_ETPortfolioCreate.CreatePortfolioObject(filenameToUrl);
	}
}
