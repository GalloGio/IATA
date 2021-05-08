import { LightningElement, track, wire, api } from 'lwc';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import { NavigationMixin } from 'lightning/navigation';
import getCountries from '@salesforce/apex/PortalRegistrationFirstLevelCtrl.getISOCountries';

//Objects schema
import OBJECT_LAB_ACCOUNT_ROLE_DETAIL from '@salesforce/schema/LAB_Account_Role_Detail__c';

//Fields with picklist
import FIELD_LAB_TYPE from '@salesforce/schema/LAB_Account_Role_Detail__c.Lab_Type__c';
import FIELD_ARE_THEY_YOUR_OWN_FACILITIES_OR_PARTNER from '@salesforce/schema/LAB_Account_Role_Detail__c.Are_they_your_own_facilities_or_partner__c';
import FIELD_ARE_YOUR_LABS_PART_OF_NATIONAL_PLATFORM from '@salesforce/schema/LAB_Account_Role_Detail__c.Are_your_labs_part_of_national_platform__c';
import FIELD_DO_YOU_ISSUE_TEST_RESULTS_FOR_ALL_LAB from '@salesforce/schema/LAB_Account_Role_Detail__c.Do_you_issue_test_results_for_all_lab__c';
import FIELD_DO_YOU_MANAGE_BOOKING_FOR_ALL_LOCATIONS from '@salesforce/schema/LAB_Account_Role_Detail__c.Do_you_manage_booking_for_all_locations__c';
import FIELD_EXISTING_PARTNERSHIP_WITH_AIRLINES from '@salesforce/schema/LAB_Account_Role_Detail__c.Existing_partnership_with_airlines__c';
import FIELD_NATIONAL_ACCREDITATION_FOR_ALL_THE_LABS from '@salesforce/schema/LAB_Account_Role_Detail__c.National_accreditation_for_all_the_labs__c';
import FIELD_TYPE_OF_LAB from '@salesforce/schema/LAB_Account_Role_Detail__c.Type_of_lab__c';

//Labels
import Button_Cancel from '@salesforce/label/c.Button_Cancel';
import Button_Next from '@salesforce/label/c.Button_Next';
import Button_Previous from '@salesforce/label/c.Button_Previous';
import ISSP_Confirm from '@salesforce/label/c.ISSP_Confirm';
import CSP_LabReg_HowManyLabs from '@salesforce/label/c.CSP_LabReg_HowManyLabs';
import CSP_LabReg_InitialQuestion from '@salesforce/label/c.CSP_LabReg_InitialQuestion';
import CSP_LabReg_ListRegion_countries from '@salesforce/label/c.CSP_LabReg_ListRegion_countries';
import CSP_LabReg_OwnFacilities from '@salesforce/label/c.CSP_LabReg_OwnFacilities';
import CSP_LabReg_SLACertification from '@salesforce/label/c.CSP_LabReg_SLACertification';
import CSP_LabReg_SLA_InPlace from '@salesforce/label/c.CSP_LabReg_SLA_InPlace';
import CSP_LabReg_TypeOfLab from '@salesforce/label/c.CSP_LabReg_TypeOfLab';
import CSP_LabReg_WhichAirlines from '@salesforce/label/c.CSP_LabReg_WhichAirlines';
import CSP_LabReg_airlinePartnershipSelection from '@salesforce/label/c.CSP_LabReg_airlinePartnershipSelection';
import CSP_LabReg_issueTestResultsSelection from '@salesforce/label/c.CSP_LabReg_issueTestResultsSelection';
import CSP_LabReg_labsPartOfNationalPlatform from '@salesforce/label/c.CSP_LabReg_labsPartOfNationalPlatform';
import CSP_LabReg_manageBookingSelection from '@salesforce/label/c.CSP_LabReg_manageBookingSelection';
import CSP_LabReg_nationalAccreditationSelection from '@salesforce/label/c.CSP_LabReg_nationalAccreditationSelection';
import CSP_LabRegistry from '@salesforce/label/c.CSP_LabRegistry';

import CSP_Error_Message_Mandatory_Fields from '@salesforce/label/c.CSP_Error_Message_Mandatory_Fields_Contact';

export default class PortalServiceOnboardingForm extends NavigationMixin(LightningElement) {
	abortRequest() {
        this.dispatchEvent(new CustomEvent('requestcompleted', { detail: { success: false }, bubbles: true,composed: true }));// sends the event to the grandparent
    }

