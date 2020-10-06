import{ LightningElement, track, api, wire } from "lwc";
import{ CurrentPageReference } from "lightning/navigation";
import{ fireEvent, registerListener, unregisterListener  } from "c/tidsPubSub";
import{
	getSectionInfo,
	getLocationType,
	getUserType,
	sectionNavigation,
	sectionDecision,
	displaySaveAndQuitButton,
	getApplicationType,
	getMailingCountries,
	specialCharsValidation,
	getSectionRules,
	getSfTidsInfo,
	SECTION_CONFIRMED,
  	NEW_VIRTUAL_BRANCH,
  	CHG_ADDRESS_CONTACT
} from "c/tidsUserInfo";
import getStates from "@salesforce/apex/TIDSHelper.getState";
import getLocalPlace from "@salesforce/apex/TIDSHelper.getLocalPlace";
export default class TidsMailing extends LightningElement {
	@wire(CurrentPageReference) pageRef;
	cmpName = "mailing";

	@api tidsUserInfo;
	@track vettingMode;
	@track disableButton;
	@track isSpecialCharacters = false;

	@track states = [];

	// Mailing address same as physical address
	@track mailingOptions = [
		{
			label: "Yes, I wish to use my physical address as my mailing address",
			value: "true"
		},
		{
			label: "No, I want to use a different address as my mailing address",
			value: "false"
		}
	];

	@track isPostalCodesAvailable = false;

	@track countries = [];

	@track mailingAddress;
	@track mailingAddressCounter = 0;

	@track otherAddress;
	@track city;
	@track citygeonameId;
	@track modalprivateMessage = false;
	@track citysearch = false;
	@track cityCounter = 0;

	@track state;
	@track postalCode;
	@track postalCodePlaceHolder = "";
	@track country;
	@track isMailingSameAsPhysicalAddress;
	@track showMailingAddressFields = false;

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

	@track physicalAddressError = {
		fieldLabel: "Address",
		fieldName: "physicalAddress",
		show: false,
		description: ""
	};

	@track mailingAddressError = {
		fieldLabel: "Address",
		fieldName: "mailingAddress",
		show: false,
		description: ""
	};

	@track cityError = {
		fieldLabel: "City",
		fieldName: "city",
		show: false,
		description: ""
	};

	@track stateError = {
		fieldLabel: "State / Province",
		fieldName: "state",
		show: false,
		description: ""
	};

	@track postalCodeError = {
		fieldLabel: "Postal Code",
		fieldName: "postalCode",
		show: false,
		description: ""
	};

	@track countryError = {
		fieldLabel: "Country",
		fieldName: "country",
		show: false,
		description: ""
	};

	@track physicalAddressStreet;
	@track physicalAddressCityState;
	@track physicalAddressPostalZipCode;
	@track physicalAddressConcatenate;
	@track physicalAddressData;

	// New Branch
	@track showSaveAndQuitButton = false;

	// Const field name variables
	COUNTRY = "country";
	STATE = "state";
	MAILING_ADDRESS = "mailingAddress";
	CITY = "city";
	POSTAL_CODE = "postalCode";

	// Section fields rules
	@track countryRules = {
		visible: false,
		disabled: false,
		required: false,
		regex: "",
		name: "",
		translation_english: "",
		translation_japanese: "",
		translation_spanish: "",
		translation_portuguese: "",
		translation_french: "",
		translation_chinese: ""
	};
	@track stateRules = {
		visible: false,
		disabled: false,
		required: false,
		regex: "",
		name: "",
		translation_english: "",
		translation_japanese: "",
		translation_spanish: "",
		translation_portuguese: "",
		translation_french: "",
		translation_chinese: ""
	};
	@track mailingAddressRules = {
		visible: true,
		disabled: false,
		required: false,
		regex: "",
		name: "",
		translation_english: "",
		translation_japanese: "",
		translation_spanish: "",
		translation_portuguese: "",
		translation_french: "",
		translation_chinese: ""
	};
	@track cityRules = {
		visible: false,
		disabled: false,
		required: false,
		regex: "",
		name: "",
		translation_english: "",
		translation_japanese: "",
		translation_spanish: "",
		translation_portuguese: "",
		translation_french: "",
		translation_chinese: ""
	};
	@track postalCodeRules = {
		visible: false,
		disabled: false,
		required: false,
		regex: "",
		name: "",
		translation_english: "",
		translation_japanese: "",
		translation_spanish: "",
		translation_portuguese: "",
		translation_french: "",
		translation_chinese: ""
	};

