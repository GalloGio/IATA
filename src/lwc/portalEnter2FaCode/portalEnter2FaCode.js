import { api, LightningElement, track } from 'lwc';

export default class PortalEnter2FaCode extends LightningElement {
	@api translations;

	_hideResetSection = true;
	_correctCode = false;
	_otp;

	/**
	 * @description	Set error on child component
	 */
	@api setError(msg){
		this.template.querySelector('c-portal-mfa-activation-code').setCodeHasError(msg);
	}
	
	/**
	 * @description	Show the reset section
	 */
	displayResetSection(){
		this._hideResetSection = !this._hideResetSection;
	}

	/**
	 * @description	Get the entered code from child component
	 */
	handleCodeValid(){
		this._otp = this.template.querySelector('c-portal-mfa-activation-code').getCode();
		if (this._otp && this._otp.length === 6) {
			this.template.querySelector('c-portal-login-step-container').setButtonDisabled(false);	
		}else{
			this.template.querySelector('c-portal-login-step-container').setButtonDisabled(true);
		}
	}

	/**
	 * @description	Dispatch the reset event
	 */
	reset2FA(){
		this.dispatchEvent(new CustomEvent('reset', {bubbles: true, composed: true,}));
	}

	/**
	 * @description	Dispatch the login event with the entered code
	 */
	loginHandle(){
		this.dispatchEvent(new CustomEvent("validatemfacode", {bubbles: true, composed: true, detail: {vcode: this._otp}}));
	}

	/* HTML attributes */
	get isResetSectionHidden(){
		return this._hideResetSection;
	}
	
	get labels(){
		return this.translations;
	}

}