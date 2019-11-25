/* eslint-disable no-alert */
/* eslint-disable vars-on-top */

import { LightningElement, track, api} from 'lwc';

/* ==============================================================================================================*/
/* Utils & Apex & Platform
/* ==============================================================================================================*/
import { navigateToPage, getParamsFromPage }    from 'c/navigationUtils';
import RegistrationUtils                        from 'c/registrationUtils';

import getUserInformationFromEmail              from '@salesforce/apex/PortalRegistrationFirstLevelCtrl.getUserInformationFromEmail';

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
import CSP_L2_Next_Confirmation from '@salesforce/label/c.CSP_L2_Next_Confirmation';
import CSP_L2_Company_Name from '@salesforce/label/c.CSP_L2_Company_Name';
import CSP_L2_No_Matching_Results from '@salesforce/label/c.CSP_L2_No_Matching_Results';
// import CSP_Invalid_Email from '@salesforce/label/c.CSP_Invalid_Email';
// import CSP_Registration_Existing_User_Message   from '@salesforce/label/c.CSP_Registration_Existing_User_Message';
import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';

export default class PortalRegistrationEmailValidationLMS extends LightningElement {
	/* Images */
	alertIcon = CSP_PortalPath + 'alertIcon.png';

	@api customerType;
	@api contactInfo;
	@api flow;

	@track errorMessage = "";
	@track displayError = false;
	@track displaySubmitError = false;
	@track localContactInfo;
	@track userInfo = {}

	@track lms;
	@track existingUsernameVisibility;
	@track existingPersonalUsernameVisibility;
	@track validated = false;

	/* Picklist options */
	@track isoCountriesPicklistOptions;

	// customer type variables
	@track customerType;

	@track isPersonalEmail;
	@track isReverseEmail;
	
	@track isPersonalEmailVisibility = true;
	@track reverseEmailVisibility = false;

	// search inputs
	@track personalEmailInput ='';
	@track workEmailInput ='';

	get blockConfirmation(){

		let res = true;
		if(
			// (this.isPersonalEmail === 'no' && this.personalEmailInput !== '') ||
			// (this.isPersonalEmail === 'yes' && this.customerType === '') ||
			// (this.isPersonalEmail === 'yes' && this.customerType !== '' && this.workEmailInput !== '')

			(this.isPersonalEmail === 'no' && this.personalEmailInput !== '') ||
			(this.isPersonalEmail === 'yes' && this.localContactInfo.Account.Is_General_Public_Account__c === true) ||
			(this.isPersonalEmail === 'yes' && this.localContactInfo.Account.Is_General_Public_Account__c === false && this.workEmailInput !== '')
			
		){
			res = false;
		}
		return res;

	}

	// flag to warn user requesting access to a service/topic
	// @track isCategorizationModified = false;

	get PersonalEmailOptions() {
		return [
			{ label: 'Yes', value: 'yes' },
			{ label: 'No', value: 'no' }
		];
	}

	get personalEmailVisibility(){
		if(this.localContactInfo.Additional_Email__c !== '' && (this.flow === undefined || this.flow === '' || this.flow === 'flow1' || this.flow === 'flow0') ){
			return true;
		}
		return this.isPersonalEmail === 'no'? true : false;
	}

	get workEmailVisibility(){
		if(this.localContactInfo.Additional_Email__c !== '' && (this.flow === undefined || this.flow === '' || this.flow === 'flow1' || this.flow === 'flow0') ){
			return true;
		}
		return this.isPersonalEmail === 'yes' && this.localContactInfo.Account.Is_General_Public_Account__c === false ? true : false;
		
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
		CSP_L2_Next_Confirmation,
		CSP_L2_Did_Not_Find,
		CSP_L2_Did_Not_Find_Message,
		CSP_L2_No_Matching_Results
	}
	get labels() {
		return this._labels;
	}
	set labels(value) {
		this._labels = value;
	}

