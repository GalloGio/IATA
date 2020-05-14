/* eslint-disable no-alert */
/* eslint-disable vars-on-top */

import { LightningElement, track, api} from 'lwc';

/* ==============================================================================================================*/
/* Utils & Apex & Platform
/* ==============================================================================================================*/
import { getParamsFromPage }    from 'c/navigationUtils';
import RegistrationUtils                        from 'c/registrationUtils';

import getUserInformationFromEmail              from '@salesforce/apex/PortalRegistrationFirstLevelCtrl.getUserInformationFromEmail';
import validateFullName				from '@salesforce/apex/PortalRegistrationThirdLevelLMSCtrl.validateFullName';

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
import CSP_L3_Next_Confirmation_LMS from '@salesforce/label/c.CSP_L3_Next_Confirmation_LMS';
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
import CSP_L3_ExistingContact_LMS2 from '@salesforce/label/c.CSP_L3_ExistingContact_LMS2';
import CSP_L3_StillWorkingP1_LMS from '@salesforce/label/c.CSP_L3_StillWorkingP1_LMS';
import CSP_L3_StillWorkingP2_LMS from '@salesforce/label/c.CSP_L3_StillWorkingP2_LMS';
import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';
import CSP_L3_Email_Validation_LMS from '@salesforce/label/c.CSP_L3_Email_Validation_LMS';
import CSP_L3_ProvideWorkEmail_LMS from '@salesforce/label/c.CSP_L3_ProvideWorkEmail_LMS';
import CSP_Next_LMS from '@salesforce/label/c.CSP_Next_LMS';
import CSP_Registration_Existing_Work_Message from '@salesforce/label/c.CSP_Registration_Existing_Work_Message';
import CSP_Registration_Existing_User_Message_Not_Matching_F4 from '@salesforce/label/c.CSP_Registration_Existing_User_Message_Not_Matching_F4';
import CSP_Registration_Existing_User_Message_Not_Matching_F6 from '@salesforce/label/c.CSP_Registration_Existing_User_Message_Not_Matching_F6';
import CSP_Registration_Existing_Work_Message_LMS from '@salesforce/label/c.CSP_Registration_Existing_Work_Message_LMS';
import CSP_L3_Have_Work_Email from '@salesforce/label/c.CSP_L3_Have_Work_Email';


export default class PortalRegistrationEmailValidationLMS extends LightningElement {
	/* Images */
	alertIcon = CSP_PortalPath + 'alertIcon.png';

	@api customerType;
	@api contactInfo;
	@api flow;
	@api isIE;

	@track errorMessage = ""; 
	@track displayError = false;
	@track displaySubmitError = false;
	@track localContactInfo;
	@track userInfo = {}
	@track messageFlow6;
	@track messageFlow7;

	@track lms;
	@track existingUsernameVisibility;
	@track existingPersonalUsernameVisibility;
	@track existingUsernameNotMatchingF4Visibility;
	@track existingUsernameNotMatchingF6Visibility;
	@track validated = false;
	@track isFullNameMatching = true;

	/* Picklist options */
	@track isoCountriesPicklistOptions;

	// customer type variables
	@track customerType;

	@track isPersonalEmail;
	@track isReverseEmail;
	@track haveWorkEmail;
	
	@track isPersonalEmailVisibility = true;
	@track reverseEmailVisibility = false;
	@track haveWorkEmailVisibility = false;

	// search inputs
	@track personalEmailInput ='';
	@track workEmailInput ='';

	get blockConfirmation(){
		let res = true;

		if(this.reverseEmailVisibility){
			if(this.isReverseEmail !== undefined && this.isReverseEmail !== ''){
				res = false;
			}
		}else{
			if(
				(this.isPersonalEmail === 'no' && this.personalEmailInput !== '' && this.isFullNameMatching) ||
				(this.isPersonalEmail === 'yes' && this.haveWorkEmail === 'no') ||
				(this.isPersonalEmail === 'yes' && this.haveWorkEmail === 'yes' && this.workEmailInput !== '' && this.isFullNameMatching)
			){
				res = false;
			}
		}
		
		return res;

	}

	get PersonalEmailOptions() {
		return [
			{ label: 'Yes', value: 'yes' },
			{ label: 'No', value: 'no' }
		];
	}

