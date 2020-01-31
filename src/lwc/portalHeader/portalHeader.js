import { LightningElement, track, wire, api } from 'lwc';

// language
import userId from '@salesforce/user/Id';
import changeUserLanguage from '@salesforce/apex/CSP_Utils.changeUserLanguage';
import getCommunityAvailableLanguages from '@salesforce/apex/CSP_Utils.getCommunityAvailableLanguages';

//navigation
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import { navigateToPage, getPageName, getParamsFromPage } from 'c/navigationUtils';
import getBreadcrumbs from '@salesforce/apex/PortalBreadcrumbCtrl.getBreadcrumbs';

//notification apex method
import getNotifications from '@salesforce/apex/PortalHeaderCtrl.getNotifications';
import isAdmin from '@salesforce/apex/CSP_Utils.isAdmin';
import showIATAInvoices from '@salesforce/apex/PortalHeaderCtrl.showIATAInvoices'; //WMO-696 - ACAMBAS
import increaseNotificationView from '@salesforce/apex/PortalHeaderCtrl.increaseNotificationView';
import goToManageService from '@salesforce/apex/PortalHeaderCtrl.goToManageService';
import goToOldChangePassword from '@salesforce/apex/PortalHeaderCtrl.goToOldChangePassword';
import redirectChangePassword from '@salesforce/apex/PortalHeaderCtrl.redirectChangePassword';
import getContactInfo from '@salesforce/apex/PortalRegistrationSecondLevelCtrl.getContactInfo';
import getLoggedUser from '@salesforce/apex/CSP_Utils.getLoggedUser';
import isGuestUser from '@salesforce/apex/CSP_Utils.isGuestUser';

import redirectfromPortalHeader from '@salesforce/apex/CSP_Utils.redirectfromPortalHeader';

// Toast
import { ShowToastEvent } from 'lightning/platformShowToastEvent'

//custom labels
import ISSP_Services from '@salesforce/label/c.ISSP_Services';
import CSP_Support from '@salesforce/label/c.CSP_Support';
import CSP_Breadcrumb_AdvancedSearch_Title from '@salesforce/label/c.CSP_Breadcrumb_AdvancedSearch_Title';
import ICCS_Profile from '@salesforce/label/c.ICCS_Profile';
import ISSP_MyProfile from '@salesforce/label/c.ISSP_MyProfile';
import CSP_CompanyProfile from '@salesforce/label/c.CSP_CompanyProfile';
import CSP_Cases from '@salesforce/label/c.CSP_Cases';
import CSP_Settings from '@salesforce/label/c.CSP_Settings';
import CSP_LogOut from '@salesforce/label/c.CSP_LogOut';
import PortalName from '@salesforce/label/c.PortalNameRedirect';
import MarkAsRead from '@salesforce/label/c.MarkAsRead_Notification';
import NotificationCenter from '@salesforce/label/c.NotificationCenter_Title';
import ViewDetails from '@salesforce/label/c.ViewDetails_Notification';
import NotificationDetail from '@salesforce/label/c.NotificationDetail_Detail';
import ISSP_Reset_Password from '@salesforce/label/c.ISSP_Reset_Password';
import CSP_IATA_Invoices from '@salesforce/label/c.CSP_IATA_Invoices'; //WMO-627 - ACAMBAS

import Announcement from '@salesforce/label/c.Announcements_Notification';
import Tasks from '@salesforce/label/c.Tasks_Notification';
import AllNotifications from '@salesforce/label/c.All_Notifications_Notification';
import CSP_You_Dont_Have_Notifications from '@salesforce/label/c.CSP_You_Dont_Have_Notifications';
import CSP_You_Dont_Have_Announcements from '@salesforce/label/c.CSP_You_Dont_Have_Announcements';
import CSP_You_Dont_Have_Tasks from '@salesforce/label/c.CSP_You_Dont_Have_Tasks';


