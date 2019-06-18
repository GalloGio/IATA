import { LightningElement, track, api } from 'lwc';

import getPickListValues from '@salesforce/apex/CSP_Utils.getPickListValues';
import createUserForContact from '@salesforce/apex/ISSP_PortalUserStatusChange.preformActionNewPortal';

import New_Contact_Profile from '@salesforce/label/c.cpcc_New_Contact_Profile';
import Working_Areas from '@salesforce/label/c.cpcc_Working_Areas';
import Contact_Type_Status from '@salesforce/label/c.cpcc_Contact_Type_Status';
import Cancel from '@salesforce/label/c.Cancel';
import Save from '@salesforce/label/c.Save';
import Portal_Administrator from '@salesforce/label/c.cpcc_Portal_Administrator';
import Financial_Assessment_Contact from '@salesforce/label/c.cpcc_Financial_Assessment_Contact';
import Invoice_Contact from '@salesforce/label/c.cpcc_Invoice_Contact';
import Authorised_Signatory from '@salesforce/label/c.cpcc_Authorised_Signatory';
import BSP_CASS_Payment_Contact from '@salesforce/label/c.cpcc_BSP_CASS_Payment_Contact';
import Agent_Credit_Risk from '@salesforce/label/c.cpcc_Agent_Credit_Risk';


export default class PortalProfileCustomBox extends LightningElement {

    @api openModel;
    @api recordId;
    @api objectId;
    @api objectName;
    @api fieldsList = [];

    @track options = [];
    @track selectedvalues = [];

    @track isLoading = true;
    @track userType = 'Approved User';

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
        Agent_Credit_Risk
    };

    get labels() {
        return this._labels;
    }

    set labels(value) {
        this._labels = value;
    }

    // LABEL
    @track contactTypeStatus = [{ checked: false, label: this.labels.Portal_Administrator, APINAME: "PortalAdmin" },
    { checked: false, label: this.labels.Financial_Assessment_Contact, APINAME: "Financial_Assessment_Contact__c" },
    { checked: false, label: this.labels.Invoice_Contact, APINAME: "Invoicing_Contact__c" },
    { checked: false, label: this.labels.Authorised_Signatory, APINAME: "Authorized_Signatory__c" },
    { checked: false, label: this.labels.BSP_CASS_Payment_Contact, APINAME: "BSP_CASS_Payment_contact__c" },
    { checked: false, label: this.labels.Agent_Credit_Risk, APINAME: "Airline_Credit_Risk_Manager__c" }];



    connectedCallback() {

        getPickListValues({ sobj: 'Contact', field: 'Membership_Function__c' }).then(result => {
            this.options = result;
        });

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
        this.isLoading = false;
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
        this.isLoading = false;
    }

    handleSubmit(event) {
        this.isLoading = true;
        event.preventDefault();
        let fields = event.detail.fields;

        let selectedV = JSON.parse(JSON.stringify(this.selectedvalues));
        let selected = '';
        selectedV.forEach(function (item) {
            selected += item + ';';
        });


        let contactTypeStatusLocal = JSON.parse(JSON.stringify(this.contactTypeStatus));

        contactTypeStatusLocal.forEach(function (item) {
            fields[item.APINAME] = item.checked;
        });

        this.userType = (contactTypeStatusLocal[0].checked === true ? 'Approved Admin' : 'Approved User');

        fields.accountId = this.accountId;

        fields.Membership_Function__c = selected;
        fields.User_Portal_Status__c = this.userType;

        this.template.querySelector('lightning-record-edit-form').submit(fields);
    }

    handleSuccess(event) {
        let contact = JSON.parse(JSON.stringify(event.detail));
        let res;
        createUserForContact({ contactId: contact.id, portalStatus: contact.fields.User_Portal_Status__c.value, oldPortalStatus: '' }).then(result => {
            res = result;
            this.isLoading = false;
            this.dispatchEvent(new CustomEvent('closemodalwithsuccess'));
        });

    }

    handleError(event) {
        console.log('ERROR!');
        this.isLoading = false;
    }

}