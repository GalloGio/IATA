@isTest
private class SIDRAliteMassApprovalControllerTest {

    public static final String APPROVED = SIDRAliteMassApprovalController.APPROVED;
    public static final String REJECTED = SIDRAliteMassApprovalController.REJECTED;

    @isTest
    static void controllerWithoutCases_Test() {
        test.startTest();
        SIDRAliteMassApprovalController controller = new SIDRAliteMassApprovalController();
        System.AssertEquals(true, controller.listWrapperCase.isEmpty());

        controller.filter.getActionTypeList();
        controller.getApprovalButtonLabel();
        controller.getRejectionButtonLabel();
        controller.massApproveCases();
        controller.massRejectCases();
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
            Reason_for_Default__c = 'Non-payment'
        );
        insert cse;

        // set filter to find test case
        SIDRAliteMassApprovalController controller = new SIDRAliteMassApprovalController();
        controller.filter.cse.Region__c = 'Europe';
        controller.filter.cse.BSP_CASS__c = 'BSP';
        controller.filter.selectedActionType = 'DEF';

        test.startTest();
        // check that the case is searched
        controller.search();
        System.AssertEquals(1,controller.listWrapperCase.size());

        //mark case and approve it
        controller.SelectAllCheckbox = true;
        controller.SelectAll();
        controller.confirmApproval = true;
        controller.confirmMassApproveCases();
        controller.massApproveCases();
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
            Reason_for_Default__c = 'Non-payment'
        );
        insert cse;

        // set filter to find test case
        SIDRAliteMassApprovalController controller = new SIDRAliteMassApprovalController();
        controller.filter.cse.Region__c = 'Europe';
        controller.filter.cse.BSP_CASS__c = 'BSP';
        controller.filter.selectedActionType = 'DEF';

        test.startTest();
        // check that the case is searched
        controller.search();
        System.AssertEquals(1,controller.listWrapperCase.size());

        //mark case and reject it
        controller.SelectAllCheckbox = true;
        controller.SelectAll();
        controller.confirmMassRejectCases();
        controller.confirmRejection = true;
        controller.massRejectCases();
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
            DEF_Withdrawal_Reason__c  = 'Other'
        );
        insert cse;

        // set filter to find test case
        SIDRAliteMassApprovalController controller = new SIDRAliteMassApprovalController();
        controller.filter.cse.Region__c = 'Europe';
        controller.filter.cse.BSP_CASS__c = 'BSP';
        controller.filter.selectedActionType = 'DEF Withdrawal';

        test.startTest();
        // check that the case is searched
        controller.search();
        System.AssertEquals(1,controller.listWrapperCase.size());

        //mark case and approve it
        controller.SelectAllCheckbox = true;
        controller.SelectAll();
        controller.confirmMassApproveCases();
        controller.confirmApproval = true;
        controller.massApproveCases();
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
            DEF_Approval_Rejection__c = APPROVED
        );
        insert cse;

        // set filter to find test case
        SIDRAliteMassApprovalController controller = new SIDRAliteMassApprovalController();
        controller.filter.cse.Region__c = 'Europe';
        controller.filter.cse.BSP_CASS__c = 'BSP';
        controller.filter.selectedActionType = 'DEF Withdrawal';

        test.startTest();
        // check that the case is searched
        controller.search();
        System.AssertEquals(1,controller.listWrapperCase.size());

        //mark case and reject it
        controller.SelectAllCheckbox = true;
        controller.SelectAll();
        controller.confirmMassRejectCases();
        controller.confirmRejection = true;
        controller.massRejectCases();
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
        controller.filter.selectedActionType = 'IRR';

        test.startTest();
        // check that the case is searched
        controller.search();
        System.AssertEquals(1,controller.listWrapperCase.size());

        //mark case and approve it
        controller.SelectAllCheckbox = true;
        controller.SelectAll();
        controller.confirmMassApproveCases();
        controller.confirmApproval = true;
        controller.massApproveCases();
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
        controller.filter.selectedActionType = 'IRR';

        test.startTest();
        // check that the case is searched
        controller.search();
        System.AssertEquals(1,controller.listWrapperCase.size());

        //mark case and reject it
        controller.SelectAllCheckbox = true;
        controller.SelectAll();
        controller.confirmMassRejectCases();
        controller.confirmRejection = true;
        controller.massRejectCases();
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
            IRR_Withdrawal_Reason__c = 'Other'
        );
        insert cse;

        // set filter to find test case
        SIDRAliteMassApprovalController controller = new SIDRAliteMassApprovalController();
        controller.filter.cse.Region__c = 'Europe';
        controller.filter.cse.BSP_CASS__c = 'BSP';
        controller.filter.selectedActionType = 'IRR Withdrawal';

        test.startTest();
        // check that the case is searched
        controller.search();
        System.AssertEquals(1,controller.listWrapperCase.size());

        //mark case and approve it
        controller.SelectAllCheckbox = true;
        controller.SelectAll();
        controller.confirmMassApproveCases();
        controller.confirmApproval = true;
        controller.massApproveCases();
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
            IRR_Approval_Rejection__c = APPROVED
        );
        insert cse;

        // set filter to find test case
        SIDRAliteMassApprovalController controller = new SIDRAliteMassApprovalController();
        controller.filter.cse.Region__c = 'Europe';
        controller.filter.cse.BSP_CASS__c = 'BSP';
        controller.filter.selectedActionType = 'IRR Withdrawal';

        test.startTest();
        // check that the case is searched
        controller.search();
        System.AssertEquals(1,controller.listWrapperCase.size());

        //mark case and reject it
        controller.SelectAllCheckbox = true;
        controller.SelectAll();
        controller.confirmMassRejectCases();
        controller.confirmRejection = true;
        controller.massRejectCases();
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
            DEF_Withdrawal_Approval_Rejection__c = REJECTED
        );
        insert cse;

        // set filter to find test case
        SIDRAliteMassApprovalController controller = new SIDRAliteMassApprovalController();
        controller.filter.cse.Region__c = 'Europe';
        controller.filter.cse.BSP_CASS__c = 'BSP';
        controller.filter.selectedActionType = 'REI';

        test.startTest();
        // check that the case is searched
        controller.search();
        System.AssertEquals(1,controller.listWrapperCase.size());

        //mark case and approve it
        controller.SelectAllCheckbox = true;
        controller.SelectAll();
        controller.confirmMassApproveCases();
        controller.confirmApproval = true;
        controller.massApproveCases();
        test.stopTest();

        //check taht case was approved
        cse = [Select Id, REI_ApprovalRejectin__c, Confirm_ALL_Outstanding_Amounts_Paid__c from Case where Id = :cse.Id];
        System.AssertEquals(APPROVED, cse.REI_ApprovalRejectin__c);
        System.AssertEquals(Date.today(), cse.Confirm_ALL_Outstanding_Amounts_Paid__c.date());
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
            DEF_Withdrawal_Approval_Rejection__c = REJECTED
        );
        insert cse;

        // set filter to find test case
        SIDRAliteMassApprovalController controller = new SIDRAliteMassApprovalController();
        controller.filter.cse.Region__c = 'Europe';
        controller.filter.cse.BSP_CASS__c = 'BSP';
        controller.filter.selectedActionType = 'REI';

        test.startTest();
        // check that the case is searched
        controller.search();
        System.AssertEquals(1,controller.listWrapperCase.size());

        //mark case and reject it
        controller.SelectAllCheckbox = true;
        controller.SelectAll();
        controller.confirmMassRejectCases();
        controller.confirmRejection = true;
        controller.massRejectCases();
        test.stopTest();

        //check taht case was rejected
        cse = [Select Id, REI_ApprovalRejectin__c, Confirm_ALL_Outstanding_Amounts_Paid__c from Case where Id = :cse.Id];
        System.AssertEquals(REJECTED, cse.REI_ApprovalRejectin__c);
        System.AssertEquals(Date.today(), cse.Confirm_ALL_Outstanding_Amounts_Paid__c.date());
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
            DEF_Withdrawal_Approval_Rejection__c = REJECTED
        );
        insert cse;

        // set filter to find test case
        SIDRAliteMassApprovalController controller = new SIDRAliteMassApprovalController();
        controller.filter.cse.Region__c = 'Europe';
        controller.filter.cse.BSP_CASS__c = 'BSP';
        controller.filter.selectedActionType = 'TER';

        test.startTest();
        // check that the case is searched
        controller.search();
        System.AssertEquals(1,controller.listWrapperCase.size());

        //mark case and approve it
        controller.SelectAllCheckbox = true;
        controller.SelectAll();
        controller.confirmMassApproveCases();
        controller.confirmApproval = true;
        controller.massApproveCases();
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
            DEF_Withdrawal_Approval_Rejection__c = REJECTED
        );
        insert cse;

        // set filter to find test case
        SIDRAliteMassApprovalController controller = new SIDRAliteMassApprovalController();
        controller.filter.cse.Region__c = 'Europe';
        controller.filter.cse.BSP_CASS__c = 'BSP';
        controller.filter.selectedActionType = 'TER';

        test.startTest();
        // check that the case is searched
        controller.search();
        System.AssertEquals(1,controller.listWrapperCase.size());

        //mark case and reject it
        controller.SelectAllCheckbox = true;
        controller.SelectAll();
        controller.confirmMassRejectCases();
        controller.confirmRejection = true;
        controller.massRejectCases();
        test.stopTest();

        //check taht case was rejected
        cse = [Select Id, TER_Approval_Rejection__c from Case where Id = :cse.Id];
        System.AssertEquals(REJECTED, cse.TER_Approval_Rejection__c);
    }

}