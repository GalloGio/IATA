import { LightningElement, wire, track, api } from "lwc";
import getCompanyNamesList from "@salesforce/apex/CW_LandingSearchBarController.getCompanyNamesList";
import getCompanyTypes from "@salesforce/apex/CW_Utilities.getCompanyTypes";
import getLocationsList from "@salesforce/apex/CW_LandingSearchBarController.getLocationsList";

import resources from "@salesforce/resourceUrl/ICG_Resources";
import labels from "c/cwOneSourceLabels";
import { fillPredictiveValues, extractTypeFromLocation, removeGenericItemFromList, prepareSearchObjectFEICategories, checkIconType, translationTextJS, createKey, checkKeyUpValue, getPredictiveData } from "c/cwUtilities";

const LIMITNUMBERFILTERS = 25;

export default class CwResultsPageSearchBar extends LightningElement {
	label = labels.labels();
	deletetag = resources + "/icons/ic-delete-tag.svg";
	plusopen = resources + "/icons/icon-plus.svg";
	minusclose = resources + "/icons/icon-minus.svg";
	chevrondown = resources + "/icons/chevrondown.svg";
	chevronup = resources + "/icons/chevronup.svg";
	deletecustom = resources + "/icons/delete-custom.svg";
	locationwhite = resources + "/icons/ic-white-location.svg";
	searchbycompanywhite = resources + "/icons/search-by-company-white.svg";
	CertifiedAirline = resources + "/img/certifications/UfW_CertifiedAirline.png";
	animatedBanner = resources + "/img/animated-banner.gif";

	companyNameInput = "companynameinput";
	locationInput = "locationinput";

	locationsItems = [];
	@track lstFEICategories = [];
	companyNameItems = [];

	@api filterCountResponsive;

	availableLocations;
	availableLocationsCalloutPerformed;
	availableCompanyNamesCalloutPerformed;
	availableCompanyNames;
	@track locationPredictiveValues = [];
	@track locationSearchValue = "";
	@track companyNamesPredictiveValues = [];
	@track companyNamesSearchValue = "";
	@track searchSummaryList = [];
	@track searchLocationList = [];
	@track searchCompanyNameList = [];
	@track showFiltersTag = "Show More";
	@api certifications;
	@track companyTypes;
	searchObjects = [];
	@api initialLoadPerformed;
	@track disableLabel = false;
	@track isboxfocus;
	@track isboxfocuscompanyname;
	@api
	get initialSearch() {
		return this._initialSearch;
	}
	set initialSearch(values) {
		this._initialSearch = values;
	}
	_initialSearch;

	@api
	get customLocationFilter() {
		return this._customLocationFilter;
	}
	set customLocationFilter(value) {
		this._customLocationFilter = value;
		if (value) {
			this.removeAllLocations();
			this.onchangeFunction(true);
			let label = "Custom Location";
			this.searchSummaryList.push({ label: label, value: label });
		}
	}
	_customLocationFilter;

	@wire(getCompanyTypes, {})
	wiredCompanyTypes({ data }) {
		if (data) {
			this.companyTypes = JSON.parse(data);
		}
	}

	tickSelection = resources + "/icons/ic-gsearch--selected.svg";
	@track commodities = [
		{
			name: "General Cargo",
			selected: false,
			enabled: true,
			field: "General_Cargo__c",
			obj: "ICG_Account_Role_Detail__c",
			image: resources + "/icons/company_type/airline.svg",
			type: "commodity"
		},
		{
			name: "Dangerous Goods",
			selected: false,
			enabled: true,
			field: "Dangerous_Goods__c",
			obj: "ICG_Account_Role_Detail__c",
			image: resources + "/icons/company_type/airport-operator.svg",
			type: "commodity"
		},
		{
			name: "Live Animals",
			selected: false,
			enabled: true,
			field: "Live_Animals__c",
			obj: "ICG_Account_Role_Detail__c",
			image: resources + "/icons/company_type/freight-forwarder.svg",
			type: "commodity"
		},
		{
			name: "Airmail",
			selected: false,
			enabled: true,
			field: "Airmail__c",
			obj: "ICG_Account_Role_Detail__c",
			image: resources + "/icons/company_type/trucker.svg",
			type: "commodity"
		},
		{
			name: "Perishables",
			selected: false,
			enabled: true,
			field: "Perishables__c",
			obj: "ICG_Account_Role_Detail__c",
			image: resources + "/icons/company_type/cargo-handling-facility.svg",
			type: "commodity"
		},
		{
			name: "Pharmaceuticals",
			selected: false,
			enabled: true,
			field: "Pharmaceuticals__c",
			obj: "ICG_Account_Role_Detail__c",
			image: resources + "/icons/company_type/ramp-handler.svg",
			type: "commodity"
		}
	];

