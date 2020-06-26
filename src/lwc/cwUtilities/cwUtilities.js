// import { LightningElement } from 'lwc';

// export default class CwUtilities extends LightningElement {}

export function removeFromArray(array, value) {
	return array.filter(function (element) {
		return element !== value;
	});
}

export function extractTypeFromLocation(array, value) {
	let type;

	array.forEach((element) => {
		if (element.label.trim() === value.trim()) {
			type = element.type;
		}
	});

	return type;
}

export function checkIfDeselectAll(array) {
	let selected = 0;
	array.forEach((element) => {
		if (element.selected) {
			selected++;
		}
	});
	if (selected == Object.keys(array).length) {
		return true;
	} else {
		return false;
	}
}

export function fillPredictiveValues(value, availableLocations) {
	let predictiveValues = [];
	let searchValuesSplited = value ? value.split(" ") : [];
	const filteredValues = availableLocations.filter((entry) => {
		let code = entry.info.code;
		let containedWords = 0;
		searchValuesSplited.forEach((val) => {
			if (entry.info.searchValues && entry.info.searchValues.toLowerCase().indexOf(translationTextJS(val)) > -1) {
				containedWords++;
			} else if (entry.key && entry.key.toLowerCase().indexOf(translationTextJS(val)) > -1) {
				containedWords++;
			}
		});
		let codeIncludesValue = code && value ? entry.info.code.toLowerCase().includes(value.toLowerCase()) : false;
		return containedWords === searchValuesSplited.length || codeIncludesValue;
	});

	filteredValues.forEach((element) => {
		const keySeparator = element.info.description && element.info.description !== "" ? " - " : "";
		const label = element.info.alias ? element.info.alias : element.info.keyName;
		let icontype = this.checkIconType(element.info.type);
		predictiveValues.push({
			key: element.info.type + keySeparator + element.info.description,
			techkey: createKey(element.info.type + keySeparator + element.info.description + keySeparator + label),
			searchValues: element.info.searchValues,
			value: element.info.value,
			label: label,
			type: element.info.type,
			icon: icontype,
			description: element.info.description,
			code: element.info.code,
			stationsIds: element.info.stationsIds
		});
	});
	return predictiveValues;
}

export function checkIconType(typeString) {
	let iconType = "";
	if (typeString) {
		switch (typeString.toLowerCase()) {
			case "city":
				iconType = "icon-search-by-location-ico";
				break;
			case "country":
				iconType = "icon-search-by-location-ico";
				break;
			case "airport":
				iconType = "icon-search-by-airport-ico";
				break;
			case "certification":
				iconType = "icon-search-by-certification-ico";
				break;
			case "company":
				iconType = "icon-search-by-company-ico";
				break;
			case "station":
				iconType = "icon-search-by-company-ico";
				break;
			case "person":
				iconType = "icon-search-by-person-ico";
				break;
			default:
		}
	}
	return iconType;
}

export function checkMobile() {
	if (window.innerWidth <= 800 && window.innerHeight <= 600) {
		return true;
	}
	return false;
}

export function checkIfChangeSelectAllText(array) {
	let allSelected = true;
	const SELECT_ALL = "Select All";
	const DESELECT_ALL = "Deselect All";

	array.forEach((element) => {
		if (!element.selected) {
			allSelected = false;
		}
	});

	return allSelected ? DESELECT_ALL : SELECT_ALL;
}

export function prepareSearchObjectFEICategories(array, searchList) {
	let searchObject = JSON.parse(JSON.stringify(searchList));//[];
	let lstFields = [];
	let equipmentObject = {
		value: "",
		operator: "=",
		obj: "ICG_Account_Role_Capability_Assignment__c",
		relationfield: "Account_Role_Detail_Capability__c",
		field: "Account_Role_Detail_Capability__r.Equipment__c",
		labels: "",
		isOutOfQuery: true
	};

	array.forEach((equipment) => {
		if (equipment.selected) {
			equipmentObject.value = equipmentObject.value === "" || equipmentObject.value.includes(equipment.name) ? equipment.name : equipmentObject.value + ";" + equipment.name;
			equipmentObject.labels = equipmentObject.labels === "" || equipmentObject.labels.includes(equipment.label) ? equipment.label : equipmentObject.labels + ";" + equipment.label;

			if (equipment.fields) {
				equipment.fields.forEach((field) => {
					const fieldRow = this.getSearchFieldWrapper(field, lstFields);
					if (fieldRow) {
						lstFields.push(fieldRow);
					}
				});
			}
		}
	});
	searchObject.push(equipmentObject);

	if(lstFields.length !== 0 ) {
		lstFields.forEach(row => {
			searchObject.push(row);
		})
	}

	if (equipmentObject.value !== "") {
		return searchObject;
	}

	return undefined;
}

