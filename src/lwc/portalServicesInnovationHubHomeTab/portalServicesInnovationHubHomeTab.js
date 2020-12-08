import { LightningElement,track } from 'lwc';

//import apex methods
import getPortalServiceDetails from '@salesforce/apex/PortalServicesCtrl.getPortalServiceDetails';

export default class PortalServicesInnovationHubHomeTab extends LightningElement {

    @track componentLoading = true;
    @track serviceRecord = {};
    
    connectedCallback(){

        getPortalServiceDetails({"serviceName" : "Innovation Hub"})
        .then(result => {
            this.serviceRecord = JSON.parse(JSON.stringify(result));
            this.componentLoading = false;
        });
    
    }

}