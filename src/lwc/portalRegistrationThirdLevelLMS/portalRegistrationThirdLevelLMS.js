import { LightningElement, track, api} from 'lwc';

import getContactInfo               	from '@salesforce/apex/PortalRegistrationSecondLevelCtrl.getContactInfo';
import getLMSContactInfo				from '@salesforce/apex/PortalRegistrationThirdLevelLMSCtrl.getLMSContactInfo';
import getParameters                	from '@salesforce/apex/PortalRegistrationThirdLevelLMSCtrl.getParameters';
import completeRegistration         	from '@salesforce/apex/PortalRegistrationThirdLevelLMSCtrl.completeRegistration';
import getPortalServiceId 				from '@salesforce/apex/PortalServicesCtrl.getPortalServiceId';
import verifyCompleteL3DataWithCourse 	from '@salesforce/apex/PortalServicesCtrl.verifyCompleteL3DataWithCourse';

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
import CSP_L2_Go_To_Service_LMS                   from '@salesforce/label/c.CSP_L2_Go_To_Service_LMS';
import CSP_L2_SucessUpdateOnly_LMS                   from '@salesforce/label/c.CSP_L2_SucessUpdateOnly_LMS';
import CSP_L3_Email_Validation_LMS                   from '@salesforce/label/c.CSP_L3_Email_Validation_LMS';
import CSP_L3_Note_F4_LMS                   from '@salesforce/label/c.CSP_L3_Note_F4_LMS';


export default class PortalRegistrationThirdLevelLMS extends LightningElement {
	/* Images */
	alertIcon = CSP_PortalPath + 'CSPortal/alertIcon.png';
    homeIcon = CSP_PortalPath + 'CSPortal/Images/Icons/L2_home.png';
    crossIcon = CSP_PortalPath + 'CSPortal/Images/Icons/L2_cross.png';
    stepValid = CSP_PortalPath + 'CSPortal/Images/Icons/L2_step_valid.png';
    step1Active = CSP_PortalPath + 'CSPortal/Images/Icons/L2_step_1_active.png';
    step2Active = CSP_PortalPath + 'CSPortal/Images/Icons/L2_step_2_active.png';
    step2Inactive = CSP_PortalPath + 'CSPortal/Images/Icons/L2_step_2_inactive.png';
    step3Active = CSP_PortalPath + 'CSPortal/Images/Icons/L2_step_3_active.png';
    step3Inactive = CSP_PortalPath + 'CSPortal/Images/Icons/L2_step_3_inactive.png';

	@api trigger;
	
	@track openMessageModal = false;
	@track registrationParams;
	@track registerData = true;
	@track openMessageModalFlowRegister = false;
	@track title;
	@track message;
	@track button1Label;
	@track isResLoading = false;

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
	@track contactInfoLMS;
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
		CSP_L3_Note_F7_LMS,
		CSP_L2_Go_To_Service_LMS,
		CSP_L2_SucessUpdateOnly_LMS,
		CSP_L3_Email_Validation_LMS,
		CSP_L3_Note_F4_LMS
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
		// hide page scrollbar to prevent having 2 scrollbars
        document.body.style.overflow = 'hidden';
		
		let pageParams = getParamsFromPage();
		