export function getSearchFieldWrapper(field, lstFields) {
	let row = null;

	if (field.selected) {
		row = {
			value: "",
			operator: "=",
			obj: "ICG_Account_Role_Capability_Assignment__c",
			relationfield: "Account_Role_Detail_Capability__c",
			field: "Account_Role_Detail_Capability__r." + field.name,
			labels: field.label,
			isOutOfQuery: true
		};

		//manejar exceptions

		// } else
		if (field.options) {
			row.value = "";
			for (const option of field.options) {
				//ready for picklist and multipicklist
				row.value += option.selected ? option.value + ";" : "";
			}
			row.value = row.value.slice(0, -1);
		} else {
			row.value = "true";
		}
	}
	return row;
}

export function shMenu(sButton) {
	let shareBut = false;
	if (sButton) {
		shareBut = false;
	} else {
		shareBut = true;
	}
	return shareBut;
}

export function sIcons(sButton) {
	let style = "vertical-menu ";
	if (sButton) {
		style = style + "showShMenu";
	} else {
		style = style + "hiddenShMenu";
	}
	return style;
}

export function shButtonUtil(sButton) {
	let style = "";
	if (sButton) {
		style = style + "hiddenShMenu";
	} else {
		style = style + "showShMenu";
	}
	return style;
}

export function prButton(sButton) {
	let style = "p-1-5";
	if (sButton) {
		style = style + " nextToShButton";
	}
	return style;
}

export function shareBtn(sButton) {
	let styleShButton = "shareBtnContainer";
	if (sButton) {
		styleShButton = styleShButton + " margin30sh";
	}
	return styleShButton;
}

export function connectFacebook(url) {
	let urlFac = "https://www.facebook.com/sharer/sharer.php?u=" + url + "&amp;src=sdkpreparse";
	window.open(urlFac, "", "width=650,height=400,x=100,y=100,top=100,left=350");
}

export function connectTwitter(url, txt) {
	let urlTwitter = "https://twitter.com/intent/tweet?text=" + txt + "&url=" + url;
	window.open(urlTwitter, "", "width=650,height=400,x=100,y=100,top=100,left=350");
}

export function connectLinkedin(url) {
	let urlLinkedin = "https://www.linkedin.com/shareArticle?mini=true&url=" + url;
	window.open(urlLinkedin, "", "width=700,height=500,x=100,y=100,top=100,left=300");
}

export function sendMail(mail, subject, url) {
	window.open("mailto:" + mail + "?subject=" + subject + "&body=" + url);
}

export function concatinateAddressString(address) {
	return address ? address + ", " : "";
}

export function concatinateFacilityAddress(facility) {
	const postalCode = this.concatinateAddressString(facility.addressPostalCode);
	const state = this.concatinateAddressString(facility.addressStateProvince);
	const city = this.concatinateAddressString(facility.addressCity);
	const country = facility.location && facility.location.location ? this.concatinateAddressString(facility.location.location.Country) : "";

	let concatinatedAddress;
	const stateFixed = state.trim().toLowerCase();
	if (stateFixed === city.trim().toLowerCase() || stateFixed === country.trim().toLowerCase()) {
		concatinatedAddress = postalCode + city + country;
	} else {
		concatinatedAddress = postalCode + state + city + country;
	}

	return concatinatedAddress;
}

export function removeLastCommaAddress(address) {
	return address.replace(/,\s*$/, "");
}

