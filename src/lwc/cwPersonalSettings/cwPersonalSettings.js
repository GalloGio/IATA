import { LightningElement, wire, track, api } from "lwc";
import getURL from "@salesforce/apex/CW_Utilities.getURLPage";
import getUserSettingsInfo from "@salesforce/apex/CW_PersonalSettingsController.getUserSettingsInfo";

export default class CwPersonalSettings extends LightningElement {
	initialized = false;
	urlPrivateArea;
	urlPublicArea;
	@api label;
	@track UserInfo;
	@track showMenu;

	@wire(getURL, { page: "URL_ICG_PrivateArea" })
	wiredURLPrivateArea({ data }) {
		if (data) {
			this.urlPrivateArea = data;
		}
	}

	@wire(getURL, { page: "URL_ICG_Home" })
	wiredURLPublicArea({ data }) {
		if (data) {
			this.urlPublicArea = data;
		}
	}

	@wire(getUserSettingsInfo, {})
	wiredUserInfo(result) {
		try {
			if (result && result.data) {
				this.UserInfo = JSON.parse(result.data);
			}
		} catch (exc) {
			console.error(exc);
		}
	}

	renderedCallback() {
		if (this.initialized) {
			return;
		}
		this.showMenu = false;
		this.initialized = true;
	}
	displayMenu() {
		this.showMenu = !this.showMenu;
	}

	goToPrivateArea() {
		window.location.href = this.urlPrivateArea;
	}
}