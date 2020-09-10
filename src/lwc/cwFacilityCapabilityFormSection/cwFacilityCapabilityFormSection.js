import { LightningElement, api, track, wire } from 'lwc';
import resources from "@salesforce/resourceUrl/ICG_Resources";
import {
	reachedLimit
} from 'c/cwUtilities';

export default class cwFacilityCapabilityFormSection extends LightningElement {
	icons = resources + "/icons/";
	//icons
	tickSelection = this.icons + "ic-gsearch--selected.svg";
	chevrondown = this.icons + "chevrondown.svg";
	chevronup = this.icons + "chevronup.svg";
	@api label;
	@api siteclass;
	initialized = false;
	@track showModalFields = false;
	@track categoryUpdated;
	@api appliedFiltersCount;

	@track capabilityField;

	@api
	get capability() {
		return this.capabilityField;
	}
	set capability(value) {
		this.capabilityField = JSON.parse(JSON.stringify(value));
		this.initialized = false;
		this.updateElementClasses();
	}

	@api environmentVariables;

	renderedCallback() {
		if (this.initialized === true) {
			return;
		}
		this.initialized = true;
		this.updateElementClasses();
	}

	get mainCollapseImg() {
		let collapseposition = "expand-collapse-filter";
		if (this.siteclass === "searchbar") {
			collapseposition = "expand-collapse-filter-advance-search";
		}
		return collapseposition;
	}

	updateElementClasses() {
		this.capability.categories.forEach(category => {
			if(!this.initialized) {
				this._parseFieldTypes(category);
			}
			let items = this.template.querySelectorAll("[data-name='" + category.name + "']");

			items.forEach(item => {
				if(category.selected) {
					item.classList.add('itemSelected');
					item.classList.remove('itemUnselected');
				} else {
					item.classList.add('itemUnselected');
					item.classList.remove('itemSelected');
				}
				item.selected = category.selected;
			})
		})
	}

	_parseFieldTypes(category) {
		if(category.fields && category.fields.length > 0) {
			category.hasFields = true;
			category.showModalFields = false;

			category.fields.forEach(field => {
				switch (field.type.toLowerCase()) {
					case 'picklist':
						field.isPicklist = true;
						break;
					case 'multipicklist':
						field.isMultipickList = true;
						break;
					case 'checkbox':
					case 'boolean':
						field.type = 'checkbox';
						field.isOther = true;
						break;
					default:
						field.isOther = true;
						break;
				}
			});
		}
	}

	onClickEquipment(event) {
		event.stopPropagation();
		let evEquipment = event.currentTarget;
		
		if (!this.reachedLimit){
			this.clickEquipment(evEquipment);
		}
		else if (this.reachedLimit && evEquipment.selected){
			this.clickEquipment(evEquipment);
		}
	}

	clickEquipment(evEquipment){
		evEquipment.classList.toggle('itemUnselected');
		evEquipment.classList.toggle('itemSelected');
		evEquipment.selected = !evEquipment.selected;
		if(!evEquipment.selected) {
			evEquipment.moreDetails = false;
		}
		this.launchEventEquipmentSelected(evEquipment);
	}

	onUpdateFields(event) {
		const categoryUpdated = event.detail.updatedCategory;

		let temporalCapability = JSON.parse(JSON.stringify(this.capability));
		temporalCapability.categories.forEach((category, index) => {
			if(category.name === categoryUpdated.name) {
				temporalCapability.categories[index] = JSON.parse(JSON.stringify(categoryUpdated));
			}
		})
		this.capability = JSON.parse(JSON.stringify(temporalCapability));

		if(this.siteclass === 'advance'){
			this.dispatchEvent(new CustomEvent('updatecategory', { detail: categoryUpdated}));
		}
		else{
			this.categoryUpdated = categoryUpdated;
		}
	}

	launchEventEquipmentSelected(evEquipment) {
		this.initialized = false;
		let selectedItem;
		Object.keys(this.capability).forEach(element => {
			Object.keys(this.capability[element]).forEach(category => {
				if (this.capability[element][category].name === evEquipment.getAttribute("data-tosca")) {
					this.capability[element][category].selected = evEquipment.selected;

					if(!evEquipment.selected){
						this.capability[element][category].fields.forEach(field => {
							field.selected = false;
						})
					}

					this.capability[element][category].moreDetails = evEquipment.moreDetails;
					selectedItem = this.capability[element][category];
				}
			})
		})
		this.dispatchEvent(new CustomEvent('updatecategory', { detail: selectedItem}));
	}

	onMoreDetails(event) {
		event.stopPropagation();
		let evEquipment = event.currentTarget;
		evEquipment.moreDetails = !evEquipment.moreDetails;
		this.initialized = false;
		this.updateMoreDetails(evEquipment.getAttribute("data-tosca"));
		this.showModalFields = true;
	}

	updateMoreDetails(name){
		let capabilityCopy = JSON.parse(JSON.stringify(this.capability));
		capabilityCopy.categories.forEach(category => {
			category.moreDetails = category.name === name;
		})
		this.capability = JSON.parse(JSON.stringify(capabilityCopy));

	}

	get gesiteclass() {
		let styleclass = "border-light-blue p-2 company-type-content col-md-6";
		if (this.siteclass === 'searchbar') {
			styleclass = "company-type-content col-12";
		}
		return styleclass;
	}

	get marginLabel() {
		let mrglbl="cursor-pt text-blue lbl-check";
		if(this.siteclass === 'searchbar') {
			mrglbl = "cursor-pt text-blue lbl-check mb-0";
		}
		return mrglbl;
	}

	closeModalFields() {
		this.showModalFields = false;

		if(this.categoryUpdated){
			this.dispatchEvent(new CustomEvent('updatecategory', { detail: this.categoryUpdated}));
		}
		
	}

	get reachedLimit(){
		return reachedLimit(this.environmentVariables, this.appliedFiltersCount);
	}
}