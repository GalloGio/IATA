import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import Id from '@salesforce/user/Id';

//import labels

import newServiceRequestlb from '@salesforce/label/c.ISSP_New_Service_Request';
import newServiceAccessConfirmMsglb from '@salesforce/label/c.csp_ServiceAccessConfirm';
import newServiceRequestConfirmMsglb from '@salesforce/label/c.csp_ServiceRequestConfirm';
import confirmedRequestMsglb from '@salesforce/label/c.CSP_Confirmed_Requested_Service_Message';
import goToServiceslb from '@salesforce/label/c.CSP_Services_GoToServices';
import csp_RequestService_ContactPortalAdmin_LegalAuth from '@salesforce/label/c.csp_RequestService_ContactPortalAdmin_LegalAuth';
import csp_RequestService_ContactPortalAdmin_Alt from '@salesforce/label/c.csp_RequestService_ContactPortalAdmin_Alt';
import csp_RequestService_ProceedIEPAccountOpen from '@salesforce/label/c.csp_RequestService_ProceedIEPAccountOpen';
import csp_RequestService_IEPAccountOpenInProgress from '@salesforce/label/c.csp_RequestService_IEPAccountOpenInProgress';
import ANG_ISSP_ConfirmRequestIEP_1 from '@salesforce/label/c.ANG_ISSP_ConfirmRequestIEP_1';
import csp_AgencyReadOnly from '@salesforce/label/c.csp_AgencyReadOnly';
import ANG_ISSP_ConfirmRequestIEP_2 from '@salesforce/label/c.ANG_ISSP_ConfirmRequestIEP_2';
import ANG_ISSP_PORTAL_SERVICE_ROLE from '@salesforce/label/c.ANG_ISSP_PORTAL_SERVICE_ROLE';
import ISSP_ANG_Portal_Role_AgencyReadOnly from '@salesforce/label/c.ISSP_ANG_Portal_Role_AgencyReadOnly';
import ISSP_ANG_Portal_Role_TicketIssuer from '@salesforce/label/c.ISSP_ANG_Portal_Role_TicketIssuer';
import ISSP_ANG_Portal_Role_MasterWalletManager from '@salesforce/label/c.ISSP_ANG_Portal_Role_MasterWalletManager';
import ISSP_ANG_Portal_Role_IEPAdmin from '@salesforce/label/c.ISSP_ANG_Portal_Role_IEPAdmin';
import csp_MasterWalletManager from '@salesforce/label/c.csp_MasterWalletManager';
import csp_TicketIssuer from '@salesforce/label/c.csp_TicketIssuer';
import csp_IEPAdmin from '@salesforce/label/c.csp_IEPAdmin';
import ANG_ISSP_PortalRoleErrorMessage from '@salesforce/label/c.ANG_ISSP_PortalRoleErrorMessage';
import ANG_ISSP_UserProvisioningWait from '@salesforce/label/c.ANG_ISSP_UserProvisioningWait';
import ANG_ISSP_Open_IATA_EasyPay_Account from '@salesforce/label/c.ANG_ISSP_Open_IATA_EasyPay_Account';
import ISSP_Thanks_for_request from '@salesforce/label/c.ISSP_Thanks_for_request';
import ICCS_Service_Access_Inactive from '@salesforce/label/c.ICCS_Service_Access_Inactive';
import ICCS_Homepage_Select_Role_Label from '@salesforce/label/c.ICCS_Homepage_Select_Role_Label';
import ICCS_Homepage_Request_Role_Message2 from '@salesforce/label/c.ICCS_Homepage_Request_Role_Message2';
import ICCS_Service_Access_Granted_Message from '@salesforce/label/c.ICCS_Service_Access_Granted_Message';
import ISSP_AcceptTermsAndConditions from '@salesforce/label/c.ISSP_AcceptTermsAndConditions';
import ISSP_KAVI_Terms_Conditions_Part1 from '@salesforce/label/c.ISSP_KAVI_Terms_Conditions_Part1';
import ISSP_KAVI_Terms_Conditions_Part2 from '@salesforce/label/c.ISSP_KAVI_Terms_Conditions_Part2';
import ISSP_KAVI_Terms_Conditions_Part3 from '@salesforce/label/c.ISSP_KAVI_Terms_Conditions_Part3';
import ISSP_Access_Granted from '@salesforce/label/c.ISSP_Access_Granted';
import csp_TDP_ServiceRequest_TopLabel from '@salesforce/label/c.csp_TDP_ServiceRequest_TopLabel';
import csp_TDP_ServiceRequest_MediumLabel1 from '@salesforce/label/c.csp_TDP_ServiceRequest_MediumLabel1';
import csp_TDP_ServiceRequest_MediumLabel2 from '@salesforce/label/c.csp_TDP_ServiceRequest_MediumLabel2';
import csp_TD_ServiceRequest_TopLabel from '@salesforce/label/c.csp_TD_ServiceRequest_TopLabel';

