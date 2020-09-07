import { LightningElement, track, wire } from "lwc";
import getURL from "@salesforce/apex/CW_Utilities.getURLPage";
import getComparisonSchema from "@salesforce/apex/CW_FacilityCapabilitiesController.getComparisonSchema";
import resources from "@salesforce/resourceUrl/ICG_Resources";
import labels from "c/cwOneSourceLabels";
import { ShowToastEvent } from "lightning/platformShowToastEvent";
import { loadScript } from "lightning/platformResourceLoader";

const LOCAL_STORAGE_COMPARE_FIELD = "facilitiesToCompare";
const MAX_ITEMS_TO_COMPARE = 3;

import { concatinateFacilityAddress, concatinateAddressString, removeLastCommaAddress, removeFromComparisonCommon, saveComparisonListToLocalStorage } from "c/cwUtilities";

export default class CwFacilityCompareContainer extends LightningElement {
	icons = {
		searchByLocation: resources + "/icons/search-by-location.svg",
		close: resources + "/icons/icon-close-black.svg"
	};

	label = labels.labels();

	@track tooltipObject;
	@track tooltipToDisplay = "";

	initialized = false;
	@track error;
	@track isUpdating = false;

	get isDataLoaded() {
		return (this.facilitiesToCompare && this.comparisonSchema && this.comparisonSchema.superCategories) || this.isUpdating;
	}
	connectedCallback() {
		if (window.LZString === undefined) {
			Promise.all([loadScript(this, resources + "/js/lz-string.js")]);
		}
	}
	renderedCallback() {
		if (!this.initialized) {
			this.initialized = true;
			this.facilitiesToCompare = this.readFacilititiesToCompareFromLocalStorage();
			this.loadComparisonData();
		}
	}

	readFacilititiesToCompareFromLocalStorage() {
		let tmpFacilitiesToCompare = JSON.parse(window.localStorage.getItem(LOCAL_STORAGE_COMPARE_FIELD)) || [];
		tmpFacilitiesToCompare.forEach(function(currentFacility, currentFacilityIndex) {
			currentFacility.cssClassColumn = currentFacilityIndex === 1 ? "col-3 middle-facility" : "col-3";
			if (currentFacility.Id) {
				let address = concatinateAddressString(currentFacility.addressStreetNr) + concatinateAddressString(currentFacility.secondAddress) + concatinateFacilityAddress(currentFacility);
				address = removeLastCommaAddress(address);
				currentFacility.address = address;
				currentFacility.mailTo = "mailTo:" + currentFacility.email;
				currentFacility.phoneTo = "tel:" + currentFacility.phone;
				currentFacility.addresstogm = address ? "https://maps.google.com/?q=" + address : "#";
				currentFacility.listIndex = currentFacilityIndex + currentFacility.cssClassColumn + currentFacility.name;
			}
		});
		while (tmpFacilitiesToCompare.length < MAX_ITEMS_TO_COMPARE) {
			const cssClassColumn = tmpFacilitiesToCompare.length === 1 ? "col-3 middle-facility" : "col-3";
			tmpFacilitiesToCompare.push({ cssClassColumn: cssClassColumn, listIndex: tmpFacilitiesToCompare.length + cssClassColumn });
		}
		return tmpFacilitiesToCompare;
	}

	@track _facilitiesToCompare = null;
	get facilitiesToCompare() {
		return this._facilitiesToCompare;
	}

	set facilitiesToCompare(value) {
		try {
			this._facilitiesToCompare = value;
		} catch (error) {
			this.showToast("Comparison", "Something went wrong", "error");
		}
	}

	_accountRoleDetailRT = null;
	get accountRoleDetailRT() {
		if (this._accountRoleDetailRT == null && this.facilitiesToCompare.length > 0) {
			this._accountRoleDetailRT = this.facilitiesToCompare[0].recordTypeDevName;
		}

		return this._accountRoleDetailRT;
	}

	@wire(getURL, { page: "URL_ICG_ResultPage" })
	urlResultPage;

	@wire(getURL, { page: "URL_ICG_FacilityPage" })
	facilityPage;

	rawSchemaData;
	frontKeyCounter = 0;

