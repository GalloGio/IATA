/**
 * Created by pvavruska on 5/28/2019.
 */

import { LightningElement, api, track } from 'lwc';


//navigation
import { NavigationMixin } from 'lightning/navigation';
import { navigateToPage } from 'c/navigationUtils';

import isAdmin from '@salesforce/apex/CSP_Utils.isAdmin';
import getPickListValues from '@salesforce/apex/CSP_Utils.getPickListValues';
import goToPrivacyPortal from '@salesforce/apex/PortalProfileCtrl.goToPrivacyPortal';

import SaveLabel from '@salesforce/label/c.CSP_Save';
import CancelLabel from '@salesforce/label/c.CSP_Cancel';
import MembershipFunction from '@salesforce/label/c.csp_MembershipFunction';
import Area from '@salesforce/label/c.csp_WorkingAreas';
import ServicesTitle from '@salesforce/label/c.CSP_Services_Title';
import InvalidValue from '@salesforce/label/c.csp_InvalidPhoneValue';
import CompleteField from '@salesforce/label/c.csp_CompleteField';

import IdCardNumber from '@salesforce/label/c.ISSP_IDCard_VER_Number';
import IdCardValidTo from '@salesforce/label/c.ISSP_IDCard_Valid_To';
import CSP_Error_Message_Mandatory_Fields_Contact from '@salesforce/label/c.CSP_Error_Message_Mandatory_Fields_Contact';
import LastLoginDate from '@salesforce/label/c.csp_LastLoginDate';

import remove from '@salesforce/label/c.Button_Remove';
import contact from '@salesforce/label/c.ISSP_Contact';



export default class PortalRecordFormWrapper extends NavigationMixin(LightningElement) {

    @api sectionClass;
    @api headerClass;
    @api sectionTitle;
    @api showEdit;
    @api editBasics;
    @api allowContactDelete=false;

    @api editFields;
    @api recordId;
    @api objectName;
    @api showEditModal = false;
    @api isLoading;
    @api staticFields;
    @api showarea;
    @api services;
    @api showfunction;

    @api isForEdit = false;

    @track isLoading = true;
    @track isLoadingEdit = true;
    @track isSaving = false;
    @track areasOptions = [];
    @track selectedvalues = [];
    @track accessibilityText = '';
    @track functionOptions = [];
    @track selectedValuesFunction = [];
    @track fieldsValid = true;
    @track fieldsLocal;
    @track jobFunctions;
    @track removeContact = false;

    timeout = null;

    @track listSelected = [];
    @track contactTypeStatus = [];

    @track changeUserPortalStatus = false;

    @track hasError = false;

    @api
    get fields() { return this.fieldsLocal; }
    set fields(value) { this.fieldsLocal = value; }

    _labels = { SaveLabel, CancelLabel, MembershipFunction, Area, ServicesTitle, InvalidValue, CompleteField, IdCardNumber, IdCardValidTo, remove, contact, CSP_Error_Message_Mandatory_Fields_Contact,LastLoginDate};
    get labels() { return this._labels; }
    set labels(value) { this._labels = value; }

    emptyStaticServices = 'emptyStaticServices';
    emptyServices = 'emptyServices';

