import { LightningElement, track, api, wire } from "lwc";
import { CurrentPageReference } from "lightning/navigation";
import { fireEvent, registerListener } from "c/tidsPubSub";
import {
	getSectionInfo,
	getBusinessrules,
	getUserType,
	sectionNavigation,
	sectionDecision,
	displaySaveAndQuitButton,
	getApplicationType,
	specialCharsValidation,
	getSectionRules,
	validateEmail,
	getSfTidsInfo,
	CHG_NAME_COMPANY,
	SECTION_CONFIRMED
} from "c/tidsUserInfo";
export default class TidsShareholderDetails extends LightningElement {
	@wire(CurrentPageReference) pageRef;

	// Component configuration
	@track cmpName = "shareholder-details";
	@track openmodel = false;

	// JS Object with the current or actual shareholder details
	@track actualShareholder = {
		percentage: Number(0)
	};

	// Maximum number of shareholders 10
	@track MAX_SHAREHOLDERS = 10;

	@api get actualShareholder(){
		return this.actualShareholder;
	}

	// Shareholders details information to save
	@track shareholders = [];
	@api get shareholders(){
		return this.shareholders;
	}
	// Shareholder registration form
	@track register;
	@track registerFields = false;

	@track showButtons = false;
	// Read only field name publicly traded
	@track readOnlyName = false;
	// Hide email if publicly traded is true
	@track hideEmail = false;
	// Show/Hide shareholder list
	@track showShareholdersTable = false;

	// Total calculation
	@track total = 0;
	// Change total line
	@track defaultClass = "items-total";
	@track blueClass = "items-total items-valid";
	@track cmpClass;

	// Open modal
	@track openmodel = false;
	// Shareholder Id
	@track shareholderId;
	@track vettingMode;

	// TIDS Business rules shareholder min max total percentage
	@track MIN;
	@track MAX;

	@track isSpecialCharacters = false;

	// UI show hide buttons
	@track disableNextSectionButton = false;

	// Vetting errors
	@track vettingErrorOptions = false;
	@track vettingErrors = [];

	// Vetting Modal - Errors
	@track sectionHasErrors = false;
	@track fieldErrorSelected = {};

	// Field counter
	@track nameCounter = 0;
	@track emailCounter = 0;

	// Modal
	@track openModal = false;
	@track modalDefaultMessage = true;
	@track modalAction = "FIELD";

	@track shareholderError = {
		fieldLabel: "Shareholder",
		fieldName: "shareholderError",
		show: false,
		description: ""
	};

	@track isSoleOwnership = false;
	@track addButtonDisabled = false;
	@track percentageDisabled = false;

