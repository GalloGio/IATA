import { LightningElement, track } from 'lwc';
import redirectToChangePasswordPage from '@salesforce/apex/PortalFirstLoginController.redirectToChangePasswordPage';

export default class PortalFirstLogin extends LightningElement {
      @track isLoading = true;

      connectedCallback() {
        var sPageURL = ''+ window.location;
         redirectToChangePasswordPage({ urlExtension : sPageURL }).then(result => {
            this.isLoading = false;
        })
        .catch(error => {
            console.log('error' + JSON.stringify(error));
        });
      }

}