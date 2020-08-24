import { LightningElement,api,track } from 'lwc';

export default class CwBasicModal extends LightningElement {
    @api label;
    @track modal;
    @api 
    get modalMessage(){
        return this.modal;
    }
    set modalMessage(value){
        this.modal = value;
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