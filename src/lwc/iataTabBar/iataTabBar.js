import { LightningElement, api } from 'lwc';

export default class IataTabBar extends LightningElement {

	@api fullWidth = false;
	@api tabs;
	@api name = "this-tab-bar";
	@api get value() {
		let active = this.tabs.filter(t => {return t.active});

		return active !== undefined && active !== null && active.length > 0 ?
				active[0].name : null;
	}

	connectedCallback(){

	}

	handleSelectedTab(e) {
		let localTabs = JSON.parse(JSON.stringify(this.tabs));
		localTabs.forEach(element => {
			element.active = element.name === e.detail.name;
		});
		this.tabs = localTabs;
		e.preventDefault();
		this.dispatchEvent(new CustomEvent("change", {target: {name: this.name, value: this.value}}));
	}
}