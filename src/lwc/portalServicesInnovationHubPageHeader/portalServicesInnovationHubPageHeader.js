import { LightningElement, track } from 'lwc';
import { getPageName }    from 'c/navigationUtils';

//import labels
import CSP_Service_InnovationHub_Title from '@salesforce/label/c.CSP_Service_InnovationHub_Title';
import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';

export default class PortalServicesInnovationHubPageHeader extends LightningElement {
    @track labels = { 
        CSP_Service_InnovationHub_Title
    };
    backgroundIcon = CSP_PortalPath + 'CSPortal/Images/Backgrounds/ServiceInnovationHubBackground.jpg';
    @track imageInfo = '';

    connectedCallback() {
        this.imageInfo = 'background-image: url("' + this.backgroundIcon + '");'
    }
}