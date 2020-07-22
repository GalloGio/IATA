import { LightningElement, track, wire } from "lwc";
import getLocationsList from "@salesforce/apex/CW_LandingSearchBarController.getLocationsList";
import getCompanyNamesList from "@salesforce/apex/CW_LandingSearchBarController.getCompanyNamesList";
import getCertificationsList from "@salesforce/apex/CW_LandingSearchBarController.getCertificationsList";
import getURL from "@salesforce/apex/CW_Utilities.getURLPage";
import SEARCH_ICON from "@salesforce/resourceUrl/ICG_Search_Icon";
import resources from "@salesforce/resourceUrl/ICG_Resources";
import labels from "c/cwOneSourceLabels";
import { loadScript } from "lightning/platformResourceLoader";

import { checkIconType, createKey, prepareSearchParams, translationTextJS, checkKeyUpValue, getPredictiveData } from "c/cwUtilities";

export default class CwLandingSearchBar extends LightningElement {
	initialized = false;
	searchReady = false;
	label = labels.labels();

	searchtypelocation = "location";
	searchtypecertification = "certification";
	searchtypecompanyname = "companyname";

	logoSearch = resources + "/img/one-source-visual-white.svg";

	icons = resources + "/icons/";

	searchIcon = SEARCH_ICON;
	dropdownicon = this.icons + "icon-dropdown.svg";
	bluearrow = this.icons + "blue-arrow.svg";
	searchbycertification = this.icons + "search-by-certification.svg";
	searchbycompany = this.icons + "search-by-company.svg";
	searchbylocation = this.icons + "search-by-location.svg";

	searchbycertificationresp = this.icons + "responsive/ic-search-by-certf--yellow.svg";
	searchbycompanyresp = this.icons + "responsive/ic-search-companyname--yellow.svg";
	searchbylocationresp = this.icons + "responsive/ic-location--yellow.svg";
	yellowarrow = this.icons + "responsive/ic-arrow--yellow.svg";

	inputEnabled = false;

	@track showSearchTypeCombo = false;
	@track searchType = this.searchtypelocation;
	@track predictiveValues = [];
	@track searchValue = "";
	@track showLandingBar = true;
	@track showSearchAssistantcmp = false;
	@track showAdvanceSearchcmp = false;
	@track isboxfocus = false;
	@track isboxMfocus = false;

	@track availableLocations;
	availableCompanyNames;
	availableCertifications;
	urlResultPage;

	@track tooltipObject;
	@track tooltipToDisplay = "";
	@track showWizardLink = false;

	@wire(getURL, { page: "URL_ICG_ResultPage" })
	wiredURLResultPage({ data }) {
		if (data) {
			this.urlResultPage = data;
			this.searchReady = true;
		}
	}

	connectedCallback() {
		if (window.LZString === undefined) {
			Promise.all([loadScript(this, resources + "/js/lz-string.js")]);
		}
	}
	renderedCallback() {
		if (this.inputEnabled) {
			this._enableInputs();
		}
		if (this.initialized) {
			return;
		}
		getPredictiveData("getLocationsList", getLocationsList()).then(response => {
			this.inputEnabled = true;
			this.availableLocations = response;
			this._enableInputs();
		});

		getPredictiveData("getCompanyNamesList", getCompanyNamesList({ splitByCountry: true })).then(response => {
			this.availableCompanyNames = response;
		});

		getPredictiveData("getCertificationsList", getCertificationsList()).then(response => {
			this.availableCertifications = response;
		});

		this.initialized = true;
	}

	handleOnFocus(event){
		if(event.target.dataset.mobile == "true"){
			this.isboxMfocus = true;
		}
		else{
			this.isboxfocus = true;
		}

		this.closeSearchTypeCombo();
	}

	handleOnBlur(event){
		if(event.target.dataset.mobile == "true"){
			this.isboxMfocus = false;
		}
		else{
			this.isboxfocus = false;
		}
	}

