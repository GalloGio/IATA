import { LightningElement, track, wire, api } from 'lwc';
import { getObjectInfo, getPicklistValues } from 'lightning/uiObjectInfoApi';
import { NavigationMixin } from 'lightning/navigation';

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
	}

	//Steps and navigation buttons
	@track isFirstStep = true;
	@track isLastStep = false;
	
	@track currentStep = 'isFirstStep';

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


	//Schema methods
	@api recordId;
	@api objectApiName;
	
	@track objectInfo;
	@track recTypeId='';
	
	@wire(getObjectInfo, { objectApiName: OBJECT_LAB_ACCOUNT_ROLE_DETAIL }) 
		objectInfo({error, data}) {
			if (error) {
			  // handle Error
			} else if (data) {
			  const rtis = data.recordTypeInfos;
			  this.recTypeId = Object.keys(rtis).find(rti => rtis[rti].name === 'Default');
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

	
	//Lab Type
	labType='';
	handleLabTypeChange(event){
		this.labType = event.detail.value;
		if(this.labType=='IT integrator' || this.labType=='Aggregator'){
			this.isAForm = true;
			this.isBForm = false;
		} 

		if(this.labType=='Independent' || this.labType=='Lab Network'){
			this.isAForm = false;
			this.isBForm = true;
		} 
	}


	//Navigation methods
	goToNextStep(){
		this.setAllNAvigationStepsToFalse();
		
		switch(this.currentStep){
			case 'isFirstStep':
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
				break;
			
			//A FORM STEPS
			case 'SetAstep01':
				this.setAForm = true;
				this.SetAstep02 = true;
				this.currentStep = 'SetAstep02';
				break;
			case 'SetAstep02':
				this.setAForm = true;
				this.SetAstep03 = true;
				this.isLastStep = true;
				this.currentStep = 'SetAstep03';
				break;
			
			
			//B FORM STEPS
			case 'SetBstep01':
				this.setBForm = true;
				this.SetBstep02 = true;
				this.currentStep = 'SetBstep02';
				break;
			case 'SetBstep02':
				this.setBForm = true;
				this.SetBstep03 = true;
				this.isLastStep = true;
				this.currentStep = 'SetBstep03';
				break;


		}
	}


	goToPreviousStep(){
		switch(this.currentStep){
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
	}

	handleSubmitRequest(){
		//TODO Create method to save 
		this.dispatchEvent(new CustomEvent('requestcompleted', { detail: { success: false }, bubbles: true,composed: true }));// sends the event to the grandparent
	}

	


}