import { LightningElement, track, wire, api } from 'lwc';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import { NavigationMixin } from 'lightning/navigation';
import getCountries from '@salesforce/apex/PortalRegistrationFirstLevelCtrl.getISOCountries';
import getAirlinesHQ from '@salesforce/apex/LabRegistry_helper.getAirlinesHQ';
import { navigateToPage} from'c/navigationUtils';
import saveSurveyAnswers from '@salesforce/apex/LabRegistry_helper.saveSurveyAnswers';
import getAccountName from '@salesforce/apex/LabRegistry_helper.getAccountName';

//Objects schema
import OBJECT_LAB_ACCOUNT_ROLE_DETAIL from '@salesforce/schema/LAB_Account_Role_Detail__c';

//Fields with picklist
import FIELD_Lab_Type from '@salesforce/schema/LAB_Account_Role_Detail__c.Lab_Type__c';
import FIELD_Do_you_manage_booking_for_all_locations from '@salesforce/schema/LAB_Account_Role_Detail__c.Do_you_manage_booking_for_all_locations__c';
import FIELD_Do_you_issue_test_results_for_all_lab from '@salesforce/schema/LAB_Account_Role_Detail__c.Do_you_issue_test_results_for_all_lab__c';
import FIELD_Are_your_labs_part_of_national_platform from '@salesforce/schema/LAB_Account_Role_Detail__c.Are_your_labs_part_of_national_platform__c';
import FIELD_Existing_partnership_with_airlines from '@salesforce/schema/LAB_Account_Role_Detail__c.Existing_partnership_with_airlines__c';
import FIELD_Type_of_lab from '@salesforce/schema/LAB_Account_Role_Detail__c.Type_of_lab__c';
import FIELD_National_accreditation_for_all_the_labs from '@salesforce/schema/LAB_Account_Role_Detail__c.National_accreditation_for_all_the_labs__c';
import FIELD_How_long_have_you_been_in_the_business from '@salesforce/schema/LAB_Account_Role_Detail__c.How_long_have_you_been_in_the_business__c';
import FIELD_Operating_under_brand from '@salesforce/schema/LAB_Account_Role_Detail__c.Operating_under_brand__c';
import FIELD_Type_of_SLAs_in_place from '@salesforce/schema/LAB_Account_Role_Detail__c.Type_of_SLAs_in_place__c';
import FIELD_Additional_certifications_in_place from '@salesforce/schema/LAB_Account_Role_Detail__c.Additional_certifications_in_place__c';
import FIELD_Endorsed_by_governments from '@salesforce/schema/LAB_Account_Role_Detail__c.Endorsed_by_governments__c';

//Generic Labels
import CSP_LabReg_FormNotCompleted			from '@salesforce/label/c.CSP_LabReg_FormNotCompleted';
import CSP_L2_Profile_Incomplete_Message	from '@salesforce/label/c.CSP_L2_Profile_Incomplete_Message';
import CSP_L2_Yes							from '@salesforce/label/c.CSP_L2_Yes';
import CSP_L2_No							from '@salesforce/label/c.CSP_L2_No';
import CSP_PortalPath						from '@salesforce/label/c.CSP_PortalPath';
import CSP_L2_Next_Step from '@salesforce/label/c.CSP_L2_Next_Step';
import CSP_L2_Back_to_Edit from '@salesforce/label/c.CSP_L2_Back_to_Edit';
import CSP_L2_Submit from '@salesforce/label/c.CSP_L2_Submit';

