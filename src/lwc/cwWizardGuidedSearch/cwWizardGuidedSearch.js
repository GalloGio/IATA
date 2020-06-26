import { LightningElement, track, wire, api } from "lwc";
import resources from "@salesforce/resourceUrl/ICG_Resources";
import getCertifications from "@salesforce/apex/CW_ResultsPageSearchBarController.getCertifications";
import getURL from "@salesforce/apex/CW_Utilities.getURLPage";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import getCompanyTypes from "@salesforce/apex/CW_Utilities.getCompanyTypes";
import { fillPredictiveValues, extractTypeFromLocation, prepareSearchParams, checkKeyUpValue } from "c/cwUtilities";

export default class CsWizardGuidedSearch extends LightningElement {
	@api label;
	initialized = false;

	@track selectedLocation = this._setEmtpyLocation();
	@track extraLocation = this._setEmtpyLocation();
	urlResultPage;
	searchObjects = [];

	@track stages = {
		stage1: true,
		stage1b: false,
		stage2: false,
		stage3: false,
		stage4: false
	};
	@track isNextDisabled = true;

	@track locationPredictiveValues = [];
	@api availableLocations;
	@track locationWrapper = { value: "" };
	@track isboxfocus;

	icons = resources + "/icons/";
	//icons
	tickSelection = this.icons + "ic-gsearch--selected.svg";

	@track companyTypes;

	@wire(getCompanyTypes, {})
	wiredUserInfo({ data }) {
		if (data) {
			this.companyTypes = JSON.parse(data);
		}
	}

	@track commodities = [
		{
			name: "General Cargo",
			selected: false,
			enabled: true,
			field: "General_Cargo__c",
			obj: "icg_account_role_detail__c",
			image: this.icons + "ic-gsearch--selected.svg",
			type: "commodity"
		},
		{
			name: "Dangerous Goods",
			selected: false,
			enabled: true,
			field: "Dangerous_Goods__c",
			obj: "icg_account_role_detail__c",
			image: this.icons + "ic-gsearch--selected.svg",
			type: "commodity"
		},
		{
			name: "Live Animals",
			selected: false,
			enabled: true,
			field: "Live_Animals__c",
			obj: "icg_account_role_detail__c",
			image: this.icons + "ic-gsearch--selected.svg",
			type: "commodity"
		},
		{
			name: "Airmail",
			selected: false,
			enabled: true,
			field: "Airmail__c",
			obj: "icg_account_role_detail__c",
			image: this.icons + "ic-gsearch--selected.svg",
			type: "commodity"
		},
		{
			name: "Perishables",
			selected: false,
			enabled: true,
			field: "Perishables__c",
			obj: "icg_account_role_detail__c",
			image: this.icons + "ic-gsearch--selected.svg",
			type: "commodity"
		},
		{
			name: "Pharmaceuticals",
			selected: false,
			enabled: true,
			field: "Pharmaceuticals__c",
			obj: "icg_account_role_detail__c",
			image: this.icons + "ic-gsearch--selected.svg",
			type: "commodity"
		}
	];

	@track allCertifications;
	@wire(getCertifications, {})
	wiredCertifications({ data }) {
		if (data) {
			this.allCertifications = JSON.parse(JSON.stringify(data));
		}
	}
	@track _certifications;
	get certifications() {
		let availableCerts = [];
		let noctypeselected = true;
		if (this.companyTypes) {
			this.companyTypes.forEach(ctype => {
				if (ctype.selected) noctypeselected = false;
			});
		}

		if (this.allCertifications) {
			this.allCertifications.forEach(cert => {
				if (noctypeselected) {
					availableCerts.push(cert);
				} else if (cert.Applicable_to__c && this.companyTypes) {
					let added = false;
					this.companyTypes.forEach(ctype => {
						if (!added && ctype.selected && cert.Applicable_to__c.toLowerCase().indexOf(ctype.name.toLowerCase()) > -1) {
							availableCerts.push(cert);
							added = true;
						}
					});
				}
				if (cert.Name === "IEnvA") {
					cert.LabelName = cert.Name + " Stage 1";
				}
				else { 
					cert.LabelName = cert.Name;
				}
			});
			if (this._certifications && this._certifications.length > 0) {
				availableCerts.forEach(cert => {
					this._certifications.forEach(prevcert => {
						if (prevcert.selected && prevcert.Name === cert.Name) cert.selected = prevcert.selected;
					});
				});
			}
		}
		this._certifications = JSON.parse(JSON.stringify(availableCerts));
		return this._certifications;
	}
	@wire(getURL, { page: "URL_ICG_ResultPage" })
	wiredURLResultPage({ data }) {
		if (data) {
			this.urlResultPage = data;
		}
	}


