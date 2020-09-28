import { LightningElement, track, wire, api } from "lwc";
import { CurrentPageReference } from "lightning/navigation";
import { fireEvent, registerListener } from "c/tidsPubSub";

import {
	getLocationType,
	getSectionInfo,
	getUserType,
	sectionNavigation,
	sectionDecision,
	getApplicationType,
	displaySaveAndQuitButton,
	specialCharsValidation,
	getSectionRules,
	getSfTidsInfo,
	getCompanyTypes,
	SECTION_CONFIRMED,
	NEW_BRANCH,
  	NEW_VIRTUAL_BRANCH,
  	NEW_HEAD_OFFICE,
  	CHG_NAME_COMPANY,
  	CHG_ADDRESS_CONTACT,
  	CHG_BUSINESS_PROFILE_SPECIALIZATION
} from "c/tidsUserInfo";

export default class TidsAgency extends LightningElement {
	@wire(CurrentPageReference) pageRef;

	@track vettingMode = false;

	cmpName = "agency-legal-status";
	@api tidsUserInfo;

	@track companyTypes = [];
	@track companyTypesLoaded = false;

	@track companyType;
	@track taxIdVATNumber1;
	@track taxIdVATNumber1Counter = 0;

	@track taxIdVATNumber2;
	@track taxIdVATNumber2Counter = 0;

	@track businessRegistration;
	@track businessRegistrationCounter = 0;

	@track inOperationsSince;

	@api tradingName;
	@track tradingNameCounter = 0;

	@track disableButton;
	@track isSpecialCharacters = false;

	// TIDS Branch Application
	@track showSaveAndQuitButton = false;
	@track applicationType = null;

	// Vetting Modal - Errors
	@track sectionHasErrors = false;
	@track fieldErrorSelected = {};

	// Sole Ownership business rule validation
	@track hasOwnerships = false;
	@track soleOwnershipMessage = false;

	// Modal
	@track openModal = false;
	@track modalDefaultMessage = true;
	@track modalAction = "FIELD";

	// Vetting errors
	@track vettingErrorOptions = false;
	@track vettingErrors = [];

	@track tradingNameError = {
		fieldLabel: "Trading name",
		fieldName: "tradingName",
		show: false,
		description: ""
	};

	@track companyTypeError = {
		fieldLabel: "Company Type",
		fieldName: "companyType",
		show: false,
		description: ""
	};

	@track vatnumber1Error = {
		fieldLabel: "Tax ID / VAT Number 1",
		fieldName: "taxIdVATNumber1",
		show: false,
		description: ""
	};

	@track vatnumber2Error = {
		fieldLabel: "Tax ID / VAT Number 2",
		fieldName: "taxIdVATNumber2",
		show: false,
		description: ""
	};

	@track businessRegistrationError = {
		fieldLabel: "Business Registration / License Number",
		fieldName: "businessRegistration",
		show: false,
		description: ""
	};

	@track inOperationsSinceError = {
		fieldLabel: "Held Since",
		fieldName: "inOperationsSince",
		show: false,
		description: ""
	};

	// Section fields rules
	@track tradingNameRules = {
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
	};

	@track companyTypeRules = {
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
	};

	@track inOperationsSinceRules = {
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
	};

	@track taxIdVATNumber1Rules = {
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
	};

	@track taxIdVATNumber2Rules = {
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
	};

	@track businessRegistrationRules = {
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
	};

	// Report Changes
	@track tradingNameChanges = {
		display: false,
		sfValue: null
	};
	@track companyTypeChanges = {
		display: false,
		sfValue: null
	};
	@track taxIdVATNumber1Changes = {
		display: false,
		sfValue: null
	};
	@track taxIdVATNumber2Changes = {
		display: false,
		sfValue: null
	};
	@track businessRegistrationChanges = {
		display: false,
		sfValue: null
	};
	@track inOperationsSinceChanges = {
		display: false,
		sfValue: null
	};

	// Const
	TRADING_NAME = "tradingName";
	COMPANY_TYPE = "companyType";
	IN_OPERATIONS_SINCE = "inOperationsSince";
	TAX_ID_VAT_NUMBER1 = "taxIdVATNumber1";
	TAX_ID_VAT_NUMBER2 = "taxIdVATNumber2";
	BUSINESS_REGISTRATION = "businessRegistration";

