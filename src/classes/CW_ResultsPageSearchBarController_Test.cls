@isTest
private class CW_ResultsPageSearchBarController_Test {
    @isTest static void getCertifications (){
        List<ICG_Certification__c> Certifications = CW_ResultsPageSearchBarController.getCertifications();
    }
}