export function removeFromComparisonCommon(idsToRemove, array) {
	if (!idsToRemove) {
		idsToRemove = [];
	}
	if (!Array.isArray(idsToRemove)) {
		idsToRemove = [idsToRemove];
	}

	if (idsToRemove.length > 0) {
		let updatedFacilitiesToCompare = [];
		array.forEach((curItem) => {
			if (!idsToRemove.includes(curItem.Id)) {
				updatedFacilitiesToCompare.push(curItem);
			}
		});

		if (array.length !== updatedFacilitiesToCompare.length) {
			return updatedFacilitiesToCompare;
		}
	}

	return undefined;
}

export function checkInputValidation(inputs) {
	let validated = true;

	inputs.forEach((input) => {
		const valid = input.validity.valid;
		if (validated) {
			validated = input.validity.valid;
		}

		if (!valid) {
			input.reportValidity();
		}
	});

	return validated;
}

export function hideHover(item, template) {
	const elements = template.querySelector("section[data-item=" + item + "]");
	const classElement = elements.classList.value;

	if (!classElement.includes("_hide")) {
		elements.classList = classElement.replace("slds-popover", "slds-popover_hide");
	}
}

export function createKey(key) {
	key = key.toLowerCase();
	key = key.replace(/ /g, "_");
	key = key.replace(/&/g, "and");
	key = key.replace(/\./g, "_");
	key = key.replace(/'/g, "_");
	key = key.replace(/,/g, "_");
	key = key.replace(/#/g, "_");
	return key;
}

export function generateCertificationImages(array) {
	let certificationImages = [];
	let expirationDate;
	let issueDate;
	let scope;
	let certificationId;
	let id;

	array.forEach((cert) => {
		let accountRoleCertification = cert.accountRoleCertification;
		let expired = false;
		id = "NotIncluded";
		expirationDate = null;
		issueDate = null;
		scope = null;
		certificationId = null;
		if (cert.included != null) {
			id = accountRoleCertification.ICG_Certification__c;
			if (accountRoleCertification.Expiration_Date__c) {
				let dateArray = accountRoleCertification.Expiration_Date__c.split("-");
				expirationDate = `${dateArray[2]}.${dateArray[1]}.${dateArray}`;
			}
			if (accountRoleCertification.Issue_Date__c) {
				let dateArray = accountRoleCertification.Issue_Date__c.split("-");
				issueDate = `${dateArray[2]}.${dateArray[1]}.${dateArray}`;
			}
			certificationId = accountRoleCertification.Certification_Id__c;

			if (cert.name && cert.name.indexOf("CEIV") > -1) {
				scope = accountRoleCertification.CEIV_Scope_List__c;
			} else if (cert.name && cert.name.indexOf("SF Operational") > -1) {
				scope = accountRoleCertification.SFOC_Scope__c;
			}
			expired = accountRoleCertification.isExpired__c;
		}

		let image = cert.image;
		let name = cert.name;
		let order = cert.order;
		let cssClass = cert.included !== "false" && cert.included !== null && accountRoleCertification.isExpired__c !== true ? "cert-account-img width-100 max-w-75" : "disabled-filter cert-account-img width-100 max-w-75";
		let hasCerts = cert.included !== "false" && cert.included !== null ? true : false;
		certificationImages.push({
			Id: id,
			image: image,
			name: name,
			order: order,
			issueDate: issueDate,
			expirationDate: expirationDate,
			certificationId: certificationId,
			cssClass: cssClass,
			scope: scope,
			hasCerts: hasCerts,
			included: cert.included,
			expired: expired
		});
	});

	return certificationImages;
}

export function getImageString(recordTypeDevName) {
	if (recordTypeDevName === "Airline") {
		return "airline.svg";
	} else if (recordTypeDevName === "Airport_Operator" || recordTypeDevName === "Airport Operator" || recordTypeDevName === "Airport") {
		return "airport-operator.svg";
	} else if (recordTypeDevName === "Cargo_Handling_Facility" || recordTypeDevName === "Cargo Handling Facility") {
		return "cargo-handling-facility.svg";
	} else if (recordTypeDevName === "Freight_Forwarder" || recordTypeDevName === "Freight Forwarder") {
		return "freight-forwarder.svg";
	} else if (recordTypeDevName === "Ramp_Handler" || recordTypeDevName === "Ramp Handler") {
		return "ramp-handler.svg";
	} else if (recordTypeDevName === "Shipper") {
		return "shipper.svg";
	} else if (recordTypeDevName === "Trucker") {
		return "trucker.svg";
	}
	return "missing-photo";
}

export function getIataSrc(recordTypeDevName, location, locationClass, resources) {
	let src;
	let freightForwarderValid = recordTypeDevName === "Freight_Forwarder" && locationClass && locationClass.toLowerCase() === "c";
	let locationIsUS = location && location.location && location.location.Country === "United States";

	if (freightForwarderValid && locationIsUS) {
		src = resources + "/img/cns-endorsed-agent.png";
	} else if (freightForwarderValid || recordTypeDevName === "Airline") {
		src = resources + "/img/iata-logo-cut.png";
	}

	return src;
}

export function getIataTooltip(recordTypeDevName, location, locationClass, label) {
	let tooltip = "";

	let freightForwarderValid = recordTypeDevName === "Freight_Forwarder" && locationClass && locationClass.toLowerCase() === "c";
	let locationIsUS = location && location.location && location.location.Country === "United States";

	if (freightForwarderValid && locationIsUS) {
		tooltip = label.icg_cns_endorsed_agent;
	} else if (freightForwarderValid) {
		tooltip = label.icg_accredited_agent;
	} else if (recordTypeDevName === "Airline") {
		tooltip = label.icg_accredited_airline;
	}

	return tooltip;
}
export function prepareSearchParams(searchList) {
	let emptySearch = this.checkIfEmptySearch(searchList);

	let hashedParams = "";

	if (searchList) {
		hashedParams = encodeURI(btoa(encodeURI(JSON.stringify(searchList))))
			.replace("=", "")
			.replace("=", "");
	}

	const urlParams = !emptySearch ? hashedParams : "all";

	return urlParams;
}

export function checkIfEmptySearch(searchList) {
	let emptySearch = true;

	searchList.forEach((searchValue) => {
		if (searchValue.value && searchValue.value !== "WORLDWIDE") {
			emptySearch = false;
		}
	});

	return emptySearch;
}

export function translationTextJS(inputText) {
	if (inputText) {
		inputText = inputText.toLowerCase();
		inputText = inputText.replace(new RegExp("\\s", "g"), "");
		inputText = inputText.replace(new RegExp("[àáâãäå]", "g"), "a");
		inputText = inputText.replace(new RegExp("æ", "g"), "ae");
		inputText = inputText.replace(new RegExp("ç", "g"), "c");
		inputText = inputText.replace(new RegExp("[èéêë]", "g"), "e");
		inputText = inputText.replace(new RegExp("[ìíîï]", "g"), "i");
		inputText = inputText.replace(new RegExp("ñ", "g"), "n");
		inputText = inputText.replace(new RegExp("[òóôõö]", "g"), "o");
		inputText = inputText.replace(new RegExp("œ", "g"), "oe");
		inputText = inputText.replace(new RegExp("[ùúûü]", "g"), "u");
		inputText = inputText.replace(new RegExp("[ýÿ]", "g"), "y");
		inputText = inputText.replace(new RegExp("\\W", "g"), "");

		inputText = inputText.replace(new RegExp("ß", "g"), "ss");
	}
	return inputText;
}

export function translationUmlauteTextJS(inputText) {
	if (inputText) {
		inputText = inputText.toLowerCase();
		inputText = inputText.replace(new RegExp("[äÄ]", "g"), "ae");
		inputText = inputText.replace(new RegExp("[öÖ]", "g"), "oe");
		inputText = inputText.replace(new RegExp("[üÜ]", "g"), "ue");
		inputText = inputText.replace(new RegExp("ß", "g"), "ss");
	}
	return inputText;
}

export function checkKeyUpValue(event) {
	let isValidKeyCode = false;

	if (event.keyCode === 13) {
		isValidKeyCode = true;
	}

	return isValidKeyCode;
}

export function getQueryParameters() {
	var params = {};
	var search = location.search.substring(1);

	if (search) {
		if (search.substring(search.length - 1) === "=") {
			search = search.substring(0, search.length - 1);
		}
		try {
			params = JSON.parse('{"' + search.replace(/&/g, '","').replace(/=/g, '":"') + '"}', (key, value) => {
				return key === "" ? value : decodeURIComponent(value);
			});
		} catch (error) {
			return params;
		}
	}

	return params;
}

export function getCompanyTypeImage(ctype) {
	let imageString = "";
	imageString = getImageString(ctype);
	return "/icons/company_type/" + imageString;
}

export function prepareExcelRow(elem, shouldIncludeCertifications, shouldIncludeRemoteValidations) {
	let facilityName = elem.Name;
	let facilityRecordType = elem.RecordType.Name;
	let facilityCity = elem.City_FOR__c;
	let facilityCountry = elem.IATA_ISO_Country__r.Name;

	let obj = {
		Name: facilityName,
		Type: facilityRecordType,
		City: facilityCity,
		Country: facilityCountry
	};

	if (shouldIncludeCertifications) {
		obj.ienvaStage2 = elem.certifications[0].expDate;
		obj.ceivFresh = elem.certifications[1].expDate;
		obj.unitedOfWildlife = elem.certifications[2].expDate;
		obj.ceivPharma = elem.certifications[3].expDate;
		obj.ienva = elem.certifications[4].expDate;
		obj.ceivLiveAnimals = elem.certifications[5].expDate;
		obj.smartFacility = elem.certifications[6].expDate;
	}
	if (shouldIncludeRemoteValidations) {
		obj.remoteValidation = elem.remoteValidations[0].expDate;
	}

	return obj;
}

export function getPredictiveData(dataType, apexJsFn) {
	return new Promise((resolve, reject) => {
		// Check cached version
		const maxTimeCachedInMinutes = 60 * 24;
		const cachedDataKey = dataType + "_cached";
		const cachedDataAtKey = dataType + "_cachedAt";

		let cachedData = JSON.parse(window.localStorage.getItem(cachedDataKey)) || [];
		let cachedDataAt = JSON.parse(window.localStorage.getItem(cachedDataAtKey)) || 0;
		let secondsCached = Math.floor((Date.now() - cachedDataAt) / 1000);
		let useCachedVersion = cachedData.length > 0 && secondsCached / 60 <= maxTimeCachedInMinutes;

		if (useCachedVersion) {
			resolve(cachedData);
		} else {
			if (dataType === "getLocationsList") {
				apexJsFn
					.then(response => {
						let data = response
							? JSON.parse(response).sort(function(a, b) {
									return b.value - a.value;
							  })
							: [];
						window.localStorage.setItem(cachedDataKey, JSON.stringify(data));
						window.localStorage.setItem(cachedDataAtKey, JSON.stringify(Date.now()));
						resolve(data);
					})
					.catch(errorResponse => {
						reject(errorResponse);
					});
			} else if (dataType === "getCompanyNamesList") {
				apexJsFn
					.then(response => {
						let data = response ? JSON.parse(response) : [];
						window.localStorage.setItem(cachedDataKey, JSON.stringify(data));
						window.localStorage.setItem(cachedDataAtKey, JSON.stringify(Date.now()));
						resolve(data);
					})
					.catch(errorResponse => {
						reject(errorResponse);
					});
			} else if (dataType === "getCertificationsList") {
				apexJsFn
					.then(response => {
						let data = response
							? JSON.parse(response).sort(function(a, b) {
									return b.value - a.value;
							  })
							: [];
						window.localStorage.setItem(cachedDataKey, JSON.stringify(data));
						window.localStorage.setItem(cachedDataAtKey, JSON.stringify(Date.now()));
						resolve(data);
					})
					.catch(errorResponse => {
						reject(errorResponse);
					});
			} else {
				reject("dataType not supported: " + dataType);
			}
		}
	});
}