	@track reportErrorButtonDisabled;

	changeField(event) {
		this.isSpecialCharacters = specialCharsValidation(event.target.value);

		if (event.target.name === this.TRADING_NAME) {
			this.tradingName = event.target.value;
		} else if (event.target.name === this.TAX_ID_VAT_NUMBER1) {
			this.taxIdVATNumber1 = event.target.value;
		} else if (event.target.name === this.TAX_ID_VAT_NUMBER2) {
			this.taxIdVATNumber2 = event.target.value;
		} else if (event.target.name === this.BUSINESS_REGISTRATION) {
			this.businessRegistration = event.target.value;
		}

		this.fieldsCounter();

		if (this.isSpecialCharacters) {
			this.resetValues(event.target.name);
			this.disableButton = true;
		} else {
			this.nextButtonDisabled();
		}
	}

	fieldsCounter() {
		this.tradingNameCounter = this.tradingName ? this.tradingName.length : 0;
		this.taxIdVATNumber1Counter = this.taxIdVATNumber1
			? this.taxIdVATNumber1.length
			: 0;
		this.taxIdVATNumber2Counter = this.taxIdVATNumber2
			? this.taxIdVATNumber2.length
			: 0;
		this.businessRegistrationCounter = this.businessRegistration
			? this.businessRegistration.length
			: 0;
	}

	resetValues(fieldName) {
		switch (fieldName) {
			case this.TRADING_NAME:
				this.tradingName = "";
				break;
			case this.TAX_ID_VAT_NUMBER1:
				this.taxIdVATNumber1 = "";
				break;
			case this.TAX_ID_VAT_NUMBER2:
				this.taxIdVATNumber2 = "";
				break;
			case this.BUSINESS_REGISTRATION:
				this.businessRegistration = "";
				break;
			default:
				break;
		}
	}

	handleChangeDate(event) {
		this.isSpecialCharacters = specialCharsValidation(event.target.value);
		if (!this.isSpecialCharacters) {
			this.inOperationsSince = event.target.value;
			this.nextButtonDisabled();
		} else {
			this.disableButton = true;
		}
	}

	connectedCallback() {
		console.log('tidsAgency');
		this.companyTypes = getCompanyTypes();
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

		this.reportErrorButtonDisabled = true;

		this.sectionFieldsRules();

		this.disableButton = true;
		this.applicationType = getApplicationType();

		this.showSaveAndQuitButton = displaySaveAndQuitButton({
			payload: { applicationType: this.applicationType }
		});

		let userType = getUserType();
		this.vettingMode = userType === "vetting" ? true : false;

		let savedInfo = getSectionInfo(this.cmpName);

		this.companyTypeSoleOwnershipValidation();

		if (savedInfo) {
			this.tradingName = savedInfo.values.tradingName;
			this.companyType = savedInfo.values.companyType;
			this.taxIdVATNumber1 = savedInfo.values.taxIdVATNumber1;
			this.taxIdVATNumber2 = savedInfo.values.taxIdVATNumber2;
			this.businessRegistration = savedInfo.values.businessRegistration;
			this.inOperationsSince = savedInfo.values.inOperationsSince;

			this.fieldsCounter();

			this.reportChanges();

			if (
				savedInfo.errors !== undefined &&
				savedInfo.errors &&
				savedInfo.errors.length > 0 &&
				this.vettingMode
			) {
				let er = JSON.parse(JSON.stringify(savedInfo.errors));
				er.forEach((el) => {
					this.updateinfoErrors(el);
				});
				this.vettingErrorOptions = true;
				this.sectionHasErrors = this.noFormErrors();
				this.notifySectionHasError();
			}
			this.nextButtonDisabled();
		}
		this.setFormText();
	}

	@track istext1=false
	@track istext2=false;

