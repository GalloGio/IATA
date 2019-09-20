/**
 * Created by bkaya01 on 03/09/2019.
 */

import { LightningElement } from 'lwc';
import { navigateToPage }   from 'c/navigationUtils';
import CSP_PortalPath       from '@salesforce/label/c.CSP_PortalPath';
import successMsg1Label     from '@salesforce/label/c.CSP_Chg_Pass_Success_Msg_1';
import successMsg2Label     from '@salesforce/label/c.CSP_Chg_Pass_Success_Msg_2';
import loginNowLabel        from '@salesforce/label/c.CSP_Login_Now';

export default class PortalChangePasswordSuccess extends LightningElement {
    logoIcon  = CSP_PortalPath + 'check2xGreen.png';
    logoIcon2 = CSP_PortalPath + 'CSPortal/Images/Logo/group.svg';

    labels = {
        loginNowLabel,
        successMsg1Label,
        successMsg2Label
    }

    connectedCallback() {
       window.setTimeout(function(){
           navigateToPage(CSP_PortalPath);
        }, 10000);
    }

    handleLogin(){
       navigateToPage(CSP_PortalPath);
    }
}