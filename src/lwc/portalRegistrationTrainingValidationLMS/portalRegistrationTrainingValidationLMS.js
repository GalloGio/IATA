/* eslint-disable no-alert */
/* eslint-disable vars-on-top */

import { LightningElement, track, api} from 'lwc';

/* ==============================================================================================================*/
/* Utils & Apex & Platform
/* ==============================================================================================================*/
// import { getParamsFromPage }			from 'c/navigationUtils';
// import RegistrationUtils				from 'c/registrationUtils';
import { navigateToPage } from'c/navigationUtils';

// import getUserInformationFromEmail		from '@salesforce/apex/PortalRegistrationFirstLevelCtrl.getUserInformationFromEmail';
import validateYasUserId				from '@salesforce/apex/PortalRegistrationThirdLevelLMSCtrl.validateYasUserId';
import getLMSContactInfo				from '@salesforce/apex/PortalRegistrationThirdLevelLMSCtrl.getLMSContactInfo';

//custom labels
import CSP_L2_Account_Selection_Message from '@salesforce/label/c.CSP_L2_Account_Selection_Message';
import CSP_L2_Account_Information from '@salesforce/label/c.CSP_L2_Account_Information';
import CSP_L2_Account_Information_Message from '@salesforce/label/c.CSP_L2_Account_Information_Message';
import ISSP_MyProfile_SECTOR from '@salesforce/label/c.ISSP_MyProfile_SECTOR';
import ISSP_MyProfile_CATEGORY from '@salesforce/label/c.ISSP_MyProfile_CATEGORY';
import CSP_L2_IATA_Codes from '@salesforce/label/c.CSP_L2_IATA_Codes';
import CSP_L2_Company_Location from '@salesforce/label/c.CSP_L2_Company_Location';
import CSP_L2_Back_to_Profile_Details from '@salesforce/label/c.CSP_L2_Back_to_Profile_Details';
import CSP_L2_Search from '@salesforce/label/c.CSP_L2_Search';
import CSP_L2_Search_Results from '@salesforce/label/c.CSP_L2_Search_Results';
import CSP_L2_Select from '@salesforce/label/c.CSP_L2_Select';
import CSP_L2_Select_Company_Message from '@salesforce/label/c.CSP_L2_Select_Company_Message';
import CSP_L2_Did_Not_Find from '@salesforce/label/c.CSP_L2_Did_Not_Find';
import CSP_L2_Did_Not_Find_Message from '@salesforce/label/c.CSP_L2_Did_Not_Find_Message';
import CSP_L2_Create_Account_Message from '@salesforce/label/c.CSP_L2_Create_Account_Message';
import CSP_L2_Create_New_Account from '@salesforce/label/c.CSP_L2_Create_New_Account';
import CSP_L3_Next_Confirmation_LMS from '@salesforce/label/c.CSP_L2_Next_Confirmation';
import CSP_L2_Company_Name from '@salesforce/label/c.CSP_L2_Company_Name';
import CSP_L2_No_Matching_Results from '@salesforce/label/c.CSP_L2_No_Matching_Results';
import CSP_L2_EmailValidationDescri_LMS from '@salesforce/label/c.CSP_L2_EmailValidationDescri_LMS';
import CSP_L3_EmailInformation_LMS from '@salesforce/label/c.CSP_L3_EmailInformation_LMS';
import CSP_L3_CompleteInformation_LMS from '@salesforce/label/c.CSP_L3_CompleteInformation_LMS';
import CSP_L3_IsPersonalEmail_LMS from '@salesforce/label/c.CSP_L3_IsPersonalEmail_LMS';
import CSP_L3_IsReversedEmail_LMS from '@salesforce/label/c.CSP_L3_IsReversedEmail_LMS';
import CSP_L3_WorkEmail_LMS from '@salesforce/label/c.CSP_L3_WorkEmail_LMS';
import CSP_L_PersonalEmail_LMS from '@salesforce/label/c.CSP_L_PersonalEmail_LMS';
import CSP_L3_ExistingUser_LMS from '@salesforce/label/c.CSP_L3_ExistingUser_LMS';
import CSP_L3_ExistingContact_LMS from '@salesforce/label/c.CSP_L3_ExistingContact_LMS';
import CSP_L3_StillWorkingP1_LMS from '@salesforce/label/c.CSP_L3_StillWorkingP1_LMS';
import CSP_L3_StillWorkingP2_LMS from '@salesforce/label/c.CSP_L3_StillWorkingP2_LMS';
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
		CSP_L2_Account_Selection_Message,
		CSP_L2_Account_Information,
		CSP_L2_Account_Information_Message,
		ISSP_MyProfile_SECTOR,
		ISSP_MyProfile_CATEGORY,
		CSP_L2_Company_Name,
		CSP_L2_IATA_Codes,
		CSP_L2_Company_Location,
		CSP_L2_Back_to_Profile_Details,
		CSP_L2_Search,
		CSP_L2_Search_Results,
		CSP_L2_Select_Company_Message,
		CSP_L2_Select,
		CSP_L2_Create_Account_Message,
		CSP_L2_Create_New_Account,
		CSP_L3_Next_Confirmation_LMS,
		CSP_L2_Did_Not_Find,
		CSP_L2_Did_Not_Find_Message,
		CSP_L2_No_Matching_Results,
		CSP_L2_EmailValidationDescri_LMS,
		CSP_L3_EmailInformation_LMS,
		CSP_L3_CompleteInformation_LMS,
		CSP_L3_IsPersonalEmail_LMS,
		CSP_L3_IsReversedEmail_LMS,
		CSP_L3_WorkEmail_LMS,
		CSP_L_PersonalEmail_LMS,
		CSP_L3_ExistingUser_LMS,
		CSP_L3_ExistingContact_LMS,
		CSP_L3_StillWorkingP1_LMS,
		CSP_L3_StillWorkingP2_LMS,
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
		CSP_L2_RegistrationFailed_LMS
	}
	get labels() {
		return this._labels;
	}
	set labels(value) {
		this._labels = value;
	}

	connectedCallback() {
console.log('TrainingValidation connectedCallback this.contactInfo: ', this.contactInfo);		
		this.localContactInfo = JSON.parse(JSON.stringify(this.contactInfo));
console.log('TrainingValidation connectedCallback this.localContactInfo: ', this.localContactInfo);
		this.startLoading();
		getLMSContactInfo({lms:'yas'})
		.then(result2 => {
			if(result2 !== undefined){
				this.contactInfoLMS = result2;

				this.localContactInfo.Username = this.contactInfoLMS.Username__c !== undefined ? this.contactInfoLMS.Username__c : '';
				this.localContactInfo.UserId = this.contactInfoLMS.UserId__c !== undefined ? this.contactInfoLMS.UserId__c : '';
				// if(this.localContactInfo.lmsCourse !== ''){
				// 	this.localContactInfo.lmsCourse = this.contactInfoLMS.Preferred_Course__c !== undefined ? this.contactInfoLMS.Preferred_Course__c : '';
				// }
			}else{
				this.localContactInfo.Username = '';
				this.localContactInfo.UserId = '';
			}

			if(this.localContactInfo.Username !== '' && this.localContactInfo.Username !== null && this.localContactInfo.Username !== undefined
				&& this.localContactInfo.UserId !== '' && this.localContactInfo.UserId !== null && this.localContactInfo.UserId !== undefined ){
					
				if(this.localContactInfo.firstLogin){
					this.dispatchEvent(new CustomEvent('next'));
				}else{
					this.haveTrainingUser = 'yes';
					this.validated = true;
				}
			}
			this.stopLoading();					
		})
		.catch((error) => {
			this.stopLoading();
			this.localContactInfo.Username = '';
			this.localContactInfo.UserId = '';
		
			this.openMessageModalFlowRegister = true;
			this.message = CSP_L2_RegistrationFailed_LMS + error;
			console.log('Error: ', JSON.parse(JSON.stringify(error)));
			console.log('Error2: ', error);
		});


		

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
	}

	changeUsername(event){
		this.localContactInfo.Username = event.target.value;

		if(this.localContactInfo.UserId !== '' && this.localContactInfo.Username !== ''){
			this.validated = false;
			this.existingUsernameVisibility = false;
			this.notMatchingVisibility = false;
			this.matchingVisibility = false;
			
			window.clearTimeout(this.delayTimeout);
			// eslint-disable-next-line @lwc/lwc/no-async-operation
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
console.log('entrei next');
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
		this.matchingVisibility = false;

		if(this.localContactInfo.UserId !== '' && this.localContactInfo.Username !== ''){
			this.startLoading();
			validateYasUserId({userId : this.localContactInfo.UserId, username: this.localContactInfo.Username, firstname : this.localContactInfo.FirstName, lastname : this.localContactInfo.LastName})
			.then(result => {
			
				if(result === 'not_existing'){

					this.validated = true;
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
				console.log('Error: ', JSON.parse(JSON.stringify(error)));
			});
		}
	}

	navigateToSupport() {
        // navigateToPage(CSP_PortalPath + "support-reach-us?category=Training&topic=Self_study_courses&subtopic=Sign_Up_Join_ssc");

		let params = {};
		params.category = 'Training';
		params.topic = 'Self_study_courses';
		params.subtopic = 'Sign_Up_Join_ssc';
		navigateToPage(CSP_PortalPath + 'support-reach-us',params);
	}
	
	@api
	getContactInfo(){
		return this.localContactInfo;
	}
	
}