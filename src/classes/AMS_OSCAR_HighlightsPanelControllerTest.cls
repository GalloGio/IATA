@isTest
private class AMS_OSCAR_HighlightsPanelControllerTest {

    @testSetup static void setup(){
		AMS_OSCAR_TestDataFactory.createOSCARtestData();
    }
    
    static testMethod void test_OscarController() {
        Case cse = [SELECT Id, OSCAR__c FROM Case WHERE OSCAR__c != '' limit 1];
       
        PageReference oscarPage = Page.AMS_OSCAR_HighlightsPanel;
        oscarPage.getParameters().put('id', String.valueOf(cse.OSCAR__c));
       Test.setCurrentPage(oscarPage);
        
        Test.startTest();
       
        AMS_OSCAR_HightlightsPanelController oscarCon = new AMS_OSCAR_HightlightsPanelController();
        oscarCon.saveStatus();
        oscarCon.cancelStatus();

        Test.stopTest();
    }

    static testMethod void test_CaseController() {
        Case cse = [SELECT Id, OSCAR__c FROM Case WHERE OSCAR__c != '' limit 1];
       
        PageReference casePage = Page.AMS_OSCAR_HighlightsPanel;
        casePage.getParameters().put('id', String.valueOf(cse.Id));
        Test.setCurrentPage(casePage);
        
        Test.startTest();

        AMS_OSCAR_HightlightsPanelController caseCon = new AMS_OSCAR_HightlightsPanelController();

        //create error to test exception
        caseCon.theOSCAR.Type_of_Change__c = '';
        caseCon.theOSCAR.Apply_Penalty_Fee__c = true;
        caseCon.saveStatus();

        Test.stopTest();
        
    }
}