import { LightningElement, track } from 'lwc';

//import labels
import CSP_Service_TIPReports_Title from '@salesforce/label/c.CSP_Service_TIPReports_Title';
import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';

export default class PortalServicesTIPReportsPageHeader extends LightningElement {
    label = { 
        CSP_Service_TIPReports_Title
    };
    backgroundIcon = CSP_PortalPath + 'CSPortal/Images/Backgrounds/CasesBackground.jpg';
    @track imageInfo = '';

    connectedCallback() {
        this.imageInfo = 'background-image: url("' + this.backgroundIcon + '");'
    }
}