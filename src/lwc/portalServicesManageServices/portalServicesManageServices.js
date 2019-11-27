import { LightningElement, track } from 'lwc';

//import navigation methods
import { NavigationMixin } from 'lightning/navigation';
import { getParamsFromPage, navigateToPage } from 'c/navigationUtils';

import goToOldIFAP from '@salesforce/apex/PortalProfileCtrl.goToOldIFAP';

//import labels
import aboutlb from '@salesforce/label/c.CSP_About';
import contactslb from '@salesforce/label/c.ISSP_Contacts';
import manageUserslb from '@salesforce/label/c.CSP_Manage_Portal_Users';
import goToServicelb from '@salesforce/label/c.CSP_Services_GoToService';
import cancelRequestlb from '@salesforce/label/c.CSP_Cancel_Request';
import newServiceRequestlb from '@salesforce/label/c.ISSP_New_Service_Request';
import newServiceAccessConfirmMsglb from '@salesforce/label/c.ISSP_ServiceAccessConfirm';
import newServiceRequestConfirmMsglb from '@salesforce/label/c.ISSP_ServiceRequestConfirm';
import confirmedRequestMsglb from '@salesforce/label/c.CSP_Confirmed_Requested_Service_Message';
import goToServiceslb from '@salesforce/label/c.CSP_Services_GoToServices';
import grantAccessNoUser from '@salesforce/label/c.ISSP_GrantAccess_NoUser';
import appRejectreason from '@salesforce/label/c.ISSP_Service_Approval_Rejection_Reason';
import confirmDenyAccessMsg from '@salesforce/label/c.CSP_Confirm_Deny_User_Access';
import confirmGrantAccessMsg from '@salesforce/label/c.CSP_Confirm_Grant_User_Access';
import grantAccessTitle from '@salesforce/label/c.CSP_Grant_User_Access_Title';
import denyAccessTitle from '@salesforce/label/c.CSP_Deny_User_Access_Title';
import ServiceAccess from '@salesforce/label/c.CSP_Service_Access';
import CancelServiceMessage from '@salesforce/label/c.CSP_CancelServiceMessage';
import CancelServiceActionLabel from '@salesforce/label/c.CSP_CancelServiceActionLabel';
import CSP_Search_NoResults_text1 from '@salesforce/label/c.CSP_Search_NoResults_text1';
import CSP_Search_NoResults_text2 from '@salesforce/label/c.CSP_Search_NoResults_text2';
import cancelAccessMsg from '@salesforce/label/c.CSP_Cancel_Access_Message';
import cancelAccessTitle from '@salesforce/label/c.CSP_Cancel_Access_Title';
import searchContactPlaceholder from '@salesforce/label/c.CSP_Search_In_Contacts_In_Service';
import ISSP_IATA_Location_Code from '@salesforce/label/c.ISSP_IATA_Location_Code';
import Email from '@salesforce/label/c.Email';
import Status from '@salesforce/label/c.Status';
import CSP_User from '@salesforce/label/c.CSP_User';
import confirm from '@salesforce/label/c.ISSP_Confirm';
import cancel from '@salesforce/label/c.CSP_Cancel';
import addUsers from '@salesforce/label/c.CSP_Add_User';
import newProfile from '@salesforce/label/c.CSP_NewContactProfile';
import newProfileMessage from '@salesforce/label/c.CSP_NewServiceUserMessage';
import addNewUser from '@salesforce/label/c.CSP_Add_New_User';
import ISSP_ANG_Portal_Role_AgencyReadOnly from '@salesforce/label/c.ISSP_ANG_Portal_Role_AgencyReadOnly';
import ISSP_ANG_Portal_Role_TicketIssuer from '@salesforce/label/c.ISSP_ANG_Portal_Role_TicketIssuer';
import ISSP_ANG_Portal_Role_MasterWalletManager from '@salesforce/label/c.ISSP_ANG_Portal_Role_MasterWalletManager';
import ISSP_ANG_Portal_Role_IEPAdmin from '@salesforce/label/c.ISSP_ANG_Portal_Role_IEPAdmin';
import ANG_ISSP_PORTAL_SERVICE_ROLE from '@salesforce/label/c.ANG_ISSP_PORTAL_SERVICE_ROLE';
import ISSP_Homepage_Pending_approval from '@salesforce/label/c.ISSP_Homepage_Pending_approval';
import ANG_ISSP_Request_Access_IATA_EasyPay from '@salesforce/label/c.ANG_ISSP_Request_Access_IATA_EasyPay';
import ANG_ISSP_IEP_Portal_Request_Access_Msg from '@salesforce/label/c.ANG_ISSP_IEP_Portal_Request_Access_Msg';
import ANG_ISSP_IEP_add_users_to_account_not_open_error_msg from '@salesforce/label/c.ANG_ISSP_IEP_add_users_to_account_not_open_error_msg';
import ISSP_AMC_CLOSE from '@salesforce/label/c.ISSP_AMC_CLOSE';
import CSP_Manage_Services_NoIEPAccount from '@salesforce/label/c.CSP_Manage_Services_NoIEPAccount';
import ISSP_ANG_GenericError from '@salesforce/label/c.ISSP_ANG_GenericError';

