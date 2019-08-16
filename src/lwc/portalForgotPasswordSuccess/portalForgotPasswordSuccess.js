import { LightningElement, api } from 'lwc';

import { navigateToPage }    from 'c/navigationUtils';
import createNewAccountLabel from '@salesforce/label/c.OneId_CreateNewAccount';

export default class PortalForgotPasswordSuccess extends LightningElement {
    @api selfRegistrationUrl;

    labels = {
        createNewAccountLabel
    }

    toForgotPassword() {
         const changePage = new CustomEvent('tryagain');
         this.dispatchEvent(changePage);
    }

    navigateToSelfRegister() {
        navigateToPage(this.selfRegistrationUrl);
    }

}