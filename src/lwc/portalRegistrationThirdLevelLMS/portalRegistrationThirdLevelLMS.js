/* eslint-disable no-alert */
/* eslint-disable vars-on-top */
/**
 * Created by mmercier on 30.07.2019.
 */

import { LightningElement, track, wire, api} from 'lwc';

import getContactInfo               from '@salesforce/apex/PortalRegistrationSecondLevelCtrl.getContactInfo';
import getParameters                from '@salesforce/apex/PortalRegistrationThirdLevelLMSCtrl.getParameters';
import completeRegistration                from '@salesforce/apex/PortalRegistrationThirdLevelLMSCtrl.completeRegistration';


// import getCustomerTypeFromSectorAndCategory from '@salesforce/apex/GCS_CustomerType.getCustomerTypeFromSectorAndCategory';

import { navigateToPage, getParamsFromPage } from'c/navigationUtils';

//import isServiceAvailableForCategorization  from '@salesforce/apex/GCS_RegistrationController.isServiceAvailableForCategorization';

//custom labels
import CSP_L2_Banner_Title              from '@salesforce/label/c.CSP_L2_Banner_Title';
import CSP_L2_Profile_Details              from '@salesforce/label/c.CSP_L2_Profile_Details';
import CSP_L2_Account_Selection              from '@salesforce/label/c.CSP_L2_Account_Selection';
import CSP_L2_Confirmation              from '@salesforce/label/c.CSP_L2_Confirmation';
import CSP_L2_Profile_Incomplete              from '@salesforce/label/c.CSP_L2_Profile_Incomplete';
import CSP_L2_Profile_Incomplete_Message              from '@salesforce/label/c.CSP_L2_Profile_Incomplete_Message';
import CSP_L2_Yes              from '@salesforce/label/c.CSP_L2_Yes';
import CSP_L2_No              from '@salesforce/label/c.CSP_L2_No';
import CSP_PortalPath                   from '@salesforce/label/c.CSP_PortalPath';

export default class PortalRegistrationThirdLevelLMS extends LightningElement {
	/* Images */
	youAreSafeIcon = CSP_PortalPath + 'CSPortal/Images/Icons/youaresafe.png';
	alertIcon = CSP_PortalPath + 'alertIcon.png';
	homeIcon = CSP_PortalPath + 'CSPortal/Images/Icons/L2_home.png';
	crossIcon = CSP_PortalPath + 'CSPortal/Images/Icons/L2_cross.png';
	stepValid = CSP_PortalPath + 'CSPortal/Images/Icons/L2_step_valid.svg';
	step1Active = CSP_PortalPath + 'CSPortal/Images/Icons/L2_step_1_active.svg';
	step2Active = CSP_PortalPath + 'CSPortal/Images/Icons/L2_step_2_active.svg';
	step2Inactive = CSP_PortalPath + 'CSPortal/Images/Icons/L2_step_2_inactive.svg';
	step3Active = CSP_PortalPath + 'CSPortal/Images/Icons/L2_step_3_active.svg';
	step3Inactive = CSP_PortalPath + 'CSPortal/Images/Icons/L2_step_3_inactive.svg';

	@api trigger;
	@api isTriggeredByRequest = false;

	@track openMessageModal = false;
	@track registrationParams;
	@track registerData = true;
	@track openMessageModalFlowRegister = false;
	@track title;
	@track message;
	@track button1Label;
	@track isResLoading = false;
	@api serviceid;
	/*
		1 : Profile Details
		2 : Account Selection
		3 : Account Creation - Company Information
		4 : Account Creation - Address Information
		5 : Confirmation
	*/
   @track currentStep = 1;

   @track isLoading = false;

	// Collected information
	selectedAccountId = '';
	selectedCountryId;
	selectedCustomerType;
	searchResults;
	address = {
		'isPoBox':false,
		'countryId':'',
		'countryCode':'',
		'countryName':'',
		'stateId':'',
		'stateName':'',
		'cityId':'',
		'cityName':'',
		'street':'',
		'street2':'',
		'zip':'',
		'validationStatus':0,
		'addressSuggestions':[]
	};

