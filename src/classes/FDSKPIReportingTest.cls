@IsTest(SeeAllData=false)
private class FDSKPIReportingTest {

    private static final String CASE_COMMENT_ACTION = 'Public Case Comment';
    private static final String CASE_ACTION_CASE_CLOSURE = 'Case Closure';
    public static final String CASE_ACTION_CASE_ESCALATION = 'Case Escalation';
    public static final String CASE_ACTION_CASE_REOPENING = 'Case Reopening';
    public static final String CASE_ACTION_SEND_NOI = 'Send NOI';
    public static final String CASE_ACTION_CREATING_A_TASK = 'Creating a Task';
    
    private static void setupReportings() {
        List<String> actionTypes = new List<String>{CASE_ACTION_CASE_CLOSURE, 
            CASE_ACTION_CASE_ESCALATION, CASE_ACTION_CASE_REOPENING, CASE_ACTION_SEND_NOI, CASE_COMMENT_ACTION, 
            CASE_ACTION_CREATING_A_TASK};
                List<FDS_KPI_Reporting__c> kpiReportingsToInsert = new List<FDS_KPI_Reporting__c>();
        String cscRTId = [SELECT Id FROM RecordType WHERE sObjectType = 'FDS_KPI_Reporting__c' and DeveloperName = 'CSC' LIMIT 1].Id;
        
        for(String actionType: actionTypes) {
            FDS_KPI_Reporting__c newKPIReporting = new FDS_KPI_Reporting__c();
            newKPIReporting.Type_Of_Action__c = actionType;
            newKPIReporting.Name = actionType;
            newKPIReporting.RecordTypeId = cscRTId;
            
            kpiReportingsToInsert.add(newKPIReporting);
        }
        
        try{
            if(kpiReportingsToInsert.size() > 0 ){
                insert kpiReportingsToInsert;
            }
            
        } catch (DmlException e) {
            System.debug('DML Exception: ' + e.getMessage());
        }
    }
    
    private static void setup(){
        setupReportings();
        Account a = ISSP_ObjectFactory.createNewAccount();
        a.BillingCity = 'test';
        a.Name = 'test';
        insert a;

        Contact contact = ISSP_ObjectFactory.createNewContact();
        contact.AccountId= a.Id;
        contact.Email = 'test@test.com';
        insert contact;

        RecordType RT = [SELECT Id FROM RecordType WHERE sObjectType = 'Case' AND DeveloperName = 'Cases_Global' LIMIT 1];

        Case caseOpened = new Case();
        caseOpened.Status = 'Action Needed';
        caseOpened.RecordtypeId = RT.Id;
        caseOpened.ContactId = contact.Id;
        caseOpened.AccountId = contact.AccountId;
        caseOpened.NOI_sent__c = null;
        insert caseOpened;
    }

    private static void setup2(){
        setupReportings();
        Account a = ISSP_ObjectFactory.createNewAccount();
        a.BillingCity = 'test';
        a.Name = 'test';
        insert a;

        Contact contact = ISSP_ObjectFactory.createNewContact();
        contact.AccountId= a.Id;
        contact.Email = 'test@test.com';
        insert contact;

        RecordType RT = [SELECT Id FROM RecordType WHERE sObjectType = 'Case' AND DeveloperName = 'Cases_Global' LIMIT 1];

        Case caseOpened = new Case();
        caseOpened.Status = 'Action Needed';
        caseOpened.RecordtypeId = RT.Id;
        caseOpened.ContactId = contact.Id;
        caseOpened.AccountId = contact.AccountId;
        caseOpened.NOI_sent__c = null;
        insert caseOpened;

        Case caseOpened2 = new Case();
        caseOpened2.Status = 'Action Needed';
        caseOpened2.RecordtypeId = RT.Id;
        caseOpened2.ContactId = contact.Id;
        caseOpened2.AccountId = contact.AccountId;
        caseOpened2.NOI_sent__c = null;
        insert caseOpened2;
    }
    
    

    static testMethod void testSetup() {

        setup();
        System.assertEquals(1, [SELECT ID FROM Account WHERE Name = 'test'].size());
        System.assertEquals(1, [SELECT ID FROM Contact WHERE Email = 'test@test.com'].size());
        System.assertEquals(1, [SELECT ID FROM Case].size());

    }