//Questions labels
import CSP_LabReg_AdditionalCertInPlace from '@salesforce/label/c.CSP_LabReg_AdditionalCertInPlace';
import CSP_LabReg_airlinePartnershipSelection from '@salesforce/label/c.CSP_LabReg_airlinePartnershipSelection';
import CSP_LabReg_Describe_SLA_Nature from '@salesforce/label/c.CSP_LabReg_Describe_SLA_Nature';
import CSP_LabReg_How_Long_In_Business from '@salesforce/label/c.CSP_LabReg_How_Long_In_Business';
import CSP_LabReg_HowManyLabs from '@salesforce/label/c.CSP_LabReg_HowManyLabs';
import CSP_LabReg_InitialQuestion from '@salesforce/label/c.CSP_LabReg_InitialQuestion';
import CSP_LabReg_InitialQuestionDescription from '@salesforce/label/c.CSP_LabReg_InitialQuestionDescription';
import CSP_LabReg_issueTestResultsSelection from '@salesforce/label/c.CSP_LabReg_issueTestResultsSelection';
import CSP_LabReg_labsPartOfNationalPlatform from '@salesforce/label/c.CSP_LabReg_labsPartOfNationalPlatform';
import CSP_LabReg_manageBookingSelection from '@salesforce/label/c.CSP_LabReg_manageBookingSelection';
import CSP_LabReg_National_Govern_Platform from '@salesforce/label/c.CSP_LabReg_National_Govern_Platform';
import CSP_LabReg_nationalAccreditationSelection from '@salesforce/label/c.CSP_LabReg_nationalAccreditationSelection';
import CSP_LabReg_Operating_Brand from '@salesforce/label/c.CSP_LabReg_Operating_Brand';
import CSP_LabReg_OwnFacilities from '@salesforce/label/c.CSP_LabReg_OwnFacilities';
import CSP_LabReg_SLA_InPlace from '@salesforce/label/c.CSP_LabReg_SLA_InPlace';
import CSP_LabReg_TypeOfLab from '@salesforce/label/c.CSP_LabReg_TypeOfLab';
import CSP_LabReg_Which_One from '@salesforce/label/c.CSP_LabReg_Which_One';
import CSP_LabReg_WhichAirlines from '@salesforce/label/c.CSP_LabReg_WhichAirlines';
import CSP_LabRegistry from '@salesforce/label/c.CSP_LabRegistry';
import CSP_LabReg_CountryLabs from '@salesforce/label/c.CSP_LabReg_CountryLabs';
import CSP_L2_Profile_Details_Message from '@salesforce/label/c.CSP_L2_Profile_Details_Message';
import CSP_LabReg_ConfirmationMessage from '@salesforce/label/c.CSP_LabReg_ConfirmationMessage';
import CSP_LabReg_confirmDetails from '@salesforce/label/c.CSP_LabReg_confirmDetails';
import CSP_LabReg_Step2Intro from '@salesforce/label/c.CSP_LabReg_Step2Intro';
import CSP_LabReg_NumberOfLocations from '@salesforce/label/c.CSP_LabReg_NumberOfLocations';

//Spash screen labels

import CSP_LabReg_Step from '@salesforce/label/c.CSP_LabReg_Step';
import CSP_LabReg_Start from '@salesforce/label/c.CSP_LabReg_Start';
import CSP_LabReg_SplashScreen_Intro from '@salesforce/label/c.CSP_LabReg_SplashScreen_Intro';
import CSP_LabReg_SplashScreen_Step1 from '@salesforce/label/c.CSP_LabReg_SplashScreen_Step1';
import CSP_LabReg_SplashScreen_Step2 from '@salesforce/label/c.CSP_LabReg_SplashScreen_Step2';
import CSP_LabReg_SplashScreen_Step3 from '@salesforce/label/c.CSP_LabReg_SplashScreen_Step3';
import CSP_LabReg_SplashScreen_Step4 from '@salesforce/label/c.CSP_LabReg_SplashScreen_Step4';


//Steps labels
import CSP_labReg_Step_GeneralInformation from '@salesforce/label/c.CSP_labReg_Step_GeneralInformation';
import CSP_LabReg_Step_Locations from '@salesforce/label/c.CSP_LabReg_Step_Locations';
import CSP_L2_Confirmation from '@salesforce/label/c.CSP_L2_Confirmation';
import CSP_labReg_Step_Airline_Agreements from '@salesforce/label/c.CSP_labReg_Step_Airline_Agreements';

//Modal Labels
import CSP_L2_Details_Saved from "@salesforce/label/c.CSP_L2_Details_Saved";
import CSP_L2_Go_To_Homepage from "@salesforce/label/c.CSP_L2_Go_To_Homepage";
import CSP_L2_Go_Back from "@salesforce/label/c.CSP_L2_Go_Back";
import CSP_L2_Go_To_Service from "@salesforce/label/c.CSP_L2_Go_To_Service";
import CSP_L2_Registration_Error_Title from "@salesforce/label/c.CSP_L2_Registration_Error_Title";
import CSP_L2_Contact_Support from "@salesforce/label/c.CSP_L2_Contact_Support";
import CSP_LabReg_ThankYouForRequestingService from "@salesforce/label/c.CSP_LabReg_ThankYouForRequestingService";

export default class PortalServiceOnboardingForm extends NavigationMixin(LightningElement) {
	/* Images */
    alertIcon = CSP_PortalPath + 'CSPortal/alertIcon.png';
    homeIcon = CSP_PortalPath + 'CSPortal/Images/Icons/L2_home.png';
    crossIcon = CSP_PortalPath + 'CSPortal/Images/Icons/L2_cross.png';
    stepCheckedLogo = CSP_PortalPath + 'CSPortal/Images/Icons/L2_step_valid.png';
	successIcon = CSP_PortalPath + 'CSPortal/Images/Icons/youaresafe.png';
    
