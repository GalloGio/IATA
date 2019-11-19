/* eslint-disable no-alert */
/* eslint-disable vars-on-top */

import { LightningElement, api, track } from 'lwc';

import createIsoCity                        from '@salesforce/apex/PortalRegistrationSecondLevelCtrl.createIsoCity';
import registration                         from '@salesforce/apex/PortalRegistrationThirdLevelLMSCtrl.registration';
import sendSingleEmail						from '@salesforce/apex/PortalRegistrationThirdLevelLMSCtrl.sendSingleEmail';
import getLMSTermAndConditionAcceptance		from '@salesforce/apex/PortalRegistrationThirdLevelLMSCtrl.getLMSTermAndConditionAcceptance';

import { navigateToPage } from'c/navigationUtils';

import CSP_PortalPath from '@salesforce/label/c.CSP_PortalPath';

import ISSP_CompanyName      from '@salesforce/label/c.ISSP_CompanyName';

import CSP_L2_Confirmation_Message from '@salesforce/label/c.CSP_L2_Confirmation_Message';
import CSP_L2_Personal_Details from '@salesforce/label/c.CSP_L2_Personal_Details';
import CSP_L2_Personal_Details_Message from '@salesforce/label/c.CSP_L2_Personal_Details_Message';
import CSP_L2_Back_to_Edit from '@salesforce/label/c.CSP_L2_Back_to_Edit';
import CSP_L2_Company_Account from '@salesforce/label/c.CSP_L2_Company_Account';
import CSP_L2_Company_Account_Message from '@salesforce/label/c.CSP_L2_Company_Account_Message';
import CSP_L2_Back_to_Business_Address_Information from '@salesforce/label/c.CSP_L2_Back_to_Business_Address_Information';
import CSP_L2_Submit from '@salesforce/label/c.CSP_L2_Submit';
import CSP_L2_Details_Saved from '@salesforce/label/c.CSP_L2_Details_Saved';
import CSP_L2_Details_Saved_Message from '@salesforce/label/c.CSP_L2_Details_Saved_Message';
import CSP_L2_Go_To_Homepage from '@salesforce/label/c.CSP_L2_Go_To_Homepage';
import CSP_L2_Go_To_Service from '@salesforce/label/c.CSP_L2_Go_To_Service';
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

export default class PortalRegistrationConfirmationLMS extends LightningElement {
	/* Images */
	successIcon = CSP_PortalPath + 'CSPortal/Images/Icons/youaresafe.png';

	// TO DO : find an image for error
	errorIcon = CSP_PortalPath + 'CSPortal/Images/Icons/youaresafe.png';

	@api contactInfo;
	@api flow;
	@api address;
	// @api searchResults;
	// @api selectedAccountId;

	@track street;
	@track street2;
	@track zip;
	@track city;
	@track state;
	@track tos;

	createdCityId;

	// selectedAccount;
	// @track selectedAccountSet = false;

	@track openSuccessModal = false;
	@track openVerificationMailSuccessModal = false;
	@track openErrorModal = false;
	//to be replaced by a custom label
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
		CSP_L2_Confirmation_Message,
		CSP_L2_Country,
		CSP_L2_Date_of_Birth,
		CSP_L2_Details_Saved,
		CSP_L2_Details_Saved_Message,
		CSP_L2_Email_Address,
		CSP_L2_Go_To_Homepage,
		CSP_L2_Go_To_Service,
		CSP_L2_Job_Function,
		CSP_L2_Job_Title,
		CSP_L2_Legal_Name,
		CSP_L2_Personal_Details,
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
		CSP_LMS_Privacy_Policy
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

		console.log('this.localContactInfo: ',this.localContactInfo);
		console.log('this.localAddress: ',this.localAddress);
		console.log('this.flow: ',this.flow);