// Accept Terms
import { updateRecord } from 'lightning/uiRecordApi';
import { getRecord } from 'lightning/uiRecordApi';
import Id from '@salesforce/user/Id';
import User_ToU_accept from '@salesforce/schema/User.ToU_accepted__c';
import AccountSector from '@salesforce/schema/User.Contact.Account.Sector__c';
import Portal_Registration_Required from '@salesforce/schema/User.Portal_Registration_Required__c';

import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';


export default class PortalHeader extends NavigationMixin(LightningElement) {

    @api showServices = false;
    @api showCases = false;
    @api showFAQs = false;
    @api showDocuments = false;
    @api showAdvancedSearch = false;
    @api language;
    @api searchBarPlaceholder;

    @track filteringObject;
    // language
    @track selectedLang = 'en_US';
    @track langOptions = [];
    @track chagingLang = false;
    @track loadingLangs = true;
    @track userId = userId;
    @track internalUser = false;

    @wire(getRecord, { recordId: "$userId", fields: ['User.LanguageLocaleKey'] })
    getUserLang(result) {
        if (result.data) {
            let data = JSON.parse(JSON.stringify(result.data));
            if (data.fields) {
                this.selectedLang = data.fields.LanguageLocaleKey.value;
            }
        }
    }

    handleChangeLang(event) {
        this.chagingLang = true;
        let lang = event.detail.value;
        changeUserLanguage({lang}).then(() => {
            window.location.reload(); // Review this
        }).catch(error => {
            console.error('Error changeUserLanguage', error);
            this.chagingLang = false;
        });
    }

    getLanguagesOptions() {
        this.loadingLangs = true;
        getCommunityAvailableLanguages().then(result => {
            if (result) {
                this.langOptions = result;
            }
            this.loadingLangs = false;
        }).catch(error => {
            console.error('Error getCommunityAvailableLanguages', error);
            this.loadingLangs = false;
        });
    }

    // terms
    @track displayAcceptTerms = true;
    @track displayRegistrationConfirmation = false;
    @track displayFirstLogin = false;
    @track firstLogin = false;

    // l2 registration
    level2RegistrationTrigger = 'homepage';
    isTriggeredByRequest = false;
    
    @wire(getRecord, { recordId: Id, fields: [User_ToU_accept, Portal_Registration_Required] })
    WiregetUserRecord(result) {
        if (result.data) {
            let user = JSON.parse(JSON.stringify(result.data));
            let acceptTerms = user.fields.ToU_accepted__c.value;
            let registrationRequired = user.fields.Portal_Registration_Required__c.value;
            let currentURL = window.location.href;
            if (currentURL.includes(this.labels.PortalName)) {
                this.displayAcceptTerms = acceptTerms;
            }

            console.log('displayAcceptTerms: ', this.displayAcceptTerms);
            console.log('firstLogin: ', this.firstLogin);
            console.log('registrationRequired: ', registrationRequired);

            if(acceptTerms == true){
                if(registrationRequired == true){
                    this.displayRegistrationConfirmation = true;
                }else{
                    if(this.firstLogin == true){
                        this.displayFirstLogin = true;
                    }
                }
            }

        }
    }

    // company tab on profile
    @track displayCompanyTab = false;

    @wire(getRecord, { recordId: Id, fields: [AccountSector] })
    WiregetAccountSector(result) {
        if (result.data) {
            let user = JSON.parse(JSON.stringify(result.data));
            let accountSector = user.fields.Contact.value.fields.Account.value.fields.Sector__c.value;

            if (accountSector === 'General Public') {
                this.displayCompanyTab = false;
            } else {
                this.displayCompanyTab = true;
            }
        }
    }

