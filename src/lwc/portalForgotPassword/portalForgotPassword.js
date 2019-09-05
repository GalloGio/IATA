import { LightningElement, track, api } from 'lwc';
import { navigateToPage }      from 'c/navigationUtils';
import handleResetPassword     from '@salesforce/apex/PortalForgotPasswordController.handleResetPassword';
import invalidMailFormat       from '@salesforce/label/c.ISSP_AMS_Invalid_Email';
import loginLabel              from '@salesforce/label/c.Login';
import submitLabel             from '@salesforce/label/c.ISSP_Submit';
import createNewAccountLabel   from '@salesforce/label/c.OneId_CreateNewAccount';
import troubleshootingLabel    from '@salesforce/label/c.OneId_CSP_Troubleshooting';
import troubleshootingUrl      from '@salesforce/label/c.OneId_CSP_Troubleshooting_Link';

export default class ForgotPasswordOneId extends LightningElement {
    @track email           = "";
    @track buttonDisabled  = true;
    @track isLoading       = false;
    @track message;
    @api loginUrl;
    @api selfRegistrationUrl;
    @api isSelfRegistrationEnabled;

    labels = {
        loginLabel,
        submitLabel,
        createNewAccountLabel,
        troubleshootingLabel
    };

    handleSubmit(){
        //check email format
        var regExpEmailformat = /^(([^<>()\[\]\\.,;:\s@"]+(\.[^<>()\[\]\\.,;:\s@"]+)*)|(".+"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$/;
        if(!this.email.match(regExpEmailformat)){
            this.message = invalidMailFormat;
            var emailDiv = this.template.querySelector('[data-id="emailDiv"]');
            emailDiv.classList.add('slds-has-error');
         }
         else{
            this.isLoading = true;
            handleResetPassword({ email : this.email }).then(result => {
                if(result.success != true){
                    this.dispatchSubmitEvent(false);
                }
                else{
                  this.dispatchSubmitEvent(true);
                }
            });
         }
    }

    dispatchSubmitEvent(isSuccess){
         const submitEvent = new CustomEvent('submit', { detail: isSuccess });
         this.dispatchEvent(submitEvent);
    }

    handleEmailChange(event) {
        this.email = event.target.value;
        var submitBtn = this.template.querySelector('[data-id="submitButton"]');
        var emailDiv  = this.template.querySelector('[data-id="emailDiv"]');
        emailDiv.classList.remove('slds-has-error');

        //set button visibility
        this.message = "";
        if (this.email !== '' && this.email !== null && this.email.length > 0) {
            submitBtn.classList.remove('containedButtonDisabled');
            submitBtn.classList.add('containedButtonLogin');
            this.buttonDisabled = false;
        } else {
            submitBtn.classList.remove('containedButtonLogin');
            submitBtn.classList.add('containedButtonDisabled');
            this.buttonDisabled = true;
        }
    }

    navigateToLogin() {
        navigateToPage(this.loginUrl);
    }

    navigateToSelfRegister() {
        navigateToPage(this.selfRegistrationUrl);
    }

    handleNavigateToTroubleshooting() {
        navigateToPage(troubleshootingUrl);
    }

}