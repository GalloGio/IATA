@isTest
private class SIDRAliteMassApprovalControllerTest {

    public static final String APPROVED = SIDRAliteMassApprovalController.APPROVED;
    public static final String REJECTED = SIDRAliteMassApprovalController.REJECTED;
    public static final String IRR = SIDRAliteMassApprovalController.IRR;
    public static final String IRR_WD = SIDRAliteMassApprovalController.IRR_WD;
    public static final String DEF = SIDRAliteMassApprovalController.DEF;
    public static final String DEF_WD = SIDRAliteMassApprovalController.DEF_WD;
    public static final String REI = SIDRAliteMassApprovalController.REI;
    public static final String TER = SIDRAliteMassApprovalController.TER;
    public static final String REI_AFTER_TER = SIDRAliteMassApprovalController.REI_AFTER_TER;

    @isTest
    static void controllerWithoutCases_Test() {
        test.startTest();
        SIDRAliteMassApprovalController controller = new SIDRAliteMassApprovalController();
        System.AssertEquals(true, controller.listWrapperCase.isEmpty());

        controller.getApprovalButtonLabel();
        controller.getRejectionButtonLabel();
        controller.confirmMassApproveCases();
        controller.confirmMassRejectCases();
        controller.cancelMassApproveCases();
        controller.cancelMassRejectCases();
        controller.exportCSV();
        controller.getcsvContent();
        test.stopTest();
    }

    @isTest
    static void approveCaseDEF_Test() {
        Case cse = new Case(
            RecordtypeId = SIDRAliteMassApprovalController.SIDRA_LITE_RECORDTYPE,
            BSP_CASS__c = 'BSP',
            Region__c = 'Europe',
            BSPCountry__c = 'France',
            DEF_Approval_Rejection__c = null,
            Reason_for_Default__c = 'Non-payment',
            SIDRA_Lite_Reason__c = 'Bankruptcy',
            SIDRA_Lite_Default_Date__c = Date.today()
        );
        insert cse;

        // set filter to find test case
        SIDRAliteMassApprovalController controller = new SIDRAliteMassApprovalController();
        controller.filter.cse.Region__c = 'Europe';
        controller.filter.cse.BSP_CASS__c = 'BSP';
        controller.filter.cse.Reason_for_Default__c = cse.Reason_for_Default__c;
        controller.filter.selectedActionType = DEF;

        test.startTest();
        // check that the case is searched
        controller.search();
        System.AssertEquals(1,controller.listWrapperCase.size());

        controller.exportCSV();
        controller.getcsvContent();

        //mark case and approve it
        controller.selectedIds = cse.Id;
        //controller.confirmApproval = true;
        controller.confirmMassApproveCases();
        controller.massApproveUpdateCases();
        controller.getcsvContent();
        test.stopTest();

        //check taht case was approved
        cse = [Select Id, DEF_Approval_Rejection__c, Confirmation_moneys_not_received__c from Case where Id = :cse.Id];
        System.AssertEquals(APPROVED, cse.DEF_Approval_Rejection__c);
        System.AssertEquals(Date.today(), cse.Confirmation_moneys_not_received__c.date());
    }

    @isTest
    static void rejectCaseDEF_Test() {
        Case cse = new Case(
            RecordtypeId = SIDRAliteMassApprovalController.SIDRA_LITE_RECORDTYPE,
            BSP_CASS__c = 'BSP',
            Region__c = 'Europe',
            BSPCountry__c = 'France',
            DEF_Approval_Rejection__c = null,
            Reason_for_Default__c = 'Non-payment',
            SIDRA_Lite_Default_Date__c = Date.today()
        );
        insert cse;

        // set filter to find test case
        SIDRAliteMassApprovalController controller = new SIDRAliteMassApprovalController();
        controller.filter.cse.Region__c = 'Europe';
        controller.filter.cse.BSP_CASS__c = 'BSP';
        controller.filter.cse.Reason_for_Default__c = cse.Reason_for_Default__c;
        controller.filter.selectedActionType = DEF;

        test.startTest();
        // check that the case is searched
        controller.search();
        System.AssertEquals(1,controller.listWrapperCase.size());

        //mark case and reject it
        controller.selectedIds = cse.Id;
        //controller.confirmRejection = true;
        controller.confirmMassRejectCases();
        controller.massRejectUpdateCases();
        controller.getcsvContent();
        test.stopTest();

        //check taht case was rejected
        cse = [Select Id, DEF_Approval_Rejection__c, Confirmation_moneys_not_received__c from Case where Id = :cse.Id];
        System.AssertEquals(REJECTED, cse.DEF_Approval_Rejection__c);
        System.AssertEquals(Date.today(), cse.Confirmation_moneys_not_received__c.date());
    }

