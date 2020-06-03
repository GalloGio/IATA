import { LightningElement, track, api } from 'lwc';

export default class IataPicklist extends LightningElement {

	@api id;
	@api name;
	@api label;
	@api title;
	@api placeholder;
	@api options;
	@api required = false;
	@api disabled = false;
	@api multiSelect = false;

	@api pillFilters = false;
	@api pillFiltersCollapsible = false;
	@api displayVertical = false;
	@api templateRatio = '1:1';
	
	@track _listBoxOpen = false;
	@track _displayErrors = false;

	connectedCallback(){
		
	}

	renderedCallback() {
		if(this._listBoxOpen) {
			this.dispatchEvent(
				new CustomEvent(
					"picklistopen",
					{target:
						{
							value: this.value,
							name: this.name
						}
					}
				)
			);
		}
	}
	handleChange(e) {
		this.value = e.target.value;
		this.dispatchEvent(
			new CustomEvent("change", {"value" : this.value})
		);
	}

	noBlur = false;

	handleClickSelect(e){
		if(this.disabled) {
			let input = this.template.querySelector('input');
			input.blur();
			return;
		}
		if(this.noBlur && e.target.tagName === 'SPAN'){
            this.noBlur = false;
        }
        this._listBoxOpen = !this._listBoxOpen;
        if(this._listBoxOpen){
			let input = this.template.querySelector('input');
			input.focus();
        }
        else {
            let input = this.template.querySelector('input');
			input.blur();
        }
        
	}

	handleClickSelectIcon(e) {
        if(this._listBoxOpen){
            this.noBlur = true;
        }
	}

	handleBlurSelect(e, closeButton=false){
        if(this.noBlur){
            return;
        }
        if(!this.multiSelect || closeButton){
            this._listBoxOpen = false;
        }
	}

    handleClickClose(e) {
		this.handleBlurSelect(e, true);
	}

	@api
	close() {
		this.handleBlurSelect(null, true);
	}

	handleClickOption(e) {
		let optionElement = this.getOptionElement(e.target);
		let currentValue = optionElement.dataset.value;

		let localOptions = JSON.parse(JSON.stringify(this.options));
		localOptions.forEach( o => {
			o['selected'] = !this.multiSelect ?
                                o.value === currentValue :
                                (currentValue === o.value ? 
									this.value.indexOf(currentValue) === -1 : o['selected']);
			
		});
		this.options = localOptions;
				
		this.dispatchEvent(
            new CustomEvent("change", {"value" : this.value})
		);

		if(this._displayErrors){
			this._displayErrors = false;
		}
	}

	handlePillFilterChange(e) {
		this.selectedOptions = e.target.value;
	}

    reducer = (accumulator = [], currentValue) => [...accumulator, ...currentValue];
    
    get selectedOptions(){
		if(this.options === undefined || this.options === null){
			return [];
		}
		return this.options.filter(o => {return o.selected;});
    }

	set selectedOptions(incomeOptions) {
		let incomeValues = incomeOptions.length > 0 ? incomeOptions.map(function(o){return [o.value];}).reduce(this.reducer) : [];
		let optionsClone = JSON.parse(JSON.stringify(this.options));
		optionsClone.forEach(option => {
			option.selected = incomeValues.indexOf(option.value) > -1;
		});
		this.options = optionsClone;
		
		this.dispatchEvent(
            new CustomEvent("change", {"value" : this.value})
		);
	}

	@api
	get value(){
		if(this.selectedOptions.length === 0){
			return !this.multiSelect ? null : [];
		}
        let selectedValues = this.selectedOptions.map(function(e){return e.selected ? [e.value] : [];}).reduce(this.reducer);
		return selectedValues !== undefined && selectedValues !== null ?
				!this.multiSelect ?
					selectedValues[0] :
					selectedValues :
				[];
	}

	set value(v) {
		let localOptions = JSON.parse(JSON.stringify(this.options));
		localOptions.forEach(option => {
			option['selected'] = !this.multiSelect ? 
									option.value === v :
									v && v.indexOf(option.value) > -1;

		});
		this.options = localOptions;
	}

    get valueLabel(){
		if(this.selectedOptions.length === 0){
			return null;
		}
        let selectedLabels = this.selectedOptions.map(function(e){return e.selected ? [e.label] : [];}).reduce(this.reducer);
		return selectedLabels !== undefined && selectedLabels !== null ?
				!this.multiSelect ?
					selectedLabels :
					selectedLabels.join('; ') :
				null;
                
	}
	
	get picklistPlaceholder() {
		return this.placeholder === undefined || this.placeholder === null ?
				this.multiSelect ?
					"Select values" :
					"Select value" :
				this.placeholder;
	}

	getOptionElement(node){
		if(node.tagName.toLowerCase() === 'div'){
			return node;
		}
		return this.getOptionElement(node.parentNode);
	}

	get picklistContainerClass() {
        return "slds-grid"
            + (this.displayVertical ?
                " slds-wrap" :
                "");
    }

	get listBoxContainerClass() {
		return "slds-listbox slds-listbox_vertical slds-dropdown slds-dropdown_fluid slds-dropdown_left " +
				(this._listBoxOpen ?
					"slds-show" :
					"slds-hide");
		
	}

	get listBoxClass() {
		return "slds-dropdown_length-with-icon-10";
	}

	get isOpen() {
		return this._listBoxOpen;
	}

	get listBoxArrow() {
		return this._listBoxOpen ? "up" : "down";
	}

	get picklistIconClass() {
		return "slds-is-absolute picklist-icon picklist-icon_arrow-"
				+ this.listBoxArrow;
	}

	get formElementClass() {
		return "slds-col"
                + this.formElementSizeClass
                + " slds-form-element"
                + (this._displayErrors ?
                    " slds-has-error" :
                    "");
	}

    get pillFiltersContainerClass() {
        return "slds-col"
                + this.pillFiltersContainerSizeClass
                + " slds-is-relative";
    }

    get pillFiltersContainerStyle() {
		return this.displayVertical ?
				this.pillFiltersCollapsible ?
					 "height:4rem;" :
					 "" :
				 "";
	}

	get formElementSizeClass() {
		return this.pillFilters && !this.displayVertical ? 
				" slds-size_" + this.picklistColSize + "-of-" + this.totalSize : 
				" slds-size_1-of-1";
	}

	get pillFiltersContainerSizeClass() {
		return this.pillFilters && !this.displayVertical ? 
				" slds-size_" + this.filtersColSize + "-of-" + this.totalSize : 
				" slds-size_1-of-1";
	}
	
	get picklistColSize() {
		return parseInt(this.templateRatio.split(':')[0]);
	}

	get filtersColSize() {
		return parseInt(this.templateRatio.split(':')[1]);
	}

	get totalSize() {
		return this.picklistColSize + this.filtersColSize;
	}

	@api
	checkValidity() {
		return !this.required || 
				(this.required && this.value !== null && this.value.length > 0);
	}

	@api
	reportValidity() {
		let validity = this.checkValidity();
		if(validity) {
			this._displayErrors = false;
		}
		else {
			this._displayErrors = true;
		}
		return validity;
	}

	get displayErrors() {
		return this._displayErrors;
	}
}