	onClickItem(event) {
		if (!this.disableLabel) {
			this.disableLabel = true;
			event.preventDefault();
			let eTarget = event.currentTarget;
			eTarget.classList.toggle("itemUnselected");
			eTarget.classList.toggle("itemSelected");
			eTarget.selected = !eTarget.selected;

			let inputs = this.template.querySelectorAll("[data-name='" + eTarget.getAttribute("data-name") + "']");
			inputs.forEach(element => {
				if (element.type === "checkbox") {
					element.checked = !element.checked;
				}
			});
			this.onchangeFunction();
		}
	}
	sortJS(listToOrder) {
		return new Promise((resolve, reject) => {
			try {
				let orderedList = listToOrder.sort(function(a, b) {
					return b.value - a.value;
				});
				resolve(orderedList);
			} catch (err) {
				reject(err);
			}
		});
	}
	onchangeFunction = function inputChange(customLocationFilter) {
		this.template.querySelector(".panel-filter-search-button").classList.remove("panel-filter-search-button-hide");
		this.searchObjects = [];
		let inputs = this.template.querySelectorAll("input");
		this.setSearchSummaryList();
		for (let i = 0; i < inputs.length; i++) {
			let searchObj = {};
			if (((inputs[i].type === "checkbox" && inputs[i].checked === true) || (inputs[i].type !== "checkbox" && inputs[i].value !== "" && inputs[i].value !== undefined)) && inputs[i].getAttribute("data-obj") != null && inputs[i].getAttribute("data-field") != null && inputs[i].getAttribute("data-operator") != null) {
				searchObj.obj = inputs[i].getAttribute("data-obj");
				searchObj.field = inputs[i].getAttribute("data-field");
				searchObj.operator = inputs[i].getAttribute("data-operator");
				if (inputs[i].getAttribute("data-relationfield")) {
					searchObj.relationfield = inputs[i].getAttribute("data-relationfield");
				}
				searchObj.value = inputs[i].type === "checkbox" && inputs[i].value === "on" ? true : inputs[i].value;
				this.searchObjects.push(searchObj);
			}
		}
		this.searchLocationList.forEach(loc => {
			let searchObj = {};
			searchObj.obj = "ICG_Account_Role_Detail__c";
			searchObj.field = "City_FOR__c";
			searchObj.operator = "LIKE";
			searchObj.value = loc.label;
			let type = extractTypeFromLocation(this.locationPredictiveValues, loc.label);

			if (type) {
				searchObj.type = type;
			}

			this.searchObjects.push(searchObj);
		});

		this.searchCompanyNameList.forEach(elem => {
			let searchObj = {};
			searchObj.obj = "ICG_Account_Role_Detail__c";
			searchObj.field = "Company_FOR__c";
			searchObj.operator = "LIKE";
			searchObj.value = elem.label;

			this.searchObjects.push(searchObj);
		});

		if (customLocationFilter && customLocationFilter === true) {
			let maxLatObj = {};
			let maxLongObj = {};
			let minLatObj = {};
			let minLongObj = {};

			maxLatObj.obj = "ICG_Account_Role_Detail__c";
			maxLongObj.obj = "ICG_Account_Role_Detail__c";
			minLatObj.obj = "ICG_Account_Role_Detail__c";
			minLongObj.obj = "ICG_Account_Role_Detail__c";

			maxLatObj.field = "Account_Role__r.Account__r.Business_Geo_Coordinates__Latitude__s";
			minLatObj.field = "Account_Role__r.Account__r.Business_Geo_Coordinates__Latitude__s";
			maxLongObj.field = "Account_Role__r.Account__r.Business_Geo_Coordinates__Longitude__s";
			minLongObj.field = "Account_Role__r.Account__r.Business_Geo_Coordinates__Longitude__s";

			maxLatObj.operator = "<";
			maxLongObj.operator = "<";
			minLatObj.operator = ">";
			minLongObj.operator = ">";

			maxLatObj.value = this._customLocationFilter.maxLat;
			maxLongObj.value = this._customLocationFilter.maxLong;
			minLatObj.value = this._customLocationFilter.minLat;
			minLongObj.value = this._customLocationFilter.minLong;

			this.searchObjects.push(maxLatObj);
			this.searchObjects.push(maxLongObj);
			this.searchObjects.push(minLatObj);
			this.searchObjects.push(minLongObj);
		}

		let searchObject = prepareSearchObjectFEICategories(this.lstFEICategories, this.searchObjects);
		if (searchObject) {
			this.searchObjects = JSON.parse(JSON.stringify(searchObject));
		}
		const searchEvent = new CustomEvent("search", {
			detail: this.searchObjects
		});

		const selectedEventFilt = new CustomEvent("filtercountchange", {
			detail: this.searchSummaryList.length
		});

		// Dispatches the event.

		this.disableInput(this.locationInput, this.searchLocationList);
		this.disableInput(this.companyNameInput, this.searchCompanyNameList);

		this.disableLabel = false;
		// Dispatches the event.
		this.dispatchEvent(searchEvent);
		this.dispatchEvent(selectedEventFilt);
	};

