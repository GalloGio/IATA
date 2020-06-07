import { LightningElement, track, api} from 'lwc';

import { navigateToNewPage } from'c/navigationUtils';

import validateYasUserId				from '@salesforce/apex/PortalRegistrationThirdLevelLMSCtrl.validateYasUserId';
import getLMSContactInfo				from '@salesforce/apex/PortalRegistrationThirdLevelLMSCtrl.getLMSContactInfo';

//custom labels
import CSP_L_TrainingEmail_LMS from '@salesforce/label/c.CSP_L_TrainingEmail_LMS';
import CSP_L_TrainingUser_LMS from '@salesforce/label/c.CSP_L_TrainingUser_LMS';
import CSP_L3_Training_Validation_LMS from '@salesforce/label/c.CSP_L3_Training_Validation_LMS';
import CSP_L3_TrainValidationDescri_LMS from '@salesforce/label/c.CSP_L3_TrainValidationDescri_LMS';
import CSP_L3_Training_Information_LMS from '@salesforce/label/c.CSP_L3_Training_Information_LMS';
import CSP_L3_haveTrainingUser_LMS from '@salesforce/label/c.CSP_L3_haveTrainingUser_LMS';
import CSP_L3_Back_to_Email_Validation_LMS from '@salesforce/label/c.CSP_L3_Back_to_Email_Validation_LMS';
import CSP_L3_ExistTrainUser_LMS from '@salesforce/label/c.CSP_L3_ExistTrainUser_LMS';
import CSP_L3_ExistTrainNameMatch_LMS from '@salesforce/label/c.CSP_L3_ExistTrainNameMatch_LMS';
import CSP_L3_ExistTrainUserMatch_LMS from '@salesforce/label/c.CSP_L3_ExistTrainUserMatch_LMS';
import CSP_L3_ContactSupport_LMS from '@salesforce/label/c.CSP_L3_ContactSupport_LMS';
import CSP_L3_NumericError_LMS from '@salesforce/label/c.CSP_L3_NumericError_LMS';
import CSP_L2_RegistrationFailed_LMS from '@salesforce/label/c.CSP_L2_RegistrationFailed_LMS';
import CSP_L3_ExistTrainUserId_LMS from '@salesforce/label/c.CSP_L3_ExistTrainUserId_LMS';
import CSP_Next_LMS from '@salesforce/label/c.CSP_Next_LMS';
import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';

/** The delay used when debouncing input filters. */
const DELAY = 350;

export default class PortalRegistrationTrainingValidationLMS extends LightningElement {
	/* Images */
	alertIcon = CSP_PortalPath + 'alertIcon.png';

	@api customerType;
	@api contactInfo;
	@api flow;
	@api isIE;

	@track errorMessage = ""; 
	@track errorMessageUserId = "";
	@track displayError = false;
	@track displayErrorUserId = false;
	@track displaySubmitError = false;
	@track localContactInfo;
	@track userInfo = {}

	@track lms;
	@track existingUsernameVisibility = false;
	@track notMatchingVisibility = false;
	@track matchingVisibility = false;
	@track alreadyMatchingUseridVisibility = false;
	@track validated = false;
	
	/* Picklist options */
	@track isoCountriesPicklistOptions;

	@track haveTrainingUser;
	

	get blockConfirmation(){

		let res = true;
		if(
			(this.haveTrainingUser === 'yes' && this.localContactInfo.Username !== '' 
				&& this.localContactInfo.UserId !== '' && this.validated)
			|| (this.haveTrainingUser === 'no')
		){
			res = false;
		}
		return res;

	}

	get TrainingUserOptions() {
		return [
			{ label: 'Yes', value: 'yes' },
			{ label: 'No', value: 'no' }
		];
	}

	get trainingInfoVisibility(){
		let retValue = false;
		if(this.haveTrainingUser  === 'yes'){
			retValue =  true;
		}
		return retValue;		
	}


	@track inputModified = true;

	// label variables
	_labels = {
		CSP_L3_Training_Validation_LMS,
		CSP_L3_TrainValidationDescri_LMS,
		CSP_L3_Training_Information_LMS,
		CSP_L3_haveTrainingUser_LMS,
		CSP_L_TrainingEmail_LMS,
		CSP_L_TrainingUser_LMS,
		CSP_L3_Back_to_Email_Validation_LMS,
		CSP_L3_ExistTrainUser_LMS,
		CSP_L3_ExistTrainNameMatch_LMS,
		CSP_L3_ExistTrainUserMatch_LMS,
		CSP_L3_ContactSupport_LMS,
		CSP_L3_NumericError_LMS,
		CSP_L2_RegistrationFailed_LMS,
		CSP_L3_ExistTrainUserId_LMS,
		CSP_Next_LMS
	}
	get labels() {
		return this._labels;
	}
	set labels(value) {
		this._labels = value;
	}

