import { LightningElement, track } from 'lwc';

import CSP_Cases from '@salesforce/label/c.CSP_Cases';

import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';


export default class PortalCasesListPageHeader extends LightningElement {
    @track label = { CSP_Cases };
    backgroundIcon = CSP_PortalPath + 'CSPortal/Images/Backgrounds/CasesBackground.jpg';
    @track imageInfo;

    connectedCallback() {
        this.imageInfo = 'background-image: url("' + this.backgroundIcon + '");background-position: center;background-repeat: no-repeat;background-size: cover;height:185px;'
    }
}
