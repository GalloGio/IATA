import { LightningElement,api,track } from 'lwc';

export default class cwIntermediateModal extends LightningElement {
    @track modal;
    @api extraClasses;
    @api titleheader = "";
    @api noBackDropGrey = false;
    @track modalStyles = 'slds-modal__container';
    
    @api 
    get modalContainerWidth() {
        return this.modalStyles;
    }
    set modalContainerWidth(value) {
        if(value) {
            this.modalStyles = value;
        }
    }

    @api 
    get modalMessage() {
        return this.modal;
    }
    set modalMessage(value) {
        this.modal = value;
        if(value) {
            let elem = this.template.querySelector('[id*="modalmessage"]');
            if(elem) {
                elem.innerHTML = value;
            }
        }
    }
    @api modalImage;

    closeModal(event) {
        event.preventDefault();
        this.dispatchEvent( new CustomEvent('closemodal'));
    }

    renderedCallback() {
        if (this.modalMessage) {
            let elem = this.template.querySelector('[id*="modalmessage"]');
            if(elem) {
                elem.innerHTML = this.modalMessage;
            }
        }
    }

    get modalStyle() {
        let modalstyles = 'slds-modal__content padding-intermediate-modal overflow-auto ';
        if(this.extraClasses) {
            modalstyles += this.extraClasses;
        }
        return modalstyles;
    }

    get backDropStyle() {
        let backDropStyle = 'slds-backdrop slds-backdrop_open';
        if(this.noBackDropGrey) {
            backDropStyle = ' backdrop-noBackGround';
        }
        return backDropStyle;
    }

    get showHeader() {
        let show = false;
        if(this.titleheader != '') {
            show = true;
        }
        return show;
    }

    get emptyHeader(){
        let headerStyle = 'slds-modal__header slds-modal__header_empty';
        if(this.titleheader != ''){
            headerStyle = 'slds-modal__header';
        }
        return headerStyle;
    }
    get titleHeader(){
        return this.titleheader;
    }


}