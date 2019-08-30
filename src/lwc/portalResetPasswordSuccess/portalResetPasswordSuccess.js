/**
 * Created by bkaya01 on 28/08/2019.
 */

import { LightningElement } from 'lwc';
import { navigateToPage }   from 'c/navigationUtils';
import CSP_PortalPath       from '@salesforce/label/c.CSP_PortalPath';

export default class PortalResetPasswordSuccess extends LightningElement {
    logoIcon = CSP_PortalPath + 'check2xGreen.png';

    handleLogin(){
       navigateToPage(CSP_PortalPath);
    }
}