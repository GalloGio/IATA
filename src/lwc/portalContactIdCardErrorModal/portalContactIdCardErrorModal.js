import { LightningElement, track } from 'lwc';

import message        from '@salesforce/label/c.CSP_Contact_Id_Card_Error_Msg';
import cancelLabel    from '@salesforce/label/c.Cancel';
import reachUsLAbel   from '@salesforce/label/c.CSP_FAQReachUsBanner_ButtonText';
import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';

export default class PortalContactIdCardErrorModal extends LightningElement {

    labels = {
        message,
        cancelLabel,
        reachUsLAbel
    }

    redirectToSupport(event) {
         window.location.href = CSP_PortalPath + "support-reach-us?category=Travel&topic=ID_Card_Print_Digital&subtopic=Update_Account_Details_ID_Card_Print_Digital";
    }

    handleCancel(event){
        this.dispatchEvent(new CustomEvent('closeidcarderrorpopup'));
    }

}