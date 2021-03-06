public with sharing class CW_ResultsPageSearchBarController {

	@AuraEnabled (cacheable = true)
	public static List<ICG_Certification__c> getCertifications(){
		List<String> listValidationPrograms = new List<String>();
		if(String.isNotBlank(CW_Utilities.VALIDATION_PROGRAMS)){
			listValidationPrograms = CW_Utilities.VALIDATION_PROGRAMS.split(',');
		}

		return [Select id, name, Label__c, Image__c, Image_Filename__c,Applicable_to__c from ICG_Certification__c WHERE is_visible__C = TRUE AND ValidationPrograms__c IN : listValidationPrograms ORDER BY Order__c]; //where isactive and more filters
	}
}