	disableInput(inputString, array) {
		let inputBox = this.template.querySelector('[data-tosca="' + inputString + '"]');
		const shouldDisable = array.length > 1;
		inputBox.disabled = shouldDisable;
	}

	addGenerichSearchFilter(event, inputString, array) {
		event.preventDefault();
		let field = this.template.querySelector('[data-tosca="' + inputString + '"]').value;
		let hasValue = false;
		if (field && field.length >= 3 && array.length < 2) {
			array.forEach(loc => {
				if (field.toUpperCase() === loc.label.toUpperCase()) {
					hasValue = true;
				}
			});
		}

		hasValue = hasValue || array.length > 1;

		return { hasValue: hasValue, field: field };
	}

	addCompanyName(event) {
		const fieldResult = this.addGenerichSearchFilter(event, this.companyNameInput, this.searchCompanyNameList);
		if (fieldResult.hasValue === false && fieldResult.field && fieldResult.field.length > 2) {
			this.searchCompanyNameList.push({ label: fieldResult.field });
			this.companyNameItems.push(fieldResult.field);
			this.template.querySelector("[data-tosca=" + this.companyNameInput + "]").value = "";
			this.onchangeFunction();
		}
	}

	addLocation(event) {
		const fieldResult = this.addGenerichSearchFilter(event, this.locationInput, this.searchLocationList);
		if (fieldResult.hasValue === false && fieldResult.field && fieldResult.field.length > 2) {
			this.searchLocationList.push({ label: fieldResult.field });
			this.locationsItems.push(fieldResult.field);
			this.template.querySelector("[data-tosca=" + this.locationInput + "]").value = "";
			this.onchangeFunction();
		}
	}

	removeCompanyNameClicked(event) {
		this.removeCompanyName(event);
		this.onchangeFunction();
	}

	removeLocationClicked(event) {
		this.removeLocation(event);
		this.onchangeFunction();
	}

	removeLocation(event) {
		event.preventDefault();
		let label = event.currentTarget.getAttribute("data-delete");
		const updatedList = removeGenericItemFromList(label, this.searchLocationList);
		this.searchLocationList = updatedList.auxList;
		this.locationsItems = updatedList.auxListLabels;
		this.locationSearchValue = "";
		this.template.querySelector("[data-tosca=" + this.locationInput + "]").value = "";
	}

	removeCompanyName(event) {
		event.preventDefault();
		let label = event.currentTarget.getAttribute("data-delete");
		const updatedList = removeGenericItemFromList(label, this.searchCompanyNameList);
		this.searchCompanyNameList = updatedList.auxList;
		this.companyNameItems = updatedList.auxListLabels;
		this.companyNamesSearchValue = "";
		this.template.querySelector("[data-tosca=" + this.companyNameInput + "]").value = "";
	}



