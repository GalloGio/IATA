import{ LightningElement, track, api, wire } from "lwc";
import{ CurrentPageReference } from "lightning/navigation";
import{ fireEvent, registerListener, unregisterListener } from "c/tidsPubSub";
import{ 
	getSectionInfo, 
	getUserType, 
	sectionNavigation, 
	sectionDecision, 
	getApplicationType,
	displaySaveAndQuitButton, 
	specialCharsValidation, 
	getSectionRules,
	getSfTidsInfo,
	CHG_ADDRESS_CONTACT,
	SECTION_CONFIRMED 
} from "c/tidsUserInfo";

//Get States based on ISO Country e.g. Canada = CA
import getStates from "@salesforce/apex/TIDSHelper.getState";
import getLocalPlace from "@salesforce/apex/TIDSHelper.getLocalPlace";

export default class TidsAddress extends LightningElement{
	@wire(CurrentPageReference) pageRef;
	@api tidsUserInfo;

	@track address;
	@track addressCounter = 0;

	@track city;
	@track citygeonameId;
	@track modalprivateMessage=false;
	@track citysearch=false;
	@track cityCounter = 0;

	@track state;
	@track postalCode;
	@track postalCodePlaceHolder="";
	@track postalCodeCounter = 0;

	@track country;

	@track disableButton;
	@track isSpecialCharacters = false;

	cmpName = "address";
	@track applicantInfo;
	@track states = [];
	@track showSaveAndQuitButton = false;

	// Vetting Modal - Errors
	@track sectionHasErrors = false;
	@track fieldErrorSelected ={};

	// Modal
	@track openModal = false;
	@track modalDefaultMessage = true;
	@track modalAction = "FIELD";

	// Vetting errors
	@track vettingErrorOptions = false;
	@track vettingErrors = [];

	@track addressError ={
		show: false,
		description: "",
		fieldName: "address",
		fieldLabel: "Address"
	};

	@track cityError ={
		show: false,
		description: "",
		fieldName: "city",
		fieldLabel: "City"
	};

	@track stateError ={
		show: false,
		description: "",
		fieldName: "state",
		fieldLabel: "State / Province"
	};

	@track postalCodeError ={
		show: false,
		description: "",
		fieldName: "postalCode",
		fieldLabel: "Postal Code"
	};

	@track countryError ={
		show: false,
		description: "",
		fieldName: "country",
		fieldLabel: "Country"
	};

	// TIDS Branch Application
	@track applicationType = null;

	@track isPostalCodesAvailable=false;
	@track postalcodes=[]
	
	// Const field name variables
	COUNTRY = 'country';
	STATE = 'state';
	ADDRESS = 'address';
	CITY = 'city';
	POSTAL_CODE = 'postalCode';

	// Section fields rules
	@track countryRules ={
		visible:false,
		disabled: false,
		required: false,
		regex:'',
		name:'',
		translation_english:'',
		translation_russian:'',
		translation_spanish:'',
		translation_portuguese:'',
		translation_french:'',
		translation_chinese:''
	};
	@track stateRules ={
		visible:false,
		disabled: false,
		required: false,
		regex:'',
		name:'',
		translation_english:'',
		translation_russian:'',
		translation_spanish:'',
		translation_portuguese:'',
		translation_french:'',
		translation_chinese:''
	};
	@track addressRules ={
		visible:false,
		disabled: false,
		required: false,
		regex:'',
		name:'',
		translation_english:'',
		translation_russian:'',
		translation_spanish:'',
		translation_portuguese:'',
		translation_french:'',
		translation_chinese:''
	};
	@track cityRules ={
		visible:false,
		disabled: false,
		required: false,
		regex:'',
		name:'',
		translation_english:'',
		translation_russian:'',
		translation_spanish:'',
		translation_portuguese:'',
		translation_french:'',
		translation_chinese:''
	};
	@track postalCodeRules ={
		visible:false,
		disabled: false,
		required: false,
		regex:'',
		name:'',
		translation_english:'',
		translation_russian:'',
		translation_spanish:'',
		translation_portuguese:'',
		translation_french:'',
		translation_chinese:''
	};
	
	@track hasRequiredFields;

