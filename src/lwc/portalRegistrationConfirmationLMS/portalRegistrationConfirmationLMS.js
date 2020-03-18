/* eslint-disable no-alert */
/* eslint-disable vars-on-top */

import { LightningElement, api, track } from 'lwc';

import createIsoCity                        from '@salesforce/apex/PortalRegistrationSecondLevelCtrl.createIsoCity';
import registration                         from '@salesforce/apex/PortalRegistrationThirdLevelLMSCtrl.registration';
import sendSingleEmail						from '@salesforce/apex/PortalRegistrationThirdLevelLMSCtrl.sendSingleEmail';
import getLMSTermAndConditionAcceptance		from '@salesforce/apex/PortalRegistrationThirdLevelLMSCtrl.getLMSTermAndConditionAcceptance';
import verifyCompleteL3DataWithCourse		from '@salesforce/apex/PortalServicesCtrl.verifyCompleteL3DataWithCourse';
import getPortalServiceId 					from '@salesforce/apex/PortalServicesCtrl.getPortalServiceId';

import { navigateToPage } from'c/navigationUtils';

import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';

import ISSP_CompanyName      from '@salesforce/label/c.ISSP_CompanyName';

import CSP_L3_Confirmation_Message_LMS from '@salesforce/label/c.CSP_L3_Confirmation_Message_LMS';
import CSP_L2_Profile_Details from '@salesforce/label/c.CSP_L2_Profile_Details';
import CSP_L2_Personal_Details_Message from '@salesforce/label/c.CSP_L2_Personal_Details_Message';
import CSP_L2_Back_to_Edit from '@salesforce/label/c.CSP_L2_Back_to_Edit';
import CSP_L2_Company_Account from '@salesforce/label/c.CSP_L2_Company_Account';
import CSP_L2_Company_Account_Message from '@salesforce/label/c.CSP_L2_Company_Account_Message';
import CSP_L2_Back_to_Business_Address_Information from '@salesforce/label/c.CSP_L2_Back_to_Business_Address_Information';
import CSP_L2_Submit from '@salesforce/label/c.CSP_L2_Submit';
import CSP_L2_Details_Saved from '@salesforce/label/c.CSP_L2_Details_Saved';
import CSP_L2_Details_Saved_Message_LMS from '@salesforce/label/c.CSP_L2_Details_Saved_Message_LMS';
import CSP_L2_Go_To_Homepage_LMS from '@salesforce/label/c.CSP_L2_Go_To_Homepage_LMS';
import CSP_L2_Go_To_Service_LMS from '@salesforce/label/c.CSP_L2_Go_To_Service_LMS';
import CSP_L2_Company_Information from '@salesforce/label/c.CSP_L2_Company_Information';
import CSP_L2_Business_Address_Information from '@salesforce/label/c.CSP_L2_Business_Address_Information';
import CSP_L2_Is_PO_Box_Address from '@salesforce/label/c.CSP_L2_Is_PO_Box_Address';

