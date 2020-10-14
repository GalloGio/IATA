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
		@api pageParams; //this is not fetched from the URL because the parent component already handled the params

        @track success = false;
        successIcon = CSP_PortalPath + 'CSPortal/Images/Icons/success.png';

        labels = {
            successLabel,
            loginNowLabel,
            sendEmailLabel,
            errorMessage1Label,
            errorMessage2Label,
            successMessageLabel
        }

        handleSendEmail() {
            ResendEmail({ paramStr : JSON.stringify(this.params), urlParam : this.pageParams })
            .then(result => {
                this.success = result;
            })
            .catch(() => {
                this.success = false;
            });
        }

        handleLogin() {
            navigateToPage(CSP_PortalPath, this.pageParams);
        }
}