	@track hasRequiredFields;

	@track countryChanges = {
		display: false,
		sfValue: null
	};
	@track mailingAddressChanges = {
		display: false,
		sfValue: null
	};
	@track cityChanges = {
		display: false,
		sfValue: null
	};
	@track stateChanges = {
		display: false,
		sfValue: null
	};
	@track postalCodeChanges = {
		display: false,
		sfValue: null
	};

	connectedCallback(){
		//first unregisterListener
		unregisterListener("vettingMenuListener", this.vettingMenuListener, this);
		unregisterListener("modalProceedListener", this.modalProceedListener, this);
		unregisterListener("modalCloseListener", this.modalCloseListener, this);
		unregisterListener("modalDeleteAllErrorsListener",this.modalDeleteAllErrorsListener,this);
		unregisterListener("disableMCityGeonameId", this.disableMCityGeonameId, this);

		// Vetting menu
		registerListener("vettingMenuListener", this.vettingMenuListener, this);
		registerListener("modalProceedListener", this.modalProceedListener, this);
		registerListener("modalCloseListener", this.modalCloseListener, this);
		registerListener("modalDeleteAllErrorsListener",this.modalDeleteAllErrorsListener,this);
		registerListener("disableMCityGeonameId", this.disableMCityGeonameId, this);

		// Get the section fields rules
		this.sectionFieldsRules();
		let userType = getUserType();
		this.countries = getMailingCountries();
		this.vettingMode = userType === "vetting" ? true : false;
		this.disableButton = true;
		this.physicalAddressData = getSectionInfo("address");
		let mailingAddressSectionValues = getSectionInfo(this.cmpName);
		this.showSaveAndQuitButton = displaySaveAndQuitButton({
			payload: { applicationType: getApplicationType() }
		});
		if (this.physicalAddressData){
			this.physicalAddressStreet = this.physicalAddressData.values.address;
			if (
				this.physicalAddressData.values.state !== undefined &&
				this.physicalAddressData.values.state !== ""
			){
				this.physicalAddressCityState =
					this.physicalAddressData.values.city +
					", " +
					this.physicalAddressData.values.state.label;
			} else {
				this.physicalAddressCityState = this.physicalAddressData.values.city;
			}

			if (
				this.physicalAddressData.values.postalCode !== undefined &&
				this.physicalAddressData.values.postalCode !== ""
			){
				this.physicalAddressPostalZipCode =
					this.physicalAddressData.values.countryIsoCode +
					", " +
					this.physicalAddressData.values.postalCode;
			} else {
				this.physicalAddressPostalZipCode = this.physicalAddressData.values.countryIsoCode;
			}
			// this.physicalAddressConcatenate = this.physicalAddressStreet + this.physicalAddressCityState + this.physicalAddressPostalZipCode;
		}

		if (mailingAddressSectionValues){
			this.isMailingSameAsPhysicalAddress =
				mailingAddressSectionValues.values.isMailingSameAsPhysicalAddress;
			
			this.showMailingAddressFields = !this.stringToBoolean(
				this.isMailingSameAsPhysicalAddress
			);

			if (this.showMailingAddressFields){
				this.mailingAddress = mailingAddressSectionValues.values.mailingAddress;
				this.city = mailingAddressSectionValues.values.city;
				this.citygeonameId = mailingAddressSectionValues.values.citygeonameId;
				this.country = mailingAddressSectionValues.values.countryIsoCode;
				this.statesValues(this.country,false);
				this.postalCode = mailingAddressSectionValues.values.postalCode;
				this.state = undefined;
				if (this.state = mailingAddressSectionValues.values.state!=undefined){
					 this.state = mailingAddressSectionValues.values.state.value;
				}
				this.reportChanges();
			}

			if (
				this.vettingMode &&
				mailingAddressSectionValues.errors !== undefined &&
				mailingAddressSectionValues.errors &&
				mailingAddressSectionValues.errors.length > 0
			){
				let er = JSON.parse(JSON.stringify(mailingAddressSectionValues.errors));
				er.forEach((el) => {
					this.updateinfoErrors(el);
				});
				this.vettingErrorOptions = true;
				this.sectionHasErrors = this.noFormErrors();
				this.notifySectionHasError();
			}
		}

		// Disable next button
		this.nextButtonDisabled();
		this.setFormText();
	}
	@track istext1=false
	@track istext2=false;