	abortRequest() {
        this.dispatchEvent(new CustomEvent('requestcompleted', { detail: { success: false }, bubbles: true,composed: true }));// sends the event to the grandparent
    }

	@track AccntName = '';
	connectedCallback(){
		getAccountName()
		.then(response => {
			if (response!=null){
				this.AccntName = response;
			}
		});
	}

	//exposed labels
    @track labels = {
		CSP_LabReg_AdditionalCertInPlace
		,CSP_LabReg_airlinePartnershipSelection
		,CSP_LabReg_Describe_SLA_Nature
		,CSP_LabReg_How_Long_In_Business
		,CSP_LabReg_HowManyLabs
		,CSP_LabReg_InitialQuestion
		,CSP_LabReg_issueTestResultsSelection
		,CSP_LabReg_labsPartOfNationalPlatform
		,CSP_LabReg_manageBookingSelection
		,CSP_LabReg_National_Govern_Platform
		,CSP_LabReg_nationalAccreditationSelection
		,CSP_LabReg_Operating_Brand
		,CSP_LabReg_OwnFacilities
		,CSP_LabReg_SLA_InPlace
		,CSP_LabReg_TypeOfLab
		,CSP_LabReg_Which_One
		,CSP_LabReg_WhichAirlines
		,CSP_LabRegistry
		,CSP_L2_Profile_Incomplete_Message
		,CSP_L2_Yes
		,CSP_L2_No
		,CSP_LabReg_FormNotCompleted
		,CSP_LabReg_CountryLabs
		,CSP_L2_Profile_Details_Message
		,CSP_L2_Next_Step
		,CSP_labReg_Step_Airline_Agreements
		,CSP_L2_Confirmation
		,CSP_LabReg_Step_Locations
		,CSP_labReg_Step_GeneralInformation
		,CSP_L2_Back_to_Edit
		,CSP_L2_Submit
		,CSP_L2_Details_Saved
		,CSP_LabReg_ThankYouForRequestingService
		,CSP_L2_Go_To_Homepage
		,CSP_L2_Go_To_Service
		,CSP_L2_Registration_Error_Title
		,CSP_L2_Go_Back
		,CSP_LabReg_ConfirmationMessage
		,CSP_L2_Contact_Support
		,CSP_LabReg_Step
		,CSP_LabReg_Start
		,CSP_LabReg_SplashScreen_Intro
		,CSP_LabReg_SplashScreen_Step1
		,CSP_LabReg_SplashScreen_Step2
		,CSP_LabReg_SplashScreen_Step3
		,CSP_LabReg_SplashScreen_Step4
		,CSP_LabReg_confirmDetails
		,CSP_LabReg_NumberOfLocations
		,CSP_LabReg_Step2Intro
		,CSP_LabReg_InitialQuestionDescription
	}

	@track showSplashScreen = true;

	startSurvey(){
		this.showSplashScreen = false;
	}

	@track isLoading = false;
	//Schema and picklist methods
	@api recordId;
	@api objectApiName;
	
	@track objectInfo;
	@track recTypeId='';
	
	@wire(getObjectInfo, { objectApiName: OBJECT_LAB_ACCOUNT_ROLE_DETAIL }) 
		objectInfo({error, data}) {
			if (data) {
			  const rtis = data.recordTypeInfos;
			  this.recTypeId = Object.keys(rtis).find(rti => rtis[rti].name === 'Default');
			}else if(error){
				//TODO: Handle error
			}
		  };

