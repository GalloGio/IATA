/**
 * Created by bkaya01 on 28/08/2019.
 */

import { LightningElement } from 'lwc';
import { navigateToPage }   from 'c/navigationUtils';
import CSP_PortalPath       from '@salesforce/label/c.CSP_PortalPath';
import successLabel         from '@salesforce/label/c.CSP_Success';
import loginNowLabel        from '@salesforce/label/c.CSP_Login_Now';
import message1Label        from '@salesforce/label/c.CSP_Reset_Password_Success_Msg_1';
import message2Label        from '@salesforce/label/c.CSP_Reset_Password_Success_Msg_2';

export default class PortalResetPasswordSuccess extends LightningElement {
    successIcon = CSP_PortalPath + 'CSPortal/Images/Icons/success.png';

    labels = {
        successLabel,
        loginNowLabel,
        message1Label,
        message2Label
    }

    handleLogin(){
       navigateToPage(CSP_PortalPath);
    }
}