	removeFEICategory(event) {
		event.preventDefault();
		let label = event.currentTarget.getAttribute("data-delete");
		let labelIncludingParent = event.currentTarget.getAttribute("data-delete-with-parent");

		let feiCategoriesCopy = JSON.parse(JSON.stringify(this.lstFEICategories));


		let categoryToHandle = feiCategoriesCopy.filter(cat => {
			let isCategory = cat.label === label;
			let isField = false;
			if(cat.fields){
				let isFieldLabel = cat.fields.some(field => field.label === label);
				let isOptionLabel;

				cat.fields.forEach(field => {
					if(field.options){
						field.options.forEach(opt => {
							if(opt.label === label){
								isOptionLabel = true;
							}
						})
					}
				})
				

				isField = isFieldLabel || isOptionLabel;
			}

			return labelIncludingParent.includes(cat.label) && isCategory || isField;
		});


		if(categoryToHandle && categoryToHandle.length == 1){
			let category = categoryToHandle[0];
			let isCategory = category.label === label;
			let isField = false;
			if(category.fields){
				let isFieldLabel = category.fields.some(field => field.label === label);
				let isOptionLabel;

				category.fields.forEach(field => {
					if(field.options){
						field.options.forEach(opt => {
							if(opt.label === label){
								isOptionLabel = true;
							}
						})
					}
				})
				

				isField = isFieldLabel || isOptionLabel;
			}


			if(isCategory){
				const updatedList = removeGenericItemFromList(label, feiCategoriesCopy);
				feiCategoriesCopy = updatedList.auxList;
			}
			else if(isField){
				let fieldsCopy = JSON.parse(JSON.stringify(category.fields));
				let fieldsNew = [];
				
				fieldsCopy.forEach(field => {
					if(field.label === label){
						field.selected = false;
						if(field.options){
							field.options.forEach(opt => {
								opt.selected = false;
							})
						}
					}

					if(field.options){
						field.options.forEach(opt => {
							if(opt.label === label){
								opt.selected = false;
								field.selected = false;
							}
						})
					}

					fieldsNew.push(field);
				});
				category.fields = JSON.parse(JSON.stringify(fieldsNew));

			}
		}
		this.lstFEICategories = JSON.parse(JSON.stringify(feiCategoriesCopy));
	}

	removeAllLocations() {
		this.searchLocationList = [];
		this.locationsItems = [];
	}

	unSetSearchSummaryList() {
		this.searchLocationList = [];
		this.locationsItems = [];
		this.lstFEICategories = [];
		this.searchCompanyNameList = [];
		this.companyNameItems = [];
		this.template.querySelector("[data-tosca=" + this.companyNameInput + "]").value = "";
		this.template.querySelector("[data-tosca=" + this.locationInput + "]").value = "";

		let inputs = this.template.querySelectorAll("input");
		for (let i = 0; i < inputs.length; i++) {
			if (inputs[i].type === "checkbox" && inputs[i].checked === true) {
				inputs[i].checked = false;
			}
		}
		let elements = this.template.querySelectorAll(".itemSelected");
		elements.forEach(element => {
			element.classList.add("itemUnselected");
			element.classList.remove("itemSelected");
			element.selected = false;
		});
		this.setSearchSummaryList();
		this.onchangeFunction();
	}

	addToSearchSummaryList(array) {
		if (array) {
			array.forEach(element => {
				this.searchSummaryList.push({
					label: element,
					value: element
				});
			});
		}
	}

	setSearchSummaryList() {
		let inputs = this.template.querySelectorAll("input");
		this.searchSummaryList = [];

		this.addToSearchSummaryList(this.locationsItems);
		this.addToSearchSummaryList(this.companyNameItems);
		this.lstFEICategoriesLabels.forEach(lbl => {
			
			this.searchSummaryList.push({
				label: lbl.label,
				value: lbl.value
			});
		})
		inputs.forEach(input => {
			if (input.type === "checkbox" && input.checked === true) {
				this.searchSummaryList.push({
					label: input.getAttribute("data-name"),
					value: input.getAttribute("data-name")
				});
			}
		});
	}

