import { LightningElement,track } from 'lwc';

import getUserAccessGrantedServices from '@salesforce/apex/PortalServicesCtrl.getUserAccessGrantedServices';

export default class PortalServicesAccessGranted extends LightningElement {

    @track componentLoading = true;

    @track lstServicesGranted = [];

    connectedCallback(){

        getUserAccessGrantedServices({})
        .then(results => {
            this.lstServicesGranted = results;
            this.componentLoading = false;
            //console.log('PortalServicesAccessGranted connectedCallback getUserAccessGrantedServices: ' , results);
        });

    }
    

}