import { LightningElement, track } from 'lwc';

import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';

import CSP_YouAndIATA from '@salesforce/label/c.CSP_YouAndIATA';

export default class PortalYouIATAPageHeader extends LightningElement {

    backgroundIcon = CSP_PortalPath + 'CSPortal/Images/Backgrounds/FAQsBackground.jpg';

    @track backgroundStyle;

    @track labels = {CSP_YouAndIATA}

    connectedCallback() {
        this.backgroundStyle = 'background-image: url("' + this.backgroundIcon + '");background-position: center;background-repeat: no-repeat;background-size: cover;height:230px;'
    }
}