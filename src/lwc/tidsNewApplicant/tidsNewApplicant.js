import { LightningElement, track, wire, api } from "lwc";
// TIDS_Controller (Apex Class) - get the countries list
import getCountries from "@salesforce/apex/TIDSHelper.getCountry";
import companyNameUnique from "@salesforce/apex/TIDSHelper.companyNameUnique";
// Pubsub pattern
import { CurrentPageReference,NavigationMixin } from "lightning/navigation";
import { fireEvent, registerListener } from "c/tidsPubSub";
// TIDS Configuration/Data Object
import {
	getLocationType,
	getSectionInfo,
	getUserType,
	sectionNavigation,
	sectionDecision,
	getApplicationType,
	displaySaveAndQuitButton,
	getSfTidsInfo,
	specialCharsValidation,
	getSectionRules,
	SECTION_CONFIRMED,
  	CHG_NAME_COMPANY
} from "c/tidsUserInfo";

export default class TidsNewApplicant extends NavigationMixin(LightningElement){
	@wire(CurrentPageReference) pageRef;

	// Welcome / New Applicant component behaviour
	@track cmpName = "new-applicant";
	@api tidsUserInfo;
	@api disableButton;

	@track countrySelected={};
	@track showConfimationModal = false;
	@track isSpecialCharacters = false;

	// Welcome / New Applicant form fields
	@api accountInfo;
	@api companyLegalName;
	@api country;
	// Const field API name
	COMPANY_LEGAL_NAME = 'companyLegalName';
	COUNTRY = 'country';

	// Fields counter
	@track companyLegalNameCounter = 0;
	@track companyLegalNameMaxLength = 90
	
	@api get companyLegalNameCounter(){
		return this.companyLegalName.length;
	}
	// Welcome / New Applicant form values e.g picklist
	@track countries = [];

	// Init Vetting errors configuration/objects
	@track sectionHasErrors = false;
	@track fieldErrorSelected={};
	@track vettingErrorOptions = false;
	@track vettingErrors = [];
	@track vettingMode = false;
	
	@track vettingOption = null;

	// Modal
	@track openModal = false;
	@track modalDefaultMessage = true;
	@track modalAction = "FIELD";

	// Application type
	@track applicationType = getApplicationType();

	@track companyLegalNameError={
		fieldLabel: "Company Legal Name",
		fieldName: "companyLegalName",
		show: false,
		description: ""
	};
	// End Init Vetting errors configuration/objects
	@track showDeduplication=false;
	// Apex calls
	@wire(getCountries) countriesCallback({ error, data }){
		if (data){
			this.countries = data;
		}
	}

	// Section fields rules
	@track companyLegalNameRules={
		visible: true,
		disabled: false,
		required: false,
		regex:'',
		name:'',
		translation_english:'',
		translation_japanese:'',
		translation_spanish:'',
		translation_portuguese:'',
		translation_french:'',
		translation_chinese:''
	};

	@track countryRules={
		visible: true,
		disabled: false,
		required: false,
		regex:'',
		name:'',
		translation_english:'',
		translation_japanese:'',
		translation_spanish:'',
		translation_portuguese:'',
		translation_french:'',
		translation_chinese:''
	};

	// Disable report errors and proceed
	@track reportErrorButtonDisabled;

	// Display confirmation modal Account duplicated
	@track openVettingConfirmationModal;
	// Action const vetting button Report Errors And Proceed 
	VETTING_ACTION_REPORT_ERROR_PROCEED = 'report-errors-and-proceed';
	// Action const vetting button Report Errors And Proceed 
	VETTING_ACTION_CONFIRM_REVIEW_PROCEED = 'confirm-review-status';
	// Vetting action clicked e.g button Confirm Review and Proceed or Report Errors and Proceed
	@track vettingAction = null;
	// Report Changes
	@track companyLegalNameChanges={
		display: false,
		sfValue: null
	};

	@track countryChanges={
		display: false,
		sfValue: null
	};

	@track previousCompanyLegalName = null;

	connectedCallback(){
		// Vetting menu listener
		registerListener("vettingMenuListener", this.vettingMenuListener, this);
		// Vetting modal listener
		registerListener("modalProceedListener", this.modalProceedListener, this);
		registerListener("modalCloseListener", this.modalCloseListener, this);
		registerListener(
			"modalDeleteAllErrorsListener",
			this.modalDeleteAllErrorsListener,
			this
		);
		
		this.reportErrorButtonDisabled = true;
		let sectionRules = getSectionRules(this.cmpName);
		
		sectionRules.forEach(element => {
			switch(element.apiName){
				case this.COMPANY_LEGAL_NAME:
					this.companyLegalNameRules = element;
					break;
				case this.COUNTRY:
					this.countryRules = element;
					break;
				default: break;
			}
		});

		this.init();
		this.setFormText();
	}

