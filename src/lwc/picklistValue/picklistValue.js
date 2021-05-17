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

		this.dispatchEvent(new CustomEvent('itemselected', { detail: { selected: this.selected, cntrid: this.value, cntrname:this.label  }}));// sends the event to the grandparent
    }
}