    // labels
    _labels = {
        ISSP_Services,
        CSP_Support,
        CSP_Breadcrumb_AdvancedSearch_Title,
        ICCS_Profile,
        ISSP_MyProfile,
        CSP_CompanyProfile,
        CSP_Cases,
        CSP_Settings,
        CSP_LogOut,
        PortalName,
        MarkAsRead,
        NotificationCenter,
        ViewDetails,
        NotificationDetail,
        Announcement,
        Tasks,
        AllNotifications,
        ISSP_Reset_Password,
        CSP_You_Dont_Have_Notifications,
        CSP_You_Dont_Have_Announcements,
        CSP_You_Dont_Have_Tasks,
        CSP_IATA_Invoices //WMO-627 - ACAMBAS
    };

    get labels() {
        return this._labels;
    }
    set labels(value) {
        this._labels = value;
    }

    //links for images
    logoIcon = CSP_PortalPath + 'CSPortal/Images/Logo/group.svg';
    logoWhiteIcon = CSP_PortalPath + 'CSPortal/Images/Logo/logo-group-white.svg';
    servicesIcon = CSP_PortalPath + 'CSPortal/Images/Icons/service-white.svg';
    supportIcon = CSP_PortalPath + 'CSPortal/Images/Icons/support-white.svg';
    profileIcon = CSP_PortalPath + 'CSPortal/Images/Icons/profile-white.svg';
    profileIconBlue = CSP_PortalPath + 'CSPortal/Images/Icons/profile-blue.svg';
    arrowIcon = CSP_PortalPath + 'CSPortal/Images/Icons/arrow-down-white.svg';
    arrowIconBlue = CSP_PortalPath + 'CSPortal/Images/Icons/arrow-down-blue.svg';
    notificationIcon = CSP_PortalPath + 'CSPortal/Images/Icons/notification-white.svg';
    searchWhiteIcon = CSP_PortalPath + 'CSPortal/Images/Icons/searchWhite.svg';
    searchBlueIcon = CSP_PortalPath + 'CSPortal/Images/Icons/searchBlue.svg';
    mobileMenuIcon = CSP_PortalPath + 'CSPortal/Images/Icons/menu.svg';

    //notifications
    @track numberOfNotifications;
    @track openNotifications = false;
    @track openSearch = false;
    @track openSideBarMenu = false;
    @track openSideBarMenuProfile = false;
    @track notification;

    //notification Center Tab
    @track allNotificationTab;
    @track announcementTab;
    @track taskTab;

    //notification counter
    @track notificationCounter = 0;
    @track taskCounter = 0;

    @track notificationsList;
    @track currentURL;
    @track baseURL;
    @track showBackdrop = false;

    @track showHoverResults = false;

    //User Type
    @track userAdmin;

    //Flag that defines if the IATA Invoices entry is displayed in the menu
    @track displayInvoicesMenu; //WMO-696 - ACAMBAS

    //style variables for notifications
    @track sideMenuBarStyle;
    @track headerButtonNotificationsContainerStyle;
    @track headerButtonNotificationsCloseIconStyle;
    @track headerButtonNotificationsStyle;
    @track notificationNumberStyle='display: none;';
    @track openNotificationsStyle;
    @track displayBodyStyle;
    @track displayNotificationStyle;
    //style variables for search
    @track headerButtonSearchContainerStyle;
    @track headerButtonSearchCloseIconStyle;
    @track headerButtonSearchStyle;
    @track openSearchStyle;
    @track displayBodyStyle;
    @track displaySearchStyle;
    //
    @track checkDisplayBodyStyle

    // MODAL
    @track openModal = false;

    @track mainBackground = 'z-index: 9999;';