		// Retrieve Contact information
		getContactInfo()
			.then(result => {
				this.contactInfo = JSON.parse(JSON.stringify(result));
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

				if(this.contactInfo.Birthdate === undefined){
					this.contactInfo.Birthdate = '';
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
					this.contactInfo.lmsCourse =  pageParams.lmsCourse.replace(new RegExp('%40_%40','g'),'%26');
				}

				if(pageParams !== undefined && pageParams.RelayState !== undefined ){
					this.contactInfo.lmsCourse =  pageParams.RelayState.replace(new RegExp('%40_%40','g'),'%26');
				}

				if(pageParams !== undefined && pageParams.firstLogin !== undefined ){
					this.contactInfo.firstLogin =  pageParams.firstLogin;
				}else{
					this.contactInfo.firstLogin =  false;
				}
				
				this.contactInfo.serviceid = this.serviceid;

				//Address Info
				getLMSContactInfo({lms:'yas'})
				.then(result2 => {
					if(result2 !== undefined && result2 !== null){
						this.contactInfoLMS = JSON.parse(JSON.stringify(result2));
						
						if(this.contactInfoLMS.Country_Reference__c != null &&
							this.contactInfoLMS.Country_Reference__c != undefined &&
							this.contactInfoLMS.Country_Reference__c !== ''){

								if(this.contactInfoLMS.Country__c.toLowerCase() === 'no country'){
									this.address.countryId = '';
									this.address.countryName = '';
								}else{
									this.address.countryId = this.contactInfoLMS.Country_Reference__c;
									this.address.countryName = this.contactInfoLMS.Country__c;
									}
							}else{
								let countryName = this.contactInfo.Account.IATA_ISO_Country__r.Name;
								if(countryName.toLowerCase() === 'no country'){
									this.address.countryId = '';
									this.address.countryName = '';
							}else{
								this.address.countryId = this.contactInfo.Account.IATA_ISO_Country__r.Id;
								this.address.countryName = this.contactInfo.Account.IATA_ISO_Country__r.Name;
							}
						}
						
						// this.address.stateId = this.contactInfoLMS.State_Reference__c;
						if(this.contactInfoLMS.State_Reference__c != null &&
							this.contactInfoLMS.State_Reference__c != undefined &&
							this.contactInfoLMS.State_Reference__c !== '' &&
							this.contactInfoLMS.State_Reference__r.iso_code__c != null &&
							this.contactInfoLMS.State_Reference__r.iso_code__c != undefined &&
							this.contactInfoLMS.State_Reference__r.iso_code__c !== ''){

							this.address.stateId = this.contactInfoLMS.State_Reference__r.iso_code__c;
						}else{
							this.address.stateId = this.contactInfoLMS.State_Name__c !== undefined? this.contactInfoLMS.State_Name__c : '';
						}
						this.address.stateName =  this.contactInfoLMS.State_Name__c !== undefined? this.contactInfoLMS.State_Name__c : '';
						this.address.cityId = this.contactInfoLMS.City_Reference__c !== undefined? this.contactInfoLMS.City_Reference__c : '';
						this.address.cityName = this.contactInfoLMS.City_Name__c !== undefined? this.contactInfoLMS.City_Name__c : '';
						
						this.address.isPoBox =  this.contactInfoLMS.PO_Box__c === undefined || this.contactInfoLMS.PO_Box__c === ''? false : true;
						this.address.PoBoxAddress =  this.contactInfoLMS.PO_Box_Address__c !== undefined? this.contactInfoLMS.PO_Box_Address__c : false;
						
						this.address.street = this.contactInfoLMS.Street__c !== undefined? this.contactInfoLMS.Street__c : '';
						this.address.street2 = this.contactInfoLMS.Street2__c !== undefined? this.contactInfoLMS.Street2__c : '';
						this.address.zip = this.contactInfoLMS.Postal_Code__c !== undefined? this.contactInfoLMS.Postal_Code__c : '';
					
					}else{
						this.contactInfo.Username = '';
						this.contactInfo.UserId = '';
					}

				})
				.catch((error) => {
					this.contactInfo.Username = '';
					this.contactInfo.UserId = '';
				
					this.openMessageModalFlowRegister = true;
					this.message = CSP_L2_RegistrationFailed_LMS + error;
				});
				
				// FOR LMS L3
			if(pageParams !== undefined && pageParams.lmsflow !== undefined ){
				if(pageParams.lmsflow.indexOf('flow') > -1){
					let boldStr = '<b>' + CSP_L3_Note_LMS + '</b>';
					this.registerData = false;

					this.title=CSP_L3_ProfileUpdate_LMS;
			
					if(pageParams.lmsflow === 'flow3'){
						this.message=CSP_L3_UpdatingProfileP1_LMS + '<br>';
					}

					if(pageParams.lmsflow === 'flow4'){
						this.message=CSP_L3_UpdatingProfileP1_LMS + '<br>';
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
					this.button1Label= CSP_L2_Go_To_Service_LMS;
					
					this.openMessageModalFlowRegister = true;
					this.isResLoading = true;

					let sPageURL = ''+ window.location;
					getParameters({ urlExtension : sPageURL }).then(result => {
						this.contactInfo = JSON.parse(result.userInfo);
						
						if(this.contactInfo.UserId !== undefined && this.contactInfo.UserId !== null && this.contactInfo.UserId !== ''){
							this.contactInfo.Username = this.contactInfo.Id.substring(0,15);
						}
						
						if(pageParams.lmsflow === 'flow3'){
							this.message=CSP_L3_UpdatingProfileP1_LMS + '<br>' + CSP_L3_UpdatingProfileP2_LMS + '<br>' + CSP_L3_NewLoginEmail_LMS + ' <b>' + this.contactInfo.Email + '</b>';
						}
						if(pageParams.lmsflow === 'flow4'){
							this.message=CSP_L3_UpdatingProfileP1_LMS + '<br>' + CSP_L3_UpdatingProfileP2_LMS + '<br>' + CSP_L3_NewLoginEmail_LMS + ' <b>' + this.contactInfo.Email + '</b>';
						}
						if(pageParams.lmsflow === 'flow5'){
							this.message=CSP_L3_UpdatingProfileP1_LMS ;
						}
						if(pageParams.lmsflow === 'flow6'){
							this.message=CSP_L3_UpdatingProfileP1_LMS + '<br><b>' + CSP_L3_Note_F6_LMS + '</b><br>';
						}
						if(pageParams.lmsflow === 'flow7'){
							boldStr = CSP_L3_Note_F7_LMS;
						
							boldStr = boldStr.replace('[work_email]',this.contactInfo.Email);
							this.message=CSP_L3_UpdatingProfileP1_LMS + '<br>' + boldStr + '<br>';
						}

						completeRegistration({params: JSON.stringify(this.contactInfo) })
						.then(result2 => {

							if(result2.isSuccess == true){
								//need to wait a few seconds while mulesoft creates the user in YAS, otherwise we can get an SSO error saying the user not existing
								this.sleep(6000)
								.then(() => { 
									if(pageParams.lmsflow === 'flow3' || pageParams.lmsflow === 'flow4'){
										boldStr = '<b>' + CSP_L3_Note_F4_LMS + '</b>';
										boldStr = boldStr.replace('[Email]',this.contactInfo.Email);
										boldStr = boldStr.replace('[PersonalEmail]',this.contactInfo.Additional_Email);
										this.message = this.message + '<br><br>' + boldStr;
										
									}else if(pageParams.lmsflow === 'flow5'){
										this.message = this.message + '<br><br>' + CSP_L2_SucessUpdateOnly_LMS;
										this.message = this.message.replace('[Email]',this.contactInfo.Email);
									}else if(pageParams.lmsflow === 'flow7'){
										let msgF7 = CSP_L2_SucessUpdate_LMS.replace('[Email]',this.contactInfo.Email);
										this.message = this.message + '<br><br>' + msgF7;
									}else{
										this.message = this.message + '<br><br><b>' + CSP_L2_SucessUpdate_LMS + '</b>';
										this.message = this.message.replace('[Email]',this.contactInfo.Email);
									}
								
									this.isResLoading = false;
									var submitButton = this.template.querySelector('[data-id="submitButton"]');
									submitButton.classList.remove('containedButtonDisabled');
									submitButton.classList.add('containedButtonLogin');
									submitButton.disabled = false;
								})
								
							}
							else{
								this.isResLoading = false;
								this.message = CSP_L2_Registration_Failed_LMS+'\n'+result2.message;
							}
							
						})
						.catch(error => {
							this.errorModalMessage = JSON.parse(JSON.stringify(error));
							this.isResLoading = false;
							this.openMessageModalFlowRegister = true;
							this.message = CSP_L2_RegistrationFailed_LMS + error;
						});
					})
			
				}
			}
				

			})
		.catch((error) => {
			this.openMessageModalFlowRegister = true;
			this.message = CSP_L2_RegistrationFailed_LMS + error;
		})

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

	@track step1Complete = false;
	@track step2Complete = false;
	
	step1CompletionStatus(event){
		this.step1Complete = event.detail;
	}
 
	step2CompletionStatus(event){
		this.step2Complete = event.detail;
	}

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
		}

