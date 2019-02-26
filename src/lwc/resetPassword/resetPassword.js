import { LightningElement, api, track, wire } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import noEligibleUserLABEL from '@salesforce/label/c.NoEligibleUserForContact';
import confirmSendMsgLABEL from '@salesforce/label/c.resetPasswordConfirmMessage';
import communityLABEL from '@salesforce/label/c.CSP_Community';
import selectCommunityLABEL from '@salesforce/label/c.CSP_SelectCommunity';

import sendEmail from '@salesforce/apex/ChooseCommunityCtrl.SendEmail';
import getCommunitiesValues from '@salesforce/apex/ChooseCommunityCtrl.getAvalaibleCommunities';
import hasValidUser from '@salesforce/apex/ChooseCommunityCtrl.hasValidUser';


export default class ResetPassword extends LightningElement {
    @api recordId;
    @wire(getCommunitiesValues) options;
    @wire(hasValidUser, { contactId: '$recordId' }) enableDropDown;
    @track selected = [];
    @track loading=false;
    contactFields = ['Salutation', 'Function__c', 'FirstName', 'LastName', 'Email', 'AccountName', 'ISO_Country__c', 'User_Portal_Status__c', 'Phone'];
    passwordFields = ['Community__c'];

    label = {
        noEligibleUserLABEL,
        confirmSendMsgLABEL,
        communityLABEL,
        selectCommunityLABEL
    };


    handleChange(event) {
        // Get the string of the "value" attribute on the selected option
        this.selected = event.detail.value;
    }
    get noUser() {
        return !this.enableDropDown.data;
    }

    get noSelected() {
        return (this.selected && this.selected.length) == 0 ? true : false;
    }


    sendPassword() {
        var conf=confirm(this.label.confirmSendMsgLABEL);
        if(conf){
            this.loading=true;
            sendEmail({ contactId: this.recordId, community: this.selected })
            .then(() => {
                const closeQuickActionEvent = new CustomEvent('closeQuickAction');
                // Fires the custom event
                this.dispatchEvent(closeQuickActionEvent);
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: 'Success',
                        message: 'Password Sent!',
                        variant: 'success'
                    })
                    );
                this.loading=false;
                this.selected = [];
                
                })
                .catch(error => {
                    this.dispatchEvent(
                        new ShowToastEvent({
                            title: 'Error',
                            message: reduceErrors(error).join(', '),
                            variant: 'error'
                        })
                    );
                });
            }
        }
    }