	@track stateChanges ={
		display: false,
		sfValue: null
	}
	@track cityChanges ={
		display: false,
		sfValue: null
	}
	@track addressChanges ={
		display: false,
		sfValue: null
	}
	@track postalCodeChanges ={
		display: false,
		sfValue: null
	}

	connectedCallback(){
		//first unregisterListener
		unregisterListener("vettingMenuListener", this.vettingMenuListener, this);
		unregisterListener("modalProceedListener", this.modalProceedListener, this);
		unregisterListener("modalCloseListener", this.modalCloseListener, this);
		unregisterListener("modalDeleteAllErrorsListener",this.modalDeleteAllErrorsListener,this);
		unregisterListener("disableCityGeonameId", this.disableCityGeonameId, this);
		// Vetting menu
		registerListener("vettingMenuListener", this.vettingMenuListener, this);
		// Vetting modal listener
		registerListener("modalProceedListener", this.modalProceedListener, this);
		registerListener("modalCloseListener", this.modalCloseListener, this);
		registerListener("modalDeleteAllErrorsListener",this.modalDeleteAllErrorsListener,this);
		registerListener("disableCityGeonameId", this.disableCityGeonameId, this);

		this.sectionFieldsRules();

		let savedInfo = getSectionInfo(this.cmpName);
		this.applicantInfo = getSectionInfo("new-applicant");
		this.stateRules.visible=false;
		this.stateRules.required=false;
		if (this.applicantInfo){
			this.country = this.applicantInfo.values.countryName;
			getStates({ countryIsoCode: this.applicantInfo.values.countryIsoCode }).then(
				result =>{
					if (result.length>0){
						this.states = result;
						this.stateRules.visible=true;
						this.stateRules.required=true;
					}
				}
			).catch(error => {
				console.log('error',JSON.stringify(error));
			});
		}
		this.disableButton = true;
		let userType = getUserType();
		this.vettingMode = userType === "vetting" ? true : false;
		this.applicationType = getApplicationType();
		this.showSaveAndQuitButton = displaySaveAndQuitButton({payload:{applicationType: this.applicationType}});
		if(this.applicationType === 'NEW_BR'){
			let action ={
				payload:{
					cmpName: this.cmpName
				}
			}
		}
		if (savedInfo){
			this.address = savedInfo.values.address;
			this.city = savedInfo.values.city;
			this.citygeonameId = savedInfo.values.citygeonameId;
			this.state = savedInfo.values.state ? savedInfo.values.state.value : null;
			this.postalCode = savedInfo.values.postalCode;
			this.reportChanges();
			if (
				this.vettingMode &&
				savedInfo.errors !== undefined &&
				savedInfo.errors &&
				savedInfo.errors.length > 0){
				let er = JSON.parse(JSON.stringify(savedInfo.errors));
				er.forEach(el =>{
					this.updateinfoErrors(el);
				});
				this.vettingErrorOptions = true;
				this.sectionHasErrors = this.noFormErrors();
				this.notifySectionHasError();
			}
			this.nextButtonDisabled();
		}
	}

	reportChanges(){
		let sfInfo = getSfTidsInfo();
		if (this.applicationType === CHG_ADDRESS_CONTACT && this.vettingMode){
			if (this.state !== sfInfo.stateProvince.value){
				this.stateChanges.display = true;
				this.stateChanges.sfValue = sfInfo.stateProvince.label;
			}
			if (this.city !== sfInfo.city){
				this.cityChanges.display = true;
				this.cityChanges.sfValue = sfInfo.city;
			}
			if (this.address !== sfInfo.address){
				this.addressChanges.display = true;
				this.addressChanges.sfValue = sfInfo.address;
			}
			if (this.postalCode !== sfInfo.postalCode){
				this.postalCodeChanges.display = true;
				this.postalCodeChanges.sfValue = sfInfo.postalCode;
			}
		}
	}

	vettingMenuListener(props){
		this.modalAction = "ALL";
		if (this.sectionHasErrors){
			this.modalDefaultMessage = true;
			this.openModal = true;
		} else{
			this.openModal = false;
			this.vettingErrorOptions = props;
		}
	}

	notifySectionHasError(){
		// eslint-disable-next-line @lwc/lwc/no-async-operation
		setTimeout(() =>{
				fireEvent(this.pageRef, "sectionErrorListener", this.sectionHasErrors);
			},
			1,
			this
		);
	}