    @isTest
    static void approveCaseDEFWithdrawal_Test() {
        Case cse = new Case(
            RecordtypeId = SIDRAliteMassApprovalController.SIDRA_LITE_RECORDTYPE,
            BSP_CASS__c = 'BSP',
            Region__c = 'Europe',
            BSPCountry__c = 'France',
            DEF_Withdrawal_Approval_Rejection__c = null,
            DEF_Approval_Rejection__c = APPROVED,
            DEF_Withdrawal_Reason__c  = 'Other',
            SIDRA_Lite_Reason__c = 'Bankruptcy',
            AG_Request_DEF_Withdrawal__c = DateTime.now()
        );
        insert cse;

        // set filter to find test case
        SIDRAliteMassApprovalController controller = new SIDRAliteMassApprovalController();
        controller.filter.cse.Region__c = 'Europe';
        controller.filter.cse.BSP_CASS__c = 'BSP';
        controller.filter.cse.DEF_Withdrawal_Reason__c = cse.DEF_Withdrawal_Reason__c;
        controller.filter.selectedActionType = DEF_WD;

        test.startTest();
        // check that the case is searched
        controller.search();
        System.AssertEquals(1,controller.listWrapperCase.size());

        //mark case and approve it
        controller.selectedIds = cse.Id;
        //controller.confirmApproval = true;
        controller.confirmMassApproveCases();
        controller.massApproveUpdateCases();
        controller.getcsvContent();
        test.stopTest();

        //check taht case was approved
        cse = [Select Id, DEF_Withdrawal_Approval_Rejection__c, R_S_Confirm_DEFWD_Justifications__c from Case where Id = :cse.Id];
        System.AssertEquals(APPROVED, cse.DEF_Withdrawal_Approval_Rejection__c);
        System.AssertEquals(Date.today(), cse.R_S_Confirm_DEFWD_Justifications__c.date());
    }

    @isTest
    static void rejectCaseDEFWithdrawal_Test() {
        Case cse = new Case(
            RecordtypeId = SIDRAliteMassApprovalController.SIDRA_LITE_RECORDTYPE,
            BSP_CASS__c = 'BSP',
            Region__c = 'Europe',
            BSPCountry__c = 'France',
            DEF_Withdrawal_Approval_Rejection__c = null,
            DEF_Approval_Rejection__c = APPROVED,
            SIDRA_Lite_Reason__c = 'Bankruptcy',
            AG_Request_DEF_Withdrawal__c = DateTime.now()
        );
        insert cse;

        // set filter to find test case
        SIDRAliteMassApprovalController controller = new SIDRAliteMassApprovalController();
        controller.filter.cse.Region__c = 'Europe';
        controller.filter.cse.BSP_CASS__c = 'BSP';
        controller.filter.cse.DEF_Withdrawal_Reason__c = cse.DEF_Withdrawal_Reason__c;
        controller.filter.selectedActionType = DEF_WD;

        test.startTest();
        // check that the case is searched
        controller.search();
        System.AssertEquals(1,controller.listWrapperCase.size());

        //mark case and reject it
        controller.selectedIds = cse.Id;
        controller.confirmMassRejectCases();
        //controller.confirmRejection = true;
        controller.massRejectUpdateCases();
        controller.getcsvContent();
        test.stopTest();

        //check taht case was rejected
        cse = [Select Id, DEF_Withdrawal_Approval_Rejection__c, R_S_Confirm_DEFWD_Justifications__c from Case where Id = :cse.Id];
        System.AssertEquals(REJECTED, cse.DEF_Withdrawal_Approval_Rejection__c);
        System.AssertEquals(Date.today(), cse.R_S_Confirm_DEFWD_Justifications__c.date());
    }

