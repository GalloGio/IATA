public with sharing class SIDRAliteMassApprovalController{

    public static final Integer MAX_SEARCH_ELEMENTS = 900;
    public static final Id SIDRA_LITE_RECORDTYPE = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'SIDRA_Lite');
    public static final String APPROVED = 'Approved';
    public static final String REJECTED = 'Rejected';

    public static final String IRR = 'IRR';
    public static final String IRR_WD = 'IRR Withdrawal';
    public static final String DEF = 'DEF';
    public static final String DEF_WD = 'DEF Withdrawal';
    public static final String REI = 'REI';
    public static final String TER = 'TER';
    public static final String REI_AFTER_TER = 'REI After TER';
    public static final String NOT_APPROVAL = 'NOT';

    public list<WrapperCase> listWrapperCase {get;set;}
    public list<WrapperCase> listWrapperResult {get;set;}
    public WrapperFilter filter {get;set;}
    public String selectedIds {get;set;}
    public list<WrapperCase> listSelectedWrapper {get;set;}
    public Integer getSelectedIdsSize() {return this.listSelectedWrapper.size();}

    // variables to show/hide sections
    public Boolean approveCasesSection{get;set;}
    public Boolean rejectCasesSection{get;set;}
    public Boolean showProcessedSection{get;set;}

    /**
        Constructor
        by default the page is loaded with all cases searched without filter
    **/
    public SIDRAliteMassApprovalController() {
        reset();
    }

    /**
        Search all cases based on the filters selected by the user
    **/
    public void search() {
        if (this.filter.selectedActionType==null || this.filter.selectedActionType=='') {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.WARNING,'Select an Action Type'));
            return;
        }
        
        String query = 'Select Id, CaseNumber, SIDRA_Lite_Reason__c, BSP_CASS__c, Region__c, BSPCountry__c, DEF_Approval_Rejection__c, ';
        query += ' DEF_Withdrawal_Approval_Rejection__c, IRR_Approval_Rejection__c, IRR_Withdrawal_Approval_Rejection__c, REI_ApprovalRejectin__c, ';
        query += ' TER_Approval_Rejection__c, IRR_Withdrawal_Reason__c, DEF_Withdrawal_Reason__c, accountId, AIMS_status__c, CreatedDate, ';
        query += ' Reason_for_Default__c, Termination_Reason__c, Termination_date__c, OwnerId, Reason_of_REI_WD__c, Type_of_REI_WD__c, ';
        query += ' NOT_Approval__c, NOT_Date__c, Subject, Owner.Name, Account.Name, Account.Status__c';
        query += ' From Case';
        query += ' Where RecordtypeId = :SIDRA_LITE_RECORDTYPE';

        if (this.filter.cse.BSP_CASS__c != '' && this.filter.cse.BSP_CASS__c != null) {
            query += ' And BSP_CASS__c = \'' + this.filter.cse.BSP_CASS__c + '\'';
        }
        if (this.filter.cse.SIDRA_Lite_Reason__c != '' && this.filter.cse.SIDRA_Lite_Reason__c != null) {
            query += ' And SIDRA_Lite_Reason__c = \'' + this.filter.cse.SIDRA_Lite_Reason__c + '\'';
        }
        // Region is mandatory
        query += ' And Region__c = \'' + this.filter.cse.Region__c + '\'';
        if (this.filter.cse.BSPCountry__c != '' && this.filter.cse.BSPCountry__c != null) {
            query += ' And BSPCountry__c = \'' + this.filter.cse.BSPCountry__c + '\'';
        }
        if (this.filter.category != '' && this.filter.category != null) {
            query += ' AND Account.Category__c = \'' + String.escapeSingleQuotes(this.filter.category) + '\'';
        }
        if (this.filter.selectedActionType == IRR) {
            query += ' And IRR_Approval_Rejection__c = null';
        }
        if (this.filter.selectedActionType == IRR_WD) {
            query += ' And IRR_Withdrawal_Approval_Rejection__c = null';
            query += ' And IRR_Approval_Rejection__c = :APPROVED';
            query += ' And AG_Request_IRR_Withdrawal__c != null';
            if (this.filter.cse.IRR_Withdrawal_Reason__c != null) {
                query += ' And IRR_Withdrawal_Reason__c = \'' + this.filter.cse.IRR_Withdrawal_Reason__c + '\'';
            }
        }
        if (this.filter.selectedActionType == DEF) {
            query += ' And DEF_Approval_Rejection__c = null';
            query += ' And SIDRA_Lite_Default_Date__c != null';
            query += ' And Account.Status__c != \'Terminated\'';
        }
        if (this.filter.selectedActionType == DEF_WD) {
            query += ' And DEF_Withdrawal_Approval_Rejection__c = null';
            query += ' And DEF_Approval_Rejection__c = :APPROVED';
            query += ' And AG_Request_DEF_Withdrawal__c != null';
            if (this.filter.cse.DEF_Withdrawal_Reason__c != null) {
                query += ' And DEF_Withdrawal_Reason__c = \'' + this.filter.cse.DEF_Withdrawal_Reason__c + '\'';
            }
        }
        if (this.filter.selectedActionType == REI) {
            query += ' And REI_ApprovalRejectin__c = null';
            query += ' And DEF_Approval_Rejection__c = :APPROVED';
            query += ' And DEF_Withdrawal_Approval_Rejection__c != :APPROVED';
            query += ' And AG_Reinstatement_Request__c != null';
        }
        if (this.filter.selectedActionType == TER) {
            query += ' And TER_Approval_Rejection__c = null';
            query += ' And DEF_Approval_Rejection__c = :APPROVED';
            query += ' And (DEF_Withdrawal_Approval_Rejection__c != :APPROVED OR REI_ApprovalRejectin__c != :APPROVED)';
            query += ' And Propose_Default__c != null';
            query += ' And Account.Status__c != \'Terminated\'';
        }
        if (this.filter.selectedActionType == REI_AFTER_TER) {
            query += ' And TER_Approval_Rejection__c = :APPROVED';
            query += ' And Update_AIMS_TER__c != null';
            query += ' And REI_ApprovalRejectin__c  = null';
            query += ' And AG_Reinstatement_Request__c != null';
        }
        if (this.filter.selectedActionType == NOT_APPROVAL) {
            query += ' And NOT_Date__c != null';
            query += ' And NOT_Approval__c = null';
            query += ' And Account.Status__c != \'Terminated\'';
        }

        query += ' order by CaseNumber desc';
        query += ' limit ' + (MAX_SEARCH_ELEMENTS + 1);
        initListWrapperCase(query);

        // hide processed section to show result section
        this.showProcessedSection = false;
    }
    
    /**
        Creates a list of wrappers with the input query and checks if the maximum lilmit is exceeded
    **/
    private void initListWrapperCase(String query) {
        System.debug('*** QUERY: ' + query);
        this.listWrapperCase = new list<WrapperCase>();
        for (Case cse: Database.query(query)) {
            if (this.listWrapperCase.size() < MAX_SEARCH_ELEMENTS) {
                this.listWrapperCase.add(new WrapperCase(cse));
            } else {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,
                    'Your search criteria result exceeds the limit of number of records (' + MAX_SEARCH_ELEMENTS + ').'
                    + 'Try to apply more filters to reduce the number of records or process your request in multiple sessions'));
                return;
            }
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
        Shows the section to confirm the approval
    **/
    public PageReference confirmMassApproveCases() {
        this.approveCasesSection = true;
        updateListSelectedWrapper();
        return null;
    }

    /**
        Hides the section to confirm the approval
    **/
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
        //search();
        this.showProcessedSection = true;
        return null;
    }

    /**
        Shows the section to reject the approval
    **/
    public PageReference confirmMassRejectCases() {
        this.rejectCasesSection = true;
        updateListSelectedWrapper();
        return null;
    }

    /**
        Hides the section to reject the approval
    **/
    public PageReference cancelMassRejectCases() {
        this.rejectCasesSection = false;
        return null;
    }

    /**
        converts the string containing selected case ids to a list of selected wrapperCases
    **/
    private void updateListSelectedWrapper() {
        // get selected ids from string
        set<Id> setSelectedIds = new Set<Id>();
        for (String ids  : this.selectedIds.split(',')) {
            try {
                setSelectedIds.add(Id.valueOf(ids));
            } catch(Exception e) {
                System.debug( ids + ' ' + e.getMessage());
            }
        }

        // find those ids in list wrapper
        this.listSelectedWrapper = new list<WrapperCase>();
        for (WrapperCase wrapper: listWrapperCase) {
            if (setSelectedIds.contains(wrapper.cse.Id)) {
                this.listSelectedWrapper.add(wrapper);
            }
        }
    }

    /**
        Process done when the user clicks on the Rejection button
    **/
    public PageReference massRejectUpdateCases() {
        this.rejectCasesSection = false;
        updateCases(REJECTED);
        this.showProcessedSection = true;
        return null;
    }

    /**
        Reset filter
    **/
    public PageReference reset() {
        this.listWrapperCase = new list<WrapperCase>();
        this.filter = new WrapperFilter();
        this.approveCasesSection = false;
        this.rejectCasesSection = false;
        this.showProcessedSection = false;
        this.selectedIds = '';
        this.listSelectedWrapper = new list<WrapperCase>();
        return null;
    }

    /**
        Approves o rejects all selecte cases by the user
    **/
    private void updateCases(String ApproveReject) {
        String type = this.filter.selectedActionType;
        list<Case> listUpdateCase = new list<Case>();
        for (WrapperCase wrapper: this.listSelectedWrapper) {
            if (type == IRR) {
                wrapper.cse.IRR_Approval_Rejection__c = ApproveReject;
                if (ApproveReject==APPROVED) {
                    wrapper.cse.Propose_Irregularity__c = DateTime.now();
                }
            } else if (type == IRR_WD) {
                wrapper.cse.IRR_Withdrawal_Approval_Rejection__c = ApproveReject;
                wrapper.cse.R_S_Confirm_IRRWD_Justifications__c = DateTime.now();
                wrapper.cse.IRR_Withdrawal_Reason__c = filter.cse.IRR_Withdrawal_Reason__c;
                wrapper.cse.IRR_Withdrawal_Remarks__c = filter.cse.IRR_Withdrawal_Remarks__c;
            } else if (type == DEF) {
                wrapper.cse.DEF_Approval_Rejection__c = ApproveReject;
                wrapper.cse.Confirmation_moneys_not_received__c = DateTime.now();
                wrapper.cse.Reason_for_Default__c = filter.cse.Reason_for_Default__c;
                wrapper.cse.DEF_Approval_Rejection_Remarks__c = filter.cse.DEF_Approval_Rejection_Remarks__c;
            } else if (type == DEF_WD) {
                wrapper.cse.DEF_Withdrawal_Approval_Rejection__c = ApproveReject;
                wrapper.cse.R_S_Confirm_DEFWD_Justifications__c = DateTime.now();
                wrapper.cse.DEF_Withdrawal_Reason__c = filter.cse.DEF_Withdrawal_Reason__c;
                wrapper.cse.DEF_Withdrawal_Approval_Rejection_Remark__c = filter.cse.DEF_Withdrawal_Approval_Rejection_Remark__c;
            } else if (type == REI) {
                wrapper.cse.REI_ApprovalRejectin__c = ApproveReject;
                wrapper.cse.REI_Approval_Rejection_remarks__c = filter.cse.REI_Approval_Rejection_remarks__c;
                wrapper.cse.Reason_of_REI_WD__c = filter.cse.Reason_of_REI_WD__c;
                wrapper.cse.Type_of_REI_WD__c = filter.cse.Type_of_REI_WD__c;
            } else if (type == TER) {
                wrapper.cse.TER_Approval_Rejection__c = ApproveReject;
                wrapper.cse.Termination_Reason__c = filter.cse.Termination_Reason__c;
                wrapper.cse.FS_Action_requested__c = filter.cse.FS_Action_requested__c;
                wrapper.cse.TER_Approval_Rejection_Remarks__c = filter.cse.TER_Approval_Rejection_Remarks__c;
            } else if (type == REI_AFTER_TER) {
                wrapper.cse.REI_ApprovalRejectin__c = ApproveReject;
                wrapper.cse.Reason_of_REI_WD__c = filter.cse.Reason_of_REI_WD__c;
                wrapper.cse.Type_of_REI_WD__c = filter.cse.Type_of_REI_WD__c;
            } else if (type == NOT_APPROVAL) {
                wrapper.cse.NOT_Approval__c = ApproveReject;
            }
            listUpdateCase.add(wrapper.cse);
        }
        try {
            // make the update and store the results in a map
            list<Database.SaveResult> listResult = Database.update(listUpdateCase, false);
            map<Id,Database.SaveResult> mapResults = new map<Id,Database.SaveResult>();
            for (Database.SaveResult result: listResult) {
                mapResults.put(result.getId(),result);
            }
            // refill wrapper list case with updated cases plus save results
            this.listWrapperResult = new list<WrapperCase>();
            for (Case cse: [Select id, CaseNumber from Case where id in :listUpdateCase]) {
                WrapperCase wrapper = new WrapperCase(cse);
                wrapper.addResult(mapResults.get(wrapper.cse.Id));
                this.listWrapperResult.add(wrapper);
            }
            this.showProcessedSection = true;
        } catch (Exception e) {
            System.debug('updateCases ERROR: ' + e.getMessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,e.getMessage()));
        }
        reset();
    }

    /**
        Wrapper to show a case in the main table adding a selection checkbox
    **/
    public class WrapperCase {
        public Case cse {get; set;}
        public list<String> listErrors {get; set;}

        public WrapperCase(Case cse) {
            this.cse = cse;
            this.listErrors = new list<String>();
        }

        public void addResult(Database.SaveResult result) {
            if (result!=null && !result.isSuccess()) {
                for ( Database.Error error: result.getErrors()) {
                    this.listErrors.add(error.getMessage());
                }
            }
        }

        public Boolean getIsSuccess() {
            return this.listErrors.isEmpty();
        }
    }

    /**
        class to store all variables required to create a set of filters
        for the case selection
    **/
    public class WrapperFilter {
        public Case cse {get; set;}
        public String selectedActionType {get; set;}
        public String category {get; set;}

        public WrapperFilter() {
            reset();
        }

        public void reset() {
            this.cse = new Case();
            this.cse.RecordtypeId = SIDRA_LITE_RECORDTYPE;
            this.cse.Region__c = SidraLiteUtil.getDefaultRegion();
            this.selectedActionType = '';
            this.category = '';
        }
    }

    /**
        Redirect to the Page in csv format
    **/
    public PageReference exportCSV() {
        return Page.SIDRAliteMassApprovalExport;
    }

    /**
        Returns a string with the content of current listWrapper in csv format
    **/
    public String getcsvContent() {
        Map <String, Schema.SObjectField> mapCaseFields = Schema.getGlobalDescribe().get('Case').getDescribe().fields.getMap();

        // create csv header
        String content = '"Id"';
        content += ',"' + mapCaseFields.get('CaseNumber').getDescribe().getLabel() + '"';
        content += ',"' + mapCaseFields.get('Subject').getDescribe().getLabel() + '"';
        content += ',"' + mapCaseFields.get('SIDRA_Lite_Reason__c').getDescribe().getLabel() + '"';
        content += ',"' + mapCaseFields.get('BSP_CASS__c').getDescribe().getLabel() + '"';
        content += ',"' + mapCaseFields.get('Region__c').getDescribe().getLabel() + '"';
        content += ',"' + mapCaseFields.get('BSPCountry__c').getDescribe().getLabel() + '"';
        content += ',"' + mapCaseFields.get('OwnerId').getDescribe().getLabel() + '"';
        content += ',"' + mapCaseFields.get('OwnerId').getDescribe().getLabel() + ' Name"';
        content += ',"' + mapCaseFields.get('AccountId').getDescribe().getLabel() + ' Id"';
        content += ',"' + mapCaseFields.get('AccountId').getDescribe().getLabel() + ' Name"';
        content += ',"' + mapCaseFields.get('AIMS_status__c').getDescribe().getLabel() + '"';
        content += ',"' + mapCaseFields.get('CreatedDate').getDescribe().getLabel() + '"';
        content += '\n';
        // fill each line
        for (WrapperCase wrapper: this.listWrapperCase) {
            content += '"' +  wrapper.cse.Id + '"';
            content += ',"' + wrapper.cse.CaseNumber + '"';
            content += ',"' + wrapper.cse.Subject + '"';
            content += ',"' + wrapper.cse.SIDRA_Lite_Reason__c + '"';
            content += ',"' + wrapper.cse.BSP_CASS__c + '"';
            content += ',"' + wrapper.cse.Region__c + '"';
            content += ',"' + wrapper.cse.BSPCountry__c + '"';
            content += ',"' + wrapper.cse.OwnerId + '"';
            content += ',"' + wrapper.cse.Owner.Name + '"';
            content += ',"' + wrapper.cse.AccountId + '"';
            content += ',"' + wrapper.cse.Account.Name + '"';
            content += ',"' + wrapper.cse.AIMS_status__c + '"';
            content += ',"' + wrapper.cse.CreatedDate + '"';
            content += '\n';
        }
        return content;
    }

}
