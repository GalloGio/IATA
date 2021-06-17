import { LightningElement, track, api } from 'lwc';

export default class App extends LightningElement {
    @api selected = false;
    @api label;
    @api value;

    handleSelect(event) {
        //this.selected = true;
        if(this.selected){
            this.selected = false;
        }else{
            this.selected = true;
        } 

		this.dispatchEvent(new CustomEvent('itemselected', { detail: { selected: this.selected, selectedItemId: this.value, selectedItemName:this.label  }}));// sends the event to the grandparent
    }
}