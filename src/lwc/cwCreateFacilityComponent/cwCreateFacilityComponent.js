import { LightningElement, track, wire, api } from "lwc";
import getCompanyTypes from "@salesforce/apex/CW_Utilities.getCompanyTypes";
import getCountries from "@salesforce/apex/CW_Utilities.getIATACountries";
import getArdTypesBySectorAndCategory from '@salesforce/apex/CW_Utilities.getArdTypesBySectorAndCategory';
import becomeFacilityAdmin from "@salesforce/apex/CW_Utilities.becomeFacilityAdmin";
import resources from "@salesforce/resourceUrl/ICG_Resources";
import createFacility from "@salesforce/apex/CW_CreateFacilityController.createFacility";
import createDummyCompany from "@salesforce/apex/CW_CreateFacilityController.createDummyCompany";
import getAvailableLanguages from "@salesforce/apex/CW_Utilities.getFacilityLanguages";
import generateOpeningHours from "@salesforce/apex/CW_FacilityContactInfoController.generateOpeningHours";
import { concatinateAddressString,concatinateFacilityAddress,getCompanyTypeImage } from "c/cwUtilities";
import fetchAirports from "@salesforce/apex/CW_LandingSearchBarController.fetchAirports";
import createIsoCity from '@salesforce/apex/PortalRegistrationSecondLevelCtrl.createIsoCity';
import updateAccountCoordinates from '@salesforce/apex/CW_CreateFacilityController.updateAccountCoordinates';
import getOnAirportStations from '@salesforce/apex/CW_CreateFacilityController.getOnAirportStations';
import labels from 'c/cwOneSourceLabels';
import getUserFacilities from "@salesforce/apex/CW_PrivateAreaController.getUserFacilities";
import getUserCompanyInfo from "@salesforce/apex/CW_PrivateAreaController.getUserCompanyInfo";
import { loadStyle } from "lightning/platformResourceLoader";
import { NavigationMixin } from "lightning/navigation";
import getAllServicesAvailable from "@salesforce/apex/CW_Utilities.getAllServicesAvailableJson"; 

