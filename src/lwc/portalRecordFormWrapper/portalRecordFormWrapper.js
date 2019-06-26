/**
 * Created by pvavruska on 5/28/2019.
 */

import { LightningElement, api, track } from 'lwc';


//navigation
import { NavigationMixin } from 'lightning/navigation';
import { navigateToPage } from 'c/navigationUtils';


import getPickListValues from '@salesforce/apex/CSP_Utils.getPickListValues';

import SaveLabel from '@salesforce/label/c.CSP_Save';
import CancelLabel from '@salesforce/label/c.CSP_Cancel';
import MembershipFunction from '@salesforce/label/c.csp_MembershipFunction';
import Area from '@salesforce/label/c.csp_WorkingAreas';



export default class PortalRecordFormWrapper extends NavigationMixin(LightningElement) {

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
    @api services;
    @api showfunction;

    @track isLoading = true;
    @track isLoadingEdit = true;
    @track isSaving = false;
    @track areasOptions = [];
    @track selectedvalues = [];
    @track accessibilityText = '';
    @track functionOptions = [];
    @track selectedValuesFunction = [];

    @track listSelected = [];
    @track contactTypeStatus = [];

    @track changeUserPortalStatus = false;

    _labels = { SaveLabel, CancelLabel, MembershipFunction, Area };
    get labels() { return this._labels; }
    set labels(value) { this._labels = value; }

    connectedCallback() {
        this.showEdit = (this.showEdit === 'true' ? true : false);

        console.log('BLA: ', JSON.stringify(this.staticFields));

        if (this.isContact) {
            getPickListValues({ sobj: 'Contact', field: 'Area__c' }).then(result => {
                let options = JSON.parse(JSON.stringify(result));
                let contact = JSON.parse(JSON.stringify(this.staticFields));
                let selectedV = JSON.parse(JSON.stringify(this.selectedvalues));

                if (contact.Area__c != null) {

                    let values = contact.Area__c.split(";");
                    values.forEach(function (value) {
                        options.forEach(function (option) {
                            if (option.label == value) { option.checked = true; selectedV.push(option.value); }
                        });
                    });

                    this.selectedvalues = selectedV;
                }

                this.areasOptions = options;
            });

            //Get membership function values
            getPickListValues({ sobj: 'Contact', field: 'Membership_Function__c' }).then(result => {
                let options = JSON.parse(JSON.stringify(result));
                let contact = JSON.parse(JSON.stringify(this.staticFields));
                let selectedV = JSON.parse(JSON.stringify(this.selectedValuesFunction));

                if (contact.Membership_Function__c != null) {

                    let values = contact.Membership_Function__c.split(";");
                    values.forEach(function (value) {
                        options.forEach(function (option) {
                            if (option.label == value) { option.checked = true; selectedV.push(option.value); }
                        });
                    });

                    this.selectedValuesFunction = selectedV;
                }

                this.functionOptions = options;
            });

        }

    }

    get accessibilityGetter() {

        let contactTypeStatus = [];
        let contactType = [];
        let fieldsToIterate = JSON.parse(JSON.stringify(this.fields));
        fieldsToIterate.forEach(function (item) {
            if (item.isAccessibility) {
                contactType = item.accessibilityList;
                item.accessibilityList.forEach(function (acc) {
                    if (acc.checked) {
                        contactTypeStatus.push(acc.label);
                    }
                });
            }
        });

        this.accessibilityText = contactTypeStatus.join(', ');
        this.contactTypeStatus = contactType;
        this.listSelected = contactTypeStatus;

        return this.accessibilityText
    }

    openModal() { this.showEditModal = true; }
    closeModal() { this.showEditModal = false; }

    loaded(event) {
        this.isLoading = false;
        let fields = JSON.parse(JSON.stringify(event.detail.objectInfos.Contact.fields));

    }
    loadedEdit() {
        this.isLoadingEdit = false;
        this.styleInputs();
    }

