/*
 * @author
 * Description: CW_ResultsPageSearchBarController Tests
 */
 @isTest
private class CW_ResultsPageSearchBarController_Test {
	/*
	* @author
	* Description: Get Certifications
	*/
	@isTest static void getCertifications (){
		List<ICG_Certification__c> Certifications = CW_ResultsPageSearchBarController.getCertifications();
	}
}