	_enableInputs() {
		let box = this.template.querySelector('[data-tosca="locationinput"]');
		if (box) {
			box.disabled = false;
		}
		let boxM = this.template.querySelector('[data-tosca="locationinputMobile"]');
		if (boxM) {
			boxM.disabled = false;
		}
		let magnifierBtn = this.template.querySelector('[data-tosca="search-btn"]');
		if (magnifierBtn) {
			magnifierBtn.classList.remove("disabled-filter");
			magnifierBtn.disabled = false;
		}
		this.showWizardLink = true;
	}

	get isLocation() {
		return this.searchType === this.searchtypelocation;
	}
	get isCertification() {
		return this.searchType === this.searchtypecertification;
	}
	get isCompanyName() {
		return this.searchType === this.searchtypecompanyname;
	}
	get searchValueForFirstItem() {
		return this.isCertification ? null : this.searchValue;
	}
	closeSearchTypeCombo() {
		this.showSearchTypeCombo = false;
	}
	setLocationSearchType() {
		this.searchType = this.searchtypelocation;
		this.closeSearchTypeCombo();
		this.predictiveValues = [];
	}
	setCertificationSearchType() {
		this.searchType = this.searchtypecertification;
		this.closeSearchTypeCombo();
		this.predictiveValues = [];
	}
	setCompanyNameSearchType() {
		this.searchType = this.searchtypecompanyname;
		this.closeSearchTypeCombo();
		this.predictiveValues = [];
	}
	displaySearchTypeCombo() {
		this.showSearchTypeCombo = true;
	}
	get searchBoxPlaceholder() {
		if (this.isLocation) return this.label.type_search + " " + this.label.location_search;
		else if (this.isCertification) return this.label.type_search + " " + this.label.certification_search;
		else if (this.isCompanyName) return this.label.type_search + " " + this.label.company_name_search;

		return "Please, pick a type";
	}
	evaluateDisplaySearchAssistant() {
		if (!this.showSearchAssistantcmp) {
			this.showSearchAssistantcmp = true;
			this.showLandingBar = false;
		} else {
			this.showSearchAssistantcmp = false;
			this.initialized = false;
			this.showLandingBar = true;
		}
	}

	evaluateDisplayAdvanceSearch() {
		if (!this.showAdvanceSearchcmp) {
			this.showAdvanceSearchcmp = true;
			this.showLandingBar = false;
		} else {
			this.showAdvanceSearchcmp = false;
			this.initialized = false;
			this.showLandingBar = true;
		}
	}

	hideSearchTypeCombo(event) {
		event.stopPropagation(); //cancel bubbling

		let ele = event.target || event.srcElement;
		if (ele.className === "containercombo") {
			this.closeSearchTypeCombo();
		}
	}

