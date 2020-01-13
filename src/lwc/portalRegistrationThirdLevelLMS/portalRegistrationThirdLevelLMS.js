import { LightningElement, track, api} from 'lwc';

import getContactInfo               from '@salesforce/apex/PortalRegistrationSecondLevelCtrl.getContactInfo';
import getParameters                from '@salesforce/apex/PortalRegistrationThirdLevelLMSCtrl.getParameters';
import completeRegistration                from '@salesforce/apex/PortalRegistrationThirdLevelLMSCtrl.completeRegistration';

import { navigateToPage, getParamsFromPage } from'c/navigationUtils';

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
import CSP_L3_Note_LMS                   from '@salesforce/label/c.CSP_L3_Note_LMS';
import CSP_L3_UpdatingProfileP1_LMS                   from '@salesforce/label/c.CSP_L3_UpdatingProfileP1_LMS';
import CSP_L3_ProfileUpdate_LMS                   from '@salesforce/label/c.CSP_L3_ProfileUpdate_LMS';
import CSP_L3_UpdatingProfileP2_LMS                   from '@salesforce/label/c.CSP_L3_UpdatingProfileP2_LMS';
import CSP_L3_HomePage_LMS                   from '@salesforce/label/c.CSP_L3_HomePage_LMS';
import CSP_L2_RegistrationFailed_LMS                   from '@salesforce/label/c.CSP_L2_RegistrationFailed_LMS';
import CSP_L2_Registration_Failed_LMS                   from '@salesforce/label/c.CSP_L2_Registration_Failed_LMS';
import CSP_L2_SucessUpdate_LMS                   from '@salesforce/label/c.CSP_L2_SucessUpdate_LMS';
import CSP_L3_NewLoginEmail_LMS                   from '@salesforce/label/c.CSP_L3_NewLoginEmail_LMS';
import OneId_Contact_Association_Validation                   from '@salesforce/label/c.OneId_Contact_Association_Validation';
import CSP_L3_Header_Title                   from '@salesforce/label/c.CSP_L3_Header_Title';
import CSP_L3_Note_F5_LMS                   from '@salesforce/label/c.CSP_L3_Note_F5_LMS';
import CSP_L3_Note_F6_LMS                   from '@salesforce/label/c.CSP_L3_Note_F6_LMS';
import CSP_L3_Note_F7_LMS                   from '@salesforce/label/c.CSP_L3_Note_F7_LMS';


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
		CSP_L2_No,
		CSP_L3_Note_LMS,
		CSP_L3_ProfileUpdate_LMS,
		CSP_L3_UpdatingProfileP1_LMS,
		CSP_L3_UpdatingProfileP2_LMS,
		CSP_L3_HomePage_LMS,
		CSP_L2_RegistrationFailed_LMS,
		CSP_L2_Registration_Failed_LMS,
		CSP_L2_SucessUpdate_LMS,
		CSP_L3_NewLoginEmail_LMS,
		OneId_Contact_Association_Validation,
		CSP_L3_Header_Title,
		CSP_L3_Note_F5_LMS,
		CSP_L3_Note_F6_LMS,
		CSP_L3_Note_F7_LMS
	}
	get labels() {
		return this._labels;
	}
	set labels(value) {
		this._labels = value;
	}

	@track isIE = this.checkIE;
	get checkIE(){

		let ua= navigator.userAgent;
		let M= ua.match(/(opera|chrome|safari|firefox|msie|trident(?=\/))\/?\s*(\d+)/i) || [];
		let ret;
		if(/trident/i.test(M[1])){
			ret = true;
		}else{
			ret = false;
		}
		return ret;
	}

	scrollToTop(){
		let scrollobjective = this.template.querySelector('[data-name="top"]');
		scrollobjective.scrollIntoView({ behavior: 'smooth', block:'start' });
	}

	connectedCallback() {
		document.body.setAttribute('style', 'overflow: hidden;');
		
		let pageParams = getParamsFromPage();

		// Retrieve Contact information

		getContactInfo()
			.then(result => {
				this.contactInfo = result;
				this.contactFound = this.contactInfo != null;

				if(!this.contactFound){
					return;
				}

				// set up cached data
				let countryName = this.contactInfo.Account.IATA_ISO_Country__r.Name;
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
					this.contactInfo.lms =  pageParams.lms;
				}

				if(pageParams !== undefined && pageParams.lmsCourse !== undefined ){
					this.contactInfo.lmsCourse =  pageParams.lmsCourse.replace('%40_%40','%26');
				}

				if(pageParams !== undefined && pageParams.RelayState !== undefined ){
					this.contactInfo.lmsCourse =  pageParams.RelayState;
				}

				if(pageParams !== undefined && pageParams.firstLogin !== undefined ){
					this.contactInfo.firstLogin =  pageParams.firstLogin;
				}else{
					this.contactInfo.firstLogin =  false;
				}
				
				this.contactInfo.serviceid = this.serviceid;

			})
		.catch((error) => {
			this.openMessageModalFlowRegister = true;
			this.message = CSP_L2_RegistrationFailed_LMS + error;
			console.log('Error: ', JSON.parse(JSON.stringify(error)));
		})
		.finally(() => {
			
			// FOR LMS L3
			if(pageParams !== undefined && pageParams.lmsflow !== undefined ){
				if(pageParams.lmsflow.indexOf('flow') > -1){
					let boldStr = '<b>' + CSP_L3_Note_LMS + '</b>';
					this.registerData = false;

					this.title=CSP_L3_ProfileUpdate_LMS;
					// this.message=CSP_L3_UpdatingProfileInitialMessage_LMS; 

					if(pageParams.lmsflow === 'flow3'){
						this.message=CSP_L3_UpdatingProfileP1_LMS + '<br>' + boldStr + '<br>' + CSP_L3_UpdatingProfileP2_LMS;
					}

					if(pageParams.lmsflow === 'flow4'){
						this.message=CSP_L3_UpdatingProfileP1_LMS + '<br>' + boldStr + '<br>' + CSP_L3_UpdatingProfileP2_LMS;
					}

					if(pageParams.lmsflow === 'flow5'){
						boldStr = '<b>' + CSP_L3_Note_F5_LMS + '</b>';
						this.message=CSP_L3_UpdatingProfileP1_LMS + '<br>' + boldStr + '<br>' + CSP_L3_UpdatingProfileP2_LMS;
					}

					if(pageParams.lmsflow === 'flow6'){
						boldStr = '<b>' + CSP_L3_Note_F6_LMS + '</b>';
						this.message=CSP_L3_UpdatingProfileP1_LMS + '<br>' + boldStr + '<br>';
					}
					if(pageParams.lmsflow === 'flow7'){
						boldStr = CSP_L3_Note_F7_LMS;
						boldStr = boldStr.replace('[work_email]',this.contactInfo.Email);
						this.message=CSP_L3_UpdatingProfileP1_LMS + '<br>' + boldStr + '<br>';
					}
					this.button1Label= CSP_L3_HomePage_LMS;

					this.openMessageModalFlowRegister = true;
					this.isResLoading = true;

					let sPageURL = ''+ window.location;
					getParameters({ urlExtension : sPageURL }).then(result => {
						this.contactInfo = JSON.parse(result.userInfo);
						
						if(pageParams.lmsflow === 'flow3'){
							this.message=CSP_L3_UpdatingProfileP1_LMS + '<br>' + boldStr + '<br>' + CSP_L3_UpdatingProfileP2_LMS + '<br>' + CSP_L3_NewLoginEmail_LMS + ' <b>' + this.contactInfo.Email + '</b>';
						}
						if(pageParams.lmsflow === 'flow4'){
							this.message=CSP_L3_UpdatingProfileP1_LMS + '<br>' + boldStr + '<br>' + CSP_L3_UpdatingProfileP2_LMS + '<br>' + CSP_L3_NewLoginEmail_LMS + ' <b>' + this.contactInfo.Email + '</b>';
						}
						if(pageParams.lmsflow === 'flow5'){
							boldStr ='<b>' + CSP_L3_Note_F5_LMS + '</b>';
							this.message=CSP_L3_UpdatingProfileP1_LMS + '<br>' + boldStr + '<br>' + CSP_L3_UpdatingProfileP2_LMS + '<br>' + CSP_L3_NewLoginEmail_LMS + ' <b>' + this.contactInfo.Email + '</b>';
						}
						if(pageParams.lmsflow === 'flow6'){
							boldStr =  CSP_L3_Note_F6_LMS;
							this.message=CSP_L3_UpdatingProfileP1_LMS + '<br>' + boldStr + '<br>';
						}
						if(pageParams.lmsflow === 'flow7'){
							boldStr = CSP_L3_Note_F7_LMS;
						
							boldStr = boldStr.replace('[work_email]',this.contactInfo.Email);
							this.message=CSP_L3_UpdatingProfileP1_LMS + '<br>' + boldStr + '<br>';
						}

						completeRegistration({params: JSON.stringify(this.contactInfo) })
						.then(result2 => {

							if(result2.isSuccess == true){
								if(pageParams.lmsflow === 'flow7'){
									let msgF7 = CSP_L2_SucessUpdate_LMS.replace('[Email]',this.contactInfo.Email);
									this.message = this.message + '<br><br>' + msgF7;
								}else{
									this.message = this.message + '<br><br><b>' + CSP_L2_SucessUpdate_LMS + '</b>';
								}
							}
							else{
								this.message = CSP_L2_Registration_Failed_LMS+'\n'+result2.message;
							}
							this.isResLoading = false;
						})
						.catch(error => {
							console.log('Error: ', JSON.parse(JSON.stringify(error)));
							this.errorModalMessage = JSON.parse(JSON.stringify(error));
							this.isResLoading = false;
						});
					})
			
				}
			}
		});
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

		let contactInfo = '';
		let flow = '';
		let addressInformation = '';

		// Profile Details
		if(this.currentStep === 1){
			contactInfo = this.template.querySelector('c-portal-registration-profile-details-l-m-s').getContactInfo();
			this.contactInfo = JSON.parse(JSON.stringify(contactInfo));
		}
		
		// Address Information
		else if(this.currentStep === 2){
			addressInformation = this.template.querySelector('c-portal-registration-address-information-l-m-s').getAddressInformation();
			this.address = JSON.parse(JSON.stringify(addressInformation));
		}

		// email validation
		else if(this.currentStep === 3){
			contactInfo = this.template.querySelector('c-portal-registration-email-validation-l-m-s').getContactInfo();
			flow = this.template.querySelector('c-portal-registration-email-validation-l-m-s').getFlow();
			this.contactInfo = JSON.parse(JSON.stringify(contactInfo));
			this.flow = flow;
console.log('getCurrentStepData 3 this.contactInfo: ', this.contactInfo);
		}

		// Training Information
		else if(this.currentStep === 4){
			contactInfo = this.template.querySelector('c-portal-registration-training-validation-l-m-s').getContactInfo();
			flow = this.template.querySelector('c-portal-registration-training-validation-l-m-s').getFlow();
			this.contactInfo = JSON.parse(JSON.stringify(contactInfo));
			this.flow = flow;
console.log('getCurrentStepData 4 this.contactInfo: ', this.contactInfo);			
		}
		
	}

	goToStep(event){
		var futureStep = parseInt(event.detail);
		this.getCurrentStepData();
		this.currentStep = futureStep;
	}


	/*
	ProfileDetails 		- 1
	AddressInformation	- 2
	EmailInformation	- 3
	TrainingInformation	- 4
	Confirmation		- 5
	*/

	fromProfileDetailsToAddressInformation(){
		// retrieve profile details
		var contactInfo = this.template.querySelector('c-portal-registration-profile-details-l-m-s').getContactInfo();
		this.contactInfo = JSON.parse(JSON.stringify(contactInfo));

		// go to next step
		this.currentStep = 3;
	}

	fromAddressInformationToProfileDetails(){
		this.currentStep = 1;
	}

	fromAddressInformationToEmailInformation(){
		// retrieve profile details
		let contactInfo = this.template.querySelector('c-portal-registration-profile-details-l-m-s').getContactInfo();
		let addressInformation = this.template.querySelector('c-portal-registration-address-information-l-m-s').getAddressInformation();
		this.contactInfo = JSON.parse(JSON.stringify(contactInfo));
		this.address = JSON.parse(JSON.stringify(addressInformation));

		// go to next step
		this.currentStep = 3;
	}

	fromEmailInformationToAddressInformation(){
		this.currentStep = 1;
	}

	fromEmailInformationToTrainingInformation(){
		var contactInfo = this.template.querySelector('c-portal-registration-email-validation-l-m-s').getContactInfo();
		var flow = this.template.querySelector('c-portal-registration-email-validation-l-m-s').getFlow();
		
		this.contactInfo = JSON.parse(JSON.stringify(contactInfo));
		this.flow = flow;
console.log('fromEmailInformationToTrainingInformation this.contactInfo: ', this.contactInfo);
		this.currentStep = 4;
	}

	fromTrainingInformationToEmailInformation(){
		this.currentStep = 3;
	}

	fromTrainingInformationToConfirmation(){
		var contactInfo = this.template.querySelector('c-portal-registration-training-validation-l-m-s').getContactInfo();
		this.contactInfo = JSON.parse(JSON.stringify(contactInfo));
console.log('fromTrainingInformationToConfirmation this.contactInfo: ', this.contactInfo);		
		this.currentStep = 5;
	}

	fromConfirmationToProfileDetails(){
		this.currentStep = 1;
	}
	
	fromConfirmationToAddressInformation(){
		this.currentStep = 2;
	}

	fromConfirmationToEmailValidation(){
		this.currentStep = 3;
	}

	fromConfirmationToTrainingInformation(){
		this.currentStep = 4;
	}

	get isProfileInformationStep(){
		return this.currentStep === 1;
	}

	get isAddressInformationStep(){
		return this.currentStep === 2;
	}

	get isEmailValidationStep(){
		return this.currentStep === 3;
	}

	get isTrainingValidationStep(){
console.log('isTrainingValidationStep this.contactInfo: ', this.contactInfo);			
		return this.currentStep === 4;
	}
	
	get isConfirmationStep(){
		return this.currentStep === 5;
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
		this.openMessageModal = false;
		navigateToPage(CSP_PortalPath,{});
	}

	secondLevelRegistrationCompletedAction2(){
		this.dispatchEvent(new CustomEvent('secondlevelregistrationcompletedactiontwo'));
	}

		
	browserType(){
		let ua= navigator.userAgent;
		let tem;
		let M= ua.match(/(opera|chrome|safari|firefox|msie|trident(?=\/))\/?\s*(\d+)/i) || [];

		if(/trident/i.test(M[1])){
			tem=  /\brv[ :]+(\d+)/g.exec(ua) || [];
			// alert("IE"+'IE '+(tem[1] || ''));
			return 'IE '+(tem[1] || '');
		}
		if(M[1]=== 'Chrome'){
			tem= ua.match(/\b(OPR|Edge)\/(\d+)/);
			if(tem!= null) return tem.slice(1).join(' ').replace('OPR', 'Opera');
			// alert('chrome');
		}
		M= M[2]? [M[1], M[2]]: [navigator.appName, navigator.appVersion, '-?'];
		if((tem= ua.match(/version\/(\d+)/i))!= null) M.splice(1, 1, tem[1]);
		return M.join(' ');
	}

		

	
}