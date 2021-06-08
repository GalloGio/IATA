import { LightningElement, api } from 'lwc';

export default class IgModal extends LightningElement {
    @api header = '';
    @api acceptDisabled = false;
    _acceptButtonLabel = 'Accept';
    @api set acceptButtonLabel(value) {
        this._acceptButtonLabel = value;
    };
    get acceptButtonLabel() {
        return this._acceptButtonLabel;
    }
    @api disabled = false;
    @api hideCancel = false;
    @api removeClose = false;
    @api
    hide() {
        this.template.querySelector('.slds-backdrop').classList.remove('slds-backdrop_open');
        this.template.querySelector('.slds-modal').classList.remove('slds-fade-in-open');
    }
    @api
    show() {
        this.template.querySelector('.slds-backdrop').classList.add('slds-backdrop_open');
        this.template.querySelector('.slds-modal').classList.add('slds-fade-in-open');
    }
    acceptClickHandler(ev) {
        this.dispatchEvent(new CustomEvent("accept"));
    }
}