import { LightningElement,track } from 'lwc';

import getUserAccessRequestedServices from '@salesforce/apex/PortalServicesCtrl.getUserAccessRequestedServices';

//import labels
import CSP_Services_AccessRequestedTitle from '@salesforce/label/c.CSP_Services_AccessRequestedTitle';

export default class PortalServicesAccessRequested extends LightningElement {

    label = {
        CSP_Services_AccessRequestedTitle
    };

    @track componentLoading = true;

    @track lstServicesRequested = [];
    @track viewRequestedServicesArea = false;

    connectedCallback(){

        getUserAccessRequestedServices({})
        .then(results => {
            if(results !== undefined && results.length > 0){
                this.lstServicesRequested = results;
                this.viewRequestedServicesArea = true;
            }
            this.componentLoading = false;
        });

    }
    

}