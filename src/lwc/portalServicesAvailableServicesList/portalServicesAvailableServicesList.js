import { LightningElement,track,wire } from 'lwc';

import getUserAvailableServices from '@salesforce/apex/PortalServicesCtrl.getUserAvailableServices';
import getContactInfo from '@salesforce/apex/PortalRegistrationSecondLevelCtrl.getContactInfo';
import { refreshApex } from '@salesforce/apex';

export default class PortalServicesAvailableServicesList extends LightningElement {

    @track componentLoading = true;

    @track lstServicesGranted = [];

    @track isFirstLevelUser;

    @wire( getUserAvailableServices,{})
    wiredGetUsers(results){
        this.lstServicesGranted = results.data;
        this.componentLoading = false;
    }

    connectedCallback(){
        getContactInfo()
            .then(result => {
                this.isFirstLevelUser = result.Account.Is_General_Public_Account__c;
            })
            .catch((error) => {
                console.log('Error: ', JSON.parse(JSON.stringify(error)));
            });
    }


    handleServiceGranted(event){
        let servRec=JSON.parse(JSON.stringify(event.detail.serviceId));
        let tempList=this.lstServicesGranted.filter(elem=> {return elem.recordService.Id !=servRec.recordService.Id });
        this.lstServicesGranted=tempList;
    }

    
}