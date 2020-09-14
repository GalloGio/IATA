import { LightningElement, api } from 'lwc';

export default class IataRadioGroup extends LightningElement {

	//variant: base | button | tab
	@api variant = "base";
	@api tabFullWidth = false;
	@api displayHorizontal = false;
	/** Only available when display horizontal */
	@api alignLeft = false;
	@api required = false;
	@api disabled = false;
	@api name;
	@api label;
	@api options;
	@api hideLabel = false;

	@api get value() {
		let f;
		return this.options && (f = this.options.filter(o => {return o.selected;})) !== null 
				&& f.length > 0 ?
					 f[0].value : null;
	}

	set value(v) {
		let localOptions = JSON.parse(JSON.stringify(this.options));
		localOptions.forEach(option => {
			option.selected = option.value === v;
		});

		this.options = localOptions;
	}

	get displayTabBar() {
		return this.variant === "tab";
	}

	get displayButtonGroup() {
		return this.variant === "button";
	}

	get displayBase() {
		return !this.displayTabBar && !this.displayButtonGroup;
	}

	get tabItems() {
		let localOptions = JSON.parse(JSON.stringify(this.options));
		localOptions.forEach((option, i) => {
			option["name"] = option.value;
			option["active"] = option.selected ? true : false;
			option["index"] = i;
			option["style"] = "";
		})

		return localOptions;
	}

	get formElementControlClass() {
		return "slds-form-element__control" +
				(this.displayHorizontal ?
					" slds-grid slds-wrap " +
					(this.alignLeft ?
						"slds-gutters " :
						"slds-grid_align-spread "
					) :
				"");
	}

	get radioButtonContainerClass() {
		return "slds-radio" + 
				(this.displayHorizontal ? " slds-col" : "");
	}

	handleChange(e) {
		console.log('radio-group', e.target.name, e.target.value);
		this.value = e.target.value;
		e.preventDefault();
		this.dispatchEvent(new CustomEvent("change", {target: {name: this.name, value: this.value}}));
	}

}