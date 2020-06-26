import { LightningElement, track, api } from 'lwc';
import icons from "@salesforce/resourceUrl/ICG_Resources";
import {
    concatinateFacilityAddress,
    concatinateAddressString,
    removeLastCommaAddress
  } from 'c/cwUtilities';

export default class CwBecomeManagerFacilityList extends LightningElement {
    tickSelection = icons + "/icons/ic-tic-green.svg";
    tickReadonly = icons + "/icons/ic-tic-orange.svg";
    @track pageSelected = 1;
    @track letterSelected;
    @track showOnlySelected = false;
    _preselectedFacilities;
    @api userInfo;
    @api label;
    @track _filterText;
    @api
    get filterText() {
        return this._filterText;
    }
    set filterText(val) {
        this._filterText = val;
        if (this.letterSelected) this.unselectLetter();
    }
    @api
    get preselectedFacilities() {
        return this._preselectedFacilities;
    }
    set preselectedFacilities(values) {
        this._preselectedFacilities = values;
        this._facilities.forEach(facility => {
            this._preselectedFacilities.forEach(preselected => {
                if (facility.value === preselected.value) facility.selected = true;
            });
        });
    }
    @track _facilities = [];
    @api
    get facilities() {
        return this._facilities;
    }
    set facilities(userFacilities) {
        //this._facilities = JSON.parse(JSON.stringify(value));
        this._facilities = [];
        userFacilities.forEach(facility => {
            if (facility && facility.isApproved__c && ((this.userInfo && this.userInfo.isCompanyAdmin != true) || !this.userInfo)) {
                let address = concatinateAddressString(facility.addressStreetNr) + concatinateAddressString(facility.secondAddress) + concatinateFacilityAddress(facility);
                address = removeLastCommaAddress(address);  
                let facilityInfo = {
                    value: facility.Id,
                    label: facility.Name,
                    selected: false,
                    clickable: true,
                    companyType: facility.RecordType.Name,
                    address: address
                }
                facilityInfo.address = facilityInfo.address.replace('undefined', '');
                if (facility.ICG_Contact_Role_Details__r && facility.ICG_Contact_Role_Details__r.totalSize > 0) {
                    facilityInfo.clickable = false;
                    facility.ICG_Contact_Role_Details__r.records.forEach(role => {
                        if (role.isApproved__c && role.ICG_Role__c === 'Facility Manager') facilityInfo.userManaged = true;
                        if (!facilityInfo.userManaged && role.isPendingApproval__c && role.ICG_Role__c === 'Facility Manager') facilityInfo.pendingUserManaged = true;
                    });
                }

                this._facilities.push(facilityInfo);

            }
        });
        //ADD HEADERS
        let facilitiesDummy = [];
        let prevLetter;
        this._facilities.forEach(facility => {
            if (!prevLetter || prevLetter !== facility.label.charAt(0).toUpperCase()) {
                facilitiesDummy.push({ label: facility.label.charAt(0).toUpperCase(), isHeader: true });
            }
            prevLetter = facility.label.charAt(0).toUpperCase();
            facilitiesDummy.push(facility);
        });
        this._facilities = facilitiesDummy;

    }

    initialized = false;
    renderedCallback() {
        if (!this.initialized) {
            this.initialized = true;
        }
    }

    selectFacility(event) {
        event.preventDefault();
        let eTarget = event.currentTarget;
        let name = eTarget.dataset ? eTarget.dataset.name : 'missing dataset';

        let numberOfSelectedFacilities = this.allSelectedFacilities ? this.allSelectedFacilities.length : 0;    
        let isSameFacility = false;

        this.allSelectedFacilities.forEach(elem => {
            if(elem.value === name){
                isSameFacility = true;
            }
        });

        if(numberOfSelectedFacilities > 0 && !isSameFacility){
            this.dispatchEvent(new CustomEvent('toomanyfacilities', {})); 
        }
        else{
            this._facilities.forEach(elem => { if (elem.value === name) { elem.selected = !elem.selected } });
            this.dispatchEvent(new CustomEvent('selectfacilities', { detail: this.allSelectedFacilities })); 
        }
    }

    showHideSelectedFacilities() {
        this.unselectLetter()
        this.showOnlySelected = !this.showOnlySelected;
    }

    selectLetter(event) {
        this.pageSelected = 1;
        this.letterSelected = event.currentTarget.dataset.letter;
        this.template.querySelectorAll('.letterSelected').forEach(elem => {
            elem.classList.remove('letterSelected');
        });

        this.template.querySelector('[data-letter="' + this.letterSelected + '"]').classList.add('letterSelected');
    }
    unselectLetter() {
        this.pageSelected = 1;
        this.letterSelected = null;
        this.template.querySelectorAll('.letterSelected').forEach(elem => {
            elem.classList.remove('letterSelected');
        });
        this.template.querySelector('[data-letter="ALL"]').classList.add('letterSelected');
    }
    next() {
        this.pageSelected++;
    }
    back() {
        this.pageSelected--;
    }

