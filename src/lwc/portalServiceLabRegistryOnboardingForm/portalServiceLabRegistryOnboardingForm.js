import { LightningElement, track, wire, api } from 'lwc';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import { NavigationMixin } from 'lightning/navigation';
import getCountries from '@salesforce/apex/PortalRegistrationFirstLevelCtrl.getISOCountries';
import getAirlinesHQ from '@salesforce/apex/LabRegistry_helper.getAirlinesHQ';

//Objects schema
import OBJECT_LAB_ACCOUNT_ROLE_DETAIL from '@salesforce/schema/LAB_Account_Role_Detail__c';

//Fields with picklist
import FIELD_Lab_Type from '@salesforce/schema/LAB_Account_Role_Detail__c.Lab_Type__c';

import FIELD_How_long_have_you_been_in_the_business from '@salesforce/schema/LAB_Account_Role_Detail__c.How_long_have_you_been_in_the_business__c';
import FIELD_Operating_under_brand from '@salesforce/schema/LAB_Account_Role_Detail__c.Operating_under_brand__c';
import FIELD_Type_of_SLAs_in_place from '@salesforce/schema/LAB_Account_Role_Detail__c.Type_of_SLAs_in_place__c';
import FIELD_Do_you_manage_booking_for_all_locations from '@salesforce/schema/LAB_Account_Role_Detail__c.Do_you_manage_booking_for_all_locations__c';
import FIELD_Do_you_issue_test_results_for_all_lab from '@salesforce/schema/LAB_Account_Role_Detail__c.Do_you_issue_test_results_for_all_lab__c';
import FIELD_Are_your_labs_part_of_national_platform from '@salesforce/schema/LAB_Account_Role_Detail__c.Are_your_labs_part_of_national_platform__c';
import FIELD_Existing_partnership_with_airlines from '@salesforce/schema/LAB_Account_Role_Detail__c.Existing_partnership_with_airlines__c';
import FIELD_Type_of_lab from '@salesforce/schema/LAB_Account_Role_Detail__c.Type_of_lab__c';
import FIELD_National_accreditation_for_all_the_labs from '@salesforce/schema/LAB_Account_Role_Detail__c.National_accreditation_for_all_the_labs__c';
import FIELD_Additional_certifications_in_place from '@salesforce/schema/LAB_Account_Role_Detail__c.Additional_certifications_in_place__c';
import FIELD_Endorsed_by_governments from '@salesforce/schema/LAB_Account_Role_Detail__c.Endorsed_by_governments__c';

//Labels
import Button_Cancel from '@salesforce/label/c.Button_Cancel';
import Button_Next from '@salesforce/label/c.Button_Next';
import Button_Previous from '@salesforce/label/c.Button_Previous';
import ISSP_Confirm from '@salesforce/label/c.ISSP_Confirm';

