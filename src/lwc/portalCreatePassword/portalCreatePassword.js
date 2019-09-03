import { LightningElement,track }   from 'lwc';
import { navigateToPage }           from 'c/navigationUtils';
import { ShowToastEvent }           from 'lightning/platformShowToastEvent';
import { reduceErrors }             from 'c/ldsUtils';
import RegistrationUtils            from 'c/registrationUtils';
import passwordLabel                from '@salesforce/label/c.OneId_Password'
import invalidMailFormat            from '@salesforce/label/c.ISSP_AMS_Invalid_Email';
import CSP_PortalPath               from '@salesforce/label/c.CSP_PortalPath';
import confirmPasswordLabel         from '@salesforce/label/c.Confirm_password';
import getParameters                from '@salesforce/apex/portalCreatePasswordController.getParameters';
import createUser                   from '@salesforce/apex/portalCreatePasswordController.createUserAndSetPassword';

export default class PortalCreatePassword extends LightningElement {
    @track email             = "";
    @track password          = "";
    @track isLoading         = true;
    @track confirmPassword   = "";
    @track passwordFormat    = false;
    @track buttonDisabled    = true;
    @track emailDisabled     = true;
    @track passwordInputType = "password";

    @track message;
    @track isSanctioned;
    @track registrationParams;

    logoIcon = CSP_PortalPath + 'CSPortal/Images/Logo/group.svg';

    labels = {
        passwordLabel,
        confirmPasswordLabel
    };

    get svgURL(){
        return CSP_PortalPath + 'show_blue.png';
    }

    get isPasswordIconDisabled(){
        return this.password.length > 0 ? false : true;
    }

    connectedCallback() {
        const RegistrationUtilsJs = new RegistrationUtils();
        RegistrationUtilsJs.getUserLocation().then(result=> {
            this.isSanctioned = result.isRestricted;
            if(this.isSanctioned == true){
                navigateToPage(CSP_PortalPath + "restricted-login");
            }
            else{
                const RegistrationUtilsJs = new RegistrationUtils();
                RegistrationUtilsJs.checkUserIsSystemAdmin().then(result=> {
                   if(result == true){
                       this.changeIsLoading();
                       return;
                   }
                   else{
                       var sPageURL = ''+ window.location;
                        getParameters({ urlExtension : sPageURL }).then(result => {
                            this.registrationParams = JSON.parse(result.registrationParameters);

                           if(result.isUserExist == true){
                               navigateToPage(CSP_PortalPath);
                           }
                           else if(this.registrationParams['email'] != ''){
                              this.email = this.registrationParams['email'];
                              this.changeIsLoading();
                           }
                       })
                   }
                });
            }
        });
    }

    handleShowPassword(){
        if(this.passwordInputType == "password"){
            this.passwordInputType = "text";
        }else{
            this.passwordInputType = "password";
        }
    }

    setButtonDisabled(){
        var submitBtn = this.template.querySelector('[data-id="submitButton"]');
        submitBtn.classList.remove('containedButtonLogin');
        submitBtn.classList.add('containedButtonDisabled');
        this.buttonDisabled = true;
    }

    checkButtonVisibility(){
         var submitBtn        = this.template.querySelector('[data-id="submitButton"]');
         var confirmPassword  = this.template.querySelector('[data-id="confirmPasswordDiv"]');
         if(this.password.length > 0 && this.confirmPassword.length > 0 && this.confirmPassword == this.password && this.passwordFormat == true){
                    submitBtn.classList.remove('containedButtonDisabled');
                    submitBtn.classList.add('containedButtonLogin');
                    this.buttonDisabled = false;
                    confirmPassword.classList.remove('slds-has-error');
                }
                else if(this.password.length > 0 && this.confirmPassword.length > 0 && this.confirmPassword != this.password){
                    confirmPassword.classList.add('slds-has-error');
                }
                else{
                    this.setButtonDisabled();
                    confirmPassword.classList.remove('slds-has-error');
         }
    }

