import { LightningElement, api, track } from "lwc";

import setFacilityInfo_ from "@salesforce/apex/CW_FacilityContactInfoController.setFacilityInfo";
import ICG_RESOURCES from "@salesforce/resourceUrl/ICG_Resources";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { checkInputValidation } from "c/cwUtilities";

export default class CwFacilityContactInfo extends LightningElement {
	icons = {
		chevrondown: ICG_RESOURCES + "/icons/chevrondown.svg",
		chevronup: ICG_RESOURCES + "/icons/chevronup.svg"
	};

	initialized = false;
	@track isLoading = false;
	@track showLanguagesContent = true;
	@track editHours = false;
	
	@api label;
	_facility;

	@api 
	get facility(){
		return this._facility;
	}
	set facility(value){
		this._facility = JSON.parse(JSON.stringify(value));
		this._facility.supportedLanguages.forEach(lang => {
			let picklistValue = (this._facility.availableLanguages.filter(elem => {return elem.value === lang}));
			if(picklistValue.length > 0 && lang && lang !== '') this.langCalculator(lang, picklistValue[0].label);
		})
	}
	@api editMode = false;
	@api saveOnTheFly = false;

	languageSelectorEventListenersAdded=false;
	@track predictiveValues;
	@track langSearchValue = '';
	@track selectedLanguagesList = [];
	@track islangboxfocus;

	@api
	openSectionsOpeningHours(){
		this.template.querySelectorAll('c-cw-opening-hours').forEach(cmp =>{
			cmp.forceShowContent();
		})
	}

	get dataInformed() {
		return this.facility != null ? true : false;
	}

	get mailTo() {
		return "mailto:" + this.facility.email;
	}

	get showOnlineBooking() {
		return this.facility.recordTypeName !== "Airport Operator";
	}

	showImportHours() {
		return this.facility.recordTypeName === "Cargo Handling Facility";
	}

	showExportHours() {
		return this.facility.recordTypeName === "Cargo Handling Facility";
	}

	showCustomsHours() {
		return this.facility.recordTypeName === "Cargo Handling Facility" || this.facility.recordTypeName === "Airport Operator";
	}

	showOfficeHours() {
		return true;
	}

	showOperatingHours() {
		return this.facility.recordTypeName === "Airline" || this.facility.recordTypeName === "Freight Forwarder" || this.facility.recordTypeName === "Trucker";
	}

	showAirportHours() {
		return this.facility.recordTypeName === "Airport Operator";
	}

	showFlightHours() {
		return this.facility.recordTypeName === "Airport Operator";
	}

	showRampHours() {
		return this.facility.recordTypeName === "Ramp Handler";
	}

	get showSupportedLanguages() {
		return !(this.facility.recordTypeName === "Airline" || this.facility.recordTypeName === "Airport Operator");
	}

	renderedCallback() {
		if (this.initialized) {
			return;
		}
		this.initialized = true;
		let inputs = this.template.querySelectorAll(".input");
		let validated = checkInputValidation(inputs);
		this.updateDataValid(validated);
		//PredictiveBox Languages Listener
		let langbox = this.template.querySelector('[data-tosca="languagesinput"]');
		if (langbox && !this.languageSelectorEventListenersAdded) {
			langbox.addEventListener("focus", event => {
				this.langPredictiveSearch();
				this.islangboxfocus = true;
			});
			langbox.addEventListener("blur", event => {
				this.islangboxfocus = false;
			});
			this.languageSelectorEventListenersAdded = true;
		}
	}

	updateDataValid(validated) {
		let customEvent = new CustomEvent("updatedatavalidcontactinfo", {
			detail: validated
		});
		this.dispatchEvent(customEvent);
	}

	showToast(title, message, variant) {
		const event = new ShowToastEvent({
			title: title,
			message: message,
			variant: variant
		});
		this.dispatchEvent(event);
	}

	handleContactInfoValueChange(event) {
		let name = event.target.name;
		let newValue = event.target.value;
		let oldValue = this.facility[name];
		let inputs = this.template.querySelectorAll(".input");

		let validated = checkInputValidation(inputs);
		this.updateDataValid(validated);
		if (["email", "phone", "website", "onlineBooking", "supportedLanguages", "pilotInformation"].includes(name) && oldValue !== newValue) {
			this.setFacilityInfo(this.facility.Id, name, newValue);
		}
		event.currentTarget.blur();
    }

	handleDaysUpdated(event) {
		let keys = event.detail.key.split("_");
		let days = event.detail.days;
		this.facility.openingHours['data' + keys[0].charAt(0).toUpperCase() + keys[0].slice(1)].days = days;
		
		this.updateFacilityOnParent();
	}

	showHideLanguagesContent() {
		this.showLanguagesContent = !this.showLanguagesContent;
	}


	updateFacilityOnParent() {
		let customEvent = new CustomEvent("updatefacility", {
			detail: this.facility
		});
		this.dispatchEvent(customEvent);
	}

