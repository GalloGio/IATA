import { LightningElement, track, wire, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import { NavigationMixin } from 'lightning/navigation';
import retrieveSavedData from '@salesforce/apex/LabRegistry_helper.retrieveSavedData';
import ApproveDenyApplication from '@salesforce/apex/LabRegistry_helper.ApproveDenyApplication';

import cspStylesheet    from '@salesforce/resourceUrl/CSP_Stylesheet';

//Generic Labels
import CSP_L2_Yes							from '@salesforce/label/c.CSP_L2_Yes';
import CSP_L2_No							from '@salesforce/label/c.CSP_L2_No';
import CSP_L2_Submit from '@salesforce/label/c.CSP_L2_Submit';

//Questions labels
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
import CSP_LabReg_CountryLabs from '@salesforce/label/c.CSP_LabReg_CountryLabs';
import CSP_L2_Profile_Details_Message from '@salesforce/label/c.CSP_L2_Profile_Details_Message';

//Steps labels
import CSP_labReg_Step_GeneralInformation from '@salesforce/label/c.CSP_labReg_Step_GeneralInformation';
import CSP_LabReg_Step_Locations from '@salesforce/label/c.CSP_LabReg_Step_Locations';
import CSP_L2_Confirmation from '@salesforce/label/c.CSP_L2_Confirmation';
import CSP_labReg_Step_Airline_Agreements from '@salesforce/label/c.CSP_labReg_Step_Airline_Agreements';


export default class LabRegistryReviewApplication extends NavigationMixin(LightningElement) {
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
		,CSP_L2_Yes
		,CSP_L2_No
		,CSP_LabReg_CountryLabs
		,CSP_L2_Profile_Details_Message
		,CSP_labReg_Step_Airline_Agreements
		,CSP_L2_Confirmation
		,CSP_LabReg_Step_Locations
		,CSP_labReg_Step_GeneralInformation
		,CSP_L2_Submit
	}

	@api countryColumns = [
		{ label: 'Name', fieldName: 'Name'},
		{ label: 'Number Of Labs', fieldName: 'NumOfLabs', type: 'number'}
	];

	@api airlinesColumns = [
		{ label: 'Name', fieldName: 'Name'}
	];

	@track isPARAlreadyApprovedOrDenied;
	@track isAppropriateCase;

	@api caseId = null;
	@api PAR;
	@api labRoleDetail;
	@api lsCountriesLab = [];
	@api lsAirlineAgreement = [];

	@api labTypeSelection;
	@api howLongInBusinessSelection;
	@api labsPartOfNationalPlatform;
		@api showWhichNationalPlatform = false;
		@api whichNationalPlatform;
	@api issueTestResultsSelection;
	@api manageBookingSelection;
	@api airlinePartnershipSelection;

	//FORM A
	@api isAForm;
	@api operatingUnderBrand;
		@api showWhichBrand = false;
		@api whichBrands;
	@api SLAInPlace;
		@api showNatureOfSLA = false;
		@api NatureOfSLA;

	//FORM B
	@api isBForm;
	@api typeOfLabSelection;
	@api AdditionalCertInPlace;
		@api showAdditionalCert = false;
		@api whichAdditionalCert;
	@api endorsedByGovern;
		@api showWhichGovern = false;
		@api whichGovern;
	@api nationalAccreditationSelection;

	connectedCallback() {
		loadStyle(this, cspStylesheet);

		if (this.caseId){
			//alert(this.caseId);
			retrieveSavedData({
				recordID: this.caseId
			})
			.then(result => {
				if(result){
					this.PAR = result.PAR;
					let onboardingCase = result.onboardingCase;
					if (onboardingCase.CaseArea__c == 'IATA Travel Pass' && onboardingCase.Reason1__c =='New access request')
						this.isAppropriateCase = true;
					else
						this.isAppropriateCase = false;

					if(this.PAR.Right__c == 'Access Requested')
						this.isPARAlreadyApprovedOrDenied = false;
					else
						this.isPARAlreadyApprovedOrDenied = true;
					
					this.labRoleDetail = result.labRoleDetail;
	
					this.labTypeSelection = result.labRoleDetail.Lab_Type__c;
					this.howLongInBusinessSelection = result.labRoleDetail.How_long_have_you_been_in_the_business__c;
					this.labsPartOfNationalPlatform = result.labRoleDetail.Are_your_labs_part_of_national_platform__c;
					if(this.labsPartOfNationalPlatform == 'Yes')	this.showWhichNationalPlatform = true;
					this.whichNationalPlatform = result.labRoleDetail.Which_National_Platform__c;
					this.issueTestResultsSelection = result.labRoleDetail.Do_you_issue_test_results_for_all_lab__c;
					this.manageBookingSelection = result.labRoleDetail.Do_you_manage_booking_for_all_locations__c;
					this.airlinePartnershipSelection = result.labRoleDetail.Existing_partnership_with_airlines__c;
	
					if(this.labTypeSelection == 'IT Integrator' || this.labTypeSelection == 'Aggregator'){
						this.isAForm = true;
						this.isBForm = false;
					}else{
						this.isAForm = false;
						this.isBForm = true;
					}
					//FORM A
					this.operatingUnderBrand = result.labRoleDetail.Operating_under_brand__c;
					if(this.operatingUnderBrand == 'Yes')	this.showWhichBrand = true;
					this.whichBrands = result.labRoleDetail.Which_Operating_Brand__c;
					this.SLAInPlace = result.labRoleDetail.Type_of_SLAs_in_place__c;
					if(this.SLAInPlace == 'Yes')	this.showNatureOfSLA = true;
					this.NatureOfSLA = result.labRoleDetail.Nature_of_SLA__c;
					
					//FORM B
					this.typeOfLabSelection = result.labRoleDetail.Type_of_lab__c;
					this.AdditionalCertInPlace = result.labRoleDetail.Additional_certifications_in_place__c;
					if(this.AdditionalCertInPlace == 'Yes') this.showAdditionalCert = true;
					this.whichAdditionalCert = result.labRoleDetail.Additional_Certifications__c;
					this.endorsedByGovern = result.labRoleDetail.Endorsed_by_governments__c;
					if(this.endorsedByGovern == 'Yes')	this.showWhichGovern = true;
					this.whichGovern = result.labRoleDetail.Which_Governments__c;
					this.nationalAccreditationSelection = result.labRoleDetail.National_accreditation_for_all_the_labs__c;
	
	
					result.lsCountriesLab.forEach((item) => {
						this.lsCountriesLab.push({'Name' : item.CountryName__c , 'NumOfLabs': item.How_Many_Lab__c});
					});
					this.lsCountriesLab = [...this.lsCountriesLab];

					result.lsAirlineAgreement.forEach((item) => {
						this.lsAirlineAgreement.push({'Name' : item.Airline_Name__c});
					});
					this.lsAirlineAgreement = [...this.lsAirlineAgreement];
				}else
					alert('No result???');
			})

		}
	}
	
	approveApplication(event){
		this.updatePAR('Access Granted');
	}

	cancel(event){
		open(location, '_self').close();
	}

	denyApplication(event){
		this.updatePAR('Access Denied');
	}

	isCompleted = false;

	updatePAR(PARStatus){
		this.isLoading = true;
		ApproveDenyApplication({PARID: this.PAR.Id, st: PARStatus}).then(result => {
			let res = JSON.parse(JSON.stringify(result));
			if(res === true){
				alert('successfully saved');
			}
			else{
				alert('Error while saving');
			}
			this.isLoading = false;
			this.isCompleted = true;
		}).catch(error => {
			alert('exception!! ' + error);
			this.isLoading = false;
		});
		
	}

	@track isLoading;
	/*@wire(retrieveSavedData, {recordID:this.caseId}) wiredResult(result){
		alert(this.caseId);
		
	}*/
}