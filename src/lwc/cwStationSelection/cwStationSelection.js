import { LightningElement, api, track } from 'lwc';
import resources from "@salesforce/resourceUrl/ICG_Resources";
import {getImageString} from "c/cwUtilities";

export default class CwStationSelection extends LightningElement {

    icons = resources + "/icons/";

    @api label;
    @api userManagedFacilities;
    @track selectedFacility;
    @track facilityName;
    @track facility;
    @track groupName;
    @track address;
    @track recordTypeName;
    @track logoURL;
    searchbylocation = this.icons + "search-by-location.svg";
    _preSelectedFacility;
    @api 
    get preSelectedFacility(){
        return this._preSelectedFacility;
    }
    set preSelectedFacility(value){
        this._preSelectedFacility = value;
        this.selectedFacility = value;
        this.updateValues();
    }


    selectFacility(event) {
        this.selectedFacility = event.target.value;
        this.updateValues();

        const newEvent = new CustomEvent("selectfacility", {
            detail: {
                data: this.selectedFacility
            }
        });
        this.dispatchEvent(newEvent);
    }

    updateValues() {
        this.address = "";

        if (this.userManagedFacilities) {
            this.userManagedFacilities.forEach(facility => {
                if (facility.Id === this.selectedFacility) {
                    let facilityCopy = JSON.parse(JSON.stringify(facility));
                    facilityCopy.isSelected = facility.Id === this.selectedFacility;
                    facility = JSON.parse(JSON.stringify(facilityCopy));
                    this.facilityName = facility.Name;
                    this.facility = facility;
                    this.recordTypeName = facility.RecordType.Name;
                    this.groupName = facility.groupName;
                    this.logoURL = facility.logoUrl__c;
                    this.recordTypeDevName = facility.RecordType.DeveloperName;
                    this.address = facility.Formatted_Address__c;
                }
            });
        }
    }

    get getCompanyTypeImage() {
		let imageString = "";
		if (this.facility) {
			imageString = getImageString(this.recordTypeDevName);
		}
		return resources + "/icons/company_type/" + imageString;
    }

    get getLogoUrl() {
		if (this.facility && this.facility.logoUrl__c) {
			return this.facility.logoUrl__c;
		}

		return resources + "/img/no-image.svg";
    }
    
    setDefaultImg(event){
		event.target.src = resources + "/img/no-image.svg";
	}

}