	loadComparisonData() {
		getComparisonSchema({ accountRoleDetailRT: this.accountRoleDetailRT })
			.then(result => {
				this.rawSchemaData = JSON.parse(JSON.stringify(result));
				this.rawSchemaData.superCategories.forEach(supercategory => {
					let key = supercategory.label;
					key = key.toLowerCase();
					key = key.replace(/ /g, "_");
					supercategory.key = key;
					supercategory.frontKey = key + this.frontKeyCounter++;
				});

				this.updateSchemaTable();
			})
			.catch(error => {
				this.error = error;
				console.error(error);
			});
	}

	handleComparisonSchema(array) {
		let arrayCopy = JSON.parse(JSON.stringify(array));

		// Loop comparison sections
		arrayCopy.superCategories.forEach(compSuperCategory => {
			compSuperCategory.sections.forEach(compSection => {
				// Loop comparison Record Types
				compSection.rts.forEach(compRt => {
					// Loop comparison categories
					compRt.categories.forEach(compCategory => {
						// Loop comparison equipments
						compCategory.equipments.forEach(compEquipment => {
							// try to get data
							// let dataFound = { auxType: undefined, rows: []};
							let dataFound = this.getDataComparison(compSection.label, compRt.name, compCategory.value, compEquipment.label, compCategory.columns);
							compCategory.auxType = dataFound.auxType;
							compEquipment.auxType = dataFound.auxType;
							if (!compEquipment.rows) {
								compEquipment.rows = [];
							}
							dataFound.rows.forEach(currentRow => {
								currentRow.frontKey = "row" + this.frontKeyCounter++;
								compEquipment.rows.push(currentRow);
							});
						});
					});
				});
			});
		});

		this.error = undefined;
		this.isUpdating = false;
		return JSON.parse(JSON.stringify(arrayCopy));
	}

	@track comparisonSchema;

	prepareBasicDataFoundArray() {
		let dataFound = [];
		for (let x = 0; x < MAX_ITEMS_TO_COMPARE; x++) {
			dataFound.push([]);
		}

		return dataFound;
	}

	calculateValueCss(index) {
		return index === 1 ? "col-3 text-center col-no-padding middle-facility" : "col-3 text-center col-no-padding";
	}

	calculateRowCss(isFirst) {
		return isFirst ? "row-no-margin col-12 col-no-padding" : "row-no-margin col-12 col-no-padding hidden";
	}