    @track mobileMenuStyle = 'headerBarButton';
    @track buttonServiceStyle = 'slds-m-left_xx-large slds-p-left_x-small headerBarButton buttonService';
    @track buttonSupportStyle = 'slds-m-left_medium slds-p-left_x-small headerBarButton buttonSupport';
    @track buttonSideMenuServiceStyle = 'headerBarButton buttonService';
    @track buttonSideMenuSupportStyle = 'headerBarButton buttonSupport';
    @track buttonSideMenuSearchStyle = 'headerBarButton buttonSearch';
    @track buttonSideMenuProfileStyle = 'headerBarButton buttonProfile';
    @track buttonSideMenuCompanyStyle = 'headerBarButton buttonCompany';
    @track buttonSideMenuCasesStyle = 'headerBarButton buttonCases';
    @track buttonSideMenuResetPwStyle = 'headerBarButton buttonResetPw';
    @track buttonSideMenuLogoutStyle = 'headerBarButton buttonLogout';

    @track trackedIsInOldPortal;

    @api
    get isInOldPortal() {
        return this.trackedIsInOldPortal;
    }
    set isInOldPortal(value) {
        this.trackedIsInOldPortal = value;
    }

    @wire(CurrentPageReference)
    getPageRef() {
        this.handlePageRefChanged();
    }

    connectedCallback() {

        isGuestUser().then(results => {            
            this.internalUser = !results;
        });
        
        getLoggedUser()
        .then(results => {
            if(results.Contact !== undefined) {
                let userPortalStatus = results.Contact.User_Portal_Status__c !== undefined ? results.Contact.User_Portal_Status__c : '';
                let accountCategory = results.Contact.Account !== undefined && results.Contact.Account.Category__c !== undefined ? results.Contact.Account.Category__c : '';
                let accountSector = results.Contact.Account !== undefined && results.Contact.Account.Sector__c !== undefined ? results.Contact.Account.Sector__c : '';
                let isoCode = results.Contact.Account.IATA_ISO_Country__r !== undefined && results.Contact.Account.IATA_ISO_Country__r.ISO_Code__c !== undefined ? results.Contact.Account.IATA_ISO_Country__r.ISO_Code__c : '';
                let jobFunction = results.Contact.Membership_Function__c !== undefined ? results.Contact.Membership_Function__c.replace(/;/g, ',') : '';
                
                this.setCookie('userguiding_acc_categ', accountCategory, 1);
                this.setCookie('userguiding_acc_sector', accountSector, 1);
                this.setCookie('userguiding_iso-code', isoCode, 1);
                this.setCookie('userguiding_user-status', userPortalStatus, 1);
                this.setCookie('userguiding_job-function', jobFunction, 1);
            }
        });

        this.getLanguagesOptions();

        isAdmin().then(result => {
            this.userAdmin = result;
        });

        let pageParams = getParamsFromPage();
        if(pageParams !== undefined && pageParams.firstLogin !== undefined){
            if(pageParams.firstLogin == "true"){
                this.firstLogin = true;
            }
        }

        //WMO-696 - ACAMBAS: Begin
        showIATAInvoices().then(result => {
            this.displayInvoicesMenu = result;
        });
        //WMO-696 - ACAMBAS: End

        this.redirectChangePassword();

        getNotifications().then(result => {
            this.baseURL = window.location.href;
            let resultsAux = JSON.parse(JSON.stringify(result));

            resultsAux.sort(function (a, b) {
                return new Date(b.createdDate) - new Date(a.createdDate);
            });

            this.notificationsList = resultsAux;

            let notificationCounter = 0;
            let taskCounter = 0;
            resultsAux.forEach(function (element) {
                if (element.type === 'Notification') {
                    if (element.viewed === false) {
                        notificationCounter++;
                    }
                } else {
                    taskCounter++;
                }
            });

            this.notificationCounter = notificationCounter;
            this.taskCounter = taskCounter;

            this.announcementTab = this.labels.Announcement + ' (' + notificationCounter + ')';
            this.taskTab = this.labels.Tasks + ' (' + taskCounter + ')';
            this.allNotificationTab = this.labels.AllNotifications + ' (' + (notificationCounter + taskCounter) + ')';
            this.numberOfNotifications = (notificationCounter + taskCounter);

            if (this.numberOfNotifications === "0" || this.numberOfNotifications === 0) {
                this.notificationNumberStyle = 'display: none;';
            }else{
				this.notificationNumberStyle = 'display: inline;';
				this.headerButtonNotificationsStyle='display: inline; vertical-align:top;';
			}

        });

        getContactInfo().then(result => {
            this.displayCompanyTab = !result.Account.Is_General_Public_Account__c;
        });
    }

