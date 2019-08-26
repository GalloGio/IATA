import { LightningElement, api } from 'lwc';

import { navigateToPage }    from 'c/navigationUtils';
import CSP_PortalPath        from '@salesforce/label/c.CSP_PortalPath';
import createNewAccountLabel from '@salesforce/label/c.OneId_CreateNewAccount';

export default class PortalForgotPasswordSuccess extends LightningElement {
    logoIcon = CSP_PortalPath + 'check2xGreen.png';

    @api selfRegistrationUrl;
    @api isSelfRegistrationEnabled;

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