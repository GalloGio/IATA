import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { updateRecord } from 'lightning/uiRecordApi';

import relocateAccount from '@salesforce/apex/PortalProfileCtrl.relocateContact';

import ISSP_Relocate_Contact from '@salesforce/label/c.ISSP_Relocate_Contact';
import submitLABEL from '@salesforce/label/c.ISSP_Confirm';
import cancelLABEL from '@salesforce/label/c.ISSP_Cancel';
import remove from '@salesforce/label/c.Button_Remove';
import contact from '@salesforce/label/c.ISSP_Contact';
import ISSP_Relocate_Move_To from '@salesforce/label/c.ISSP_Relocate_Move_To';
import ISSP_Relocate_Select_Account from '@salesforce/label/c.ISSP_Relocate_Select_Account';
import ISSP_Relocate_No_Accounts from '@salesforce/label/c.ISSP_Relocate_No_Accounts';
import ICCS_Account_Name_Label from '@salesforce/label/c.ICCS_Account_Name_Label';
import ISSP_CompanyAddressInformation from '@salesforce/label/c.ISSP_CompanyAddressInformation';
import csp_AccountRelocateSuccess from '@salesforce/label/c.csp_AccountRelocateSuccess';
import ISSP_Relocate_Failed from '@salesforce/label/c.ISSP_Relocate_Failed';
import CSP_Error_Message_Mandatory_Fields_Contact from '@salesforce/label/c.CSP_Error_Message_Mandatory_Fields_Contact';
import CSP_Continue from '@salesforce/label/c.CSP_Continue';

export default class ChangeUserPortalStatus extends LightningElement {
    @api recordId;
    @api objectApiName;
    @api relatedAccounts;

    @track hasError = false
    @track loading = false
    @track errorMessage = '';
    @track relatedAccountOptions = [];
    @track relatedAccountValue;
    @track showAccountInfo = false;
    @track AccountInfo;
    @track myResults = [];
    @track resultMessage = false;
    @track resultMessageLabel = '';
    @track selectAccountPlaceholder;

    label = {
        submitLABEL,
        cancelLABEL,
        remove,
        contact,
        ISSP_Relocate_Contact,
        ISSP_Relocate_Move_To,
        ISSP_Relocate_Select_Account,
        ISSP_Relocate_No_Accounts,
        ICCS_Account_Name_Label,
        ISSP_CompanyAddressInformation,
        csp_AccountRelocateSuccess,
        ISSP_Relocate_Failed,
        CSP_Error_Message_Mandatory_Fields_Contact,
        CSP_Continue
    }

    get titleLabel() {
        return this.label.ISSP_Relocate_Contact;
    }

    connectedCallback() {
        let myRelatedAccountOptions = [];

        this.myResult = JSON.parse(JSON.stringify(this.relatedAccounts));

        //Auxiliary Map
        const map = new Map();
        //Array to consume SubTopic Options
        //first element on the picklist
        for (const item of this.myResult) {
            if (!map.has(item.Name)) {
                myRelatedAccountOptions.push({
                    label: (item.Site === undefined ? '' : item.Site) + ' ' + (item.Name === undefined ? '' : item.Name) + ' ' + (item.IATA_ISO_Country__c === undefined ? '' : item.IATA_ISO_Country__r.Name),
                    value: item.Id
                });
            }
        }
        this.relatedAccountOptions = myRelatedAccountOptions;

        if(this.hasNoOptions) {
            this.selectAccountPlaceholder = this.label.ISSP_Relocate_No_Accounts;
        } else {
            this.selectAccountPlaceholder = this.label.ISSP_Relocate_Select_Account;
        }
    }

    get hasNoOptions() {
        if(this.relatedAccountOptions === undefined || this.relatedAccountOptions === null || this.relatedAccountOptions.length === 0) {
            return true;
        }
        return false;
    }

    get isConfirmDisabled() {
        if(this.hasNoOptions || !this.relatedAccountValue) {
            return true;
        }
        return false;
    }

    handleRelatedAccountChange(event) {
        this.relatedAccountValue = event.target.value;
        if (this.relatedAccountValue) {
            this.showAccountInfo = true;
            this.fillAccountInfo(this.relatedAccountValue);
        } else {
            this.showAccountInfo = false;
        }
    }

    fillAccountInfo(relatedAccountValue) {
        this.AccountInfo = this.myResult.filter(obj => obj.Id === relatedAccountValue)[0];
    }

    submitAction() {
        if (this.AccountInfo !== undefined) {
            let account = this.AccountInfo;
            let contactId = this.recordId;
            this.loading = true;
            
            relocateAccount({ acc: account, contactId: contactId })
            .then(result => {
                this.loading = false;
                this.resultMessage = true;
                
                this.resultMessageLabel = this.label.csp_AccountRelocateSuccess;

                // a way (WORKAROUND) to refresh data in standard components
                updateRecord({ fields: { Id: this.recordId } });
            })
            .catch(error => {
                console.error('relocate account error', JSON.parse(JSON.stringify(error)));
                this.loading = false;
                this.dispatchEvent(
                    new ShowToastEvent({
                        title: this.label.ISSP_Relocate_Contact,
                        message: this.label.ISSP_Relocate_Failed,
                        variant: 'error'
                    })
                );
            });
        } else {
            this.dispatchEvent(
                new ShowToastEvent({
                    title: this.label.PKB2_js_error,
                    message: this.label.CSP_Error_Message_Mandatory_Fields_Contact,
                    variant: 'error'
                })
            );
        }
    }

    closeModal() {
        this.dispatchEvent(new CustomEvent('closemodal'));
    }
}