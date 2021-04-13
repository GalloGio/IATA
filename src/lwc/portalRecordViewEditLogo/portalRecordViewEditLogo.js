import { LightningElement, api, track } from 'lwc';
import getLogoUrl from '@salesforce/apex/PortalServicesStartupHotlistCtrl.getProviderImgURLById';
import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';

export default class PortalRecordViewEditLogo extends LightningElement {

    @track providerId;
    @track logoId;
    @track logoCSS = '';
    @track logoNotAvailable = CSP_PortalPath + 'CSPortal/Images/Icons/logoNotAvailable.png';

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
            }
            else{
                this.logoCSS = 'background: url(' + '"' + this.logoNotAvailable + '"' + ');';
            }
        });
    }

}