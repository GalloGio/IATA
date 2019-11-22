import { LightningElement, track, wire } from 'lwc';

import getUserAvailableServices from '@salesforce/apex/PortalServicesCtrl.getUserAvailableServices';
import getRecommendations from '@salesforce/apex/PortalRecommendationCtrl.getRecommendations';
import { refreshApex } from '@salesforce/apex';

export default class PortalServicesAvailableServicesList extends LightningElement {

    @track componentLoading = true;

    @track lstServicesGranted = [];
    @track highlightList;
    @track specialCase = true;

    @wire(getUserAvailableServices, {})
    wiredGetUsers(results) {
        this.lstServicesGranted = results.data;
        this.componentLoading = false;
    }

    connectedCallback() {
        getRecommendations().then(result => {
            this.highlightList = result;
        });  
    }


    handleServiceGranted(event) {
        let servRec = JSON.parse(JSON.stringify(event.detail.serviceId));
        let tempList = this.lstServicesGranted.filter(elem => { return elem.recordService.Id != servRec.recordService.Id });
        this.lstServicesGranted = tempList;
    }


}