//import navigation methods
import { NavigationMixin } from 'lightning/navigation';
import { getParamsFromPage, navigateToPage } from 'c/navigationUtils';

//import static resources
import IATA_LOADING_IMAGE from '@salesforce/resourceUrl/IataLoadingImage';


// import getServiceDetails from '@salesforce/apex/PortalServicesCtrl.getServiceDetails';
import requestServiceAccess from '@salesforce/apex/PortalServicesCtrl.requestAccess';
import getPortalAdmins from '@salesforce/apex/PortalServicesCtrl.getPortalAdmins';
import getUserOptions from '@salesforce/apex/PortalServicesCtrl.getUserOptions';
import availableIEPPortalServiceRoles from '@salesforce/apex/PortalServicesCtrl.availableIEPPortalServiceRoles';
import availableICCSPortalServiceRoles from '@salesforce/apex/PortalServicesCtrl.availableICCSPortalServiceRoles';
import userProvisioningRequests from '@salesforce/apex/PortalServicesCtrl.userProvisioningRequests';
import serviceWrapperRedirect from '@salesforce/apex/PortalServicesCtrl.serviceWrapperRedirect';
import performCheckonPoll from '@salesforce/apex/PortalServicesCtrl.performCheckonPoll';
import ISSP_AvailableService_newAppsRequest2 from '@salesforce/apex/PortalServicesCtrl.newAppsRequest2';
import newAppsRequestICCS from '@salesforce/apex/PortalServicesCtrl.newAppsRequestICCS';


export default class PortalServicesManageServices extends NavigationMixin(LightningElement) {

    //exposed labels
    @track label = {
        newServiceRequestlb,
        newServiceAccessConfirmMsglb,
        newServiceRequestConfirmMsglb,
        confirmedRequestMsglb,
        goToServiceslb,
        csp_RequestService_ContactPortalAdmin_LegalAuth,
        csp_RequestService_ContactPortalAdmin_Alt,
        csp_RequestService_ProceedIEPAccountOpen,
        csp_RequestService_IEPAccountOpenInProgress,
        ANG_ISSP_ConfirmRequestIEP_1,
        csp_AgencyReadOnly,
        csp_TicketIssuer,
        csp_IEPAdmin,
        csp_MasterWalletManager,
        ANG_ISSP_ConfirmRequestIEP_2,
        ANG_ISSP_PORTAL_SERVICE_ROLE,
        ISSP_ANG_Portal_Role_AgencyReadOnly,
        ISSP_ANG_Portal_Role_TicketIssuer,
        ISSP_ANG_Portal_Role_MasterWalletManager,
        ISSP_ANG_Portal_Role_IEPAdmin,
        ANG_ISSP_PortalRoleErrorMessage,
        ANG_ISSP_UserProvisioningWait,
        ANG_ISSP_Open_IATA_EasyPay_Account,
        ISSP_Thanks_for_request,
        ICCS_Service_Access_Inactive,
        ICCS_Homepage_Select_Role_Label,
        ICCS_Homepage_Request_Role_Message2,
        ICCS_Service_Access_Granted_Message,
        ISSP_AcceptTermsAndConditions,
        ISSP_KAVI_Terms_Conditions_Part1,
        ISSP_KAVI_Terms_Conditions_Part2,
        ISSP_KAVI_Terms_Conditions_Part3,
        ISSP_Access_Granted,
        csp_TDP_ServiceRequest_TopLabel,
        csp_TDP_ServiceRequest_MediumLabel1,
        csp_TDP_ServiceRequest_MediumLabel2,
        csp_TD_ServiceRequest_TopLabel

    };

