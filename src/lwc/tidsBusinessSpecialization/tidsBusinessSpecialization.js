import { LightningElement, track, wire } from 'lwc';
import { CurrentPageReference } from "lightning/navigation";
import { fireEvent, registerListener } from "c/tidsPubSub";
import {
	getSectionInfo,
	getUserType,
	sectionNavigation,
	sectionDecision,
	getFocusValues,
	getMainMarketSpecialization,
	getPrincipalDestinations,
	mappingSelectedValues,
	getApplicationType,
	displaySaveAndQuitButton,
	sum,
	getSectionRules,
	SECTION_CONFIRMED,
} from "c/tidsUserInfo";

export default class TidsBusinessSpecialization extends LightningElement {
	@wire(CurrentPageReference) pageRef;

	@track cmpName = "business-specialization";
	// Variable to say true or false if the user is in Vetting Mode
	@track vettingMode;
	// Variable to disable the Next Section button on the page
	@track disableButton;

	// Question label, picklist values and error for percentage breakdown
	@track percentageBreakdownQuestion =
		"What is the approximate % breakdown of your total annual sales for the following?";
	@track percentageBreakdownValues = [];
	@track percentageBreakdownError = {
		fieldLabel: this.percentageBreakdownQuestion,
		fieldName: "percentageBreakdown",
		show: false,
		description: ""
	};

	// Question label, picklist values and error for Market specialties
	@track marketSpecialtiesQuestion =
		"What are the 3 Market Specialties of your entity?";
	@track marketSpecialtiesValues = [];
	@track marketSpecialtiesError = {
		fieldLabel: this.marketSpecialtiesQuestion,
		fieldName: "marketSpecialties",
		show: false,
		description: ""
	};

	// Question label, picklist values and error for Destination specialties
	@track destinationSpecialtiesQuestion =
		"What are the 3 Destination Specialties of your entity?";
	@track destinationSpecialtiesValues = [];
	@track destinationSpecialtiesError = {
		fieldLabel: this.destinationSpecialtiesQuestion,
		fieldName: "destinationSpecialties",
		show: false,
		description: ""
	};

	// Variable to retrieve the information from TIDS Case Salesforce e.g data.json
	@track savedInfo;

	// Array to save the answers
	@track answers = {
		percentageBreakdown: {},
		marketSpecialties: {},
		destinationSpecialties: {},
	};

	// Vetting Modal - Errors
	@track sectionHasErrors = false;
	@track fieldErrorSelected = {};

	// Modal
	@track openModal = false;
	@track modalDefaultMessage = true;
	@track modalAction = "FIELD";

	// Vetting errors
	@track vettingErrorOptions = false;
	@track vettingErrors = [];
	
	// New branch
	@track showSaveAndQuitButton = false;

	// Section fields rules
	@track marketSpecialtiesRules = {
		visible: false,
		required: false,
		disabled: false
	}

	@track destinationSpecialtiesRules = {
		visible: false,
		required: false,
		disabled: false
	}

	@track percentageBreakdownRules = {
		visible: false,
		required: false,
		disabled: false
	}

	// Const variable API name
	MARKET_SPECIALTIES = 'marketSpecialties';
	DESTINATION_SPECIALTIES = 'destinationSpecialties';
	PERCENTAGE_BREAKDOWN = 'percentageBreakdown';

	// Disable Next Section button when all the fields are not required
	@track hasFieldsToValidate;

	@track reportErrorButtonDisabled;

	connectedCallback() {
		// Vetting menu
		registerListener("vettingMenuListener", this.vettingMenuListener, this);
		// Vetting modal listener
		registerListener("modalProceedListener", this.modalProceedListener, this);
		registerListener("modalCloseListener", this.modalCloseListener, this);
		registerListener(
			"modalDeleteAllErrorsListener",
			this.modalDeleteAllErrorsListener,
			this
		);

		registerListener("percentageListener", this.percentageListener, this);
		registerListener("badgeListener", this.badgeListener, this);
		
		this.reportErrorButtonDisabled = true;
		
		let sectionRules = getSectionRules(this.cmpName);
		this.mappingRules(sectionRules);

		let userType = getUserType();
		this.vettingMode = userType === "vetting" ? true : false;
		this.disableButton = true;
		this.savedInfo = getSectionInfo(this.cmpName);
		
		this.percentageBreakdownValues = getFocusValues();
		this.destinationSpecialtiesValues = getPrincipalDestinations();
		this.marketSpecialtiesValues = getMainMarketSpecialization();

		this.init();
	}

