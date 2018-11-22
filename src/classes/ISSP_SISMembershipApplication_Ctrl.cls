global class ISSP_SISMembershipApplication_Ctrl {
    
    public static final String APP_NAME = 'SIS Membership Application';
    public static final Id CASE_RT_AIRLINE_PARTICIPATION = Schema.SObjectType.Case.getRecordTypeInfosByDeveloperName().get('IDFS_Airline_Participation_Process').getRecordTypeId();
    public static final Map<String,Schema.RecordTypeInfo> MAP_AP_RT = Schema.SObjectType.AP_Process_Form__c.getRecordTypeInfosByDeveloperName();
    public static final Id AP_RT_ISPA = MAP_AP_RT.get('SIS_Application_ISPA').getRecordTypeId();
    public static final Id AP_RT_ISUA = MAP_AP_RT.get('SIS_Application_ISUA').getRecordTypeId();
    public static final Id AP_RT_TOU  = MAP_AP_RT.get('SIS_Application_TOU').getRecordTypeId();
    public static final Map<Id,String> MAP_RECORDTYPE_FORMS = new Map<Id,String>{
        AP_RT_ISPA => 'ISPA',
        AP_RT_ISUA => 'ISUA',
        AP_RT_TOU => 'TOU'
    };
    public static final Map<String,Id> MAP_FORMS_RECORDTYPE = new Map<String,Id>{
        'ISPA' => AP_RT_ISPA,
        'ISUA' => AP_RT_ISUA,
        'TOU' => AP_RT_TOU
    };
    public static final Map<String,String> MAP_DEFECT_ISSUE = new Map<String,String>{
        'ISPA' => 'Airlines (send/receive all categories)',
        'ISUA' => 'Suppliers (send/receive non transportation)',
        'TOU'  => 'Receiver only (non transportation)'
    };

    /**
        get field names list for features
    **/
    public list<String> getListFeatureNames() {
        return new list<String>{
            'Sending_e_invoices__c',
            'Receiving_e_invoices__c',
            'ERP_Integration__c',
            'Data_Validation__c',
            'Enables_Automated_Posting_Reconciliati__c',
            'Online_Functions_and_Dashboard__c',
            'Full_Traceability__c',
            'Transaction_Fees__c',
            'Invoice_and_details_in_Excel_format__c',
            'Payment_Status__c'};
    }

    public list<WrapperType> listWrapperType {get;set;}
    public list<AP_Process_Form__c> listExistingForms {get;set;}
    private User currentUser;
    @TestVisible private Account account;

    /**
        Start actions, check rights and terms and conditions
    **/
    public PageReference initActions() {
        try {
            String strId = this.currentUser.ContactId;
            Portal_Application_Right__c appRight = [
                SELECT Id, Right__c
                FROM Portal_Application_Right__c
                WHERE ContactId__c = :strId.left(15)
                AND Portal_Application__r.Name = :APP_NAME
            ];
            // If user has rights to use this app then return null
            if (appRight.Right__c=='Access Granted') {
                return null;
            }
            //otherwise go to home page
        } catch(Exception e) {
        }
        Pagereference pageref = Page.ISSP_Homepage;
        pageref.setRedirect(true);
        return pageref;
    }

    /**
        CONSTRUCTOR
    **/
    public ISSP_SISMembershipApplication_Ctrl() {
        // get current user
        this.currentUser = retrieveCurrentUser();

        Id hqAccountId = this.currentUser.Contact.Account.Top_Parent__c;
        if (hqAccountId==null) {
            hqAccountId = this.currentUser.Contact.AccountId;
        }
        // get top parent account
        this.account = [
            SELECT Id,Name,Legal_name__c,Status__c,Country_ISO_Code__c,
                Sector__c, Category__c,Airline_Prefix__c,Airline_designator__c,
                Give_SIS_Membership__c,SIS_Status__c,SIS_Sub_Status__c,
                BillingStreet,BillingCity,BillingState,BillingPostalCode,BillingCountry
            FROM Account
            WHERE Id = :hqAccountId];
        // get Sis types associated to related account
        this.listWrapperType = retrieveListSISType(this.account);
    }
    
    /**
        Find and return the current user record
    **/
    private static User retrieveCurrentUser() {
        return [
            SELECT Id, ContactId, Contact.AccountId, Contact.Account.Top_Parent__c
            FROM User
            WHERE id = :UserInfo.getUserId()];
    }

    /**
        get SIS types and permissions
    **/
    private list<WrapperType> retrieveListSISType(Account account) {
        //use this map to check if a specific SIS Membership type has an existing form in process
        map<String,AP_Process_Form__c> mapExistingForms = retrieveMapExistingForms(account);

        list<WrapperType> listWrapperType = new list<WrapperType>();
        Map<String,Sis_Management_Type__mdt> mapSisMembership = new Map<String,Sis_Management_Type__mdt>();
        for (Sis_Management_Type__mdt sisType:[
                SELECT Id, DeveloperName, MasterLabel, Description_Label__c, 
                    Sending_e_invoices__c, Receiving_e_invoices__c, ERP_Integration__c, Data_Validation__c,
                    Enables_Automated_Posting_Reconciliati__c, Online_Functions_and_Dashboard__c, 
                    Full_Traceability__c, Transaction_Fees__c, Invoice_and_details_in_Excel_format__c,
                    Payment_Status__c, Requirements_Text__c,
                    (SELECT Id, Sector__c, Category__c, Is_Visible__c from SIS_Management_Visibilities__r
                    WHERE Sector__c = :account.Sector__c
                    AND Category__c = :account.Category__c
                    AND Is_Visible__c = true)
                FROM Sis_Management_Type__mdt] ){
            mapSisMembership.put(sisType.DeveloperName, sisType);
            if (!sisType.SIS_Management_Visibilities__r.isEmpty()) {
                AP_Process_Form__c existingForm = mapExistingForms.get(sisType.DeveloperName);
                listWrapperType.add(new WrapperType(sisType, account, existingForm));
            }
        }

        // if permission is defined in the account
        if (account.Give_SIS_Membership__c!=null) {
            listWrapperType = new list<WrapperType>();
            for (String membershipName: account.Give_SIS_Membership__c.split(';')) {
                Sis_Management_Type__mdt sisType = mapSisMembership.get(membershipName);
                AP_Process_Form__c existingForm = mapExistingForms.get(sisType.DeveloperName);
                listWrapperType.add(new WrapperType(sisType,account, existingForm));
            }
        }
        return listWrapperType;
    }

    /**
        Try to find all SIS forms related to the input account
    **/
    private map<String,AP_Process_Form__c> retrieveMapExistingForms(Account account) {
        list<AP_Process_Form__c> listForms = [
            SELECT Id, RecordTypeId, Case__r.Id, Case__r.Status, Case__r.OwnerId, Case__r.Owner.Name,
                 Case__r.CreatedById, Case__r.CreatedBy.Name, Case__r.ContactId, Case__r.Contact.Name
            FROM AP_Process_Form__c
            WHERE Case__r.AccountId = :account.Id
            AND Case__r.RecordTypeId = :CASE_RT_AIRLINE_PARTICIPATION
            AND Case__r.isClosed = false
            AND (NOT Case__r.Owner.Name LIKE 'Recycle Bin%')
            AND RecordTypeId IN :MAP_RECORDTYPE_FORMS.keyset()
            ORDER BY CreatedDate desc];

        map<String,AP_Process_Form__c> mapForms = new map<String,AP_Process_Form__c>();
        for (AP_Process_Form__c form: listForms) {
            String formTypeName = MAP_RECORDTYPE_FORMS.get(form.RecordTypeId);
            mapForms.put(formTypeName, form);
        }
        return mapForms;
    }

    /**
        Create a case with a related form for a type of SIS membership
    **/
    public static AP_Process_Form__c createNewForm(String selectedType, Account account) {
        // check the type of membership for the new form
        Id formRT = MAP_FORMS_RECORDTYPE.get(selectedType);
        if (formRT==null) {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Invalid form type'));
            return null;
        }

        // create case and form objects
        Savepoint sPointContact = Database.setSavepoint();
        try {
            User currentUser = retrieveCurrentUser();
            Case newCase = new Case(
                RecordtypeId = CASE_RT_AIRLINE_PARTICIPATION,
                AccountId = account.Id,
                CaseArea__c = 'Airline Joining',
                Reason1__c = 'SIS Client',
                Classification_SIS__c = 'SIS Membership',
                Type = selectedType,
                Defect_Issue__c = MAP_DEFECT_ISSUE.get(selectedType),
                Subject = 'SIS Membership - ' + account.name + ' - ' + selectedType,
                Status = 'Draft',
                Origin = 'Portal',
                ContactId = currentUser.ContactId
            );
            insert newCase;

            AP_Process_Form__c form = new AP_Process_Form__c(
                RecordTypeId = formRT,
                Case__c = newCase.Id,
                Airline__c = account.Id
            );
            insert form;
            return [
                SELECT Id, RecordTypeId, Case__r.Id, Case__r.Status, Case__r.OwnerId, Case__r.Owner.Name,
                     Case__r.CreatedById, Case__r.CreatedBy.Name, Case__r.ContactId, Case__r.Contact.Name
                FROM AP_Process_Form__c
                WHERE Id = :form.Id];

        } catch(Exception e) {
            Database.rollback(sPointContact);
            System.debug('ERROR in createNewForm ' + e.getmessage());
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Cannot create this form' + e.getMessage()));
            return null;
        }
    }

    /**
        Wrapper class to pack a sis type, its form record and some functions
    **/
    @TestVisible
    class WrapperType {
        public Sis_Management_Type__mdt sisType{get;set;}
        private Account account;
        public AP_Process_Form__c form {get;set;}

        public WrapperType(Sis_Management_Type__mdt sistype, Account account, AP_Process_Form__c form) {
            this.sisType = sistype;
            this.account = account;
            this.form = form; // this form can be null, it means that there is no existing form and a new one can be created
        }

        /**
            Show Apply Now button if there is no existing form
            it means that clicking in this button will create a brand new form for this type
        **/
        public Boolean getShowApplyNow() {
            return !getShowCurrentMembership() && this.form==null;
        }

        /**
            Show Continue Process button if there is an opened form in Draft status
            Clicking in this button will redirect to that form
        **/
        public Boolean getShowContinueProcess() {
            return !getShowCurrentMembership() && this.form!=null && this.form.Case__r.Status == 'Draft';
        }

        /**
            Show Go To Case button if there is an opened form but it's parent case status 
            has been moved from Draft, In this situation the form is no loger editable.
            Clicking in this button will redirect to form's related case
        **/
        public Boolean getShowGoToCase() {
            return !getShowCurrentMembership() && this.form!=null && this.form.Case__r.Status != 'Draft';
        }

        /**
            Show info panel to inform that the current type is already approved
            This is defined in parent account SIS substatus field
        **/
        public Boolean getShowCurrentMembership() {
            String substatus = this.account.SIS_Sub_Status__c;
            return this.account.SIS_Status__c=='Active' 
                && substatus!=null 
                && substatus.containsIgnoreCase(this.sisType.DeveloperName);
        }

        /**
            When click here a new Case and form are created, then opens the page to edit them
        **/
        public PageReference applyNow() {
            this.form = createNewForm(this.sisType.DeveloperName, this.account);
            if (this.form==null || this.form.Id==null) return null;
            PageReference pageref = Page.ISSP_SISMembershipApplicationForm;
            pageref.getParameters().put('id',this.form.Id);
            pageref.setRedirect(true);
            return pageref;
        }

        /**
            Opens the existing form in edit mode
        **/
        public PageReference continueProcess() {
            if (this.form==null) return null;
            User currentUser = retrieveCurrentUser();
            if (this.form.Case__r.ContactId!=currentUser.ContactId) {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,Label.ISSP_SIS_Membership_Application_ongoing.replace('{0}',this.form.Case__r.Contact.Name)));
                return null;
            }
            PageReference pageref = Page.ISSP_SISMembershipApplicationForm;
            pageref.getParameters().put('id',this.form.Id);
            pageref.setRedirect(true);
            return pageref;
        }

        /**
            Redirect to the view Case page
        **/
        public PageReference goToCase() {
            UserRecordAccess recordAccess = [SELECT RecordId, HasTransferAccess, HasReadAccess, HasEditAccess, HasDeleteAccess, HasAllAccess
                FROM UserRecordAccess WHERE UserId = :UserInfo.getUserId() AND RecordId = :this.form.Id];
            if (!recordAccess.hasReadAccess) {
                
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.INFO,Label.ISSP_SIS_Membership_Application_no_access.replace('{0}',this.form.Case__r.CreatedBy.Name) ));
                return null;
            }
            PageReference pageref = Page.ISSP_Case;
            pageref.getParameters().put('caseId',this.form.Case__c);
            pageref.getParameters().put('mid','M1S2');
            pageref.setRedirect(true);
            return pageref;
        }
    }
}