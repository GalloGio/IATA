import { LightningElement, track, api } from 'lwc';

export default class IataModal extends LightningElement {

	@track isOpen = false;
    @api showclosebutton = false;
    @api showhomebutton = false;
    @api roundCorners = false;

    _hideHeader = false;
    _hideFooter = false;

    @api get hideHeader(){
        return this.displayIcon || this._hideHeader;
    }

    set hideHeader(v){
        this._hideHeader = v;
    }

    @api get hideFooter(){
        return this.displayIcon || this._hideFooter;
    }

    set hideFooter(v){
        this._hideFooter = v;
    }

    @api widthSmall = false;
    @api iconPosition = false;

    //options: x-small | small | medium | large
    @api size = "medium";

    @track modalContainerBox = "slds-modal__container";
    @track bodyClass = "slds-modal__content slds-p-around_medium slds-text-align_left ";

    //options: neutral | info | success | warning | error
    @api variant = "neutral";

    //options: success | warning | error
    @track _variantIcon = '';
    @api get variantIcon(){
        return this._variantIcon;
    }
    set variantIcon(v){
        this._variantIcon = v;
    }

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
        return this.variantIcon === "success" ? "utility:check" : this.variantIcon === "warning" ? "utility:warning" : "utility:close";
    }

    get iconColor(){
        return this.variantIcon === "success" ? "darkGreenIcon" : this.variantIcon === "warning" ? "yellowIcon" : "redIcon";
    }

    get innerCircle(){
        return this.variantIcon === "success" ? "innerCircle innerCircleSuccess" : this.variantIcon === "warning" ? "innerCircle innerCircleWarning" : "innerCircle innerCircleError";
    }

    get outerCircle(){
        return this.variantIcon === "success" ? "outerCircle outerCircleSuccess" : this.variantIcon === "warning" ? "outerCircle outerCircleWarning" : "outerCircle outerCircleError";
    }

    get displayIcon(){
        return this.variantIcon !== undefined && this.variantIcon !== null && this.variantIcon !== '';
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