    //exposed static resources
    iataLoadingImage = IATA_LOADING_IMAGE;

    userID = Id;

    @api
    get service() {
        return this.trackedServiceId;
    }
    set service(val) {
        console.log('ppf', val)
        this.trackedServiceId = val;
    }

    //receives service record by parameter// used in manage services page
    @api
    get serviceRecord() {
        return this.trackedServiceRecord;
    }
    set serviceRecord(val) {
        val = JSON.parse(JSON.stringify(val));
        this.trackedServiceRecord = val;
        if (this.trackedServiceRecord) {
            this.trackedServiceId = this.trackedServiceRecord.recordService.Id;
            this.isAdmin = this.trackedServiceRecord.isAdmin;
            this.addUsersEnable = this.trackedServiceRecord.addUsersEnable;
            this.serviceFullName = this.trackedServiceRecord.recordService.Name;
            this.serviceName = this.trackedServiceRecord.recordService.ServiceName__c;
            this.submitMessage = this.label.confirmedRequestMsglb.replace('{0}', this.serviceName);
            this.popUpHandler();

        }

    }

    @api
    get displayConfirm() {
        return this.showConfirm;
    }
    set displayConfirm(val) {
        this.showConfirm = val;
    }

    get confirmMessage() {
        if (this.isAdmin) {
            return this.label.newServiceRequestConfirmMsglb + ' ' + this.serviceFullName;
        }
        return this.label.newServiceAccessConfirmMsglb + ' ' + this.serviceFullName;
    }


    @track trackedServiceId;
    @track trackedServiceRecord = {};


    @track showConfirm = false;
    @track showPopUp = false;
    @track showSpinner = false;
    @track defaultMessage = true;
    @track IEPMessage = false;
    @track IATARequestConfirm = false;
    @track IEPOptionalMessages;
    @track IEPIntroOptionalMessages;
    @track IEPRoleChangeConfirm = false;
    @track AgencyReadOnly = false;
    @track TicketIssuer = false;
    @track MasterWalletManager = false;
    @track IEPAdmin = false;
    @track showRoleSelection = false;
    @track IEPOpenAccount = false;
    @track IEPOpenAccountModal = false;
    @track IEPRoleSelectionModal = false;
    @track ICCSMessage = false;
    @track ICCSOptionalMessages;
    @track ICCSOpenAccount = false;
    @track ICCSRoleChangeConfirm = false;
    @track showICCSRoleSelection = false;
    @track ICCSRoleSelectionModal = false;
    @track ICCSOpenAccountModal = false;
    @track acceptSSWSConditions = false;
    @track SSWSSuccessModal = false;
    @track TDMessage = false;
    @track TDOptionalMessages;
    @track acceptTDConditions = false;
    @track SSWSMessage = false;
    @track showButtons = false;
    @track TDSuccessModal = false;
    @track ICCSSuccessMessage;
    @track SSWSSuccessMessage;
    @track roleICCSList = [];
    @track roleList;


    serviceDetailsResult;
    userContactId;
    NumberOfUseProvisioningRequests;
    timeout = null;
    permSetSSO;
    IATA_IEP_RadioButtons;

    @track isAdmin = false;
    @track serviceName = '';
    @track serviceFullName = '';
    @track addUsersEnable = false;
    @track portalAdminList = [];
    @track submitMessage = '';


    @wire(getPortalAdmins) portalAdminList;


    connectedCallback() {
        this.popUpHandler();
        //this.submitMessage= this.label.confirmedRequestMsglb.replace('{0}', this.serviceName);

    }