	handleChange(event){
		// Get the string of the "value" attribute on the selected option
		this.state = event.detail.value;
		this.nextButtonDisabled();
	}

	changeField(event){
		if (event.target.name === "address"){
		} else if (event.target.name === "city"){
			let xcity = event.target.value;
			if (xcity===undefined || xcity===''){
				this.isPostalCodesAvailable=false;
			}
		}
		this.isSpecialCharacters = specialCharsValidation(event.target.value);
		if (event.target.name === "address"){
			this.address = event.target.value;
			this.addressCounter = this.address.length;
		} else if (event.target.name === "city"){
			this.city = event.target.value;
			this.cityCounter = this.city.length;
			this.getLocationPlace(event.target.name,this.city);
		} else if (event.target.name === "state"){
			this.state = event.target.value;
			this.getLocationPlace(event.target.name,this.city)
		} else if (event.target.name === "postalCode"){
			this.postalCode = event.target.value;
			this.postalCodeCounter = this.postalCode.length;
		}
		if(this.isSpecialCharacters){
			this.resetValues(event.target.name);
			this.disableButton = true;
		} else{
			this.nextButtonDisabled();
		} 
	}

	resetValues(fieldName){
		switch(fieldName){
			case "address":
				this.address = "";
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
			default: break;
		}
	}

	handleNextSection(event){
		event.preventDefault();
		const allValid = [
			...this.template.querySelectorAll(
				"[data-name='address'],[data-name='city'],[data-name='state'],[data-name='postalCode'],[data-name='country']"
			)
		].reduce((validSoFar, inputCmp) =>{
			inputCmp.reportValidity();
			return validSoFar && inputCmp.checkValidity();
		}, true);
		if (allValid){
			if (this.citygeonameId===undefined || this.citygeonameId===null){
				this.geonameIdNotSelected();
			}else{
				let addressValues = this.infoToBeSave();
				fireEvent(this.pageRef, "tidsUserInfoUpdate", addressValues);
				window.scrollTo(0,0);
			}
		}else{
			if (this.citygeonameId==undefined || this.citygeonameId===null){
				this.geonameIdNotSelected();
			}
		}
	}

	stateSelected(props){
		return this.states.find(state => state.value === props);
	}

	// Fields validation
	countryValid(){
		let isValid = false;
		let cmpField = this.template.querySelector("[data-name='"+this.COUNTRY+"']");
		if(this.countryRules.required && cmpField){
			isValid = cmpField.validity.valid;
		} else if(this.countryRules.required && this.country){
			isValid = true;
		}
		return isValid;
	}

	stateValid(){
		let isValid = false;
		let cmpField = this.template.querySelector("[data-name='"+this.STATE+"']");
		if(this.stateRules.required && cmpField){
			isValid = cmpField.validity.valid;
		} else if(this.stateRules.required && this.state){
			isValid = true;
		}
		return isValid;
	}

	addressValid(){
		let isValid = false;
		let cmpField = this.template.querySelector("[data-name='"+this.ADDRESS+"']");
		if(this.addressRules.required && cmpField){
			isValid = cmpField.validity.valid;
		} else if(this.addressRules.required && this.address){
			isValid = true;
		}
		return isValid;
	}

	cityValid(){
		let isValid = false;
		let cmpField = this.template.querySelector("[data-name='"+this.CITY+"']");
		if(this.cityRules.required && cmpField){
			isValid = cmpField.validity.valid;
		} else if(this.cityRules.required && this.city){
			isValid = true;
		}
		return isValid;
	}

	postalCodeValid(){
		let isValid = false;
		let cmpField = this.template.querySelector("[data-name='"+this.POSTAL_CODE+"']");
		if(this.postalCodeRules.required && cmpField){
			isValid = cmpField.validity.valid;
		} else if(this.postalCodeRules.required && this.postalCode){
			isValid = true;
		}
		return isValid;
	}

