/**
 * Created by bkaya01 on 03/09/2019.
 */

import { LightningElement } from 'lwc';
import { navigateToPage }   from 'c/navigationUtils';
import CSP_PortalPath       from '@salesforce/label/c.CSP_PortalPath';

export default class PortalChangePasswordSuccess extends LightningElement {
    logoIcon = CSP_PortalPath + 'check2xGreen.png';

    connectedCallback() {
       window.setTimeout(function(){
           navigateToPage(CSP_PortalPath);
        }, 10000);
    }

    handleLogin(){
       navigateToPage(CSP_PortalPath);
    }
}