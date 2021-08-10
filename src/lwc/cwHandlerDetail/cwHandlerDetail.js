import { LightningElement, track, api } from "lwc";
import _getDefaultAirlineHandlersDataApex from "@salesforce/apex/CW_HandledAirlinesController.getAllAirlines";
import _getDefaultCargoRampHandlersApex from "@salesforce/apex/CW_CreateFacilityController.getOnAirportStations";

import saveAirlinesHandled from "@salesforce/apex/CW_HandledAirlinesController.saveAirlinesHandled";
import saveHiddenOperatingStations from "@salesforce/apex/CW_HandledAirlinesController.saveHiddenOperatingStations";

import resources from "@salesforce/resourceUrl/ICG_Resources";

const FILTER_LETTERS = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"];
export default class CwHandlerDetail extends LightningElement {

	generateItemsToShow(numberItemSum, numberItemLoopSum) {
		let itemsToLoop = this.showOnlySelected ? this.selectedItems : this.filteredHandlerItemsByText;
		if (itemsToLoop && itemsToLoop.length >= this.pageSelected + numberItemSum) {
			return itemsToLoop.slice((this.pageSelected - 1) * 15 + numberItemSum, (this.pageSelected - 1) * 15 + numberItemLoopSum);
		}
		return [];
	}
	get getAllItemsToShow() {
		return [
			{
				label: "first",
				value: this.generateItemsToShow(0, 5)
			},
			{
				label: "second",
				value: this.generateItemsToShow(5, 10)
			},
			{
				label: "third",
				value: this.generateItemsToShow(10, 15)
			}
		];
	}

	// ########################################################################################
	// @api
	// ########################################################################################

	@api stationProfile;

	@api handlerType;

	/**
	 * IMPORTANT: if the param @api isReadOnly = true, this parameter must be passed before the param @api handlerData in the initialization of the component
	 *  Example: <c-cw-handler-detail station-profile={profileData} handler-type="handlerType" url-base-to-station-profile="urlBaseToStationProfile" handler-data={handlerData} is-read-only={isReadOnly} label={label}>
	 */
	@api urlBaseToStationProfile;

	_handlerData;
	_settingHandlerData = false;
	@api
	get handlerData() {
		return this._handlerData;
	}
	set handlerData(value) {
		this._settingHandlerData = true;
		if (!this.isValidHandlerType) {
			this._handlerData = [];
			this._handlerDataDraft = [];
			this._settingHandlerData = false;
		} else {
			this.completeData(value)
				.then( (response) => {
					this._handlerData = JSON.parse(JSON.stringify(this.transformHandlerData(response)));
					this._handlerDataDraft = JSON.parse(JSON.stringify(this._handlerData));
				})
				.finally( () => {
					this._settingHandlerData = false;
				});
		}
	}

	completeData(value) {
		return new Promise((resolve) => {
			if (this.isAirlineHandlers) {
				this.getDefaultAirlineHandlersDataApex()
					.then(response => {
						response.forEach(_data => {
							let itemFound = value.find( obj => { return obj.value === _data.value; });
							if (itemFound){ _data.selected = itemFound.selected; }
						});
						resolve(JSON.parse(JSON.stringify(response)));
					});
			} else {
				if (value === undefined || value.length === 0) {
					this.getDefaultCargoRampHandlersApex().then(response => { resolve(response); });
				} else {
					resolve(value);
				}
			}
		});
	}

	_editModeAvailable = false;
	@api
	get isEditModeAvailable() {
		return this._editModeAvailable;
	}
	set isEditModeAvailable(value) {
		this._editModeAvailable = value;
	}

	_isReadOnly;
	@api
	get isReadOnly() {
		return this._isReadOnly;
	}
	set isReadOnly(val) {
		this._isReadOnly = val;
		this.showOnlySelected = val;

		this.dispatchEvent(
			new CustomEvent("event", {
				detail: {
					name: "changeReadOnly",
					handlerType: this.handlerType,
					isReadOnly: this._isReadOnly
				}
			})
		);
	}

	@api label;

	@api autoSelection = false;