    redirectChangePassword() {
        redirectChangePassword().then(result => {
            if (result) {
                let location = window.location.href;
                location = String(location);
                let terms = JSON.parse(JSON.stringify(this.displayAcceptTerms));
                if (!location.includes("ISSP_ChangePassword") && terms === true) {
                    this.navigateToChangePassword();
                }
            }
        });
    }


    //navigation methods
    navigateToOtherPage(pageNameToNavigate) {
        this[NavigationMixin.Navigate]({
            type: "standard__namedPage",
            attributes: {
                pageName: pageNameToNavigate
            },
        });
    }

    // Check if we are in the Old/New Portal
    navigationCheck(pageNameToNavigate, currentService) {
        
        this.closeSideMenu();
        if (this.trackedIsInOldPortal) {
            redirectfromPortalHeader({ pageName: currentService }).then(result => {
                window.location.href = result;
            });
        } else {
            this.navigateToOtherPage(pageNameToNavigate);
        }
    }

    //WMO-627 - ACAMBAS: Begin
    // Navigate to other page tab
	navigationCheckToPageTab(pageNameToNavigate, currentService, tab) {
		if (this.trackedIsInOldPortal) {
            redirectfromPortalHeader({ pageName: currentService }).then(result => {
                if (tab != null && tab != '')
                    window.location.href = result + '?tab=' + tab;
                else
                    window.location.href = result;
                });
        } else {
            let params = {};
            if (tab !== undefined && tab !== null) {
                params.tab = tab;
            }

            this[NavigationMixin.GenerateUrl]({
                type: "standard__namedPage",
                attributes: {
                    pageName: pageNameToNavigate
                }
            })
            .then(url => navigateToPage(url, params));
        }
    }
    //WMO-627 - ACAMBAS: End

    navigateToHomePage() {
        this.navigationCheck("home", "");
        //this.navigateToOtherPage("home");
    }

    navigateToServices() {
        this.navigationCheck("services", "services");
        //this.navigateToOtherPage("services");
    }

    navigateToSupport() {
        this.navigationCheck("support", "support");
        //this.navigateToOtherPage("support");
    }

    navigateToMyProfile() {
        this.navigationCheck("my-profile", "my-profile");
    }

    navigateToCompanyProfile() {
        //WMO-627 - ACAMBAS: Begin
        //this.navigationCheck("company-profile", "company-profile");
        this.navigationCheckToPageTab("company-profile", "company-profile", null);
        //WMO-627 - ACAMBAS: End
    }

    navigateToCases() {
        this.navigationCheck("cases-list", "cases-list");
    }

    //WMO-627 - ACAMBAS: Begin
    navigateToInvoices() {
        this.navigationCheckToPageTab("company-profile", "company-profile", "invoices");
    }
    //WMO-627 - ACAMBAS: End

    navigateToSettings() {
        //this.navigateToOtherPage("");
    }

    navigateToChangePassword() {
        goToOldChangePassword({}).then(results => {
            window.open(results, "_self");
        });

    }

    navigateToCspChangePassword() {
        this.navigationCheck("changePassword", "changePassword");
    }

    //user logout
    logOut() {
        navigateToPage("/secur/logout.jsp?retUrl=" + CSP_PortalPath + "login");
    }


