import { LightningElement,track,api } from 'lwc';

import RegistrationUtils                        from 'c/registrationUtils';

import getContactInfo               	from '@salesforce/apex/PortalRegistrationSecondLevelCtrl.getContactInfo';
import getLMSContactInfo               	from '@salesforce/apex/PortalRegistrationThirdLevelLMSCtrl.getLMSContactInfo';
import getUserInformationFromEmail              from '@salesforce/apex/PortalRegistrationFirstLevelCtrl.getUserInformationFromEmail';
import validateFullName							from '@salesforce/apex/PortalRegistrationThirdLevelLMSCtrl.validateFullName';
import sendSingleEmail						from '@salesforce/apex/PortalRegistrationThirdLevelLMSCtrl.sendSingleEmail';

//custom labels
import CSP_L2_Business_Address_Information from '@salesforce/label/c.CSP_L2_Business_Address_Information_LMS';
import CSP_L2_Create_New_Account from '@salesforce/label/c.CSP_L2_Create_New_Account';
import CSP_L2_Company_Information_Message from '@salesforce/label/c.CSP_L2_Company_Information_Message';
import CSP_L2_Company_Information from '@salesforce/label/c.CSP_L2_Company_Information';
import ISSP_MyProfile_SECTOR from '@salesforce/label/c.ISSP_MyProfile_SECTOR';
import ISSP_MyProfile_CATEGORY from '@salesforce/label/c.ISSP_MyProfile_CATEGORY';
import CSP_L2_Legal_Name from '@salesforce/label/c.CSP_L2_Legal_Name';
import CSP_L2_Trade_Name from '@salesforce/label/c.CSP_L2_Trade_Name';
import CSP_L2_Phone_Number from '@salesforce/label/c.CSP_L2_Phone_Number';
import CSP_L2_Email_Address from '@salesforce/label/c.CSP_L2_Email_Address';
import CSP_L2_Website from '@salesforce/label/c.CSP_L2_Website';
import CSP_L2_Business_Address_Information_Message from '@salesforce/label/c.CSP_L2_Business_Address_Information_Message_LMS';
import CSP_L2_Back_to_Company_Information from '@salesforce/label/c.CSP_L2_Back_to_Company_Information';
import CSP_L2_Next_Confirmation from '@salesforce/label/c.CSP_L2_Next_Confirmation';
import CSP_Next_LMS from '@salesforce/label/c.CSP_Next_LMS';
import SaveLabel from '@salesforce/label/c.CSP_Save';
import CancelLabel from '@salesforce/label/c.CSP_Cancel';
import CSP_L3_PersonalEmail_LMS from '@salesforce/label/c.CSP_L3_PersonalEmail_LMS';

import CSP_Registration_Existing_User_Message_Not_Matching_F6 from '@salesforce/label/c.CSP_Registration_Existing_User_Message_Not_Matching_F6';
import CSP_Invalid_Email from '@salesforce/label/c.CSP_Invalid_Email';
import CSP_Registration_Existing_Work_Message_LMS from '@salesforce/label/c.CSP_Registration_Existing_Work_Message_LMS_Profile';
import CSP_L3_ExistingContact_LMS from '@salesforce/label/c.CSP_L3_ExistingContact_LMS';
import CSP_L3_ExistingContact_LMS2 from '@salesforce/label/c.CSP_L3_ExistingContact_LMS2';
import CSP_L3_VerificationMailTitle_LMS from '@salesforce/label/c.CSP_L3_VerificationMailTitle_LMS';
import CSP_L2_VerificationToP1_LMS from '@salesforce/label/c.CSP_L2_VerificationToP1_LMS';
import CSP_L2_VerificationToP2_LMS from '@salesforce/label/c.CSP_L2_VerificationToP2_LMS';
import CSP_L2_VerificationToP3_LMS from '@salesforce/label/c.CSP_L2_VerificationToP3_LMS';
import CSP_L2_RegistrationFailed_LMS from '@salesforce/label/c.CSP_L2_RegistrationFailed_LMS';
import CSP_Close from '@salesforce/label/c.CSP_Close';
import CSP_LogOut from '@salesforce/label/c.CSP_LogOut';
import CSP_Registration_Existing_User_Message_Not_Matching_F6_Prof from '@salesforce/label/c.CSP_Registration_Existing_User_Message_Not_Matching_F6_Prof';



export default class PortalRegistrationAddressInformationLMS extends LightningElement {

	// inputs
	@api address;
	@api countryId;
	@api recordId;
	@api contactId;
	@api additionalEmail;
	
	@track localAddress;
	@track localAdditionalEmail;
	@track isSaving = false;
	@track savedForm = 0;