	get personalEmailVisibility(){
		if(this.localContactInfo.Additional_Email__c !== '' && 
			(this.haveWorkEmail === '' || this.haveWorkEmail === 'no') && 
			(this.flow === undefined || this.flow === '' || this.flow === 'flow1' || this.flow === 'flow0') ){
			return true;
		}else if(this.reverseEmailVisibility){
			return true;
		}
		return this.isPersonalEmail === 'no'? true : false;
	}

	get hasWorkEmailVisibility(){
		return this.isPersonalEmail === 'yes' ? true : false;
		
	}

	get workEmailVisibility(){
		if(this.reverseEmailVisibility){
			return true;
		}
		return this.isPersonalEmail === 'yes' && this.haveWorkEmail === 'yes' ? true : false;
		
	}

	get isReverseEmailVisible(){
		return this.reverseEmailVisibility;
	}

	get isPersonalEmailVisible(){
		return this.isPersonalEmailVisibility;
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
		CSP_L3_ExistingContact_LMS2,
		CSP_L3_StillWorkingP1_LMS,
		CSP_L3_StillWorkingP2_LMS,
		CSP_L3_Email_Validation_LMS,
		CSP_L3_ProvideWorkEmail_LMS,
		CSP_Next_LMS,
		CSP_Registration_Existing_Work_Message,
		CSP_Registration_Existing_User_Message_Not_Matching_F4,
		CSP_Registration_Existing_User_Message_Not_Matching_F6,
		CSP_Registration_Existing_Work_Message_LMS,
		CSP_L3_Have_Work_Email
	}
	get labels() {
		return this._labels;
	}
	set labels(value) {
		this._labels = value;
	}

	connectedCallback() {
		this.localContactInfo = JSON.parse(JSON.stringify(this.contactInfo));

		if(this.localContactInfo.initialEmail === undefined || this.localContactInfo.initialEmail === '' ){
			this.localContactInfo.initialEmail = this.localContactInfo.Email;
		}
		if(this.localContactInfo.initialAdditionalEmail !== undefined && this.localContactInfo.initialAdditionalEmail !== '' ){
			this.localContactInfo.initialAdditionalEmail = this.localContactInfo.Additional_Email__c;
		}

		if(this.localContactInfo.flow !== undefined && this.localContactInfo.flow !== '' ){
			this.flow = this.localContactInfo.flow;

			//Set form fields to their previous values when coming back from other form
			if(this.flow === 'flow2'){
				this.isPersonalEmail = 'yes';
				this.haveWorkEmail = 'no';
				this.isPersonalEmailVisibility = true;
				this.personalEmailInput = '';
				this.workEmailInput = '';
				this.validated = true;
			}else if(this.flow === 'flow3' || this.flow === 'flow4'){
				this.isPersonalEmail = 'yes';
				this.haveWorkEmail = 'yes';
				this.isPersonalEmailVisibility = true;
				this.personalEmailInput = this.localContactInfo.Additional_Email__c;
				this.workEmailInput = this.localContactInfo.Email;
				this.validated = true;
			}else if(this.flow === 'flow5' || this.flow === 'flow6' || this.flow === 'flow7'){
				this.isPersonalEmail = 'no';
				this.isPersonalEmailVisibility = true;
				
				this.personalEmailInput = this.localContactInfo.Additional_Email__c;
				this.workEmailInput = this.localContactInfo.Email;
				this.validated = true;
			}

		}
		
		let pageParams = getParamsFromPage();// FOR LMS L3
		if(pageParams !== undefined && pageParams.lms !== undefined){
			this.lms = pageParams.lms;
		}

		if(this.customerType === ''){
			this.setCustomerType(null);
		}
		else{
			this.setCustomerType(this.customerType);
		}

		//FLOW 0 && FLOW 1
		if(this.localContactInfo.Additional_Email__c !== '' && (this.flow === undefined || this.flow === '' || this.flow === 'flow1' || this.flow === 'flow0') ){
			this.flow = 'flow1';
			this.isPersonalEmailVisibility = false;
			this.reverseEmailVisibility = true;
			
			this.workEmailInput = this.localContactInfo.Email;
			this.personalEmailInput = this.localContactInfo.Additional_Email__c;

			if(!this.localContactInfo.firstLogin){
				this.isReverseEmail = 'no';
			}
		}
	}

