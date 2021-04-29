import { LightningElement, track } from 'lwc';
import { getPageName }    from 'c/navigationUtils';

//import labels
import CSP_Service_StartupHotlist_Title from '@salesforce/label/c.CSP_Service_StartupHotlist_Title';
import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';

export default class PortalServicesStartupHotlistPageHeader extends LightningElement {
    @track labels = { 
        CSP_Service_StartupHotlist_Title
    };
    backgroundIcon = CSP_PortalPath + 'CSPortal/Images/Backgrounds/ServiceStartupHotlistBackground.jpg';
    @track imageInfo = '';

    connectedCallback() {
        this.imageInfo = 'background-image: url("' + this.backgroundIcon + '");'
    }
}