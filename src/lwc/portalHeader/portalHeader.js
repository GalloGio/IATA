import { LightningElement, track, wire, api } from 'lwc';

// language
import userId from '@salesforce/user/Id';
import changeUserLanguage from '@salesforce/apex/CSP_Utils.changeUserLanguage';
import getCommunityAvailableLanguages from '@salesforce/apex/CSP_Utils.getCommunityAvailableLanguages';

//navigation
import { NavigationMixin, CurrentPageReference } from 'lightning/navigation';
import { navigateToPage, getPageName } from 'c/navigationUtils';
import getBreadcrumbs from '@salesforce/apex/PortalBreadcrumbCtrl.getBreadcrumbs';

//notification apex method
import getNotifications from '@salesforce/apex/PortalHeaderCtrl.getNotifications';
import isAdmin from '@salesforce/apex/CSP_Utils.isAdmin';
import increaseNotificationView from '@salesforce/apex/PortalHeaderCtrl.increaseNotificationView';
import goToManageService from '@salesforce/apex/PortalHeaderCtrl.goToManageService';
import goToOldChangePassword from '@salesforce/apex/PortalHeaderCtrl.goToOldChangePassword';
import redirectChangePassword from '@salesforce/apex/PortalHeaderCtrl.redirectChangePassword';

import redirectfromPortalHeader from '@salesforce/apex/CSP_Utils.redirectfromPortalHeader';

// Toast
import { ShowToastEvent } from 'lightning/platformShowToastEvent'

//custom labels
import ISSP_Services from '@salesforce/label/c.ISSP_Services';
import CSP_Support from '@salesforce/label/c.CSP_Support';
import CSP_YouAndIATA from '@salesforce/label/c.CSP_YouAndIATA';
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

import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';


export default class PortalHeader extends NavigationMixin(LightningElement) {
    // language
    @track selectedLang = 'en_US';
    @track langOptions = [];
    @track chagingLang = false;
    @track loadingLangs = true;
    @track userId = userId;

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