    //method to change the style when the user clicks on the notifications
    toggleNotifications() {

        this.openNotifications = !this.openNotifications;

        if (this.openNotifications) {
            this.headerButtonNotificationsContainerStyle = 'background-color: #ffffff; z-index: 10000; padding-right: 6px; padding-left: 6px;';
            this.headerButtonNotificationsCloseIconStyle = 'display: flex; align-items: center; justify-content: center;';
            this.headerButtonNotificationsStyle = 'display: none;';
            this.notificationNumberStyle = 'display: none;';
            this.openNotificationsStyle = 'display: block;';
            this.showBackdrop = true;
            this.displayBodyStyle = '';
            this.displayNotificationStyle = 'width: 100%'
            this.closeSideMenu();
        } else {
            this.headerButtonNotificationsContainerStyle = 'z-index: 100;';
            this.headerButtonNotificationsCloseIconStyle = 'display: none; ';
            this.headerButtonNotificationsStyle = 'display: inline; vertical-align:top;';
            this.notificationNumberStyle = (this.numberOfNotifications === 0 ? 'display: none;' : 'display: inline;');
            this.openNotificationsStyle = 'display: none;';
            this.showBackdrop = false;
        }
           
    }
    //method to change the style when the user clicks on the search
    toggleSearch() {
        this.openSearch = !this.openSearch;

        if (this.openSearch) {
            this.headerButtonSearchContainerStyle = 'background-color: #ffffff; z-index: 10000; padding-right: 6px; padding-left: 6px; padding-top: 6px; padding-bottom:90px; margin-top: 0; margin-bottom: 0;';
            this.headerButtonSearchCloseIconStyle = 'display: flex; align-items: center; justify-content: center;';
            this.headerButtonSearchStyle = 'display: none;';
            this.openSearchStyle = 'display: block;';
            this.showBackdrop = true;
            this.displayBodyStyle = '';
            this.displaySearchStyle = 'width: 100%';
            this.closeSideMenu();
            
        } else {
            this.headerButtonSearchContainerStyle = 'z-index: 100;';
            this.headerButtonSearchCloseIconStyle = 'display: none; ';
            this.headerButtonSearchStyle = 'display: block; vertical-align:top;';
            this.openSearchStyle = 'display: none;';
            this.showBackdrop = false;
        }
           
    }

    toggleSideMenu()
    {
        this.openSideBarMenu = ! this.openSideBarMenu;

        if (this.openSideBarMenu) {
            this.sideMenuBarStyle = 'display: block; width: 300px;';
        } else {
            this.sideMenuBarStyle = 'width: 0px;';
        }
    }

    toggleSideMenuProfile()
    {
        this.openSideBarMenuProfile = ! this.openSideBarMenuProfile;

        if (this.openSideBarMenuProfile) {
            this.sideMenuBarProfileStyle = 'display: block; height: 240px;';
        } else {
            this.sideMenuBarProfileStyle = 'height: 1px;';
        }
    }

    closeSideMenu()
    {
        if (this.openSideBarMenu) {
            this.toggleSideMenu();
        }
    }

    onClickAllNotificationsView(event) {
        this.notificationsView(event);
    }

    openmodal(event) {
        this.notificationsView(event);

        this.mainBackground = "z-index: 10004;";
        this.openModal = true;
    }

    closeModal() {
        this.mainBackground = "z-index: 10000;";
        this.openModal = false;
    }