	setFormText() {
		let type = getLocationType();
		let apptype=getApplicationType();
		console.log('type:',type,' apptype:',apptype);
		this.istext1=true;
		this.istext2=false;
		if (apptype === NEW_VIRTUAL_BRANCH) {
			this.istext1=false;
			this.istext2=true;
		}	
		if (apptype === CHG_ADDRESS_CONTACT){
			if (type==='VB') {
				this.istext1=false;
				this.istext2=true;
		   	}
		}
	}

	reportChanges(){
		let applicationType = getApplicationType();
		if (
			applicationType === CHG_ADDRESS_CONTACT &&
			this.vettingMode &&
			this.showMailingAddressFields
		){
			let sfInfo = getSfTidsInfo();
			if (this.country !== sfInfo.mailingCountry.value){
				this.countryChanges.display = true;
				this.countryChanges.sfValue = sfInfo.mailingCountry.label;
			}
			if (this.state !== sfInfo.mailingStateProvince.value){
				this.stateChanges.display = true;
				this.stateChanges.sfValue = sfInfo.mailingStateProvince.value;
			}
			if (this.city !== sfInfo.mailingCity){
				this.cityChanges.display = true;
				this.cityChanges.sfValue = sfInfo.mailingCity;
			}
			if (this.mailingAddress !== sfInfo.mailingAddress){
				this.mailingAddressChanges.display = true;
				this.mailingAddressChanges.sfValue = sfInfo.mailingAddress;
			}
			if (this.postalCode !== sfInfo.mailingPostalCode){
				this.postalCodeChanges.display = true;
				this.postalCodeChanges.sfValue = sfInfo.mailingPostalCode;
			}
		}
	}

	vettingMenuListener(props){
		this.modalAction = "ALL";
		if (this.sectionHasErrors){
			this.modalDefaultMessage = true;
			this.openModal = true;
		} else {
			this.openModal = false;
			this.vettingErrorOptions = props;
		}
	}

	nextButtonDisabled(){
		if (this.stringToBoolean(this.isMailingSameAsPhysicalAddress)){
			this.disableButton = false;
		} else {
			this.disableButton = this.fieldsValidation() ? false : true;
		}
		console.log("This Disable Button", this.disableButton);
	}

	changeField(event){
		if (event.target.name === "address"){
		} else if (event.target.name === "city"){
			let xcity = event.target.value;
			console.log("xcity");
			console.log(xcity);
			if (xcity === undefined || xcity === ""){
				this.isPostalCodesAvailable = false;
			}
		}
		this.isSpecialCharacters = specialCharsValidation(event.target.value);
		if (event.target.name === "mailingAddress"){
			this.mailingAddress = event.target.value;
			this.mailingAddressCounter = this.mailingAddress.length;
		} else if (event.target.name === "isMailingSameAsPhysicalAddress"){
			this.isMailingSameAsPhysicalAddress = event.detail.value;
			this.showMailingAddressFields = !this.stringToBoolean(
				this.isMailingSameAsPhysicalAddress
			);
		} else if (event.target.name === "city"){
			this.city = event.target.value;
			this.cityCounter = this.city.length;
			this.getLocationPlace(event.target.name, this.city);
		} else if (event.target.name === "state"){
			this.state = event.target.value;
			this.getLocationPlace(event.target.name, this.city);
		} else if (event.target.name === "postalCode"){
			this.postalCode = event.target.value;
		} else if (event.target.name === "country"){
			this.country = event.target.value;
			this.statesValues(this.country, true);
		}

		if (this.isSpecialCharacters){
			this.resetValues(event.target.name);
			this.disableButton = true;
		} else {
			this.nextButtonDisabled();
		}
	}

	resetValues(fieldName){
		switch (fieldName){
			case "mailingAddress":
				this.mailingAddress = "";
				break;
			case "city":
				this.city = "";
				break;
			case "state":
				this.state = "";
				break;
			case "postalCode":
				this.postalCode = "";
				break;
			case "country":
				this.country = "";
				break;
			default:
				break;
		}
	}

	statesValues(props, isrefreshed){
		this.stateRules.visible=false;
		this.stateRules.required=false;
		if (isrefreshed) {this.state=undefined;}
		getStates({ countryIsoCode: props }).then((result) => {
			console.log('getStates:result',JSON.stringify(result));
			if (result.length>0){
				this.states = result;
				this.stateRules.visible=true;
				this.stateRules.required=true;
			}
			
		});
	}