	@wire(getPicklistValues, { recordTypeId: "$recTypeId", fieldApiName: FIELD_Lab_Type }) FIELD_Lab_Type_PicklistValues;
	@wire(getPicklistValues, { recordTypeId: "$recTypeId", fieldApiName: FIELD_Are_your_labs_part_of_national_platform }) FIELD_Are_your_labs_part_of_national_platform_PicklistValues;
	@wire(getPicklistValues, { recordTypeId: "$recTypeId", fieldApiName: FIELD_Do_you_issue_test_results_for_all_lab }) FIELD_Do_you_issue_test_results_for_all_lab_PicklistValues;
	@wire(getPicklistValues, { recordTypeId: "$recTypeId", fieldApiName: FIELD_Do_you_manage_booking_for_all_locations }) FIELD_Do_you_manage_booking_for_all_locations_PicklistValues;
	@wire(getPicklistValues, { recordTypeId: "$recTypeId", fieldApiName: FIELD_Existing_partnership_with_airlines }) FIELD_Existing_partnership_with_airlines_PicklistValues;
	@wire(getPicklistValues, { recordTypeId: "$recTypeId", fieldApiName: FIELD_National_accreditation_for_all_the_labs }) FIELD_National_accreditation_for_all_the_labs_PicklistValues;
	@wire(getPicklistValues, { recordTypeId: "$recTypeId", fieldApiName: FIELD_Type_of_lab }) FIELD_Type_of_lab_PicklistValues;
	@wire(getPicklistValues, { recordTypeId: "$recTypeId", fieldApiName: FIELD_How_long_have_you_been_in_the_business }) FIELD_How_long_have_you_been_in_the_business_PicklistValues;
	@wire(getPicklistValues, { recordTypeId: "$recTypeId", fieldApiName: FIELD_Operating_under_brand }) FIELD_Operating_under_brand_PicklistValues;
	@wire(getPicklistValues, { recordTypeId: "$recTypeId", fieldApiName: FIELD_Type_of_SLAs_in_place }) FIELD_Type_of_SLAs_in_place_PicklistValues;
	@wire(getPicklistValues, { recordTypeId: "$recTypeId", fieldApiName: FIELD_Additional_certifications_in_place }) FIELD_Additional_certifications_in_place_PicklistValues;
	@wire(getPicklistValues, { recordTypeId: "$recTypeId", fieldApiName: FIELD_Endorsed_by_governments }) FIELD_Endorsed_by_governments_PicklistValues;


	

	
	//Lab Type
	@track labTypeSelection='';
	@track SLAInPlace='';
	@track showNatureOfSLA = false;
	@track NatureOfSLA='';
	@track ownFacilitiesOrPartnerLabSelection='';
	@track manageBookingSelection='';
	@track howLongInBusinessSelection='';
	@track operatingUnderBrand = '';
	@track whichBrands = '';
	@track showWhichBrand = false;
	@track issueTestResultsSelection='';
	@track airlinePartnershipSelection='';
	@track showAirlineSelectionBox=false;
	@track typeOfLabSelection='';
	@track SLACertificationInPlace='';
	@track nationalAccreditationSelection='';
	@track labsPartOfNationalPlatform = '';
	@track whichNationalPlatform = '';
	@track showWhichNationalPlatform = '';
	@track AdditionalCertInPlace = '';
	@track showAdditionalCert = false;
	@track whichAdditionalCert = '';
	@track endorsedByGovern = '';
	@track showWhichGovern = false;
	@track whichGovern = '';


