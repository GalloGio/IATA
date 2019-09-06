import { LightningElement, track, api } from 'lwc';
import { navigateToPage }     from 'c/navigationUtils';
import emailLabel             from '@salesforce/label/c.Email';
import nextLabel              from '@salesforce/label/c.PKB2_Next_Link';
import loginLabel             from '@salesforce/label/c.Login';
import invalidMailFormat      from '@salesforce/label/c.CSP_Invalid_Email';
import createNewAccountLabel  from '@salesforce/label/c.OneId_CreateNewAccount';
import errorMessageLabel      from '@salesforce/label/c.CSP_Forgot_Password_Error_Message';
import newAccountInfoLabel    from '@salesforce/label/c.CSP_Create_New_Account_Info';

export default class PortalForgotPasswordError extends LightningElement {

     @track email = "";
     @track message;
     @api loginUrl;
     @api selfRegistrationUrl;

     labels = {
         emailLabel,
         nextLabel,
         loginLabel,
         errorMessageLabel,
         createNewAccountLabel,
         newAccountInfoLabel
     }

      handleNext(){
         var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
         if(!this.email.match(regExpEmailformat)){
             this.message = invalidMailFormat;
             var emailDiv = this.template.querySelector('[data-id="emailDiv"]');
             emailDiv.classList.add('slds-has-error');
         }
         else{
             let params      = {};
             params.email    = this.email;
             navigateToPage(this.selfRegistrationUrl,params);
         }
      }

       handleEmailChange(event) {
          this.email = event.target.value;
          var submitBtn = this.template.querySelector('[data-id="submitButton"]');
          var emailDiv  = this.template.querySelector('[data-id="emailDiv"]');

          emailDiv.classList.remove('slds-has-error');
          this.message = "";

          if (this.email !== '' && this.email !== null && this.email.length > 0) {
              submitBtn.classList.remove('containedButtonDisabled');
              submitBtn.classList.add('containedButtonLogin');
              submitBtn.disabled = false;
          } else {
              submitBtn.classList.remove('containedButtonLogin');
              submitBtn.classList.add('containedButtonDisabled');
              submitBtn.disabled = true;
          }
       }

       navigateToLogin() {
          navigateToPage(this.loginUrl);
       }
}