	renderedCallback() {
		if (this.initialized) {
			return;
		}
		// this.setDatalistLocationInput();
		this.initialized = true;
		if (this.stages.stage3) this.alignSelectedCertifications();
		if (this.stages.stage2) this.alignSelectedCTypes();
		if (this.stages.stage4) this.alignSelectedTCargo();

		this.isboxfocus = false;
		this._addFocusOnSearchListener();
	}

	_addFocusOnSearchListener() {
		let box = this.template.querySelector('[data-tosca="locationinput"]');
		if (box) {
			box.addEventListener("focus", event => {
				this.isboxfocus = true;
			});
			box.addEventListener("blur", event => {
				this.isboxfocus = false;
			});
		}
	}

	_setEmtpyLocation() {
		return { name: "", loc: "", icon: "" };
	}

	updateSearchbox(event) {
		this.locationWrapper = event.detail;
		this.locationWrapper = this.generateDescription(this.locationWrapper);
		this._switchPredictiveDisplay(false);
	}

	_switchPredictiveDisplay(bool) {
		let container = this.template.querySelector('[data-tosca="predictiveContainer"]');
		container.style.display = bool === true ? "block" : "none";
	}

	nextStep() {
		switch (true) {
			case this.stages.stage1:
				this.manageLocationAction();
				break;
			case this.stages.stage1b:
				this.changeStage("stage2");
				break;
			case this.stages.stage2:
				//this.calculateAvailableCertifications();
				this.changeStage("stage3");
				break;
			case this.stages.stage3:
				this.changeStage("stage4");
				break;
			case this.stages.stage4:
				this.changeStage("stage5");
				break;
			default:
		}
	}

	previousStep() {
		switch (true) {
			case this.stages.stage1b:
				if (this.extraLocation.name !== "") {
					this.extraLocation = this._setEmtpyLocation();
				} else if (this.selectedLocation.name !== "") {
					this.selectedLocation = this._setEmtpyLocation();
				}
				this.changeStage("stage1");
				break;
			case this.stages.stage2:
				if (this.selectedLocation && this.selectedLocation.name.toUpperCase() === "WORLDWIDE") {
					this.selectedLocation = this._setEmtpyLocation();
					this.locationWrapper = { value: "" };
					this.changeStage("stage1");
				} else {
					this.changeStage("stage1b");
				}
				break;
			case this.stages.stage3:
				this.changeStage("stage2");
				break;
			case this.stages.stage4:
				this.changeStage("stage3");
				break;
			default:
		}
	}

	manageLocationAction() {
		if (this.locationWrapper && this.locationWrapper.value !== "") {
			if (this.locationWrapper.value.toUpperCase() === "WORLDWIDE") {
				this.selectedLocation.name = this.locationWrapper.value;
				this.selectedLocation.loc = this.locationWrapper.description;
				this.selectedLocation.icon = this.locationWrapper.icon;
				this.extraLocation = this._setEmtpyLocation();
				this.changeStage("stage2");
			} else if (this.selectedLocation.name === "" || this.selectedLocation.name === undefined) {
				this.selectedLocation.name = this.locationWrapper.value;
				this.selectedLocation.loc = this.locationWrapper.description;
				this.selectedLocation.icon = this.locationWrapper.icon;
				this.changeStage("stage1b");
				this.isNextDisabled = true;
			} else {
				if (this.selectedLocation.name.toLowerCase() === this.locationWrapper.value.toLowerCase()) {
					const evt = new ShowToastEvent({
						title: "Pick a different location",
						message: "You are already searching for this location",
						variant: "error"
					});
					this.dispatchEvent(evt);
				} else {
					this.extraLocation.name = this.locationWrapper.value;
					this.extraLocation.loc = this.locationWrapper.description;
					this.extraLocation.icon = this.locationWrapper.icon;
					this.changeStage("stage1b");
					this.isNextDisabled = true;
				}
			}
		} else {
			const evt = new ShowToastEvent({
				title: "Pick a location",
				message: "Location value must be populated",
				variant: "error"
			});
			this.dispatchEvent(evt);
		}
	}

