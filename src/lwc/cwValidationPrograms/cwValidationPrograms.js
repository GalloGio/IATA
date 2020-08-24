import { LightningElement, wire, track, api } from 'lwc';
import getCertifications from "@salesforce/apex/CW_ResultsPageSearchBarController.getCertifications";
import resources from "@salesforce/resourceUrl/ICG_Resources";
import {
    checkIfDeselectAll,
    checkIfChangeSelectAllText
} from 'c/cwUtilities';
import getEnvironmentVariables from '@salesforce/apex/CW_Utilities.getEnvironmentVariables';

export default class CwValidationPrograms extends LightningElement {
    @track selectedText = 'Select All';
    @api label;
    @api appliedFiltersCount;
    icons = resources + "/icons/";
    //icons
    tickSelection = this.icons + "ic-gsearch--selected.svg";
    
    @track certifications;
    @wire(getCertifications, {})
    wiredCertifications({ data }) {
        if (data) {
            this.certifications = JSON.parse(JSON.stringify(data));
        }
    }

    @wire(getEnvironmentVariables, {})
    environmentVariables;
    
    onClickItem(event) {
        let eTarget = event.currentTarget;
        let name = eTarget.getAttribute("data-name");

        let selectedProgram;
        let selected;

        this.certifications.forEach(element => {
            if (element.Name === name && (!this.reachedLimit || (this.reachedLimit && element.selected))) {
                element.selected = !element.selected;
                selectedProgram = [element];
                selected = element.selected;
            }
        });

        let items = this.template.querySelectorAll("[data-name='" + name + "']");

        if(selected){
            if (!this.reachedLimit){
                this._selectItems(items);

                this.selectedText = checkIfChangeSelectAllText(this.certifications);
                this.dispatchEvent(new CustomEvent('selectvalidationprograms', { detail: selectedProgram }));
            }
        }
        else{
            this._unselectItems(items);

            this.selectedText = checkIfChangeSelectAllText(this.certifications);
            this.dispatchEvent(new CustomEvent('selectvalidationprograms', { detail: selectedProgram }));
        }
    }

    selectAllCertifications() {

        let shouldDeselectAll = checkIfDeselectAll(this.certifications);
        let allPrograms = [];

        this.certifications.forEach(element => {
            element.selected = !shouldDeselectAll;
            allPrograms.push(element);
        });

        let items = this.template.querySelectorAll("[data-type='certification']");
        if(shouldDeselectAll){
            this._unselectItems(items);
        }
        else {
            this._selectItems(items);
        }

        this.selectedText = checkIfChangeSelectAllText(this.certifications);

        this.dispatchEvent(new CustomEvent('selectvalidationprograms', { detail: allPrograms }));
    }

    _selectItems(items) {
        items.forEach(element => {
            element.classList.remove('itemUnselected');
            element.classList.add('itemSelected');
        });
    }

    _unselectItems(items){
        items.forEach(element => {
            element.classList.remove('itemSelected');
            element.classList.add('itemUnselected');
        });
    }

    get reachedLimit(){
		return  this.appliedFiltersCount >= this.environmentVariables.data.max_filters_allowed__c;
    }

    get reachedLimitWithAll(){
        if (this.certifications){
            let potentialSelect = 0;
            this.certifications.forEach(element => {
                if (!element.selected) {
                    potentialSelect++;
                }
            });
            return  (this.appliedFiltersCount + potentialSelect) > this.environmentVariables.data.max_filters_allowed__c;
        }
    }
    
    get selectAllVisible(){
        if (this.certifications){
            return !(this.selectedText === "Select All" && this.reachedLimitWithAll);
        }
    }
}