	deleteFilter(event) {
		event.preventDefault();
		let itemToDelete = event.currentTarget.getAttribute("data-delete");
		let elements = this.template.querySelectorAll('[data-name="' + itemToDelete + '"]');
		elements.forEach(element => {
			if (element.type === "checkbox" && element.checked === true) {
				element.checked = false;
			}
			if (element.classList.contains("itemSelected")) {
				element.classList.add("itemUnselected");
				element.classList.remove("itemSelected");
				element.selected = false;
			}
		});
		this.removeLocation(event);
		this.removeFEICategory(event);
		this.removeCompanyName(event);
		this.onchangeFunction();
	}

	initialized = false;
	searchQueryReceived = false;
	renderedCallback() {
		if (this.searchQueryReceived !== true && this._initialSearch && this.certifications && this.companyTypes) {
			this.alignInitialSearch();
			this.searchQueryReceived = true;
		}

		//Show/Hide Show more/less tags filter
		let pills = this.template.querySelector(".collapse-tags");
		if(pills){
			let height = pills.scrollHeight;
			let showmoreless = this.template.querySelector(".label-see-more");
			if (height > 85) {
				showmoreless.classList.remove("hidden");
			} else {
				showmoreless.classList.add("hidden");
			}
		}

		if (!this.availableLocationsCalloutPerformed && this.certifications) {
			this.callLocationsList();
		}

		if (!this.availableCompanyNamesCalloutPerformed && this.certifications) {
			this.callCompanyNamesList();
		}

		if (this.initialized === true) return;
		this.initialized = true;

		let coll = this.template.querySelectorAll(".collapsible");

		for (let i = 0; i < coll.length; i++) {
			coll[i].addEventListener("click", function() {
				this.classList.toggle("active");
				let content = this.nextElementSibling;
				let imgchild = this.querySelector("img");
				if (content.classList.contains("max-height-100")) {
					imgchild.src = resources + "/icons/chevrondown.svg";
					content.classList.remove("max-height-100");
				} else {
					imgchild.src = resources + "/icons/chevronup.svg";
					content.classList.add("max-height-100");
				}
			});
		}

		this.isboxfocus = false;
		this._addFocusOnSearchListener();

		this.isboxfocuscompanyname = false;
		this._addFocusOnSearchListenerCompanyNames();
	}

	callLocationsList() {
		getPredictiveData("getLocationsList", getLocationsList()).then(response => {
			this.availableLocations = response;
			this._enableInputs();
		});
		this.availableLocationsCalloutPerformed = true;
	}

	callCompanyNamesList() {
		getPredictiveData("getCompanyNamesList", getCompanyNamesList({ splitByCountry: false })).then(response => {
			this.availableCompanyNames = response;
		});
		this.availableCompanyNamesCalloutPerformed = true;
	}

	_addFocusOnSearchListener() {
		let box = this.template.querySelector("[data-tosca=" + this.locationInput + "]");
		if (box) {
			box.addEventListener("focus", event => {
				this.isboxfocus = true;
			});
			box.addEventListener("blur", event => {
				this.isboxfocus = false;
			});
		}
	}

	_addFocusOnSearchListenerCompanyNames() {
		let box = this.template.querySelector("[data-tosca=" + this.companyNameInput + "]");
		if (box) {
			box.addEventListener("focus", event => {
				this.isboxfocuscompanyname = true;
			});
			box.addEventListener("blur", event => {
				this.isboxfocuscompanyname = false;
			});
		}
	}

	predictiveSearchLocation(event) {
		if (checkKeyUpValue(event)) {
			this.updateSearchboxLocation(event);
		}
		this.locationPredictiveValues = [];
		this.locationSearchValue = event.target.value;
		if (!this.locationSearchValue || this.locationSearchValue.length < 3) {
			return;
		}
		this.locationPredictiveValues = fillPredictiveValues(event.target.value, this.availableLocations);
		this._switchPredictiveDisplay(true, "predictiveContainerLocation");
	}

