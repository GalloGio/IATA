import { LightningElement, api, track } from "lwc";

export default class CwFieldsSection extends LightningElement {
	initialized = false;
	@track _currentCategory;
	@track _currentCategoryPicklist = [];
	@track _currentCategoryMultiPickList;
	@track _currentCategoryOthers;
	@api label;
	@api
	get currentCategory() {
		return this._currentCategory;
	}

	initCurrentCategoryByType(){
		let _currentCategoryPicklistTemp = [];
		let _currentCategoryMultiPickListTemp = [];
		let _currentCategoryOthersTemp = [];
		this._currentCategory.fields.forEach((field) => {
			if(field.isPicklist){
				_currentCategoryPicklistTemp.push(field);
			}
			if(field.isMultipickList){
				_currentCategoryMultiPickListTemp.push(field);
			}
			if(field.isOther){
				_currentCategoryOthersTemp.push(field);
			}
		 });

		 this._currentCategoryPicklist = _currentCategoryPicklistTemp;
		 this._currentCategoryMultiPickList = _currentCategoryMultiPickListTemp;
		 this._currentCategoryOthers = _currentCategoryOthersTemp;
	}

	set currentCategory(value) {
		this._currentCategory = value;
	}

	renderedCallback() {
		if (this.initialized === true) {
			return;
		}
		JSON.stringify("fields: " + JSON.stringify(this.fields));
		this.initCurrentCategoryByType();
		this.initialized = true;
	}

	get preselected(){

		let value = this.label.select;

		let preselectedValue = this._currentCategoryPicklist.some(obj => obj.selected);

		if(preselectedValue){
			this._currentCategoryPicklist.forEach(obj => {
				if(obj.options){
					obj.options.forEach(opt => {
						if(opt.selected){
							value = opt.value;
						}
					})
				}
			})
		}


		return value;
	}

	get preselectedLabel(){
		let value = this.label.select;

		let preselectedValue = this._currentCategoryPicklist.some(obj => obj.selected);

		if(preselectedValue){
			this._currentCategoryPicklist.forEach(obj => {
				if(obj.options){
					obj.options.forEach(opt => {
						if(opt.selected){
							value = opt.label;
						}
					})
				}
			})
		}


		return value;
	}

	onClickItem(event) {
		event.stopPropagation();

		this._updateFields(event);
	}

	applyAction(event) {
		this.dispatchEvent(new CustomEvent("fieldupdate", { detail: { updatedCategory: this.currentCategory } }));
		this.closeModal(event);
	}

	closeModal(event) {
		event.preventDefault();
        this.dispatchEvent( new CustomEvent('closemodal', { detail: { updatedCategory: this.currentCategory } }));
	}

	_updateFields(event) {
		let evItem = event.target;
		let fieldsUpdated = [];
        this._currentCategory.fields.forEach(field => {
            let newField = JSON.parse(JSON.stringify(field));
			if(field.label === evItem.label
					|| field.name === evItem.getAttribute("data-tosca")) {
				newField.selected = evItem.checked;
				
				if(field.type === "picklist") {
					newField.options.forEach(opt => {
						const checkSelected = opt.value === evItem.options[evItem.selectedIndex].value ? true : false
						opt.selected = checkSelected;
						if(checkSelected) {
							newField.selected = checkSelected;
						}
					});
 
				}
			}
            fieldsUpdated.push(newField);
        });
        let categoryUpdated = JSON.parse(JSON.stringify(this._currentCategory));
        categoryUpdated.fields = fieldsUpdated;
		this._currentCategory = JSON.parse(JSON.stringify(categoryUpdated));
	}
}