	fieldsValidation(){
		let result = true;
		if (this.countryRules.required){
			result = result && this.countryValid();
		}
		if (this.addressRules.required){
			result = result && this.addressValid();
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

	nextButtonDisabled(){
		this.disableButton = this.fieldsValidation() ? false : true;
	}

	// Vetting errors

	handleError(event){
		event.preventDefault();
		let errorField = event.target.dataset.name;
		this.modalAction = "FIELD";
		switch (errorField){
			case "error-address":
				if (this.addressError.show && this.addressError.description !== ""){
					this.fieldErrorSelected = this.addressError;
					this.modalDefaultMessage = false;
					this.openModal = true;
				} else{
					this.addressError.show = !this.addressError.show;
				}
				break;
			case "error-city":
				if (this.cityError.show && this.cityError.description !== ""){
					this.fieldErrorSelected = this.cityError;
					this.modalDefaultMessage = false;
					this.openModal = true;
				} else{
					this.cityError.show = !this.cityError.show;
				}
				break;
			case "error-state":
				if (this.stateError.show && this.stateError.description !== ""){
					this.fieldErrorSelected = this.stateError;
					this.modalDefaultMessage = false;
					this.openModal = true;
				} else{
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
				} else{
					this.postalCodeError.show = !this.postalCodeError.show;
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
			case "error-address-desc":
				this.addressError.description = event.target.value;
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
			default:
				break;
		}
		this.sectionHasErrors = this.noFormErrors();
	}

	handleProceed(event){
		event.preventDefault();
		if (this.citygeonameId==undefined){
				this.geonameIdNotSelected();
		}else{
			let option = event.target.dataset.name;
			this.handleSave(option);
		}
	}

	handleSave(option){
		let addressValues;
		if (option === "report-errors-and-proceed"){
			this.updateErrors();
			addressValues = this.infoToBeSave();
		} else if(option === 'confirm-review-status'){
			addressValues = this.infoToBeSave();
			addressValues.sectionDecision = SECTION_CONFIRMED;
		}else if (option==='confirm-next-step'){
			addressValues = this.infoToBeSave();
		}
		fireEvent(this.pageRef, "tidsUserInfoUpdate", addressValues);
	}

	updateErrors(){
		if (this.addressError.show && this.addressError.description !== ""){
			this.addVettingError(this.addressError);
		}
		if (this.cityError.show && this.cityError.description !== ""){
			this.addVettingError(this.cityError);
		}
		if (this.stateError.show && this.stateError.description !== ""){
			this.addVettingError(this.stateError);
		}
		if (
			this.postalCodeError.show &&
			this.postalCodeError.description !== ""
		){
			this.addVettingError(this.postalCodeError);
		}
	}

	addVettingError(props){
		let index = this.vettingErrors.findIndex(
			error => error.fieldName === props.fieldName
		);
		if (index === -1){
			this.vettingErrors.push(props);
		} else{
			this.vettingErrors.splice(index, 1);
			this.vettingErrors.push(props);
		}
	}
	
	handleSaveAndQuit(event){
		event.preventDefault();
		let option = event.target.dataset.next;
		let addressValues = this.infoToBeSave();
		addressValues.target = option;
		addressValues.action = 'SaveAndQuit';
		fireEvent(this.pageRef, "tidsUserInfoUpdate", addressValues);
	}

	modalProceedListener(props){
		this.updateinfoErrors(props);
		this.sectionHasErrors = this.noFormErrors();
		this.openModal = false;
	}

	updateinfoErrors(props){
		if (props.fieldName === "address"){
			this.addressError = props;
		} else if (props.fieldName === "city"){
			this.cityError = props;
		} else if (props.fieldName === "state"){
			this.stateError = props;
		} else if (props.fieldName === "postalCode"){
			this.postalCodeError = props;
		} else if (props.fieldName === "country"){
			this.countryError = props;
		}
	}

	modalCloseListener(props){
		this.openModal = props;
		if(this.modalAction === 'ALL'){
			fireEvent(this.pageRef, "sectionErrorListener", true);
		}
	}

	modalDeleteAllErrorsListener(props){
		// Reset Values
		this.addressError.show = false;
		this.addressError.description = "";
		this.cityError.show = false;
		this.cityError.description = "";
		this.stateError.show = false;
		this.stateError.description = "";
		this.postalCodeError.show = false;
		this.postalCodeError.description = "";
		this.countryError.show = false;
		this.countryError.description = "";
		this.sectionHasErrors = this.noFormErrors();
		this.vettingErrorOptions = this.noFormErrors();
		this.openModal = false;
		fireEvent(this.pageRef, "sectionErrorListener", false);
	}

	// Section business logic Save
	infoToBeSave(){
		let sectionNav = JSON.parse(JSON.stringify(sectionNavigation(this.cmpName)));
		let addressValues ={
			cmpName: this.cmpName,
			target: sectionNav.next,
			sectionDecision: sectionDecision(this.sectionHasErrors),
			values:{
				address: this.address,
				city: this.city,
				citygeonameId: this.citygeonameId,
				state: this.stateSelected(this.state),
				postalCode: this.postalCode,
				countryName: this.applicantInfo.values.countryName,
				countryIsoCode: this.applicantInfo.values.countryIsoCode,
				countryId: this.applicantInfo.values.countryId
			},
			vettingErrors: this.vettingErrors
		};
		return addressValues;
	}

	noFormErrors(){
		let addressValid =
			this.addressError.show && this.addressError.description !== ""
				? true
				: false;
		let cityValid =
			this.cityError.show && this.cityError.description !== "" ? true : false;
		let stateValid =
			this.stateError.show && this.stateError.description !== "" ? true : false;
		let postalCodeValid =
			this.postalCodeError.show && this.postalCodeError.description !== ""
				? true
				: false;
		let result = addressValid || cityValid || stateValid || postalCodeValid;
		return result;
	}

//Additional Code
//Additional Code
geonameIdNotSelected(){
	this.modalAction='GEONAME';
	this.cityError.show=true; 
	this.cityError.description='The city entered is not found in our records.\n Select "Review Information" to amend or "Proceed" to continue.';
	this.fieldErrorSelected = this.cityError;
	this.modalDefaultMessage = false;
	this.modalprivateMessage=true;
	this.openModal = true;
}
disableCityGeonameId(props){
	if (this.vettingMode){
		 this.handleSave('confirm-review-status');
	}else{
		this.handleSave('confirm-next-step');
	}
}
setCitySearchOn(event){
	this.citysearch=true;
	if (this.city=='' || this.city==undefined){
		 this.citygeonameId=undefined;
	}
}
setCitySearchOff(event){
	this.citysearch=false;
	if (this.city=='' || this.city==undefined){
		this.citygeonameId=undefined;
	}
}
setCitySearchPrevent(event){
	event.preventDefault();
}
selectCity(event){
	let geonameId = event.currentTarget.id;
	geonameId = '$'+geonameId.split('$')[1]+'$';
	let cityselected;
	this.postalcodes.forEach(function(item){
		 if (item.geonameId===geonameId){
			cityselected=item;
		 }
	});
	if (cityselected!=undefined) this.setcity(cityselected);
	this.isPostalCodesAvailable=false;
	this.citysearch=false;
}
setcity(cityselected){
	this.cityselected = cityselected;
	this.city=cityselected.toponymName;
	this.citygeonameId=cityselected.citygeonameId;
	getLocalPlace({ fieldType:'postalcode', searchValue:cityselected.lat, countryIsoCode:cityselected.lng}).then(
		result =>{
			if (result!=null){
				let pcs = JSON.parse(result);
				let postalcodeselected;
				pcs.postalCodes.forEach(function(item){
					 postalcodeselected=item;
				});
				if (postalcodeselected!=undefined){
					this.postalCodePlaceHolder=postalcodeselected.postalCode;
				}
		}
	});
}
// this function will be called by our JSON callback
// the parameter jData will contain an array with postalcode objects
getLocationPlace(fieldtype,searchvalue){  
	this.isPostalCodesAvailable=false;
	this.citysearch=false;
	if (fieldtype=='city'){
		searchvalue = searchvalue.toLowerCase();
		searchvalue=searchvalue.replace(/(^\w|\s\w)/g, m => m.toUpperCase());
		//searchvalue= searchvalue.replace(/^\w/, c => c.toUpperCase());
		this.city =searchvalue;
	}  
	if (searchvalue==undefined || searchvalue==''){
		this.postalcodes=[];
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
					"adminCodes1":{
							"ISO3166_2": "QC"
					},
					"countryName": "Canada",
					"fcodeName": "seat of a second-order administrative division",
					"adminName1": "Quebec",
					"lat": "45.50884",
					"fcode": "PPLA2"
			},*/
	getLocalPlace({ fieldType:'city', searchValue:searchvalue, countryIsoCode: this.applicantInfo.values.countryIsoCode }).then(
		result =>{
			if (result!=null){
				this.citygeonameId=null;
				this.postalcodes=[];
				let pcs = JSON.parse(result);
				let newpcs=[];
				let isstateselected=false;
				let isstateselecteable=false;
				let selectedstate=this.state;
				if (selectedstate!=undefined){
					if (this.stateSelected(selectedstate)!=undefined){
						selectedstate=this.stateSelected(selectedstate).label;
						isstateselected=true;
				 }
				}
				if (selectedstate!=undefined){selectedstate=selectedstate.toUpperCase();}
				if (!isstateselected){
					if (this.states!=undefined && this.states.length>0){
						isstateselecteable=true;
					}
				}
				let letterNumber = /^[0-9]+$/;
				pcs.geonames.forEach(function(item){
					if (item.fcode==='PPLC'
						 || item.fcode==='PPL'
						 || item.fcode==='PPLA'
						 || item.fcode==='PPLA2'
						 || item.fcode==='PPLA3'
						 || item.fcode==='PPLA4'
						 || item.fcode==='PPLA5'
						 ){
							 let isitemtopush=true;
							 let s1=searchvalue.toUpperCase();
							 let s2=item.toponymName.toUpperCase();
							 var a = 0;
							 var b = 0;
							 for(var i=0; i<s1.length;i++){
									a += s1.charCodeAt(i);
									b += s2.charCodeAt(i);
							 }
							 let isclose=false;
							 if (a==b){
									isclose=true;
							 }else{
									var r=0;
									if (a>b){
										r=100*(a-b)/a;
									}else{
										r=100*(b-a)/b;
									}
									if (r<50){
										isclose=true;
									}
							 }
							 s2=item.name.toUpperCase();
							 b = 0;
							 for(var i=0; i<s1.length;i++){
									b += s2.charCodeAt(i);
							 }
							 let isclose2=false;
							 if (a==b){
									isclose2=true;
							 }else{
									var r=0;
									if (a>b){
										r=100*(a-b)/a;
									}else{
										r=100*(b-a)/b;
									}
									if (r<50){
										isclose2=true;
									}
							 }
							 if (isclose==false && isclose2==false){
									isitemtopush=false;
							 }
							 if (isitemtopush && (item.name.match(letterNumber) || item.toponymName.match(letterNumber))){
								isitemtopush=false;
							 }  
							 if (isitemtopush && isstateselected){
								let statef = item.adminName1;
								if (statef!=undefined){statef=statef.toUpperCase();}
								if (statef!= selectedstate){
									isitemtopush=false;
								}
							 }else{
								 if (isstateselecteable){
			 
								 }
							 }
							 if (isitemtopush){
								item.citygeonameId=item.geonameId;
								item.geonameId='$'+item.geonameId+'$';
								newpcs.push(item);
							 }
						 }
				});
				this.postalcodes=newpcs;
				if (newpcs.length>0){
					if (newpcs.length==1){
						let byitem=newpcs[0];
						if (byitem.name==this.city || byitem.toponymName==this.city){
							this.citygeonameId=byitem.citygeonameId;
						}
					}
					this.isPostalCodesAvailable=true;
					this.citysearch=true;
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
	
	// Section fields rules logic begin
	sectionFieldsRules(){
		let sectionRules = getSectionRules(this.cmpName);
		this.hasRequiredFields;
		sectionRules.forEach(element =>{
			if(this.hasRequiredFields === undefined && element.required){
				this.hasRequiredFields = true;
			}
			switch(element.apiName){
				case this.COUNTRY:
					this.countryRules = element;
					break;
				case this.STATE:
					this.stateRules = element;
					break;
				case this.ADDRESS:
					this.addressRules = element;
					break;
				case this.CITY:
					this.cityRules = element;
					break;
				case this.POSTAL_CODE:
					this.postalCodeRules = element;
					break;
				default: break;
			}
		});
	}
	// Section fields rules logic end
}