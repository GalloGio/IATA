import { LightningElement, api, track } from 'lwc';
import resources from "@salesforce/resourceUrl/ICG_Resources";

export default class CwStationManagersContainer extends LightningElement {

    @api userInfo;
    @api label;
	@api
    get preSelectedFacility() {
        return this.selectedFacility;
    }
    set preSelectedFacility(value) {
        this.selectedFacility = value;
        this.alignSelectedFacilityRecord();
	}

	editMode = true;

    @api
    userManagedFacilities;
    
	@track selectedFacility;
	selectedFacilityRecord
	selectFacility(event) {
        if (this.checkFormFields()) {
            //this.selectedFacility = this.template.querySelector('.facility-select') ? this.template.querySelector('.facility-select').value : null;
            this.selectedFacility = event.detail.data;
            this.alignSelectedFacilityRecord();
        }
	}
	checkFormFields() {
        const inputValid = [...this.template.querySelectorAll('input')]
            .reduce((validSoFar, inputCmp) => {
                if (validSoFar) inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
        const selectValid = [...this.template.querySelectorAll('select')]
            .reduce((validSoFar, inputCmp) => {
                if (validSoFar) inputCmp.reportValidity();
                return validSoFar && inputCmp.checkValidity();
            }, true);
        return inputValid && selectValid;
    }
	removeFacility() {
        this.selectedFacility = null;
    }
	alignSelectedFacilityRecord() {
        if (this.userManagedFacilities) {
            this.userManagedFacilities.forEach(fac => {
				if (fac.Id === this.selectedFacility) this.selectedFacilityRecord = fac;
            });
        }
	}
	get getLogoUrl() {
        if (this.selectedFacilityRecord && this.selectedFacilityRecord.logoUrl__c) {
            return this.selectedFacilityRecord.logoUrl__c;
        }

        return resources + "/img/no-image.svg";
    }

    get companyData() {
        let cdata = '';
        if (this.selectedFacilityRecord) {
            if (this.selectedFacilityRecord.Name) cdata += '<b>' + this.selectedFacilityRecord.Name.toUpperCase() + '</b>,';
            if (this.selectedFacilityRecord.Street_Nr_FOR__c) cdata += this.selectedFacilityRecord.Street_Nr_FOR__c + ',';
            if (this.selectedFacilityRecord.City__c) cdata += this.selectedFacilityRecord.City__c + ',';
            if (this.selectedFacilityRecord.IATA_ISO_Country__c) cdata += this.selectedFacilityRecord.IATA_ISO_Country__r.Name + ',';
            cdata = cdata.slice(0, -1);
        }
        return cdata;
	}
	
	get userRole(){
        let ur = this.selectedFacilityRecord && this.selectedFacilityRecord.userIsCompanyAdmin ? 'Company Admin' : this.selectedFacilityRecord ? 'Facility Manager' : null;
        return ur;
	}


}