	//exposed labels
    @track label = {
		Button_Cancel
		,Button_Previous
		,Button_Next
		,ISSP_Confirm
		,CSP_LabReg_HowManyLabs
		,CSP_LabReg_InitialQuestion
		,CSP_LabReg_ListRegion_countries
		,CSP_LabReg_OwnFacilities
		,CSP_LabReg_SLACertification
		,CSP_LabReg_SLA_InPlace
		,CSP_LabReg_TypeOfLab
		,CSP_LabReg_WhichAirlines
		,CSP_LabReg_airlinePartnershipSelection
		,CSP_LabReg_issueTestResultsSelection
		,CSP_LabReg_labsPartOfNationalPlatform
		,CSP_LabReg_manageBookingSelection
		,CSP_LabReg_nationalAccreditationSelection
		,CSP_LabRegistry
		,CSP_Error_Message_Mandatory_Fields
	}

	//Steps and navigation buttons
	@track isFirstStep = true;
	@track isLastStep = false;
	
	@track currentStep = 'isFirstStep';
	@track showMandatoryFieldsError = false;

	isAForm = false;
	@track setAForm = false;
	@track SetAstep01 = false;
	@track SetAStep02 = false;
	@track SetAStep03 = false;

	isBForm = false;
	@track setBForm = false;
	@track SetBstep01 = false;
	@track SetBStep02 = false;
	@track SetBStep03 = false;


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

	@wire(getPicklistValues, { recordTypeId: "$recTypeId", fieldApiName: FIELD_LAB_TYPE }) LAB_TYPE_PicklistValues;
	@wire(getPicklistValues, { recordTypeId: "$recTypeId", fieldApiName: FIELD_ARE_THEY_YOUR_OWN_FACILITIES_OR_PARTNER }) THEY_YOUR_OWN_FACILITIES_OR_PARTNER_PicklistValues;
	@wire(getPicklistValues, { recordTypeId: "$recTypeId", fieldApiName: FIELD_ARE_YOUR_LABS_PART_OF_NATIONAL_PLATFORM }) ARE_YOUR_LABS_PART_OF_NATIONAL_PLATFORM_PicklistValues;
	@wire(getPicklistValues, { recordTypeId: "$recTypeId", fieldApiName: FIELD_DO_YOU_ISSUE_TEST_RESULTS_FOR_ALL_LAB }) DO_YOU_ISSUE_TEST_RESULTS_FOR_ALL_LAB_PicklistValues;
	@wire(getPicklistValues, { recordTypeId: "$recTypeId", fieldApiName: FIELD_DO_YOU_MANAGE_BOOKING_FOR_ALL_LOCATIONS }) DO_YOU_MANAGE_BOOKING_FOR_ALL_LOCATIONS_PicklistValues;
	@wire(getPicklistValues, { recordTypeId: "$recTypeId", fieldApiName: FIELD_EXISTING_PARTNERSHIP_WITH_AIRLINES }) EXISTING_PARTNERSHIP_WITH_AIRLINES_PicklistValues;
	@wire(getPicklistValues, { recordTypeId: "$recTypeId", fieldApiName: FIELD_NATIONAL_ACCREDITATION_FOR_ALL_THE_LABS }) NATIONAL_ACCREDITATION_FOR_ALL_THE_LABS_PicklistValues;
	@wire(getPicklistValues, { recordTypeId: "$recTypeId", fieldApiName: FIELD_TYPE_OF_LAB }) TYPE_OF_LAB_PicklistValues;

	//Countries
	@api countryColumns = [
		{ label: 'Name', fieldName: 'Name', editable: false },
		{ label: 'Iso Code', fieldName: 'IsoCode', editable: false },
		{ label: 'Number Of Labs', fieldName: 'NumOfLabs', type: 'number', editable: true, maximumFractionDigits: 0 }
	];

	@api countryMetadata = {
		Id: 'Id',
		Name: 'Name',
		IsoCode: 'Iso_code__c'
	};

	@api countriesAfrica = [];
	@track countriesEurope = [];
	@track countriesAmerica = [];
	@track countriesAsia = [];
	@track countriesChina = [];


