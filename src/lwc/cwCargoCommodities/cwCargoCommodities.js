import { LightningElement, track, api } from 'lwc';
import resources from "@salesforce/resourceUrl/ICG_Resources";
import {
    checkIfDeselectAll,
    checkIfChangeSelectAllText
} from 'c/cwUtilities';
export default class CwCargoCommodities extends LightningElement {
    @api label;
    @track selectedText = 'Select All';

    @track commodities = [{
            name: "General Cargo",
            selected: false,
            enabled: true,
            field: "General_Cargo__c",
            obj: "icg_account_role_detail__c",
            image: resources + "/icons/ic-gsearch--selected.svg",
            type: 'commodity'
        },
        {
            name: "Dangerous Goods",
            selected: false,
            enabled: true,
            field: "Dangerous_Goods__c",
            obj: "icg_account_role_detail__c",
            image: resources + "/icons/ic-gsearch--selected.svg",
            type: 'commodity'
        },
        {
            name: "Live Animals",
            selected: false,
            enabled: true,
            field: "Live_Animals__c",
            obj: "icg_account_role_detail__c",
            image: resources + "/icons/ic-gsearch--selected.svg",
            type: 'commodity'
        },
        {
            name: "Airmail",
            selected: false,
            enabled: true,
            field: "Airmail__c",
            obj: "icg_account_role_detail__c",
            image: resources + "/icons/ic-gsearch--selected.svg",
            type: 'commodity'
        },
        {
            name: "Perishables",
            selected: false,
            enabled: true,
            field: "Perishables__c",
            obj: "icg_account_role_detail__c",
            image: resources + "/icons/ic-gsearch--selected.svg",
            type: 'commodity'
        },
        {
            name: "Pharmaceuticals",
            selected: false,
            enabled: true,
            field: "Pharmaceuticals__c",
            obj: "icg_account_role_detail__c",
            image: resources + "/icons/ic-gsearch--selected.svg",
            type: 'commodity'
        }
    ]

    searchAllTCargo() {
        let shouldDeselectAll = checkIfDeselectAll(this.commodities);
        let allPrograms = [];

        this.commodities.forEach(element => {
            element.selected = !shouldDeselectAll;
            allPrograms.push(element);
        });

        let items = this.template.querySelectorAll("[data-type='commodity']");
        if(shouldDeselectAll){
            this._unselectItems(items);
        }
        else {
            this._selectItems(items);
        }
        this.selectedText = checkIfChangeSelectAllText(this.commodities);


        this.dispatchEvent(new CustomEvent('selectcommodities', { detail: allPrograms }));
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

    onClickItem(event) {
        let eTarget = event.currentTarget;
        let name = eTarget.getAttribute("data-name");

        let selectedComodity;
        let selected;

        this.commodities.forEach(element => {
            if (element.name === name) {
                element.selected = !element.selected;
                selectedComodity = [element];
                selected = element.selected;
            }
        });

        let items = this.template.querySelectorAll("[data-name='" + name + "']");

        if(selected){
            this._selectItems(items);
        }
        else{
            this._unselectItems(items);
        }

        this.selectedText = checkIfChangeSelectAllText(this.commodities);

        this.dispatchEvent(new CustomEvent('selectcommodities', { detail: selectedComodity }));
    }



    _getCommodities(searchList) {
        Object.keys(this.commodities).forEach(element => {
            if (this.commodities[element].selected) {
                const searchObject = {
                    value: this.commodities[element].selected,
                    operator: "=",
                    obj: this.commodities[element].obj,
                    relationfield: this.commodities[element].relationfield,
                    field: this.commodities[element].field
                };
                searchList.push(searchObject);
            }
        });
        return searchList;
    }
}