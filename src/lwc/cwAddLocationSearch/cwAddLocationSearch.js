import { LightningElement, track, wire, api } from "lwc";
import getLocationsList from "@salesforce/apex/CW_LandingSearchBarController.getLocationsList";
import resources from "@salesforce/resourceUrl/ICG_Resources";
import { fillPredictiveValues, getPredictiveData } from "c/cwUtilities";

export default class CwAddLocationSearch extends LightningElement {
	availableLocations;
	@api label;
	@track locationPredictiveValues = [];
	@track location1 = { value: "" };
	@track location2 = { value: "" };
	@track disabledLocation1 = false;
	@track disabledLocation2 = false;
	@track isbox1focus;
	@track isbox2focus;

	searchbylocation = resources + "/icons/ic-white-location.svg";
	selectedlocation = resources + "/icons/search-by-location.svg";
	showOption = resources + "/icons/ic-show--option.svg";

	renderedCallback() {
		if (this.initialized) {
			return;
		}

		getPredictiveData("getLocationsList", getLocationsList()).then(response => {
			this.availableLocations = response;
			this._enableInputs();
		});

		this.isbox1focus = false;
		this.isbox2focus = false;
		this._addFocusOnSearchListener();

		this.initialized = true;
	}

	_addFocusOnSearchListener() {
		let box1 = this.template.querySelector('[data-tosca="locationinput1"]');
		if (box1) {
			box1.addEventListener("focus", event => {
				this.isbox1focus = true;
			});
			box1.addEventListener("blur", event => {
				this.isbox1focus = false;
			});
		}
		let box2 = this.template.querySelector('[data-tosca="locationinput2"]');
		if (box2) {
			box2.addEventListener("focus", event => {
				this.isbox2focus = true;
			});
			box2.addEventListener("blur", event => {
				this.isbox2focus = false;
			});
		}
	}

	_enableInputs() {
		let box = this.template.querySelector('[data-tosca="locationinput1"]');
		if (box) {
			box.disabled = false;
		}
		let boxM = this.template.querySelector('[data-tosca="locationinput2"]');
		if (boxM) {
			boxM.disabled = false;
		}
	}

	updateSearchbox1(event) {
		this.updateSearchbox(event, "1");
	}
	updateSearchbox2(event) {
		this.updateSearchbox(event, "2");
	}
	updateSearchbox(event, inputNumber) {
		if (inputNumber === "1") {
			this.location1 = event.detail;
		} else if (inputNumber === "2") {
			this.location2 = event.detail;
		}

		this.template.querySelector('[data-tosca="locationinput' + inputNumber + '"]').value = event.detail.value;
		this._switchPredictiveDisplay(false, inputNumber);
	}

	focusoninput(event) {
		const eTargetButton = event.target.getAttribute("data-tosca");

		const inputNumber = eTargetButton.includes("1") ? "1" : "2";
		const alterInputNumber = eTargetButton.includes("1") ? "2" : "1";
		this._switchPredictiveDisplay(true, inputNumber);
		this._switchPredictiveDisplay(false, alterInputNumber);
	}

	_switchPredictiveDisplay(bool, number) {
		let container = this.template.querySelector('[data-tosca="predictiveContainer' + number + '"]');

		if (container) {
			container.style.display = bool === true ? "block" : "none";
		}
	}

	predictiveSearch(event) {
		this.locationPredictiveValues = [];
		let num;
		if (event.target.getAttribute("data-tosca") === "locationinput1") {
			this.location1.value = event.target.value;
			num = "1";
		} else if (event.target.getAttribute("data-tosca") === "locationinput2") {
			this.location2.value = event.target.value;
			num = "2";
		}
		if (!event.target.value || event.target.value.length < 3) {
			return;
		}

		this.locationPredictiveValues = fillPredictiveValues(event.target.value, this.availableLocations);
		this._switchPredictiveDisplay(true, num);
	}

	addLocation(event) {
		const eTargetButton = event.target.getAttribute("data-tosca");
		let locationFired;
		let type;

		if (eTargetButton === "addlocationbutton1") {
			locationFired = this.location1.value;
			this.disabledLocation1 = true;
		} else {
			locationFired = this.location2.value;
			this.disabledLocation2 = true;
		}

		this.locationPredictiveValues.forEach(element => {
			if (element.label.trim() === locationFired.trim()) {
				type = element.type;
			}
		});

		let customEvent;
		if (type) {
			customEvent = new CustomEvent("selectlocations", { detail: { location: locationFired, type: type, position: eTargetButton, action: "add" } });
		} else {
			customEvent = new CustomEvent("selectlocations", { detail: { location: locationFired, position: eTargetButton, action: "add" } });
		}

		this.dispatchEvent(customEvent);
	}

	removeLocation(event) {
		const eTargetButton = event.currentTarget.getAttribute("data-tosca");

		let locationFired;
		if (eTargetButton === "removeLocation1") {
			locationFired = this.location1.value;
			this.location1 = { value: "" };
			this.disabledLocation1 = false;
		} else {
			locationFired = this.location2.value;
			this.location2 = { value: "" };
			this.disabledLocation2 = false;
		}
		this.initialized = false;
		this.dispatchEvent(new CustomEvent("selectlocations", { detail: { location: locationFired, position: eTargetButton, action: "delete" } }));
	}
}