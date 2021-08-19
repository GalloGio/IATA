import { LightningElement, track, api } from 'lwc';
import { util } from 'c/portalUtility';

export default class PortalMfaReset2Fa extends LightningElement {
	@api securityQuestion;
	@api translations;
	answer;
	_codeHasError = false;

	@api setCodeHasError(){
		this._codeHasError = true;
	}

	/**
	 * @description	Dispatch checkanswer event with the introduced answer
	 */
	submitHandle(){
		this.dispatchEvent(new CustomEvent("checkanswer", {bubbles: true, composed: true, detail: {answer: this.answer}}));
	}

	/**
	 * @description	Dispatch goback event
	 */
	navigateStepBack(){
		this.dispatchEvent(new CustomEvent("goback", {bubbles: true, composed: true}));
	}

	/**
	 * @description	Manage that answer is only updated when user spends 100 ms without typing down.
	 */
	debouncedAnswerUpdate = util.debounce((info) => {
		this.answer = info.value;
	}, 100);

	/**
	 * @description	Update introduced answer information and disable child component button
	 */
	updateAnswer(event) {
		event.target.setCustomValidity('');
		this.debouncedAnswerUpdate({
			value : event.target.value
		});
		this.template.querySelector('c-portal-login-step-container').setButtonDisabled(false);
	}


	/* HTML attributes - START */
	get answerInputClasses(){
		let classes = 'slds-input mfa-text-input'
		if(this._codeHasError){
			classes += ' error-border'
		}
		return classes;
	}
	
	get labels(){
		return this.translations;
	}
	/* HTML attributes - END */
}