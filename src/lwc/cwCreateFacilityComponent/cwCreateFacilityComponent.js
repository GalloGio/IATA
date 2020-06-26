import { LightningElement, track, wire, api } from "lwc";
import getCompanyTypes from "@salesforce/apex/CW_Utilities.getCompanyTypes";
import getCountries from "@salesforce/apex/CW_Utilities.getIATACountries";
import becomeFacilityAdmin from "@salesforce/apex/CW_Utilities.becomeFacilityAdmin";
import becomeCompanyAdmin from "@salesforce/apex/CW_Utilities.becomeCompanyAdmin";
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

export default class CwCreateFacilityComponent extends LightningElement {
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

	@track companyTypesRaw;
	@track countries;
	@track predictiveValues;
	@track formData = {};
	@track additionalData = {};
	@track selectedAirlines = [];
	@track selectedOperatingCHF = [];
	@track selectedRampH = [];
	@track filterTextAirlines;
	@track filterTextOperatingAirlines;
	@track filterTextOperatingCHF;
	@track filterTextRampH;
	@track openingHours;
	@track activeInfoWindow;
	@track setFacilityNameAndType;
	logoInfoObject;
	@track logoImage;
	@track showModal = false;
	@track modalMessage =
		"When you perform an action, this modal appears with extra info.";
	CHECKED_IMAGE = resources + "/icons/ic-tic-green.svg";
	ERROR_IMAGE = resources + "/icons/error-icon.svg";
	@track modalImage = this.CHECKED_IMAGE + "/icons/ic-tic-green.svg";
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
	@track _userFacilities;
	@track requesting;
	@track availableLanguages;
	@track hoveredCompany;
	@track hoveredFacilities;

	selectedHQCountry;

	@track newAddressPrompt;
	@track accountCreationPrompt;
	@track stationCreationPrompt;


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

	chfToAdd = [];
	chfToRemove = [];
	rampToAdd = [];
	rampToRemove = [];
	hiddenCargoStations;
	hiddenRampHandlers;

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
	
