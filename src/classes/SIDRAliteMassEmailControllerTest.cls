@isTest
private class SIDRAliteMassEmailControllerTest{

    public static final String APPROVED = SIDRAliteMassEmailController.APPROVED;
    public static final String REJECTED = SIDRAliteMassEmailController.REJECTED;

    public static Case getSidraCase() {
        Account account = new Account(
            Name = 'test account',
            Sector__c = 'Travel Agent',
            Category__c = 'Travel Agency Association'
        );
        insert account;

        Case cse = new Case(
            AccountId = account.Id,
            RecordtypeId = SIDRAliteMassApprovalController.SIDRA_LITE_RECORDTYPE,
            BSP_CASS__c = 'BSP',
            Region__c = 'Europe',
            BSPCountry__c = 'France'
        );
        insert cse;
        return cse;
    }

    @isTest
    static void controllerWithoutCases_Test() {
        test.startTest();
        SIDRAliteMassEmailController controller = new SIDRAliteMassEmailController();
        System.AssertEquals(true, controller.listWrapperCase.isEmpty());

        controller.filter.getActionTypeList();
        controller.selectAll();
        controller.sendEmails();
        controller.getNumSelected();
        controller.filter.getlistSector();
        controller.filter.getlistCategory();
        test.stopTest();
    }

    @isTest
    static void sendEmailDEF_Test() {
        Case cse = getSidraCase();
        cse.DEF_Approval_Rejection__c = APPROVED;
        cse.Inform_Agent_DEF__c = null;
        cse.Reason_for_Default__c = 'Non-payment';
        cse.SIDRA_Lite_Reason__c = 'Bankruptcy';
        update cse;

        test.startTest();
        SIDRAliteMassEmailController controller = new SIDRAliteMassEmailController();
        controller.filter.cse.BSP_CASS__c = 'BSP';
        controller.filter.cse.Region__c = 'Europe';
        controller.filter.cse.BSPCountry__c = 'France';
        controller.filter.account.Sector__c = 'Travel Agent';
        controller.filter.account.Category__c = 'Travel Agency Association';
        controller.filter.selectedActionType = 'DEF';
        controller.search();
        System.AssertEquals(1, controller.listWrapperCase.size());

        controller.SelectAllCheckbox = true;
        controller.selectAll();
        controller.confirmSendEmailToCurrent();
        controller.confirmSendEmail = true;
        controller.sessionId = 'sessionId';
        controller.apiServerUrl = 'apiServerUrl';
        controller.sendEmails();
        test.stopTest();
    }

    @isTest
    static void sendEmailDEFWithdrawal_Test() {
        Case cse = getSidraCase();
        cse.DEF_Withdrawal_Approval_Rejection__c = APPROVED;
        cse.Confirm_Reinstatement_to_AG__c = null;
        cse.DEF_Withdrawal_Reason__c  = 'Other';
        update cse;

        test.startTest();
        SIDRAliteMassEmailController controller = new SIDRAliteMassEmailController();
        controller.filter.selectedActionType = 'DEF Withdrawal';
        controller.filter.cse.Region__c = 'Europe';
        controller.search();
        System.AssertEquals(1, controller.listWrapperCase.size());

        controller.SelectAllCheckbox = true;
        controller.selectAll();
        controller.confirmSendEmailToCurrent();
        controller.confirmSendEmail = true;
        controller.sessionId = 'sessionId';
        controller.apiServerUrl = 'apiServerUrl';
        controller.sendEmails();
        test.stopTest();
    }

    @isTest
    static void sendEmailIRR_Test() {
        Case cse = getSidraCase();
        cse.IRR_Approval_Rejection__c = APPROVED;
        cse.NOI_sent__c = null;
        update cse;

        test.startTest();
        SIDRAliteMassEmailController controller = new SIDRAliteMassEmailController();
        controller.filter.selectedActionType = 'IRR';
        controller.filter.cse.Region__c = 'Europe';
        controller.search();
        System.AssertEquals(1, controller.listWrapperCase.size());

        controller.SelectAllCheckbox = true;
        controller.selectAll();
        controller.confirmSendEmailToCurrent();
        controller.confirmSendEmail = true;
        controller.sessionId = 'sessionId';
        controller.apiServerUrl = 'apiServerUrl';
        controller.sendEmails();
        test.stopTest();
    }

    @isTest
    static void sendEmailIRRWithdrawal_Test() {
        Case cse = getSidraCase();
        cse.IRR_Withdrawal_Approval_Rejection__c = APPROVED;
        cse.Confirm_IRR_Withdrawal_to_AG__c = null;
        cse.IRR_Withdrawal_Reason__c = 'Other';
        update cse;

        test.startTest();
        SIDRAliteMassEmailController controller = new SIDRAliteMassEmailController();
        controller.filter.selectedActionType = 'IRR Withdrawal';
        controller.filter.cse.Region__c = 'Europe';
        controller.search();
        System.AssertEquals(1, controller.listWrapperCase.size());

        controller.SelectAllCheckbox = true;
        controller.selectAll();
        controller.confirmSendEmailToCurrent();
        controller.confirmSendEmail = true;
        controller.sessionId = 'sessionId';
        controller.apiServerUrl = 'apiServerUrl';
        controller.sendEmails();
        test.stopTest();
    }

    @isTest
    static void sendEmailREI_Test() {
        Case cse = getSidraCase();
        cse.REI_ApprovalRejectin__c = APPROVED;
        cse.DEF_Withdrawal_Approval_Rejection__c = REJECTED;
        cse.Confirm_Reinstatement_to_AG__c = null;
        cse.DEF_Withdrawal_Reason__c = 'Agent error';
        cse.Type_of_REI_WD__c = 'DEF/SUS REI';
        cse.Reason_of_REI_WD__c = 'Commissioner decision';
        update cse;

        test.startTest();
        SIDRAliteMassEmailController controller = new SIDRAliteMassEmailController();
        controller.filter.selectedActionType = 'REI';
        controller.filter.cse.Region__c = 'Europe';
        controller.search();
        System.AssertEquals(1, controller.listWrapperCase.size());

        controller.SelectAllCheckbox = true;
        controller.selectAll();
        controller.confirmSendEmailToCurrent();
        controller.confirmSendEmail = true;
        controller.sessionId = 'sessionId';
        controller.apiServerUrl = 'apiServerUrl';
        controller.sendEmails();
        test.stopTest();
    }

    @isTest
    static void sendEmailTER_Test() {
        Case cse = getSidraCase();
        cse.TER_Approval_Rejection__c = APPROVED;
        cse.Notify_TER_to_AG__c = null;
        update cse;

        test.startTest();
        SIDRAliteMassEmailController controller = new SIDRAliteMassEmailController();
        controller.filter.selectedActionType = 'TER';
        controller.filter.cse.Region__c = 'Europe';
        controller.search();
        System.AssertEquals(1, controller.listWrapperCase.size());

        controller.SelectAllCheckbox = true;
        controller.selectAll();
        controller.confirmSendEmailToParent();
        controller.confirmSendEmail = true;
        controller.sessionId = 'sessionId';
        controller.apiServerUrl = 'apiServerUrl';
        controller.sendEmails();
        test.stopTest();
    }
}