	startLoading(){
		this.dispatchEvent(new CustomEvent('startloading'));
	}

	stopLoading(){
		this.dispatchEvent(new CustomEvent('stoploading'));
	}

	/* Events handler methods */
	setCustomerType(customerType){
		this.selectedCustomerType = customerType;

	 }

	changeIsPersonalEmail(event) {
		this.isPersonalEmail = event.target.value;
		this.workEmailInput = '';
		this.personalEmailInput = '';
		this.existingPersonalUsernameVisibility = false;
		this.existingUsernameVisibility = false;
		this.existingUsernameNotMatchingF4Visibility = false;
		this.existingUsernameNotMatchingF6Visibility = false;
		this.inputModified = true;		
		this.haveWorkEmail = '';
		this.validated = false;
		this.localContactInfo.Email = this.localContactInfo.initialEmail;
		if(this.localContactInfo.initialAdditionalEmail !== undefined && this.localContactInfo.initialAdditionalEmail !== '' ){
			this.localContactInfo.Additional_Email__c = this.localContactInfo.initialAdditionalEmail;
		}
		
	}

	
	changeHaveWorkEmail(event) {
		this.haveWorkEmail = event.target.value;
		this.workEmailInput = '';
		this.personalEmailInput = '';
		this.existingPersonalUsernameVisibility = false;
		this.existingUsernameVisibility = false;
		this.existingUsernameNotMatchingF4Visibility = false;
		this.existingUsernameNotMatchingF6Visibility = false;
		this.inputModified = true;
		this.validated = false;
		this.localContactInfo.Email = this.localContactInfo.initialEmail;
		if(this.localContactInfo.initialAdditionalEmail !== undefined && this.localContactInfo.initialAdditionalEmail !== '' ){
			this.localContactInfo.Additional_Email__c = this.localContactInfo.initialAdditionalEmail;
		}
	}

	changeReverseEmail(event) {
		this.isReverseEmail = event.target.value;
		this.inputModified = true;
	}

	changePersonalEmail(event){
		this.personalEmailInput = event.target.value;
		this.existingPersonalUsernameVisibility = false;
		this.existingUsernameVisibility = false;
		this.existingUsernameNotMatchingF4Visibility = false;
		this.existingUsernameNotMatchingF6Visibility = false;
		this.isFullNameMatching = true;
		this.validated = false;
		this.inputModified = true;
		this.validated = false;
	}

	changeWorkEmail(event){
		this.workEmailInput = event.target.value;
		this.existingPersonalUsernameVisibility = false;
		this.existingUsernameVisibility = false;
		this.existingUsernameNotMatchingF4Visibility = false;
		this.existingUsernameNotMatchingF6Visibility = false;
		this.isFullNameMatching = true;
		this.validated = false;
		this.inputModified = true;
		this.validated = false;
	}


	/* Navigation methods */
	previous(){
		this.dispatchEvent(new CustomEvent('previous'));
	}

