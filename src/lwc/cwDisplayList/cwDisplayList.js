import { LightningElement, api, track } from "lwc";
import resources from "@salesforce/resourceUrl/ICG_Resources";
import setFacilityCargoComodity_ from "@salesforce/apex/CW_FacilityContactInfoController.setFacilityInfo";
import { hideHover, generateCertificationImages } from "c/cwUtilities";

export default class CwDisplayList extends LightningElement {
	SUFFIX_VALIDATED = "ValidatedByIata";

	icons = {
		greenCheck: resources + "/icons/ic-tic-green.svg",
		blueCheck: resources + "/icons/ic-tic-blue.svg",
		blackCheck: resources + "/icons/ic-tic-black.svg",
		cargoCompanyType: resources + "/icons/company_type/cargo_com_airline.jpg"
	};

	@track
	cargoComodities = [
		{ key: "generalCargo", name: "General Cargo", matchesCerts: [] },
		{ key: "liveAnimals", name: "Live Animals", matchesCerts: ["CEIV Live Animals"] },
		{ key: "dangerousGoods", name: "Dangerous Goods", matchesCerts: [] },
		{ key: "airmail", name: "Airmail", matchesCerts: [] },
		{ key: "perishables", name: "Perishables", matchesCerts: ["CEIV Fresh"] },
		{ key: "pharmaceuticals", name: "Pharmaceuticals", matchesCerts: ["CEIV Pharma"] }
	];

	renderCallbackExecuted = false;
	@track isLoading = false;
	@track editModeActive = false;
	@api saveOnTheFly = false;
	@track editOn = false;

	@api listDetailCertFacility;
	@api label;
	@api title;
	@api titleType = "search-result";
	@track _facility;
	@api
	get facility() {
		return this._facility;
	}
	set facility(value) {
		this._facility = JSON.parse(JSON.stringify(value));
		this.updateValidatedCheck();
	}
	@api editMode = false;

	get isTitleFacilityPageType() {
		return this.titleType === "facility-page";
	}

	get titleCss() {
		return this.isTitleFacilityPageType ? "title-facility-page" : "title-search-result";
	}

	isFacilityComparisonPageType() {
		return this.titleType === "facility-compare-page";
	}

	get itemCssClass() {
		if (this.isFacilityComparisonPageType) {
			return "col-6 col-no-padding-right mt-1 mb-1 pl-3";
		}
		return "col-sm-6 col-md-4 col-no-padding-right mt-1 mb-1";
	}

	get itemLayoutCssClass() {
		if (this.editModeActive) {
			return "cursor-pt";
		}
		return "";
	}

	renderedCallback() {
		if (this.renderCallbackExecuted || !this.listDetailCertFacility) {
			return;
		}
		this.renderCallbackExecuted = true;
		this.updateValidatedCheck();
	}

	checkIfCommodityValidated(item, processedCertsList) {
		let verifications = [];
		this.facility.listAccCert.forEach(accCert => {
			let name = accCert.ICG_Certification__c ? accCert.ICG_Certification__r.Name : "Unable to extract name";
			let validatedByCert = this.checkIfValidatedByCert(item, processedCertsList, name);
			if ((accCert.SFOC_Scope__c && accCert.SFOC_Scope__c.includes(item.name)) || validatedByCert) {
				verifications.push(name);
			}
		});

		return verifications;
	}

	checkIfValidatedByCert(item, processedCertsList, name) {
		let validatedByCert = false;
		processedCertsList.forEach(cert => {
			if (cert.name === name && item.matchesCerts.includes(name) && cert.included) {
				validatedByCert = true;
			}
		});

		return validatedByCert;
	}

	setActiveCargo(event) {
		event.preventDefault();
		if (!this.editModeActive) {
			return;
		}
		let key = event.currentTarget.dataset.id;
		this.facility = JSON.parse(JSON.stringify(this.facility));
		this.setFacilityCargoComodity(this.facility.Id, key, !this.facility[key]);

	}

