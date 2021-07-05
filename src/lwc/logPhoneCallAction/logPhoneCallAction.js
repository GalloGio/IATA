import { LightningElement, api, track, wire} from 'lwc';
import { getRecord} from 'lightning/uiRecordApi';
import { getPicklistValues} from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import listCaseRecordtypesJSON from '@salesforce/apex/LogPhoneCaseController.listCaseRecordtypesJSON';

import CASE_OBJECT from '@salesforce/schema/Case';
import CASE_CASEAREA_FIELD from '@salesforce/schema/Case.CaseArea__c';
import CASE_LANGUAGE_FIELD from '@salesforce/schema/Case.Case_Language__c';
import CASE_RECORDTYPE_FIELD from '@salesforce/schema/Case.RecordTypeId';
import CASE_CONTACT_FIELD from '@salesforce/schema/Case.ContactId';
import CASE_DESCRIPTION_FIELD from '@salesforce/schema/Case.Description';
import CASE_COUNTRY_FIELD from '@salesforce/schema/Case.BSPCountry__c';
import CASE_REASON_FIELD from '@salesforce/schema/Case.Reason1__c';
import CASE_REGION_FIELD from '@salesforce/schema/Case.Region__c';
import CASE_STATUS_FIELD from '@salesforce/schema/Case.Status';
import CASE_SUBJECT_FIELD from '@salesforce/schema/Case.Subject';
import CASE_TYPE_FIELD from '@salesforce/schema/Case.Type';
import CASE_TYPECUSTOMER_FIELD from '@salesforce/schema/Case.Type_of_customer__c';
import CASE_ACCOUNT_FIELD from '@salesforce/schema/Case.AccountId';

const CASE_FIELDS = [
	CASE_CASEAREA_FIELD,
	CASE_LANGUAGE_FIELD,
	CASE_RECORDTYPE_FIELD,
	CASE_CONTACT_FIELD,
	CASE_DESCRIPTION_FIELD,
	CASE_COUNTRY_FIELD,
	CASE_REASON_FIELD,
	CASE_REGION_FIELD,
	CASE_STATUS_FIELD,
	CASE_SUBJECT_FIELD,
	CASE_TYPE_FIELD,
	CASE_TYPECUSTOMER_FIELD,
	CASE_ACCOUNT_FIELD
];

export default class LogPhoneCallAction extends LightningElement {

	@api recordId;
	@track error;
	@track recordtypeValue;
	@track recordtypePicklist;
	@track caseareaPicklist = [];
	cse;
	defaultCaseArea = '';
	defaultReason = '';
	defaultType = '';
	defaultLanguage = '';
	defaultContact = '';
	defaultCountry = '';
	defaultRegion = '';
	defaultTypecustomer = '';
	defaultAccount = '';
	caseareaValue = '';
	buttonclicked = '';
	loading = true;

	caseObject = CASE_OBJECT;
	casearea = CASE_CASEAREA_FIELD;
	language = CASE_LANGUAGE_FIELD;
	recordtype = CASE_RECORDTYPE_FIELD;
	contact = CASE_CONTACT_FIELD;
	description = CASE_DESCRIPTION_FIELD;
	country = CASE_COUNTRY_FIELD;
	reason = CASE_REASON_FIELD;
	region = CASE_REGION_FIELD;
	status = CASE_STATUS_FIELD;
	subject = CASE_SUBJECT_FIELD;
	type = CASE_TYPE_FIELD;
	typecustomer = CASE_TYPECUSTOMER_FIELD;
	account = CASE_ACCOUNT_FIELD;

	@wire(getRecord, { recordId: '$recordId', fields: CASE_FIELDS})
	wiredCase({ error, data }) {
		if (data) {
			this.cse = data;
			this.defaultSubject = 'Phone call received on the ' + new Date().toDateString();
			this.defaultCaseArea = this.cse.fields.CaseArea__c.value;
			this.defaultReason = this.cse.fields.Reason1__c.value;
			this.defaultType = this.cse.fields.Type.value;
			this.defaultLanguage = this.cse.fields.Case_Language__c.value;
			this.defaultContact = this.cse.fields.ContactId.value;
			this.defaultCountry = this.cse.fields.BSPCountry__c.value;
			this.defaultRegion = this.cse.fields.Region__c.value;
			this.defaultTypecustomer = this.cse.fields.Type_of_customer__c.value;
			this.defaultAccount = this.cse.fields.AccountId.value;
			this.error = undefined;
			this.recordtypeValue = data.recordTypeId;
		} else if (error) {
			this.error = error;
			this.cse = undefined;
			this.recordtypeValue = '';
		}
	}

	@wire(getPicklistValues,{recordTypeId: '$recordtypeValue', fieldApiName: CASE_CASEAREA_FIELD})
	wiredCaseAreaPicklist({ error, data }) {
		if (data) {
			this.caseareaPicklist = data;
			this.loading = false;
		} else if (error) {
			this.error = error;
			this.caseareaPicklist = [];
		}
	};

	handleRecordtypeChange(event) {
		this.recordtypeValue = event.detail.value;
		this.template.querySelectorAll('lightning-input-field').forEach(each => {
			if (each.fieldName === 'CaseArea__c' || each.fieldName === 'Reason__c') {
				each.value = '';
			}
		});
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
		const caseId = event.detail.id;
		const caseNumber = event.detail.fields.CaseNumber.value;
		const toastEvent = new ShowToastEvent({
			"message": "Case {0} was created",
			"messageData": [
				{
					url: '/' + caseId,
					label: caseNumber
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

	connectedCallback(){
		listCaseRecordtypesJSON({})
		.then(results => {
			if(results !== undefined){
				this.recordtypePicklist = [];
				results.forEach(result => {
					this.recordtypePicklist.push({ label: result.Name, value: result.Id });
				});
			}
		}).catch(error => {
			if (error.body.message) {
				handleError();
			}
		});
	}

	closeModal() {
		const closeModal = new CustomEvent('close');
		this.dispatchEvent(closeModal);
	};

}