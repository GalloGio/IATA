import { LightningElement,api,track } from 'lwc';

export default class PortalWarningBanner extends LightningElement {

    @track label = '';

    @api
    get labelInput(){
        return this.label;
    }
    set labelInput(value){
        this.label = value;
    }


}