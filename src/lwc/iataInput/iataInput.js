import { LightningElement, track, api } from 'lwc';

export default class IataInput extends LightningElement {
	@api id;
	@api name;
	@api label;
	@api title;
	@api type;
	@api placeholder;
	@api value;
	@api step;
	@api hideLabel = false;
	@api required = false;
	@api disabled = false;
	@api readonly = false;
	@api icon = null;
	@api iconStyling = '';
	@api noSvg = false;
	@api clearButton = false;

	@track _displayErrors = false;

	get formElementClass() {
		return "slds-form-element"
                + (this._displayErrors ?
                    " slds-has-error" :
                    "");
	}
	
	handleChange(e) {
		this.notifyChanges("change", e);
	}

	handleKeyDown(e) {
		this.notifyChanges("keydown", e);
	}

	handleKeyUp(e) {
		this.notifyChanges("keyup", e);
	}

	handleKeyPress(e) {
		this.notifyChanges("keypress", e);
	}

	notifyChanges(eventName, sourceEvent) {
		this.value = sourceEvent.target.value;
		
		this.dispatchEvent(
			new CustomEvent(eventName, {"value" : this.value})
		);
	}

	clear() {
		this.value = null;
		this.notifyChanges("change", {target: {value: null}});
		this.notifyChanges("empty", {target: {value: null}});
	} 

	@api
	checkValidity() {
		return !this.required || 
				(this.required && this.value !== null && this.value.length > 0) ||
				this.template.querySelector('input').checkValidity();;
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

	get formElementControlClass() {
		return "slds-form-element__control" +
			(this.hasIcon ?
				" slds-input-has-icon" +
					(this.clearButton ?
						" slds-input-has-icon_left-right" :
						" slds-input-has-icon_left"
					) :
				(this.clearButton ?
					" slds-input-has-icon_right" :
					""
				)
			);
	}

	get hasIcon() {
		return this.icon !== undefined && this.icon !== null && this.icon !== '';
	}

}