	getDataComparison(sectionToSearch, rtToSearch, categoryToSearch, equipmentToSearch, columns) {
		let returnValue = {
			auxType: undefined,
			rows: []
		};
		let dataFound = this.prepareBasicDataFoundArray();

		// Facility Loop
		let currentFacilityIndex = 0;
		let facilitiesToCompareNumber = 0;

		let specialAuxType = ["standard_temperature_ranges", "custom_temperature_ranges", "temperature_controlled_ground_service_eq", "tcha_temperature_range__c"];

		let facilitiesCopy = JSON.parse(JSON.stringify(this.facilitiesToCompare));

		facilitiesCopy.forEach(currentFacility => {
			if (currentFacility.capabilities && currentFacility.capabilities.superCategories) {
				facilitiesToCompareNumber += 1;

				// Section Lopp
				currentFacility.capabilities.superCategories.forEach(currentSuperCategory => {
					if (currentSuperCategory.sections) {
						currentSuperCategory.sections.forEach(currentSection => {
							if (currentSection.label === sectionToSearch) {
								// Rt Loop
								currentSection.capabilities.forEach(currentRt => {
									if (currentRt.name === rtToSearch.toLowerCase()) {
										// Category Loop
										currentRt.categories.forEach(currentCategory => {
											let lastRowIndex = -1;
											if (currentCategory.value === categoryToSearch) {
												// If not is defined auxType, set
												if (!returnValue.auxType) {
													returnValue.auxType = currentCategory.auxType;
												}
												// Equipment Lopp
												currentCategory.rows.forEach(currentEquipment => {
													let generateFirstHeader = specialAuxType.includes(currentCategory.auxType);

													if (currentEquipment.equipment__c === equipmentToSearch) {
														lastRowIndex += 1;
														// found data, remove unused properties and add new ones
														let valueFound = JSON.parse(JSON.stringify(currentEquipment));

														columns.forEach(function(currentColumn, currentColumnIndex) {
															let tmpValue = valueFound[currentColumn.name];
															let tmpColumn = JSON.parse(JSON.stringify(currentColumn));
															tmpColumn.key = `${sectionToSearch}#${rtToSearch}#${categoryToSearch}#${equipmentToSearch}`.replace(/ /g, "_").toLowerCase();

															if (generateFirstHeader) {
																if (lastRowIndex === 0) {
																	generateFirstHeader = false;
																	let tmpHeaderColumn = JSON.parse(JSON.stringify(tmpColumn));
																	tmpHeaderColumn.auxType = currentCategory.auxType;

																	dataFound[currentFacilityIndex].push({
																		column: tmpHeaderColumn,
																		value: valueFound[currentColumn.name]
																	});
																}

																if (currentColumn.name === "equipment__c") {
																	tmpColumn.name = "equipment__c_dummy";
																	tmpColumn.label = currentEquipment[currentColumn.name];
																	tmpColumn.auxType = currentCategory.auxType;
																	tmpColumn.index = lastRowIndex;
																	tmpColumn.cssClass = "row-field";
																	tmpColumn.cssClassFacility = "row-field-facility";
																	tmpValue = null;
																}
															}

															dataFound[currentFacilityIndex].push({
																column: tmpColumn,
																value: tmpValue
															});
														});
													}
												});
											}
										});
									}
								});
							}
						});
					}
				});
			}

			currentFacilityIndex += 1;
		});
		this.facilitiesToCompare = JSON.parse(JSON.stringify(facilitiesCopy));

		let maxRows = this.extractMaxRowsForDataFound(dataFound);
		for (let rowIndex = 0; rowIndex < maxRows; rowIndex++) {
			let currentRow = {
				values: []
			};

			currentRow.info = this.extractRowInfo(dataFound, rowIndex, facilitiesToCompareNumber);

			dataFound.forEach((currentDataFound, currentDataFoundIndex) => {
				currentRow = this.handleCurrentRow(currentDataFound, currentDataFoundIndex, currentRow, rowIndex, facilitiesToCompareNumber);
			});
			let newValues = [];
			for (let index = 0; index < currentRow.values.length; index++) {
				let tmpValue = {};
				tmpValue[currentRow.info.name] = currentRow.values[index];
				tmpValue.valueCss = this.calculateValueCss(index);
				tmpValue.frontKey = "value" + this.frontKeyCounter++;
				newValues.push(tmpValue);
			}
			currentRow.values = newValues;
			let isFirst = rowIndex === 0;
			currentRow.isFirst = isFirst;
			currentRow.rowCss = this.calculateRowCss(isFirst);
			let objToAdd = this.calculateRowToAdd(currentRow);
			returnValue.rows.push(objToAdd);
		}

		if (returnValue.rows.length === 0) {
			for (let index = 0; index < columns.length; index++) {
				let currentColumn = columns[index];
				let key = sectionToSearch + "#" + rtToSearch + "#" + categoryToSearch + "#" + equipmentToSearch;
				key = key.toLowerCase();
				key = key.replace(/ /g, "_");
				let rowToAdd = {
					info: {
						cssClass: currentColumn.cssClass,
						cssClassFacility: currentColumn.cssClassFacility,
						label: currentColumn.name.toLowerCase() === "equipment__c" ? equipmentToSearch : currentColumn.label,

						name: currentColumn.name,
						key: key
					},
					values: []
				};

				for (let x = 0; x < MAX_ITEMS_TO_COMPARE; x++) {
					let dummyValue = {};
					if (x < facilitiesToCompareNumber) {
						dummyValue[rowToAdd.info.name] = rowToAdd.info.name.toLowerCase() === "equipment__c" ? false : null;
					}
					dummyValue.valueCss = this.calculateValueCss(x);
					dummyValue.frontKey = "value" + this.frontKeyCounter++;
					rowToAdd.values.push(dummyValue);
				}
				let isFirst = index === 0;
				rowToAdd.isFirst = isFirst;
				rowToAdd.rowCss = this.calculateRowCss(isFirst);
				let objToAdd = this.calculateRowToAdd(rowToAdd);
				returnValue.rows.push(objToAdd);
			}
		}

		return returnValue;
	}

	calculateRowToAdd(currentRow) {
		return {
			isFirst: currentRow.isFirst,
			rowCss: currentRow.rowCss,
			values: currentRow.values,
			info: currentRow.info
		};
	}

