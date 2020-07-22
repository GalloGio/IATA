import { LightningElement, wire, api, track } from "lwc";
import getURL from "@salesforce/apex/CW_Utilities.getURLPage";
import resources from "@salesforce/resourceUrl/ICG_Resources";
import { loadScript } from "lightning/platformResourceLoader";
import { removeFromArray, removeGenericItemFromList, prepareSearchObjectFEICategories, prepareSearchParams } from "c/cwUtilities";

const MAX_FILTERS_ALLOWED = 25;
let lstLocationTypes = {};
let lstLocations = [];
let lstValidationPrograms = [];
let lstCommodities = [];
let lstCompanyTypes = [];
let lstFEICategories = [];
export default class CwAdvancedSearchContainer extends LightningElement {
	@api label;
	urlResultPage;
	@api modalContainerWidth;
	@track allowSearch = true;
	@track filtersApplied = [];

	@wire(getURL, { page: "URL_ICG_ResultPage" })
	wiredURLResultPage({ data }) {
		if (data) {
			this.urlResultPage = data;
		}
	}

	connectedCallback(){
		lstLocationTypes = {};
		lstLocations = [];
		lstValidationPrograms = [];
		lstCommodities = [];
		lstCompanyTypes = [];
		lstFEICategories = [];
		if (window.LZString === undefined) {
			Promise.all([loadScript(this, resources + "/js/lz-string.js")]);
		}
	}

	getFilters() {
		let filters = [];

		if (lstLocations){
			lstLocations.forEach(item => {
				filters.push({'label':item, 'value':item});
			});
		}

		if (lstCommodities){
			lstCommodities.forEach(item => {
				filters.push({'label': item.name, 'value': item.name});
			});
		}

		if (lstCompanyTypes){
			lstCompanyTypes.forEach(item => {
				filters.push({'label': item.name, 'value': item.name});
			});
		}

		if (lstValidationPrograms){
			lstValidationPrograms.forEach(item=>{
				filters.push({'label': item.Name, 'value': item.Name});
			});
		}

		if (lstFEICategories){
			lstFEICategories.forEach(category => {
				if(category.selected){
					filters.push({ 'label': category.label, 'value': category.label});

					if(category.fields){
						category.fields.forEach(field => {
							if(field.selected){
								if(field.type === 'picklist' && field.options){
									field.options.forEach(opt => {
										if(opt.selected){
											filters.push({ label: opt.label + ' (' + category.label + ')', value: opt.label });
										}
									});
								} else if(field.type !== 'picklist') {
									filters.push({ label: field.label + ' (' + category.label + ')', value: field.label });
								}
							}
						});
					}
				}
			});
		}
		return filters;
	}

	updateAndCheckFiltersLimitReached() {
		this.filtersApplied = this.getFilters();
		this.allowSearch = this.filtersApplied.length <= MAX_FILTERS_ALLOWED;
	}
	setSelectedPrograms(event) {
		const programInput = event.detail;

		programInput.forEach(element => {
			if (element.selected) {
				let itemFound = lstValidationPrograms.find( obj => { return obj.Id === element.Id; }, element);
				if (!itemFound){
					lstValidationPrograms.push(element);
				}
			} else {
				lstValidationPrograms = removeFromArray(lstValidationPrograms, element);
			}
		});
		this.updateAndCheckFiltersLimitReached();
	}

	setCompanyTypes(event) {
		const cTypeInput = event.detail;
		cTypeInput.forEach(element => {
			if (element.selected) {
				let itemFound = lstCompanyTypes.find( obj => { return obj.value === element.value; }, element);
				if (!itemFound){
					lstCompanyTypes.push(element);
				}
			} else {
				lstCompanyTypes = removeFromArray(lstCompanyTypes, element);
			}
		});
		this.updateAndCheckFiltersLimitReached();
	}

