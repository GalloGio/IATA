import { LightningElement, api, track } from 'lwc';

import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';

export default class PortalHighlightCard extends LightningElement {

    @api type;
    @api highlight;

    @track backgroundStyle;

    path = CSP_PortalPath;

    connectedCallback() {}

    goToLink() {
        window.location.href = this.highlight.informationButtonLink;
    }

    goToAction() {
        window.location.href = this.highlight.actionButtonLink;
    }

}