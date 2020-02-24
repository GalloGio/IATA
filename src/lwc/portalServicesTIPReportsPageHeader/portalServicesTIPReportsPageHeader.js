import { LightningElement, track } from 'lwc';

//import labels
import CSP_Service_TIPReports_Title from '@salesforce/label/c.CSP_Service_TIPReports_Title';
import CSP_Service_TIPReports_Subtitle from '@salesforce/label/c.CSP_Service_TIPReports_Subtitle';
import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';

export default class PortalServicesTIPReportsPageHeader extends LightningElement {
    label = { 
        CSP_Service_TIPReports_Title,
        CSP_Service_TIPReports_Subtitle
    };
    backgroundIcon = CSP_PortalPath + 'CSPortal/Images/Backgrounds/CasesBackground.jpg';
    @track imageInfo = '';

    connectedCallback() {
        this.imageInfo = 'background-image: url("' + this.backgroundIcon + '");background-position: center;background-repeat: no-repeat;background-size: cover;height:185px;'
    }
}