    @isTest
    static void approveCaseIRR_Test() {
        Case cse = new Case(
            RecordtypeId = SIDRAliteMassApprovalController.SIDRA_LITE_RECORDTYPE,
            BSP_CASS__c = 'BSP',
            Region__c = 'Europe',
            BSPCountry__c = 'France',
            IRR_Approval_Rejection__c = null
        );
        insert cse;

        // set filter to find test case
        SIDRAliteMassApprovalController controller = new SIDRAliteMassApprovalController();
        controller.filter.cse.Region__c = 'Europe';
        controller.filter.cse.BSP_CASS__c = 'BSP';
        controller.filter.selectedActionType = IRR;

        test.startTest();
        // check that the case is searched
        controller.search();
        System.AssertEquals(1,controller.listWrapperCase.size());

        //mark case and approve it
        controller.selectedIds = cse.Id;
        controller.confirmMassApproveCases();
        //controller.confirmApproval = true;
        controller.confirmMassApproveCases();
        controller.massApproveUpdateCases();
        controller.getcsvContent();
        test.stopTest();

        //check taht case was approved
        cse = [Select Id, IRR_Approval_Rejection__c, Propose_Irregularity__c from Case where Id = :cse.Id];
        System.AssertEquals(APPROVED, cse.IRR_Approval_Rejection__c);
        System.AssertEquals(Date.today(), cse.Propose_Irregularity__c.date());
    }

    @isTest
    static void rejectCaseIRR_Test() {
        Case cse = new Case(
            RecordtypeId = SIDRAliteMassApprovalController.SIDRA_LITE_RECORDTYPE,
            BSP_CASS__c = 'BSP',
            Region__c = 'Europe',
            BSPCountry__c = 'France',
            IRR_Approval_Rejection__c = null
        );
        insert cse;

        // set filter to find test case
        SIDRAliteMassApprovalController controller = new SIDRAliteMassApprovalController();
        controller.filter.cse.Region__c = 'Europe';
        controller.filter.cse.BSP_CASS__c = 'BSP';
        controller.filter.selectedActionType = IRR;

        test.startTest();
        // check that the case is searched
        controller.search();
        System.AssertEquals(1,controller.listWrapperCase.size());

        //mark case and reject it
        controller.selectedIds = cse.Id;
        controller.confirmMassRejectCases();
        //controller.confirmRejection = true;
        controller.massRejectUpdateCases();
        controller.getcsvContent();
        test.stopTest();

        //check taht case was rejected
        cse = [Select Id, IRR_Approval_Rejection__c, Propose_Irregularity__c from Case where Id = :cse.Id];
        System.AssertEquals(REJECTED, cse.IRR_Approval_Rejection__c);
        System.AssertEquals(null, cse.Propose_Irregularity__c);
    }

    @isTest
    static void approveCaseIRRWithdrawal_Test() {
        Case cse = new Case(
            RecordtypeId = SIDRAliteMassApprovalController.SIDRA_LITE_RECORDTYPE,
            BSP_CASS__c = 'BSP',
            Region__c = 'Europe',
            BSPCountry__c = 'France',
            IRR_Withdrawal_Approval_Rejection__c = null,
            IRR_Approval_Rejection__c = APPROVED,
            IRR_Withdrawal_Reason__c = 'Other',
            AG_Request_IRR_Withdrawal__c = DateTime.now()
        );
        insert cse;

        // set filter to find test case
        SIDRAliteMassApprovalController controller = new SIDRAliteMassApprovalController();
        controller.filter.cse.Region__c = 'Europe';
        controller.filter.cse.BSP_CASS__c = 'BSP';
        controller.filter.cse.IRR_Withdrawal_Reason__c = cse.IRR_Withdrawal_Reason__c;
        controller.filter.selectedActionType = IRR_WD;

        test.startTest();
        // check that the case is searched
        controller.search();
        System.AssertEquals(1,controller.listWrapperCase.size());

        //mark case and approve it
        controller.selectedIds = cse.Id;
        controller.confirmMassApproveCases();
        //controller.confirmApproval = true;
        controller.confirmMassApproveCases();
        controller.massApproveUpdateCases();
        controller.getcsvContent();
        test.stopTest();

        //check taht case was approved
        cse = [Select Id, IRR_Withdrawal_Approval_Rejection__c, R_S_Confirm_IRRWD_Justifications__c from Case where Id = :cse.Id];
        System.AssertEquals(APPROVED, cse.IRR_Withdrawal_Approval_Rejection__c);
        System.AssertEquals(Date.today(), cse.R_S_Confirm_IRRWD_Justifications__c.date());
    }

