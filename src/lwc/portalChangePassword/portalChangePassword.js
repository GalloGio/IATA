import { LightningElement, track } from 'lwc';
import { navigateToPage }       from 'c/navigationUtils';
import { ShowToastEvent }       from 'lightning/platformShowToastEvent';
import CSP_PortalPath           from '@salesforce/label/c.CSP_PortalPath';
import ChangePassword           from '@salesforce/apex/PortalPasswordHandler.changePassword';
import confirmPasswordLabel     from '@salesforce/label/c.Confirm_password';
import newPasswordLabel         from '@salesforce/label/c.New_password';
import currentPasswordLabel     from '@salesforce/label/c.Current_password';
import saveLabel                from '@salesforce/label/c.CSP_Save';
import changePasswordLabel      from '@salesforce/label/c.CSP_Change_Password';
import changePasswordInfoLabel  from '@salesforce/label/c.CSP_Change_Password_Info_1';
import changePasswordInfo2Label from '@salesforce/label/c.CSP_Change_Password_Info_2';
import passwordRule1Label       from '@salesforce/label/c.CSP_Password_Rule_1';
import passwordRule2Label       from '@salesforce/label/c.CSP_Password_Rule_2';
import passwordRule3Label       from '@salesforce/label/c.CSP_Password_Rule_3';
import passwordRule4Label       from '@salesforce/label/c.CSP_Password_Rule_4';
import errorMessageLabel        from '@salesforce/label/c.CSP_Change_Password_Error';


export default class PortalChangePassword extends LightningElement {
    @track isLoading         = false;
    @track currentPassword   = "";
    @track newPassword       = "";
    @track confirmPassword   = "";
    @track showErrorMessage  = false;
    @track passwordFormat           = false;
    @track buttonDisabled           = true;
    @track currentPasswordInputType = "password";
    @track newPasswordInputType     = "password";

    cancelIcon      = CSP_PortalPath + 'CSPortal/Images/Icons/cancel_white.svg';
    exclamationIcon = CSP_PortalPath + 'CSPortal/Images/Icons/exclamation_mark_white.svg';

    labels = {
        saveLabel,
        newPasswordLabel,
        errorMessageLabel,
        passwordRule1Label,
        passwordRule2Label,
        passwordRule3Label,
        passwordRule4Label,
        changePasswordLabel,
        confirmPasswordLabel,
        currentPasswordLabel,
        changePasswordInfoLabel,
        changePasswordInfo2Label
    }

    get svgURL(){
        return CSP_PortalPath + 'CSPortal/Images/Icons/show_blue.png';
    }

    get isCurrentPasswordIconDisabled(){
        return this.currentPassword.length > 0 ? false : true;
    }

    get isNewPasswordIconDisabled(){
        return this.newPassword.length > 0 ? false : true;
    }

    handleShowCurrentPassword(){
        if(this.currentPasswordInputType == "password"){
            this.currentPasswordInputType = "text";
        }else{
            this.currentPasswordInputType = "password";
        }
    }

    handleShowNewPassword(){
        if(this.newPasswordInputType == "password"){
            this.newPasswordInputType = "text";
        }else{
            this.newPasswordInputType = "password";
        }
    }

    handleCurrentPasswordChange(event){
        this.setButtonDisabled();
        this.currentPassword = event.target.value;
        if(this.currentPassword.length > 0){
           this.template.querySelector('[data-id="currentPasswordIcon"]').classList.remove('showPasswordIconDisabled');
        }else{
           this.template.querySelector('[data-id="currentPasswordIcon"]').classList.add('showPasswordIconDisabled');
        }
        this.checkButtonVisibility();
    }

