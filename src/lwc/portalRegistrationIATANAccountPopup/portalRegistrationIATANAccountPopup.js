/**
 * Created by bkaya01 on 20/11/2019.
 */

import { LightningElement } from 'lwc';

import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';
import close from '@salesforce/label/c.CSP_Close';
import goToWebstar from '@salesforce/label/c.CSP_Go_to_Webstar';
import message from '@salesforce/label/c.CSP_IATAN_Register_Info';

export default class PortalRegistrationIatanAccountPopup extends LightningElement {

    alertIcon = CSP_PortalPath + 'CSPortal/alertIcon.png';

    labels = {
        close,
        goToWebstar,
        message
    }

    handleCloseModal(){
        this.dispatchEvent(new CustomEvent('closepopup'));
    }

    handleGoToWebstar(){
        window.location.href = 'https://webstar.iatan.org/WebStarExtranetWEB/login.jsp?token=void';
    }


}