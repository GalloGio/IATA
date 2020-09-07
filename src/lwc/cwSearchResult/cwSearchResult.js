import { LightningElement, wire, api } from "lwc";
import resources from "@salesforce/resourceUrl/ICG_Resources";
import { concatinateFacilityAddress, concatinateAddressString, removeLastCommaAddress } from "c/cwUtilities";

export default class CwSearchResult extends LightningElement {
	icons = resources + "/icons/";
	searchbylocation = this.icons + "search-by-location.svg";
	@api label;
	@api urlResultPage;

	_input;

	@api 
	get input(){
		return this._input;
	}

	set input(value){
		let valueCopy = JSON.parse(JSON.stringify(value));
		let facilityCopy = JSON.parse(JSON.stringify(valueCopy.facility));
		facilityCopy.lstAvailableCertifications = JSON.parse(JSON.stringify(value.lstAvailableCertifications)); 
		valueCopy.facility = facilityCopy;
		this._input = valueCopy;
	}

	handleMoreInfo() {
		//var currenturl = location.href;
		let url = this.urlResultPage + "?eid=" + this.input.facility.Id;

		window.open(url, "_blank");
	}
	get phoneto() {
		let phone = this.input.facility.phone ? this.input.facility.phone : "N/A";
		return "tel:" + phone;
	}

	get emailto() {
		if (this.input.facility.email) return "mailto:" + this.input.facility.email;
		return "#";
	}

	get addresstogm() {
		let address = concatinateAddressString(this.input.facility.addressStreetNr) + concatinateAddressString(this.input.facility.secondAddress) + concatinateFacilityAddress(this.input.facility);
		address = removeLastCommaAddress(address);
		if (address) return "https://maps.google.com/?q=" + address;
		return "#";
	}

	get facilityAddress() {
		let address = concatinateAddressString(this.input.facility.addressStreetNr) + concatinateAddressString(this.input.facility.secondAddress) + concatinateFacilityAddress(this.input.facility);
		return removeLastCommaAddress(address);
	}

	get addressAndPhone() {
		return this.facilityAddress && this.input.facility.phone;
	}

	get phoneAndEmail() {
		return this.input.facility.phone && this.input.facility.email;
	}

	get addressAndEmail() {
		return this.facilityAddress && !this.input.facility.phone && this.input.facility.email;
	}
}