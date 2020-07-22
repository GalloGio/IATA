import { LightningElement, api, track } from "lwc";
import resources from "@salesforce/resourceUrl/ICG_Resources";
import labels from 'c/cwOneSourceLabels';

export default class cwMultiPicklist extends LightningElement {
    label = labels.labels();
    @track picklistElems;
    @track selectedItemsNumber;
    @track allSelected;
    @api
    get elements(){
        return this.picklistElems;
    }
    set elements(elem){
        this.picklistElems = JSON.parse(JSON.stringify(elem));
        this.selectedItemsNumber = this.selectedItems.length;
        this.allSelected = this.picklistElems.length === this.selectedItemsNumber;
    }
    icons = resources + "/icons/";
    ckIcon = this.icons + "ic-tic-green.svg";
    downIcon = this.icons + "icon-plus.svg";

    toggle(event) {
        event.preventDefault();
        let droplist = this.template.querySelector(
            '[id*="droplist"]'
        );
        if (droplist){
            if(droplist.className && droplist.className.indexOf('slds-hide')>-1) droplist.className = droplist.className.replace('hide','show')
            else if(droplist.className && droplist.className.indexOf('slds-show')>-1) droplist.className = droplist.className.replace('show','hide')
        }
    }

    uncheckAll() {
        this.picklistElems.forEach(elem =>{
            elem.selected = false;
        });
        this.sendItems();
    }

    checkAll() {
        this.picklistElems.forEach(elem =>{
            elem.selected = true;
        });
        this.sendItems();
    }

    checkItem (event){
        let val = event.currentTarget.dataset.value;
        this.picklistElems.forEach(elem =>{
            if(elem.value === val) elem.selected = true;
        });
        this.sendItems();
    };

    uncheckItem (event) {
        let val = event.currentTarget.dataset.value;
        this.picklistElems.forEach(elem =>{
            if(elem.value === val) elem.selected = false;
        });
        this.sendItems();
    };
    get selectedItems(){
        let dummyArr = [];
        this.picklistElems.forEach(elem =>{
            if(elem.selected === true) dummyArr.push(elem);
        })
        return dummyArr;
    }
    sendItems(){
        this.dispatchEvent(new CustomEvent('selectitems', { detail: this.picklistElems}));
    }
}