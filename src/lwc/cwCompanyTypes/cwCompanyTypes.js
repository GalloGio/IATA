import { LightningElement, track, wire, api } from 'lwc';
import getCompanyTypes from '@salesforce/apex/CW_Utilities.getCompanyTypes';
import pubsub from "c/cwPubSub";
import {
    checkIfDeselectAll,
    checkIfChangeSelectAllText
} from 'c/cwUtilities';
import getEnvironmentVariables from '@salesforce/apex/CW_Utilities.getEnvironmentVariables';
export default class CwCompanyTypes extends LightningElement {
    // @api file;
    @api label;
    @track selectedText = 'Select All';
    @api appliedFiltersCount;

    @track companyTypes;
    @wire(getCompanyTypes, {})
    wiredUserInfo({ data }) {
        if (data) {
            this.companyTypes = JSON.parse(data);
        }
    }

    @wire(getEnvironmentVariables, {})
    environmentVariables;

    onClickItem(event) {
        let eTarget = event.currentTarget;
        let name = eTarget.getAttribute("data-name");

        let selectedCType;
        let selected;

        this.companyTypes.forEach(element => {
            if (element.name === name && (!this.reachedLimit || (this.reachedLimit && element.selected))) {
                element.selected = !element.selected;
                selectedCType = [element];
                selected = element.selected;
            }
        });

        let items = this.template.querySelectorAll("[data-name='" + name + "']");

        if(selected) {
            if (!this.reachedLimit){
                this._selectItems(items);

                this.selectedText = checkIfChangeSelectAllText(this.companyTypes);
        
                pubsub.fire("stationTypeUpdated", selectedCType);
                this.dispatchEvent(new CustomEvent('selectcompanytype', { detail: selectedCType }));
            }
        }
        else{
            this._unselectItems(items);

            this.selectedText = checkIfChangeSelectAllText(this.companyTypes);
    
            pubsub.fire("stationTypeUpdated", selectedCType);
            this.dispatchEvent(new CustomEvent('selectcompanytype', { detail: selectedCType }));
        }
    }

    searchAllCTypes() {
        let shouldDeselectAll = checkIfDeselectAll(this.companyTypes);
        let allPrograms = [];

        this.companyTypes.forEach(element => {
            element.selected = !shouldDeselectAll;
            allPrograms.push(element);
        });

        let items = this.template.querySelectorAll("[data-type='companyType']");
        if(shouldDeselectAll) {
            this._unselectItems(items);
        }
        else {
            this._selectItems(items);
        }
        this.selectedText = checkIfChangeSelectAllText(this.companyTypes);
        pubsub.fire("stationTypeUpdated", allPrograms);
        this.dispatchEvent(new CustomEvent('selectcompanytype', { detail: allPrograms }));

    }

    _selectItems(items) {
        items.forEach(element => {
            element.classList.remove('itemUnselected');
            element.classList.add('itemSelected');
        });
    }

    _unselectItems(items) {
        items.forEach(element => {
            element.classList.remove('itemSelected');
            element.classList.add('itemUnselected');
        });
    }

    get reachedLimit(){
		return  this.appliedFiltersCount >= this.environmentVariables.data.max_filters_allowed__c;
    }

    get reachedLimitWithAll(){
        if (this.companyTypes){
            let potentialSelect = 0;
            this.companyTypes.forEach(element => {
                if (!element.selected) {
                    potentialSelect++;
                }
            });
            return  (this.appliedFiltersCount + potentialSelect) > this.environmentVariables.data.max_filters_allowed__c;
        }
    }
    
    get selectAllVisible(){
        if (this.companyTypes){
            return !(this.selectedText === "Select All" && this.reachedLimitWithAll);
        }
    }

}