	setCommodities(event) {
		const commodityInput = event.detail;

		commodityInput.forEach(element => {
			if (element.selected) {
				let itemFound = lstCommodities.find( obj => { return obj.name === element.name; }, element);
				if (!itemFound){
					lstCommodities.push(element);
				}
			} else {
				lstCommodities = removeFromArray(lstCommodities, element);
			}
		});
		this.updateAndCheckFiltersLimitReached();
	}

	setSelectedLocations(event) {
		const locationInput = event.detail;
		if (locationInput.action === "add") {
			switch (locationInput.position.charAt(locationInput.position.length - 1)) {
				case "1":
					lstLocations[0] = locationInput.location;
					if (locationInput.type) {
						lstLocationTypes[locationInput.location] = locationInput.type;
					}
					break;
				case "2":
					lstLocations[1] = locationInput.location;
					if (locationInput.type) {
						lstLocationTypes[locationInput.location] = locationInput.type;
					}
					break;
				default:
			}
		} else {
			lstLocations = removeFromArray(lstLocations, locationInput.location);
			delete lstLocationTypes[locationInput.location];
		}
		this.updateAndCheckFiltersLimitReached();
	}

	setSelectedCategory(event) {
		const categoryInput = event.detail;
		if (categoryInput.selected) {
			const updatedList = removeGenericItemFromList(categoryInput.label, lstFEICategories);
			lstFEICategories = updatedList.auxList;
			lstFEICategories.push(categoryInput);

		} else {
			categoryInput.fields.forEach(field => {
				field.selected = false;
			})

			const updatedList = removeGenericItemFromList(categoryInput.label, lstFEICategories);
			lstFEICategories = updatedList.auxList;
		}
		this.updateAndCheckFiltersLimitReached();
	}

	onSearch() {
		try {
			let searchList = [];

			searchList = this._getLocations(searchList);
			searchList = this._getCompanyNames(searchList);
			searchList = this._getCerts(searchList);
			searchList = this._getCommodities(searchList);
			searchList = this._getFEIEquipmentsPerCategory(searchList);


			const urlParams = prepareSearchParams(searchList);
			window.location.href = this.urlResultPage + "?q=" + urlParams;
		} catch (exc) {
			console.error(exc);
		}
	}

	_getLocations(searchList) {
		let location = { operator: "LIKE", obj: "icg_account_role_detail__c", field: "City_FOR__c" };
		location.value = lstLocations.join(";");

		for (let key in lstLocationTypes) {
			if (lstLocationTypes[key].toLowerCase() === "airport") {
				location.type = lstLocationTypes[key];
			}
		}

		searchList.push(location);

		return searchList;
	}

	_getCompanyNames(searchList) {
		Object.keys(lstCompanyTypes).forEach(element => {
			if (lstCompanyTypes[element].selected) {
				const searchObject = {
					value: lstCompanyTypes[element].value,
					operator: "LIKE",
					obj: lstCompanyTypes[element].obj,
					field: lstCompanyTypes[element].field
				};
				searchList.push(searchObject);
			}
		});
		return searchList;
	}
	_getCommodities(searchList) {
		Object.keys(lstCommodities).forEach(element => {
			if (lstCommodities[element].selected) {
				const searchObject = {
					value: lstCommodities[element].selected,
					operator: "=",
					obj: lstCommodities[element].obj,
					relationfield: lstCommodities[element].relationfield,
					field: lstCommodities[element].field
				};
				searchList.push(searchObject);
			}
		});
		return searchList;
	}
	_getCerts(searchList) {
		Object.keys(lstValidationPrograms).forEach(element => {
			if (lstValidationPrograms[element].selected) {
				const searchObject = {
					value: lstValidationPrograms[element].Name,
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
	_getFEIEquipmentsPerCategory(searchList) {
		let searchObject = prepareSearchObjectFEICategories(lstFEICategories, searchList);
		if (searchObject) {
			return searchObject;
		}
		return searchList;
	}
}