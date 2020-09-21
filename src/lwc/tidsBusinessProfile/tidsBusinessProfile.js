import { LightningElement, track, api, wire } from "lwc";
import { CurrentPageReference } from "lightning/navigation";
import { fireEvent, registerListener } from "c/tidsPubSub";

import {
	getSectionInfo,
	getUserType,
	sectionNavigation,
	sectionDecision,
	getMainActivities,
	getSalesVolume,
	getGDSValues,
	SECTION_CONFIRMED,
	getNumberOfEmployees,
	getApplicationType,
	sum,
	getSectionRules,
	displaySaveAndQuitButton
} from "c/tidsUserInfo";

export default class TidsBusinessProfile extends LightningElement {
	@wire(CurrentPageReference) pageRef;

	@api tidsUserInfo;
	@api value;
	@track cmpName = "business-profile";

	@track vettingMode;
	@track disableButton;

	@track salesMixQuestion = "Online / Offline Sales Mix";
	@track salesMixValues = [
		{ label: "Online", value: null },
		{ label: "Offline", value: null }
	];

	@track principalActivityQuestion =
		"What is the principal activity of your agency? (Select 1)";
	@track principalActivityValues = [];

	@track marketFocusQuestion =
		"Market Focus: Indicate the approximate % of your Leisure and Corporate business.";
	@track marketFocusValues = [
		{ label: "Leisure", value: null },
		{ label: "Corporate", value: null }
	];

	@track gdsQuestion = 'Which Global Distribution Systems (GDSs) do you primarily use? (Select up to 4)';
	@track gdsValues = [];

	@track numberEmployeesQuestion = 'Number of Employees at the office applying for TIDS';
	@track numberEmployeesSelected;
	@track numberEmployeesValues = [];

	@track numberOfficesQuestion = 'Number of Offices your agency has in ';
	@track numberOfficesValue;

	@track travelSalesQuestion = "What is your agency's annual sales volume?";
	@track travelSalesSelected;
	@track travelSalesValues = [];
	
	@track answers = {
		principalActivities: {},
		marketFocus: {},
		salesMix: {},
		travelSales: {},
		GDS: {},
		numberEmployees: {},
		numberOffices: {}
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

	@track salesMixError = {
		fieldLabel: this.salesMixQuestion,
		fieldName: "salesMix",
		show: false,
		description: ""
	};

	@track principalActivitiesError = {
		fieldLabel: this.principalActivityQuestion,
		fieldName: "principalActivities",
		show: false,
		description: ""
	};

	@track marketFocusError = {
		fieldLabel: this.marketFocusQuestion,
		fieldName: "marketFocus",
		show: false,
		description: ""
	};

	@track travelSalesError = {
		fieldLabel: this.travelSalesQuestion,
		fieldName: "travelSales",
		show: false,
		description: ""
	};

	@track gdsError = {
		fieldLabel: this.gdsQuestion,
		fieldName: "GDS",
		show: false,
		description: ""
	};

	@track numberEmployeesError = {
		fieldLabel: this.numberEmployeesQuestion,
		fieldName: "numberEmployees",
		show: false,
		description: ""
	};

	@track numberOfficesError = {
		fieldLabel: this.numberOfficesQuestion,
		fieldName: "numberOffices",
		show: false,
		description: ""
	};

	@track savedInfo;

	// TIDS Branch Application
	@track showSaveAndQuitButton = false;
	@track applicationType = null;

	// Section field rules
	@track numberEmployeesRules = {
		visible: false,
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
	}

	@track numberOfficesRules = {
		visible: false,
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
	}

	@track gdsRules = {
		visible: false,
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
	}

	@track principalActivitiesRules = {
		visible: false,
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
	}

	@track marketFocusRules = {
		visible: false,
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
	}

	@track salesMixRules = {
		visible: false,
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
	}

	@track travelSalesRules = {
		visible: false,
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
	}

	NUMBER_EMPLOYEES = 'numberEmployeesSelected';
	NUMBER_OFFICES = 'numberOfficesValue';
	GDS = 'GDS';
	PRINCIPAL_ACTIVITIES = 'principalActivities';
	MARKET_FOCUS = 'marketFocus';
	SALES_MIX = 'salesMix';
	TRAVEL_SALES = 'travelSales';

	@track reportErrorButtonDisabled;
	
	@track hasFieldsToValidate;

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
		// Get Welcome information to get country
		let welcomeSectionInfo = getSectionInfo('new-applicant');
		this.numberOfficesQuestion += 'Canada';//welcomeSectionInfo.values.countryName;

		this.principalActivityValues = getMainActivities();
		this.travelSalesValues = getSalesVolume();
		this.gdsValues = getGDSValues();
		this.numberEmployeesValues = getNumberOfEmployees();

		this.init();
	}
	

