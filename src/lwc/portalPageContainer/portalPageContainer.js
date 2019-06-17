import { LightningElement,api,track } from 'lwc';

export default class PortalPageContainer extends LightningElement {
    @api
    get styleClass() {
        return this._styleClass;
    }

    set styleClass(value) {
        this._styleClass = value;
    }
}