    static testMethod void testMonthNumberToText() {
        //CaseCommentHandler
        System.assertEquals('January', CaseCommentHandler.convertMonthNumberToText(1));
        System.assertEquals('February', CaseCommentHandler.convertMonthNumberToText(2));
        System.assertEquals('March', CaseCommentHandler.convertMonthNumberToText(3));
        System.assertEquals('April', CaseCommentHandler.convertMonthNumberToText(4));
        System.assertEquals('May', CaseCommentHandler.convertMonthNumberToText(5));
        System.assertEquals('June', CaseCommentHandler.convertMonthNumberToText(6));
        System.assertEquals('July', CaseCommentHandler.convertMonthNumberToText(7));
        System.assertEquals('August', CaseCommentHandler.convertMonthNumberToText(8));
        System.assertEquals('September', CaseCommentHandler.convertMonthNumberToText(9));
        System.assertEquals('October', CaseCommentHandler.convertMonthNumberToText(10));
        System.assertEquals('November', CaseCommentHandler.convertMonthNumberToText(11));
        System.assertEquals('December', CaseCommentHandler.convertMonthNumberToText(12));
        System.assertEquals('incorrect month', CaseCommentHandler.convertMonthNumberToText(13));

        //CaseTriggerHelper
        System.assertEquals('January', CaseTriggerHelper.convertMonthNumberToText(1));
        System.assertEquals('February', CaseTriggerHelper.convertMonthNumberToText(2));
        System.assertEquals('March', CaseTriggerHelper.convertMonthNumberToText(3));
        System.assertEquals('April', CaseTriggerHelper.convertMonthNumberToText(4));
        System.assertEquals('May', CaseTriggerHelper.convertMonthNumberToText(5));
        System.assertEquals('June', CaseTriggerHelper.convertMonthNumberToText(6));
        System.assertEquals('July', CaseTriggerHelper.convertMonthNumberToText(7));
        System.assertEquals('August', CaseTriggerHelper.convertMonthNumberToText(8));
        System.assertEquals('September', CaseTriggerHelper.convertMonthNumberToText(9));
        System.assertEquals('October', CaseTriggerHelper.convertMonthNumberToText(10));
        System.assertEquals('November', CaseTriggerHelper.convertMonthNumberToText(11));
        System.assertEquals('December', CaseTriggerHelper.convertMonthNumberToText(12));
        System.assertEquals('incorrect month', CaseTriggerHelper.convertMonthNumberToText(13));

        //TaskTriggerHelper
        System.assertEquals('January', TaskTriggerHelper.convertMonthNumberToText(1));
        System.assertEquals('February', TaskTriggerHelper.convertMonthNumberToText(2));
        System.assertEquals('March', TaskTriggerHelper.convertMonthNumberToText(3));
        System.assertEquals('April', TaskTriggerHelper.convertMonthNumberToText(4));
        System.assertEquals('May', TaskTriggerHelper.convertMonthNumberToText(5));
        System.assertEquals('June', TaskTriggerHelper.convertMonthNumberToText(6));
        System.assertEquals('July', TaskTriggerHelper.convertMonthNumberToText(7));
        System.assertEquals('August', TaskTriggerHelper.convertMonthNumberToText(8));
        System.assertEquals('September', TaskTriggerHelper.convertMonthNumberToText(9));
        System.assertEquals('October', TaskTriggerHelper.convertMonthNumberToText(10));
        System.assertEquals('November', TaskTriggerHelper.convertMonthNumberToText(11));
        System.assertEquals('December', TaskTriggerHelper.convertMonthNumberToText(12));
        System.assertEquals('incorrect month', TaskTriggerHelper.convertMonthNumberToText(13));

    }