	setFormText() {
		let type = getLocationType();
		let apptype=getApplicationType();
		this.istext1=true;
		this.istext2=false;
		if (apptype === NEW_HEAD_OFFICE) {}
		if (apptype=== NEW_BRANCH) {}		
		if (apptype === NEW_VIRTUAL_BRANCH) {}		
	
		if (apptype=== CHG_NAME_COMPANY){
		  if (type==='HO') {
				this.istext1=false;
				this.istext2=true;
			}else if (type==='BR' || type==='VB'){
		  }
		}	
		if (apptype === CHG_ADDRESS_CONTACT){
		   	if (type==='HO') {			 
		   	}else if (type==='BR') {			  
		   	}else if (type==='VB') {}
		}	
		if (apptype=== CHG_BUSINESS_PROFILE_SPECIALIZATION){
			if (type==='HO') {
		   	}else if (type==='BR' || type==='VB') {}
		}
	}

	reportChanges() {
		if(this.applicationType === CHG_NAME_COMPANY && this.vettingMode) {
			let sfInfo = getSfTidsInfo();

			if (this.tradingName !== sfInfo.tradeName) {
				this.tradingNameChanges.display = true;
				this.tradingNameChanges.sfValue = sfInfo.tradeName;
			}
			if (this.companyType !== sfInfo.companyType) {
				let companyTypePreviousSelected = this.companyTypes.find(
					(item) => item.value === sfInfo.companyType
				);
				this.companyTypeChanges.display = true;
				this.companyTypeChanges.sfValue = companyTypePreviousSelected.label;
			}
			if (this.taxIdVATNumber1 !== sfInfo.vatNumber1) {
				this.taxIdVATNumber1Changes.display = true;
				this.taxIdVATNumber1Changes.sfValue = sfInfo.vatNumber1;
			}
			if (this.taxIdVATNumber2 !== sfInfo.vatNumber2) {
				this.taxIdVATNumber2Changes.display = true;
				this.taxIdVATNumber2Changes.sfValue = sfInfo.vatNumber2;
			}
			if (this.businessRegistration !== sfInfo.licenseNumber) {
				this.businessRegistrationChanges.display = true;
				this.businessRegistrationChanges.sfValue = sfInfo.licenseNumber;
			}
			if (this.inOperationsSince !== sfInfo.inOperationsSince) {
				this.inOperationsSinceChanges.display = true;
				this.inOperationsSinceChanges.sfValue = sfInfo.inOperationsSince;
			}
		}
	}

	companyTypeSoleOwnershipValidation() {
		let shareholderInfo = getSectionInfo("shareholder-details");
		this.hasOwnerships = false;
		if (shareholderInfo) {
			if (
				shareholderInfo.values.length > 0 &&
				this.applicationType === "NEW_HO"
			) {
				this.hasOwnerships = true;
			}
		}
	}