	mappingRules(sectionRules) {
		console.log('mappingRules:sectionRules',JSON.stringify(sectionRules));
		sectionRules.forEach(element => {
			if(this.hasFieldsToValidate === undefined && element.required){
				this.hasFieldsToValidate = true;
			}
			switch(element.apiName) {
				case this.NUMBER_EMPLOYEES:
					this.numberEmployeesRules = element;
					break;
				case this.NUMBER_OFFICES:
					this.numberOfficesRules = element;
					break;
				case this.GDS:
					this.gdsRules = element;
					break;
				case this.PRINCIPAL_ACTIVITIES:
					this.principalActivitiesRules = element;
					break;
				case this.MARKET_FOCUS:
					this.marketFocusRules = element;
					break;
				case this.SALES_MIX:
					this.salesMixRules = element;
					break;
				case this.TRAVEL_SALES:
					this.travelSalesRules = element;
					break;
				default: break;
			}
		});
	}

	init() {

		this.applicationType = getApplicationType();

		if(this.applicationType === 'NEW_BR') {
			let action = {
				payload: {
					cmpName: this.cmpName
				}
			}
		}

		if (this.savedInfo) {
			let info = JSON.parse(JSON.stringify(this.savedInfo));
			this.mainActivitiesLoaded = false;
			// eslint-disable-next-line guard-for-in
			for(let index in info.values){
				if(info.values[index]) {
					this.reloadInfo(info.values[index]);
					info.values[index].valid = true;
					this.addAnswer(info.values[index]);
				}
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
		this.showSaveAndQuitButton = displaySaveAndQuitButton({payload:{applicationType: this.applicationType}});
	}

	reloadInfo(item) {
		if(item){
			switch (item.fieldName) {
				case "salesMix":
					item.values.forEach(i => {
						i.value = i.value ? Number(i.value) : null;
					});
					this.salesMixValues = item.values;
					break;
				case "principalActivities":
					this.principalActivityValues = this.mappingSelectedValues(
						this.principalActivityValues,
						item.values
					);
					break;
				case "marketFocus":
					item.values.forEach(i => {
						i.value = i.value ? Number(i.value) : null;
					});
					this.marketFocusValues = item.values;
					break;
				case "travelSales":
					this.travelSalesSelected = item.values;
					break;
				case "GDS":
					this.gdsValues = this.mappingSelectedValues(
						this.gdsValues,
						item.values
					);
					break;
				case "numberEmployees":
					this.numberEmployeesSelected = item.values;
					break;
				case "numberOffices":
					this.numberOfficesValue = item.values;
					break;
				default:
					break;
			}
		}
	}

	mappingSelectedValues(items, itemselected) {
		items.forEach(item => {
			item.isSelected = false;
			itemselected.forEach(item2 => {
				if (item.label === item2.label) {
					item.isSelected = true;
				}
			});
		});
		return items;
	}

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

	handleChange(event) {
		// Get the string of the "value" attribute on the selected option
		this.travelSalesSelected = event.detail.value;
		let result = {
			fieldName: "travelSales",
			values: this.travelSalesSelected,
			valid: true
		};
		this.addAnswer(result);
	}

	handleChangeNumberEmployees(event) {
		// Get the string of the "value" attribute on the selected option
		this.numberEmployeesSelected = event.detail.value;
		if(this.numberEmployeesSelected) {
			let result = {
				fieldName: "numberEmployees",
				values: this.numberEmployeesSelected,
				valid: true
			};

			this.addAnswer(result);
		}
	}

	handleChangeNumberOffices(event) {
		// Get the string of the "value" attribute on the selected option
		this.numberOfficesValue = event.target.value;
		let result = {
			fieldName: "numberOffices",
			values: this.numberOfficesValue,
			valid: true
		};
		this.addAnswer(result);
	}

	percentageListener(props) {
		this.addAnswer(props);
	}

	badgeListener(props) {
		this.addAnswer(props);
	}

	addAnswer(props) {

		switch(props.fieldName) {
			case 'principalActivities':
				this.answers.principalActivities = {
					fieldName: props.fieldName, 
					values: props.values
				}
				break;
			case 'marketFocus':
				this.answers.marketFocus = {
					fieldName: props.fieldName, 
					values: props.values
				}
				break;
			case 'salesMix':
				this.answers.salesMix = {
					fieldName: props.fieldName, 
					values: props.values
				}
				break;
			case 'travelSales':
				this.answers.travelSales = {
					fieldName: props.fieldName, 
					values: props.values
				}
				break;
			case 'GDS':
				this.answers.GDS = {
					fieldName: props.fieldName, 
					values: props.values
				}
				break;
			case 'numberEmployees':
				this.answers.numberEmployees = {
					fieldName: props.fieldName, 
					values: props.values
				}
				break;
			case 'numberOffices':
				this.answers.numberOffices = {
					fieldName: props.fieldName, 
					values: props.values
				}
				break;
			default: break;
		}

		this.nextButtonDisabled();
	}

	handleNextSection(event) {
		event.preventDefault();
		if (this.nextButtonDisabled()) {
			let businessProfileValues = this.infoToBeSave();

			fireEvent(this.pageRef, "tidsUserInfoUpdate", businessProfileValues);
		}
	}

	// Fields Validation
	salesMixValid() {
		let {salesMix} = this.answers;
		let isValid = false;
		let sMix = JSON.parse(JSON.stringify(salesMix))

		if(Object.keys(salesMix).length > 0) {
			let totalMix = sum(sMix);
			isValid = totalMix === 100 ? true : false;
		}
		return isValid;
	}

	principalActivitiesValid() {
		let {principalActivities} = this.answers;
		let isValid = false;
		if(Object.keys(principalActivities).length > 0) {
			let pActivities = JSON.parse(JSON.stringify(principalActivities));
			if(principalActivities && pActivities.values.length === 1) {
				isValid = true;
			}
		}
		return isValid;
	}

	marketFocusValid() {
		let {marketFocus} = this.answers;
		let isValid = false;
		if(Object.keys(marketFocus).length > 0){
			let mFocus = JSON.parse(JSON.stringify(marketFocus));
			let total = sum(mFocus);
			isValid = total === 100 ? true : false;
		}
		return isValid;
	}
	
	gdsValid() {
		let {GDS} = this.answers;
		let isValid = false;
		if(Object.keys(GDS).length > 0) {
			let gds = JSON.parse(JSON.stringify(GDS));
			if(gds && gds.values.length >= 1 && gds.values.length <= 4) {
				isValid = true;
			}
		}
		return isValid;
	}

	travelSalesValid() {
		let isValid = false;
		if(Object.keys(this.answers.travelSales).length > 0) {
			isValid = true;
		}
		return isValid;
	}

	numberEmployeesValid() {
		let isValid = false;
		if(Object.keys(this.answers.numberEmployees).length > 0) {
			isValid = this.answers.numberEmployees.values !== "" ? true : false;
		}
		return isValid;
	}

	numberOfficesValid() {
		let isValid = false;
		if(Object.keys(this.answers.numberOffices).length > 0) {
			isValid = this.answers.numberOffices.values !== "" ? true : false;
		}
		return isValid;
	}

	fieldsValidation() {
		let result = true;
		
		if(this.numberEmployeesRules.required) {
			result = result && this.numberEmployeesValid();
		}

		if(this.numberOfficesRules.required) {
			result = result && this.numberOfficesValid();
		}

		if(this.gdsRules.required) {
			result = result && this.gdsValid();
		}

		if(this.principalActivitiesRules.required) {
			result = result && this.principalActivitiesValid();
		}

		if(this.marketFocusRules.required) {
			result = result && this.marketFocusValid();
		}

		if(this.salesMixRules.required) {
			result = result && this.salesMixValid();
		}
		
		if(this.travelSalesRules.required) {
			result = result && this.travelSalesValid();
		}

		return result;
	}

	nextButtonDisabled() {
		// Is for is valid and without errors
		let isFormValid = this.fieldsValidation();
		// Enable the button Next Section is the form is valid
		this.disableButton = !isFormValid;
		return isFormValid; 
	}

	// Vetting errors
	handleError(event) {
		event.preventDefault();
		let errorField = event.target.dataset.name;
		this.modalAction = "FIELD";
		switch (errorField) {
			case "error-sales-mix":
				if (this.salesMixError.show && this.salesMixError.description !== "") {
					this.fieldErrorSelected = this.salesMixError;
					this.modalDefaultMessage = false;
					this.openModal = true;
				} else {
					this.salesMixError.show = !this.salesMixError.show;
				}
				break;
			case "error-principal-activities":
				if (
					this.principalActivitiesError.show &&
					this.principalActivitiesError.description !== ""
				) {
					this.fieldErrorSelected = this.principalActivitiesError;
					this.modalDefaultMessage = false;
					this.openModal = true;
				} else {
					this.principalActivitiesError.show = !this.principalActivitiesError
						.show;
				}
				break;
			case "error-market-focus":
				if (
					this.marketFocusError.show &&
					this.marketFocusError.description !== ""
				) {
					this.fieldErrorSelected = this.marketFocusError;
					this.modalDefaultMessage = false;
					this.openModal = true;
				} else {
					this.marketFocusError.show = !this.marketFocusError.show;
				}
				break;
			case "error-travel-sales":
				if (
					this.travelSalesError.show &&
					this.travelSalesError.description !== ""
				) {
					this.fieldErrorSelected = this.travelSalesError;
					this.modalDefaultMessage = false;
					this.openModal = true;
				} else {
					this.travelSalesError.show = !this.travelSalesError.show;
				}
				break;
			case "error-gds":
				if (
					this.gdsError.show &&
					this.gdsError.description !== ""
				) {
					this.fieldErrorSelected = this.gdsError;
					this.modalDefaultMessage = false;
					this.openModal = true;
				} else {
					this.gdsError.show = !this
						.gdsError.show;
				}
				break;
			case "error-number-employees":
				if (
					this.numberEmployeesError.show &&
					this.numberEmployeesError.description !== ""
				) {
					this.fieldErrorSelected = this.numberEmployeesError;
					this.modalDefaultMessage = false;
					this.openModal = true;
				} else {
					this.numberEmployeesError.show = !this
						.numberEmployeesError.show;
				}
				break;
			case "error-number-offices":
				if (
					this.numberOfficesError.show &&
					this.numberOfficesError.description !== ""
				) {
					this.fieldErrorSelected = this.numberOfficesError;
					this.modalDefaultMessage = false;
					this.openModal = true;
				} else {
					this.numberOfficesError.show = !this
						.numberOfficesError.show;
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
			case "error-sales-mix-desc":
				this.salesMixError.description = event.target.value;
				break;
			case "error-principal-activities-desc":
				this.principalActivitiesError.description = event.target.value;
				break;
			case "error-market-focus-desc":
				this.marketFocusError.description = event.target.value;
				break;
			case "error-travel-sales-desc":
				this.travelSalesError.description = event.target.value;
				break;
			case "error-gds-desc":
				this.gdsError.description = event.target.value;
				break;
			case "error-number-employees-desc":
				this.numberEmployeesError.description = event.target.value;
				break;
			case "error-number-offices-desc":
				this.numberOfficesError.description = event.target.value;
				break;
			default:
				break;
		}
		this.sectionHasErrors = this.noFormErrors();
	}

	handleProceed(event) {
		event.preventDefault();
		let option = event.target.dataset.name;

		let businessProfileValues;

		if (option === "report-errors-and-proceed") {
			this.updateErrors();
			businessProfileValues = this.infoToBeSave();
		} else if (option === "confirm-review-status") {
			businessProfileValues = this.infoToBeSave();
			businessProfileValues.sectionDecision = SECTION_CONFIRMED;
		}

		fireEvent(this.pageRef, "tidsUserInfoUpdate", businessProfileValues);
	}

	updateErrors() {
		if (this.salesMixError.show && this.salesMixError.description !== "") {
			this.addVettingError(this.salesMixError);
		}
		if (
			this.principalActivitiesError.show &&
			this.principalActivitiesError.description !== ""
		) {
			this.addVettingError(this.principalActivitiesError);
		}
		if (
			this.marketFocusError.show &&
			this.marketFocusError.description !== ""
		) {
			this.addVettingError(this.marketFocusError);
		}
		if (
			this.travelSalesError.show &&
			this.travelSalesError.description !== ""
		) {
			this.addVettingError(this.travelSalesError);
		}
		if (
			this.gdsError.show &&
			this.gdsError.description !== ""
		) {
			this.addVettingError(this.gdsError);
		}
		if (
			this.numberEmployeesError.show &&
			this.numberEmployeesError.description !== ""
		) {
			this.addVettingError(this.numberEmployeesError);
		}
		if (
			this.numberOfficesError.show &&
			this.numberOfficesError.description !== ""
		) {
			this.addVettingError(this.numberOfficesError);
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

	handleSaveAndQuit(event) {
		event.preventDefault();
		let option = event.target.dataset.next;
		let businessProfileValues = this.infoToBeSave();
		businessProfileValues.target = option;
		businessProfileValues.action = 'SaveAndQuit';
		fireEvent(this.pageRef, "tidsUserInfoUpdate", businessProfileValues);
	}

	// Modal Listeners
	modalProceedListener(props) {
		this.updateinfoErrors(props);
		this.sectionHasErrors = this.noFormErrors();
		this.openModal = false;
	}

	updateinfoErrors(props) {
		switch (props.fieldName) {
			case "salesMix":
				this.salesMixError = props;
				break;
			case "principalActivities":
				this.principalActivitiesError = props;
				break;
			case "marketFocus":
				this.marketFocusError = props;
				break;
			case "travelSales":
				this.travelSalesError = props;
				break;
			case "GDS":
				this.gdsError = props;
				break;
			case "numberEmployees":
				this.numberEmployeesError = props;
				break;
				case "numberOffices":
					this.numberOfficesError = props;
					break;
			default:
				break;
		}
	}

	modalCloseListener(props) {
		this.openModal = props;
		if (this.modalAction === "ALL") {
			fireEvent(this.pageRef, "sectionErrorListener", true);
		}
	}

	modalDeleteAllErrorsListener() {
		// Reset Values
		this.salesMixError.show = false;
		this.salesMixError.description = "";
		this.principalActivitiesError.show = false;
		this.principalActivitiesError.description = "";
		this.marketFocusError.show = false;
		this.marketFocusError.description = "";
		this.travelSalesError.show = false;
		this.travelSalesError.description = "";
		this.gdsError.show = false;
		this.gdsError.description = "";
		this.numberEmployeesError.show = false;
		this.numberEmployeesError.description = "";
		this.numberOfficesError.show = false;
		this.numberOfficesError.description = "";

		this.sectionHasErrors = this.noFormErrors();
		this.vettingErrorOptions = this.noFormErrors();
		this.openModal = false;
		fireEvent(this.pageRef, "sectionErrorListener", false);
	}

	// Section business logic Save
	infoToBeSave() {
		let sectionNav = JSON.parse(
			JSON.stringify(sectionNavigation(this.cmpName))
		);

		let cAnswers = this.answers;
		
		// Apply only when the Market Focus is required
		if (this.marketFocusRules.required) {
			cAnswers.marketFocus.values.forEach(i => {
				i.value = i.value ? i.value.toString() : null;
			});
		}
		
		// Apply only when the Sales Mix question is required
		if (this.salesMixRules.required) {
			cAnswers.salesMix.values.forEach(i => {
				i.value = i.value ? i.value.toString() : null;
			});
		}

		let businessProfileValues = {
			cmpName: this.cmpName,
			target: sectionNav.next,
			sectionDecision: sectionDecision(this.sectionHasErrors),
			values: cAnswers,
			vettingErrors: this.vettingErrors
		};

		return businessProfileValues;
	}

	noFormErrors() {
		let salesMixValid =
			this.salesMixError.show && this.salesMixError.description !== ""
				? true
				: false;
		let principalActivitiesValid =
			this.principalActivitiesError.show &&
			this.principalActivitiesError.description !== ""
				? true
				: false;
		let marketFocusValid =
			this.marketFocusError.show && this.marketFocusError.description !== ""
				? true
				: false;
		let travelSalesValid =
			this.travelSalesError.show && this.travelSalesError.description !== ""
				? true
				: false;
		let gdsValid =
		this.gdsError.show &&
		this.gdsError.description !== ""
			? true
			: false;
		let numberEmployeesValid =
		this.numberEmployeesError.show &&
		this.numberEmployeesError.description !== ""
			? true
			: false;
		
			let numberOfficesValid =
		this.numberOfficesError.show &&
		this.numberOfficesError.description !== ""
			? true
			: false;

		let result =
			salesMixValid ||
			principalActivitiesValid ||
			marketFocusValid ||
			travelSalesValid ||
			gdsValid ||
			numberEmployeesValid ||
			numberOfficesValid;
		this.reportErrorButtonDisabled = result ? false : true;
		return result;
	}

	notifySectionHasError() {
		// eslint-disable-next-line @lwc/lwc/no-async-operation
		setTimeout(() => {
			fireEvent(this.pageRef, "sectionErrorListener", this.sectionHasErrors);
		},
		1,
		this
		);
	}

	mapping(props) {
		let values = JSON.parse(JSON.stringify(props));
		let index = 0;
		let results = [];
		values.forEach(item => {
			results.push({
				id: index++,
				label: item.label,
				value: item.value,
				isSelected: false
			});
		});
		return results;
	}
}