//import user id
import Id from '@salesforce/user/Id';



//import apex methods
import getServiceDetails from '@salesforce/apex/PortalServicesCtrl.getServiceDetails';
import getContacts from '@salesforce/apex/PortalServicesCtrl.getContactsAndStatusRelatedToServiceList';
import searchContacts from '@salesforce/apex/PortalServicesCtrl.searchContactsInService';
import goToOldPortalService from '@salesforce/apex/PortalServicesCtrl.goToOldPortalService';
import updateLastModifiedService from '@salesforce/apex/PortalServicesCtrl.updateLastModifiedService';
import grantUserAccess from '@salesforce/apex/PortalServicesCtrl.grantAccess';
import massGrantUserAccess from '@salesforce/apex/PortalServicesCtrl.massGrantAccess';
import massDenyUserAccess from '@salesforce/apex/PortalServicesCtrl.massDenyAccess';
import denyUserAccess from '@salesforce/apex/PortalServicesCtrl.denyAccess';
import getLoggedUser from '@salesforce/apex/CSP_Utils.getLoggedUser';
import getContactsForAssignment from '@salesforce/apex/PortalServicesCtrl.getContactsForServiceAssignment';
import grantServiceAccessToContacts from '@salesforce/apex/PortalServicesCtrl.grantAccessToContacts';
import getUserOptions from '@salesforce/apex/PortalServicesCtrl.getUserOptions';
import availableIEPPortalServiceRoles from '@salesforce/apex/PortalServicesCtrl.availableIEPPortalServiceRoles';
import newUserRequestableWithoutApproval from '@salesforce/apex/PortalServicesCtrl.newUserRequestableWithoutApproval';
import ActivateIEPUsers from '@salesforce/apex/PortalServicesCtrl.ActivateIEPUsers';
import CreateNewPortalAccess from '@salesforce/apex/PortalServicesCtrl.CreateNewPortalAccess';



import { ShowToastEvent } from 'lightning/platformShowToastEvent';


import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';

export default class PortalServicesManageServices extends NavigationMixin(LightningElement) {

    label = {
        aboutlb,
        contactslb,
        manageUserslb,
        goToServicelb,
        cancelRequestlb,
        newServiceRequestlb,
        newServiceAccessConfirmMsglb,
        newServiceRequestConfirmMsglb,
        confirmedRequestMsglb,
        goToServiceslb,
        grantAccessNoUser,
        appRejectreason,
        confirmDenyAccessMsg,
        confirmGrantAccessMsg,
        grantAccessTitle,
        denyAccessTitle,
        ServiceAccess,
        CancelServiceMessage,
        CancelServiceActionLabel,
        CSP_Search_NoResults_text1,
        CSP_Search_NoResults_text2,
        cancelAccessMsg,
        cancelAccessTitle,
        searchContactPlaceholder,
        confirm,
        cancel,
        addUsers,
        newProfile,
        newProfileMessage,
        addNewUser,
        ISSP_ANG_Portal_Role_AgencyReadOnly,
        ISSP_ANG_Portal_Role_TicketIssuer,
        ISSP_ANG_Portal_Role_MasterWalletManager,
        ISSP_ANG_Portal_Role_IEPAdmin,
        ANG_ISSP_PORTAL_SERVICE_ROLE,
        ISSP_Homepage_Pending_approval,
        ANG_ISSP_Request_Access_IATA_EasyPay,
        ANG_ISSP_IEP_Portal_Request_Access_Msg,
        ANG_ISSP_IEP_add_users_to_account_not_open_error_msg,
        ISSP_AMC_CLOSE,
        CSP_Manage_Services_NoIEPAccount,
        ISSP_ANG_GenericError
    };

    //links for images
    searchIconUrl = CSP_PortalPath + 'CSPortal/Images/Icons/searchColored.svg';

    @track iconLink;
    @track loadReady = false; // to prevent flicking between user and admin view's

    @track category = '';


    @track serviceId;
    @track serviceRecord = { //initialize record to avoid crashing with undefined access to recordService
        'recordService': {}
    };

    @track contactList = [];    //list of contacts organized by pages list<list<contacts>
    @track contactListOg = [];  // stores original contactList after filtering
    @track currentContactPage = []; //page being displayed
    @track pageList = [];         // list of pages for the pagination cmp
    @track totalNrPagesOg = 0;
    @track totalNrPages = 0; // total nr pages 
    @track totalNrRecords = 0;
    @track nrLoadedRecs = 0;     //nr of loaded records
    @track currentPageNumber = 1;

    searchMode = false;


    searchIconNoResultsUrl = CSP_PortalPath + 'CSPortal/Images/Icons/searchNoResult.svg';


    //Variables to trak
    @track showConfirm = false; // controls visibility on displaying confirm to request Access to portal sercice
    @track showPopUp = true;
    @track showSpinner = false;

    @track componentLoading = true;