	sectionFieldsRules() {
		let sectionRules = getSectionRules(this.cmpName);

		// Mapping fields rules
		sectionRules.forEach((element) => {
			switch (element.apiName) {
				case this.TRADING_NAME:
					this.tradingNameRules = element;
					break;
				case this.COMPANY_TYPE:
					this.companyTypeRules = element;
					break;
				case this.IN_OPERATIONS_SINCE:
					this.inOperationsSinceRules = element;
					break;
				case this.TAX_ID_VAT_NUMBER1:
					this.taxIdVATNumber1Rules = element;
					break;
				case this.TAX_ID_VAT_NUMBER2:
					this.taxIdVATNumber2Rules = element;
					break;
				case this.BUSINESS_REGISTRATION:
					this.businessRegistrationRules = element;
					break;
				default:
					break;
			}
		});
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

	tradingNameValid() {
		let isValid = false;
		let cmpField = this.template.querySelector(
			"[data-name='" + this.TRADING_NAME + "']"
		);
		if (this.tradingNameRules.required && cmpField) {
			isValid = cmpField.validity.valid;
		} else if (this.tradingNameRules.required && this.tradingName) {
			isValid = true;
		}
		console.log(this.TRADING_NAME,isValid);
		return isValid;
	}

	companyTypeValid() {
		let isValid = false;
		let cmpField = this.template.querySelector(
			"[data-name='" + this.COMPANY_TYPE + "']"
		);
		if (this.companyTypeRules.required && cmpField) {
			isValid = cmpField.validity.valid;
		} else if (this.companyTypeRules.required && this.companyType) {
			isValid = true;
		}
		console.log(this.COMPANY_TYPE,isValid);
		return isValid;
	}

	inOperationsSinceValid() {
		let isValid = false;
		let cmpField = this.template.querySelector(
			"[data-name='" + this.IN_OPERATIONS_SINCE + "']"
		);
		if (this.inOperationsSinceRules.required && cmpField) {
			isValid = cmpField.validity.valid;
		} else if (this.inOperationsSinceRules.required && this.inOperationsSince) {
			isValid = true;
		}
		console.log(this.IN_OPERATIONS_SINCE,isValid);
		return isValid;
	}

	taxIdVATNumber1Valid() {
		let isValid = false;
		let cmpField = this.template.querySelector(
			"[data-name='" + this.TAX_ID_VAT_NUMBER1 + "']"
		);
		if (this.taxIdVATNumber1Rules.required && cmpField) {
			isValid = cmpField.validity.valid;
		} else if (this.taxIdVATNumber1Rules.required && this.taxIdVATNumber1) {
			isValid = true;
		}
		console.log(this.TAX_ID_VAT_NUMBER1,isValid);
		return isValid;
	}

	taxIdVATNumber2Valid() {
		let isValid = false;
		let cmpField = this.template.querySelector(
			"[data-name='" + this.TAX_ID_VAT_NUMBER2 + "']"
		);
		if (this.taxIdVATNumber2Rules.required && cmpField) {
			isValid = cmpField.validity.valid;
		} else if (this.taxIdVATNumber2Rules.required && this.taxIdVATNumber2) {
			isValid = true;
		}
		console.log(this.TAX_ID_VAT_NUMBER2,isValid);
		return isValid;
	}

	businessRegistrationValid() {
		let isValid = false;
		let cmpField = this.template.querySelector(
			"[data-name='" + this.BUSINESS_REGISTRATION + "']"
		);
		if (this.businessRegistrationRules.required && cmpField) {
			isValid = cmpField.validity.valid;
		} else if (
			this.businessRegistrationRules.required &&
			this.businessRegistration
		) {
			isValid = true;
		}
		console.log(this.BUSINESS_REGISTRATION ,isValid);
		return isValid;
	}

	fieldsValidation() {
		let result = true;

		if (this.tradingNameRules.required) {
			result = result && this.tradingNameValid();
		}

		if (this.companyTypeRules.required) {
			result = result && this.companyTypeValid();
		}

		if (this.inOperationsSinceRules.required) {
			result = result && this.inOperationsSinceValid();
		}

		if (this.taxIdVATNumber1Rules.required) {
			result = result && this.taxIdVATNumber1Valid();
		}

		if (this.taxIdVATNumber2Rules.required) {
			result = result && this.taxIdVATNumber2Valid();
		}

		if (this.businessRegistrationRules.required) {
			result = result && this.businessRegistrationValid();
		}

		return result;
	}

	nextButtonDisabled() {
		this.disableButton = this.fieldsValidation() ? false : true;
	}
	

	handleChange(event) {
		event.preventDefault();
		if (event.detail.value === "S" && this.hasOwnerships) {
			this.soleOwnershipMessage = true;
		} else {
			this.companyType = event.detail.value;
			this.nextButtonDisabled();
		}
	}

	handleNextSection(event) {
		event.preventDefault();
		const allValid = [
			...this.template.querySelectorAll(
				"[data-name='companyType'],[data-name='taxIdVATNumber1'],[data-name='taxIdVATNumber1'],[data-name='taxIdVATNumber2'],[data-name='businessRegistration'],[data-name='inOperationsSince']"
			)
		].reduce((validSoFar, inputCmp) => {
			inputCmp.reportValidity();
			return validSoFar && inputCmp.checkValidity();
		}, true);

		if (allValid) {
			let agencyValues = this.infoToBeSave();
			window.scrollTo(0,0);
			fireEvent(this.pageRef, "tidsUserInfoUpdate", agencyValues);
		}
	}

	//Vetting errors
	handleError(event) {
		event.preventDefault();
		let errorField = event.target.dataset.name;
		this.modalAction = "FIELD";
		switch (errorField) {
			case "error-tradingname":
				if (
					this.tradingNameError.show &&
					this.tradingNameError.description !== ""
				) {
					this.fieldErrorSelected = this.tradingNameError;
					this.modalDefaultMessage = false;
					this.openModal = true;
				} else {
					this.tradingNameError.show = !this.tradingNameError.show;
				}
				break;
			case "error-companytype":
				if (
					this.companyTypeError.show &&
					this.companyTypeError.description !== ""
				) {
					this.fieldErrorSelected = this.companyTypeError;
					this.modalDefaultMessage = false;
					this.openModal = true;
				} else {
					this.companyTypeError.show = !this.companyTypeError.show;
				}
				break;
			case "error-vatnumber1":
				if (
					this.vatnumber1Error.show &&
					this.vatnumber1Error.description !== ""
				) {
					this.fieldErrorSelected = this.vatnumber1Error;
					this.modalDefaultMessage = false;
					this.openModal = true;
				} else {
					this.vatnumber1Error.show = !this.vatnumber1Error.show;
				}
				break;
			case "error-vatnumber2":
				if (
					this.vatnumber2Error.show &&
					this.vatnumber2Error.description !== ""
				) {
					this.fieldErrorSelected = this.vatnumber2Error;
					this.modalDefaultMessage = false;
					this.openModal = true;
				} else {
					this.vatnumber2Error.show = !this.vatnumber2Error.show;
				}
				break;
			case "error-business-registration":
				if (
					this.businessRegistrationError.show &&
					this.businessRegistrationError.description !== ""
				) {
					this.fieldErrorSelected = this.businessRegistrationError;
					this.modalDefaultMessage = false;
					this.openModal = true;
				} else {
					this.businessRegistrationError.show = !this.businessRegistrationError
						.show;
				}
				break;
			case "error-in-operations-since":
				if (
					this.inOperationsSinceError.show &&
					this.inOperationsSinceError.description !== ""
				) {
					this.fieldErrorSelected = this.inOperationsSinceError;
					this.modalDefaultMessage = false;
					this.openModal = true;
				} else {
					this.inOperationsSinceError.show = !this.inOperationsSinceError.show;
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
			case "error-tradingname-desc":
				this.tradingNameError.description = event.target.value;
				break;
			case "error-companytype-desc":
				this.companyTypeError.description = event.target.value;
				break;
			case "error-vatnumber1-desc":
				this.vatnumber1Error.description = event.target.value;
				break;
			case "error-vatnumber2-desc":
				this.vatnumber2Error.description = event.target.value;
				break;
			case "error-business-registration-desc":
				this.businessRegistrationError.description = event.target.value;
				break;
			case "error-in-operations-since-desc":
				this.inOperationsSinceError.description = event.target.value;
				break;
			default:
				break;
		}
		this.sectionHasErrors = this.noFormErrors();
	}

	handleProceed(event) {
		event.preventDefault();
		let option = event.target.dataset.name;
		let agencyValues;

		if (option === "report-errors-and-proceed") {
			this.agencyErrors();
			agencyValues = this.infoToBeSave();
		} else if (option === "confirm-review-status") {
			agencyValues = this.infoToBeSave();
			agencyValues.sectionDecision = SECTION_CONFIRMED;
		}

		fireEvent(this.pageRef, "tidsUserInfoUpdate", agencyValues);
	}

	agencyErrors() {
		if (
			this.tradingNameError.show &&
			this.tradingNameError.description !== ""
		) {
			this.addVettingError(this.tradingNameError);
		}
		if (
			this.companyTypeError.show &&
			this.companyTypeError.description !== ""
		) {
			this.addVettingError(this.companyTypeError);
		}
		if (this.vatnumber1Error.show && this.vatnumber1Error.description !== "") {
			this.addVettingError(this.vatnumber1Error);
		}
		if (this.vatnumber2Error.show && this.vatnumber2Error.description !== "") {
			this.addVettingError(this.vatnumber2Error);
		}
		if (
			this.businessRegistrationError.show &&
			this.businessRegistrationError.description !== ""
		) {
			this.addVettingError(this.businessRegistrationError);
		}
		if (
			this.inOperationsSinceError.show &&
			this.inOperationsSinceError.description !== ""
		) {
			this.addVettingError(this.inOperationsSinceError);
		}
	}

	addVettingError(props) {
		let index = this.vettingErrors.findIndex(
			(error) => error.fieldName === props.fieldName
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
		let agencyValues = this.infoToBeSave();
		agencyValues.target = option;
		agencyValues.action = "SaveAndQuit";
		fireEvent(this.pageRef, "tidsUserInfoUpdate", agencyValues);
	}

	// Section business logic Save
	infoToBeSave() {
		let sectionNav = JSON.parse(
			JSON.stringify(sectionNavigation(this.cmpName))
		);

		let agencyValues = {
			cmpName: this.cmpName,
			target: sectionNav.next,
			sectionDecision: sectionDecision(this.sectionHasErrors),
			values: {
				tradingName: this.tradingName,
				companyType: this.companyType,
				taxIdVATNumber1: this.taxIdVATNumber1,
				taxIdVATNumber2: this.taxIdVATNumber2,
				businessRegistration: this.businessRegistration,
				inOperationsSince: this.inOperationsSince
			},
			vettingErrors: this.vettingErrors
		};

		return agencyValues;
	}

	noFormErrors() {
		let tradingNameValid =
			this.tradingNameError.show && this.tradingNameError.description !== ""
				? true
				: false;
		let companyTypeValid =
			this.companyTypeError.show && this.companyTypeError.description !== ""
				? true
				: false;
		let vatnumber1Valid =
			this.vatnumber1Error.show && this.vatnumber1Error.description !== ""
				? true
				: false;
		let vatnumber2Valid =
			this.vatnumber2Error.show && this.vatnumber2Error.description !== ""
				? true
				: false;
		let businessRegistrationValid =
			this.businessRegistrationError.show &&
			this.businessRegistrationError.description !== ""
				? true
				: false;
		let inOperationsSinceValid =
			this.inOperationsSinceError.show &&
			this.inOperationsSinceError.description !== ""
				? true
				: false;
		let result =
			companyTypeValid ||
			vatnumber1Valid ||
			vatnumber2Valid ||
			businessRegistrationValid ||
			inOperationsSinceValid ||
			tradingNameValid;
		this.reportErrorButtonDisabled = result ? false : true;
		return result;
	}

	// Modal Sole ownership
	handleSoleOwnership(event) {
		event.preventDefault();
		this.soleOwnershipMessage = false;
		this.companyTypesLoaded = false;
		setTimeout(() => {
			this.companyTypesLoaded = true;
		}, 1);
	}

	// Modal Listeners
	modalProceedListener(props) {
		this.updateinfoErrors(props);
		this.sectionHasErrors = this.noFormErrors();
		this.openModal = false;
	}

	updateinfoErrors(props) {
		if (props.fieldName === "tradingName") {
			this.tradingNameError = props;
		} else if (props.fieldName === "companyType") {
			this.companyTypeError = props;
		} else if (props.fieldName === "taxIdVATNumber1") {
			this.vatnumber1Error = props;
		} else if (props.fieldName === "taxIdVATNumber2") {
			this.vatnumber2Error = props;
		} else if (props.fieldName === "businessRegistration") {
			this.businessRegistrationError = props;
		} else if (props.fieldName === "inOperationsSince") {
			this.inOperationsSinceError = props;
		}
	}

	modalCloseListener(props) {
		this.openModal = props;
		if (this.modalAction === "ALL") {
			fireEvent(this.pageRef, "sectionErrorListener", true);
		}
	}

	modalDeleteAllErrorsListener(props) {
		// Reset Values
		this.tradingNameError.show = false;
		this.tradingNameError.description = "";
		this.companyTypeError.show = false;
		this.companyTypeError.description = "";
		this.vatnumber1Error.show = false;
		this.vatnumber1Error.description = "";
		this.vatnumber2Error.show = false;
		this.vatnumber2Error.description = "";
		this.businessRegistrationError.show = false;
		this.businessRegistrationError.description = "";
		this.inOperationsSinceError.show = false;
		this.inOperationsSinceError.description = "";

		this.sectionHasErrors = this.noFormErrors();
		this.vettingErrorOptions = this.noFormErrors();

		this.openModal = false;
		fireEvent(this.pageRef, "sectionErrorListener", false);
	}

	mapping(props) {
		let values = JSON.parse(JSON.stringify(props));
		let results = [];
		values.forEach((item) => {
			results.push({
				label: item.label,
				value: item.value
			});
		});
		return results;
	}
}