	@api
	getItemsSelected() {
		this.dispatchEvent(
			new CustomEvent("event", {
				detail: {
					name: "getItemsSelected",
					handlerType: this.handlerType,
					itemsToAdd: this.getHandlerItemIdsToShow
				}
			})
		);
	}
	@api getShownOperationStations() {
		this.dispatchEvent(
			new CustomEvent("event", {
				detail: {
					name: "getShownOperationStations",
					handlerType: this.handlerType,
					idsToShow: this.getHandlerItemIdsToShow
				}
			})
		);
	}
	@api getHiddenOperationStations() {
		this.dispatchEvent(
			new CustomEvent("event", {
				detail: {
					name: "getHiddenOperationStations",
					handlerType: this.handlerType,
					idsToHide: this.getHandlerItemIdsToHide
				}
			})
		);
	}

	// ########################################################################################
	// @track / normal variables
	// ########################################################################################
	@track _handlerDataDraft = []; // Manage items seleceted / unselected draft

	// pagination
	@track pageSelected = 1;

	// Filter
	@track showOnlySelected = false;
	@track letterSelected;

	// ########################################################################################
	// Properties
	// ########################################################################################

	// Items Filter
	_filterText;
	get filterText() {
		return this._filterText;
	}
	set filterText(val) {
		this._filterText = val;
		if (this.letterSelected) {
			this.unselectLetter();
		}
	}
	get filteredHandlerItemsByText() {
		if (!this.filterText) {
			return this.filteredHandlerItemsByFirstLetter;
		} else {
			let filteredItems = [];
			this.filteredHandlerItemsByFirstLetter.forEach(handlerItem => {
				if (handlerItem.isHeader == false && handlerItem.label && handlerItem.label.length > 0 && handlerItem.label.toLowerCase().indexOf(this.filterText.toLowerCase()) > -1) {
					filteredItems.push(handlerItem);
				}
			});

			this.addHandlerItemHeaders(filteredItems);
			return filteredItems;
		}
	}
	get getLettersForFilters() {
		return FILTER_LETTERS;
	}
	get filteredHandlerItemsByFirstLetter() {
		if (!this.letterSelected) {
			return this._handlerDataDraft;
		} else {
			let filteredItems = [];
			const isOthersLetter = this.letterSelected.toLowerCase() === 'others';
			this._handlerDataDraft.forEach(handlerItem => {
				const currentLabel = (handlerItem && handlerItem.label) ? handlerItem.label.trim().toUpperCase() : '';
				if (handlerItem.isHeader == false && currentLabel.length > 0 
					&& (
						(isOthersLetter === false && FILTER_LETTERS.indexOf(currentLabel[0]) >= 0 && currentLabel[0].toLowerCase() === this.letterSelected.toLowerCase())
						||
						(isOthersLetter === true && FILTER_LETTERS.indexOf(currentLabel[0]) < 0)
					)
				) {
					filteredItems.push(handlerItem);
				}
			});
			this.addHandlerItemHeaders(filteredItems);

			return filteredItems;
		}
	}

	// Items Filter Result
	get showHideSelectedItemsButtonText() {
		return this.showOnlySelected ? this.label.icg_show_all : this.label.icg_show_selected;
	}
	get selectedItems() {
		let selectedItems = [];
		this.filteredHandlerItemsByText.forEach(currentHandlerItem => {
			if (currentHandlerItem.isHeader == false && currentHandlerItem.selected == true) {
				selectedItems.push(currentHandlerItem);
			}
		});
		this.addHandlerItemHeaders(selectedItems);
		return selectedItems;
	}

	// Validations
	get validHandlerTypes() {
		return ["airline", "cargo", "ramp"];
	}
	get isValidHandlerType() {
		return this.handlerType && this.validHandlerTypes.indexOf(this.handlerType) > -1;
	}
	get isAirlineHandlers() {
		return this.isValidHandlerType && this.handlerType == "airline";
	}
	get isCargoHandlers() {
		return this.isValidHandlerType && this.handlerType == "cargo";
	}
	get isRampHandlers() {
		return this.isValidHandlerType && this.handlerType == "ramp";
	}

