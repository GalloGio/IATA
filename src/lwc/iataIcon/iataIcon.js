import { LightningElement, api } from 'lwc';

export default class IataIcon extends LightningElement {

	@api title = '';
	@api icon = null;
	@api iconStyling = '';
	@api noSvg = false;
	@api iconClass = 'slds-icon';
	@api size = 'small';
	@api fill;

	connectedCallback() {
		this.iconStyling += (this.fill ? `fill: ${this.fill};` : '');
		this.iconClass += (" slds-icon_" + this.size);
	}

	get hasIcon() {
		return this.icon !== undefined && this.icon !== null && this.icon !== '';
	}

	get iconSprite() {
		if(this.hasIcon && this.icon.includes(':')){
			return this.icon.split(':')[0];
		}
		return null;
	}

	get iconName() {
		if(this.hasIcon && this.icon.includes(':')){
			return this.icon.split(':')[1];
		}
		else if(this.hasIcon){
			return this.icon;
		}
		return null;
	}
	
	get isIconImage() {
		return this.hasIcon && this.noSvg;
	}

	get isIconSVG() {
		return this.hasIcon && !this.isIconImage;
	}

	get iconLocation() {
		if(this.iconSprite !== null) {
			return "/_slds/icons/" + this.iconSprite + "-sprite/svg/symbols.svg#" + this.iconName;
		}
		return this.iconName;
	}
}