import CSP_L2_Title from '@salesforce/label/c.CSP_L2_Title';
import CSP_L2_Date_of_Birth from '@salesforce/label/c.CSP_L2_Date_of_Birth';
import CSP_L2_Job_Function from '@salesforce/label/c.CSP_L2_Job_Function';
import CSP_L2_Job_Title from '@salesforce/label/c.CSP_L2_Job_Title';
import CSP_L2_Back_to_Account_Selection from '@salesforce/label/c.CSP_L2_Back_to_Account_Selection';
import ISSP_MyProfile_SECTOR from '@salesforce/label/c.ISSP_MyProfile_SECTOR';
import ISSP_MyProfile_CATEGORY from '@salesforce/label/c.ISSP_MyProfile_CATEGORY';
import CSP_L2_Street from '@salesforce/label/c.CSP_L2_Street';
import CSP_L2_Country from '@salesforce/label/c.CSP_L2_Country';
import CSP_L2_Trade_Name from '@salesforce/label/c.CSP_L2_Trade_Name';
import CSP_L2_Legal_Name from '@salesforce/label/c.CSP_L2_Legal_Name';
import CSP_L2_Phone_Number from '@salesforce/label/c.CSP_L2_Phone_Number';
import CSP_L2_Email_Address from '@salesforce/label/c.CSP_L2_Email_Address';
import CSP_L2_Website from '@salesforce/label/c.CSP_L2_Website';
import CSP_L2_State from '@salesforce/label/c.CSP_L2_State';
import CSP_L2_City from '@salesforce/label/c.CSP_L2_City';
import CSP_L2_Postal_Code from '@salesforce/label/c.CSP_L2_Postal_Code';
import CSP_LMS_Privacy_Policy from '@salesforce/label/c.CSP_LMS_Privacy_Policy';
import CSP_L3_LoginEmail_LMS from '@salesforce/label/c.CSP_L3_LoginEmail_LMS';
import CSP_L3_PersonalEmail_LMS from '@salesforce/label/c.CSP_L3_PersonalEmail_LMS';
import CSP_L3_Username_LMS from '@salesforce/label/c.CSP_L3_Username_LMS';
import CSP_L3_UserId_LMS from '@salesforce/label/c.CSP_L3_UserId_LMS';
import CSP_L3_Phone_LMS from '@salesforce/label/c.CSP_L3_Phone_LMS';
import CSP_L3_WorkPhone_LMS from '@salesforce/label/c.CSP_L3_WorkPhone_LMS';
import CSP_L2_Registration_Failed_LMS from '@salesforce/label/c.CSP_L2_Registration_Failed_LMS';
import CSP_L2_RegistrationFailed_LMS from '@salesforce/label/c.CSP_L2_RegistrationFailed_LMS';
import CSP_L2_VerificationToP1_LMS from '@salesforce/label/c.CSP_L2_VerificationToP1_LMS';
import CSP_L2_VerificationToP2_LMS from '@salesforce/label/c.CSP_L2_VerificationToP2_LMS';
import CSP_L_TrainingEmail_LMS from '@salesforce/label/c.CSP_L_TrainingEmail_LMS';
import CSP_L_TrainingUser_LMS from '@salesforce/label/c.CSP_L_TrainingUser_LMS';


export default class PortalRegistrationConfirmationLMS extends LightningElement {
	/* Images */
	successIcon = CSP_PortalPath + 'CSPortal/Images/Icons/youaresafe.png';

	// TO DO : find an image for error
	errorIcon = CSP_PortalPath + 'CSPortal/Images/Icons/youaresafe.png';

	@api contactInfo;
	@api flow;
	@api address;
	@api isIE;

	@track street;
	@track street2;
	@track zip;
	@track city;
	@track state;
	@track tos;

	createdCityId;

	
	@track trainingInfoVisibility = false;
	
	@track openSuccessModal = false;
	@track openVerificationMailSuccessModal = false;
	@track openErrorModal = false;
	successModalTitle = 'Verification Mail';
	@track successModalMessage = '';
	errorModalTitle = 'Error';
	@track errorModalMessage = '';

	@track registrationForm = { "email" : "",
		"firstName" : "",
		"lastName" : "",
		"country" : "",
		"contactId" : "",
		"accountId" : "",
		"existingContactId" : "",
		"existingContactName" : "",
		"existingContactEmail" : "",
		"existingContactAccount" : ""
	};


	// label variables
	_labels = {
		CSP_L2_Back_to_Account_Selection,
		CSP_L2_Back_to_Business_Address_Information,
		CSP_L2_Back_to_Edit,
		CSP_L2_Business_Address_Information,
		CSP_L2_City,
		CSP_L2_Company_Account,
		CSP_L2_Company_Account_Message,
		CSP_L2_Company_Information,
		CSP_L3_Confirmation_Message_LMS,
		CSP_L2_Country,
		CSP_L2_Date_of_Birth,
		CSP_L2_Details_Saved,
		CSP_L2_Details_Saved_Message_LMS,
		CSP_L2_Email_Address,
		CSP_L2_Go_To_Homepage_LMS,
		CSP_L2_Go_To_Service_LMS,
		CSP_L2_Job_Function,
		CSP_L2_Job_Title,
		CSP_L2_Legal_Name,
		CSP_L2_Profile_Details,
		CSP_L2_Personal_Details_Message,
		CSP_L2_Phone_Number,
		CSP_L2_Postal_Code,
		CSP_L2_State,
		CSP_L2_Street,
		CSP_L2_Submit,
		CSP_L2_Title,
		CSP_L2_Trade_Name,
		CSP_L2_Website,
		ISSP_CompanyName,
		ISSP_MyProfile_CATEGORY,
		ISSP_MyProfile_SECTOR,
		CSP_LMS_Privacy_Policy,
		CSP_L3_LoginEmail_LMS,
		CSP_L3_PersonalEmail_LMS,
		CSP_L3_Username_LMS,
		CSP_L3_UserId_LMS,
		CSP_L3_Phone_LMS,
		CSP_L3_WorkPhone_LMS,
		CSP_L2_Registration_Failed_LMS,
		CSP_L2_RegistrationFailed_LMS,
		CSP_L2_VerificationToP1_LMS,
		CSP_L2_VerificationToP2_LMS,
		CSP_L_TrainingEmail_LMS,
		CSP_L_TrainingUser_LMS
	}
	get labels() {
		return this._labels;
	}
	set labels(value) {
		this._labels = value;
	}