		// Training Information
		else if(this.currentStep === 4){
			contactInfo = this.template.querySelector('c-portal-registration-training-validation-l-m-s').getContactInfo();
			flow = this.template.querySelector('c-portal-registration-training-validation-l-m-s').getFlow();
			this.contactInfo = JSON.parse(JSON.stringify(contactInfo));
			this.flow = flow;
		}
		
	}

	goToStep(event){
		var futureStep = parseInt(event.detail);
		this.getCurrentStepData();
		this.currentStep = futureStep;
	}

	fromProfileDetailsToAddressInformation(){
		// retrieve profile details
		var contactInfo = this.template.querySelector('c-portal-registration-profile-details-l-m-s').getContactInfo();
		this.contactInfo = JSON.parse(JSON.stringify(contactInfo));

		// go to next step
		this.currentStep = 2;
	}

	fromAddressInformationToProfileDetails(){
		this.currentStep = 1;
	}

	fromAddressInformationToEmailInformation(){
		// retrieve profile details
		let addressInformation = this.template.querySelector('c-portal-registration-address-information-l-m-s').getAddressInformation();
		this.address = JSON.parse(JSON.stringify(addressInformation));
		// go to next step
		this.currentStep = 3;
		this.step1Complete = true;
	}

	fromEmailInformationToAddressInformation(){
		this.currentStep = 2;
	}

	fromEmailInformationToTrainingInformation(){
		var contactInfo = this.template.querySelector('c-portal-registration-email-validation-l-m-s').getContactInfo();
		var flow = this.template.querySelector('c-portal-registration-email-validation-l-m-s').getFlow();
		
		this.contactInfo = JSON.parse(JSON.stringify(contactInfo));
		this.flow = flow;
		this.currentStep = 4;
		this.step2Complete = true;
	}

	fromTrainingInformationToEmailInformation(){
		this.currentStep = 3;
	}

	fromTrainingInformationToConfirmation(){
		var contactInfo = this.template.querySelector('c-portal-registration-training-validation-l-m-s').getContactInfo();
		this.contactInfo = JSON.parse(JSON.stringify(contactInfo));
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
		return this.currentStep === 4;
	}
	
	get isConfirmationStep(){
		return this.currentStep === 5;
	}

	get isStep2Inactive(){
		if(this.step2Complete){
			return false;
		}
		return this.isProfileInformationStep || this.isAddressInformationStep;
	}

	get isStep2Active(){
		if(this.step2Complete){
			return false;
		}
		return this.isEmailValidationStep;
	}

	get isStep2Valid(){
		if(this.step2Complete){
			return true;
		}
		return this.isTrainingValidationStep || this.isConfirmationStep;
	}

	get hasStep1Link(){
		if(this.step1Complete){
			return true;
		}
		if(this.currentStep !== 1 && this.currentStep !== 2){
			return false;
		}
        return false;
	}
	
	get hasStep2Link(){
		if(this.step2Complete){
			return true;
		}
        if( (this.currentStep === 1 && !this.step1Complete) || this.currentStep === 2 || this.currentStep === 3){
            return false;
        }
        if(this.currentStep === 4 || this.currentStep === 5 || ((this.currentStep === 1 || this.currentStep === 2) && this.step1Complete)){
            return true;
        }
        return false;
	}
	
	get hasStep3Link(){
        return this.step1Complete && this.step2Complete;
	}
	
	goToProfileDetailsFromBanner(){
        this.getCurrentStepData();
        this.currentStep = 1;
    }

    goToEmailValidationStepFromBanner(){
        this.getCurrentStepData();
        this.currentStep = 3;
    }

    goToConfirmationFromBanner(){
        this.getCurrentStepData();
        this.currentStep = 5;
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
						window.open(result);
						this.stopLoading();
						navigateToPage(CSP_PortalPath,{});
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
			
	browserType(){
		let ua= navigator.userAgent;
		let tem;
		let M= ua.match(/(opera|chrome|safari|firefox|msie|trident(?=\/))\/?\s*(\d+)/i) || [];

		if(/trident/i.test(M[1])){
			tem=  /\brv[ :]+(\d+)/g.exec(ua) || [];
			return 'IE '+(tem[1] || '');
		}
		if(M[1]=== 'Chrome'){
			tem= ua.match(/\b(OPR|Edge)\/(\d+)/);
			if(tem!= null) return tem.slice(1).join(' ').replace('OPR', 'Opera');
		}
		M= M[2]? [M[1], M[2]]: [navigator.appName, navigator.appVersion, '-?'];
		if((tem= ua.match(/version\/(\d+)/i))!= null) M.splice(1, 1, tem[1]);
		return M.join(' ');
	}	
}