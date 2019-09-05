/**
 * Created by bkaya01 on 05/09/2019.
 */

import { LightningElement, api, track } from 'lwc';
import CSP_PortalPath       from '@salesforce/label/c.CSP_PortalPath';
import { navigateToPage }   from 'c/navigationUtils';
import ResendEmail          from '@salesforce/apex/PortalCreatePasswordController.resendEmail';

export default class PortalCreatePasswordError extends LightningElement {
        @api params;

        @track success = false;
        logoIcon       = CSP_PortalPath + 'check2xGreen.png';

        handleSendEmail() {
             ResendEmail({ paramStr : JSON.stringify(this.params) })
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