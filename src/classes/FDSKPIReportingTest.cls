@IsTest(SeeAllData=false)
private class FDSKPIReportingTest {

    private static final String CASE_COMMENT_ACTION = 'Public Case Comment';
    private static final String CASE_ACTION_CASE_CLOSURE = 'Case Closure';
    public static final String CASE_ACTION_CASE_ESCALATION = 'Case Escalation';
    public static final String CASE_ACTION_CASE_REOPENING = 'Case Reopening';
    public static final String CASE_ACTION_SEND_NOI = 'Send NOI';
    public static final String CASE_ACTION_CREATING_A_TASK = 'Creating a Task';
    public static final String CASE_EMAIL_SEND_ACTION = 'Send Email';
    
    public static RecordType globalRT = RecordTypeSingleton.getInstance().getRecordType('Case', 'Cases_Global');
    public static RecordType cscRT = RecordTypeSingleton.getInstance().getRecordType('FDS_KPI_Reporting__c', 'CSC');
    public static RecordType sidraRT = RecordTypeSingleton.getInstance().getRecordType('Case', 'SIDRA');


    private static void setupReportings() {
        List<String> actionTypes = new List<String>{CASE_ACTION_CASE_CLOSURE, 
            CASE_ACTION_CASE_ESCALATION, CASE_ACTION_CASE_REOPENING, CASE_ACTION_SEND_NOI, CASE_COMMENT_ACTION, 
            CASE_ACTION_CREATING_A_TASK, CASE_EMAIL_SEND_ACTION};
                List<FDS_KPI_Reporting__c> kpiReportingsToInsert = new List<FDS_KPI_Reporting__c>();
        
        for(String actionType: actionTypes) {
            FDS_KPI_Reporting__c newKPIReporting = new FDS_KPI_Reporting__c();
            newKPIReporting.Type_Of_Action__c = actionType;
            newKPIReporting.Name = actionType;
            newKPIReporting.RecordTypeId = cscRT.Id;
            
            kpiReportingsToInsert.add(newKPIReporting);
        }
        
        
        if(kpiReportingsToInsert.size() > 0 ){
            insert kpiReportingsToInsert;
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


        Case caseOpened = new Case();
        caseOpened.Status = 'Action Needed';
        caseOpened.RecordtypeId = globalRT.Id;
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

        Case caseOpened = new Case();
        caseOpened.Status = 'Action Needed';
        caseOpened.RecordtypeId = globalRT.Id;
        caseOpened.ContactId = contact.Id;
        caseOpened.AccountId = contact.AccountId;
        caseOpened.NOI_sent__c = null;
        insert caseOpened;

        Case caseOpened2 = new Case();
        caseOpened2.Status = 'Action Needed';
        caseOpened2.RecordtypeId = globalRT.Id;
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

    
    static testMethod void testNewCommentKPIReporting() {
        setupReportings();
        Account a = ISSP_ObjectFactory.createNewAccount();
        a.BillingCity = 'test';
        a.Name = 'test';
        insert a;

        Contact contact = ISSP_ObjectFactory.createNewContact();
        contact.AccountId= a.Id;
        contact.Email = 'test@test.com';
        insert contact;



        Case caseOpened = new Case();
        caseOpened.Status = 'Action Needed';
        caseOpened.RecordtypeId = sidraRT.Id;
        caseOpened.ContactId = contact.Id;
        caseOpened.AccountId = contact.AccountId;
        insert caseOpened;


        Test.startTest();

        String caseId = [SELECT ID FROM Case LIMIT 1].Id;
        
        CaseComment caseComment = new CaseComment(
            ParentId=caseId,
            IsPublished = true
        );
        insert caseComment;
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

     static testMethod void testNewEmailKPIReporting() {
         setupReportings();
         Account a = ISSP_ObjectFactory.createNewAccount();
         a.BillingCity = 'test';
         a.Name = 'test';
         insert a;

        Contact contact = ISSP_ObjectFactory.createNewContact();
        contact.AccountId= a.Id;
        contact.Email = 'test@test.com';
        insert contact;



        Case caseOpened = new Case();
        caseOpened.Status = 'Action Needed';
        caseOpened.RecordtypeId = sidraRT.Id;
        caseOpened.ContactId = contact.Id;
        caseOpened.AccountId = contact.AccountId;
        insert caseOpened;
        
         Test.startTest();
        Id caseId = [SELECT ID FROM Case LIMIT 1].Id;


            EmailMessage caseComment = new EmailMessage(
                    ParentId=caseId,
                    Incoming = false
            );
            insert caseComment;





        Test.stopTest();

        //for verification
        List<FDS_KPI_Reporting__c> kpiReportings = [SELECT Id, Type_Of_Action__c FROM FDS_KPI_Reporting__c WHERE Type_Of_Action__c = 'Send Email'];
        List<KPI_Value__c> kpiValues = [SELECT ID, CaseNumber__c, FDS_KPI_Reporting__c, Responsible__c, KPI_Value__c FROM KPI_Value__c];

        //verify parent record
        System.assertEquals(1, kpiReportings.size());
        System.assertEquals(CASE_EMAIL_SEND_ACTION, kpiReportings.get(0).Type_Of_Action__c);

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
        
        Test.startTest();
        
        caseToProcess.Status = 'Closed';
        caseToProcess.Reason1__c = 'New Account request';
        update caseToProcess;
        
        Test.stopTest();
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
        
        Test.startTest();

            caseToProcess.Status = 'Escalated Internally';
            //caseToProcess.Reason1__c = 'New Account request';
            update caseToProcess;



        Test.stopTest();
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



        Case caseOpened = new Case();
        //caseOpened.Status = 'Closed';
        caseOpened.Status = 'Reopen';
        
        caseOpened.RecordtypeId = globalRT.Id;
        caseOpened.ContactId = contact.Id;
        caseOpened.AccountId = contact.AccountId;
        insert caseOpened;

        Case caseToProcess = [SELECT Id, Status, RecordTypeId, Reason1__c, Reopening_reason__c FROM Case LIMIT 1];

        Test.startTest();
        
        caseToProcess.Status = 'Closed';
        caseToProcess.Reopening_reason__c = 'same query';
        update caseToProcess;
        
        Test.stopTest();



        //for verification
        List<FDS_KPI_Reporting__c> kpiReportings = [SELECT Id, Type_Of_Action__c FROM FDS_KPI_Reporting__c WHERE Type_Of_Action__c = 'Case Closure'];
        List<KPI_Value__c> kpiValues = [SELECT ID, CaseNumber__c, FDS_KPI_Reporting__c, Responsible__c, KPI_Value__c FROM KPI_Value__c];

        //verify parent record
        System.assertEquals(CASE_ACTION_CASE_CLOSURE, kpiReportings.get(0).Type_Of_Action__c);

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



        Case caseOpened = new Case();
        //caseOpened.Status = 'Closed';
        caseOpened.Status = 'Reopen';
        caseOpened.RecordtypeId = globalRT.Id;
        caseOpened.ContactId = contact.Id;
        caseOpened.AccountId = contact.AccountId;
        insert caseOpened;

        Case caseOpened2 = new Case();
        //caseOpened2.Status = 'Closed';
        caseOpened.Status = 'Reopen';
        caseOpened2.RecordtypeId = globalRT.Id;
        caseOpened2.ContactId = contact.Id;
        caseOpened2.AccountId = contact.AccountId;
        insert caseOpened2;

        Test.startTest();

        List<Case> casesToProcess = [SELECT Id, Status, Reason1__c, Reopening_reason__c FROM Case];

        for(Case cas : casesToProcess){
            cas.Status = 'Closed';
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
        //System.assertEquals(kpiValues.get(0).FDS_KPI_Reporting__c, kpiReportings.get(0).Id);
        System.assertEquals(true, kpiValues.get(0).KPI_Value__c != null );
    }

    static testMethod void testCaseNOIKPIReporting(){

        setupReportings();
        Account a = ISSP_ObjectFactory.createNewAccount();
        a.BillingCity = 'test';
        a.Name = 'test';
        insert a;

        Contact contact = ISSP_ObjectFactory.createNewContact();
        contact.AccountId= a.Id;
        contact.Email = 'test@test.com';
        insert contact;



        Case caseOpened = new Case();
        caseOpened.Status = 'Action Needed';
        caseOpened.RecordtypeId = sidraRT.Id;
        caseOpened.ContactId = contact.Id;
        caseOpened.AccountId = contact.AccountId;
        caseOpened.NOI_sent__c = null;
        insert caseOpened;

        Case caseToProcess = [SELECT Id, Status, RecordTypeId, Reason1__c, Reopening_reason__c, NOI_sent__c FROM Case LIMIT 1];

        Test.startTest();
            caseToProcess.NOI_sent__c = Datetime.newInstance(2018,11,11,1,1,1);
            CaseTriggerHelper.isDone = false;

            update caseToProcess;

        Test.stopTest();


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

       setupReportings();
        Account a = ISSP_ObjectFactory.createNewAccount();
        a.BillingCity = 'test';
        a.Name = 'test';
        insert a;

        Contact contact = ISSP_ObjectFactory.createNewContact();
        contact.AccountId= a.Id;
        contact.Email = 'test@test.com';
        insert contact;



        Case caseOpened = new Case();
        caseOpened.Status = 'Action Needed';
        caseOpened.RecordtypeId = sidraRT.Id;
        caseOpened.ContactId = contact.Id;
        caseOpened.AccountId = contact.AccountId;
        caseOpened.NOI_sent__c = null;
        insert caseOpened;

        Case caseOpened2 = new Case();
        caseOpened2.Status = 'Action Needed';
        caseOpened2.RecordtypeId = sidraRT.Id;
        caseOpened2.ContactId = contact.Id;
        caseOpened2.AccountId = contact.AccountId;
        caseOpened2.NOI_sent__c = null;
        insert caseOpened2;

        Test.startTest();

        List<Case> casesToProcess = [SELECT Id, Status, Reason1__c, Reopening_reason__c, NOI_sent__c FROM Case];

        for(Case cas : casesToProcess){
            cas.NOI_sent__c = Datetime.newInstance(2018,11,11,1,1,1);
        }
         CaseTriggerHelper.isDone = false;
        update casesToProcess;
        CaseTriggerHelper.isDone = true;
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