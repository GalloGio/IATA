import { LightningElement, api, track } from "lwc";
import resources from "@salesforce/resourceUrl/ICG_Resources";
import setFacilityInfo_ from "@salesforce/apex/CW_FacilityContactInfoController.setFacilityInfo";
import { checkInputValidation } from "c/cwUtilities";

export default class CwAccountDetailOverview extends LightningElement {
	initialized = false;
	isLoading = false;
	mainCssCapability = "facility-overview-item-container p-1-5 col-md-12 col-lg-3 col-xl-3";
	disabledFilter = " disabled-filter-dark";
	textInformationHover = "Information not verified by IATA";

	@track tooltipObject;
	@track tooltipToDisplay = "";
	@track editOn = false;

	//icons
	icon = {
		employees: resources + "/icons/ic-employees-inverted.svg",
		airlines: resources + "/icons/ic-airlines-handled--blue.svg",
		blueCheck: resources + "/icons/ic-tic-blue.svg",
		blueCheckInverted: resources + "/icons/ic-tic-blue-inverted.svg",
		trucker: resources + "/icons/company_type/trucker.svg"
	};

	@api title = "";
	@api facility = null;
	@api editMode = false;
	@api saveOnTheFly = false;
	@api label;

	numberEmployeesRT = ["Cargo_Handling_Facility", "Freight_Forwarder", "Airline", "Airport_Operator", "Trucker", "Ramp_Handler"];
	roadFeederRT = ["Airline"];
	facilitySpaceRT = ["Cargo_Handling_Facility","Freight_Forwarder"];
	onAirportRT = ["Cargo_Handling_Facility", "Freight_Forwarder", "Trucker"];
	trucksRT = ["Trucker"];
	directRampAccessRT = ["Cargo_Handling_Facility"];
	overallAirportSizeRT = ["Airport_Operator"];
	hideAll = ["Shipper"];

	get shouldHideAll() {
		return this.hideAll.includes(this.facility.recordTypeDevName);
	}

	get numberEmployeesFormatted() {
		return this.numberToString(this.facility.NumberEmployees);
	}

	get numberTrucksFormatted() {
		return this.numberToString(this.facility.fleet);
	}

	get getListAirIcon() {
		return resources + "/icons/company_type/cargo_com_airline.jpg";
	}

	get showNumberEmployyes() {
		return this.numberEmployeesRT.includes(this.facility.recordTypeDevName);
	}

	get showRoadFeeder() {
		return this.roadFeederRT.includes(this.facility.recordTypeDevName);
	}

	get showFacilitySpace() {
		return this.facilitySpaceRT.includes(this.facility.recordTypeDevName);
	}

	get showTrucks() {
		return this.trucksRT.includes(this.facility.recordTypeDevName);
	}

	get showOverallAirportSize() {
		return this.overallAirportSizeRT.includes(this.facility.recordTypeDevName);
	}

	get showOnAirport() {
		return this.onAirportRT.includes(this.facility.recordTypeDevName);
	}
	get showDirectRampAccess() {
		return this.directRampAccessRT.includes(this.facility.recordTypeDevName);
	}

	get facilitySizeFormatted() {
		return this.numberToString(this.facility.FacilitySize);
	}

	get overallSizeFormatted() {
		return this.numberToString(this.facility.overallAirportSize);
	}

	renderedCallback() {
		if (this.initialized) {
			return;
		}
		this.initialized = true;
		let inputs = this.template.querySelectorAll(".input");
		let validated = checkInputValidation(inputs);
		this.updateDataValid(validated);
	}

	updateFacilityOnParent() {
		let customEvent = new CustomEvent("updatefacility", { detail: this.facility });
		this.dispatchEvent(customEvent);
	}

