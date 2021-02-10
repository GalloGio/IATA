import { LightningElement, api, track } from 'lwc';
import getLogoUrl from '@salesforce/apex/PortalServicesInnovationHubCtrl.getProviderImgURLById';
import CSP_No_Logo_Available from '@salesforce/label/c.CSP_No_Logo_Available';

export default class PortalRecordViewEditLogo extends LightningElement {

    @track providerId;
    @track logoId;
    @track logoCSS = '';
    @track showLogo = false;

    labels = {
        CSP_No_Logo_Available,
    }

    @api 
    get providerIdApi(){
        return this.providerId;
    }
    set providerIdApi(value){
        this.providerId = value;
    }

    connectedCallback() {
        getLogoUrl({providerId: this.providerId})
        .then(results => {
            if(results !== null){
                this.logoCSS = 'background: url(' + '"' + results + '"' + ');';
                this.showLogo = true;
            }
        });
    }

}