	setFacilityInfo(id, key, value) {
		this.isLoading = true;

		if (this.saveOnTheFly) {
			setFacilityInfo_({ id, key, value })
				.then(response => {
					if (response.result.status === "OK") {
						if (response.result.key === "supportedLanguages") {
							response.result.value = response.result.value.split(";");
						}

						this.facility[response.result.key] = response.result.value;
						this.updateFacilityOnParent();
					}
					this.isLoading = false;
				})
				.catch(error => {
					this.isLoading = false;
					console.error("error", error);
				});
		} else {
			if (key === "supportedLanguages") {
				value = value.split(";");
			}
			this.facility[key] = value;
			this.isLoading = false;
			this.updateFacilityOnParent();
		}
	}

	importHoursLabel() {
		return this.facility.openingHours && this.facility.openingHours.dataImport ? this.facility.openingHours.dataImport.label : "Import Opening Hours";
	}

	exportHoursLabel() {
		return this.facility.openingHours && this.facility.openingHours.dataExport ? this.facility.openingHours.dataExport.label : "Export Opening Hours";
	}

	officeHoursLabel() {
		return this.facility.openingHours && this.facility.openingHours.dataOffice ? this.facility.openingHours.dataOffice.label : "Office Opening Hours";
	}

	operatingHoursLabel() {
		return this.facility.openingHours && this.facility.openingHours.dataOperating ? this.facility.openingHours.dataOperating.label : "Operating Opening Hours";
	}

	airportHoursLabel() {
		return this.facility.openingHours && this.facility.openingHours.dataAirport ? this.facility.openingHours.dataAirport.label : "Airport Opening Hours";
	}

	flightHoursLabel() {
		return this.facility.openingHours && this.facility.openingHours.dataFlight ? this.facility.openingHours.dataFlight.label : "Flight Opening Hours";
	}

	rampHoursLabel() {
		return this.facility.openingHours && this.facility.openingHours.dataRamp ? this.facility.openingHours.dataRamp.label : "Ramp Operating Hours";
	}

	customsHoursLabel() {
		return this.facility.openingHours && this.facility.openingHours.dataCustoms ? this.facility.openingHours.dataCustoms.label : "Customs Opening Hours";
	}

	importDaysArray() {
		return this.facility.openingHours && this.facility.openingHours.dataImport ? this.facility.openingHours.dataImport.days : [];
	}

	exportDaysArray() {
		return this.facility.openingHours && this.facility.openingHours.dataExport ? this.facility.openingHours.dataExport.days : [];
	}

	officeDaysArray() {
		return this.facility.openingHours && this.facility.openingHours.dataOffice ? this.facility.openingHours.dataOffice.days : [];
	}

	operatingDaysArray() {
		return this.facility.openingHours && this.facility.openingHours.dataOperating ? this.facility.openingHours.dataOperating.days : [];
	}

	airportDaysArray() {
		return this.facility.openingHours && this.facility.openingHours.dataAirport ? this.facility.openingHours.dataAirport.days : [];
	}

	flightDaysArray() {
		return this.facility.openingHours && this.facility.openingHours.dataFlight ? this.facility.openingHours.dataFlight.days : [];
	}

	rampDaysArray() {
		return this.facility.openingHours && this.facility.openingHours.dataRamp ? this.facility.openingHours.dataRamp.days : [];
	}

	customsDaysArray() {
		return this.facility.openingHours && this.facility.openingHours.dataCustoms ? this.facility.openingHours.dataCustoms.days : [];
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

	langPredictiveSearch(event) {
		this.predictiveValues = [];
		this.langSearchValue = event && event.target ? event.target.value : this.langSearchValue ? this.langSearchValue : "";
		if (!this.langSearchValue || this.langSearchValue.length < 3) {
			return;
		}
		let filteredValues = [];
		filteredValues = this.facility.availableLanguages.filter(entry => {
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
	setLanguages(event) {
		event.preventDefault();
		this.langCalculator(event.detail.item, event.detail.value);
		this.updateLangField();
	}
	langCalculator(value, label){
		if(this.selectedLanguagesList){
			let exists = this.selectedLanguagesList.filter(elem =>{
				return elem.value === value;
			})
			if(exists.length === 0) this.selectedLanguagesList.push({value: value, label: label})
			this.langSearchValue = '';
		}
	}
	removeLang(event){
		event.preventDefault();
		this.selectedLanguagesList = this.selectedLanguagesList.filter(lang => {
			return lang.value != event.currentTarget.dataset.value;
		})
		this.updateLangField();
	}
	updateLangField(){
		let langvalue = '';
		this.updateDataValid(true);
		this.selectedLanguagesList.forEach(lang => {
			langvalue += lang.value+';';
		})
		this.setFacilityInfo(this.facility.Id, 'supportedLanguages', langvalue);
    }
    
    get isPilotInformationBlank() {
        return !this._facility || !this._facility.pilotInformation;
	}
	
	showInput(event){
		let elementName = event.target.dataset.item;
		this.template.querySelectorAll('.'+elementName).forEach(elem =>{
			elem.classList.toggle("hidden");
		})
		if(event.target.title == 'Edit'){
			this.editHours = true;
		}else{
			this.editHours = false;
		}

	}

	get showPilotInformation() {
		return this.facility.recordTypeName === "Airport Operator";
	}
}