	@track istext1=false
	@track istext2=false;

	setFormText() {
		let type = getLocationType();
		let apptype=getApplicationType();
		this.istext1=true;
		this.istext2=false;
		
		if (apptype=== CHG_NAME_COMPANY){
		  	if (type==='HO') {
				this.istext1=false;
				this.istext2=true;
		  	}
		}
	}

	init(){
		// Disable the Next section button
		this.disableButton = true;
		// Confirmation vetting modal init
		this.openVettingConfirmationModal = false;

		let userType = getUserType();
		this.vettingMode = userType === "vetting" ? true : false;
		// Get the information saved for this section coming from JSON
		this.accountInfo=getSectionInfo('account-info');
		let savedInfo = getSectionInfo(this.cmpName);
		if (savedInfo){
			// Mapping saved information into form fields
			this.companyLegalName = savedInfo.values.companyLegalName;
			this.previousCompanyLegalName = savedInfo.values.companyLegalName;
			this.fieldsCounter();
			this.country = savedInfo.values.countryIsoCode;
			this.countrySelected = this.countries.find(
				country => country.value === this.country
			);
			// Report Changes
			this.reportChanges();
			// If the form has errors and it is on vetting mode loading
			if (
				this.vettingMode &&
				savedInfo.errors !== undefined &&
				savedInfo.errors &&
				savedInfo.errors.length > 0
			){
				let er = JSON.parse(JSON.stringify(savedInfo.errors));
				er.forEach(el => {
					if (el.fieldName === "companyLegalName"){
						this.companyLegalNameError = el;
					}
				});
				this.vettingErrorOptions = true;
				this.sectionHasErrors = this.noFormErrors();
				this.notifySectionHasError();
			}
			this.nextButtonDisabled();
		}

	}

	reportChanges(){
		if(this.applicationType === CHG_NAME_COMPANY && this.vettingMode){
			let sfInfo = getSfTidsInfo();
			if(sfInfo.name !== this.companyLegalName){
				this.companyLegalNameChanges.display = true;
				this.companyLegalNameChanges.sfValue = sfInfo.name;
			}

			if(sfInfo.country.value !== this.countrySelected.value){
				let previousCountrySelected = this.countries.find(
					country => country.value === sfInfo.country.value
				);
				this.countryChanges.display = true;
				this.countryChanges.sfValue = previousCountrySelected.label;
			}
		}
	}

	notifySectionHasError(){
		// eslint-disable-next-line @lwc/lwc/no-async-operation
		setTimeout(
			() => {
				fireEvent(this.pageRef, "sectionErrorListener", this.sectionHasErrors);
			},
			1,
			this
		);
	}

	vettingMenuListener(props){
		this.modalAction = "ALL";
		if (this.sectionHasErrors){
			this.modalDefaultMessage = true;
			this.openModal = true;
		}else{
			this.openModal = false;
			this.vettingErrorOptions = props;
		}
	}

	changeField(event){
		this.isSpecialCharacters = this.charsValidation(event);

		if (event.target.name === "companyLegalName"){
			this.companyLegalName = event.target.value;
			this.fieldsCounter();
		}
		
		if(this.isSpecialCharacters){
			this.disableButton = true;
		}else{
			this.nextButtonDisabled();
		}

	}

	fieldsCounter(){
		this.companyLegalNameCounter = this.companyLegalName ? this.companyLegalName.length : 0;
	}

	charsValidation(event){
		let value = event.target.value;
		return specialCharsValidation(value);
	}

	handleChange(event){
		this.country = event.detail.value;
		this.nextButtonDisabled();
	}

	handleNextSection(event){
		event.preventDefault();
		this.countrySelected = this.countries.find(
			country => country.value === this.country
		);
		this.showConfimationModal = true;
	}
	
	companyLegalNameValidation(){
		let isValid = false;
		let cmpField = this.template.querySelector("[data-name='"+this.COMPANY_LEGAL_NAME+"']");
		if(this.companyLegalNameRules.required && cmpField){
			isValid = cmpField.validity.valid;
		} else if(this.companyLegalNameRules.required && this.companyLegalName){
			isValid = true;
		}
		return isValid;
	}

	countryValidation(){
		let isValid = false;
		let cmpField = this.template.querySelector("[data-name='"+this.COUNTRY+"']");
		if(this.countryRules.required && cmpField){
			isValid = cmpField.validity.valid;
		} else if(this.countryRules.required && this.country){
			isValid = true;
		}
		return isValid;
	}

	fieldsValidation(){
		let result = true;
		if(this.companyLegalNameRules.required){
			result = result && this.companyLegalNameValidation();
		}

		if(this.countryRules.required){
			result = result && this.countryValidation();
		}

		return result;
	}

