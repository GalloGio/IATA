import { LightningElement, track, wire } from 'lwc';

import getUserAvailableServices from '@salesforce/apex/PortalServicesCtrl.getUserAvailableServices';
import getContactInfo from '@salesforce/apex/PortalRegistrationSecondLevelCtrl.getContactInfo';

import { refreshApex } from '@salesforce/apex';

export default class PortalServicesAvailableServicesList extends LightningElement {

    @track componentLoading = true;

    @track lstServicesGranted = [];

    @track isFirstLevelUser;

    @track specialCase = true;

    connectedCallback(){
        getContactInfo()
        .then(result => {
            this.isFirstLevelUser = result.Account.Is_General_Public_Account__c;
        })
        .catch((error) => {
            console.log('Error: ', JSON.parse(JSON.stringify(error)));
        });

        getUserAvailableServices().then(result => {
            let results = JSON.parse(JSON.stringify(result));

            if(results !== undefined){
                for(let i = 0; i < results.length; i++){
                    if(results[i].recordService.Application_icon_URL__c !== undefined && results[i].recordService.Application_icon_URL__c !== ''){
                        results[i].recordService.imageCSS = 'background: url(' + results[i].recordService.Application_icon_URL__c + ');';
                    }else{
                        results[i].recordService.imageCSS = '';
                    }
                }
            }
    
            this.lstServicesGranted = results;
            this.componentLoading = false;
        });
    }

    handleServiceGranted(event) {
        let servRec = JSON.parse(JSON.stringify(event.detail.serviceId));
        let tempList = this.lstServicesGranted.filter(elem => { return elem.recordService.Id != servRec.recordService.Id });
        this.lstServicesGranted = tempList;
    }

}