	// Data
	get getTitle() {
		if (!this.stationProfile) {
			return null;
		} else if (this.isAirlineHandlers) {
			if (this.stationProfile.recordTypeDevName == "Ramp_Handler") {
				return this.label.list_airlines_handled;
			} else if (this.stationProfile.recordTypeDevName == "Cargo_Handling_Facility") {
				return this.label.list_airlines_handled;
			} else if (this.stationProfile.recordTypeDevName == "Airport_Operator") {
				return this.label.operating_airlines;
			}
		} else if (this.isCargoHandlers) {
			return this.label.operating_cargo_handling_facilities;
		} else if (this.isRampHandlers) {
			return this.label.operating_ramp_handler;
		} else {
			return null;
		}
	}
	get getHandlerItemIdsToAdd() {
		let itemsToAdd = [];

		this._handlerDataDraft.forEach(newItem => {
			if (newItem.isHeader === false && newItem.selected === true) {
				let previousItem;
				if (this.handlerData && this.handlerData != null) {
					previousItem = this.handlerData.find(itemFound => itemFound.isHeader === false && itemFound.value === newItem.value);
				}

				if (!previousItem || previousItem.selected === false) {
					itemsToAdd.push(newItem.value);
				}
			}
		});

		return itemsToAdd;
	}
	get getHandlerItemIdsToDel() {
		let itemsToDel = [];
		this.handlerData.forEach(previousItem => {
			if (previousItem.isHeader === false && previousItem.selected === true) {
				let newItem;
				if (this._handlerDataDraft && this._handlerDataDraft != null) {
					newItem = this._handlerDataDraft.find(itemFound => itemFound.isHeader === false && itemFound.value === previousItem.value);
				}
				if (!newItem || newItem.selected === false) {
					itemsToDel.push(previousItem.value);
				}
			}
		});

		return itemsToDel;
	}
	get getHandlerItemIdsToShow() {
		let idsToShow = [];
		this._handlerDataDraft.forEach(currentHandlerItem => {
			if (currentHandlerItem.isHeader === false && currentHandlerItem.selected === true) {
				idsToShow.push(currentHandlerItem.value);
			}
		});
		return idsToShow;
	}
	get getHandlerItemIdsToHide() {
		let idsToHide = [];
		this._handlerDataDraft.forEach(currentHandlerItem => {
			if (currentHandlerItem.isHeader === false && currentHandlerItem.selected === false) {
				idsToHide.push(currentHandlerItem.value);
			}
		});
		return idsToHide;
	}

	// Pagination
	get showBackButton() {
		return this.pageSelected > 1;
	}
	get showNextButton() {
		let list = this.showOnlySelected ? this.selectedItems : this.filteredHandlerItemsByText;
		let listSize = list ? list.length : 15;
		return (this.pageSelected - 1) * 15 + 15 < listSize;
	}

	// Styles
	get getCssTitle() {
		if (this.isCargoHandlers) {
			return "slds-truncate";
		} else {
			return "";
		}
	}
	get getCssYellowUnderlineTitle() {
		if (this.isRampHandlers) {
			return "yellow-underline";
		} else {
			return "yellow-underline mt-2";
		}
	}
	get getCssItemReadOnly() {
		return this.isReadOnly ? "itemBase itemUnselected text-truncate cursor-default" : "itemBase itemUnselected text-truncate";
	}
	get getCssItemUnselectedEditMode() {
		return "itemBase itemUnselected text-truncate cursor-default";
	}
	get getCssItemSelectedEditMode() {
		return "itemBase itemSelectedPrivate text-truncate cursor-default";
	}
	get getIconInformation() {
		return resources + "/icons/company_type/cargo_com_airline.jpg";
	}
	get getIconSelectedItem() {
		return resources + "/icons/ic-tic-blue.svg";
	}

	// ########################################################################################
	// Logic
	// ########################################################################################
	@api
	setDefaultHandlerData() {
		if (this.handlerType == "airline") {
			this.getDefaultAirlineHandlersDataApex()
				.then(response => { this.handlerData = response; });

		} else if (this.handlerType == "cargo" || this.handlerType == "ramp") {
			this.getDefaultCargoRampHandlersApex()
				.then(response => { this.handlerData = response; });
		}
	}

	getDefaultAirlineHandlersDataApex() {
		return new Promise((resolve) => {
			_getDefaultAirlineHandlersDataApex()
				.then(returnData => {
					if (returnData && returnData != null) {
						returnData = JSON.parse(returnData);
					}
					resolve(returnData);
				})
				.catch(error => {
					resolve([]);
				});

		});
	}

