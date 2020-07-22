import { LightningElement,api,track } from 'lwc';

export default class CwBasicModal extends LightningElement {
    @api label;
    @track _modalMessage;
    @api 
    get modalMessage(){
        return this._modalMessage;
    }
    set modalMessage(value){
        this._modalMessage = value;
        if(value){
            let elem = this.template.querySelector('[id*="modalmessage"]');
            if(elem) elem.innerHTML = value;
        }
    }
    @api modalImage;

    closeModal(event){
        event.preventDefault();
        this.dispatchEvent( new CustomEvent('closemodal'));
    }

    renderedCallback(){
        if (this.modalMessage){
            let elem = this.template.querySelector('[id*="modalmessage"]');
            if(elem) elem.innerHTML = this.modalMessage;
        }
    }
}