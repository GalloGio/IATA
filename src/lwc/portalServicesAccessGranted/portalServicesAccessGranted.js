import { LightningElement,track } from 'lwc';

import getAccessGrantedServices from '@salesforce/apex/PortalServicesCtrl.getAccessGrantedServices';

export default class PortalServicesAccessGranted extends LightningElement {

    @track lstServicesGranted = [];

    connectedCallback(){

        getAccessGrantedServices({})
        .then(results => {
            this.lstServicesGranted = results;
        })
        .catch(error => {
            console.log('PortalServicesAccessGranted connectedCallback getAccessGrantedServices error: ' , error);
        });

    }
    

}