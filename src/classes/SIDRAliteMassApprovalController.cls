public with sharing class SIDRAliteMassApprovalController{

    public static final Id SIDRA_LITE_RECORDTYPE = Schema.SObjectType.Case.getRecordTypeInfosByName().get('SIDRA Lite').getRecordtypeId();
    public static final String APPROVED = 'Approved';
    public static final String REJECTED = 'Rejected';

    public list<WrapperCase> listWrapperCase {get;set;}
    public WrapperFilter filter {get;set;}
    public Boolean SelectAllCheckbox{get;set;}
    // variables to handle approval process
    public Boolean approveCasesSection{get;set;}
    //public Boolean confirmApproval{get;set;}
    // variables to handle rejection process
    public Boolean rejectCasesSection{get;set;}
    //public Boolean confirmRejection{get;set;}

    /**
        Constructor
        by default the page is loaded with all cases searched without filter
    **/
    public SIDRAliteMassApprovalController() {
        this.listWrapperCase = new list<WrapperCase>();
        this.filter = new WrapperFilter();
        this.SelectAllCheckbox = false;
        // init variable to handle approval and rejection
        this.approveCasesSection = false;
        this.rejectCasesSection = false;
        search();
    }

    /**
        Search all cases based on the filters selected by the user
    **/
    public void search() {
        this.SelectAllCheckbox = false;

        String query = 'Select Id, CaseNumber, SIDRA_Lite_Reason__c, BSP_CASS__c, Region__c, BSPCountry__c, DEF_Approval_Rejection__c, DEF_Withdrawal_Approval_Rejection__c, IRR_Approval_Rejection__c, IRR_Withdrawal_Approval_Rejection__c, REI_ApprovalRejectin__c, TER_Approval_Rejection__c, IRR_Withdrawal_Reason__c, DEF_Withdrawal_Reason__c, accountId, AIMS_status__c, CreatedDate, Reason_for_Default__c, Termination_Reason__c, Termination_date__c, OwnerId ';
        query += ' From Case';
        query += ' Where RecordtypeId = :SIDRA_LITE_RECORDTYPE';
        query += ' And isClosed = false';

        if (this.filter.cse.BSP_CASS__c != '' && this.filter.cse.BSP_CASS__c != null) {
            query += ' And BSP_CASS__c = \'' + this.filter.cse.BSP_CASS__c + '\'';
        }
        // Region is mandatory
        query += ' And Region__c = \'' + this.filter.cse.Region__c + '\'';
        if (this.filter.cse.BSPCountry__c != '' && this.filter.cse.BSPCountry__c != null) {
            query += ' And BSPCountry__c = \'' + this.filter.cse.BSPCountry__c + '\'';
        }
        if (this.filter.selectedActionType == 'IRR') {
            query += ' And IRR_Approval_Rejection__c = null';
        }
        if (this.filter.selectedActionType == 'IRR Withdrawal') {
            query += ' And IRR_Withdrawal_Approval_Rejection__c = null';
            query += ' And IRR_Approval_Rejection__c = :APPROVED';
            if (this.filter.cse.IRR_Withdrawal_Reason__c != null) {
                query += ' And IRR_Withdrawal_Reason__c = \'' + this.filter.cse.IRR_Withdrawal_Reason__c + '\'';
            }
        }
        if (this.filter.selectedActionType == 'DEF') {
            query += ' And DEF_Approval_Rejection__c = null';
        }
        if (this.filter.selectedActionType == 'DEF Withdrawal') {
            query += ' And DEF_Withdrawal_Approval_Rejection__c = null';
            query += ' And DEF_Approval_Rejection__c = :APPROVED';
            if (this.filter.cse.DEF_Withdrawal_Reason__c != null) {
                query += ' And DEF_Withdrawal_Reason__c = \'' + this.filter.cse.DEF_Withdrawal_Reason__c + '\'';
            }
        }
        if (this.filter.selectedActionType == 'REI') {
            query += ' And REI_ApprovalRejectin__c = null';
            query += ' And DEF_Approval_Rejection__c = :APPROVED';
            query += ' And DEF_Withdrawal_Approval_Rejection__c != :APPROVED';
        }
        if (this.filter.selectedActionType == 'TER') {
            query += ' And TER_Approval_Rejection__c = null';
            query += ' And DEF_Approval_Rejection__c = :APPROVED';
            query += ' And (DEF_Withdrawal_Approval_Rejection__c != :APPROVED OR REI_ApprovalRejectin__c != :APPROVED)';
        }

        query += ' order by CaseNumber desc';
        query += ' limit 2000';

        System.debug('*** QUERY: ' + query);

        this.listWrapperCase = new list<WrapperCase>();
        for (Case cse: Database.query(query)) {
            this.listWrapperCase.add(new WrapperCase(cse));
        }
    }

    /**
        Return the label of the Approval button based on the filter
    **/
    public String getApprovalButtonLabel() {
        return 'Mass ' + this.filter.selectedActionType + ' Approval';
    }

    /**
        Return the label of the Rejection button based on the filter
    **/
    public String getRejectionButtonLabel() {
        return 'Mass ' + this.filter.selectedActionType + ' Rejection';
    }

    /**
        Returns number of selected cases in wrapper list
    **/
    private Integer countSelectedcases() {
        Integer count = 0;
        for (WrapperCase wrapper: listWrapperCase) {
            if (wrapper.selected) {
                count++;
            }
        }
        return count;
    }

    /**
        Shows the section to confirm the approval
    **/
    public PageReference confirmMassApproveCases() {
        if (countSelectedcases() == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'No case selected'));
        } else {
            this.approveCasesSection = true;
        }
        return null;
    }

    public PageReference cancelMassApproveCases() {
        this.approveCasesSection = false;
        return null;
    }

    /**
        Process done when the user clicks on the Aproval button when some update fields are requested
    **/
    public PageReference massApproveUpdateCases() {
        this.approveCasesSection = false;
        updateCases(APPROVED);
        search();
        return null;
    }

    /**
        Shows the section to reject the approval
    **/
    public PageReference confirmMassRejectCases() {
        if (countSelectedcases() == 0) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'No case selected'));
        } else {
            this.rejectCasesSection = true;
        }
        return null;
    }

    public PageReference cancelMassRejectCases() {
        this.rejectCasesSection = false;
        return null;
    }

    /**
        Process done when the user clicks on the Rejection button
    **/
    public PageReference massRejectUpdateCases() {
        this.rejectCasesSection = false;
        updateCases(REJECTED);
        search();
        return null;
    }

    /**
        Reset filter
    **/
    public PageReference reset() {
        this.filter.reset();
        this.SelectAllCheckbox = false;
        SelectAll();
        return null;
    }

    /**
        Approves o rejects all selecte cases by the user
    **/
    private void updateCases(String ApproveReject) {
        String type = this.filter.selectedActionType;
        list<Case> listUpdateCase = new list<Case>();
        for (WrapperCase wrapper: listWrapperCase) {
            if (wrapper.selected) {
                if (type == 'IRR') {
                    wrapper.cse.IRR_Approval_Rejection__c = ApproveReject;
                    if (ApproveReject==APPROVED) {
                        wrapper.cse.Propose_Irregularity__c = DateTime.now();
                    }
                } else if (type == 'IRR Withdrawal') {
                    wrapper.cse.IRR_Withdrawal_Approval_Rejection__c = ApproveReject;
                    wrapper.cse.R_S_Confirm_IRRWD_Justifications__c = DateTime.now();
                    wrapper.cse.IRR_Withdrawal_Reason__c = filter.cse.IRR_Withdrawal_Reason__c;
                    wrapper.cse.IRR_Withdrawal_Remarks__c = filter.cse.IRR_Withdrawal_Remarks__c;
                } else if (type == 'DEF') {
                    wrapper.cse.DEF_Approval_Rejection__c = ApproveReject;
                    wrapper.cse.Confirmation_moneys_not_received__c = DateTime.now();
                    wrapper.cse.Reason_for_Default__c = filter.cse.Reason_for_Default__c;
                    wrapper.cse.DEF_Approval_Rejection_Remarks__c = filter.cse.DEF_Approval_Rejection_Remarks__c;
                } else if (type == 'DEF Withdrawal') {
                    wrapper.cse.DEF_Withdrawal_Approval_Rejection__c = ApproveReject;
                    wrapper.cse.R_S_Confirm_DEFWD_Justifications__c = DateTime.now();
                    wrapper.cse.DEF_Withdrawal_Reason__c = filter.cse.DEF_Withdrawal_Reason__c;
                    wrapper.cse.DEF_Withdrawal_Approval_Rejection_Remark__c = filter.cse.DEF_Withdrawal_Approval_Rejection_Remark__c;
                } else if (type == 'REI') {
                    wrapper.cse.REI_ApprovalRejectin__c = ApproveReject;
                    wrapper.cse.REI_Approval_Rejection_remarks__c = filter.cse.REI_Approval_Rejection_remarks__c;
                } else if (type == 'TER') {
                    wrapper.cse.TER_Approval_Rejection__c = ApproveReject;
                    wrapper.cse.Termination_Reason__c = filter.cse.Termination_Reason__c;
                    wrapper.cse.FS_Action_requested__c = filter.cse.FS_Action_requested__c;
                    wrapper.cse.TER_Approval_Rejection_Remarks__c = filter.cse.TER_Approval_Rejection_Remarks__c;
                }
                listUpdateCase.add(wrapper.cse);
            }
        }
        try {
            if (listUpdateCase.isEmpty()) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,'No case selected'));
            } else {
                update listUpdateCase;
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, listUpdateCase.size() + ' cases updated'));
            }
        } catch (Exception e) {
            System.debug('updateCases ERROR: ' + e.getMessage());
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage());
        }
        reset();
    }

    /**
        Select or unselect all cases
    **/
    public PageReference SelectAll() {
        for (WrapperCase wrapper: this.listWrapperCase ) {
            wrapper.selected = this.SelectAllCheckbox;
        }
      return null;
    }

    /**
        Get the number of elements in the case list selected by user
    **/
    public Integer getNumSelected() {
        Integer counter = 0;
        for (WrapperCase wrapper: listWrapperCase) {
            if (wrapper.selected) {
                counter++;
            }
        }
        return counter;
    }

    /**
        Wrapper to show a case in the main table adding a selection checkbox
    **/
    public class WrapperCase {
        public Boolean selected {get; set;}
        public Case cse {get; set;}

        public WrapperCase(Case cse) {
            this.cse = cse;
            this.selected = false;
        }
    }

    /**
        class to store all variables required to create a set of filters
        for the case selection
    **/
    public class WrapperFilter {
        public Case cse {get; set;}
        public String selectedActionType {get; set;}

        public WrapperFilter() {
            reset();
        }

        public void reset() {
            this.cse = new Case();
            this.cse.RecordtypeId = SIDRA_LITE_RECORDTYPE;
            this.cse.Region__c = SidraLiteUtil.getDefaultRegion();
            this.selectedActionType = '';
        }

        public List<SelectOption> getActionTypeList() {
            List<SelectOption> listOptions = new list<SelectOption>();
            listOptions.add(new SelectOption('','-- None --'));
            listOptions.add(new SelectOption('DEF','DEF Approval'));
            listOptions.add(new SelectOption('DEF Withdrawal','DEF Withdrawal Approval'));
            listOptions.add(new SelectOption('IRR Withdrawal','IRR Withdrawal Approval'));
            listOptions.add(new SelectOption('REI','REI Approval'));
            listOptions.add(new SelectOption('TER','TER Approval'));
            return listOptions;
        }
    }
}