	predictiveSearchCompanyName(event) {
		if (checkKeyUpValue(event)) {
			this.updateSearchboxCompanyName(event);
		}
		this.companyNamesPredictiveValues = [];
		this.companyNamesSearchValue = event.target.value;
		if (!this.companyNamesSearchValue || this.companyNamesSearchValue.length < 3) {
			return;
		}
		let searchValuesSplited = this.companyNamesSearchValue.split(" ");
		let filteredValues = this.availableCompanyNames.filter(entry => {
			let containedWords = 0;
			searchValuesSplited.forEach(val => {
				if (entry.info.searchValues && entry.info.searchValues.toLowerCase().indexOf(translationTextJS(val)) > -1) {
					containedWords++;
				} else if (
					entry.key &&
					entry.key
						.split("#")[0]
						.toLowerCase()
						.indexOf(translationTextJS(val)) > -1
				) {
					containedWords++;
				}
			});
			return containedWords === searchValuesSplited.length;
		});

		filteredValues.forEach(element => {
			const keySeparator = element.info.description && element.info.description !== "" ? " - " : "";
			const label = element.info.alias ? element.info.alias : element.info.keyName;
			this.companyNamesPredictiveValues.push({
				key: element.info.type + keySeparator + element.info.description,
				techkey: createKey(element.info.type + keySeparator + element.info.description + keySeparator + label + keySeparator + element.info.uniqueId),
				searchValues: element.info.searchValues,
				value: element.info.value,
				label: label,
				icon: checkIconType(element.info.type),
				basekey: element.key,
				stationsIds: element.info.stationsIds
			});
		});

		this._switchPredictiveDisplay(true, "predictiveContainerCompanyName");
	}

	alignInitialSearch() {
		if (this._initialSearch) {
			let inputs = this.template.querySelectorAll("input");
			let parsedValues = this._initialSearch;
			parsedValues.forEach(elem => {
				if (elem.obj.toUpperCase() === "ICG_ACCOUNT_ROLE_DETAIL__C" && elem.field.toUpperCase() === "CITY_FOR__C") {
					let values = elem.value ? elem.value.split(";") : null;
					if (values) {
						values.forEach(value => {
							this.searchLocationList.push({ label: value });
							this.locationsItems.push(value);
						});
					}
				} else if (elem.obj.toUpperCase() === "ICG_ACCOUNT_ROLE_CAPABILITY_ASSIGNMENT__C" && elem.field.toUpperCase().includes("ACCOUNT_ROLE_DETAIL_CAPABILITY__R")) {
					if(elem.equipmentObjects){
						elem.equipmentObjects.forEach(equip => {
							this.lstFEICategories.push(equip);
						})
					}
				} else if (elem.obj.toUpperCase() === "ICG_ACCOUNT_ROLE_DETAIL__C" && elem.field.toUpperCase() === "COMPANY_FOR__C") {
					if (elem.value) {
						this.companyNameItems.push(elem.value);
						this.searchCompanyNameList.push({ label: elem.value });
					}
				}

				for (let i = 0; i < inputs.length; i++) {
					if (
						inputs[i].getAttribute("data-obj") &&
						inputs[i].getAttribute("data-field") &&
						inputs[i].getAttribute("data-operator") &&
						//Case Insensitive Comparison
						inputs[i].getAttribute("data-obj").toUpperCase() === elem.obj.toUpperCase() &&
						inputs[i].getAttribute("data-field").toUpperCase() === elem.field.toUpperCase() &&
						inputs[i].getAttribute("data-operator").toUpperCase() === elem.operator.toUpperCase()
					) {
						if (elem.value && typeof elem.value === "string" && elem.value.toUpperCase() !== "TRUE") {
							let values = elem.value ? elem.value.split(";") : elem.value;
							values.forEach(value => {
								if (inputs[i].type === "checkbox" && inputs[i].value && inputs[i].value.toUpperCase() === value.toUpperCase()) {
									inputs[i].checked = true;
									//Data Name matches a clickable element with its input
									if (inputs[i].getAttribute("data-name")) {
										inputs[i].parentNode.classList.remove("itemUnselected");
										inputs[i].parentNode.classList.add("itemSelected");
										inputs[i].parentNode.setAttribute("selected", true);
									}
								} else if (inputs[i].type !== "checkbox") {
									inputs[i].value = value;
								}
							});
						} else if (elem.value && (typeof elem.value === "boolean" || elem.value.toUpperCase() === "TRUE" || elem.value.toUpperCase() === "ON")) {
							if (inputs[i].type === "checkbox") {
								inputs[i].checked = true;
								inputs[i].parentNode.classList.remove("itemUnselected");
								inputs[i].parentNode.classList.add("itemSelected");
								inputs[i].parentNode.setAttribute("selected", true);
							}
						}
					}
				}
			});
			this.setSearchSummaryList();
		}
	}

