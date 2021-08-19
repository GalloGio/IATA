import { LightningElement, api, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import MFAStylesResources from '@salesforce/resourceUrl/MFA_StylesApp';

export default class PortalMfaActivationContainer extends LightningElement {
	@api styleResources = 'default';
	@api isSettings = false;
	@api qrCode;
	@api secret;
	@api translations;
	_otp;
	codeHasError = false;

	/**
	 * @description	Set error on OTP code
	 */
	@api setError(){
		this.codeHasError = true;
		this.template.querySelector('c-portal-mfa-activation-code').setCodeHasError();
	}

	/**
	 * @description	Handle the continue btn dispatch
	 */
	continue2FAProcess(){
		this.dispatchEvent(new CustomEvent("validatemfacode", {bubbles: true, composed: true, detail: {vcode: this._otp}}));		
	}

	renderedCallback() {
		if(this.styleResources === 'default'){
			loadStyle(this, MFAStylesResources);
		}
	}

	/**
	 * @description	Recover the code to validate
	 */
	handleCodeValid(){
		this.codeHasError = false;
		this._otp = this.template.querySelector('c-portal-mfa-activation-code').getCode();
	}

	/**
	 * @description	Display the security question step
	 */
	handleBack(){
		this.dispatchEvent(new CustomEvent("goback"));
	}

	/* HTML attributes - START */
	get isContinueDisabled(){
		return !this._otp || this.codeHasError;
	}

	get labels(){
		return this.translations;
	}
	/* HTML attributes - END */
}