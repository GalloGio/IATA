import { LightningElement, api } from 'lwc';

export default class PortalRegistrationGenericModal extends LightningElement {
    @api icon;
    @api title;
    @api message;
    @api button1Label;
    @api button2Label;

    get displayButton1(){
        return this.button1Label !== '';
    }

    get isIconDefined(){
        return this.icon !== undefined; 
    }

    /**
     * @description Dispatchs the event to the parent element to set the button action
     */
    button1Action(){
        this.dispatchEvent(new CustomEvent('buttononeaction'));
    }

    /**
     * @description Dispatchs the event to the parent element to set the button action
     */
    button2Action(){
        this.dispatchEvent(new CustomEvent('buttontwoaction'));
    }

}