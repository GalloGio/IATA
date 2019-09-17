/**
 * Created by bkaya01 on 05/09/2019.
 */

import { LightningElement, api, track } from 'lwc';
import CSP_PortalPath       from '@salesforce/label/c.CSP_PortalPath';
import { navigateToPage }   from 'c/navigationUtils';
import ResendEmail          from '@salesforce/apex/PortalCreatePasswordController.resendEmail';
import successLabel         from '@salesforce/label/c.CSP_Success';
import errorMessage1Label   from '@salesforce/label/c.CSP_Expired_Link_Msg_1';
import errorMessage2Label   from '@salesforce/label/c.CSP_Expired_Link_Msg_2';
import sendEmailLabel       from '@salesforce/label/c.PKB2_send_mail';
import loginNowLabel        from '@salesforce/label/c.CSP_Resend_Verification_Email';
import successMessageLabel  from '@salesforce/label/c.CSP_Expired_Email_Success_Msg';

export default class PortalCreatePasswordError extends LightningElement {
        @api params;

        @track success = false;
        logoIcon       = CSP_PortalPath + 'check2xGreen.png';

        labels = {
            successLabel,
            loginNowLabel,
            sendEmailLabel,
            errorMessage1Label,
            errorMessage2Label,
            successMessageLabel
        }

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