    @track isAdmin = false;
    @track serviceName = false;
    @track isAgency = false;
    
    @track contactTableColums = [];
    @track contactsToAddColumns = [];
    @track showConfirmPopup = false;
    @track popupTitle = '';
    @track popupMsg = '';
    @track appRejReason = '';

    @track showSpinner = false;
    @track loadingContacts = false;

    //Add new user
    @track showAddUserModal = false;
    @track availableContacts = [];
    @track contactsToAdd = [];
    @track grantingAccess = false;
    @track canAddUsers = false;

    //IEP Rolelist
    @track roleList;
    @track isIEPService = false;
    @track radioOption = '';
    @track serviceFullName;


    @track IEPRoleSuccessModal = false;
    @track IEPDeniedModal = false;
    @track serviceIEPStatus;

    //user id from import
    userID = Id;

    serviceDetailsResult; // wire result holder

    PAGE_SIZE = 10; //nr of contact record per page

    // Variables for mass update
    @track selectedRecords = [];
    @track showMassApprove = false;
    @track showMassDeny = false;

    checkMassActionButtons() {
        if(this.selectedRecords && this.selectedRecords.length > 0) {
            const uniqueGrant = [...new Set(this.selectedRecords.map((rec) => {
                return rec.showGrant;
                })
            )];
            this.showMassApprove = !uniqueGrant.includes(false);
            
            const uniqueDeny = [...new Set(this.selectedRecords.map((rec) => {
                return rec.showDeny;
                })
            )];
            this.showMassDeny = !uniqueDeny.includes(false);

        } else {
            this.showMassApprove = false;
            this.showMassDeny = false;
        }
    }

    connectedCallback() {

        //get the parameters for this page
        this.pageParams = getParamsFromPage();
        if (this.pageParams) {
            this.serviceId = this.pageParams.serviceId;
        }

        getLoggedUser().then(userResult => {
            let loggedUser = JSON.parse(JSON.stringify(userResult));

            if(loggedUser.Contact != null && loggedUser.Contact.AccountId != null) {
                let account = loggedUser.Contact.Account;
                if(account.RecordType.DeveloperName === 'IATA_Agency' && 
                account.Status__c !== undefined && account.Status__c !== 'New application pending') {
                        this.isAgency = true;
                }

                this.contactTableColums = [
                    { label: CSP_User, fieldName: 'contactName', type: 'text' },
                    { label: Email, fieldName: 'emailAddress', type: 'text' },
                    { label: ISSP_IATA_Location_Code, fieldName: 'iataCodeLoc', type: 'text' },
                    { label: Status, fieldName: 'serviceRight', type: 'text' },
                    { type: 'action', typeAttributes: { iconName: 'utility:delete', disabled: true, rowActions: this.getRowActions } }
                ];
        
                //Remove column IATA Code (Location) if User Account is not an Agency
                if(!this.isAgency) {
                    this.contactTableColums = this.contactTableColums.slice(0, 2).concat(this.contactTableColums.slice(3));
                }

           this.contactsToAddColumns = [
            { label: 'User', fieldName: 'title', type: 'text' },
            { label: 'Email', fieldName: 'subtitle', type: 'text' },
            { label: 'IATA Location Code', fieldName: 'iataCodeLocation', type: 'text' },
            { label: 'Status', fieldName: 'status', type: 'text' },
            { label: '', type: 'button', initialWidth: 35, typeAttributes: { label: '', variant: "base", title: 'Remove', name: 'removeContact', iconName: 'utility:delete' } }
        ];
            }
        });


        //get the service details
        this.getServiceDetailsJS();

    }

    resetComponent() {
        //Resets the component properties back to the start
        this.appRejReason = '';
        this.contactList = [];    //list of contacts organized by pages list<list<contacts>
        this.contactListOg = [];  // stores original contactList after filtering
        this.currentContactPage = []; //page being displayed
        this.pageList = [];         // list of pages for the pagination cmp
        this.totalNrPagesOg = 0;
        this.totalNrPages = 0; // total nr pages 
        this.totalNrRecords = 0;
        this.nrLoadedRecs = 0;     //nr of loaded records
        this.currentPageNumber = 1;
		this.selectedRecords = [];

        this.getServiceDetailsJS();
    }

    getServiceDetailsJS() {
        if (this.serviceId !== undefined && this.serviceId !== '') {

            getServiceDetails({ serviceId: this.serviceId })
                .then(result => {

                    this.serviceRecord = JSON.parse(JSON.stringify(result));
                    this.isAdmin = this.serviceRecord.isAdmin;
                    this.loadReady = true;
                    this.serviceName = this.serviceRecord.recordService.ServiceName__c;
                    this.serviceFullName = this.serviceRecord.recordService.Name;
                    this.isIFG_Service = this.serviceRecord.isIFGPending;

                    if (this.serviceName.includes('IATA EasyPay')) {
                        this.serviceIEPStatus = this.serviceRecord.accessGranted;
                    }


                    if (this.isAdmin) {
                        this.getContactsForPage();
                        this.getContactsForAssignment();
                        this.getCanAddUsers();
                    } else {
                        //this.showSpinner = false;
                        this.componentLoading = false;
                    }
                })
                .catch(error => {
                    //this.showSpinner = false;
                    this.componentLoading = false;
                });

        }
    }

