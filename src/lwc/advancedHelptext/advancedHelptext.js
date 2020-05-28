import { LightningElement, api, track } from 'lwc';

export default class AdvancedHelptext extends LightningElement {
	@api name = "";
	@api content = "";
	@track _visible = false;

	@api show() {
		this._visible = true;
	}

	@api hide() {
		this._visible = false;
	}

	get tooltipClass() {
		return "slds-popover slds-popover_tooltip tooltiptext"
			+ (this._visible ? ' tooltip-visible' : '');
	}

	handleMouseOver(e) {
		console.log('tooltip mouse over', this.name);
		this.dispatchEvent(new CustomEvent("tooltipover", {bubbles: true, composed: true, detail: {name: this.name}}));
	}

	handleMouseOut(e) {
		console.log('tooltip mouse over', this.name);
		this.dispatchEvent(new CustomEvent("tooltipout", {bubbles: true, composed: true, detail: {name: this.name}}));
	}
}