	ctypesMapBySector = {
		Airline : ["Airline", "Cargo Handling Facility", "Ramp Handler"],
		FreightForwarder : ["Freight Forwarder", "Cargo Handling Facility"],
		AirlineSupplier : ["Cargo Handling Facility", "Ramp Handler"],
		NonAirlineTransportation : ["Trucker"],
		InfrastructurePartner : ["Airport Operator","Cargo Handling Facility","Ramp Handler"],
		Other : ["Shipper"]
	}

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
		return this._userFacilities || [];
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
		if (this.checkFormFields()) {
			this.collectFormData();
			if (event.currentTarget.dataset.substep)
				this.step = Number((this.step + 0.1).toFixed(1));
			else this.step = (~~this.step)+1;

			if (event.currentTarget.dataset.sameadress) {
				if (event.currentTarget.dataset.sameadress === "yes")
					this.formData.sameaddress = true;
				else this.formData.sameaddress = false;
			}
		}
		this.airportSelectorEventListenersAdded = false;
		this.languageSelectorEventListenersAdded = false;
		this.scrollToTop();
	}
	checkFormFields() {
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
		return inputValid && selectValid;
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
			this.additionalData.openingHours = JSON.stringify(this.openingHours);
		}
		
	}
	initializeBasicFormData() {
		let formu = this.template.querySelector(".basicdataform");
		if (formu) {
			this.formData = this.emptyFormJSON(formu.elements);
			if (this.companyInfo && this.companyInfo.IATA_ISO_Country__c)
				this.formData.disabledcountry = this.companyInfo.IATA_ISO_Country__r.Name;
			if (this.companyInfo && this.companyInfo.Business_City__c)
				this.formData.disabledcity = this.companyInfo.Business_City__r.Name;
			if (this.companyInfo && this.companyInfo.Business_Street__c)
				this.formData.disabledstreet = this.companyInfo.Business_Street__c;
			if (this.companyInfo && this.companyInfo.Business_Postal_Code__c)
				this.formData.disabledzip = this.companyInfo.Business_Postal_Code__c;
			if (this.companyInfo && this.companyInfo.Business_State_Name__c)
				this.formData.disabledstate = this.companyInfo.Business_State_Name__c;
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
			this.getAdditionalFormData();
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
				this.ishqboxfocus = true;
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
				this.islangboxfocus = true;
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
				this.isairportboxfocus = true;
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
				if (parsedRes.success) {
					this.modalMessage =
						"Thank you for your request. IATA will contact you shortly.";
					this.modalImage = this.CHECKED_IMAGE;
					this.dispatchEvent(new CustomEvent("refresh"));
				} else {
					this.modalMessage = parsedRes.message;
					this.modalImage = this.ERROR_IMAGE;
				}
				this.showModal = true;
				this.requesting = false;
				this.removeHoverDiv();
			})
			.catch(err => {
				this.modalMessage = err.message;
				this.modalImage = this.ERROR_IMAGE;
				this.showModal = true;
				this.requesting = false;
			});
	}
	becomeCompanyAdminJS() {
		this.requesting = true;
		becomeCompanyAdmin({
			companyId: this.userInfo.AccountId,
			contactId: this.userInfo.ContactId
		})
			.then(resp => {
				let parsedRes = JSON.parse(resp);
				if (parsedRes.success) {
					this.modalMessage =
						"Thank you for your request. IATA will contact you shortly.";
					this.modalImage = this.CHECKED_IMAGE;
					this.dispatchEvent(new CustomEvent("refresh"));
				} else {
					this.modalMessage = parsedRes.message;
					this.modalImage = this.ERROR_IMAGE;
				}
				this.showModal = true;
				this.requesting = false;
			})
			.catch(err => {
				this.modalMessage = err.message;
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
		}else{
			this.selectRt = true;
			this.selectStationName=false;
		}
	}

	setGeocoordinates(event){
		this.updatedLatitude = event.detail.latitude;
		this.updatedLongitude = event.detail.longitude;
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
					createDummyCompany({account: JSON.stringify(account), opsHierarchy : this.account.opsHierarchy}).then(resp => {
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
						this.modalMessage = ex.body.message;
					})
                })
                .catch(error => {
					this.creatingAccount = false;
					this.accountCreated = false;
					this.errorCreatingStation = true;
					this.modalMessage = ex.body.message;
                });
            }
            else{
				
				createDummyCompany({account: JSON.stringify(account), opsHierarchy : this.account.opsHierarchy}).then(resp => {
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
					this.errorCreatingAccount = true;
					this.modalMessage = ex.body.message;
				})
            }
		}else {
			this.creatingStation = true;
			//Not using standard UpdateRecord because we need to avoid sharing to update any Account
			updateAccountCoordinates({
					accId : this.selectedCompany.accountInfo.Id,
					latitude : this.updatedLatitude,
					longitude : this.updatedLongitude
			}).then(() => {
				this.registerStation();
			}).catch(error => {
				console.log(error);
				this.creatingStation = false;
				this.stationCreated = false;
				this.errorCreatingStation = true;
				this.modalMessage = error.body.message;
			});
		}
	}

	get isCompanyAdminOfSelectedOpsHierarchy(){
		let isAdmin = false;
		this.userFacilities.forEach(group => {
			if(group.groupName === (this.parentGroup || this.account.opsHierarchy) && group.isCompanyAdmin) isAdmin = true;
		})
		return isAdmin;
	}

	registerStation(){
		this.objectBeingCreated = 'Station';
		let station = {
			sobjectType: 'ICG_Account_Role_Detail__c',
			Name : this.formData.name,
			RecordTypeId : this.formData.recordtype,
			Number_of_Employees__c : parseInt(this.additionalData.noemployees || 0,10),
			Number_of_Facilities__c : parseInt(this.additionalData.nofacilities || 0,10),
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
			second_address__c : this.additionalData.stationsecondaddress,
			Is_Direct_Ramp_Access__c : this.additionalData.directrampaccess
		}
		createFacility({
			accountId: this.parentCompany
				? this.parentCompany
				: this.userInfo.AccountId,
			station : JSON.stringify(station),
			logoInfo: JSON.stringify(this.logoInfoObject),
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
				this.errorCreatingStation = !parsedRes.success;
				if (parsedRes.success) {
					this.goToHome = true;
					this.dispatchEvent(new CustomEvent("refresh"));
					if(this.isInternalUser) this.step = 1;
				}else{
					this.modalMessage = parsedRes.message;
				}
			})
			.catch(err => {
				console.log(err);
				this.creatingStation = false;
				this.stationCreated = false;
				this.errorCreatingStation = true;
				this.modalMessage = err.body.message;
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

	setSelectedAirlines(event) {
		this.getAdditionalFormData();
		this.selectedAirlines = JSON.parse(JSON.stringify(event.detail));
	}
	setSelectedCHF(event) {
		this.getAdditionalFormData();
		this.selectedOperatingCHF = JSON.parse(JSON.stringify(event.detail));
	}
	setSelectedRamp(event) {
		this.getAdditionalFormData();
		this.selectedRampH = JSON.parse(JSON.stringify(event.detail));
	}
	filterAirlinesHandled(event) {
		if(this.filterTextAirlines != event.detail){
			this.getAdditionalFormData();
			this.filterTextAirlines = event.detail;
		}
	}
	filterOperatingAirlines(event) {
		if(this.filterTextOperatingAirlines != event.detail){
			this.getAdditionalFormData();
			this.filterTextOperatingAirlines = event.detail;
		}
	}
	filterOperatingCHF(event) {
		if(this.filterTextOperatingCHF != event.detail){
			this.getAdditionalFormData();
			this.filterTextOperatingCHF = event.detail;
		}
	}
	filterRampH(event) {
		if(this.filterTextRampH != event.detail){
			this.getAdditionalFormData();
			this.filterTextRampH = event.detail;
		}
	}

	hqPredictiveSearch(event) {
		this.predictiveValues = [];
		this.hqSearchValue = event && event.target ? event.target.value : this.hqSearchValue ? this.hqSearchValue : "";
		if (!this.hqSearchValue || this.hqSearchValue.length < 3) {
			return;
		}
		let filteredValues = [];
		filteredValues = this.countries.filter(entry => {
			return entry.Name.toLowerCase().indexOf(this.hqSearchValue.toLowerCase()) > -1;
		});
		filteredValues.forEach(element => {
			this.predictiveValues.push({
				value: element.Id,
				key: element.Id,
				label: element.Name,
			});
		});
	}

	langPredictiveSearch(event) {
		this.predictiveValues = [];
		this.langSearchValue = event && event.target ? event.target.value : this.langSearchValue ? this.langSearchValue : "";
		if (!this.langSearchValue || this.langSearchValue.length < 3) {
			return;
		}
		let filteredValues = [];
		filteredValues = this.availableLanguages.filter(entry => {
			return entry.value.toLowerCase().indexOf(this.langSearchValue.toLowerCase()) > -1;
		});
		filteredValues.forEach(element => {
			this.predictiveValues.push({
				value: element.value,
				key: element.value,
				label: element.label,
			});
		});
	}

	airportPredictiveSearch(event) {
		this.predictiveValues = [];
		this.airportSearchValue = event && event.target ? event.target.value : this.airportSearchValue ? this.airportSearchValue : "";
		if (!this.airportSearchValue || this.airportSearchValue.length < 3) {
			return;
		}
		let filteredValues = [];
		filteredValues = Object.values(this.availableAirports).filter(entry => {
			return entry.description.toLowerCase().indexOf(this.airportSearchValue.toLowerCase()) > -1 || entry.keyName.toLowerCase().indexOf(this.airportSearchValue.toLowerCase()) > -1;
		});
		filteredValues.forEach(element => {
			this.predictiveValues.push({
				value: element.code,
				key: element.code,
				label: element.description,
			});
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
		if (!this.errorCreatingStation) {
			this.dispatchEvent(new CustomEvent("gotohome"));
			this.goToHome = false;
		}else{
			this.creatingStation = false;
			this.stationCreated = false;
			this.errorCreatingStation = false;
			this.modalMessage = null;
			this.creatingAccount = false;
			this.accountCreated = false;
			this.errorCreatingAccount = false;
		}
	}
	get showListAirlines() {
		return (this.companyType === 'Ramp Handler' ||
			this.companyType === 'Cargo Handling Facility' || this.companyType === 'Airport Operator');
	}

	get showOperatingAirlines() {
		return this.companyType === 'Airport Operator';
	}

	get showOperatingCHFandRampH() {
		return ((this.companyType === 'Airport Operator' ||
			this.companyType === 'Airline') && this.selectedAirport && (this.onAirportOperatingCHF.length > 0 || this.onAirportRampH.length > 0));
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
		if(this.companyType === 'Airline' || this.companyType === 'Airport Operator') this.getOnAirportStationsJS();
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

	hideCargoStations(event){
		this.hiddenCargoStations = [];
		this.chfToAdd  = [];
		this.chfToRemove = [];
		this.onAirportOperatingCHF.forEach(chf => {
			if (!event.detail.find(val => val.value === chf.value)) {
				this.hiddenCargoStations.push(chf.value);
				if(chf.originallySelected) this.chfToRemove.push(chf.value);
				chf.selected = false;
			}else{
				if(!chf.originallySelected) this.chfToAdd.push(chf.value);
				chf.selected = true;
			}
		});
		
	}
	hideRampHandlers(event){
		this.hiddenRampHandlers = [];
		this.rampToAdd = [];
		this.rampToRemove = [];
		this.onAirportRampH.forEach(rmph => {
			if (!event.detail.find(val => val.value === rmph.value)) {
				this.hiddenRampHandlers.push(rmph.value);
				if(rmph.originallySelected) this.rampToRemove.push(rmph.value);
				rmph.selected = false;
			}else{
				if(!rmph.originallySelected) this.rampToAdd.push(rmph.value);
				rmph.selected = true;
			}
		});
	}

	get hiddenOperatingStations(){
		let hiddenOperatingStations = '';
		if(this.companyType === 'Airport Operator'){
			hiddenOperatingStations = this.hiddenCargoStations && this.hiddenCargoStations.length > 0 ? 'OperatingCargo:'+this.hiddenCargoStations.join(',')+'|': '';
			hiddenOperatingStations += this.hiddenRampHandlers && this.hiddenRampHandlers.length > 0 ? 'OperatingRamp:'+this.hiddenRampHandlers.join(',')+'|':'';
		}
		return hiddenOperatingStations;
	}

	get stationsToAdd(){
		return this.rampToAdd.concat(this.chfToAdd);
	}
	get stationsToRemove(){
		return this.rampToRemove.concat(this.chfToRemove);
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
				if (elem.rtid === this.formData.recordtype) ctype = elem.name;
			});
		}
		return ctype;
	}
	get companyTypes() {
		this.companyTypesRaw.forEach(ctype => {
			if(!this.selectedCompany && this.account.sector && this.account.category){
				let trimmedSector = this.account.sector.replace(/\s+/g, '').replace(/-/gi,'');
				if(ctype.name && this.ctypesMapBySector[trimmedSector].includes(ctype.name)) ctype.available = true;
				else ctype.available = false;
			}else{
				ctype.available = true;
			}
		});
		return this.companyTypesRaw;
		
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
							if (fac.RecordType.Name === "Airline")
								comp.airlinecount++;
							else if (fac.RecordType.Name === "Airport Operator")
								comp.airportcount++;
							else if (fac.RecordType.Name === "Cargo Handling Facility")
								comp.cargocount++;
							else if (fac.RecordType.Name === "Freight Forwarder")
								comp.ffcount++;
							else if (fac.RecordType.Name === "Ramp Handler")
								comp.ramphandlercount++;
							else if (fac.RecordType.Name === "Shipper")
								comp.shippercount++;
							else if (fac.RecordType.Name === "Trucker")
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
	get airlinesHandledText() {
		let txt = "";
		if (this.selectedAirlines) {
			this.selectedAirlines.forEach(airline => {
				txt = txt + airline.label + ", ";
			});
			txt = txt.slice(0, -2);
		}
		return txt;
	}
	get ardRelIds() {
		let txt = "";
		if (this.selectedAirlines) {
			this.selectedAirlines.forEach(airline => {
				if(airline.value) txt = txt + airline.value + ";";
			});
		}
		if (this.selectedOperatingCHF) {
			this.selectedOperatingCHF.forEach(operatingchf => {
				if(operatingchf.value) txt = txt + operatingchf.value + ";";
			});
		}
		if (this.selectedRampH) {
			this.selectedRampH.forEach(ramphand => {
				if(ramphand.value) txt = txt + ramphand.value + ";";
			});
		}
		return txt;
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
		let street;
		let city;
		let postalcode;
		let state;
		let country;
		if (this.selectedCompany){
			street = this.selectedCompany.accountInfo.Business_Street__c;
			city = this.selectedCompany.accountInfo.Business_City__r ? this.selectedCompany.accountInfo.Business_City__r.Name : this.selectedCompany.accountInfo.Business_City_Name__c;
			state = this.selectedCompany.accountInfo.Iso_State__r ? this.selectedCompany.accountInfo.Iso_State__r.Name : this.selectedCompany.accountInfo.Business_State_Name__c;
			postalcode = this.selectedCompany.accountInfo.Business_Postal_Code__c;
			country = this.selectedCompany.accountInfo.IATA_ISO_Country__r.Name;
		}else{
			let selectedAddress;
			this.address.addressSuggestions.forEach(sugg =>{
				if(sugg.isSelected){
					selectedAddress = sugg;
				}
			})
			street = selectedAddress ? selectedAddress.street : this.address.street;
			city = selectedAddress ? selectedAddress.locality :this.address.cityName;
			state = selectedAddress ? selectedAddress.province :this.address.stateName;
			postalcode = selectedAddress ? selectedAddress.postalCode :this.address.zip;
			country = this.address.countryName;
		}
		let location = {addressPostalCode : postalcode, addressStateProvince : state,  addressCity: city, location : {location:{Country : country}}};

		let address = concatinateAddressString(street) + concatinateFacilityAddress(location);

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
			addressObj.country = this.selectedCompany.accountInfo.IATA_ISO_Country__r.Name;
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
		if(this.selectedAddressObject.latitude && this.selectedAddressObject.longitude) return this.selectedAddressObject.latitude+','+this.selectedAddressObject.longitude
		else return this.selectedAddress;
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
		return this.companyType === "Cargo Handling Facility";
	}

	showExportHours() {
		return this.companyType === "Cargo Handling Facility";
	}

	showCustomsHours() {
		return this.companyType === "Cargo Handling Facility" || this.companyType === "Airport Operator";
	}

	showOfficeHours() {
		return true;
	}

	showOperatingHours() {
		return this.companyType === "Airline" || this.companyType === "Freight Forwarder" || this.companyType === "Trucker";
	}

	showAirportHours() {
		return this.companyType === "Airport Operator";
	}

	showFlightHours() {
		return this.companyType === "Airport Operator";
	}

	showRampHours() {
		return this.companyType === "Ramp Handler";
	}

	get showOnlineBooking() {
		return this.companyType !== "Airport Operator";
	}
	get showPilotInformation() {
		return this.companyType === "Airport Operator";
	}
	get showSupportedLanguages() {
		return !(this.companyType === "Airline" || this.companyType === "Airport Operator");
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
	
	get successMessage (){
		let message = this.isInternalUser ? 'The station has been automatically approved' : 'The request has been sent to your Company Admins/IATA for approval.';
		return message;
	}
	get additionalMessage(){
		let additionalMessage = this.selectedCompany ? null : 'Since you have requested the Account creation, the station will only be available when the new Account has been approved.';
		return additionalMessage;
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
				this._userFacilities = [];
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
								station.country = company.accountInfo.IATA_ISO_Country__r.Name;
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
					this._userFacilities.push({accountRoleDetailId, groupName, isCompanyAdmin,isPendingCompanyAdmin, companyList, numberOfStations, numberOfApprovedStations, status, createdDateDateFormat, createdDate});
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
		this._userFacilities = copiedValues;
	}

	get showDirectRampAccess(){
		return this.isInternalUser && this.companyType === 'Cargo Handling Facility';
	}
	
}