import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
const standClass = 'slds-align_absolute-center';

export default class IataButton extends LightningElement {
	/* eslint-disable no-console */
	/* eslint-disable no-alert */
	@api variant;
	@api label;
	@api fullWidth = false;
	@api errormsg = '';
    @api disabled = false;
    //Vertical Align: top | middle | bottom
    @api verticalAlign = 'middle';
    
    @api icon;
    
    @track _iconSize = 'x-small';
    @api
    get iconSize(){
        return this._iconSize;
    }

    set iconSize(size){
        this._iconSize = size;
    }

    //button variations: contained,outlined,various e text
	//get button div
    @track myClass = '';
    
	get renderedClass() {
		this.myClass = standClass + ' ' + this.variant;
		if (this.disabled) {
			this.myClass += 'Disabled';
		}
		if (this.fullWidth) {
			this.myClass += ' fullWidth';
        }
        this.myClass += ' iata-button-v-align_' + this.verticalAlign;

		return this.myClass;
	}

	handleClick(event) {
        if (!this.disabled) {
            this.onClick(event);
		} else if (this.errormsg !== '') {
			const evt = new ShowToastEvent({
				title: 'Error.',
				message: this.errormsg,
				variant: 'warning',
				mode: 'dismissable'
			});
			this.dispatchEvent(evt);
		}
	}
}