	mappingRules(sectionRules) {
		sectionRules.forEach(element => {
			if(this.hasFieldsToValidate === undefined && element.required){
				this.hasFieldsToValidate = true;
			}
			switch(element.apiName) {
				case this.MARKET_SPECIALTIES:
					this.marketSpecialtiesRules = element;
					break;
				case this.DESTINATION_SPECIALTIES:
					this.destinationSpecialtiesRules = element;
					break;
				case this.PERCENTAGE_BREAKDOWN:
					this.percentageBreakdownRules = element;
					break;
				default: break;
			}
		});
	}

	init() {
		if (this.savedInfo) {
			let info = JSON.parse(JSON.stringify(this.savedInfo));
			this.mainActivitiesLoaded = false;
			// eslint-disable-next-line guard-for-in
			for(let index in info.values){
				this.reloadInfo(info.values[index]);
				info.values[index].valid = true;
				this.addAnswer(info.values[index]);
			}

			if (
				this.vettingMode &&
				this.savedInfo.errors !== undefined &&
				this.savedInfo.errors &&
				this.savedInfo.errors.length > 0
			) {
				let er = JSON.parse(JSON.stringify(this.savedInfo.errors));
				er.forEach(error => {
					this.updateinfoErrors(error);
				});
				this.vettingErrorOptions = true;
				this.sectionHasErrors = this.noFormErrors();
				this.notifySectionHasError();
			}
		}
		this.showSaveAndQuitButton = displaySaveAndQuitButton({payload:{applicationType: getApplicationType()}});
	}

	notifySectionHasError() {
		// eslint-disable-next-line @lwc/lwc/no-async-operation
		setTimeout(
			() => {
				fireEvent(this.pageRef, "sectionErrorListener", this.sectionHasErrors);
			},
			1,
			this
		);
	}

	// Method to reload the information from TIDS Case Salesforce
	reloadInfo(item) {
		switch (item.fieldName) {
			case "percentageBreakdown":
				item.values.forEach(i => {
					i.id = i.id ? Number(i.id) : null;
					i.value = i.value ? Number(i.value) : null;
					i.isSelected = i.isSelected === 'true' ? true : false;
				});
				this.percentageBreakdownValues = item.values;
				break;
			case "marketSpecialties":
				this.marketSpecialtiesValues = mappingSelectedValues(
					this.marketSpecialtiesValues,
					item.values
				);
				break;
			case "destinationSpecialties":
				this.destinationSpecialtiesValues = mappingSelectedValues(
					this.destinationSpecialtiesValues,
					item.values
				);
				break;
			default:
				break;
		}
	}

	// Method to add the answer selected by the user
	addAnswer(props) {
		switch(props.fieldName) {
			case 'percentageBreakdown':
				this.answers.percentageBreakdown = {
					fieldName: props.fieldName, 
					values: props.values
				}
				break;
			case 'marketSpecialties':
				this.answers.marketSpecialties = {
					fieldName: props.fieldName, 
					values: props.values
				}
				break;
			case 'destinationSpecialties':
				this.answers.destinationSpecialties = {
					fieldName: props.fieldName, 
					values: props.values
				}
				break;
			default: break;
		}

		this.nextButtonDisabled();
	}

	// Fields validation
	percentageBreakdownValid() {
		let isValid = false;
		let {percentageBreakdown} = this.answers;
		let pBreakdown = JSON.parse(JSON.stringify(percentageBreakdown));
		if(Object.keys(pBreakdown).length > 0) {
			let total = sum(pBreakdown);
			isValid = total === 100 ? true : false;
		}
		return isValid;
	}

	marketSpecialtiesValid(){
		let m=this.answers.marketSpecialties;
		if (m==undefined) return false;
		if (m.values==undefined) return false;
		let l=m.values.length;
		return (l>0);
	}

