import { LightningElement, track, api } from 'lwc';
import PortalPath from '@salesforce/label/c.CSP_PortalPath';

export default class IataModal extends LightningElement {

	@track isOpen = false;
    @api showclosebutton = false;
    @api showhomebutton = false;
	@api roundCorners = false;

    _hideHeader = false;
    @api get hideHeader() {
        return this.displayIcon || this._hideHeader;
    }
    set hideHeader(v) {
        this._hideHeader = v;
    }
	@api hideFooter = false;

    
    @api widthSmall = false;
    @api iconPosition = false;

    //options: x-small | small | medium | large
    @api size = "medium";

    modalContainerBox = "slds-modal__container";
    _bodyClass = "slds-modal__content slds-p-around_medium slds-text-align_left ";

    //options: neutral | info | success | warning | error
    @api variant = "neutral";

    @api backgroundGray = false

    @api
    openModal() {
        this.isOpen = true
    }

    @api
    closeModal() {
        this.isOpen = false
        this.dispatchEvent(new CustomEvent('modalclose'));
	}
	
	@api
	scrollTo(position) {
		this.template.querySelector("div[name='bodyDiv']").scrollTop = position;
	}

    get modalPanelClass() {
		return "panel slds-modal slds-modal_" + this.size +
				(this.isOpen ? " slds-fade-in-open" : "");
	}
	
	get backdropClass() {
		return "slds-backdrop" +
			(this.isOpen ? " slds-backdrop_open" : "");
	}

    get icon(){
		return PortalPath + 
			(this.variant === "success" ?
				"CSPortal/Images/Icons/successIcon.svg" :
				this.variant === "warning" ?
					"CSPortal/Images/Icons/exclamation_point.svg" : "");
    }

    get displayIcon(){
        return this.variant === 'success' || this.variant === 'warning';
	}
	
	get bodyClass() {
		return this._bodyClass + (this.displayIcon ? ' larger-top-padding' : '');
	}

    connectedCallback() {
        if (this.displayBorderRadius) {
            this.bodyCss += ' modalRadius';
        }

        if (this.widthSmall) {
            this.modalContainerBox += ' widthSmall';
        }

        this.modalContainerBox += ' oss-modal_' + this.variant + (this.roundCorners ? ' oss-modal_round-corners' : ' oss-modal_straight-corners');

        if (this.iconPosition) {
            this.bodyCss += ' iconPosition';
        }

        if (this.backgroundGray) {
            this.bodyCss += ' backGroundGray';
        }


    }

    saveMethod() {
        this.closeModal();
    }
}