    handleSucess(event) {
        const updatedRecord = event.detail.id;
        this.isSaving = false;

        let listSelected = JSON.parse(JSON.stringify(this.listSelected));
        this.dispatchEvent(new CustomEvent('refreshview'));
        this.closeModal();
        //eval("$A.get('e.force:refreshView').fire();");
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

    get isContact() {
        return this.objectName != null && this.objectName.toLowerCase() == 'contact';
    }

    get showAreas() {
        return this.showarea;
    }

    get showMembershipFunction() {
        return this.showfunction;
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
        if (this.isContact) {
            event.preventDefault();

            let selectedV = JSON.parse(JSON.stringify(this.selectedvalues));
            let selected = '';
            selectedV.forEach(function (item) { selected += item + ';'; });

            let selectedFunction = JSON.parse(JSON.stringify(this.selectedValuesFunction));
            let selectedF = '';
            selectedFunction.forEach(function (item) { selectedF += item + ';'; });

            let fields = event.detail.fields;
            fields.accountId = this.accountId;

            fields.Area__c = selected;
            fields.Membership_Function__c = selectedF;

            let listSelected = JSON.parse(JSON.stringify(this.listSelected));
            if (listSelected.length > 0) {
                let contactTypeStatusLocal = JSON.parse(JSON.stringify(this.contactTypeStatus));

                contactTypeStatusLocal.forEach(function (item) {
                    if (listSelected.includes(item.label)) {
                        fields[item.APINAME] = true;
                    } else {
                        fields[item.APINAME] = false;
                    }
                });

            }

            this.template.querySelector('lightning-record-edit-form').submit(fields);
        }
    }

    getValueSelected(event) {
        let selected = event.target.dataset.item;
        let type = event.target.dataset.type;
        let isArea = (type == 'Area__c');

        let options = isArea ? JSON.parse(JSON.stringify(this.areasOptions)) : JSON.parse(JSON.stringify(this.functionOptions));
        let selectedV = isArea ? JSON.parse(JSON.stringify(this.selectedvalues)) : JSON.parse(JSON.stringify(this.selectedValuesFunction));


        if (!selectedV.includes(selected)) {
            selectedV.push(selected);
            options.forEach(function (option) {
                if (option.value == selected) { option.checked = true; }
            });
        } else {
            let index = selectedV.indexOf(selected);
            if (index > -1) {
                selectedV.splice(index, 1);
                options.forEach(function (option) {
                    if (option.value == selected) { option.checked = false; }
                });
            }
        }

        if (isArea) {
            this.areasOptions = options;
            this.selectedvalues = selectedV;
        } else {
            this.functionOptions = options;
            this.selectedValuesFunction = selectedV;
        }
    }

    navigateTo(event) {
        let serviceId = event.target.dataset.id;

        let params = {};
        params.serviceId = serviceId;

        event.preventDefault();
        event.stopPropagation();
        this[NavigationMixin.GenerateUrl]({
            type: "standard__namedPage",
            attributes: {
                pageName: "manage-service"
            }
        })
            .then(url => navigateToPage(url, params));

    }

    getValueSelectedTypeStatus(event) {

        let selected = event.target.dataset.item;
        let type = event.target.dataset.type;

        let fieldValue = JSON.parse(JSON.stringify(this.listSelected));

        if (!fieldValue.includes(selected)) {
            fieldValue.push(selected)
        } else {
            for (let i = fieldValue.length - 1; i >= 0; i--) {
                if (fieldValue[i] === selected) {
                    fieldValue.splice(i, 1);
                }
            }
        }

        this.listSelected = fieldValue;

    }

    openChangeUserPortalStatus() {
        this.changeUserPortalStatus = true;
    }

    closePortalChangeUserStatus() {
        this.changeUserPortalStatus = false;
    }

    closePortalChangeUserStatusWithRefresh() {
        this.dispatchEvent(new CustomEvent('refreshview'));
        this.changeUserPortalStatus = false;
    }
}