/**
 * Created by pvavruska on 5/28/2019.
 */

import { LightningElement, api, track } from 'lwc';

import getPickListValues from '@salesforce/apex/CSP_Utils.getPickListValues';

import SaveLabel from '@salesforce/label/c.CSP_Save';
import CancelLabel from '@salesforce/label/c.CSP_Cancel';

export default class PortalRecordFormWrapper extends LightningElement {

    @api sectionClass;
    @api headerClass;
    @api sectionTitle;
    @api showEdit;
    @api fields;
    @api editFields;
    @api recordId;
    @api objectName;
    @api showEditModal = false;
    @api isLoading;
    @api staticFields;
    @api showarea;

    @track isLoading = true;
    @track isLoadingEdit = true;
    @track isSaving = false;
    @track areasOptions = [];
    @track selectedvalues = [];


    _labels = { SaveLabel, CancelLabel };
    get labels() { return this._labels; }
    set labels(value) { this._labels = value; }

    connectedCallback() {
        this.showEdit = (this.showEdit === 'true' ? true : false);

        if(this.isContact){
            getPickListValues({ sobj: 'Contact', field: 'Area__c' }).then(result => {
                let options = result;
                let contact = JSON.parse(JSON.stringify(this.staticFields));
                let selectedV = JSON.parse(JSON.stringify(this.selectedvalues));

                if(contact.Area__c != null){

                    let values = contact.Area__c.split(";");
                    values.forEach(function (value) {
                        options.forEach(function (option) {
                            if(option.label == value){option.checked = true; selectedV.push(option.value);}
                        });
                    });

                    this.selectedvalues = selectedV;
                }

                this.areasOptions = options;
            });
        }
    }

    openModal() { this.showEditModal = true; }
    closeModal() { this.showEditModal = false; }

    loaded() { this.isLoading = false; }
    loadedEdit() {
        this.isLoadingEdit = false;
        this.styleInputs();
    }

    handleSucess(event) {
        const updatedRecord = event.detail.id;
        this.isSaving = false;
        this.closeModal();
    }

    handleError(event) {
        this.isSaving = false;
    }

    onRecordSubmit(event) {
        this.isSaving = true;
    }

    get haveEditFields() {
        return this.editFields != null;
    }

    get isContact(){
        return this.objectName != null && this.objectName.toLowerCase() == 'contact';
    }

    get showAreas(){
        return this.showarea;
    }

    styleInputs() {
        let inputs = this.template.querySelectorAll('lightning-input-field');
        if (inputs) {
            if (inputs.length) {
                for (let i = 0; i < inputs.length; i++) {
                    if (!inputs[i].disabled) {
                        if (inputs[i].value == null || inputs[i].value.length == 0) {

                            if (inputs[i].classList) {
                                inputs[i].classList.add('whiteBackgroundInput');
                            } else {
                                inputs[i].classList = ['whiteBackgroundInput'];
                            }
                        } else {
                            if (inputs[i].classList) {
                                inputs[i].classList.remove('whiteBackgroundInput');
                            }
                        }
                    }
                }
            } else {
                if (!inputs.disabled) {
                    if (inputs.value == null || inputs.value.length == 0) {
                        if (inputs.classList) {
                            inputs.classList.add('whiteBackgroundInput');
                        } else {
                            inputs.classList = ['whiteBackgroundInput'];
                        }
                    } else {
                        if (inputs.classList) {
                            inputs.classList.remove('whiteBackgroundInput');
                        }
                    }
                }
            }

        }
    }

    handleSubmit(event) {
    	this.isSaving = true;
    	if(this.isContact){
            event.preventDefault();

            let selectedV = JSON.parse(JSON.stringify(this.selectedvalues));
            let selected = '';
            selectedV.forEach(function (item) { selected += item + ';'; });

            let fields = event.detail.fields;
            fields.accountId = this.accountId;

            fields.Area__c = selected;

            this.template.querySelector('lightning-record-edit-form').submit(fields);
    	}
    }

    getValueSelected(event) {
        let selected = event.target.dataset.item;
        let options = JSON.parse(JSON.stringify(this.areasOptions));

        let selectedV = JSON.parse(JSON.stringify(this.selectedvalues));


        if (!selectedV.includes(selected)) {
            selectedV.push(selected);
            options.forEach(function (option) {
                if(option.value == selected){option.checked = true;}
            });
        } else {
            let index = selectedV.indexOf(selected);
            if (index > -1) {
                selectedV.splice(index, 1);
                options.forEach(function (option) {
                    if(option.value == selected){option.checked = false;}
                });
            }
        }

        this.areasOptions = options;
        this.selectedvalues = selectedV;
    }

}