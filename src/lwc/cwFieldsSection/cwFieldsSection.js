import { LightningElement, api, track, wire } from "lwc";
import {
	reachedLimit
} from 'c/cwUtilities';

export default class CwFieldsSection extends LightningElement {
	@track initialCount;
	initialCountSet = false;
	category;
	@api label;
	@api siteclass;
	@api appliedFiltersCount;
	@api
	get currentCategory() {
		return this.category;
	}

	set currentCategory(value) {
		let valueCopy = JSON.parse(JSON.stringify(value));
		if(valueCopy.fields){

			let handledFieldsAfterUpdate = valueCopy.fields.map(field => {
				field.disable = !field.selected && this.reachedLimit;
				return field;
			});
			valueCopy.fields = JSON.parse(JSON.stringify(handledFieldsAfterUpdate));
		}

		this.category = valueCopy;

		if(!this.initialCountSet){
			this.calculateInitialCount(valueCopy.fields);
			this.initialCountSet = true;
		}
	}

	@api environmentVariables;
	
	calculateInitialCount(){
		this.initialCount = this.getSelectedCount();
	}

	getSelectedCount(){
		return this.currentCategory && this.currentCategory.fields ? this.currentCategory.fields.reduce((acc, field) => field.selected ? ++acc : acc, 0) : 0;
	}

	onClickItem(event) {
		event.stopPropagation();

		this.updateFields(event);
	}

	applyAction() {
		this.dispatchEvent(new CustomEvent("fieldupdate", { detail: { updatedCategory: this.currentCategory } }));
	}

	removeInternalFilters(event) {
		event.preventDefault();
		let fieldsUpdated = [];
		this.currentCategory.fields.forEach(field => {
			let newField = JSON.parse(JSON.stringify(field));
			newField.selected = false;

			if (field.type === "picklist") {
				newField.options.forEach(opt => {
					opt.selected = false;
				});
			}

			fieldsUpdated.push(newField);
		});

		this.updateCurrentCategory(fieldsUpdated);
		this.applyAction();
	}

	updateCurrentCategory(fieldsUpdated) {
		let categoryUpdated = JSON.parse(JSON.stringify(this.currentCategory));
		categoryUpdated.fields = fieldsUpdated;
		this.currentCategory = JSON.parse(JSON.stringify(categoryUpdated));
	}

	updateFields(event) {
		let evItem = event.target;
		this.updateFieldsAndApply(evItem);
	}

	updateFieldsAndApply(evItem) {

		let fieldsUpdated = [];
		this.currentCategory.fields.forEach(field => {
			let newField = JSON.parse(JSON.stringify(field));
			if (field.label === evItem.label || field.name === evItem.getAttribute("data-tosca")) {
				newField.selected = evItem.checked;

				if (field.type === "picklist") {
					newField.options.forEach(opt => {
						const checkSelected = opt.value === evItem.options[evItem.selectedIndex].value ? true : false;
						opt.selected = checkSelected;
						if (checkSelected) {
							newField.selected = checkSelected;
						}
					});
				}
			}
			fieldsUpdated.push(newField);
		});

		this.updateCurrentCategory(fieldsUpdated);
		this.applyAction();
	}

	get isSearchBar() {
		return this.siteclass === "searchbar";
	}

	get isAdvancedSearch() {
		return this.siteclass === "advance";
	}

	get currentCategoryPicklist() {

		let filteredList = [];

		if(this.currentCategory && this.currentCategory.fields){
			filteredList = this.currentCategory.fields.filter(field => field.isPicklist);
		}

		return filteredList;

	}

	get currentCategoryMultiPickList() {
		let filteredList = [];

		if(this.currentCategory && this.currentCategory.fields){
			filteredList = this.currentCategory.fields.filter(field => field.isMultipickList);
		}

		return filteredList;
	}

	get currentCategoryOthers() {
		let filteredList = [];

		if(this.currentCategory && this.currentCategory.fields){
			filteredList = this.currentCategory.fields.filter(field => field.isOther);
		}

		return filteredList;
	}

	get reachedLimit(){
		let counter = this.isSearchBar ? this.appliedFiltersCount + (this.getSelectedCount() - this.initialCount) : this.appliedFiltersCount;
		return reachedLimit(this.environmentVariables, counter);
	}
}