	getDefaultCargoRampHandlersApex() {
		return new Promise((resolve) => {
			_getDefaultCargoRampHandlersApex({
				rtype: this.stationProfile.recordTypeDevName,
				accountName: this.stationProfile.accountName,
				airportId: this.stationProfile.nearestAirport.city,
				accountId: this.stationProfile.companyId
			})
				.then(returnData => {
					let defaultHandlerData = [];
					JSON.parse(returnData).forEach(currentItem => {
						if (this.handlerType == "cargo" && currentItem.recordTypeDevName == "Cargo_Handling_Facility") {
							defaultHandlerData.push(currentItem);
						} else if (this.handlerType == "ramp" && currentItem.recordTypeDevName == "Ramp_Handler") {
							defaultHandlerData.push(currentItem);
						}
					});
					resolve(defaultHandlerData);
				})
				.catch(error => {
					resolve([]);
				});
		});
	}

	transformHandlerData(valuesToTransform) {
		let newValues = [];
		valuesToTransform.forEach(currentItem => {
			let newCurrentItem = JSON.parse(JSON.stringify(currentItem));
			newCurrentItem.isHeader = false;

			// Auto Selection
			if (this.autoSelection === true) {
				if (this.stationProfile.recordTypeDevName === "Airline" && (this.handlerType === "cargo" || this.handlerType === "ramp")) {
					newCurrentItem.selected = false;
				} else if (this.stationProfile.recordTypeDevName === "Airport_Operator" && (this.handlerType === "cargo" || this.handlerType === "ramp")) {
					newCurrentItem.selected = true;
				}
			}

			// Url to Station Profile
			if (this.handlerType == "cargo" || this.handlerType == "ramp") {
				newCurrentItem.stationProfileUrl = this.urlBaseToStationProfile + "?eid=" + newCurrentItem.value;
			}

			newValues.push(newCurrentItem);
		});

		this.addHandlerItemHeaders(newValues);

		return newValues;
	}

	addHandlerItemHeaders(values) {
		// If contains headers, remove them to add the new ones
		let headerIndexToRemove = [];
		for (let z = values.length - 1; z >= 0; z--) {
			if (values[z].isHeader && values[z].isHeader === true) {
				headerIndexToRemove.push(z);
			}
		}
		headerIndexToRemove.forEach(index => {
			values.splice(index, 1);
		});

		let headers = [];
		values.forEach(currentItem => {
			if (currentItem.isHeader === undefined || currentItem.isHeader === false) {
				if (currentItem.label && currentItem.label.length > 0) {
					let firstChar = currentItem.label[0].toUpperCase();
					if (headers.indexOf(firstChar) < 0) {
						headers.push(firstChar);
					}
				}
			}
		});

		headers.forEach(currentHeader => {
			values.push({ label: currentHeader, value: currentHeader, isHeader: true });
		});
		values.sort(this.sortItems);
	}
	removeHandlerItemHeaders(values) {
		let valuesWithoutHeaders = [];

		values.forEach(currentItem => {
			if (currentItem.label && currentItem.label.length > 0 && currentItem.isHeader === false) {
				valuesWithoutHeaders.push(currentItem);
			}
		});

		valuesWithoutHeaders.sort(this.sortItems);
		return valuesWithoutHeaders;
	}

	sortItems(a, b) {
		let aFixed = a.label.trim().toUpperCase();
		if (aFixed.length > 0 && FILTER_LETTERS.indexOf(aFixed[0]) < 0 ) { aFixed = 'ZZZZ' + aFixed; }

		let bFixed = b.label.trim().toUpperCase();
		if (bFixed.length > 0 && FILTER_LETTERS.indexOf(bFixed[0]) < 0 ) { bFixed = 'ZZZZ' + bFixed; }

		if (aFixed < bFixed) { return -1; }
		if (aFixed > bFixed) { return 1; }
		return 0;
	}

