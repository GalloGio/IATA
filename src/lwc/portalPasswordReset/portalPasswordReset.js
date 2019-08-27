import { LightningElement, track } from 'lwc';
import RegistrationUtils           from 'c/registrationUtils';
import { navigateToPage }          from 'c/navigationUtils';
import CSP_PortalPath              from '@salesforce/label/c.CSP_PortalPath';
import redirectToResetPasswordPage from '@salesforce/apex/PortalPasswordResetController.redirectToResetPasswordPage';

export default class PortalFirstLogin extends LightningElement {
      @track isSanctioned;
      @track isLoading = true;

      connectedCallback() {
            var sPageURL = ''+ window.location;
           redirectToResetPasswordPage({ urlExtension : sPageURL }).then(result => {
            this.isLoading = false;
           })
           .catch(error => {
            console.log('error' + JSON.stringify(error));
           });
      }

}