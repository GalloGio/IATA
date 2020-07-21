import { LightningElement, api, track } from 'lwc';

export default class AdvancedHelptext extends LightningElement {
	@api icon = false;
	@api name = "";
	@api content = "";
	@api activator = false;
	@api display = false;
	@api customStyle = {};
	@track _visible = false;
	@track _offsetLeft = null;
	@track _offsetTop = null;
	@track _offsetWidth = null;

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
		return `left: ${this._offsetLeft}; `
				+ `top: ${this._offsetTop}; `
				+ (this._offsetWidth ? `width: ${this._offsetWidth}; max-width: unset;` : '');
	}

	@api show(event) {
		this.content = event.detail.content;
		this._visible = true;
		this._offsetLeft = event.detail.left;
		this._offsetTop = event.detail.top;
		this._offsetWidth = event.detail.width;
	}

	@api hide() {
		this.content = null;
		this._visible = false;
	}

	handleMouseOver(e) {
		if(!this.activator && !this.display){
			this.show();
			return;
		}
		this.dispatchEvent(
			new CustomEvent(
				"tooltipover",
				{
					bubbles: true,
					composed: true,
					detail: {
						name: this.name,
						content: this.content,
						left: this.customStyle.left,
						top: this.customStyle.top,
						width: this.customStyle.width
					}
				}
			)
		);
	}

	handleMouseOut(e) {
		if(!this.activator && !this.display){
			this.hide();
			return;
		}
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