	@track showSaveAndQuitButton = false;
	@track previoustypeChecked;
	// Section fields rules
	@track nameRules = {
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

	@track percentageRules = {
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

	@track emailRules = {
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

	@track sectionRules = [];

	// Group section rules by Type
	@track personRules = {
		name: {
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
		},
		percentage: {
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
		},
		email: {
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
	};

	@track companyRules = {
		name: {
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
		},
		percentage: {
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
		},
		email: {
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
	};

	@track publiclyTradedRules = {
		name: {
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
		},
		percentage: {
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
		},
		email: {
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
	};

	// Report Changes
	@track typeChanges = {
		display: false,
		sfValue: null
	};

	@track nameChanges = {
		display: false,
		sfValue: null
	};

	@track emailChanges = {
		display: false,
		sfValue: null
	};

	@track percentageChanges = {
		display: false,
		sfValue: null
	};

	// Const
	NAME = "name";
	EMAIL = "email";
	PERCENTAGE = "percentage";
	PERCENTAGE_NUMBER = "percentage-number";
	ERROR_MESSAGE_PERCENTAGE_VALUE =
		"The percentage value needs to be greater than zero";

	get shareholderTypeValues(){
		return [
			{ label: "Person", value: "Person" },
			{ label: "Company", value: "Company" },
			{ label: "Publicly Traded", value: "Publicly Traded" }
		];
	}

	@track reportErrorButtonDisabled;

	connectedCallback(){
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
		this.sectionRules = getSectionRules(this.cmpName);
		this.mappingSectionRules();

		this.addShareholderDisabled = true;

		this.register = true;
		let userType = getUserType();
		this.vettingMode = userType === "vetting" ? true : false;
		this.disableNextSectionButton = true;
		this.showButtons = true;

		let businessRules = getBusinessrules();
		this.MIN = Number(businessRules.TIDS_Total_Ownership_Minimum);
		this.MAX = Number(businessRules.TIDS_Total_Ownership_Maximum);
		this.handleSavedInfo();

		this.showSaveAndQuitButton = displaySaveAndQuitButton({
			payload: { applicationType: getApplicationType() }
		});
	}

	mappingSectionRules(){
		this.sectionRules.forEach((element) => {
			if (element.apiName.includes("person")){
				if (element.apiName.includes("name")){
					this.personRules.name = element;
				}
				if (element.apiName.includes("percentage")){
					this.personRules.percentage = element;
				}
				if (element.apiName.includes("email")){
					this.personRules.email = element;
				}
			}
			// Type Person
			if (element.apiName.includes("company")){
				if (element.apiName.includes("name")){
					this.companyRules.name = element;
				}
				if (element.apiName.includes("percentage")){
					this.companyRules.percentage = element;
				}
				if (element.apiName.includes("email")){
					this.companyRules.email = element;
				}
			}
			// Type Publicly Traded
			if (element.apiName.includes("publicly")){
				if (element.apiName.includes("name")){
					this.publiclyTradedRules.name = element;
				}
				if (element.apiName.includes("percentage")){
					this.publiclyTradedRules.percentage = element;
				}
				if (element.apiName.includes("email")){
					this.publiclyTradedRules.email = element;
				}
			}
		});
	}

	sectionFieldRules(type){
		switch (type){
			case "Person":
				this.nameRules = this.personRules.name;
				this.percentageRules = this.personRules.percentage;
				this.emailRules = this.personRules.email;
				break;
			case "Company":
				this.nameRules = this.companyRules.name;
				this.percentageRules = this.companyRules.percentage;
				this.emailRules = this.companyRules.email;
				break;
			case "Publicly Traded":
				this.nameRules = this.publiclyTradedRules.name;
				this.percentageRules = this.publiclyTradedRules.percentage;
				this.emailRules = this.publiclyTradedRules.email;
				break;
			default:
				break;
		}
	}

	soleOwnership(){
		// Sole Ownership Validation
		let agencyInfo = getSectionInfo("agency-legal-status");
		if (agencyInfo){
			this.isSoleOwnership =
				agencyInfo.values.companyType === "S" ? true : false;
		}
		if (this.isSoleOwnership){
			this.handlePercentageLogic(100);
			this.percentageRules.disabled = true;
			if (this.shareholders.length > 0){
				this.addButtonDisabled = true;
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

	handleSavedInfo(){
		let savedInfo = getSectionInfo(this.cmpName);

		if (savedInfo){
			this.shareholders = JSON.parse(JSON.stringify(savedInfo.values));

			if (this.shareholders.length > 0){
				this.register = false;
				this.shareholders.forEach((item) => {
					item.percentage = Number(item.percentage);
				});
				this.showShareholdersTable = true;
				this.disableNextSectionButton = false;
			} else {
				this.disableNextSectionButton = true;
				this.register = true;
			}

			if (
				this.vettingMode &&
				savedInfo.errors !== undefined &&
				savedInfo.errors &&
				savedInfo.errors.length > 0
			){
				let er = JSON.parse(JSON.stringify(savedInfo.errors));
				er.forEach((el) => {
					this.updateinfoErrors(el);
				});
				this.vettingErrorOptions = true;
				this.sectionHasErrors = this.noFormErrors();
				this.notifySectionHasError();
			}

			this.totalCalculation(this.shareholders);
			this.addButtonDisabled = this.total === 100 ? true : false;
		}
		this.soleOwnership();
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
	
	handleShareholderChanges(event){
		event.preventDefault();
		let option =
			event.target.dataset.name === "percentage-number"
				? "percentage"
				: event.target.dataset.name;
		//console.log('handleShareholderChanges:event.target.dataset.name',event.target.dataset.name);
		this.isSpecialCharacters = specialCharsValidation(event.target.value);
		switch (option){
			case "name":
				this.actualShareholder.name = event.target.value;
				break;
			case "type":
				let typeChecked = event.detail.value;
				if (this.previoustypeChecked!=typeChecked){
					 this.actualShareholder.name='';
					 this.actualShareholder.email='';
					 this.percentageChanges.display=false;
					 //this.handlePercentageLogic(0);
					 this.previoustypeChecked=typeChecked;
				}
				this.sectionFieldRules(typeChecked);
				this.handleCompanyTypeLogic(typeChecked);
				break;
			case "percentage":
				//console.log('handleShareholderChanges:event.target.value',event.target.value);
				this.handlePercentageLogic(event.target.value);
				break;
			case "email":
				this.actualShareholder.email = event.target.value;
				break;
			default:
				break;
		}

		this.fieldsCounter();

		if (this.isSpecialCharacters){
			//this.resetValues(option);
			this.disableNextSectionButton = true;
		}

		this.showButtons = false;
	}

	fieldsCounter(){
		this.nameCounter = this.actualShareholder.name
			? this.actualShareholder.name.length
			: 0;
		this.emailCounter = this.actualShareholder.email
			? this.actualShareholder.email.length
			: 0;
	}

	resetValues(fieldName){
		switch (fieldName){
			case "name":
				this.actualShareholder.name = "";
				break;
			case "type":
				this.actualShareholder.type = "";
				break;
			case "percentage":
				this.actualShareholder = { percentage: 0 };
				break;
			case "email":
				this.actualShareholder.email = "";
				break;
			default:
				break;
		}
	}
	
	handleCompanyTypeLogic(value){
		this.registerFields = true;
		this.actualShareholder.type = value;
		this.hideEmail = false;
		this.readOnlyName = false;
		//console.log('value',value);
		if (value === "Publicly Traded"){
			this.actualShareholder.name = "Publicly Traded";
			this.readOnlyName = true;
			this.hideEmail = true;
		}

		this.soleOwnership();
	}

	handlePubliclyTradedLogic(){
		this.actualShareholder.publiclyTraded =
			this.actualShareholder.publiclyTraded === undefined
				? false
				: !this.actualShareholder.publiclyTraded;
		//console.log('this.actualShareholder.publiclyTraded ',this.actualShareholder.publiclyTraded );
		this.readOnlyName = this.actualShareholder.publiclyTraded ? true : false;
		this.hideEmail = this.actualShareholder.publiclyTraded ? true : false;
		this.actualShareholder.name = this.actualShareholder.publiclyTraded
			? "Publicly Traded"
			: "";
	}

	handlePercentageLogic(value){
		this.actualShareholder.percentage = Number(value);
		this.percentageValid();
	}

	cancelShareholder(event){
		event.preventDefault();
		this.actualShareholder = { percentage: 0 };
		this.register = false;
		this.registerFields = false;
		this.showButtons = true;
		this.addButtonDisabled = this.isSoleOwnership ? true : false;
	}

	// Add a new shareholder
	addShareholder(event){
		event.preventDefault();

		if (
			this.fieldsValidation() &&
			this.shareholders.length < this.MAX_SHAREHOLDERS
		){
			this.shareholders.push(
				this.mappingShareholderFields(this.actualShareholder)
			);
			this.actualShareholder = { percentage: 0 };
			this.register = false;
			this.registerFields = false;
			this.totalCalculation(this.shareholders);
			this.showShareholdersTable = true;
			this.readOnlyName = false;
			this.hideEmail = false;
			if (this.rangeTotalValidation()){
				this.disableNextSectionButton = false;
			} else {
				this.disableNextSectionButton = true;
			}
			this.showButtons = true;
		}

		this.addButtonDisabledRules();
		window.scrollTo(0, 0);
	}

	addButtonDisabledRules(){
		if (
			this.isSoleOwnership ||
			this.total === 100 ||
			this.shareholders.length === this.MAX_SHAREHOLDERS
		){
			this.addButtonDisabled = true;
		} else {
			this.addButtonDisabled = false;
		}
	}

	updateShareholder(event){
		event.preventDefault();
		//console.log('this.fieldsValidation()',this.fieldsValidation());
		if (this.fieldsValidation()){
			let shareholderId = event.target.dataset.id;
			this.edit = false;
			let shareholderIndex = this.shareholders.findIndex(
				(x) => x.id === shareholderId
			);
			this.shareholders.splice(shareholderIndex, 1);
			this.addButtonDisabled = false;
			this.addShareholder(event);
		}
		this.addButtonDisabledRules();
	}

	editShareholder(event){
		event.preventDefault();
		let shareholderId = event.target.dataset.id;
		this.actualShareholder = { percentage: 0 };
		this.edit = true;
		this.addButtonDisabled = true;
		this.register = true;
		this.registerFields = true;
		this.percentageChanges.display=false;
		let shareholderIndex = this.shareholders.findIndex(
			(x) => x.id === shareholderId
		);

		let shareholderFound = this.shareholders[shareholderIndex];
		let shareholderConverted = JSON.parse(JSON.stringify(shareholderFound));
		this.actualShareholder = shareholderConverted;
		this.readOnlyName=false;
		if (this.actualShareholder.type === "Publicly Traded"){
			this.actualShareholder.email = null;
			this.hideEmail = true;
			this.readOnlyName=true;
		}

		if (this.actualShareholder.percentage > 0){
			this.addShareholderDisabled = false;
		}
		this.previoustypeChecked  = this.actualShareholder.type;
		this.sectionFieldRules(this.actualShareholder.type);
		this.fieldsCounter();
		this.reportChanges();
		this.showButtons = false;
	}

	reportChanges(){
		let applicationType = getApplicationType();
		if (applicationType === CHG_NAME_COMPANY && this.vettingMode){
			this.resetReportChanges();
			let sfInfo = getSfTidsInfo();
			let previousShareholderInfo = sfInfo.accountRoles.find(
				(item) => item.Owner_Name__c === this.actualShareholder.name
			);
			if (previousShareholderInfo !== undefined){
				if (
					previousShareholderInfo.Owner_Category__c !==
					this.actualShareholder.type
				){
					this.typeChanges.display = true;
					this.typeChanges.sfValue = previousShareholderInfo.Owner_Category__c;
				}
				if (
					previousShareholderInfo.Owner_Name__c !== this.actualShareholder.name
				){
					this.nameChanges.display = true;
					this.nameChanges.sfValue = previousShareholderInfo.Owner_Name__c;
				}
				if (
					previousShareholderInfo.Percentage__c !==
					this.actualShareholder.percentage
				){
					this.percentageChanges.display = true;
					this.percentageChanges.sfValue =
						previousShareholderInfo.Percentage__c;
				}
				if (this.actualShareholder.type !== "Publicly traded"){
					if (
						previousShareholderInfo.Owner_Email__c !==
						this.actualShareholder.email
					){
						this.emailChanges.display = true;
						this.emailChanges.sfValue = previousShareholderInfo.Owner_Email__c;
					}
				}
			}
		}
	}

	resetReportChanges(){
		let applicationType = getApplicationType();
		if (applicationType === CHG_NAME_COMPANY && this.vettingMode){
			this.typeChanges = {
				display: false,
				sfValue: null
			};

			this.nameChanges = {
				display: false,
				sfValue: null
			};

			this.emailChanges = {
				display: false,
				sfValue: null
			};

			this.percentageChanges = {
				display: false,
				sfValue: null
			};
		}
	}

	actualTotalCalculation(){
		let actualTotal = 0;
		if (this.shareholders.length > 0){
			this.shareholders.forEach((item) => {
				if (item.id !== this.actualShareholder.id){
					actualTotal += item.percentage;
				}
			});
			actualTotal += this.actualShareholder.percentage;
		}
		console.log('actualTotal1',actualTotal);
		if (this.isSoleOwnership){
			actualTotal = 100;
			console.log('actualTotal0',actualTotal);
		} else if (this.edit){
			/*
			this.shareholders.forEach((item) => {
				if (item.id !== this.actualShareholder.id){
					actualTotal += item.percentage;
				}
			});
			actualTotal += this.actualShareholder.percentage;
			*/
			//console.log('actualTotal1',actualTotal);
		} else {
			if (this.shareholders.length > 0){
				this.totalCalculation(this.shareholders);
				actualTotal = this.total + this.actualShareholder.percentage;
				console.log('actualTotal2',actualTotal);
			}
		}
		if (Number(actualTotal) > Number(this.MAX)){
			this.totalError = true;
			this.addShareholderDisabled = true;
			//console.log('this.addShareholderDisabled',this.addShareholderDisabled);
		} else {
			this.totalError = false;
			this.addShareholderDisabled = false;
			//console.log('this.addShareholderDisabled',this.addShareholderDisabled);
		}
	}

	// Toggle Show or hide the Shareholder registration fields
	handleAddNewShareholder(event){
		event.preventDefault();
		this.actualShareholder = { percentage: 0 };
		this.register = !this.register;
	}

	mappingShareholderFields(props){
		let shareholder = JSON.parse(JSON.stringify(props));
		if (shareholder.type === "Publicly Traded"){
			shareholder.email = null;
		}
		shareholder.id = this.shareholderRandomId();
		return shareholder;
	}

	removeShareholder(event){
		event.preventDefault();
		this.shareholderId = event.target.dataset.id;
		//this.showButtons = false;
		this.openmodel = true;
	}

	// Save shareholder
	handleNextSection(event){
		event.preventDefault();
		let shareholderDetailValues = this.infoToBeSave();
		window.scrollTo(0,0);
		fireEvent(this.pageRef, "tidsUserInfoUpdate", shareholderDetailValues);
	}

	// Shareholder Id generator
	shareholderRandomId(){
		return (((1 + Math.random()) * 0x10000) | 0).toString(16).substring(1);
	}

	// Shareholder total calculation
	totalCalculation(props){
		//console.log('props',JSON.stringify(props));
		this.total = 0;
		let attlist = JSON.parse(JSON.stringify(props));
		attlist.forEach((item) => {
			//console.log('item',JSON.stringify(item));
			let percent = item.percentage;
			percent = Math.round((percent + Number.EPSILON) * 100) / 100;
			item.percentage=percent;
			this.total += percent;
		});
		let total=this.total;
		total = Math.round((total + Number.EPSILON) * 100) / 100;
		this.total = total;
		let delta = (total -100.00);
		delta=Math.round((delta + Number.EPSILON) * 100);
		console.log('total',this.total,total,delta);
		this.cmpClass = delta===0 ? this.blueClass : this.defaultClass;
		console.log('this.cmpClass',this.cmpClass);
	}

	rangeTotalValidation(){
		let result = false;
		if (this.total >= this.MIN && this.total <= this.MAX){
			return true;
		}
		return result;
	}

	// Section business logic Save
	infoToBeSave(){
		let sectionNav = JSON.parse(
			JSON.stringify(sectionNavigation(this.cmpName))
		);

		let cShareholders = this.shareholders;
		cShareholders.forEach((item) => {
			item.percentage = item.percentage.toString();
		});

		let shareholderDetailValues = {
			cmpName: this.cmpName,
			target: sectionNav.next,
			sectionDecision: sectionDecision(this.sectionHasErrors),
			values: cShareholders,
			vettingErrors: this.vettingErrors
		};

		return shareholderDetailValues;
	}

	// Modal business logic
	handleModalProceed(event){
		event.preventDefault();
		let shareholderIndex = this.shareholders.findIndex(
			(x) => x.id === this.shareholderId
		);
		this.shareholders.splice(shareholderIndex, 1);
		this.totalCalculation(this.shareholders);

		if (this.shareholders.length === 0){
			this.showShareholdersTable = false;
			this.registerFields = false;
			this.actualShareholder = { percentage: 0 };
			this.edit = false;
			this.disableNextSectionButton = true;
			this.register = true;
		}else{
			if (this.rangeTotalValidation()){
				this.disableNextSectionButton = false;
			} else {
				this.disableNextSectionButton = true;
			}
		}
		//this.addButtonDisabled = this.total === 100 ? true : false;
		this.addButtonDisabledRules();
		this.openmodel = false;
		//this.showButtons = true;
	}

	handleModalClose(event){
		event.preventDefault();
		this.openmodel = false;
	}

	//Vetting errors
	handleError(event){
		event.preventDefault();
		let errorField = event.target.dataset.name;
		switch (errorField){
			case "error-shareholder":
				if (
					this.shareholderError.show &&
					this.shareholderError.description !== ""
				){
					this.fieldErrorSelected = this.shareholderError;
					this.modalDefaultMessage = false;
					this.openModal = true;
				} else {
					this.shareholderError.show = !this.shareholderError.show;
				}
				break;
			default:
				break;
		}
	}

	changeErrorFields(event){
		let field = event.target.dataset.name;
		switch (field){
			case "error-shareholder-desc":
				this.shareholderError.description = event.target.value;
				break;
			default:
				break;
		}
		this.sectionHasErrors = this.noFormErrors();
	}

	handleProceed(event){
		event.preventDefault();
		let option = event.target.dataset.name;
		let shareholderDetailValues;

		if (option === "report-errors-and-proceed"){
			if (
				this.shareholderError.show &&
				this.shareholderError.description !== ""
			){
				this.addVettingError(this.shareholderError);
			}
			shareholderDetailValues = this.infoToBeSave();
		} else if (option === "confirm-review-status"){
			shareholderDetailValues = this.infoToBeSave();
			shareholderDetailValues.sectionDecision = SECTION_CONFIRMED;
		}

		fireEvent(this.pageRef, "tidsUserInfoUpdate", shareholderDetailValues);
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
		let shareholderDetailValues = this.infoToBeSave();
		shareholderDetailValues.target = option;
		shareholderDetailValues.action = "SaveAndQuit";
		fireEvent(this.pageRef, "tidsUserInfoUpdate", shareholderDetailValues);
	}

	// Fields validations
	fieldsValidation(){
		let result = false;

		if (
			this.actualShareholder.type === "Person" ||
			this.actualShareholder.type === "Company"
		){
			if (
				this.nameRules.required &&
				this.percentageRules.required &&
				this.emailRules.required
			){
				result =
					this.nameValid() && this.percentageValid() && this.emailValid();
			}
		}

		if (this.actualShareholder.type === "Publicly Traded"){
			if (this.nameRules.required && this.percentageRules.required){
				result = this.nameValid() && this.percentageValid();
			}
		}

		return result;
	}

	nameValid(){
		let isValid = false;
		let cmpField = this.template.querySelector(
			"[data-name='" + this.NAME + "']"
		);
		if (this.nameRules.required && cmpField){
			isValid = cmpField.validity.valid;
		} else if (this.nameRules.required && this.actualShareholder.name){
			isValid = true;
		}
		return isValid;
	}

	percentageValid(){
		let isValid = false;
		let cmpField = this.template.querySelector("[data-name='" + this.PERCENTAGE + "']");
		let cmpNumberField = this.template.querySelector("[data-name='" + this.PERCENTAGE_NUMBER + "']");
		console.log('cmpNumberField',cmpNumberField);
		console.log(' cmpField', cmpField);
		this.addShareholderDisabled = true;
		if (Number(this.actualShareholder.percentage) <= 0){
			cmpField.setCustomValidity(this.ERROR_MESSAGE_PERCENTAGE_VALUE);
			cmpNumberField.setCustomValidity("");
			cmpField.reportValidity();
			cmpNumberField.reportValidity();
			console.log('isValid0', isValid);
		} else if (this.percentageRules.required && cmpField && cmpNumberField){
			cmpField.setCustomValidity("");
			isValid = cmpField.validity.valid && cmpNumberField.validity.valid;
			cmpField.reportValidity();
			console.log('isValid1', isValid);
		} else if (this.percentageRules.required &&
			Number(this.actualShareholder.percentage) > 0){
			isValid = true;
			console.log('isValid2', isValid);
		}
		this.disableSaveOrUpdateButton();
		return isValid;
	}

	disableSaveOrUpdateButton(){
		if (this.actualShareholder.percentage <= 0){
			this.addShareholderDisabled = true;
			console.log('this.addShareholderDisabled', this.addShareholderDisabled);
		} else {
			this.actualTotalCalculation();
		}
	}

	emailValid(){
		let isValid = validateEmail(this.actualShareholder.email);
		return isValid;
	}

	cancelNewShareholder(event){
		event.preventDefault();
		this.actualShareholder = { percentage: 0 };
		this.register = this.showShareholdersTable ? false : true;
		this.registerFields = false;
		this.showButtons = true;
		this.addButtonDisabled = this.isSoleOwnership ? true : false;
		this.resetReportChanges();
	}

	// Modal Listeners
	modalProceedListener(props){
		this.updateinfoErrors(props);
		this.sectionHasErrors = this.noFormErrors();
		this.openModal = false;
	}

	updateinfoErrors(props){
		if (props.fieldName === "shareholderError"){
			this.shareholderError = props;
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
		this.shareholderError.show = false;
		this.shareholderError.description = "";

		this.sectionHasErrors = this.noFormErrors();
		this.vettingErrorOptions = this.noFormErrors();
		this.openModal = false;
		fireEvent(this.pageRef, "sectionErrorListener", false);
	}

	noFormErrors(){
		let shareholderValid =
			this.shareholderError.show && this.shareholderError.description !== ""
				? true
				: false;
		this.reportErrorButtonDisabled = shareholderValid ? false : true;
		return shareholderValid;
	}
}