	handleFormElementChange(event){
		let formElementName = event.target.name;
		let formElementValue = event.target.value;

		switch(formElementName){
			case 'labTypeSelection':
				this.labTypeSelection = formElementValue;
				if(this.labTypeSelection=='IT Integrator' || this.labTypeSelection=='Aggregator'){
					this.isAForm = true;
					this.isBForm = false;
				} 
		
				if(this.labTypeSelection=='Independent Lab' || this.labTypeSelection=='Lab Partner/Network'){
					this.isAForm = false;
					this.isBForm = true;
				} 
				break;
			case 'SLAInPlace':
				this.SLAInPlace = formElementValue;
				if(this.SLAInPlace=='Yes')	this.showNatureOfSLA = true;
				else this.showNatureOfSLA = false;
				break;
			case 'ownFacilitiesOrPartnerLabSelection':
				this.ownFacilitiesOrPartnerLabSelection = formElementValue;
				break;
			case 'manageBookingSelection':
				this.manageBookingSelection = formElementValue;
				break;
			case 'howLongInBusinessSelection':
				this.howLongInBusinessSelection = formElementValue;
				break;
			case 'operatingUnderBrand':
				this.operatingUnderBrand = formElementValue;
				if(this.operatingUnderBrand=='Yes')	this.showWhichBrand = true;
				else this.showWhichBrand = false;
				break;
			case 'issueTestResultsSelection':
				this.issueTestResultsSelection = formElementValue;
				break;
			case 'airlinePartnershipSelection':
				this.airlinePartnershipSelection = formElementValue;
				if(this.airlinePartnershipSelection=='Yes')	this.showAirlineSelectionBox = true;
				else this.showAirlineSelectionBox = false;
				break;
			case 'typeOfLabSelection':
				this.typeOfLabSelection = formElementValue;
				break;
			case 'SLACertificationInPlace':
				this.SLACertificationInPlace = formElementValue;
				break;
			case 'nationalAccreditationSelection':
				this.nationalAccreditationSelection = formElementValue;
				break;
			case 'labsPartOfNationalPlatform':
				this.labsPartOfNationalPlatform = formElementValue;
				if(this.labsPartOfNationalPlatform=='Yes') this.showWhichNationalPlatform = true;
				else this.showWhichNationalPlatform = false;
				break;
			case 'AdditionalCertInPlace':
				this.AdditionalCertInPlace = formElementValue;
				if(this.AdditionalCertInPlace=='Yes') this.showAdditionalCert = true;
				else this.showAdditionalCert = false;
				break;
			case 'whichAdditionalCert':
				this.whichAdditionalCert = formElementValue;
				break;
			case 'endorsedByGovern':
				this.endorsedByGovern = formElementValue;
				if(this.endorsedByGovern=='Yes') this.showWhichGovern = true;
				else this.showWhichGovern = false;
				break;
			case 'whichGovern':
				this.whichGovern = formElementValue;
				break;
			case 'whichNationalPlatform':
				this.whichNationalPlatform = formElementValue;
				break;
			case 'whichBrands':
				this.whichBrands = formElementValue;
				break;
			case 'NatureOfSLA':
				this.NatureOfSLA = formElementValue;
				break;
		}

		if(this.isYourDetailsStep){
			if(this.isAForm){
				if(this.labTypeSelection=='' 
					||this.howLongInBusinessSelection==''
					|| this.operatingUnderBrand == ''
					|| (this.operatingUnderBrand == 'Yes' && this.whichBrands == '')
					|| this.SLAInPlace == ''
					|| (this.SLAInPlace == 'Yes' && this.NatureOfSLA == '')
					|| this.manageBookingSelection == ''
					|| this.issueTestResultsSelection == ''
					|| this.labsPartOfNationalPlatform == ''
					|| (this.labsPartOfNationalPlatform == 'Yes' && this.whichNationalPlatform == '')){
						this.isYourDetailStepValid = false;
						//this.isNextDisabled = true;
						this.isConfirmationStepValid = false;
				}else{
					this.isYourDetailStepValid = true;
					//this.isNextDisabled = false;
				}
			}

			if(this.isBForm){
				if(this.labTypeSelection=='' 
					|| this.howLongInBusinessSelection == ''
					|| this.typeOfLabSelection == ''
					|| this.manageBookingSelection == ''
					|| this.issueTestResultsSelection == ''
					|| this.nationalAccreditationSelection == ''
					|| this.AdditionalCertInPlace == ''
					|| (this.AdditionalCertInPlace == 'Yes' && this.whichAdditionalCert == '')
					|| this.endorsedByGovern == ''
					|| (this.endorsedByGovern == 'Yes' && this.whichGovern == '')
					|| this.labsPartOfNationalPlatform == ''
					|| (this.labsPartOfNationalPlatform == 'Yes' && this.whichNationalPlatform == '')){
						this.isYourDetailStepValid = false;
						//this.isNextDisabled = true;
						this.isAirlineAgrStepReachable = false;
						this.isCountryLabsStepReachable = false;
						this.isConfirmationStepValid = false;
				}else{
					this.isYourDetailStepValid = true;
					//this.isNextDisabled = false;
				}
			}
		}

		if(this.isAirlineAgrStep){
			if(this.airlinePartnershipSelection == ''){
				this.isAirlineAgrStepValid = false;
				//this.isNextDisabled = true;
				this.isConfirmationStepValid = false;
			}
			else{
				this.isAirlineAgrStepValid = true;
				//this.isNextDisabled = false;
				this.isConfirmationStepValid = true;
			}
		}

		this.isConfirmationStepReachable = this.isAirlineAgrStepValid && this.isYourDetailStepValid;
		this.isAirlineAgrStepReachable = this.isYourDetailStepValid;
		this.isCountryLabsStepReachable = this.isYourDetailStepValid;

		this.isNextDisabled = ((this.isYourDetailsStep && !this.isYourDetailStepValid)
								|| (this.isCountryLabsStep && !this.isYourDetailStepValid)
								|| (this.isAirlineAgrStep && !this.isAirlineAgrStepValid));
	}


	//Steps and navigation methods
	@track isNextDisabled = true;
	@track showPreviousPageLink = false;

	@track isYourDetailsStep = true;
	@track isCountryLabsStep = false;
	@track isAirlineAgrStep = false;
	@track isConfirmationStep = false;
	@track isGreetingStep = false;

	@track isCountryLabsStepReachable = false;
	@track isAirlineAgrStepReachable = false;
	@track isConfirmationStepReachable = false;
	