	extractRowInfo(dataFound, rowIndex, facilitiesToCompareNumber) {
		let info;

		for (let i = 0; i < facilitiesToCompareNumber; i++) {
			let rowData = dataFound[i];
			if (rowData && rowData[rowIndex] && rowData[rowIndex].column && !info) {
				info = rowData[rowIndex].column;
				if (info.name.toLowerCase() === "equipment__c") {
					info.label = rowData[rowIndex].value;
				}
			}
		}
		return info;
	}

	handleCurrentRow(currentDataFound, currentDataFoundIndex, rawCurrentRow, rowIndex, facilitiesToCompareNumber) {
		let currentRow = JSON.parse(JSON.stringify(rawCurrentRow));
		currentRow.values.push(undefined);

		currentRow.values[currentDataFoundIndex] = currentDataFound[rowIndex];

		if (currentRow.values[currentDataFoundIndex]) {
			// Comparison data
			currentRow.values[currentDataFoundIndex] = currentRow.values[currentDataFoundIndex].value;

			if (currentRow.info.name.toLowerCase() === "equipment__c") {
				currentRow.values[currentDataFoundIndex] = currentRow.values[currentDataFoundIndex].length > 0;
			}
		} else if (currentRow.info && currentRow.info.name.toLowerCase() === "equipment__c" && currentDataFoundIndex < facilitiesToCompareNumber) {
			currentRow.values[currentDataFoundIndex] = false;
		}
		return currentRow;
	}

	extractMaxRowsForDataFound(dataFound) {
		let maxRows = 0;

		dataFound.forEach(currentDataFound => {
			if (currentDataFound.length > maxRows) {
				maxRows = currentDataFound.length;
			}
		});

		return maxRows;
	}

	handleMoreInfo(event) {
		let currentId = event.target.dataset.facilityId;
		window.open(this.facilityPage.data + "?eid=" + currentId, "_blank");
	}

	handleAddItem() {
		let filteredValues = this.facilitiesToCompare.filter(entry => {
			return entry.Id;
		});

		this.updateFacilitiesToCompareLocal(filteredValues, false);

		let q = window.localStorage.getItem("q1");
		let url = this.urlResultPage.data;
		if (q) url += "?q=" + q;
		window.open(url, "_self");
	}

	showHideContentEquipment(event) {
		let keyToSearch = event.currentTarget.dataset.keyToSearch;
		let elements = this.template.querySelectorAll('[data-key="' + keyToSearch + '"]');
		elements.forEach(element => {
			let isFirst = element.getAttribute("data-is-first");
			if (isFirst === "false") {
				if (element.classList.contains("hidden")) {
					element.classList.remove("hidden");
					event.currentTarget.iconName = "utility:dash";
				} else {
					element.classList.add("hidden");
					event.currentTarget.iconName = "utility:add";
				}
			}
		});
	}

	showHideContentRt(event) {
		let keyToSearch = event.currentTarget.dataset.keyToSearch;
		let elements = this.template.querySelectorAll(`[data-key='${keyToSearch}']`);
		elements.forEach(element => {
			if (element.classList.contains("hidden")) {
				element.classList.remove("hidden");
				event.currentTarget.iconName = "utility:chevronup";
			} else {
				element.classList.add("hidden");
				event.currentTarget.iconName = "utility:chevrondown";
			}
		});
	}

	handleRemoveItemFromComparison(event) {
		this.isUpdating = true;
		const id = event.currentTarget.getAttribute("data-item-id");
		this.removeFromComparison(id);
	}

	updateFacilitiesToCompareLocal(value, updateSchema) {
		saveComparisonListToLocalStorage(value);
		this.facilitiesToCompare = this.readFacilititiesToCompareFromLocalStorage();
		if (updateSchema) {
			this.updateSchemaTable();
		}
	}

	updateSchemaTable() {
		this.comparisonSchema = this.handleComparisonSchema(this.rawSchemaData);
	}

	removeFromComparison(idsToRemove) {
		const updatedFacilitiesToCompare = removeFromComparisonCommon(idsToRemove, this.facilitiesToCompare);
		if (updatedFacilitiesToCompare) {
			this.updateFacilitiesToCompareLocal(updatedFacilitiesToCompare, true);
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
}