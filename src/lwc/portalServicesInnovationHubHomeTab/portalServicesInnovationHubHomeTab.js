import { LightningElement, track } from 'lwc';

//import labels
import CSP_Service_InnovationHub_NoAccess from '@salesforce/label/c.CSP_Service_InnovationHub_NoAccess';

export default class PortalServicesInnovationHubHomeTab extends LightningElement {

    @track labels = {
        CSP_Service_InnovationHub_NoAccess
    }
    @track componentLoading = true;

    connectedCallback(){
        this.componentLoading = false;
    }
}