	connectedCallback() {
		this.localContactInfo = JSON.parse(JSON.stringify(this.contactInfo));


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

		//FLOW 1
		if(this.localContactInfo.Additional_Email__c !== '' && (this.flow === undefined || this.flow === '' || this.flow === 'flow1' || this.flow === 'flow0') ){
			this.flow = 'flow1';
			this.isPersonalEmailVisibility = false;
			this.reverseEmailVisibility = true;
			this.isPersonalEmail = 'yes';

			this.workEmailInput = this.localContactInfo.Email;
			this.personalEmailInput = this.localContactInfo.Additional_Email__c;
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
		this.inputModified = true;
	}

	changeReverseEmail(event) {
		this.isReverseEmail = event.target.value;
		this.inputModified = true;
	}

	changePersonalEmail(event){
		this.personalEmailInput = event.target.value;
		this.existingPersonalUsernameVisibility = false;
		this.existingUsernameVisibility = false;
		this.validated = false;
		this.inputModified = true;
	}

	changeWorkEmail(event){
		this.workEmailInput = event.target.value;
		this.existingPersonalUsernameVisibility = false;
		this.existingUsernameVisibility = false;
		this.validated = false;
		this.inputModified = true;
	}


	/* Navigation methods */
	previous(){
		this.dispatchEvent(new CustomEvent('previous'));
	}

	next(){

		if(this.flow === 'flow1'){
			if(this.isReverseEmail === 'yes'){
				this.flow = 'flow0';
				this.localContactInfo.Email = this.personalEmailInput;
				this.localContactInfo.Additional_Email__c = this.workEmailInput;
			}
			this.dispatchEvent(new CustomEvent('next'));
		}else{

			//
			// if(this.isPersonalEmail === 'yes' && this.customerType === ''){
			if(this.isPersonalEmail === 'yes' && this.localContactInfo.Account.Is_General_Public_Account__c === true){
				this.localContactInfo.Additional_Email__c = this.localContactInfo.Email;
				this.flow = 'flow2';
				this.dispatchEvent(new CustomEvent('next'));
			}else{

				let auxEmail = '';

				const RegistrationUtilsJs = new RegistrationUtils();

				if(this.isPersonalEmail === 'no' && this.personalEmailInput !== ''){
					this.localContactInfo.Additional_Email__c = this.personalEmailInput;
					auxEmail = this.personalEmailInput;
				}

				if(this.isPersonalEmail === 'yes' && this.localContactInfo.Account.Is_General_Public_Account__c === false && this.workEmailInput !== ''){
					this.localContactInfo.Additional_Email__c = this.workEmailInput;
					auxEmail = this.workEmailInput;
				}

				if(auxEmail !== '' && this.validated === false){

					if(this.isPersonalEmail === 'no' && this.personalEmailInput !== ''){
						this.flow = 'flow5';
					}

					if(this.isPersonalEmail === 'yes' && this.localContactInfo.Account.Is_General_Public_Account__c === false && this.workEmailInput !== ''){
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
								if(result2 == 'true'){
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
											this.existingUsernameVisibility = true;
											if(userInfo.hasExistingUser == true){

												if(this.flow === 'flow3'){
													this.flow = 'flow4';
												}
												if(this.flow === 'flow5'){
													this.flow = 'flow6';
												}
						
												this.localContactInfo.existingContactId = userInfo.contactId;
												this.localContactInfo.existingContactAccount = userInfo.existingContactAccount;
												this.localContactInfo.hasExistingContact = userInfo.hasExistingContact;
												this.localContactInfo.hasExistingUser = userInfo.hasExistingUser;
												this.localContactInfo.hasExistingContact = userInfo.hasExistingContact;
												this.localContactInfo.existingContactEmail = userInfo.existingContactEmail;
												this.localContactInfo.existingContactName = userInfo.existingContactName;
												this.localContactInfo.hasExistingContactPersonalEmail = userInfo.hasExistingContactPersonalEmail;
												this.localContactInfo.hasExistingUserPersonalEmail = userInfo.hasExistingUserPersonalEmail;

												this._showEmailValidationError(true, this.labels.CSP_Registration_Existing_User_Message);
												this.stopLoading();
											}
										}else{
											//Don't validate the personal email for this flow
											if(this.flow === 'flow3'){
												this.stopLoading();
												this.dispatchEvent(new CustomEvent('next'));
											}else if(userInfo.hasExistingContactPersonalEmail == true){
												this.existingPersonalUsernameVisibility = true;
												if(userInfo.hasExistingUserPersonalEmail == true){

													if(this.flow === 'flow5'){
														this.flow = 'flow7';
													}

													console.log('userInfo.contactId: ', userInfo.contactId);

													this.localContactInfo.hasExistingContact = userInfo.hasExistingContact;
													this.localContactInfo.hasExistingUser = userInfo.hasExistingUser;
													this.localContactInfo.existingContactAccount = userInfo.existingContactAccount;
													this.localContactInfo.existingContactEmail = userInfo.existingContactEmail;
													this.localContactInfo.existingContactId = userInfo.existingContactId;
													this.localContactInfo.existingContactName = userInfo.existingContactName;
													this.localContactInfo.hasExistingContactPersonalEmail = userInfo.hasExistingContactPersonalEmail;
													this.localContactInfo.hasExistingUserPersonalEmail = userInfo.hasExistingUserPersonalEmail;


													this._showEmailValidationError(true, this.labels.CSP_Registration_Existing_User_Message);
													this.stopLoading();
												}
												//Send Verification email
												this._showEmailValidationError(true, this.labels.CSP_Invalid_Email);
												this.stopLoading();
											}else{

												this.stopLoading();
												this.dispatchEvent(new CustomEvent('next'));
											}
										}
										this.validated = true;
									})
									.catch(error => {
										console.log('Error: ', error);
										this.isLoading = false;
									});
								}
							});
						}
					});
				}else{
					this.dispatchEvent(new CustomEvent('next'));
				}
			}
		}


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