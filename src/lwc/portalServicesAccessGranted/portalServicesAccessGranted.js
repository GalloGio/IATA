import { LightningElement,track } from 'lwc';

import getAccessGrantedServices from '@salesforce/apex/PortalServicesCtrl.getAccessGrantedServices';

export default class PortalServicesAccessGranted extends LightningElement {

    @track lstServicesGranted = [];

    connectedCallback(){

        getAccessGrantedServices({})
        .then(results => {
            this.lstServicesGranted = results;
            console.log('results: ' , results);
        })
        .catch(error => {
            console.log('error: ' , error);
        });

    }
    

}