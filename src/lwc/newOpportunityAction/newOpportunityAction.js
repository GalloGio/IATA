/**
 * Controller for the quick action to create a new opportunity from a case
 */

import { LightningElement, api, track, wire} from 'lwc';
import { getRecord} from 'lightning/uiRecordApi';
import { getObjectInfo } from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

//import custom labels
import errorMsg from '@salesforce/label/c.General_Error_Message';
import NEW_OPP_LABEL from '@salesforce/label/c.New_Opportunity';
import CANCEL_LABEL from '@salesforce/label/c.CSP_Cancel';
import SAVE_LABEL from '@salesforce/label/c.CSP_Save';
import SAVE_CLOSE_LABEL from '@salesforce/label/c.SaveClose';

//import Opportunity fields
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

//import case fields
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
	relatedContactRequired = false;
	defaultOppName = '';
	defaultOppAccount = '';
    defaultOppContact = '';
	buttonclicked = '';
	loading = true;

	newOppLabel = NEW_OPP_LABEL;
	saveLabel = SAVE_LABEL;
	saveCloseLabel = SAVE_CLOSE_LABEL;
	cancelLabel = CANCEL_LABEL;
	
	//map opportunity fields to local variables
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

	//get case record and fields and map it to the opportunity fields
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

	//get the available Opportunity Record Types and populate the picklist
	@wire(getObjectInfo ,{objectApiName: OPP_OBJECT})
	oppObjectInfo({ error, data }) {
		if (data) {
            let optionsValues = [];			
            // map of record type Info
            const rtInfos = data.recordTypeInfos;

            // getting map values
            let rtValues = Object.values(rtInfos);

            for(let i = 0; i < rtValues.length; i++) {
                if(rtValues[i].name !== 'Master' && rtValues[i].available) {
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

	//when the recordType picklist has changed
	handleRecordtypeChange(event) {
		this.recordtypeValue = event.detail.value;
		var label = event.target.options.find(opt => opt.value === event.detail.value).label
		this.relatedContactRequired = (label == 'Opportunity' || label == 'Sales Order');
	}

	//when the close button was pressed
	handleClose(){
		this.closeModal();
	}

	//when the save and close button was pressed
	handleSaveClose(){
		this.buttonclicked = 'SaveClose';
	}

	//when the form is submitted
	handleSubmit(event) {
		event.preventDefault();
		this.loading = true;
		var eventFields = event.detail.fields;
		if (this.buttonclicked === 'SaveClose') {
			eventFields.Status = 'Closed';
		}
		this.template.querySelector('lightning-record-edit-form').submit(eventFields);
	}

	//when the record was successfully created
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

	//when an error has occured
	handleError(event){
		this.loading = false;
		this.dispatchEvent(
			new ShowToastEvent({
				message: errorMsg,
				variant: 'error',
			})
		);
	}

	//to close the modal
	closeModal() {
		const closeModal = new CustomEvent('close');
		this.dispatchEvent(closeModal);
	};

}