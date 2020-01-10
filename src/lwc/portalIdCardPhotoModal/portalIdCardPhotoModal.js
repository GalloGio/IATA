import { LightningElement, api } from 'lwc';
import cancelLabel from '@salesforce/label/c.Cancel';

export default class PortalIdCardPhotoModal extends LightningElement {

    @api photoUrl;

    labels = {
        cancelLabel
    }

    handleCancel(event){
        this.dispatchEvent(new CustomEvent('closeidcardphotopopup'));
    }

}