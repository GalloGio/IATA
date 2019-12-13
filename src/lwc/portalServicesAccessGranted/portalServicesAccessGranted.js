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