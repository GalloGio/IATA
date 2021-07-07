import { LightningElement, api, track, wire} from 'lwc';
import { getRecord} from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import OPP_OBJECT from '@salesforce/schema/Opportunity';
import OPP_RECORDTYPE_FIELD from '@salesforce/schema/Opportunity.RecordTypeId';
import OPP_NAME_FIELD from '@salesforce/schema/Opportunity.Name';
import OPP_DESCRIPTION_FIELD from '@salesforce/schema/Opportunity.Description';
import OPP_ACCOUNT_FIELD from '@salesforce/schema/Opportunity.AccountId';
import OPP_STAGE_FIELD from '@salesforce/schema/Opportunity.StageName';
import OPP_AMOUNT_FIELD from '@salesforce/schema/Opportunity.Amount';
import OPP_PRIMARYCAMPAIGN_FIELD from '@salesforce/schema/Opportunity.CampaignId';
import OPP_TYPE_FIELD from '@salesforce/schema/Opportunity.Type';
import OPP_CLOSEDATE_FIELD from '@salesforce/schema/Opportunity.CloseDate';
import OPP_LEADSOURCE_FIELD from '@salesforce/schema/Opportunity.LeadSource';
import OPP_CONTACT_FIELD from '@salesforce/schema/Opportunity.Related_Contact__c';

import CASE_OBJECT from '@salesforce/schema/Case';
import CASE_CONTACT_FIELD from '@salesforce/schema/Case.ContactId';
import CASE_ACCOUNT_FIELD from '@salesforce/schema/Case.AccountId';
import CASE_ACCOUNTNAME_FIELD from '@salesforce/schema/Case.Account.Name';
const CASE_FIELDS = [
	CASE_CONTACT_FIELD,
	CASE_ACCOUNT_FIELD,
	CASE_ACCOUNTNAME_FIELD
];


export default class NewOpportunityAction extends LightningElement {

	@api recordId;
	@track error;
	@track recordtypeValue;
	@track recordtypePicklist;
	cse;
	defaultOppName = '';
	defaultOppAccount = '';
    defaultOppContact = '';
	buttonclicked = '';
	loading = true;

	oppObject = OPP_OBJECT;
    oppRecType = OPP_RECORDTYPE_FIELD;
    oppName = OPP_NAME_FIELD;
	oppDescription = OPP_DESCRIPTION_FIELD;
	oppAccount = OPP_ACCOUNT_FIELD;
	oppStage = OPP_STAGE_FIELD;
	oppAmount = OPP_AMOUNT_FIELD;
	oppPrimaryCampaign = OPP_PRIMARYCAMPAIGN_FIELD;
	oppType = OPP_TYPE_FIELD;
	oppCloseDate = OPP_CLOSEDATE_FIELD;
	oppLeadSource = OPP_LEADSOURCE_FIELD;
	oppContact = OPP_CONTACT_FIELD;


	@wire(getRecord, { recordId: '$recordId', fields: CASE_FIELDS})
	wiredCase({ error, data }) {
		if (data) {
			this.defaultOppName = data.fields.Account.value.fields.Name.value;
			this.defaultOppAccount = data.fields.AccountId.value;
			this.defaultOppContact = data.fields.ContactId.value;
			this.error = undefined;
		} else if (error) {
			this.error = error;
		}
	}

	@wire(getObjectInfo ,{objectApiName: OPP_OBJECT})
	oppObjectInfo({ error, data }) {
		if (data) {
            let optionsValues = [];			
            // map of record type Info
            const rtInfos = data.recordTypeInfos;

            // getting map values
            let rtValues = Object.values(rtInfos);

            for(let i = 0; i < rtValues.length; i++) {
                if(rtValues[i].name !== 'Master') {
                    optionsValues.push({
                        label: rtValues[i].name,
                        value: rtValues[i].recordTypeId
                    })
                }
            }

            this.recordtypePicklist = optionsValues;

			this.loading = false;
		} else if (error) {
			this.error = error;
			this.recordtypePicklist = [];
		}
	};

	handleRecordtypeChange(event) {
		this.recordtypeValue = event.detail.value;
	}

	handleClose(){
		this.closeModal();
	}

	handleSaveClose(){
		this.buttonclicked = 'SaveClose';
	}

	handleSubmit(event) {
		event.preventDefault();
		this.loading = true;
		var eventFields = event.detail.fields;
		if (this.buttonclicked === 'SaveClose') {
			eventFields.Status = 'Closed';
		}
		this.template.querySelector('lightning-record-edit-form').submit(eventFields);
	}

	handleSuccess(event){
		this.loading = false;
		const oppId = event.detail.id;
		const oppName = event.detail.fields.Name.value;
		const toastEvent = new ShowToastEvent({
			"message": "Opportunity {0} was created",
			"messageData": [
				{
					url: '/' + oppId,
					label: oppName
				}
			],
			variant: 'success'
		});
		this.dispatchEvent(toastEvent);

		this.closeModal();
	}

	handleError(event){
		this.loading = false;
		this.dispatchEvent(
			new ShowToastEvent({
				message: 'An error has occured, please contact your administrator',
				variant: 'error',
			})
		);
	}

	closeModal() {
		const closeModal = new CustomEvent('close');
		this.dispatchEvent(closeModal);
	};

}