    notificationsView(event) {
        let selectedNotificationId = event.target.dataset.item;

        let notificationsListAux = JSON.parse(JSON.stringify(this.notificationsList));

        let notification = notificationsListAux.find(function (element) {
            if (element.id === selectedNotificationId) {
                return element;
            }
            return null;
        });

        this.notification = notification;

        if (notification.type === 'Notification') {
            increaseNotificationView({ id: selectedNotificationId })
                .then(results => {

                    if (!notification.viewed) {
                        let notificationCounter = this.notificationCounter;
                        let taskCounter = this.taskCounter;

                        notificationCounter--;
                        this.numberOfNotifications = notificationCounter + taskCounter;
                        this.announcementTab = this.labels.Announcement + ' (' + notificationCounter + ')';
                        this.allNotificationTab = this.labels.AllNotifications + ' (' + (notificationCounter + taskCounter) + ')';
                        this.notificationCounter = notificationCounter;

                        this.numberOfNotifications = (notificationCounter + taskCounter);
                        if (this.numberOfNotifications === "0" || this.numberOfNotifications === 0) {
                            this.notificationNumberStyle = 'display: none;';
                        }

                        notification.viewed = true;
                        notification.styles = 'readNotification';
                        this.notificationsList = notificationsListAux;
                    }

                })
                .catch(error => {
                    const showError = new ShowToastEvent({
                        title: 'Error',
                        message: 'An error has occurred: ' + error.getMessage,
                        variant: 'error',
                    });
                    this.dispatchEvent(showError);

                });
        } else if (notification.type === "Portal Service") {

            let params = {};
            params.serviceId = notification.id;
            //Parameter added to force filtrage for Access Requested Contacts on the Service Management Page.
            params.status = "Access_Request";
            this.currentURL = window.location.href;

            if (this.currentURL.includes(this.labels.PortalName)) {
                this[NavigationMixin.GenerateUrl]({
                    type: "standard__namedPage",
                    attributes: {
                        pageName: "manage-service"
                    }
                })
                    .then(url => navigateToPage(url, params));
            } else {
                goToManageService().then(results => {
                    navigateToPage(results, params);
                });
            }
        } else if (notification.type === "Portal Access") {
            navigateToPage("company-profile?tab=contact&contactName=" + notification.contactName);
        } else {
            navigateToPage("company-profile?tab=contact");
        }
    }

    goToAdvancedSearchPage() {
        this.navigationCheck("advanced-search", "advanced-search");
    }

    handlePageRefChanged() {
        let pagename = getPageName();
        
        this.buttonServiceStyle = this.buttonServiceStyle.replace(/selectedButton/g, '');
        this.buttonSupportStyle = this.buttonSupportStyle.replace(/selectedButton/g, '');
        this.buttonSideMenuServiceStyle = this.buttonSideMenuServiceStyle.replace(/selectedButton/g, '');
        this.buttonSideMenuSupportStyle = this.buttonSideMenuSupportStyle.replace(/selectedButton/g, '');
        this.buttonSideMenuSearchStyle = this.buttonSideMenuSearchStyle.replace(/selectedButton/g, '');
        this.buttonSideMenuProfileStyle = this.buttonSideMenuProfileStyle.replace(/selectedButton/g, '');
        this.buttonSideMenuCompanyStyle = this.buttonSideMenuCompanyStyle.replace(/selectedButton/g, '');
        this.buttonSideMenuCasesStyle = this.buttonSideMenuCasesStyle.replace(/selectedButton/g, '');

        if (pagename) {
            getBreadcrumbs({ pageName: pagename })
                .then(results => {
                    let breadCrumbs = JSON.parse(JSON.stringify(results));
                    if (breadCrumbs && breadCrumbs[1])
                    {
                        if (breadCrumbs[1].DeveloperName === 'services') {
                            this.buttonServiceStyle = `${this.buttonServiceStyle} selectedButton`;
                            this.buttonSideMenuServiceStyle = `${this.buttonSideMenuServiceStyle} selectedButton`;
                        } else if (breadCrumbs[1].DeveloperName === 'support') {
                            this.buttonSupportStyle = `${this.buttonSupportStyle} selectedButton`;
                            this.buttonSideMenuSupportStyle = `${this.buttonSideMenuSupportStyle} selectedButton`;
                        } else if (breadCrumbs[1].DeveloperName === 'advanced_search') {
                            this.buttonSideMenuSearchStyle = `${this.buttonSideMenuSearchStyle} selectedButton`;
                        } else if (breadCrumbs[1].DeveloperName === 'my_profile') {
                            this.buttonSideMenuProfileStyle = `${this.buttonSideMenuProfileStyle} selectedButton`;
                        } else if (breadCrumbs[1].DeveloperName === 'company_profile') {
                            this.buttonSideMenuCompanyStyle = `${this.buttonSideMenuCompanyStyle} selectedButton`;
                        } else if (breadCrumbs[1].DeveloperName === 'cases_list') {
                            this.buttonSideMenuCasesStyle = `${this.buttonSideMenuCasesStyle} selectedButton`;
                        }
                    }
                });
        }
    }

