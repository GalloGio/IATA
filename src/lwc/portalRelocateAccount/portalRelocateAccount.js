import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import searchRelatedAccounts from '@salesforce/apex/PortalProfileCtrl.getMapHierarchyAccounts';
import relocateAccount from '@salesforce/apex/PortalProfileCtrl.RelocateContact';


import ISSP_Relocate_Contact from '@salesforce/label/c.ISSP_Relocate_Contact';
import submitLABEL from '@salesforce/label/c.ISSP_Confirm';
import cancelLABEL from '@salesforce/label/c.ISSP_Cancel';
import remove from '@salesforce/label/c.Button_Remove';
import contact from '@salesforce/label/c.ISSP_Contact';

import ISSP_Relocate_Move_To from '@salesforce/label/c.ISSP_Relocate_Move_To';
import ISSP_Relocate_Select_Account from '@salesforce/label/c.ISSP_Relocate_Select_Account';
import ICCS_Account_Name_Label from '@salesforce/label/c.ICCS_Account_Name_Label';
import ISSP_CompanyAddressInformation from '@salesforce/label/c.ISSP_CompanyAddressInformation';
import csp_AccountRelocateSuccess from '@salesforce/label/c.csp_AccountRelocateSuccess';
import ISSP_Relocate_Failed from '@salesforce/label/c.ISSP_Relocate_Failed';
import CSP_Error_Message_Mandatory_Fields_Contact from '@salesforce/label/c.CSP_Error_Message_Mandatory_Fields_Contact';

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

    label = {
        submitLABEL,
        cancelLABEL,
        remove,
        contact,
        ISSP_Relocate_Contact,
        ISSP_Relocate_Move_To,
        ISSP_Relocate_Select_Account,
        ICCS_Account_Name_Label,
        ISSP_CompanyAddressInformation,
        csp_AccountRelocateSuccess,
        ISSP_Relocate_Failed,
        CSP_Error_Message_Mandatory_Fields_Contact
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
                    if (result === 'Success') {
                        this.resultMessageLabel = this.label.csp_AccountRelocateSuccess;
                    } else if (result === this.label.ISSP_Relocate_Failed) {
                        this.resultMessageLabel = this.label.ISSP_Relocate_Failed;
                    }

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

        if (this.resultMessage) {
            this.dispatchEvent(new CustomEvent('refreshview'));
            this.dispatchEvent(new CustomEvent('closemodal'));
        } else {
            this.dispatchEvent(new CustomEvent('closemodal'));
        }
    }
}