	connectedCallback(){
		this.localContactInfo = JSON.parse(JSON.stringify(this.contactInfo));
		this.localAddress = JSON.parse(JSON.stringify(this.address));

		this.street = this.localAddress.street;
		this.street2 = this.localAddress.street2;
		this.zip = this.localAddress.zip;
		this.city = this.localAddress.cityName;
		this.state = this.localAddress.stateName;

		//if training info already exists we don't show, only when the user enter de data manually
		if(!this.localContactInfo.ExistingTrainingInfo 
			&& this.localContactInfo.Username !== '' && this.localContactInfo.Username !== null && this.localContactInfo.Username !== undefined
			&& this.localContactInfo.UserId !== '' && this.localContactInfo.UserId !== null && this.localContactInfo.UserId !== undefined ){
				
			this.trainingInfoVisibility = true;
		}

		for(let i = 0; i < this.localAddress.addressSuggestions.length; i++){
			if(this.localAddress.addressSuggestions[i].isSelected){
				this.street = this.localAddress.addressSuggestions[i].street;
				this.zip = this.localAddress.addressSuggestions[i].postalCode;

				if(this.address.stateId === ''){
					this.state = this.localAddress.addressSuggestions[i].province !== undefined? this.localAddress.addressSuggestions[i].province : '';
					this.city = this.localAddress.addressSuggestions[i].locality !== undefined? this.localAddress.addressSuggestions[i].locality : '';
				}
			}
		}

		let service = this.localContactInfo.serviceid != '' ? this.localContactInfo.serviceid : 'yas';

		getLMSTermAndConditionAcceptance({serviceId: service, contactId:this.localContactInfo.Id})
		.then(result => {
			this.tos = result;

			var submitButton = this.template.querySelector('[data-id="submitButton"]');
			if(this.tos){
				submitButton.classList.remove('containedButtonDisabled');
				submitButton.classList.add('containedButtonLogin');
				submitButton.disabled = false;
			}
			else{
				submitButton.classList.remove('containedButtonLogin');
				submitButton.classList.add('containedButtonDisabled');
				submitButton.disabled = true;
			}
		})
		.catch((error) => {
			this.openMessageModalFlowRegister = true;
			this.message = CSP_L2_RegistrationFailed_LMS + error;
			console.log('Error: ', JSON.parse(JSON.stringify(error)));
		});

	}

	startLoading(){
		this.dispatchEvent(new CustomEvent('startloading'));
	}

	stopLoading(){
		this.dispatchEvent(new CustomEvent('stoploading'));
	}

	submit(){
		this.startLoading();
		this.submitRegistration();
	}