	// account = {
	//     'legalName':'',
	//     'tradeName':'',
	//     'phone':'',
	//     'email':'',
	//     'website':'',
	//     'customerType':'',
	//     'customerTypeSector':'',
	//     'customerTypeCategory':'',
	//     'sector':'',
	//     'category':''
	// };

	@track contactInfo;
	@track contactFound;
	@track flow;

	// customer type variables
	originalCustomerType;
	@track selectedMetadataCustomerType;
	@track isCustomerTypeGeneralPublic;

	// label variables
	_labels = {
		CSP_L2_Banner_Title,
		CSP_L2_Profile_Details,
		CSP_L2_Account_Selection,
		CSP_L2_Confirmation,
		CSP_L2_Profile_Incomplete,
		CSP_L2_Profile_Incomplete_Message,
		CSP_L2_Yes,
		CSP_L2_No
	}
	get labels() {
		return this._labels;
	}
	set labels(value) {
		this._labels = value;
	}

	scrollToTop(){
		let scrollobjective = this.template.querySelector('[data-name="top"]');
		scrollobjective.scrollIntoView({ behavior: 'smooth', block:'start' });
	}

	connectedCallback() {
		document.body.setAttribute('style', 'overflow: hidden;');
		console.log('callback ServiceId: ' + this.serviceid);
		let pageParams = getParamsFromPage();

		// Retrieve Contact information
		getContactInfo()
			.then(result => {
				this.contactInfo = result;
				this.contactFound = this.contactInfo != null;

				console.log('connectedCallback - getContactInfo - this.contactInfo: ',this.contactInfo);

				if(!this.contactFound){
					return;
				}

				// set up cached data
				var countryName = this.contactInfo.Account.IATA_ISO_Country__r.Name;
				if(countryName.toLowerCase() === 'no country'){
					this.selectedCountryId = '';
				}
				else{
					this.selectedCountryId = this.contactInfo.Account.IATA_ISO_Country__r.Id;
				}

				if(this.contactInfo.Title === undefined){
					this.contactInfo.Title = null;
				}

				if(this.contactInfo.Phone === undefined){
					this.contactInfo.Phone = '';
				}

				if(this.contactInfo.OtherPhone === undefined){
					this.contactInfo.OtherPhone = '';
				}

				if(this.contactInfo.Account.Sector__c === 'General Public'){
					this.selectedCustomerType = '';
					this.originalCustomerType = '';
				}

				if(pageParams !== undefined && pageParams.lms !== undefined ){
					this.contactInfo.lms =  pageParams.lms
				}
				if(pageParams !== undefined && pageParams.lmsCourse !== undefined ){
					this.contactInfo.lmsCourse =  pageParams.lmsCourse
				}

				this.contactInfo.serviceid = this.serviceid;

				//Address Info
				console.log('connectedCallback getContactInfo - start this.address ');
				console.log('CHECK1 connectedCallback getContactInfo - this.contactInfo - ',JSON.stringify(this.contactInfo) );
				if(this.contactInfo.Shipping_Address__c != null &&
					this.contactInfo.Shipping_Address__c != undefined &&
					this.contactInfo.Shipping_Address__c !== ''){

					this.address.isPoBox =  this.contactInfo.Shipping_Address__r.PO_Box__c !== undefined? this.contactInfo.Shipping_Address__r.PO_Box__c : false;
					this.address.countryId = this.contactInfo.Shipping_Address__r.Country_Reference__c;
					this.address.countryName = this.contactInfo.Shipping_Address__r.Country__c;

					// this.address.stateId = this.contactInfo.Shipping_Address__r.State_Reference__c;
					if(this.contactInfo.Shipping_Address__r.State_Reference__c != null &&
						this.contactInfo.Shipping_Address__r.State_Reference__c != undefined &&
						this.contactInfo.Shipping_Address__r.State_Reference__c !== '' &&
						this.contactInfo.Shipping_Address__r.State_Reference__r.iso_code__c != null &&
						this.contactInfo.Shipping_Address__r.State_Reference__r.iso_code__c != undefined &&
						this.contactInfo.Shipping_Address__r.State_Reference__r.iso_code__c !== ''){

						this.address.stateId = this.contactInfo.Shipping_Address__r.State_Reference__r.iso_code__c;
					}else{
						this.address.stateId = this.contactInfo.Shipping_Address__r.State__c !== undefined? this.contactInfo.Shipping_Address__r.State__c : '';
					}
					this.address.stateName =  this.contactInfo.Shipping_Address__r.State__c !== undefined? this.contactInfo.Shipping_Address__r.State__c : '';
					this.address.cityId = this.contactInfo.Shipping_Address__r.City_Reference__c !== undefined? this.contactInfo.Shipping_Address__r.City_Reference__c : '';
					this.address.cityName = this.contactInfo.Shipping_Address__r.City__c !== undefined? this.contactInfo.Shipping_Address__r.City__c : '';
					this.address.street = this.contactInfo.Shipping_Address__r.Street__c;
					this.address.street2 = this.contactInfo.Shipping_Address__r.Street2__c !== undefined? this.contactInfo.Shipping_Address__r.Street2__c : '';
					this.address.zip = this.contactInfo.Shipping_Address__r.Postal_Code__c;
				}



			})
		.catch((error) => {
			this.openMessageModalFlowRegister = true;
			this.message = 'Your registration failed. An Error Occurred - ' + error;
			console.log('Error: ', JSON.parse(JSON.stringify(error)));
			console.log('Error2: ', error);
		});

		// FOR LMS L3
		if(pageParams !== undefined && pageParams.lmsflow !== undefined ){

			if(pageParams.lmsflow.indexOf('flow') > -1){
				this.registerData = false;

				this.title="Profile Update"
				this.message="Updating profile Information, switching email data"
				this.button1Label="Homepage";

				this.openMessageModalFlowRegister = true;
				this.isResLoading = true;

				var sPageURL = ''+ window.location;
				console.log('sPageURL: ',sPageURL);
				getParameters({ urlExtension : sPageURL }).then(result => {
					// this.registrationParams = JSON.stringify(JSON.parse(result.registrationParameters));
					this.contactInfo = JSON.parse(result.userInfo);
					console.log('CHECK2 connectedCallback getParameters: this.contactInfo : ', JSON.stringify(this.contactInfo) );
					completeRegistration({params: JSON.stringify(this.contactInfo) })
						.then(result2 => {
							console.log('result: ', JSON.parse(JSON.stringify(result)));
							if(result2.isSuccess == true){
								this.message="Successfully Updated profile Information"
							}
							else{
								this.message = 'Your registration failed. \n'+result2.message;
							}
							this.isResLoading = false;
						})
						.catch(error => {
							console.log('Error: ', JSON.parse(JSON.stringify(error)));
							this.errorModalMessage = JSON.parse(JSON.stringify(error));
							this.isResLoading = false;
						});
					console.log('this.registrationParams: ',this.contactInfo);
					console.log('this.registrationParams.email: ',this.contactInfo.Email);
				})




			}
		}
	}