	destinationSpecialtiesValid() {
		let d=this.answers.destinationSpecialties;
		if (d==undefined) return false;
		if (d.values==undefined) return false;
		let l=d.values.length;
		return (l>0);
	}
	
	fieldsValidation() {
		let result = true;
		if(this.percentageBreakdownRules.required) {
			result = result && this.percentageBreakdownValid();
		}

		if(this.marketSpecialtiesRules.required) {
			result = result && this.marketSpecialtiesValid();
		}

		if(this.destinationSpecialtiesRules.required) {
			result = result && this.destinationSpecialtiesValid();
		}
		return result;
	}

	// Method to handle the behavior when the Next Section button had to be Disabled for the user
	nextButtonDisabled() {
		let isFormValid = this.fieldsValidation();
		this.disableButton = !isFormValid;
		return isFormValid;
	}

	updateinfoErrors(props) {
		switch (props.fieldName) {
			case "percentageBreakdown":
				this.percentageBreakdownError = props;
				break;
			case "marketSpecialties":
				this.marketSpecialtiesError = props;
				break;
			case "destinationSpecialties":
				this.destinationSpecialtiesError = props;
				break;
			default:
				break;
		}
	}

	noFormErrors() {
		let percentageBreakdownValid =
			this.percentageBreakdownError.show &&
			this.percentageBreakdownError.description !== ""
				? true
				: false;
		let marketSpecialtiesValid =
			this.marketSpecialtiesError.show &&
			this.marketSpecialtiesError.description !== ""
				? true
				: false;
		let destinationSpecialtiesValid =
			this.destinationSpecialtiesError.show &&
			this.destinationSpecialtiesError.description !== ""
				? true
				: false;

		let result =
			percentageBreakdownValid ||
			marketSpecialtiesValid ||
			destinationSpecialtiesValid;
		this.reportErrorButtonDisabled = result ? false : true;
		return result;
	}

	// Next section button
	handleNextSection(event) {
		event.preventDefault();
		if (this.nextButtonDisabled()) {
			let businessSpecializationValues = this.infoToBeSave();
			window.scrollTo(0,0);
			fireEvent(this.pageRef, "tidsUserInfoUpdate", businessSpecializationValues);
		}
	}

	// Section business logic Save
	infoToBeSave() {
		let sectionNav = JSON.parse(
			JSON.stringify(sectionNavigation(this.cmpName))
		);

		let cAnswers = this.answers;

		if(this.percentageBreakdownRules.required) {
			if (Object.keys(cAnswers.percentageBreakdown).length > 0) {
				cAnswers.percentageBreakdown.values.forEach(i => {
					i.id = i.id ? i.id.toString() : null;
					i.value = i.value ? i.value.toString() : null;
					i.isSelected = i.isSelected ? 'true' : 'false';
				});
			}
		}
		
		let businessSpecializationValues = {
			cmpName: this.cmpName,
			target: sectionNav.next,
			sectionDecision: sectionDecision(this.sectionHasErrors),
			values: cAnswers,
			vettingErrors: this.vettingErrors
		};
		return businessSpecializationValues;
	}

	handleSaveAndQuit(event) {
		event.preventDefault();
		let option = event.target.dataset.next;
		let businessSpecializationValues = this.infoToBeSave();
		businessSpecializationValues.target = option;
		businessSpecializationValues.action = 'SaveAndQuit';
		fireEvent(this.pageRef, "tidsUserInfoUpdate", businessSpecializationValues);
	}

	handleProceed(event) {
		event.preventDefault();
		let option = event.target.dataset.name;

		let businessSpecializationValues;

		if (option === "report-errors-and-proceed") {
			this.updateErrors();
			businessSpecializationValues = this.infoToBeSave();
		} else if (option === "confirm-review-status") {
			businessSpecializationValues = this.infoToBeSave();
			businessSpecializationValues.sectionDecision = SECTION_CONFIRMED;
		}

		fireEvent(this.pageRef, "tidsUserInfoUpdate", businessSpecializationValues);
	}

