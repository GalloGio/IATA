import { LightningElement,track } from 'lwc';

import getAccessRequestedServices from '@salesforce/apex/PortalServicesCtrl.getAccessRequestedServices';

//import labels
import CSP_Services_AccessRequestedTitle from '@salesforce/label/c.CSP_Services_AccessRequestedTitle';

export default class PortalServicesAccessRequested extends LightningElement {

    label = {
        CSP_Services_AccessRequestedTitle
    };

    @track lstServicesRequested = [];
    @track viewRequestedServicesArea = false;

    connectedCallback(){

        getAccessRequestedServices({})
        .then(results => {
            if(results !== undefined && results.length > 0){
                this.lstServicesRequested = results;
                this.viewRequestedServicesArea = true;
            }
        })
        .catch(error => {
            console.log('PortalServicesAccessRequested connectedCallback getAccessRequestedServices error: ' , error);
        });

    }
    

}