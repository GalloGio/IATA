/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest(seeAllData=true)
private class SISHelpDesk_CaseSLATracking_Test {
    
    private static Set<String> SIS_CaseStopStatus = new Set<String>{'Closed - pending customer approval','Closed'};    
    private static Set<String> SIS_KaleStopStatus = new Set<String>{'Onhold', 'Resolved', 'Closed'};       
    private static Set<String> kale_StopStatus = new Set<String>{'Onhold', 'Resolved', 'Closed', 'Waiting for customer feedback', 'Rejected', ''};
    private static final String Kale_BusinessHours_Name = 'SIS HelpDesk Kale';
    private static final String SIS_BusinessHours_Name = 'SIS Help Desk';
    
    static testMethod void updateSLA_Test() 
    {
        // Get Record Type Cases - SIS Help Desk ID
        ID sisHelpDeskCaseRecordTypeID = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'Cases_SIS_Help_Desk');
        
        List<BusinessHours> busiHours = [SELECT Id, Name FROM BusinessHours WHERE Name IN (:Kale_BusinessHours_Name, :SIS_BusinessHours_Name)];
        BusinessHours sisBusinessHours, kaleBusinessHours;
        System.debug('******************* ' + busiHours.size());
        System.debug('******************* ' + busiHours[0].Name);
        for (BusinessHours b : busiHours)
        { 
            if (b.Name == Kale_BusinessHours_Name)
                kaleBusinessHours = b;
            if (b.Name == SIS_BusinessHours_Name)
                sisBusinessHours = b;
        }
         
        //Create List of Case           
        Case case1 = new Case();
        case1.Status = 'Open';
        case1.Kale_Status__c = 'Open';
        case1.CaseArea__c = 'SIS';
       // case1.SuppliedEmail = 'email@noemail.com';
        case1.classification__c = 'Application Error';
        case1.Classification_SIS__c = 'Application Error'; 
        case1.Type = 'SIS Technical Problem';
        case1.Defect_Issue__c = 'SIS Solution is not working';     
        case1.Description = 'Case Area: SIS Case Classification: Application Error Case Type: SIS Technical Problem Case Defect/Issue: SIS Solution is not working';
        case1.RecordTypeId = sisHelpDeskCaseRecordTypeID;
        
        Case case2 = new Case();
        case2.Status = 'Open';
        case2.Kale_Status__c = 'Open';
        case2.CaseArea__c = 'SIS';
      //  case2.SuppliedEmail = 'email@noemail.com';
        case2.classification__c = 'Application Error';
        case2.Classification_SIS__c = 'Application Error'; 
        case2.Type = 'SIS Technical Problem';
        case2.Defect_Issue__c = 'Alerts are not / incorrectly delivered';
        case2.Description = 'Case Area: SIS Case Classification: Application Error Case Type: SIS Technical Problem Case Defect/Issue: Alerts are not / incorrectly delivered';
        case2.RecordTypeId = sisHelpDeskCaseRecordTypeID;
        
        Case case3 = new Case();
        case3.Status = 'Open';
        case3.Kale_Status__c = 'Open';
        case3.CaseArea__c = 'SIS';
        //case3.SuppliedEmail = 'email@noemail.com';
        case3.classification__c = 'New Feature';
        case3.Classification_SIS__c = 'New Feature'; 
        case3.Type = 'SIS Feature Request';
        case3.Defect_Issue__c = 'Request a New Feature';   
        case3.Description = 'Case Area: SIS Case Classification: New Feature Case Type: SIS Feature Request Case Defect/Issue: Request a New Feature';
        case3.RecordTypeId = sisHelpDeskCaseRecordTypeID;
        
        Case case4 = new Case();
        case4.Status = 'Escalated';
        case4.Kale_Status__c = 'Open';
        case4.CaseArea__c = 'SIS';
      //  case4.SuppliedEmail = 'email@noemail.com';
        case4.Description = 'Case Area: SIS';        
        case4.Classification_SIS__c = 'New Feature'; 
        case4.Type = 'SIS Feature Request';
        case4.Defect_Issue__c = 'Request a New Feature';
        case4.RecordTypeId = sisHelpDeskCaseRecordTypeID;
        
        List<Case> caseInserList = new List<Case>{case1, case2, case3};
        
        System.debug('++++++++++++++++++++++++++++ ' + case1.RecordTypeId + ' +++++ ' + case2.RecordTypeId + ' +++++ ' + case3.RecordTypeId);
        insert caseInserList;     
        System.debug('---------------------------- ' + case1.RecordTypeId + ' ----- ' + case2.RecordTypeId + ' ----- ' + case3.RecordTypeId);
        List<Case> sisCasesToUpdate = [SELECT Id, Status, Priority, SIS_SLATracking_LastUpdated__c, createdDate, HasSISCaseBeenClosed__c, 
                                       SIS_SLATracking__c, Kale_Status__c, Kale_SLATracking_LastUpdated__c, Kale_SLATracking__c
                                       FROM Case WHERE  CaseArea__c = 'SIS' AND RecordType.DeveloperName = 'Cases_SIS_Help_Desk'
                                       AND Status NOT IN :SIS_CaseStopStatus AND Kale_Status__c NOT IN :kale_StopStatus]; 
        case1.Kale_Status__c = 'On hold';
        case1.Status = 'Escalated';
        case2.Kale_Status__c = 'Open';
        case2.Status = 'Escalated';
        case3.Status = 'Closed - pending customer approval';
        
        List<Case> caseUpdateList = new List<Case>{case1, case2, case3};
        update caseUpdateList; 
        
        case1.Kale_Status__c = 'Open';
        update case1;        
        
    }
    
    static testMethod void schedulerSLAUpdateTest()
    {
        
        String min, hour, day, month;
        if ((datetime.now().minute() + 2) < 57)
        {
            min = '' + (datetime.now().minute() + 2);       
            hour = '' + datetime.now().hour();
        }
        else
        {
            min = '2';       
            hour = '' + (datetime.now().hour() + 1);
        }
        day = '' + datetime.now().day();
        month = '' + datetime.now().month();        
        Test.StartTest();
        System.schedule('SIS Help Desk Cases SLA Update Test',
                                        '0 ' + min + ' ' + hour + ' ' + day + ' ' + month + ' ?', 
                                        new SISHelpDeskSchedulerSLAUpdate());
        Test.StopTest();
    }
    
    static testMethod void addPriorityMapping() 
    {
        Priority_Mapping__c priorityMapping1 = new Priority_Mapping__c();
        priorityMapping1.Application__c = 'SIS Help Desk';
        priorityMapping1.Case_Classification__c = 'Classification';
        priorityMapping1.Case_Reason__c = 'Reason';
        priorityMapping1.Case_Type__c = 'Type';
        
        insert priorityMapping1;     
        
        priorityMapping1.Application__c = 'SIS Help Desk 2';
        
        update priorityMapping1;
    }
}