import { LightningElement, track, wire, api } from "lwc";
import ICG_RESOURCES from "@salesforce/resourceUrl/ICG_Resources";
import getStructureFacilities from "@salesforce/apex/CW_AdvancedSearch.getStructureFacilities";
import getMapCategoriesByAccountRoleDetailRecordType from "@salesforce/apex/CW_FacilityCapabilitiesController.getMapCategoriesByAccountRoleDetailRecordType";
import { createKey, removeFromArray } from "c/cwUtilities";
import pubsub from "c/cwPubSub";

const LOCAL_STORAGE_SUPERCATEGORIES = "supercategoriesjson";
export default class CwFacilityEquipmentInfraestructureWrapper extends LightningElement {
	initialized = false;
	eventListenersAdded = false;
	chevrondown = ICG_RESOURCES + "/icons/chevrondown.svg";
	chevronup = ICG_RESOURCES + "/icons/chevronup.svg";

	@api siteclass = "advance";
	@api label;

	@track tooltipObject;
	@track error;
	@track superCategories;
	@track loaded = false;
	_lstFeiCategories;
	@track mapCategoriesByRecordType;
	@track availableSections;

	@api
	get lstFeiCategories() {
		return this._lstFeiCategories;
	}

	set lstFeiCategories(value) {
		this._lstFeiCategories = JSON.parse(JSON.stringify(value));
		if (this.superCategories) {
			this.superCategories.forEach(superCategory => {
				superCategory.key = createKey(superCategory.label);
				superCategory.sections.forEach(section => {
					section.capabilityRT.forEach(crt => {
						crt.isVisible = true;
						crt.categories.forEach(category => {
							category.isVisible = true;
							let categoryNew = this.lstFeiCategories.filter(cat => cat.label === category.label);
							if(categoryNew && categoryNew.length === 1){
								category.selected = categoryNew[0].selected;
								if(categoryNew[0].fields){
									category.fields = JSON.parse(JSON.stringify(categoryNew[0].fields));
								}
							}
							else {
								category.selected = false;
								if(category.fields){
									category.fields.forEach(field => {
										field.selected = false;
										
										if(field.options){
											field.options.forEach(opt => {
												opt.selected = false;
											})
										}

									})
								}
							}
						});
					});
					section.capabilityRT = JSON.parse(JSON.stringify(section.capabilityRT));
				});
			});
		}
	}

	@wire(getStructureFacilities, {})
	wiredStructureFacilities({ error, data }) {
		if (data) {
			this.superCategories = JSON.parse(data);
			this.superCategories.forEach(superCategory => {
				superCategory.isVisible = true;
				superCategory.sections.forEach(section => {
					section.capabilityRT.forEach(crt => {
						crt.isVisible = true;
						crt.categories.forEach(category => {
							category.isVisible = true;
						});
					});
					section.capabilityRT = JSON.parse(JSON.stringify(section.capabilityRT));
				});
			});
			
			this.error = undefined;
			this.loaded = true;
			this.dispatchEvent(new CustomEvent("sectionsloaded", { detail: this.loaded }));
		} else if (error) {
			this.superCategories = undefined;
			this.error = "Unknown error";
			if (Array.isArray(error.body)) {
				this.error = error.body.map(e => e.message).join(", ");
			} else if (typeof error.body.message === "string") {
				this.error = error.body.message;
			}
			this.loaded = true;
		}
	}

	@wire(getMapCategoriesByAccountRoleDetailRecordType, {})
	wiredCategoriesPerRecordType({ error, data }) {
		if (data) {
			this.mapCategoriesByRecordType = JSON.parse(JSON.stringify(data));
		} else if (error) {
			if (Array.isArray(error.body)) {
				this.error = error.body.map(e => e.message).join(", ");
			} else if (typeof error.body.message === "string") {
				this.error = error.body.message;
			}
		}
	}

	connectedCallback() {
		this.selectedCTypeCallback = this.cTypeUpdated.bind(this);
		this.register();
	}

	renderedCallback() {
		if (this.initialized === true) {
			return;
		}
		if (this.superCategories && !this.eventListenersAdded) {
			this._manageCollapsibleSections();
			this.initialized = true;
		}
	}

	@api
	register() {
		pubsub.register("stationTypeUpdated", this.selectedCTypeCallback);
	}

	@track lstRecordTypesChecked = [];
	selectedCTypeCallback;
	cTypeUpdated(payload) {
		payload.forEach(row => {
			if (row.selected) {
				this.lstRecordTypesChecked.push(row.value.toLowerCase());
			} else {
				this.lstRecordTypesChecked = removeFromArray(this.lstRecordTypesChecked, row.value.toLowerCase());
			}
		});
		this._updateAvailableSections(this.lstRecordTypesChecked);
		//this._manageCollapsibleSections();
		this.initialized = false;
		this.eventListenersAdded = false;
	}