    //Display Add New User button if isAdmin and service can be managed or is EasyPay
    getCanAddUsers() {
        newUserRequestableWithoutApproval({ isAdmin: this.isAdmin, serviceId: this.serviceId })
            .then(result => {
                this.canAddUsers = result;
            });
    }

    getContactsForPage() {
        getContacts({ serviceId: this.serviceId, offset: this.nrLoadedRecs })
            .then(result => {
                let resultData = JSON.parse(JSON.stringify(result));
                this.initialPageLoad(resultData, this.serviceRecord.totalNrContacts);

                //this.showSpinner = false;
                this.componentLoading = false;
                this.checkMassActionButtons();
            });
    }

    get renderCancelRequest() {
        //for either normal users and admin users
        let returnBool = this.serviceRecord !== undefined && this.serviceRecord.recordService !== undefined &&
            ((this.serviceRecord.accessGranted === true && this.serviceRecord.recordService.Requestable__c !== undefined && this.serviceRecord.recordService.Requestable__c === true && this.serviceRecord.recordService.Cannot_be_managed_by_portal_admin__c !== undefined && this.serviceRecord.recordService.Cannot_be_managed_by_portal_admin__c === false) ||
                (this.serviceRecord.accessRequested === true && this.serviceRecord.recordService.Requestable__c !== undefined && this.serviceRecord.recordService.Requestable__c === true));
        return returnBool;
    }

    //==================== CONTACT LIST METHODS ==============

    //loads and organizes the records in pages
    initialPageLoad(contactList, totalNrRecs) {
        this.totalNrRecords = totalNrRecs;
        this.totalNrPages = totalNrRecs.length === 0 ? 0 : Math.ceil(totalNrRecs / this.PAGE_SIZE);
        this.processContacList(contactList, 1);
        this.generatePageList();
    }

    //transforms the received list in page form
    processContacList(contactList, startPage) {
        let tempList = [];
        let tempPage = [];

        for (let i = 1; i <= contactList.length; i++) {
            tempPage.push(contactList[i - 1]);
            if ((i % this.PAGE_SIZE) === 0) { // organizes the records by pages
                tempList.push(tempPage);
                tempPage = [];
            }
        }

        if (tempPage.length > 0) tempList.push(tempPage);

        if (this.contactList.length === 0) //on first load
            this.contactList = tempList;
        else {
            let contList = JSON.parse(JSON.stringify(this.contactList));
            this.contactList = contList.concat(tempList); // adds to current page list
        }

        this.currentPageNumber = startPage;
        this.currentContactPage = tempList[startPage - 1];
        if (!this.searchMode)
            this.nrLoadedRecs += contactList.length;

    }

    //generates paginators menu
    generatePageList() {
        let currentPageList = [];
        let currentTotalPages = this.totalNrPages;

        if (currentTotalPages > 1) {
            if (currentTotalPages <= 10) {
                let counter = 2;
                for (; counter < currentTotalPages; counter++) {
                    currentPageList.push(counter);
                }
            } else {
                if (this.currentPageNumber < 5) {
                    currentPageList.push(2, 3, 4, 5, 6);
                } else {
                    if (this.currentPageNumber > (currentTotalPages - 5)) {
                        currentPageList.push(currentTotalPages - 5, currentTotalPages - 4, currentTotalPages - 3, currentTotalPages - 2, currentTotalPages - 1);
                    } else {
                        currentPageList.push(this.currentPageNumber - 2, this.currentPageNumber - 1, this.currentPageNumber, this.currentPageNumber + 1, this.currentPageNumber + 2);
                    }
                }
            }
        }
        this.pageList = currentPageList;
    }

    // ============= PAGINATION Event Methods =======
    handlePreviousPage() {
        this.refreshContactPageView(this.currentPageNumber - 1);

    }
    handleNextPage() {
        this.refreshContactPageView(this.currentPageNumber + 1);

    }
    handleSelectedPage(event) {
        //the event contains the selected page
        this.refreshContactPageView(event.detail);
    }

    handleFirstPage() {
        this.refreshContactPageView(1);

    }
    handleLastPage() {
        this.refreshContactPageView(this.totalNrPages);
    }


    //navigates and renders results for the selected page
    refreshContactPageView(currentPage) {

        this.currentPageNumber = currentPage;
        let newPage = this.contactList[this.currentPageNumber - 1];
        //if page not loaded yet        
        if (!newPage) {
            this.loadingContacts = true;
            getContacts({ serviceId: this.serviceId, offset: this.nrLoadedRecs }).then(result => {
                let resultData = JSON.parse(JSON.stringify(result));
                this.processContacList(resultData, currentPage);
                this.generatePageList();
                this.refreshContactPageView(currentPage);
            });
        }else{
            this.generatePageList();
        }
        this.loadingContacts = false;
        this.currentContactPage = this.contactList[this.currentPageNumber - 1];
    }