	@api
	saveHandlerItems() {
		if (!this.isValidHandlerType) {
			return;
		}

		if (this.stationProfile && this.handlerData && this._handlerDataDraft) {
			if (this.isAirlineHandlers || this.stationProfile.recordTypeDevName === "Airline") {
				this.saveHandlerItemsAirline();
			} else if ((this.isCargoHandlers || this.isRampHandlers) && this.stationProfile.recordTypeDevName === "Airport_Operator") {
				this.saveHandlerItemsHiddenOperatingStation();
			}
		}
	}
	saveHandlerItemsAirline() {
		let itemsToAdd = this.getHandlerItemIdsToAdd;
		let itemsToDel = this.getHandlerItemIdsToDel;

		if (itemsToAdd.length > 0 || itemsToDel.length > 0) {
			saveAirlinesHandled({
				addList: JSON.stringify(itemsToAdd),
				deleteList: JSON.stringify(itemsToDel),
				facilityId: this.stationProfile.Id
			})
				.then(result => {
					this.handlerData = this.removeHandlerItemHeaders(this._handlerDataDraft);
					this.dispatchEvent(
						new CustomEvent("event", {
							detail: {
								name: "save",
								handlerType: this.handlerType
							}
						})
					);
				})
				.catch(err => {
					this.dispatchEvent(
						new CustomEvent("event", {
							detail: {
								name: "save",
								handlerType: this.handlerType,
								error: err,

								addList: JSON.stringify(itemsToAdd),
								deleteList: JSON.stringify(itemsToDel),
								facilityId: this.stationProfile.Id
							}
						})
					);
				});
		}
	}
	saveHandlerItemsHiddenOperatingStation() {
		if (JSON.stringify(this.handlerData) != JSON.stringify(this._handlerDataDraft)) {
			let itemsToHide = this.getHandlerItemIdsToHide;
			let hiddenOperatingStations = "Operating" + this.handlerType.charAt(0).toUpperCase() + this.handlerType.slice(1) + ":" + itemsToHide.join(",");

			saveHiddenOperatingStations({ hiddenOperatingStations: hiddenOperatingStations, facilityId: this.stationProfile.Id })
				.then(result => {
					if (result) {
						this.handlerData = this.removeHandlerItemHeaders(this._handlerDataDraft);
						this.dispatchEvent(
							new CustomEvent("event", {
								detail: {
									name: "save",
									handlerType: this.handlerType,
									result: result
								}
							})
						);
					}
				})
				.catch(err => {
					this.dispatchEvent(
						new CustomEvent("event", {
							detail: {
								name: "save",
								handlerType: this.handlerType,
								error: err,

								hiddenOperatingStations: hiddenOperatingStations,
								facilityId: this.stationProfile.Id
							}
						})
					);
				});
		}
	}

	// ########################################################################################
	// Events
	// ########################################################################################
	connectedCallback() {
		if (!this._settingHandlerData && (this.handlerData == undefined || this.handlerData == null || this.handlerData.length == 0)) {
			this.setDefaultHandlerData();
		}	
	}

	// Handler Item
	toggleReadOnlyMode(event) {
		this.isReadOnly = !this.isReadOnly;
	}

	setSelectedHandlerItem(event) {
		event.preventDefault();

		if (!this.isValidHandlerType || this.isReadOnly) {
			return;
		}

		let eTarget = event.currentTarget;
		let itemSelected;
		let itemsUpdated = [];
		this._handlerDataDraft.forEach(elem => {
			if (elem.value === eTarget.dataset.name) {
				elem.selected = !elem.selected;
				itemSelected = JSON.parse(JSON.stringify(elem));
			}
			if (elem.isHeader === false) {
				itemsUpdated.push(elem);
			}
		});

		this.dispatchEvent(
			new CustomEvent("event", {
				detail: {
					name: "selectItem",
					handlerType: this.handlerType,
					itemSelected: itemSelected
				}
			})
		);
	}

	// Search
	setHandlersFilterText(event) {
		this.filterText = event.detail;
	}
	showHideSelectedItems(event) {
		this.unselectLetter();
		this.showOnlySelected = !this.showOnlySelected;
	}
	unselectLetter(event) {
		this.pageSelected = 1;
		this.letterSelected = null;
		this.template.querySelectorAll(".letterSelected").forEach(elem => {
			elem.classList.remove("letterSelected");
		});
		this.template.querySelector('[data-letter="ALL"]').classList.add("letterSelected");
	}
	selectLetter(event) {
		this.pageSelected = 1;
		this.letterSelected = event.currentTarget.dataset.letter;
		this.template.querySelectorAll(".letterSelected").forEach(elem => {
			elem.classList.remove("letterSelected");
		});

		this.template.querySelector('[data-letter="' + this.letterSelected + '"]').classList.add("letterSelected");
	}

	// Pagination
	back(event) {
		this.pageSelected--;
	}
	next(event) {
		this.pageSelected++;
	}
}