	startLoading(){
		this.isLoading = true;
	}

	stopLoading(){
		this.isLoading = false;
	}

	button1Action(){
		navigateToPage(CSP_PortalPath,{});
	}

	cancel(){
		this.dispatchEvent(
			new CustomEvent('closesecondlevelregistration')
		);
	}


	/* NAVIGATION METHODS */
	getCurrentStepData(){
		// Profile Details
		if(this.currentStep === 1){
			var contactInfo = this.template.querySelector('c-portal-registration-profile-details-l-m-s').getContactInfo();
			this.contactInfo = JSON.parse(JSON.stringify(contactInfo));
		}
		// Account Selection
		else if(this.currentStep === 2){
			var contactInfo = this.template.querySelector('c-portal-registration-email-validation-l-m-s').getContactInfo();
			this.contactInfo = JSON.parse(JSON.stringify(contactInfo));
			var flow = this.template.querySelector('c-portal-registration-email-validation-l-m-s').getFlow();
			this.flow = flow

		}

		// Address Information
		else if(this.currentStep === 4){
			var addressInformation = this.template.querySelector('c-portal-registration-address-information-l-m-s').getAddressInformation();
			this.address = JSON.parse(JSON.stringify(addressInformation));
			console.log('getCurrentStepData this.address - ',this.address );
		}
	}

