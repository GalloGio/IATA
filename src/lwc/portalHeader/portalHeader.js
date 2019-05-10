import { LightningElement, track} from 'lwc';

//navigation
import { NavigationMixin } from 'lightning/navigation';

//notification apex method
import getNotificationsCount from '@salesforce/apex/CSP_Utils.getNotificationsCount';

//custom labels
import ISSP_Services from '@salesforce/label/c.ISSP_Services';
import CSP_Support from '@salesforce/label/c.CSP_Support';
import ICCS_Profile from '@salesforce/label/c.ICCS_Profile';
import ISSP_MyProfile from '@salesforce/label/c.ISSP_MyProfile';
import CSP_CompanyProfile from '@salesforce/label/c.CSP_CompanyProfile';
import CSP_Cases from '@salesforce/label/c.CSP_Cases';
import CSP_Settings from '@salesforce/label/c.CSP_Settings';
import CSP_LogOut from '@salesforce/label/c.CSP_LogOut';


export default class PortalHeader extends NavigationMixin(LightningElement) {

    labels = {
        ISSP_Services,
        CSP_Support,
        ICCS_Profile,
        ISSP_MyProfile,
        CSP_CompanyProfile,
        CSP_Cases,
        CSP_Settings,
        CSP_LogOut
    }
    
    //links for images
    logoIcon = '/csportal/s/CSPortal/Images/Logo/group.svg';

    //notifications
    @track numberOfNotifications;
    @track openNotifications = false;

    //style variables for notifications
    @track headerButtonNotificationsContainerStyle;
    @track headerButtonNotificationsCloseIconStyle;
    @track headerButtonNotificationsStyle;
    @track notificationNumberStyle;
    @track openNotificationsStyle;

    connectedCallback() { 

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

    navigateToHomePage() {
        this.navigateToOtherPage("home");
    }

    navigateToServices() {
        //this.navigateToOtherPage("");
    }

    navigateToSupport() {
        this.navigateToOtherPage("support");
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

        /*this.openNotifications = !this.openNotifications;

        if(this.openNotifications) {
            this.headerButtonNotificationsContainerStyle = 'background-color: #ffffff;';
            this.headerButtonNotificationsCloseIconStyle = 'display: block;';
            this.headerButtonNotificationsStyle = 'display: none;';
            this.notificationNumberStyle = 'display: none;';
            this.openNotificationsStyle = 'display: block;';
       } else {
            this.headerButtonNotificationsContainerStyle = '';
            this.headerButtonNotificationsCloseIconStyle = 'display: none;';
            this.headerButtonNotificationsStyle = 'display: block;';
            this.notificationNumberStyle = 'display: block;';
            this.openNotificationsStyle = 'display: none;';
        }*/
    }
}