    static testMethod void testNewCommentKPIReporting() {

        setup();

        Test.startTest();

        String caseId = [SELECT ID FROM Case LIMIT 1].Id;

        try {
            CaseComment caseComment = new CaseComment(
                    ParentId=caseId,
                    IsPublished = true
            );
            insert caseComment;
            //System.assert(false, 'Error expected');
        } catch(Exception e) {
            System.assert(false);
        }

        Test.stopTest();

        //for verification
        List<FDS_KPI_Reporting__c> kpiReportings = [SELECT Id, Type_Of_Action__c FROM FDS_KPI_Reporting__c WHERE Type_Of_Action__c = 'Public Case Comment'];
        List<KPI_Value__c> kpiValues = [SELECT ID, CaseNumber__c, FDS_KPI_Reporting__c, Responsible__c, KPI_Value__c FROM KPI_Value__c];

        //verify parent record
        System.assertEquals(1, kpiReportings.size());
        System.assertEquals(CASE_COMMENT_ACTION, kpiReportings.get(0).Type_Of_Action__c);

        //verify child
        System.assertEquals(1, kpiValues.size());
        System.assertEquals(kpiValues.get(0).Responsible__c, UserInfo.getUserId());
        System.assertEquals(kpiValues.get(0).CaseNumber__c, caseId);
        System.assertEquals(kpiValues.get(0).FDS_KPI_Reporting__c, kpiReportings.get(0).Id);
        System.assertEquals(true, kpiValues.get(0).KPI_Value__c != null );


    }

    static testMethod void testNew2CommentsKPIReporting() {

        setup();

        Test.startTest();

        String caseId = [SELECT ID FROM Case LIMIT 1].Id;

        try {
            CaseComment caseComment = new CaseComment(
                    ParentId=caseId,
                    IsPublished = true
            );
            insert caseComment;
        } catch(Exception e) {
            System.assert(false);
        }

        try {
            CaseComment caseComment = new CaseComment(
                    ParentId=caseId,
                    IsPublished = true
            );
            insert caseComment;
        } catch(Exception e) {
            System.assert(false);
        }

        Test.stopTest();

        //for verification
        List<FDS_KPI_Reporting__c> kpiReportings = [SELECT Id, Type_Of_Action__c FROM FDS_KPI_Reporting__c WHERE Type_Of_Action__c = 'Public Case Comment'];
        List<KPI_Value__c> kpiValues = [SELECT ID, CaseNumber__c, FDS_KPI_Reporting__c, Responsible__c, KPI_Value__c FROM KPI_Value__c];

        //verify parent record
        System.assertEquals(1, kpiReportings.size());
        System.assertEquals(CASE_COMMENT_ACTION, kpiReportings.get(0).Type_Of_Action__c);

        //verify child
        System.assertEquals(2, kpiValues.size());
        System.assertEquals(kpiValues.get(0).Responsible__c, UserInfo.getUserId());
        System.assertEquals(kpiValues.get(0).CaseNumber__c, caseId);
        System.assertEquals(kpiValues.get(0).FDS_KPI_Reporting__c, kpiReportings.get(0).Id);
        System.assertEquals(true, kpiValues.get(0).KPI_Value__c != null );
    }

    static testMethod void testCaseClosureKPIReporting(){

        setup();

        Case caseToProcess = [SELECT Id, Status, RecordTypeId, Reason1__c FROM Case LIMIT 1];

        try{
            caseToProcess.Status = 'Closed';
            caseToProcess.Reason1__c = 'New Account request';
            update caseToProcess;
        } catch(Exception e) {
            System.debug('LW ERROR: ' + e.getMessage());
        }

        //for verification
        List<FDS_KPI_Reporting__c> kpiReportings = [SELECT Id, Type_Of_Action__c FROM FDS_KPI_Reporting__c WHERE Type_Of_Action__c = 'Case Closure'];
        List<KPI_Value__c> kpiValues = [SELECT ID, CaseNumber__c, FDS_KPI_Reporting__c, Responsible__c, KPI_Value__c FROM KPI_Value__c];
        
        System.debug('+++ kpi values: '+ kpiValues);
        System.debug('+++ cases: ' + [SELECT Id, Status FROM Case]);
        //verify parent record
        System.assertEquals(CASE_ACTION_CASE_CLOSURE, kpiReportings.get(0).Type_Of_Action__c);

        //verify child
        System.assertEquals(1, kpiValues.size());
        System.assertEquals(kpiValues.get(0).Responsible__c, UserInfo.getUserId());
        System.assertEquals(kpiValues.get(0).CaseNumber__c, caseToProcess.Id);
        System.assertEquals(kpiValues.get(0).FDS_KPI_Reporting__c, kpiReportings.get(0).Id);
        System.assertEquals(true, kpiValues.get(0).KPI_Value__c != null );


    }