    //search Records
    searchRecord(event) {
        let searchKey = event.target.value.toLowerCase().trim();
        this.searchKey = searchKey;
        if (searchKey !== '' && searchKey.length >= 3) {
            //enters search mode
            //backups already retrieve values from server to _og variables
            if (!this.searchMode) {
                this.searchMode = true;
                this.contactListOg = this.contactList.slice();
                this.totalNrPagesOg = this.totalNrPages;
            }
            //if all records loadded searches localy only
            if (this.totalNrRecords == this.nrLoadedRecs) {

                let tempContactPagesList = JSON.parse(JSON.stringify(this.contactListOg.slice()));
                let resultList = [];
                tempContactPagesList.forEach((el, pos, arr) => {
                    let filteredResults = el.filter((el) => {
                        //to avoid uninitialized values
                        if (!el.contactName) el.contactName = '';
                        if (!el.iataCodeLoc) el.iataCodeLoc = '';
                        if (!el.emailAddress) el.emailAddress = '';
                        return el.contactName.toLowerCase().search(searchKey) != -1 || el.iataCodeLoc.toLowerCase().search(searchKey) != -1 || el.emailAddress.toLowerCase().search(searchKey) != -1;
                    });
                    resultList = resultList.concat(filteredResults);

                });

                this.contactList = [];
                this.processContacList(resultList, 1);
                this.totalNrPages = Math.ceil(resultList.length / this.PAGE_SIZE);
                this.generatePageList();
            } else {
                //searchs from db - invokes server to retrieve search result
                searchContacts({ serviceId: this.serviceId, searchkey: searchKey }).then(result => {
                    let tempSearchResult = JSON.parse(JSON.stringify(result));

                    this.contactList = [];
                    this.totalNrPages = Math.ceil(tempSearchResult.length / this.PAGE_SIZE);
                    this.processContacList(tempSearchResult, 1);
                    this.generatePageList();
                });
            }
        } else if (searchKey === '') {
            if (this.searchMode) {
                //Exit search mode
                //restore all records already retrieved
                this.searchMode = false;
                this.contactList = this.contactListOg.slice();
                this.totalNrPages = this.totalNrPagesOg;
                this.generatePageList();
                this.refreshContactPageView(1);
            }
        }

    }

    //toggles dropdown when access requested
    togglebuttongroup() {
        this.template.querySelector('[data-dropmenu]').classList.toggle('s lds-is-open');
    }

    //displays the actions based the action visibility
    getRowActions(row, doneCallback) {
        //available on the next US
        const actions = [];
        if (row) {
            if (row.showGrant) {
                actions.push({
                    'label': 'Grant Access',
                    'name': 'activateUser'
                });
            }
            if (row.showDeny) {
                actions.push({
                    'label': 'Deny Acces',
                    'name': 'deactivateUser'
                });
            }

            if (row.showIfap) {
                actions.push({
                    'label': 'Assign IFAP Contact',
                    'name': 'ifapContact'
                });
            }
            doneCallback(actions);
        }

    }

    onRowSelection(event) {
        const selectedRows = event.detail.selectedRows;
        this.selectedRecords = selectedRows;
        
        this.checkMassActionButtons();
    }

    handleMassApproveAccess(event) {
        console.log('MASS Approve', event.detail, this.selectedRecords);
        let contactNames = this.selectedRecords.map(function(elem){
            return elem.contactName;
        }).join("; ");

        this.popupTitle = this.label.grantAccessTitle;
        
        this.popupMsg = this.label.confirmGrantAccessMsg.replace('{0}', this.serviceRecord.recordService.ServiceName__c).replace('{1}', contactNames);
        this.mode = 'mass_grant';
        this.showConfirmPopup = true;
    }

    handleMassDenyAccess(event) {
        console.log('MASS DENY', event.detail, this.selectedRecords);
        let contactNames = this.selectedRecords.map(function(elem){
            return elem.contactName;
        }).join("; ");

        let title = this.label.denyAccessTitle;
        let msg = this.label.confirmDenyAccessMsg.replace('{0}', this.serviceRecord.recordService.ServiceName__c).replace('{1}', contactNames);
        
        this.popupTitle = title;
        this.popupMsg = msg;

        this.mode = 'mass_deny';
        this.showConfirmPopup = true;
    }

    //Action on the top button ( request access or navigate to service)
    handleTopAction() {
        let serviceRec = JSON.parse(JSON.stringify(this.serviceRecord));

        if (serviceRec.accessGranted) {
            //goes to service
            let appInfo = serviceRec.recordService
            this.goToService(appInfo);
        } else {
            //displays popup to confirm request
            this.showConfirm = true;
        }
    }

    get renderRequest() {
        let returnBool = this.serviceRecord.accessRequested === true;
        return returnBool;
    }


    //only display contact list for portal admins with access granted
    get displayAdminView() {
        return this.isAdmin;
    }