	stateSelected(props){
		return this.states.find((state) => state.value === props);
	}

	handleNextSection(event){
		event.preventDefault();
		console.log("const allValid");
		const allValid = [
			...this.template.querySelectorAll(
				"[data-name='mailingAddress'],[data-name='city'],[data-name='state'],[data-name='postalCode'],[data-name='country']"
			)
		].reduce((validSoFar, inputCmp) => {
			inputCmp.reportValidity();
			return validSoFar && inputCmp.checkValidity();
		}, true);
		console.log("let sameasphysicaladdress=false;");
		let sameasphysicaladdress = false;
		if (this.stringToBoolean(this.isMailingSameAsPhysicalAddress)){
			sameasphysicaladdress = true;
			console.log("sameasphysicaladdress=true;");
		}
		console.log("if (sameasphysicaladdress)");
		if (sameasphysicaladdress){
			if (allValid){
				console.log("let mailingAddressValues =");
				let mailingAddressValues = this.infoToBeSave();
				window.scrollTo(0,0);
				fireEvent(this.pageRef, "tidsUserInfoUpdate", mailingAddressValues);
			}
		} else {
			if (this.citygeonameId === undefined || this.citygeonameId===null){
				console.log("this.citygeonameId==undefined");
				this.geonameIdNotSelected();
			} else {
				if (allValid){
					console.log("fireEvent(this.pageRef");
					let mailingAddressValues = this.infoToBeSave();
					window.scrollTo(0,0);
					fireEvent(this.pageRef, "tidsUserInfoUpdate", mailingAddressValues);
				}
			}
		}
	}

