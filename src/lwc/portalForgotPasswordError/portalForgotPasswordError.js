import { LightningElement, track, api } from 'lwc';
import { navigateToPage }    from 'c/navigationUtils';
import nextLabel             from '@salesforce/label/c.PKB2_Next_Link';
import loginLabel            from '@salesforce/label/c.Login';
import invalidMailFormat     from '@salesforce/label/c.ISSP_AMS_Invalid_Email';
import createNewAccountLabel from '@salesforce/label/c.OneId_CreateNewAccount';

export default class PortalForgotPasswordError extends LightningElement {

     @track email = "";
     @track message;
     @api loginUrl;
     @api selfRegistrationUrl;

     labels = {
         nextLabel,
         loginLabel,
         createNewAccountLabel
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
          this.template.querySelector('[data-id="emailInput"]').classList.remove('inputBackgroundGrey');

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

       handleEmailFocusOut(event){
          if(this.email.length > 0){
               this.template.querySelector('[data-id="emailInput"]').classList.add('inputBackgroundGrey');
          }else{
               this.template.querySelector('[data-id="emailInput"]').classList.remove('inputBackgroundGrey');
          }
       }

       navigateToLogin() {
          navigateToPage(this.loginUrl);
       }
}