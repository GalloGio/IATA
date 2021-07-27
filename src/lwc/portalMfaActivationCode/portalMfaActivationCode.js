import { LightningElement, api, track } from 'lwc';
import { labelUtil } from 'c/portalLabels';

export default class PortalMfaActivationCode extends LightningElement {
	@track labels; 

	@api isOnlyInput = false;
	@api actualCode;
	@api length = 3;

	_codeHasError = false;
	_pastedCodeFullyFilled = true;

	_codeVal = [];
	inputCode;

	/**
	 * @description	Loads the translated labels 
	 */
	connectedCallback(){
		for(let i = 0; i<this.length; i++){
			this._codeVal.push(null);
		}

		var container = this;
		labelUtil.getTranslations().then((result) => {
			container.labels = result;
		});
	}

	renderedCallback(){
		if(!this.inputCode && this._codeVal[0] === null ){
			var inputElements = this.template.querySelectorAll('input');
			if(inputElements && inputElements.length > 0){
				inputElements[0].focus();
			}
		}
	}

	/**
	 * Method to set the code and navigate through the multiple inputs that can exist
	 * @param {*} event Dispatched event, can be triggered inputting a value on the input fields
	 */
	setInput(event){
		let elem = event.target;
		let pos = parseInt(elem.dataset.pos);
		let posInList = pos-1;

		//Control CTRL+V action + Paste action
		if(this._pastedCodeFullyFilled){
			if(isNaN(elem.value) || elem.value === undefined || elem.value === ' ' || elem.value === ''){
				//Only allow numeric values in inputs
				let currentInput = this.template.querySelector(`[data-pos="${pos}"]`);
				currentInput.value = null;
				return;
			}
			this._codeHasError = false;
			this._codeVal[posInList] = elem.value;

			if (pos !== this.maxLength) {
				//Navigate between inputs once value is inserted
				let nextPos = (pos + 1);
				let nextInput = this.template.querySelector(`[data-pos="${nextPos}"]`);
				nextInput.focus();
			}else{
				//Once every input has a value, check if code is same
				if(!this._codeVal.includes(null)){
					this.inputCode = this._codeVal.join('');
					this.isCodeSet();
				}
			}
		}else{
			this._pastedCodeFullyFilled = true;
			let currentInput = this.template.querySelector(`[data-pos="${pos}"]`);
			currentInput.value = null;
			currentInput.focus();
		}
	}

	/**
	 * Method to handle the onkeyup event
	 */
	removeValues(event){
		let elem = event.target;
		let pos = parseInt(elem.dataset.pos);
		let posInList = pos-1;
		if(event.keyCode === 8){
			//When delete, return to previous input
			if(posInList !== 0){
				//In last position input it should just remove the value
				let prevInput;
				if(posInList === (this.maxLength-1) && this._codeVal[posInList] != null){
					prevInput = this.template.querySelector(`[data-pos="${pos}"]`);

				}else{
					prevInput = this.template.querySelector(`[data-pos="${posInList}"]`);
				}
				prevInput.value = null;
				this._codeVal[posInList] = null;
				this.inputCode = null;
				prevInput.focus();
				this.isCodeSet();
			}
			return;
		}
	}

	/**
	 * Method that filles the code up whenever the code is pasted
	 */
	fillCodeUp(event){
		let clipboard = (event.clipboardData || window.clipboardData).getData('text');
		let codeFullyFilled = false;
		let latestInputPos = 0;
		for (let i = 0; i < this.length; i++) {
			const character = clipboard[i];
			let currentInput = this.template.querySelector(`[data-pos="${i+1}"]`);
			if (character !== undefined && character !== ' ' && character !== '' && !isNaN(character)) {
				this._codeVal[i] = character;
				currentInput.value = character;
				if (i === (this.length-1)) {
					codeFullyFilled = true;
				}
			}else{
				latestInputPos = i;
				currentInput.value = null;
				currentInput.focus();
				break;
			}
		}
		if(codeFullyFilled){
			let lastInput = this.template.querySelector(`[data-pos="${this.length-1}"]`);
			lastInput.focus();
			this.inputCode = this._codeVal.join('');
			this.isCodeSet();
		}else{
			this._pastedCodeFullyFilled = false;
			for (let index = latestInputPos; index < this.length; index++) {
				let inputToEmpty = this.template.querySelector(`[data-pos="${index+1}"]`);
				inputToEmpty.value = null;
			}
		}
	}

	@api getCode(){
		return this.inputCode;
	}

	@api setCodeHasError(msg){
		if (msg) {
			console.log('___portalMfaActivationCode - Two Factor authentication returned the following exception message: ' + msg);
		}
		this._codeHasError = true;
	}

	isCodeSet(){
		this.dispatchEvent(new CustomEvent("codeset"));
	}

	get maxLength(){
		return parseInt(this.length);
	}

	get dataPositions(){
		let positions = [];
		for(let i = 0; i<this.length; i++){
			positions.push(i+1);
		}
		return positions;
	}

	get separatorClass(){
		if(this.isOnlyInput){
			return '';
		}
		return "slds-grid slds-align_absolute-center slds-p-top_medium"
	}

	get borderClass(){
		let classes = "border-small slds-align_absolute-center slds-p-horizontal_medium slds-p-vertical_small";
		if(this._codeHasError){
			return classes + " error";
		}
		return classes;
	}
}