	// Vetting errors
	handleError(event){
		event.preventDefault();
		let errorField = event.target.dataset.name;
		this.modalAction = "FIELD";
		switch (errorField){
			case "error-mailing-address":
				if (
					this.mailingAddressError.show &&
					this.mailingAddressError.description !== ""
				){
					this.fieldErrorSelected = this.mailingAddressError;
					this.modalDefaultMessage = false;
					this.openModal = true;
				} else {
					this.mailingAddressError.show = !this.mailingAddressError.show;
				}
				break;
			case "error-city":
				if (this.cityError.show && this.cityError.description !== ""){
					this.fieldErrorSelected = this.cityError;
					this.modalDefaultMessage = false;
					this.openModal = true;
				} else {
					this.cityError.show = !this.cityError.show;
				}
				break;
			case "error-state":
				if (this.stateError.show && this.stateError.description !== ""){
					this.fieldErrorSelected = this.stateError;
					this.modalDefaultMessage = false;
					this.openModal = true;
				} else {
					this.stateError.show = !this.stateError.show;
				}
				break;
			case "error-postal-code":
				if (
					this.postalCodeError.show &&
					this.postalCodeError.description !== ""
				){
					this.fieldErrorSelected = this.postalCodeError;
					this.modalDefaultMessage = false;
					this.openModal = true;
				} else {
					this.postalCodeError.show = !this.postalCodeError.show;
				}
				break;
			case "error-country":
				if (this.countryError.show && this.countryError.description !== ""){
					this.fieldErrorSelected = this.countryError;
					this.modalDefaultMessage = false;
					this.openModal = true;
				} else {
					this.countryError.show = !this.countryError.show;
				}
				break;
			case "error-physical-address":
				if (
					this.physicalAddressError.show &&
					this.physicalAddressError.description !== ""
				){
					this.fieldErrorSelected = this.physicalAddressError;
					this.modalDefaultMessage = false;
					this.openModal = true;
				} else {
					this.physicalAddressError.show = !this.physicalAddressError.show;
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
			case "error-mailing-address-desc":
				this.mailingAddressError.description = event.target.value;
				break;
			case "error-city-desc":
				this.cityError.description = event.target.value;
				break;
			case "error-state-desc":
				this.stateError.description = event.target.value;
				break;
			case "error-postal-code-desc":
				this.postalCodeError.description = event.target.value;
				break;
			case "error-country-desc":
				this.countryError.description = event.target.value;
				break;
			case "error-physical-address-desc":
				this.physicalAddressError.description = event.target.value;
				break;
			default:
				break;
		}
		this.sectionHasErrors = this.noFormErrors();
	}

	handleProceed(event){
		event.preventDefault();
		//if physical address is the same as mailing address 
		//avoid displying modal message alert
		//about the citygeonameId
		if (!this.stringToBoolean(this.isMailingSameAsPhysicalAddress)
			 && this.citygeonameId == undefined){
			this.geonameIdNotSelected();
		} else {
			let option = event.target.dataset.name;
			this.handleSave(option);
		}
	}

	handleSave(option){
		let mailingAddressValues;
		console.log('handleSave.option:',option);
		if (option === "report-errors-and-proceed"){
			this.updateErrors();
			mailingAddressValues = this.infoToBeSave();
		} else if (option === "confirm-review-status"){
			mailingAddressValues = this.infoToBeSave();
			mailingAddressValues.sectionDecision = SECTION_CONFIRMED;
		} else if (option === "confirm-next-step"){
			mailingAddressValues = this.infoToBeSave();
		}
		console.log('fireEvent tidsUserInfoUpdate with ',JSON.stringify(mailingAddressValues));
		fireEvent(this.pageRef, "tidsUserInfoUpdate", mailingAddressValues);
	}

	updateErrors(){
		if (
			this.mailingAddressError.show &&
			this.mailingAddressError.description !== ""
		){
			this.addVettingError(this.mailingAddressError);
		}
		if (this.cityError.show && this.cityError.description !== ""){
			this.addVettingError(this.cityError);
		}
		if (this.stateError.show && this.stateError.description !== ""){
			this.addVettingError(this.stateError);
		}
		if (this.postalCodeError.show && this.postalCodeError.description !== ""){
			this.addVettingError(this.postalCodeError);
		}
		if (this.countryError.show && this.countryError.description !== ""){
			this.addVettingError(this.countryError);
		}
		if (
			this.physicalAddressError.show &&
			this.physicalAddressError.description !== ""
		){
			this.addVettingError(this.physicalAddressError);
		}
	}

	addVettingError(props){
		let index = this.vettingErrors.findIndex(
			(error) => error.fieldName === props.fieldName
		);
		if (index === -1){
			this.vettingErrors.push(props);
		} else {
			this.vettingErrors.splice(index, 1);
			this.vettingErrors.push(props);
		}
	}

	handleSaveAndQuit(event){
		event.preventDefault();
		let option = event.target.dataset.next;
		let mailingAddressValues = this.infoToBeSave();
		mailingAddressValues.target = option;
		mailingAddressValues.action = "SaveAndQuit";
		fireEvent(this.pageRef, "tidsUserInfoUpdate", mailingAddressValues);
	}

	// Modal Listeners
	modalProceedListener(props){
		this.updateinfoErrors(props);
		this.sectionHasErrors = this.noFormErrors();
		this.openModal = false;
	}

	updateinfoErrors(props){
		if (props.fieldName === "mailingAddress"){
			this.mailingAddressError = props;
		} else if (props.fieldName === "city"){
			this.cityError = props;
		} else if (props.fieldName === "state"){
			this.stateError = props;
		} else if (props.fieldName === "postalCode"){
			this.postalCodeError = props;
		} else if (props.fieldName === "country"){
			this.countryError = props;
		} else if (props.fieldName === "physicalAddress"){
			this.physicalAddressError = props;
		}
	}

	modalCloseListener(props){
		this.openModal = props;
		if (this.modalAction === "ALL"){
			fireEvent(this.pageRef, "sectionErrorListener", true);
		}
	}

	modalDeleteAllErrorsListener(props){
		// Reset Values
		this.mailingAddressError.show = false;
		this.mailingAddressError.description = "";
		this.cityError.show = false;
		this.cityError.description = "";
		this.stateError.show = false;
		this.stateError.description = "";
		this.postalCodeError.show = false;
		this.postalCodeError.description = "";
		this.countryError.show = false;
		this.countryError.description = "";
		this.physicalAddressError.show = false;
		this.physicalAddressError.description = "";

		this.sectionHasErrors = this.noFormErrors();
		this.vettingErrorOptions = this.noFormErrors();
		this.openModal = false;
		fireEvent(this.pageRef, "sectionErrorListener", false);
	}

	// Section business logic Save
	infoToBeSave(){
		let mailingAddressValues = {};
		let sectionNav = JSON.parse(
			JSON.stringify(sectionNavigation(this.cmpName))
		);

		if (this.stringToBoolean(this.isMailingSameAsPhysicalAddress)){
			mailingAddressValues = {
				cmpName: this.cmpName,
				target: sectionNav.next,
				sectionDecision: sectionDecision(this.sectionHasErrors),
				values: {
					isMailingSameAsPhysicalAddress: this.isMailingSameAsPhysicalAddress
				},
				vettingErrors: this.vettingErrors
			};
		} else {
			let countrySelected = this.countries.find(
				(country) => country.value === this.country
			);

			mailingAddressValues = {
				cmpName: this.cmpName,
				target: sectionNav.next,
				sectionDecision: sectionDecision(this.sectionHasErrors),
				values: {
					isMailingSameAsPhysicalAddress: this.isMailingSameAsPhysicalAddress,
					mailingAddress: this.mailingAddress,
					city: this.city,
					citygeonameId: this.citygeonameId,
					state: this.stateSelected(this.state),
					postalCode: this.postalCode,
					countryName: countrySelected.label,
					countryIsoCode: countrySelected.value,
					countryId: countrySelected.Id
				},
				vettingErrors: this.vettingErrors
			};
		}

		return mailingAddressValues;
	}

	noFormErrors(){
		let result;

		if (this.stringToBoolean(this.isMailingSameAsPhysicalAddress)){
			result =
				this.physicalAddressError.show &&
				this.physicalAddressError.description !== ""
					? true
					: false;
		} else {
			let mailingAddressValid =
				this.mailingAddressError.show &&
				this.mailingAddressError.description !== ""
					? true
					: false;
			let cityValid =
				this.cityError.show && this.cityError.description !== "" ? true : false;
			let stateValid =
				this.stateError.show && this.stateError.description !== ""
					? true
					: false;
			let postalCodeValid =
				this.postalCodeError.show && this.postalCodeError.description !== ""
					? true
					: false;
			let countryValid =
				this.countryError.show && this.countryError.description !== ""
					? true
					: false;
			result =
				mailingAddressValid ||
				cityValid ||
				stateValid ||
				postalCodeValid ||
				countryValid;
		}

		return result;
	}

	stringToBoolean(value){
		return value === "true" ? true : false;
	}

	booleanToString(value){
		return value ? "true" : "false";
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
	//Additional Code
	geonameIdNotSelected(){
		this.modalAction = "MGEONAME";
		this.cityError.show = true;
		this.cityError.description = 'The city entered is not found in our records.\n Select "Review Information" to amend or "Proceed" to continue.';
		this.fieldErrorSelected = this.cityError;
		this.modalDefaultMessage = false;
		this.modalprivateMessage = true;
		this.openModal = true;
	}
	//Call by the modal to proceed even the geonameId is null
	disableMCityGeonameId(props){
		this.openModal = false;
		console.log("disableMCityGeonameId vettingMode:",this.vettingMode);
		if (this.vettingMode){
			this.handleSave("confirm-review-status");
		}else{
			this.handleSave("confirm-next-step");
		}
	}
	setCitySearchOn(event){
		this.citysearch = true;
		if (this.city == "" || this.city == undefined){
			this.citygeonameId = undefined;
		}
	}
	setCitySearchOff(event){
		this.citysearch = false;
		if (this.city == "" || this.city == undefined){
			this.citygeonameId = undefined;
		}
	}
	setCitySearchPrevent(event){
		event.preventDefault();
	}
	selectCity(event){
		event.preventDefault();
		let geonameId = event.currentTarget.id;
		geonameId = "$" + geonameId.split("$")[1] + "$";
		console.log("event.currentTarget.id");
		console.log(geonameId);
		let cityselected;
		this.postalcodes.forEach(function (item){
			console.log(item.geonameId);
			if (item.geonameId === geonameId){
				console.log("item selected");
				cityselected = item;
			}
		});
		console.log("item selected");
		if (cityselected != undefined) this.setcity(cityselected);
		this.isPostalCodesAvailable = false;
		this.citysearch = false;
	}
	setcity(cityselected){
		this.cityselected = cityselected;
		this.city = cityselected.toponymName;
		this.citygeonameId = cityselected.citygeonameId;
		console.log("by selection", cityselected.citygeonameId);
		//this.postalCode=cityselected.
		console.log("cityselected.lat", cityselected.lat);
		console.log("cityselected.lng", cityselected.lng);

		getLocalPlace({
			fieldType: "postalcode",
			searchValue: cityselected.lat,
			countryIsoCode: cityselected.lng
		}).then((result) => {
			console.log("result>>>", result);
			if (result != null){
				let pcs = JSON.parse(result);
				let postalcodeselected;
				pcs.postalCodes.forEach(function (item){
					postalcodeselected = item;
				});
				if (postalcodeselected != undefined){
					console.log("postalcodeselected");
					console.log(postalcodeselected.postalCode);
					this.postalCodePlaceHolder = postalcodeselected.postalCode;
				}
			}
		});
	}
	// this function will be called by our JSON callback
	// the parameter jData will contain an array with postalcode objects
	getLocationPlace(fieldtype, searchvalue){
		this.isPostalCodesAvailable = false;
		this.citysearch = false;
		if (fieldtype == "city"){
			searchvalue = searchvalue.toLowerCase();
			searchvalue = searchvalue.replace(/(^\w|\s\w)/g, (m) => m.toUpperCase());
			//searchvalue= searchvalue.replace(/^\w/, c => c.toUpperCase());
			this.city = searchvalue;
		}
		if (searchvalue == undefined || searchvalue == ""){
			this.postalcodes = [];
			return;
		}
		/*
		"geonames": [
				{
						"adminCode1": "10",
						"lng": "-73.58781",
						"geonameId": 6077243,
						"toponymName": "Montréal",
						"countryId": "6251999",
						"fcl": "P",
						"population": 1600000,
						"countryCode": "CA",
						"name": "Montreal",
						"fclName": "city, village,...",
						"adminCodes1": {
								"ISO3166_2": "QC"
						},
						"countryName": "Canada",
						"fcodeName": "seat of a second-order administrative division",
						"adminName1": "Quebec",
						"lat": "45.50884",
						"fcode": "PPLA2"
				},*/
		getLocalPlace({
			fieldType: "city",
			searchValue: searchvalue,
			countryIsoCode: this.country
		}).then((result) => {
			console.log("this.country", this.country);
			console.log("result>>>", result);
			if (result != null){
				this.citygeonameId = null;
				this.postalcodes = [];
				let pcs = JSON.parse(result);
				let newpcs = [];
				let isstateselected = false;
				let isstateselecteable = false;
				let selectedstate = this.state;
				if (selectedstate != undefined){
					console.log("this.stateSelected(selectedstate)",this.stateSelected(selectedstate));
					if (this.stateSelected(selectedstate) != undefined){
						selectedstate = this.stateSelected(selectedstate).label;
						isstateselected = true;
					}
				}
				if (selectedstate!=undefined){selectedstate=selectedstate.toUpperCase();}
				//console.log('this.states>>>',JSON.stringify(this.states));
				if (!isstateselected){
					if (this.states != undefined && this.states.length > 0){
						isstateselecteable = true;
					}
				}
				let letterNumber = /^[0-9]+$/;
				pcs.geonames.forEach(function (item){
					//console.log('item');
					if (
						item.fcode === "PPLC" ||
						item.fcode === "PPL" ||
						item.fcode === "PPLA" ||
						item.fcode === "PPLA2" ||
						item.fcode === "PPLA3" ||
						item.fcode === "PPLA4" ||
						item.fcode === "PPLA5"
					){
						//console.log('this.postalcodes.push');
						//console.log(item);
						let isitemtopush = true;
						let s1 = searchvalue.toUpperCase();
						let s2 = item.toponymName.toUpperCase();
						var a = 0;
						var b = 0;
						for (var i = 0; i < s1.length; i++){
							a += s1.charCodeAt(i);
							b += s2.charCodeAt(i);
						}
						let isclose = false;
						//console.log("result a and b", a, b);
						if (a == b){
							isclose = true;
						} else {
							var r = 0;
							if (a > b){
								r = (100 * (a - b)) / a;
							} else {
								r = (100 * (b - a)) / b;
							}
							console.log(r);
							if (r < 50){
								isclose = true;
							}
						}
						s2 = item.name.toUpperCase();
						b = 0;
						for (var i = 0; i < s1.length; i++){
							b += s2.charCodeAt(i);
						}
						let isclose2 = false;
						//console.log("result a and b", a, b);
						if (a == b){
							isclose2 = true;
						} else {
							var r = 0;
							if (a > b){
								r = (100 * (a - b)) / a;
							} else {
								r = (100 * (b - a)) / b;
							}
							console.log(r);
							if (r < 50){
								isclose2 = true;
							}
						}
						if (isclose == false && isclose2 == false){
							isitemtopush = false;
							console.log("condition1");
						}
						//if (!item.toponymName.startsWith(searchvalue)){
						// isitemtopush=false;
						//}
						if (isitemtopush &&
							(item.name.match(letterNumber) ||
							item.toponymName.match(letterNumber))
						){
							isitemtopush = false;
							console.log("condition2");
						}
						if (isitemtopush && isstateselected){
							let statef = item.adminName1;
							if (statef!=undefined){statef=statef.toUpperCase();}
							if (statef!= selectedstate){
								isitemtopush = false;
								console.log("condition3",statef,selectedstate);
							}
						} else {
							if (isstateselecteable){
							}
						}
						if (isitemtopush){
							item.citygeonameId = item.geonameId;
							item.geonameId = "$" + item.geonameId + "$";
							newpcs.push(item);
						}
					}
				});
				this.postalcodes = newpcs;
				if (newpcs.length > 0){
					if (newpcs.length == 1){
						let byitem = newpcs[0];
						if (byitem.name == this.city || byitem.toponymName == this.city){
							console.log("by default", byitem.citygeonameId);
							this.citygeonameId = byitem.citygeonameId;
						}
					}
					console.log("this.postalcodes.length");
					console.log(newpcs.length);
					this.isPostalCodesAvailable = true;
					this.citysearch = true;
				}
			}
			// iterate over places and build suggest box content
			// for every postalcode record we create a html div
			// each div gets an id using the array index for later retrieval
			// define mouse event handlers to highlight places on mouseover
			// and to select a place on click
			// all events receive the postalcode array index as input parameter
			//"postalCode": "N4X",
			//"adminName1": "Ontario",
			//"placeName": "St. Mary's",
		});
	}
	//Additional Code

	// Section fields rules logic begin
	sectionFieldsRules(){
		let sectionRules = getSectionRules(this.cmpName);
		this.hasRequiredFields;
		sectionRules.forEach((element) => {
			if (this.hasRequiredFields === undefined && element.required){
				this.hasRequiredFields = true;
			}
			console.log("element.apiName", element.apiName);
			switch (element.apiName){
				case this.COUNTRY:
					this.countryRules = element;
					break;
				case this.STATE:
					this.stateRules = element;
					break;
				case this.MAILING_ADDRESS:
					this.mailingAddressRules = element;
					break;
				case this.CITY:
					this.cityRules = element;
					break;
				case this.POSTAL_CODE:
					this.postalCodeRules = element;
					break;
				default:
					break;
			}
		});
	}

	// Fields validation
	countryValid(){
		let isValid = false;
		let cmpField = this.template.querySelector(
			"[data-name='" + this.COUNTRY + "']"
		);
		if (this.countryRules.required && cmpField){
			isValid = cmpField.validity.valid;
		} else if (this.countryRules.required && this.country){
			isValid = true;
		}
		return isValid;
	}

	stateValid(){
		let isValid = false;
		let cmpField = this.template.querySelector(
			"[data-name='" + this.STATE + "']"
		);
		if (this.stateRules.required && cmpField){
			isValid = cmpField.validity.valid;
		} else if (this.stateRules.required && this.state){
			isValid = true;
		}
		return isValid;
	}

	mailingAddressValid(){
		let isValid = false;
		let cmpField = this.template.querySelector(
			"[data-name='" + this.MAILING_ADDRESS + "']"
		);
		if (this.mailingAddressRules.required && cmpField){
			isValid = cmpField.validity.valid;
		} else if (this.mailingAddressRules.required && this.mailingAddress){
			isValid = true;
		}
		return isValid;
	}
	cityValid(){
		let isValid = false;
		let cmpField = this.template.querySelector(
			"[data-name='" + this.CITY + "']"
		);
		if (this.cityRules.required && cmpField){
			isValid = cmpField.validity.valid;
		} else if (this.cityRules.required && this.city){
			isValid = true;
		}
		return isValid;
	}

	postalCodeValid(){
		let isValid = false;
		let cmpField = this.template.querySelector(
			"[data-name='" + this.POSTAL_CODE + "']"
		);
		if (this.postalCodeRules.required && cmpField){
			isValid = cmpField.validity.valid;
		} else if (this.postalCodeRules.required && this.postalCode){
			isValid = true;
		}
		return isValid;
	}

	fieldsValidation(){
		let result = true;
		if (this.countryRules.required){
			result = result && this.countryValid();
		}
		if (this.mailingAddressRules.required){
			result = result && this.mailingAddressValid();
		}
		if (this.stateRules.required){
			result = result && this.stateValid();
		}
		if (this.cityRules.required){
			result = result && this.cityValid();
		}
		if (this.postalCodeRules.required){
			result = result && this.postalCodeValid();
		}
		return result;
	}
	// Section fields rules logic end
}