    //Callback on service request submit completed
    requestComplete(event) {
        if (event.detail.success) {
            this.resetComponent();
            //refreshApex(this.serviceDetailsResult);
        }
        this.resetComponent();
        this.showConfirm = false;
    }

    //navigates to service
    goToService(serviceAux) {

        //attributes stored on element that is related to the event
        let appFullUrlData = serviceAux.Application_URL__c;
        let openWindowData = serviceAux.New_Window__c;
        let requestable = serviceAux.Requestable__c
        let recordId = serviceAux.Id;

        // update Last Visit Date on record
        updateLastModifiedService({ serviceId: recordId })

        let myUrl = appFullUrlData;

        //verifies if the event target contains all data for correct redirection
        if (openWindowData !== undefined) {
            //determines if the link is to be opened on a new window or on the current
            if (openWindowData === "true") {
                if (appFullUrlData !== 'undefined') {
                    myUrl = appFullUrlData;
                }
                //is this link a requestable Service?
                if (requestable === "true") {
                    //method that redirects the user to the old portal maintaing the same loginId
                    goToOldPortalService({ myurl: myUrl })
                        .then(result => {
                            //stop the spinner
                            this.toggleSpinner();
                            //open new tab with the redirection
                            window.open(result);
                        })
                        .catch(error => {
                            //throws error
                            this.error = error;
                        });
                } else {
                    myUrl = window.location.protocol + '//' + window.location.hostname + myUrl;
                    window.open(myUrl);
                }
            } else {
                window.location.href = myUrl;
            }
        }
    }


    navigateToServicesPage() {
        navigateToPage("services");
    }


    get cancelMessage() {
        return CancelServiceMessage.replace('{0}', this.serviceName);
    }
    get cancelLink() {
        return CancelServiceActionLabel.replace('{0}', this.serviceName);
    }

    get renderCancelService() {
        return this.serviceRecord.accessGranted;
    }

    get noResultsFound() {
        return this.searchMode && this.contactList.length == 0;
    }

    get noContactsToAdd() {
        return this.contactsToAdd === undefined || this.contactsToAdd.length == 0;
    }

    get confirmAddUserClass() {
        return this.noContactsToAdd ? 'containedButtonWhite' : 'containedButton';
    }

    //Cancel Service Access
    cancelServiceAccessRequest(event) {
        let contact = {
            contactId: this.serviceRecord.userContactId
        };
        let msg = this.label.cancelAccessMsg.replace('{0}', this.serviceName);
        let title = this.label.cancelAccessTitle;

        this.denyUserAccessJS(contact, msg, title, false);

    }



    //================== Admin Section =======================//

    handleRowAction(event) {
        //handles row actions (grant/deny Access)
        const row = event.detail.row;
        const actionName = event.detail.action.name;

        switch (actionName) {
            case 'activateUser':
                this.grantUserAccess(row);
                break;
            case 'deactivateUser':
                let title = this.label.denyAccessTitle;
                let msg = this.label.confirmDenyAccessMsg.replace('{0}', this.serviceRecord.recordService.ServiceName__c).replace('{1}', row.contactName);
                this.denyUserAccessJS(row, msg, title, true);
                break;
            case 'ifapContact':
                const {contactId, contactName } = row;
                
                goToOldIFAP({hasContact : true, contactId : contactId, contactName : contactName}).then(results => {
                    window.open(results, "_self");
                });
                
                break;
            default:
        }
    }


    //grant access to the service
    grantUserAccess(contact) {
        this.popupTitle = this.label.grantAccessTitle;
        this.selectedlRow = contact;
        if (contact.hasNoContact) {
            this.popupMsg = this.label.grantAccessNoUser;
        } else {
            this.popupMsg = this.label.confirmGrantAccessMsg.replace('{0}', this.serviceRecord.recordService.ServiceName__c).replace('{1}', contact.contactName);
        }
        this.mode = 'grant';
        this.showConfirmPopup = true;
    }

    denyUserAccessJS(contact, msg, title, isFromContactTable ){
        this.popupTitle = title;
        this.selectedlRow = contact;
        this.popupMsg = msg;
        this.isFromContactTable = isFromContactTable;

        this.mode = 'deny';
        this.showConfirmPopup = true;
    }

    //================== Popup Methods =======================// 
    handleChangeReason(event) {
        this.appRejReason = event.target.value;
    }

    handlePopupCancelAction() {
        this.showConfirmPopup = false;
    }

    handlePopupConfirmAction() {
        this.showSpinner = true;

        let methodParams = {
            serviceId: this.serviceRecord.recordService.Id,
            reason: this.appRejReason
        };
        switch (this.mode) {
            case 'grant':
                methodParams.contactId = this.selectedlRow.contactId;
                grantUserAccess(methodParams).then(result => {
                    this.componentLoading = true;
                    this.showSpinner = false;
                    this.showConfirmPopup = false;
                    this.resetComponent();
                }).catch(error=>{
					this.showSpinner = false;
                    this.showConfirmPopup = false;
                });
                break;
            case 'deny':
                methodParams.contactId = this.selectedlRow.contactId;
                methodParams.isFromContactTable = this.isFromContactTable;

                denyUserAccess(methodParams).then(result => {
                    this.componentLoading = true;
                    this.showSpinner = false;
                    this.showConfirmPopup = false;
                    this.resetComponent();
                }).catch(error => {
					this.showSpinner = false;
                    this.showConfirmPopup = false;
                });
                break;
            case 'mass_grant':
                this.confirmMassGrantAction(this.selectedRecords);
                break;
            case 'mass_deny':
                this.confirmMassDenyAction(this.selectedRecords);
                break;
            default:
                this.showSpinner = false;
        }
    }