	@track errorMessage = ""; 
	@track displayError = false;
	@track displaySubmitError = false;
	@track localContactInfo;
	@track contactInfo;
	@track userInfo = {}
	@track messageFlow6;
	@track messageFlow7;

	@track isLoading = false;
	@track lms;
	@track existingUsernameVisibility = false;
	@track existingPersonalUsernameVisibility = false;
	@track existingUsernameNotMatchingF6Visibility = false;
	@track validated = false;
	@track isFullNameMatching = true;
	@track isMailChanged = false;
	@track initialMail = '';

	@track openVerificationMailSuccessModal = false;
	@track openVerificationMailSuccessModalLogOut = false;

	// flag to enable/disable the "Next Step / Confirmation" button
	@track isConfirmationButtonDisabled;

	// labels
	_labels = {
		CSP_L2_Business_Address_Information,
		CSP_L2_Create_New_Account,
		CSP_L2_Company_Information_Message,
		CSP_L2_Company_Information,
		ISSP_MyProfile_SECTOR,
		ISSP_MyProfile_CATEGORY,
		CSP_L2_Legal_Name,
		CSP_L2_Trade_Name,
		CSP_L2_Phone_Number,
		CSP_L2_Email_Address,
		CSP_L2_Website,
		CSP_L2_Business_Address_Information_Message,
		CSP_L2_Back_to_Company_Information,
		CSP_L2_Next_Confirmation,
		CSP_Next_LMS,
		SaveLabel,
		CancelLabel,
		CSP_L3_PersonalEmail_LMS,
		CSP_Registration_Existing_User_Message_Not_Matching_F6,
		CSP_Invalid_Email,
		CSP_Registration_Existing_Work_Message_LMS,
		CSP_L3_ExistingContact_LMS,
		CSP_L3_ExistingContact_LMS2,
		CSP_L3_VerificationMailTitle_LMS,
		CSP_L2_VerificationToP1_LMS,
		CSP_L2_VerificationToP2_LMS,
		CSP_L2_VerificationToP3_LMS,
		CSP_L2_RegistrationFailed_LMS,
		CSP_Close,
		CSP_LogOut,
		CSP_Registration_Existing_User_Message_Not_Matching_F6_Prof
	}


	get labels() {
		return this._labels;
	}
	set labels(value) {
		this._labels = value;
	}

	connectedCallback() {

		this.lms = 'yas';

		//Set the initial mail to test if after changing the email to check if the change is equal to the initial email
		this.initialMail = this.additionalEmail;
		this.localAdditionalEmail = '';

		if(this.additionalEmail !== null && this.additionalEmail !== '' && this.additionalEmail != undefined){
			this.validated = true;
			this.localAdditionalEmail = this.additionalEmail;
		}

		this.localAddress = JSON.parse(JSON.stringify(this.address));
		this.dispatchEvent(new CustomEvent('scrolltotop'));
		
		// Retrieve Contact information
		getContactInfo()
			.then(result => {
				this.localContactInfo = JSON.parse(JSON.stringify(result));
				this.localContactInfo.lms = 'yas';
				
				this.localContactInfo.serviceid = this.serviceid;
				getLMSContactInfo({lms:'yas'})
					.then(result2 => {
						if(result2 !== undefined && result2 !== null){
							this.contactInfoLMS = JSON.parse(JSON.stringify(result2));
							this.localContactInfo.Username = this.contactInfoLMS.Username__c !== undefined && this.contactInfoLMS.Username__c !== null ? this.contactInfoLMS.Username__c : '';
							this.localContactInfo.UserId = this.contactInfoLMS.UserId__c !== undefined && this.contactInfoLMS.UserId__c !== null ? this.contactInfoLMS.UserId__c : '';
						}else{
							this.localContactInfo.Username = '';
							this.localContactInfo.UserId = '';
						}
					})
				.catch((error2) => {
					this.localContactInfo.Username = '';
					this.localContactInfo.UserId = '';
				});
				
			})
		.catch((error) => {
			this.openMessageModalFlowRegister = true;
			this.message = CSP_L2_RegistrationFailed_LMS + error;
		})
		
	}

	toCompanyInformation(){
		this.dispatchEvent(new CustomEvent('gotostep', {detail:'1'}));
	}

	toConfirmation(){
		this.dispatchEvent(new CustomEvent('gotostep', {detail:'2'}));
	}

	next(){
		this.dispatchEvent(new CustomEvent('next'));
	}

	setValidationStatus(event){
		let res = this.template.querySelector('c-portal-address-form-l-m-s').getAddressInformation();
			
		this.localAddress = JSON.parse(JSON.stringify(res));
		
		if(this.localAddress.countryId !== '' && this.localAddress.cityName !== '' && (this.localAddress.street !== '' || this.localAddress.PO_Box_Address__c !== '') ){
			this.isConfirmationButtonDisabled = false;
		}else if(this.isConfirmationButtonDisabled !== !event.detail){
			this.isConfirmationButtonDisabled = !event.detail;
			this.dispatchEvent(new CustomEvent('completionstatus',{detail : event.detail}));
		}
	}