    @isTest
    static void rejectCaseIRRWithdrawal_Test() {
        Case cse = new Case(
            RecordtypeId = SIDRAliteMassApprovalController.SIDRA_LITE_RECORDTYPE,
            BSP_CASS__c = 'BSP',
            Region__c = 'Europe',
            BSPCountry__c = 'France',
            IRR_Withdrawal_Approval_Rejection__c = null,
            IRR_Approval_Rejection__c = APPROVED,
            AG_Request_IRR_Withdrawal__c = DateTime.now()
        );
        insert cse;

        // set filter to find test case
        SIDRAliteMassApprovalController controller = new SIDRAliteMassApprovalController();
        controller.filter.cse.Region__c = 'Europe';
        controller.filter.cse.BSP_CASS__c = 'BSP';
        controller.filter.selectedActionType = IRR_WD;

        test.startTest();
        // check that the case is searched
        controller.search();
        System.AssertEquals(1,controller.listWrapperCase.size());

        //mark case and reject it
        controller.selectedIds = cse.Id;
        controller.confirmMassRejectCases();
        //controller.confirmRejection = true;
        controller.massRejectUpdateCases();
        controller.getcsvContent();
        test.stopTest();

        //check taht case was rejected
        cse = [Select Id, IRR_Withdrawal_Approval_Rejection__c, R_S_Confirm_IRRWD_Justifications__c from Case where Id = :cse.Id];
        System.AssertEquals(REJECTED, cse.IRR_Withdrawal_Approval_Rejection__c);
        System.AssertEquals(Date.today(), cse.R_S_Confirm_IRRWD_Justifications__c.date());
    }

    @isTest
    static void approveCaseREI_Test() {
        Case cse = new Case(
            RecordtypeId = SIDRAliteMassApprovalController.SIDRA_LITE_RECORDTYPE,
            BSP_CASS__c = 'BSP',
            Region__c = 'Europe',
            BSPCountry__c = 'France',
            REI_ApprovalRejectin__c = null,
            DEF_Approval_Rejection__c = APPROVED,
            DEF_Withdrawal_Approval_Rejection__c = REJECTED,
            SIDRA_Lite_Reason__c = 'Bankruptcy',
            AG_Reinstatement_Request__c = DateTime.now()
        );
        insert cse;

        // set filter to find test case
        SIDRAliteMassApprovalController controller = new SIDRAliteMassApprovalController();
        controller.filter.cse.Region__c = 'Europe';
        controller.filter.cse.BSP_CASS__c = 'BSP';
        controller.filter.cse.REI_Approval_Rejection_remarks__c = 'comment';
        controller.filter.selectedActionType = REI;

        test.startTest();
        // check that the case is searched
        controller.search();
        System.AssertEquals(1,controller.listWrapperCase.size());

        //mark case and approve it
        controller.selectedIds = cse.Id;
        controller.confirmMassApproveCases();
        //controller.confirmApproval = true;
        cse = controller.listWrapperCase[0].cse;
        cse.Type_of_REI_WD__c = 'DEF/SUS REI';
        cse.DEF_Withdrawal_Reason__c = 'Agent error';
        cse.Reason_of_REI_WD__c = 'Commissioner decision';
        controller.confirmMassApproveCases();
        controller.massApproveUpdateCases();
        controller.getcsvContent();
        test.stopTest();

        //check taht case was approved
        cse = [Select Id, REI_ApprovalRejectin__c, REI_Approval_Rejection_remarks__c from Case where Id = :cse.Id];
        System.AssertEquals(APPROVED, cse.REI_ApprovalRejectin__c);
        System.AssertEquals('comment', cse.REI_Approval_Rejection_remarks__c);
    }