	setFacilityCargoComodity(id, key, value) {
		this.isLoading = true;
		if(this.saveOnTheFly){
			setFacilityCargoComodity_({ id, key, value })
				.then(response => {
					if (response.result.status === "OK") {
						this.facility = JSON.parse(JSON.stringify(this.facility));
						let newValue = response.result.value;

						if (newValue === "undefined") {
							newValue = null;
						}

						this.facility[response.result.key] = newValue === "true";
						this.refreshCargoCommoditiesExtraProperties();
					}
					this.isLoading = false;
				})
				.catch(() => {
					this.isLoading = false;
				});
		}else {

			this.facility[key] = value;
			this.isLoading = false;
			this.updateFacilityOnParent();
		}
	}

	updateFacilityOnParent() {
		let customEvent = new CustomEvent("updatefacility", {
			detail: this.facility
		});
		this.dispatchEvent(customEvent);
	}

	resetItem(item) {
		delete item.checked;
		delete item.dataKey;
		delete item.title;
		delete item.cssClass;
		delete item.validated;
		delete item.validatedCommodities;
		delete item.itemSrc;
		delete item.itemSpanClass;
		return item;
	}

	refreshCargoCommoditiesExtraProperties() {
		let processedCertsList = this.getProcessedCertsList();

		this.cargoComodities.forEach(item => {
			// Reset required properties
			item = this.resetItem(item);

			item.checked = this.facility[item.key];
			item.validated = this.facility[item.key + this.SUFFIX_VALIDATED] && item.checked;
			item.dataKey = item.key;

			if (item.validated) {
				item.validatedCommodities = this.checkIfCommodityValidated(item, processedCertsList);
				item.cssClass = "commodity-active text-green";
				item.iconSrc = this.icons.greenCheck;
			} else if (item.checked) {
				item.cssClass = "commodity-active text-black";
				item.iconSrc = this.icons.blackCheck;
			} else {
				item.cssClass = "disabled-filter commodity-inactive";
				item.iconSrc = this.icons.greenCheck;
			}

			item.itemSpanClass = "pl-1 text-truncate";
			if (this.editModeActive && !item.validated) {
				delete item.iconSrc;
				item.iconSrc = this.icons.blueCheck;
				item.itemSpanClass += " text-blue";
			}
		});
	}

	showPopover(event) {
		if (this.editModeActive) {
			return;
		}

		let commodity = event.target.dataset.item;
		const elements = this.template.querySelector("section[data-item=" + commodity + "]");
		let containerDiv = this.template.querySelector('[data-tosca="' + commodity + '"]');
		let bounds = containerDiv.getBoundingClientRect();
		elements.style.marginLeft = "calc(" + bounds.width / 40 + "px)";
		elements.style.marginTop = bounds.height * 1.5 + "px";
		const classElement = elements.classList.value;
		const containerDivClasses = containerDiv.classList.value;

		if (!containerDivClasses.includes("disabled")) {
			if (classElement.includes("_hide")) {
				elements.classList = classElement.replace("slds-popover_hide", "slds-popover");
			}
		}
	}

	hidePopover(event) {
		let item = event.target.dataset.item;
		hideHover(item, this.template);
	}

	getProcessedCertsList() {
		let processedCertsList = [];
		if (this.listDetailCertFacility) {
			processedCertsList = generateCertificationImages(JSON.parse(JSON.stringify(this.listDetailCertFacility)));
		}
		return processedCertsList;
	}

	updateValidatedCheck() {
		let processedCertsList = this.getProcessedCertsList();

		this.cargoComodities.forEach(item => {
			this.facility[item.key + this.SUFFIX_VALIDATED] = false;
			if (this.facility.listAccCert) {
				const commodityValidatedBy = this.checkIfCommodityValidated(item, processedCertsList);
				if (commodityValidatedBy.length > 0) {
					this.facility[item.key + this.SUFFIX_VALIDATED] = true;
				}
			}
		});

		this.refreshCargoCommoditiesExtraProperties();
	}


	showInput(event){
		this.editOn = !this.editOn;
		if(this.editOn){
			this.editModeActive = true;
		}else{
			this.editModeActive = false;
		}
	}

	@api editOff(){		
		this.editOn = false;
		this.editModeActive = false;
	}

}