    static testMethod void testCaseClosureKPIReporting2(){
        setup2();

        Test.startTest();

        List<Case> casesToProcess = [SELECT Id, Status, Reason1__c FROM Case];

        for(Case cas : casesToProcess){
            cas.Status = 'Closed';
            cas.Reason1__c = 'New Account request';
        }

        update casesToProcess;
        CaseTriggerHelper.isDone = true;
        Test.stopTest();

        //for verification
        List<FDS_KPI_Reporting__c> kpiReportings = [SELECT Id, Type_Of_Action__c FROM FDS_KPI_Reporting__c WHERE Type_Of_Action__c = 'Case Closure'];
        List<KPI_Value__c> kpiValues = [SELECT ID, CaseNumber__c, FDS_KPI_Reporting__c, Responsible__c, KPI_Value__c FROM KPI_Value__c];

        //verify child
        System.assertEquals(2, kpiValues.size());
        System.assertEquals(kpiValues.get(0).Responsible__c, UserInfo.getUserId());
        System.assertEquals(kpiValues.get(0).FDS_KPI_Reporting__c, kpiReportings.get(0).Id);
        System.assertEquals(true, kpiValues.get(0).KPI_Value__c != null );
    }

    static testMethod void testCaseEscalatedKPIReporting(){

        setup();

        Case caseToProcess = [SELECT Id, Status, RecordTypeId, Reason1__c FROM Case LIMIT 1];

        try{
            caseToProcess.Status = 'Escalated Internally';
            //caseToProcess.Reason1__c = 'New Account request';
            update caseToProcess;
        } catch(Exception e) {
            System.debug('LW ERROR: ' + e.getMessage());
        }

        //for verification
        List<FDS_KPI_Reporting__c> kpiReportings = [SELECT Id, Type_Of_Action__c FROM FDS_KPI_Reporting__c WHERE Type_Of_Action__c = 'Case Escalation'];
        List<KPI_Value__c> kpiValues = [SELECT ID, CaseNumber__c, FDS_KPI_Reporting__c, Responsible__c, KPI_Value__c FROM KPI_Value__c];

        //verify parent record
        System.assertEquals(CASE_ACTION_CASE_ESCALATION, kpiReportings.get(0).Type_Of_Action__c);

        //verify child
        System.assertEquals(1, kpiValues.size());
        System.assertEquals(kpiValues.get(0).Responsible__c, UserInfo.getUserId());
        System.assertEquals(kpiValues.get(0).CaseNumber__c, caseToProcess.Id);
        System.assertEquals(kpiValues.get(0).FDS_KPI_Reporting__c, kpiReportings.get(0).Id);
        System.assertEquals(true, kpiValues.get(0).KPI_Value__c != null );


    }

    static testMethod void testCaseEscalatedKPIReporting2(){
        setup2();

        Test.startTest();

        List<Case> casesToProcess = [SELECT Id, Status, Reason1__c FROM Case];

        for(Case cas : casesToProcess){
            cas.Status = 'Escalated Internally';
            //cas.Reason1__c = 'New Account request';
        }

        update casesToProcess;
        CaseTriggerHelper.isDone = true;
        Test.stopTest();

        //for verification
        List<FDS_KPI_Reporting__c> kpiReportings = [SELECT Id, Type_Of_Action__c FROM FDS_KPI_Reporting__c WHERE Type_Of_Action__c = 'Case Escalation'];
        List<KPI_Value__c> kpiValues = [SELECT ID, CaseNumber__c, FDS_KPI_Reporting__c, Responsible__c, KPI_Value__c FROM KPI_Value__c];

        //verify child
        System.assertEquals(2, kpiValues.size());
        System.assertEquals(kpiValues.get(0).Responsible__c, UserInfo.getUserId());
        System.assertEquals(kpiValues.get(0).FDS_KPI_Reporting__c, kpiReportings.get(0).Id);
        System.assertEquals(true, kpiValues.get(0).KPI_Value__c != null );
    }

