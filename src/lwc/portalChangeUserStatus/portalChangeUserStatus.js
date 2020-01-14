import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { reduceErrors } from 'c/ldsUtils';

import getRejectionReasonsValues from '@salesforce/apex/ISSP_PortalUserStatusChange.getRejectionReasons';
import getUserPortalStatusOptionsValues from '@salesforce/apex/ISSP_PortalUserStatusChange.getUserPortalStatusOptions';
import hasIdCard from '@salesforce/apex/ISSP_PortalUserStatusChange.hasIdCard';
import saveNewAccess from '@salesforce/apex/ISSP_PortalUserStatusChange.saveNewStatusAura';

import PORTAL_STATUS_FLD from '@salesforce/schema/Contact.User_Portal_Status__c'
import INACTIVATION_REASON_FLD from '@salesforce/schema/Contact.Portal_Inactivation_Reason__c'
import COMMUNITY_FLD from '@salesforce/schema/Contact.Community__c'

import changeUserPortalStatusLABEL from '@salesforce/label/c.ISSP_ChangeUserPortalStatus';
import submitLABEL from '@salesforce/label/c.ISSP_Confirm';
import cancelLABEL from '@salesforce/label/c.ISSP_Cancel';
import activeIdCardUserLABEL from '@salesforce/label/c.ISSP_InactiveUser_IdCard';
import confirmContinueLABEL from '@salesforce/label/c.ISSP_SureToContinue';
import selectPortalStatusLABEL from '@salesforce/label/c.CSP_SelectPortalStatus';
import selectReasonLABEL from '@salesforce/label/c.CSP_selectReason';
import reasonLABEL from '@salesforce/label/c.ICCS_Reason_Label';
import communityLABEL from '@salesforce/label/c.CSP_Community';
import portalStatusLABEL from '@salesforce/label/c.CSP_Portal_Status';
import remove from '@salesforce/label/c.Button_Remove';
import contact from '@salesforce/label/c.ISSP_Contact';
import innactivationReason from '@salesforce/label/c.ISSP_ReasonInactivation';
import removeContactReason from '@salesforce/label/c.CSP_RemoveContact_Reason';



const FIELDS = [PORTAL_STATUS_FLD, INACTIVATION_REASON_FLD, COMMUNITY_FLD];

const DEACTIVATED_VAL = "Deactivated"


export default class ChangeUserPortalStatus extends LightningElement {
    @api recordId;
    @track removeContactLocal = false;

    @wire(getRejectionReasonsValues) rejectRegionsOptions;
    @wire(getUserPortalStatusOptionsValues, { contactId: "$recordId" }) portalStatusOptions;
    @wire(hasIdCard, { contactId: "$recordId" }) hasActiveCardId;
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS }) contactRecord;

    @track selectedCommunity = 'ISS Customer Portal';
    @track selectedPortalStatus = '';
    @track selectedReason = '';
    @track loading = false;
    @track inactiveStatus = false;

    @track hasError = false
    @track errorMessage = '';

    label = {
        changeUserPortalStatusLABEL,
        submitLABEL,
        cancelLABEL,
        activeIdCardUserLABEL,
        confirmContinueLABEL,
        selectReasonLABEL,
        selectPortalStatusLABEL,
        reasonLABEL,
        communityLABEL,
        portalStatusLABEL,
        remove,
        contact,
        innactivationReason,
        removeContactReason
    }

    @api
    get removeContact(){
        return this.removeContactLocal;
    }

    set removeContact(value){
        this.removeContactLocal = value;

        if(value == true){
            this.inactiveStatus = true;
        }
    }

    get CommunityVal() {
        var val = getFieldValue(this.contactRecord.data, COMMUNITY_FLD);
        if (this.selectedCommunity !== undefined && this.selectedCommunity !== '') val = this.selectedCommunity;
        return val;
    }

    get PortalStatVal() {
        //If removing contact, deactivated is set by default, select is disabled
        var val = this.removeContact ? DEACTIVATED_VAL : getFieldValue(this.contactRecord.data, PORTAL_STATUS_FLD);

        if (this.selectedPortalStatus !== undefined && this.selectedPortalStatus !== '') val = this.selectedPortalStatus;

        if (val === DEACTIVATED_VAL) {
            this.inactiveStatus = true;
        } else {
            this.inactiveStatus = false;
        }

        return val;
    }

    get InactReasonVal() {
        var val = getFieldValue(this.contactRecord.data, INACTIVATION_REASON_FLD);
        if (this.selectedReason !== undefined && this.selectedReason !== '') val = this.selectedReason;
        return val;
    }

    get renderIdMessage() {
        if (this.hasActiveCardId === undefined) return false;
        return this.inactiveStatus && this.hasActiveCardId.data;
    }

    get reasonLabel(){
        return this.removeContact ? this.label.removeContactReason : this.label.reasonLABEL;
    }

    get titleLabel(){
        return this.removeContact ? (this.label.remove + ' '+this.label.contact) : this.label.changeUserPortalStatusLABEL;
    }

    handlePortalStatusChange(event) {
        // Get the string of the "value" attribute on the selected option
        this.selectedPortalStatus = event.detail.value;
        this.hasError = false;
        this.selectedReason = null;
        if (this.selectedPortalStatus === DEACTIVATED_VAL) {
            this.inactiveStatus = true;
        } else {
            this.inactiveStatus = false;
            this.selectedReason = [];
        }
    }

    handleReasonCommChange(event) {
        // Get the string of the "value" attribute on the selected option
        this.selectedReason = event.detail.value;
        this.hasError = false;
    }

    get noSelected() {
        var result = true;
        if (this.PortalStatVal != null && this.PortalStatVal !== DEACTIVATED_VAL)
            result = false;
        else if (this.PortalStatVal === DEACTIVATED_VAL && this.InactReasonVal != null
            && this.selectedReason !== null && this.selectedReason !== '')
            result = false;
        return result;
    }


    submitAction() {
        if (this.hasActiveCardId.data && this.inactiveStatus) {
            let conf = confirm(this.label.activeIdCardUserLABEL + this.label.confirmContinueLABEL);
            if (conf) {
                this.saveNewStatus();
            }
        } else {
            this.saveNewStatus();
        }
    }

    saveNewStatus() {

        if(this.removeContact){
            this.selectedPortalStatus = DEACTIVATED_VAL;
        }

        this.loading = true;
        saveNewAccess({
            community: this.selectedCommunity,
            newValue: this.selectedPortalStatus,
            contactId: this.recordId,
            inactivationReason: this.selectedReason.length === 0 ? '' : this.selectedReason
        })
            .then(msg => {
                this.loading = false;
                if (msg.isSuccess) {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Success',
                            message: msg.successMsg,
                            variant: 'success'
                        })
                    );
                    this.dispatchEvent(new CustomEvent('refreshview'));
                } else {
                    this.hasError = true;
                    this.errorMessage = msg.errorMsg;
                }
                // this.selected = [];
            })
            .catch(error => {
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Error',
                        message: reduceErrors(error).join(', '),
                        variant: 'error'
                    })
                );
                this.loading = false;
            });
        //}
    }

    closeModal() {
        this.dispatchEvent(new CustomEvent('closemodal'));
    }
}