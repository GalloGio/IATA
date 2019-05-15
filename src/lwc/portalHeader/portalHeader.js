import { LightningElement, track} from 'lwc';

//navigation
import { NavigationMixin } from 'lightning/navigation';

//notification apex method
import getNotificationsCount from '@salesforce/apex/CSP_Utils.getNotificationsCount';
import getNotifications from '@salesforce/apex/CSP_Utils.getNotifications';
import getUserType from '@salesforce/apex/CSP_Utils.getUserType';
import increaseNotificationView from '@salesforce/apex/CSP_Utils.increaseNotificationView';


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


export default class PortalHeader extends NavigationMixin(LightningElement) {

    labels = {
        ISSP_Services,
        CSP_Support,
        ICCS_Profile,
        ISSP_MyProfile,
        CSP_CompanyProfile,
        CSP_Cases,
        CSP_Settings,
        CSP_LogOut,
        PortalName
    }
    
    //links for images
    logoIcon = '/csportal/s/CSPortal/Images/Logo/group.svg';

    //notifications
    @track numberOfNotifications;
    @track openNotifications = false;

    @track notificationsList;
    @track currentURL;
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

    connectedCallback() { 

        getUserType().then(result => {
            this.userAdmin = result;
        });

        getNotifications().then(result => {
            let resultsAux = JSON.parse(JSON.stringify(result));
            this.notificationsList = resultsAux;
        });

        getNotificationsCount().then(result => {

            this.numberOfNotifications = result;

            if(this.numberOfNotifications === "0" || this.numberOfNotifications === 0) {
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
    navigationCheck(pageNameToNavigate, currentService){
        this.currentURL = window.location.href;
        if ( !this.currentURL.includes(this.labels.PortalName) ) {
            window.history.pushState("", "", this.labels.PortalName + currentService);
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
        //this.navigateToOtherPage("");
    }

    navigateToCompanyProfile() {
        //this.navigateToOtherPage("");
    }

    navigateToCases() {
        this.navigateToOtherPage("cases-list");
    }

    navigateToSettings() {
        //this.navigateToOtherPage("");
    }


    //user logout
    logOut() {
        //window.location.replace("/secur/logout.jsp");
    }


    //method to change the style when the user clicks on the notifications
    toggleNotifications() {

        this.openNotifications = !this.openNotifications;

        if(this.openNotifications) {
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

    onClickAllNotificationsView(event){
        let selectedNotificationId = event.target.dataset.item;

        let notificaion = this.notificationsList.find(function(element) {
            if (element.id === selectedNotificationId){
                return element;
            }
            return null;
        });

        if (notificaion.typeNotification === 'Announcement' ){
            increaseNotificationView({id : selectedNotificationId})
            .then(results => {
                notificaion.viewed = true;
            })
            .catch(error => {
                console.log('Portalheaer onClickAllNotificationsView increaseNotificationView error: ' , error);
            });
        }
        

        
    }
    }

}