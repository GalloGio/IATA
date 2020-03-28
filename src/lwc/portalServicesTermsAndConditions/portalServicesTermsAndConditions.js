import { LightningElement, api, track } from 'lwc';

import getWrappedTermsAndConditions from '@salesforce/apex/ServiceTermsAndConditionsUtils.getWrappedTermsAndConditions';

import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';

import CSP_Have_Read_Terms from '@salesforce/label/c.CSP_Have_Read_Terms';

export default class PortalServicesTermsAndConditions extends LightningElement {
    alreadyAcceptedIcon = CSP_PortalPath + 'CSPortal/Images/Icons/L2_step_valid.png';

    @api portalServiceId;
    @api contactId;
    @api language;

    @track termsAndConditionsLocal;
    @track termsAndConditionsAccepted = false;

    @track showTermsAndConditions = false;

    @track termsConditionsValue;

    closeModal(){
        this.showTermsAndConditions = false;
    }

    _labels = {
        CSP_Have_Read_Terms
    }
    get labels() {
        return this._labels;
    }
    set labels(value) {
        this._labels = value;
    }

    connectedCallback(){
        getWrappedTermsAndConditions({contactId: this.contactId, portalServiceId: this.portalServiceId, language : this.language})
        .then(result => {
            var termsAndConditions = JSON.parse(JSON.stringify(result));
            this.termsAndConditionsLocal = [];
            for(let i = 0; i < termsAndConditions.length; i++){
                if(termsAndConditions[i].isLatestVersionAccepted === false){
                    this.termsAndConditionsLocal.push(termsAndConditions[i]);
                }
            }
        });
    }

    handleAcceptanceChange(){
        this.termsAndConditionsAccepted = !this.termsAndConditionsAccepted;
        this.dispatchEvent(new CustomEvent('acceptancechanged', { detail: this.termsAndConditionsAccepted }));
    }
    
    openModal(event){
        var termId = event.target.getAttribute('data-id');

        for(let i = 0; i < this.termsAndConditionsLocal.length; i++){
            if(this.termsAndConditionsLocal[i].id === termId){
                this.termsAndConditionsTitle = this.termsAndConditionsLocal[i].label;
                this.termsAndConditionsDescription = this.termsAndConditionsLocal[i].description;
                this.showTermsAndConditions = true;
                break;
            }
        }
    }
}