	goToStep(event){
		console.log('goToStep INIT');
		var futureStep = parseInt(event.detail);
		console.log('goToStep futureStep - ',futureStep );
		this.getCurrentStepData();
		this.currentStep = futureStep;
	}

	fromProfileDetailsToAccountSelection(){
		// retrieve profile details
		var contactInfo = this.template.querySelector('c-portal-registration-profile-details-l-m-s').getContactInfo();
		this.contactInfo = JSON.parse(JSON.stringify(contactInfo));

		// go to next step
		this.currentStep = 4;
	}

	fromAccountSelectionToProfileDetails(){

		this.currentStep = 1;
	}

	fromAccountSelectionToConfirmation(){
		var contactInfo = this.template.querySelector('c-portal-registration-email-validation-l-m-s').getContactInfo();
		this.contactInfo = JSON.parse(JSON.stringify(contactInfo));
		var flow = this.template.querySelector('c-portal-registration-email-validation-l-m-s').getFlow();
		this.flow = flow

		this.currentStep = 5;
	}

	fromAccountSelectionToCompanyInformation(){

		this.currentStep = 3;
	}

	fromCompanyInformationToAccountSelection(){
		var companyInformation= this.template.querySelector('c-portal-registration-company-information').getCompanyInformation();

		this.account = JSON.parse(JSON.stringify(companyInformation));
		this.selectedCustomerType = companyInformation.customerType;

		this.currentStep = 2;
	}

	// fromCompanyInformationToAddressInformation(){
	//     var companyInformation= this.template.querySelector('c-portal-registration-company-information').getCompanyInformation();

	//     this.account = JSON.parse(JSON.stringify(companyInformation));
	//     this.selectedCustomerType = companyInformation.customerType;

	//     this.currentStep = 4;
	// }

	// fromAddressInformationToCompanyInformation(){
	//     var addressInformation = this.template.querySelector('c-portal-registration-address-information').getAddressInformation();
	//     this.address = JSON.parse(JSON.stringify(addressInformation));

	//     this.currentStep = 3;
	// }

	// fromAddressInformationToConfirmation(){
	//     var addressInformation = this.template.querySelector('c-portal-registration-address-information').getAddressInformation();
	//     this.address = JSON.parse(JSON.stringify(addressInformation));

	//     this.currentStep = 5;
	// }

	fromConfirmationToProfileDetails(){
		this.currentStep = 1;
	}

	fromConfirmationToAccountSelection(){
		this.currentStep = 2;
	}

	fromConfirmationToCompanyInformation(){
		this.currentStep = 3;
	}

	fromConfirmationToAddressInformation(){
		this.currentStep = 4;
	}

	get isProfileInformationStep(){
		return this.currentStep === 1;
	}

	get isEmailValidationStep(){
		return this.currentStep === 2;
	}

	get isCompanyInformationStep(){
		return this.currentStep === 3;
	}

	get isAddressInformationStep(){
		return this.currentStep === 4;
	}

	get isConfirmationStep(){
		return this.currentStep === 5;
	}

	get isAccountStep(){
		return this.currentStep === 2 || this.currentStep === 3 || this.currentStep === 4;
	}

	landingPage;

	openSaveAndClosePopup(){
		this.landingPage = 'same';
		this.openMessageModal = true;
	}

	openSaveAndGoToHomePopup(){
		this.landingPage = 'homepage';
		this.openMessageModal = true;
	}

	// cancel(){
	//     this.openMessageModal = false;
	// }

	saveAndClose(){
		// To do save contact info


		this.openMessageModal = false;
		if(this.landingPage == 'same'){
			this.dispatchEvent(new CustomEvent('closesecondlevelregistration'));
		}
		else if(this.landingPage == 'homepage'){
			navigateToPage(CSP_PortalPath,{});
		}
	}

	secondLevelRegistrationCompletedAction1(){
		this.dispatchEvent(new CustomEvent('secondlevelregistrationcompletedactionone'));
	}

	secondLevelRegistrationCompletedAction2(){
		this.dispatchEvent(new CustomEvent('secondlevelregistrationcompletedactiontwo'));
	}
}