    confirmMassGrantAction(recordsList) {
        let contactIds = recordsList.map((rec) => { return rec.contactId });

        let methodParam = { 
            contactIds: contactIds,
            serviceId: this.serviceRecord.recordService.Id,
            reason: this.appRejReason
        };

        massGrantUserAccess(methodParam)
        .then(result => {
            this.componentLoading = true;
            this.showSpinner = false;
            this.showConfirmPopup = false;

            this.resetComponent();
            this.checkMassActionButtons();
        }).catch( error => {
            this.showConfirmPopup = false;
            this.showSpinner = false;
            this.componentLoading = false;
            this.checkMassActionButtons();
            
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error,
                    variant: 'error'
                })
            );
        });
    }
    
    confirmMassDenyAction(recordsList) {
        let contactIds = recordsList.map((rec) => { return rec.contactId });

        let methodParam = { 
            contactIds: contactIds,
            serviceId: this.serviceRecord.recordService.Id,
            reason: this.appRejReason
        };

        massDenyUserAccess(methodParam)
        .then(result => {
            this.componentLoading = true;
            this.showSpinner = false;
            this.showConfirmPopup = false;
            
            this.resetComponent();
            this.checkMassActionButtons();
        }).catch( error => {
            this.showConfirmPopup = false;
            this.showSpinner = false;
            this.componentLoading = false;
            this.checkMassActionButtons();

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: error,
                    variant: 'error'
                })
            );
        });
    }

    /* Add Users to service */
    toggleAddUserModal() {
        this.showAddUserModal = !this.showAddUserModal;
        this.contactsToAdd = [];
        this.radioOption = '';
        if (this.showAddUserModal) {
            this.isIEPService = false;
            if (this.serviceName.includes('IATA EasyPay')) {
                this.isIEPService = true;
                getUserOptions({ portalUser: this.userID })
                    .then(useropts => {
                        let userOptions = JSON.parse(JSON.stringify(useropts));
                        if (userOptions.IEP_Status === 'Open') {
                            availableIEPPortalServiceRoles({ serviceId: this.serviceId })
                                .then(data => {
                                    let roleslist = JSON.parse(JSON.stringify(data));
                                    this.roleList = roleslist;
                                    this.roleList = this.roleList.filter(obj => obj.Connected_App__c === this.serviceFullName);
                                    this.roleList = this.roleList.sort((a, b) => (a.Order__c > b.Order__c) ? 1 : -1);
                                    for (const item of this.roleList) {
                                        let newlabel = 'ISSP_ANG_Portal_Role_' + item.Role__c.split(' ').join('');
                                        item.label = this.label[newlabel];
                                    }
                                });
                        } else {
                            this.showAddUserModal = !this.showAddUserModal;
                            this.IEPDeniedModal = true;
                        }
                    });
            }
        }
    }

    closeIEPDenied() {
        this.IEPDeniedModal = false;
    }

    handlRadioOptions(event) {
        const radioOption = event.target.attributes.getNamedItem('data-id');
        event.target.value = !event.target.value;
        this.selectedRole(radioOption);
    }

    selectedRole(radioOption) {
        this.radioOption = radioOption.value;
    }

    confirmAddUser() {

        if (this.isIEPService && (this.radioOption === undefined || this.radioOption === null || this.radioOption === '')) {

            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: 'Please select a role.\n',
                    variant: 'error'
                })
            );

        } else if (this.isIEPService && (this.radioOption !== undefined || this.radioOption !== null)) {

            console.log(this.contactsToAdd);
            const contactsToAddIDs = this.contactsToAdd.map(function (el) { return el.id; });
            const serviceid = this.serviceId;
            const roleSelected = this.radioOption;
            this.showSpinner = true;
            //Activate Users that are inactive

            ActivateIEPUsers({ contactIds: contactsToAddIDs })
                .then(() => {

                    CreateNewPortalAccess({
                        ContactIds: contactsToAddIDs,
                        ServiceId: serviceid,
                        PortalServiceRole: roleSelected
                    }).then(result => {

                        this.showSpinner = false;
                        this.showAddUserModal = false;
                        const results = JSON.parse(JSON.stringify(result));

                        if (results === 'Success') {
                            this.IEPRoleSuccessModal = true;

                        } else if (results === 'Failure') {
                            this.dispatchEvent(
                                new ShowToastEvent({
                                    title: 'Error',
                                    message: 'Unable to grant service access.\n',
                                    variant: 'error'
                                })
                            );
                        }
                    }).catch(error => {
                        this.showSpinner = false;
                        console.log(error);
                        this.componentLoading = false;
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error',
                                message: this.label.ISSP_ANG_GenericError,
                                variant: 'error'
                            })
                        );
                    });

                }).catch(error => {
                    this.showSpinner = false;
                    this.componentLoading = false;
                    console.log(error);
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: this.label.ISSP_ANG_GenericError,
                            variant: 'error'
                        })
                    );
                });

        } else {

            this.grantingAccess = true;
            let contactIds = [];

            this.contactsToAdd.forEach((el, pos, arr) => {
                contactIds.push(el.id);
            });

            if (contactIds.length > 0) {
                grantServiceAccessToContacts({ contactIds: contactIds, serviceId: this.serviceId })
                    .then(result => {
                        this.grantingAccess = false;
                        this.contactsToAdd = [];
                        this.showAddUserModal = false;
                        this.resetComponent();
                    }).catch((error) => {
                        this.grantingAccess = false;
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error',
                                message: 'Unable to grant service access.\n',
                                variant: 'error'
                            })
                        );
                    });
            }
        }

    }

    closeIEPConfirm() {
        this.IEPRoleSuccessModal = false;
    }

    getAvailableContacts() {
        let availableContacts = JSON.parse(JSON.stringify(this.availableContacts));
        let toAdd = JSON.parse(JSON.stringify(this.contactsToAdd));

        let available = availableContacts.filter(function (c) {
            c.iataCodeLocation = c.extraFields.iataCodeLocation;
            c.status = c.extraFields.status;

            return !toAdd.some(contact => contact.id === c.id)
        });
        this.template.querySelector('[data-id="contactlookup"]').setSearchResults(available);
    }

    addAllContactEntries() {
        let selection = this.template.querySelector('[data-id="contactlookup"]').getSearchResults();

        let contactsToAdd = JSON.parse(JSON.stringify(this.contactsToAdd));

        selection.forEach((el, pos, arr) => {
            contactsToAdd.push(JSON.parse(JSON.stringify(el)));
        });

        this.contactsToAdd = contactsToAdd;

    }

    addContactEntry() {
        let inputCmp = this.template.querySelector('[data-id="contactlookup"]').getSelection();//[0].id;
        let comp = this.template.querySelector('[data-name="selectionList"]');

        let values = inputCmp;
        inputCmp = [];
        comp.focus();

        let availableContacts = JSON.parse(JSON.stringify(this.availableContacts));

        let contactsToAdd = JSON.parse(JSON.stringify(this.contactsToAdd));

        values.forEach((c, pos, arr) => {
            let contact = availableContacts.find(function (con) { return c.id === con.id; });
            contact .deleteIcon = 'utility:delete';

            contactsToAdd.push(contact);
        });

        this.contactsToAdd = contactsToAdd;
    }

    removeContact(event) {
        let itemVal = event.target.dataset.item;
        let contactsToAdd = JSON.parse(JSON.stringify(this.contactsToAdd));

        this.contactsToAdd = contactsToAdd.filter(item => item.id !== itemVal);
    }

    getContactsForAssignment() {
        getContactsForAssignment({ serviceId: this.serviceId }).then(result => {

            let availableContacts = JSON.parse(JSON.stringify(result));
            let toAdd = JSON.parse(JSON.stringify(this.contactsToAdd));

            let available = availableContacts.filter(function (c) {
                c.iataCodeLocation = c.extraFields.iataCodeLocation;
                c.status = c.extraFields.status;
                return !toAdd.some(contact => contact.id === c.id)
            });

            this.availableContacts = available;

        });
    }

    handleContactSearch(event) {
        let details = event.detail;

        if (details.searchTerm !== undefined && details.searchTerm.length > 0) {
            getContactsForAssignment({ serviceId: this.serviceId, queryString: details.searchTerm })
                .then(results => {
                    let availableContacts = JSON.parse(JSON.stringify(results));
                    let toAdd = JSON.parse(JSON.stringify(this.contactsToAdd));

                    let available = availableContacts.filter(function (c) {
                        c.iataCodeLocation = c.extraFields.iataCodeLocation;
                        c.status = c.extraFields.status;
                        return !toAdd.some(contact => contact.id === c.id)
                    });

                    this.template.querySelector('[data-id="contactlookup"]').setSearchResults(available);
                    this.requiredClass = '';
                })
        } else {
            this.getContactsForAssignment();
        }
    }

    removeContactToAdd(event) {
        const row = event.detail.row;

        if (row.id !== undefined) {
            let contactsToAdd = JSON.parse(JSON.stringify(this.contactsToAdd));
            this.contactsToAdd = contactsToAdd.filter(item => item.id !== row.id);
        }
    }

    toCompanyContacts() {
        this[NavigationMixin.GenerateUrl]({
            type: "standard__namedPage",
            attributes: {
                pageName: "company-profile"
            }
        })
            .then(url => navigateToPage(url, { 'tab': 'contact' }));
    }

}