	//isCountryLabStep is not having any mandatory field, so is valid when isYourDetailStepValid is true
	@track isYourDetailStepValid = false;
	@track isAirlineAgrStepValid = false;
	@track isConfirmationStepValid = false;

	isAForm = false;
	isBForm = false;

	goToNextStep(){
		if(this.isYourDetailsStep){
			if(this.isYourDetailStepValid){
				//this.isNextDisabled = false; //will be active on the country lab step
				this.isYourDetailsStep = false;
				this.isCountryLabsStep = true;
				this.showPreviousPageLink = true;
			}
			return;
		}

		if(this.isCountryLabsStep){
			if(this.isYourDetailStepValid){
				this.isNextDisabled = true;
				this.isCountryLabsStep = false;
				this.isAirlineAgrStep = true;
				this.showPreviousPageLink = true;
			}
			return;
		}

		if(this.isAirlineAgrStep){
			if(this.isAirlineAgrStepValid){
				this.isNextDisabled = false;
				this.isAirlineAgrStep = false;
				this.isConfirmationStep = true;
				this.showPreviousPageLink = true;
			}
			return;
		}

		if(this.isConfirmationStep){
			this.handleSubmitRequest();
			return;
		}
	}

	goToPreviousStep(){
		this.isLoading = true;
		this.isNextDisabled = false;
		this.showPreviousPageLink = true;

		if(this.isConfirmationStep){
			this.isConfirmationStep = false;
			this.isAirlineAgrStep = true;
			this.isLoading = false;
			return;
		}

		if(this.isAirlineAgrStep){
			this.isAirlineAgrStep = false;
			this.isCountryLabsStep = true;
			this.isLoading = false;
			return;
		}

		if(this.isCountryLabsStep){
			this.isCountryLabsStep = false;
			this.isYourDetailsStep = true;
			this.isLoading = false;
			this.showPreviousPageLink = false;
			return;
		}
	}

	goToYourDetailsStep(){
		this.isYourDetailsStep = true;
		this.isCountryLabsStep = false;
		this.isAirlineAgrStep = false;
		this.isConfirmationStep = false;
	}
	goToCountryLabStep(){
		this.isYourDetailsStep = false;
		this.isCountryLabsStep = true;
		this.isAirlineAgrStep = false;
		this.isConfirmationStep = false;
	}
	goToAirlineAgrStep(){
		this.isYourDetailsStep = false;
		this.isCountryLabsStep = false;
		this.isAirlineAgrStep = true;
		this.isConfirmationStep = false;
	}
	goToConfirmationStep(){
		this.isYourDetailsStep = false;
		this.isCountryLabsStep = false;
		this.isAirlineAgrStep = false;
		this.isConfirmationStep = true;
	}


	handleSubmitRequest(){
		this.isLoading = true;
		//this.dispatchEvent(new CustomEvent('requestcompleted', { detail: { success: false }, bubbles: true,composed: true }));// sends the event to the grandparent
		//this.startLoading();

		let labDetail =  { 'sobjectType': 'LAB_Account_Role_Detail__c' };
		let countriesLabs = [];
		let airlineAgreements = [];

		//common answers
		labDetail.How_long_have_you_been_in_the_business__c = this.howLongInBusinessSelection;
		labDetail.Lab_Type__c = this.labTypeSelection;
		labDetail.Do_you_manage_booking_for_all_locations__c = this.manageBookingSelection;
		labDetail.Do_you_issue_test_results_for_all_lab__c = this.issueTestResultsSelection;
		labDetail.Are_your_labs_part_of_national_platform__c = this.labsPartOfNationalPlatform;
			if(this.labsPartOfNationalPlatform == 'Yes')
				labDetail.Which_National_Platform__c = this.whichNationalPlatform;

		labDetail.Existing_partnership_with_airlines__c = this.airlinePartnershipSelection;

		if(this.isAForm){
			labDetail.Operating_under_brand__c = this.operatingUnderBrand;
			if(this.operatingUnderBrand == 'Yes')
				labDetail.Which_Operating_Brand__c = this.whichBrands;

			labDetail.Type_of_SLAs_in_place__c = this.SLAInPlace;
			if(this.SLAInPlace == 'Yes')
				labDetail.Nature_of_SLA__c = this.NatureOfSLA;

		}if(this.isBForm){
			labDetail.Type_of_lab__c = this.typeOfLabSelection;
			labDetail.National_accreditation_for_all_the_labs__c = this.nationalAccreditationSelection;
			labDetail.Additional_certifications_in_place__c = this.AdditionalCertInPlace;
			if(this.AdditionalCertInPlace == 'Yes')
				labDetail.Additional_Certifications__c = this.whichAdditionalCert;
			
			labDetail.Endorsed_by_governments__c = this.endorsedByGovern;
			if(this.endorsedByGovern == 'Yes')
				labDetail.Which_Governments__c = this.whichGovern;
		}

		this.selectedCountries.forEach(cntr => {
			if(cntr.NumOfLabs == undefined || cntr.NumOfLabs == null ||cntr.NumOfLabs == ''){}
			else{
				let countryLab =  { 'sobjectType': 'LAB_Account_Role_Detail__c' };
				countryLab.Operating_Country__c = cntr.Id;
				countryLab.How_Many_Lab__c = cntr.NumOfLabs;
				countriesLabs.push(countryLab);
			}
		});

		this.selectedAirlines.forEach(airline =>{
			let airlineAgreement =  { 'sobjectType': 'LAB_Account_Role_Detail__c' };
			airlineAgreement.Partner_Airline__c = airline.Id;
			airlineAgreements.push(airlineAgreement);
		});
		

		saveSurveyAnswers({labRoleDetail: labDetail
							, lsCountriesLab : countriesLabs
							, lsAirlineAgreement: airlineAgreements})
			.then(result => {
				let res = JSON.parse(JSON.stringify(result));
				this.isLoading = false;
				if(res === true){
					this.openSuccessModal = true;
				}
				else{
					this.errorModalMessage = 'Error';
        			this.openErrorModal = true; 
				}
			})
			.catch(error => {
				this.errorModalMessage = error;
        		this.openErrorModal = true; 
				this.isLoading = false;
			});    
	}

	
	@track openMessageModal = false;
	landingPage