	startLoading(){
		this.isLoading = true;
	}

	stopLoading(){
		this.isLoading = false;
	}

	@api
	getAddressInformation(){
		let resAddressInformation = this.template.querySelector('c-portal-address-form-l-m-s').getAddressInformation();
		this.localAddress = JSON.parse(JSON.stringify(resAddressInformation));
		return this.localAddress;
	}

	closeModal() { 
		this.dispatchEvent(new CustomEvent('closemodal'));
	}


	handleSubmit(event) {
		this.isSaving = true;
		
		this.localAddress = JSON.parse(JSON.stringify(this.getAddressInformation() ));
		let contactSubmit = {
			'Additional_Email__c':''
		};
		let addressSubmit = {
			'PO_Box_Address__c':'',
			'Country_Reference__c':'',
			'countryCode':'',
			'Country__c':'',
			'State_Reference__c':'',
			'State_Name__c':'',
			'City_Reference__c':'',
			'City_Name__c':'',
			'Street__c':'',
			'Street2__c':'',
			'Postal_Code__c':''
		};

		contactSubmit.Additional_Email__c = this.localAdditionalEmail;
		addressSubmit.Country_Reference__c = this.localAddress.countryId; 
		addressSubmit.Country__c = this.localAddress.countryName;
		addressSubmit.State_Reference__c = this.localAddress.stateId;
		addressSubmit.State_Name__c = this.localAddress.stateName;
		addressSubmit.City_Reference__c = this.localAddress.cityId;
		addressSubmit.City_Name__c = this.localAddress.cityName;
		addressSubmit.Street__c = this.localAddress.isPoBox === false ? this.localAddress.street : '';
		addressSubmit.Street2__c = this.localAddress.street2;
		addressSubmit.Postal_Code__c = this.localAddress.zip;
		addressSubmit.PO_Box_Address__c = this.localAddress.isPoBox === true ? this.localAddress.PO_Box_Address__c : '';
		
		this.template.querySelector('lightning-record-edit-form').submit(addressSubmit);
	}
	
	handleSucess(event) {
		this.isSaving = false;
		let toSave = false;

		if(this.isMailChanged && (this.flow === 'flow5' || this.flow === 'flow6' || this.flow === 'flow7') ){
			toSave = true;
			if((this.flow === 'flow6' || this.flow === 'flow7') && this.isFullNameMatching === false){
				toSave = false;
			}
		}

		if(toSave){
			this.localContactInfo.flow = this.flow;
			this.localContactInfo.existingContactId = this.localContactInfo.existingContactId;
			this.localContactInfo.existingContactName = this.localContactInfo.existingContactName;
			this.localContactInfo.existingContactEmail = this.localContactInfo.existingContactEmail;
			this.localContactInfo.existingContactAccount = this.localContactInfo.existingContactAccount;
			this.localContactInfo.Additional_Email__c = this.localAdditionalEmail;

			//Move address info into ContactInfo
			this.localContactInfo.isPoBox = this.localAddress.isPoBox;
			this.localContactInfo.countryId = this.localAddress.countryId;
			this.localContactInfo.countryCode = this.localAddress.countryCode;
			this.localContactInfo.countryName = this.localAddress.countryName;
			this.localContactInfo.stateId = this.localAddress.stateId;
			this.localContactInfo.stateName = this.localAddress.stateName;
			this.localContactInfo.cityId = this.localAddress.cityId;
			this.localContactInfo.cityName = this.localAddress.cityName;
			this.localContactInfo.street = this.localAddress.street;
			this.localContactInfo.street2 = this.localAddress.street2;
			this.localContactInfo.zip = this.localAddress.zip;

			if(this.localContactInfo.Username !== '' && this.localContactInfo.UserId !== ''
				&& this.userInfo.existingContactTrainingUsername !== undefined && this.userInfo.existingContactTrainingUserId !== undefined){
					this.localContactInfo.Username = this.userInfo.existingContactTrainingUsername !== undefined ? this.userInfo.existingContactTrainingUsername : '';
					this.localContactInfo.UserId = this.userInfo.existingContactTrainingUserId !== undefined ? this.userInfo.existingContactTrainingUserId : '';
					this.localContactInfo.ExistingTrainingInfo = true;
			}else{
				this.localContactInfo.Username = this.localContactInfo.Username;
				this.localContactInfo.UserId = this.localContactInfo.UserId;
			
			}

			let contactName = this.localContactInfo.FirstName + ' ' + this.localContactInfo.LastName;
			let notificationEmail = this.localAdditionalEmail;
			sendSingleEmail({contactName: contactName,
								emailAddr: notificationEmail,
								flow:this.flow,
								params : JSON.stringify(this.localContactInfo)})
			.then(result => {
				if(result.isSuccess == true){

					this.openVerificationMailSuccessModal = true;
					this.verificationModalMessage = CSP_L2_VerificationToP1_LMS + ' ' + this.localContactInfo.Additional_Email__c + CSP_L2_VerificationToP2_LMS;
					
				}else{
					this.openErrorModal = true;
					if(result.message !== ''){
						this.errorModalMessage = result.message;
					}else{
						this.errorModalMessage = CSP_L2_RegistrationFailed_LMS;
					}
				}
				this.stopLoading();
			})
			.catch(error => {
				this.openErrorModal = true;
				this.errorModalMessage = JSON.parse(JSON.stringify(error));
				this.stopLoading();
			});
		}else{
			this.closeModal();
		}
    }