	searchAllLocation() {
		this.locationWrapper.value = "WORLDWIDE";
		this.selectedLocation.name = this.locationWrapper.value;
		this.selectedLocation.loc = "";
		this.selectedLocation.icon = "";
		this.extraLocation = this._setEmtpyLocation();
		this.changeStage("stage2");
	}

	addLocation(event) {
		event.preventDefault();
		this.locationWrapper = { value: "" };
		this.changeStage("stage1");
	}

	changeLocation(event) {
		event.preventDefault();
		let locationtype = event.currentTarget.dataset.location;
		if (locationtype === "main") {
			this.selectedLocation = JSON.parse(JSON.stringify(this.extraLocation));
		}
		this.extraLocation = this._setEmtpyLocation();
		this.changeStage("stage1");
	}

	selectAllCertifications() {
		this.certifications.forEach(element => {
			element.selected = true;
		});

		let items = this.template.querySelectorAll("[data-type='certification']");
		this._selectItems(items);
	}

	searchAllCTypes() {
		this.companyTypes.forEach(element => {
			element.selected = true;
		});

		let items = this.template.querySelectorAll("[data-type='companyType']");
		this._selectItems(items);
	}

	searchAllTCargo() {
		this.commodities.forEach(element => {
			element.selected = true;
		});

		let items = this.template.querySelectorAll("[data-type='commodity']");
		this._selectItems(items);
	}

	alignSelectedCertifications() {
		this._certifications.forEach(element => {
			if (element.selected === true) {
				let items = this.template.querySelectorAll("[data-name='" + element.Name + "']");
				if (items) this._selectItems(items);
			}
		});
	}

	alignSelectedCTypes() {
		Object.keys(this.companyTypes).forEach(element => {
			if (this.companyTypes[element].selected === true) {
				let items = this.template.querySelectorAll("[data-name='" + this.companyTypes[element].name + "']");
				if (items) this._selectItems(items);
			}
		});
	}

	alignSelectedTCargo() {
		Object.keys(this.commodities).forEach(element => {
			if (this.commodities[element].selected === true) {
				let items = this.template.querySelectorAll("[data-name='" + this.commodities[element].name + "']");
				if (items) this._selectItems(items);
			}
		});
	}

	_selectItems(items) {
		items.forEach(element => {
			element.classList.remove("itemUnselected");
			element.classList.add("itemSelected");
		});
	}

	changeStage(stageActive) {
		Object.keys(this.stages).forEach(element => {
			this.stages[element] = String(element) === stageActive ? true : false;
		});
		this.initialized = false;
	}

	predictiveSearch(event) {
		if(checkKeyUpValue(event)) {
			this.nextStep();
		}
		this.locationPredictiveValues = [];
		this.locationWrapper.value = event.target.value;
		if (!event.target.value || event.target.value.length < 3) {
			return;
		}

		this.locationPredictiveValues = fillPredictiveValues(event.target.value, this.availableLocations);
		this._switchPredictiveDisplay(true);
	}

	onClickItem(event) {
		let eTarget = event.currentTarget;

		eTarget.classList.toggle("itemUnselected");
		eTarget.classList.toggle("itemSelected");

		this.manageAction(eTarget);
	}

	manageAction(eTarget) {
		switch (eTarget.getAttribute("data-type")) {
			case "certification":
				this._certifications.forEach(element => {
					if (element.Name === eTarget.getAttribute("data-name")) {
						element.selected = eTarget.classList.contains("itemSelected");
					}
				});
				break;
			case "companyType":
				Object.keys(this.companyTypes).forEach(element => {
					if (this.companyTypes[element].name === eTarget.getAttribute("data-name")) {
						this.companyTypes[element].selected = eTarget.classList.contains("itemSelected");
					}
				});
				break;
			case "commodity":
				Object.keys(this.commodities).forEach(element => {
					if (this.commodities[element].name === eTarget.getAttribute("data-name")) {
						this.commodities[element].selected = eTarget.classList.contains("itemSelected");
					}
				});
				break;
			default:
		}
	}

	resultsPage() {
		let searchList = [];

		searchList = this._getLocations(searchList);
		searchList = this._getCompanyNames(searchList);
		searchList = this._getCerts(searchList);
		searchList = this._getCommodities(searchList);

		let urlParams = prepareSearchParams(searchList);
		if (urlParams === "all" && this.isEmptySearchWithWorldwide(searchList)) {
			urlParams = "all-worldwide";
		}
		window.location.href = this.urlResultPage + "?q=" + urlParams;
	}

