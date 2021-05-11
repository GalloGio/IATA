import { LightningElement, api, track } from 'lwc';
import resources from "@salesforce/resourceUrl/ICG_Resources";

export default class CwHandlingServices extends LightningElement {
	initialized = false;
	@track editModeActive = false;
	@api label;
	@api title;
	@track isLoading = false;
	@track editModeActive = false;
	@track editOn = false;
	@api editMode = false;
	@track _facility;
	@track services = [];
	@api saveOnTheFly = false;
	@api
	get facility() {
		return this._facility;
	}
	set facility(value) {
		this._facility = JSON.parse(JSON.stringify(value));
		this.loadServices();
	}

	icons = {
		greenCheck: resources + "/icons/ic-tic-green.svg",
		blueCheck: resources + "/icons/ic-tic-blue.svg",
		blackCheck: resources + "/icons/ic-tic-black.svg",
		cargoCompanyType: resources + "/icons/company_type/cargo_com_airline.jpg"
	};

	get itemLayoutCssClass() {
		return "cursor-pt tooltip-service display-flex";
	}

	setActiveService(event){
		if (!this.editModeActive) {
			return;
		}

		let selectedService = event.currentTarget;
		let idService = event.currentTarget.dataset.id;

		let inHouseServices = [];
		let thirdPartyServices = [];

		this.services.forEach(item => {
			if (item.id == idService){
				if (item.isInHouse){
					item.isInHouse = false;
					item.isThirdParty = true;
					item.isDeselected = false;
					item.hasTooltip = true;
				}else if (item.isThirdParty){
					item.isInHouse = false;
					item.isThirdParty = false;
					item.isDeselected = true;
					item.hasTooltip = (item.tooltip != '') ? true : false;
				}else {
					item.isInHouse = true;
					item.isThirdParty = false;
					item.isDeselected = false;
					item.hasTooltip = true;
				}
			}

			if (item.isInHouse){
				inHouseServices.push({ api: item.key, label: item.label });
			} else if (item.isThirdParty){
				thirdPartyServices.push({ api: item.key, label: item.label });
			} 
		});

		this.facility.inHouseServices = inHouseServices;
		this.facility.thirdPartyServices = thirdPartyServices;
		this.updateFacilityOnParent();
	}

	initialStatus(event){
		let selectedService = event.currentTarget;
		let idService = event.currentTarget.dataset.id;
		let imgCheck =this.template.querySelector(`img[data-item="${idService}"]`);

		let status = 'inactive-service';
		this.services.forEach(item => {
			if (item.id == idService){
				if (item.isInHouse){
					imgCheck.src=this.icons.blackCheck;
					status = 'active-service';
				}else if (item.isThirdParty){
					imgCheck.src=this.icons.greenCheck;
					status = 'active-third-service';
				}else {
					imgCheck.src='';
					status = 'inactive-service';
				}
			}
		});
		return status;
	}

	showInput(event){
		this.editOn = !this.editOn;
		if(this.editOn){
			this.editModeActive = true;
		}else{
			this.editModeActive = false;
		}
	}

	@api editOff(){		
		this.editOn = false;
		this.editModeActive = false;
	}

	loadServices() {
		if (!this.initialized) {
			let thirdPartyServices = [];
			let inHouseServices = [];
			this.facility.thirdPartyServices.forEach(item => { thirdPartyServices.push(item.api); });
			this.facility.inHouseServices.forEach(item => { inHouseServices.push(item.api); });

			let idHtml = 0;
			
			this.facility.allServices.forEach(item => {
				let hasTooltip = item.tooltip != '' ? true : false;
				idHtml++;
				if (thirdPartyServices.includes(item.api)){
					this.services.push({ key: item.api, label: item.label, id: idHtml, isThirdParty: true, isInHouse: false, isDeselected: false, tooltip: item.tooltip, hasTooltip: hasTooltip });
				}
				else if (inHouseServices.includes(item.api)){
					this.services.push({ key: item.api, label: item.label, id: idHtml, isThirdParty: false, isInHouse: true, isDeselected: false, tooltip: item.tooltip, hasTooltip: hasTooltip });

				}else{
					this.services.push({ key: item.api, label: item.label, id: idHtml, isThirdParty: false, isInHouse: false, isDeselected: true, tooltip: item.tooltip, hasTooltip: hasTooltip });
				}
			});

			this.initialized = true;
		}
	}

	updateFacilityOnParent() {
		let customEvent = new CustomEvent("updatefacility", { detail: this.facility });
		this.dispatchEvent(customEvent);
	}
}