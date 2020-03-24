import { LightningElement, api, track } from 'lwc';

import getUserAccessGrantedServices from '@salesforce/apex/PortalServicesCtrl.getUserAccessGrantedServices';

export default class PortalServicesAccessGranted extends LightningElement {

    @api showOnlyFavorites;

    @track componentLoading;

    @track lstAllServicesGranted = [];
    @track lstFavoriteServicesGranted = [];

    connectedCallback(){
        this.getGrantedServices();
    }

    getGrantedServices(){
        this.componentLoading = true;
        getUserAccessGrantedServices({})
        .then(results => {
            this.lstAllServicesGranted = results;

            let favorites = [];
            for(let i = 0; i < results.length; i++){
                if(results[i].isFavorite !== false){
                    favorites.push(results[i]);
                }

                if(results[i].recordService.Application_icon_URL__c !== undefined && results[i].recordService.Application_icon_URL__c !== ''){
                    results[i].recordService.imageCSS = 'background: url(' + results[i].recordService.Application_icon_URL__c + ');';
                }else{
                    results[i].recordService.imageCSS = '';
                }
            }
            this.lstFavoriteServicesGranted = favorites;

            this.componentLoading = false;
        });
    }

    startLoading(){
        this.componentLoading = true;
    }

    stopLoading(){
        this.componentLoading = false;
    }
}