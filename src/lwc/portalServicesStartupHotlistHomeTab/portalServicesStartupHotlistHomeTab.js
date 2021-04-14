import { LightningElement, track } from 'lwc';

//import labels
import CSP_Service_StartupHotlist_NoAccess from '@salesforce/label/c.CSP_Service_StartupHotlist_NoAccess';

export default class PortalServicesStartupHotlistHomeTab extends LightningElement {

    @track labels = {
        CSP_Service_StartupHotlist_NoAccess
    }
    @track componentLoading = true;

    connectedCallback(){
        this.componentLoading = false;
    }
}