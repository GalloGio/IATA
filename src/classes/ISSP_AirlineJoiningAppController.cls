public with sharing class ISSP_AirlineJoiningAppController {

    public static final String APP_NAME = 'Airline Joinings';

    private User currentUser;
    private Contact contact;
    private Account account;

    public list<WrapperType> listWrapperType {get;set;}

    public ISSP_AirlineJoiningAppController() {
        // get current user
        this.currentUser = [
            SELECT Id,
                Profile.Id, Profile.Name,
                Contact.Id,Contact.FirstName, Contact.LastName, Contact.Email,
                Contact.Account.Id, Contact.Account.Top_Parent__c, Contact.Account.Category__c
            FROM User
            WHERE id = :UserInfo.getUserId()];
        this.contact = this.currentUser.contact;
        this.account = this.currentUser.contact.account;

        this.listWrapperType = retrieveWrapper();
    }

    public Boolean getIsGSSAUser() {
        return this.currentUser.Profile.Name.startsWith('ISS Portal GSA');
    }

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
        get SIS types and permissions
    **/
    private list<WrapperType> retrieveWrapper() {
        list<WrapperType> listWrapperType = new list<WrapperType>();

        if(!getIsGSSAUser()) { //GSSA cannot create BSP cases
            listWrapperType.add(new WrapperType('BSP', null));
        }

        if(this.account.Category__c == 'IBCS consolidator'){
            listWrapperType.add(new WrapperType('BSP', null));
        }

        if(this.account.Category__c <> 'IBCS consolidator'){
            listWrapperType.add(new WrapperType('CASS Export', null));
            listWrapperType.add(new WrapperType('CASS Import', null));
        }

        listWrapperType.add(new WrapperType('ICH', null));

        return listWrapperType;
    }

    /**
        Wrapper class to pack a sis type, its form record and some functions
    **/
    @TestVisible
    class WrapperType {
        public String name {get;set;}
        public AP_Process_Form__c form {get;set;}

        public WrapperType(String name, AP_Process_Form__c form) {
            this.name = name;
            this.form = form; // this form can be null, it means that there is no existing form and a new one can be created
        }

        /**
            Show Apply Now button if there is no existing form
            it means that clicking in this button will create a brand new form for this type
        **/
        public Boolean getShowApplyNow() {
            return true;
        }

        /**
            Show Continue Process button if there is an opened form in Draft status
            Clicking in this button will redirect to that form
        **/
        public Boolean getShowContinueProcess() {
            return false;
        }

        /**
            Show Go To Case button if there is an opened form but it's parent case status 
            has been moved from Draft, In this situation the form is no loger editable.
            Clicking in this button will redirect to form's related case
        **/
        public Boolean getShowGoToCase() {
            return false;
        }

        /**
            Show info panel to inform that the current type is already approved
            This is defined in parent account SIS substatus field
        **/
        public Boolean getShowCurrentMembership() {
            return false;
        }

        /**
            When click here a new Case and form are created, then opens the page to edit them
        **/
        public PageReference applyNow() {
            return null;
        }

        /**
            Opens the existing form in edit mode
        **/
        public PageReference continueProcess() {
            return null;
        }

        /**
            Redirect to the view Case page
        **/
        public PageReference goToCase() {
            return null;
        }
    }
}