    static testMethod void testCaseReopenedKPIReporting(){
        setupReportings();
        Account a = ISSP_ObjectFactory.createNewAccount();
        a.BillingCity = 'test';
        a.Name = 'test';
        insert a;

        Contact contact = ISSP_ObjectFactory.createNewContact();
        contact.AccountId= a.Id;
        contact.Email = 'test@test.com';
        insert contact;

        RecordType RT = [SELECT Id FROM RecordType WHERE sObjectType = 'Case' AND DeveloperName = 'Cases_Global' LIMIT 1];

        Case caseOpened = new Case();
        caseOpened.Status = 'Closed';
        caseOpened.RecordtypeId = RT.Id;
        caseOpened.ContactId = contact.Id;
        caseOpened.AccountId = contact.AccountId;
        insert caseOpened;

        Case caseToProcess = [SELECT Id, Status, RecordTypeId, Reason1__c, Reopening_reason__c FROM Case LIMIT 1];

        try{
            caseToProcess.Status = 'Reopen';
            caseToProcess.Reopening_reason__c = 'same query';
            update caseToProcess;
        } catch(Exception e) {
            System.debug('LW ERROR: ' + e.getMessage());
        }

        //for verification
        List<FDS_KPI_Reporting__c> kpiReportings = [SELECT Id, Type_Of_Action__c FROM FDS_KPI_Reporting__c WHERE Type_Of_Action__c = 'Case Reopening'];
        List<KPI_Value__c> kpiValues = [SELECT ID, CaseNumber__c, FDS_KPI_Reporting__c, Responsible__c, KPI_Value__c FROM KPI_Value__c];

        //verify parent record
        System.assertEquals(CASE_ACTION_CASE_REOPENING, kpiReportings.get(0).Type_Of_Action__c);

        //verify child
        System.assertEquals(1, kpiValues.size());
        System.assertEquals(kpiValues.get(0).Responsible__c, UserInfo.getUserId());
        System.assertEquals(kpiValues.get(0).CaseNumber__c, caseToProcess.Id);
        System.assertEquals(kpiValues.get(0).FDS_KPI_Reporting__c, kpiReportings.get(0).Id);
        System.assertEquals(true, kpiValues.get(0).KPI_Value__c != null );


    }

    static testMethod void testCaseReopenedKPIReporting2(){
        setupReportings();
        Account a = ISSP_ObjectFactory.createNewAccount();
        a.BillingCity = 'test';
        a.Name = 'test';
        insert a;

        Contact contact = ISSP_ObjectFactory.createNewContact();
        contact.AccountId= a.Id;
        contact.Email = 'test@test.com';
        insert contact;

        RecordType RT = [SELECT Id FROM RecordType WHERE sObjectType = 'Case' AND DeveloperName = 'Cases_Global' LIMIT 1];

        Case caseOpened = new Case();
        caseOpened.Status = 'Closed';
        caseOpened.RecordtypeId = RT.Id;
        caseOpened.ContactId = contact.Id;
        caseOpened.AccountId = contact.AccountId;
        insert caseOpened;

        Case caseOpened2 = new Case();
        caseOpened2.Status = 'Closed';
        caseOpened2.RecordtypeId = RT.Id;
        caseOpened2.ContactId = contact.Id;
        caseOpened2.AccountId = contact.AccountId;
        insert caseOpened2;

        Test.startTest();

        List<Case> casesToProcess = [SELECT Id, Status, Reason1__c, Reopening_reason__c FROM Case];

        for(Case cas : casesToProcess){
            cas.Status = 'Reopen';
            cas.Reopening_reason__c = 'same query';
        }

        update casesToProcess;
        CaseTriggerHelper.isDone = true;
        Test.stopTest();

        //for verification
        List<FDS_KPI_Reporting__c> kpiReportings = [SELECT Id, Type_Of_Action__c FROM FDS_KPI_Reporting__c WHERE Type_Of_Action__c = 'Case Reopening'];
        List<KPI_Value__c> kpiValues = [SELECT ID, CaseNumber__c, FDS_KPI_Reporting__c, Responsible__c, KPI_Value__c FROM KPI_Value__c];

        //verify child
        System.assertEquals(2, kpiValues.size());
        System.assertEquals(kpiValues.get(0).Responsible__c, UserInfo.getUserId());
        System.assertEquals(kpiValues.get(0).FDS_KPI_Reporting__c, kpiReportings.get(0).Id);
        System.assertEquals(true, kpiValues.get(0).KPI_Value__c != null );
    }