    @wire(getRecord, { recordId: Id, fields: [User_ToU_accept] })
    WiregetUserRecord(result) {
        if (result.data) {
            let user = JSON.parse(JSON.stringify(result.data));
            let acceptTerms = user.fields.ToU_accepted__c.value;
            let currentURL = window.location.href;
            if (currentURL.includes(this.labels.PortalName)) {
                this.displayAcceptTerms = acceptTerms;
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
        CSP_YouAndIATA,
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
        CSP_You_Dont_Have_Tasks

    };

    get labels() {
        return this._labels;
    }
    set labels(value) {
        this._labels = value;
    }

    //links for images
    logoIcon = CSP_PortalPath + 'CSPortal/Images/Logo/group.svg';
    logoWhiteIcon = CSP_PortalPath + 'CSPortal/Images/Logo/group_white.svg';
    servicesIcon = CSP_PortalPath + 'CSPortal/Images/Icons/service-white.svg';
    supportIcon = CSP_PortalPath + 'CSPortal/Images/Icons/support-white.svg';
    youAndIATA = CSP_PortalPath + 'CSPortal/Images/Icons/youiata-white.svg';
    profileIcon = CSP_PortalPath + 'CSPortal/Images/Icons/profile-white.svg';
    profileIconBlue = CSP_PortalPath + 'CSPortal/Images/Icons/profile-blue.svg';
    arrowIcon = CSP_PortalPath + 'CSPortal/Images/Icons/arrow-down-white.svg';
    arrowIconBlue = CSP_PortalPath + 'CSPortal/Images/Icons/arrow-down-blue.svg';
    notificationIcon = CSP_PortalPath + 'CSPortal/Images/Icons/notification-white.svg';
    searchWhiteIcon = CSP_PortalPath + 'CSPortal/Images/Icons/searchWhite.svg';
    mobileMenuIcon = CSP_PortalPath + 'CSPortal/Images/Icons/menu.svg';

    //notifications
    @track numberOfNotifications;
    @track openNotifications = false;
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

    //User Type
    @track userAdmin;

    //style variables for notifications
    @track sideMenuBarStyle;
    @track headerButtonNotificationsContainerStyle;
    @track headerButtonNotificationsCloseIconStyle;
    @track headerButtonNotificationsStyle;
    @track notificationNumberStyle;
    @track openNotificationsStyle;
    @track displayBodyStyle;
    @track displayNotificationStyle;
    //
    @track checkDisplayBodyStyle

    // MODAL
    @track openmodel = false;

    @track mainBackground = 'z-index: 9999;';

    @track mobileMenuStyle = 'headerBarButton';
    @track buttonServiceStyle = 'slds-m-left_xx-large slds-p-left_x-small headerBarButton buttonService';
    @track buttonYouIATAStyle = 'slds-m-left_medium slds-p-left_x-small headerBarButton buttonYouIATA';
    @track buttonSupportStyle = 'slds-m-left_medium slds-p-left_x-small headerBarButton buttonSupport';
    @track buttonSideMenuServiceStyle = 'headerBarButton buttonService';
    @track buttonSideMenuYouIATAStyle = 'headerBarButton buttonYouIATA';
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
        
        this.getLanguagesOptions();

        isAdmin().then(result => {
            this.userAdmin = result;
        });

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
            }

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

    navigateToYouIata() {
        this.navigationCheck("youIATA", "youIATA");
    }

    navigateToMyProfile() {
        this.navigationCheck("my-profile", "my-profile");
    }

    navigateToCompanyProfile() {
        this.navigationCheck("company-profile", "company-profile");
    }

    navigateToCases() {
        this.navigationCheck("cases-list", "cases-list");
    }

    navigateToSettings() {
        //this.navigateToOtherPage("");
    }

    navigateToChangePassword() {
        goToOldChangePassword({}).then(results => {
            window.open(results, "_self");
        });

    }

    //user logout
    logOut() {
        navigateToPage("/secur/logout.jsp");
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
            this.headerButtonNotificationsStyle = 'display: block;';
            this.notificationNumberStyle = (this.numberOfNotifications === 0 ? 'display: none;' : 'display: block;');
            this.openNotificationsStyle = 'display: none;';
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
        this.openmodel = true;
    }

    closeModal() {
        this.mainBackground = "z-index: 10000;";
        this.openmodel = false;
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
        } else {
            navigateToPage("company-profile?tab=contact&contactName=" + notification.contactName);
        }
    }

    goToAdvancedSearchPage() {
        this.navigationCheck("advanced-search", "advanced-search");
    }

    handlePageRefChanged() {
        let pagename = getPageName();
        
        this.buttonServiceStyle = this.buttonServiceStyle.replace(/selectedButton/g, '');
        this.buttonYouIATAStyle = this.buttonYouIATAStyle.replace(/selectedButton/g, '');
        this.buttonSupportStyle = this.buttonSupportStyle.replace(/selectedButton/g, '');
        this.buttonSideMenuServiceStyle = this.buttonSideMenuServiceStyle.replace(/selectedButton/g, '');
        this.buttonSideMenuYouIATAStyle = this.buttonSideMenuYouIATAStyle.replace(/selectedButton/g,'');
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
                        } else if (breadCrumbs[1].DeveloperName === 'youIATA') {
                            this.buttonYouIATAStyle = `${this.buttonYouIATAStyle} selectedButton`;
                            this.buttonSideMenuYouIATAStyle = `${this.buttonSideMenuYouIATAStyle} selectedButton`;
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

    close() {
        if (this.openNotifications) {
            this.openNotifications = true;
            this.toggleNotifications();
        }

    }

    get totalNotification() {
        let toReturn = true;
        if (this.notificationsList !== undefined) {
            let notList = JSON.parse(JSON.stringify(this.notificationsList));
            if (notList !== undefined && notList.length > 0) {
                notList.forEach(function (element) {
                    if (element.type === 'Notification' || element.type === 'Portal Service' || element.type === 'Portal Access')
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
                    if (element.type === 'Portal Service' || element.type === 'Portal Access')
                        toReturn = false;
                });
            }
        }
        return toReturn;
    }

}