import CSP_LabReg_AdditionalCertInPlace from '@salesforce/label/c.CSP_LabReg_AdditionalCertInPlace';
import CSP_LabReg_airlinePartnershipSelection from '@salesforce/label/c.CSP_LabReg_airlinePartnershipSelection';
import CSP_LabReg_Describe_SLA_Nature from '@salesforce/label/c.CSP_LabReg_Describe_SLA_Nature';
import CSP_LabReg_How_Long_In_Business from '@salesforce/label/c.CSP_LabReg_How_Long_In_Business';
import CSP_LabReg_HowManyLabs from '@salesforce/label/c.CSP_LabReg_HowManyLabs';
import CSP_LabReg_InitialQuestion from '@salesforce/label/c.CSP_LabReg_InitialQuestion';
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
		,CSP_Error_Message_Mandatory_Fields
		,CSP_LabReg_AdditionalCertInPlace
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
	}


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
			result.data.countryList.forEach(cntr =>{
				switch(cntr.Region__c){
					case 'Africa & Middle East':
						this.countriesAfrica.push({ 'Id': cntr.Id, 'Name': cntr.Name, 'IsoCode':cntr.ISO_Code__c});
						break;
					case 'Americas':
						this.countriesAmerica.push({ 'Id': cntr.Id, 'Name': cntr.Name, 'IsoCode':cntr.ISO_Code__c});
						break;
					case 'Asia & Pacific':
						this.countriesAsia.push({ 'Id': cntr.Id, 'Name': cntr.Name, 'IsoCode':cntr.ISO_Code__c});
						break;
					case 'China & North Asia':
						this.countriesChina.push({ 'Id': cntr.Id, 'Name': cntr.Name, 'IsoCode':cntr.ISO_Code__c});
						break;
					case 'Europe':
						this.countriesEurope.push({ 'Id': cntr.Id, 'Name': cntr.Name, 'IsoCode':cntr.ISO_Code__c});
						break;
				}
			});
		}
    }

	handleCountryInlineEdit(event){
		let countryId = event.detail.draftValues[0].Id;
		let labNum = event.detail.draftValues[0].NumOfLabs;

		let chinaIndexFuond = this.countriesChina.findIndex(ar => ar.Id == countryId);
		if(chinaIndexFuond > -1)	this.countriesChina[chinaIndexFuond].NumOfLabs = labNum;

		let africaIndexFuond = this.countriesAfrica.findIndex(ar => ar.Id == countryId);
		if(africaIndexFuond > -1)	this.countriesAfrica[africaIndexFuond].NumOfLabs = labNum; 

		let americaIndexFuond = this.countriesAmerica.findIndex(ar => ar.Id == countryId);
		if(americaIndexFuond > -1)	this.countriesAmerica[americaIndexFuond].NumOfLabs = labNum;

		let asiaIndexFuond = this.countriesAsia.findIndex(ar => ar.Id == countryId);
		if(asiaIndexFuond > -1)	this.countriesAsia[asiaIndexFuond].NumOfLabs = labNum;

		let europeIndexFuond = this.countriesEurope.findIndex(ar => ar.Id == countryId);
		if(europeIndexFuond > -1)	this.countriesEurope[europeIndexFuond].NumOfLabs = labNum;
	}

	@track savedLabsNumberPerCountry = [];

	//Airlines HQ
	@track selectedAirlines = [];
	@api airlinesHQColumns = [
		{ label: 'Name', fieldName: 'Name'},
		{ label: 'Airline Code', fieldName: 'Airline_designator'}
	];

	@track airlinesHQ = [];
	localAirlinesHQ = [];

	@wire(getAirlinesHQ, {}) airlinesData(result){
		if(result.data){
			result.data.forEach(accnt => {
				this.localAirlinesHQ.push({'Id':accnt.Id, 'Name':accnt.Name, 'Airline_designator': accnt.Airline_designator__c});
			});
		}else{
			if(result.error){
			}
		}
	}

	/*filterAirlines(event) {
		if(event.target.value=='' || event.target.value == undefined || event.target.value == null){
			this.airlinesHQ = [];
		}else{
			if(event.target.value.length>1){
				var regex = new RegExp(event.target.value,'gi')
				this.airlinesHQ = this.localAirlinesHQ.filter(row => regex.test(row.Name));
			}
		}
    }*/

	selectAirline(event){
		const selectedRows = event.detail.selectedRows;
		selectedAirlines = [];
		for (let i = 0; i < selectedRows.length; i++){
			this.selectedAirlines.push(selectedRows[i]);
        }
	}

	handleLetterFilter(event){
		let letter = event.target.text;
		var regex = new RegExp('^' + letter, 'i');
		this.airlinesHQ = this.localAirlinesHQ.filter(row => regex.test(row.Name));
		//alert(letter);
	}

	
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
				if(this.airlinePartnership01Selection == 'Yes'){
					this.showConfirmButton = false;
					this.showNextButton = true;
				}else{
					this.showConfirmButton = true;
					this.showNextButton = false;
				}
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
				if(this.airlinePartnership02Selection == 'Yes'){
					this.showConfirmButton = false;
					this.showNextButton = true;
				}else{
					this.showConfirmButton = true;
					this.showNextButton = false;
				}
				break;
		}
	}


	//Steps and navigation methods
	@track isFirstStep = true;
	@track isLastStep = false;
	
	@track currentStep = 'isFirstStep';
	@track showMandatoryFieldsError = false;

	isAForm = false;
	@track setAForm = false;
	@track SetAstep01 = false;
	@track SetAStep02 = false;

	isBForm = false;
	@track setBForm = false;
	@track SetBstep01 = false;
	@track SetBStep02 = false;

	@track airlineSelectionStep = false;
	@track confirmStep = false;
	@track finalStep = false;

	@track showNextButton = true;
	@track showPrevButton = false;
	@track showConfirmButton = false;

	goToNextStep(){
		switch(this.currentStep){
			case 'isFirstStep':
				if(this.labTypeSelection==''){
					this.showMandatoryFieldsError = true;
				}else{
					this.setAllNAvigationStepsToFalse();
					this.showPrevButton = true;
					this.showNextButton = true;
					this.showConfirmButton = false;

					if(this.isAForm){
						this.setAForm = true;
						this.setBForm = false;
						this.SetAstep01 = true;
						this.currentStep = 'SetAstep01';
					}

					if(this.isBForm){
						this.setBForm = true;
						this.setAForm = false;
						this.SetBstep01 = true;
						this.currentStep = 'SetBstep01';
					}
				}
				break;
			
			//A FORM STEPS
			case 'SetAstep01':
				this.setAllNAvigationStepsToFalse();
				//this.setAForm = true;
				this.SetAstep02 = true;
				this.currentStep = 'SetAstep02';
				this.showPrevButton = true;
				this.showNextButton = false;
				this.showConfirmButton = false;
				break;
			case 'SetAstep02':
				if(this.SLAInPlace == '' || this.ownFacilitiesOrPartnerLabSelection == '' || this.manageBookingSelection == '' || this.issueTestResultsSelection=='' || this.airlinePartnership01Selection==''){
					this.showMandatoryFieldsError = true;
				}else{
					this.setAllNAvigationStepsToFalse();
					//this.setAForm = true;
					this.showPrevButton = true;
					this.showNextButton = false;
					this.showConfirmButton = false;

					if(this.airlinePartnership01Selection=='Yes'){
						this.currentStep = 'airlineSelectionStep';
						this.airlineSelectionStep = true;
						this.showConfirmButton = true;
					}else{
						this.currentStep = 'finalStep';
						this.finalStep = true;
					}
				}
				break;
			
			
			//B FORM STEPS
			case 'SetBstep01':
				this.setAllNAvigationStepsToFalse();
				//this.setBForm = true;
				this.SetBstep02 = true;
				this.currentStep = 'SetBstep02';
				this.showPrevButton = true;
				this.showNextButton = false;
				this.showConfirmButton = false;
				break;
			case 'SetBstep02':
				if(this.typeOfLabSelection == '' || this.SLACertificationInPlace == '' || this.nationalAccreditationSelection == '' || this.labsPartOfNationalPlatform=='' || this.airlinePartnership02Selection==''){
					this.showMandatoryFieldsError = true;
				}else{
					this.setAllNAvigationStepsToFalse();
					//this.setBForm = true;
					this.showPrevButton = true;
					this.showNextButton = false;
					this.showConfirmButton = false;

					if(this.airlinePartnership02Selection=='Yes'){
						this.currentStep = 'airlineSelectionStep';
						this.airlineSelectionStep = true;
						this.showConfirmButton = true;
					}else{
						this.currentStep = 'finalStep';
						this.finalStep = true;
					}
				}
				break;
			
			case 'airlineSelectionStep':
				this.setAllNAvigationStepsToFalse();
				this.showConfirmButton = false;
				this.showNextButton = false;
				this.showPrevButton = false;
				this.currentStep = 'finalStep'
				this.finalStep = true;
				break
				/*this.setAllNAvigationStepsToFalse();
				this.showPrevButton = true;
				this.showNextButton = false;
				this.showConfirmButton = true;

				this.currentStep = 'confirmStep';
				break;

			//ConfirmStep
			case 'confirmStep':
				this.setAllNAvigationStepsToFalse();
				this.showConfirmButton = false;
				this.showNextButton = false;
				this.showPrevButton = false;
				this.currentStep = 'finalStep'
				break;*/
		}
	}


	goToPreviousStep(){
		this.setAllNAvigationStepsToFalse();
		switch(this.currentStep){

			case 'SetAstep02':
				//this.setAForm = true;
				this.SetAstep01 = true;
				this.showConfirmButton = false;
				this.showNextButton = true;
				this.showPrevButton = true;
				this.currentStep = 'SetAstep01';
				break;

			case 'SetAstep01':
				this.isFirstStep = true;
				this.showConfirmButton = false;
				this.showNextButton = true;
				this.showPrevButton = false;
				this.currentStep = 'isFirstStep';
				break;

			

			case 'SetBstep02':
				//this.setBForm = true;
				this.showConfirmButton = false;
				this.showNextButton = true;
				this.showPrevButton = true;
				this.SetBstep01 = true;
				this.currentStep = 'SetBstep01';
				break;
			case 'SetBstep01':
				this.isFirstStep = true;
				this.showConfirmButton = false;
				this.showNextButton = true;
				this.showPrevButton = false;
				this.currentStep = 'isFirstStep';
				break;


			
			case 'airlineSelectionStep':
				this.showConfirmButton = false;
				this.showNextButton = true;
				this.showPrevButton = true;

				if(this.setBForm){
					this.SetBstep02 = true;
					this.currentStep = 'SetBstep02';
				}
				else{
					this.SetAstep02 = true;
					this.currentStep = 'SetAstep02';
				}

				break;

		}

	}

	setAllNAvigationStepsToFalse(){
		this.isFirstStep = false;
		
		//this.setAForm = false;
		this.SetAstep01 = false;
		this.SetAstep02 = false;

		//this.setBForm = false;
		this.SetBstep01 = false;
		this.SetBstep02 = false;

		this.airlineSelectionStep = false;
		this.confirmStep = false;
		this.finalStep = false;
	
		this.showPrevButton = false;

		this.showMandatoryFieldsError = false;
	}

	handleSubmitRequest(){
		//TODO Create method to save
		if(this.setAForm && (this.SLAInPlace == '' || this.ownFacilitiesOrPartnerLabSelection == '' || this.manageBookingSelection == '' || this.issueTestResultsSelection=='' || this.airlinePartnership01Selection=='')){
			this.showMandatoryFieldsError = true;
		}
		else if(this.setBForm && (this.typeOfLabSelection == '' || this.SLACertificationInPlace == '' || this.nationalAccreditationSelection == '' || this.labsPartOfNationalPlatform=='' || this.airlinePartnership02Selection=='')){
			this.showMandatoryFieldsError = true;
		}
		else{
			//this.dispatchEvent(new CustomEvent('requestcompleted', { detail: { success: false }, bubbles: true,composed: true }));// sends the event to the grandparent
		}
	}

	


}