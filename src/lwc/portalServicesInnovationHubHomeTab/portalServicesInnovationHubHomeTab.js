import { LightningElement,track } from 'lwc';

//import apex methods
import getInnovationHubServiceDetails from '@salesforce/apex/PortalServicesInnovationHubCtrl.getInnovationHubServiceDetails';

export default class PortalServicesInnovationHubHomeTab extends LightningElement {

    @track componentLoading = true;
    @track serviceRecord = {};
    
    connectedCallback(){

        getInnovationHubServiceDetails({})
        .then(result => {
            this.serviceRecord = JSON.parse(JSON.stringify(result));
            this.componentLoading = false;
        });
    
    }

}