	nextButtonDisabled(){
		this.disableButton = this.fieldsValidation() ? false : true;
	}

	handleError(event){
		event.preventDefault();
		let errorField = event.target.dataset.name;
		this.modalAction = "FIELD";

		switch (errorField){
			case "error-companylegal":
				if (
					this.companyLegalNameError.show &&
					this.companyLegalNameError.description !== ""
				){
					this.fieldErrorSelected = this.companyLegalNameError;
					this.modalDefaultMessage = false;
					this.openModal = true;
				}else{
					this.companyLegalNameError.show = !this.companyLegalNameError.show;
				}
				break;
			default:
				break;
		}
	}

	changeErrorFields(event){
		let field = event.target.dataset.name;
		this.modalAction = "FIELD";
		switch (field){
			case "error-companylegalname-desc":
				this.companyLegalNameError.show=true;
				this.companyLegalNameError.description = event.target.value;
				break;
			default:
				break;
		}
		this.sectionHasErrors = this.noFormErrors();
	}

	/**
	 * Vetting duplicate account confirmation modal
	*/
	handleVettingAction(event){
		event.preventDefault();
		this.vettingAction = event.target.dataset.name;
		this.vettingOption = event.target.dataset.name;
		
		let vettingPayload={
		action: "VETTING_DUPLICATE",
		type: this.applicationType
		}
		this.duplicateAccountValidation(vettingPayload); 
	}
	
	/**
	 * payload={
	 *  action: "VALIDATE",
	 *  type: application-type,
	 *  values: response from salesforce
	 * }
	 */
	extractAccountId(){
		if (this.accountInfo!=undefined){
			 if (this.accountInfo.userInfo.tidsAccount.Id!=undefined){
				return this.accountInfo.userInfo.tidsAccount.Id;
			 }
		}
		return '';
	}
	duplicateAccountValidation(payload){
		if(this.companyLegalName !== this.previousCompanyLegalName){
			companyNameUnique({
				accounid: this.extractAccountId(),
				companyName: this.companyLegalName,
				countryIsoCode: this.countrySelected.value
			})
			.then(result => {
				payload.values = JSON.parse(JSON.stringify(result));
				this.duplicateAccountValidationCallback(payload);
			})
			.catch(error => {
				console.log('error',JSON.stringify(error));
			});
		} else if(this.vettingOption === "confirm-review-status"){
				this.handleConfirmReviewAndProceed();
				this.vettingOption = null;
		}else{
			let newApplicantValues = this.applicantToSave(event);
			fireEvent(this.pageRef, "tidsUserInfoUpdate", newApplicantValues);
		}
	}
	//Condition 8
	duplicateAccountValidationCallback(payload){
		switch(payload.action){
			case "VETTING_DUPLICATE":
				this.vettingDuplicateAccountValidation(payload.values);
				break;
			case "CLIENT_DUPLICATE":
				this.clientDuplicateAccountValidation(payload.values);
				break;
			default: 
				break;
		}
	}

	vettingDuplicateAccountValidation(duplicateAccount){
		if (duplicateAccount.hasAnError){
			this.openVettingConfirmationModal = true;
			return;
		}else{
			this.vettingActionProceed();
		}
	}

	clientDuplicateAccountValidation(duplicateAccount){
		if (duplicateAccount.hasAnError){
			fireEvent(this.pageRef,"duplicateAccountListener",duplicateAccount);
		} else if(duplicateAccount.hasReinstatementDeadline){
			fireEvent(this.pageRef,"duplicateAccountListener",duplicateAccount);
		}else{
			let newApplicantValues = this.applicantToSave(event);
			if(this.vettingOption === "confirm-review-status"){
				newApplicantValues.sectionDecision = SECTION_CONFIRMED;
				this.vettingOption = null;
			}
			fireEvent(this.pageRef, "tidsUserInfoUpdate", newApplicantValues);
		}
	}

	// Type of the Action clicked by the user on Vetting mode
	vettingActionProceed(){
		switch(this.vettingAction){
			case this.VETTING_ACTION_CONFIRM_REVIEW_PROCEED:
				this.handleConfirmReviewAndProceed();
				break;
			case this.VETTING_ACTION_REPORT_ERROR_PROCEED:
				this.handleReportErrorsAndProceed();
				break;
			default: 
				break;
		}
	}
	
	// TIDS Vetting Confirm Review and proceed business logic
	handleConfirmReviewAndProceed(){
		let newApplicantValues = this.applicantToSave();
		this.saveApplicantInformation(newApplicantValues);
		newApplicantValues.sectionDecision = SECTION_CONFIRMED;
		this.saveApplicantInformation(newApplicantValues);
	}