	@wire(getCountries,{}) countryData(result){
		
		if(result.data){
			console.log('I am loading countries data');
			let Africa = [];
			let America = [];
			let Asia = [];
			let China = [];
			let Europe = [];

			result.data.countryList.forEach(cntr =>{
				let tmp = {};

				tmp.Id = cntr.Id;
				tmp.Name = cntr.Name;
				tmp.IsoCode = cntr.ISO_Code__c;

				switch(cntr.Region__c){
					case 'Africa & Middle East':
						Africa.push(tmp);
						//this.countriesAfrica.push({ 'Id': cntr.Id, 'Name': cntr.Name, 'IsoCode':cntr.ISO_Code__c});
						break;
					case 'Americas':
						America.push(tmp);
						//this.countriesAmerica.push({ 'Id': cntr.Id, 'Name': cntr.Name, 'IsoCode':cntr.ISO_Code__c});
						break;
					case 'Asia & Pacific':
						Asia.push(tmp);
						//this.countriesAsia.push({ 'Id': cntr.Id, 'Name': cntr.Name, 'IsoCode':cntr.ISO_Code__c});
						break;
					case 'China & North Asia':
						China.push(tmp);
						//this.countriesChina.push({ 'Id': cntr.Id, 'Name': cntr.Name, 'IsoCode':cntr.ISO_Code__c});
						break;
					case 'Europe':
						Europe.push(tmp);
						//this.countriesEurope.push({ 'Id': cntr.Id, 'Name': cntr.Name, 'IsoCode':cntr.ISO_Code__c});
						break;
				}

				this.countriesAfrica = Africa;
				this.countriesAmerica = America;
				this.countriesAsia = Asia;
				this.countriesChina = China;
				this.countriesEurope = Europe;
			});
		}
    }

	getSavedLabNum(cntrId){
		let indexFound = this.savedLabsNumberPerCountry.findIndex(ar => ar.Id == cntrId);
		if(indexFound>-1) return this.savedLabsNumberPerCountry[indexFound].labNum;
		else return null;
	}

	

	handleCountryInlineEdit(event){
		let countryId = event.detail.draftValues[0].Id;
		let labNum = event.detail.draftValues[0].NumOfLabs;

		let chinaIndexFuond = this.countriesChina.findIndex(ar => ar.Id == countryId);
		if(chinaIndexFuond > -1){
			console.log('found index in countriesChina set: ' + chinaIndexFuond);
			this.countriesChina[chinaIndexFuond].NumOfLabs = labNum;
		}

		let africaIndexFuond = this.countriesAfrica.findIndex(ar => ar.Id == countryId);
		if(africaIndexFuond > -1){
			console.log('found index in countriesAfrica set: ' + africaIndexFuond);
			this.countriesAfrica[africaIndexFuond].NumOfLabs = labNum;
			console.log(this.countriesAfrica[africaIndexFuond].labNum);
		} 

		let americaIndexFuond = this.countriesAmerica.findIndex(ar => ar.Id == countryId);
		if(americaIndexFuond > -1){
			console.log('found index in countriesAmerica set: ' + americaIndexFuond);
			this.countriesAmerica[americaIndexFuond].NumOfLabs = labNum;
		}

		let asiaIndexFuond = this.countriesAsia.findIndex(ar => ar.Id == countryId);
		if(asiaIndexFuond > -1){
			console.log('found index in countriesAsia set: ' + asiaIndexFuond);
			this.countriesAsia[asiaIndexFuond].NumOfLabs = labNum;
		}

		let europeIndexFuond = this.countriesEurope.findIndex(ar => ar.Id == countryId);
		if(europeIndexFuond > -1){
			console.log('found index in countriesEurope set: ' + europeIndexFuond);
			this.countriesEurope[europeIndexFuond].NumOfLabs = labNum;
		}

		

		let indexFound = this.savedLabsNumberPerCountry.findIndex(ar => ar.Id == countryId);

		if(indexFound>-1)
			this.savedLabsNumberPerCountry[indexFound].NumOfLabs = labNum;
		else
			this.savedLabsNumberPerCountry.push({'Id': countryId, 'NumOfLabs':labNum});
	}

	@track savedLabsNumberPerCountry = []
	
