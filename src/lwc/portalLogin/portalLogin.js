/**
 * Created by ukaya01 on 27/06/2019.
 */

/* ==============================================================================================================*/
/* Utils & Apex & Platform
/* ==============================================================================================================*/
import { LightningElement, track, wire} from 'lwc';
import { navigateToPage, getParamsFromPage } from'c/navigationUtils';
import RegistrationUtils from 'c/registrationUtils'
import isGuest from '@salesforce/user/isGuest';
import getInitialConfig from '@salesforce/apex/PortalLoginCtrl.getInitialConfig';
import login from '@salesforce/apex/PortalLoginCtrl.login';

/* ==============================================================================================================*/
/* Custom Labels
/* ==============================================================================================================*/
import LoginLabel from '@salesforce/label/c.login';
import EmailLabel from '@salesforce/label/c.Email';
import PasswordLabel from '@salesforce/label/c.OneId_Password';
import ForgotPasswordLabel from '@salesforce/label/c.OneId_ForgotPassword';
import CreateNewAccountLabel from '@salesforce/label/c.OneId_CreateNewAccount';
import TroubleshootingLabel from '@salesforce/label/c.OneId_CSP_Troubleshooting';
import FrozenUserLabel from '@salesforce/label/c.ISSP_Frozen_User_Alert_Message';
import invalidMailFormatLabel from '@salesforce/label/c.ISSP_AMS_Invalid_Email';
import TroubleShootingUrl from '@salesforce/label/c.OneId_CSP_Troubleshooting_Link';
import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';



export default class PortalLogin extends LightningElement {

    /* ==============================================================================================================*/
    /* Attributes
    /* ==============================================================================================================*/

    @track showLoginForm = false;
    @track isSanctioned = false;
    @track isLoading = true;
    @track config = {};
    @track loginButtonDisabled = true;
    @track passwordIconDisabled = true;
    @track displayTroubleshooting = false;
    @track email = "";
    @track password = "";
    @track errorMessage = "";
    @track showError = false;
    @track showPageMessage = false;
    @track pageMessage = "";
    @track passwordInputType = "password";
    @track isEmailFieldReadOnly = false;
    @track isFrozen = false;
    @track isLoginDisabled = false;
    exclamationIcon = CSP_PortalPath + 'CSPortal/Images/Icons/exclamation_point.svg';
    alertIcon = CSP_PortalPath + 'alertIcon.png';

    _labels = {
        LoginLabel,
        EmailLabel,
        PasswordLabel,
        ForgotPasswordLabel,
        CreateNewAccountLabel,
        TroubleshootingLabel,
        FrozenUserLabel,
        TroubleShootingUrl,
        DisabledLoginLabel : 'Portal Login is currently disabled. Thank you for your understanding.'
    }
    get labels() {
        return this._labels;
    }
    set labels(value) {
        this._labels = value;
    }

    get isPasswordIconDisabled(){
        return this.password.length > 0 ? false : true;
    }

    get svgURL(){
        return CSP_PortalPath + 'show_blue.png';
    }

    /* ==============================================================================================================*/
    /* Lifecycle Hooks
    /* ==============================================================================================================*/

    connectedCallback() {

        const RegistrationUtilsJs = new RegistrationUtils();

        RegistrationUtilsJs.checkUserIsSystemAdmin().then(result=> {
            if(result == false && isGuest == false){
                navigateToPage(CSP_PortalPath,{});
                return;
            }
        });

        let pageParams = getParamsFromPage();
        if(pageParams !== undefined && pageParams.email !== undefined){
            this.email = decodeURIComponent(pageParams.email);
            this.isEmailFieldReadOnly = true;
            if(pageParams.redirect == "1"){
                this.showPageMessage = true;
                this.pageMessage = 'It seems you are already a portal user. You can login with your password.';
            }
        }

        RegistrationUtilsJs.getUserLocation().then(result=> {
            this.isSanctioned = result.isRestricted;
            if(this.isSanctioned == true){
                //navigate to error page
                navigateToPage(CSP_PortalPath + 'restricted-login');
            }else{
                getInitialConfig().then(result => {
                    var config = JSON.parse(JSON.stringify(result));
                    console.log('config: ', config);
                    config.selfRegistrationUrl = result.selfRegistrationUrl.substring(result.selfRegistrationUrl.indexOf(CSP_PortalPath));
                    config.forgotPasswordUrl = result.forgotPasswordUrl.substring(result.forgotPasswordUrl.indexOf(CSP_PortalPath));
                    this.config = config;

                    //todo remove this part - for testing only.
                    //config.isUsernamePasswordEnabled = false;
                    //------------------------------------------
                    //this.isFrozen = true;
                    //this.showLoginForm = false;
                    //this.isLoading = false;
                    //return;
                    //todo end of remove
                    if(config.isUsernamePasswordEnabled == false){
                         this.showLoginForm = false;
                         this.isLoginDisabled = true;
                         this.isLoading = false;
                         return;
                    }
                    this.showLoginForm = true;
                    this.isLoading = false;


                })
                .catch(error => {
                    this.isLoading = false;
                });
            }
        });

    }

