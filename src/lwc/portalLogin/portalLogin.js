/* ==============================================================================================================*/
/* Utils & Apex & Platform
/* ==============================================================================================================*/
import { LightningElement, track } from 'lwc';
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
import CSP_Create_New_User_Label            from '@salesforce/label/c.CSP_Create_New_User_Label';
import CSP_Frozen_User_Message              from '@salesforce/label/c.CSP_Frozen_User_Message';
import CSP_Portal_Login_Disabled_Message    from '@salesforce/label/c.CSP_Portal_Login_Disabled_Message';
import CSP_Invalid_Email                    from '@salesforce/label/c.CSP_Invalid_Email';
import OneId_CSP_Troubleshooting_Link       from '@salesforce/label/c.OneId_CSP_Troubleshooting_Link';
import CSP_Existing_User_Message            from '@salesforce/label/c.CSP_Existing_User_Message';
import OneId_LoginFail                      from '@salesforce/label/c.OneId_LoginFail';
import CSP_PortalPath                       from '@salesforce/label/c.CSP_PortalPath';

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
    rendered = false;

    _pageParams;
    _labels = {
        Login,
        CSP_Email,
        CSP_Password,
        CSP_Change_Email,
        CSP_Forgot_Password,
        CSP_Troubleshooting_Info,
        CSP_Troubleshooting,
        CSP_Create_New_Account_Info,
        CSP_Create_New_User_Label,
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

        this._pageParams = getParamsFromPage();

        const RegistrationUtilsJs = new RegistrationUtils();

        RegistrationUtilsJs.checkUserIsSystemAdmin().then(result=> {
            if(!result && !isGuest){
                let startUrl = this._pageParams.startURL;
                delete this._pageParams.startURL;
                navigateToPage(startUrl ? startUrl : CSP_PortalPath,this._pageParams);
            }
        });

        if(this._pageParams && this._pageParams.email){
            this.email = this._pageParams.email;
            this.isEmailFieldReadOnly = true;
            if(this._pageParams.redirect == "1"){
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
                    config.selfRegistrationUrl = result.selfRegistrationUrl.substring(result.selfRegistrationUrl.indexOf(CSP_PortalPath));
                    config.forgotPasswordUrl = result.forgotPasswordUrl.substring(result.forgotPasswordUrl.indexOf(CSP_PortalPath));
                    this.config = config;

                    this.isLoginDisabled = !config.isUsernamePasswordEnabled;
                    this.showLoginForm = config.isUsernamePasswordEnabled;
                    this.isLoading = false;
                })
                .catch(() => {
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
        if(!this.rendered){
            if(this.isEmailFieldReadOnly === true){
                this.template.querySelector('[data-id="passwordInput"]').focus();
            }
            else{
                this.template.querySelector('[data-id="emailInput"]').focus();
            }
            this.rendered = true;
        }
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


    handleEmailFocusOut(){
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

    handlePasswordFocusOut(){
        this._checkPasswordField();
    }

    handleLogin(){

        this.isLoading = true;

        const RegistrationUtilsJs = new RegistrationUtils();
        RegistrationUtilsJs.checkEmailIsValid(`${this.email}`).then(result=> {
            if(!result){
                this._showLoginError(true, this.labels.CSP_Invalid_Email, true);
                this.isLoading = false;
            }else{
                let startURL = this._pageParams.startURL;
                if(!startURL) startURL = "";
                delete this._pageParams.startURL;

                login({username: this.email, password: this.password, landingPage: startURL, params: this._pageParams}).then(r => {
                    var response = JSON.parse(JSON.stringify(r));
                    if(response.isSuccess){
                        navigateToPage(response.sessionUrl, this._pageParams);
                    }else{
                        this.isFrozen = r.userIsFrozen;
                        this.showLoginForm = !r.userIsFrozen;
                        this._showLoginError(true, response.errorMessage, false);
                        this.isLoading = false;
                    }
                })
                .catch(() => {
                    this.isLoading = false;
                });
            }
        }).catch(() => {
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
        navigateToPage(this.config.forgotPasswordUrl, this._pageParams);
    }

    handleNavigateToSelfRegister() {
        navigateToPage(this.config.selfRegistrationUrl, this._pageParams);
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