	updateSearchbox(event, inputString, containerString) {
		let input = this.template.querySelector('[data-tosca="' + inputString + '"]');
		input.value = event.detail && event.detail.value ? event.detail.value : event.target.value;
		input.key = event.detail && event.detail.basekey && event.detail.basekey.split("##").length > 1 ? event.detail.basekey.split("##")[1] : "";

		this._switchPredictiveDisplay(false, containerString);
	}

	updateSearchboxLocation(event) {
		this.updateSearchbox(event, this.locationInput, "predictiveContainerLocation");
		this.addLocation(event);
	}

	updateSearchboxCompanyName(event) {
		this.updateSearchbox(event, this.companyNameInput, "predictiveContainerCompanyName");
		this.addCompanyName(event);
	}

	_switchPredictiveDisplay(bool, containerString) {
		let container = this.template.querySelector('[data-tosca="' + containerString + '"]');
		container.style.display = bool === true ? "block" : "none";
	}

	showResultsResponsive() {
		this.template.querySelector(".panel-filter-search-button").classList.add("panel-filter-search-button-hide");
		const showresults = new CustomEvent("clicksearch");
		// Dispatches the event.
		this.dispatchEvent(showresults);
	}

	seeAllTags() {
		let tags = this.template.querySelector(".div-tags");
		tags.classList.toggle("collapse-tags");
		this.showFiltersTag = this.showFiltersTag === "Show More" ? "Show Less" : "Show More";
	}

	_enableInputs() {
		let box = this.template.querySelector('[data-tosca="locationinput"]');
		if (box) {
			box.disabled = false;
		}
		let boxM = this.template.querySelector('[data-tosca="companynameinput"]');
		if (boxM) {
			boxM.disabled = false;
		}
	}

	getLocationsListJS() {
		return getLocationsList({});
	}

	get searchSummaryListLength() {
		return this.searchSummaryList.length;
	}

	get visibilityFilters() {
		return this.searchSummaryList.length < LIMITNUMBERFILTERS ? '' : 'hidden' ;
	}

	get limitReached() {
		return this.searchSummaryList.length >= LIMITNUMBERFILTERS ? '' : 'hidden' ;
	}

	setSelectedCategory(event) {
		const categoryInput = event.detail;
		if (categoryInput.selected) {

			const updatedList = removeGenericItemFromList(categoryInput.label, this.lstFEICategories);
			this.lstFEICategories = updatedList.auxList;


			this.lstFEICategories.push(categoryInput);


		} else {

			categoryInput.fields.forEach(field => {
				field.selected = false;
			})
			


			const updatedList = removeGenericItemFromList(categoryInput.label, this.lstFEICategories);
			this.lstFEICategories = updatedList.auxList;
		}

		this.onchangeFunction();
	}

	updateSectionLoaded() {
		this.lstFEICategories = [...this.lstFEICategories];
	}

	get lstFEICategoriesLabels(){
		let array = [];

		this.lstFEICategories.forEach(category => {
			if(category.selected){
				let obj = {
					label: category.label,
					value: category.label
				}
				array.push(obj);
			}

			if(category.fields){
				category.fields.forEach(field => {
					if(field.selected){
						if(field.type === 'picklist'){
							if(field.options){
								field.options.forEach(opt => {
									if(opt.selected){
										let obj = {
											label: opt.label + ' (' + category.label + ')',
											value: opt.label
										}
										array.push(obj);
									}
								})
							}

						}
						else{
							let obj = {
								label: field.label + ' (' + category.label + ')',
								value: field.label
							}
							array.push(obj);
						}
					}
				})
			}
		})


		return array;
	}
}