	// TIDS Vetting Report Errors and proceed business logic
	handleReportErrorsAndProceed(){
		this.applicantErrors();
		let newApplicantValues = this.applicantToSave();
		this.saveApplicantInformation(newApplicantValues);
	}

	// Insert or Update information in Salesforce Case as a JSON attachment
	saveApplicantInformation(values){
		fireEvent(this.pageRef, "tidsUserInfoUpdate", values);
	}

	applicantToSave(){
		this.applicantErrors();
		let countrySelected = this.countries.find(
			country => country.value === this.country
		);

		let sectionNav = JSON.parse(
			JSON.stringify(sectionNavigation(this.cmpName))
		);

		let applicantValues={
			cmpName: this.cmpName,
			target: sectionNav.next,
			sectionDecision: sectionDecision(this.sectionHasErrors),
			values: {
				companyLegalName: this.companyLegalName,
				countryName: countrySelected.label,
				countryIsoCode: countrySelected.value,
				countryId: countrySelected.Id
			},
			vettingErrors: this.vettingErrors
		};
		return applicantValues;
	}

	applicantErrors(){
		if (this.companyLegalNameError.show &&
			this.companyLegalNameError.description !== ""){
			this.addVettingError(this.companyLegalNameError);
		}
	}

	noFormErrors(){
		let companyLegalNameValid = false;
		if(this.companyLegalNameError.show && this.companyLegalNameError.description !== ""){
			companyLegalNameValid = true;
		}
		this.reportErrorButtonDisabled = !companyLegalNameValid;
		return companyLegalNameValid;
	}

	addVettingError(props){
		let index = this.vettingErrors.findIndex(
			error => error.fieldName === props.fieldName
		);
		if (index === -1){
			this.vettingErrors.push(props);
		}else{
			this.vettingErrors.splice(index, 1);
			this.vettingErrors.push(props);
		}
	}

	// Modal Listeners
	modalProceedListener(props){
		switch (props.fieldName){
			case "companyLegalName":
				this.companyLegalNameError = props;
				break;
			default:
				break;
		}
		this.sectionHasErrors = this.noFormErrors();
		this.openModal = false;
	}

	modalCloseListener(props){
		this.openModal = props;
		if (this.modalAction === "ALL"){
			fireEvent(this.pageRef, "sectionErrorListener", true);
		}
	}

	modalDeleteAllErrorsListener(props){
		this.companyLegalNameError.show = false;
		this.companyLegalNameError.description = "";

		this.sectionHasErrors = this.noFormErrors();
		this.vettingErrorOptions = this.noFormErrors();
		this.openModal = false;
		fireEvent(this.pageRef, "sectionErrorListener", false);
	}

	handleReviewInformation(event){
		event.preventDefault();
		this.showConfimationModal = false;
	}

	handleConfirmationInformation(event){
		event.preventDefault();
		this.showDeduplication=false;
		const allValid = [
			...this.template.querySelectorAll(
				"[data-name='companyLegalName'],[data-name='country']"
			)
		].reduce((validSoFar, inputCmp) => {
			inputCmp.reportValidity();
			return validSoFar && inputCmp.checkValidity();
		}, true);
		if (allValid){
			if(this.companyLegalName!==this.previousCompanyLegalName){
				companyNameUnique({
					accountid: this.extractAccountId(),
					companyName: this.companyLegalName,
					countryIsoCode: this.countrySelected.value
				})
				.then(result => {
					if (result.hasAnError){
						let clientPayload={
						action: "CLIENT_DUPLICATE",
						type: this.applicationType,
						values:result
						};
						this.showDeduplication=true;
						this.template.querySelector('[id|="confirmation-data"]:not([id|="confirmation-data-vetting"]) + footer').className +=' error';
						if (this.applicationType != CHG_NAME_COMPANY){
							this.duplicateAccountValidationCallback(clientPayload);
						}
					}else{
						this.proceedSave();
					}          
				})
				.catch(error => {
					this.showConfimationModal = false;
					console.log('error',JSON.stringify(error));
				});
			}else{
				this.proceedSave();
			}
		}
	}
	proceedSave(){
		this.showConfimationModal = false;
		let newApplicantValues = this.applicantToSave(event);
		if(this.vettingOption === "confirm-review-status"){
			newApplicantValues.sectionDecision = SECTION_CONFIRMED;
			this.vettingOption = null;
		}
		fireEvent(this.pageRef, "tidsUserInfoUpdate", newApplicantValues);
	}
	handleOk(event){
		// event.preventDefault();
		this.showDeduplication=false;
		this[NavigationMixin.Navigate]({
			type: 'standard__namedPage',
			attributes: {
					pageName: 'tids'
			},
		});
	}
	handleVettingConfirmation(event){
		event.preventDefault();
		this.openVettingConfirmationModal = false;
	}
}