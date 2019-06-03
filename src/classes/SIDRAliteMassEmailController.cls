public with sharing class SIDRAliteMassEmailController{

    public static final Id SIDRA_LITE_RECORDTYPE = RecordTypeSingleton.getInstance().getRecordTypeId('Case', 'SIDRA_Lite');
    public static final String APPROVED = 'Approved';
    public static final String REJECTED = 'Rejected';

    public list<WrapperCase> listWrapperCase {get;set;}
    public Boolean SelectAllCheckbox{get;set;}
    public WrapperFilter filter{get;set;}
    public String sessionId {get;set;}
    public String apiServerUrl {get;set;}

    // variables to handle confirmation email
    public Boolean showConfirmationSection{get;set;}
    public Boolean confirmSendEmail{get;set;}
    public Boolean sendEmailToParentCase{get;set;}

    public SIDRAliteMassEmailController() {
        this.listWrapperCase = new list<WrapperCase>();
        this.SelectAllCheckbox = false;
        this.filter = new WrapperFilter();
        // init variable to handle approval and rejection
        this.showConfirmationSection = false;
        this.confirmSendEmail = false;
        search();
    }

    /**
    	Search all SIDRA lite cases with the filter selected by the user
    **/
    public void search() {
        String query = 'Select Id, accountId, contactId, SIDRA_Lite_Reason__c, account.Category__c, account.Sector__c, BSP_CASS__c, BSPCountry__c, CaseNumber, Confirm_IRR_Withdrawal_to_AG__c, Confirm_Reinstatement_to_AG__c, CS_Rep_Acc_DEF__c, CS_Rep_Acc_IRR_DEF__c, CS_Rep_ACC_IRR_Withdrawal__c, CS_Rep_Acc_REI__c, DEF_Approval_Rejection__c, DEF_Withdrawal_Approval_Rejection__c, Inform_Agent_DEF__c, IRR_Approval_Rejection__c, IRR_Withdrawal_Approval_Rejection__c, NOI_sent__c, Region__c, REI_ApprovalRejectin__c, TER_Approval_Rejection__c, Update_AIMS_DEF__c, Update_AIMS_IRR__c, Update_AIMS_IRRWITH__c, Update_AIMS_REI_DEFWITH__c, Reason_for_Default__c, DEF_Withdrawal_Reason__c, IRR_Withdrawal_Reason__c, Termination_Reason__c, FS_Action_requested__c, CreatedDate, parent.contactId ';
        query += ' From Case';
        query += ' Where RecordtypeId = :SIDRA_LITE_RECORDTYPE';
        //query += ' And isClosed = false';
        query += ' And ' + String.join(this.filter.getFilters(),' And ');
        query += ' order by CaseNumber desc';
        query += ' limit 2000';

        System.debug('*** QUERY: ' + query);

        this.listWrapperCase = new list<WrapperCase>();
        for (Case cse: Database.query(query)) {
            this.listWrapperCase.add(new WrapperCase(cse));
        }
    }

    /**
        Shows the section to confirm the email send
    **/
    public PageReference confirmSendEmailToCurrent() {
        this.showConfirmationSection = true;
        this.sendEmailToParentCase = false;
        return null;
    }

    public PageReference confirmSendEmailToParent() {
        this.showConfirmationSection = true;
        this.sendEmailToParentCase = true;
        return null;
    }

    /**
        get all cases selected by the user and send them to the send email Batch
    **/
    public PageReference sendEmails() {
        this.showConfirmationSection = false;
        if (!this.confirmSendEmail) {
            return null;
        }
        if (this.sessionId==null || this.sessionId=='') {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Session Id is missing'));
            return null;
        }
        if (this.apiServerUrl==null || this.apiServerUrl=='') {
            ApexPages.addMessage(new ApexPages.message(ApexPages.severity.ERROR,'Server URL is missing'));
            return null;
        }
        this.confirmSendEmail = false;
        list<Case> listSelected = new list<Case>();
        for( WrapperCase wrapper: this.listWrapperCase) {
            if (wrapper.selected) {
                listSelected.add(wrapper.cse);
            }
        }

        if ( listSelected.isEmpty()) {
          ApexPages.addMessage(new ApexPages.message(ApexPages.severity.WARNING,'There are no selected cases.'));
          return null;
        }

        SIDRAliteMassEmailBatch batch = new SIDRAliteMassEmailBatch(listSelected, this.filter.selectedActionType, this.sendEmailToParentCase, this.sessionId, this.apiServerUrl);
        ID batchprocessid = Database.executeBatch(batch,5);

        String message = 'The Email Reminders have been created but may take some time to be sent.' ;
        ApexPages.addMessage(new ApexPages.message(ApexPages.severity.INFO, message));

        return null;
    }

    /**
        Activate or deactivate all cases in the list
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
        wrapper used to list all cases in the main table with a checkbox
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
        class to handle all elements in the filter section
    **/
    public class WrapperFilter {
        public Case cse {get; set;}
        public Account account {get; set;}
        //public String selectedSector {get; set;}
        //public String selectedCategory {get; set;}
        public String selectedActionType {get; set;}

        public WrapperFilter() {
            reset();
        }

        /**
            Set filter to default status
        **/
        public void reset() {
            this.cse = new Case();
            this.cse.RecordtypeId = SIDRA_LITE_RECORDTYPE;
            this.cse.Region__c = SidraLiteUtil.getDefaultRegion();
            this.account = new Account();
            this.account.Sector__c = 'Travel Agent';
            this.account.Category__c = '';
            //this.selectedSector = 'Travel Agent';
            //this.selectedCategory = '';
            this.selectedActionType = 'DEF';
        }

        public list<SelectOption> getlistSector() {
            list<SelectOption> listOption = new list<SelectOption>();
            listOption.add(new SelectOption('Travel Agent', 'Travel Agent'));
            listOption.add(new SelectOption('Cargo Agent', Label.ISSP_Cargo_Label_Value));//WMO-391
            return listOption;
        }

        public list<SelectOption> getlistCategory() {
            list<SelectOption> listOption = new list<SelectOption>();
            listOption.add(new SelectOption('', '--None--'));
            if (this.account.Sector__c == 'Travel Agent') {
                listOption.add(new SelectOption('IATA Passenger Sales Agent', 'IATA Passenger Sales Agent'));
                listOption.add(new SelectOption('TIDS Agent', 'TIDS Agent'));
                listOption.add(new SelectOption('GSA General Sales Agent', 'GSA General Sales Agent'));
            }
            if (this.account.Sector__c == 'Cargo Agent') {
                listOption.add(new SelectOption('IATA Cargo Agent', 'IATA Cargo Agent'));
                listOption.add(new SelectOption('CASS Associate', 'CASS Associate'));
                listOption.add(new SelectOption('Import Agent', 'Import Agent'));
                listOption.add(new SelectOption('GSSA Cargo', 'GSSA Cargo'));
                listOption.add(new SelectOption('Handling Agent', 'Handling Agent'));
            }
            return listOption;
        }

        /**
            Creates a list with all available type lists
        **/
        public List<SelectOption> getActionTypeList() {
            List<SelectOption> listOptions = new list<SelectOption>();
            listOptions.add(new SelectOption('DEF','DEF Approval'));
            listOptions.add(new SelectOption('DEF Withdrawal','DEF Withdrawal Approval'));
            //listOptions.add(new SelectOption('IRR','IRR Approval'));
            listOptions.add(new SelectOption('IRR Withdrawal','IRR Withdrawal Approval'));
            listOptions.add(new SelectOption('REI','REI Approval'));
            listOptions.add(new SelectOption('TER','TER Approval'));
            return listOptions;
        }

        /**
            returns a list of conditions to be used in a where clause
            these conditions are based on the filter values
        **/
        public List<String> getFilters() {
            list<String> listFilters = new list<String>();
            if (this.cse.BSP_CASS__c != '' && this.cse.BSP_CASS__c != null) {
                listFilters.add('BSP_CASS__c = \'' + this.cse.BSP_CASS__c + '\'');
            }
            //if (this.cse.Region__c != '' && this.cse.Region__c != null) {
                listFilters.add('Region__c = \'' + this.cse.Region__c + '\'');
            //}
            if (this.cse.BSPCountry__c != '' && this.cse.BSPCountry__c != null) {
                listFilters.add('BSPCountry__c = \'' + this.cse.BSPCountry__c + '\'');
            }
            if (this.account.Sector__c != '' && this.account.Sector__c != null) {
                listFilters.add('account.Sector__c = \'' + this.account.Sector__c + '\'');
            }
            /*
            if (this.selectedSector != '' && this.selectedSector != null) {
                listFilters.add('account.Sector__c = \'' + this.selectedSector + '\'');
            }
            */
            if (this.account.Category__c != '' && this.account.Category__c != null) {
                listFilters.add('account.Category__c = \'' + this.account.Category__c + '\'');
            }
            /*
            if (this.selectedCategory != '' && this.selectedCategory != null) {
                listFilters.add('account.Category__c = \'' + this.selectedCategory + '\'');
            }
            */
            if (this.selectedActionType == 'IRR') {
                listFilters.add('IRR_Approval_Rejection__c = :APPROVED');
                listFilters.add('NOI_sent__c = null');
            }
            else if (this.selectedActionType == 'IRR Withdrawal') {
                listFilters.add('IRR_Withdrawal_Approval_Rejection__c = :APPROVED');
                listFilters.add('Confirm_IRR_Withdrawal_to_AG__c = null');
                if (this.cse.IRR_Withdrawal_Reason__c != null) {
                    listFilters.add('IRR_Withdrawal_Reason__c = \'' + this.cse.IRR_Withdrawal_Reason__c + '\'');
                }
            }
            else if (this.selectedActionType == 'DEF') {
                listFilters.add('DEF_Approval_Rejection__c = :APPROVED');
                listFilters.add('Inform_Agent_DEF__c = null');
            }
            else if (this.selectedActionType == 'DEF Withdrawal') {
                listFilters.add('DEF_Withdrawal_Approval_Rejection__c = :APPROVED');
                listFilters.add('Confirm_Reinstatement_to_AG__c = null');
                if (this.cse.DEF_Withdrawal_Reason__c != null) {
                    listFilters.add('DEF_Withdrawal_Reason__c = \'' + this.cse.DEF_Withdrawal_Reason__c + '\'');
                }
            }
            else if (this.selectedActionType == 'REI') {
                listFilters.add('REI_ApprovalRejectin__c = :APPROVED');
                listFilters.add('DEF_Withdrawal_Approval_Rejection__c != :APPROVED');
                listFilters.add('Confirm_Reinstatement_to_AG__c = null');
            }
            else if (this.selectedActionType == 'TER') {
                listFilters.add('TER_Approval_Rejection__c = :APPROVED');
                listFilters.add('Notify_TER_to_AG__c = null');
            }
            else {
                listFilters.add('1=0');
            }
            return listFilters;
        }
    }
}