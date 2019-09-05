/**
 * Created by bkaya01 on 05/09/2019.
 */

import { LightningElement, api, track } from 'lwc';
import CSP_PortalPath     from '@salesforce/label/c.CSP_PortalPath';
import { navigateToPage } from 'c/navigationUtils';
import ResendEmail        from '@salesforce/apex/PortalResetPasswordController.resendEmail';

export default class PortalResetPasswordError extends LightningElement {

    @api user;
    @api password;
    @track success = false;
    logoIcon = CSP_PortalPath + 'check2xGreen.png';

    handleSendEmail() {
         ResendEmail({ userInfo : JSON.stringify(this.user), password : this.password })
         .then(result => {
            this.success = result;
         })
         .catch(error => {
            this.success = false;
         });
    }

    handleLogin() {
        navigateToPage(CSP_PortalPath);
    }
}