    popUpHandler() {
        if (this.serviceName !== undefined && this.serviceName !== '') {
            if (this.serviceName.includes('IATA EasyPay')) {
                this.defaultMessage = false;
                this.showRoleSelection = false;
                //stays true for any IATA EasyPay PopUp
                this.IEPMessage = true;
                this.IEPIntroOptionalMessages = this.label.newServiceRequestlb;
                getUserOptions({ portalUser: this.userID })
                    .then(result => {
                        let userOptions = JSON.parse(JSON.stringify(result));
                        if (userOptions.User_ContactId !== null && userOptions.User_ContactId !== '') {
                            this.userContactId = userOptions.User_ContactId;
                        }
                        if (userOptions.IEP_Status !== 'Open' && userOptions.User_Portal_Status === 'Approved User') {
                            this.IEPOptionalMessages = this.label.csp_RequestService_ContactPortalAdmin_LegalAuth;
                        }
                        else if (userOptions.IEP_Status === 'Open' && (userOptions.Legal_Auth_Signature === 'false' || userOptions.Legal_Auth_Signature === 'true')
                            && (userOptions.User_Portal_Status === 'Approved User' || userOptions.User_Portal_Status === 'Approved Admin')) {
                            this.IEPRoleChangeConfirm = true;
                            this.showRoleSelection = true;
                            this.IEPIntroOptionalMessages = this.label.ANG_ISSP_ConfirmRequestIEP_1;
                            this.IEPOptionalMessages = this.label.ANG_ISSP_ConfirmRequestIEP_2;
                            availableIEPPortalServiceRoles()
                                .then(data => {
                                    this.roleList = JSON.parse(JSON.stringify(data));
                                    if (this.serviceFullName === 'IATA EasyPay (EDENRED)') {
                                        this.roleList = this.roleList.filter(obj => obj.Connected_App__c === 'IATA EasyPay (EDENRED)');
                                        for (const item of this.roleList) {
                                            if (item.Connected_App__c === 'IATA EasyPay (EDENRED)') {
                                                let newlabel = 'ISSP_ANG_Portal_Role_' + item.Role__c.split(' ').join('');
                                                item.label = this.label[newlabel];
                                            }
                                        }
                                    }

                                });
                        }
                        else if (userOptions.IEP_Status === 'No IEP Account' && userOptions.User_Portal_Status === 'Approved Admin'
                            && userOptions.Legal_Auth_Signature === 'false') {
                            this.IEPOptionalMessages = this.label.csp_RequestService_ContactPortalAdmin_Alt;
                        }
                        else if (userOptions.IEP_Status === 'No IEP Account' && userOptions.User_Portal_Status === 'Approved Admin'
                            && userOptions.Legal_Auth_Signature === 'true') {
                            this.IEPOpenAccount = true;
                            this.IEPOptionalMessages = this.label.csp_RequestService_ProceedIEPAccountOpen;
                        }
                        else if (userOptions.IEP_Status === 'In Progress' && userOptions.User_Portal_Status === 'Approved Admin'
                            && userOptions.Legal_Auth_Signature === 'false') {
                            this.IEPOptionalMessages = this.label.csp_RequestService_ProceedIEPAccountOpen;
                        }
                    });
            }
            else if (this.serviceName.includes('ICCS')) {
                this.ICCSMessage = true;
                this.defaultMessage = false;
                this.showRoleSelection = false;
                this.showButtons = true;
                this.IEPIntroOptionalMessages = this.label.newServiceRequestlb;
                getUserOptions({ portalUser: this.userID })
                    .then(result => {
                        let userOptions = JSON.parse(JSON.stringify(result));
                        if (userOptions.User_ContactId !== null && userOptions.User_ContactId !== '') {
                            this.userContactId = userOptions.User_ContactId;
                        }
                        if (userOptions.User_ICCS_Membership_Status === 'Member') {
                            this.ICCSOptionalMessages = this.label.ICCS_Homepage_Select_Role_Label
                                + '<br/><br/><br/>'
                                + this.label.ICCS_Homepage_Request_Role_Message2;

                            this.showICCSRoleSelection = true;
                            this.ICCSRoleChangeConfirm = false;
                            let myICCSRolesOptions = [];
                            availableICCSPortalServiceRoles()
                                .then(data => {
                                    let roles = JSON.parse(JSON.stringify(data));
                                    if (this.serviceFullName === 'ICCS') {
                                        let allRoles = roles.filter(obj => obj.Connected_App__c === 'ICCS');
                                        allRoles.forEach(element => {
                                            myICCSRolesOptions.push({
                                                label: element.Role__c, value: element.Role__c
                                            });
                                        });
                                        this.roleICCSList = myICCSRolesOptions;
                                    }
                                });
                        } else {
                            this.ICCSOptionalMessages = this.label.ICCS_Service_Access_Inactive;
                            this.ICCSOpenAccount = true;
                        }
                    });
            }
            else if (this.serviceName.includes('Standards Setting Workspace')) {
                this.defaultMessage = false;
                //stays true for any IATA EasyPay PopUp
                this.SSWSMessage = true;
                this.showButtons = true;
                getUserOptions({ portalUser: this.userID })
                    .then(result => {
                        let userOptions = JSON.parse(JSON.stringify(result));
                        if (userOptions.User_ContactId !== null && userOptions.User_ContactId !== '') {
                            this.userContactId = userOptions.User_ContactId;
                        }
                    });
                this.IEPIntroOptionalMessages = this.label.newServiceRequestlb;
                this.SSWSOptionalMessages = this.label.ISSP_KAVI_Terms_Conditions_Part1
                    + '<br/>' + this.label.ISSP_KAVI_Terms_Conditions_Part2
                    + '<br/>' + this.label.ISSP_KAVI_Terms_Conditions_Part3;
            }
            else if (this.serviceName.includes('Treasury Dashboard')) {
                this.defaultMessage = false;
                //stays true for any IATA EasyPay PopUp
                this.TDMessage = true;
                this.showButtons = true;
                this.acceptTDConditions = true;
                getUserOptions({ portalUser: this.userID })
                    .then(result => {
                        let userOptions = JSON.parse(JSON.stringify(result));
                        if (userOptions.User_ContactId !== null && userOptions.User_ContactId !== '') {
                            this.userContactId = userOptions.User_ContactId;
                        }
                    });
                this.IEPIntroOptionalMessages = this.label.newServiceRequestlb;
                if (this.serviceName === 'Treasury Dashboard - Premium') {
                    this.TDOptionalMessages = '<b>' + this.label.csp_TDP_ServiceRequest_TopLabel + '</b>'
                        + '<br/><br/>' + this.serviceName
                        + '<br/><br/>' + this.label.csp_TDP_ServiceRequest_MediumLabel1
                        + '<br/>' + this.label.csp_TDP_ServiceRequest_MediumLabel2;
                } else {
                    this.TDOptionalMessages = '<b>' + this.label.csp_TD_ServiceRequest_TopLabel + '</b>'
                        + '<br/><br/>' + this.serviceName
                        + '<br/><br/>' + this.label.csp_TDP_ServiceRequest_MediumLabel1
                        + '<br/>' + this.label.csp_TDP_ServiceRequest_MediumLabel2;
                }
            }

            //get the parameters for this page  
            this.pageParams = getParamsFromPage();
            if (this.pageParams) {
                this.serviceId = this.pageParams.serviceId;
            }
        }
    }