    handleError(event) {
		this.isSaving = false;
    }

    onRecordSubmit(event) {
		this.isSaving = true;
	}
	
	handleFieldChange(event){
		this.localAdditionalEmail = event.target.value;

		//validate if the change return the email to its initial value
		if(this.localAdditionalEmail === this.initialMail){
			this.isMailChanged = false;
			this.validated = true;
		}else{
			this.isMailChanged = true;
			this.validated = false;
		}
		
		this.existingPersonalUsernameVisibility = false;
		this.existingUsernameVisibility = false;
		this.existingUsernameNotMatchingF6Visibility = false;
	}

	button1Action(){
		this.closeModal();
	}

	next(){

		if(this.validated === true){
			this.handleSubmit();
		}else{

			let auxEmail = this.localAdditionalEmail;

			const RegistrationUtilsJs = new RegistrationUtils();
	
			if(auxEmail !== '' && this.validated === false){

				this.flow = 'flow5';

				this.startLoading();
				RegistrationUtilsJs.checkEmailIsValid(`${auxEmail}`).then(result=> {
					if(result == false){
						this.isLoading = false;
					}else{
						let anonymousEmail = 'iata' + auxEmail.substring(auxEmail.indexOf('@'));
						RegistrationUtilsJs.checkEmailIsDisposable(`${anonymousEmail}`).then(result2=> {
							if(result2 === 'true'){
								this.stopLoading();
							}else{
								//1) If there is an existing contact & user with that email -> The user is redirected to the login page,
								//but the "E-Mail" field is pre-populated and, by default, not editable.
								//The user can click a Change E-Mail link to empty the E-Mail field and set it editable again.
								//2) If there is an existing contact but not a user with that email -> Terms and conditions and submit
								//button is displayed on the form.
								getUserInformationFromEmail({ email : auxEmail, LMSRedirectFrom: this.lms}).then(result3 => {

									var userInfo = JSON.parse(JSON.stringify(result3));
									this.userInfo = userInfo;

									if(userInfo.hasExistingContact == true){
											if(this.flow === 'flow5'){
												this.flow = 'flow6';
											}

											//validate the 60% on the name comparison
											validateFullName({existingContactId: userInfo.existingContactId , firstname : this.localContactInfo.FirstName, lastname : this.localContactInfo.LastName})
												.then(result4 => {

													//TO REMOVE AFTER FIX ON MULESOFT FOR FLOWS 6 and 7
													//the line of code below is set to do not execute FLOW6 and 7 on the Myprofile
													result4 = 'not_matching';
													
													if(result4 === 'not_matching'){
														this.isFullNameMatching = false;
														if(this.flow === 'flow6'){
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
												});

											this.stopLoading();
									}else{
										if(userInfo.hasExistingContactPersonalEmail == true){
											
												if(this.flow === 'flow5'){
													this.flow = 'flow7';
												}

												//validate the 60% on the name comparison
												validateFullName({existingContactId: userInfo.existingContactId , firstname : this.localContactInfo.FirstName, lastname : this.localContactInfo.LastName})
												.then(result4 => {

													//TO REMOVE AFTER FIX ON MULESOFT FOR FLOWS 6 and 7
													//the line of code below is set to do not execute FLOW6 and 7 on the Myprofile
													result4 = 'not_matching';

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
												});
												this.stopLoading();
											this.stopLoading();
										}else{

											this.stopLoading();
											this.localContactInfo.flow = this.flow;

											this.handleSubmit();
										}
									}
									this.validated = true;
								})
								.catch(error => {
									this.stopLoading();
									
								});
							}
						});
					}
				});
			}else{
				this.localContactInfo.flow = this.flow;
				this.handleSubmit();
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

}