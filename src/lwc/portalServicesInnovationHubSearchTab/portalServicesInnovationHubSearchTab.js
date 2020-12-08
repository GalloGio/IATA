import { LightningElement, api, track } from 'lwc';

import getLstProviders from '@salesforce/apex/PortalServicesInnovationHubCtrl.getLstProviders';

export default class PortalServicesInnovationHubSearchTab extends LightningElement {

    @track componentLoading = true;

    @track lstAllProviders = [];

    connectedCallback(){
        this.getGrantedServices();
    }

    getGrantedServices(){
        this.componentLoading = true;
        getLstProviders({})
        .then(results => {
            this.lstAllProviders = results;

            for(let i = 0; i < results.length; i++){
                if(results[i].imageUrl !== undefined && results[i].imageUrl !== ''){
                    results[i].imageCSS = 'background: url(' + results[i].imageUrl + ');';
                }else{
                    results[i].imageCSS = '';
                }
            }

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