	openGoToHomePopup(){
        this.landingPage = 'homepage';
        this.openMessageModal = true;
    }

	cancel(){
        this.openMessageModal = false;
    }

	openClosePopup(){
        this.landingPage = 'same';
        this.openMessageModal = true;
    }

	close(){
        this.openMessageModal = false;
        if(this.landingPage == 'same'){
            //abortRequest();
			this.dispatchEvent(new CustomEvent('requestcompleted', { detail: { success: false }, bubbles: true,composed: true }));// sends the event to the grandparent
        }
        else if(this.landingPage == 'homepage'){
            navigateToPage(CSP_PortalPath,{});
        }
    }

	/***********
	 * 
	 *  LAB PER COUNTRIES
	 * 
	 *********/
	 @api countryColumns = [
		{ label: 'Name', fieldName: 'label', editable: false },
		{ label: CSP_LabReg_NumberOfLocations , fieldName: 'NumOfLabs', type: 'number', editable: true, maximumFractionDigits: 0 },
		{ type: 'button-icon', initialWidth: 50, typeAttributes: {iconName: 'utility:close', name: 'delete', variant:'container'}}
	];

	@api countryColumnsRO = [
		{ label: 'Name', fieldName: 'label'},
		{ label: CSP_LabReg_NumberOfLocations, fieldName: 'NumOfLabs', type: 'number'}
	];

	@api countryMetadata = {
		Id: 'Id',
		Name: 'Name'
	};

	@track filteredCountries = [];
	@track countrySearchKey = '';

	allCountries = [];
	selectedCountries = [];
	showdropdown;

	@wire(getCountries,{}) countryData(result){
		if(result.data){
			result.data.countryList.forEach(cntr =>{
				this.allCountries.push({'label' : cntr.Name, 'value' : cntr.Id, 'selected':false});
			});
		}
    }

	handleShowdropdown(event){
		if(event.target.value=='' || event.target.value == undefined || event.target.value == null){
			this.showdropdown = false;
		}
		else{
			if(event.target.value.length>1){
				let searchRegExp = new RegExp(event.target.value , 'i');
				this.filteredCountries = this.allCountries; //reinitialize
				this.filteredCountries = this.filteredCountries.filter(({label}) => label.match(searchRegExp));
				this.showdropdown = true;
			}
		}
    }

	handleSelect(event){
		let allCountriesIndexFound = this.allCountries.findIndex(ar => ar.value == event.detail.selectedItemId);
		if(allCountriesIndexFound>-1)
			this.allCountries[allCountriesIndexFound].selected = event.detail.selected;
		
		if(event.detail.selected==true){
			this.selectedCountries.push({ 'Id': event.detail.selectedItemId, 'label': event.detail.selectedItemName});
		}else{
			let selCountryIndexFound = this.selectedCountries.findIndex(ar => ar.Id == event.detail.selectedItemId);
			this.selectedCountries.splice(selCountryIndexFound, 1);
		}
		this.selectedCountries = [...this.selectedCountries];
	}