	next(){

		if(this.validated === true){
			//if not set yet, set Training info in case of already existing information in order to ByPass Training form
			if(this.localContactInfo.Username !== '' && this.localContactInfo.UserId !== ''
				&& this.userInfo.existingContactTrainingUsername !== undefined && this.userInfo.existingContactTrainingUserId !== undefined){
					this.localContactInfo.Username = this.userInfo.existingContactTrainingUsername !== undefined ? this.userInfo.existingContactTrainingUsername : '';
					this.localContactInfo.UserId = this.userInfo.existingContactTrainingUserId !== undefined ? this.userInfo.existingContactTrainingUserId : '';
					this.localContactInfo.ExistingTrainingInfo = true;
			}
			this.localContactInfo.flow = this.flow;

			this.dispatchEvent(new CustomEvent('next'));
		}else{

			//Since user may come back and retried another email we clean the values
			// this.localContactInfo.Username = '';
			// this.localContactInfo.UserId = '';

			if(this.flow === 'flow1'){
				if(this.isReverseEmail === 'yes'){
					this.flow = 'flow0';
					this.localContactInfo.Email = this.personalEmailInput;
					this.localContactInfo.Additional_Email__c = this.workEmailInput;
				}this.localContactInfo.flow = this.flow;

				this.dispatchEvent(new CustomEvent('next'));
			}else{

				if(this.isPersonalEmail === 'yes' && this.haveWorkEmail === 'no'){
					this.localContactInfo.Additional_Email__c = this.localContactInfo.Email;
					this.flow = 'flow2';
					this.localContactInfo.flow = this.flow;

					this.dispatchEvent(new CustomEvent('next'));
				}else{

					let auxEmail = '';

					const RegistrationUtilsJs = new RegistrationUtils();

					if(this.isPersonalEmail === 'no' && this.personalEmailInput !== ''){
						this.localContactInfo.Additional_Email__c = this.personalEmailInput;
						auxEmail = this.personalEmailInput;
					}

					if(this.isPersonalEmail === 'yes' && this.haveWorkEmail === 'yes' && this.workEmailInput !== ''){
						this.localContactInfo.Additional_Email__c = this.workEmailInput;
						auxEmail = this.workEmailInput;
					}
					
					if(auxEmail !== '' && this.validated === false){

						if(this.isPersonalEmail === 'no' && this.personalEmailInput !== ''){
							this.flow = 'flow5';
						}

						if(this.isPersonalEmail === 'yes' && this.haveWorkEmail === 'yes' && this.workEmailInput !== ''){							
							this.flow = 'flow3';
						}

						this.startLoading();
						RegistrationUtilsJs.checkEmailIsValid(`${auxEmail}`).then(result=> {
							if(result == false){
								this._showEmailValidationError(true, this.labels.CSP_Invalid_Email);
								this.isLoading = false;
							}else{
								let anonymousEmail = 'iata' + auxEmail.substring(auxEmail.indexOf('@'));
								RegistrationUtilsJs.checkEmailIsDisposable(`${anonymousEmail}`).then(result2=> {
									if(result2 === 'true'){
									//todo:disposable email alert!
										this._showEmailValidationError(true, this.labels.CSP_Invalid_Email);
										this.stopLoading();
									}else{
										//todo:check if the email address is associated to a contact and/or a user
										//1) If there is an existing contact & user with that email -> The user is redirected to the login page,
										//but the "E-Mail" field is pre-populated and, by default, not editable.
										//The user can click a Change E-Mail link to empty the E-Mail field and set it editable again.
										//2) If there is an existing contact but not a user with that email -> Terms and conditions and submit
										//button is displayed on the form.
										// getUserInformationFromEmail({ email : auxEmail}).then(result3 => {

										getUserInformationFromEmail({ email : auxEmail, LMSRedirectFrom: this.lms}).then(result3 => {

											var userInfo = JSON.parse(JSON.stringify(result3));
											this.userInfo = userInfo;
														
											if(userInfo.hasExistingContact == true){
												// if(userInfo.hasExistingUser == true){
													if(this.flow === 'flow3'){
														this.flow = 'flow4';

														//reverse email
														this.localContactInfo.Additional_Email__c = this.localContactInfo.Email;
														this.localContactInfo.Email = this.workEmailInput;
														
													}
													if(this.flow === 'flow5'){
														this.flow = 'flow6';
													}

													//validate the 60% on the name comparison
													validateFullName({existingContactId: userInfo.existingContactId , firstname : this.localContactInfo.FirstName, lastname : this.localContactInfo.LastName})
														.then(result4 => {
															if(result4 === 'not_matching'){
																this.isFullNameMatching = false;
																if(this.flow === 'flow4'){
																	this.existingUsernameNotMatchingF4Visibility = true;
																}else if(this.flow === 'flow6'){
																	this.existingUsernameNotMatchingF6Visibility = true;
																}
															}else if(result4 === 'existing_user'){
																this.isFullNameMatching = true;
																this.existingUsernameVisibility = true;
																this.localContactInfo.existingContactId = userInfo.contactId;
																this.localContactInfo.existingContactAccount = userInfo.existingContactAccount;
																this.localContactInfo.hasExistingContact = userInfo.hasExistingContact;
																this.localContactInfo.hasExistingUser = userInfo.hasExistingUser;
																this.localContactInfo.hasExistingContact = userInfo.hasExistingContact;
																this.localContactInfo.existingContactEmail = userInfo.existingContactEmail;
																this.localContactInfo.existingContactName = userInfo.existingContactName;
																this.localContactInfo.hasExistingContactPersonalEmail = userInfo.hasExistingContactPersonalEmail;
																this.localContactInfo.hasExistingUserPersonalEmail = userInfo.hasExistingUserPersonalEmail;
																
																this.messageFlow6 = CSP_Registration_Existing_Work_Message_LMS;
																this.messageFlow6 = this.messageFlow6.replace('[Email]',this.localContactInfo.Email);
															}
														})
														.catch((error) => {
															this.stopLoading();
															// console.log('Error: ', JSON.parse(JSON.stringify(error)));
														});

													this.stopLoading();
												// }
											}else{
												//Don't validate the personal email for this flow
												if(this.flow === 'flow3'){
													//reverse email
													this.localContactInfo.Additional_Email__c = this.localContactInfo.Email;
													this.localContactInfo.Email = this.workEmailInput;
													this.stopLoading();
													this.localContactInfo.flow = this.flow;

													this.dispatchEvent(new CustomEvent('next'));
												}else if(userInfo.hasExistingContactPersonalEmail == true){
													// if(userInfo.hasExistingUserPersonalEmail == true){

														if(this.flow === 'flow5'){
															this.flow = 'flow7';
														}

														//validate the 60% on the name comparison
														validateFullName({existingContactId: userInfo.existingContactId , firstname : this.localContactInfo.FirstName, lastname : this.localContactInfo.LastName})
														.then(result4 => {
														
															if(result4 === 'not_matching'){
																this.isFullNameMatching = false;
																this.existingUsernameNotMatchingF6Visibility = true;
																
															}else if(result4 === 'existing_user'){
																this.isFullNameMatching = true;
																this.existingPersonalUsernameVisibility = true;
																this.localContactInfo.hasExistingContact = userInfo.hasExistingContact;
																this.localContactInfo.hasExistingUser = userInfo.hasExistingUser;
																this.localContactInfo.existingContactAccount = userInfo.existingContactAccount;
																this.localContactInfo.existingContactEmail = userInfo.existingContactEmail;
																this.localContactInfo.existingContactId = userInfo.existingContactId;
																this.localContactInfo.existingContactName = userInfo.existingContactName;
																this.localContactInfo.hasExistingContactPersonalEmail = userInfo.hasExistingContactPersonalEmail;
																this.localContactInfo.hasExistingUserPersonalEmail = userInfo.hasExistingUserPersonalEmail;

																this.messageFlow7 = CSP_L3_ExistingContact_LMS + CSP_L3_ExistingContact_LMS2;
																this.messageFlow7 = this.messageFlow7.replace('[Existing_email]',userInfo.existingContactEmail);
																this.messageFlow7 = this.messageFlow7.replace('[Existing_email]',userInfo.existingContactEmail);
																this.messageFlow7 = this.messageFlow7.replace('[Email]',this.localContactInfo.Email);
																this.messageFlow7 = this.messageFlow7.replace('[Email]',this.localContactInfo.Email);
															}
														})
														.catch((error) => {
															this.stopLoading();
															// console.log('Error: ', JSON.parse(JSON.stringify(error)));
														});
														this.stopLoading();
													// }
													//Send Verification email
													this._showEmailValidationError(true, this.labels.CSP_Invalid_Email);
													this.stopLoading();
												}else{

													this.stopLoading();
													this.localContactInfo.flow = this.flow;

													this.dispatchEvent(new CustomEvent('next'));
												}
											}
											this.validated = true;
										})
										.catch(error => {
											// console.log('Error: ', JSON.parse(JSON.stringify(error)));
											this.stopLoading();
											
										});
									}
								});
							}
						});
					}else{
						this.localContactInfo.flow = this.flow;
						this.dispatchEvent(new CustomEvent('next'));
					}
				}
			}
		}
		this.localContactInfo.flow = this.flow;
	}


	/* ==============================================================================================================*/
	/* Helper Methods
	/* ==============================================================================================================*/


	_showEmailValidationError(state, message){
		var emailDiv = this.template.querySelector('[data-id="emailDiv"]');
		this.errorMessage = message;
		this.displayError = state;

		if(state == true){
			emailDiv.classList.add('slds-has-error');
		}else{
			emailDiv.classList.remove('slds-has-error');
		}
	}




	@api
	getContactInfo(){
		return this.localContactInfo;
	}
	@api
	getFlow(){
		return this.flow;
	}
}