import { LightningElement,track,wire } from 'lwc';

import getUserAvailableServices from '@salesforce/apex/PortalServicesCtrl.getUserAvailableServices';
import { refreshApex } from '@salesforce/apex';

export default class PortalServicesAvailableServicesList extends LightningElement {

    @track componentLoading = true;

    @track lstServicesGranted = [];

    @wire( getUserAvailableServices,{})
    wiredGetUsers(results){
        this.lstServicesGranted = results.data;
        this.componentLoading = false;
    }



    handleServiceGranted(event){
        let servRec=JSON.parse(JSON.stringify(event.detail.serviceId));
        let tempList=this.lstServicesGranted.filter(elem=> {return elem.recordService.Id !=servRec.recordService.Id });
        this.lstServicesGranted=tempList;
    }

    
}