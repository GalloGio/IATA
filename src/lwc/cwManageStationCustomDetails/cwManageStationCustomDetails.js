import { LightningElement, track, api } from "lwc";
import { NavigationMixin } from "lightning/navigation";
import getResults from "@salesforce/apex/CW_SearchEngine.getInfo";
import resources from "@salesforce/resourceUrl/ICG_Resources";
import { refreshApex } from "@salesforce/apex";
import updateFacility_ from "@salesforce/apex/CW_CreateFacilityController.updateFacility";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import labels from "c/cwOneSourceLabels";
import { loadStyle } from "lightning/platformResourceLoader";

export default class cwManageStationCustomDetails extends NavigationMixin(LightningElement) {
	label = labels.labels();

	_facilityid;
	@api
	get facilityid() {
		return this._facilityid;
	}
	set facilityid(value) {
		this._facilityid = value;
		this.getData(this._facilityid);
	}

	@track _editMode = true;
	get editMode() {
		return this._editMode;
	}
	get readOnlyMode() {
		return !this._editMode;
	}

	initialized = false;
	@api recordId = "";
	@track facility;
	@track results;
	@track loaded;
	sendActionToSave = false;
	logoImage;
	logoInfoObject;

	// UI Events - Start
	connectedCallback() {
		Promise.all([loadStyle(this, resources + "/css/internal.css")]);
	}
	renderedCallback() {
		if (!this.initialized) {
			this.initialized = true;
			let id = this._facilityid;
			if (!id) {
				if (this.recordId) {
					id = this.recordId;
					this.getData(id);
				}
			}
		}
	}
	showToast(title, message, variant) {
		const event = new ShowToastEvent({
			title: title,
			message: message,
			variant: variant
		});
		this.dispatchEvent(event);
	}
	cancelChanges() {
		this.template.querySelector('[id*="logoimage"]').value = null;
		refreshApex(this.getData(this.facility.Id));
	}

	setLoadedStatus() {
		this.loaded = true;
		this.dispatchEvent(new CustomEvent("loaded"));
	}
	getData(id) {
		const searchCriterion = {
			operator: "=",
			value: id,
			obj: "ICG_Account_Role_Detail__c",
			field: "Id",
			fields: ["Id"]
		};
		let searchWrapper = [searchCriterion];
		this.getResults(searchWrapper);
	}

	getResults(searchWrapper) {
		this.dispatchEvent(new CustomEvent("loading"));
		this.loaded = false;
		getResults({ attributes: JSON.stringify(searchWrapper), getOpeningHours: true, getHandledAirlines: true, orderByOnAirport: false, isPendingApproval: false })
			.then(result => {
				this.results = result ? JSON.parse(result) : null;
				if (this.results && this.results.length > 0) {
					this.facility = this.results[0].facility;
					if (this.template.querySelector('[id*="logopreview"]')) {
						this.template.querySelector('[id*="logopreview"]').setAttribute("src", this.getLogoUrl);
					}
					this.facility.lstAvailableCertifications = this.results[0].lstAvailableCertifications;
					this.airlineHandlers = this.facility.handledAirlines;
					this.cargoHandlers = [];
					this.rampHandlers = [];

					if (this.facility.recordTypeDevName === "Airport_Operator" || this.facility.recordTypeDevName === "Airline") {
						this.facility.onAirportStations.forEach(facility => {
							this.populateOperatingStations(facility);
						});
					} else {
						this.facility.operatingStations.forEach(facility => {
							this.populateOperatingStations(facility);
						});
					}
					this.setLoadedStatus();
				} else {
					this.setLoadedStatus();
				}
				this.loaded = true;
			})
			.catch(error => {
				this.setLoadedStatus();
			});
	}

