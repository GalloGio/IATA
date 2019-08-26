/**
* Created by Tiago Fernandes on 21/08/2019.
*/

import { LightningElement, api, track } from 'lwc';

import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import { deleteRecord } from 'lightning/uiRecordApi';

import { createRecord } from 'lightning/uiRecordApi';
import ACCOUNT_DOMAIN_OBJECT from '@salesforce/schema/Account_Domain__c';
import NAME_FIELD from '@salesforce/schema/Account_Domain__c.Name';
import ACCOUNT_FIELD from '@salesforce/schema/Account_Domain__c.Account__c';

import Confirmation from '@salesforce/label/c.Confirmation';
import ISSP_EMADOMVAL_RemoveConfirmMsg from '@salesforce/label/c.ISSP_EMADOMVAL_RemoveConfirmMsg';

import ISSP_Yes from '@salesforce/label/c.ISSP_Yes';
import ISSP_No from '@salesforce/label/c.ISSP_No';

import ISSP_Submit from '@salesforce/label/c.ISSP_Submit';
import ISSP_Cancel from '@salesforce/label/c.ISSP_Cancel';


import CSP_New_Email_Domain from '@salesforce/label/c.CSP_New_Email_Domain';
import CSP_Success from '@salesforce/label/c.CSP_Success';

import CSP_Record_Deleted from '@salesforce/label/c.CSP_Record_Deleted';
import CSP_Error_while_delete_record from '@salesforce/label/c.CSP_Error_while_delete_record';

import CSP_Account_Domain_Created from '@salesforce/label/c.CSP_Account_Domain_Created';
import CSP_Error_Creating_Record from '@salesforce/label/c.CSP_Error_Creating_Record';


export default class PortalEmailDomainModal extends LightningElement {

    @api accountId;
    @api domainId;
    @api isNewRecord;

    @track title;
    @track message;
    @track btnSuccess;
    @track btnCancel;

    @track showSpinner = false;

    @track domain = '';

    labels = {
        Confirmation,
        ISSP_EMADOMVAL_RemoveConfirmMsg,
        ISSP_Yes,
        ISSP_No,
        ISSP_Submit,
        ISSP_Cancel,
        CSP_New_Email_Domain,
        CSP_Success,
        CSP_Record_Deleted,
        CSP_Error_while_delete_record,
        CSP_Account_Domain_Created,
        CSP_Error_Creating_Record
    }

    connectedCallback() {
        if (!this.isNewRecord) {
            this.title = this.labels.Confirmation;
            this.message = this.labels.ISSP_EMADOMVAL_RemoveConfirmMsg;
            this.btnSuccess = this.labels.ISSP_Yes;
            this.btnCancel = this.labels.ISSP_No;
        } else {
            this.title = this.labels.CSP_New_Email_Domain;
            this.message = "";
            this.btnSuccess = this.labels.ISSP_Submit;
            this.btnCancel = this.labels.ISSP_Cancel;
        }
    }

    closeModal() {
        this.dispatchEvent(new CustomEvent('closeemaildomainmodal'));
    }

    cancel() {
        this.closeModal();
    }

    addDomain() {
        if (!this.isNewRecord) {
            this.showSpinner = true;
            this.deleteAccount();
        } else {
            this.showSpinner = true;
            this.createAccountDomain();
        }
    }

    deleteAccount() {
        deleteRecord(this.domainId)
            .then(() => {
                this.displayToast(this.labels.CSP_Success, this.labels.CSP_Record_Deleted, 'success');
                this.closeModal();
            })
            .catch(error => {
                this.displayToast(this.labels.CSP_Error_while_delete_record, error.message, 'error');
                this.closeModal();
            });
    }

    handleDomainChange(event) {
        this.domain = event.target.value;
    }

    createAccountDomain() {
        const fields = {};
        fields[NAME_FIELD.fieldApiName] = this.domain;
        fields[ACCOUNT_FIELD.fieldApiName] = this.accountId;
        const recordInput = { apiName: ACCOUNT_DOMAIN_OBJECT.objectApiName, fields };
        createRecord(recordInput)
            .then(account => {
                this.accountId = account.id;
                this.displayToast(this.labels.CSP_Success, this.labels.CSP_Account_Domain_Created, 'success');
                this.closeModal();
            })
            .catch(error => {
                this.displayToast(this.labels.CSP_Error_Creating_Record, error.body.message, 'error');
                this.closeModal();
            });
    }

    displayToast(title, message, variant) {
        this.dispatchEvent(
            new ShowToastEvent({
                title: title,
                message: message,
                variant: variant,
            }),
        );
    }

}