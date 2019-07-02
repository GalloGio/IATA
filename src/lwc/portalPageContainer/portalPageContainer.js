import { LightningElement,api } from 'lwc';

export default class PortalPageContainer extends LightningElement {

    defaultClass = ' slds-grid slds-grid_align-center slds-p-horizontal_medium ';

    @api
    get styleClass() {
        return this._styleClass;
    }

    set styleClass(value) {
        this._styleClass = this.defaultClass+value;
    }
    
}