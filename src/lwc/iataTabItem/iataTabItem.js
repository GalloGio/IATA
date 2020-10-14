import { LightningElement, api } from 'lwc';

export default class IataTabItem extends LightningElement {

	@api name;
	@api label;
	@api selected = false;

	baseItemClass = 'slds-tabs_default__item'
	
	get tabIndex() {
		return this.selected ? 0 : -1;
	}

	get itemClass() {
		return this.baseItemClass +
			(this.selected ? ' slds-is-active' : '');
	}

	selectTab(e) {
		this.dispatchEvent(
			new CustomEvent("tabselected", {detail: {name: this.name}})
		);
	}
}