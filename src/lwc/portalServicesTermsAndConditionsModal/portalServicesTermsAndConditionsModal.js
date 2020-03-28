import { LightningElement, api, track } from 'lwc';

import acceptServiceTermsAndConditions from '@salesforce/apex/ServiceTermsAndConditionsUtils.acceptServiceTermsAndConditions';

import CSP_Services_Accept_Terms from '@salesforce/label/c.CSP_Services_Accept_Terms';
import OneId_TermsAndConditions from '@salesforce/label/c.OneId_TermsAndConditions';

export default class PortalServicesTermsAndConditionsModal extends LightningElement {

    @api portalServiceId;
    @api contactId;
    @api language;

    @track isLoading = false;
    @track acceptDisabled = true;

    _labels = {
        CSP_Services_Accept_Terms,
        OneId_TermsAndConditions
    }
    get labels() {
        return this._labels;
    }
    set labels(value) {
        this._labels = value;
    }

    tcAcceptanceChanged(event){
		var detail = event.detail;
		this.acceptDisabled = !detail;
    }

    accept(){
        this.startLoading();
        //save the T&C
        acceptServiceTermsAndConditions({contactId: this.contactId, portalServiceId: this.portalServiceId}).then(result=> {
            this.stopLoading();
            this.dispatchEvent(new CustomEvent('accept'));
        })
        .catch(error => {
            console.info('Error: ', JSON.parse(JSON.stringify(error)));
            this.stopLoading();
        });    
    }

    cancel(){
        this.dispatchEvent(new CustomEvent('cancel'));
    }

    startLoading(){
        this.isLoading = true;
    }

    stopLoading(){
        this.isLoading = false;
    }
}