    handleNewPasswordChange(event){
         this.setButtonDisabled();
         this.newPassword = event.target.value;
         if(this.newPassword.length > 0){
            this.template.querySelector('[data-id="newPasswordIcon"]').classList.remove('showPasswordIconDisabled');
         }else{
            this.template.querySelector('[data-id="newPasswordIcon"]').classList.add('showPasswordIconDisabled');
         }

         if (this.newPassword.length >= 10){
             this.template.querySelector('[data-id="chars"]').classList.add("checked");
             this.template.querySelector('[data-id="checkCircleInputChars"]').checked = true;
         } else {
             this.template.querySelector('[data-id="chars"]').classList.remove("checked");
             this.template.querySelector('[data-id="checkCircleInputChars"]').checked = false;
         }

         if (/[A-Z]/.test(this.newPassword)) {
             this.template.querySelector('[data-id="letter"]').classList.add("checked");
             this.template.querySelector('[data-id="checkCircleInputLetter"]').checked = true;
         } else {
             this.template.querySelector('[data-id="letter"]').classList.remove("checked");
             this.template.querySelector('[data-id="checkCircleInputLetter"]').checked = false;
         }

         if (/\d/.test(this.newPassword)) {
             this.template.querySelector('[data-id="number"]').classList.add("checked");
             this.template.querySelector('[data-id="checkCircleInputNumber"]').checked = true;
         } else {
             this.template.querySelector('[data-id="number"]').classList.remove("checked");
             this.template.querySelector('[data-id="checkCircleInputNumber"]').checked = false;
         }

         if (/[\W_]/.test(this.newPassword)) {
             this.template.querySelector('[data-id="symbol"]').classList.add("checked");
             this.template.querySelector('[data-id="checkCircleInputSymbol"]').checked = true;
         } else {
             this.template.querySelector('[data-id="symbol"]').classList.remove("checked");
             this.template.querySelector('[data-id="checkCircleInputSymbol"]').checked = false;
         }

         if(this.newPassword.length >= 10 && /[A-Z]/.test(this.newPassword) && /\d/.test(this.newPassword) && /[\W_]/.test(this.newPassword)) {
             this.passwordFormat = true;
         } else {
             this.passwordFormat = false;
         }

         this.checkButtonVisibility();
    }

    handleConfirmPasswordChange(event){
        this.setButtonDisabled();
        this.confirmPassword = event.target.value;
        this.checkButtonVisibility();
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
         if(this.newPassword.length > 0              && this.confirmPassword.length > 0 && this.currentPassword.length > 0 &&
            this.confirmPassword == this.newPassword && this.passwordFormat == true){
            submitBtn.classList.remove('containedButtonDisabled');
            submitBtn.classList.add('containedButtonLogin');
            this.buttonDisabled = false;
            confirmPassword.classList.remove('slds-has-error');
         }
         else if(this.newPassword.length > 0 && this.confirmPassword.length > 0 && this.confirmPassword != this.newPassword){
            confirmPassword.classList.add('slds-has-error');
         }
         else{
            this.setButtonDisabled();
            confirmPassword.classList.remove('slds-has-error');
         }
    }

    handleSavePassword(){
        this.changeIsLoading();
        if(this.buttonDisabled == false){
             ChangePassword({ currentPassword : this.currentPassword, newPassword : this.newPassword, confirmPassword : this.confirmPassword }).then(result => {
                             if(result.success == true){
                                 navigateToPage("/secur/logout.jsp?retUrl=" + CSP_PortalPath + "changePasswordSuccess");
                             }
                             else{
                                 this.message = errorMessageLabel;
                                 this.showErrorMessage = true;
                                 this.changeIsLoading();
                             }
                           })
                           .catch(error => {
                               this.message = errorMessageLabel;
                               this.showErrorMessage = true;
                               this.changeIsLoading();
                           });
        }
    }

    handleFormKeyPress(event) {
        if(event.keyCode === 13){
             if(this.buttonDisabled == false){
                 this.handleSavePassword();
             }
         }
    }

    changeIsLoading(){
        this.isLoading = !this.isLoading;
    }

    handleSnackbarCancel() {
        this.showErrorMessage = false;
    }
}