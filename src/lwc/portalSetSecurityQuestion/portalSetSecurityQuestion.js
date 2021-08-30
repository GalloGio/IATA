import { LightningElement, api, track } from 'lwc';
import { loadStyle } from 'lightning/platformResourceLoader';
import { util } from 'c/portalUtility';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';

import MFAStylesResources from '@salesforce/resourceUrl/MFA_StylesApp';

export default class PortalSetSecurityQuestion extends LightningElement {
	@api isSettings = false;
	@api displayIntroInfo = false;
	@api styleResources = 'default';
	@api userQuestion = '';
	@api translations;
	userAnswer = '';
	disableButton = false;
	hideCeteredBtn = false;
	successfulSave = false;
	
	renderedCallback() {
		if(this.styleResources === 'default'){
			loadStyle(this, MFAStylesResources);
		}

		const inputElems = this.template.querySelectorAll('input');
		inputElems.forEach(elem =>{
			if(elem.type === 'password'){
				elem.type = 'text';
				elem.removeAttribute('autocomplete');
			}
		});
	}

	debouncedQuestionUpdate = util.debounce((info) => {
		this.userQuestion = info.value;
	}, 100);

	debouncedAnswerUpdate = util.debounce((info) => {
		this.userAnswer = info.value;
	}, 100);

	updateQuestion(event){
		this.debouncedQuestionUpdate({
			value : event.target.value
		});
	}

	updateAnswer(event){
		this.debouncedAnswerUpdate({
			value : event.target.value
		});
	}

	@api hideModal(){
		this.dispatchEvent(new CustomEvent('closemodal', {bubbles: true, composed: true,}));
	}

	saveInformation(){
		this.saveSecurityQuestion();
	}

	goToNextStep(){
		this.saveSecurityQuestion();
	}

	saveSecurityQuestion(){
		this.dispatchEvent(new CustomEvent('savesecurityquestion', {bubbles: true, composed: true, detail :{ question: this.userQuestion, answer: this.userAnswer}}));
	}

	showNotification(title, msg, variant) {
		const evt = new ShowToastEvent({
			title: title,
			message: msg,
			variant: variant,
		});
		this.dispatchEvent(evt);
	}

	disableInputFields(){
		const inputElems = this.template.querySelectorAll('input');
		inputElems.forEach(elem =>{
			elem.disabled = true;
		});
		
		this.disableButton = true;
		this.hideCeteredBtn = true;
	}

	get containerClass(){
		var classList = ['slds-theme_default', 'slds-p-vertical_large', 'mfa-text-center', 'slds-p-horizontal_large', 'slds-p-vertical_xx-large'];
		if (this.displayIntroInfo) {
			classList.push('slds-large-size_5-of-6');
			classList.push('slds-x-small-size_1-of-1');
		}
		return classList.join(' ');
	}

	get secQandAClass(){
		if(!this.isOnSettings){
			return 'slds-p-horizontal_x-large';
		}else{
			let classes = 'slds-p-bottom_x-large';
			if (this.showCenteredBtn) {
				classes += ' slds-p-horizontal_xx-large';
			}
			return classes;
		}
	}

	get isOnSettings(){
		return this.isSettings;
	}

	get isContinueDisabled(){
		return !this.userAnswer || !this.userQuestion || this.disableButton;
	}

	get currentUserQuestion(){
		return this.userQuestion;
	}

	get currentUserAnswer(){
		return this.userAnswer;
	}

	get showCenteredBtn(){
		return (!this.isSettings || this.displayIntroInfo) && !this.hideCeteredBtn;
	}

	get showSuccessLbl(){
		return this.showCenteredBtn && this.successfulSave;
	}

    get isSaveDisabled(){
        return !this.userAnswer || !this.userQuestion
    }

	get labels(){
		return this.translations;
	}

	get secQuestionClass(){
		if(this.displayIntroInfo){
			return "slds-grid";
		}
		return "";
	}

	get btnDivClass(){
		if(this.showCenteredBtn){
			return "slds-p-horizontal_large slds-grid slds-gutters slds-align_absolute-center";
		}
		return "slds-p-horizontal_large slds-grid slds-gutters";
	}
}