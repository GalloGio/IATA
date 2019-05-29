import { LightningElement,track } from 'lwc';

import getUserAvailableServices from '@salesforce/apex/PortalServicesCtrl.getUserAvailableServices';

export default class PortalServicesAvailableServicesList extends LightningElement {

    @track componentLoading = true;

    @track lstServicesGranted = [];

    connectedCallback(){

        getUserAvailableServices({})
        .then(results => {
            this.lstServicesGranted = results;
            this.componentLoading = false;
            //console.log('getAvailableServices: ', results);
        });

    }
    

}