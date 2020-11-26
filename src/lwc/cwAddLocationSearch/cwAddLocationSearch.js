import { LightningElement, track, wire, api } from "lwc";
import getLocationsList from "@salesforce/apex/CW_LandingSearchBarController.getLocationsList";
import resources from "@salesforce/resourceUrl/ICG_Resources";
import { fillPredictiveValues, getPredictiveData, reachedLimit } from "c/cwUtilities";
import { ShowToastEvent } from "lightning/platformShowToastEvent";

export default class CwAddLocationSearch extends LightningElement {
	availableLocations;
	@api label;
	@api filtersApplied = [];
	@track locationPredictiveValues = [];
	@track location1 = { value: "" };
	@track location2 = { value: "" };
	@track disabledLocation1 = false;
	@track disabledLocation2 = false;
	@track isbox1focus;
	@track isbox2focus;
	@track searchValue = "";
	@api appliedFiltersCount;

	searchbylocation = resources + "/icons/ic-white-location.svg";
	selectedlocation = resources + "/icons/search-by-location.svg";
	showOption = resources + "/icons/ic-show--option.svg";

	@api environmentVariables;

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
		const eTargetButton = event.target.getAttribute("data-tosca");
		this.addLocation(eTargetButton);
	}
	updateSearchbox2(event) {
		this.updateSearchbox(event, "2");
		const eTargetButton = event.target.getAttribute("data-tosca");
		this.addLocation(eTargetButton);
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
		if (!this.reachedLimit){
			const eTargetButton = event.target.getAttribute("data-tosca");

			const inputNumber = eTargetButton.includes("1") ? "1" : "2";
			const alterInputNumber = eTargetButton.includes("1") ? "2" : "1";
			this._switchPredictiveDisplay(true, inputNumber);
			this._switchPredictiveDisplay(false, alterInputNumber);
		}
	}

	_switchPredictiveDisplay(bool, number) {
		let container = this.template.querySelector('[data-tosca="predictiveContainer' + number + '"]');

		if (container) {
			container.style.display = bool === true ? "block" : "none";
		}
	}

	predictiveSearch(event) {
		if (!this.reachedLimit){
			this.locationPredictiveValues = [];
			let num;
			this.searchValue = event.target ? event.target.value : "";
			if (event.target.getAttribute("data-tosca") === "locationinput1") {
				this.location1.value = this.searchValue;
				num = "1";
			} else if (event.target.getAttribute("data-tosca") === "locationinput2") {
				this.location2.value = this.searchValue;
				num = "2";
			}
			if (!this.searchValue || this.searchValue.length < 3) {
				return;
			}
			if(this.searchValue.length >=3 && this.searchValue.trim().length == 0){
				return;
			}

			this.locationPredictiveValues = fillPredictiveValues(this.searchValue, this.availableLocations);
			this._switchPredictiveDisplay(true, num);
		}
	}

	addLocation(eTargetButton) {
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

		let alreadyApplied = this.filtersApplied.some(filter => filter.label === locationFired);
		if(alreadyApplied){

			if (eTargetButton === "addlocationbutton1") {
				this.disabledLocation1 = false;
			} else {
				this.disabledLocation2 = false;
			}

			const event = new ShowToastEvent({
				title: 'Warning',
				message: this.label.icg_already_applied_filter,
				variant: 'warning'
			});
			this.dispatchEvent(event);
		}
		else{
			this.dispatchEvent(customEvent);
		}
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
	
	get reachedLimit(){
		return reachedLimit(this.environmentVariables, this.appliedFiltersCount);
	}
}