@isTest
public class AMS_OSCAR_SupportPanelTest {

    private static void setTestData(){
        
        PageReference pageRef = Page.AMS_OSCAR_SupportPanel;
        Test.setCurrentPage(pageRef);
        
        Id agencyRT = AMS_Utils.getId('Account', 'IATA_Agency');
        Account acc1 = new Account(RecordTypeId = agencyRT, Name='Test1 Account');
        insert acc1;
        
        AMS_OSCAR__c oscar = new AMS_OSCAR__c(STEP1__c = 'In Progress', Account__c = acc1.Id);
        insert oscar;
        
        //updating a OSCAR step will create a lifecycle event which is where the history is stored
        oscar.STEP12__c = 'Passed';
        oscar.STEP15__c = 'Passed';
        oscar.STEP25__c = 'Passed';
        oscar.STEP2__c = 'Passed';
        oscar.STEP1__c = 'Passed';
        update oscar;

        Map<string, Id> caseRT  =  TransformationHelper.RtIDsPerDeveloperNamePerObj(new list<string> {'Case'}).get('Case');
        
        Case c = new Case(OSCAR__c = oscar.Id, recordtypeid = caseRT.get('OSCAR_Communication'));
        insert c;
                
        Complaint__c cmplt = new Complaint__c(Complaint_Opened_Date__c=System.today(), Related_Case_Number__c=c.Id);
        insert cmplt;
        
    }    
    
    static testMethod void testRightPanelController() {
        
        setTestData();
        
        AMS_OSCAR__c oscar = [SELECT Id FROM AMS_OSCAR__c limit 1];
        
        Test.startTest();
        ApexPages.StandardController sc = new ApexPages.StandardController(oscar);
        AMS_OSCAR_SupportPanelController controller = new AMS_OSCAR_SupportPanelController(sc);
        Test.stopTest();
 
    }
    
    /*static testMethod void testRightPanelComplaints(){
        
        AMS_OSCAR__c oscar = new AMS_OSCAR__c();
        insert oscar;
        
        oscar = [SELECT Id FROM AMS_OSCAR__c limit 1];
        
        Case c = new Case(OSCAR__c = oscar.Id);
        insert c;*/
        /*setTestData();
        AMS_OSCAR__c oscar = [SELECT Id FROM AMS_OSCAR__c limit 1];
        
        Test.startTest();
        AMS_OSCAR_ComplaintsController controller = new AMS_OSCAR_ComplaintsController();
        controller.intVal = new AMS_IntegerCarrier();
        controller.oscarId = oscar.Id;
        controller.getComplaints();
        Test.stopTest();
        
    }*/
    
    static testMethod void testRightPanelHistory(){

        setTestData();
        
        Test.startTest();
        AMS_OSCAR_HistoryController controller = new AMS_OSCAR_HistoryController();
        controller.nhist = new AMS_IntegerCarrier();
        controller.getOSCARHistory();
        Test.stopTest();
        
    }
    
    static testMethod void AMS_OSCAR_RelatedCasesController(){
        
        setTestData();
        
        Test.startTest();
        AMS_OSCAR_RelatedCasesController controller = new AMS_OSCAR_RelatedCasesController();
        controller.intVal = new AMS_IntegerCarrier();
        controller.getcases();
        controller.createNewCase();
        Test.stopTest();
        
    }

    static testMethod void AMS_OSCAR_CommunicationController(){
        setTestData();

        AMS_OSCAR__c oscar = [select id from AMS_OSCAR__c];

        ApexPages.CurrentPage().getparameters().put('pid', oscar.id);
        ApexPages.StandardController sc = new ApexPages.standardController(oscar);

        Test.startTest();
        AMS_OSCAR_CommunicationController oscarctrl = new AMS_OSCAR_CommunicationController(sc);
        Test.stopTest();
    }

}