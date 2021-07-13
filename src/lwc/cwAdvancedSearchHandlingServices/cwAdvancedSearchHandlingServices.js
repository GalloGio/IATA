import { LightningElement, track, api, wire } from 'lwc';
import resources from "@salesforce/resourceUrl/ICG_Resources";
import {
	checkIfDeselectAll,
	checkIfChangeSelectAllText,
	reachedLimit,
	reachedLimitWithAll
} from 'c/cwUtilities';
import getPicklistValues from '@salesforce/apex/CW_Utilities.getPicklistValues';

export default class CwAdvancedSearchHandlingServices extends LightningElement {
	@api label;
	@track selectedText = 'Select All';
	@api appliedFiltersCount;
	@track services = [];
	initialized=false;
	loaded=false;
	
	renderedCallback(){
		if(!this.initialized){
			this.initialized = true;
			this.loadServices();		
		}
	}

	loadServices(){
        let objectApi = "ICG_Account_Role_Detail__c";
		let fieldApi = "In_House_Services__c";
		getPicklistValues({objectApi,fieldApi}).then(response =>{
			if(response){
				let dataParsed = JSON.parse(response);
				let services = [];
				dataParsed.forEach(item => {
					let service = {
						name: item.api,
						label: item.label,
						selected: false,
						enabled: true,
						field: "Third_Party_Services__c;In_House_Services__c",
						obj: objectApi,
						type: "service"
					};
					this.services.push(service);
				});
			}
		})
		.catch(error => {
			this.initialized = false;
		});
	}

	searchAllServices() {
		let shouldDeselectAll = checkIfDeselectAll(this.services);
		let allPrograms = [];

		this.services.forEach(element => {
			element.selected = !shouldDeselectAll;
			allPrograms.push(element);
		});

		let items = this.template.querySelectorAll("[data-type='services']");
		if(shouldDeselectAll){
			this._unselectItems(items);
		}
		else {
			this._selectItems(items);
		}
		this.selectedText = checkIfChangeSelectAllText(this.services);


		this.dispatchEvent(new CustomEvent('selectservices', { detail: allPrograms }));
	}

	@api environmentVariables;

	_selectItems(items) {
		items.forEach(element => {
			element.classList.remove('itemUnselected');
			element.classList.add('itemSelected');
		});
	}

	_unselectItems(items){
		items.forEach(element => {
			element.classList.remove('itemSelected');
			element.classList.add('itemUnselected');
		});
	}

	onClickItem(event) {
		let eTarget = event.currentTarget;
		let name = eTarget.getAttribute("data-name");

		let selectedComodity;
		let selected;

		this.services.forEach(element => {
			if (element.name === name && (!this.reachedLimit || (this.reachedLimit && element.selected))) {
				element.selected = !element.selected;
				selectedComodity = [element];
				selected = element.selected;
			}
		});

		let items = this.template.querySelectorAll("[data-name='" + name + "']");

		if(selected){
			if (!this.reachedLimit){
				this._selectItems(items);
				
				this.selectedText = checkIfChangeSelectAllText(this.services);
				this.dispatchEvent(new CustomEvent('selectservices', { detail: selectedComodity }));
			}
		}
		else{
			this._unselectItems(items);
			
			this.selectedText = checkIfChangeSelectAllText(this.services);
			this.dispatchEvent(new CustomEvent('selectservices', { detail: selectedComodity }));
		}
	}

	_getServices(searchList) {
		Object.keys(this.services).forEach(element => {
			if (this.services[element].selected) {
				const searchObject = {
					value: this.services[element].selected,
					operator: "=",
					obj: this.services[element].obj,
					relationfield: this.services[element].relationfield,
					field: this.services[element].field
				};
				searchList.push(searchObject);
			}
		});
		return searchList;
	}

	get reachedLimit(){
		return reachedLimit(this.environmentVariables, this.appliedFiltersCount);
	}

	get reachedLimitWithAll(){
		return reachedLimitWithAll(this.environmentVariables, this.services, this.appliedFiltersCount);
	}
	
	get selectAllVisible(){
		if (this.services){
			return !(this.selectedText === "Select All" && this.reachedLimitWithAll);
		}
	}
}