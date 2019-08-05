import { LightningElement, track } from 'lwc';

import Next from '@salesforce/label/c.ISSP_Next';
import ISSP_TC_Accept from '@salesforce/label/c.ISSP_TC_Accept';
import ISSP_Registration_acceptGeneralConditions from '@salesforce/label/c.ISSP_Registration_acceptGeneralConditions';
import CSP_Accept_Terms_Error from '@salesforce/label/c.CSP_Accept_Terms_Error';

export default class PortalChangePassword extends LightningElement {

    @track isLoading = false;

    @track acceptTerms = false;

    @track errorMessageClass = 'errorMessageClassNone';

    @track
    _labels = {
        Next,
        ISSP_TC_Accept,
        ISSP_Registration_acceptGeneralConditions,
        CSP_Accept_Terms_Error
    };

    get labels() {
        return this._labels;
    }

    set labels(value) {
        this._labels = value;
    }

    

    connectedCallback() {

    }

    closeModal() {
        this.dispatchEvent(new CustomEvent('closeacceptterms'));
    }

    save(event) {
        console.log('Save');
        let accept = this.acceptTerms;
        if (!accept) {
            this.errorMessageClass = 'errorMessageClassDisplay';
        } else {
            this.isLoading = true;
            this.dispatchEvent(new CustomEvent('acceptterms'));
        }

    }

    handleChange() {
        let checked = this.template.querySelector('input[name="acceptTerms"]').checked

        if (checked) {
            this.errorMessageClass = 'errorMessageClassNone';
        } else {
            this.errorMessageClass = 'errorMessageClassDisplay';
        }

        this.acceptTerms = checked;

    }


}