    static testMethod void testCaseNOIKPIReporting(){

        setup();

        Case caseToProcess = [SELECT Id, Status, RecordTypeId, Reason1__c, Reopening_reason__c, NOI_sent__c FROM Case LIMIT 1];

        try{
            caseToProcess.NOI_sent__c = Datetime.newInstance(2018,11,11,1,1,1);
            CaseTriggerHelper.isDone = false;

            update caseToProcess;
        } catch(Exception e) {
            System.debug('LW ERROR: ' + e.getMessage());
        }

        //for verification
        List<FDS_KPI_Reporting__c> kpiReportings = [SELECT Id, Type_Of_Action__c FROM FDS_KPI_Reporting__c WHERE Type_Of_Action__c = 'Send NOI' ];
        List<KPI_Value__c> kpiValues = [SELECT ID, CaseNumber__c, FDS_KPI_Reporting__c, Responsible__c, KPI_Value__c FROM KPI_Value__c];

        //verify parent record
        System.assertEquals(CASE_ACTION_SEND_NOI, kpiReportings.get(0).Type_Of_Action__c);

        //verify child
        System.assertEquals(1, kpiValues.size());
        System.assertEquals(kpiValues.get(0).Responsible__c, UserInfo.getUserId());
        System.assertEquals(kpiValues.get(0).CaseNumber__c, caseToProcess.Id);
        System.assertEquals(kpiValues.get(0).FDS_KPI_Reporting__c, kpiReportings.get(0).Id);
        System.assertEquals(true, kpiValues.get(0).KPI_Value__c != null );


    }

    static testMethod void testCaseNOIKPIReporting2(){

        setup2();

        Test.startTest();

        List<Case> casesToProcess = [SELECT Id, Status, Reason1__c, Reopening_reason__c, NOI_sent__c FROM Case];

        for(Case cas : casesToProcess){
            cas.NOI_sent__c = Datetime.newInstance(2018,11,11,1,1,1);
        }
         CaseTriggerHelper.isDone = false;
        update casesToProcess;
       
        Test.stopTest();

        //for verification
        List<FDS_KPI_Reporting__c> kpiReportings = [SELECT Id, Type_Of_Action__c FROM FDS_KPI_Reporting__c WHERE Type_Of_Action__c = 'Send NOI'];
        List<KPI_Value__c> kpiValues = [SELECT ID, CaseNumber__c, FDS_KPI_Reporting__c, Responsible__c, KPI_Value__c FROM KPI_Value__c];

        //verify child
        System.assertEquals(2, kpiValues.size());
        System.assertEquals(kpiValues.get(0).Responsible__c, UserInfo.getUserId());
        System.assertEquals(kpiValues.get(0).FDS_KPI_Reporting__c, kpiReportings.get(0).Id);
        System.assertEquals(true, kpiValues.get(0).KPI_Value__c != null );
    }

    static testMethod void testCaseCreateTaskKPIReporting(){
        setup();

        Test.startTest();

        String caseId = [SELECT ID FROM Case LIMIT 1].Id;

        Task newTask = new Task();
        newTask.TaskSubType = 'Call';
        newTask.WhatId = caseId;

        insert newTask;

        Test.stopTest();

        //for verification
        List<FDS_KPI_Reporting__c> kpiReportings = [SELECT Id, Type_Of_Action__c FROM FDS_KPI_Reporting__c WHERE Type_Of_Action__c = 'Creating a Task'];
        List<KPI_Value__c> kpiValues = [SELECT ID, CaseNumber__c, FDS_KPI_Reporting__c, Responsible__c, KPI_Value__c FROM KPI_Value__c];

        //verify parent record
        System.assertEquals(CASE_ACTION_CREATING_A_TASK, kpiReportings.get(0).Type_Of_Action__c);

        //verify child
        System.assertEquals(1, kpiValues.size());
        System.assertEquals(kpiValues.get(0).Responsible__c, UserInfo.getUserId());
        System.assertEquals(kpiValues.get(0).CaseNumber__c, caseId);
        System.assertEquals(kpiValues.get(0).FDS_KPI_Reporting__c, kpiReportings.get(0).Id);
        System.assertEquals(true, kpiValues.get(0).KPI_Value__c != null );
    }
}