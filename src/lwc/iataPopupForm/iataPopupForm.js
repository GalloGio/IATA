import { LightningElement, api, track } from 'lwc';

export default class IataMultiselectPopup extends LightningElement {

    @api header = "Select values";
	@api label;
	@api name;
	
	@api buttonLabel = "Select Values";
	@api buttonWidth = "large";
	@api buttonAlignment = "center";
	@api buttonSmallText = false;
	@api buttonIcon;
	@api buttonIconSize = "x-small";
	@api buttonIconRight = false;
	@api buttonVariant;

	@api fields = [];
	@api formVariant = "cols";
	@api disabled = false;

	@track _tempValue = {};
	@track _value = {};
	@track _displayErrors = false;

	@api get value() {
		return this._value;
	}

	renderedCallback() {
	}

	set value(v) {
		this._tempValue = v;
		this._value = v;
		for(let key in v) {
			if(key && key !== ""){
				this.template.querySelector('c-iata-dependent-picklist').setValue(key, v[key]);
			}
		}
	}

	get buttonAreaSize() {
		return this.displayPills ? 5 : 12;
	}

    get readOnly() {
        return !this.disabled;
    }

    get componentLabel() {
        return this.label !== undefined && this.label !== null && this.label !== "" ?
            this.label : this.header;
	}
	
	handleChange(event) {
		this._tempValue[event.detail.name] = event.detail.value;
	}

	handlepicklistopen(event){
		let updatingField = this.template.querySelector("c-iata-dependent-picklist").fieldList[0].fields.filter(f => {return f.name === event.detail.name;});
		if(updatingField !== undefined && updatingField[0] !== undefined && updatingField[0].scrollTopOnOpen){
			this.template.querySelector("c-iata-modal").scrollTo(event.detail.top);
		}
	}

	open() {
		if(!this.disabled){
			this.template.querySelector("c-iata-modal").openModal();
		}
	}
	
	apply(event) {
		this.template.querySelector('c-iata-dependent-picklist').closeAllOpenPicklists();
		this._value = this._tempValue;
		this.dispatchEvent(new CustomEvent("change", {target: {name: this.name, value: this.value}}));
        this.template.querySelector("c-iata-modal").closeModal();
	}

	clear(event) {
		this.template.querySelector('c-iata-dependent-picklist').closeAllOpenPicklists();
		let valueClone = JSON.parse(JSON.stringify(this._value));
		for(let field in valueClone) {
			if(Array.isArray(valueClone[field])){
				valueClone[field] = [];
			}
			else {
				valueClone[field] = null;
			}
		}
		this.value = valueClone;
	}

	get displayErrors() {
		return this._displayErrors;
	}

	get formElementClass() {
		return "slds-form-element slds-grid" + (this._displayErrors ? " slds-has-error" : "");
	}
	

	/*@api displayPills = false;

	@api multiSelectLabel = "";
    @api multiSelectSourceLabel = "Available";
    @api multiSelectSelectedLabel = "Selected";
    @api multiSelectHelp = "Select markets";
    @api multiSelectOptions = [];
    
	@api required = false;
	@track valueLabel;
	@track selectedOptions = [];

    fillValueLabel() {
        if(this.value === null || this.value.length === 0){
            return "No value selected";
        }

        let selected = [];
        this.multiSelectOptions.forEach(option => {
            if(this.value.indexOf(option.value) > -1){
				selected.push({"label": option.label, "value": option.value});
				
            }
        });

		this.selectedOptions = selected;

		if(this._displayErrors){
			this._displayErrors = false;
		}
	}
	
	removePill(e) {
		let currentValue = e.target.dataset.value;
		let selected = JSON.parse(JSON.stringify(this.selectedOptions));
		let newSelected = [];
		let newValue = [];
		selected.forEach(option => {
			if(option.value !== currentValue){
				newSelected.push(option);
				newValue.push(option.value);
			}
		});

		this.value = newValue;
		this.selectedOptions = newSelected;

	}

    @api
	checkValidity() {
		console.log('required', this.required, 'value', this.value);
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
		console.log('validity', validity, 'display', this._displayErrors);
		return validity;
	}*/

}