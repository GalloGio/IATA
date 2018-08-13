@isTest
private class AMS_OSCAR_ProcessViewerControllerTest {

    @testSetup static void setup(){
        AMS_OSCAR_TestDataFactory.createOSCARtestData();
        
        AMS_OSCAR__c oscar = [SELECT Id, Account__c, STEP8__c, STEP9__c, STEP10__c, STEP2__c, STEP6__c, STEP11__c, STEP15__c FROM AMS_OSCAR__c limit 1];
        
        System.assertEquals('Not Started', oscar.STEP8__c);
        System.assertEquals('Not Started', oscar.STEP9__c);
        System.assertEquals('Passed', oscar.STEP10__c);
        System.assertEquals('Not Started', oscar.STEP2__c);
        System.assertEquals('Not Started', oscar.STEP6__c);
        System.assertEquals('Not Started', oscar.STEP11__c);
        System.assertEquals('Not Started', oscar.STEP15__c);    
    }
    
    @isTest static void test_ProcessViewer() {
    
        Boolean result;
        String stringResult;
        AMS_OSCAR__c oscar = [SELECT Id, Account__c, STEP8__c, STEP9__c, STEP10__c, STEP2__c, STEP6__c, STEP11__c, STEP15__c,Step34__c, Step35__c FROM AMS_OSCAR__c limit 1];

        System.assertEquals('Not Started', oscar.STEP8__c);
        System.assertEquals('Not Started', oscar.STEP9__c);
        System.assertEquals('Passed', oscar.STEP10__c);
        System.assertEquals('Not Started', oscar.STEP2__c);
        System.assertEquals('Not Started', oscar.STEP6__c);
        System.assertEquals('Not Started', oscar.STEP11__c);
        System.assertEquals('Not Started', oscar.STEP15__c);

        oscar.STEP8__c = 'Passed';
        oscar.STEP9__c = 'Failed';
        oscar.STEP10__c = 'Not Applicable';
        oscar.STEP2__c = 'Late';
        oscar.STEP6__c = 'In Progress';
        oscar.STEP11__c = 'Not Started';
        oscar.STEP15__c = 'Something else';
        oscar.STEP12__c = 'Something else';
        
        update oscar;
        
        Test.startTest();

        PageReference pageAMS_OSCAR_ProcessViewer = Page.AMS_OSCAR_ProcessViewer;
        pageAMS_OSCAR_ProcessViewer.getParameters().put('Id', oscar.Id);
        Test.setCurrentPage(pageAMS_OSCAR_ProcessViewer);

        //ApexPages.StandardController sc = new ApexPages.StandardController(oscar);
        AMS_OSCAR_ProcessViewerController controller = new AMS_OSCAR_ProcessViewerController();
        
        Boolean isNotNewGenProcessValue = controller.isNotNewGenProcess;

        result = controller.showRequiredOverlay;
        stringResult = controller.getEffectiveDate();
        result = controller.getIsAgencyChange();
        result = controller.isNewGenHEProcess;
        result = controller.isAnalystProfile;
        /* commented as per NEWGEN-3301
        result = controller.canBeDisplayed('Is_PCI_compliant__c',AMS_Utils.NGCORRECTION,'Corporate Card');
        result = controller.canBeDisplayed('Is_PCI_compliant__c',AMS_Utils.NEWHELITE,'Corporate Card');
        result = controller.canBeDisplayed('AnotherStuff',AMS_Utils.NGCORRECTION,'Corporate Card');
        */
        Test.stopTest();
    }
    
    @isTest static void test_ProcessViewer_2() {
        Test.startTest();
        AMS_OSCAR_ProcessViewerController ctr = new AMS_OSCAR_ProcessViewerController();
        ctr.checkAMSRemittance(new AMS_OSCAR__c());
        Test.stopTest();
    }

    @isTest static void test_ProcessViewer2() {

        Test.startTest();
        AMS_OSCAR_ProcessViewerController controller = new AMS_OSCAR_ProcessViewerController();
        Boolean a1 = controller.isToRemoveFieldsUI;
        Boolean a2 = controller.isPCICompliant;
        Set<String> a3 = controller.processToRemoveFields;
        Test.stopTest();
    }

}