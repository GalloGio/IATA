/**
* Created by Tiago Fernandes on 20/08/2019.
*/

import { LightningElement, api, track } from 'lwc';

import getAccountDomains from '@salesforce/apex/PortalProfileCtrl.getAccountDomains';

// LABELS
import ISSP_EMADOMVAL_Title from '@salesforce/label/c.ISSP_EMADOMVAL_Title';
import ISSP_EMADOMVAL_ImportantInformation from '@salesforce/label/c.ISSP_EMADOMVAL_ImportantInformation';
import ISSP_EMADOMVAL_AddBtn from '@salesforce/label/c.ISSP_EMADOMVAL_AddBtn';
import ISSP_EMADOMVAL_TableTitle_EmailDomain from '@salesforce/label/c.ISSP_EMADOMVAL_TableTitle_EmailDomain';
import ISSP_EMADOMVAL_TableTitle_AddedOn from '@salesforce/label/c.ISSP_EMADOMVAL_TableTitle_AddedOn';

export default class PortalEmailDomain extends LightningElement {
    @api recordId;

    @track domainId;
    @track isNewRecord;

    @track columns = [];
    @track domainsList = [];

    @track emailDomainModal = false;

    labels = {
        ISSP_EMADOMVAL_Title,
        ISSP_EMADOMVAL_ImportantInformation,
        ISSP_EMADOMVAL_AddBtn,
        ISSP_EMADOMVAL_TableTitle_EmailDomain,
        ISSP_EMADOMVAL_TableTitle_AddedOn
    }

    connectedCallback() {

        this.columns = [
            {
                label: this.labels.ISSP_EMADOMVAL_TableTitle_EmailDomain,
                fieldName: 'Name'
            },
            {
                label: this.labels.ISSP_EMADOMVAL_TableTitle_AddedOn,
                fieldName: 'CreatedDate',
                type: "date-local",
                typeAttributes: {
                    month: "2-digit",
                    day: "2-digit"
                }
            },
            {
                type: 'button-icon',
                initialWidth: 50,
                typeAttributes: {
                    iconName: 'utility:delete',
                    name: 'Delete',
                    title: 'Delete',
                    variant: 'border-filled',
                    alternativeText: 'Delete'
                }
            },
        ];

        this.getAccountDomainsEmail();

    }

    getAccountDomainsEmail() {
        getAccountDomains({ accountId: this.recordId }).then(result => {
            this.domainsList = result;
        });
    }

    closeModal() {
        this.dispatchEvent(new CustomEvent('closeemaildomain'));
    }

    addDomain() {
        this.isNewRecord = true;
        this.emailDomainModal = true;
    }

    handleRowAction(event) {
        const actionName = event.detail.action.name;
        const row = event.detail.row;

        this.domainId = row.Id;
        this.isNewRecord = false;
        this.emailDomainModal = true;
    }

    closeEmailDomain() {
        this.getAccountDomainsEmail();
        this.emailDomainModal = false;
    }

}