		this.street = this.localAddress.street;
		this.street2 = this.localAddress.street2;
		this.zip = this.localAddress.zip;
		this.city = this.localAddress.cityName;
		this.state = this.localAddress.stateName;

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
			console.log('CHECK1 connectedCallback getLMSTermAndConditionAcceptance - result - ',result );
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
			console.log('connectedCallback getContactInfo - this.tos - ',this.tos );
		})
		.catch((error) => {
			this.openMessageModalFlowRegister = true;
			this.message = 'Your registration failed. An Error Occurred - ' + error;
			console.log('Error: ', JSON.parse(JSON.stringify(error)));
			console.log('Error2: ', error);
		});

		console.log('this.street: ',this.street);
		console.log('this.street2: ',this.street2);
		console.log('this.zip: ',this.zip);
		console.log('this.state: ',this.state);
		console.log('this.city: ',this.city);


	}


	startLoading(){
		this.dispatchEvent(new CustomEvent('startloading'));
	}

	stopLoading(){
		this.dispatchEvent(new CustomEvent('stoploading'));
	}

	submit(){
		console.log('Submit - this.localContactInfo:',this.localContactInfo);
		console.log('Submit - this.flow:',this.flow);
		console.log('Submit - this.localAddress:',this.localAddress);
		console.log('Submit - this.localAddress.isPoBox:',this.localAddress.isPoBox);

		this.startLoading();

		// Check first if we need to create a Geoname city
		if(this.localAddress.stateId !== '' && this.localAddress.cityId === ''){
			createIsoCity({name : this.localAddress.cityName, stateId: this.localAddress.stateId, isPoBox: this.localAddress.isPoBox})
			.then(result => {
				this.createdCityId = result;
				console.log('Submit - this.createdCityId:',this.createdCityId);
			})
			.catch(error => {
				console.log('Error: ', error);
				console.log('Error: ', JSON.parse(JSON.stringify(error)));
				this.openErrorModal = true;
				this.errorModalMessage = JSON.parse(JSON.stringify(error));
				this.stopLoading();
			})
			.finally(() => {
				this.submitRegistration();

			});
		}else{
			this.submitRegistration();
		}



				// register({ registrationForm : JSON.stringify(this.registrationForm),
	}


	submitRegistration(){
		console.log('Submit - pssou createIsoCity');
		var auxSearchValues = new Map();

		auxSearchValues = [
			this.localContactInfo.Username,
			this.localContactInfo.UserId,
			this.localContactInfo.lmsCourse,
			this.street,
			this.zip,
			this.localAddress.countryId,
			this.localAddress.stateId,
			this.state,
			this.createdCityId === '' ? this.createdCityId : this.localAddress.cityId,
			this.city,
			this.localAddress.isPoBox,
			this.localContactInfo.serviceid,
			this.localAddress.street2
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

		console.log('CHECK local contact info: ' + JSON.stringify(this.localContactInfo));

		console.log('Submit - pssou mandar dados address para contactInfo');

		console.log('CHECKEXTRA extraValues: ' + auxSearchValues);

		if(this.flow === 'flow1' || this.flow === 'flow2'){
			registration({con: this.localContactInfo, extraValues: auxSearchValues})
				.then(result => {
					console.log('registration call');
					console.log('result: ', JSON.parse(JSON.stringify(result)));
					if(result.isSuccess == true){
							this.openSuccessModal = true;
							console.log('registration successful');
						}
						else{
							this.openErrorModal = true;
							if(result.message !== ''){
								this.errorModalMessage = result.message;
							}else{
								this.errorModalMessage = 'Your registration failed.';
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
			// Additional_Email__c


			// this.registrationForm.country = this.flow;
			// this.registrationForm.firstName = this.localContactInfo.FirstName;
			// this.registrationForm.lastName = this.localContactInfo.LastName;

			// this.registrationForm.email = this.localContactInfo.Additional_Email__c;
			// this.registrationForm.contactId = this.localContactInfo.contactId;
			// this.registrationForm.accountId = this.localContactInfo.accountId;
			// // this.registrationForm.lms = this.localContactInfo.LastName;
			// this.registrationForm.existingContactId = this.localContactInfo.existingContactId;
			// this.registrationForm.existingContactName = this.localContactInfo.existingContactName;
			// this.registrationForm.existingContactEmail = this.localContactInfo.existingContactEmail;
			// this.registrationForm.existingContactAccount = this.localContactInfo.existingContactAccount;

			this.localContactInfo.flow = this.flow;
			// this.registrationForm.lms = this.localContactInfo.LastName;
			this.localContactInfo.existingContactId = this.localContactInfo.existingContactId;
			this.localContactInfo.existingContactName = this.localContactInfo.existingContactName;
			this.localContactInfo.existingContactEmail = this.localContactInfo.existingContactEmail;
			this.localContactInfo.existingContactAccount = this.localContactInfo.existingContactAccount;

			let contactName = this.localContactInfo.FirstName + ' ' + this.localContactInfo.LastName;

			console.log('contactName: ', contactName);
			console.log('emailAddr: ', this.localContactInfo.Additional_Email__c);
			console.log('this.flow: ', this.flow);
			console.log('this.localContactInfo: ', this.localContactInfo);
			console.log('this.localContactInfo ', JSON.stringify(this.localContactInfo));
			sendSingleEmail({contactName: contactName,
								emailAddr: this.localContactInfo.Additional_Email__c,
								flow:this.flow,
								params : JSON.stringify(this.localContactInfo)})
			.then(result => {
				console.log('result: ', JSON.parse(JSON.stringify(result)));
				if(result.isSuccess == true){
						this.openVerificationMailSuccessModal = true;
						this.successModalMessage = 'Verification Mail was sent to: '+ this.localContactInfo.Additional_Email__c+'. Please go there to complete your Registration';
					}
					else{
						this.openErrorModal = true;
						if(result.message !== ''){
							this.errorModalMessage = result.message;
						}else{
							this.errorModalMessage = 'Your registration failed.';
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

		//navigateToPage(CSP_PortalPath,{});

		// We'll have to create a second method with a second event (go to homepage or remain on the current one)
		// this.dispatchEvent(new CustomEvent('secondlevelregistrationcompleted'));
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

	handleToSChange(event){
		this.tos = event.target.checked;
		console.log('handleToSChange - this.tos: ', this.tos);

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