	_getLocations(searchList) {
		let searchObjLoc1 = { operator: "LIKE", obj: "icg_account_role_detail__c", field: "City_FOR__c" };
		searchObjLoc1.value = this.selectedLocation.name;

		let type = extractTypeFromLocation(this.locationPredictiveValues, searchObjLoc1.value);
		if (type) {
			searchObjLoc1.type = type;
		}

		searchList.push(searchObjLoc1);

		if (this.extraLocation && this.extraLocation.name !== "") {
			let searchObjLoc2 = { operator: "LIKE", obj: "icg_account_role_detail__c", field: "City_FOR__c" };
			searchObjLoc2.value = this.extraLocation.name;

			let type2 = extractTypeFromLocation(this.locationPredictiveValues, searchObjLoc2.value);
			if (type2) {
				searchObjLoc2.type = type2;
			}

			searchList.push(searchObjLoc2);
		}
		return searchList;
	}

	_getCompanyNames(searchList) {
		Object.keys(this.companyTypes).forEach(element => {
			if (this.companyTypes[element].selected) {
				const searchObject = {
					value: this.companyTypes[element].value,
					operator: "LIKE",
					obj: this.companyTypes[element].obj,
					field: this.companyTypes[element].field
				};
				searchList.push(searchObject);
			}
		});
		return searchList;
	}
	_getCommodities(searchList) {
		Object.keys(this.commodities).forEach(element => {
			if (this.commodities[element].selected) {
				const searchObject = {
					value: this.commodities[element].selected,
					operator: "=",
					obj: this.commodities[element].obj,
					relationfield: this.commodities[element].relationfield,
					field: this.commodities[element].field
				};
				searchList.push(searchObject);
			}
		});
		return searchList;
	}
	_getCerts(searchList) {
		Object.keys(this._certifications).forEach(element => {
			if (this._certifications[element].selected) {
				const searchObject = {
					value: this._certifications[element].Name,
					operator: "LIKE",
					obj: "ICG_Capability_Assignment_Group__c",
					relationfield: "icg_account_role_detail__c",
					field: "ICG_Certification__r.Name"
				};
				searchList.push(searchObject);
			}
		});
		return searchList;
	}

	removeselectedlocation(event) {
		event.preventDefault();
		this.selectedLocation = this._setEmtpyLocation();
		if (this.extraLocation.name !== "") {
			this.selectedLocation = JSON.parse(JSON.stringify(this.extraLocation));
			this.extraLocation = this._setEmtpyLocation();
		} else {
			this.locationWrapper = { value: "" };
			this.changeStage("stage1");
		}
	}

	removeextralocation(event) {
		event.preventDefault();
		this.extraLocation = this._setEmtpyLocation();
	}

	generateDescription(location) {
		// let description;
		switch (location.type.toLowerCase()) {
			case "airport":
				location.description = location.type + " - " + location.description;
				break;
			case "country":
				location.description = location.type + " - " + location.description;
				break;
			case "city":
				location.description = location.type + " - " + location.description;
				break;
			default:
				location.description = "";
				break;
		}
		return location; //description;
	}

	get extratLocation() {
		let extraloc = "col-xl-6 col-lg-6 col-md-12 text-center";
		if (this.extraLocation.name === "" || this.extraLocation.name === undefined) {
			extraloc = "col-12 text-center";
		}
		return extraloc;
	}

	get extraLoc() {
		let extraloc = true;
		if (this.extraLocation.name === "" || this.extraLocation.name === undefined) {
			extraloc = false;
		}
		return extraloc;
	}

	get mainLoc() {
		let mainLoc = false;
		if (this.selectedLocation.name === "") {
			mainLoc = true;
		}
		return mainLoc;
	}

	get showAddLocation() {
		let addLoc = true;

		if (this.selectedLocation.name !== "" && this.selectedLocation.name !== undefined && this.extraLocation.name !== "" && this.extraLocation.name !== undefined) {
			addLoc = false;
		}
		if (this.selectedLocation.name === "WORLDWIDE" || this.extraLocation.name === "WORLDWIDE") {
			addLoc = false;
		}
		return addLoc;
	}

	isEmptySearchWithWorldwide(searchList) {
		let worldwide = false;

		searchList.forEach(searchValue => {
			if (searchValue.value && searchValue.value === "WORLDWIDE") {
				worldwide = true;
			}
		});

		return worldwide;
	}
}