import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { getRecord, getFieldValue } from 'lightning/uiRecordApi';
import { reduceErrors } from 'c/ldsUtils';

import getCommunitiesValues from '@salesforce/apex/ISSP_PortalUserStatusChange.getAvalaibleCommunities';
import getRejectionReasonsValues from '@salesforce/apex/ISSP_PortalUserStatusChange.getRejectionReasons';
import getUserPortalStatusOptionsValues from '@salesforce/apex/ISSP_PortalUserStatusChange.getUserPortalStatusOptions';
import hasIdCard from '@salesforce/apex/ISSP_PortalUserStatusChange.hasIdCard';
import saveNewAccess from '@salesforce/apex/ISSP_PortalUserStatusChange.saveNewStatusAura';

import PORTAL_STATUS_FLD from '@salesforce/schema/Contact.User_Portal_Status__c'
import INACTIVATION_REASON_FLD from '@salesforce/schema/Contact.Portal_Inactivation_Reason__c'
import COMMUNITY_FLD from '@salesforce/schema/Contact.Community__c'

import changeUserPortalStatusLABEL from '@salesforce/label/c.ISSP_ChangeUserPortalStatus';
import submitLABEL from '@salesforce/label/c.ISSP_Submit';
import activeIdCardUserLABEL from '@salesforce/label/c.ISSP_InactiveUser_IdCard';
import confirmContinueLABEL from '@salesforce/label/c.ISSP_SureToContinue';
import selectCommunityLABEL from '@salesforce/label/c.CSP_SelectCommunity';
import selectPortalStatusLABEL from '@salesforce/label/c.CSP_SelectPortalStatus';
import selectReasonLABEL from '@salesforce/label/c.CSP_selectReason';
import reasonLABEL from '@salesforce/label/c.ICCS_Reason_Label';
import communityLABEL from '@salesforce/label/c.CSP_Community';
import portalStatusLABEL from '@salesforce/label/c.CSP_Portal_Status';

const FIELDS = [PORTAL_STATUS_FLD, INACTIVATION_REASON_FLD, COMMUNITY_FLD];

const DEACTIVATED_VAL = "Deactivated"


export default class ChangeUserPortalStatus extends LightningElement {
    @api recordId;
    @wire(getCommunitiesValues) communityOptions;
    @wire(getRejectionReasonsValues) rejectRegionsOptions;
    @wire(getUserPortalStatusOptionsValues, { contactId: "$recordId" }) portalStatusOptions;
    @wire(hasIdCard, { contactId: "$recordId" }) hasActiveCardId;
    @wire(getRecord, { recordId: '$recordId', fields: FIELDS }) contactRecord;

    @track selectedCommunity = '';
    @track selectedPortalStatus = '';
    @track selectedReason = '';
    @track loading = false;
    @track inactiveStatus = false;

    label = {
        changeUserPortalStatusLABEL,
        submitLABEL,
        activeIdCardUserLABEL,
        confirmContinueLABEL,
        selectReasonLABEL,
        selectPortalStatusLABEL,
        selectCommunityLABEL,
        reasonLABEL,
        communityLABEL,
        portalStatusLABEL
    }
  
    get CommunityVal() {
        var val = getFieldValue(this.contactRecord.data, COMMUNITY_FLD);
        if (this.selectedCommunity != undefined && this.selectedCommunity != '') val = this.selectedCommunity;
        return val;
    }

    get PortalStatVal() {
        var val = getFieldValue(this.contactRecord.data, PORTAL_STATUS_FLD);
        if (this.selectedPortalStatus != undefined && this.selectedPortalStatus != '') val = this.selectedPortalStatus;

        if (val == DEACTIVATED_VAL) {
            this.inactiveStatus = true;
        } else {
            this.inactiveStatus = false;
        }
        return val;
    }

    get InactReasonVal() {
        var val = getFieldValue(this.contactRecord.data, INACTIVATION_REASON_FLD);
        if (this.selectedReason != undefined && this.selectedReason != '') val = this.selectedReason;
        return val;
    }

    get renderIdMessage(){
        console.log(this.hasActiveCardId);
        if(this.hasActiveCardId==undefined) return false;
        return this.inactiveStatus && this.hasActiveCardId.data ;
    }

   

    handleCommChange(event) {
        // Get the string of the "value" attribute on the selected option
        this.selectedCommunity = event.detail.value;

    }

    handlePortalStatusChange(event) {
        // Get the string of the "value" attribute on the selected option
        this.selectedPortalStatus = event.detail.value;

        if (this.selectedPortalStatus == DEACTIVATED_VAL) {
            this.inactiveStatus = true;
        } else {
            this.inactiveStatus = false;
            this.selectedReason = [];
        }
    }

    handleReasonCommChange(event) {
        // Get the string of the "value" attribute on the selected option
        this.selectedReason = event.detail.value;

    }

    get noSelected() {
        var result = true;
        console.log(this.CommunityVal);
        if (this.CommunityVal != null && this.PortalStatVal != null && this.PortalStatVal != DEACTIVATED_VAL)
            result = false;
        else if (this.CommunityVal != null && this.PortalStatVal == DEACTIVATED_VAL && this.InactReasonVal != null)
            result = false;
        return result;
    }


    submitAction(){
        if(this.hasActiveCardId.data && this.inactiveStatus){
            var conf=confirm(this.label.activeIdCardUserLABEL+ this.label.confirmContinueLABEL);
            if(conf){
                this.saveNewStatus();
            }
        }else{
            this.saveNewStatus();
        }
    }

    saveNewStatus() {
        this.loading = true;
        saveNewAccess({
            community: this.selectedCommunity,
            newValue: this.selectedPortalStatus,
            contactId: this.recordId,
            inactivationReason: this.selectedReason.length == 0 ? '' : this.selectedReason
        })
            .then(msg => {
                const closeQuickActionEvent = new CustomEvent('closeQuickAction');
                // Fires the custom event
                this.dispatchEvent(closeQuickActionEvent);
                this.dispatchEvent(

                    new ShowToastEvent({
                        title: msg.isSuccess ? 'Success' : 'Error',
                        message: msg.isSuccess ? msg.successMsg : msg.errorMsg,
                        variant: msg.isSuccess ? 'success' : 'error'
                    })
                );
                this.loading = false;

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
}