export default class CwCreateFacilityComponent extends NavigationMixin(
	LightningElement
  ) {
	ctypeimages = resources + "/icons/company_type/";
	icons = resources + "/icons/";
	//company types
	airline = this.ctypeimages + "airline.svg";
	airportoperator = this.ctypeimages + "airport-operator.svg";
	freight = this.ctypeimages + "freight-forwarder.svg";
	trucker = this.ctypeimages + "trucker.svg";
	cargohandling = this.ctypeimages + "cargo-handling-facility.svg";
	shipper = this.ctypeimages + "shipper.svg";
	ramphandler = this.ctypeimages + "ramp-handler.svg";
	backimg = this.icons + "back.svg";
	deletecustom = this.icons + "delete-custom.svg";

	createdStation;
	@track companyTypesRaw;
	@track countries;
	@track ctypesMapBySectorAndCategory;
	@track predictiveValues;
	@track formData = {};
	@track additionalData = {};
	@track selectedAirlines = [];
	@track openingHours;
	@track activeInfoWindow;
	@track setFacilityNameAndType;

	@track handlingServicesEdit = {isCreateView: true , isSummary: false, facilityHandlingService: []};
	@track handlingServicesSummary = {isCreateView: true , isSummary: true};
	inHouseServicesValue = '';
	thirdPartyServicesValue = '';
	
	logoInfoObject;
	geoLocationInfoObject;
	@track logoImage;
	@track showModal = false;
	@track modalMessage = "";
	CHECKED_IMAGE = resources + "/icons/ic-tic-green.svg";
	ERROR_IMAGE = resources + "/icons/error-icon.svg";
	@track modalImage = this.CHECKED_IMAGE;
	@api companyAdmins;
	_label;
	@api 
	get label(){
		return this._label ? this._label : labels.labels();
	}set label(value){
		this._label = value;
	}
	//createHQInitialized = false;
	additionalDataInitialized = false;
	hoverFacilitiesEventListenersAdded = false;
	hqPredictiveInputEventsListenersAdded = false;
	languageSelectorEventListenersAdded = false;
	airportSelectorEventListenersAdded = false;
	@track step = 1;
	@track facilityList;
	@track requesting;
	@track availableLanguages;
	@track hoveredCompany;
	@track hoveredFacilities;

	selectedHQCountry;

	@track newAddressPrompt;
	@track accountCreationPrompt;
	@track stationCreationPrompt;

	@track
	cargoCommodities = [
		{ key: "generalCargo", name: "General Cargo", matchesCerts: [], checked: false },
		{ key: "liveAnimals", name: "Live Animals", matchesCerts: ["ceiv_live_animals"], checked: false },
		{ key: "dangerousGoods", name: "Dangerous Goods", matchesCerts: [], checked: false },
		{ key: "airmail", name: "Airmail", matchesCerts: [], checked: false },
		{ key: "perishables", name: "Perishables", matchesCerts: ["ceiv_fresh"], checked: false },
		{ key: "pharmaceuticals", name: "Pharmaceuticals", matchesCerts: ["ceiv_pharma"], checked: false }
	];
	

	get stationProfile() {
		let station = {
			recordTypeDevName: this.companyType,
			accountName: this.selectedCompany ? 
							this.selectedCompany.accountInfo.Name : 
							this.account.legalname, 
			nearestAirport: {
				city: this.selectedAirport ? this.selectedAirport.value : null,
			},
			companyId: this.selectedCompany ? 
				this.selectedCompany.accountInfo.Id : 
				null
		}
		return station;
	}

	autoSelection = true;
	airlineHandledItemsToAdd;
	airlineHandledItemsToDel;
	cargoShownOperatingStationIds;
	cargoHideOperatingStationIds;
	rampShownOperatingStationIds;
	rampHideOperatingStationIds;

	manageChildEvent(event) {
		let eventData = event.detail
		if (eventData.error) {
			this.showToast("Error", this.label.icg_error_update_facility, "error");
			return;
		}
		
		if (eventData.name === 'getItemsSelected') {
			this.getItemsSelectedChildEvent(eventData);
		} else if (eventData.name === 'getShownOperationStations') {
			this.getShownOperationStationsChildEvent(eventData);
		} else if (eventData.name === 'getHiddenOperationStations') {
			this.getHiddenOperationStationsChildEvent(eventData);
		}
	}

	getItemsSelectedChildEvent(eventData) {
		if (eventData.name === 'getItemsSelected' && eventData.handlerType === 'airline') {
			this.airlineHandledItemsToAdd = eventData.itemsToAdd;
		}
	}
	getShownOperationStationsChildEvent(eventData) {
		if (eventData.name === 'getShownOperationStations' && eventData.handlerType === 'cargo' && eventData.idsToShow) {
			this.cargoShownOperatingStationIds = eventData.idsToShow;
		}
		if (eventData.name === 'getShownOperationStations' && eventData.handlerType === 'ramp' && eventData.idsToShow) {
			this.rampShownOperatingStationIds = eventData.idsToShow;
		}
	}
	getHiddenOperationStationsChildEvent(eventData) {
		if (eventData.name === 'getHiddenOperationStations' && eventData.handlerType === 'cargo' && eventData.idsToHide) {
			this.cargoHideOperatingStationIds = eventData.idsToHide;
		}
		if (eventData.name === 'getHiddenOperationStations' && eventData.handlerType === 'ramp' && eventData.idsToHide) {
			this.rampHideOperatingStationIds = eventData.idsToHide;
		}
	}




	get showCargoCommoditiesSection(){
		return this.cargoCommodities.length >0;
	}

	@track selectRt;
	@track selectStationName;
	@track existingStationNotif;
	@track existingStationTypeNotif;

	@track ishqboxfocus;
	@track islangboxfocus;
	@track isairportboxfocus;
	@track hqSearchValue = '';
	@track langSearchValue = '';
	@track airportSearchValue = '';
	@track selectedLanguagesList = [];
	@track selectedAirport;

	@track availableAirports = [];
	airportsFetched = false;

	@track objectBeingCreated;
	@track accountCreated;
	@track creatingAccount;
	@track errorCreatingAccount;

	@track creatingStation;
	@track stationCreated;
	@track errorCreatingStation;
	
	get creatingStationAccount(){
		return this.creatingAccount || this.creatingStation;
	}
	
	get stationAccountCreated(){
		return (this.accountCreated && this.stationCreated) || this.stationCreated;
	}
	
	get errorCreatingStationAccount(){
		return this.errorCreatingAccount || this.errorCreatingStation;
	}

	//Determine if is an internal user who creates
	//a station from Account page
	@api isInternalUser = false;
	_recordId;
	@api 
	get recordId(){
		return this._recordId;
	}
	set recordId(value){
		this._recordId = value;
		this.getUserFacilitiesFromAccount();
	}
	@track isLoading;

	clickedFacility;
	parentCompany; //Id of the parent company
	parentGroup; //Name of the ops hierarchy of the account

	account = {
		'legalname':'',
		'tradename':'',
		'phone':'',
		'email':'',
		'website':'',
		'customerType':'',
		'customerTypeSector':'',
		'customerTypeCategory':'',
		'sector':'',
		'category':'',
		'opsHierarchy':''
	};
	address = {
		'isPoBox':false,
		'countryId':'',
		'countryCode':'',
		'countryName':'',
		'stateId':'',
		'stateName':'',
		'cityId':'',
		'cityName':'',
		'street':'',
		'zip':'',
		'validationStatus':0,
		'checkPerformed':false,
		'inputModified':true,
		'geonameWarning1':'',
		'geonameWarning2':'',
		'addressSuggestions':[]
	};

	createdCityId;
	@track duplicatedStationsByType;
	@track duplicatedStationsByName;

	updatedLatitude;
	updatedLongitude;

	@track onAirportOperatingCHF = [];
	@track onAirportRampH = [];
	
	@wire(getAvailableLanguages, {})
	wiredLanguages({ data }) {
		if (data) {
			this.availableLanguages = JSON.parse(data);
		}
	}
	@wire(generateOpeningHours, {})
	wiredOpeningHours({ data }) {
		if (data) {
			this.openingHours = JSON.parse(JSON.stringify(data));
			Object.keys(this.openingHours).forEach(key => {
				this.openingHours[key].days.forEach(day =>{
					day.empty = false;
				})
			})
		}
	}
	@api
	get userFacilities() {
		return this.facilityList || [];
	}
	set userFacilities(values) {
		let copiedValues = JSON.parse(JSON.stringify(values));
		this.initializeUserFacilities(copiedValues);
	}
	@api userInfo;
	@api companyInfo;
	@track _potentialDupFacilities = [];
	initialized = false;
	@wire(getCompanyTypes, {})
	wiredCompanyTypes({ data }) {
		if (data) {
			this.companyTypesRaw = JSON.parse(data);
		}
	}
	@wire(getCountries, {})
	wiredCountries({ data }) {
		if (data) {
			this.countries = JSON.parse(data);
		}
	}
	@wire(getArdTypesBySectorAndCategory, {})
	wiredArdTypesBySectorAndCategory({ data }) {
		if (data) {
			this.ctypesMapBySectorAndCategory = JSON.parse(data);
		}
	}
	selectHQCountry(event){
		this.selectedHQCountry = event.detail.item;
		this.hqSearchValue = event.detail.value;
		this.step = 2;
	}
	formToJSON = elements =>
		[].reduce.call(
			elements,
			(data, element) => {
				if (element.name === "recordtype") {
					this.companyTypesRaw.forEach(elem => {
						if (elem.rtid === element.value) elem.selected = true;
						else elem.selected = false;
					});
				} 
				if (
					element.name &&
					element.name.indexOf("startAt") < 0 &&
					element.name.indexOf("endAt") < 0
				) {
					if (element.type !== "checkbox") data[element.name] = element.value;
					else if (element.type === "checkbox")
						data[element.name] = element.checked;
				}
				return data;
			},
			{}
		);
	emptyFormJSON = elements =>
		[].reduce.call(
			elements,
			(data, element) => {
				if (element.name) data[element.name] = "";
				return data;
			},
			{}
		);

	next(event) {
		event.preventDefault();
		this.closeFacilityNameAndTypeModal();
		this.closeStationInNewAddressPrompt();
		let validFields = this.checkFormFields(true);
		if (validFields) {
			this.collectFormData();
			this.step = event.currentTarget.dataset.substep ? Number((this.step + 0.1).toFixed(1)) : (~~this.step)+1;
			if (event.currentTarget.dataset.sameadress) {
				this.formData.sameaddress = event.currentTarget.dataset.sameadress === "yes";
			}
		}
		this.airportSelectorEventListenersAdded = false;
		this.languageSelectorEventListenersAdded = false;
		if (validFields) {
			this.scrollToTop();
		}
	}
	checkFormFields(isNextCall) {
		const inputValid = [...this.template.querySelectorAll("input")].reduce(
			(validSoFar, inputCmp) => {
				if (validSoFar) inputCmp.reportValidity();
				return validSoFar && inputCmp.checkValidity();
			},
			true
		);
		const selectValid = [...this.template.querySelectorAll("select")].reduce(
			(validSoFar, inputCmp) => {
				if (validSoFar) inputCmp.reportValidity();
				return validSoFar && inputCmp.checkValidity();
			},
			true
		);
		
		let validNearestAirpot = this.step === 3 ? false : true;
		validNearestAirpot = isNextCall ? validNearestAirpot : true;
		
		if (this.selectedAirport){
			validNearestAirpot = true;
		}
		else{
			let nearestAiport = this.template.querySelector('.nearestairportsearchbox');
			if (nearestAiport){
				nearestAiport.focus();
			}
		}

		return inputValid && selectValid && validNearestAirpot;
	}

	back(event) {
		event.preventDefault();
		this.collectFormData();
		if(this.step === 2){
			if(this.formData.sameaddress) this.step=1;
			else this.step=1.1
		}else{
			if (event.currentTarget.dataset.substep)
			this.step = Number((this.step - 0.1).toFixed(1));
			else this.step--;
		}
		this.airportSelectorEventListenersAdded = false;
		this.languageSelectorEventListenersAdded = false;
		this.scrollToTop();
	}



	getBasicFormData() {
		let formu = this.template.querySelector(".basicdataform");
		if (formu && formu.elements) {
			let newFormData = this.formToJSON(formu.elements);
			Object.keys(newFormData).forEach(key => {
				this.formData[key] = newFormData[key];
			});
		}
	}
	getRtAndNameFormData(){
		let formu = this.template.querySelector(".selectRtModal");
		if (formu && formu.elements) {
			let newFormData = this.formToJSON(formu.elements);
			Object.keys(newFormData).forEach(key => {
				this.formData[key] = newFormData[key];
			});
		}
	}
	getAdditionalFormData() {
		let formu = this.template.querySelector(".additionaldataform");
		if(formu && formu.elements){
			this.additionalData = this.formToJSON(formu.elements);
		}
	}
	beforeSummaryAction() {
		let formu = this.template.querySelector(".additionaldataform");
		if(formu && formu.elements){
			this.additionalData = this.formToJSON(formu.elements);
			this.additionalData.openingHours = JSON.stringify(this.openingHours);
			this.additionalData.generalCargo = this.cargoCommodities[0].checked;
			this.additionalData.liveAnimals = this.cargoCommodities[1].checked;
			this.additionalData.dangerousGoods = this.cargoCommodities[2].checked;
			this.additionalData.airmail = this.cargoCommodities[3].checked;
			this.additionalData.perishables = this.cargoCommodities[4].checked;
			this.additionalData.pharmaceuticals = this.cargoCommodities[5].checked;
		}
	}
	initializeBasicFormData() {
		let formu = this.template.querySelector(".basicdataform");
		if (formu) {
			this.formData = this.emptyFormJSON(formu.elements);
			if (this.companyInfo && this.companyInfo.IATA_ISO_Country__c){
				this.formData.disabledcountry = this.companyInfo.IATA_ISO_Country__r.Name;
			}
				
			if (this.companyInfo && this.companyInfo.Business_City__c){
				this.formData.disabledcity = this.companyInfo.Business_City__r.Name;
			}
				
			if (this.companyInfo && this.companyInfo.Business_Street__c){
				this.formData.disabledstreet = this.companyInfo.Business_Street__c;
			}
				
			if (this.companyInfo && this.companyInfo.Business_Postal_Code__c){
				this.formData.disabledzip = this.companyInfo.Business_Postal_Code__c;
			}
				
			if (this.companyInfo && this.companyInfo.Business_State_Name__c){
				this.formData.disabledstate = this.companyInfo.Business_State_Name__c;
			}
				
		}
	}
	initializeadditionalFormData() {
		let formu = this.template.querySelector(".additionaldataform");
		if(formu && formu.elements) this.additionalData = this.emptyFormJSON(formu.elements);
	}
	initializeRtAndNameModal() {
		let formu = this.template.querySelector(".selectRtModal");
		if (formu && formu.elements) {
			let emptyFormData = this.emptyFormJSON(formu.elements);
			Object.keys(emptyFormData).forEach(key => {
				if (!this.formData[key]) this.formData[key] = emptyFormData[key];
			});
		}
	}
	collectFormData() {
		//Remove any hover
		this.removeHoverDiv();
		this.clickedFacility = false;
		////
		if (this.step >= 1 && this.step < 2) {
			this.getBasicFormData();
		} else if (this.step >=2 && this.step < 3) {
			this.getRtAndNameFormData();
		} else if (this.step === 3) {
			
			this.airlineHandledItemsToDel = [];
			this.template.querySelectorAll("c-cw-handler-detail").forEach(element => {
				if (element.handlerType === 'airline') {
					element.getItemsSelected();
				}else if (element.handlerType === 'cargo') {
					element.getShownOperationStations();
					element.getHiddenOperationStations();
				}else if (element.handlerType === 'ramp') {
					element.getShownOperationStations();
					element.getHiddenOperationStations();
				}
			});
			this.getAdditionalFormData();
		}else if (this.step === 4) {
			this.beforeSummaryAction();
		}
	}
	renderedCallback() {
		if (!this.initialized) {
			if(this.companyInfo){
				this.initializeBasicFormData();
			}else{
				getUserCompanyInfo({accountId:this.recordId}).then(result =>{
					this.companyInfo = JSON.parse(result);
					this.initializeBasicFormData();
				})

			}
			this.initialized = true;
			Promise.all([
				loadStyle(this, resources + "/css/portal.css")
			]);
			if(this.isInternalUser){
				Promise.all([
					loadStyle(this, resources + "/css/internal.css")
				]);

				this.template.querySelector('.formcontainer').classList.add('mb-4');
			}
		}
		this.addEventListeners();

		if (this.facilityDetailsStep) {
			if (!this.additionalDataInitialized) {
				this.initializeadditionalFormData();
				this.additionalDataInitialized = true;
			}
			if(this.availableAirports.length === 0 && !this.airportsFetched){
				fetchAirports().then(data =>{
					this.availableAirports = data;
					this.airportsFetched = true;
				})
				
			}
			this.setLogoPreview(null);
		}
		if (this.summaryStep) {
			this.setLogoPreview(null);
		}
		if(this.setFacilityNameAndType){
			this.initializeRtAndNameModal();
		}
		this.loadHandlingService();
	}
	addEventListeners() {
		let elems = this.template.querySelectorAll(".stationhover");
		if (elems && elems.length > 0) {
			if (!this.hoverFacilitiesEventListenersAdded) {
				elems.forEach(elem => {
					elem.addEventListener("mouseover", event => {
						if (!this.clickedFacility) {
							this.viewHoverDiv(event.currentTarget.parentElement.parentElement.dataset.group,event.currentTarget.parentElement.parentElement.dataset.key, event.currentTarget.dataset.type, event.currentTarget.parentElement.parentElement.dataset.isbranch, event);
						}

					});
					elem.addEventListener("mouseout", event => {
						if (!this.clickedFacility) {
							this.removeHoverDiv();
						}
					});
					elem.addEventListener("blur", event => {
						this.clickedFacility = false;
						this.removeHoverDiv();
					});
					elem.addEventListener("click", event => {
						let isbranch = event.currentTarget.parentElement.parentElement.dataset.isbranch ? true : false;
						let elemkey = event.currentTarget.parentElement.parentElement.dataset.key + ';' + event.currentTarget.dataset.type + ';' + isbranch;
						if (this.clickedFacility) {
							this.removeHoverDiv();
							if (this.clickedFacility !== elemkey) {
								this.viewHoverDiv(event.currentTarget.parentElement.parentElement.dataset.group,event.currentTarget.parentElement.parentElement.dataset.key, event.currentTarget.dataset.type, isbranch, event);
								this.clickedFacility = elemkey;
							} else {
								this.clickedFacility = false;
							}



						} else {
							this.clickedFacility = elemkey;
						}
					});
				});
				this.hoverFacilitiesEventListenersAdded = true;
			}
		} else {
			this.hoverFacilitiesEventListenersAdded = false;
		}

		//PredictiveBox HQ Listener
		let hqbox = this.template.querySelector('[data-tosca="hqcountryinput"]');
		if (hqbox && !this.hqPredictiveInputEventsListenersAdded) {
			hqbox.addEventListener("focus", event => {
				this.hqPredictiveSearch();
			});
			hqbox.addEventListener("blur", event => {
				this.ishqboxfocus = false;
			});
			this.hqPredictiveInputEventsListenersAdded = true;
		}
		//PredictiveBox Languages Listener
		let langbox = this.template.querySelector('[data-tosca="languagesinput"]');
		if (langbox && !this.languageSelectorEventListenersAdded) {
			langbox.addEventListener("focus", event => {
				this.getAdditionalFormData();
				this.langPredictiveSearch();
			});
			langbox.addEventListener("blur", event => {
				this.islangboxfocus = false;
			});
			this.languageSelectorEventListenersAdded = true;
		}

		//PredictiveBox NearestAiroprt Listener
		let airportbox = this.template.querySelector('[data-tosca="nearestairportinput"]');
		if (airportbox && !this.airportSelectorEventListenersAdded) {
			airportbox.addEventListener("focus", event => {
				this.getAdditionalFormData();
				this.airportPredictiveSearch();
				
			});
			airportbox.addEventListener("blur", event => {
				this.isairportboxfocus = false;
			});
			this.airportSelectorEventListenersAdded = true;
		}
	}

	removeHoverDiv() {
		this.hoveredCompany = null;
		this.hoveredFacilities = null;
		const infoWindow = this.template.querySelector(".popover-custom");
		const classElement = infoWindow.classList.value;

		if (!classElement.includes("_hide")) {
			infoWindow.classList = classElement.replace(
				"slds-popover",
				"slds-popover_hide"
			);
		}
	}

	viewHoverDiv(groupnm,key, type, isbranch, event) {
		if (!isbranch) {
			this._potentialDupFacilities.forEach(gr => {
				if (gr.groupName === groupnm){
					gr.companyList.forEach(acc => {
						if (acc.accountInfo.Id === key) this.hoveredCompany = acc;
					})
				}
			});
		} else {
			//Not working with branches yet
			this._potentialDupFacilities.forEach(group => {
				if (group.groupName === groupnm){
					group.companyList.forEach(acc => {
						if (acc.accountInfo.Id === key) this.hoveredCompany = acc;
					})
				}
				return returnValue;
			});
		}
		this.hoveredFacilities = this.hoveredCompany ? this.hoveredCompany.stations.filter(
			fac => {
				return fac.RecordType.Name === type;
			}
		) : [];
		if (event) {
			let infoWindow = this.template.querySelector(".popover-custom");
			let bounds = event.currentTarget.getBoundingClientRect();
			infoWindow.style.left =
				"calc(" + (bounds.left + bounds.width / 2) + "px - 1.5rem)"; //bounds.left + bounds.width + 20 + "px";
			infoWindow.style.top = bounds.top + 40 + "px";
			const classElement = infoWindow.classList.value;
			if (classElement.includes("_hide")) {
				infoWindow.classList = classElement.replace(
					"slds-popover_hide",
					"slds-popover"
				);
			}
		}
	}

	becomeFacilityAdminJS(event) {
		let facilityId = event.target.dataset.facility;
		this.requesting = true;
		becomeFacilityAdmin({
			companyId: event.target.dataset.companyid,
			facilityIds: facilityId,
			contactId: this.userInfo.ContactId
		})
			.then(resp => {
				let parsedRes = JSON.parse(resp);
				this.modalMessage = parsedRes.message;
				this.modalImage = this.CHECKED_IMAGE;
				this.dispatchEvent(new CustomEvent("refresh"));
				this.showModal = true;
				this.requesting = false;
				this.removeHoverDiv();
			})
			.catch(err => {
				this.modalMessage = this.label.icg_error_message;
				this.modalImage = this.ERROR_IMAGE;
				this.showModal = true;
				this.requesting = false;
			});
	}

	selectParentAccount(event) {
		this.parentCompany = event.currentTarget.dataset.companyid;
		this.parentGroup = event.currentTarget.dataset.groupname;
		this.setFacilityNameAndType = true;
		//first select record type... then, select the name.
		this.selectRt = true;
	}

	closeFacilityNameAndTypeModal(){
		this.selectStationName = false;
		this.selectRt = false;
		this.existingStationTypeNotif = false;
		this.existingStationNotif = false;
		this.setFacilityNameAndType = false;
	}

	selectRtypeAndNameJS(event){
		this.existingStationTypeNotif = false;
		this.existingStationNotif = false;
		this.duplicatedStationsByType=[];
		this.duplicatedStationsByName=[];
		if (this.checkFormFields()){
			this.collectFormData();
			if(this.selectRt){
				if(this.selectedCompany && this.selectedCompany.stations){
					this.selectedCompany.stations.forEach(st =>{
						if(st.RecordTypeId === this.formData.recordtype) {
							this.existingStationTypeNotif = true;
							if(!this.isInternalUser) st.privateAreaLink = '#ID:'+st.Id;
							else st.privateAreaLink = '/'+st.Id;
							this.duplicatedStationsByType.push(st);
						}
					})
				}
				if(!this.existingStationTypeNotif){
					this.selectRt = false;
					this.selectStationName = true;
					this.setFocusStationName();
				} 
			}else if(this.selectStationName){
				if(this.selectedCompany && this.selectedCompany.stations){
					this.selectedCompany.stations.forEach(st =>{
						if(st.RecordTypeId === this.formData.recordtype && st.Name.toLowerCase().replace(/\s+/g, '') ===this.formData.name.toLowerCase().replace(/\s+/g, '')) {
							this.existingStationNotif = true;
							st.privateAreaLink = '#'+st.Id;
							this.duplicatedStationsByName.push(st);
						}
					})
				}
				if(!this.existingStationNotif){
					this.next(event);
				}
			}
		}
	}
	continueOrBackSelectRtAndName(event){
		this.existingStationTypeNotif = false;
		this.existingStationNotif = false;
		if(event.currentTarget.dataset.continue){
			this.selectRt = false;
			this.selectStationName = true;
			this.setFocusStationName();
		}else{
			this.selectRt = true;
			this.selectStationName=false;
		}
		this.loadHandlingService();
	}

	setGeocoordinates(event){
		this.updatedLatitude = event.detail.latitude;
		this.updatedLongitude = event.detail.longitude;

		this.geoLocationInfoObject = {
			longitude: this.updatedLongitude,
			latitude: this.updatedLatitude
		}
		
	}

	createFacilityJS() {
		this.stationCreationPrompt = true;
		if(!this.selectedCompany){
			this.objectBeingCreated = 'Account';
			this.creatingAccount = true;
			this.creatingStation = true;
			let account = this.registerNewAccount()
			// Check first if we need to create a Geoname city
			if(this.selectedAddressObject.stateId !== '' && this.selectedAddressObject.cityId === ''){
				createIsoCity({name : this.selectedAddressObject.city, stateId: this.selectedAddressObject.stateId, isPoBox: false})
				.then(result => {
					this.createdCityId = result;
					this.createCompany(account);
				})
				.catch(error => {
					this.creatingAccount = false;
					this.accountCreated = false;
					this.errorCreatingStation = true;
					this.modalMessage = this.label.icg_error_message;
				});
			}
			else{
				this.createCompany(account);
			}
		}else {
			this.creatingStation = true;
			if(!this.selectedCompany.accountInfo.Business_Geo_Coordinates__Longitude__s || !this.selectedCompany.accountInfo.Business_Geo_Coordinates__Latitude__s){
				//Not using standard UpdateRecord because we need to avoid sharing to update any Account
				updateAccountCoordinates({
					accId : this.selectedCompany.accountInfo.Id,
					latitude : this.updatedLatitude,
					longitude : this.updatedLongitude
				})
			}
			this.registerStation();
		}
	}
	
	createCompany(account){
		createDummyCompany({account: JSON.stringify(account), opsHierarchy : this.account.opsHierarchy, isNewHierarchy : this.account.isNewOpsHierarchy}).then(resp => {
			let parsedRes = JSON.parse(resp);
			this.creatingAccount = false;
			this.accountCreated = parsedRes.success;
			this.errorCreatingAccount = !parsedRes.success;
			if (parsedRes.success){
				this.parentCompany = parsedRes.message;
				this.registerStation();
			}else{
				this.errorCreatingStation = true;
				this.modalMessage = parsedRes.message;
			}
		}).catch( ex => {
			this.creatingAccount = false;
			this.accountCreated = false;
			this.errorCreatingStation = true;
			this.modalMessage = this.label.icg_error_message;
		});
	}

	get isCompanyAdminOfSelectedOpsHierarchy(){
		let isAdmin = false;
		this.userFacilities.forEach(group => {
			if(group.groupName === (this.parentGroup || this.account.opsHierarchy) && group.isCompanyAdmin) isAdmin = true;
		})
		return isAdmin;
	}

	get onlinePlatform(){
		return this.additionalData && this.additionalData.onlineplatform ? this.additionalData.onlineplatform : this.label.icg_https_default_value;;
	}

	get websiteValue(){
		return this.additionalData && this.additionalData.website ? this.additionalData.website : this.label.icg_https_default_value;
	}

	get pilotInfoValue(){
		return this.additionalData && this.additionalData.pilotinfo ? this.additionalData.pilotinfo : this.label.icg_https_default_value;
	}
	
	get onlinePlatformSummaryValue(){
		if (this.additionalData && this.additionalData.website){
			return this.additionalData.website === this.label.icg_https_default_value ? '' : this.additionalData.website;
		} 
		else{
			return '';
		}
	}
	
	get websiteSummaryValue(){
		if (this.additionalData && this.additionalData.onlineplatform){
			return this.additionalData.onlineplatform === this.label.icg_https_default_value ? '' : this.additionalData.onlineplatform;
		} 
		else{
			return '';
		}
	}

	registerStation(){
		this.objectBeingCreated = 'Station';
		let station = {
			sobjectType: 'ICG_Account_Role_Detail__c',
			Name : this.formData.name,
			RecordTypeId : this.formData.recordtype,
			Number_of_Employees__c : parseInt(this.additionalData.noemployees || 0,10),
			Number_of_Facilities__c : parseInt(this.additionalData.nofacilities || 0,10),
			Overall_Facility_Size_m2__c : (this.companyType === "Cargo_Handling_Facility") ? parseInt(this.additionalData.overallFacilitySizeM2 || 0,10) : 0,
			Overall_Airport_Size__c : (this.companyType === "Airport_Operator") ? parseInt(this.additionalData.overallFacilitySizeM2 || 0,10) : 0,
			Fleet__c : parseInt(this.additionalData.fleet || 0,10),
			Customer_Service_Email__c : this.additionalData.email,
			Customer_Service_Phone_Number__c : this.additionalData.phone,
			Website__c : this.additionalData.website,
			Online_Booking_System_Link__c : this.additionalData.onlineplatform,
			Status__c : this.isInternalUser ? 'Approved' : 'Pending for Approval',
			Available_Languages__c : this.selectedLanguages,
			Opening_Hours__c : JSON.stringify(this.openingHours),
			Is_On_Airport__c : this.additionalData.onairport,
			IATA_ISO_Country__c : this.selectedAddressObject.countryId,
			Hidden_Operating_Stations__c : this.hiddenOperatingStations,
			Pilot_Information__c : this.additionalData.pilotinfo,
			Secondary_Address__c : this.additionalData.stationsecondaddress,
			Is_Direct_Ramp_Access__c : this.additionalData.directrampaccess,
			General_Cargo__c : this.additionalData.generalCargo,
			Live_Animals__c : this.additionalData.liveAnimals,
			Dangerous_Goods__c : this.additionalData.dangerousGoods,
			Airmail__c : this.additionalData.airmail,
			Perishables__c : this.additionalData.perishables,
			Pharmaceuticals__c : this.additionalData.pharmaceuticals,
			Road_Feeder_Services__c : this.additionalData.roadFeederServices
		}
		
		if (this.showRampHours()){
			station.In_House_Services__c = this.inHouseServicesValue;
			station.Third_Party_Services__c = this.thirdPartyServicesValue;
		}
		
		let accountId = this.parentCompany ? this.parentCompany : this.userInfo.AccountId;
		if(this.geoLocationInfoObject){
			this.geoLocationInfoObject.companyId = accountId;
		}
		else {
			this.geoLocationInfoObject = {
				companyId: accountId
			}
		}
		createFacility({
			accountId: accountId,
			station : JSON.stringify(station),
			logoInfo: JSON.stringify(this.logoInfoObject),
			geoLocationInfo: JSON.stringify(this.geoLocationInfoObject),
			ardRelIds : this.ardRelIds,
			nearestAirportCode : this.selectedAirport ? this.selectedAirport.value : null,
			isCompanyAdmin: this.isCompanyAdminOfSelectedOpsHierarchy,
			isInternalUser: this.isInternalUser,
			isNewAccount : !this.selectedCompany,
			stationsToAdd : JSON.stringify(this.stationsToAdd),
			stationsToRemove : JSON.stringify(this.stationsToRemove),
		})
			.then(resp => {
				let parsedRes = JSON.parse(resp);
				this.creatingStation = false;
				this.stationCreated = parsedRes.success;
				this.creatingAccount = this.stationCreated ? false : this.creatingAccount;

				this.errorCreatingStation = !parsedRes.success;
				if(this.isInternalUser){
					this.modalMessage = this.label.icg_station_has_been_created;
				}else{
					this.modalMessage = parsedRes.message;
				}				
				if (parsedRes.success) {
					this.goToHome = true;
					this.dispatchEvent(new CustomEvent("refresh"));
					if(this.isInternalUser){
						this.step = 1;

						if(parsedRes.obj){
							this.createdStation = parsedRes.obj
						}
					} 
				}
			})
			.catch(err => {
				this.creatingStation = false;
				this.stationCreated = false;
				this.errorCreatingStation = true;
				this.modalMessage = this.label.icg_error_message;
			});
	}

	navigateToRecordViewPage(recordId) {
		this[NavigationMixin.GenerateUrl]({
			type: 'standard__recordPage',
			attributes: {
				recordId: recordId,
				actionName: 'view'
			}
		}).then(url => {
			window.open(url);

			if(this.isInternalUser){
				window.location.reload();
			}
		   });
	}

	setLogoPreview(event) {
		if(event) this.getAdditionalFormData();
		let logoInput = this.template.querySelector('[id*="logoimage"]');
		//that means we have the input file element
		if (logoInput) {
			let files;
			if (event && logoInput.files && logoInput.files.length > 0) {
				this.logoImage = logoInput.files;
				files = logoInput.files;
			}
			else {
				logoInput.files = this.logoImage;
				files = this.logoImage;
			}
			if (files && files[0]) {
				let reader = new FileReader();
				reader.onload = e => {
					this.template
						.querySelector('[id*="logopreview"]')
						.setAttribute("src", e.target.result);
					this.logoInfoObject = this.setFileInfo(
						logoInput.files[0],
						e.target.result.match(/,(.*)$/)[1]
					);
				};
				reader.readAsDataURL(logoInput.files[0]);
			} else {
				if (this.logoImage && this.logoImage[0]) {
					let reader = new FileReader();
					reader.onload = e => {
						this.template
							.querySelector('[id*="logopreview"]')
							.setAttribute("src", e.target.result);
					};
					reader.readAsDataURL(this.logoImage[0]);
				}else{
					this.logoInfoObject = this.setFileInfo(null, null);
					this.template.querySelector('[id*="logopreview"]').setAttribute('src', '');
				}
			}
		} else {
			if (this.logoImage && this.logoImage[0]) {
				let reader = new FileReader();
				reader.onload = e => {
					this.template
						.querySelector('[id*="logopreview"]')
						.setAttribute("src", e.target.result);
				};
				reader.readAsDataURL(this.logoImage[0]);
			}else{
				this.logoInfoObject = this.setFileInfo(null, null);
				this.template.querySelector('[id*="logopreview"]').setAttribute('src', '');
			}
		}
	}
	removeLogoInput(event){
		event.preventDefault();
		this.getAdditionalFormData();
		this.logoImage = null;
		this.logoInfoObject = this.setFileInfo(null, null);
		this.template.querySelector('[id*="logopreview"]').removeAttribute('src');
	}

	setFileInfo(file, base64Data) {
		let fileInfo = {};
		if (file) {
			fileInfo = {
				fileName: file.name,
				base64Data: base64Data,
				contentType: file.type
			};
		}
		return fileInfo;
	}

	handleDaysUpdated(event) {
		this.getAdditionalFormData();
		let keys = event.detail.key.split("_");
		let days = event.detail.days;
		this.openingHours['data' + keys[0].charAt(0).toUpperCase() + keys[0].slice(1)].days = days;
	}

	getAccountInfo(){
		let companyInformation= this.template.querySelector('c-cw-station-creation-company-information');
		if(companyInformation) {
			this.account = JSON.parse(JSON.stringify(companyInformation.getCompanyInformation()));
		}		
	}
	getAddressInfo(){
		let addressInformation= this.template.querySelector('c-cw-station-creation-address-information');
		if(addressInformation) {
			this.address = JSON.parse(JSON.stringify(addressInformation.getAddressInformation()));
		}		
	}
	goToBasicForm() {
		this.collectFormData();
		this.step = 1;
		this.scrollToTop();
	}
	goToSelectCountryForm() {
		this.collectFormData();
		this.step = 1.1;
		this.scrollToTop();
	}
	goToCheckDups() {
		this.collectFormData();
		this.step = 2;
		this.scrollToTop();
	}
	goToCreateHQStep(){
		this.closeStationInNewAddressPrompt();
		this.parentCompany = null;
		this.parentGroup = null;
		this.step = 2.1;
		this.scrollToTop();
	}
	goToSetAddressStep(){
		this.getAccountInfo();
		this.step = 2.2;
		this.scrollToTop();
	}
	goToAdvancedForm() {
		if(this.accountCreationPrompt){
			this.setFacilityNameAndType = true;
			//first select record type... then, select the name.
			this.selectRt = true;
			this.accountCreationPrompt = false;
		}else{
			this.step = 3;
		}
	}
	

	addressInfoCompleted(event){
		this.getAddressInfo();
		this.accountCreationPrompt = true;
	}

	scrollToTop(){
		let selector = '[data-name="top"]';
		let scrollobjective = this.template.querySelector(selector);
		scrollobjective.scrollIntoView({ behavior: 'smooth', block:'start' });
	}

	invalidFilterValue(value){
		return !value || value.length < 3;
	}

	generateValueFromEvent(event, value){
		return event && event.target ? event.target.value : value ? value : "";
	}

	hqPredictiveSearch(event) {
		this.ishqboxfocus = true;
		this.predictiveValues = [];
		this.hqSearchValue = this.generateValueFromEvent(event, this.hqSearchValue);
		if (this.invalidFilterValue(this.hqSearchValue)) {
			return;
		}
		this.predictiveValues = this.countries.filter(entry => {
			let isNumber = /^\d+$/.test(entry.ISO_Code__c);
			return entry.Name.toLowerCase().indexOf(this.hqSearchValue.toLowerCase()) > -1  && !isNumber;
		}) 
		.map(element => {
			return {
				value: element.Id,
				key: element.Id,
				label: element.Name
			}
		});
	}

	langPredictiveSearch(event) {
		this.islangboxfocus = true;
		this.predictiveValues = [];
		this.langSearchValue = this.generateValueFromEvent(event, this.langSearchValue);
		if (this.invalidFilterValue(this.langSearchValue)) {
			return;
		}
		this.predictiveValues = this.availableLanguages.filter(entry => {
			return entry.value.toLowerCase().indexOf(this.langSearchValue.toLowerCase()) > -1;
		})
		.map(element => {
			return {
				value: element.value,
				key: element.value,
				label: element.label
			}
		});
	}

	airportPredictiveSearch(event) {
		this.isairportboxfocus = true;
		this.predictiveValues = [];
		this.airportSearchValue = this.generateValueFromEvent(event, this.airportSearchValue);
		if (this.invalidFilterValue(this.airportSearchValue)) {
			return;
		}

		this.predictiveValues = Object.values(this.availableAirports).filter(entry => {
			return entry.description.toLowerCase().indexOf(this.airportSearchValue.toLowerCase()) > -1 || entry.keyName.toLowerCase().indexOf(this.airportSearchValue.toLowerCase()) > -1;
		})
		.map(element => {
			return {
				value: element.code,
				key: element.code,
				label: element.description,
			}
		});
	}

	createStationInNewAddress(){
		this.newAddressPrompt = true;
	}
	closeStationInNewAddressPrompt(){
		this.newAddressPrompt = false;
	}
	
	closeNewAccountCreationPrompt(){
		this.accountCreationPrompt = false;
	}
	closeStationCreationPrompt(){
		if(!this.stationCreationCompleted) return;
		this.stationCreationPrompt = false;
		this.accountCreated = false;
		this.modalMessage = null;
		this.stationCreated = false;

		if (!this.errorCreatingStation) {		
			this.dispatchEvent(new CustomEvent("gotohome"));
			this.goToHome = false;

			if(this.createdStation && this.isInternalUser){
				this.navigateToRecordViewPage(this.createdStation.Id);
			}
		}else{
			this.creatingStation = false;
			this.errorCreatingStation = false;
			this.creatingAccount = false;
			this.accountCreated = false;
			this.errorCreatingAccount = false;
		}

	}

	get showOperatingCHFandRampH() {
		return ((this.companyType === 'Airport_Operator' || this.companyType === 'Airline') && this.selectedAirport);
	}

	setLanguages(event) {
		event.preventDefault();
		this.getAdditionalFormData();
		if(this.selectedLanguagesList){
			let exists = this.selectedLanguagesList.filter(elem =>{
				return elem.value === event.detail.item;
			})
			if(exists.length === 0) this.selectedLanguagesList.push({value: event.detail.item, label: event.detail.value})
			this.langSearchValue = '';
		}
	}

	setNearestAirport(event){
		event.preventDefault();
		this.getAdditionalFormData();
		this.selectedAirport = {value: event.detail.item, label: event.detail.value}
		if(this.companyType === 'Airline' || this.companyType === 'Airport_Operator') this.getOnAirportStationsJS();
		this.airportSearchValue = '';
	}

	getOnAirportStationsJS(){
		this.onAirportOperatingCHF = [];
		this.onAirportRampH = [];
		getOnAirportStations({rtype : this.companyType, accountName : this.selectedCompany ? this.selectedCompany.accountInfo.Name : this.account.legalname, airportId : this.selectedAirport.value, accountId : this.selectedCompany ? this.selectedCompany.accountInfo.Id : null }).then(res => {
			let parsedRes = JSON.parse(res);
			parsedRes.forEach(station => {
				station.originallySelected = station.selected;
				this.populateOperatingStations(station);
			})
			
			let cmpCHF = this.template.querySelector(".cmpOperatingCHF");
			if (cmpCHF){
				cmpCHF.rawData = this.onAirportOperatingCHF;
				cmpCHF.RefreshData();
			}
			
			let cmpRamp = this.template.querySelector(".cmpRampHandlers");
			if (cmpRamp){
				cmpRamp.rawData = this.onAirportRampH;
				cmpRamp.RefreshData();
			}

		})
	}
	populateOperatingStations(station){
		switch (station.recordTypeDevName) {
			case "Cargo_Handling_Facility":
				this.onAirportOperatingCHF.push(station);
				break;
			case "Ramp_Handler":
				this.onAirportRampH.push(station);
				break;
			default:
				break;
		}
	}

	get hiddenOperatingStations(){
		let hiddenOperatingStation = [];
		if(this.companyType === 'Airport_Operator'){
			if (this.cargoHideOperatingStationIds) {
				hiddenOperatingStation.push('OperatingCargo:' + this.cargoHideOperatingStationIds.join(','));
			}
			if (this.rampHideOperatingStationIds) {
				hiddenOperatingStation.push('OperatingRamp:' + this.rampHideOperatingStationIds.join(','));
			}
		}
		return hiddenOperatingStation.join('|');
	}

	get stationsToAdd(){
		return [];
	}
	get stationsToRemove(){
		let idsToRemove = [];
		if (this.cargoHideOperatingStationIds) {
			this.cargoHideOperatingStationIds.forEach(currentItem => {
				if (currentItem && currentItem.trim().length > 0) {
					idsToRemove.push(currentItem);
				}
			});
		}
		if (this.rampHideOperatingStationIds) {
			this.rampHideOperatingStationIds.forEach(currentItem => {
				if (currentItem && currentItem.trim().length > 0) {
					idsToRemove.push(currentItem);
				}
			});
		}
		return idsToRemove;
	}

	removeLang(event){
		event.preventDefault();
		this.getAdditionalFormData();
		this.selectedLanguagesList = this.selectedLanguagesList.filter(lang => {
			return lang.value != event.currentTarget.dataset.value;
		})
	}
	removeSelectedAirport(event){
		event.preventDefault();
		this.getAdditionalFormData();
		this.selectedAirport = null;
		this.onAirportOperatingCHF = [];
		this.onAirportRampH = [];
	}
	removeCargoCommodities(event){
		event.preventDefault();
	}
	
	get selectedLanguages() {
		let selectedLanguages = "";
		if (this.selectedLanguagesList) {
			this.selectedLanguagesList.forEach(lang => {
				selectedLanguages += lang.value + ";";
			});
		}
		return selectedLanguages;
	}

	get setBasicInfoStep() {
		return this.step >= 1 && this.step < 2;
	}
	get selectCountryStep() {
		return this.step === 1.1;
	}
	get checkDuplicatesStep() {
		return this.step === 2;
	}
	get createHQStep() {
		return this.step === 2.1;
	}
	get setAddressStep() {
		return this.step === 2.2;
	}
	get facilityDetailsStep() {
		return this.step === 3;
	}
	get summaryStep() {
		return this.step === 4;
	}
	get duplicatesFound() {
		return (
			this.potentialDupFacilities && this.potentialDupFacilities.length > 0
		);
	}

	get companyType() {
		let ctype = "";
		if (this.formData.recordtype && this.formData.recordtype != "") {
			this.companyTypesRaw.forEach(elem => {
				if (elem.rtid === this.formData.recordtype) ctype = elem.value;
			});
		}
		return ctype;
	}
	get companyTypes() {
		let sector = !this.selectedCompany ? this.account.sector : this.selectedCompany.accountInfo.Sector__c;
		let category = !this.selectedCompany ? this.account.category : this.selectedCompany.accountInfo.Category__c;

		this.companyTypesRaw.forEach(ctype => {
			if (sector && category && ctype.value) {
				ctype.available = this.isCompanyTypeAvailable(sector.toLowerCase(), category.toLowerCase(), ctype.value.toLowerCase());
			} else {
				ctype.available = false;
			}
		});
		return this.companyTypesRaw;
	}

	get classMainlyContainer() {
		if (this.facilityDetailsStep){
			return 'col-lg-8 col-md-12 formcontainer additionaldataform';
		}
		else if (this.summaryStep){
			return 'col-8 formcontainer summarystep';
		}

		return '';
	}

	get mainlyContainer(){
		if (this.facilityDetailsStep || this.summaryStep){
			return true;
		}
		return false;
	}

	isCompanyTypeAvailable(sector, category, ctypeName) {
		for (let sectorX = 0; sectorX < this.ctypesMapBySectorAndCategory.sectors.length; sectorX++){
			if ((this.ctypesMapBySectorAndCategory.sectors[sectorX].sectorName.toLowerCase() === sector || this.ctypesMapBySectorAndCategory.sectors[sectorX].sectorLabel.toLowerCase() === sector )
				&& this.ctypesMapBySectorAndCategory.sectors[sectorX].categories
			) {
				for (let categoryX = 0; categoryX < this.ctypesMapBySectorAndCategory.sectors[sectorX].categories.length; categoryX++){
					if (
						this.ctypesMapBySectorAndCategory.sectors[sectorX].categories[categoryX].categoryName === '*' ||
						this.ctypesMapBySectorAndCategory.sectors[sectorX].categories[categoryX].categoryName.toLowerCase() === category ||
						this.ctypesMapBySectorAndCategory.sectors[sectorX].categories[categoryX].categoryLabel.toLowerCase() === category
					) {
						if (this.ctypesMapBySectorAndCategory.sectors[sectorX].categories[categoryX].allowedTypes.indexOf(ctypeName) > -1) {
							return true;
						}
					}
				}
			}
		}
		return false;
	}

	get companyHasAdmins() {
		return this.companyAdmins.length > 0;
	}

	get potentialDupFacilities() {
		this._potentialDupFacilities = [];
		let userFacilitiesCopy = JSON.parse(JSON.stringify(this.userFacilities));
		userFacilitiesCopy.forEach(group => {
			let companyList = [];
			group.companyList.forEach(comp => {
				if ((this.formData.sameaddress && comp.accountInfo.Business_City__c === this.companyInfo.Business_City__c) 
					||
					(!this.formData.sameaddress && comp.accountInfo.IATA_ISO_Country__c === this.selectedHQCountry)
				){
					if (comp.stations) {
						comp.airlinecount = 0;
						comp.airportcount = 0;
						comp.cargocount = 0;
						comp.ffcount = 0;
						comp.truckercount = 0;
						comp.shippercount = 0;
						comp.ramphandlercount = 0;
						comp.stations.forEach(fac => {
							if (fac.RecordType.DeveloperName === "Airline")
								comp.airlinecount++;
							else if (fac.RecordType.DeveloperName === "Airport_Operator")
								comp.airportcount++;
							else if (fac.RecordType.DeveloperName === "Cargo_Handling_Facility")
								comp.cargocount++;
							else if (fac.RecordType.DeveloperName === "Freight_Forwarder")
								comp.ffcount++;
							else if (fac.RecordType.DeveloperName === "Ramp_Handler")
								comp.ramphandlercount++;
							else if (fac.RecordType.DeveloperName === "Shipper")
								comp.shippercount++;
							else if (fac.RecordType.DeveloperName === "Trucker")
								comp.truckercount++;
						});
					}
					companyList.push(comp);
				}
			})
			if(companyList.length > 0){
				group.companyList = companyList;
				this._potentialDupFacilities.push(group);
			}
		});
		return this._potentialDupFacilities;
	}
	get selectedCompany() {
		let company;
		if(this.parentGroup && this.parentCompany || this.formData.sameaddress){
			let compId = this.parentCompany ? this.parentCompany : this.userInfo.AccountId;
			this.userFacilities.forEach(group => {
				if(!this.parentGroup || group.groupName === this.parentGroup){
					group.companyList.forEach(comp => {
						if (comp.accountInfo.Id === compId) {
							company = comp;
						}
					});
				}
			});
		}
		return company;
	}
	get ardRelIds() {
		let newIds = [];
		if (this.airlineHandledItemsToAdd){
			this.airlineHandledItemsToAdd.forEach(currentItem=> { 
				if (currentItem && currentItem.trim().length > 0) {
					newIds.push(currentItem) 
				}
			});
		}
		if (this.cargoShownOperatingStationIds){
			this.cargoShownOperatingStationIds.forEach(currentItem=> { 
				if (currentItem && currentItem.trim().length > 0) {
					newIds.push(currentItem)
				}
			});
		}
		if (this.rampShownOperatingStationIds){
			this.rampShownOperatingStationIds.forEach(currentItem=> {
				if (currentItem && currentItem.trim().length > 0) {
					newIds.push(currentItem)
			 	}
			});
		}
		return newIds.join(';');
	}
	get countryOrAddress() {
		if (this.selectedHQCountry && !this.formData.sameaddress) return "the selected country";
		return "this address";
	}

	closeModal() {
		this.showModal = false;
		if (this.goToHome) {
			this.dispatchEvent(new CustomEvent("gotohome"));
			this.goToHome = false;
		}
	}

	startLoading(){
		this.requesting = true;
	}

	stopLoading(){
		this.requesting = false;
	}
	
	get opsHierarchyList(){
		let opsHierarchies = [];
		this.userFacilities.forEach(group => {
			opsHierarchies.push({value : group.groupName, label : group.groupName, selected : group.groupName === this.account.opsHierarchy});
		})
		if(opsHierarchies.length === 1) opsHierarchies[0].selected = true;
		return opsHierarchies;
	}

	get selectedAddress(){
		let location = {
			addressPostalCode : this.selectedAddressObject.postalcode, 
			addressStateProvince : this.selectedAddressObject.state,  
			addressCity: this.selectedAddressObject.city, 
			location : {
				location:{
					Country : this.selectedAddressObject.country
				}
			}
		};
		let address = concatinateAddressString(this.selectedAddressObject.street) + concatinateFacilityAddress(location);
		return address.slice(0,-2);
	}
	get selectedAddressObject(){
		let addressObj = {};
		if (this.selectedCompany){
			addressObj.street = this.selectedCompany.accountInfo.Business_Street__c;
			addressObj.city = this.selectedCompany.accountInfo.Business_City__r ? this.selectedCompany.accountInfo.Business_City__r.Name : this.selectedCompany.accountInfo.Business_City_Name__c;
			addressObj.cityId = this.selectedCompany.accountInfo.Business_City__c;
			addressObj.state = this.selectedCompany.accountInfo.Iso_State__r ? this.selectedCompany.accountInfo.Iso_State__r.Name : this.selectedCompany.accountInfo.Business_State_Name__c;
			addressObj.stateId = this.selectedCompany.accountInfo.Iso_State__c;
			addressObj.postalcode = this.selectedCompany.accountInfo.Business_Postal_Code__c;
			addressObj.country = this.selectedCompany.accountInfo.IATA_ISO_Country__r ? this.selectedCompany.accountInfo.IATA_ISO_Country__r.Name : '';
			addressObj.countryId = this.selectedCompany.accountInfo.IATA_ISO_Country__c;
			addressObj.latitude = this.selectedCompany.accountInfo.Business_Geo_Coordinates__Latitude__s;
			addressObj.longitude = this.selectedCompany.accountInfo.Business_Geo_Coordinates__Longitude__s;
		}else{
			let selectedAddress;
			this.address.addressSuggestions.forEach(sugg =>{
				if(sugg.isSelected){
					selectedAddress = sugg;
				}
			})
			addressObj.street = selectedAddress ? selectedAddress.street : this.address.street;
			addressObj.city = selectedAddress ? selectedAddress.locality :this.address.cityName;
			addressObj.cityId = selectedAddress ? null : this.address.cityId;
			addressObj.state = selectedAddress ? selectedAddress.province :this.address.stateName;
			addressObj.stateId = selectedAddress ? null : this.address.stateId;
			addressObj.postalcode = selectedAddress ? selectedAddress.postalCode :this.address.zip;
			addressObj.country = this.address.countryName;
			addressObj.countryId = this.selectedHQCountry;
		}
		return addressObj;
	}

	get selectedAddressForMap (){
		let mapAddress = this.addressGeo ? this.addressGeo.Latitude+','+this.addressGeo.Longitude : this.selectedAddress;
		return mapAddress;
	}

	get configOpeningHours() {
		var arrayOpeningHours = [];
		//New Import Opening Hours
		var openingHours = {
			show: this.showImportHours(),
			title: this.importHoursLabel(),
			arrayDays: this.importDaysArray()
		};
		arrayOpeningHours.push(openingHours);
		//New Export Opening Hours
		openingHours = {
			show: this.showExportHours(),
			title: this.exportHoursLabel(),
			arrayDays: this.exportDaysArray()
		};
		arrayOpeningHours.push(openingHours);
		//Office Opening Hours
		openingHours = {
			show: this.showOfficeHours(),
			title: this.officeHoursLabel(),
			arrayDays: this.officeDaysArray()
		};
		arrayOpeningHours.push(openingHours);
		//Operating Hours
		openingHours = {
			show: this.showOperatingHours(),
			title: this.operatingHoursLabel(),
			arrayDays: this.operatingDaysArray()
		};
		arrayOpeningHours.push(openingHours);
		//Airport Opening Hours
		openingHours = {
			show: this.showAirportHours(),
			title: this.airportHoursLabel(),
			arrayDays: this.airportDaysArray()
		};
		arrayOpeningHours.push(openingHours);
		//Flight Operating Hours
		openingHours = {
			show: this.showFlightHours(),
			title: this.flightHoursLabel(),
			arrayDays: this.flightDaysArray()
		};
		arrayOpeningHours.push(openingHours);
		//Ramp Opening Hours
		openingHours = {
			show: this.showRampHours(),
			title: this.rampHoursLabel(),
			arrayDays: this.rampDaysArray()
		};
		arrayOpeningHours.push(openingHours);
		//New Custom Opening Hours
		openingHours = {
			show: this.showCustomsHours(),
			title: this.customsHoursLabel(),
			arrayDays: this.customsDaysArray()
		};
		arrayOpeningHours.push(openingHours);

		return arrayOpeningHours;
	}
	importHoursLabel() {
		return this.openingHours && this.openingHours.dataImport ? this.openingHours.dataImport.label : "Import Opening Hours";
	}

	exportHoursLabel() {
		return this.openingHours && this.openingHours.dataExport ? this.openingHours.dataExport.label : "Export Opening Hours";
	}

	officeHoursLabel() {
		return this.openingHours && this.openingHours.dataOffice ? this.openingHours.dataOffice.label : "Office Opening Hours";
	}

	operatingHoursLabel() {
		return this.openingHours && this.openingHours.dataOperating ? this.openingHours.dataOperating.label : "Operating Opening Hours";
	}

	airportHoursLabel() {
		return this.openingHours && this.openingHours.dataAirport ? this.openingHours.dataAirport.label : "Airport Opening Hours";
	}

	flightHoursLabel() {
		return this.openingHours && this.openingHours.dataFlight ? this.openingHours.dataFlight.label : "Flight Opening Hours";
	}

	rampHoursLabel() {
		return this.openingHours && this.openingHours.dataRamp ? this.openingHours.dataRamp.label : "Ramp Operating Hours";
	}

	customsHoursLabel() {
		return this.openingHours && this.openingHours.dataCustoms ? this.openingHours.dataCustoms.label : "Customs Opening Hours";
	}

	importDaysArray() {
		return this.openingHours && this.openingHours.dataImport ? this.openingHours.dataImport.days : [];
	}

	exportDaysArray() {
		return this.openingHours && this.openingHours.dataExport ? this.openingHours.dataExport.days : [];
	}

	officeDaysArray() {
		return this.openingHours && this.openingHours.dataOffice ? this.openingHours.dataOffice.days : [];
	}

	operatingDaysArray() {
		return this.openingHours && this.openingHours.dataOperating ? this.openingHours.dataOperating.days : [];
	}

	airportDaysArray() {
		return this.openingHours && this.openingHours.dataAirport ? this.openingHours.dataAirport.days : [];
	}

	flightDaysArray() {
		return this.openingHours && this.openingHours.dataFlight ? this.openingHours.dataFlight.days : [];
	}

	rampDaysArray() {
		return this.openingHours && this.openingHours.dataRamp ? this.openingHours.dataRamp.days : [];
	}

	customsDaysArray() {
		return this.openingHours && this.openingHours.dataCustoms ? this.openingHours.dataCustoms.days : [];
	}
	showImportHours() {
		return this.companyType === "Cargo_Handling_Facility";
	}

	showExportHours() {
		return this.companyType === "Cargo_Handling_Facility";
	}

	showCustomsHours() {
		return this.companyType === "Cargo_Handling_Facility" || this.companyType === "Airport_Operator";
	}

	showOfficeHours() {
		return true;
	}

	showOperatingHours() {
		return this.companyType === "Airline" || this.companyType === "Freight_Forwarder" || this.companyType === "Trucker";
	}

	showAirportHours() {
		return this.companyType === "Airport_Operator";
	}

	showFlightHours() {
		return this.companyType === "Airport_Operator";
	}

	showRampHours() {
		return this.companyType === "Ramp_Handler";
	}

	get showRoadFeederServices() {
		return this.companyType === "Airline";
	}

	get showOperatingCHFList() {
		return this.companyType === "Airline";
	}

	get showOperatingRampHandlersList() {
		return this.companyType === "Airline";
	}

	get showOverallFacilitySizeM2() {
		return this.companyType === "Cargo_Handling_Facility" || this.companyType === "Airport_Operator";
	}

	get showFleet() {
		return this.companyType === "Trucker" || this.companyType === "Freight_Forwarder";
	}

	get showLabelFacilityAirportSizeM2() {
		return this.companyType === "Airport_Operator" ? this.label.icg_overall_aiport_size : this.label.icg_overall_facility_size;
	}
	get showOnlineBooking() {
		return this.companyType !== "Airport_Operator";
	}
	get showPilotInformation() {
		return this.companyType === "Airport_Operator";
	}
	get showSupportedLanguages() {
		return true;
	}
	get showAirlines(){
		return this.showListAirlines || this.showOperatingAirlines;
	}
	get showListAirlines() {
		return (this.companyType === 'Ramp_Handler' || this.companyType === 'Cargo_Handling_Facility');
	}
	get showOperatingAirlines() {
		return this.companyType === 'Airport_Operator';
	}
	get getListAirIcon() {
		return resources + "/icons/company_type/cargo_com_airline.jpg";
	}
	get showOnAiport() {
		return this.companyType === "Cargo_Handling_Facility" || this.companyType === "Ramp_Handler";
	}
	get showNearestAirport() {
		return true;
	}
	get showRampHandler() {
		return this.companyType === "Ramp_Handler";
	}

	get companyTypeInput(){
		return this.companyType.replaceAll('_', ' ');
	}

	registerNewAccount(){
		// The event data needs to indicate if the creation form is fine. Let's say that if data is null, it means the form is invalid
		// otherwise it should contain the account information

		let account = { 'sobjectType': 'Account' };
			account.Name = this.account.legalname;
			account.Legal_name__c = this.account.legalname;
			account.TradeName__c = this.account.tradename;
			account.Phone = this.account.phone;
			account.Email__c = this.account.email;
			account.Website = this.account.website;
			account.Sector__c = this.account.customerTypeSector;
			account.Category__c = this.account.customerTypeCategory;
			account.Global_Ultimate_Account_Global_ID__c = this.userInfo ? this.userInfo.Account.Global_Ultimate_Account_Global_ID__c : '';
			// business address

			account.Business_Street__c = this.selectedAddressObject.street;
			account.BillingStreet = this.selectedAddressObject.street;
			account.ShippingStreet = this.selectedAddressObject.street;
			account.Business_Geo_Coordinates__Latitude__s = this.updatedLatitude;
			account.Business_Geo_Coordinates__Longitude__s = this.updatedLongitude;

			// Zip
			account.Business_Postal_Code__c = this.selectedAddressObject.postalcode;
			account.BillingPostalCode = this.selectedAddressObject.postalcode;
			account.ShippingPostalCode = this.selectedAddressObject.postalcode;

			// Country
			account.BillingCountry = this.selectedAddressObject.country;
			account.ShippingCountry = this.selectedAddressObject.country;

			account.IATA_ISO_Country__c = this.selectedAddressObject.countryId;
			account.IATA_ISO_Shipping_Country__c = this.selectedAddressObject.countryId;

			// City and State
			if(this.selectedAddressObject.stateId !== ''){

				account.Business_City__c = this.selectedAddressObject.cityId !== '' ? this.selectedAddressObject.cityId : this.createdCityId;
				account.Business_City_Name__c = this.address.cityName;

				account.Geoname_Billing_City__c = this.address.cityId !== '' ? this.selectedAddressObject.cityId : this.createdCityId ? this.createdCityId : '';
				account.BillingCity = this.address.cityName;
				
				account.Geoname_Shipping_City__c = this.address.cityId !== '' ? this.selectedAddressObject.cityId : this.createdCityId ? this.createdCityId : '';
				account.ShippingCity = this.address.cityName;

				account.Iso_State__c = this.address.stateId;
				
				account.Business_State_Name__c = this.address.stateName;

				account.IATA_ISO_Billing_State__c = this.address.stateId;
				account.BillingState = this.address.stateName;

				account.IATA_ISO_Shipping_State__c = this.address.stateId;
				account.ShippingState = this.address.stateName;
			}
			else{

				account.Business_City_Name__c = this.selectedAddressObject.city;
				account.BillingCity = this.selectedAddressObject.city;
				account.ShippingCity = this.selectedAddressObject.city;

				account.Business_State_Name__c = this.selectedAddressObject.state;
				account.BillingState = this.selectedAddressObject.state;
				account.ShippingState = this.selectedAddressObject.state;
			}
			return account;
			
	}
	get errorCreatingStation(){
		return this.errorCreatingAccount || this.errorCreatingStation;
	}
	get stationCreationCompleted(){
		return this.errorCreatingStation || this.stationCreated;
	}

	getUserFacilitiesFromAccount(){
		getUserFacilities({fromAccId : this.recordId}).then(result => {
			if (result) {
				
				this.facilityList = [];
				let objEntries = Object.entries(JSON.parse(result));
				objEntries.forEach(opsHierarchyGroup => {
					//0 is Group Name. 1 is Group Facilities. This is the result of object.entries.
					let [groupName, groupInfo] = opsHierarchyGroup;
					let numberOfStations = 0;
					let numberOfApprovedStations = 0;
					groupInfo.companyList.forEach(company =>{
						if(company.stations){
							numberOfStations += company.stations.length;
							company.stations.forEach(station => {
								if (station.Account_Role__c) {
									station.ctypeimage = resources + getCompanyTypeImage(station.RecordType.Name);
								}
								station.thumbnail = station.logoUrl__c ? station.logoUrl__c : resources + "/img/no-image.svg";
								station.recordUrl = this.urlBaseFacilityPage + "?eid=" + station.Id;
								station.groupName = groupName;
								station.city = company.accountInfo.Business_City__r ? company.accountInfo.Business_City__r.Name : company.accountInfo.Business_City_Name__c;
								station.country =  company.accountInfo.IATA_ISO_Country__r ? company.accountInfo.IATA_ISO_Country__r.Name : '';
								station.street = company.accountInfo.Business_Street__c;
								station.state = company.accountInfo.Business_State_Name__c;
								station.postalCode = company.accountInfo.Business_Postal_Code__c;
								station.userIsCompanyAdmin = groupInfo.isCompanyAdmin;
								station.userIsPendingCompanyAdmin = groupInfo.isPendingCompanyAdmin;
								station.pendingForIataApproval = station.Status__c === 'Pending for IATA Approval';
								let location = {addressPostalCode : station.postalCode, addressStateProvince : station.state,  addressCity: station.city, location : {location:{Country : station.country}}};
								let address = concatinateAddressString(station.street) + concatinateFacilityAddress(location);
								station.address = address.slice(0,-2);
								station.CreatedDateDateFormat = (station.CreatedDate.split("-")[2]).split('T')[0] + "-" + station.CreatedDate.split("-")[1] + "-" + station.CreatedDate.split("-")[0];
								station.createdById = company.CreatedById;
								if(station.isApproved__c) numberOfApprovedStations++;
								
							})
						}
						
					})
					
					let companyList = groupInfo.companyList;
					let isCompanyAdmin = groupInfo.isCompanyAdmin;
					let isPendingCompanyAdmin = groupInfo.isPendingCompanyAdmin;
					let status = groupInfo.status;
					let accountRoleDetailId  = groupInfo.id;
					let createdDateDateFormat = groupInfo.createdDate ? (groupInfo.createdDate.split("-")[2]).split('T')[0] + "-" + groupInfo.createdDate.split("-")[1] + "-" + groupInfo.createdDate.split("-")[0] : null;
					let createdDate = groupInfo.createdDate;
					this.facilityList.push({accountRoleDetailId, groupName, isCompanyAdmin,isPendingCompanyAdmin, companyList, numberOfStations, numberOfApprovedStations, status, createdDateDateFormat, createdDate});
				});
				this.isLoading = false;
				this.initializeUserFacilities(this.userFacilities);
			}else{
				this.isLoading = false;
			}
		})
	}

	initializeUserFacilities(copiedValues){
		copiedValues.forEach(group => {
			group.companyList.forEach(cmp => {
				if(cmp.stations){
					let validatedFacilities = [];
					cmp.stations.forEach(facility => {
						if (facility.isApproved__c) {
							if (
								facility.ICG_Contact_Role_Details__r &&
								facility.ICG_Contact_Role_Details__r.totalSize > 0
							) {
								if (!this.userInfo || !group.isCompanyAdmin) {
									facility.ICG_Contact_Role_Details__r.records.forEach(role => {
										if (
											!facility.isPendingCompanyAdmin &&
											role.Status__c === "Approved" &&
											role.ICG_Role__c === "Facility Manager"
										) {
											facility.isManager = true;
										} else if (
											!facility.isManager &&
											role.isPendingApproval__c &&
											role.ICG_Role__c === "Facility Manager"
										) {
											facility.isPendingManager = true;
										} else {
											facility.canRequestAccess = !this.isInternalUser;
										}
									});
								}
							} else {
								if(!group.isCompanyAdmin && !group.isPendingCompanyAdmin) facility.canRequestAccess = !this.isInternalUser;
							}
							validatedFacilities.push(facility);
						}
					})
					cmp.stations = validatedFacilities;
				}
			})
			
		});
		this.facilityList = copiedValues;
	}

	get showDirectRampAccess(){
		if (this.isInternalUser){
			return this.companyType === "Cargo_Handling_Facility" || this.companyType === "Trucker" || this.companyType === "Freight_Forwarder";
		}
		else{
			return false;
		}
	}

	get addressGeo(){
		let addressGeoObj;
		if(this.selectedCompany && this.selectedCompany.accountInfo && this.selectedCompany.accountInfo.Business_Geo_Coordinates__Latitude__s && this.selectedCompany.accountInfo.Business_Geo_Coordinates__Longitude__s){
			addressGeoObj = {
				Latitude: this.selectedCompany.accountInfo.Business_Geo_Coordinates__Latitude__s,
				Longitude: this.selectedCompany.accountInfo.Business_Geo_Coordinates__Longitude__s
			}
		}
		
		return addressGeoObj;
	}
	
	setFocusStationName(){
		let fieldToFocus = this.template.querySelector('.inputName');
		if(fieldToFocus){
			fieldToFocus.focus();
		}
	}

	loadHandlingService(){
		if (this.showRampHours()){
			if (this.handlingServicesEdit.facilityHandlingService && !this.handlingServicesEdit.facilityHandlingService.allServices){
				getAllServicesAvailable().then(result =>{
					this.handlingServicesEdit.facilityHandlingService.allServices = JSON.parse(result);
					this.handlingServicesEdit.facilityHandlingService.thirdPartyServices = [];
					this.handlingServicesEdit.facilityHandlingService.inHouseServices = [];
				});
			}
		}
	}

	updateFacility(event) {
		this.handlingServicesEdit.facilityHandlingService.thirdPartyServices = event.detail.thirdPartyServices;
		this.handlingServicesEdit.facilityHandlingService.inHouseServices = event.detail.inHouseServices;

		this.inHouseServicesValue = '';
		this.thirdPartyServicesValue = '';

		if (this.handlingServicesEdit.facilityHandlingService.inHouseServices.length > 0)
		{
			this.handlingServicesEdit.facilityHandlingService.inHouseServices.forEach(item => {
				this.inHouseServicesValue += item.api +';';
			});
		}
		
		if (this.handlingServicesEdit.facilityHandlingService.thirdPartyServices.length > 0)
		{
			this.handlingServicesEdit.facilityHandlingService.thirdPartyServices.forEach(item => {
				this.thirdPartyServicesValue += item.api +';';
			});
		}
	}
}