	connectedCallback() {
		this.localContactInfo = JSON.parse(JSON.stringify(this.contactInfo));
	
		//If Training information already exist from existing user to Merge, can happen on Flows 4,6 and 7
		if(this.localContactInfo.Username !== '' && this.localContactInfo.Username !== null && this.localContactInfo.Username !== undefined
		&& this.localContactInfo.UserId !== '' && this.localContactInfo.UserId !== null && this.localContactInfo.UserId !== undefined ){
			this.dispatchEvent(new CustomEvent('next'));
		}else{

			this.startLoading();
			getLMSContactInfo({lms:'yas'})
			.then(result2 => {
				if(result2 !== undefined){
					this.contactInfoLMS = result2;

					this.localContactInfo.Username = this.contactInfoLMS.Username__c !== undefined ? this.contactInfoLMS.Username__c : '';
					this.localContactInfo.UserId = this.contactInfoLMS.UserId__c !== undefined ? this.contactInfoLMS.UserId__c : '';
				}else{
					this.localContactInfo.Username = '';
					this.localContactInfo.UserId = '';
				}

				if(this.localContactInfo.Username !== '' && this.localContactInfo.Username !== null && this.localContactInfo.Username !== undefined
					&& this.localContactInfo.UserId !== '' && this.localContactInfo.UserId !== null && this.localContactInfo.UserId !== undefined ){
						
					this.localContactInfo.ExistingTrainingInfo = true;
					this.dispatchEvent(new CustomEvent('next'));
				}
				this.stopLoading();					
			})
			.catch((error) => {
				this.stopLoading();
				this.localContactInfo.Username = '';
				this.localContactInfo.UserId = '';
			
				this.openMessageModalFlowRegister = true;
				this.message = CSP_L2_RegistrationFailed_LMS + error;
				console.error('error: ', JSON.parse(JSON.stringify(error))); 
			});
		}

		

	}

	startLoading(){
		this.dispatchEvent(new CustomEvent('startloading'));
	}

	stopLoading(){
		this.dispatchEvent(new CustomEvent('stoploading'));
	}

	/* Events handler methods */

	changeHaveTrainingUser(event) {
		this.haveTrainingUser = event.target.value;
		this.inputModified = true;
		this.localContactInfo.UserId = '';
		this.localContactInfo.Username = '';
		this.validated = false;
		this.existingUsernameVisibility = false;
		this.notMatchingVisibility = false;
		this.alreadyMatchingUseridVisibility = false;
		this.matchingVisibility = false;
	}

	changeUsername(event){
		this.localContactInfo.Username = event.target.value;

		if(this.localContactInfo.UserId !== '' && this.localContactInfo.Username !== ''){
			this.validated = false;
			this.existingUsernameVisibility = false;
			this.notMatchingVisibility = false;
			this.alreadyMatchingUseridVisibility = false;
			this.matchingVisibility = false;
			
			window.clearTimeout(this.delayTimeout);
			this.delayTimeout = setTimeout(() => {
				this.validateUserId();
			}, DELAY);
		}

	}
	
	changeUserId(event){
		this.localContactInfo.UserId = event.target.value;

		var inputCmp = this.template.querySelector(".userIdInputClass");
		inputCmp.setCustomValidity('');
		inputCmp.reportValidity();

		var userDiv = this.template.querySelector('[data-id="userDiv"]');

		if(isNaN(this.localContactInfo.UserId)){
			this.validated = false;
			this.existingUsernameVisibility = false;
			this.notMatchingVisibility = false;
			this.alreadyMatchingUseridVisibility = false;
			this.matchingVisibility = false;
			
			userDiv.classList.add('slds-has-error');
			this.errorMessageUserId = CSP_L3_NumericError_LMS;
			this.displayErrorUserId = true;
		}else{
			userDiv.classList.remove('slds-has-error');
			this.errorMessageUserId = '';
			this.displayErrorUserId = false;
		
			if(this.localContactInfo.UserId !== '' && this.localContactInfo.Username !== ''){
				window.clearTimeout(this.delayTimeout);
				// eslint-disable-next-line @lwc/lwc/no-async-operation
				this.delayTimeout = setTimeout(() => {
					this.validateUserId();
				}, DELAY);
			}
		}

	}


	/* Navigation methods */
	previous(){
		this.dispatchEvent(new CustomEvent('previous'));
	}

	next(){
		if(this.haveTrainingUser === 'no'){
			this.validated = true;
			this.localContactInfo.existingTrainingId = '';
			this.localContactInfo.Username = '';
			this.localContactInfo.UserId = '';
		}
		
		if(this.validated === true){
			this.dispatchEvent(new CustomEvent('next'));
		}

	}


	/* ==============================================================================================================*/
	/* Helper Methods
	/* ==============================================================================================================*/


	validateUserId(){
		this.validated = false;
		this.existingUsernameVisibility = false;
		this.notMatchingVisibility = false;
		this.alreadyMatchingUseridVisibility = false;
		this.matchingVisibility = false;

		if(this.localContactInfo.UserId !== '' && this.localContactInfo.Username !== ''){
			this.startLoading();
			validateYasUserId({userId : this.localContactInfo.UserId, username: this.localContactInfo.Username, firstname : this.localContactInfo.FirstName, lastname : this.localContactInfo.LastName})
			.then(result => {
				if(result === 'not_existing'){

					this.validated = true;
					this.localContactInfo.existingTrainingId = '';

				}else if(result === 'already_existing_userid'){

					this.alreadyMatchingUseridVisibility = true;
					this.localContactInfo.existingTrainingId = '';
				
				}else if(result === 'not_matching'){

					this.notMatchingVisibility = true;
					this.localContactInfo.existingTrainingId = '';
				
				}else if(result === 'existing_user'){
				
					this.existingUsernameVisibility = true;
					this.localContactInfo.existingTrainingId = '';
				
				}else if(result !== ''){

					this.validated = true;
					this.matchingVisibility = true;
					this.localContactInfo.existingTrainingId = result;
				}
				this.stopLoading();
			})
			.catch((error) => {
				this.stopLoading();
				console.error('error: ', JSON.parse(JSON.stringify(error))); 
			});
		}
	}

	navigateToSupport() {
		let params = {};
		params.category = 'Training';
		params.topic = 'Self_study_courses';
		params.subtopic = 'Sign_Up_Join_ssc';
		navigateToNewPage(CSP_PortalPath + 'support-reach-us',params);
	}
	
	@api
	getContactInfo(){
		return this.localContactInfo;
	}
	
}