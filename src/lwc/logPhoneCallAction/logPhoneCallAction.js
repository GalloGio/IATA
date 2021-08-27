import { LightningElement, api, track, wire} from 'lwc';
import { getRecord} from 'lightning/uiRecordApi';
import { getPicklistValues} from 'lightning/uiObjectInfoApi';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import listCaseRecordtypesJSON from '@salesforce/apex/LogPhoneCaseController.listCaseRecordtypesJSON';
import getDefaultRecordType from '@salesforce/apex/LogPhoneCaseController.getDefaultRecordType';

import CASE_OBJECT from '@salesforce/schema/Case';
import CASE_CASEAREA_FIELD from '@salesforce/schema/Case.CaseArea__c';
import CASE_LANGUAGE_FIELD from '@salesforce/schema/Case.Case_Language__c';
import CASE_RECORDTYPE_FIELD from '@salesforce/schema/Case.RecordTypeId';
import CASE_CASERECORDTYPE_FIELD from '@salesforce/schema/Case.Case_record_type__c';
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
	CASE_CASERECORDTYPE_FIELD,
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

import CONTACT_ID_FIELD from '@salesforce/schema/Contact.Id';
import CONTACT_ACCOUNTID_FIELD from '@salesforce/schema/Contact.AccountId';
import CONTACT_ACCOUNT_COUNTRYNAME_FIELD from '@salesforce/schema/Contact.Account.IATA_ISO_Country__r.Name';
import CONTACT_ACCOUNT_COUNTRYREGION_FIELD from '@salesforce/schema/Contact.Account.Region_formula__c';
import CONTACT_ACCOUNTTYPE_FIELD from '@salesforce/schema/Contact.Account.Account_Type__c';
import CONTACT_PREFERRED_LANGUAGE_FIELD from '@salesforce/schema/Contact.Preferred_Language__c';

const CONTACT_FIELDS = [
	CONTACT_ID_FIELD,
	CONTACT_ACCOUNTID_FIELD,
	CONTACT_ACCOUNT_COUNTRYNAME_FIELD,
	CONTACT_ACCOUNT_COUNTRYREGION_FIELD,
	CONTACT_ACCOUNTTYPE_FIELD,
	CONTACT_PREFERRED_LANGUAGE_FIELD
]

const SOBJECT_FIELDS = new Map([
	['500', CASE_FIELDS],
	['003', CONTACT_FIELDS]
]);

export default class LogPhoneCallAction extends LightningElement {

	@api recordId;
	@track error;
	@track recordtypeValue;
	@track recordtypePicklist;
	mapRecordtypePicklist;
	@track caseareaPicklist = [];

	@api get objectFields() {
		return SOBJECT_FIELDS.get(this.recordId.substr(0,3));
	}

	defaultCaseArea = '';
	defaultReason = '';
	defaultType = '';
	defaultLanguage = '';
	defaultContact = '';
	defaultCountry = '';
	defaultRegion = '';
	defaultTypecustomer = '';
	defaultAccount = '';
	defaultCaseRecordtype = '';
	caseareaValue = '';
	buttonclicked = '';
	loading = true;

	caseObject = CASE_OBJECT;
	casearea = CASE_CASEAREA_FIELD;
	language = CASE_LANGUAGE_FIELD;
	recordtype = CASE_RECORDTYPE_FIELD;
	caserecordtype = CASE_CASERECORDTYPE_FIELD;
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

	@wire(getRecord, { recordId: '$recordId', fields: '$objectFields'})
	wiredCase({ error, data }) {
		if (data) {
			if (data.apiName === "Contact") {
				try {
					let contact = data;
					let account = contact.fields.Account.value;
					let country = account.fields.IATA_ISO_Country__r.value;
					this.defaultSubject = 'Phone call received on the ' + new Date().toDateString();
					this.defaultCaseArea = '';
					this.defaultReason = '';
					this.defaultType = account.fields.Account_Type__c.value;
					this.defaultLanguage = contact.fields.Preferred_Language__c.value;
					this.defaultContact = contact.id;
					this.defaultCountry = country.fields.Name.value;
					this.defaultRegion = account.fields.Region_formula__c.value;
					this.defaultTypecustomer = account.fields.Account_Type__c.value;
					this.defaultAccount = account.id;
				} catch(e) {}
				this.error = undefined;
			}
			if (data.apiName === "Case") {
				try {
					let cse = data.fields;
					this.defaultSubject = 'Phone call received on the ' + new Date().toDateString();
					this.defaultCaseArea = cse.CaseArea__c.value;
					this.defaultReason = cse.Reason1__c.value;
					this.defaultType = cse.Type.value;
					this.defaultLanguage = cse.Case_Language__c.value;
					this.defaultContact = cse.ContactId.value;
					this.defaultCountry = cse.BSPCountry__c.value;
					this.defaultRegion = cse.Region__c.value;
					this.defaultTypecustomer = cse.Type_of_customer__c.value;
					this.defaultAccount = cse.AccountId.value;
					this.recordtypeValue = data.recordTypeId;
					this.defaultCaseRecordtype = this.mapRecordtypePicklist.get(this.recordtypeValue);
				} catch(e) {}
				this.error = undefined;
			}

		} else if (error) {
			this.error = error;
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
			if (each.fieldName === 'Case_record_type__c') {
				each.value = this.mapRecordtypePicklist.get(this.recordtypeValue);
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
		let eventFields = event.detail.fields;
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
				this.mapRecordtypePicklist = new Map();
				results.forEach(result => {
					this.recordtypePicklist.push({ label: result.Name, value: result.Id });
					this.mapRecordtypePicklist.set(result.Id, result.Name);
				});
			}
		}).catch(error => {
			if (error.body.message) {
				handleError();
			}
		});
		// only for contacts
		if (this.recordId.substr(0,3)=="003") {
			getDefaultRecordType({})
			.then(result => {
				if(result !== undefined){
					this.recordtypeValue = result;
					this.defaultCaseRecordtype = this.mapRecordtypePicklist.get(this.recordtypeValue);
				}
			}).catch(error => {
				if (error.body.message) {
					handleError();
				}
			});
		}
	}

	closeModal() {
		const closeModal = new CustomEvent('close');
		this.dispatchEvent(closeModal);
	};

}