    changeIEPRole() {
        if (this.radioOption === undefined || this.radioOption === '') {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: 'Error',
                    message: this.label.ANG_ISSP_PortalRoleErrorMessage,
                    variant: 'error',
                    mode: 'pester'
                })
            );
        }
        else {
            this.IEPMessage = false;
            this.IEPRoleSelectionModal = true;
            this.newAppRequest(this.trackedServiceId, this.serviceFullName, this.userContactId, this.radioOption, false, '');
        }
    }

    openIEPAccount() {
        this.IEPMessage = false;
        this.IEPOpenAccountModal = true;
        availableIEPPortalServiceRoles()
            .then(result => {
                let myResults = JSON.parse(JSON.stringify(result));
                this.defaultPortalUserRole = myResults.find(obj => obj.Default_User_Role__c === true).Role__c;
            });

        this.newAppRequest(this.trackedServiceId, this.serviceFullName, this.userContactId, '', true, this.defaultPortalUserRole);
    }

    ICCSRolePick(event) {
        this.ICCSRole = event.target.value;
        if (this.ICCSRole !== undefined && this.ICCSRole !== '') {
            this.ICCSRoleChangeConfirm = true;
        } else {
            this.ICCSRoleChangeConfirm = false;
        }
    }

    handleSSWSConditions(event) {
        this.acceptSSWSConditions = event.target.value;
    }

    openICCSAccount() {
        this.ICCSSuccessMessage = this.label.ICCS_Service_Access_Granted_Message;
        this.showSpinner = true;

        this.newAppsRequestICCS(this.trackedServiceId, this.serviceFullName, this.userContactId);
    }

    changeICCSRole() {
        this.ICCSSuccessMessage = this.label.ISSP_Thanks_for_request;
        this.showSpinner = true;

        this.newAppRequest(this.trackedServiceId, this.serviceFullName, this.userContactId, this.ICCSRole, false, '');
    }

    OpenSSWSAccount() {
        this.showSpinner = true;
        this.newAppsRequestSSWS(this.trackedServiceId, this.serviceFullName, this.userContactId);
    }

    OpenTDAccount() {
        this.showSpinner = true;
        this.newAppsRequestTD(this.trackedServiceId, this.serviceFullName, this.userContactId);
    }


    newAppRequest(AppId, AppName, ContactId, AppPortalRole, FlagUseDefaultRole, defaultPortalUserRole) {
        ISSP_AvailableService_newAppsRequest2({
            applicationId: AppId,
            applicationName: AppName,
            contactId: ContactId,
            portalServiceRole: AppPortalRole,
            flagUseDefaultRole: FlagUseDefaultRole,
            defaultPortalUserRole: defaultPortalUserRole
        })
            .then(result => {
                let results = JSON.parse(JSON.stringify(result));
                this.showSpinner = false;
                if (this.ICCSRole !== undefined && this.ICSSRole !== '') {
                    this.ICCSMessage = false;
                    this.ICCSRoleSelectionModal = true;
                }

                if (results === 'okauto') {
                    this.preparePolling();
                }
            });
    }

    newAppsRequestICCS(AppId, AppName, ContactId) {

        newAppsRequestICCS({
            applicationId: AppId,
            applicationName: AppName,
            contactId: ContactId
        })
            .then(result => {
                let results = JSON.parse(JSON.stringify(result));
                this.showSpinner = false;
                this.ICCSMessage = false;
                this.showButtons = false;

                if (results === 'okauto') {
                    this.ICCSRoleSelectionModal = true;
                }
            });
    }

    newAppsRequestSSWS(AppId, AppName, ContactId) {

        newAppsRequestICCS({
            applicationId: AppId,
            applicationName: AppName,
            contactId: ContactId
        })
            .then(result => {
                let results = JSON.parse(JSON.stringify(result));
                this.showSpinner = false;
                this.SSWSMessage = false;
                this.showButtons = false;

                if (results === 'okauto') {
                    this.SSWSSuccessModal = true;
                }
            });
    }

    newAppsRequestTD(AppId, AppName, ContactId) {

        newAppsRequestICCS({
            applicationId: AppId,
            applicationName: AppName,
            contactId: ContactId
        })
            .then(result => {
                let results = JSON.parse(JSON.stringify(result));
                this.showSpinner = false;
                this.TDMessage = false;
                this.showButtons = false;
                if (results === 'ok') {
                    this.TDSuccessModal = true;
                }
            });
    }

    preparePolling() {
        userProvisioningRequests()
            .then(NumberofUserProvisioningRequests => {
                this.NumberOfUseProvisioningRequests = NumberofUserProvisioningRequests;
                availableIEPPortalServiceRoles()
                    .then(result => {
                        let results = JSON.parse(JSON.stringify(result));
                        let myRolesObj = [];
                        let iepRoles = results.filter(obj => { return obj.Connected_App__c.startsWith('IATA EasyPay') && obj.Permission_set_SSO__c != null });
                        for (const role of iepRoles) {
                            myRolesObj.push({ label: role.Connected_App__c + ' - ' + role.Role__c, value: role.Permission_set_SSO__c });
                        }
                        if (this.radioOption !== undefined && this.radioOption !== '') {
                            this.permSetSSO = myRolesObj.find(obj => obj.label === this.serviceFullName + ' - ' + this.radioOption).value;
                        } else {
                            this.permSetSSO = myRolesObj.find(obj => obj.label === this.serviceFullName + ' - ' + this.defaultPortalUserRole).value;
                        }
                        this.onchangeSearchInput();

                    });
            })
    }

    onchangeSearchInput() {

        // Clear the timeout if it has already been set.
        // This will prevent the previous task from executing
        // if it has been less than <MILLISECONDS>
        clearTimeout(this.timeout);

        // Make a new timeout set to go off in 5000ms
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.timeout = setTimeout(() => {

            performCheckonPoll({ permSetSSO: this.permSetSSO, failedCount: this.NumberOfUseProvisioningRequests })
                .then(data => {
                    // you can access your data here
                    let results = JSON.parse(JSON.stringify(data));
                    if (results === 'Success') {

                        if ((this.radioOption === undefined || this.radioOption === '')
                            && (this.ICCSRole === undefined && this.ICSSRole === '')) {
                            serviceWrapperRedirect({ serviceId: this.trackedServiceId })
                                .then(result => {
                                    window.open(JSON.parse(JSON.stringify(result)));
                                    location.reload();
                                });
                        }

                    } else if (results === 'Incomplete') {
                        this.onchangeSearchInput();
                    } else {
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error',
                                message: 'Timeout on service request. Please try again later.',
                                variant: 'error',
                                mode: 'pester'
                            })
                        );
                    }
                })
                .catch(error => {
                    //throws error
                    this.error = error;
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: JSON.parse(JSON.stringify(error)).body.message,
                            variant: 'error',
                            mode: 'pester'
                        })
                    );
                });

        }, 5000, this);

    }

    reloadPage() {
        location.reload();
    }

    checkStuff() {
        console.log('test');
    }

    handlRadioOptions(event) {
        const radioOption = event.target.attributes.getNamedItem('data-id');
        event.target.value = !event.target.value;
        this.selectedRole(radioOption);
    }

    selectedRole(radioOption) {
        this.radioOption = radioOption.value;
    }

    handleTicketIssuer() {
        this.resetRadioButtons();
        this.TicketIssuer = true;
    }
    handleMasterWalletManager() {
        this.resetRadioButtons();
        this.MasterWalletManager = true;
    }
    handleIEPAdmin() {
        this.resetRadioButtons();
        this.IEPAdmin = true;
    }

    resetRadioButtons() {
        this.AgencyReadOnly = false;
        this.TicketIssuer = false;
        this.MasterWalletManager = false;
        this.IEPAdmin = false;
    }

    loadServiceInfo() {

        /*getServiceDetails({ serviceId: '$trackedServiceId'}){
            this.serviceDetailsResult = result;
            if (result.data) {
                this.serviceRecord = result.data;
                console.log(this.serviceRecord);
                this.isAdmin = this.serviceRecord.isAdmin;
                this.addUsersEnable = this.serviceRecord.addUsersEnable;
                this.serviceName = this.serviceRecord.recordService.ServiceName__c;
            }
        }*/
    }



 


    handleSubmitRequest() {
        this.showConfirm = false; //hides confirm box

        //displays popup with active spinner
        this.showPopUp = true;
        this.showSpinner = true;

        requestServiceAccess({ applicationId: this.trackedServiceId })
            .then(() => {
                //Show toas with confirmation            
                //this.showSpinner = false;
                if (this.isAdmin) {
                    this.showPopUp = false; // for admins no success box
                } else {
                    this.showSpinner = false;
                }

                this.dispatchEvent(new CustomEvent('requestcompleted', { detail: { success: true } }));// sends to parent the nr of records

            }).catch(error => {
                console.error(error);
            });

    }

    navigateToServicesPage() {
        navigateToPage("services");
    }
    abortRequest() {
        this.showConfirm = false;
        this.dispatchEvent(new CustomEvent('requestcompleted', { detail: { success: false } }));// sends to parent the nr of records

    }

}