	submitRegistration(){
		let auxSearchValues = new Map();

		let lmsCourseDecoded = '';

		lmsCourseDecoded = decodeURIComponent(this.localContactInfo.lmsCourse);

		auxSearchValues = [
			this.localContactInfo.Username,
			this.localContactInfo.UserId,
			lmsCourseDecoded,
			this.street,
			this.zip,
			this.localAddress.countryId,
			this.localAddress.stateId,
			this.state,
			this.createdCityId === '' ? this.createdCityId : this.localAddress.cityId,
			this.city,
			this.localAddress.isPoBox,
			this.localContactInfo.serviceid,
			this.localAddress.street2,
			this.localContactInfo.existingTrainingId
		];

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


		if(this.flow === 'flow0' || this.flow === 'flow1' || this.flow === 'flow2'){
			registration({con: this.localContactInfo, extraValues: auxSearchValues})
				.then(result => {
					if(result.isSuccess == true){
							this.openSuccessModal = true;
						}
						else{
							this.openErrorModal = true;
							if(result.message !== ''){
								this.errorModalMessage = result.message;
							}else{
								this.errorModalMessage = CSP_L2_Registration_Failed_LMS;
							}

						}
						this.stopLoading();
					})
					.catch(error => {
						console.log('Error: ', JSON.parse(JSON.stringify(error)));
						this.openErrorModal = true;
						this.errorModalMessage = JSON.parse(JSON.stringify(error));
						this.stopLoading();
					});
		}

		if(this.flow === 'flow3' || this.flow === 'flow4' || this.flow === 'flow5' || this.flow === 'flow6' || this.flow === 'flow7' ){

			this.localContactInfo.flow = this.flow;
			this.localContactInfo.existingContactId = this.localContactInfo.existingContactId;
			this.localContactInfo.existingContactName = this.localContactInfo.existingContactName;
			this.localContactInfo.existingContactEmail = this.localContactInfo.existingContactEmail;
			this.localContactInfo.existingContactAccount = this.localContactInfo.existingContactAccount;

			let contactName = this.localContactInfo.FirstName + ' ' + this.localContactInfo.LastName;

			sendSingleEmail({contactName: contactName,
								emailAddr: this.localContactInfo.Additional_Email__c,
								flow:this.flow,
								params : JSON.stringify(this.localContactInfo)})
			.then(result => {
				if(result.isSuccess == true){
						this.openVerificationMailSuccessModal = true;
						this.successModalMessage = CSP_L2_VerificationToP1_LMS + ' ' + this.localContactInfo.Additional_Email__c + CSP_L2_VerificationToP2_LMS;
					}
					else{
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
					console.log('Error: ', JSON.parse(JSON.stringify(error)));
					this.openErrorModal = true;
					this.errorModalMessage = JSON.parse(JSON.stringify(error));
					this.stopLoading();
				});
		}

	}



	closeSuccessModal(){

		this.openSuccessModal = false;
	}

	closeVerificationMailSuccessModal(){
		this.openVerificationMailSuccessModal = false;
	}

	closeErrorModal(){
		this.openErrorModal = false;
	}

	toProfileDetails(){
		this.dispatchEvent(new CustomEvent('toprofiledetails'));
	}

	toAddressInformation(){
		this.dispatchEvent(new CustomEvent('toaddressinformation'));
	}

	button1Action(){
		this.dispatchEvent(new CustomEvent('secondlevelregistrationcompletedactionone'));
	}

	button2Action(){
		this.dispatchEvent(new CustomEvent('secondlevelregistrationcompletedactiontwo'));
	}

	get displayToS(){
		return true;
	}

	sleep(ms) {
		return new Promise(resolve => setTimeout(resolve, ms));
	}

	goToService(){
		this.startLoading();
		getPortalServiceId({ serviceName: 'Training Platform (LMS)' })
			.then(serviceId => {
				verifyCompleteL3DataWithCourse({serviceId: serviceId})
				.then(result => {					
					if(result !== 'not_complete'){
						//need to wait a few seconds while mulesoft creates the user in YAS, otherwise we can get an SSO error saying the user not existing
						this.closeSuccessModal();
						this.sleep(6000)
						.then(() => { 
							window.open(result);
							this.stopLoading();
							this.dispatchEvent(new CustomEvent('secondlevelregistrationcompletedactionone'));
						})
					}
					else{
						this.stopLoading();
						navigateToPage(CSP_PortalPath+'?firstLogin=true&lms=yas');
					}
				})
				.catch(error => {
					this.stopLoading();
					this.error = error;
				});
			})
			.catch(error => {
				this.stopLoading();
				this.error = error;
		});
	}

	handleToSChange(event){
		this.tos = event.target.checked;

		var submitButton = this.template.querySelector('[data-id="submitButton"]');
		if(this.tos){
			submitButton.classList.remove('containedButtonDisabled');
			submitButton.classList.add('containedButtonLogin');
			submitButton.disabled = false;
		}
		else{
			submitButton.classList.remove('containedButtonLogin');
			submitButton.classList.add('containedButtonDisabled');
			submitButton.disabled = true;
		}
	}
}