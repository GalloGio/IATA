@isTest
private class AMS_OSCAR_HighlightsPanelControllerTest {

    @testSetup static void setup(){
		AMS_OSCAR_TestDataFactory.createOSCARtestData();
    }
    
    @isTest static void test_method_one() {
        AMS_OSCAR__c oscar = [SELECT Id, Account__c FROM AMS_OSCAR__c limit 1];
       
       	PageReference pageRef = Page.AMS_OSCAR_HighlightsPanel;
        pageRef.getParameters().put('id', String.valueOf(oscar.Id));
		Test.setCurrentPage(pageRef);
        
        Test.startTest();
       
        AMS_OSCAR_HightlightsPanelController controller = new AMS_OSCAR_HightlightsPanelController();
        controller.saveStatus();
        controller.cancelStatus();

        Test.stopTest();
    }
}