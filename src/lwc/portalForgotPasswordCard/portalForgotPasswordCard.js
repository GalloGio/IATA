import { LightningElement, track } from 'lwc';
import { navigateToPage } from 'c/navigationUtils';
import getInitialConfig   from '@salesforce/apex/PortalForgotPasswordController.getInitialConfig';
import RegistrationUtils  from 'c/registrationUtils';
import isGuest            from '@salesforce/user/isGuest';
import CSP_PortalPath     from '@salesforce/label/c.CSP_PortalPath';

export default class PortalForgotPasswordCard extends LightningElement {

    @track isLoadingMain    = true;
    @track isForgotPassword = true;
    @track isSuccess;
    @track loginUrl;
    @track selfRegistrationUrl;
    @track isSelfRegistrationEnabled;
    @track isSanctioned;
    @track troubleShootingUrl;

    connectedCallback() {
       this.checkUserIsGuestOrAdmin();
       const RegistrationUtilsJs = new RegistrationUtils();
       //check user location
       RegistrationUtilsJs.getUserLocation().then(result=> {
           this.isSanctioned = result.isRestricted;
           if(this.isSanctioned == true){
               navigateToPage(CSP_PortalPath + "restricted-login");
           }
           else{
               //get initial configuration information
                getInitialConfig().then(result => {
                   this.selfRegistrationUrl       = result.selfRegistrationUrl.substring(result.selfRegistrationUrl.indexOf(CSP_PortalPath));
                   this.loginUrl                  = result.loginUrl.substring(result.loginUrl.indexOf(CSP_PortalPath));
                   this.isSelfRegistrationEnabled = result.isSelfRegistrationEnabled;
                   this.troubleShootingUrl        = result.troubleShootingUrl;
                   this.changeIsLoadingMain();
               });
           }
       });
    }

    checkUserIsGuestOrAdmin() {
        const RegistrationUtilsJs = new RegistrationUtils();
        RegistrationUtilsJs.checkUserIsSystemAdmin().then(result=> {
            if(result == false && isGuest == false){
                navigateToPage(CSP_PortalPath,{});
                return;
            }
        });
    }

    changePage(event){
        this.changeIsLoadingMain();
        this.isSuccess = event.detail;
        this.isForgotPassword = false;
        this.changeIsLoadingMain();
    }

    changePageFp(){
        this.changeIsLoadingMain();
        this.isForgotPassword = true;
        this.changeIsLoadingMain();
    }

    changeIsLoadingMain(){
        this.isLoadingMain = !this.isLoadingMain;
    }

}