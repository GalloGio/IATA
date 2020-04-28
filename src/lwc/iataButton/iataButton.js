import { LightningElement, api, track } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

export default class IataButton extends LightningElement {
	/* eslint-disable no-console */
	/* eslint-disable no-alert */
	@api name;
	@api variant = 'base';
	@api label;
	@api errormsg = "";
    @api disabled = false;
    //Vertical Align: top | middle | bottom
	@api verticalAlign = "middle";
	@api textAlign = "center";
	@api smallText = false;
	/** flex | medium | large | full */
	@api width = 'flex';
	@api heightLarge = false;
    
    @api icon;
    @track _iconSize = "x-small";
	@track _iconPosition = "left";

	@api get iconSize(){
        return this._iconSize;
    }

    set iconSize(size){
        this._iconSize = size;
    }

	@api get iconLeft() {
		return this.icon && this._iconPosition === "left";
	}

	set iconLeft(v) {
		this._iconPosition = "left";
	}

	@api get iconRight() {
		return this.icon && this._iconPosition === "right";
	}

	set iconRight(v) {
		this._iconPosition = "right";
	}

	get iconColor() {
		return this.variant === "contained" ?
			"#FFFFFF" :
			"3333ff";
	}

	get fullWidth() {
		return this.width === 'full';
	}

	get widthLarge() {
		return this.width === 'large';
	}

	get widthMedium() {
		return this.width === 'medium';
	}

	get alignLeft() {
		return this.textAlign === 'left';
	}

	get alignRight() {
		return this.textAlign === 'right';
	}

    get renderedClass() {
		return  (this.alignLeft ? 
					'slds-text-align_left slds-var-p-left_small ' :
					this.alignRight ?
						'slds-text-align_right ' :
						'slds-text-align_center ') +
				this.variant +
				' iata-button-v-align_' + this.verticalAlign +
				(this.fullWidth ? 
					' full-width' :
					this.widthLarge ?
						' width-large' :
						this.widthMedium ?
							' width-medium' :
							' width-flex') +
				(this.heightLarge ? ' height-large' : '') +
				(this.smallText ? ' slds-text-body_regular ' : ' slds-text-heading_small');
				
	}

	handleClick(event) {
        if (!this.disabled) {
			
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