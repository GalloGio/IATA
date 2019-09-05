import { LightningElement, api } from 'lwc';

export default class PortalOscarProgressBar extends LightningElement {
    @api progressStatusList;

    connectedCallback() {
        console.log('Progress List: ', JSON.parse(JSON.stringify(this.progressStatusList)) );
    }
}