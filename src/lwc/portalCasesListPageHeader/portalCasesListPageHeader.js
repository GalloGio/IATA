import { LightningElement, track } from 'lwc';
import CSP_Cases from '@salesforce/label/c.CSP_Cases';

export default class PortalCasesListPageHeader extends LightningElement {
    @track label = { CSP_Cases };
    backgroundIcon = '/csportal/s/CSPortal/Images/Backgrounds/ControlTower.jpg';
    @track imageInfo;

    connectedCallback() {
        this.imageInfo = 'background-image: url("' + this.backgroundIcon + '");background-position: center;background-repeat: no-repeat;background-size: cover;height:185px;'
    }
}