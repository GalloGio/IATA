import { LightningElement, api, track } from 'lwc';

export default class PortalCustomCardContainer extends LightningElement {
    @api
    get bodyWithoutMargins() {
        return this._bodyWithoutMargins;
    }
    set bodyWithoutMargins(value) {
       
        if(value !== undefined && value !== null){
            if(value===false){
                this.bodyStyle = 'slds-m-horizontal_x-large';
                this._bodyWithoutMargins = false;
            }else{
                this.bodyStyle = '';
                this._bodyWithoutMargins = true;
            }
        }else{
            this.bodyStyle = 'slds-m-horizontal_x-large';
            this._bodyWithoutMargins = false;
        }

    }

    @api specialCard = false;
    @api specialBody = false;

    @track bodyStyle = 'slds-m-horizontal_x-large';
    @track customCardCss = "customLightShadow background-white";

    @track headerCss = "slds-p-top_x-large slds-p-bottom_x-small";

    connectedCallback() {
        if (this.specialCard){
            this.customCardCss = "background-white";
            this.headerCss = "slds-p-bottom_x-small";
        }

        if (this.specialBody){
            this.bodyStyle = 'slds-m-horizontal_medium';
        }
        
    }

}