import { LightningElement, api } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import MFAStylesResources from '@salesforce/resourceUrl/MFA_StylesApp';

export default class PortalLoginStepContainer extends LightningElement {
	@api styleResources = 'default';

	@api title;
	@api buttonLabel;
	@api backLabel;

	@api removeBackOption = false;
	@api removeButton = false;
	@api removeFooter = false;
	@api removeFooterBorder = false;

	@api linkPClass;

	isButtonDisabled = true;

	/**
	 * @description	Api method to set right button enabled or disabled
	 */
	@api setButtonDisabled(isButtonDisabled){
		this.isButtonDisabled = isButtonDisabled;
	}

	renderedCallback() {
		if(this.styleResources === 'default'){
			loadStyle(this, MFAStylesResources);
		}
	}

	/**
	 * @description	Trigger the button click for the action button
	 */
	triggerBtnClick(){
		this.dispatchEvent(new CustomEvent('buttonclick', {bubbles: true, composed: true, }));
	}

	/**
	 * @description	Trigger the button click for the back button
	 */
	triggerBackLinkClick(){
		this.dispatchEvent(new CustomEvent('backclick', {bubbles: true, composed: true, }));
	}

	/* HTML attributes - START */
	get isBackHidden(){
		return this.removeBackOption;
	}

	get isFooterHidden(){
		return this.removeFooter;
	}

	get isButtonHidden(){
		return this.removeButton;
	}

	get footerClass(){
		if(!this.removeFooterBorder){
			return 'slds-p-vertical_large mfa-footer-border-top slds-m-top_x-large';
		}else{
			return 'slds-p-vertical_medium';
		}
	}

	get linkClass(){
		var classes = "slds-float_right slds-p-right_large slds-text-align_center ";
		classes += this.linkPClass;
		return classes;
	}
	/* HTML attributes - END */
}