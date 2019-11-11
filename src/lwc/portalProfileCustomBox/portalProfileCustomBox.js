import { LightningElement, track, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent'

import getPickListValues from '@salesforce/apex/CSP_Utils.getPickListValues';
import createUserForContact from '@salesforce/apex/ISSP_PortalUserStatusChange.preformActionNewPortal';
import getAccounts from '@salesforce/apex/portalProfileCustomBoxCtrl.getAccounts';
import updateUserStatus from '@salesforce/apex/portalProfileCustomBoxCtrl.updateUserStatus';
import searchServices from '@salesforce/apex/portalProfileCustomBoxCtrl.searchServices';
import createPortalApplicationRigth from '@salesforce/apex/portalProfileCustomBoxCtrl.createPortalApplicationRigth';

import New_Contact_Profile from '@salesforce/label/c.CSP_cpcc_New_Contact_Profile';
import Working_Areas from '@salesforce/label/c.CSP_cpcc_Working_Areas';
import Contact_Type_Status from '@salesforce/label/c.CSP_cpcc_Contact_Type_Status';
import Cancel from '@salesforce/label/c.Cancel';
import Save from '@salesforce/label/c.Save';
import Portal_Administrator from '@salesforce/label/c.CSP_cpcc_Portal_Administrator';
import Financial_Assessment_Contact from '@salesforce/label/c.CSP_cpcc_Financial_Assessment_Contact';
import Invoice_Contact from '@salesforce/label/c.CSP_cpcc_Invoice_Contact';
import Authorised_Signatory from '@salesforce/label/c.CSP_cpcc_Authorised_Signatory';
import BSP_CASS_Payment_Contact from '@salesforce/label/c.CSP_cpcc_BSP_CASS_Payment_Contact';
import Agent_Credit_Risk from '@salesforce/label/c.CSP_cpcc_Agent_Credit_Risk';
import InvalidValue from '@salesforce/label/c.csp_InvalidPhoneValue';
import completeField from '@salesforce/label/c.CSP_Create_Contact_Complete_Field';
import ICCS_Account_Name_Label from '@salesforce/label/c.ICCS_Account_Name_Label';
import CSP_Error_Message_Mandatory_Fields_Contact from '@salesforce/label/c.CSP_Error_Message_Mandatory_Fields_Contact';
import Service_Access from '@salesforce/label/c.CSP_Service_Access';
import Assign_Service_Access from '@salesforce/label/c.CSP_Assign_New_Service';
import Search from '@salesforce/label/c.Placeholder_Search';






export default class PortalProfileCustomBox extends LightningElement {

    @api openModel;
    @api recordId;
    @api objectId;
    @api objectName;
    @track services = [];
    @track lstServices = [];
    contactServices = [];
    contact = {};
    
    @api
    get fieldsList() {
        return this.trackedFieldsList === undefined ? [] : this.trackedFieldsList;
    }

    set fieldsList(value) {
        let fieldsListAux = JSON.parse(JSON.stringify(value));
        fieldsListAux.forEach(function (item) {
            item.class = item.fieldName + ' labelValue textValue';
            item.hasError = false;
        });

        this.trackedFieldsList = fieldsListAux;
    }

    @track trackedFieldsList = [];

    @track options = [];
    @track selectedvalues = [];

    @track isLoading = false;
    @track userType = 'Approved User';

    @track errorFieds = ['Email', 'Phone'];
    @track errorMessage = '';

    @track checkNumbers = ['Phone', 'MobilePhone'];

    @track canSave = true;

    @track
    _labels = {
        New_Contact_Profile,
        Working_Areas,
        Contact_Type_Status,
        Cancel,
        Save,
        Portal_Administrator,
        Financial_Assessment_Contact,
        Invoice_Contact,
        Authorised_Signatory,
        BSP_CASS_Payment_Contact,
        Agent_Credit_Risk,
        InvalidValue,
        completeField,
        ICCS_Account_Name_Label,
        CSP_Error_Message_Mandatory_Fields_Contact,
        Service_Access,
        Assign_Service_Access,
        Search
    };

    get labels() {
        return this._labels;
    }

    set labels(value) {
        this._labels = value;
    }

    @track numberHasError = false;
    @track errorfieldsHasError = false;

    @track accountList = [];
    @track accountSelected = '';

    @track hasError = false;

    @track workingAreasStyle = 'workingAreasRemoveError';

    // LABEL
    @track contactTypeStatus = [{ checked: false, label: this.labels.Portal_Administrator, APINAME: "PortalAdmin" },
    { checked: false, label: this.labels.Invoice_Contact, APINAME: "Invoicing_Contact__c" },
    { checked: false, label: this.labels.Authorised_Signatory, APINAME: "Authorized_Signatory__c" },
    { checked: false, label: this.labels.BSP_CASS_Payment_Contact, APINAME: "BSP_CASS_Payment_contact__c" },
    { checked: false, label: this.labels.Agent_Credit_Risk, APINAME: "Airline_Credit_Risk_Manager__c" }];

    connectedCallback() {
        getPickListValues({ sobj: 'Contact', field: 'Membership_Function__c' }).then(result => {
            this.options = result;
        });

        getAccounts().then(result => {
            let accountListLocal = JSON.parse(JSON.stringify(result));
            let accountBuilder = [];
            accountListLocal.forEach(function (account) {
                accountBuilder.push({ 'label': account.label, 'value': account.accountId });
            });
            this.accountList = accountBuilder;
        });

        searchServices().then(result => {
            let parsedResult = JSON.parse(JSON.stringify(result));
            let aux = [];
            parsedResult.forEach(service => {
                aux.push({ 'title': service.ServiceName__c, 'id': service.Id})
            });
            this.services = aux;
        });
    }

    handleChangeAccount(event) {
        this.accountSelected = event.detail.value;
    }

    getValueSelected(event) {
        let selected = event.target.dataset.item;
        let selectedV = JSON.parse(JSON.stringify(this.selectedvalues));
        if (!selectedV.includes(selected)) {
            selectedV.push(selected);
        } else {
            let index = selectedV.indexOf(selected);
            if (index > -1) {
                selectedV.splice(index, 1);
            }
        }

        this.selectedvalues = selectedV;
    }

    getValueSelectedContactTypeStatus(event) {
        let selected = event.target.dataset.item;
        let checked = event.target.dataset.checked;

        checked = (checked === 'true' ? false : true);
        let contactTypeStatusLocal = JSON.parse(JSON.stringify(this.contactTypeStatus));

        contactTypeStatusLocal.forEach(function (item) {
            if (item.label === selected) {
                item.checked = checked;
            }
        });

        this.contactTypeStatus = contactTypeStatusLocal;
    }



    closeModal() {
        this.dispatchEvent(new CustomEvent('closemodal'));
    }

    loaded() {

    }

    loadedEdit() {
        let inputs = this.template.querySelectorAll('lightning-input-field');

        let checkbox = this.template.querySelectorAll('lightning-input');

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

                        }
                    }
                }
            } else {
                if (!inputs.disabled) {
                    if (inputs.classList) {
                        inputs.classList.add('whiteBackgroundInput');
                    } else {
                        inputs.classList = ['whiteBackgroundInput'];
                    }
                }
            }

        }

    }

    handleSubmit(event) {
        this.hasError = false;
        this.isLoading = true;
        event.preventDefault();
        let fields = event.detail.fields;

        let selectedV = JSON.parse(JSON.stringify(this.selectedvalues));
        let selected = '';
        selectedV.forEach(function (item) {
            selected += item + ';';
        });

        let workingAreaCheck = true;
        if (selected.length > 0) {
            this.template.querySelector('.workingAreas').classList.remove('workingAreasError');

            let inputs = this.template.querySelectorAll('.workingAreasChangeOnError');
            for (let i = 0; i < inputs.length; i++) {
                inputs[i].classList.remove('errorOnCheckBox');
            }
            workingAreaCheck = false;
        } else {
            this.template.querySelector('.workingAreas').classList.add('workingAreasError');
            
            let inputs = this.template.querySelectorAll('.workingAreasChangeOnError');
            for (let i = 0; i < inputs.length; i++) {
                inputs[i].classList.add('errorOnCheckBox');
            }
        }

        let contactTypeStatusLocal = JSON.parse(JSON.stringify(this.contactTypeStatus));

        contactTypeStatusLocal.forEach(function (item) {
            fields[item.APINAME] = item.checked;
        });

        this.userType = (contactTypeStatusLocal[0].checked === true ? 'Approved Admin' : 'Approved User');

        fields.AccountId = this.accountSelected;

        fields.Membership_Function__c = selected;

        fields.Community__c = 'ISS Customer Portal';

        if (!fields.Email && !fields.Phone) {
            this.checkErrorOnErrorFields('', true);
        }

        let numberError = this.numberHasError;
        let fieldError = this.errorfieldsHasError;

        let accountCheck = true;
        let accountSelected = this.accountSelected;
        if (accountSelected.length > 0) {
            accountCheck = false;
        } else {
            accountCheck = true;
            this.template.querySelector('.AccountName').classList.add('slds-has-error');
        }

        this.canSave = (numberError || fieldError || accountCheck || workingAreaCheck ? false : true);

        if (this.canSave) {
            this.template.querySelector('lightning-record-edit-form').submit(fields);
        } else {
            this.isLoading = false;
            this.hasError = true;
        }
    }

    handleSuccess(event) {
        this.contact = JSON.parse(JSON.stringify(event.detail));
        
        let createUser = createUserForContact({ contactId: this.contact.id, portalStatus: this.userType, oldPortalStatus: '' })
        .then(result => {
            let res = JSON.parse(JSON.stringify(result));
            if (res.status === 'ok') {
                updateUserStatus({ contactId: this.contact.id, userPortalStatus: this.userType });
            } 
        });

        let giveServiceAccess;
        if(this.contactServices.length > 0){
            giveServiceAccess = createPortalApplicationRigth({contactId: this.contact.id, servicesIds: this.contactServices})
                .then( result => {
                    if(!result){
                        this.dispatchEvent(new ShowToastEvent({
                            variant: 'error',
                            title: 'Error associanting services',
                            message: 'There was an error while trying to give the user access to the selected services'
                        }));
                    }
                }).catch(() => {                   
                    this.dispatchEvent(new ShowToastEvent({
                        variant: 'error',
                        title: 'Error associanting services',
                        message: 'There was an error while trying to give the user access to the selected services'
                    }));
            });
        }
        
        let promises = [createUser];
        if(this.contactServices.length > 0){
            promises.push(giveServiceAccess);
        }

        Promise.all(promises).then(() => {
            this.isLoading = false;
            this.dispatchEvent(new CustomEvent('closemodalwithsuccess'));
        });
    }

    handleError(event) {
        this.isLoading = false;
    }

    checkValue(event) {
        let currentField = JSON.parse(JSON.stringify(event.target.dataset.field));
        this.checkSave(currentField, false);
    }

    checkSave(currentField, forcePass) {
        this.checkErrorOnErrorFields(currentField, forcePass);
        //this.checkIfNumberHasErrors(currentField);
    }

    checkErrorOnErrorFields(currentField, forcePass) {
        let isErrorField = JSON.parse(JSON.stringify(this.errorFieds));
        let isErrorfieldError = false;
        let errorMessage = '';
        if (isErrorField.includes(currentField) || forcePass) {
            let emailCheck = this.template.querySelector('.Email').value;
            let phoneCheck = this.template.querySelector('.Phone').value;

            if (emailCheck || phoneCheck) {
                this.template.querySelector('.Email').classList.remove('slds-has-error');
                this.template.querySelector('.Phone').classList.remove('slds-has-error');
                errorMessage = '';
            } else {
                this.template.querySelector('.Email').classList.add('slds-has-error');
                this.template.querySelector('.Phone').classList.add('slds-has-error');
                errorMessage = this._labels.completeField;
            }

            let fieldsListAux = JSON.parse(JSON.stringify(this.trackedFieldsList));
            let toCheck = JSON.parse(JSON.stringify(this.errorFieds));
            fieldsListAux.forEach(function (item) {
                if (toCheck.includes(item.fieldName)) {
                    item.hasError = (emailCheck || phoneCheck ? false : true);
                    item.errorToDisplay = errorMessage;
                }
            });
            this.trackedFieldsList = fieldsListAux;
            isErrorfieldError = (emailCheck || phoneCheck ? false : true);
        }

        this.errorfieldsHasError = isErrorfieldError;

    }

    checkIfNumberHasErrors(currentField) {
        let isNumberType = JSON.parse(JSON.stringify(this.checkNumbers));
        let isNumberError = false;
        let errorMessage = '';

        let phoneRegex = /[^0-9()+-]|(?!^)\+/g;

        if (isNumberType.includes(currentField)) {

            let fieldToCheck = '.' + currentField;
            let value = this.template.querySelector(fieldToCheck).value;
            let inputValue = value.replace(/ /g, '');
            let isPhone = !phoneRegex.test(inputValue);

            if (inputValue.length > 0) {
                if (!isPhone) {
                    this.template.querySelector(fieldToCheck).classList.add('slds-has-error');
                    isNumberError = true;
                    errorMessage = this._labels.InvalidValue;
                } else {
                    this.template.querySelector(fieldToCheck).classList.remove('slds-has-error');
                    isNumberError = false;
                    errorMessage = '';
                }
            } else if (currentField === 'Phone' && this.template.querySelector('.Email').value.length === 0) {
                this.template.querySelector(fieldToCheck).classList.add('slds-has-error');
                isNumberError = true;
                errorMessage = this._labels.completeField;
            } else {
                this.template.querySelector(fieldToCheck).classList.remove('slds-has-error');
                isNumberError = false;
                errorMessage = '';
            }

            let fieldsListAux = JSON.parse(JSON.stringify(this.trackedFieldsList));

            fieldsListAux.forEach(function (item) {
                if (item.fieldName === currentField) {
                    item.hasError = isNumberError;
                    item.errorToDisplay = errorMessage;
                }
            });
            this.trackedFieldsList = fieldsListAux;

        } else if (currentField === 'Email') {
            if (this.template.querySelector('.Phone').value.length > 0) {

                let value = this.template.querySelector('.Phone').value;
                let inputValue = value.replace(/ /g, '');
                let isPhone = !phoneRegex.test(inputValue);
                if (!isPhone) {
                    this.template.querySelector('.Phone').classList.add('slds-has-error');
                    isNumberError = true;
                    errorMessage = this._labels.InvalidValue;
                } else {
                    this.template.querySelector('.Phone').classList.remove('slds-has-error');
                    isNumberError = false;
                    errorMessage = '';
                }

                let fieldsListAux = JSON.parse(JSON.stringify(this.trackedFieldsList));

                fieldsListAux.forEach(function (item) {
                    if (item.fieldName === 'Phone') {
                        item.hasError = isNumberError;
                        item.errorToDisplay = errorMessage;
                    }
                });
                this.trackedFieldsList = fieldsListAux;

            }

        }



        this.numberHasError = isNumberError;

    }

    handleServiceSearch(event) {
        let toSearch = event.detail.searchTerm;
        let results = this.services.filter(elem => elem.title.toLowerCase().search(toSearch) !== -1);
        this.template.querySelector('[data-id="servicesearch"]').setSearchResults(results);
    }

    showServiceResults(){
        this.template.querySelector('[data-id="servicesearch"]').setSearchResults(this.services);

    }

    addNewServiceButtonClick(){
        let inputCmp = this.template.querySelector('[data-id="servicesearch"]').getSelection()[0];
        let comp = this.template.querySelector('[data-id="servicesearch"]');
        let lstAdditionalServices = this.lstServices;
        
        comp.focus();        
        if (!lstAdditionalServices.some(service => service.id === inputCmp.id)) {
            lstAdditionalServices.push(JSON.parse(JSON.stringify(inputCmp)));
            this.contactServices.push(inputCmp.id);
        }
        this.lstServices = lstAdditionalServices;         
    }

    removeService(event){
        let lstAdditionalServices = this.lstServices;
        let itemVal = event.target.dataset.item;
        
        if (lstAdditionalServices.some(service => service.id === itemVal)) {
            lstAdditionalServices = lstAdditionalServices.filter(service => service.id !== itemVal);
            this.contactServices = this.contactServices.filter(item => item !== itemVal);
        }

        this.lstServices = lstAdditionalServices;
    }
    
}