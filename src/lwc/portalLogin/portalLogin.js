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
import Login                                from '@salesforce/label/c.Login';
import CSP_Email                            from '@salesforce/label/c.CSP_Email';
import CSP_Password                         from '@salesforce/label/c.CSP_Password';
import CSP_Change_Email                     from '@salesforce/label/c.CSP_Change_Email';
import CSP_Forgot_Password                  from '@salesforce/label/c.CSP_Forgot_Password';
import CSP_Troubleshooting_Info             from '@salesforce/label/c.CSP_Troubleshooting_Info';
import CSP_Troubleshooting                  from '@salesforce/label/c.CSP_Troubleshooting';
import CSP_Create_New_Account_Info          from '@salesforce/label/c.CSP_Create_New_Account_Info';
import CSP_Create_New_Account_Label         from '@salesforce/label/c.CSP_Create_New_Account_Label';
import CSP_Frozen_User_Message              from '@salesforce/label/c.CSP_Frozen_User_Message';
import CSP_Portal_Login_Disabled_Message    from '@salesforce/label/c.CSP_Portal_Login_Disabled_Message';
import CSP_Invalid_Email                    from '@salesforce/label/c.CSP_Invalid_Email';
import OneId_CSP_Troubleshooting_Link       from '@salesforce/label/c.OneId_CSP_Troubleshooting_Link';
import CSP_Existing_User_Message            from '@salesforce/label/c.CSP_Existing_User_Message';
import OneId_LoginFail                      from '@salesforce/label/c.OneId_LoginFail';
import CSP_PortalPath                       from '@salesforce/label/c.CSP_PortalPath';

/*

import CreateNewAccountLabel from '@salesforce/label/c.OneId_CreateNewAccount';
import TroubleshootingLabel from '@salesforce/label/c.OneId_CSP_Troubleshooting';
import FrozenUserLabel from '@salesforce/label/c.ISSP_Frozen_User_Alert_Message';
import invalidMailFormatLabel from '@salesforce/label/c.ISSP_AMS_Invalid_Email';
import TroubleShootingUrl from '@salesforce/label/c.OneId_CSP_Troubleshooting_Link';
*/




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
    @track isEmailInvalid = false;
    exclamationIcon = CSP_PortalPath + 'CSPortal/Images/Icons/exclamation_point.svg';
    startURL = "";
    relayState = "";

    _labels = {
        Login,
        CSP_Email,
        CSP_Password,
        CSP_Change_Email,
        CSP_Forgot_Password,
        CSP_Troubleshooting_Info,
        CSP_Troubleshooting,
        CSP_Create_New_Account_Info,
        CSP_Create_New_Account_Label,
        CSP_Frozen_User_Message,
        CSP_Portal_Login_Disabled_Message,
        CSP_Invalid_Email,
        OneId_CSP_Troubleshooting_Link,
        CSP_Existing_User_Message,
        OneId_LoginFail
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
        return CSP_PortalPath + 'CSPortal/Images/Icons/show_blue.png';
    }

    /* ==============================================================================================================*/
    /* Lifecycle Hooks
    /* ==============================================================================================================*/

    connectedCallback() {

        let pageParams = getParamsFromPage();
        console.info('pageParams: ', pageParams);

        if(pageParams !== undefined){
            if(pageParams.startURL !== undefined){
                this.startURL = pageParams.startURL;
            }
            if(pageParams.RelayState !== undefined){
                this.relayState = pageParams.RelayState;
            }

        }

        const RegistrationUtilsJs = new RegistrationUtils();

        RegistrationUtilsJs.checkUserIsSystemAdmin().then(result=> {
            if(result == false && isGuest == false){
                navigateToPage(CSP_PortalPath + this.startURL,{});
                return;
            }
        });

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
                    console.log('result.selfRegistrationUrl: ', result.selfRegistrationUrl);
                    config.selfRegistrationUrl = result.selfRegistrationUrl.substring(result.selfRegistrationUrl.indexOf(CSP_PortalPath));
                    config.forgotPasswordUrl = result.forgotPasswordUrl.substring(result.forgotPasswordUrl.indexOf(CSP_PortalPath));
                    this.config = config;
                    console.log('config.selfRegistrationUrl: ', config.selfRegistrationUrl);
                    config.selfRegistrationUrl += '?startURL='+ this.startURL;
                    console.log('config.selfRegistrationUrl: ', config.selfRegistrationUrl);
                    
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
        this._showLoginError(false, "", false);

        if(event.keyCode == 13 && this.loginButtonDisabled == false){
            this.handleLogin();
        }
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

        this._showLoginError(false, "", false);

        if(event.keyCode == 13 && this.loginButtonDisabled == false){
            this.handleLogin();
        }

    }

    handlePasswordFocusOut(event){
        this._checkPasswordField();
    }

    handleLogin(event){

        this.isLoading = true;

        const RegistrationUtilsJs = new RegistrationUtils();
        RegistrationUtilsJs.checkEmailIsValid(`${this.email}`).then(result=> {
            if(result == false){
                this._showLoginError(true, this.labels.CSP_Invalid_Email, true);
                this.isLoading = false;
                return;
            }else{
                login({username: this.email, password: this.password, landingPage: this.startURL, relayState: this.relayState }).then(result => {
                    var response = JSON.parse(JSON.stringify(result));
                    if(response.isSuccess == true){
                        navigateToPage(response.sessionUrl, {});
                    }else{
                        this.isFrozen = result.userIsFrozen;
                        if(result.userIsFrozen == true){
                            this.showLoginForm = false;
                        }
                        this._showLoginError(true, response.errorMessage, false);
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
        navigateToPage(this.config.troubleShootingUrl);
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

    _showLoginError(state, message, isEmailInvalid){
        var emailDiv = this.template.querySelector('[data-id="emailDiv"]');
        var passwordDiv = this.template.querySelector('[data-id="passwordDiv"]');

        if(isEmailInvalid == false){
            this.errorMessage = message;
            this.showError = state;
            this.isEmailInvalid = false;
        }else{
            this.isEmailInvalid = true;
        }

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