/* eslint-disable no-console */
import { LightningElement, track, api} from 'lwc';

/* eslint-disable no-alert */
/* eslint-disable vars-on-top */
//import getContactJobFunctionValues      from '@salesforce/apex/PortalRegistrationSecondLevelCtrl.getContactJobFunctionValues';
import validateYasUserId                 from '@salesforce/apex/PortalRegistrationThirdLevelLMSCtrl.validateYasUserId';
import getLMSContactInfo               from '@salesforce/apex/PortalRegistrationThirdLevelLMSCtrl.getLMSContactInfo';

//custom labels
import ISSP_Registration_None                        from '@salesforce/label/c.ISSP_Registration_None';
import ISSP_Registration_MR                          from '@salesforce/label/c.ISSP_Registration_MR';
import ISSP_Registration_MRS                         from '@salesforce/label/c.ISSP_Registration_MRS';
import ISSP_Registration_MS                          from '@salesforce/label/c.ISSP_Registration_MS';

import CSP_L2_Profile_Details_Message                   from '@salesforce/label/c.CSP_L2_Profile_Details_Message';
import CSP_L2_Profile_Details from '@salesforce/label/c.CSP_L2_Profile_Details';
import CSP_L2_Title from '@salesforce/label/c.CSP_L2_Title';
import CSP_L2_Date_of_Birth from '@salesforce/label/c.CSP_L2_Date_of_Birth';
import CSP_L2_Job_Function from '@salesforce/label/c.CSP_L2_Job_Function';
import CSP_L2_Job_Title from '@salesforce/label/c.CSP_L2_Job_Title';
import CSP_L2_Next_Account_Selection from '@salesforce/label/c.CSP_L2_Next_Account_Selection';


/** The delay used when debouncing input filters. */
const DELAY = 350;

export default class PortalRegistrationProfileDetailsLMS extends LightningElement {
	@api contactInfo;
	@api isUserIdValid;
	@track localContactInfo;
	@track contactInfoLMS;
	@track errorMessage = "";
	@track displayError = false;

	/* Picklist options */
	@track salutationPicklistOptions;
	@track jobFunctionsPicklistOptions;

	/* label variables */
	_labels = {
		ISSP_Registration_None,
		ISSP_Registration_MR,
		ISSP_Registration_MRS,
		ISSP_Registration_MS,
		CSP_L2_Profile_Details,
		CSP_L2_Profile_Details_Message,
		CSP_L2_Title,
		CSP_L2_Date_of_Birth,
		CSP_L2_Job_Function,
		CSP_L2_Job_Title,
		CSP_L2_Next_Account_Selection
	}
	get labels() {
		return this._labels;
	}
	set labels(value) {
		this._labels = value;
	}

	get isNextDisabled(){
		return (this.localContactInfo.Salutation === '' || this.localContactInfo.Salutation === null || this.localContactInfo.Salutation === undefined)
				|| (this.localContactInfo.Birthdate === '' || this.localContactInfo.Birthdate === null || this.localContactInfo.Birthdate === undefined)
				|| (this.isUserIdValid === false);
	}

	connectedCallback() {
		this.localContactInfo = JSON.parse(JSON.stringify(this.contactInfo));

		//Initialize missing fields
		this.localContactInfo.Additional_Email__c = this.localContactInfo.Additional_Email__c === undefined ? '' : this.localContactInfo.Additional_Email__c;

		getLMSContactInfo({lms:'yas'})
		.then(result2 => {
			this.contactInfoLMS = result2;

			this.localContactInfo.Username = this.contactInfoLMS.Username__c != undefined ? this.contactInfoLMS.Username__c : '';
			this.localContactInfo.UserId = this.contactInfoLMS.UserId__c != undefined ? this.contactInfoLMS.UserId__c : '';
			this.localContactInfo.lmsCourse = this.contactInfoLMS.Preferred_Course__c != undefined ? this.contactInfoLMS.Preferred_Course__c : '';
		})
		.catch((error) => {
			this.openMessageModalFlowRegister = true;
			this.message = 'Your registration failed. An Error Occurred - ' + error;
			console.log('Error: ', JSON.parse(JSON.stringify(error)));
			console.log('Error2: ', error);
		});

		var salutationList = [];

		salutationList.push({ label: '', value: '' });
		salutationList.push({ label: this.labels.ISSP_Registration_MR, value: 'Mr.' });
		salutationList.push({ label: this.labels.ISSP_Registration_MRS, value: 'Mrs.' });
		salutationList.push({ label: this.labels.ISSP_Registration_MS, value: 'Ms.' });

		this.salutationPicklistOptions = salutationList;

	}

	// Events handling
	changeSalutation(event){
		this.localContactInfo.Salutation = event.target.value;
	}

	changeDateOfBirth(event){
		// Check which Contact field we're supposed to update : Date_of_Birth__c or Birthdate
		this.localContactInfo.Birthdate = event.target.value;
	}

	changeSelectedJobFunctions(event){
		let options = event.target.options;
		var selectedOpts = [];

		for (var i = 0; i < options.length; i++) {
			if (options[i].selected) {
				selectedOpts.push(options[i].value);
			}
		}
		this.localContactInfo.Membership_Function__c = selectedOpts.join(';');
	}

	changeTitle(event){
		this.localContactInfo.Title = event.target.value;
	}
	changeAdditional_Email(event){
		this.localContactInfo.Additional_Email__c = event.target.value;
	}
	changeUsername(event){
		this.localContactInfo.Username = event.target.value;
	}
	changeUserId(event){
		this.localContactInfo.UserId = event.target.value;

		window.clearTimeout(this.delayTimeout);
		// eslint-disable-next-line @lwc/lwc/no-async-operation
		this.delayTimeout = setTimeout(() => {
			this.validateUserId();
		}, DELAY);


	}
	changePhone(event){
		this.localContactInfo.Phone = event.target.value;
	}
	changeOtherPhone(event){
		this.localContactInfo.OtherPhone = event.target.value;
	}

	next(){
		this.dispatchEvent(new CustomEvent('next'));
	}

	startLoading(){
		this.dispatchEvent(new CustomEvent('startloading'));
	}

	stopLoading(){
		this.dispatchEvent(new CustomEvent('stoploading'));
	}

	validateUserId(){
		this.isUserIdValid = true;
		validateYasUserId({userId : this.localContactInfo.UserId})
		.then(result => {
			this.isUserIdValid = result;
			var inputCmp = this.template.querySelector(".userIdInputClass");
			inputCmp.setCustomValidity('');
			if(result === false) {
				inputCmp.setCustomValidity("");
			}
			inputCmp.reportValidity();

			var userDiv = this.template.querySelector('[data-id="userDiv"]');
			if(!this.isUserIdValid){
				userDiv.classList.add('slds-has-error');
				this.errorMessage = 'The input user Id is already being used.';
				this.displayError = true;
			}else{
				userDiv.classList.remove('slds-has-error');
				this.errorMessage = '';
				this.displayError = false;
			}
		})
		.catch((error) => {
			console.log('Error: ', JSON.parse(JSON.stringify(error)));
		});
	}
	@api
	getContactInfo(){
		return this.localContactInfo;
	}
}