    handleConfirmPasswordChange(event){
        this.setButtonDisabled();
        this.confirmPassword = event.target.value;
        this.checkButtonVisibility();
    }

    handlePasswordChange(event){
        this.setButtonDisabled();
        this.password = event.target.value;
        if(this.password.length > 0){
            this.template.querySelector('[data-id="passwordIcon"]').classList.remove('showPasswordIconDisabled');
        }else{
            this.template.querySelector('[data-id="passwordIcon"]').classList.add('showPasswordIconDisabled');
        }

        if (this.password.length >= 10){
            this.template.querySelector('[data-id="chars"]').classList.add("checked");
            this.template.querySelector('[data-id="checkCircleInputChars"]').checked = true;
        } else {
            this.template.querySelector('[data-id="chars"]').classList.remove("checked");
            this.template.querySelector('[data-id="checkCircleInputChars"]').checked = false;
        }

        if (/[A-Z]/.test(this.password)) {
            this.template.querySelector('[data-id="letter"]').classList.add("checked");
            this.template.querySelector('[data-id="checkCircleInputLetter"]').checked = true;
        } else {
            this.template.querySelector('[data-id="letter"]').classList.remove("checked");
            this.template.querySelector('[data-id="checkCircleInputLetter"]').checked = false;
        }

        if (/\d/.test(this.password)) {
            this.template.querySelector('[data-id="number"]').classList.add("checked");
            this.template.querySelector('[data-id="checkCircleInputNumber"]').checked = true;
        } else {
            this.template.querySelector('[data-id="number"]').classList.remove("checked");
            this.template.querySelector('[data-id="checkCircleInputNumber"]').checked = false;
        }

        if (/[\W_]/.test(this.password)) {
            this.template.querySelector('[data-id="symbol"]').classList.add("checked");
            this.template.querySelector('[data-id="checkCircleInputSymbol"]').checked = true;
        } else {
            this.template.querySelector('[data-id="symbol"]').classList.remove("checked");
            this.template.querySelector('[data-id="checkCircleInputSymbol"]').checked = false;
        }

        if(this.password.length >= 10 && /[A-Z]/.test(this.password) && /\d/.test(this.password) && /[\W_]/.test(this.password)) {
            this.passwordFormat = true;
        } else {
            this.passwordFormat = false;
        }

        this.checkButtonVisibility();
    }

    handlePasswordFocusOut(event){
        if(this.password.length > 0){
            this.template.querySelector('[data-id="passwordInput"]').classList.add('inputBackgroundGrey');
        }else{
            this.template.querySelector('[data-id="passwordInput"]').classList.remove('inputBackgroundGrey');
        }
    }

    handleConfirmPasswordFocusOut(event){
        if(this.password.length > 0){
            this.template.querySelector('[data-id="confirmPasswordInput"]').classList.add('inputBackgroundGrey');
        }else{
            this.template.querySelector('[data-id="confirmPasswordInput"]').classList.remove('inputBackgroundGrey');
        }
    }

    handleConfirmPasswordFocusIn(event){
        this.template.querySelector('[data-id="confirmPasswordInput"]').classList.remove('inputBackgroundGrey');
    }

    handlePasswordFocusIn(event){
        this.template.querySelector('[data-id="passwordInput"]').classList.remove('inputBackgroundGrey');
    }

    handleSavePassword(){
        this.changeIsLoading();
        if(this.buttonDisabled == false){
            createUser({ paramStr : JSON.stringify(this.registrationParams), password : this.password }).then(result => {
                 if(result.isSuccess == true){
                    navigateToPage(result.message, {});
                 }
                 else{
                    this.message = result.message;
                    this.showNotification();
                 }
             })
              .catch(error => {
                 this.message = reduceErrors(error).join(', ');
                 this.showNotification();
              });
        }
    }


    changeIsLoading(){
        this.isLoading = !this.isLoading;
    }

    showNotification() {
        const evt = new ShowToastEvent({
            title: 'Error',
            message: this.message,
            variant: 'error',
        });
        this.dispatchEvent(evt);
    }

}