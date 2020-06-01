import { LightningElement, api, track } from 'lwc';

export default class AdvancedHelptext extends LightningElement {
	@api icon = false;
	@api name = "";
	@api content = "";
	@api activator = false;
	@api display = false;
	@track _visible = false;
	@track _offsetLeft = null;
	@track _offsetTop = null;

	get displayLabel() {
		return !this.display && !this.icon;
	}

	get displayIcon() {
		return !this.display && this.icon;
	}

	get tooltipContainerClass() {
		return "tooltip"
			+ (this.icon ? " tooltip-with-icon" : "");
	}

	get tooltipClass() {
		return "slds-popover slds-popover_tooltip tooltiptext"
			+ (this._visible ? ' tooltip-visible' : '');
	}

	get tooltipStyle() {
		return this.display ? this._tooltipStyle : "";
	}

	get _tooltipStyle() {
		return `left: ${this._offsetLeft}px; `
				+`top: ${this._offsetTop}px;`;
	}

	@api show(event) {
		this.content = event.detail.content;
		this._visible = true;
		this._offsetLeft = event.detail.left;
		this._offsetTop = event.detail.top;
	}

	@api hide() {
		this.content = null;
		this._visible = false;
	}

	handleMouseOver(e) {
		if(!this.activator)
			return;
		this.dispatchEvent(
			new CustomEvent(
				"tooltipover",
				{
					bubbles: true,
					composed: true,
					detail: {
						name: this.name,
						content: this.content,
						left: this.offsetLeft,
						top: this.offsetTop
					}
				}
			)
		);
	}

	handleMouseOut(e) {
		if(!this.activator)
			return;
		this.dispatchEvent(
			new CustomEvent(
				"tooltipout",
				{
					bubbles: true,
					composed: true,
					detail: {
						name: this.name
					}
				}
			)
		);
	}
}