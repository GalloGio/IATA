/* eslint-disable no-console */
import { LightningElement, track, api} from 'lwc';

/* eslint-disable no-alert */
/* eslint-disable vars-on-top */
import validateYasUserId                 from '@salesforce/apex/PortalRegistrationThirdLevelLMSCtrl.validateYasUserId';
// import getLMSContactInfo               from '@salesforce/apex/PortalRegistrationThirdLevelLMSCtrl.getLMSContactInfo';

//custom labels
import ISSP_Registration_None                        from '@salesforce/label/c.ISSP_Registration_None';
import ISSP_Registration_MR                          from '@salesforce/label/c.ISSP_Registration_MR';
import ISSP_Registration_MRS                         from '@salesforce/label/c.ISSP_Registration_MRS';
import ISSP_Registration_MS                          from '@salesforce/label/c.ISSP_Registration_MS';

import CSP_L2_Profile_Details_Message                   from '@salesforce/label/c.CSP_L2_Profile_Details_Message_LMS';
import CSP_L2_Profile_Details from '@salesforce/label/c.CSP_L2_Profile_Details';
import CSP_L3_Title_LMS from '@salesforce/label/c.CSP_L3_Title_LMS';
import CSP_L2_Date_of_Birth from '@salesforce/label/c.CSP_L2_Date_of_Birth';
import CSP_L2_Job_Function from '@salesforce/label/c.CSP_L2_Job_Function';
import CSP_L2_Job_Title from '@salesforce/label/c.CSP_L2_Job_Title'; 
import CSP_L2_Next_Account_Selection from '@salesforce/label/c.CSP_L2_Next_Account_Selection';
import CSP_L_LoginEmail_LMS from '@salesforce/label/c.CSP_L_LoginEmail_LMS';
import CSP_L_PersonalEmail_LMS from '@salesforce/label/c.CSP_L_PersonalEmail_LMS';
import CSP_L_TrainingEmail_LMS from '@salesforce/label/c.CSP_L_TrainingEmail_LMS';
import CSP_L_TrainingUser_LMS from '@salesforce/label/c.CSP_L_TrainingUser_LMS';
import CSP_L_Phone_LMS from '@salesforce/label/c.CSP_L_Phone_LMS';
import CSP_L_WorkPhone_LMS from '@salesforce/label/c.CSP_L_WorkPhone_LMS';
import CSP_Next_LMS from '@salesforce/label/c.CSP_Next_LMS';
import CSP_L2_RegistrationFailed_LMS from '@salesforce/label/c.CSP_L2_RegistrationFailed_LMS';
import CSP_L2_IdAlready_LMS from '@salesforce/label/c.CSP_L2_IdAlready_LMS';
import CSP_Age_Verification from '@salesforce/label/c.CSP_Age_Verification';


/** The delay used when debouncing input filters. */
const DELAY = 350;

export default class PortalRegistrationProfileDetailsLMS extends LightningElement {
	@api contactInfo;
	@api isIE;

	@track isUserIdValid;
	@track isBirthdateValid;
	
	@track localContactInfo;
	@track contactInfoLMS;
	@track errorMessageUserId = "";
	@track displayErrorUserId = false;
	@track errorMessageBirthdate = "";
	@track displayErrorBirthdate = false;

	/* Picklist options */
	@track salutationPicklistOptions;
	@track jobFunctionsPicklistOptions;

	@track classIE = 'IEFixDisplayContainer';
	@track startIE;
	@track endIE;
	
	/* label variables */
	_labels = {
		ISSP_Registration_None,
		ISSP_Registration_MR,
		ISSP_Registration_MRS,
		ISSP_Registration_MS,
		CSP_L2_Profile_Details,
		CSP_L2_Profile_Details_Message,
		CSP_L3_Title_LMS,
		CSP_L2_Date_of_Birth,
		CSP_L2_Job_Function,
		CSP_L2_Job_Title,
		CSP_L2_Next_Account_Selection,
		CSP_L_LoginEmail_LMS,
		CSP_L_PersonalEmail_LMS,
		CSP_L_TrainingEmail_LMS,
		CSP_L_TrainingUser_LMS,
		CSP_L_Phone_LMS,
		CSP_L_WorkPhone_LMS,
		CSP_Next_LMS,
		CSP_L2_RegistrationFailed_LMS,
		CSP_L2_IdAlready_LMS,
		CSP_Age_Verification
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
				|| (this.localContactInfo.Phone === '' || this.localContactInfo.Phone === null || this.localContactInfo.Phone === undefined)
				|| (this.isBirthdateValid === false);
	}

	connectedCallback() {
		this.localContactInfo = JSON.parse(JSON.stringify(this.contactInfo));
		//Initialize missing fields
		this.localContactInfo.Additional_Email__c = this.localContactInfo.Additional_Email__c === undefined ? '' : this.localContactInfo.Additional_Email__c;

		if(!this.isIE){ 
			this.classIE = '';
			this.startIE = '<div class="IEFixDisplayContainer">';
			this.endIE = '</div>';
		}

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
		
		window.clearTimeout(this.delayTimeout);
		// eslint-disable-next-line @lwc/lwc/no-async-operation
		this.delayTimeout = setTimeout(() => {
			this.validateBirthdate();
		}, DELAY);
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

			var userDiv = this.template.querySelector('[data-id="userDiv"]');
			if(!this.isUserIdValid){
				userDiv.classList.add('slds-has-error');
				this.errorMessageUserId = CSP_L2_IdAlready_LMS;
				this.displayErrorUserId = true;
			}else{
				userDiv.classList.remove('slds-has-error');
				this.errorMessageUserId = '';
				this.displayErrorUserId = false;
			}
		})
		.catch((error) => {
			console.error('Error: ', JSON.parse(JSON.stringify(error)));
		});
	}

	validateBirthdate(){
		this.isBirthdateValid = true;

		let today = new Date();

		let uBirthdate = new Date(this.localContactInfo.Birthdate);

		let age = today.getFullYear() - uBirthdate.getFullYear();
		let m = today.getMonth() - uBirthdate.getMonth();
		if (m < 0 || (m === 0 && today.getDate() < uBirthdate.getDate())) {
			age--;
		}    

		if( age < 18 ){
			this.isBirthdateValid = false;
		}

		var birthdateDiv = this.template.querySelector('[data-id="birthdateDiv"]');
		if(!this.isBirthdateValid){
			birthdateDiv.classList.add('slds-has-error');
			this.errorMessageBirthdate = this.labels.CSP_Age_Verification;
			this.displayErrorBirthdate = true;
		}else{
			birthdateDiv.classList.remove('slds-has-error');
			this.errorMessageBirthdate = '';
			this.displayErrorBirthdate = false;
		}
	}

	@api
	getContactInfo(){
		return this.localContactInfo;
	}
}