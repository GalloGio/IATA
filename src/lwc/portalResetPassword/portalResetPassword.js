import { LightningElement, track } from 'lwc';
import { ShowToastEvent }          from 'lightning/platformShowToastEvent';
import { navigateToPage }          from 'c/navigationUtils';
import saveLabel                   from '@salesforce/label/c.ISSP_Save';
import passwordLabel               from '@salesforce/label/c.OneId_Password'
import confirmPasswordLabel        from '@salesforce/label/c.Confirm_password';
import resetPasswordLabel          from '@salesforce/label/c.ISSP_Reset_Password';
import changePasswordInfoLabel     from '@salesforce/label/c.CSP_Reset_Password_Info_1';
import changePasswordInfo2Label    from '@salesforce/label/c.CSP_Reset_Password_Info_2';
import passwordRule1Label          from '@salesforce/label/c.CSP_Password_Rule_1';
import passwordRule2Label          from '@salesforce/label/c.CSP_Password_Rule_2';
import passwordRule3Label          from '@salesforce/label/c.CSP_Password_Rule_3';
import passwordRule4Label          from '@salesforce/label/c.CSP_Password_Rule_4';
import errorMessageLabel           from '@salesforce/label/c.CSP_Change_Password_Error';
import CSP_PortalPath              from '@salesforce/label/c.CSP_PortalPath';
import RegistrationUtils           from 'c/registrationUtils';
import { reduceErrors }            from 'c/ldsUtils';
import SetNewPassword              from '@salesforce/apex/PortalResetPasswordController.setNewPassword';
import GetUser                     from '@salesforce/apex/PortalResetPasswordController.getUser';

export default class PortalResetPassword extends LightningElement {

      @track password          = "";
      @track confirmPassword   = "";
      @track tempPassword      = "";
      @track isLoading         = true;
      @track passwordFormat    = false;
      @track buttonDisabled    = true;
      @track passwordInputType = "password";
      @track success           = false;
      @track isExpired         = false;
      @track user;

      @track isSanctioned;

      logoIcon = CSP_PortalPath + 'CSPortal/Images/Logo/group.svg';

      labels = {
          saveLabel,
          passwordLabel,
          resetPasswordLabel,
          confirmPasswordLabel,
          errorMessageLabel,
          passwordRule1Label,
          passwordRule2Label,
          passwordRule3Label,
          passwordRule4Label,
          changePasswordInfoLabel,
          changePasswordInfo2Label
      }

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
                          GetUser({ urlExtension : sPageURL }).then(result => {
                             this.isExpired = result.isExpired;
                             if(!result.user){
                                 navigateToPage(CSP_PortalPath);
                             }
                             else{
                                 this.user         = result.user;
                                 this.tempPassword = result.password;
                                 this.changeIsLoading();
                             }
                           })
                        }
                    });
                 }
             });
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

      changeIsLoading(){
          this.isLoading = !this.isLoading;
      }

      handleSavePassword(){
          this.changeIsLoading();
          if(this.buttonDisabled == false){
               SetNewPassword({ user : this.user, password : this.password }).then(result => {
                   if(result.success == true){
                      this.success = result.success;
                      this.changeIsLoading();
                   }
                   else{
                       this.message = errorMessageLabel;
                       this.showNotification();
                       this.changeIsLoading();
                   }
                })
                .catch(error => {
                   this.message = errorMessageLabel;
                   this.showNotification();
                   this.changeIsLoading();
                });
          }
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