    @isTest
    static void rejectCaseREI_Test() {
        Case cse = new Case(
            RecordtypeId = SIDRAliteMassApprovalController.SIDRA_LITE_RECORDTYPE,
            BSP_CASS__c = 'BSP',
            Region__c = 'Europe',
            BSPCountry__c = 'France',
            REI_ApprovalRejectin__c = null,
            DEF_Approval_Rejection__c = APPROVED,
            DEF_Withdrawal_Approval_Rejection__c = REJECTED,
            SIDRA_Lite_Reason__c = 'Bankruptcy',
            AG_Reinstatement_Request__c = Date.today()
        );
        insert cse;

        // set filter to find test case
        SIDRAliteMassApprovalController controller = new SIDRAliteMassApprovalController();
        controller.filter.cse.Region__c = 'Europe';
        controller.filter.cse.BSP_CASS__c = 'BSP';
        controller.filter.cse.REI_Approval_Rejection_remarks__c = 'comment';
        controller.filter.selectedActionType = REI;

        test.startTest();
        // check that the case is searched
        controller.search();
        System.AssertEquals(1,controller.listWrapperCase.size());

        //mark case and reject it
        controller.selectedIds = cse.Id;
        controller.confirmMassRejectCases();
        //controller.confirmRejection = true;
        controller.massRejectUpdateCases();
        controller.getcsvContent();
        test.stopTest();

        //check taht case was rejected
        cse = [Select Id, REI_ApprovalRejectin__c, REI_Approval_Rejection_remarks__c from Case where Id = :cse.Id];
        System.AssertEquals(REJECTED, cse.REI_ApprovalRejectin__c);
        System.AssertEquals('comment', cse.REI_Approval_Rejection_remarks__c);
    }

    @isTest
    static void approveCaseTER_Test() {
        Case cse = new Case(
            RecordtypeId = SIDRAliteMassApprovalController.SIDRA_LITE_RECORDTYPE,
            BSP_CASS__c = 'BSP',
            Region__c = 'Europe',
            BSPCountry__c = 'France',
            TER_Approval_Rejection__c = null,
            DEF_Approval_Rejection__c = APPROVED,
            DEF_Withdrawal_Approval_Rejection__c = REJECTED,
            SIDRA_Lite_Reason__c = 'Bankruptcy',
            Propose_Default__c = DateTime.now()
        );
        insert cse;

        // set filter to find test case
        SIDRAliteMassApprovalController controller = new SIDRAliteMassApprovalController();
        controller.filter.cse.Region__c = 'Europe';
        controller.filter.cse.BSP_CASS__c = 'BSP';
        controller.filter.selectedActionType = TER;

        test.startTest();
        // check that the case is searched
        controller.search();
        System.AssertEquals(1,controller.listWrapperCase.size());

        //mark case and approve it
        controller.selectedIds = cse.Id;
        controller.confirmMassApproveCases();
        //controller.confirmApproval = true;
        controller.confirmMassApproveCases();
        controller.massApproveUpdateCases();
        controller.getcsvContent();
        test.stopTest();

        //check taht case was approved
        cse = [Select Id, TER_Approval_Rejection__c from Case where Id = :cse.Id];
        System.AssertEquals(APPROVED, cse.TER_Approval_Rejection__c);
    }

    @isTest
    static void rejectCaseTER_Test() {
        Case cse = new Case(
            RecordtypeId = SIDRAliteMassApprovalController.SIDRA_LITE_RECORDTYPE,
            BSP_CASS__c = 'BSP',
            Region__c = 'Europe',
            BSPCountry__c = 'France',
            TER_Approval_Rejection__c = null,
            DEF_Approval_Rejection__c = APPROVED,
            DEF_Withdrawal_Approval_Rejection__c = REJECTED,
            SIDRA_Lite_Reason__c = 'Bankruptcy',
            Propose_Default__c = DateTime.now()
        );
        insert cse;

        // set filter to find test case
        SIDRAliteMassApprovalController controller = new SIDRAliteMassApprovalController();
        controller.filter.cse.Region__c = 'Europe';
        controller.filter.cse.BSP_CASS__c = 'BSP';
        controller.filter.selectedActionType = TER;

        test.startTest();
        // check that the case is searched
        controller.search();
        System.AssertEquals(1,controller.listWrapperCase.size());

        //mark case and reject it
        controller.selectedIds = cse.Id;
        controller.confirmMassRejectCases();
        //controller.confirmRejection = true;
        controller.massRejectUpdateCases();
        controller.getcsvContent();
        test.stopTest();

        //check taht case was rejected
        cse = [Select Id, TER_Approval_Rejection__c from Case where Id = :cse.Id];
        System.AssertEquals(REJECTED, cse.TER_Approval_Rejection__c);
    }

}
