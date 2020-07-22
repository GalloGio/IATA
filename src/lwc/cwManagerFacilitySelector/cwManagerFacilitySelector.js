import { LightningElement, api, track } from 'lwc';
import resources from "@salesforce/resourceUrl/ICG_Resources";

export default class CwManagerFacilitySelector extends LightningElement {
    @api userManagedFacilities;
    @api userInfo;
    @track _selectedFacility;
    @api label;
    @api 
    get selectedFacility(){
        return this._selectedFacility;
    }
    set selectedFacility(value){
        this._selectedFacility = value;
    }

    bluearrow = resources + "/icons/blue-arrow.svg";

    get selectStyle(){
        return 'facility-select backgroundBlueArrow';
    }

    changeHandler(event){
        const selectedFacilityEvent = new CustomEvent("facilityselection", {
            detail: event.target.value
        });
        this._selectedFacility = event.target.value;
        // Dispatches the event.
        this.dispatchEvent(selectedFacilityEvent);
    }
    renderedCallback(){
        let options = this.template.querySelectorAll('option');
        if(options){
            options.forEach(opt =>{
                if(this.selectedFacility && this.selectedFacility === opt.value) opt.selected = true;
                else opt.selected = false;
            });
        }
    }
}