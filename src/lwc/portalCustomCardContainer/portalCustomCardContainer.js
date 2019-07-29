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


    @track bodyStyle = 'slds-m-horizontal_x-large';

}