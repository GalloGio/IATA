import { LightningElement, wire, api } from "lwc";
import getURL from "@salesforce/apex/CW_Utilities.getURLPage";
import { removeFromArray, removeGenericItemFromList, prepareSearchObjectFEICategories, prepareSearchParams } from "c/cwUtilities";

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

	@wire(getURL, { page: "URL_ICG_ResultPage" })
	wiredURLResultPage({ data }) {
		if (data) {
			this.urlResultPage = data;
		}
	}

	setSelectedPrograms(event) {
		const programInput = event.detail;

		programInput.forEach(element => {
			if (element.selected) {
				lstValidationPrograms.push(element);
			} else {
				lstValidationPrograms = removeFromArray(lstValidationPrograms, element);
			}
		});
	}

	setCompanyTypes(event) {
		const cTypeInput = event.detail;
		cTypeInput.forEach(element => {
			if (element.selected) {
				lstCompanyTypes.push(element);
			} else {
				lstCompanyTypes = removeFromArray(lstCompanyTypes, element);
			}
		});
	}

	setCommodities(event) {
		const commodityInput = event.detail;

		commodityInput.forEach(element => {
			if (element.selected) {
				lstCommodities.push(element);
			} else {
				lstCommodities = removeFromArray(lstCommodities, element);
			}
		});
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