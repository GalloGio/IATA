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
		ICG_Certification__c certOne = CW_TestDataFactory.newCertification();
		insert certOne;

		List<ICG_Certification__c> Certifications = CW_ResultsPageSearchBarController.getCertifications();
		system.assertNotEquals(Certifications.size(), 0);
	}
}