    renderedCallback(){

        if(this.isLoading == false &&  this.email != null && this.isEmailFieldReadOnly == true){
            //check the email field
            //If it is pre-filled apply specific style
            this._checkEmailField();
        }
        /*
        //disable autocomplete - 1 ( does not work )
        var input = this.template.querySelector('[data-id="emailInput"]');
        if(input.getAttribute("autocomplete") !== "off"){
            input.setAttribute("autocomplete","off");
        }

        //disable autocomplete - 2 ( does not work )
        if (document.getElementsByTagName) {
            var inputElements = document.getElementsByTagName("input");
            for(var i=0; inputElements[i]; i++) {
                if(inputElements[i].className && (inputElements[i].className.indexOf("disableAutoComplete") != -1)) {
                inputElements[i].setAttribute("autocomplete","off");
                }
            }
        }
        */
    }

    /* ==============================================================================================================*/
    /* Event Handlers
    /* ==============================================================================================================*/

    handleEmailChange(event){
        this.email = event.target.value;

        if(this.email.length > 0 && this.password.length > 0){
            this.loginButtonDisabled = false;
            this.template.querySelector('[data-id="loginButton"]').classList.remove('containedButtonDisabled');
            this.template.querySelector('[data-id="loginButton"]').classList.add('containedButtonLogin');
        }else{
            this.loginButtonDisabled = true;
            this.template.querySelector('[data-id="loginButton"]').classList.add('containedButtonDisabled');
            this.template.querySelector('[data-id="loginButton"]').classList.remove('containedButtonLogin');
        }
        this._showLoginError(false, "");
        //this._checkEmailField();
    }

    /*
    handleEmailFocus(){
        //disable autocomplete  ( does not work )
        var input = this.template.querySelector('[data-id="emailInput"]');
        if(input.getAttribute("autocomplete") !== "off"){
            input.setAttribute("autocomplete","off");
        }
    }
    */

    handleEmailFocusOut(event){
        this._checkEmailField();
    }

    handlePasswordChange(event){
        this.password = event.target.value;

        if(this.password.length > 0){
            this.template.querySelector('[data-id="passwordIcon"]').classList.remove('showPasswordIconDisabled');
            if(this.email.length > 0){
                this.loginButtonDisabled = false;
                this.template.querySelector('[data-id="loginButton"]').classList.remove('containedButtonDisabled');
                this.template.querySelector('[data-id="loginButton"]').classList.add('containedButtonLogin');
            }else{
                this.loginButtonDisabled = true;
                this.template.querySelector('[data-id="loginButton"]').classList.add('containedButtonDisabled');
                this.template.querySelector('[data-id="loginButton"]').classList.remove('containedButtonLogin');
            }
        }else{
            this.template.querySelector('[data-id="passwordIcon"]').classList.add('showPasswordIconDisabled');
            this.loginButtonDisabled = true;
            this.template.querySelector('[data-id="loginButton"]').classList.add('containedButtonDisabled');
            this.template.querySelector('[data-id="loginButton"]').classList.remove('containedButtonLogin');

        }

        this._showLoginError(false, "");

    }

    handlePasswordFocusOut(event){
        this._checkPasswordField();
    }

    handleLogin(event){

        this.isLoading = true;

        const RegistrationUtilsJs = new RegistrationUtils();
        RegistrationUtilsJs.checkEmailIsValid(`${this.email}`).then(result=> {
            if(result == false){
                this._showLoginError(true, invalidMailFormatLabel);
                this.isLoading = false;
                return;
            }else{
                login({username: this.email, password: this.password }).then(result => {
                    var response = JSON.parse(JSON.stringify(result));
                    console.log('login response: ' , response);
                    if(response.isSuccess == true){
                        navigateToPage(response.sessionUrl, {});
                    }else{
                        this.isFrozen = result.userIsFrozen;
                        if(result.userIsFrozen == true){
                            this.showLoginForm = false;
                        }
                        this._showLoginError(true, response.errorMessage);
                        this.isLoading = false;
                    }
                })
                .catch(error => {
                    this.isLoading = false;
                });
            }
        }).catch(error => {
            this.isLoading = false;
        });

    }

    handleShowPassword(){
        if(this.passwordInputType == "password"){
            this.passwordInputType = "text";
        }else{
            this.passwordInputType = "password";
        }
    }

    handleChangeEmail(){
        this.isEmailFieldReadOnly = false;
    }

    handleNavigateToForgotPassword() {
        navigateToPage(this.config.forgotPasswordUrl);
    }

    handleNavigateToSelfRegister() {
        navigateToPage(this.config.selfRegistrationUrl);
    }

    handleNavigateToTroubleshooting() {
        navigateToPage(this.labels.TroubleShootingUrl);
    }

    /* ==============================================================================================================*/
    /* Helper Methods
    /* ==============================================================================================================*/

    _checkPasswordField(){
        if(this.password.length > 0){
            this.template.querySelector('[data-id="passwordInput"]').classList.add('inputBackgroundGrey');
        }else{
            this.template.querySelector('[data-id="passwordInput"]').classList.remove('inputBackgroundGrey');
        }
    }

    _checkEmailField(){
        if(this.email.length > 0){
            this.template.querySelector('[data-id="emailInput"]').classList.add('inputBackgroundGrey');
        }else{
            this.template.querySelector('[data-id="emailInput"]').classList.remove('inputBackgroundGrey');
        }
    }

    _showLoginError(state, message){
        var emailDiv = this.template.querySelector('[data-id="emailDiv"]');
        var passwordDiv = this.template.querySelector('[data-id="passwordDiv"]');
        this.errorMessage = message;
        this.showError = state;
        this.displayTroubleshooting = state;

        if(state == true){
            emailDiv.classList.add('slds-has-error');
            passwordDiv.classList.add('slds-has-error');
        }else{
            emailDiv.classList.remove('slds-has-error');
            passwordDiv.classList.remove('slds-has-error');
        }

    }

}