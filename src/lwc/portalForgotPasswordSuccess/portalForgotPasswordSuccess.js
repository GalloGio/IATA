import { LightningElement, api } from 'lwc';

import { navigateToPage }     from 'c/navigationUtils';
import CSP_PortalPath         from '@salesforce/label/c.CSP_PortalPath';
import successLabel           from '@salesforce/label/c.CSP_Success';
import createNewAccountLabel  from '@salesforce/label/c.CSP_Create_New_Account_Info';
import successMessageLabel    from '@salesforce/label/c.CSP_Forgot_Password_Success_Message';
import retryTitleLabel        from '@salesforce/label/c.CSP_Forgot_Password_Retry_Title';
import retryMessageLabel      from '@salesforce/label/c.CSP_Forgot_Password_Retry_Message';
import tryAgainLabel          from '@salesforce/label/c.CSP_Try_Again';
import newAccountMessageLabel from '@salesforce/label/c.CSP_Create_New_Account_Label';

export default class PortalForgotPasswordSuccess extends LightningElement {
    logoIcon = CSP_PortalPath + 'check2xGreen.png';

    @api selfRegistrationUrl;
    @api isSelfRegistrationEnabled;

    labels = {
        successLabel,
        tryAgainLabel,
        retryTitleLabel,
        retryMessageLabel,
        successMessageLabel,
        createNewAccountLabel,
        newAccountMessageLabel
    }

    toForgotPassword() {
         const changePage = new CustomEvent('tryagain');
         this.dispatchEvent(changePage);
    }

    navigateToSelfRegister() {
        navigateToPage(this.selfRegistrationUrl);
    }

}