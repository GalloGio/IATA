import { LightningElement, api } from 'lwc';

export default class ScopedNotifications extends LightningElement {
	/** base | info | success | warning | error */
	@api variant;

	get error() {
		return 'error' === this.variant;
	}

	get warning() {
		return 'warning' === this.variant;
	}

	get success() {
		return 'success' === this.variant;
	}

	get info() {
		return 'info' === this.variant;
	}

	get base() {
		return !this.error && !this.warning && !this.success && !this.info;
	}

	get containerDivClass() {
		return 'slds-scoped-notification slds-media slds-media_center ' + (this.base ? 'slds-scoped-notification_light' : 'slds-theme_' + this.variant);
	}

	get icon() {
		return this.base ? 'info' : this.variant;
	}

	get iconLink() {
		return '/_slds/icons/utility-sprite/svg/symbols.svg#' + this.icon;
	}

	get iconContainerClass() {
		return 'slds-icon_container slds-icon-utility-' + (this.base ? 'info' : this.variant);
	}
}