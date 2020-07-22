public with sharing class CW_ResultsPageSearchBarController {
	@AuraEnabled (cacheable = true)
	public static List<ICG_Certification__c> getCertifications(){
		return [Select id, name, Image__c, Image_Filename__c,Applicable_to__c from ICG_Certification__c WHERE is_visible__C = TRUE ORDER BY Order__c]; //where isactive and more filters
	}
}