	//Lab Type
	@track labTypeSelection='';
	@track SLAInPlace='';
	@track ownFacilitiesOrPartnerLabSelection='';
	@track manageBookingSelection='';
	@track issueTestResultsSelection='';
	@track airlinePartnership01Selection='';
	@track typeOfLabSelection='';
	@track SLACertificationInPlace='';
	@track nationalAccreditationSelection='';
	@track labsPartOfNationalPlatform='';
	@track airlinePartnership02Selection='';


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
		
				if(this.labTypeSelection=='Independent' || this.labTypeSelection=='Lab Network'){
					this.isAForm = false;
					this.isBForm = true;
				} 
				break;
			case 'SLAInPlace':
				this.SLAInPlace = formElementValue;
				break;
			case 'ownFacilitiesOrPartnerLabSelection':
				this.ownFacilitiesOrPartnerLabSelection = formElementValue;
				break;
			case 'manageBookingSelection':
				this.manageBookingSelection = formElementValue;
				break;
			case 'issueTestResultsSelection':
				this.issueTestResultsSelection = formElementValue;
				break;
			case 'airlinePartnership01Selection':
				this.airlinePartnership01Selection = formElementValue;
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
				break;
			case 'airlinePartnership02Selection':
				this.airlinePartnership02Selection = formElementValue;
				break;
		}
	}


	//Navigation methods
	goToNextStep(){
		switch(this.currentStep){
			case 'isFirstStep':
				if(this.labTypeSelection==''){
					this.showMandatoryFieldsError = true;
				}else{
					this.setAllNAvigationStepsToFalse();
					if(this.isAForm){
						this.setAForm = true;
						this.SetAstep01 = true;
						this.currentStep = 'SetAstep01';
					}

					if(this.isBForm){
						this.setBForm = true;
						this.SetBstep01 = true;
						this.currentStep = 'SetBstep01';
					}
				}
				break;
			
			//A FORM STEPS
			case 'SetAstep01':
				this.setAllNAvigationStepsToFalse();
				this.setAForm = true;
				this.SetAstep02 = true;
				this.currentStep = 'SetAstep02';
				break;
			case 'SetAstep02':
				this.setAllNAvigationStepsToFalse();
				this.setAForm = true;
				this.SetAstep03 = true;
				this.isLastStep = true;
				this.currentStep = 'SetAstep03';
				break;
			
			
			//B FORM STEPS
			case 'SetBstep01':
				this.setAllNAvigationStepsToFalse();
				this.setBForm = true;
				this.SetBstep02 = true;
				this.currentStep = 'SetBstep02';
				break;
			case 'SetBstep02':
				this.setAllNAvigationStepsToFalse();
				this.setBForm = true;
				this.SetBstep03 = true;
				this.isLastStep = true;
				this.currentStep = 'SetBstep03';
				break;


		}
	}


	goToPreviousStep(){
		this.setAllNAvigationStepsToFalse();
		switch(this.currentStep){
			case 'SetAstep03':
				this.setAForm = true;
				this.SetAstep02 = true;
				this.isLastStep = false;
				this.currentStep = 'SetAstep02';
			break;
			case 'SetAstep02':
				this.setAForm = true;
				this.SetAstep01 = true;
				this.currentStep = 'SetAstep01';
				break;
			case 'SetAstep01':
				this.isFirstStep = true;
				this.currentStep = 'isFirstStep';
				break;

			
			case 'SetBstep03':
				this.setBForm = true;
				this.SetBstep02 = true;
				this.isLastStep = false;
				this.currentStep = 'SetBstep02';
			break;
			case 'SetBstep02':
				this.setBForm = true;
				this.SetBstep01 = true;
				this.currentStep = 'SetBstep01';
				break;
			case 'SetBstep01':
				this.isFirstStep = true;
				this.currentStep = 'isFirstStep';
				break;
		}

	}

	setAllNAvigationStepsToFalse(){
		this.isFirstStep = false;
		
		this.setAForm = false;
		this.SetAstep01 = false;
		this.SetAstep02 = false;
		this.SetAstep03 = false;

		this.setBForm = false;
		this.SetBstep01 = false;
		this.SetBstep02 = false;
		this.SetBstep03 = false;

		this.showMandatoryFieldsError = false;
	}

	handleSubmitRequest(){
		//TODO Create method to save 
		this.dispatchEvent(new CustomEvent('requestcompleted', { detail: { success: false }, bubbles: true,composed: true }));// sends the event to the grandparent
	}

	


}