	predictiveSearch(event) {
		if (checkKeyUpValue(event)) {
			this.updateSearchbox(event);
		}
		this.predictiveValues = [];
		this.searchValue = event.target ? event.target.value : "";
		if (!this.searchValue || this.searchValue.length < 3) {
			return;
		}

		let filteredValues = [];

		if (this.isLocation) {
			let searchValuesSplited = this.searchValue.split(" ");
			filteredValues = this.availableLocations.filter(entry => {
				let containedWords = 0;
				let code = entry.info.code;
				searchValuesSplited.forEach(val => {
					if (entry.info.searchValues && entry.info.searchValues.toLowerCase().indexOf(translationTextJS(val)) > -1) {
						containedWords++;
					} else if (entry.key && entry.key.toLowerCase().indexOf(translationTextJS(val)) > -1) {
						containedWords++;
					}
				});

				let codeIncludesValue = code ? entry.info.code.toLowerCase().includes(this.searchValue.toLowerCase()) : false;
				return containedWords === searchValuesSplited.length || codeIncludesValue;
			});
		} else if (this.isCompanyName) {
			let searchValuesSplited = this.searchValue.split(" ");
			filteredValues = this.availableCompanyNames.filter(entry => {
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
		} else if (this.isCertification) {
			filteredValues = this.availableCertifications.filter(entry => {
				const alias = entry.info.alias;
				const aliasMatches = alias ? alias.toLowerCase().includes(this.searchValue.toLowerCase()) : false;
				const keyMatches = entry.key.toLowerCase().includes(this.searchValue.toLowerCase());
				return aliasMatches || keyMatches;
			});
		}

		filteredValues.forEach(element => {
			const keySeparator = element.info.description && element.info.description !== "" ? " - " : "";
			const label = element.info.alias ? element.info.alias : element.info.keyName;
			this.predictiveValues.push({
				key: element.info.type + keySeparator + element.info.description,
				techkey: createKey(element.info.type + keySeparator + element.info.description + keySeparator + label + keySeparator + element.info.uniqueId),
				value: element.info.value,
				label: label,
				searchValues: element.info.searchValues,
				icon: checkIconType(element.info.type),
				basekey: element.key,
				stationsIds: element.info.stationsIds
			});
		});
	}

	updateSearchbox(event) {
		let searchbox = this.template.querySelector(".searchbox");
		searchbox.value = event.detail && event.detail.value ? event.detail.value : event.target.value;
		searchbox.key = event.detail && event.detail.basekey && event.detail.basekey.split("##").length > 1 ? event.detail.basekey.split("##")[1] : "";
		this.resultsPage(searchbox);
	}

	resultsPage(searchBoxFilled) {
		let searchList = [];
		let searchbox = searchBoxFilled && searchBoxFilled.value ? searchBoxFilled : this.template.querySelector(".searchbox");
		let searchObject = { operator: "LIKE", value: searchbox.value };
		let filteredValues = [];

		if (this.isLocation) {
			searchObject.obj = "ICG_Account_Role_Detail__c";
			searchObject.field = "City_FOR__c";

			filteredValues = this.availableLocations.filter(entry => {
				const splittedKey = entry.key.toLowerCase().split("#");
				return splittedKey[0] === searchbox.value ? searchbox.value.toLowerCase() : "";
			});

			if (filteredValues.length) {
				searchObject.type = filteredValues[0].info.type;
			}
		} else if (this.isCompanyName) {
			searchObject.obj = "ICG_Account_Role_Detail__c";
			searchObject.field = "Company_FOR__c";
			if (searchbox && searchbox.key && searchbox.key !== "") {
				let additionalSearchObject = {
					operator: "LIKE",
					value: searchbox.key,
					obj: "ICG_Account_Role_Detail__c",
					field: "City_FOR__c",
					type: "Country"
				};
				searchList.push(additionalSearchObject);
			}
		} else if (this.isCertification) {
			searchObject.obj = "ICG_Capability_Assignment_Group__c";
			searchObject.field = "ICG_Certification__r.Name";
			searchObject.relationfield = "ICG_Account_Role_Detail__c";

			let filteredValues = this.availableCertifications.filter(entry => {
				//Get the clicked element by Alias (used for certs)
				const alias = entry.info.alias;
				const aliasMatches = alias ? alias.toLowerCase().includes(this.searchValue.toLowerCase()) : false;
				return aliasMatches;
			});
			if (filteredValues.length > 0) {
				searchObject.value = filteredValues[0].info.keyName;
			}
		}

		searchList.push(searchObject);

		const urlParams = prepareSearchParams(searchList);
		window.location.href = this.urlResultPage + "?q=" + urlParams;
	}

	showPopover(event) {
		let item = event.currentTarget.dataset.item;
		this.tooltipToDisplay = item;
		let containerDiv = this.template.querySelector('[data-tosca="' + item + '"]');
		let bounds = containerDiv.getBoundingClientRect();
		const marginLeft = -(bounds.width / 10);
		const marginTop = bounds.height * 1.5;

		let tooltipObject = {
			item: item,
			text: this.label.icg_comming_soon,
			marginLeft: marginLeft,
			marginTop: marginTop
		};

		this.tooltipObject = tooltipObject;
	}

	hidePopover() {
		this.tooltipToDisplay = "";
		this.tooltipObject = null;
	}
}