	handleleave() {this.showdropdown = false;}

	handleCountryInlineEdit(event){
		let countryId = event.detail.draftValues[0].Id;
		let labNum = event.detail.draftValues[0].NumOfLabs;

		let selectedCountriesIndex = this.selectedCountries.findIndex(ar => ar.Id == countryId);
		if(selectedCountriesIndex > -1)	this.selectedCountries[selectedCountriesIndex].NumOfLabs = labNum;
		this.selectedCountries = [...this.selectedCountries];
	}

	handleRowAction(event) {
		const action = event.detail.action;
		const row = event.detail.row;
		switch (action.name) {
			case 'delete':
				let selCountryIndexFound = this.selectedCountries.findIndex(ar => ar.Id == row.Id);
				this.selectedCountries.splice(selCountryIndexFound, 1);
				this.selectedCountries = [...this.selectedCountries];

				let allCountryIndexFound = this.allCountries.findIndex(ar => ar.value == row.Id);
				this.allCountries[allCountryIndexFound].selected = false;
 		}	
	}

	/***********
	 * 
	 *  AIRLINES
	 * 
	 *********/
	@api airlinesColumns = [
		{ label: 'Name', fieldName: 'label'},
		{ type: 'button-icon', initialWidth: 50, typeAttributes: {iconName: 'utility:close', name: 'deleteAirline', variant:'container'}}
	];

	@api airlinesColumnsRO = [
		{ label: 'Name', fieldName: 'label'}
	];

	@api airlineMetadata = {
		Id: 'Id',
		Name: 'Name'
	};

	@track filteredAirlines = [];
	@track airlineSearchKey = '';

	allAirlines = [];
	selectedAirlines = [];
	showAirlineDropdown;

	@wire(getAirlinesHQ, {}) airlinesData(result){
		if(result.data){
			result.data.forEach(accnt => {
				this.allAirlines.push({'label':accnt.Name, 'value':accnt.Id, 'selected':false});
			});
		}
	}

	handleAirlineDropdown(event){
		if(event.target.value=='' || event.target.value == undefined || event.target.value == null){
			this.showAirlineDropdown = false;
		}
		else{
			if(event.target.value.length>1){
				let searchRegExp = new RegExp(event.target.value , 'i');
				this.filteredAirlines = this.allAirlines; //reinitialize
				this.filteredAirlines = this.filteredAirlines.filter(({label}) => label.match(searchRegExp));
				this.showAirlineDropdown = true;
			}
		}
	}
	

	handleAirlineSelection(event){
		let allAirlinesIndexFound = this.allAirlines.findIndex(ar => ar.value == event.detail.selectedItemId);
		if(allAirlinesIndexFound>-1)
			this.allAirlines[allAirlinesIndexFound].selected = event.detail.selected;
		
		if(event.detail.selected==true){
			this.selectedAirlines.push({ 'Id': event.detail.selectedItemId, 'label': event.detail.selectedItemName});
		}else{
			let selAirlinesIndexFound = this.selectedAirlines.findIndex(ar => ar.Id == event.detail.selectedItemId);
			this.selectedAirlines.splice(selAirlinesIndexFound, 1);
		}
		this.selectedAirlines = [...this.selectedAirlines];
	}

	closeAirlineDropdown() {this.showAirlineDropdown = false;}

	handleAirlineRowAction(event) {
		const action = event.detail.action;
		const row = event.detail.row;
		switch (action.name) {
			case 'deleteAirline':
				let selAirlinesIndexFound = this.selectedAirlines.findIndex(ar => ar.Id == row.Id);
				this.selectedAirlines.splice(selAirlinesIndexFound, 1);
				this.selectedAirlines = [...this.selectedAirlines];

				let allAirlinesIndexFound = this.allAirlines.findIndex(ar => ar.value == row.Id);
				this.allAirlines[allAirlinesIndexFound].selected = false;
 		}	
	}

	/***********
	 * 
	 *  MODALS METHODS
	 * 
	 **********/
	@api errorModalMessage;
	@track openSuccessModal = false;
	@track openErrorModal = false;

	button1Action(){
        navigateToPage(CSP_PortalPath,{});
    }

    button2Action(){
        navigateToPage("services?tab=availableServices");
    }

	closeErrorModal(){
        this.openErrorModal = false;
    }

	contactSupport(){
        document.body.style.overflow = 'auto';
        let category = 'Platforms';
        let topic = 'Customer_Portal';
        let subtopic = 'Customer_Portal_Support';
        var page = "support-reach-us?topic=" + topic;
        navigateToPage(page);
    }
}