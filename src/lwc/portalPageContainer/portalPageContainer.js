import { LightningElement,api } from 'lwc';

export default class PortalPageContainer extends LightningElement {

    defaultClass = ' slds-grid slds-grid_align-center slds-p-horizontal_medium ';

    @api
    get styleClass() {
        return this._styleClass;
    }

    set styleClass(value) {
        if(value !== undefined){
            this._styleClass = this.defaultClass+value;
        }else{
            this._styleClass = this.defaultClass;
        }
    }

    connectedCallback() {
        if(this.styleClass == undefined){
            this.styleClass = this.defaultClass;
        }
    }
    
}