	setFacilityOverviewInfo(id, key, value) {
		this.isLoading = true;
		if (this.saveOnTheFly) {
			setFacilityInfo_({ id, key, value })
				.then(response => {
					if (response.result.status === "OK") {
						this.facility = JSON.parse(JSON.stringify(this.facility));
						let newValue = response.result.value;

						if (newValue === "undefined") {
							newValue = null;
						}
						if (response.result.key === "IsOnAirport" || response.result.key === "DirectRampAccess") {
							newValue = newValue === "true";
						}
						this.facility[response.result.key] = newValue;
						this.updateFacilityOnParent();
					}
					this.isLoading = false;
				})
				.catch(error => {
					this.isLoading = false;
				});
		} else {
			this.isLoading = false;
			this.facility = JSON.parse(JSON.stringify(this.facility));
			this.facility[key] = value;
			this.updateFacilityOnParent();
		}
	}

	handleInputChangeValue(event) {
		let inputs = this.template.querySelectorAll(".input");
		let validated = checkInputValidation(inputs);
		this.updateDataValid(validated);

		if (event.target.name === "NumberEmployees" || event.target.name === "FacilitySize" || event.target.name === "IsOnAirport" || event.target.name === "DirectRampAccess" || event.target.name === "roadFeederServices" || event.target.name === "overallAirportSize" || event.target.name === "fleet") {
			let newValue = event.target.value;
			if (event.target.name === "NumberEmployees" || event.target.name === "FacilitySize" || event.target.name === "overallAirportSize") {
				newValue = parseInt(newValue, 10);
				if (isNaN(newValue)) {
					newValue = null;
				}
			} else if (event.target.name === "IsOnAirport" || event.target.name === "DirectRampAccess" || event.target.name === "roadFeederServices" || event.target.name === "fleet") {
				newValue = event.target.checked;
			}
			if (newValue !== this.facility[event.target.name]) {
				this.setFacilityOverviewInfo(this.facility.Id, event.target.name, newValue);
			}
		}
	}

	numberToString(numberToFormat) {
		//'de' format as default, as we agreed to use dots.
		return numberToFormat ? numberToFormat.toLocaleString("de") : "";
	}

	get roadFeederCSS() {
		return this.genericCSS(this.facility.roadFeederServices) + ' editable';
	}

	get facilitySpaceCss() {
		return this.genericCSS(this.facility.FacilitySize);
	}

	get onAirportCss() {
		return this.genericCSS(this.facility.IsOnAirport) + ' editable';
	}

	get directAccessCss() {
		return this.genericCSS(this.facility.DirectRampAccess) + ' editable';
	}

	get overallAirportCss() {
		return this.genericCSS(this.facility.overallAirportSize);
	}
	get trucksCss() {
		return this.genericCSS(this.facility.fleet);
	}

	get numberEmployeesCss() {
		return this.genericCSS(this.facility.NumberEmployees);
	}

	genericCSS(capability) {
		return capability ? this.mainCssCapability : this.mainCssCapability + this.disabledFilter;
	}

	updateDataValid(validated) {
		let customEvent = new CustomEvent("updatedatavalidoverview", { detail: validated });
		this.dispatchEvent(customEvent);
	}

	showPopover(event) {
		if (this.editMode) {
			return;
		}
		let item = event.currentTarget.dataset.item;		

		const cssParent = this.template.querySelector("div[data-css=" + item + "]");
		let shouldShow = false;
		if (cssParent) {
			const cssClassElement = cssParent.classList.value;
			shouldShow = !cssClassElement.includes(this.disabledFilter);
		}
		const text = this.textInformationHover;

		if(shouldShow){
			let tooltipObject = {
				item: item,
				text: text
			}		
			this.tooltipToDisplay = item;
			this.tooltipObject = tooltipObject;
		}
		else{
			this.hidePopover();
		}

	}

	hidePopover() {
		this.tooltipToDisplay = "";
		this.tooltipObject = null;
	}

	showInput(event){
		this.editOn = !this.editOn;
	}

	@api editOff(){		
		this.editOn = false;
	}
}