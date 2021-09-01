import { LightningElement, api } from 'lwc';
import { labelUtil } from 'c/portalLabels';
export default class PortalCustomMFAContainer extends LightningElement {
	/* ==============================================================================================================*/
	/* Attributes
	/* ==============================================================================================================*/
	@api hasMFAEnabled;
	@api hasQuestionAndAnswer;
	@api hasAuthConfigured;
	@api isResetMFA;
	@api securityQuestion;
	labels;
	qrCode;
	secret;
	isLoading = true;
	otpCode;
	showQuestionAndAnser = false;
	
	//Init
	renderedCallback(){
		this.updateLoginFlowStep();
	}

	/**
	 * @description	Loads the translated labels 
	 */
	connectedCallback(){
		var container = this;
		labelUtil.getTranslations().then((result) => {
			container.labels = result;
			if (this.template.querySelector('c-portal-login-container')) {
				this.template.querySelector('c-portal-login-container').handleTranslations(this.translations);
			}
			this.isLoading = false;
		});
	}

	/**
	 * @description	Finish the login flow if the MFA is not enabled
	 */
	updateLoginFlowStep(){
		if(this.hasMFAEnabled !== 'true'){
			this.finishFlow();
		}
	}

	/**
	 * @description	Set security question
	 */
	@api setSecurityQuestion(question){
		this.securityQuestion = question;
	}

	/**
	 * @description	Set formatted qr Code 
	 */
	@api setQRCode(qrCode){
		this.qrCode = qrCode.replaceAll('&amp;', '&');
	}

	/**
	 * @description	Set secret
	 */
	@api setSecret(secret){
		this.secret = secret;
	}

	/**
	 * @description	Set error on children components
	 */
	@api setError(){
		if(this.template.querySelector('c-portal-mfa-activation-container')){
			this.template.querySelector('c-portal-mfa-activation-container').setError();
		}else{
			this.template.querySelector('c-portal-enter2-fa-code').setError();
		}
	}

	/**
	 * @description	Set error on mfa reset component
	 */
	@api setValidationError(){
		if (this.template.querySelector('c-portal-mfa-reset-2-fa')) {
			this.template.querySelector('c-portal-mfa-reset-2-fa').setCodeHasError();
		}
	}

	/**
	 * @description	Method to refresh components hasMFAEnabled, hasQuestionAndAnswer, hasAuthConfigured controlling variables
	 */
	@api refresh(hasMFAEnabled, hasQuestionAndAnswer, hasAuthConfigured){
		this.hasMFAEnabled = hasMFAEnabled;
		this.hasQuestionAndAnswer = hasQuestionAndAnswer;
		this.hasAuthConfigured = hasAuthConfigured;
	}

	/**
	 * @description	Hide spinner in component
	 */
	@api finishLoad(){
		this.showQuestionAndAnser = false;
		this.isLoading = false;
	}

	/**
	 * @description	Show spinner in component
	 */
	@api startLoad(){
		this.isLoading = true;
	}

	/**
	 * @description	Set the one time password code
	 */
	setOPT(event){
		this.otpCode = event.detail.value;
	}

	/**
	 * @description	Display the security question and anser section
	 */
	displaySecurityQuestion(){
		this.showQuestionAndAnser = true;
	}
	
	/* HTML attributes */
	get stepResetMFA(){
		return this.hasQuestionAndAnswer === 'true' && this.hasAuthConfigured === 'true' && this.hasMFAEnabled === 'true' && this.isResetMFA === 'true';
	}

	get stepQA(){
		return (this.hasQuestionAndAnswer !== 'true' && this.hasMFAEnabled === 'true' && this.hasAuthConfigured !== 'true') || this.showQuestionAndAnser;
	}

	get stepSetAuth(){
		let showSetAuth = (this.hasQuestionAndAnswer === 'true' && this.hasAuthConfigured !== 'true' && this.hasMFAEnabled === 'true' && !this.showQuestionAndAnser);	
			
		if(showSetAuth && !this.qrCode ){			
			showSetAuth = true;
			this.dispatchEvent(new CustomEvent('initregistertotp', {bubbles: true, composed: true,}));
		}
		return showSetAuth;
	}

	get stepCode(){
		return this.hasQuestionAndAnswer === 'true' && this.hasAuthConfigured === 'true' && this.hasMFAEnabled === 'true' && this.isResetMFA !== 'true';
	}

	get translations(){
		return this.labels;
	}
	/* HTML attributes - END*/

	/**
	 * @description	Toggle reset mfa section display
	 */
	toggleResetMFA(){
		if (this.isResetMFA != 'true') {
			this.isResetMFA = 'true';
		}else{
			this.isResetMFA = 'false';
		}
	}

	/**
	 * @description	Finish lightning flow
	 */
	finishFlow(){
		this.dispatchEvent(new CustomEvent('finishFlow', {bubbles: true, composed: true,}));
	}
	
}