    connectedCallback() {

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
                let functions = [];

                if (contact.Membership_Function__c != null) {

                    let values = contact.Membership_Function__c.split(";");
                    values.forEach(function (value) {
                        functions.push(value);
                        options.forEach(function (option) {
                            if (option.label == value) { option.checked = true; selectedV.push(option.value); }
                        });
                    });

                    this.selectedValuesFunction = selectedV;
                }

                functions.sort();

                this.jobFunctions = functions;
                this.functionOptions = options;
            });


        }
        
        isAdmin().then(result => {
            this.showEdit = result && this.showEdit;
        });
    }

    get accessibilityGetter() {

        let accessibilityTextLocal = '';
        let contactTypeStatus = [];
        let contactType = [];
        let fieldsToIterate = JSON.parse(JSON.stringify(this.fields));

        if (fieldsToIterate) {
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
        }

        accessibilityTextLocal = contactTypeStatus.join(', ');
        this.contactTypeStatus = contactType;
        this.listSelected = contactTypeStatus;

        isAdmin().then(result => {
            this.showEdit = (result ? true : false);
        });

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
        this.closeModal();

        this.updateMembershipFunctions(event.detail);
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

    get removeContactLabel(){
        return this.labels.remove +' '+this.labels.contact;
    }

    removeUser(){
        this.removeContact = true;
        this.changeUserPortalStatus = true;
        this.showEditModal = false;
    }

    updateMembershipFunctions(eventDetail) {
        if(eventDetail.fields.hasOwnProperty('Membership_Function__c')) {
            let functions = [];
            if(eventDetail.fields.Membership_Function__c) {
                const values = eventDetail.fields.Membership_Function__c.value.split(";");
                values.forEach( (value) => { functions.push(value); });
            }
            this.jobFunctions = functions;
        }
    }

    styleInputs() {
        let inputs = this.template.querySelectorAll('lightning-input-field');
        let phoneRegex = /[^0-9+]|(?!^)\+/g;

        let haveEditFields = this.haveEditFields;

        let fields = haveEditFields ? JSON.parse(JSON.stringify(this.editFields)) : JSON.parse(JSON.stringify(this.fields));
        let fieldsChanged = false;
        let numberFields = ['Phone', 'MobilePhone', 'Phone_Number__c'];
        let requiredFields = [];
        let skipValidation = false;

        /*
        for(let f=0;f<fields.length;f++){
            if(fields[f].isRequired !== undefined && fields[f].isRequired == true){
                requiredFields.push(fields[f].fieldName);
            }
        }

        let fieldsValid = true;

        */

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
                    /*
                    if(requiredFields.includes(inputs[i].fieldName)){
                        if(inputs[i].value === undefined || inputs[i].value.length == 0){
                            skipValidation = true;
                            for(let f = 0;f<fields.length;f++){
                                if(fields[f].fieldName == inputs[i].fieldName){
                                    if(fields[f].missing == null || fields[f].missing == false){
                                        fields[f].missing = true;
                                        fieldsChanged = true;
                                        fieldsValid = false;
                                    }
                                }
                            }
                            inputs[i].classList.add('invalidValue');
                        }else{
                            for(let f = 0;f<fields.length;f++){
                                if(fields[f].fieldName == inputs[i].fieldName){
                                    if(fields[f].missing != null && fields[f].missing == true){
                                        fields[f].missing = false;
                                        fieldsChanged = true;
                                    }
                                    inputs[i].classList.remove('invalidValue');
                                }
                            }
                        }
                    }

                    if(!skipValidation){
                        if(numberFields.includes(inputs[i].fieldName)){
                            if(inputs[i].value != null){
                                let inputValue = inputs[i].value.replace(/ /g,'');
                                let isNotPhone = phoneRegex.test(inputValue);
                                if(isNotPhone){
                                    inputs[i].classList.add('invalidValue');
                                    fieldsValid = false;

                                    for(let f = 0;f<fields.length;f++){
                                        if(fields[f].fieldName == inputs[i].fieldName){
                                            if(fields[f].invalid == null || fields[f].invalid == false){
                                                fields[f].invalid = true;
                                                fieldsChanged = true;
                                            }
                                        }
                                    }

                                }else{
                                    for(let f = 0;f<fields.length;f++){
                                        if(fields[f].fieldName == inputs[i].fieldName){
                                            if(fields[f].invalid != null && fields[f].invalid == true){
                                                fields[f].invalid = false;
                                                fieldsChanged = true;
                                            }
                                        }
                                    }
                                    inputs[i].classList.remove('invalidValue');
                                }
                            }
                        }
                        
                    }*/

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

        /*
        if(fieldsChanged){
            clearTimeout(this.timeout);
            this.timeout = setTimeout(() => {
                if(haveEditFields){
                    this.editFields = fields;
                }else{
                    this.fields = fields;
                }
            },400,this);
        }
        this.fieldsValid = fieldsValid;
        */
    }

    handleSubmit(event) {
        this.isSaving = true;
        if (this.isContact) {
            event.preventDefault();
            let canSave = true;
            let selectedV = JSON.parse(JSON.stringify(this.selectedvalues));
            let selected = '';
            selectedV.forEach(function (item) { selected += item + ';'; });

            let selectedFunction = JSON.parse(JSON.stringify(this.selectedValuesFunction));
            let selectedF = '';
            selectedFunction.forEach(function (item) { selectedF += item + ';'; });

            let fields = event.detail.fields;
            fields.accountId = this.accountId;

            if (selected.length > 0) {
                fields.Area__c = selected;
            }

            fields.Membership_Function__c = selectedF;


            let hasFunctionLocal = this.showfunction;

            if (hasFunctionLocal) {
                if (selectedF.length > 0) {
                    this.hasError = false;
                    this.template.querySelector('.workingAreas').classList.remove('workingAreasError');

                    let inputs = this.template.querySelectorAll('.workingAreasChangeOnError');
                    for (let i = 0; i < inputs.length; i++) {
                        inputs[i].classList.remove('errorOnCheckBox');
                    }

                } else {
                    canSave = false;
                    this.hasError = true;
                    this.template.querySelector('.workingAreas').classList.add('workingAreasError');

                    let inputs = this.template.querySelectorAll('.workingAreasChangeOnError');
                    for (let i = 0; i < inputs.length; i++) {
                        inputs[i].classList.add('errorOnCheckBox');
                    }
                }
            }

            let listSelected = JSON.parse(JSON.stringify(this.listSelected));
            if (listSelected.length > 0) {
                let contactTypeStatusLocal = JSON.parse(JSON.stringify(this.contactTypeStatus));
                
                contactTypeStatusLocal.forEach(function (item) {
                    if (listSelected.includes(item.label)) {
                        fields[item.APINAME] = true;
                        item.checked = true;
                    } else {
                        fields[item.APINAME] = false;
                        item.checked = false;
                    }
                });

                // Update accessibility fields
                this.fields.forEach(function (item) {
                    if (item.isAccessibility) {
                        item.accessibilityList = contactTypeStatusLocal;
                    }
                });
            }

            if (canSave) {
                this.template.querySelector('lightning-record-edit-form').submit(fields);
            } else {
                this.isSaving = false;
            }
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
        this.removeContact = false;
        this.changeUserPortalStatus = false;
    }

    closePortalChangeUserStatusWithRefresh() {
        this.dispatchEvent(new CustomEvent('refreshview'));
        this.removeContact = false;
        this.changeUserPortalStatus = false;
    }

    get canSave() {
        return !this.fieldsValid || this.isSaving;
    }

    get canEditBasics() {
        let isRestrictedSection = this.sectionTitle == 'Basics' || this.sectionTitle == 'Branch Contact';
        return (this.editBasics && isRestrictedSection && this.showEdit) || (!isRestrictedSection && this.showEdit);
    }

    get hasIdCard() {
        return (this.staticFields !== undefined && this.staticFields.cardNumber !== undefined);
    }

    get hasFunction() {
        return this.jobFunctions !== undefined && this.jobFunctions.length > 0;
    }

    get hasServices() {
        return this.services !== undefined && this.services.length > 0;
    }

    get hasStaticServices(){
            return this.staticFields !== undefined && this.staticFields.services !== undefined && this.staticFields.services.length>0;
        }

    
    navigateToPrivacyPortal(){
        goToPrivacyPortal({})
        .then(results => {
            window.open(results);
        });
    }


}