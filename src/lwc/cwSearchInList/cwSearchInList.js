import { LightningElement, api } from 'lwc';

export default class CwSearchInList extends LightningElement {
    @api label;
    @api searchValue = '';
    filterInList (event){
        this.searchValue = event.currentTarget.value;
        this.dispatchEvent(new CustomEvent('filterinlist',{detail: event.currentTarget.value}))
    }
    renderedCallback(){
        this.dispatchEvent(new CustomEvent('filterinlist',{detail: this.searchValue}))
    }
}