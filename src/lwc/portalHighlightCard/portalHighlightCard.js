import { LightningElement, api, track } from 'lwc';

import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';

import getBaseURL from '@salesforce/apex/PortalRecommendationCtrl.getBaseURL';

export default class PortalHighlightCard extends LightningElement {

    @api type;
    @api highlight;

    @track backgroundStyle;

    path = CSP_PortalPath;

    connectedCallback() {}

    goToLink() {
        if (this.highlight.actionType === 'PRODUCT') {
            getBaseURL().then(result => {
                window.location.href = result + this.highlight.informationButtonLink;
            });
        } else {
            window.location.href = this.highlight.informationButtonLink;
        }

    }

    goToAction() {
        if (this.highlight.actionType === 'PRODUCT') {
            getBaseURL().then(result => {
                window.location.href = result + this.highlight.actionButtonLink;
            });
        } else {
            window.location.href = this.highlight.actionButtonLink;
        }

    }

}