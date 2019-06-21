import { LightningElement, track, wire } from 'lwc';

//navigation
import { NavigationMixin, CurrentPageReference} from 'lightning/navigation';
import { navigateToPage, getPageName } from 'c/navigationUtils';
import getBreadcrumbs from '@salesforce/apex/PortalBreadcrumbCtrl.getBreadcrumbs';

//notification apex method
import getNotifications from '@salesforce/apex/PortalHeaderCtrl.getNotifications';
import isAdmin from '@salesforce/apex/CSP_Utils.isAdmin';
import increaseNotificationView from '@salesforce/apex/PortalHeaderCtrl.increaseNotificationView';
import goToManageService from '@salesforce/apex/PortalHeaderCtrl.goToManageService';


// Toast
import { ShowToastEvent } from 'lightning/platformShowToastEvent'

//custom labels
import ISSP_Services from '@salesforce/label/c.ISSP_Services';
import CSP_Support from '@salesforce/label/c.CSP_Support';
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

import Announcement from '@salesforce/label/c.Announcements_Notification';
import Tasks from '@salesforce/label/c.Tasks_Notification';
import AllNotifications from '@salesforce/label/c.All_Notifications_Notification';

export default class PortalHeader extends NavigationMixin(LightningElement) {

    _labels = {
        ISSP_Services,
        CSP_Support,
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
        AllNotifications
    };
    get labels() {
        return this._labels;
    }
    set labels(value) {
        this._labels = value;
    }

    //links for images
    logoIcon = '/csportal/s/CSPortal/Images/Logo/group.svg';

    //notifications
    @track numberOfNotifications;
    @track openNotifications = false;
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

    @track buttonServiceStyle = 'slds-m-left_xx-large slds-p-left_x-small slds-p-vertical_xx-small headerBarButton buttonService';
    @track buttonSupportStyle = 'slds-m-left_medium slds-p-left_x-small slds-p-vertical_xx-small headerBarButton buttonSupport';


    @wire(CurrentPageReference)
    getPageRef() {
        this.handlePageRefChanged();
    }

    connectedCallback() {

        isAdmin().then(result => {
            this.userAdmin = result;
        });

        getNotifications().then(result => {
            this.baseURL = window.location.href;
            let resultsAux = JSON.parse(JSON.stringify(result));

            console.log('AUX: ', resultsAux);

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
        this.currentURL = window.location.href;
        if (!this.currentURL.includes(this.labels.PortalName)) {
            window.history.pushState("", "", "/" + this.labels.PortalName + "/s/" + currentService);
            location.reload();
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


    //user logout
    logOut() {
        navigateToPage("/secur/logout.jsp");
    }


    //method to change the style when the user clicks on the notifications
    toggleNotifications() {

        this.openNotifications = !this.openNotifications;

        if (this.openNotifications) {
            this.headerButtonNotificationsContainerStyle = 'background-color: #ffffff; z-index: 10000;';
            this.headerButtonNotificationsCloseIconStyle = 'display: block;';
            this.headerButtonNotificationsStyle = 'display: none;';
            this.notificationNumberStyle = 'display: none;';
            this.openNotificationsStyle = 'display: block;';
            this.showBackdrop = true;
            this.displayBodyStyle = 'width: 35vw';
            this.displayNotificationStyle = 'width: 100%'
        } else {
            this.headerButtonNotificationsContainerStyle = 'z-index: 100;';
            this.headerButtonNotificationsCloseIconStyle = 'display: none; ';
            this.headerButtonNotificationsStyle = 'display: block;';
            this.notificationNumberStyle = 'display: block;';
            this.openNotificationsStyle = 'display: none;';
            this.showBackdrop = false;
        }
    }

    onClickAllNotificationsView(event) {
        this.notificationsView(event);
    }

    openmodal(event) {
        this.notificationsView(event);

        this.mainBackground = "z-index: 10004;"
        this.openmodel = true
    }

    closeModal() {
        this.mainBackground = "z-index: 10000;"
        this.openmodel = false
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

        if (notification.typeNotification === 'Announcement') {
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
        } else {
            if (notification.type === "Portal Service") {
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

            }
        }
    }

    goToAdvancedSearchPage(event) {
        let params = {};

        this[NavigationMixin.GenerateUrl]({
            type: "standard__namedPage",
            attributes: {
                pageName: "advanced-search"
            }
        })
            .then(url => navigateToPage(url, params));
    }

    handlePageRefChanged() {
        let pagename = getPageName();
        if(pagename){
            getBreadcrumbs({ pageName : pagename })
                .then(results => {
                    let breadCrumbs = JSON.parse(JSON.stringify(results));
                    if (breadCrumbs && breadCrumbs[1] && (breadCrumbs[1].DeveloperName === 'services' || breadCrumbs[1].DeveloperName === 'support')) {
                        if (breadCrumbs[1].DeveloperName === 'services') {
                            this.buttonServiceStyle = `${this.buttonServiceStyle} selectedButton`;
                            this.buttonSupportStyle = this.buttonSupportStyle.replace(/selectedButton/g, '');
                        } else if (breadCrumbs[1].DeveloperName === 'support') {
                            this.buttonServiceStyle = this.buttonServiceStyle.replace(/selectedButton/g, '');
                            this.buttonSupportStyle = `${this.buttonSupportStyle} selectedButton`;
                        }
                    } else {
                        this.buttonServiceStyle = this.buttonServiceStyle.replace(/selectedButton/g, '');
                        this.buttonSupportStyle = this.buttonSupportStyle.replace(/selectedButton/g, '');
                    }
                })
                .catch(error => {
                    console.log('PortalHeader getBreadcrumbs error: ' , error);
                });
        } else {
            this.buttonServiceStyle = this.buttonServiceStyle.replace(/selectedButton/g, '');
            this.buttonSupportStyle = this.buttonSupportStyle.replace(/selectedButton/g, '');
        }
    }

}