	setFacilityInfo(id, key, value) {
		this.loaded = false;
		this.facility = JSON.parse(JSON.stringify(this.facility));
		this.facility[key] = value;
		this.facility = JSON.parse(JSON.stringify(this.facility));
		this.loaded = true;
	}
	handleSaveChanges() {
		let saveBtn = this.template.querySelector('[data-tosca="saveBtn"]');
		if (saveBtn) {
			const btnClasses = saveBtn.classList.value;
			if (btnClasses.includes("disabled")) {
				this.showToast("Warning", this.label.icg_facility_invalid_info, "warning");
				return;
			}
		}

		this.sendActionToSave = true;

		if (Array.isArray(this.facility.supportedLanguages)) {
			this.facility.supportedLanguages = JSON.parse(JSON.stringify(this.facility.supportedLanguages))
				.sort()
				.join(";");
		}

		let objToSave = {
			Opening_Hours__c: JSON.stringify(this.facility.openingHours),
			Id: this.facility.Id
		};

		let jsonInput = JSON.stringify(objToSave);

		this.loaded = false;

		this.template.querySelectorAll("c-cw-handler-detail").forEach(element => {
			element.saveHandlerItems();
		});

		updateFacility_({ jsonInput, logoInfo: JSON.stringify(this.logoInfoObject), geoLocationInfo: undefined })
			.then(response => {
				if (response.result.status == "OK") {
					this.showToast("Success", this.label.icg_successful_save_facility, "success");
					this.loaded = true;
				} else if (response.result.status == "error") {
					this.showToast("Error", this.label.icg_error_update_facility, "error");
					this.loaded = true;
				}
			})
			.catch(error => {
				this.loaded = true;
			});

		this.template.querySelectorAll(".cmpEditable").forEach(elem => {
			elem.editOff();
		});
	}
	// UI Events - End
	manageChildEvent(event) {
		let eventData = event.detail;
		if (eventData.error) {
			this.showToast("Error", this.label.icg_error_update_facility, "error");
			return;
		}
	}

	// Company Logo - Start
	setDefaultImg(event) {
		event.target.src = resources + "/img/no-image.svg";
	}
	setLogoPreview(event) {
		let logoInput = this.template.querySelector('[id*="logoimage"]');
		if (logoInput) {
			if (event) {
				this.logoImage = logoInput.files;
			} else {
				logoInput.files = this.logoImage;
			}
			if (logoInput.files && logoInput.files[0]) {
				let reader = new FileReader();
				reader.onload = e => {
					this.template.querySelector('[id*="logopreview"]').setAttribute("src", e.target.result);
					this.logoInfoObject = this.setFileInfo(logoInput.files[0], e.target.result.match(/,(.*)$/)[1]);
				};
				let name = event.target.name;
				this.setFacilityInfo(this.facility.Id, name, "newlogo");
				reader.readAsDataURL(logoInput.files[0]);
			}
		} else {
			if (this.logoImage && this.logoImage[0]) {
				let reader = new FileReader();
				reader.onload = e => {
					this.template.querySelector('[id*="logopreview"]').setAttribute("src", e.target.result);
				};
				reader.readAsDataURL(this.logoImage[0]);
			}
		}
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
	get getLogoUrl() {
		if (this.facility.logoUrl) {
			return this.facility.logoUrl;
		}
		return resources + "/img/no-image.svg";
	}
	// Company Logo - End

	// Opening Hours - Start
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
	showImportHours() {
		return this.facility.recordTypeDevName === "Cargo_Handling_Facility";
	}
	showExportHours() {
		return this.facility.recordTypeDevName === "Cargo_Handling_Facility";
	}
	showCustomsHours() {
		return this.facility.recordTypeDevName === "Cargo_Handling_Facility" || this.facility.recordTypeDevName === "Airport_Operator";
	}
	showOfficeHours() {
		return true;
	}
	showOperatingHours() {
		return this.facility.recordTypeDevName === "Airline" || this.facility.recordTypeDevName === "Freight_Forwarder" || this.facility.recordTypeDevName === "Trucker";
	}
	showAirportHours() {
		return this.facility.recordTypeDevName === "Airport_Operator";
	}
	showFlightHours() {
		return this.facility.recordTypeDevName === "Airport_Operator";
	}
	showRampHours() {
		return this.facility.recordTypeDevName === "Ramp_Handler";
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
	handleDaysUpdated(event) {
		let keys = event.detail.key.split("_");
		let days = event.detail.days;
		this.facility.openingHours["data" + keys[0].charAt(0).toUpperCase() + keys[0].slice(1)].days = days;
	}
	// Opening Hours - End

	// Airlines Handlers | Ramp Handlers | Cargo Handlers - Start
	populateOperatingStations(station) {
		switch (station.recordTypeDevName) {
			case "Cargo_Handling_Facility":
				this.cargoHandlers.push(station);
				break;
			case "Ramp_Handler":
				this.rampHandlers.push(station);
				break;
			default:
				break;
		}
	}

	get showAirlines() {
		return this.showListAirlines || this.showOperatingAirlines;
	}
	get showListAirlines() {
		return this.facility.recordTypeDevName === "Ramp_Handler" || this.facility.recordTypeDevName === "Cargo_Handling_Facility";
	}
	get showOperatingAirlines() {
		return this.facility.recordTypeDevName === "Airport_Operator";
	}
	get showOperatingCHFandRampH() {
		return this.facility.recordTypeDevName === "Airport_Operator" || this.facility.recordTypeDevName === "Airline";
	}
}
