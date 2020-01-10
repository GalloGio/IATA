import { LightningElement, track, wire, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import Id from '@salesforce/user/Id';

//import labels

import newServiceRequestlb from '@salesforce/label/c.ISSP_New_Service_Request';
import newServiceAccessConfirmMsglb from '@salesforce/label/c.csp_ServiceAccessConfirm';
import newServiceRequestConfirmMsglb from '@salesforce/label/c.csp_ServiceRequestConfirm';
import confirmedRequestMsglb from '@salesforce/label/c.CSP_Confirmed_Requested_Service_Message';
import goToServiceslb from '@salesforce/label/c.CSP_Services_GoToServices';
import ANG_ISSP_ConfirmRequestIEP_1 from '@salesforce/label/c.ANG_ISSP_ConfirmRequestIEP_1';
import ANG_ISSP_ConfirmRequestIEP_2 from '@salesforce/label/c.ANG_ISSP_ConfirmRequestIEP_2';
import ANG_ISSP_PORTAL_SERVICE_ROLE from '@salesforce/label/c.ANG_ISSP_PORTAL_SERVICE_ROLE';
import ISSP_ANG_Portal_Role_AgencyReadOnly from '@salesforce/label/c.ISSP_ANG_Portal_Role_AgencyReadOnly';
import ISSP_ANG_Portal_Role_TicketIssuer from '@salesforce/label/c.ISSP_ANG_Portal_Role_TicketIssuer';
import ISSP_ANG_Portal_Role_MasterWalletManager from '@salesforce/label/c.ISSP_ANG_Portal_Role_MasterWalletManager';
import ISSP_ANG_Portal_Role_IEPAdmin from '@salesforce/label/c.ISSP_ANG_Portal_Role_IEPAdmin';
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
import csp_RequestService_ContactPortalAdmin_LegalAuth from '@salesforce/label/c.csp_RequestService_ContactPortalAdmin_LegalAuth';
import csp_RequestService_ProceedIEPAccountOpen from '@salesforce/label/c.csp_RequestService_ProceedIEPAccountOpen';
import csp_MasterWalletManager from '@salesforce/label/c.csp_MasterWalletManager';
import ISSP_ANG_Portal_Role_SubWalletManager from '@salesforce/label/c.ISSP_ANG_Portal_Role_SubWalletManager';
import csp_TicketIssuer from '@salesforce/label/c.csp_TicketIssuer';
import csp_IEPAdmin from '@salesforce/label/c.csp_IEPAdmin';
import csp_RequestService_ContactPortalAdmin_Alt from '@salesforce/label/c.csp_RequestService_ContactPortalAdmin_Alt';
import csp_RequestService_IEPAccountOpenInProgress from '@salesforce/label/c.csp_RequestService_IEPAccountOpenInProgress';
import csp_NoPortalServiceNameFound from '@salesforce/label/c.csp_NoPortalServiceNameFound';
import csp_AgencyReadOnly from '@salesforce/label/c.csp_AgencyReadOnly';
import ISSP_Registration_MyInformation from '@salesforce/label/c.ISSP_Registration_MyInformation';
import ISSP_Company_Administration from '@salesforce/label/c.ISSP_Company_Administration';
import csp_RequestService_ContactSupport from '@salesforce/label/c.csp_RequestService_ContactSupport';
import Button_Cancel from '@salesforce/label/c.Button_Cancel';
import IDCard_Confirm_Replacement from '@salesforce/label/c.IDCard_Confirm_Replacement';
import csp_TimeoutIEP from '@salesforce/label/c.csp_TimeoutIEP';
import ISSP_Access_Requested from '@salesforce/label/c.ISSP_Access_Requested';
import CSP_Breadcrumb_CompanyProfile_Title from '@salesforce/label/c.CSP_Breadcrumb_CompanyProfile_Title';
import ISSP_Page from '@salesforce/label/c.ISSP_Page';


//import navigation methods
import { NavigationMixin } from 'lightning/navigation';
import { getParamsFromPage, navigateToPage } from 'c/navigationUtils';

//import static resources
import IATA_LOADING_IMAGE from '@salesforce/resourceUrl/IataLoadingImage';


// import getServiceDetails from '@salesforce/apex/PortalServicesCtrl.getServiceDetails';
import requestServiceAccess from '@salesforce/apex/PortalServicesCtrl.requestAccess';
import getUserOptions from '@salesforce/apex/PortalServicesCtrl.getUserOptions';
import availableIEPPortalServiceRoles from '@salesforce/apex/PortalServicesCtrl.availableIEPPortalServiceRoles';
import availableICCSPortalServiceRoles from '@salesforce/apex/PortalServicesCtrl.availableICCSPortalServiceRoles';
import userProvisioningRequests from '@salesforce/apex/PortalServicesCtrl.userProvisioningRequests';
import serviceWrapperRedirect from '@salesforce/apex/PortalServicesCtrl.serviceWrapperRedirect';
import performCheckonPoll from '@salesforce/apex/DAL_WithoutSharing.performCheckonPoll';
import ISSP_AvailableService_newAppsRequest2 from '@salesforce/apex/PortalServicesCtrl.newAppsRequest2';
import newAppsRequestICCS from '@salesforce/apex/PortalServicesCtrl.newAppsRequestICCS';

import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';

export default class PortalServicesManageServices extends NavigationMixin(LightningElement) {

    //icons
    exclamationIcon = CSP_PortalPath + 'CSPortal/Images/Icons/exclamation_point.svg';

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
        csp_TD_ServiceRequest_TopLabel,
        csp_NoPortalServiceNameFound,
        ISSP_Registration_MyInformation,
        ISSP_Company_Administration,
        csp_RequestService_ContactSupport,
        Button_Cancel,
        IDCard_Confirm_Replacement,
        csp_TimeoutIEP,
        ISSP_ANG_Portal_Role_SubWalletManager,
        ISSP_Access_Requested,
        CSP_Breadcrumb_CompanyProfile_Title,
        ISSP_Page
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
            return this.label.newServiceAccessConfirmMsglb.replace('{0}', this.serviceFullName);
        }
        return this.label.newServiceRequestConfirmMsglb.replace('{0}', this.serviceFullName);
    }

    @track trackedServiceId;
    @track trackedServiceRecord = {};


    @track showConfirm = false;
    @track showPopUp = false;
    @track showSpinner = false;
    @track defaultMessage = true;
    @track AgencyReadOnly = false;
    @track TicketIssuer = false;
    @track MasterWalletManager = false;
    @track IEPAdmin = false;
    @track showRoleSelection = false;
    @track IEPOpenAccountModal = false;
    @track IEPRoleSuccessModal = false;
    @track ICCSMessage = false;
    @track showICCSRoleSelection = false;
    @track ICCSsuccessModal = false;
    @track ICCSOpenAccountModal = false;
    @track SSWSSuccessModal = false;
    @track TDMessage = false;
    @track SSWSMessage = false;
    @track showButtons = false;
    @track TDSuccessModal = false;
    @track ShowIEPIntroMessage = false;
    @track IEPIntroOptionalMessages;
    @track IEPOptionalMessages;
    @track ICCSOptionalMessages;
    @track TDOptionalMessages;
    @track ICCSSuccessMessage;
    @track SSWSSuccessMessage;
    @track defaultPortalUserRole = [];
    @track roleICCSList = [];
    @track radioOption = '';
    @track roleList;

    //tracks ICCSRole
    @track ICCSRole;

    //tracks visibility of intro modal

    //tracks visibility of 

    //tracks visibility of buttons
    @track IEPRoleChangeButton = false;
    @track IEPOpenAccountButton = false;
    @track DefaultRequestButton = true;
    @track ICCSOpenAccount = false;
    @track ICCSRoleChangeConfirm = false;
    @track acceptSSWSConditions = false;
    @track acceptTDConditions = false;

    //tracks visibility of modals
    @track ShowIEPModal = false;
    @track ShowICCSModal = false;
    @track ShowSSWSModal = false;
    @track ShowTDModal = false;

    //tracks loading message IEP
    @track loadingMessage = '';

    serviceDetailsResult;
    userContactId;
    NumberOfUseProvisioningRequests;
    timeout = null;
    permSetSSO;
    IATA_IEP_RadioButtons;
    timeoutLimit = 18;
    timeoutCounter = 0;
    companyInformationLabel;
    companyInformationPageLabel;

    @track isAdmin = false;
    @track serviceName = '';
    @track serviceFullName = '';
    @track addUsersEnable = false;
    @track submitMessage = '';

    connectedCallback() {
        this.popUpHandler();

        this.companyInformationLabel = this.label.CSP_Breadcrumb_CompanyProfile_Title.toLowerCase();
        this.companyInformationPageLabel = this.label.ISSP_Page.toLowerCase();
    }

    popUpHandler() {
        if (this.serviceName) {
            this.ShowIEPModal = false;
            this.ShowICCSModal = false;
            this.ShowSSWSModal = false;
            this.TDSuccessModal = false;
            this.ShowTDModal = false;
            this.showButtons = true;
            this.ShowIEPIntroMessage = false;
            this.DefaultRequestButton = true;
            if (this.serviceName.includes('IATA EasyPay')) {
                this.ShowIEPModal = true;
                this.defaultMessage = false;
                this.showRoleSelection = false;
                this.ShowIEPIntroMessage = true;
                this.DefaultRequestButton = false;
                this.IEPIntroOptionalMessages = this.label.newServiceRequestlb;
                getUserOptions({ portalUser: this.userID })
                    .then(result => {
                        let userOptions = JSON.parse(JSON.stringify(result));
                        if (userOptions.User_ContactId !== null && userOptions.User_ContactId !== '') {
                            this.userContactId = userOptions.User_ContactId;
                        }
                        if (userOptions.IEP_Status !== 'Open' && userOptions.User_Portal_Status === 'Approved User') {
                            let string3 = this.label.csp_RequestService_ContactSupport;
                            let link0 = window.location.toString().replace('/services', '');
                            let link3 = link0 + '/support-reach-us';
                            this.IEPOptionalMessages = this.label.csp_RequestService_ContactPortalAdmin_LegalAuth.replace('{0}', string3.link(link3));
                        }
                        else if (userOptions.IEP_Status === 'Open' && (userOptions.Legal_Auth_Signature === 'false' || userOptions.Legal_Auth_Signature === 'true')
                            && (userOptions.User_Portal_Status === 'Approved User' || userOptions.User_Portal_Status === 'Approved Admin')) {
                            this.IEPRoleChangeButton = true;
                            this.showRoleSelection = true;
                            this.IEPIntroOptionalMessages = this.label.ANG_ISSP_ConfirmRequestIEP_1;
                            this.IEPOptionalMessages = this.label.ANG_ISSP_ConfirmRequestIEP_2;

                            availableIEPPortalServiceRoles({ serviceId: this.trackedServiceId })
                                .then(data => {
                                    this.roleList = JSON.parse(JSON.stringify(data));
                                    this.roleList = this.roleList.filter(obj => obj.Connected_App__c === this.serviceFullName);
                                    this.roleList = this.roleList.sort((a, b) => (a.Order__c > b.Order__c) ? 1 : -1);
                                    for (const item of this.roleList) {
                                        let newlabel = 'ISSP_ANG_Portal_Role_' + item.Role__c.split(' ').join('');
                                        item.label = this.label[newlabel];
                                    }


                                });
                        }
                        else if (userOptions.IEP_Status === 'No IEP Account' && userOptions.User_Portal_Status === 'Approved Admin'
                            && userOptions.Legal_Auth_Signature === 'false') {
                            let string1 = this.label.ISSP_Registration_MyInformation;
                            let link0 = window.location.toString().replace('/services', '');
                            let link1 = link0 + '/my-profile';
                            let string2 = this.label.ISSP_Company_Administration;
                            let link2 = link0 + '/company-profile';
                            let string3 = this.label.csp_RequestService_ContactSupport;
                            let link3 = link0 + '/support-reach-us';
                            this.IEPOptionalMessages = this.label.csp_RequestService_ContactPortalAdmin_Alt.replace('{0}', string1.link(link1)).replace('{1}', string2.link(link2)).replace('{2}', string3.link(link3));

                        }
                        else if (userOptions.IEP_Status === 'No IEP Account' && userOptions.User_Portal_Status === 'Approved Admin'
                            && userOptions.Legal_Auth_Signature === 'true') {
                            this.IEPOpenAccountButton = true;
                            this.IEPOptionalMessages = this.label.csp_RequestService_ProceedIEPAccountOpen;
                        }
                        else if (userOptions.IEP_Status === 'In Progress' && userOptions.User_Portal_Status === 'Approved Admin'
                            && userOptions.Legal_Auth_Signature === 'false') {
                            this.IEPOptionalMessages = this.label.csp_RequestService_IEPAccountOpenInProgress;
                        }
                        else if (userOptions.IEP_Status !== 'In Progress' && userOptions.IEP_Status !== 'No IEP Account'
                            && userOptions.IEP_Status !== 'Open' && userOptions.User_Portal_Status === 'Approved Admin') {
                            let string3 = this.label.csp_RequestService_ContactSupport;
                            let link0 = window.location.toString().replace('/services', '');
                            let link3 = link0 + '/support-reach-us';
                            this.IEPOptionalMessages = this.label.csp_RequestService_ContactPortalAdmin_LegalAuth.replace('{0}', string3.link(link3));

                        }
                    });
            }
            else if (this.serviceName.includes('ICCS')) {
                this.ICCSMessage = true;
                this.ShowICCSModal = true;
                this.DefaultRequestButton = false;
                this.defaultMessage = false;
                this.showRoleSelection = false;
                this.IEPIntroOptionalMessages = this.label.newServiceRequestlb;
                getUserOptions({ portalUser: this.userID })
                    .then(result => {
                        let userOptions = JSON.parse(JSON.stringify(result));
                        if (userOptions.User_ContactId !== null && userOptions.User_ContactId !== '') {
                            this.userContactId = userOptions.User_ContactId;
                        }
                        if (userOptions.User_ICCS_Membership_Status === 'Member') {
                            this.ICCSOptionalMessages = this.label.ICCS_Homepage_Select_Role_Label
                                + ':<br/><br/>'
                                + this.label.ICCS_Homepage_Request_Role_Message2;

                            this.showICCSRoleSelection = true;
                            this.ICCSRoleChangeConfirm = false;
                            let myICCSRolesOptions = [];
                            myICCSRolesOptions.push({ label: this.label.ICCS_Homepage_Select_Role_Label, value: '' });
                            availableICCSPortalServiceRoles()
                                .then(data => {
                                    let roles = JSON.parse(JSON.stringify(data));
                                    if (this.serviceFullName === 'ICCS') {
                                        let allRoles = roles.filter(obj => obj.Connected_App__c === 'ICCS' && (obj.Role__c === 'Read-only' || obj.Role__c === 'Level 1'));
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
                this.ShowSSWSModal = true;
                this.DefaultRequestButton = false;

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
                this.ShowTDModal = true;
                this.TDMessage = true;
                this.DefaultRequestButton = false;
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
            this.ShowIEPIntroMessage = false;
            this.showButtons = false;
            this.IEPRoleSuccessModal = true;
            this.showRoleSelection = false;
            this.newAppRequest(this.trackedServiceId, this.serviceFullName, this.userContactId, this.radioOption, false);
        }
    }

    openIEPAccount() {
        this.IEPOpenAccountModal = true;
        this.ShowIEPIntroMessage = false;
        this.showButtons = false;
        this.loadingMessage = this.label.ANG_ISSP_UserProvisioningWait;
        this.newAppRequest(this.trackedServiceId, this.serviceFullName, this.userContactId, '', true);

    }

    ICCSRolePick(event) {
        this.ICCSRole = event.target.value;
        if (this.ICCSRole) {
            this.ICCSRoleChangeConfirm = true;
        } else {
            this.ICCSRoleChangeConfirm = false;
        }
    }

    openICCSAccount() {
        this.ICCSSuccessMessage = this.label.ICCS_Service_Access_Granted_Message;
        this.showSpinner = true;

        this.newAppsRequestICCS(this.trackedServiceId, this.serviceFullName, this.userContactId);
    }

    handleSSWSConditions(event) {
        this.acceptSSWSConditions = event.target.value;
    }

    changeICCSRole() {
        this.ICCSSuccessMessage = this.label.ISSP_Thanks_for_request;
        this.showSpinner = true;

        this.newAppRequest(this.trackedServiceId, this.serviceFullName, this.userContactId, this.ICCSRole, false);
    }

    OpenSSWSAccount() {
        this.showSpinner = true;
        this.newAppsRequestSSWS(this.trackedServiceId, this.serviceFullName, this.userContactId);
    }

    OpenTDAccount() {
        this.showSpinner = true;
        this.newAppsRequestTD(this.trackedServiceId, this.serviceFullName, this.userContactId);
    }


    newAppRequest(AppId, AppName, ContactId, AppPortalRole, FlagUseDefaultRole) {
        ISSP_AvailableService_newAppsRequest2({
            applicationId: AppId,
            applicationName: AppName,
            contactId: ContactId,
            portalServiceRole: AppPortalRole,
            flagUseDefaultRole: FlagUseDefaultRole
        })
            .then(result => {
                let results = JSON.parse(JSON.stringify(result));
                this.showSpinner = false;
                if (this.ICCSRole) {
                    this.ICCSMessage = false;
                    this.ICCSsuccessModal = true;
                    this.showButtons = false;
                }

                if (results === 'okauto' || results === 'ok') {
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

                if (results === 'okauto' || results === 'ok') {
                    this.ICCSsuccessModal = true;
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

                if (results === 'okauto' || results === 'ok') {
                    this.SSWSSuccessModal = true;
                    this.clearURL();
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
                if (results === 'okauto' || results === 'ok') {
                    this.TDSuccessModal = true;
                }
            });
    }

    preparePolling() {
        userProvisioningRequests({})
            .then(numberofUserProvisioningRequests => {
                this.numberofUserProvisioningRequests = JSON.parse(JSON.stringify(numberofUserProvisioningRequests));

                availableIEPPortalServiceRoles({ serviceId: this.trackedServiceId })
                    .then(result => {
                        let results = JSON.parse(JSON.stringify(result));
                        let myRolesObj = [];
                        if (!this.ICCSRole) {
                            let iepRoles = results.filter(obj => { return obj.Connected_App__c.startsWith('IATA EasyPay') && obj.Permission_set_SSO__c != null });
                            for (const role of iepRoles) {
                                myRolesObj.push({ label: role.Connected_App__c + ' - ' + role.Role__c, value: role.Permission_set_SSO__c });
                            }
                            if (this.radioOption) {
                                this.permSetSSO = myRolesObj.find(obj => obj.label === this.serviceFullName + ' - ' + this.radioOption).value;
                            } else {
                                this.permSetSSO = myRolesObj.find(obj => obj.label === this.serviceFullName + ' - ' + this.defaultPortalUserRole).value;
                            }
                        }
                        this.timeoutCounter = 0;
                        this.pollServer();
                    });

            });
    }

    pollServer() {

        // Clear the timeout if it has already been set.
        // This will prevent the previous task from executing
        // if it has been less than <MILLISECONDS>
        clearTimeout(this.timeout);

        // Make a new timeout set to go off in 5000ms
        // eslint-disable-next-line @lwc/lwc/no-async-operation
        this.timeout = setTimeout(() => {
            //this.testfunction();
            performCheckonPoll({ permSetSSO: this.permSetSSO, failedCount: this.numberofUserProvisioningRequests })
                .then(data => {
                    // you can access your data here
                    let results = JSON.parse(JSON.stringify(data));
                    if (results === 'Success') {
                        if (!this.radioOption && !this.ICSSRole) {
                            serviceWrapperRedirect({ serviceId: this.trackedServiceId })
                                .then(result => {
                                    window.open(JSON.parse(JSON.stringify(result)));
                                    location.reload();
                                });
                        }

                    }
                    if (results === 'Incomplete') {
                        this.timeoutCounter = this.timeoutCounter + 1;
                        if (this.timeoutCounter === 22) {
                            this.loadingMessage = this.label.csp_TimeoutIEP;
                        }
                        if (this.timeoutCounter >= 24) {
                            location.reload();
                        }
                        this.pollServer();
                    }
                    if (results === 'Error') {
                        this.IEPOpenAccountModal = false;
                        this.showConfirm = false;
                        this.dispatchEvent(
                            new ShowToastEvent({
                                title: 'Error',
                                message: 'Error on service request. Please try again later.',
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
        let serviceNameaux = this.serviceName;
        this.submitMessage = this.label.confirmedRequestMsglb.replace('{0}', serviceNameaux);

        requestServiceAccess({ applicationId: this.trackedServiceId })
            .then(() => {
                //Show toas with confirmation            
                //this.showSpinner = false;
                if (this.isAdmin) {
                    this.showPopUp = false; // for admins no success box
                    this.dispatchEvent(new CustomEvent('requestcompleted', { detail: { success: true } }));// sends to parent the nr of records
                } else {
                    this.showSpinner = false;
                }
            }).catch(error => {
                console.error(error);
            });

    }

    navigateToServicesPage() {
        navigateToPage("services");
    }
    
    navigateToCompanyProfile() {
        let params = {};
        params.section = 'adminContacts';
        navigateToPage("company-profile", params);
    }

    abortRequest() {
        this.showConfirm = false;
        this.dispatchEvent(new CustomEvent('requestcompleted', { detail: { success: false } }));// sends to parent the nr of records

    }

    clearURL() {
        let windowURL = window.location.href;
        windowURL = windowURL.split('?');
        
        if (windowURL[1].split('&').length > 1) {
            let param = windowURL[1].split('&');
            windowURL = windowURL[0] + '?' + param[0];
            window.history.pushState(null, null, windowURL);
        }
    }
}