	_updateAvailableSections(lstRtypes) {
		this.availableSections = [];

		lstRtypes.forEach(rtype => {
			this.mapCategoriesByRecordType[rtype].forEach(row => {
				if (this.availableSections.indexOf(row) === -1) {
					this.availableSections.push(row);
				}
			});
		});
		this._updateSuperCategoriesVisibility(this.availableSections, lstRtypes);
	}

	_updateSuperCategoriesVisibility(validSections, lstRtypes) {
		let temporalMap = JSON.parse(JSON.stringify(this.superCategories));
		temporalMap.forEach(superCat => {

			if(lstRtypes.length > 0 && validSections.length === 0){
				superCat.isVisible = false;
			}
			else{
				superCat.sections.forEach(section => {
					if (section.capabilityRT) {
						section.capabilityRT.forEach(crt => {
							crt.categories = crt.categories.map(cat => {
								cat.isVisible = validSections.length === 0 ? true : validSections.includes(cat.categoryDevName.toLowerCase());
								return cat;
							});
							crt.isVisible = crt.categories.some(cat => cat.isVisible);
						});
						section.isVisible = section.capabilityRT.some(crt => crt.isVisible);
					}
				});
				superCat.isVisible = lstRtypes.length > 0 && validSections.length === 0 ? false : superCat.sections.some(section => section.isVisible);
			}
		});
		this.superCategories = JSON.parse(JSON.stringify(temporalMap));
	}

	_manageCollapsibleSections() {
		let coll = this.template.querySelectorAll(".collapsible");
		for (let i = 0; i < coll.length; i++) {
			if (coll[i].getAttribute("data-listener") !== "true") {
				coll[i].addEventListener("click", function() {
					this.classList.toggle("active");
					let content = this.nextElementSibling;
					let imgchild = this.querySelector("img");
					if (imgchild.src.includes("/icons/chevronup.svg")) {
						imgchild.src = ICG_RESOURCES + "/icons/chevrondown.svg";
						content.style.maxHeight = null;
						content.style.display = "none";
					} else {
						imgchild.src = ICG_RESOURCES + "/icons/chevronup.svg";
						content.style.maxHeight = "100%";
						content.style.display = "inherit";
					}
				});
				coll[i].setAttribute("data-listener", "true");
			}
		}
	}

	get isSearchBar() {
		let searchbar = false;
		if (this.siteclass === "searchbar") {
			searchbar = true;
		}
		return searchbar;
	}

	get gsiteclass() {
		let styleclass = "col-xl-6 col-lg-6 col-md-12 col-sm-12 col-xs-12";
		if (this.siteclass === "searchbar") {
			styleclass = "col-12 col-no-padding";
		}
		return styleclass;
	}

	get titlesize() {
		let classtitle = "filters-label h6Custom text-truncate";
		if (this.siteclass === "searchbar") {
			classtitle = "filters-label text-truncate color-second-label";
		}
		return classtitle;
	}

	get parentdivwhite() {
		let classdivparent = "col-12 bg-white text-truncate mb-3";
		if (this.siteclass === "searchbar") {
			classdivparent = "col-12";
		}
		return classdivparent;
	}

	get parentclass() {
		let classdparent = "";
		if (this.siteclass === "searchbar") {
			classdparent = "mb-3";
		}
		return classdparent;
	}

	get localpanel() {
		let localpanel = "panel-filter-result localPanel width-100 row";
		if (this.siteclass === "searchbar") {
			localpanel = "";
		}
		return localpanel;
	}

	get labelSize() {
		let labelsize = "filters-label sectionLabel cursor-pt";
		if (this.siteclass === "searchbar") {
			labelsize = "filters-label sectionLabel-search cursor-pt";
		}
		return labelsize;
	}

	get mainCollapseImg() {
		let collapseposition = "expand-collapse-filter";
		if (this.siteclass === "searchbar") {
			collapseposition = "expand-collapse-filter-advance-search";
		}
		return collapseposition;
	}

	get hrmargin() {
		let hrmrgn = "base-underline-100";
		if (this.siteclass === "searchbar") {
			hrmrgn = "base-underline-100 mt-1 mb-0";
		}
		return hrmrgn;
	}

	updateCategory(event){
		let updatedCategory = event.detail;

		if (this.superCategories) {
			this.superCategories.forEach(superCategory => {
				superCategory.key = createKey(superCategory.label);
				superCategory.sections.forEach(section => {
					section.capabilityRT.forEach(crt => {
						crt.categories.forEach(category => {
							if(category.name === updatedCategory.name){
								category.fields = JSON.parse(JSON.stringify(updatedCategory.fields));
							}
						});
					});
				});
			});
		}
		this.dispatchEvent(new CustomEvent('selectcategory', { detail: updatedCategory}));
	}
}