    acceptTerms() {

        const fields = {};
        fields.Id = Id;
        fields.ToU_accepted__c = true;
        fields.Date_ToU_accepted__c = new Date().toISOString();
        const recordInput = { fields };

        updateRecord(recordInput)
            .then(() => {
                this.displayAcceptTerms = true;
                this.redirectChangePassword();
            });

    }

    confirmRegistration() {
        const fields = {};
        fields.Id = Id;
        fields.Portal_Registration_Required__c = false;
        const recordInput = { fields };

        updateRecord(recordInput)
            .then(() => {
                window.location.reload();
                //this.displayRegistrationConfirmation = false;
        });
    }

    close() {
        if (this.openNotifications) {
            this.openNotifications = true;
            this.toggleNotifications();
        }
        if (this.openSearch) {
            this.toggleSearch();
        }
    }

    hideRegistration() {
        this.displayRegistrationConfirmation = false;
    }

    hideFirstLogin() {
        this.displayFirstLogin = false;
        this.firstLogin = false;
    }

    get totalNotification() {
        let toReturn = true;
        if (this.notificationsList !== undefined) {
            let notList = JSON.parse(JSON.stringify(this.notificationsList));
            if (notList !== undefined && notList.length > 0) {
                notList.forEach(function (element) {
                    if (element.type === 'Notification' || element.type === 'Portal Service' || element.type === 'Portal Access' || element.type === 'Customer Invoice')
                        toReturn = false;
                });
            }
        }
        return toReturn;
    }

    get announcementNumber() {
        let toReturn = true;
        if (this.notificationsList !== undefined) {
            let notList = JSON.parse(JSON.stringify(this.notificationsList));
            if (notList !== undefined && notList.length > 0) {
                notList.forEach(function (element) {
                    if (element.type === 'Notification')
                        toReturn = false;
                });
            }
        }
        return toReturn;
    }

    get taskNumber() {
        let toReturn = true;
        if (this.notificationsList !== undefined) {
            let notList = JSON.parse(JSON.stringify(this.notificationsList));
            if (notList !== undefined && notList.length > 0) {
                notList.forEach(function (element) {
                    if (element.type === 'Portal Service' || element.type === 'Portal Access' || element.type === 'Customer Invoice')
                        toReturn = false;
                });
            }
        }
        return toReturn;
    }

    @track displaySecondLevelRegistration = false;

    triggerSecondLevelRegistration(){
        this.displayFirstLogin = false;
        this.firstLogin = false;
        this.displaySecondLevelRegistration= true;
    }

    closeSecondLevelRegistration(){
        this.displaySecondLevelRegistration = false;
    }

    secondLevelRegistrationCompleted(){
        navigateToPage(CSP_PortalPath,{});
    }

    setCookie(name, value, days) {
        let expires = "";
        if (days) {
          let date = new Date();
          date.setTime(date.getTime() + (days * 24 * 60 * 60 * 1000));
          expires = "; expires=" + date.toUTCString();
        }
        document.cookie = name + "=" + (value || "") + expires + "; path=/";
    }
      
    getCookie(name) {
        let nameEQ = name + "=";
        let ca = document.cookie.split(';');
        for (let i = 0; i < ca.length; i++) {
          let c = ca[i];
          while (c.charAt(0) === ' ') c = c.substring(1, c.length);
          if (c.indexOf(nameEQ) === 0) return c.substring(nameEQ.length, c.length);
        }
        return null;
    }
}