	updateErrors() {
		if (this.percentageBreakdownError.show && this.percentageBreakdownError.description !== "") {
			this.addVettingError(this.percentageBreakdownError);
		}

		if (
			this.marketSpecialtiesError.show &&
			this.marketSpecialtiesError.description !== ""
		) {
			this.addVettingError(this.marketSpecialtiesError);
		}

		if (
			this.destinationSpecialtiesError.show &&
			this.destinationSpecialtiesError.description !== ""
		) {
			this.addVettingError(this.destinationSpecialtiesError);
		}

	}

	addVettingError(props) {
		let index = this.vettingErrors.findIndex(
			error => error.fieldName === props.fieldName
		);
		if (index === -1) {
			this.vettingErrors.push(props);
		} else {
			this.vettingErrors.splice(index, 1);
			this.vettingErrors.push(props);
		}
	}

	// Vetting errors
	handleError(event) {
		event.preventDefault();
		let errorField = event.target.dataset.name;
		this.modalAction = "FIELD";
		switch (errorField) {
			case "error-percentage-breakdown":
				if (
					this.percentageBreakdownError.show &&
					this.percentageBreakdownError.description !== ""
				) {
					this.fieldErrorSelected = this.percentageBreakdownError;
					this.modalDefaultMessage = false;
					this.openModal = true;
				} else {
					this.percentageBreakdownError.show = !this.percentageBreakdownError
						.show;
				}
				break;
			case "error-market-specialties":
				if (
					this.marketSpecialtiesError.show &&
					this.marketSpecialtiesError.description !== ""
				) {
					this.fieldErrorSelected = this.marketSpecialtiesError;
					this.modalDefaultMessage = false;
					this.openModal = true;
				} else {
					this.marketSpecialtiesError.show = !this.marketSpecialtiesError.show;
				}
				break;
			case "error-destination-specialties":
				if (
					this.destinationSpecialtiesError.show &&
					this.destinationSpecialtiesError.description !== ""
				) {
					this.fieldErrorSelected = this.destinationSpecialtiesError;
					this.modalDefaultMessage = false;
					this.openModal = true;
				} else {
					this.destinationSpecialtiesError.show = !this
						.destinationSpecialtiesError.show;
				}
				break;
			default:
				break;
		}
	}

	changeErrorFields(event) {
		let field = event.target.dataset.name;
		this.modalAction = "FIELD";
		switch (field) {
			case "error-percentage-breakdown-desc":
				this.percentageBreakdownError.description = event.target.value;
				break;
			case "error-market-specialties-desc":
				this.marketSpecialtiesError.description = event.target.value;
				break;
			case "error-destination-specialties-desc":
				this.destinationSpecialtiesError.description = event.target.value;
				break;
			default:
				break;
		}
		this.sectionHasErrors = this.noFormErrors();
	}

	// Component Listeners
	vettingMenuListener(props) {
		this.modalAction = "ALL";
		if (this.sectionHasErrors) {
			this.modalDefaultMessage = true;
			this.openModal = true;
		} else {
			this.openModal = false;
			this.vettingErrorOptions = props;
		}
	}

	percentageListener(props) {
		this.addAnswer(props);
	}

	badgeListener(props) {
		this.addAnswer(props);
	}

	// Modal Listeners
	modalProceedListener(props) {
		this.updateinfoErrors(props);
		this.sectionHasErrors = this.noFormErrors();
		this.openModal = false;
	}

	modalCloseListener(props) {
		this.openModal = props;
		if (this.modalAction === "ALL") {
			fireEvent(this.pageRef, "sectionErrorListener", true);
		}
	}

	modalDeleteAllErrorsListener() {
		// Reset Error Values
		this.percentageBreakdownError.show = false;
		this.percentageBreakdownError.description = "";
		this.marketSpecialtiesError.show = false;
		this.marketSpecialtiesError.description = "";
		this.destinationSpecialtiesError.show = false;
		this.destinationSpecialtiesError.description = "";

		this.sectionHasErrors = this.noFormErrors();
		this.vettingErrorOptions = this.noFormErrors();
		this.openModal = false;

		fireEvent(this.pageRef, "sectionErrorListener", false);
	}

}