    get facilitiesFirst() {
            let dummyFacilities = [];
            let facilitiesToLoop;
            if (this.showOnlySelected) facilitiesToLoop = this.selectedFacilities;
            else facilitiesToLoop = this.filteredFacilities;
            if (facilitiesToLoop && facilitiesToLoop.length >= this.pageSelected) return facilitiesToLoop.slice(((this.pageSelected - 1) * 10), ((this.pageSelected - 1) * 10 + 10));
            return dummyFacilities;
        }
        /*
        get facilitiesSecond(){
            let dummyFacilities = [];
            let facilitiesToLoop;
            if(this.showOnlySelected) facilitiesToLoop = this.selectedFacilities;
            else facilitiesToLoop = this.filteredFacilities;
            if (facilitiesToLoop && facilitiesToLoop.length >= this.pageSelected + 10) return facilitiesToLoop.slice(((this.pageSelected -1) * 30 + 10), ((this.pageSelected -1) * 30 + 20));
            return dummyFacilities;
        }
    
        get facilitiesThird(){
            let dummyFacilities = [];
            let facilitiesToLoop;
            if(this.showOnlySelected) facilitiesToLoop = this.selectedFacilities;
            else facilitiesToLoop = this.filteredFacilities;
            if (facilitiesToLoop && facilitiesToLoop.length >= this.pageSelected + 20) return facilitiesToLoop.slice(((this.pageSelected -1) * 30 + 20), ((this.pageSelected -1) * 30 + 30));
            return dummyFacilities;
        }
        */
    get selectedFacilities() {
        let selectedFacilities = [];
        let prevIsHeader = true;
        this.filteredFacilities.forEach(facility => {
            if (facility.isHeader || facility.selected) {
                if (selectedFacilities.length > 0 && prevIsHeader && facility.label.charAt(0).toLowerCase() != selectedFacilities[selectedFacilities.length - 1].label.toLowerCase()) selectedFacilities.pop();
                prevIsHeader = facility.isHeader;

                selectedFacilities.push(facility);
            }
        });
        if (selectedFacilities.length > 0 && selectedFacilities[selectedFacilities.length - 1].isHeader) selectedFacilities.pop();
        return selectedFacilities;
    }

    get allSelectedFacilities() {
        let selectedFacilities = [];
        let prevIsHeader = true;
        this._facilities.forEach(facility => {
            if (facility.isHeader || facility.selected) {
                if (selectedFacilities.length > 0 && prevIsHeader && facility.label.charAt(0).toLowerCase() != selectedFacilities[selectedFacilities.length - 1].label.toLowerCase()) selectedFacilities.pop();
                prevIsHeader = facility.isHeader;

                selectedFacilities.push(facility);
            }
        });
        if (selectedFacilities.length > 0 && selectedFacilities[selectedFacilities.length - 1].isHeader) selectedFacilities.pop();
        return selectedFacilities;
    }

    //First filter - By Letter
    get letterFilteredfacilities() {
        if (!this.letterSelected) {
            return this.facilities;
        } else {
            let filteredFacilities = [];
            this._facilities.forEach(facility => {
                if ((facility.isHeader && facility.label.toLowerCase() === this.letterSelected.toLowerCase()) || this.letterSelected.toLowerCase() === facility.label.charAt(0).toLowerCase()) filteredFacilities.push(facility);
            });
            return filteredFacilities;
        }
    }

    //Last Filter - Sum of all filters
    get filteredFacilities() {
        if (!this.filterText) {
            return this.letterFilteredfacilities;
        } else {
            let filteredFacilities = [];
            let prevIsHeader = true;
            this.letterFilteredfacilities.forEach(facility => {
                if (facility.isHeader || facility.label.toLowerCase().indexOf(this.filterText.toLowerCase()) > -1) {
                    if (filteredFacilities.length > 0 && prevIsHeader && facility.label.charAt(0).toLowerCase() != filteredFacilities[filteredFacilities.length - 1].label.toLowerCase()) filteredFacilities.pop();
                    prevIsHeader = facility.isHeader;
                    filteredFacilities.push(facility);
                }
            });
            if (filteredFacilities.length > 0 && filteredFacilities[filteredFacilities.length - 1].isHeader) filteredFacilities.pop();
            return filteredFacilities;
        }
    }

    get showHideSelectedFacilitiesButtonText() {
        if (this.showOnlySelected) return 'Show All Facilities';
        return 'Show Selected Facilities';
    }

    get showBackButton() {
        return this.pageSelected > 1;
    }
    get showNextButton() {
        if (this.showOnlySelected) return ((this.pageSelected - 1) * 10 + 10) < this.selectedFacilities.length;
        else return ((this.pageSelected - 1) * 10 + 10) < this.filteredFacilities.length;
    }


}